#!/usr/bin/env bash
# n8n-specialist :: diagnose-n8n.sh
#
# Diagnose seguro do n8n self-hosted Adventure — sem despejar encryption key
# ou tokens. Cobre: container up, version, workflows ativos/total, last 10
# executions globais (ou por workflow se --workflow), e via host:
#   - free disk no volume n8n_data
#   - load avg do container
#   - últimas 30 linhas de log com secrets filtrados
#
# Uso:
#   ./diagnose-n8n.sh                          # geral
#   ./diagnose-n8n.sh --workflow csuite-buffett
#   ./diagnose-n8n.sh --container-only         # só `docker exec`, sem API
#
# Pré: api-call.sh + ssh hostinger para checagens via container.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

WF_NAME=""
CONTAINER_ONLY=0
while [ $# -gt 0 ]; do
  case "$1" in
    --workflow)       WF_NAME="$2"; shift 2 ;;
    --container-only) CONTAINER_ONLY=1; shift ;;
    -h|--help) sed -n '2,14p' "$0"; exit 0 ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done

echo "═══ n8n diagnose · $(date -u +%Y-%m-%dT%H:%M:%SZ) ═══"
echo ""

# ── 1. Container ────────────────────────────────────────────────────────────
echo "── 1. Container adv-n8n ──"
if command -v ssh >/dev/null 2>&1; then
  ssh -o ConnectTimeout=10 hostinger 'docker ps --filter name=adv-n8n --format "table {{.Names}}\t{{.Status}}\t{{.Image}}"' 2>/dev/null || echo "[FAIL] ssh hostinger"
  echo ""
  echo "── 2. n8n version no container ──"
  ssh -o ConnectTimeout=10 hostinger 'docker exec adv-n8n n8n --version 2>/dev/null' 2>/dev/null || echo "[FAIL] docker exec"
  echo ""
  echo "── 3. Disco do volume n8n_data ──"
  ssh -o ConnectTimeout=10 hostinger 'docker exec adv-n8n df -h /home/node/.n8n 2>/dev/null | tail -1' 2>/dev/null || echo "[FAIL]"
fi

if [ "$CONTAINER_ONLY" -eq 1 ]; then
  echo ""
  echo "═══ (container-only) ═══"; exit 0
fi

# ── 4. API: workflows ativos ────────────────────────────────────────────────
echo ""
echo "── 4. Workflows totais (ativos / inativos) ──"
WORKFLOWS_JSON="$("$SCRIPT_DIR/api-call.sh" GET "/api/v1/workflows?limit=250" 2>/dev/null || echo '{}')"
TOTAL="$(echo "$WORKFLOWS_JSON" | jq '.data | length // 0')"
ACTIVE="$(echo "$WORKFLOWS_JSON" | jq '[.data[]? | select(.active == true)] | length // 0')"
echo "  total = $TOTAL · ativos = $ACTIVE"

# ── 5. Workflow específico ──────────────────────────────────────────────────
if [ -n "$WF_NAME" ]; then
  echo ""
  echo "── 5. Workflow '$WF_NAME' ──"
  echo "$WORKFLOWS_JSON" | jq --arg s "$WF_NAME" '
    [.data[]? | select(.name == $s)] | first
    | {id, name, active, tags: [.tags[]?.name], updatedAt}
  '
  WF_ID="$(echo "$WORKFLOWS_JSON" | jq -r --arg s "$WF_NAME" '[.data[]? | select(.name == $s)][0].id // empty')"
  if [ -n "$WF_ID" ]; then
    echo ""
    echo "── 6. Últimas 10 execuções de '$WF_NAME' ──"
    "$SCRIPT_DIR/api-call.sh" GET "/api/v1/executions?workflowId=$WF_ID&limit=10" 2>/dev/null \
      | jq '[.data[]? | {id, status, startedAt, stoppedAt, mode, retryOf}]'
  fi
else
  echo ""
  echo "── 5. Últimas 10 execuções globais ──"
  "$SCRIPT_DIR/api-call.sh" GET "/api/v1/executions?limit=10" 2>/dev/null \
    | jq '[.data[]? | {id, status, startedAt, workflowName: .workflowData.name // null, mode}]'
fi

# ── 7. Log tail do container (secrets filtrados) ────────────────────────────
if command -v ssh >/dev/null 2>&1; then
  echo ""
  echo "── 7. Últimas 30 linhas de log (secrets filtrados) ──"
  ssh -o ConnectTimeout=10 hostinger \
    'docker logs --tail 30 adv-n8n 2>&1 | sed -E "s/(N8N_ENCRYPTION_KEY|N8N_API_TOKEN|INFISICAL_TOKEN|password|secret|apiKey)[\"]?[: ]+[^,\"\\s}]+/\1=***REDACTED***/gi"' 2>/dev/null \
    || echo "[FAIL] logs"
fi

echo ""
echo "═══ Diagnose completo ═══"
