# claude-expo daily — morning log

Newest entries at the bottom. One entry per cycle; detailed reports
live in `sessions/YYYY-MM-DD.md`.

Format:

```
## YYYY-MM-DD  —  [new|continue: <subproject>]  —  Nm / Nc
Summary line.
Next: what the next cycle starts with.
```

## 2026-04-23  —  new: morning-brief  —  ~50m / 6c
Scaffolded `morning-brief/`, a bash CLI that walks `~/dev/projects`,
finds every `ops/autonomous/morning-log.md`, and prints a
consolidated per-project digest with a today-active/today-silent
summary in the header. Flags: `--today`, `--since`, `-n`,
`--projects`, `--root`. v0.1.0, working against all 7 morning-logs
currently in the workspace. Report: sessions/2026-04-23.md.
Next: continue morning-brief with per-project git HEAD + 24h commit
count so the header answers cadence at a glance.

## 2026-04-24  —  continue: morning-brief  —  ~40m / 4c
morning-brief v0.2.0: added a per-project `HEAD <sha> · N commits
last 24h · <subject>` line under the rule header (follows `--since`
when set), added `--no-git` to opt out, and wired ANSI highlighting
for `skipped` (yellow) / `pushed` (green) / `error|FAIL|WARN` (red)
in the tail. The kemek-blog case of 24 consecutive skips now jumps
off the page. README and INDEX updated; `--no-git` clean on pipes
and NO_COLOR. Report: sessions/2026-04-24.md.
Next: either a `--dirty` column that flags projects with
uncommitted changes (dirty tree is the actual story behind
kemek-blog's skip wall, and the HEAD line alone can't say so), or
split the cadence number across HEAD / commits / pushed-to-remote
so a commit-but-no-push rig is visible at a glance.

## 2026-04-25  —  continue: morning-brief  —  ~30m / 4c
morning-brief v0.3.0: dirty-tree marker. Per-project `HEAD` line
gains a yellow `· dirty: N ·` segment when `git status --porcelain`
is non-zero (suppressed when clean); header summary gains
`dirty trees: K (proj1, proj2)` next to active/silent. Walks
`all_logs` so a `--projects` drill-down still surfaces dirty trees
elsewhere. Yellow matches `skipped` because both mean "waiting on
a human". Closes the kemek-blog story end-to-end: 24 skips +
`dirty: 18` now reads as "rig correctly refusing", not "stuck
timer". README and INDEX bumped. Report: sessions/2026-04-25.md.
Next: HEAD-vs-pushed split — `git rev-list @{u}..HEAD --count` to
flag rigs that commit locally but never push, since `dev` ahead of
`origin/dev` is currently invisible to the brief.

## 2026-04-26  —  continue: morning-brief  —  ~30m / 4c
morning-brief v0.4.0: unpushed-commit marker. Per-project `HEAD`
line gains a cyan `· unpushed: N ·` segment when HEAD is ahead of
upstream (silent skip when no upstream / detached / 0 ahead);
header summary gains `unpushed: K (proj1, ...)` between silent and
dirty. Cyan keeps the palette legible (yellow=waiting-on-human,
green=shipped, red=broken; unpushed is "owes a push"). Walks
`all_logs` so drill-down still surfaces unpushed work elsewhere;
single git walk now drives both dirty and unpushed totals. First
run on the live workspace surfaced claude-expo itself at
`unpushed: 17` — exact shape the marker was added for. README
gains a claude-expo example block; INDEX bumped to v0.4.0. Report:
sessions/2026-04-26.md.
Next: self-test harness with fixture logs (no upstream / empty
repo / detached HEAD / dirty modes) so format drift and corner
cases stop being live-only catches; JSON output mode parked
behind that.
