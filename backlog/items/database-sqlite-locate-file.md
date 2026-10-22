---
target: open-abap
title: 'database-sqlite: connect( ) calls initSqlJs( ) without arguments - a browser host cannot tell sql.js where its .wasm is, and subclasses the client for that one line'
summary: '`SQLiteDatabaseClient.connect( )` does `await initSqlJs()`; emscripten then guesses the wasm URL from the page location, which is wrong as soon as the page is not at the site root, so the playground subclasses the client to pass `locateFile` - an optional `sqlJs` config in the constructor is the request'
priority: low
state: open
first_seen: 2026-10-22
upstream: abaplint/transpiler
evidence:
  - 'abap2UI5/playground `src/runtime/db-setup.mjs:15-31` (2026-10): ''leaves sql.js to guess where its .wasm file is - and emscripten''s guess is wrong as soon as the page is not at the site root … so the client is subclassed for that one line'' (`BrowserSQLiteClient`); the web build ships `sql-wasm-browser.wasm` with a `locateFile` of its own'
  - 'read 2026-10-22 in abaplint/transpiler main 53a708f - `packages/database-sqlite/src/index.ts:12-17`: the constructor takes `{trace}` only and `connect( )` calls `initSqlJs()` with no config'
  - 'prepared 2026-10-22 as `oblomov-dev/fork-transpiler` branch `feat/sqlite-sqljs-config` (a642e23) on abaplint/transpiler main 53a708f: the change plus tests, green in the package suites and the transpiler''s integration tests; the fourteen prepared branches merged together transpile open-abap-core main 239b817 and pass its whole unit suite (1172 tests).'
checked_upstream: 2026-10-22
---

# database-sqlite: pass a sql.js config through

## The problem

`new SQLiteDatabaseClient({trace})` → `connect( )` → `initSqlJs()`. In a
browser, sql.js resolves `sql-wasm.wasm` relative to the page unless a
`locateFile` (or `wasmBinary`) is given; a page served below the root
gets a 404 and a dead database. The playground subclasses the client to
override `connect( )`.

## Proposed change

```ts
new SQLiteDatabaseClient({ trace, sqlJs: { locateFile: f => "/assets/" + f } })
```

forwarded as `initSqlJs(options.sqlJs)`. Same for `wasmBinary`. Two lines
and a type.

## How to file

A PR against abaplint/transpiler, `packages/database-sqlite`.

