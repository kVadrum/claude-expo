# morning-brief

One command. Every autonomous rig's morning-log, side by side.

*README v0.2.0*

## What it does

`morning-brief` walks a workspace (default `~/dev/projects`), finds
every `ops/autonomous/morning-log.md`, and prints a single
consolidated digest so you can see what happened overnight across
every rig without opening seven files.

```
$ morning-brief
── bitcoin-astrolabe ─────────────────────────────────────────
  HEAD d2596b0  · 2 commits last 24h · chore: bump version to 0.3.2
  03:43  futures-chain    a5b1aa4  Phase 3b composition: ...
  03:47  calibrate-lambda  ec78bce  ...
  ...

── kemek-comms ───────────────────────────────────────────────
  HEAD 7da320d  · 34 commits last 24h · api: 401 RFC 7807 shape
  - 2026-04-24 04:01 pushed 5703cee — "api: live ws push ..."
  - 2026-04-24 04:10 pushed ca69461 — "api: rate-limit ..."
  ...
```

The dim `HEAD` line answers commit-cadence at a glance — the log
tail tells you what each rig *said* it did; the commit count tells
you what actually landed on `dev`. A rig that logs twenty skips
but shows `0 commits last 24h` is the shape of a stuck timer.

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
morning-brief [--today] [--since YYYY-MM-DD] [-n N]
              [--projects LIST] [--root PATH]
```

- `--today` — only lines dated today (`date +%F`).
- `--since DATE` — only lines dated on or after DATE.
- `-n N` — tail the last N matching lines per project (default 8).
- `--projects LIST` — comma-separated substrings (case-insensitive);
  show only projects whose label contains one of them. Useful for
  drilling into a single rig: `morning-brief --projects comms`.
- `--root PATH` — workspace root to scan (default `~/dev/projects`).
- `--no-git` — skip the per-project `HEAD` summary line. Faster, and
  appropriate when scanning a root that isn't all git repos.

Exit code is 0 if any log was found and (if `--projects` is set) the
filter matched at least one, 1 otherwise.

The header always carries a summary of today-active vs today-silent
rigs, independent of any filter — so you see missed runs at a
glance even when drilling in on a specific project.

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

- Detect and highlight `skipped` / `error` / `FAIL` lines. The
  kemek-blog case of twenty-four consecutive skips is the exact
  shape that should jump off the page.
- A self-test harness with fixture logs, so format changes don't
  silently regress the tail.
- JSON output mode for piping into other tools.
- Optional `--dirty` column that flags projects with uncommitted
  changes (the `kemek-blog` "dirty tree" story is invisible from the
  HEAD line alone).

## Status

v0.2.0. Works against the 6 morning-logs currently in
`~/dev/projects/`. The per-project `HEAD` line is the v0.2.0
addition.

---

KeMeK Network © 2026
