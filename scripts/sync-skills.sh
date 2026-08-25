#!/usr/bin/env bash
# sync-skills.sh - Sincroniza todas as skills para Antigravity, Claude Code, Codex e Agents
# Compatível com macOS, Linux e WSL.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "=========================================================="
echo " Sincronizando Skills Globais (macOS / Linux / WSL)"
echo " Origem: $REPO_ROOT"
echo "=========================================================="

# 1. Puxar atualizações do GitHub
echo ""
echo "[1/4] Verificando atualizações no GitHub..."
if git -C "$REPO_ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    git -C "$REPO_ROOT" pull --ff-only || echo "  Aviso: git pull não pôde ser executado automaticamente."
fi

# 2. Diretórios destino
TARGET_DIRS=(
    "$HOME/.gemini/config/skills"
    "$HOME/.gemini/antigravity-cli/skills"
    "$HOME/.claude/skills"
    "$HOME/.codex/skills"
    "$HOME/.agents/skills"
)

# 3. Listar skills válidas (diretórios com SKILL.md)
SKILLS=()
for dir in "$REPO_ROOT"/*/; do
    dir_name="$(basename "$dir")"
    if [ "$dir_name" != ".git" ] && [ "$dir_name" != "scripts" ] && [ -f "$dir/SKILL.md" ]; then
        SKILLS+=("$dir")
    fi
done

echo ""
echo "[2/4] Total de skills encontradas no repositório: ${#SKILLS[@]}"

# 4. Sincronizar
echo ""
echo "[3/4] Instalando skills nos diretórios globais de cada CLI..."
for target in "${TARGET_DIRS[@]}"; do
    echo "-> Destino: $target"
    mkdir -p "$target"
    
    count=0
    for skill_path in "${SKILLS[@]}"; do
        skill_name="$(basename "$skill_path")"
        dest_path="$target/$skill_name"
        mkdir -p "$dest_path"
        cp -R "$skill_path/." "$dest_path/"
        count=$((count + 1))
    done
    echo "   OK: $count skills instaladas/atualizadas."
done

echo ""
echo "[4/4] Validação de integridade..."
for target in "${TARGET_DIRS[@]}"; do
    if [ -d "$target" ]; then
        total=$(find "$target" -mindepth 1 -maxdepth 1 -type d | wc -l)
        echo "  - $target: $total skills disponíveis"
    fi
done

echo ""
echo "=========================================================="
echo " Sincronização concluída com sucesso para todos os CLIs!"
echo "=========================================================="
