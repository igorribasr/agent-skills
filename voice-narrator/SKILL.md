---
name: voice-narrator
description: >-
  Use this skill to generate high-quality automated audio narrations using Kokoro TTS (Text-to-Speech)
  and RVC (Retrieval-based Voice Conversion) to clone voice timbres.
---

# Voice Narrator (TTS + RVC) Skill

This skill teaches the agent how to run the automated audio narration pipeline.
The process generates a clean guide voice using **Kokoro TTS** and applies a voice clone timbre using **RVC (Retrieval-based Voice Conversion)**.

## Prerequisites & Setup

Ensure the python virtual environment or global environment has all requirements installed:
```powershell
pip install kokoro soundfile numpy scipy rvc-python torch
```

## Available Voice Models
The system automatically discovers voice models located in `C:\Users\Usuario\Voice Models`.
The currently known models are:
- **Isaac Bardavid**: `isaac`
- **Paulo Flores (Mufasa)**: `paulo`
- **Gênio da Lâmpada (Márcio Simões)**: `genio`
- **Ivan Lima (Fatos Desconhecidos)**: `ivan`

## How to Execute the Pipeline

Use the helper script [generate_narration.py](./scripts/generate_narration.py) to run the pipeline.

### Simple Generation (with custom text)
```powershell
python .agents/skills/voice-narrator/scripts/generate_narration.py --text "Seu texto de narração aqui..." --model isaac --folder-num 01
```

### Generation from a Text File
```powershell
python .agents/skills/voice-narrator/scripts/generate_narration.py --file "c:\caminho\para\texto.txt" --model paulo --folder-num 02
```

### Command Arguments Reference
- `--text`: The raw text to narrate.
- `--file`: Path to a text file containing the narration (use instead of `--text`).
- `--model`: Short name of the voice model (`isaac`, `paulo`, `genio`, `ivan`) or direct path to a `.pth` model file. Default is `isaac`.
- `--voice-tts`: The Kokoro guide voice. Default is `pm_alex` (Portuguese male).
- `--lang-code`: The Kokoro language code. Default is `p` (Brazilian Portuguese).
- `--speed`: Speed multiplier. Default is `1.0`.
- `--output-dir`: Base directory for output (Default: `D:\Documents\YT Viva o Secreto`).
- `--folder-num`: Folder number to organize outputs (Default: `01`).
- `--output-name`: Output audio filename (Default: `narracao.wav`).
