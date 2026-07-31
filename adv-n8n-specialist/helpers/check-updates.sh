#!/usr/bin/env bash
# n8n-specialist :: check-updates.sh
#
# Triangula 4 fontes para detectar updates do n8n self-hosted Adventure:
#   1. npm registry             — versão shippable (semver MAJOR.MINOR.PATCH)
#   2. GitHub releases          — release notes estruturadas (Bug Fixes, Features)
#   3. Docker Hub manifest      — digest atual de docker.n8n.io/n8nio/n8n:latest
#                                 (camada que MAIS importa: docker-compose VPS usa :latest)
#   4. Versão no container VPS  — `docker exec adv-n8n n8n --version` via ssh hostinger
#
# Output: JSON em stdout + persiste estado em ~/.claude/state/n8n-version-watch.json
# Exit codes: 0=none, 5=docs/digest_only, 10=patch, 20=minor_plus, 30=breaking, 25=infra_debt.
#
# Uso:
#   ./check-updates.sh                  # roda completo
#   ./check-updates.sh --json-only      # só JSON, exit 0
#   ./check-updates.sh --skip-vps       # pula ssh hostinger
#
# Pré: jq, curl, gh (opcional — fallback anônimo se ausente), ssh hostinger (opcional)

set -euo pipefail

STATE_DIR="${HOME}/.claude/state"
STATE_FILE="${STATE_DIR}/n8n-version-watch.json"
mkdir -p "$STATE_DIR"

JSON_ONLY=0
SKIP_VPS=0
for arg in "$@"; do
  case "$arg" in
    --json-only) JSON_ONLY=1 ;;
    --skip-vps)  SKIP_VPS=1 ;;
    -h|--help)   sed -n '2,18p' "$0"; exit 0 ;;
  esac
done

require() { command -v "$1" >/dev/null 2>&1 || { echo "missing: $1" >&2; exit 2; }; }
require curl
require jq

# ── 1. npm registry ─────────────────────────────────────────────────────────
NPM_LATEST="$(curl -s --max-time 15 https://registry.npmjs.org/n8n/latest | jq -r '.version // empty')"
[ -z "$NPM_LATEST" ] && NPM_LATEST="unknown"

# ── 2. GitHub releases (top 10) ─────────────────────────────────────────────
GH_RELEASES_JSON='[]'
if command -v gh >/dev/null 2>&1; then
  GH_RELEASES_JSON="$(gh api 'repos/n8n-io/n8n/releases?per_page=10' 2>/dev/null | \
    jq '[.[] | {tag: .tag_name, name: .name, published: .published_at, body_preview: (.body // "" | .[0:800])}]' || echo '[]')"
else
  GH_RELEASES_JSON="$(curl -s --max-time 15 'https://api.github.com/repos/n8n-io/n8n/releases?per_page=10' | \
    jq '[.[]? | {tag: .tag_name, name: .name, published: .published_at, body_preview: (.body // "" | .[0:800])}]' || echo '[]')"
fi
# Filtra releases com tag versionada (n8n@X.Y.Z), ignora "stable" rolling tag
GH_LATEST_TAG="$(echo "$GH_RELEASES_JSON" | jq -r '[.[] | select(.tag | test("^n8n@[0-9]+\\.[0-9]+\\.[0-9]+$"))][0].tag // empty')"
[ -z "$GH_LATEST_TAG" ] && GH_LATEST_TAG="unknown"
GH_LATEST_VER="${GH_LATEST_TAG#n8n@}"

# ── 3. Docker Hub manifest digest ───────────────────────────────────────────
# Tags reais ficam em n8nio/n8n (Docker Hub) — docker.n8n.io é alias
DOCKER_HUB_JSON="$(curl -s --max-time 15 \
  'https://hub.docker.com/v2/repositories/n8nio/n8n/tags/latest' 2>/dev/null || echo '{}')"
DOCKER_LATEST_DIGEST="$(echo "$DOCKER_HUB_JSON" | jq -r '.digest // .images[0].digest // empty')"
DOCKER_LATEST_LAST_UPDATED="$(echo "$DOCKER_HUB_JSON" | jq -r '.last_updated // empty')"
[ -z "$DOCKER_LATEST_DIGEST" ] && DOCKER_LATEST_DIGEST="unknown"

# ── 4. Versão real no container VPS ─────────────────────────────────────────
VPS_VERSION="skipped"
if [ "$SKIP_VPS" -eq 0 ] && command -v ssh >/dev/null 2>&1; then
  VPS_VERSION="$(ssh -o ConnectTimeout=10 -o BatchMode=yes hostinger \
    'docker exec adv-n8n n8n --version 2>/dev/null' 2>/dev/null | tr -d '\r\n ' || echo unreachable)"
  [ -z "$VPS_VERSION" ] && VPS_VERSION="unknown"
fi

# ── Diff contra estado anterior ─────────────────────────────────────────────
NOW="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
PREV_NPM=""; PREV_DIGEST=""; PREV_GH=""; PREV_VPS=""
if [ -f "$STATE_FILE" ]; then
  PREV_NPM="$(jq -r '.npm_latest // empty' "$STATE_FILE" 2>/dev/null)"
  PREV_DIGEST="$(jq -r '.docker_latest_digest // empty' "$STATE_FILE" 2>/dev/null)"
  PREV_GH="$(jq -r '.gh_latest_tag // empty' "$STATE_FILE" 2>/dev/null)"
  PREV_VPS="$(jq -r '.vps_version // empty' "$STATE_FILE" 2>/dev/null)"
fi

# Semver delta (M.m.p)
classify_semver_delta() {
  local prev="$1" curr="$2"
  [ -z "$prev" ] || [ "$prev" = "$curr" ] && { echo "none"; return; }
  local pm pmm cm cmm
  pm="$(echo "$prev"  | cut -d. -f1)"; pmm="$(echo "$prev"  | cut -d. -f2)"
  cm="$(echo "$curr"  | cut -d. -f1)"; cmm="$(echo "$curr"  | cut -d. -f2)"
  if [ "$pm" != "$cm" ]; then echo "major"
  elif [ "$pmm" != "$cmm" ]; then echo "minor"
  else echo "patch"
  fi
}

NPM_DELTA="$(classify_semver_delta "$PREV_NPM" "$NPM_LATEST")"

DIGEST_CHANGED="false"
[ -n "$PREV_DIGEST" ] && [ "$PREV_DIGEST" != "$DOCKER_LATEST_DIGEST" ] && DIGEST_CHANGED="true"

# Breaking detection (regex em releases top 3)
BREAKING_HITS="$(echo "$GH_RELEASES_JSON" | jq -r '.[0:3] | map(.body_preview) | join("\n") |
  ascii_downcase | [scan("breaking|removed|deprecated|migration guide")] | length' 2>/dev/null || echo 0)"
HAS_BREAKING="false"; [ "$BREAKING_HITS" -gt 0 ] && HAS_BREAKING="true"

# Infra-debt: VPS está ≥2 minors atrás do npm latest?
INFRA_DEBT="false"
if [ "$VPS_VERSION" != "unreachable" ] && [ "$VPS_VERSION" != "skipped" ] && [ "$VPS_VERSION" != "unknown" ]; then
  vps_minor="$(echo "$VPS_VERSION" | cut -d. -f2 2>/dev/null || echo 0)"
  npm_minor="$(echo "$NPM_LATEST"  | cut -d. -f2 2>/dev/null || echo 0)"
  vps_major="$(echo "$VPS_VERSION" | cut -d. -f1 2>/dev/null || echo 0)"
  npm_major="$(echo "$NPM_LATEST"  | cut -d. -f1 2>/dev/null || echo 0)"
  if [ "$vps_major" -lt "$npm_major" ] 2>/dev/null; then
    INFRA_DEBT="true"
  elif [ "$vps_major" = "$npm_major" ] && [ $((npm_minor - vps_minor)) -ge 2 ] 2>/dev/null; then
    INFRA_DEBT="true"
  fi
fi

# Tier final
TIER="none"
case "$NPM_DELTA" in
  major) TIER="minor_plus" ;;
  minor) TIER="minor_plus" ;;
  patch) TIER="patch" ;;
esac
[ "$HAS_BREAKING" = "true" ] && TIER="breaking"
[ "$INFRA_DEBT"   = "true" ] && [ "$TIER" = "none" ] && TIER="infra_debt"
[ "$TIER" = "none" ] && [ "$DIGEST_CHANGED" = "true" ] && TIER="digest_only"

OUTPUT="$(jq -n \
  --arg now "$NOW" \
  --arg npm "$NPM_LATEST" \
  --arg gh_tag "$GH_LATEST_TAG" \
  --arg gh_ver "$GH_LATEST_VER" \
  --arg digest "$DOCKER_LATEST_DIGEST" \
  --arg docker_last_updated "$DOCKER_LATEST_LAST_UPDATED" \
  --arg vps "$VPS_VERSION" \
  --argjson releases "$GH_RELEASES_JSON" \
  --arg prev_npm "$PREV_NPM" \
  --arg prev_digest "$PREV_DIGEST" \
  --arg prev_vps "$PREV_VPS" \
  --arg npm_delta "$NPM_DELTA" \
  --arg digest_changed "$DIGEST_CHANGED" \
  --arg has_breaking "$HAS_BREAKING" \
  --arg infra_debt "$INFRA_DEBT" \
  --arg tier "$TIER" \
  '{
    last_check: $now,
    npm_latest: $npm,
    gh_latest_tag: $gh_tag,
    gh_latest_version: $gh_ver,
    docker_latest_digest: $digest,
    docker_last_updated: $docker_last_updated,
    vps_version: $vps,
    gh_recent_releases: $releases,
    prev: { npm: $prev_npm, digest: $prev_digest, vps: $prev_vps },
    delta: {
      npm: $npm_delta,
      digest_changed: ($digest_changed == "true"),
      has_breaking: ($has_breaking == "true"),
      infra_debt: ($infra_debt == "true"),
      tier: $tier
    }
  }')"

echo "$OUTPUT" > "$STATE_FILE"
echo "$OUTPUT"

[ "$JSON_ONLY" -eq 1 ] && exit 0

case "$TIER" in
  breaking)    exit 30 ;;
  infra_debt)  exit 25 ;;
  minor_plus)  exit 20 ;;
  patch)       exit 10 ;;
  digest_only) exit 5  ;;
  *)           exit 0  ;;
esac
