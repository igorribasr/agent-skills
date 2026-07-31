# -*- coding: utf-8 -*-
import torch

# Patch torch.load globally before importing rvc_python to bypass weights_only restrictions
_original_torch_load = torch.load
def _patched_torch_load(*args, **kwargs):
    if 'weights_only' not in kwargs:
        kwargs['weights_only'] = False
    try:
        return _original_torch_load(*args, **kwargs)
    except TypeError:
        kwargs.pop('weights_only', None)
        return _original_torch_load(*args, **kwargs)
torch.load = _patched_torch_load

import os
import sys
import argparse
import numpy as np
import soundfile as sf
from kokoro import KPipeline
from rvc_python.infer import RVCInference

VOICE_MODELS_DIR = r"C:\Users\Usuario\Voice Models"

def discover_models():
    """Dynamically searches the Voice Models folder and maps short names to .pth file paths."""
    models = {}
    if not os.path.exists(VOICE_MODELS_DIR):
        return models
    for entry in os.scandir(VOICE_MODELS_DIR):
        if entry.is_dir():
            for file in os.scandir(entry.path):
                if file.name.endswith(".pth"):
                    # Add multiple aliases for easy access
                    full_dir_name = entry.name.lower()
                    models[full_dir_name] = file.path
                    
                    # e.g., "isaac_bardavid" from "ISAAC BARDAVID - Weights Model"
                    simplified = entry.name.split("-")[0].strip().lower().replace(" ", "_")
                    models[simplified] = file.path
                    
                    # e.g., "isaac"
                    first_word = simplified.split("_")[0]
                    models[first_word] = file.path
    return models

def main():
    parser = argparse.ArgumentParser(description="Pipeline de Narração Inteligente (Kokoro TTS + RVC)")
    parser.add_argument("--text", type=str, help="Texto a ser narrado.")
    parser.add_argument("--file", type=str, help="Caminho para arquivo de texto contendo a narração.")
    parser.add_argument("--model", type=str, default="isaac", help="Nome do modelo de voz (ex: isaac, paulo, genio, ivan) ou caminho absoluto do arquivo .pth.")
    parser.add_argument("--voice-tts", type=str, default="pm_alex", help="Voz guia do Kokoro (padrão: pm_alex).")
    parser.add_argument("--lang-code", type=str, default="p", help="Código de idioma do Kokoro (padrão: 'p' para Português).")
    parser.add_argument("--speed", type=float, default=1.0, help="Velocidade da narração (padrão: 1.0).")
    parser.add_argument("--output-dir", type=str, default=r"D:\Documents\YT Viva o Secreto", help="Diretório base de saída.")
    parser.add_argument("--folder-num", type=str, default="01", help="Número/nome da subpasta para organizar o áudio.")
    parser.add_argument("--output-name", type=str, default="narracao.wav", help="Nome do arquivo de áudio final.")
    parser.add_argument("--temp-name", type=str, default="temp_guia.wav", help="Nome do arquivo guia temporário.")
    
    args = parser.parse_args()
    
    # 1. Resolve Text
    text_to_narrate = args.text
    if not text_to_narrate and args.file:
        if os.path.exists(args.file):
            with open(args.file, "r", encoding="utf-8") as f:
                text_to_narrate = f.read()
        else:
            print(f"❌ Erro: Arquivo de texto não encontrado em: {args.file}")
            sys.exit(1)
            
    if not text_to_narrate:
        print("❌ Erro: Você deve fornecer o texto usando --text ou --file.")
        parser.print_help()
        sys.exit(1)
        
    # 2. Resolve RVC Model path
    discovered = discover_models()
    model_path = args.model
    model_key = args.model.lower()
    
    if model_key in discovered:
        model_path = discovered[model_key]
        print(f"🔍 Modelo resolvido automaticamente para: {model_path}")
    elif not os.path.exists(model_path):
        print(f"❌ Erro: Modelo '{args.model}' não foi encontrado nos modelos conhecidos e nem como caminho direto.")
        print(f"Modelos conhecidos: {list(discovered.keys())}")
        sys.exit(1)
        
    # 3. Setup paths
    target_dir = os.path.join(args.output_dir, args.folder_num)
    final_output_path = os.path.join(target_dir, args.output_name)
    temp_guide_path = os.path.join(os.getcwd(), args.temp_name)
    
    # 4. Generate TTS Guide
    print("⏳ 1/2: Gerando áudio guia com Kokoro TTS...")
    print(f"   Voz Guia: {args.voice_tts} | Idioma: {args.lang_code} | Velocidade: {args.speed}")
    try:
        pipeline = KPipeline(lang_code=args.lang_code)
        generator = pipeline(
            text_to_narrate.strip(),
            voice=args.voice_tts,
            speed=args.speed,
            split_pattern=r'\n+'
        )
        
        audio_chunks = []
        for _, _, audio in generator:
            audio_chunks.append(audio)
            
        if not audio_chunks:
            print("❌ Erro: Nenhuma fala foi gerada.")
            sys.exit(1)
            
        audio_final = np.concatenate(audio_chunks)
        sf.write(temp_guide_path, audio_final, 24000)
        print(f"✅ Áudio guia criado em: {temp_guide_path}")
    except Exception as e:
        print(f"❌ Erro na geração do TTS: {e}")
        sys.exit(1)
        
    # 5. Apply RVC
    print("🧠 2/2: Aplicando conversão de voz (RVC)...")
    os.makedirs(target_dir, exist_ok=True)
    
    try:
        device = "cuda:0" if os.system("nvidia-smi") == 0 else "cpu"
        print(f"🖥️ Dispositivo RVC: {device}")
        
        rvc = RVCInference(device=device)
        rvc.load_model(model_path)
        rvc.infer_file(
            input_path=temp_guide_path,
            output_path=final_output_path
        )
        
        # Cleanup
        if os.path.exists(temp_guide_path):
            os.remove(temp_guide_path)
            
        print(f"\n✨ SUCESSO! Áudio final gerado em: {os.path.abspath(final_output_path)}")
    except Exception as e:
        print(f"❌ Erro na comversão RVC: {e}")
        # Clean up temp file in case of error
        if os.path.exists(temp_guide_path):
            os.remove(temp_guide_path)
        sys.exit(1)

if __name__ == "__main__":
    main()
