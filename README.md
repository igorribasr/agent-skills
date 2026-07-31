# 🧠 agent-skills

Biblioteca pessoal de skills para o [Google Antigravity](https://antigravity.google) Agent.

Skills são pacotes modulares que estendem as capacidades do agente com conhecimentos especializados, fluxos de trabalho e ferramentas.

## 📦 Skills disponíveis

| Skill | Descrição |
|-------|-----------|
| [`commit-work`](./commit-work/) | Automatiza commits de trabalho |
| [`crafting-effective-readmes`](./crafting-effective-readmes/) | Criação de READMEs eficazes |
| [`daily-meeting-update`](./daily-meeting-update/) | Atualizações para reuniões diárias |
| [`find-skills`](./find-skills/) | Encontra e instala skills disponíveis |
| [`frontend-design`](./frontend-design/) | Direção visual e design de UI distintos e intencionais |
| [`humanizer`](./humanizer/) | Humaniza textos gerados por IA |
| [`meme-factory`](./meme-factory/) | Geração de memes |
| [`naming-analyzer`](./naming-analyzer/) | Análise e sugestão de nomenclaturas |
| [`session-handoff`](./session-handoff/) | Transferência de contexto entre sessões de agente |
| [`ship-learn-next`](./ship-learn-next/) | Fluxo de ship → learn → next iteration |
| [`skill-judge`](./skill-judge/) | Avaliação e curadoria de skills |
| [`voice-narrator`](./voice-narrator/) | Narração de áudio com Kokoro TTS + RVC voice cloning |

## 🚀 Instalação

### Instalar uma skill globalmente (via cópia manual)

```powershell
Copy-Item -Path ".\<skill-name>" -Destination "$env:USERPROFILE\.gemini\antigravity-cli\skills\<skill-name>" -Recurse
```

### Sincronizar todas as skills do repositório

```powershell
# Atualizar o repo local
git -C "D:\Documents\GitHub\agent-skills" pull

# Copiar todas as skills para o diretório global
Get-ChildItem -Path "D:\Documents\GitHub\agent-skills" -Directory |
  Where-Object { $_.Name -ne ".git" } |
  ForEach-Object {
    Copy-Item -Path $_.FullName -Destination "$env:USERPROFILE\.gemini\antigravity-cli\skills\$($_.Name)" -Recurse -Force
  }
```

## 🔄 Fluxo de trabalho

1. Edite ou crie skills neste repositório
2. Commit e push para o GitHub
3. Em qualquer máquina, faça `git pull` e sincronize com o script acima

## 📁 Estrutura de uma skill

```
skill-name/
├── SKILL.md          # Instruções para o agente (obrigatório)
├── scripts/          # Scripts auxiliares (opcional)
├── examples/         # Exemplos de uso (opcional)
└── resources/        # Recursos adicionais (opcional)
```
