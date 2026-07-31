#!/usr/bin/env node
/**
 * sync-db.mjs — sincroniza registry.json → Supabase public.adv_skills via PostgREST.
 *
 * Usado pelo workflow .github/workflows/skills-sync.yml a cada merge em main:
 * grava o snapshot dos homes DO MONOREPO sob um host_id sentinela (default
 * `repo`) = "a verdade versionada do monorepo agora". Scans por-host (cron)
 * gravam seus próprios host_id com os extras host-local/plugin. O adventure-console
 * lê a união (Supabase Realtime) pra montar a UI.
 *
 * Substitui o snapshot atômico-o-suficiente: DELETE host_id + POST das linhas.
 * (Janela vazia de ~ms entre as duas chamadas — aceitável p/ sync pós-merge.)
 *
 * Env:  SUPABASE_URL (ex.: https://<ref>.supabase.co) · SUPABASE_SERVICE_ROLE_KEY
 * Args: <registry.json> [host_id=repo]
 *
 * Sem dependências (fetch nativo do Node ≥18). Secret ausente = SKIP (exit 0),
 * pra não spammar falha antes de o Founder configurar o secret / o CI revive (#954).
 */
import { readFileSync } from "node:fs";

const [file, host = "repo"] = process.argv.slice(2);
const URL = process.env.SUPABASE_URL;
const KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!file) {
  console.error("uso: node sync-db.mjs <registry.json> [host_id]");
  process.exit(1);
}
if (!URL || !KEY) {
  console.warn("⚠️  SUPABASE_URL/SUPABASE_SERVICE_ROLE_KEY ausentes — pulando sync (SKIP).");
  process.exit(0); // soft-skip: seguro mergear antes do secret existir
}

const { rows } = JSON.parse(readFileSync(file, "utf8"));
const recs = rows.map((r) => ({
  skill: r.name,
  host_id: host,
  home: r.home,
  versioned: r.versioned,
  owner_agent: r.owner_agent,
  status: r.status,
  hosts: r.hosts,
  purpose: r.purpose,
  goal: r.goal || null,
  repo_path: r.repo_path,
  local_path: r.local_path,
  note: r.note || null,
  scanned_at: new Date().toISOString(),
}));

const base = `${URL.replace(/\/$/, "")}/rest/v1/adv_skills`;
const H = { apikey: KEY, Authorization: `Bearer ${KEY}`, "Content-Type": "application/json" };

// 1) apaga o snapshot anterior deste host sentinela
let res = await fetch(`${base}?host_id=eq.${encodeURIComponent(host)}`, { method: "DELETE", headers: H });
if (!res.ok) { console.error(`DELETE ${res.status}: ${await res.text()}`); process.exit(1); }

// 2) insere o snapshot atual
res = await fetch(base, { method: "POST", headers: { ...H, Prefer: "return=minimal" }, body: JSON.stringify(recs) });
if (!res.ok) { console.error(`INSERT ${res.status}: ${await res.text()}`); process.exit(1); }

console.log(`OK: ${recs.length} skills → adv_skills (host_id=${host})`);
