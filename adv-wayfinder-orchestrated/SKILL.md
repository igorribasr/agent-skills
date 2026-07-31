---
name: wayfinder-orchestrated
description: Planejar uma iniciativa GRANDE e nebulosa — maior do que cabe num contexto de agente — como um mapa compartilhado de tickets-de-decisão no GitHub, resolvendo um por sessão e roteando cada subissue para Luna, Terra ou Sol conforme complexidade e custo. Use quando o Founder disser "mapear uma iniciativa grande", "planejar isso que não cabe num contexto", "cria o mapa disso", "chart the map", "abre o wayfinder orquestrado", "trabalhar o mapa com subagentes", "resolve o próximo ticket do mapa", ou ao encarar algo multi-sessão e foggy (CORE, inventário de devices, dino-nfg, integração nova). NÃO usar para ops do dia nem para uma tarefa que cabe numa sessão.
metadata:
  type: skill
  hosts: all
  owner_agent: star-command
  status: active
---

# Wayfinder Orchestrated — mapa de decisões com roteamento de subagentes

> Uma iniciativa grande não se resolve de uma vez. Você desenha um **mapa** no issue tracker, transforma cada névoa em **um ticket = uma decisão**, e resolve **um por sessão** até o caminho ficar claro. Planejar é a atividade principal; entregar vem depois, quando não sobrou nada pra decidir.

Adaptado de [wayfinder do Matt Pocock](https://github.com/mattpocock/skills). Encaixada no mundo Adventure: substrato GitHub (labels **bare-name** do repo — a ADR-033 é só Proposta), no-PII, e reuso das skills de decisão que já existem.

## Quando usar / quando NÃO usar

- **É pra:** iniciativa **multi-sessão e foggy** — mais do que cabe num contexto de agente. Ex: CORE (BullMQ+LangGraph), inventário de devices (ADR-014), dino-nfg, uma integração nova de cliente.
- **NÃO é pra:** ops do dia (`sueli-deploy`, `liara-meta-ads`, `sueli-extrato-reconcilia`), nem tarefa que fecha numa sessão. Pra isso, a skill operacional específica.
- **Relação com o Âncora:** o Protocolo Âncora protege **uma sessão** (parking 🅿️ efêmero). O wayfinder é o irmão **cross-sessão**: o mapa é o 🅿️ persistido no tracker, que sobrevive ao contexto.

## Princípio não-negociável

1. **Um ticket = uma decisão.** Nada de ticket guarda-chuva.
2. **Um ticket por sessão** (exceto research, que é AFK e pode rodar em paralelo). Fechar do início ao fim é o combustível — não abrir cinco, fechar zero.
3. **O mapa é índice, não store.** Cada decisão mora em **um** lugar só (o ticket). O mapa apenas aponta.
4. **Refira tickets por TÍTULO, não número.** Uma parede de `#42, #43, #44` é ilegível; títulos se leem de relance.
5. **Charting não resolve nada.** Desenhar o mapa é uma sessão; resolver é outra.

## Orquestração de subagentes e robustez financeira

No início de cada turno iniciado por um prompt do usuário, leia ou releia o `AGENTS.md` aplicável ao escopo **antes de qualquer resposta, classificação ou ação**. Em seguida, classifique toda demanda — pergunta, solicitação de tarefa, issue ou subissue do GitHub, inclusive uma subissue de um `[MAP]` — e aplique obrigatoriamente esta matriz; a origem da demanda não altera o roteamento.

1. **Subagente Luna — esforço Low/None:** delegue perguntas factuais, explicações diretas, resumos, transformações simples, testes unitários, documentação, boilerplate, código repetitivo e alterações simples de sintaxe. Não gaste execução própria de Sol nessas demandas.
2. **Subagente Terra — esforço Medium/Low:** delegue perguntas que exijam análise padrão ou raciocínio em múltiplas etapas, lógica de negócios padrão, endpoints de API comuns e refatorações que não afetem a arquitetura central.
3. **Execução própria Sol — esforço Medium:** execute pessoalmente somente quando a demanda exigir decisões complexas de arquitetura, mudanças críticas no core ou decisões de alto impacto.

Se o runtime não expuser um modelo chamado Luna, instancie a função especializada **Luna** usando o modelo econômico disponível com esforço Low; não promova a task para Sol apenas por indisponibilidade do nome do modelo.

Ao instanciar um subagente, informe imediatamente ao usuário, substituindo os colchetes pelos valores reais e preservando este formato:

> 🤖 *Subagente [Luna/Terra] instanciado para resolver a task [Nome da Task] com esforço [X].*

Esta regra vale para **todo input do usuário**, inclusive perguntas e solicitações que não estejam vinculadas ao GitHub. No contexto do Wayfinder, o roteamento não muda a restrição de resolver apenas **um ticket por sessão**, exceto research. Subagentes executores pertencem ao ticket reivindicado; não use a matriz como autorização para resolver várias subissues do mapa em paralelo.

## Estrutura do mapa

Um único issue = o mapa. Labels **bare-name** (o esquema vivo do repo — confirme com o preflight `gh label list`):

- **Título:** `[MAP] <destino em 1 linha>`
- **Labels:** `wayfinder` + o domínio bare (ex: `core`, `sueli`, `liara`). ⚠️ O repo usa **bare-name**: o nome é curto e o `area/`/`domain/` vive na *descrição* (PT), não no nome. A ADR-033 (que prescreve `area/wayfinder` com `/`) é só **Proposta** — não o vivo. Se o label `wayfinder` não existir, criar (descrição PT). **Nunca** inventar `area/wayfinder`.
- **Corpo** (5 seções):
  - **Destino** — 1-2 linhas: a spec, decisão ou mudança que a iniciativa busca.
  - **Notas** — contexto de domínio + preferências fixas (inclusive quais skills invocar em cada tipo).
  - **Decisões tomadas** — tickets fechados, um gist de 1 linha cada (o índice).
  - **Ainda não especificado** — névoa in-scope, ainda vaga demais pra virar ticket.
  - **Fora de escopo** — o que foi conscientemente descartado além do destino.

Tickets = **child issues** do mapa, cada um com `wayfinder` + o domínio (`core`…) + um label de tipo bare (`enhancement`/`question`/`chore`/`documentation`). Bloqueio entre tickets = **native dependencies** do GitHub. Um ticket é **reivindicado** (assign) antes de começar.

## Tipos de ticket → skills Adventure

| Tipo | Modo | Label | Como resolver |
|---|---|---|---|
| **Research** | AFK (paralelo) | `type/question` | subagent **`deep-research`** — levanta fatos de doc/externo |
| **Grilling** | HITL | `type/question` | **`grill-me`** / **`grill-with-docs`** + **`domain-modeling`** — decisão por conversa |
| **Prototype** | HITL | `type/enhancement` | artefato barato pra elevar a fidelidade da discussão — usar a skill de artefato que couber (`landing-page-fast`, `nano-banana`, `heygen-specialist`…). Não há skill `/prototype` dedicada. |
| **Task** | HITL/AFK | `type/chore` | trabalho manual que desbloqueia (provisionar acesso, mover dado…) |

## Fluxo A — "Chart the map" (invocação inicial)

1. Nomeie o destino via **`grill-me`**/**`grill-with-docs`** + **`domain-modeling`**.
2. Mapeie a fronteira **breadth-first** por todo o espaço (não fundo numa parte só).
3. Crie o mapa com Destino + Notas; **deixe Decisões-tomadas vazio**.
4. Crie os tickets-de-decisão como child issues; ligue as arestas de bloqueio.
5. Dispare os research tickets (`deep-research`) em paralelo.
6. **PARE.** Charting é uma sessão; não resolva nada agora.

## Fluxo B — "Work through the map" (invocação contínua)

1. Carregue a visão low-res do mapa.
2. Reivindique (assign) **um** ticket de fronteira não-reivindicado — ou o que o Founder apontar.
3. Resolva-o, invocando a skill nomeada nas Notas.
4. Poste a resolução como **comentário**, feche o issue, e faça **append** de 1 linha em "Decisões tomadas".
5. Crie tickets recém-surgidos e gradue a névoa que clareou de "Ainda não especificado" → ticket.
6. Ticket que caiu além do destino → mova pra **Fora de escopo** em vez de resolver.

**Restrição-chave:** nunca resolva **mais de um** ticket por sessão — exceto research.

## Quando o caminho fica claro → handoff pro build

O mapa está **completo** quando "o caminho está claro — não sobrou nada a decidir antes de alguém ir e construir". Aí **não pare no mapa**: o wayfinder mapeia decisões, não código. Faça o handoff pro pipeline de execução, com confiança.

- **Gatilho (confiança ALTA):** as "Decisões tomadas" cobrem o Destino **e** "Ainda não especificado" está vazio (ou só resta névoa fora-de-escopo). Nesse ponto, **proativamente sugira o próximo elo** — não espere o Founder pedir.
- **Próximo elo → `to-spec`:** sintetiza as decisões do mapa num spec publicado. Como `to-spec`/`to-tickets` são `disable-model-invocation` (não auto-disparam), o wayfinder **propõe explicitamente**: "o caminho está claro — rodo `/to-spec` pra virar spec?" e segue sob OK (ou o Founder invoca `/to-spec`).
- **Depois → `to-tickets`:** fatia o spec em tickets de build (vertical slices, 1 = 1 sessão bg). Proponha `/to-tickets` na sequência.
- **Não confunda as camadas:** os tickets do wayfinder são **decisões** (planejamento); os do `to-tickets` são **slices de build** (execução). O handoff é a fronteira entre as duas.

## Gates Adventure (obrigatórios)

- **Preflight de label (fonte de verdade):** `gh label list -R <repo>` antes de usar — revela o esquema **bare-name** vivo. Reusar o domínio bare existente (`core`/`sueli`/…). Criar o label `wayfinder` (bare) se faltar, com **descrição em PT** (padrão do repo). NÃO usar `area/wayfinder` com `/` (é a ADR-033 Proposta, não o vivo).
- **Body multi-linha:** `gh issue`/`gh pr` sempre com **`--body-file`** (inline quebra em backtick/bloco de código).
- **NO-PII** em issue/PR público: sem nome de cliente/pessoa, campanha, IDs de objeto, financeiro por-cliente. Marca/agente (Sueli, Buzz, Liara) NÃO é PII. Varrer título+corpo antes. Canon: `ssot/GUARDRAILS.md` + memória `feedback-no-pii-in-public-pr-issue`.
- **Autorização antes de criar issue:** criar issue é efeito externo. A skill **nunca** cria issue/label sozinha — proponha e espere o OK do Founder (cole a URL depois).
- **Canon durável:** se o mapa fixa uma decisão que vira canon, registre **ADR** (par PR-ssot + PR-monorepo, Links block) — `ssot/ADR/TEMPLATE.md`, número único (CI `adr-unique-number.yml`).
- **Board (ADR-033 §3):** ancorar o mapa no board da iniciativa/produto (`Adventure Labs OS` p/ transversais). Status-de-progresso vive em **coluna de board**, não em label.

## Relacionados

- **Protocolo Âncora** (CLAUDE.md) — parking 🅿️ per-sessão; o wayfinder é a versão persistida cross-sessão.
- **`/frentes`** — liveness de worktrees/branches em voo (execução), não decisões. Camada diferente.
- **`grill-me` / `grill-with-docs` / `domain-modeling`** — resolvem tickets de grilling.
- **`deep-research`** — resolve tickets de research.
- **`to-spec` / `to-tickets`** — o handoff **downstream** quando o caminho fica claro: o mapa vira spec (`to-spec`) e depois tickets de build (`to-tickets`). Ver "Quando o caminho fica claro → handoff pro build".
- **`ssot/RUNBOOKS/model-routing-policy.md`** — qual **motor/modelo por ticket** (custo-benefício): T2 Claude default · Codex (`ad-route --agent codex`) p/ teto/2ª-opinião/transform mecânico · T3 Ollama só p/ **Q&A raw sobre dado sensível** (não edita arquivo — implementação sensível fica em T2). Cada ticket pode carregar o **tier sugerido** na descrição; roteia por capacidade da tarefa, não por $ (Claude Max é flat).
- **ADR-033** (`ssot/ADR/033-*`, **Proposta**) descreve uma taxonomia `prefixo/nome`; o esquema **vivo** do repo é bare-name (nome curto + `area/`/`domain/` na descrição). O preflight `gh label list` é a fonte de verdade, não a ADR.
