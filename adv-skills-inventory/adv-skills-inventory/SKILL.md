---
name: skills-inventory
description: Gera e mantém o índice canônico de skills da Adventure Labs — onde cada skill vive (repo versionado em skills/ vs host-local em ~/.claude/skills), quais hosts a têm, owner e status — pra humanos e agentes consultarem um arquivo só (skills/REGISTRY.md) em vez da lista efêmera de runtime. Use quando o Founder/agente disser "onde vive a skill X", "inventário de skills", "lista as skills e onde estão", "atualiza o REGISTRY de skills", "quais skills são versionadas / só host-local", "criei/movi uma skill, atualiza o índice", ou ao adicionar/remover/mover qualquer skill. Varre os dois homes, deriva home/versioned do FILESYSTEM (zero drift) e enriquece com frontmatter (owner_agent/status/hosts). Saída = skills/REGISTRY.md (humanos) + registry.json + upsert opcional em Supabase adv_skills (agentes, cross-host). NÃO cria skills (isso é trabalho manual / revisar-skill-pos-execucao), NÃO edita o conteúdo das skills — só inventaria. Estreada 2026-06-15.
metadata:
  type: skill
  home: both
  hosts: all
  versioned: true
  owner_agent: star-command
  status: active
---

# Skill: skills-inventory

> Um lugar só pra responder "onde vive a skill X e onde deveria rodar". A lista
> de skills que aparece em runtime é **efêmera**; as skills moram em **vários
> homes**. Presença efetiva por runtime é outra prova: `scripts/sync-skills.* --check`.

## Homes cobertos (fonte de verdade = filesystem)

| `home` | Onde | Versionada? |
|---|---|---|
| `repo` | `skills/` no monorepo | ✅ ideal (cross-host) |
| `repo-openclaw` | `openclaw/skills/` | ✅ (runtime OpenClaw) |
| `repo-cursor` | `.cursor/skills/` | ✅ (runtime Cursor) |
| `sep-repo` | `~/.claude/skills/<x>` com `.git` próprio | ✅ (repo git à parte, ex.: `flow-google-especialista`) |
| `plugin` | plugin — `plugins/<x>/` no monorepo **ou** cache do marketplace | ✅ se em `plugins/` do monorepo ou repo próprio; ❌ se só instalado no host |
| `host-local` | só `~/.claude/skills/` desta máquina | ❌ **risco de perda** |

Precedência de dedupe (menor vence): `repo(0) > repo-openclaw(1) > repo-cursor(2) > plugin-repo(3) > sep-repo(4) > plugin-host(5) > host-local(6)` — assim um plugin versionado em `plugins/` vence a cópia instalada em `~/.claude/plugins`.

Symlinks em `~/.claude/skills` que apontam pro monorepo são pulados (já contam como `repo`). Dedupe por nome com precedência: `repo > repo-openclaw > repo-cursor > sep-repo > plugin > host-local`.

## Princípio: filesystem é a verdade da localização

`home`/`versioned` são **derivados de onde o arquivo SKILL.md está fisicamente** — nunca anotados à mão (anotar = apodrecer). O frontmatter só **enriquece** com o que o filesystem não sabe:

```yaml
metadata:
  type: skill
  home: repo | host-local | both   # opcional/informativo — o gerador recalcula pelo FS
  hosts: [macbook] | all           # onde roda/está instalada (intenção declarada)
  versioned: true | false          # idem — recalculado pelo FS
  owner_agent: sueli | liara | star-command | …
  status: active | stopgap | deprecated
```
Skills sem esses campos entram no índice mesmo assim (defaults: `status=active`, `owner=—`, `hosts=all` se versionada senão o host varrido). Adotar os campos é incremental.

## Uso

```bash
# Regenera o REGISTRY.md — visão FULL-HOST (rode do root do monorepo):
node skills/skills-inventory/scripts/build.mjs \
  --repo skills --root . --local ~/.claude/skills \
  --out skills/REGISTRY.md --json skills/skills-inventory/registry.json \
  --host "$(scripts-resolve-host || echo macbook)"

# Só os homes do monorepo (o que o CI enxerga) — usado pelo workflow:
node skills/skills-inventory/scripts/build.mjs --repo skills --root . --repo-only \
  --host repo --json /tmp/registry.json --out /tmp/REGISTRY.md
```
- Sem deps (Node puro). `--stamp "<txt>"` fixa o timestamp (CI/determinismo); default = agora UTC.
- `--root <dir>` = raiz do monorepo (default `dirname(--repo)`), pra achar `openclaw/skills` e `.cursor/skills`.
- `--repo-only` = só homes versionados do monorepo (pula `~/.claude` + plugins). É o modo do CI.
- Em **outro host**, rode com `--host <id>` — os extras `host-local`/`plugin` refletem aquela máquina.

## Camada Supabase (cross-host, queryável por agente)

Tabela `public.adv_skills` (espelho do padrão `adv_devices`): 1 linha por (skill, host_id) com `home/versioned/owner_agent/status/hosts/purpose/repo_path/local_path/note/scanned_at`. A coluna `note` carrega a **procedência** ("onde vive / por quê") — o flag pra saber a origem sem adivinhar. Modelo de host_id:
- **`host_id='repo'`** — a verdade versionada do monorepo (escrita pelo workflow `skills-sync` a cada merge; `--repo-only`). É a base pra UI do adventure-console.
- **`host_id='<máquina>'`** (macbook/beelink/…) — o snapshot daquele host, incluindo os extras `host-local`/`plugin`/`sep-repo` que só existem lá.
- O console lê a **união** (Supabase Realtime). RLS service-only + owner.

Sync via `scripts/sync-db.mjs <registry.json> [host_id]` (PostgREST, sem deps; DELETE do snapshot do host + POST). Soft-skip se faltam `SUPABASE_URL`/`SUPABASE_SERVICE_ROLE_KEY`.

## Sync automático (GitHub Action `skills-sync`)

`.github/workflows/skills-sync.yml` roda a cada **merge em main** que toca `skills/**`, `openclaw/skills/**` ou `.cursor/skills/**`: varre `--repo-only` e faz upsert em `adv_skills` sob `host_id='repo'`. Runner self-hosted (Beelink). **Ativação:** precisa dos secrets `SUPABASE_URL` + `SUPABASE_SERVICE_ROLE_KEY` (guard-step pula gracioso sem eles) + Actions da org destravado (adventure-labs#954).

## Anti-rot (LaunchAgent do Mac semanal)

O command deck regenera a visão full-host e **abre PR no monorepo se o
`REGISTRY.md` mudou** (drift = skill criada/movida/removida sem atualizar o
índice). Outros hosts não atualizam esse arquivo; contribuem via `adv_skills`.
O Action cobre o caminho reativo (merge); o LaunchAgent cobre o full-host +
drift do documento.

## Gotchas
- Skill nova só aparece depois de rodar o gerador — não é automático em tempo real (é por isso que existe o cron).
- `metadata.hosts` expressa intenção, não comprova instalação. Rode
  `scripts/sync-skills.sh --check` ou `scripts\sync-skills.ps1 -Check` no host.
- `~/.claude/skills` é **por host**: o REGISTRY gerado no macbook não conhece skills que só existem no xeon/VPS. A verdade cross-host completa vem da agregação Supabase, não de um único scan.
- Não editar `REGISTRY.md` à mão (tem header de aviso) — a edição é perdida no próximo run.

## Relacionados
- `revisar-skill-pos-execucao` — patcha skills após execução (este só inventaria).
- `scripts/sync-skills.*` — instala e audita a presença das skills versionadas
  nos homes do Claude Code e Codex.
- `device-onboard` / `fleet` — padrão análogo pra devices (Supabase `adv_device_*`); `adv_skills` segue a mesma filosofia pra skills.
