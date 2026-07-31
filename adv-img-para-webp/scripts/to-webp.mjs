#!/usr/bin/env node
// to-webp.mjs — converte imagens raster (jpg/png/gif/tiff/bmp/avif) em WebP.
//
// Motor: sharp (binários pré-compilados, cross-platform). Se não estiver
// instalado, o script auto-instala na 1ª execução dentro da própria skill.
//
// Uso:
//   node to-webp.mjs <entrada...> [opções]
//
// Entrada pode ser: arquivo, glob ("fotos/*.png"), ou diretório.
// Opções:
//   -q, --quality N     qualidade 1-100 (default 80; ignorado em --lossless)
//   --lossless          WebP sem perdas (bom pra PNG com transparência/linhas)
//   --near-lossless N   0-100, compressão near-lossless (só com --lossless)
//   --max-width N       redimensiona pra largura máx N (mantém proporção)
//   --max-height N      redimensiona pra altura máx N (mantém proporção)
//   -r, --recursive     ao receber diretório, varre subpastas também
//   -o, --out-dir DIR   grava os .webp aqui (default: ao lado do original)
//   --overwrite         sobrescreve .webp já existente (default: pula)
//   --delete            apaga o original após conversão bem-sucedida
//   --effort N          0-6, esforço de compressão (default 4; 6 = menor/mais lento)
//   -n, --dry-run       lista o que faria, sem escrever nada
//   -h, --help          esta ajuda
//
// Saída: uma linha por arquivo + tabela-resumo com economia total.

import { execSync } from "node:child_process";
import { readFile, stat, mkdir, unlink, glob as fsGlob } from "node:fs/promises";
import { existsSync } from "node:fs";
import { fileURLToPath, pathToFileURL } from "node:url";
import { dirname, join, resolve, basename, extname, relative } from "node:path";

const HERE = dirname(fileURLToPath(import.meta.url));
const SKILL_DIR = resolve(HERE, "..");

const RASTER_EXT = new Set([
  ".jpg", ".jpeg", ".jpe", ".png", ".gif", ".tif", ".tiff",
  ".bmp", ".avif", ".webp",
]);

// ── args ──────────────────────────────────────────────────────────────────
function parseArgs(argv) {
  const o = {
    inputs: [], quality: 80, lossless: false, nearLossless: null,
    maxWidth: null, maxHeight: null, recursive: false, outDir: null,
    overwrite: false, del: false, effort: 4, dryRun: false,
  };
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    const next = () => argv[++i];
    switch (a) {
      case "-q": case "--quality": o.quality = clampInt(next(), 1, 100); break;
      case "--lossless": o.lossless = true; break;
      case "--near-lossless": o.nearLossless = clampInt(next(), 0, 100); break;
      case "--max-width": o.maxWidth = clampInt(next(), 1, 1e9); break;
      case "--max-height": o.maxHeight = clampInt(next(), 1, 1e9); break;
      case "-r": case "--recursive": o.recursive = true; break;
      case "-o": case "--out-dir": o.outDir = next(); break;
      case "--overwrite": o.overwrite = true; break;
      case "--delete": o.del = true; break;
      case "--effort": o.effort = clampInt(next(), 0, 6); break;
      case "-n": case "--dry-run": o.dryRun = true; break;
      case "-h": case "--help": printHelp(); process.exit(0); break;
      default:
        if (a.startsWith("-")) fail(`opção desconhecida: ${a}`);
        o.inputs.push(a);
    }
  }
  if (!o.inputs.length) { printHelp(); process.exit(o.inputs.length ? 0 : 1); }
  return o;
}

function clampInt(v, lo, hi) {
  const n = parseInt(v, 10);
  if (Number.isNaN(n)) fail(`valor numérico inválido: ${v}`);
  return Math.min(hi, Math.max(lo, n));
}
function fail(msg) { console.error(`✖ ${msg}`); process.exit(1); }
function printHelp() {
  console.log([
    "to-webp.mjs — converte jpg/png/gif/tiff/bmp/avif em WebP",
    "",
    "  node to-webp.mjs <entrada...> [opções]",
    "",
    "  entrada: arquivo, glob ('fotos/*.png') ou diretório",
    "  -q, --quality N     qualidade 1-100 (default 80)",
    "  --lossless          WebP sem perdas",
    "  --near-lossless N   0-100 (só com --lossless)",
    "  --max-width N       largura máx (mantém proporção)",
    "  --max-height N      altura máx (mantém proporção)",
    "  -r, --recursive     varre subpastas de um diretório",
    "  -o, --out-dir DIR   saída (default: ao lado do original)",
    "  --overwrite         sobrescreve .webp existente (default: pula)",
    "  --delete            apaga original após sucesso",
    "  --effort N          0-6 (default 4)",
    "  -n, --dry-run       só lista, não escreve",
  ].join("\n"));
}

// ── sharp bootstrap ─────────────────────────────────────────────────────────
async function loadSharp() {
  try {
    return (await import("sharp")).default;
  } catch {
    process.stderr.write("… sharp não encontrado — instalando na skill (1ª vez, ~15s)\n");
    try {
      execSync("npm install sharp --no-fund --no-audit --loglevel=error", {
        cwd: SKILL_DIR, stdio: "inherit",
      });
    } catch {
      fail("falha ao instalar 'sharp'. Rode manualmente: npm install sharp (dentro da pasta da skill)");
    }
    const p = join(SKILL_DIR, "node_modules", "sharp", "lib", "index.js");
    try {
      return (await import(pathToFileURL(p).href)).default;
    } catch {
      return (await import("sharp")).default;
    }
  }
}

// ── resolução de entradas → lista de arquivos ────────────────────────────────
async function resolveInputs(inputs, recursive) {
  const files = new Set();
  for (const raw of inputs) {
    const p = resolve(raw);
    if (existsSync(p)) {
      const s = await stat(p);
      if (s.isDirectory()) {
        const pat = recursive ? "**/*" : "*";
        for await (const f of fsGlob(join(p, pat))) {
          if (isRaster(f)) files.add(resolve(f));
        }
      } else if (isRaster(p)) {
        files.add(p);
      }
    } else {
      // trata como glob relativo ao cwd
      for await (const f of fsGlob(raw)) {
        if (isRaster(f)) files.add(resolve(f));
      }
    }
  }
  return [...files].sort();
}
function isRaster(f) { return RASTER_EXT.has(extname(f).toLowerCase()); }

function outPathFor(inFile, outDir) {
  const name = basename(inFile, extname(inFile)) + ".webp";
  return outDir ? join(resolve(outDir), name) : join(dirname(inFile), name);
}

function human(bytes) {
  if (bytes < 1024) return `${bytes} B`;
  if (bytes < 1024 ** 2) return `${(bytes / 1024).toFixed(1)} KB`;
  return `${(bytes / 1024 ** 2).toFixed(2)} MB`;
}

// ── main ─────────────────────────────────────────────────────────────────────
async function main() {
  const o = parseArgs(process.argv.slice(2));
  const files = await resolveInputs(o.inputs, o.recursive);

  if (!files.length) fail("nenhuma imagem raster encontrada nas entradas dadas.");
  if (o.outDir && !o.dryRun) await mkdir(resolve(o.outDir), { recursive: true });

  const sharp = o.dryRun ? null : await loadSharp();

  const rows = [];
  let totIn = 0, totOut = 0, converted = 0, skipped = 0, errors = 0;

  for (const inFile of files) {
    const outFile = outPathFor(inFile, o.outDir);
    const rel = relative(process.cwd(), inFile) || basename(inFile);

    // não reconverter webp em si mesmo
    if (resolve(inFile) === resolve(outFile)) { skipped++; continue; }
    if (existsSync(outFile) && !o.overwrite && !o.dryRun) {
      console.log(`⏭  ${rel} → já existe (use --overwrite)`);
      skipped++; continue;
    }

    const inSize = (await stat(inFile)).size;

    if (o.dryRun) {
      console.log(`◦ ${rel} → ${relative(process.cwd(), outFile)}`);
      converted++; totIn += inSize; continue;
    }

    try {
      let img = sharp(inFile, { animated: true }); // preserva GIF animado
      if (o.maxWidth || o.maxHeight) {
        img = img.resize({
          width: o.maxWidth ?? undefined,
          height: o.maxHeight ?? undefined,
          fit: "inside", withoutEnlargement: true,
        });
      }
      const webpOpts = o.lossless
        ? { lossless: true, effort: o.effort,
            ...(o.nearLossless != null ? { nearLossless: true, quality: o.nearLossless } : {}) }
        : { quality: o.quality, effort: o.effort };
      await img.webp(webpOpts).toFile(outFile);

      const outSize = (await stat(outFile)).size;
      const pct = inSize ? ((1 - outSize / inSize) * 100) : 0;
      rows.push({ rel, inSize, outSize, pct });
      totIn += inSize; totOut += outSize; converted++;
      console.log(`✔ ${rel}  ${human(inSize)} → ${human(outSize)}  (${pct >= 0 ? "-" : "+"}${Math.abs(pct).toFixed(0)}%)`);

      if (o.del) await unlink(inFile);
    } catch (e) {
      errors++;
      console.error(`✖ ${rel} — ${e.message}`);
    }
  }

  // resumo
  console.log("\n" + "─".repeat(48));
  if (o.dryRun) {
    console.log(`dry-run: ${converted} arquivo(s) seriam convertidos, ${skipped} pulado(s).`);
  } else {
    const savedPct = totIn ? ((1 - totOut / totIn) * 100) : 0;
    console.log(`convertidos: ${converted}   pulados: ${skipped}   erros: ${errors}`);
    if (converted) {
      console.log(`tamanho: ${human(totIn)} → ${human(totOut)}   economia: ${savedPct.toFixed(1)}%`);
    }
    if (o.del && converted) console.log("originais apagados (--delete).");
  }
  process.exit(errors ? 1 : 0);
}

main().catch((e) => fail(e.stack || e.message));
