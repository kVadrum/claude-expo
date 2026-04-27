# Portfolio Index

Short entries, linked to each project's own repo/README. Reconcile
against memory (`~/.claude/projects/.../memory/MEMORY.md`) before
editing — memory is the source of truth for status.

## Shipped / live

_(pending first cut)_

## Active development

- **[ichnograph](./ichnograph/)** — One-screen orientation CLI for any
  codebase. Detects stack, extracts README, surfaces runnable
  commands (package.json / Makefile / justfile), surfaces
  STATE/TODO/CHANGELOG/spec files, shows recent commits with
  working-tree status and in-progress files, renders a depth-limited
  structure tree. Zero runtime deps. TypeScript, Node ≥20, MIT.
  Currently v0.3.0. Previously developed as `glance`, briefly
  `alidade`; settled on `ichnograph` (Vitruvian term for an
  architectural floor plan drawn from directly above). Local-only
  (not yet published to npm).

- **[morning-brief](./morning-brief/)** — Consolidated tail of every
  autonomous rig's `ops/autonomous/morning-log.md` across the
  workspace. Walks `~/dev/projects`, discovers every log, prints a
  per-project digest with a header summary of today-active vs
  today-silent rigs, unpushed-branch count, and dirty-tree count; a
  per-project `HEAD` line with short SHA + commit count in the
  active window + unpushed + dirty markers; and ANSI highlighting
  for `skipped` / `pushed` / `error` in the tail. Flags: `--today`,
  `--since`, `--projects`, `-n`, `--root`, `--no-git`. Bash, no
  deps, single-file script. Currently v0.5.0. Built to solve the
  daily papercut of opening six-plus editor tabs for the morning
  review; v0.3.0 distinguished a stuck timer from a rig correctly
  refusing to act on a dirty tree, v0.4.0 closed the `dev` ahead of
  `origin/dev` blind spot, v0.5.0 added a fixture-driven self-test
  harness (14 cases) so format drift and edge-case regressions stop
  being live-only catches.

## Pre-scaffold / spec stage

_(pending first cut)_

## Archived / paused

_(pending first cut)_
