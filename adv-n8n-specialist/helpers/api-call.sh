#!/usr/bin/env bash
# n8n-specialist :: api-call.sh
#
# Wrapper para a REST API do n8n self-hosted Adventure, com leitura segura
# de credenciais via `infisical run` aninhado — token NUNCA aparece em stdout
# da sessão Claude Code.
#
# Uso:
#   ./api-call.sh GET /api/v1/workflows
#   ./api-call.sh GET '/api/v1/workflows?active=true'
#   ./api-call.sh GET /api/v1/executions
#   ./api-call.sh GET /api/v1/workflows/123
#   ./api-call.sh POST /api/v1/workflows --data @workflow.json
#   ./api-call.sh PUT /api/v1/workflows/123 --data @workflow.json
#   ./api-call.sh DELETE /api/v1/workflows/123
#
# Output: resposta JSON formatada via jq.
# Códigos HTTP não-2xx fazem o script sair com exit 3 e imprimir o status.
#
# Pré-requisitos:
#   - cwd com .infisical.json (i.e., ~/Documents/GitHub/adventurelabsbrasil/adventure-labs)
#   - Infisical CLI logado (universal auth ou token sessão)
#   - Secrets em /admin env prod: N8N_API_URL, N8N_API_TOKEN

set -euo pipefail

METHOD="${1:-}"
PATH_PART="${2:-}"
shift 2 || { echo "Uso: $0 <METHOD> <PATH> [curl-args...]" >&2; exit 2; }

case "$METHOD" in GET|POST|PUT|PATCH|DELETE) ;; *) echo "method invalido: $METHOD" >&2; exit 2;; esac
[ -z "$PATH_PART" ] && { echo "path vazio" >&2; exit 2; }

# Garante cwd com .infisical.json
if [ ! -f ".infisical.json" ]; then
  if [ -f "$HOME/Documents/GitHub/adventurelabsbrasil/adventure-labs/.infisical.json" ]; then
    cd "$HOME/Documents/GitHub/adventurelabsbrasil/adventure-labs"
  else
    echo "WARN: rodando sem .infisical.json no cwd; pode falhar." >&2
  fi
fi

# Output em arquivo temporário para separar body de headers (não passar pelo stdout direto)
TMP_OUT="$(mktemp)"
trap 'rm -f "$TMP_OUT"' EXIT

# shellcheck disable=SC2016
infisical run --env=prod --path=/admin/ -- bash -c '
  set -e
  : "${N8N_API_URL:?N8N_API_URL ausente em Infisical /admin prod}"
  : "${N8N_API_TOKEN:?N8N_API_TOKEN ausente em Infisical /admin prod}"
  HTTP_CODE=$(curl -s -o "$1" -w "%{http_code}" \
    -X "$2" \
    -H "X-N8N-API-KEY: $N8N_API_TOKEN" \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    "${@:5}" \
    "${N8N_API_URL}$3")
  echo "$HTTP_CODE"
' _bash "$TMP_OUT" "$METHOD" "$PATH_PART" "$@" 2>&1 | grep -v -E "INF |new release|brew update|Injecting" > "${TMP_OUT}.code" || true

HTTP_CODE="$(tail -n 1 "${TMP_OUT}.code" 2>/dev/null || echo 000)"

if [[ ! "$HTTP_CODE" =~ ^2[0-9]{2}$ ]]; then
  echo "HTTP $HTTP_CODE — request falhou" >&2
  jq '.' "$TMP_OUT" 2>/dev/null || cat "$TMP_OUT"
  rm -f "${TMP_OUT}.code"
  exit 3
fi

jq '.' "$TMP_OUT" 2>/dev/null || cat "$TMP_OUT"
rm -f "${TMP_OUT}.code"
