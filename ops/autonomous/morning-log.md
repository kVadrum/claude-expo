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
