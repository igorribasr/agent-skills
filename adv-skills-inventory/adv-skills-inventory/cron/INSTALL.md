# Instalar o anti-rot do skills-inventory (macbook)

Roda **só no command deck (macbook)** — é onde `~/.claude/skills` é canônico. Outros hosts
não rodam o refresh-do-REGISTRY (contaminariam o índice); eles só fazem upsert das próprias
linhas em `adv_skills` (rode o gerador com `--json` + upsert quando quiser).

**Pré-req:** monorepo em `~/Code/adventure-labs`, `node` no PATH, `gh` autenticado.

```bash
# 1) pós-merge, com main atualizada:
chmod +x ~/Code/adventure-labs/skills/skills-inventory/cron/refresh.sh

# 2) instalar o LaunchAgent (semanal, segunda 09:05):
cp ~/Code/adventure-labs/skills/skills-inventory/cron/com.adventurelabs.skills-inventory.plist \
   ~/Library/LaunchAgents/
launchctl unload ~/Library/LaunchAgents/com.adventurelabs.skills-inventory.plist 2>/dev/null || true
launchctl load   ~/Library/LaunchAgents/com.adventurelabs.skills-inventory.plist

# 3) testar agora (dispara o refresh; abre PR só se houver drift):
launchctl start com.adventurelabs.skills-inventory
tail -f /tmp/skills-inventory.out.log
```

Desinstalar: `launchctl unload ~/Library/LaunchAgents/com.adventurelabs.skills-inventory.plist && rm ~/Library/LaunchAgents/com.adventurelabs.skills-inventory.plist`.

> O refresh abre PR autonomamente quando detecta drift (skill criada/movida/removida sem
> atualizar o índice) — mesmo padrão dos update-watch. Sem drift = no-op silencioso.
