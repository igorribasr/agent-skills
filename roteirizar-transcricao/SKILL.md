---
name: roteirizar-transcricao
description: Transcript conversion. Use when the user pastes a transcript, asks to adapt a viral video, or wants to rewrite a video narration.
---

# Roteirizar Transcrição

Converts a provided video transcript into a fully compliant *Viva o Secreto* script.

## 1. Branch selection

Read the user's request to select the adaptation branch:
- **Viral branch**: The user calls the transcript a "viral video", "viral reference", or "validated reference".
- **Standard branch**: The user provides an ordinary transcript.

**Completion criterion**: You have committed to either the Viral branch or the Standard branch.

## 2. Draft the narration

Write the new narration following the chosen branch.

- **Viral branch**: Isolate the **viral logic** — the reference's pacing, tension spikes, and hook placement. Write the new narration mirroring this **viral logic**. You must adapt the phrasing to obey the channel's physical constraints: maximum 60 seconds of total spoken time, and maximum 10 words per image.
- **Standard branch**: Discard the original structure. Write a new narration using the **standard 4-block** anatomy (Hook, Development, Active CTA, Infinite Loop).

**Completion criterion**: The drafted narration is complete, totals under 60 seconds, and allocates 10 words or fewer per image sequence.

## 3. Format the deliverable

Assemble the drafted narration into the required project deliverables from `AGENTS.md`. 

Generate the following components in order:
1. **Storyboard Flow**: Cinematic headers, action descriptions, and Narrator blocks.
2. **Decoupage Table**: Exactly 4 columns (Tempo, Imagem da Cena, 3 Prompts de Animação, Narração Limpa).
3. **TTS Table**: Exactly 2 columns and 3 rows (Scene, Sample Context, Text).
4. **SEO Blocks**: Titles, Shorts Description, TikTok/Reels Description, and Tags.

**Completion criterion**: The final response contains all four structural components.
