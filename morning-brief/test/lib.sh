# morning-brief test library — assertions + fixture builders.
#
# Sourced by run-tests.sh and per-case files. Keeps state in shell
# vars and a single tmpdir under $MB_ROOT, so each test starts clean.
#
# Public surface:
#
#   mb_setup           prepare a fresh fixture root + tmpdir
#   mb_teardown        wipe the fixture root (auto-called by trap)
#   mb_brief [args]    run morning-brief --root $MB_ROOT [args],
#                      capture stdout+stderr+exit into vars:
#                        MB_OUT, MB_ERR, MB_EXIT
#
# Fixture builders (all take a project name; reusable across cases):
#   mb_make_project NAME            create dir + empty morning-log.md
#   mb_log NAME LINE                append a line to morning-log.md
#   mb_init_repo NAME               git init + identity, no commits
#   mb_seed NAME [MSG]              git add -A + commit (turns the
#                                   morning-log fixture file into HEAD,
#                                   so it stops counting as dirty)
#   mb_commit NAME [MSG]            allow-empty commit on current branch
#   mb_dirty NAME [N]               create N untracked files (default 1)
#   mb_attach_upstream NAME         add a bare remote and push current
#                                   branch so @{u} resolves
#   mb_detach_head NAME             checkout HEAD by sha (detach)
#
# Assertions:
#   t NAME BODY            run BODY in a subshell, record pass/fail
#   assert_contains S SUB  fail if SUB not in S
#   assert_not_contains    fail if SUB IS in S
#   assert_eq A B          fail unless A == B
#   assert_exit CODE       fail unless MB_EXIT == CODE
#
# Each case file defines functions; run-tests.sh calls them in order.

set -u

# Resolve the morning-brief binary once, relative to this file's dir.
MB_LIB_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
MB_BIN="${MB_LIB_DIR}/../bin/morning-brief"

if [[ ! -x "$MB_BIN" ]]; then
  echo "test/lib.sh: morning-brief not executable at $MB_BIN" >&2
  exit 2
fi

# Counters owned by the runner.
MB_PASS=0
MB_FAIL=0
MB_FAIL_NAMES=()

# Per-test state, reset by mb_setup.
MB_ROOT=""
MB_OUT=""
MB_ERR=""
MB_EXIT=0
MB_CURRENT_TEST=""

mb_setup() {
  MB_ROOT="$(mktemp -d -t morning-brief-test.XXXXXX)"
  # NO_COLOR by default so output is deterministic; override in a
  # specific case if you want to assert ANSI behavior.
  export NO_COLOR=1
}

mb_teardown() {
  if [[ -n "$MB_ROOT" && -d "$MB_ROOT" ]]; then
    rm -rf "$MB_ROOT"
  fi
  MB_ROOT=""
}

# Ensure cleanup even on a hard fail mid-test.
trap 'mb_teardown' EXIT

mb_make_project() {
  local name="$1"
  local dir="$MB_ROOT/$name/ops/autonomous"
  mkdir -p "$dir"
  : > "$dir/morning-log.md"
}

mb_log() {
  local name="$1"; shift
  local line="$*"
  printf '%s\n' "$line" >> "$MB_ROOT/$name/ops/autonomous/morning-log.md"
}

mb_init_repo() {
  local name="$1"
  local dir="$MB_ROOT/$name"
  git -C "$dir" init -q -b dev
  git -C "$dir" config user.email "test@example.invalid"
  git -C "$dir" config user.name "morning-brief test"
  # Disable signing in case the user's global config requires it.
  git -C "$dir" config commit.gpgsign false
  git -C "$dir" config tag.gpgsign false
}

mb_commit() {
  local name="$1"
  local msg="${2:-test commit}"
  git -C "$MB_ROOT/$name" commit --allow-empty -q -m "$msg"
}

# Stage every file currently in the project dir and commit. Used after
# mb_init_repo to turn the fixture's existing morning-log.md (and any
# other seeded files) into HEAD, so they stop counting as dirty.
mb_seed() {
  local name="$1"
  local msg="${2:-seed}"
  git -C "$MB_ROOT/$name" add -A
  git -C "$MB_ROOT/$name" commit -q -m "$msg"
}

mb_dirty() {
  local name="$1"
  local n="${2:-1}"
  local i
  for ((i=0; i<n; i++)); do
    : > "$MB_ROOT/$name/dirty-$i.txt"
  done
}

# Attach a bare remote and push the current branch so @{u} resolves.
# Used to test the "unpushed" segment by then making local commits
# that won't be pushed.
mb_attach_upstream() {
  local name="$1"
  local dir="$MB_ROOT/$name"
  local bare="$MB_ROOT/.remotes/$name.git"
  mkdir -p "$(dirname "$bare")"
  git init --bare -q "$bare"
  git -C "$dir" remote add origin "$bare"
  git -C "$dir" push -q -u origin HEAD
}

mb_detach_head() {
  local name="$1"
  local sha
  sha="$(git -C "$MB_ROOT/$name" rev-parse HEAD)"
  git -C "$MB_ROOT/$name" -c advice.detachedHead=false checkout -q "$sha"
}

# Run the brief against $MB_ROOT and capture streams.
mb_brief() {
  local out_f err_f
  out_f="$(mktemp)"
  err_f="$(mktemp)"
  set +e
  "$MB_BIN" --root "$MB_ROOT" "$@" >"$out_f" 2>"$err_f"
  MB_EXIT=$?
  set -e
  MB_OUT="$(cat "$out_f")"
  MB_ERR="$(cat "$err_f")"
  rm -f "$out_f" "$err_f"
}

# t NAME BODY — run a single case. BODY is a shell command (usually a
# function name). Each case gets its own clean $MB_ROOT.
t() {
  MB_CURRENT_TEST="$1"; shift
  mb_setup
  set +e
  ( set -e; "$@" )
  local rc=$?
  set -e
  mb_teardown
  if (( rc == 0 )); then
    MB_PASS=$((MB_PASS+1))
    printf '  \033[32mPASS\033[0m  %s\n' "$MB_CURRENT_TEST"
  else
    MB_FAIL=$((MB_FAIL+1))
    MB_FAIL_NAMES+=("$MB_CURRENT_TEST")
    printf '  \033[31mFAIL\033[0m  %s (rc=%d)\n' "$MB_CURRENT_TEST" "$rc"
  fi
}

assert_contains() {
  local hay="$1" needle="$2"
  if [[ "$hay" != *"$needle"* ]]; then
    printf '    assert_contains: missing %q\n' "$needle" >&2
    printf '    --- output ---\n%s\n    --- end ---\n' "$hay" >&2
    return 1
  fi
}

assert_not_contains() {
  local hay="$1" needle="$2"
  if [[ "$hay" == *"$needle"* ]]; then
    printf '    assert_not_contains: unexpected %q\n' "$needle" >&2
    printf '    --- output ---\n%s\n    --- end ---\n' "$hay" >&2
    return 1
  fi
}

assert_eq() {
  local a="$1" b="$2"
  if [[ "$a" != "$b" ]]; then
    printf '    assert_eq: %q != %q\n' "$a" "$b" >&2
    return 1
  fi
}

assert_exit() {
  local want="$1"
  if [[ "$MB_EXIT" != "$want" ]]; then
    printf '    assert_exit: got %s, want %s\n' "$MB_EXIT" "$want" >&2
    printf '    --- stdout ---\n%s\n    --- stderr ---\n%s\n' "$MB_OUT" "$MB_ERR" >&2
    return 1
  fi
}

mb_summary() {
  printf '\n%d passed, %d failed\n' "$MB_PASS" "$MB_FAIL"
  if (( MB_FAIL > 0 )); then
    printf 'failed:\n'
    local n
    for n in "${MB_FAIL_NAMES[@]}"; do
      printf '  - %s\n' "$n"
    done
    return 1
  fi
}
