---
target: open-abap
title: 'transpiler: databaseSetup hands out the CREATE TABLE statements as one SQL string list - hosts regex the table name back out of it and rewrite it to IF NOT EXISTS'
summary: '`IDatabaseSetup.schemas.sqlite` is `string[]` of CREATE TABLE statements in no declared order and with no table name attached; the playground matches `/^CREATE TABLE ''([^'']+)''/` to attach DDL to `abap.DDIC`, and the MCP server scrapes the same lines out of the generated `init.mjs` and rewrites them to `CREATE TABLE IF NOT EXISTS` for a database that persists across runs'
priority: low
state: open
first_seen: 2026-10-22
upstream: abaplint/transpiler
evidence:
  - 'abap2UI5/playground `src/editor/transpile-core.mjs:241-265` (2026-10): regex `/^CREATE TABLE ''([^'']+)''/` over `output.databaseSetup.schemas.sqlite`, result stored per table in `abap.DDIC[NAME]`'
  - 'abap2UI5/mcp-server `lib/npm-backend.mjs:441-461` (`tableSchema`) scrapes `sqlite.push(`CREATE TABLE …`)` lines out of the generated `init.mjs`; `:497` rewrites them to `CREATE TABLE IF NOT EXISTS`'
  - 'read 2026-10-22 in abaplint/transpiler main 53a708f - `packages/transpiler/src/db/` builds the statements per table and `IDatabaseSetup` flattens them to `schemas.sqlite: string[]`'
checked_upstream: 2026-10-22
---

# transpiler: a per-table schema in `databaseSetup`

## The problem

`run( )` returns `databaseSetup.schemas.sqlite` (and `pg`, `hdb`, …) as a
flat `string[]` of `CREATE TABLE` statements and `insert` as another list.
The builder knows the table each statement belongs to; the consumer no
longer does. Two abap2UI5 hosts parse the SQL back: the playground to
attach DDL to `abap.DDIC`, the MCP server (out of the written `init.mjs`,
even) to turn it into `CREATE TABLE IF NOT EXISTS` for a database that
outlives one run.

## Proposed change

```ts
interface IDatabaseSetup {
  schemas: { sqlite: string[]; … };            // as today
  tables?: { name: string; type: "TABL"|"VIEW"; sqlite: string; pg: string; … }[];
  insert: string[];
  inserts?: { table: string; sql: string }[];
}
```

plus an option `databaseSetup: { ifNotExists?: boolean }` so the DDL can
be re-run against an existing file. The CLI writes `tables` as
`output/schema.json` when asked (it already writes `init.mjs`).

## How to file

An issue against abaplint/transpiler with the two regexes as the case.

