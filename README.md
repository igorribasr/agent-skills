# 🧠 agent-skills

Biblioteca pessoal de skills para **Google Antigravity**, **Claude Code**, **Codex CLI** e agentes compatíveis com o padrão Open Agents.

Skills são pacotes modulares que estendem as capacidades dos agentes com conhecimentos especializados, fluxos de trabalho e ferramentas de ponta.

---

## 📦 Skills disponíveis

> Total: **52 skills** (12 pessoais + 28 do [mattpocock/skills](https://github.com/mattpocock/skills) + 12 do [adventure-labs](https://github.com/adventurelabsbrasil/adventure-labs))

### 🧑‍💻 Skills pessoais

| Skill | Descrição |
|-------|-----------|
| [`commit-work`](./commit-work/) | Automatiza commits de trabalho de alta qualidade |
| [`crafting-effective-readmes`](./crafting-effective-readmes/) | Criação de READMEs eficazes e direcionados |
| [`daily-meeting-update`](./daily-meeting-update/) | Atualizações inteligentes para reuniões diárias/standup |
| [`find-skills`](./find-skills/) | Encontra e instala skills disponíveis |
| [`frontend-design`](./frontend-design/) | Direção visual e design de UI distintos e intencionais |
| [`humanizer`](./humanizer/) | Remove padrões óbvios de escrita gerada por IA |
| [`meme-factory`](./meme-factory/) | Geração de memes via API |
| [`naming-analyzer`](./naming-analyzer/) | Análise e sugestão de boas nomenclaturas |
| [`session-handoff`](./session-handoff/) | Transferência de contexto entre sessões de agentes |
| [`ship-learn-next`](./ship-learn-next/) | Transforma aprendizados em planos acionáveis |
| [`skill-judge`](./skill-judge/) | Avaliação e curadoria de qualidade de skills |
| [`voice-narrator`](./voice-narrator/) | Narração de áudio com Kokoro TTS + clonagem de voz RVC |

### ⚙️ Engineering (mattpocock)

| Skill | Descrição |
|-------|-----------|
| [`mp-ask-matt`](./mp-ask-matt/) | Consulta técnica em estilo "pergunte ao Matt" |
| [`mp-code-review`](./mp-code-review/) | Revisão criteriosa de código em dois eixos (Spec e Standards) |
| [`mp-codebase-design`](./mp-codebase-design/) | Vocabulário compartilhado para design de módulos profundos |
| [`mp-diagnosing-bugs`](./mp-diagnosing-bugs/) | Diagnóstico sistemático de bugs e regressões |
| [`mp-domain-modeling`](./mp-domain-modeling/) | Modelagem de domínio e definições canônicas |
| [`mp-grill-with-docs`](./mp-grill-with-docs/) | Interrogatório técnico rigoroso com docs oficiais |
| [`mp-implement`](./mp-implement/) | Implementação orientada a especificações |
| [`mp-improve-codebase-architecture`](./mp-improve-codebase-architecture/) | Identificação de oportunidades de deepening e refatoração |
| [`mp-prototype`](./mp-prototype/) | Prototipagem rápida para validar hipóteses de design |
| [`mp-research`](./mp-research/) | Pesquisa técnica estruturada em fontes primárias |
| [`mp-resolving-merge-conflicts`](./mp-resolving-merge-conflicts/) | Resolução guiada de merge/rebase conflicts |
| [`mp-tdd`](./mp-tdd/) | Desenvolvimento guiado por testes (Red-Green-Refactor) |
| [`mp-to-spec`](./mp-to-spec/) | Transformação de ideias em especificações formais |
| [`mp-to-tickets`](./mp-to-tickets/) | Quebra de requisitos em tickets granulares |
| [`mp-triage`](./mp-triage/) | Triagem e priorização de issues e bugs |
| [`mp-wayfinder`](./mp-wayfinder/) | Navegação e orientação em codebases complexos |

### 🛠️ Misc (mattpocock)

| Skill | Descrição |
|-------|-----------|
| [`mp-git-guardrails-claude-code`](./mp-git-guardrails-claude-code/) | Hooks de proteção contra comandos perigosos de git |
| [`mp-migrate-to-shoehorn`](./mp-migrate-to-shoehorn/) | Migração de asserções `as` em testes para shoehorn |
| [`mp-scaffold-exercises`](./mp-scaffold-exercises/) | Estruturação de exercícios educacionais |
| [`mp-setup-pre-commit`](./mp-setup-pre-commit/) | Configuração de Husky e lint-staged em repositórios |

### 🚀 Productivity (mattpocock)

| Skill | Descrição |
|-------|-----------|
| [`mp-grill-me`](./mp-grill-me/) | Entrevista rigorosa para testar planos e ideias |
| [`mp-grilling`](./mp-grilling/) | Stress-test de tomadas de decisão técnicas |
| [`mp-handoff`](./mp-handoff/) | Criação de documentos de handoff de contexto |
| [`mp-teach`](./mp-teach/) | Ensino didático de conceitos complexos |
| [`mp-writing-great-skills`](./mp-writing-great-skills/) | Guia de melhores práticas para escrever skills |

### 👤 Personal (mattpocock)

| Skill | Descrição |
|-------|-----------|
| [`mp-edit-article`](./mp-edit-article/) | Edição e refinamento de artigos e ensaios |
| [`mp-obsidian-vault`](./mp-obsidian-vault/) | Integração e gestão de notas no Obsidian Vault |

### 🏢 Adventure Labs

| Skill | Descrição |
|-------|-----------|
| [`adv-wayfinder-orchestrated`](./adv-wayfinder-orchestrated/) | Planejamento de iniciativas de grande porte via tickets |
| [`adv-grill-me`](./adv-grill-me/) | Interrogatório técnico alinhado aos padrões Adventure |
| [`adv-grill-with-docs`](./adv-grill-with-docs/) | Auditoria profunda que atualiza o canon ssot |
| [`adv-teach`](./adv-teach/) | Ensinar habilidades e conceitos novos |
| [`adv-to-spec`](./adv-to-spec/) | Transformar requisitos informais em specs formais |
| [`adv-limpar-codigo`](./adv-limpar-codigo/) | Refatoração e limpeza de código aplicando Clean Code |
| [`adv-img-para-webp`](./adv-img-para-webp/) | Otimização e conversão de imagens em lote para WebP |
| [`adv-n8n-specialist`](./adv-n8n-specialist/) | Operação, exportação e diagnóstico de fluxos n8n |
| [`adv-igor-start`](./adv-igor-start/) | Início de sessão de trabalho com boot leve |
| [`adv-igor-end`](./adv-igor-end/) | Encerramento seguro de sessão com abertura de PR assinado |
| [`adv-drive-organizacao`](./adv-drive-organizacao/) | Organização estruturada do Google Drive corporativo |
| [`adv-skills-inventory`](./adv-skills-inventory/) | Inventário e automação de índice de skills |

---

## 🚀 Como Usar em Qualquer Máquina (Windows, Mac ou Linux)

Como o repositório é público no GitHub, você pode instalar e usar todas as suas skills em qualquer computador.

### 🪟 No Windows (PowerShell)

1. **Clone o repositório**:
   ```powershell
   git clone https://github.com/igorribasr/agent-skills.git "$HOME\Documents\agent-skills"
   cd "$HOME\Documents\agent-skills"
   ```

2. **Execute o script de sincronização**:
   ```powershell
   powershell -ExecutionPolicy Bypass -File .\scripts\sync-skills.ps1
   ```

3. **(Opcional) Atalho global `sync-skills`**:
   Copie `sync-skills.cmd` para uma pasta do seu PATH (ex: `$HOME\.local\bin` ou `$HOME\AppData\Local\Microsoft\WindowsApps`) para poder rodar apenas `sync-skills` de qualquer lugar.

---

### 🍎 No macOS / 🐧 Linux / WSL (Bash / Zsh)

1. **Clone o repositório**:
   ```bash
   git clone https://github.com/igorribasr/agent-skills.git ~/agent-skills
   cd ~/agent-skills
   ```

2. **Execute o script de sincronização**:
   ```bash
   chmod +x ./scripts/sync-skills.sh
   ./scripts/sync-skills.sh
   ```

3. **(Opcional) Atalho no terminal**:
   Adicione um alias no seu `~/.bashrc` ou `~/.zshrc`:
   ```bash
   alias sync-skills="bash ~/agent-skills/scripts/sync-skills.sh"
   ```

---

## 🔄 Diretórios Globais Sincronizados

O script instala e mantém atualizadas as skills nos diretórios oficiais de cada CLI:

| CLI / Ferramenta | Caminho no Windows | Caminho no macOS / Linux |
|---|---|---|
| **Google Antigravity** | `~/.gemini/config/skills/` | `~/.gemini/config/skills/` |
| **Claude Code** | `~/.claude/skills/` | `~/.claude/skills/` |
| **Codex CLI** | `~/.codex/skills/` | `~/.codex/skills/` |
| **Padrão Open Agents** | `~/.agents/skills/` | `~/.agents/skills/` |

---

## 📁 Estrutura de uma Skill

```
nome-da-skill/
├── SKILL.md          # Instruções e metadados para o agente (obrigatório)
├── scripts/          # Scripts auxiliares e automações (opcional)
├── examples/         # Exemplos de uso e referências (opcional)
└── resources/        # Recursos adicionais e templates (opcional)
```
