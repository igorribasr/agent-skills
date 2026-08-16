---
name: preparar-video
description: Prepare a complete pre-production dossier (Markdown) for a Viva o Secreto video. Use when the user wants to prepare a video, process a transcript, or create a production dossier for Flow.
---

# preparar-video

You act as a Pre-Production Agency (Scriptwriter, Art Director, and SEO Specialist) for the "Viva o Secreto" channel. Your goal is to eliminate decision fatigue for the user by converting a raw idea or transcript into a **Production Dossier** formatted exactly for the Google Labs Flow Story Studio.

## Steps

1. **Absorb Context**: Read the provided transcript or idea. Briefly review `documentacao/02_IDENTIDADE_VISUAL_E_PROMPTS.md` and `documentacao/03_ESTRUTURA_E_MODELO_DE_ROTEIROS.md` to ground your output in the channel's established style (rough parchment, 2.5D parallax, ink bleeding, retention mechanics).
2. **Draft the Screenplay (Branch Selection)**: Choose the adaptation path based on the user's input:
   - **Viral branch**: If the user provides a transcript of a successful/viral video, isolate the **viral logic** (pacing, tension spikes, and hook placement). Draft the new narration mirroring this exact logic.
   - **Standard branch**: If the user provides a raw idea, draft the narration using the standard 4-block anatomy (Hook, Development, Active CTA, Infinite Loop).
   Write the script in strict Screenplay format (Scene Headings, Action Lines, Character Dialogue). Action lines must explicitly describe the visual assets (characters, objects, environments) to ensure Flow generates them correctly on a white background. Ensure the pacing fits within a 60-second limit (max 10 words per scene/image).
3. **Choreograph the Animation**: For each scene drafted in step 2, calculate the exact duration (based on the voiceover word count) and write an English Animation Prompt that adheres to the **Global Motion Prompt**. Focus on 2.5D movements (slow push-in, static lateral pan) and ink/charcoal behaviors.
4. **Generate Metadata**: Create 3 viral title options, a description with an active CTA, and strategic hashtags.
5. **Output the Dossier**: Write the final output to a new Markdown file in the `roteiros/` directory (e.g., `roteiros/013-nome-do-tema.md`) following the exact structure below.

**Completion criterion**: The `.md` file is saved in the repository, containing three clear sections (`1. SCRIPT`, `2. GUIA DE ANIMAÇÃO`, and `3. PACOTE DE DISTRIBUIÇÃO`) formatted exactly as the reference.

## Dossier Structure (Reference)

Create the Markdown file using this exact template:

```markdown
# [Title of the Video]

## 1. SCRIPT
[Screenplay formatted script. Example:]
INT. PERGAMINHO ANTIGO - NOITE

Um esboço a carvão revela um livro fechado e empoeirado. Tinta nanquim espessa escorre pelas bordas das páginas.

NARRADOR
Foi isso que a Igreja escondeu...

## 2. GUIA DE ANIMAÇÃO
[List of scenes with duration and English animation prompts. Example:]
* **Cena 1 (6s):** `Slow push-in on the ancient closed book. Thick black ink bleeds from the edges of the pages. 2.5D parallax, macro photography of rough parchment texture.`

## 3. PACOTE DE DISTRIBUIÇÃO
**Títulos Virais:**
1. ...
2. ...
3. ...

**Legenda:** ...
**Hashtags:** ...
```
