---
name: to-spec
description: >-
  Transforma a conversa atual em um spec (PRD) e publica no tracker.
  Gatilhos: "transforma a conversa em spec", "vira um spec", "publica o
  spec", "to-spec", "escreve o PRD disso", "documenta essa decisão como
  spec". NÃO usar para elicitar do zero — esta skill SINTETIZA o que já foi
  discutido na conversa + codebase, não entrevista; para arrancar requisitos
  ou modelo do nada use `grill-me` / `domain-modeling`.
disable-model-invocation: true
metadata:
  type: skill
  hosts: all
  owner_agent: star-command
  status: active
---

Pega o contexto da conversa atual + entendimento do codebase e produz um **spec** (você pode conhecer como PRD). **NÃO entreviste o Founder** — sintetize o que já foi discutido. Se falta contexto pra sintetizar, a origem é `wayfinder` (decisões) ou `prototype` (snippets), não uma entrevista.

Elo da cadeia: alimentada por `wayfinder` (decisões) e `prototype` (snippets) → produz o spec → é o handoff pra `to-tickets` (que quebra em issues executáveis).

## Processo

1. Explore o repo pra entender o estado atual, se ainda não fez. Use o **vocabulário do glossário do projeto** ao longo de todo o spec (skill `glossario`) e **respeite os ADRs** da área que você está tocando.

2. Esboce os **seams** (costuras) onde a feature será testada. Prefira seams existentes a novos. Use o seam mais alto possível. Quanto menos seams no codebase, melhor — **o número ideal de seams é UM**. Se precisar de seam novo, proponha no ponto mais alto que conseguir. **Confirme os seams com o Founder** antes de escrever o spec.

3. Escreva o spec usando o template abaixo. Depois publique como issue no GitHub (ver **Gates**), com o label `ready-for-agent`. Sem triagem adicional.

<spec-template>

## Problem Statement
O problema que o usuário enfrenta, na perspectiva dele.

## Solução
A solução pro problema, na perspectiva do usuário.

## User Stories
Uma lista **numerada, longa e extensiva** de user stories, cada uma no formato:

1. Como <ator>, quero <X>, para <benefício>

Exemplo: `1. Como cliente do banco mobile, quero ver o saldo das minhas contas, para decidir melhor sobre meus gastos.`

Cubra todos os aspectos da feature.

## Decisões de Implementação
Módulos a construir/modificar; interfaces desses módulos; clarificações técnicas; decisões arquiteturais; mudanças de schema; contratos de API; interações específicas.

**NÃO inclua file paths nem code snippets** — ficam stale rápido. **Exceção:** se um `prototype` produziu um snippet que codifica uma decisão com mais precisão que a prosa (state machine, reducer, schema, type shape), inline dentro da decisão relevante e note que veio de um protótipo. Corte pras partes ricas em decisão — não um demo funcional.

## Decisões de Teste
O que faz um bom teste (testar só comportamento externo, não detalhe de implementação); quais módulos serão testados; prior art (testes similares no codebase).

## Fora de Escopo
O que fica de fora deste spec.

## Notas
Notas adicionais sobre a feature.

</spec-template>

## Gates

- **Tracker = GitHub.** Preflight `gh label list -R <repo>`. Labels neste repo são **BARE-NAME** — o eixo `area/`/`domain/` vive na **descrição** do label, não no nome; **NÃO** usar `area/x` com barra (a ADR-033 que prescreve barra é só **Proposta**, não vigente). Se faltar o label `ready-for-agent`, crie-o bare com descrição em PT.
- **Issue multi-linha → `--body-file`** (nunca `--body` com heredoc inline pra corpo longo).
- **NO-PII em issue público:** sem nome de cliente/pessoa, campanha, IDs ou financeiro. Marca/agente OK. Varra o corpo antes de publicar.
- **Autorização do Founder antes de criar o issue** — criar issue é efeito externo. A skill **propõe** o spec e o comando `gh` e **espera OK** explícito.
- **Assinatura Star Command** no fim do corpo do issue:
  ```
  <sub><img src="https://app.adventurelabs.com.br/agents/star-command.png" width="16" height="16" align="top"> Generated with <a href="https://adventurelabs.com.br">Star Command</a> by Adventure Labs · <em>agente: Star Command</em></sub>
  ```

## Relacionados
`wayfinder` (decisões que alimentam o spec) · `prototype` (snippets inlináveis) · `to-tickets` (consome este spec) · `domain-modeling` / `grill-me` (para elicitar do zero, quando NÃO é o caso) · `glossario` (vocabulário canônico).
