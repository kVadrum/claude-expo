# morning-brief

One command. Every autonomous rig's morning-log, side by side.

*README v0.4.0*

## What it does

`morning-brief` walks a workspace (default `~/dev/projects`), finds
every `ops/autonomous/morning-log.md`, and prints a single
consolidated digest so you can see what happened overnight across
every rig without opening seven files.

```
$ morning-brief
morning-brief — 6 log(s) under /home/kv/dev/projects
  active today: 5  ·  silent today: 1 (kemek-digest)  ·  unpushed: 1 (claude-expo)  ·  dirty trees: 1 (kemek-blog)

── bitcoin-astrolabe ─────────────────────────────────────────
  HEAD d2596b0  · 2 commits last 24h · chore: bump version to 0.3.2
  03:43  futures-chain    a5b1aa4  Phase 3b composition: ...
  03:47  calibrate-lambda  ec78bce  ...
  ...

── claude-expo ───────────────────────────────────────────────
  HEAD 09c2e7b  · 5 commits last 24h · unpushed: 17 · dirty: 1 · claude-expo-daily: ...
  ...

── kemek-blog ────────────────────────────────────────────────
  HEAD e119cc2  · 0 commits last 24h · dirty: 18 · ops: 2026-04-24 01:46 session report (skipped)
  - 2026-04-23 04:18 (skipped)
  - 2026-04-24 01:46 (skipped)
  ...
```

The dim `HEAD` line answers commit-cadence at a glance — the log
tail tells you what each rig *said* it did; the commit count tells
you what actually landed on `dev`. A rig that logs twenty skips
but shows `0 commits last 24h` *and* `dirty: 18` is the shape of a
rig correctly refusing to act on a tree it can't touch — a
different problem from a stuck timer, and one the morning brief
distinguishes.

The cyan `unpushed: N` segment closes a different blind spot: a
rig that commits cleanly but never pushes. `dev` ahead of
`origin/dev` was previously invisible — every other signal could
look healthy while the work hadn't actually left the box. The
brief now flags it both per-project and in the header.

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
rigs, a count of unpushed branches, and a count of dirty trees (each
with the project list), independent of any filter — so you see
missed runs, unpushed work, and stuck trees at a glance even when
drilling in on a specific project. The unpushed and dirty-tree
counts are both suppressed by `--no-git`.

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

- A self-test harness with fixture logs, so format changes don't
  silently regress the tail.
- JSON output mode for piping into other tools.
- Distinguish dirty kinds — modified-tracked vs untracked vs staged
  — when the count alone is too coarse to triage from.
- Highlight the *opposite* of unpushed too: rigs whose `origin/dev`
  is ahead of local (someone pushed from another machine and the
  local clone hasn't pulled). Less common in this workspace but
  cheap to add once the upstream-aware path exists.

## Status

v0.4.0. Works against the 6 morning-logs currently in
`~/dev/projects/`. The v0.4.0 addition is the unpushed-commit
marker — per-project cyan segment plus header summary — closing
the `dev` ahead of `origin/dev` blind spot.

---

KeMeK Network © 2026
