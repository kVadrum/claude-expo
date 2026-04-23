# claude-expo — autonomous ideation rig

Daily autonomous session for picking a new tool, scoping it, and
starting to build. One hour hard cap. 24 commits max. See
`prompt.md` for the full brief.

Unlike every other per-project rig (which continues existing work on
a specific subproject), this rig is scoped to the claude-expo root
and explicitly permitted to create new subprojects.

## Pieces

- `run-tonight.sh` — systemd-invoked wrapper
- `prompt.md` — the cycle prompt
- `sessions/` — per-cycle reports
- `morning-log.md` — newest-at-bottom summary index
- `~/.config/systemd/user/claude-expo-daily.{service,timer}` — the
  timer pair (not committed)
- `~/logs/claude-expo-daily.log` — raw session output

## Arm / disarm

```bash
systemctl --user enable --now claude-expo-daily.timer   # arm
systemctl --user disable --now claude-expo-daily.timer  # disarm
systemctl --user start claude-expo-daily.service        # run once now
```

Check status at the POSEIDON portal (`http://localhost:5850/concierge`)
or with `systemctl --user list-timers claude-expo-daily.timer`.

## Fences

The claude-expo-wide `.claude/hooks/guardrails.sh` hook is unchanged:
in headless mode it hard-denies package publishing, `git push` to
`main`, and `rm -rf` outside the project root. Everything else —
including scaffolding new subproject directories, running `git init`
in them, installing packages, and committing + pushing to `dev` —
runs without prompting.

Budgets live in the wrapper: `SESSION_MINUTES=60`, `COMMIT_CAP=24`.
The prompt reads and enforces them.
