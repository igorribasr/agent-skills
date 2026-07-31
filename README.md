# 🧠 agent-skills

Biblioteca pessoal de skills para o [Google Antigravity](https://antigravity.google) Agent.

Skills são pacotes modulares que estendem as capacidades do agente com conhecimentos especializados, fluxos de trabalho e ferramentas.

## 📦 Skills disponíveis

> Total: **40 skills** (12 pessoais + 28 do [mattpocock/skills](https://github.com/mattpocock/skills))

### 🧑‍💻 Skills pessoais

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

### ⚙️ Engineering (mattpocock)

| Skill | Descrição |
|-------|-----------|
| [`mp-ask-matt`](./mp-ask-matt/) | Consulta em estilo "pergunte ao Matt" |
| [`mp-code-review`](./mp-code-review/) | Revisão de código criteriosa |
| [`mp-codebase-design`](./mp-codebase-design/) | Design de arquitetura de codebase |
| [`mp-diagnosing-bugs`](./mp-diagnosing-bugs/) | Diagnóstico sistemático de bugs |
| [`mp-domain-modeling`](./mp-domain-modeling/) | Modelagem de domínio |
| [`mp-grill-with-docs`](./mp-grill-with-docs/) | Interrogatório técnico com docs |
| [`mp-implement`](./mp-implement/) | Implementação orientada a spec |
| [`mp-improve-codebase-architecture`](./mp-improve-codebase-architecture/) | Melhoria de arquitetura |
| [`mp-prototype`](./mp-prototype/) | Prototipagem rápida |
| [`mp-research`](./mp-research/) | Pesquisa técnica estruturada |
| [`mp-resolving-merge-conflicts`](./mp-resolving-merge-conflicts/) | Resolução de merge conflicts |
| [`mp-tdd`](./mp-tdd/) | Test-Driven Development |
| [`mp-to-spec`](./mp-to-spec/) | Geração de especificações |
| [`mp-to-tickets`](./mp-to-tickets/) | Conversão de tarefas em tickets |
| [`mp-triage`](./mp-triage/) | Triagem de issues e bugs |
| [`mp-wayfinder`](./mp-wayfinder/) | Navegação e orientação em codebases |

### 🛠️ Misc (mattpocock)

| Skill | Descrição |
|-------|-----------|
| [`mp-git-guardrails-claude-code`](./mp-git-guardrails-claude-code/) | Proteções de git |
| [`mp-migrate-to-shoehorn`](./mp-migrate-to-shoehorn/) | Migração para shoehorn |
| [`mp-scaffold-exercises`](./mp-scaffold-exercises/) | Scaffolding de exercícios |
| [`mp-setup-pre-commit`](./mp-setup-pre-commit/) | Configuração de pre-commit hooks |

### 🚀 Productivity (mattpocock)

| Skill | Descrição |
|-------|-----------|
| [`mp-grill-me`](./mp-grill-me/) | Interrogatório de ideias |
| [`mp-grilling`](./mp-grilling/) | Técnicas de grilling |
| [`mp-handoff`](./mp-handoff/) | Handoff de sessão/contexto |
| [`mp-teach`](./mp-teach/) | Ensino e explicação de conceitos |
| [`mp-writing-great-skills`](./mp-writing-great-skills/) | Como escrever boas skills |

### 👤 Personal (mattpocock)

| Skill | Descrição |
|-------|-----------|
| [`mp-edit-article`](./mp-edit-article/) | Edição de artigos |
| [`mp-obsidian-vault`](./mp-obsidian-vault/) | Integração com Obsidian Vault |

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
