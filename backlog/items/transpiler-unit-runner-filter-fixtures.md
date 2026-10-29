---
target: open-abap
title: 'transpiler: the generated unit runner takes no filter, runs class_setup/setup outside its TRY and prints text only - three abap2UI5 tools patch or replace index.mjs by string surgery'
summary: '`unitTestScript( )` emits a runner that iterates every test class of the output, calls `class_setup` and `setup` outside the per-method try (one failing fixture aborts the whole run), accepts no object/class/method argument and reports in prose; the MCP server string-replaces the loop to filter, abap-agent-runtime cuts the file at `async function run` and appends its own runner, the playground runs one class at a time to survive a fixture failure'
priority: medium
state: open
first_seen: 2026-10-22
upstream: abaplint/transpiler
evidence:
  - 'abap2UI5/mcp-server `lib/runtime.mjs:3159-3166` (2026-10): ''It takes no filter … the patch is refused … when that line is not where the template put it''; `RUNNER_LOOP = ''for (const st of getData()) {''` is replaced textually (`:3236-3240`); `:3177-3195` guesses a fixture failure from stack frames; `:3299-3302` raises `--stack-trace-limit=100` because V8''s ten frames lose the test class'
  - 'abap2UI5-addons/abap-agent-runtime `.github/scripts/unit.mjs:129-237`: cuts the generated `index.mjs` at `"async function run"` (`:131`) and appends a runner with a prefix filter (`UNIT_FILTER`), a try around `class_setup` and PASS/FAIL/SKIP tallies'
  - 'abap2UI5/playground `src/runtime/index.mjs:153-158`: runs one test class at a time because ''The runner calls class_setup and setup outside its own TRY … every test of every class came back failed'''
  - 'read 2026-10-22 in abaplint/transpiler main 53a708f - `packages/transpiler/src/unit_test.ts:231`: `if (localClass.class_setup) await localClass.class_setup();` with no try; the runner reads no arguments; JSON output exists only in `unitTestScriptOpen`'
checked_upstream: 2026-10-22
---

# transpiler: a unit runner with a filter, fixture isolation and machine output

## The problem

`unitTestScript( )` (`packages/transpiler/src/unit_test.ts`) generates
`index.mjs`, the runner `npm run unit` executes. Three hosts have
rewritten it independently because it lacks the same three things:

1. **A filter.** No way to run one object, class or method. The MCP
   server string-replaces the runner's loop; abap-agent-runtime cuts the
   file at `async function run` and appends its own loop with
   `UNIT_FILTER`.
2. **Fixture isolation.** `class_setup` and `setup` run outside the
   per-method `try` (`unit_test.ts:231`), so one failing fixture ends the
   run with a stack trace and no result for anything after it. The
   playground runs one class per invocation to contain it; the MCP server
   guesses "fixture failure" from stack frames.
3. **Machine-readable results.** The runner prints prose;
   `output.json` exists only in the "open" variant.

## Proposed change

The generated runner reads `process.argv` (or an exported `run(options)`):

```
node index.mjs --filter ZCL_FOO[:ltcl_bar[:method]] --json results.json
```

- the filter matches object, class and method prefixes, case-insensitive;
- `class_setup` and `setup` inside a try per class / per method; a
  fixture failure is reported once per affected method as `ERROR` with
  the fixture name, and the run continues with the next class;
- `--json` writes `{object, class, method, status: PASS|FAIL|ERROR|SKIP,
  message, durationMs}[]`, the same shape for both runner variants.

## How to file

An issue against abaplint/transpiler with the three rewrites as the
evidence; the PR is in `unit_test.ts` and its template.

