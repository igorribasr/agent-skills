---
name: drive-organizacao
description: Audita e mantém a organização/nomenclatura/metadata padronizada dos arquivos do Google Drive corporativo da Adventure (`mydrive:`), rodando o sistema drive-taxonomy no xeon (ollama local). Read-only por design — DIAGNOSTICA e RECOMENDA (mover X pra categoria Z, renomear Y, preencher metadata), nunca move/renomeia sem OK explícito do Founder. Use quando Rodrigo pedir "organiza o Drive", "audita a organização/estrutura do Drive", "o Drive está bagunçado", "padroniza os nomes/pastas do Drive", "roda o organizador do Drive", "o que está fora do lugar no Drive", "revisa a taxonomia do Drive", "arquivos soltos na raiz", ou ao agendar a revisão contínua. NÃO usar pra backup do Drive (rclone/backup-to-drive), pra baixar arquivo específico do WhatsApp (whatsapp-puxar), nem pra editar planilha do Drive (drive-xlsx-edit-rebuild).
argument-hint: "[full | continuous | report]"
user-invocable: true
---

# drive-organizacao

Interface pro sistema **drive-taxonomy** (mora em `xeon:~/drive-taxonomy`). Padroniza
organização + nomenclatura + metadata do `mydrive:`. **Só recomenda.**

## Princípio

- **Read-only por design.** O sistema gera relatório + recomendações; NADA é movido
  ou renomeado sem aprovação explícita do Founder num lote (Fase C, ainda não construída).
- **Dado não sai do host.** Julgamento roda em ollama local no xeon (CPU). Não mandar
  conteúdo de arquivo pra API externa.
- **Fonte de verdade = `spec/taxonomy_spec.toml`** no xeon. Categorias, regras de nome
  e schema de metadata vivem ali; editável pelo Founder. Se ele quer mudar o padrão,
  edita o spec — não hardcode regra nova no código.

## Modos

- `full` (default): auditoria completa. `ssh xeon '~/drive-taxonomy/bin/run_audit.sh'`
- `continuous`: rodada incremental do fluxo contínuo (respeita Shabat).
  `ssh xeon '~/drive-taxonomy/bin/continuous.sh'`
- `report`: só mostra o último relatório sem re-rodar.

## Passo a passo

1. **Conectar e rodar** (o `run_audit.sh` sobe o ollama on-demand e desliga no fim):
   ```bash
   ssh xeon '~/drive-taxonomy/bin/run_audit.sh'
   ```
   A varredura completa leva ~40-60 min em CPU (o LLM só toca itens sinalizados).
   Pra rodada rápida sem re-julgar, use o modo `report`.

2. **Ler o resultado** — pega o run mais recente:
   ```bash
   ssh xeon 'RID=$(cat ~/drive-taxonomy/data/last_run); cat ~/drive-taxonomy/reports/report_$RID.md'
   ```
   O `.jsonl` irmão (`recommendations_$RID.jsonl`) é a lista máquina-legível.

3. **Apresentar ao Founder**: priorize `ROOT_DRIFT` (arquivos/pastas soltos na raiz —
   o mais acionável), depois duplicatas e nomes ruins. Resuma em bloco clicável; NÃO
   despeje as 400 recomendações. Ofereça aprovar um lote.

4. **Aplicar (gated)**: se e quando o Founder aprovar mover/renomear, isso é a Fase C —
   ainda NÃO existe. Não improvisar `rclone move` sem construir o aplicador com dry-run,
   confirmação por re-leitura (HTTP 200 ≠ moveu) e log reversível.

## Agendar o contínuo

`continuous.sh` é idempotente e barato. Agendar por `systemd --user` timer semanal no
xeon (guarda de Shabat já embutida). Ver `xeon:~/drive-taxonomy/README.md`.

## Gotchas

- **ollama masked no xeon**: o serviço systemd está mascarado de propósito (poupa RAM;
  divide 15 GB com OpenClaw). Os scripts sobem `ollama serve` on-demand e desligam. Não
  desmascarar sem falar com o Founder.
- **rclone client_id compartilhado**: o remote `mydrive` usa o client_id público do
  rclone (aposenta em 2026). Migrar pra service account read-only (`gcloud-specialist`).
- **Escala**: ~7-8k itens, ~74 GB. Coleta idempotente; rode à vontade.
- Motor default = `qwen2.5:3b-instruct`. Upgrade de qualidade = trocar pra `:7b` no spec.
