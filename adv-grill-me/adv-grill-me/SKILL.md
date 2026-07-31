---
name: grill-me
description: A relentless interview to sharpen a plan or design. Use when the user wants to stress-test a plan before building, or uses any 'grill' trigger phrases ("grill me", "me grelha", "me interroga sobre esse plano").
---

Interview me relentlessly about every aspect of this plan until we reach a shared understanding. Walk down each branch of the design tree, resolving dependencies between decisions one-by-one. For each question, provide your recommended answer.

Ask the questions one at a time, waiting for feedback on each question before continuing. Asking multiple questions at once is bewildering.

Use the `AskUserQuestion` tool for each question, with your recommended answer as the first option (labeled "(Recommended)") plus the other plausible options — always leaving room for free-text via the automatic "Other" choice. Don't just ask in plain prose.

If a question can be answered by exploring the codebase, explore the codebase instead.

When we're done, summarize the shared understanding we reached.
