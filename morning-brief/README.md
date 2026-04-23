# morning-brief

One command. Every autonomous rig's morning-log, side by side.

*README v0.1.0*

## What it does

`morning-brief` walks a workspace (default `~/dev/projects`), finds
every `ops/autonomous/morning-log.md`, and prints a single
consolidated digest so you can see what happened overnight across
every rig without opening seven files.

```
$ morning-brief
── bitcoin-astrolabe ─────────────────────────────────────────
  03:43  futures-chain    a5b1aa4  Phase 3b composition: ...
  03:47  calibrate-lambda  ec78bce  ...
  ...

── claude-expo ───────────────────────────────────────────────
  (no entries yet)

── kemek-comms ───────────────────────────────────────────────
  - 2026-04-23 04:01 pushed 5703cee — "api: live ws push ..."
  - 2026-04-23 04:10 pushed ca69461 — "api: rate-limit ..."
  ...
```

## Why

The workspace has a growing fleet of daily autonomous rigs. Each one
writes its own `morning-log.md`. Reviewing them in the morning meant
opening N files in N editor tabs and eyeballing the tails — a
papercut that gets worse every time a new project joins the rotation.

`morning-brief` is the consolidated view.

## Design choices

- **No parser.** Every rig's log looks a little different (some use
  `## date` headers, some use flat bulleted lines, some use
  indented-timestamp blocks). Trying to parse them all would be
  fragile and thankless. Default is a raw tail of the last N
  non-blank lines — works for every format. `--since` and `--today`
  do a narrower date-grep on top of that, matching any ISO date
  anywhere in the line.
- **Bash.** No deps, no build step, one file in `bin/`.
  `morning-brief` is a tool you should be able to read in a minute.
- **Cheap to run.** No network, no git clones. Just reads local
  files.

## Usage

```
morning-brief [--today] [--since YYYY-MM-DD] [-n N] [--root PATH]
```

- `--today` — only lines dated today (`date +%F`).
- `--since DATE` — only lines dated on or after DATE.
- `-n N` — tail the last N matching lines per project (default 8).
- `--root PATH` — workspace root to scan (default `~/dev/projects`).

Exit code is 0 if any log was found, 1 otherwise.

## Install

```
ln -s "$PWD/bin/morning-brief" ~/.local/bin/morning-brief
```

Or run it in place:

```
./bin/morning-brief
```

No package manager, no registry. It's ~100 lines of bash; vendor it
however you like.

## Roadmap (informal)

Next cycle ideas, in rough priority order:

- Per-project git HEAD + short commit count ("3 commits in last 24h")
  alongside the log tail, so you can see cadence at a glance.
- Detect and highlight `skipped` / `error` / `FAIL` lines.
- `--projects A,B` filter.
- JSON output mode for piping into other tools.

## Status

v0.1.0. Works against the 7 morning-logs currently in `~/dev/projects/`.

---

KeMeK Network © 2026
