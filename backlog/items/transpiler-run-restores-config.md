---
target: open-abap
title: 'transpiler: run( ) replaces the registry''s configuration for its validation and leaves it in place - a host that keeps the registry for its own linting gets the transpiler''s rules back'
summary: '`validation.ts` calls `reg.setConfig(conf)` with the transpiler''s own config (OpenABAP syntax, void everything) and never restores the caller''s; an editor that reuses the registry for abaplint diagnostics has to save and restore the config and reparse after every transpile'
priority: low
state: open
first_seen: 2026-10-22
upstream: abaplint/transpiler
evidence:
  - 'abap2UI5/playground `src/editor/transpile-core.mjs:55-60` and `:95-98` (2026-10): ''The transpiler restores nothing it changes: it replaces the registry''s …''; the playground sets the editor config back through the proxy and calls `reg.parse()` again; `docs/design/build-traps.md:220-222`'
  - 'read 2026-10-22 in abaplint/transpiler main 53a708f - `packages/transpiler/src/validation.ts:145-156`: `reg.setConfig(conf)` with no restore'
  - 'prepared 2026-10-22 as `oblomov-dev/fork-transpiler` branch `fix/run-restores-registry-config` (fd69084) on abaplint/transpiler main 53a708f: the change plus tests, green in the package suites and the transpiler''s integration tests; the fourteen prepared branches merged together transpile open-abap-core main 239b817 and pass its whole unit suite (1172 tests).'
checked_upstream: 2026-10-22
---

# transpiler: `run( )` should leave the registry's config as it found it

## The problem

`Validation.run( )` installs the transpiler's own abaplint configuration
on the registry it was given (`packages/transpiler/src/validation.ts:145-156`,
`reg.setConfig(conf)`) and returns without restoring the previous one.
For a one-shot CLI that is invisible. For a host that keeps one registry
for the editor's diagnostics and the transpile, every transpile silently
switches the editor's rules, version and unknown-type handling; the
playground saves and restores the config and reparses after each run.

## Proposed change

`const previous = reg.getConfig(); try { reg.setConfig(conf); … } finally
{ reg.setConfig(previous); }` - and document that `run( )` reparses. If a
reparse after restore is too expensive, validate on `reg` with
`conf` applied only for the duration (abaplint's `Registry.findIssues`
takes the config from the registry today, so the restore is the cheap
option).

## How to file

A small PR against abaplint/transpiler.

