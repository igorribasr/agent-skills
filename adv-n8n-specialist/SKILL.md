---
name: n8n-specialist
description: Especialista operacional em n8n self-hosted (Adventure roda em `flow.adventurelabs.com.br` na VPS Hostinger, container `adv-n8n` via docker-compose). Use quando o Founder pedir "configurar n8n", "criar workflow n8n", "exportar/importar workflow", "diagnose n8n", "upgrade do n8n", "rotacionar encryption key", "habilitar queue mode", "n8n não tá rodando", "n8n API token", "criar webhook em flow.adventurelabs.com.br", "mover workflow Make pra n8n", "deploy de workflow n8n", "n8n binary data S3", "n8n SSO", ou colar erro/log do container `adv-n8n` pedindo análise. Cobre VPS principal + caso de uso n8n no Beelink/xeon (futuro), e workflows versionados em `adventure-labs/tools/n8n/workflows/`. Saída final = workflow rodando/ajustado com `N8N_ENCRYPTION_KEY` preservada + audit em `agent_context`. **NÃO** usar para Make.com (skill `paridade-pingolead-young`) nem para automações Adventure-internas que não passam por n8n. Inclui mecanismo de detecção de updates 4-camadas (npm + GitHub releases + Docker Hub manifest digest + versão no container VPS) que roda via cron Beelink semanal.
---

# n8n self-hosted — Especialista Operacional

Pipeline determinístico para operar o **n8n self-hosted Adventure** (`docs.n8n.io`, repo `github.com/n8n-io/n8n`, Sustainable Use License, semver `MAJOR.MINOR.PATCH`). Operacionaliza criação, manutenção, upgrade e versionamento de workflows do orquestrador-mãe da automação Adventure.

## Princípio orientador

**n8n é a única superfície aprovada para automações Adventure-internas que envolvam (a) integração com APIs de terceiros, (b) webhooks recebidos, (c) cron jobs visíveis a humanos, ou (d) qualquer fluxo que o Founder/time precise debugar via UI.** Make.com permanece em uso **apenas para automações Young legadas** (cenário `3485123`, ver [[skill-paridade-pingolead-young]]) — não migrar nem expandir. Para automações novas Adventure, default = n8n self-hosted.

Justificativa: open-source, self-hosted = sem custo variável, encryption key em volume Docker controlado, audit via export JSON versionado em git, REST API completa, integra com Supabase + Infisical + Telegram + WhatsApp Cloud API/Evolution + Plane + Metabase via nodes nativos ou HTTP genérico.

## Estado atual VPS (validado 2026-05-18)

| Item | Valor |
|---|---|
| **URL pública** | `https://flow.adventurelabs.com.br` (nginx + Let's Encrypt) |
| **Container** | `adv-n8n` (em `/opt/adventure-labs/tools/openclaw/docker-compose.vps-n8n-openclaw-nginx.yml`) |
| **Image** | `docker.n8n.io/n8nio/n8n:latest` ⚠️ **NÃO pinned** — restart pode trazer upgrade não-planejado |
| **Volume** | `n8n_data:/home/node/.n8n` (workflows + credentials + encryption key) |
| **Webhook URL externa** | `https://flow.adventurelabs.com.br/webhook/<path>` |
| **Timezone** | `America/Sao_Paulo` (`GENERIC_TIMEZONE` + `TZ`) |
| **Owner técnico histórico** | Eduardo Tebaldi (sócio Adventure, montou setup original) |
| **API token Adventure** | Infisical `/admin` env `prod` → `N8N_API_URL` + `N8N_API_TOKEN` |
| **Encryption key** | `N8N_ENCRYPTION_KEY` injetada via env do docker-compose (NÃO no UI) |
| **Backup** | Cron VPS `30 6 * * *` → `gdrive:99_ARQUIVO/VPS_BACKUPS/` (volume `n8n_data` incluso) |
| **Uptime monitor** | `tools/n8n-uptime/check-workflows.mjs` rodando `*/5` no Beelink → Kuma push |
| **Modo de execução** | Single-process (sem queue mode/Redis ainda). Upgrade pra queue mode = decisão futura. |

## ⚠️ Regras críticas Adventure n8n

Estas regras vêm de incidentes reais e estão em `adventure-labs/CLAUDE.md` § "Regras Operacionais Críticas de Infra":

1. **`INFISICAL_TOKEN` do n8n é gerenciado SOMENTE via `docker-compose environment`** — nunca tentar editar em "Variables" no UI. n8n community não tem a feature Variables. Tentar editar pelo UI = silenciosamente não persiste, depois o credential quebra.
2. **`N8N_ENCRYPTION_KEY` NUNCA muda fora de plano coordenado.** Mudar essa chave = todas as credentials existentes ficam ilegíveis. Rotação requer runbook próprio (re-criar credentials manualmente após swap). Antes de qualquer edit no docker-compose, **confirmar que essa env var permaneceu inalterada**.
3. **`adv-n8n` não tem replica.** Single-container, single-process. Não rodar `docker-compose down` durante horário comercial sem aviso — workflows ativos morrem.
4. **Image `:latest`** = drift silencioso. Toda vez que VPS restartar o container (deploy, host reboot), n8n pode subir uma versão diferente. Tratar como bug de infra (handoff aberto: pinar versão).
5. **Workflows versionados em git**: export para `adventure-labs/tools/n8n/workflows/<slug>.json`. Mudou workflow no UI → exportar e commitar. Sem isso, perdemos histórico se o volume morrer.

## Modelo recomendado por etapa

Princípio canon: [[feedback-modelo-por-contexto]].

| Etapa | Modelo (cron rotina) | `--deep` (Founder pede review profundo) | Razão |
|---|---|---|---|
| **1. Diagnose container + last executions** | Nenhum (Bash + REST) | Nenhum | Determinístico |
| **2. Update-watch (npm + GH + Docker digest)** | Nenhum (Bash + jq) | Nenhum | Comparação de strings |
| **3. Síntese release notes em issue `gargalo`** | **Sonnet 4.6** | **Opus 4.7** | Sonnet resume bug fixes; Opus quando major (2.x → 3.x) ou breaking |
| **4. Export/import workflow + commit em git** | Haiku 4.5 ou Sonnet 4.6 | Sonnet 4.6 | Quase mecânico (curl + jq + sanitization de IDs) |
| **5. Desenhar workflow novo (HTTP + nodes)** | Sonnet 4.6 | Opus 4.7 | Lógica de fluxo varia; Opus quando ramificação complexa, ou produto-novo |
| **6. Migrar workflow Make → n8n** | Sonnet 4.6 | Opus 4.7 | Mapping de módulos; Opus quando expressões/filtros densos |
| **7. Habilitar queue mode (Redis + workers)** | Opus 4.7 | Opus 4.7 | Decisão arquitetural permanente |
| **8. Rotação de `N8N_ENCRYPTION_KEY`** | Opus 4.7 | Opus 4.7 | Risco alto, runbook próprio |
| **9. Troubleshooting (timeout, OOM, queue stuck)** | Sonnet 4.6 | Opus 4.7 | Diagnose; Opus quando root cause não-óbvio |

**Quando rodado via cron Beelink (`claude -p --model claude-sonnet-4-6 -- run n8n-specialist check-updates`):** default Sonnet, flag `--deep` escala para Opus.

## Leitura segura de secrets

Pattern canon ([[feedback-infisical-run-aninhado-leitura-segura]] + [[feedback-infisical-secrets-cli]]). Token n8n (`N8N_API_TOKEN`) e `N8N_ENCRYPTION_KEY` **nunca** devem aparecer em stdout observado por Claude Code.

**Pattern canônico para chamar a API n8n:**

```bash
cd ~/Code/adventure-labs   # ⚠️ NÃO ~/Documents/GitHub — repos Adventure vivem em ~/Code (fora do iCloud)
infisical run --env=prod --path=/admin/ -- bash -c '
  curl -s -H "X-N8N-API-KEY: $N8N_API_TOKEN" \
    "$N8N_API_URL/api/v1/workflows?active=true" \
    | jq "[.data[] | {id, name, active, updatedAt}]"
'
```

O `curl` referencia `$N8N_API_TOKEN` por env var injetada (nunca expandido em stdout); `jq` filtra para campos seguros. Wrapper centralizado em `helpers/api-call.sh`.

**Nunca:**
- `docker exec adv-n8n env | grep ENCRYPTION` — vaza encryption key.
- `cat /var/lib/docker/volumes/adv-labs_n8n_data/_data/config` — vaza encryption key + arquivo de credentials cifrado.
- `infisical secrets get N8N_API_TOKEN --plain --silent` quando sessão Claude observa stdout.

## Gotchas de criação via REST API (validados 2026-06-17)

Criar workflow + credenciais 100% via API (sem dirigir a UI por pixels) funciona e é mais determinístico. Frictions reais que mordem:

1. **Credencial `httpHeaderAuth` exige `allowedHttpRequestDomains`** (SSRF guard). `data:{name,value}` puro → **HTTP 400** `requires property "allowedDomains"`. Forma correta: escopar ao domínio de destino —
   ```json
   {"name":"resend-prod","type":"httpHeaderAuth","data":{"name":"Authorization","value":"Bearer <key>","allowedHttpRequestDomains":"domains","allowedDomains":"api.resend.com"}}
   ```
   Para credencial NÃO usada em request de saída (ex.: auth do node Webhook): `"allowedHttpRequestDomains":"none"` e **omita** `allowedDomains` (o schema proíbe presença quando ≠ `domains`). Sempre `GET /api/v1/credentials/schema/<type>` antes pra ver os campos. `GET /credentials` (listar) NÃO existe na API pública — referencie por nome.
2. **`//` em expressão n8n é comentário JS, não nullish.** `={{ { "status":"sent", "id": ($json.id // null) } }}` → execução `error` "invalid syntax" (o `//` comenta o resto). Use `??` ou `||`. Em `respondToWebhook`, o mais robusto é `responseBody` **JSON estático** (string), não expressão.
3. **Header-auth no node Webhook** = `authentication:"headerAuth"` + credencial `httpHeaderAuth` (header custom, ex. `x-adv-token`). Sem token → **HTTP 403**. Blinda o endpoint público contra spam — fazer sempre em webhook que dispara efeito externo (envio de email/WhatsApp).
4. **Verificar relendo, não pelo HTTP do webhook.** `POST /webhook/...` pode dar 200 com corpo vazio mas a execução ter dado `error` num node downstream. Confirme com `GET /api/v1/executions?workflowId=<id>&limit=1&includeData=true` → `.data[0].status` + saída do node real (ex.: id retornado pelo Resend = email aceito).
5. **Ativar é passo separado:** `POST /api/v1/workflows/<id>/activate` (e `/deactivate`). `PUT /workflows/<id>` atualiza definição mas mexe no estado ativo — confirmar `active` relendo.
6. **`scheduleTrigger` (tv1.2) com `cronExpression` NÃO dispara de forma confiável** (validado 2026-06-18: `{"field":"cronExpression","expression":"0 8 * * *"}` foi salvo e ativo, mas não executou no horário enquanto outros workflows do mesmo container dispararam). Usar a forma **field-based**: diário → `{"field":"days","daysInterval":1,"triggerAtHour":8,"triggerAtMinute":0}`; intervalo → `{"field":"minutes","minutesInterval":N}` / `{"field":"hours","hoursInterval":N}`. É a que os workflows que de fato disparam usam.
7. **Testar workflow agendado sem UI (a public API não tem execute manual):** setar temporariamente `{"field":"minutes","minutesInterval":1}` → `activate` → esperar ~75s → ler `GET /api/v1/executions?workflowId=<id>&includeData=true&limit=2` (cada node tem `data.main[0]` com itens de saída e `error`) → restaurar o schedule final + reativar. Cada execução dispara os efeitos externos do workflow (envio real) — contar como teste autorizado.
8. **Poller de alta frequência incha o volume:** workflow que roda a cada N min gera milhares de execuções/mês salvas por padrão. Setar nas `settings` do workflow `"saveDataSuccessExecution":"none","saveDataErrorExecution":"all"` (guarda só erros) p/ não estourar o volume `n8n_data`.

## Mecanismo de detecção de updates (4 camadas)

n8n upstream **publica release notes ricas** em `https://github.com/n8n-io/n8n/releases` (validado 2026-05-18: stable 2.20.11 com seções `### Bug Fixes`, `### Features` por categoria — `core`, `editor`, `nodes`, etc.). Adicionalmente publica em `https://docs.n8n.io/release-notes/`. A skill cobre 4 fontes — incluindo a camada que **mais importa pro setup Adventure**: o digest da imagem Docker, porque o docker-compose VPS usa `:latest`.

| Camada | Fonte | O que detecta | Helper |
|---|---|---|---|
| **1. npm registry** | `https://registry.npmjs.org/n8n/latest` | Versão shippable mais recente (semver `MAJOR.MINOR.PATCH`) | `helpers/check-updates.sh` |
| **2. GitHub releases** | `gh api repos/n8n-io/n8n/releases?per_page=10` | Release notes estruturadas (`### Bug Fixes`, `### Features`, breaking changes) | `helpers/check-updates.sh` |
| **3. Docker Hub manifest digest** | `https://hub.docker.com/v2/repositories/n8nio/n8n/tags/latest` | SHA256 da imagem que `:latest` resolve agora vs. último check | `helpers/check-updates.sh` |
| **4. Versão real no container VPS** | `ssh hostinger 'docker exec adv-n8n n8n --version'` | O que está efetivamente rodando | `helpers/check-updates.sh` |

Estado persistido em `~/.claude/state/n8n-version-watch.json`. Política de delta:

| Delta detectado | Ação |
|---|---|
| Nenhum delta | Atualiza `last_check` e termina silencioso |
| Apenas Docker digest mudou (mesma version semver) | Linha em `agent_context` — n8n republicou `:latest` |
| Patch bump (`2.20.11` → `2.20.12`) | Linha em `agent_context`, sem issue |
| Minor+ bump (`2.20.x` → `2.21.x` ou `3.0.x`) | Issue `gargalo` + linha em `agent_context` |
| Major bump (`2.x` → `3.x`) ou breaking detectado (regex `BREAKING`, `removed`, `deprecated`, `migration` nas release notes) | Issue `gargalo` com label extra `breaking` + síntese das notes |
| Container VPS está ≥2 minor atrás do `latest` | Issue `gargalo` com label `infra-debt` (mesmo sem release nova; sinal de drift) |

**Cadência:** semanal, cron no Beelink T4 Pro:

```cron
# ~/.config/cron/n8n-update-watch (Beelink)
0 10 * * 1 cd ~/adventure-labs && claude -p --model claude-sonnet-4-6 -- "rode n8n-specialist check-updates"
```

(1h após o `openclaw-update-watch`, para não disputar tokens Anthropic.)

## Fluxo principal — criar workflow novo

Executar **na ordem**. Cada step grava artefato em `$CLAUDE_JOB_DIR/n8n-workflow-<slug>/`.

### Fase 0 — Especificação

- [ ] **Trigger**: webhook? cron? manual? sub-workflow? Definir antes de tocar no UI.
- [ ] **Inputs/outputs**: schema do payload de entrada e do resultado esperado.
- [ ] **Credenciais necessárias**: já existem em n8n? Se não, listar e criar primeiro.
- [ ] **Idempotência**: se for retriado, vai duplicar efeito? Definir chave de dedupe (Supabase upsert, ou cache em memória).
- [ ] **Cliente owner** (se cliente-específico): grava `tenant_id` correspondente em todos os outputs.

### Fase 1 — Build no UI

1. Abrir `https://flow.adventurelabs.com.br`, login Founder.
2. Workflows → New → desenhar.
3. Para nodes HTTP: use **Predefined Credentials** quando possível, ou criar credential nova com nome `<service>-<env>` (ex: `supabase-prod`).
4. Salvar com nome convencional: `<area>-<slug>` (ex: `csuite-buffett`, `gerente-rose`, `plane-to-adv-tasks-sync`).
5. **Não** ativar ainda.

### Fase 2 — Export para git (versionamento)

```bash
cd ~/Documents/GitHub/adventurelabsbrasil/adventure-labs
bash ~/.claude/skills/n8n-specialist/helpers/export-workflow.sh --slug <area>-<slug>
```

O helper:
- Resolve o workflow ID via API (`GET /api/v1/workflows?name=<slug>`).
- Faz `GET /api/v1/workflows/<id>` → JSON.
- Sanitiza: remove `id`, `versionId`, `createdAt`, `updatedAt`, `staticData`, credentials (só mantém `name`+`type`), webhook IDs auto-gerados.
- Grava em `tools/n8n/workflows/<area>-<slug>.json`.

### Fase 3 — Smoke test

- [ ] Disparar manualmente (Execute Workflow no UI).
- [ ] Verificar last execution: `helpers/diagnose-n8n.sh --workflow <slug>`.
- [ ] Se webhook: `curl -X POST https://flow.adventurelabs.com.br/webhook-test/<path>` com payload de teste.

### Fase 4 — Ativar + commit

- [ ] Activate no UI.
- [ ] Commit em `adventure-labs`: `feat(n8n): adiciona workflow <slug>`.
- [ ] PR com Star Command trailer ([[feedback-assinatura-star-command]]).

### Fase 5 — Audit em `agent_context`

```sql
INSERT INTO public.agent_context (category, key, value, source, ttl_hours) VALUES (
  'n8n_workflow_active',
  'vps.n8n.' || :slug || '.activated.' || now()::text,
  jsonb_build_object(
    'workflow_slug', :slug,
    'workflow_id', :n8n_id,
    'trigger_type', :trigger,
    'webhook_path', :webhook_path,
    'tenant_id', :tenant_or_null,
    'git_path', 'tools/n8n/workflows/' || :slug || '.json',
    'n8n_version', :version
  ),
  720,
  'n8n-specialist'
);
```

## Fluxo — importar workflow versionado em git → n8n

Após pull (ou em onboard de host novo), restaurar workflows do git para o n8n:

```bash
bash ~/.claude/skills/n8n-specialist/helpers/import-workflow.sh --file tools/n8n/workflows/<slug>.json
```

Helper:
- Lê JSON.
- Resolve credenciais por **nome** (se credential `supabase-prod` não existe no n8n alvo, falha com erro útil).
- `POST /api/v1/workflows` ou `PUT /api/v1/workflows/<id>` se já existir mesmo nome.
- Retorna o `id` novo.

## Fluxo — upgrade do container

Procedimento manual (não-automatizado por enquanto — bloqueado por: image tag não-pinned). Quando issue `gargalo` para minor+ aparecer:

1. [ ] Founder aprova upgrade na issue.
2. [ ] **Snapshot do volume**: `ssh hostinger 'cd /opt/adventure-labs/tools/openclaw && docker run --rm -v adv-labs_n8n_data:/data -v $(pwd):/backup alpine tar czf /backup/n8n_data_pre_upgrade_$(date +%F).tgz /data'`. Copiar pra gdrive.
3. [ ] Pinar a versão alvo no `docker-compose.vps-n8n-openclaw-nginx.yml`: `image: docker.n8n.io/n8nio/n8n:2.21.0` (não mais `:latest`).
4. [ ] `docker-compose pull n8n && docker-compose up -d n8n` (downtime ~30s).
5. [ ] Verificar `docker exec adv-n8n n8n --version`.
6. [ ] Acionar smoke workflow (ex: `csuite-buffett` em execute manual).
7. [ ] Verificar Kuma `n8n: workflows healthy` continua verde.
8. [ ] Commit do docker-compose: `chore(infra): pin n8n para 2.21.0`.

## Helpers da skill

- `helpers/check-updates.sh` — Update-watch 4-camadas. Cron Beelink semanal.
- `helpers/api-call.sh` — Wrapper REST API com leitura segura via `infisical run`.
- `helpers/export-workflow.sh` — Export workflow do n8n para JSON sanitizado em git.
- `helpers/import-workflow.sh` — Import JSON do git para n8n alvo.
- `helpers/diagnose-n8n.sh` — Diagnose: container up, last 10 executions por workflow, queue depth, version.

## Referência condensada da doc n8n

Doc oficial (`docs.n8n.io`) tem 400+ páginas. Referência viva consolidada em `references/`:

- `references/architecture.md` — Single vs queue mode, binary data, encryption key, REST API surface.
- `references/api-cheatsheet.md` — Endpoints principais (`workflows`, `executions`, `credentials`, `users`, `tags`).
- `references/env-vars.md` — Env vars críticas (subset relevante Adventure).
- `references/security.md` — Encryption key rotation, SSRF protection, public API disable, blocking nodes.
- `references/migration-make-to-n8n.md` — Mapping de módulos Make → nodes n8n (relevante p/ migração Young eventual).

Cada arquivo cita link canônico em `https://docs.n8n.io/<path>/index.md` para verificação upstream.

## Workflows versionados Adventure

Tracking de workflows exportados em `adventure-labs/tools/n8n/workflows/`:

| Workflow | Owner | Status | Última export |
|---|---|---|---|
| `csuite-buffett` (CFO) | Adventure | Script existe, nunca rodou (CLAUDE.md) | Sem timestamp |
| `csuite-cagan` (CPO) | Adventure | Bug RLS Supabase | 2026-04-17 |
| `csuite-davinci` (CINO) | Adventure | Bug RLS Supabase | 2026-04-17 |
| `csuite-ogilvy` (CMO) | Adventure | Bug RLS Supabase | 2026-04-17 |
| `csuite-ohno` (COO) | Adventure | Bug RLS Supabase | 2026-04-17 |
| `csuite-torvalds` (CTO) | Adventure | Nunca rodou | Sem timestamp |
| `gerente-rose` | Cliente Rose | Bug RLS Supabase | 2026-04-17 |
| `gerente-benditta` | Cliente Benditta | Nunca rodou | Sem timestamp |
| `gerente-young` | Cliente Young | Nunca rodou | Sem timestamp |
| `plane-to-adv-tasks-sync` | Adventure | Ativo? (verificar) | Sem timestamp |
| `alexa-comando-estelar-*` (v3, v3.1 DUAL_MODE, v3.2 PROXY) | Adventure | Parqueado (Alexa BACKLOG-02) | Sem timestamp |

**Pendência:** estabelecer headers de metadata nos JSONs (workflow_status, last_export, owner) para que `check-workflows.mjs` + esta skill possam cruzar referência com `adv_clients` e estado real do container.

## Sobreposições e relações

- **Complementa** `tools/n8n-uptime/check-workflows.mjs` — uptime é "n8n workflows estão verdes?"; esta skill é "como mexer no n8n com segurança". Não duplicar.
- **Não substitui** [[skill-paridade-pingolead-young]] — aquele skill opera Make `3485123` (Young legado). n8n é para tudo Adventure-novo, não para Young Make.
- **Integra** com [[skill-whatsapp-oficial]] — workflows n8n que enviam WhatsApp Cloud API usam `META_ACCESS_TOKEN_ADVENTURE` via node HTTP.
- **Integra** com [[skill-identificador-gargalos]] — issues `n8n-upgrade` e `n8n-workflow-broken` aparecem no scan semanal.
- **Compartilha host** com [[skill-openclaw-specialist]] (VPS) — mesmo docker-compose, mesmo nginx. Upgrade coordenado quando ambos forem mexer.

## Pendências canon

- [ ] Pinar `image: docker.n8n.io/n8nio/n8n:<version>` no docker-compose VPS (eliminar drift `:latest`).
- [ ] Investigar bug RLS Supabase que trava memória dos 5 agents C-Suite + gerente-rose (CLAUDE.md monorepo § Agentes Autônomos).
- [ ] Avaliar migração para **queue mode** (Redis + workers) quando volume de execução crescer.
- [ ] Estabelecer headers de metadata padronizados nos JSONs exportados (campo `_adventure_meta` no top-level).
- [ ] Habilitar cron `n8n-update-watch` no Beelink (aguarda Founder ligar).
- [ ] Considerar habilitar `N8N_DIAGNOSTICS_ENABLED=false` se ainda não estiver (não envia telemetria pra n8n.io).
