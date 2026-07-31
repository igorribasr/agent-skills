# n8n — Arquitetura (referência condensada)

Fonte upstream: <https://docs.n8n.io/hosting/> · <https://docs.n8n.io/hosting/scaling/overview/>

## Modos de execução

| Modo | Quando usar | Componentes |
|---|---|---|
| **Single-process** (Adventure hoje) | < ~100 execuções/dia, sem latência crítica | 1 container n8n, SQLite ou Postgres externo opcional |
| **Queue mode** | > 100 execuções/dia, paralelismo, workflows longos | n8n main + N workers + Redis (broker) |
| **Webhook/worker split** | High throughput de webhook | webhook process separado de main |

**Adventure hoje:** single-process. Upgrade pra queue mode quando algum workflow superar 5min/exec consistente ou quando concorrência ficar relevante (ex: Buzz orquestrando vários csuite-*).

Doc: `https://docs.n8n.io/hosting/scaling/queue-mode/`

## Componentes principais

| Componente | Função | Caminho VPS |
|---|---|---|
| **Main process** | UI + REST API + agendador cron | `/home/node/.n8n` (volume `n8n_data`) |
| **Workflows DB** | Workflows + executions + credentials cifrados | SQLite por padrão em `$N8N_USER_FOLDER/database.sqlite`; Postgres recomendado em prod sério |
| **Encryption key** | Cifra credenciais no DB | `N8N_ENCRYPTION_KEY` env var (Adventure: docker-compose env) |
| **Binary data** | Anexos, arquivos de uploads/downloads | Filesystem default; S3 recomendado se volume grande (`N8N_DEFAULT_BINARY_DATA_MODE=s3`) |
| **Webhook endpoint** | Recebe POSTs externos | `/webhook/<path>` (prod) e `/webhook-test/<path>` (em test mode) |

## REST API (v1)

Base: `${N8N_API_URL}/api/v1`. Auth: header `X-N8N-API-KEY: <jwt>` (gerado em Settings → API no UI).

Doc: `https://docs.n8n.io/api/api-reference/`

Endpoints principais — ver `references/api-cheatsheet.md`.

## Encryption key — invariante crítico

`N8N_ENCRYPTION_KEY` cifra **todas** as credentials no DB. Trocar essa chave = todas as credentials viram lixo cifrado e precisam ser re-criadas manualmente.

**Procedimento de rotação** (runbook obrigatório):
1. Listar todas as credentials atuais (nome + tipo + workflow consumer).
2. Backup do `database.sqlite` (ou pg_dump).
3. Decifrar credentials uma a uma (via n8n CLI `n8n export:credentials --decrypted=true --all`) e gravar payload em local seguro temporário.
4. Trocar `N8N_ENCRYPTION_KEY` no docker-compose.
5. Reimportar credentials (via API ou CLI).
6. Apagar payload temporário decifrado.

Doc: `https://docs.n8n.io/hosting/securing/encryption-key-rotation/`

Não fazer isso sem o Founder presente e janela de manutenção avisada.

## Binary data — quando migrar pra S3

n8n grava binary data em filesystem por padrão. Volume cresce silenciosamente. Migrar pra S3 quando:
- Volume `n8n_data` ultrapassar 5GB.
- Workflows que processam PDFs/imagens grandes ficarem comuns.

Env vars:
```
N8N_DEFAULT_BINARY_DATA_MODE=s3
N8N_EXTERNAL_STORAGE_S3_HOST=...
N8N_EXTERNAL_STORAGE_S3_BUCKET_NAME=...
N8N_EXTERNAL_STORAGE_S3_BUCKET_REGION=...
N8N_EXTERNAL_STORAGE_S3_ACCESS_KEY=...
N8N_EXTERNAL_STORAGE_S3_ACCESS_SECRET=...
```

Doc: `https://docs.n8n.io/hosting/scaling/external-storage/`

## Versionamento de workflows

n8n NÃO tem git embutido. Versionamento é manual via export JSON → repo git.
Adventure: `adventure-labs/tools/n8n/workflows/<slug>.json`. Helpers nesta skill (`export-workflow.sh`, `import-workflow.sh`) automatizam.

Source Control nativo do n8n (Settings → Source Control) é feature **Enterprise** (paga). Adventure usa export manual.
