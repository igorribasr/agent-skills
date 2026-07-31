---
name: teach
description: Loop de ensino multi-sessão (adaptado do /teach de Matt Pocock) — monta um workspace durável de aprendizado (MISSION/RESOURCES/lessons/learning-records) e ensina um tópico ao longo de várias sessões, fundamentado em fontes de alta confiança e na zona de desenvolvimento proximal. Use quando o Founder disser "/teach", "me ensina X", "quero aprender Y ao longo do tempo", "vira meu professor de Z". Tópico pode ser técnico ou não (Rust, yoga, copywriting, finanças). NÃO é canon Adventure — é aprendizado pessoal; o workspace vive em ~/Code/learning/<topico>/, fora do ssot.
disable-model-invocation: true
argument-hint: "O que você quer aprender?"
metadata:
  type: skill
  hosts: [macbook]
  owner_agent: star-command
  status: active
---

The user has asked you to teach them something. This is a stateful request - they intend to learn the topic over multiple sessions.

## Teaching Workspace (Adventure)

This learning is **personal knowledge, not Adventure operational canon** — it never goes to the `ssot` repo, `agent_context`, or Supabase. It lives in its own durable home so it survives across sessions and is backed up.

**Workspace home:** `~/Code/learning/<topico-dash-case>/` — one directory per mission, a real git repo, **outside iCloud** (iCloud corrupts `.git`). On the first session of a new topic: create the dir, `git init`, and confirm the slug with the user. Do **not** treat a random current directory as the workspace.

**Backup:** after a session that produced lessons or records, mirror the workspace to Drive via `rclone` (reuse the Adventure backup convention) so the learning is recoverable off-host. Verify with `rclone check` (md5).

The state of the user's learning is captured in the workspace in several files:

- `MISSION.md`: A document capturing the _reason_ the user is interested in the topic. This should be used to ground all teaching. Use the format in [MISSION-FORMAT.md](./MISSION-FORMAT.md).
- `./reference/*.html`: A directory of reference materials. These are the compressed learnings from the lessons - cheat sheets, reference algorithms, syntax, yoga poses, glossaries. They should be beautiful documents which print out well, and are designed for quick reference.
- `RESOURCES.md`: A list of resources which can be explored to ground your teaching in contextual knowledge, or to acquire knowledge and wisdom. Use the format in [RESOURCES-FORMAT.md](./RESOURCES-FORMAT.md).
- `./learning-records/*.md`: A directory of learning records, which capture what the user has learned. These are loosely equivalent to architectural decision records in software development - they capture non-obvious lessons and key insights that may drive future sessions. They are used to calculate the zone of proximal development. Titled `0001-<dash-case-name>.md`, incrementing. Use the format in [LEARNING-RECORD-FORMAT.md](./LEARNING-RECORD-FORMAT.md).
- `./lessons/*.html`: A directory of lessons. A **lesson** is a single, self-contained HTML output that teaches one tightly-scoped thing tied to the mission. This is the primary unit of teaching in this workspace.
- `./assets/*`: Reusable **components** shared across lessons. See [Assets](#assets).
- `NOTES.md`: A scratchpad for user preferences and working notes.

## Architecture — where each layer lives (Adventure)

The workspace is **local-first by design, not just for simplicity.** The primary consumer of the learning *state* is the teaching agent itself, reading prose to compute the ZPD — and for that reader, **files beat a database** (grep/Read, zero latency, no auth, native to an LLM). Moving mission/records/resources into a DB would add friction to the loop that matters most. So split by what each layer actually needs:

- **Knowledge / authoring** (mission, learning-records, resources, lessons, reference) → **local files (git + Drive).** Never a DB. This is the default and the right call for ~90% of the system.
- **Consumption** (reading a lesson) → **local browser by default.** Only graduate to a **hosted static mirror** when the mission genuinely implies reading off the command-deck Mac (phone, couch, travel). The git repo stays the source of truth; the host is a read-only mirror built on push.
- **Telemetry** (quiz scores / missed questions) → **`localStorage` + a copyable result line the user pastes back** (the paste is itself a retrieval act and keeps the agent in the loop). Only escalate to a **table** (Supabase) if automatic, cross-device score capture becomes a real pain — it is the highest-ops, lowest-marginal-value piece. Default: do not.
- **Spacing / SRS** (the storage-strength goal) → solve with **dated learning-records + a scheduled routine** that pokes the agent to author a review lesson when items are due. A scheduler over dated files, **not** a DB.

**Offer, do not force.** Hosting is **default-off.** When the mission implies multi-device reading, *offer* a protected static deploy — never create one unprompted. No workspace should inherit ops it did not ask for.

**PII guardrail (hard rule).** Lessons anchor in real cases and often name real clients/people (e.g. campaign clients). A *public* deploy would expose client names + internal strategy on an indexable URL, and cache/indexing is irreversible. Therefore: **if ever hosted, it MUST be access-protected — never public.** Acceptable: Vercel Deployment Protection (Vercel Authentication), or a VPS subdomain behind basic auth (Traefik). When in doubt, stay local. (See [[feedback-no-pii-in-public-pr-issue]].)

## Grounding — never trust parametric knowledge (Adventure)

Before `RESOURCES.md` is well-populated, your focus is to find high-quality resources. Ground every claim in real sources, not your own recall. Use the Adventure research tooling:

- For a broad new topic, run the **`deep-research`** skill to fan out and surface trusted sources, then distil them into `RESOURCES.md`.
- For a single fact or a primary source, use `WebSearch` / `WebFetch` directly.
- Lessons should be littered with citations linking back to `RESOURCES.md` entries — this is what makes a lesson trustworthy.

## Philosophy

To learn at a deep level, the user needs three things:

- **Knowledge**, captured from high-quality, high-trust resources
- **Skills**, acquired through highly-relevant interactive lessons devised by you, based on the knowledge
- **Wisdom**, which comes from interacting with other learners and practitioners

Some topics may require more skills than knowledge. Theoretical physics is more knowledge-based; yoga more skills-based.

### Fluency vs Storage Strength

Split between two types of learning:

- **Fluency strength**: in-the-moment retrieval of knowledge
- **Storage strength**: long-term retention of knowledge

Fluency can give an illusory sense of mastery, but storage strength is the real goal. Design lessons that build long-term retention through desirable difficulty:

- Retrieval practice (recall from memory)
- Spacing (distributing practice over time)
- Interleaving (mixing different but related topics in practice — skills practice only)

## Lessons

A lesson is the main thing you produce. Each lesson is one self-contained HTML file in `./lessons/`, titled `0001-<dash-case-name>.html`, incrementing.

A lesson should be **beautiful** — clean, readable typography (think Tufte) — since the user returns to review them. It should be short and quickly completable: working memory is small. But each lesson should give one tangible win, tied to the mission, in the user's zone of proximal development.

If possible, open the lesson file for the user via a CLI command. Each lesson should link (HTML anchors) to other lessons and reference docs, recommend one primary high-trust source, and remind the user they can ask you (their teacher) followup questions.

## Assets

Lessons are built from reusable **components** in `./assets/`: stylesheets, quiz widgets, simulators, diagram helpers. Reuse is the default — read `./assets/` before authoring; when something reusable is needed, write it as a component and link it, never inline-duplicate. A shared stylesheet is the first component every workspace earns, so the course looks consistent.

## The Mission

Every lesson ties into the mission. If the mission is unclear or `MISSION.md` is empty, your first job is to interview the user on *why* they want to learn this — ungrounded knowledge feels abstract and gives you no way to judge what comes next. Missions change as the user grows; when the goal moves, confirm with the user, update `MISSION.md`, and add a learning record.

## Zone Of Proximal Development

Each lesson, the user should feel challenged 'just enough'. If they name an exact thing, teach that. Otherwise, read their `learning-records`, weigh the mission, and teach the most relevant thing that fits in their ZPD.

## Knowledge & Skills

For **knowledge**, difficulty is the enemy — it eats working memory. Teach only the knowledge a skill requires, gathered from `RESOURCES.md`, then have the user practice.

For **skills**, difficulty is the tool — effortful retrieval builds storage strength. Teach via interactive lessons (quizzes, light in-browser tasks, or guided real-world steps like yoga poses), each built on the tightest possible **feedback loop** — immediate and ideally automatic. For quizzes, make every answer the same number of words (and characters if possible) so formatting leaks no clues.

## Acquiring Wisdom

Wisdom comes from real-world interaction outside the learning environment. When a question needs wisdom, attempt an answer but ultimately delegate to a **community** — a forum, subreddit, class, or local group where the user tests skills for real. Find high-reputation communities; if the user opts out, respect it and note it in `RESOURCES.md`.

## Reference Documents

While creating lessons, also create reference documents — the compressed essence of lessons, designed for quick reference (syntax/snippets, algorithms/flowcharts, poses/sequences, glossaries). Lessons are rarely revisited; reference docs are. A **glossary**, in particular, is essential: once created, adhere to it in every lesson.

## `NOTES.md`

When the user expresses how they want to be taught, record it in `NOTES.md` so you can honour it when designing future lessons.

---

> **Origem & licença.** Adaptado do skill `/teach` de **Matt Pocock** ([github.com/mattpocock/skills](https://github.com/mattpocock/skills), MIT). O miolo pedagógico é dele; as adaptações Adventure são o **home durável do workspace** (`~/Code/learning/` + backup Drive, fora do `ssot`/canon) e o **grounding via `deep-research`/WebSearch**. Mesmo padrão de adaptação de `grill-me`, `grill-with-docs`, `domain-modeling` (ADR-026).
