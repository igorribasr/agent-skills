#!/usr/bin/env bash
# skills-inventory — anti-rot. Regenera skills/REGISTRY.md a partir do filesystem e,
# se houver DRIFT vs a branch (skill criada/movida/removida sem atualizar o índice),
# abre PR no monorepo. Mesmo padrão dos update-watch das outras skills.
#
# HOME canônico do REGISTRY = command deck (macbook), cujo ~/.claude/skills é a
# referência. NÃO rodar o refresh-do-REGISTRY em Beelink/VPS (injetaria as skills
# host-local DAQUELE host no índice). Outros hosts contribuem só via adv_skills
# (upsert por host) — ver --json + SKILL.md §Camada Supabase.
#
# ISOLAMENTO (por que git worktree): este script roda semanal por LaunchAgent no
# checkout principal compartilhado ($REPO). Versões anteriores faziam `git switch main`
# + `git switch -c` direto nesse checkout — o que ARRANCARIA a branch de qualquer
# sessão paralela (Cowork/Claude Code/Sueli) trabalhando ali no momento. Agora todo o
# trabalho git (sync main, gerar, branch de drift, commit, push) acontece num
# `git worktree` EFÊMERO fora do checkout. O checkout principal nunca é tocado — só
# servimos de `git fetch` (read-only do ponto de vista de working tree/HEAD).
#
# Instalar (macbook, pós-merge): LaunchAgent em skills/skills-inventory/cron/
#   com.adventurelabs.skills-inventory.plist (semanal). Ver INSTALL.md.
set -euo pipefail

REPO="${ADV_MONOREPO_PATH:-$HOME/Code/adventure-labs}"
LOCAL_SKILLS="${ADV_LOCAL_SKILLS:-$HOME/.claude/skills}"

# Worktree efêmero, fora do checkout principal (auto-removido no exit).
WT="$(mktemp -d "${TMPDIR:-/tmp}/skills-inventory-wt.XXXXXX")"
cleanup() {
  GIT_OPTIONAL_LOCKS=0 git -C "$REPO" worktree remove --force "$WT" 2>/dev/null \
    || rm -rf "$WT"
  GIT_OPTIONAL_LOCKS=0 git -C "$REPO" worktree prune 2>/dev/null || true
}
trap cleanup EXIT

# fetch atualiza só o ref origin/* (compartilhado entre worktrees) — não mexe na
# working tree nem no HEAD do checkout principal, então é seguro com sessões paralelas.
GIT_OPTIONAL_LOCKS=0 git -C "$REPO" fetch origin --quiet

# Worktree destacado em origin/main (estado fresco, sem depender do HEAD do checkout).
GIT_OPTIONAL_LOCKS=0 git -C "$REPO" -c submodule.recurse=false \
  worktree add -q --detach "$WT" origin/main
cd "$WT"

node skills/skills-inventory/scripts/build.mjs \
  --repo skills --local "$LOCAL_SKILLS" \
  --out skills/REGISTRY.md --json skills/skills-inventory/registry.json \
  --host "$(scutil --get LocalHostName 2>/dev/null || hostname -s)"

if GIT_OPTIONAL_LOCKS=0 git diff --quiet -- skills/REGISTRY.md skills/skills-inventory/registry.json; then
  echo "skills-inventory: sem drift ($(date -u +%FT%TZ))"
  exit 0
fi

BR="chore/skills-inventory-refresh-$(date +%Y%m%d-%H%M)"
GIT_OPTIONAL_LOCKS=0 git switch -c "$BR"
GIT_OPTIONAL_LOCKS=0 git add skills/REGISTRY.md skills/skills-inventory/registry.json
GIT_OPTIONAL_LOCKS=0 git commit -q \
  -m "chore(skills-inventory): refresh REGISTRY (drift detectado)" \
  -m "Co-Authored-By: Star Command <star-command@adventurelabs.com.br>"
GIT_OPTIONAL_LOCKS=0 git push -u origin "$BR" --quiet

BODY=$(mktemp)
cat > "$BODY" <<'EOF'
Drift detectado pelo anti-rot do `skills-inventory` (LaunchAgent semanal, command deck).
Skill criada/movida/removida sem atualizar o índice — `REGISTRY.md` regenerado a partir do filesystem.

Revise e mergeie. Para regenerar à mão: `/skills-inventory`.

---

<sub>Generated with <a href="https://adventurelabs.com.br">Star Command</a> by Adventure Labs · <em>agente: Star Command</em></sub>
EOF
# --head/--base/-R explícitos: rodando de worktree efêmero o gh NÃO infere a branch
# nem o repo sozinho (falha com "must first push the current branch / use --head").
# Sem mascarar com `|| true`: se o PR falhar, a branch ficou pushada órfã — reporte e
# saia não-zero pra não anunciar "PR aberto" mentirosamente (o LaunchAgent loga o erro).
if gh pr create -R adventurelabsbrasil/adventure-labs \
     --title "chore(skills-inventory): refresh REGISTRY (drift)" \
     --body-file "$BODY" --head "$BR" --base main; then
  rm -f "$BODY"
  echo "skills-inventory: drift → PR aberto na branch $BR"
else
  rm -f "$BODY"
  echo "skills-inventory: drift → branch $BR PUSHADA mas gh pr create FALHOU — abrir PR à mão" >&2
  exit 1
fi
