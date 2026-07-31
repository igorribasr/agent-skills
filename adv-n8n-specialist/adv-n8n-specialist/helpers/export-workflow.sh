#!/usr/bin/env bash
# n8n-specialist :: export-workflow.sh
#
# Exporta um workflow do n8n self-hosted para JSON sanitizado em git.
# Sanitização: remove `id`, `versionId`, timestamps, `staticData`, webhook IDs
# auto-gerados, e mantém credentials só por `name`+`type` (não revela IDs).
#
# Uso:
#   ./export-workflow.sh --slug csuite-buffett
#   ./export-workflow.sh --id 42 --out tools/n8n/workflows/csuite-buffett.json
#
# Sem --out, salva em $REPO/tools/n8n/workflows/<slug>.json.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

SLUG=""; WF_ID=""; OUT=""
while [ $# -gt 0 ]; do
  case "$1" in
    --slug) SLUG="$2"; shift 2 ;;
    --id)   WF_ID="$2"; shift 2 ;;
    --out)  OUT="$2"; shift 2 ;;
    -h|--help) sed -n '2,12p' "$0"; exit 0 ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done

[ -z "$SLUG" ] && [ -z "$WF_ID" ] && { echo "Passe --slug ou --id" >&2; exit 2; }

REPO="$HOME/Documents/GitHub/adventurelabsbrasil/adventure-labs"
[ -z "$OUT" ] && OUT="$REPO/tools/n8n/workflows/${SLUG}.json"

# Se só temos slug, resolve ID via API filtrando por nome
if [ -z "$WF_ID" ]; then
  echo "→ Resolvendo workflow ID por nome '$SLUG'..." >&2
  WF_ID="$("$SCRIPT_DIR/api-call.sh" GET "/api/v1/workflows?name=$SLUG" \
    | jq -r --arg s "$SLUG" '[.data[]? | select(.name == $s)][0].id // empty')"
  [ -z "$WF_ID" ] && { echo "Não achei workflow com nome '$SLUG'" >&2; exit 3; }
  echo "→ Workflow ID = $WF_ID" >&2
fi

# Pull do workflow
RAW="$("$SCRIPT_DIR/api-call.sh" GET "/api/v1/workflows/$WF_ID")"

# Sanitização: usa jq pra remover campos voláteis e cifrados
CLEAN="$(echo "$RAW" | jq '
  del(
    .id, .versionId, .createdAt, .updatedAt,
    .staticData, .triggerCount, .pinData,
    .meta.instanceId, .shared,
    .nodes[]?.webhookId, .nodes[]?.credentials[]?.id
  )
  | .nodes |= map(
      if .credentials then
        .credentials |= with_entries(.value = {name: .value.name})
      else . end
    )
  | ._adventure_meta = {
      exported_at: (now | strftime("%Y-%m-%dT%H:%M:%SZ")),
      exported_by: "n8n-specialist/export-workflow.sh",
      source_id: $WF_ID
    }
' --arg WF_ID "$WF_ID")"

mkdir -p "$(dirname "$OUT")"
echo "$CLEAN" | jq '.' > "$OUT"

NAME="$(echo "$CLEAN" | jq -r '.name')"
NODE_COUNT="$(echo "$CLEAN" | jq '.nodes | length')"

echo ""
echo "✓ Exported workflow:"
echo "  name:        $NAME"
echo "  source_id:   $WF_ID"
echo "  node count:  $NODE_COUNT"
echo "  out:         $OUT"
echo ""
echo "Próximos passos:"
echo "  cd $REPO"
echo "  git add tools/n8n/workflows/$(basename "$OUT")"
echo "  git commit -m \"feat(n8n): export workflow $NAME ($WF_ID)\""
