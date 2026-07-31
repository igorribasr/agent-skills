#!/usr/bin/env node
/**
 * skills-inventory — gera um índice canônico de skills Adventure Labs.
 *
 * Varre TODOS os homes onde uma skill Adventure pode morar e deriva
 * `home`/`versioned` de ONDE o SKILL.md está fisicamente (o filesystem é a
 * verdade — zero drift). O frontmatter só enriquece: owner_agent/status/hosts.
 *
 * Homes cobertos (e precedência de dedupe — menor vence):
 *   0 repo          skills/                         monorepo, versionado — IDEAL
 *   1 repo-openclaw openclaw/skills/                monorepo, runtime OpenClaw
 *   2 repo-cursor   .cursor/skills/                 monorepo, runtime Cursor
 *   3 plugin(repo)  plugins/<x>/skills/             monorepo, plugin versionado
 *   4 sep-repo      ~/.claude/skills/<x> c/ .git    repo git à parte, instalado local
 *   5 plugin(host)  ~/.claude/plugins/<x>/skills/   plugin instalado (só host)
 *   6 host-local    ~/.claude/skills/<x> sem .git   só nesta máquina — NÃO versionada
 *
 * Homes 4-6 são pulados com --repo-only (o CI não enxerga ~/.claude). Symlinks em
 * ~/.claude/skills que apontam pro monorepo são pulados (já contam como repo).
 *
 * Uso:
 *   node build.mjs --repo <repoSkillsDir> [--root <monorepoRoot>] \
 *     [--local <~/.claude/skills>] [--out <REGISTRY.md>] [--json <out.json>] \
 *     [--host <id>] [--stamp <txt>] [--repo-only]
 * Defaults: repo=<cwd>/skills, root=dirname(repo), local=$HOME/.claude/skills,
 *           out=<repo>/REGISTRY.md. --repo-only = só homes do monorepo (CI).
 */
import { readFileSync, readdirSync, existsSync, statSync, lstatSync, writeFileSync } from "node:fs";
import { join, dirname } from "node:path";

function arg(flag, def) {
  const i = process.argv.indexOf(flag);
  return i > -1 && process.argv[i + 1] ? process.argv[i + 1] : def;
}
const has = (flag) => process.argv.includes(flag);

const HOME = process.env.HOME || "";
const repoSkills = arg("--repo", join(process.cwd(), "skills"));
const root = arg("--root", dirname(repoSkills));
const localSkills = arg("--local", join(HOME, ".claude", "skills"));
const hostId = arg("--host", "macbook");
const outMd = arg("--out", join(repoSkills, "REGISTRY.md"));
const outJson = arg("--json", null);
const repoOnly = has("--repo-only");
const stamp = arg("--stamp", new Date().toISOString().replace("T", " ").slice(0, 16) + " UTC");

/** Rótulo humano curto por home (pra REGISTRY.md). */
const HOME_LABEL = {
  repo: "repo (ideal)",
  "repo-openclaw": "repo · openclaw",
  "repo-cursor": "repo · cursor",
  "sep-repo": "repo próprio",
  plugin: "plugin",
  "host-local": "host-local",
};

/** Frontmatter YAML sem dep: top-level + bloco metadata: + block-scalar (>- / |). */
function parseFrontmatter(text) {
  if (!text.startsWith("---")) return { metadata: {} };
  const end = text.indexOf("\n---", 3);
  if (end === -1) return { metadata: {} };
  const lines = text.slice(3, end).split("\n");
  const out = { metadata: {} };
  let inMeta = false;
  for (let i = 0; i < lines.length; i++) {
    const raw = lines[i];
    if (/^metadata:\s*$/.test(raw)) { inMeta = true; continue; }
    const meta = raw.match(/^\s{2,}([a-z_]+):\s*(.*)$/i);
    if (inMeta && meta) { out.metadata[meta[1]] = strip(meta[2]); continue; }
    const top = raw.match(/^([a-z_]+):\s*(.*)$/i);
    if (top) {
      inMeta = false;
      let val = top[2];
      if (/^[|>][-+]?\s*$/.test(val.trim()) || val.trim() === "") {
        const buf = [];
        for (let j = i + 1; j < lines.length; j++) {
          if (/^\s+\S/.test(lines[j])) buf.push(lines[j].trim());
          else if (lines[j].trim() === "") continue;
          else break;
        }
        if (buf.length) val = buf.join(" ");
      }
      out[top[1]] = strip(val);
    }
  }
  return out;
}
const strip = (v) => (v || "").trim().replace(/^["']|["']$/g, "");
const firstSentence = (d) => {
  if (!d) return "—";
  const s = d.replace(/\s+/g, " ").trim();
  const cut = s.search(/(?<=[.!?])\s|\s—\s|\. /);
  return (cut > 0 ? s.slice(0, cut) : s).slice(0, 140).trim();
};

/** Lê 1 SKILL.md → registro cru, ou null. */
function readSkill(dir, name, { home, versioned, prec, relBase, local, note }) {
  const p = join(dir, name, "SKILL.md");
  if (!existsSync(p)) return null;
  const fm = parseFrontmatter(readFileSync(p, "utf8"));
  return {
    name: fm.name || name, home, versioned, prec, note: note || "", fm,
    relPath: relBase ? `${relBase}/${name}/SKILL.md` : null,
    local: local || null,
  };
}

const isDir = (p) => { try { return statSync(p).isDirectory(); } catch { return false; } };

/** Varre um dir de skills do monorepo (todos versionados). */
function scanRepoHome(dir, home, prec, relBase, note) {
  const rows = [];
  if (!existsSync(dir)) return rows;
  for (const name of readdirSync(dir)) {
    if (!isDir(join(dir, name))) continue;
    const r = readSkill(dir, name, { home, versioned: true, prec, relBase, note });
    if (r) rows.push(r);
  }
  return rows;
}

/** Varre plugins/<x>/skills do monorepo (versionados). */
function scanRepoPlugins(root) {
  const rows = [];
  const base = join(root, "plugins");
  if (!existsSync(base)) return rows;
  for (const plugin of readdirSync(base)) {
    const sk = join(base, plugin, "skills");
    if (!existsSync(sk)) continue;
    for (const name of readdirSync(sk)) {
      if (!existsSync(join(sk, name, "SKILL.md"))) continue;
      const r = readSkill(sk, name, {
        home: "plugin", versioned: true, prec: 3,
        relBase: `plugins/${plugin}/skills`, note: `plugin ${plugin} (versionado no monorepo)`,
      });
      if (r) rows.push(r);
    }
  }
  return rows;
}

/** Varre ~/.claude/skills: pula symlinks (= repo); dir c/ .git próprio = sep-repo. */
function scanHostLocal(dir) {
  const rows = [];
  if (!existsSync(dir)) return rows;
  for (const name of readdirSync(dir)) {
    const full = join(dir, name);
    let st;
    try { st = lstatSync(full); } catch { continue; }
    if (st.isSymbolicLink() || !st.isDirectory()) continue;
    const ownGit = existsSync(join(full, ".git"));
    const r = readSkill(dir, name, ownGit
      ? { home: "sep-repo", versioned: true, prec: 4, local: `~/.claude/skills/${name}/SKILL.md`, note: "repo git próprio (instalado local)" }
      : { home: "host-local", versioned: false, prec: 6, local: `~/.claude/skills/${name}/SKILL.md`, note: "só nesta máquina — NÃO versionada" });
    if (r) rows.push(r);
  }
  return rows;
}

/** Cache mais recente de um plugin do marketplace local. */
function latestPluginSkills(pluginName) {
  const base = join(HOME, ".claude", "plugins", "cache", "adventure-local", pluginName);
  if (!existsSync(base)) return null;
  const vers = readdirSync(base).filter((v) => existsSync(join(base, v, "skills"))).sort();
  return vers.length ? join(base, vers[vers.length - 1], "skills") : null;
}

/** Varre um dir de skills de plugin INSTALADO (host). */
function scanHostPlugin(dir, label, versioned, note) {
  const rows = [];
  if (!dir || !existsSync(dir)) return rows;
  for (const name of readdirSync(dir)) {
    if (!existsSync(join(dir, name, "SKILL.md"))) continue;
    const r = readSkill(dir, name, { home: "plugin", versioned, prec: 5, local: `plugin:${label}`, note: `${label}: ${note}` });
    if (r) rows.push(r);
  }
  return rows;
}

// ── coleta ──────────────────────────────────────────────────────────────────
const raw = [
  ...scanRepoHome(repoSkills, "repo", 0, "skills", "versionada em skills/ (cross-host)"),
  ...scanRepoHome(join(root, "openclaw", "skills"), "repo-openclaw", 1, "openclaw/skills", "runtime OpenClaw/Buzz — lida da pasta do OpenClaw"),
  ...scanRepoHome(join(root, ".cursor", "skills"), "repo-cursor", 2, ".cursor/skills", "runtime Cursor — lida da pasta do Cursor"),
  ...scanRepoPlugins(root),
];
if (!repoOnly) {
  raw.push(...scanHostLocal(localSkills));
  raw.push(...scanHostPlugin(join(HOME, ".claude", "plugins", "beelink-overnight", "skills"),
    "beelink-overnight", false, "plugin host-local (ver plugins/ no monorepo se já promovido)"));
  raw.push(...scanHostPlugin(latestPluginSkills("sueli-financeiro"),
    "sueli-financeiro", true, "repo próprio via marketplace adventure-local"));
}

// ── dedupe por nome (precedência explícita) ──────────────────────────────────
const byName = new Map();
for (const r of raw) {
  const cur = byName.get(r.name);
  if (!cur || r.prec < cur.prec) {
    byName.set(r.name, { ...r, relPath: r.relPath || cur?.relPath, local: r.local || cur?.local });
  } else if (r.relPath && !cur.relPath) cur.relPath = r.relPath;
  else if (r.local && !cur.local) cur.local = r.local;
}

const rows = [...byName.values()].map((e) => {
  const md = e.fm.metadata || {};
  const isRepoHome = e.prec <= 2; // repo/openclaw/cursor
  return {
    name: e.name,
    home: e.home,
    versioned: !!e.versioned,
    hosts: md.hosts || (e.versioned && isRepoHome ? "all" : hostId),
    owner_agent: md.owner_agent || "—",
    status: md.status || "active",
    goal: e.fm.goal || "",
    purpose: firstSentence(e.fm.description),
    repo_path: e.relPath || "—",
    local_path: e.local || "—",
    note: e.note || "",
  };
}).sort((a, b) => {
  const pa = byName.get(a.name).prec, pb = byName.get(b.name).prec;
  return pa !== pb ? pa - pb : a.name.localeCompare(b.name);
});

// ── saída ────────────────────────────────────────────────────────────────────
const n = rows.length;
const c = (f) => rows.filter(f).length;
const summary =
  `**${n} skills** · ideal (\`skills/\`): ${c((x) => x.home === "repo")} · ` +
  `repo home-alt (openclaw/cursor): ${c((x) => x.home === "repo-openclaw" || x.home === "repo-cursor")} · ` +
  `plugin versionado: ${c((x) => x.home === "plugin" && x.versioned)} · repo próprio: ${c((x) => x.home === "sep-repo")} · ` +
  `plugin host-local: ${c((x) => x.home === "plugin" && !x.versioned)} · host-local: ${c((x) => x.home === "host-local")}`;

const head = `<!-- GERADO por skills-inventory — NÃO editar à mão. Rode \`/skills-inventory\` (ou node skills/skills-inventory/scripts/build.mjs) pra atualizar. -->
# Skills Registry — Adventure Labs

> Índice canônico de skills: **onde cada uma vive** e se está versionada, pra humanos e agentes consultarem um lugar só.
> Gerado: ${stamp} · host de varredura: \`${hostId}\`${repoOnly ? " · modo `--repo-only` (só monorepo)" : ""}. \`home\`/\`versioned\` derivados do filesystem; \`owner_agent\`/\`status\`/\`hosts\` do frontmatter.

${summary}

| Skill | Home | Versionada | Host(s) | Owner | Status | Goal | Propósito | Nota (onde vive / por quê) |
|---|---|:---:|---|---|---|:---:|---|---|
`;
const body = rows
  .map((x) => `| \`${x.name}\` | ${HOME_LABEL[x.home] || x.home} | ${x.versioned ? "✅" : "—"} | ${x.hosts} | ${x.owner_agent} | ${x.status} | ${x.goal ? "✅" : "—"} | ${x.purpose} | ${x.note || "—"} |`)
  .join("\n");
const legend = `

## Legenda
- **Home** — onde o SKILL.md mora fisicamente (fonte de verdade da localização):
  - \`repo (ideal)\` — versionada em \`skills/\` do monorepo (cross-host, lugar-padrão).
  - \`repo · openclaw\` / \`repo · cursor\` — versionada no monorepo, mas em home de runtime próprio (o OpenClaw/Cursor lê da pasta dele).
  - \`plugin\` (versionada ✅) — vem de um plugin. \`plugins/<x>/\` no monorepo = versionado; cache do marketplace = repo próprio.
  - \`repo próprio\` — versionada num repo git à parte (ex.: \`adventurelabsbrasil/flow-google-especialista\`), instalada localmente.
  - \`plugin\` (—) / \`host-local\` — só existe em \`~/.claude/\` desta máquina; **não versionada** (risco de perda).
- **Nota** — a procedência: onde a skill vive e por quê (o "flag" pra saber a origem sem adivinhar).
- **Versionada** — está sob git em algum repo (sobrevive à troca de host / é auditável).
- **Host(s)** — onde roda/está instalada (\`metadata.hosts\`; \`all\` = qualquer host via monorepo).
- **Goal** — marca ✅ quando a skill declara o campo goal no frontmatter (condição verificável do /goal; canon em ssot/GUARDRAILS.md, seção /goal). O texto completo da condição vive no registry.json + tabela adv_skills (machine-readable); aqui é só sinal de cobertura.
- Fonte de verdade da localização = **o filesystem**. Este arquivo é derivado; não edite à mão.
`;
writeFileSync(outMd, head + body + legend + "\n");
if (outJson) writeFileSync(outJson, JSON.stringify({ stamp, host: hostId, repo_only: repoOnly, rows }, null, 2));
console.log(`OK: ${n} skills → ${outMd}`);
console.log(summary.replace(/\*\*/g, ""));
