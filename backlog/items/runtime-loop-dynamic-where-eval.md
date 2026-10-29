---
target: open-abap
title: 'runtime: a dynamic LOOP … WHERE (lv_cond) is run through JS eval( ) - the condition text is executable JavaScript'
summary: '`statements/loop.ts` rewrites the dynamic WHERE text and hands it to `eval(text)`, so a condition like `table_line EQ table_line OR (globalThis.x=1)` runs arbitrary JS in the host; the MCP server flags every dynamic WHERE it migrates and gives child processes an environment allowlist because of it'
priority: medium
state: open
first_seen: 2026-10-22
upstream: abaplint/transpiler
evidence:
  - 'read 2026-10-22 in abaplint/transpiler main 53a708f - `packages/runtime/src/statements/loop.ts:149-152`: the dynamic WHERE string is rewritten and `return eval(text)` evaluates it per row'
  - 'abap2UI5/mcp-server `lib/migrate.mjs:106-114` (2026-10): ''evaluates a dynamic WHERE condition with eval() after rewriting the … `table_line EQ table_line OR (globalThis.x=1)` sets x''; `:195-210` emits a warning per dynamic WHERE; `SECURITY.md:112-118`, `AGENTS.md:1436-1441`; `lib/runtime.mjs:2085-2095` gives child processes an env allowlist for the same reason'
checked_upstream: 2026-10-22
---

# runtime: the dynamic `WHERE` of a LOOP is JavaScript

## What happens

```abap
DATA lv_cond TYPE string.
lv_cond = `table_line EQ table_line OR (globalThis.x = 1)`.
LOOP AT lt_tab INTO lv_line WHERE (lv_cond).
ENDLOOP.
" runtime 2.14.10: globalThis.x is 1 afterwards
```

`packages/runtime/src/statements/loop.ts` turns the condition text into a
JS expression by text replacement and runs it with `eval( )` for every
row. Whatever the string holds that survives the rewrite is executed in
the process: for a server that runs user ABAP (the abap2UI5 MCP server,
the playground worker), a dynamic WHERE is a code-execution path, and
the tools around it carry an allowlist and a warning instead of a fix.
On a system the text is parsed as an ABAP condition and anything else is
`CX_SY_ITAB_DYN_LOOP`.

## Proposed change

Parse the condition with abaplint's expression parser (the runtime
already depends on `@abaplint/core` for the dynamic `SELECT … WHERE`
path, see `statements/select.ts`) into a small AST of `AND`/`OR`/`NOT`,
comparisons and `IN`, and evaluate that against the row with the
existing `compare/*` functions. A text that does not parse raises
`CX_SY_ITAB_DYN_LOOP`. The same for `DELETE … WHERE (cond)` and
`READ TABLE … WITH KEY (cond)` if they share the path.

## Test

The existing dynamic-WHERE tests, plus `(globalThis.x = 1)` expecting
`CX_SY_ITAB_DYN_LOOP` and `x` untouched.

## How to file

An issue against abaplint/transpiler; it is a security finding for every
host that evaluates foreign ABAP, so say so in the title.

