---
name: grill-with-docs
description: A relentless interview to sharpen a plan or design, which also captures durable Adventure canon (ssot ADRs + GLOSSARY) as we go. The stateful sibling of grill-me. Use when the plan is worth grilling AND the decisions should outlive the session.
---

Run a relentless grilling interview AND use the `domain-modeling` skill to capture state in the Adventure canon as we go.

## The interview (same as grill-me)

Interview me relentlessly about every aspect of this plan until we reach a shared understanding. Walk down each branch of the design tree, resolving dependencies between decisions one-by-one. For each question, provide your recommended answer.

Ask the questions one at a time, waiting for feedback on each question before continuing. Asking multiple questions at once is bewildering.

If a question can be answered by exploring the codebase, explore the codebase instead.

## Capture state as we go (this is what makes it "with-docs")

Invoke the `domain-modeling` skill throughout. It writes to the **Adventure canon in `ssot`**, not generic DDD files. The moment a decision crystallises:

- **Resolve a term →** draft a row into `ssot/GLOSSARY.md` (the single global table; status `active`/`deprecated`/`forbidden`/`alias` + `canonical_term`). Don't batch — capture it the instant it's settled.
- **A real architectural decision →** offer an ADR drafted from `ssot/ADR/TEMPLATE.md` as `Status: Proposta`, but only when ALL THREE are true: (1) hard to reverse, (2) surprising without context, (3) genuine trade-off. If any is missing, skip it — it's stateless reasoning, not canon.

Both the glossary and the ADR are **canon**: the skill drafts inline during the conversation, but the change reaches `main` through a branch + PR with the **Star Command** signature — never a direct push. The Founder ratifies.

When we're done, summarize the shared understanding AND list every ADR/glossary row drafted (with its branch/PR), so nothing is left only in the conversation.

## Roteamento de modelo (custo-benefício)

Quando uma decisão que cravamos vira trabalho, registre o **tier de modelo/executor** sugerido — ver `ssot/RUNBOOKS/model-routing-policy.md`: julgamento/canon/ADR → **Claude** (Max, flat); transform mecânico em massa → **Codex** (`ad-route --agent codex`); dado sensível → **T2 Claude** (T3 Ollama local só faz Q&A raw offline, não edita arquivo). Roteia por capacidade da tarefa e privacidade, não por $ dentro do Claude.
