---
name: igor-end
description: Fechar a tarefa do Igor com segurança — revisar diff, commitar assinado e abrir o PR (low-priv, sem prod). Use quando o Igor terminar ou digitar "/igor-end", "fechar tarefa", "abrir o PR", "terminei, manda pro Rodrigo". Valida o diff contra as REDLINES (segredo/.env/valores + PII nos metadados do PR), garante branch igor/... (nunca main), commita como autor Igor Ribas + trailer Star Command, push e PR. NÃO mergeia/deploy/SSH nem escreve em agent_context (isso é o /adend do Founder). Par da skill igor-start.
---

# igor-end — fechar tarefa e abrir o PR (Igor)

Versão **leve e sem credencial** do fechamento. NÃO escreve em `agent_context`, NÃO mergeia, NÃO faz deploy — Rodrigo revisa e mergeia o PR. Objetivo: **entregar um PR limpo e atribuído ao Igor**.

## Passos

1. **Confirmar a branch** (nunca `main`):
   ```bash
   git rev-parse --abbrev-ref HEAD   # precisa começar com igor/
   ```
   Se estiver em `main`: PARE, crie a branch (`git switch -c igor/<cliente>-<desc>`) antes de commitar.

2. **Revisar o diff** (antes de qualquer `add`) — checar contra as **REDLINES** (Parte D do `docs/IGOR_HANDOFF_CLAUDE_CODE.md`):
   ```bash
   git status && git diff
   ```
   - **Nenhum** segredo/token/`sk-...`/`eyJ...`/`.env`/`credentials.json`/comprovante/valor R$/CPF/CNPJ.
   - Só arquivos **esperados** da tarefa. Nada de `git add .` cego.
   - Mudou canon/skill/config/migration/infra? → isso é **PR de revisão do Rodrigo**, sinalize.

3. **Commit** (stage seletivo + assinatura):
   ```bash
   git add <arquivos específicos>
   git commit            # mensagem Conventional Commits; trailer abaixo na última linha
   ```
   Trailer obrigatório (última linha do commit):
   ```
   Co-Authored-By: Star Command <star-command@adventurelabs.com.br>
   ```
   Autor = `Igor Ribas <igor@adventurelabs.com.br>` (já no `git config`).

4. **Push + PR:**
   ```bash
   git push -u origin igor/<cliente>-<descricao-curta>
   gh pr create --base main --fill      # Rodrigo revisa e mergeia
   ```
   Corpo mais longo → escrever num arquivo e usar `--body-file <arquivo>`.
   **PII nos metadados (ssot#188):** título, corpo e **nome da branch** do PR sem nome de **cliente** nem de **pessoa** — use "o cliente"/iniciais/placeholder. Caminho `apps/clientes/0N_<slug>/` no diff é ok; agentes/marcas OK.

5. **Confirmar e reportar:** mostrar a URL do PR ao Igor e lembrar que **o merge é do Rodrigo** — não tentar mergear. Se sobrou pendência, anotar no corpo do PR (ou abrir issue), não deixar trabalho solto.
   > **Preview automático:** se o PR toca um site de cliente com preview ligado (ex.: `apps/clientes/07_alma/**`), em ~1-2 min o bot do CI comenta no PR uma URL `🔎 Preview …` (Vercel, publicada pelo CI — Igor **não** precisa de conta na Vercel). Aguarde esse comentário e passe a URL pro Rodrigo pra ele revisar o resultado no navegador antes do merge. Um eventual check vermelho da "Vercel – …" dizendo *"Git author must have access"* é da integração antiga, **não bloqueia e não é problema do Igor** — o preview que vale é o do comentário do bot. Detalhe: seção "Preview automático" do `docs/IGOR_HANDOFF_CLAUDE_CODE.md`.
   > **Não apague a branch aqui.** O PR ainda está em revisão — se o Rodrigo pedir ajuste, é só dar `push` de novo na mesma branch `igor/...`. A limpeza das branches (local + remota) já mergeadas acontece no **próximo `/igor-start`** (`git fetch --prune` + `git branch -d` das `igor/*` já na `main`), quando o merge já ocorreu.

## REDLINES de fechamento
- **Não mergeia** (sem permissão de `main`); **não faz deploy/SSH/infra/Infisical** (é do Rodrigo). Tarefa que pedir prod → **abre issue**, não tenta.
- Segredo no diff = PARA e remove antes de commitar.

> Disponibilidade: versionada em `skills/igor-end/`. Pra aparecer no Claude Code da máquina: `bash scripts/sync-skills-to-claude.sh igor-start igor-end`.
