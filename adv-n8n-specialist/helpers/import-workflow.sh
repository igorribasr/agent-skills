#!/usr/bin/env bash
# n8n-specialist :: import-workflow.sh
#
# Importa um workflow JSON versionado no git para uma instância n8n alvo.
# Se já existe workflow com o mesmo nome, faz PUT (update). Senão POST (create).
# Mantém o workflow INATIVO ao final — ativação é manual após smoke test.
#
# Uso:
#   ./import-workflow.sh --file tools/n8n/workflows/csuite-buffett.json
#   ./import-workflow.sh --file <path> --rename <new-name>
#
# Pré: credentials referenciadas pelo workflow precisam existir no n8n alvo
# (pelo nome). Senão a importação cria o workflow mas os nodes ficam quebrados.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

FILE=""; RENAME=""
while [ $# -gt 0 ]; do
  case "$1" in
    --file)   FILE="$2"; shift 2 ;;
    --rename) RENAME="$2"; shift 2 ;;
    -h|--help) sed -n '2,12p' "$0"; exit 0 ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done
[ -z "$FILE" ] || [ ! -f "$FILE" ] && { echo "--file ausente ou não encontrado" >&2; exit 2; }

# Strip campos não-aceitos pelo n8n na criação + aplica rename se pedido
PAYLOAD="$(jq --arg name "$RENAME" '
  del(._adventure_meta, .active, .id, .versionId, .createdAt, .updatedAt)
  | if $name != "" then .name = $name else . end
' "$FILE")"

WORKFLOW_NAME="$(echo "$PAYLOAD" | jq -r '.name')"
[ -z "$WORKFLOW_NAME" ] || [ "$WORKFLOW_NAME" = "null" ] && { echo "JSON sem campo .name" >&2; exit 3; }

# Procura workflow existente com mesmo nome
echo "→ Procurando workflow existente '$WORKFLOW_NAME'..." >&2
EXISTING_ID="$("$SCRIPT_DIR/api-call.sh" GET "/api/v1/workflows?name=$WORKFLOW_NAME" 2>/dev/null \
  | jq -r --arg s "$WORKFLOW_NAME" '[.data[]? | select(.name == $s)][0].id // empty')"

TMP_PAYLOAD="$(mktemp)"
echo "$PAYLOAD" > "$TMP_PAYLOAD"
trap 'rm -f "$TMP_PAYLOAD"' EXIT

if [ -n "$EXISTING_ID" ]; then
  echo "→ Workflow existe (id=$EXISTING_ID). PUT update..." >&2
  RESULT="$("$SCRIPT_DIR/api-call.sh" PUT "/api/v1/workflows/$EXISTING_ID" --data "@$TMP_PAYLOAD")"
  ACTION="updated"
else
  echo "→ Workflow novo. POST create..." >&2
  RESULT="$("$SCRIPT_DIR/api-call.sh" POST "/api/v1/workflows" --data "@$TMP_PAYLOAD")"
  ACTION="created"
fi

NEW_ID="$(echo "$RESULT" | jq -r '.id // .data.id // empty')"
echo ""
echo "✓ Workflow $ACTION:"
echo "  name:   $WORKFLOW_NAME"
echo "  id:     $NEW_ID"
echo "  active: false (ativar manualmente após smoke test)"
echo ""
echo "Smoke test:"
echo "  ~/.claude/skills/n8n-specialist/helpers/diagnose-n8n.sh --workflow \"$WORKFLOW_NAME\""
