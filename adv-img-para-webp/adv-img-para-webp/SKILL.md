---
name: img-para-webp
description: Converte imagens raster (JPG/JPEG, PNG, GIF, TIFF, BMP, AVIF) em WebP para reduzir peso e acelerar sites/LPs, com controle de qualidade, lossless, redimensionamento em lote e resumo de economia. Use quando o usuário pedir "converte essa imagem pra webp", "transforma esses PNG/JPG em webp", "otimiza as imagens da LP", "deixa essas fotos mais leves", "gera webp em lote", "converte a pasta de assets pra webp", ou colar/apontar arquivos ou uma pasta pedindo WebP. Entrega os `.webp` gerados + tabela de economia (antes/depois). NÃO usar para editar/gerar imagem do zero (isso é nano-banana) nem para vetorizar logo (isso é logo-vetorizar).
---

# img-para-webp — Conversão de imagens para WebP

Converte imagens raster (**JPG, JPEG, PNG, GIF, TIFF, BMP, AVIF**) em **WebP**, formato ~25–35% mais leve que JPEG e muito menor que PNG, ideal pra landing pages, sites de cliente e criativos web da Adventure.

Motor: **Node + `sharp`** (binários pré-compilados, cross-platform). Não depende de ImageMagick, cwebp nem Python. Na primeira execução o script auto-instala o `sharp` dentro da própria skill (~15s, uma vez só).

## Quando usar
- "converte essa imagem / essas imagens pra webp"
- "otimiza as imagens da LP / da pasta de assets"
- "deixa essas fotos mais leves pro site"
- "gera webp em lote da pasta X" / "converte só a maior resolução"

**Não** usar para: gerar/editar imagem do zero (`nano-banana`), vetorizar logo raster (`logo-vetorizar`), ou vídeo.

## Como rodar

O trabalho pesado está em `scripts/to-webp.mjs`. Aceita **arquivo, glob ou diretório**.

```bash
# um arquivo
node scripts/to-webp.mjs foto.png

# vários / glob
node scripts/to-webp.mjs "assets/*.jpg" hero.png

# uma pasta inteira (opcionalmente recursiva)
node scripts/to-webp.mjs ./public/img
node scripts/to-webp.mjs ./public/img --recursive

# qualidade custom (default 80) e saída em pasta separada
node scripts/to-webp.mjs banner.jpg -q 72 -o ./dist/webp

# PNG com transparência/linhas → lossless costuma render melhor
node scripts/to-webp.mjs logo.png --lossless

# redimensionar no ato (nunca amplia) — ótimo pra heros gigantes
node scripts/to-webp.mjs hero-4000px.jpg --max-width 1920 -q 78

# só simular, sem escrever nada
node scripts/to-webp.mjs ./img --recursive --dry-run
```

> No Windows (PowerShell), rodar com `node .\scripts\to-webp.mjs ...`. Se o glob não expandir, passe entre aspas (`"assets/*.png"`) — o script faz o glob internamente.

### Opções
| Flag | Efeito |
|------|--------|
| `-q, --quality N` | Qualidade 1–100 (default **80**; ignorado em lossless) |
| `--lossless` | WebP sem perdas (recomendado pra PNG com alpha/line-art) |
| `--near-lossless N` | 0–100, near-lossless (só junto de `--lossless`) |
| `--max-width N` / `--max-height N` | Redimensiona pra caber em N px, mantém proporção, **não amplia** |
| `-r, --recursive` | Ao receber diretório, varre subpastas |
| `-o, --out-dir DIR` | Grava os `.webp` nessa pasta (default: ao lado do original) |
| `--overwrite` | Sobrescreve `.webp` já existente (default: **pula**) |
| `--delete` | Apaga o original após conversão bem-sucedida |
| `--effort N` | 0–6, esforço de compressão (default 4; 6 = menor e mais lento) |
| `-n, --dry-run` | Lista o que faria, sem escrever |

## Diretrizes de qualidade (recomendações Adventure)
- **Fotos / heros JPEG:** lossy `-q 75–82`. Abaixo de 70 começa a aparecer artefato em gradientes.
- **PNG com transparência, ícones, screenshots, line-art:** `--lossless` (mantém nitidez; ainda fica menor que o PNG).
- **Heros acima de ~2000px** que serão exibidos menores: adicione `--max-width 1920` (ou o tamanho de exibição) — quase sempre é a maior economia.
- **GIF animado:** o script preserva a animação (`animated: true`). WebP animado é bem menor que GIF.
- Por padrão o script **não apaga** o original nem sobrescreve `.webp` existente — seguro pra rodar em pasta de produção. Use `--delete` / `--overwrite` conscientemente.

## Fluxo padrão
1. Identifique a entrada (arquivo, glob ou pasta) que o usuário passou. Se ambíguo, pergunte.
2. Rode o script com as flags adequadas (default `-q 80`; `--lossless` pra PNG com alpha).
3. Para lotes grandes ou pasta de produção, rode **`--dry-run` primeiro** e mostre ao usuário antes de escrever.
4. Ao terminar, **reporte a tabela de economia** que o script imprime (antes → depois, % total) e liste onde os `.webp` foram gravados.
5. Se o objetivo for trocar as imagens numa LP/site, lembre o usuário de atualizar as referências (`<img src>`, `srcset`, CSS `url()`) ou usar `<picture>` com fallback — a conversão sozinha não mexe no HTML/CSS.

## Notas
- `.webp` já existentes são ignorados como saída redundante (não reconverte sobre si mesmo).
- Formatos não suportados pelo `sharp` na máquina (ex.: alguns HEIC sem libheif) falham só naquele arquivo e o lote continua; o resumo mostra a contagem de erros.
- `node_modules/` da skill (criado no bootstrap do `sharp`) **não** deve ser commitado — está fora do escopo versionado da skill.
