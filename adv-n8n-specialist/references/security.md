# n8n self-hosted — Security & hardening (referência condensada)

Fonte upstream: <https://docs.n8n.io/hosting/securing/overview/>

## Threat model relevante Adventure

| Vetor | Defesa nativa n8n | Status Adventure |
|---|---|---|
| Credentials vazadas via DB roubado | `N8N_ENCRYPTION_KEY` cifra credentials no DB | ✓ Habilitado |
| Webhook DDoS / abuso público | n8n não tem rate-limit nativo robusto; depende de nginx | nginx Adventure: sem rate-limit configurado (pendência) |
| SSRF via HTTP node abusando URLs internas | `N8N_BLOCK_FILE_ACCESS_TO_N8N_FILES=true` + SSRF protection | Pendente verificar |
| RCE via Code node ou Execute Command | `Code node` é isolado por VM2/vm sandbox; `Execute Command` pode rodar shell arbitrário no container | `executeCommand` não bloqueado — pendência hardening |
| API key vazada | API token Adventure em Infisical `/admin` | ✓ |
| Workflow malicioso importado | Workflows revisados em PR git | ✓ (via export/import + git) |
| Upgrade não-planejado | `image: :latest` no docker-compose | ⚠️ DRIFT — pendência canon |

Doc: `https://docs.n8n.io/hosting/securing/overview/`

## SSL / TLS

Adventure usa Let's Encrypt via `certbot` container no docker-compose. Renew automático via cron VPS (cobre todos os domains `flow.`, `bi.`, `pw.`, etc.).

Verificar próxima expiração:
```bash
ssh hostinger 'docker exec adv-certbot certbot certificates 2>/dev/null | grep -E "Domains|Expiry"'
```

## SSRF protection (importante)

n8n por padrão pode fazer HTTP requests para IPs internos (`localhost`, `10.0.0.0/8`, `172.16.0.0/12`, `192.168.0.0/16`, `127.0.0.1`). Workflow malicioso pode escanear rede interna VPS.

Mitigação: `N8N_BLOCKED_HOSTS` (lista de hostnames/IPs bloqueados). Habilitar antes de qualquer workflow lidar com input não-confiável.

Doc: `https://docs.n8n.io/hosting/securing/ssrf-protection/`

## Public API disable

Se a REST API não for usada para automações externas, desabilitar:
```
N8N_PUBLIC_API_DISABLED=true
```

**Adventure NÃO pode habilitar isso** — `tools/n8n-uptime/check-workflows.mjs` e esta skill dependem da API.

Doc: `https://docs.n8n.io/hosting/securing/disable-public-api/`

## Encryption key rotation

Procedimento delicado. Resumo (detalhes em `references/architecture.md` § Encryption key):

1. Backup do volume `n8n_data`.
2. `docker exec adv-n8n n8n export:credentials --decrypted=true --all > /tmp/creds.json`.
3. Editar `N8N_ENCRYPTION_KEY` no docker-compose com nova chave.
4. `docker-compose up -d n8n` (restart).
5. `docker exec adv-n8n n8n import:credentials --input=/tmp/creds.json`.
6. `shred -u /tmp/creds.json` (no host, dentro do container).

**NÃO fazer sem runbook completo + janela acordada + Founder ciente.**

Doc: `https://docs.n8n.io/hosting/securing/encryption-key-rotation/`

## API token rotation

Token Adventure (`N8N_API_TOKEN` em Infisical `/admin`):
1. Settings → API → Revoke current key.
2. Create new key.
3. Update Infisical: `infisical secrets set N8N_API_TOKEN=<new> --env=prod --path=/admin > /dev/null 2>&1` (output redirect — ver [[feedback-infisical-set-leaks-value]]).
4. Rebuild dos serviços que consomem (Beelink n8n-uptime, esta skill).

## Blocking nodes (recomendado)

Adventure pendente: `N8N_NODES_EXCLUDE=["n8n-nodes-base.executeCommand"]` em docker-compose.

Doc: `https://docs.n8n.io/hosting/securing/blocking-nodes/`

## User management e 2FA

Hoje Adventure UI é Founder-only (single user). Se algum dia adicionar usuários:
- `N8N_USER_MANAGEMENT_DISABLED=false`
- Forçar 2FA via `N8N_MFA_ENABLED=true`
- SMTP configurado em env vars (`N8N_SMTP_*`) para password reset

## Audit

`docker logs adv-n8n` é o canal principal. Filtrar secrets com `sed -E "s/(token|secret|key|password)[\"]?[: ]+[^,\"]+/\1=***REDACTED***/gi"`.

Para audit estruturado: `N8N_LOG_OUTPUT=file` + rotate via logrotate no host.

## Checklist pré-produção (cliente ou Buzz)

- [ ] Image tag pinned (não `:latest`).
- [ ] `N8N_ENCRYPTION_KEY` único Adventure (não default).
- [ ] `N8N_DIAGNOSTICS_ENABLED=false`.
- [ ] `N8N_BLOCKED_HOSTS` com IPs internos VPS (Docker network) bloqueados.
- [ ] `N8N_NODES_EXCLUDE` com `executeCommand` removido.
- [ ] Backup do volume `n8n_data` rodando diariamente (cron VPS já faz).
- [ ] Workflows ativos exportados em git.
- [ ] Webhook URLs externos com path random (não previsível).
- [ ] nginx com rate-limit nos paths `/webhook/*` (pendência).
