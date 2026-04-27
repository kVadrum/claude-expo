#!/usr/bin/env bash
# morning-brief test runner.
#
# Builds throwaway fixture projects under a tmp $MB_ROOT, invokes
# bin/morning-brief --root $MB_ROOT, and asserts on the output. Each
# test gets its own root so state never bleeds.
#
# Run: ./test/run-tests.sh
# Exits 0 on green, 1 on any failure.

set -u

THIS_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
. "$THIS_DIR/lib.sh"

# ----- cases ----------------------------------------------------------------

# Each case is a function. Functions assume:
#   - mb_setup has run; $MB_ROOT exists
#   - NO_COLOR=1 is exported (deterministic strings)
# A case fails by returning non-zero from any assert helper.

case_no_logs_under_root() {
  mb_brief
  assert_exit 1
  assert_contains "$MB_ERR" "no morning-log.md found"
}

case_basic_two_projects() {
  mb_make_project alpha
  mb_log alpha "## 2026-04-27  —  alpha cycle  —  pushed"
  mb_make_project beta
  mb_log beta "## 2026-04-27  —  beta cycle  —  skipped"

  mb_brief
  assert_exit 0
  assert_contains "$MB_OUT" "morning-brief"
  assert_contains "$MB_OUT" "alpha"
  assert_contains "$MB_OUT" "beta"
  assert_contains "$MB_OUT" "active today: 2"
  assert_contains "$MB_OUT" "silent today: 0"
  # NO_COLOR=1 → no ANSI escape sequences anywhere.
  assert_not_contains "$MB_OUT" $'\033'
}

case_silent_today_listed() {
  mb_make_project recent
  mb_log recent "## 2026-04-27  —  ran today"
  mb_make_project stale
  mb_log stale "## 2026-04-20  —  last week"

  mb_brief
  assert_exit 0
  assert_contains "$MB_OUT" "active today: 1"
  assert_contains "$MB_OUT" "silent today: 1"
  assert_contains "$MB_OUT" "(stale)"
}

case_dirty_tree_marker() {
  mb_make_project messy
  mb_log messy "## 2026-04-27  —  cycle"
  mb_init_repo messy
  mb_seed messy
  mb_dirty messy 3

  mb_brief
  assert_exit 0
  assert_contains "$MB_OUT" "dirty: 3"
  # Header total surfaces the dirty project name even on a wide brief.
  assert_contains "$MB_OUT" "dirty trees: 1"
  assert_contains "$MB_OUT" "(messy)"
}

case_unpushed_marker() {
  mb_make_project ahead
  mb_log ahead "## 2026-04-27  —  cycle"
  mb_init_repo ahead
  mb_seed ahead
  mb_attach_upstream ahead
  mb_commit ahead "local-only-1"
  mb_commit ahead "local-only-2"

  mb_brief
  assert_exit 0
  assert_contains "$MB_OUT" "unpushed: 2"
  assert_contains "$MB_OUT" "unpushed: 1"  # also the header total
}

case_no_upstream_silent_on_unpushed() {
  # Repo has commits but no @{u} configured. The HEAD line should
  # render fine, but the "unpushed" segment must NOT appear — that
  # signal is reserved for "rig committed, never pushed", not "no
  # remote at all".
  mb_make_project orphan
  mb_log orphan "## 2026-04-27  —  cycle"
  mb_init_repo orphan
  mb_seed orphan

  mb_brief
  assert_exit 0
  # The header always prints "unpushed: 0"; the per-project segment
  # only prints "unpushed: N" with N >= 1. So checking the >=1 forms
  # are absent is enough — no project has any commits ahead of @{u}
  # (and, here, no @{u} at all).
  assert_contains "$MB_OUT" "unpushed: 0"
  assert_not_contains "$MB_OUT" "unpushed: 1"
  assert_not_contains "$MB_OUT" "unpushed: 2"
}

case_empty_repo_no_commits() {
  mb_make_project empty
  mb_log empty "## 2026-04-27  —  cycle"
  mb_init_repo empty
  # No commits. `git rev-parse HEAD` will fail.

  mb_brief
  assert_exit 0
  assert_contains "$MB_OUT" "(no commits)"
}

case_detached_head() {
  # Detached HEAD has no upstream and no symbolic ref. The brief
  # should still render the HEAD line with sha + subject and not
  # crash or emit an "unpushed" segment.
  mb_make_project floating
  mb_log floating "## 2026-04-27  —  cycle"
  mb_init_repo floating
  mb_seed floating
  mb_commit floating "second"
  mb_detach_head floating

  mb_brief
  assert_exit 0
  assert_contains "$MB_OUT" "floating"
  assert_contains "$MB_OUT" "second"   # HEAD subject still rendered
  # No upstream on a detached HEAD; the per-project unpushed segment
  # must stay silent. (Header still prints "unpushed: 0".)
  assert_contains "$MB_OUT" "unpushed: 0"
  assert_not_contains "$MB_OUT" "unpushed: 1"
}

case_no_git_flag_suppresses() {
  mb_make_project withrepo
  mb_log withrepo "## 2026-04-27  —  cycle"
  mb_init_repo withrepo
  mb_commit withrepo "seed"
  mb_dirty withrepo 1

  mb_brief --no-git
  assert_exit 0
  assert_contains "$MB_OUT" "withrepo"
  # No HEAD line, no dirty/unpushed segments, no header totals.
  assert_not_contains "$MB_OUT" "HEAD"
  assert_not_contains "$MB_OUT" "dirty:"
  assert_not_contains "$MB_OUT" "dirty trees:"
  assert_not_contains "$MB_OUT" "unpushed:"
}

case_projects_filter_no_match() {
  mb_make_project alpha
  mb_log alpha "## 2026-04-27"
  mb_make_project beta
  mb_log beta "## 2026-04-27"

  mb_brief --projects nope
  assert_exit 1
  assert_contains "$MB_ERR" "matched 0"
}

case_projects_filter_substring() {
  mb_make_project kemek-comms
  mb_log kemek-comms "## 2026-04-27 — comms"
  mb_make_project kemek-blog
  mb_log kemek-blog "## 2026-04-27 — blog"
  mb_make_project ichnograph
  mb_log ichnograph "## 2026-04-27 — ichno"

  mb_brief --projects kemek
  assert_exit 0
  assert_contains "$MB_OUT" "kemek-comms"
  assert_contains "$MB_OUT" "kemek-blog"
  # ichnograph should not appear in tail blocks; the header may still
  # mention it in silent_today, but our filter said --today active so
  # it'll just be excluded from the rendered logs.
  # Cheap check: per-project rule lines are bolded with "── <name> ".
  assert_not_contains "$MB_OUT" "── ichnograph "
}

case_invalid_since_arg() {
  mb_make_project x
  mb_log x "anything"
  mb_brief --since "not-a-date"
  assert_exit 2
  assert_contains "$MB_ERR" "YYYY-MM-DD"
}

case_since_filters_lines() {
  mb_make_project mixed
  mb_log mixed "## 2026-04-20  —  old line"
  mb_log mixed "## 2026-04-27  —  fresh line"

  mb_brief --since 2026-04-25
  assert_exit 0
  assert_contains "$MB_OUT" "fresh line"
  assert_not_contains "$MB_OUT" "old line"
}

case_today_implies_since_today() {
  mb_make_project todayproj
  mb_log todayproj "## 2026-04-20  —  ancient"
  mb_log todayproj "## $(date +%F)  —  current"

  mb_brief --today
  assert_exit 0
  assert_contains "$MB_OUT" "current"
  assert_not_contains "$MB_OUT" "ancient"
}

# ----- entry ----------------------------------------------------------------

main() {
  printf 'morning-brief test suite\n'
  printf '  bin: %s\n\n' "$MB_BIN"

  t "no-logs-under-root"            case_no_logs_under_root
  t "basic-two-projects"            case_basic_two_projects
  t "silent-today-listed"           case_silent_today_listed
  t "dirty-tree-marker"             case_dirty_tree_marker
  t "unpushed-marker"               case_unpushed_marker
  t "no-upstream-silent-on-unpushed" case_no_upstream_silent_on_unpushed
  t "empty-repo-no-commits"         case_empty_repo_no_commits
  t "detached-head"                 case_detached_head
  t "no-git-flag-suppresses"        case_no_git_flag_suppresses
  t "projects-filter-no-match"      case_projects_filter_no_match
  t "projects-filter-substring"     case_projects_filter_substring
  t "invalid-since-arg"             case_invalid_since_arg
  t "since-filters-lines"           case_since_filters_lines
  t "today-implies-since-today"     case_today_implies_since_today

  mb_summary
}

main "$@"
