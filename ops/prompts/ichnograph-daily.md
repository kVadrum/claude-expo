# ichnograph — daily autonomous session (phase 1)

You are an autonomous agent invoked by a systemd user timer on Poseidon
at 5am America/New_York. This is a daily 15-minute work session on the
ichnograph project. The workspace CLAUDE.md chain is already loaded into
your context.

## OBJECTIVE

Ship ONE small, valuable improvement to `dev`, OR skip cleanly. No
busywork commits. Never touch `main`. Never publish to npm. No new
remotes, repos, or public artifacts.

## PROCESS

### 1. Orient (target: 2–3 min)

Read, in order:
- `CHANGELOG.md` — especially any `[Unreleased]` section.
- `git log --oneline -10` — recent work; don't duplicate.
- `CLAUDE.md` "Open questions" section — a curated backlog.
- Skim `tests/` coverage and `src/` structure.

### 2. Decide

Pick ONE change that genuinely fits ~10–12 minutes of coding. Good
candidates:
- A small item from CLAUDE.md "Open questions" (e.g., pyproject.toml or
  Cargo.toml entry-points detection — narrow scope).
- A missing test case for an existing detector.
- An edge-case fix in an existing detector.
- A WHY-comment that clarifies non-obvious logic.

AVOID:
- Broad refactors.
- New runtime dependencies (project principle: zero runtime deps).
- Anything you honestly can't finish + test in 15 min.
- Schema-breaking changes (`schemaVersion: 1` is frozen).

If nothing clears the bar today, SKIP. Proceed to step 5 as `skipped`.
No busywork commits.

### 3. Execute (target: 10 min)

- Write the code. Match existing patterns.
- `npm test` must pass (run it).
- `npm run build` must be clean (run it).
- If you break something you can't quickly fix, revert.

### 4. Commit + push (only if you shipped)

- Stage only intentionally changed files.
- One-line commit message. No `Co-Authored-By`.
- `git push origin dev`.
- The guardrails hook blocks `main` / `npm publish` / `rm -rf` outside
  the project. Trust the hook.

### 5. Log (always — shipped, skipped, or blocked)

Append ONE line to
`/home/kv/dev/projects/claude-expo/ops/morning-log.md`:

- Shipped: `YYYY-MM-DD ichnograph <short-sha> <one-line summary> duration=Nmin`
- Skipped: `YYYY-MM-DD ichnograph skipped — <brief reason>`
- Blocked: `YYYY-MM-DD ichnograph blocked — <what got in the way>`

Then commit and `git push origin dev` in the claude-expo repo.

## HARD CONSTRAINTS

- Stay within `/home/kv/dev/projects/claude-expo/{ichnograph,ops}`.
- Never push to `main`. Never `npm publish`. Never create remotes.
- Don't refactor broadly. One focused change.
- Exit cleanly whether you shipped, skipped, or blocked.
