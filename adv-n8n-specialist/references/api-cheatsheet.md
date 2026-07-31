# n8n REST API — cheatsheet (v1)

Fonte upstream: <https://docs.n8n.io/api/api-reference/>

**Auth:** header `X-N8N-API-KEY: <jwt>`. Token gerado em Settings → API no UI.
**Base:** `https://flow.adventurelabs.com.br/api/v1` (Adventure prod).
**Wrapper seguro:** `helpers/api-call.sh` desta skill (usa `infisical run` aninhado).

## Workflows

| Método | Path | Uso |
|---|---|---|
| GET | `/workflows` | Lista todos. Query: `active=true`, `name=<exact>`, `limit=250`. |
| GET | `/workflows/{id}` | Detalhe completo (com nodes + connections). |
| POST | `/workflows` | Cria. Body = workflow JSON (sem `id`). |
| PUT | `/workflows/{id}` | Update. |
| DELETE | `/workflows/{id}` | Apaga. |
| POST | `/workflows/{id}/activate` | Ativa. |
| POST | `/workflows/{id}/deactivate` | Desativa. |
| GET | `/workflows/{id}/tags` | Tags do workflow. |
| PUT | `/workflows/{id}/tags` | Substitui tags. |

## Executions

| Método | Path | Uso |
|---|---|---|
| GET | `/executions` | Lista. Query: `workflowId=<id>`, `status=success|error|crashed|waiting`, `limit`, `lastId` (cursor). |
| GET | `/executions/{id}` | Detalhe (com `data` de cada node — pode ser GRANDE). Query `includeData=true` para o blob bruto. |
| DELETE | `/executions/{id}` | Apaga 1 execução. |

## Credentials

| Método | Path | Uso |
|---|---|---|
| GET | `/credentials/schema/{credentialTypeName}` | Schema do tipo (ex: `httpBasicAuth`). Útil pra montar payload de criação. |
| POST | `/credentials` | Cria. Body cifrado in-DB via `N8N_ENCRYPTION_KEY`. |
| DELETE | `/credentials/{id}` | Apaga. |
| ⚠️ NÃO há GET de credentials individuais com data | Por design — secrets não saem da API. |

## Tags

| Método | Path | Uso |
|---|---|---|
| GET | `/tags` | Lista. |
| POST | `/tags` | Cria. |
| PUT | `/tags/{id}` | Update. |
| DELETE | `/tags/{id}` | Apaga. |

## Users (somente em prod com user management ligado)

| Método | Path | Uso |
|---|---|---|
| GET | `/users` | Lista users da instância. |
| POST | `/users` | Cria. |
| GET | `/users/{id}` | Detalhe. |
| DELETE | `/users/{id}` | Apaga. |
| PATCH | `/users/{id}/role` | Muda role. |

## Variables (community: limitado; enterprise: completo)

| Método | Path | Uso |
|---|---|---|
| GET | `/variables` | Lista. **Community edition:** UI não permite editar variables (ver regra § INFISICAL_TOKEN no SKILL.md). |

## Source Control (Enterprise apenas)

`/source-control/*` — não disponível na community que Adventure usa.

## Audit logs (Enterprise apenas)

`/audit` — não disponível community.

## Paginação

Endpoints de lista retornam `{ data: [...], nextCursor: "<id>" }`. Iterar passando `cursor=<nextCursor>` até `nextCursor` ficar null.

## Healthcheck (sem auth)

`GET /healthz` — retorna `{ "status": "ok" }` se o processo está vivo. Não precisa de token. Útil pra Kuma/probe externo.

`GET /healthz/readiness` (em alguns builds) — readiness probe pra Kubernetes.
