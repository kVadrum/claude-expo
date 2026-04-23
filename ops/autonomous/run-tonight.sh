#!/usr/bin/env bash
# claude-expo ideation rig wrapper.
#
# This rig is different from every other per-project rig: its job is
# to invent. Each cycle, Claude picks a small tool that would help the
# kVadrum/Claude workflow or help others, scopes it, and starts
# building. One hour hard cap. Subproject creation is explicitly
# allowed. Still strictly on `dev`; the guardrails hook converts every
# `ask` decision to `deny` under CLAUDE_HEADLESS=1, so publishing and
# main-touching pushes remain blocked.
#
# Invoked by the systemd user timer. All output appended to ~/logs/.

set -uo pipefail

WORKSPACE=/home/kv/dev/projects/claude-expo
PROMPT="$WORKSPACE/ops/autonomous/prompt.md"
LOG=/home/kv/logs/claude-expo-daily.log
CLAUDE=/home/kv/.local/bin/claude

mkdir -p "$(dirname "$LOG")"

# Hard budgets. The prompt reads these and self-enforces.
export SESSION_MINUTES=60
export COMMIT_CAP=24

# Signal to the guardrails hook that we are in a non-interactive
# session — any "ask" decision cannot be prompted, so the hook
# converts ask → deny.
export CLAUDE_HEADLESS=1
export CLAUDE_PROJECT_DIR="$WORKSPACE"

# Load nvm's default node onto PATH so the agent can scaffold Node/npm
# projects, run tests, and run builds in any new or existing subproject.
# Systemd's user environment does not inherit interactive shell rc
# files, so the binaries must be put on PATH explicitly.
export NVM_DIR="$HOME/.nvm"
# shellcheck disable=SC1091
if [[ -s "$NVM_DIR/nvm.sh" ]]; then
  . "$NVM_DIR/nvm.sh" >/dev/null 2>&1
  nvm use default >/dev/null 2>&1 || true
fi

ts() { date '+%Y-%m-%d %H:%M:%S %Z'; }

{
  echo "===== $(ts) START claude-expo-daily ====="
  echo "cwd: $WORKSPACE"
  echo "model: claude-opus-4-7  effort: high"
  echo "budget: ${SESSION_MINUTES}m / ${COMMIT_CAP} commits"
  echo "node: $(command -v node || echo MISSING)  npm: $(command -v npm || echo MISSING)"
} >>"$LOG"

cd "$WORKSPACE" || { echo "$(ts) FATAL: cannot cd to $WORKSPACE" >>"$LOG"; exit 1; }

"$CLAUDE" \
  --print \
  --model claude-opus-4-7 \
  --effort high \
  --permission-mode acceptEdits \
  --output-format text \
  "$(cat "$PROMPT")" \
  >>"$LOG" 2>&1

rc=$?

echo "===== $(ts) END claude-expo-daily rc=$rc =====" >>"$LOG"
exit "$rc"
