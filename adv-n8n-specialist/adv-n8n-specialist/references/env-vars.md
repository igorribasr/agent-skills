# n8n env vars — subset relevante Adventure

Fonte upstream: <https://docs.n8n.io/hosting/configuration/environment-variables/>

Não tem catálogo completo aqui — a doc oficial tem 200+ env vars. Este arquivo lista só as que importam para a operação Adventure VPS e potenciais futuras.

## Em uso hoje (docker-compose.vps-n8n-openclaw-nginx.yml)

| Env var | Valor | Por que |
|---|---|---|
| `N8N_HOST` | `flow.adventurelabs.com.br` | Domain externo |
| `N8N_PORT` | `5678` | Porta do container (nginx faz proxy) |
| `N8N_PROTOCOL` | `https` | Forçado (atrás de Let's Encrypt) |
| `WEBHOOK_URL` | `https://flow.adventurelabs.com.br` | Webhook URLs precisam ser https-públicas |
| `N8N_ENCRYPTION_KEY` | (segredo) | **NÃO MUDAR sem runbook** |
| `N8N_DISABLE_PRODUCTION_MAIN_PROCESS` | `false` | Mantém main process em prod |
| `N8N_ENDPOINT_WEBHOOK` | `webhook` | Webhooks prod em `/webhook/<path>` |
| `N8N_ENDPOINT_WEBHOOK_TEST` | `webhook-test` | Test mode em `/webhook-test/<path>` |
| `N8N_BASIC_AUTH_WEBHOOK` | `false` | Sem basic auth no webhook |
| `GENERIC_TIMEZONE` / `TZ` | `America/Sao_Paulo` | Cron triggers em horário BR |

## Críticas para considerar adicionar

| Env var | Default | Sugerido Adventure | Motivo |
|---|---|---|---|
| `N8N_DIAGNOSTICS_ENABLED` | `true` | `false` | Para de enviar telemetria pra n8n.io. Diretiva Adventure: minimizar dados de produção saindo. |
| `N8N_VERSION_NOTIFICATIONS_ENABLED` | `true` | `false` | Não precisamos do banner — temos a skill. |
| `N8N_TEMPLATES_ENABLED` | `true` | `true` | Templates marketplace é útil. |
| `N8N_LOG_LEVEL` | `info` | `info` ou `warn` | `debug` enche disco. |
| `N8N_LOG_OUTPUT` | `console` | `console` + `file` se quiser persistência além do `docker logs`. |
| `N8N_SECURE_COOKIE` | `true` | `true` | Atrás de nginx https. |
| `N8N_PUSH_BACKEND` | `websocket` | `websocket` | Comunicação UI em tempo real. |
| `EXECUTIONS_PROCESS` | `main` | `main` (single) | Mudaria pra `worker` em queue mode. |
| `EXECUTIONS_MODE` | `regular` | `regular` (hoje) | Vira `queue` em queue mode. |
| `DB_TYPE` | `sqlite` | considerar `postgresdb` | SQLite OK até ~50k execs total; Postgres mais robusto. |
| `EXECUTIONS_DATA_PRUNE` | `true` | `true` | Auto-prune de executions antigas. |
| `EXECUTIONS_DATA_MAX_AGE` | `336` (14 dias) | `168` (7 dias) | Reduzir disco. Customer-facing precisa de mais? Decidir. |

## Para queue mode (futuro)

```
EXECUTIONS_MODE=queue
QUEUE_BULL_REDIS_HOST=redis
QUEUE_BULL_REDIS_PORT=6379
QUEUE_BULL_REDIS_DB=0
N8N_CONCURRENCY_PRODUCTION_LIMIT=10
```

Doc: `https://docs.n8n.io/hosting/configuration/environment-variables/queue-mode/`

## Para SSO (se algum dia houver multi-user)

```
N8N_USER_MANAGEMENT_DISABLED=false
N8N_USER_MANAGEMENT_JWT_SECRET=...
```

Adventure hoje é Founder-only no UI, então N/A.

## Para binary data S3 (futuro)

Ver `references/architecture.md` § Binary data.

## Bloqueio de nodes (security hardening)

```
NODES_EXCLUDE=["n8n-nodes-base.executeCommand"]  # bloqueia exec arbitrário
```

Considerar bloquear `executeCommand` em prod — workflow malicioso (ou compromise via webhook) pode rodar shell no container. Adventure prod: avaliar.

Doc: `https://docs.n8n.io/hosting/securing/blocking-nodes/`
