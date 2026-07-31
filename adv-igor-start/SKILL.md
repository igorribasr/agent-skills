---
name: igor-start
description: Boot leve de sessão do Igor no monorepo (low-priv, sem credencial/prod). Use quando o Igor abrir o Claude Code ou digitar "/igor-start", "começar tarefa", "abrir sessão", "vou mexer no cliente X". Sincroniza o canon fresco (ssot + adventure-labs) via relay do xeon — a máquina do Igor não tem auth GitHub, então o xeon (always-on, autenticado) faz bundle+ff-merge pra cá. Depois lê o ssot (Camada 0 — CONTEXT_VERSION/vocabulário/REDLINES; repo privado, só leitura no boot), dá o briefing recorrente (áreas livres / o que exige PR do Rodrigo / REDLINES / PII nos metadados) e prepara o git (main + branch igor/<cliente>-<desc>). Canon completo (IGOR_BOOT.md/AGENTS.md) só na 1ª sessão ou em dúvida — não relê a cada boot. NÃO faz agent_context/Supabase/diagnose (isso é o /adstart do Founder) nem deploy/SSH/infra (é do Rodrigo). Par da skill igor-end.
---

# igor-start — abrir sessão de trabalho (Igor)

Versão **leve e sem credencial** do boot. NÃO escreve em `agent_context`, NÃO roda `diagnose.sh`, NÃO toca Infisical/Supabase — isso é o `/adstart` do Founder (orquestração cross-host, exige prod que o Igor não tem por design). Aqui o objetivo é simples: **sincronizar o canon + ler o ssot + situar o Igor + abrir a branch certa**. O `CLAUDE.md` da raiz já é auto-carregado pelo Claude Code — não precisa reler; o ssot é repo separado (Camada 0) e é lido explicitamente no passo 2.

## Passos

1. **Sincronizar o canon (via xeon — sem depender de auth GitHub).** A máquina do Igor **não tem GitHub autenticado** (por design low-priv), então `git pull` direto falha. O **xeon** (always-on, autenticado) relaya o canon fresco (`ssot` + `adventure-labs`) pra cá:
   ```bash
   ssh -o ConnectTimeout=25 rodrigo@xeon-adventure ~/bin/canon-to-igor.sh
   ```
   O xeon faz `fetch origin main` + `git bundle` dos dois repos, manda por `scp` e faz `merge --ff-only` nos teus clones `/c/Code/ssot` e `/c/Code/adventure-labs`. **Só faz ff-merge se o clone estiver em `main` e limpo** — se você tem trabalho não-commitado, ele **pula seguro** (não toca no teu WIP) e reporta; nesse caso, commite/`git stash` e rode de novo. Um cron no xeon roda o mesmo relay às 06:00 BRT; este passo é a versão **sob demanda** pra garantir canon fresco no exato momento que você abre a sessão.
   - **Se o xeon estiver inacessível** (SSH falha/timeout): siga com o canon local (pode estar desatualizado) e **avise o Igor** que o canon não foi atualizado. Não trave a sessão por isso.
   - Pré-requisito (uma vez): a chave SSH desta máquina precisa estar autorizada no xeon. Se o SSH pedir senha/recusar, a chave ainda não foi autorizada — reporte ao Rodrigo.
   - **Espelhar TODAS as skills versionadas pro runtime.** O relay traz os arquivos das skills em `skills/<name>/`, mas o Claude Code só as enxerga se estiverem em `~/.claude/skills/`. Rode o sync (idempotente — a cada boot as skills novas aparecem sozinhas):
     ```bash
     bash scripts/sync-skills-to-claude.sh          # sem args = todas
     ```
     Symlinka `skills/<name>` → `~/.claude/skills/<name>`. **`adstart`/`adend` NÃO entram** (são comandos do Founder em `~/.claude/commands/`, não skills do monorepo) — teu boot é `/igor-start` e teu fecho é `/igor-end` por compliance. No Windows/Git Bash o script já força symlink nativo (`MSYS=winsymlinks:nativestrict`); se ele abortar em "existe e não é symlink", há uma cópia velha em `~/.claude/skills/<name>` — remova-a e rode de novo.

2. **Ler o ssot (Camada 0 — canon canônico).** A verdade canônica da Adventure (CONTEXT_VERSION, vocabulário, REDLINES, topologia de hosts) vive em **`adventurelabsbrasil/ssot`**, clonado em `/c/Code/ssot` (já atualizado pelo passo 1). É repo **PRIVADO** — leitura só; não precisa pedir permissão.
   - Leia **`START_HERE.md`** na ordem que ele prescreve.
   - **Cite a `version` de `CONTEXT_VERSION.json` na 1ª resposta** (é o handshake de que você está no contexto certo).
   - Bateu dúvida de vocabulário/termo? confira o `GLOSSARY.md`.

   Continua leve: **só ler** o ssot — nada de `agent_context`/`diagnose`/Infisical (isso é o `/adstart` do Founder).

3. **Briefing (o resumo abaixo já é o teu boot — não relê o canon inteiro).** Diga ao Igor em ≤150 palavras (pt-BR):
   - **Áreas livres** (edita e abre PR sem fricção — prefixo de branch `igor/`).
   - **Exige PR + aprovação do Rodrigo:** `main`, `.claude/` versionado, `supabase/migrations/`, `tools/`, `.github/`, `CLAUDE.md`/`AGENTS.md`, infra.
   - **REDLINES:** nunca commitar segredo/`.env`/valores R$/CPF-CNPJ; sem prod/Infisical/service-role/SSH; mexer no cérebro compartilhado (skill/config/canon) → issue/PR, nunca edição direta.
   - **PII nos METADADOS visíveis (título/corpo/commit/nome de branch de PR e issue) — canon [ssot#188](https://github.com/adventurelabsbrasil/ssot/blob/main/GUARDRAILS.md):** sem nome de **cliente** nem de **pessoa** (use "o cliente" / iniciais / placeholder; o caminho `apps/clientes/0N_<slug>/` é ok). Nomes de **agentes/marcas** (Sueli, Liara, Star Command) são OK. Diferente de "não commitar secret dentro de arquivo": aqui é o que aparece nos metadados do GitHub. Vale **mesmo em repo privado** — o `adventure-labs` é compartilhado.
   - **Fluxo:** branch → commit → push → PR (Rodrigo mergeia).

   > **Aprofundar só quando precisar** (1ª sessão ou em dúvida — não a cada boot): manual completo em `docs/IGOR_BOOT.md` (cenários do dia a dia, erros comuns, glossário Git), diretrizes multi-agente em `AGENTS.md`, redlines detalhadas na **Parte D** de `docs/IGOR_HANDOFF_CLAUDE_CODE.md`.

4. **Contexto do cliente** (só se a tarefa for de um cliente): leia o `README.md` da pasta — ex.: `apps/clientes/07_alma/README.md` (Alma Cleaning) — + o `docs/briefing-*.md` relevante.

5. **Preparar o git** (confirmar identidade, limpar branches velhas e abrir a nova):
   ```bash
   git config user.name   # esperado: Igor Ribas
   git config user.email  # esperado: igor@adventurelabs.com.br
   git switch main        # main já veio fresco do relay (passo 1) — não precisa pull (e o pull exige auth GitHub)
   git fetch --prune 2>/dev/null || true                                # best-effort; sem auth pode falhar, tudo bem
   git branch --merged main | grep '^  igor/' | xargs -r git branch -d  # apaga locais já mergeadas pelo Rodrigo
   git switch -c igor/<cliente>-<descricao-curta>     # ex.: igor/alma-contact-form
   ```
   O `/igor-end` **não** apaga branch (o PR ainda está em revisão quando ele roda) — a limpeza acontece aqui, no boot seguinte, quando o PR já foi mergeado. `git branch -d` (minúsculo) só apaga o que já entrou na `main`; se reclamar "not fully merged", a branch tem trabalho não mergeado — **não** force com `-D`, investigue.
   - **Push/PR (no `/igor-end`) ainda exige GitHub autenticado.** Se `gh auth status` falhar, rode `gh auth login` (passo a passo no `HANDOFF-Adventure-Igor.txt` na Área de Trabalho). O relay do passo 1 cobre só a **entrada** de canon; a **saída** (teus PRs) depende da tua auth GitHub.

6. **Fixar a âncora da sessão:** repetir numa linha qual é o resultado que define sucesso da tarefa de hoje. Antes de cada commit, validar o que vai ser commitado contra as REDLINES e alertar se violar.

## Regra de ouro
**Nunca commita na `main`** — sempre branch `igor/...` → PR. Commits assinados como autor `Igor Ribas <igor@adventurelabs.com.br>` com trailer `Co-Authored-By: Star Command <star-command@adventurelabs.com.br>`. Ao terminar, use **`/igor-end`**.

> Disponibilidade: esta skill é versionada em `skills/igor-start/`. O **passo 1** já espelha TODAS as skills versionadas pro runtime via `bash scripts/sync-skills-to-claude.sh` (sem args) — não precisa mais sincronizar `igor-start`/`igor-end` à mão. Numa máquina nova, se o `/igor-start` ainda não aparece pra ser invocado, rode uma vez `bash scripts/sync-skills-to-claude.sh igor-start` e reinicie o Claude Code.
