# Make.com → n8n — mapping de módulos

Fonte upstream n8n: <https://docs.n8n.io/integrations/builtin/core-nodes/>

Relevante para Adventure quando/se decidirmos migrar workflows Young (cenário Make `3485123`) para n8n. **Hoje:** Make permanece em uso só para Young (ver [[skill-paridade-pingolead-young]]). Esta referência é planejamento.

## Mapping conceitual

| Make conceito | n8n equivalente |
|---|---|
| Scenario | Workflow |
| Module | Node |
| Bundle | Item (1 elemento do array de execution data) |
| Connection | Credential |
| Webhook trigger | `Webhook` node |
| HTTP module | `HTTP Request` node |
| Router | `Switch` node (multi-branch) |
| Iterator | `Split In Batches` ou `Item Lists` node |
| Aggregator | `Aggregate` ou `Merge` node |
| Data store | `Variable` (Enterprise) ou Postgres/Supabase via DB node |
| Sleep / Wait | `Wait` node |
| Tools → Set variable | `Set` node |
| Filter | `IF` node |
| Bundle position `{{1.id}}` | `{{ $('Webhook').item.json.id }}` (n8n expression) |
| `{{now}}` | `{{ $now }}` (Luxon DateTime) |

## Padrões Make Young — onde cuidar

| Padrão Make 3485123 | Tradução n8n |
|---|---|
| Roteador central → branch por código empreendimento (CAY, SBY2, IDA, …) | `Switch` node com 8+ outputs, ou tabela de roteamento via `Set` + `IF` |
| Módulo HTTP RD + módulo HTTP Pingolead em paralelo (dual-capture canon Young) | Dois `HTTP Request` em paralelo após o Switch, depois `Merge` em `Wait` |
| Variáveis com `1.body.utm_source ?? 'organic'` | Expression: `{{ $json.body.utm_source ?? 'organic' }}` |
| Erro handler global do scenario | n8n: `Error Trigger` workflow + setting `errorWorkflow` em cada workflow |

## Anti-patterns durante migração

- **Não traduzir 1:1.** Make tem módulos especializados (ex: "Google Sheets Add Row") que viram `Google Sheets` node com operation `append`. Mas alguns Make modules viram 2-3 nodes n8n encadeados. Não tente preservar a topologia visual.
- **Variáveis globais Make** → n8n community **não tem** Variables globais (feature Enterprise). Usar Supabase tabela `n8n_globals` ou similar como workaround.
- **Bundles vs items** — em Make um module pode receber 1 bundle e emitir N. Em n8n cada node recebe array de items e emite array. Mental model é diferente: aprender antes de migrar.
- **Datastore Make** = blob key-value. Em n8n use Supabase upsert via PostgreSQL node, ou cache em arquivo se quiser leve.

## Validação pós-migração

Para cada workflow migrado:
1. Test mode: rodar com payload conhecido em Make e em n8n; comparar output JSON byte-a-byte.
2. Smoke E2E: lead teste do empreendimento alvo em ambos os pipelines; confirmar destino (RD Station + Pingolead) recebeu.
3. Volume teste: rodar 100 inputs em paralelo, comparar latência média e P95.
4. Cutover gradual: 1 empreendimento Young por vez, com fallback rápido pro Make scenario original.

## Quando migrar — gatilho

Não migrar Young agora. Gatilhos válidos:
- Custo Make passar custo Adventure VPS aumentado por queue mode (improvável tão cedo).
- Make depreciar feature crítica do scenario 3485123.
- Cliente Young pedir auditoria/visibilidade do scenario (n8n self-hosted permite UI direto).
- Founder decidir consolidar todas automações em n8n.

Até lá: Make continua para Young, n8n para Adventure-novo.
