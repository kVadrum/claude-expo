#!/usr/bin/env bash
# Wrapper invoked by the systemd user timer. Fires an Opus 4.7 headless
# Claude Code session against ichnograph using the prompt at
# $PROJECT/ops/prompt.md. All output appended to ~/logs/.

set -uo pipefail

WORKSPACE=/home/kv/dev/projects/claude-expo
PROJECT="$WORKSPACE/ichnograph"
PROMPT="$PROJECT/ops/prompt.md"
LOG=/home/kv/logs/ichnograph-daily.log
CLAUDE=/home/kv/.local/bin/claude

mkdir -p "$(dirname "$LOG")"

# Signal to the guardrails hook that we are in a non-interactive
# session — any "ask" decision cannot be prompted, so the hook
# converts ask → deny.
export CLAUDE_HEADLESS=1
export CLAUDE_PROJECT_DIR="$PROJECT"

# Load nvm's default node onto PATH so the agent can run `npm test`
# and `npm run build`. Systemd's user environment does not inherit
# interactive shell rc files, so the node/npm binaries must be put on
# PATH explicitly. Using nvm (not a hardcoded versioned path) survives
# node upgrades — `nvm use default` resolves whatever version is current.
export NVM_DIR="$HOME/.nvm"
# shellcheck disable=SC1091
if [[ -s "$NVM_DIR/nvm.sh" ]]; then
  . "$NVM_DIR/nvm.sh" >/dev/null 2>&1
  nvm use default >/dev/null 2>&1 || true
fi

ts() { date '+%Y-%m-%d %H:%M:%S %Z'; }

{
  echo "===== $(ts) START ichnograph-daily ====="
  echo "cwd: $PROJECT"
  echo "model: claude-opus-4-7  effort: medium"
  echo "node: $(command -v node || echo MISSING)  npm: $(command -v npm || echo MISSING)"
} >>"$LOG"

cd "$PROJECT" || { echo "$(ts) FATAL: cannot cd to $PROJECT" >>"$LOG"; exit 1; }

"$CLAUDE" \
  --print \
  --model claude-opus-4-7 \
  --effort medium \
  --permission-mode acceptEdits \
  --output-format text \
  "$(cat "$PROMPT")" \
  >>"$LOG" 2>&1

rc=$?

echo "===== $(ts) END ichnograph-daily rc=$rc =====" >>"$LOG"
exit "$rc"
