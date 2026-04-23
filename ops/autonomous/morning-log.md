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
