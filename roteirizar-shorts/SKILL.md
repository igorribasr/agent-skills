---
name: roteirizar-shorts
description: Viral short-form scriptwriting for YouTube Shorts, Reels, and TikTok for Viva o Secreto. Use when creating a new script from scratch, rewriting an existing script, or engineering viral short-form content.
---

# Roteirizar Shorts Virais — Viva o Secreto

Creates or rewrites high-retention, viral short-form scripts (YouTube Shorts, TikTok, Instagram Reels) tailored to the **Viva o Secreto** brand, algorithmic retention rules, and the "Living Manuscript" aesthetic.

## External Reference Pointers

Consult detailed project guidelines as needed during execution:
- [01 Estratégia e Métricas](file:///media/igorribas/Igor_1/Documents/GitHub/viva-secreto/documentacao/01_ESTRATEGIA_E_METRICAS.md) — Algorithmic KPIs (>65% VVSA, >70% retention).
- [02 Identidade Visual e Prompts](file:///media/igorribas/Igor_1/Documents/GitHub/viva-secreto/documentacao/02_IDENTIDADE_VISUAL_E_PROMPTS.md) — Living Manuscript aesthetic & prompts.
- [03 Guia Definitivo de Roteiros](file:///media/igorribas/Igor_1/Documents/GitHub/viva-secreto/documentacao/03_ESTRUTURA_E_MODELO_DE_ROTEIROS.md) — 4-Block anatomy, Gemini TTS, Decupagem.
- [04 Diagnósticos e Lições Aprendidas](file:///media/igorribas/Igor_1/Documents/GitHub/viva-secreto/documentacao/04_DIAGNOSTICOS_E_LICOES_APRENDIDAS.md) — Post-mortem analysis & hook fixes.
- [05 Filosofia Criativa](file:///media/igorribas/Igor_1/Documents/GitHub/viva-secreto/documentacao/05_FILOSOFIA_CRIATIVA.md) — Creative mindset & affirmative voice.
- [Regras Gerais de Conteúdo](file:///media/igorribas/Igor_1/Documents/GitHub/viva-secreto/.agents/AGENTS.md) — System rules & constraints.

---

## Leading Concepts

- **Retention-engineered**: Every word and visual change is optimized for >65% Viewed vs. Swiped Away and >70% relative retention.
- **Living-manuscript**: Visual style simulating ancient parchment, charcoal sketches, ink bleed (nanquim), and glowing gold leaf details with 2.5D motion.
- **Word-cap**: Strict limit of maximum 10 words (<11 words) per narration segment per image, enforcing a visual scene change every 3 to 4 seconds.
- **Seamless-loop**: Final sentence connects syntactically and logically into the opening sentence, driving watch time above 100%.
- **Affirmative-stance**: Solemn, authoritative voice ("A Bíblia revela", "O texto mostra") that takes a clear position rather than timid neutral phrasing.

---

## 1. Viral Strategy & Branch Selection

Select the operational branch based on the user's input:
- **Branch A (New Script from Concept)**: User provides a topic, theme, biblical mystery, or passage.
- **Branch B (Rewrite / Performance Refactor)**: User provides an existing script or low-performing draft to optimize.

### Execution Steps:
1. **Identify Curiosity Gap & Pillar**: Map the topic to one of the channel's core pillars:
   - *Mistérios & Profecias* (Angels, Demons, Eden, Apocalypse)
   - *Ciência & Arqueologia Bíblica* (DNA code, ancient discoveries, lost cities)
   - *Orações & Reflexões de Fé* (Spiritual protection, warfare)
2. **Formulate Hook Strategy (0s–3s)**: Select an approved viral hook category:
   - *Mentira Comum*: "Você foi enganado sobre..."
   - *Segredo Biológico*: "Existe um código gravado nos seus ossos..."
   - *Revelação Geográfica/Espiritual*: "O inferno não fica onde você pensa..."
   - *Ação Imediata*: "Se você sente um arrepio sem explicação..."
3. **Design Frame A (Opening Visual Anchor)**: Select the single most visually striking image concept of the script for the first 3 seconds (e.g., Macro of ink bleeding from a charcoal eye on ancient parchment).

**Completion criterion**: Branch selected, viral curiosity gap defined, hook framework chosen, and Frame A visual anchor specified before drafting prose.

---

## 2. Narration Drafting & Word-Cap Enforcement

Draft the complete Portuguese narration following the 4-Block Anatomy:

1. **Gancho (00:00 - 00:03)**: Immediate tension/intrigue without greetings or filler.
2. **Desenvolvimento (00:03 - 00:35/00:45)**: Rapid, sensory-rich information delivery in punchy beats.
3. **CTA Ativa (00:35 - 00:45/00:55)**: Active call to action asking an opinion-based question or driving comments ("Qual dessas te impressionou? Comente aqui embaixo!").
4. **Loop Infinito (00:55 - 00:60)**: End sentence syntactically attaches to the start sentence.

### Guardrails:
- **Pacing**: Group narration into lines of **at most 10 words per image**. (Never exceed 10 words per row).
- **Total Duration**: Maximum 60 seconds. If topic requires more time, split into **Parte 1** and **Parte 2** (each <=60s with its own hook, CTA, and loop).
- **Tone**: Solemn, mysterious, and affirmative. Replace passive expressions ("alguns acreditam") with definitive statements ("a Bíblia revela").

**Completion criterion**: Narration complete, total time <=60s, every line strictly <=10 words, affirmative voice verified, and seamless loop syntax validated.

---

## 3. Deliverable Assembly

Assemble the output into the 3 standardized delivery components plus SEO metadata:

### A. Roteiro Cinematográfico (Script Principal - Storyboard Flow)
- Scene headers in uppercase text (e.g., `INT. ESCURIDÃO CELESTIAL - ATEMPORAL`).
- Action descriptions incorporating 2.5D camera movements and Living Manuscript aesthetics.
- Narration labeled simply as `NARRADOR`.
- Transitions in uppercase (e.g., `CORTE RÁPIDO PARA:`).

### B. Narração — Gemini 3.1 Flash TTS
Table with **2 columns and 3 lines**:
| Campo | Conteúdo |
| :--- | :--- |
| **Scene** | Environmental atmosphere for voice model context |
| **Sample Context** | Voice style, pace, and rhythm description |
| **Text** | Clean narration string containing Gemini TTS expressive tags (`[mystery]`, `[description]`, `[tension]`, `[sensory]`) and strategic punctuation. |

### C. Tabela de Decupagem (Fallback)
Table with **4 columns**:
| Tempo | Imagem da Cena (Plano Técnico) | 3 Prompts de Animação (Opções) | 🎙️ Narração Limpa (TTS) |

- **Column 1**: Time range (e.g., `00:00 - 00:03`).
- **Column 2**: Technical shot angle & Living Manuscript visual description.
- **Column 3**: 3 distinct visual animation options in English, numbered `1.`, `2.`, `3.` separated by `<br>`, splitting narrative beats.
- **Column 4**: Clean TTS narration segment (strictly <=10 words).

### D. Otimização de SEO e Metadados
Include section `## ⚙️ Otimização de SEO e Metadados` with all 4 required sub-sections:
1. **📌 Sugestões de Títulos para YouTube (Escolha 1)**: 3 titles (CTR/Impact, Direct/Mysterious, Emotional/Theological).
2. **🔴 Descrição Otimizada para YouTube Shorts**: 2-3 magnetic sentences + CTA + `#VivaOSecreto #Shorts` hashtags.
3. **🖤 Descrição Otimizada para TikTok / Instagram Reels**: 1-2 direct lines + hashtags.
4. **🏷️ Bloco de Tags para YouTube Studio**: Single code block with comma-separated tags.

**Completion criterion**: Response contains Storyboard Flow, Gemini TTS table, 4-column Decupagem table, and full SEO metadata block without omission.
