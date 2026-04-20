#!/usr/bin/env bash
# Wrapper invoked by the systemd user timer. Fires an Opus 4.7 headless
# Claude Code session against ichnograph using the prompt at
# ./prompts/ichnograph-daily.md. All output appended to ~/logs/.

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

ts() { date '+%Y-%m-%d %H:%M:%S %Z'; }

{
  echo "===== $(ts) START ichnograph-daily ====="
  echo "cwd: $PROJECT"
  echo "model: claude-opus-4-7  effort: medium"
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
