---
target: open-abap
title: 'transpiler: databaseSetup hands out the CREATE TABLE statements as one SQL string list - hosts regex the table name back out of it and rewrite it to IF NOT EXISTS'
summary: '`IDatabaseSetup.schemas.sqlite` is `string[]` of CREATE TABLE statements with no table name attached; the MCP server scrapes them out of the generated `init.mjs` and rewrites them to `CREATE TABLE IF NOT EXISTS` for a database that persists across runs (the playground no longer needs the names, abap2UI5/playground#154)'
priority: low
state: deferred
filed: https://github.com/abaplint/transpiler/pull/2033
first_seen: 2026-10-22
upstream: abaplint/transpiler
evidence:
  - 'abap2UI5/playground `src/editor/transpile-core.mjs:241-265` (2026-10): regex `/^CREATE TABLE ''([^'']+)''/` over `output.databaseSetup.schemas.sqlite`, result stored per table in `abap.DDIC[NAME]`'
  - 'abap2UI5/mcp-server `lib/npm-backend.mjs:441-461` (`tableSchema`) scrapes `sqlite.push(`CREATE TABLE …`)` lines out of the generated `init.mjs`; `:497` rewrites them to `CREATE TABLE IF NOT EXISTS`'
  - 'read 2026-10-22 in abaplint/transpiler main 53a708f - `packages/transpiler/src/db/` builds the statements per table and `IDatabaseSetup` flattens them to `schemas.sqlite: string[]`'
  - 'prepared 2026-10-23 as `oblomov-dev/fork-transpiler` branch `feat/database-setup-tables` (40f2e2a) on abaplint/transpiler main 3197186: databaseSetup.tables and .inserts, option databaseSetup.ifNotExists (sqlite tables and views, pg and snowflake tables; hdb and pg views unchanged), CLI write_schema writes schema.json; transpiler suite 411 green, eslint clean. Note: the CLI package compiles against the published transpiler, so its build needs the transpiler release or link-local, as CI does'
  - 'filed 2026-10-23 as abaplint/transpiler#2033'
  - 'review 2026-10-28: larshp asked for the root cause (https://github.com/abaplint/transpiler/pull/2033#issuecomment-6466364141). Answered: the per-table pairing was a playground design choice, not a need - the playground can run the whole list and take the names from its TABL objects; the MCP server can ignore "already exists". Offered to cut the PR to the ifNotExists option or close it; conflicts with main resolved (54646a9). No answer yet on 2026-10-29'
  - 'abap2UI5/playground#154 (merged 2026-10-28) removed the playground''s regex: the set''s CREATE TABLEs run as one list, the names come from the TABL objects. What remains is only the MCP server''s IF NOT EXISTS rewrite'
  - 'closed 2026-10-29: abaplint/transpiler#2033 closed after a conversation with the maintainer - a database that outlives one run is to be migrated with sqlite-schema-diff (https://mizuchi.dev/projects/sqlite-schema-diff/, github.com/mizuchilabs/sqlite-schema-diff: diffs a SQLite database against .sql files and applies CREATE / ALTER ADD COLUMN / table recreation with a backup, in one transaction), not with IF NOT EXISTS; the per-table result has no consumer since abap2UI5/playground#154. https://github.com/abaplint/transpiler/pull/2033#issuecomment-6503890106'
checked_upstream: 2026-10-29
---

## Deferred (2026-10-29)

abaplint/transpiler#2033 is closed. The maintainer's direction for a database
that outlives one run is [sqlite-schema-diff](https://mizuchi.dev/projects/sqlite-schema-diff/):
it diffs the database against the schema as `.sql` files and migrates it,
which also covers a table whose definition changed - `IF NOT EXISTS` would
leave such a table as it was. The per-table result lost its consumer with
abap2UI5/playground#154. What could still be asked of the transpiler is the
schema written out as a `.sql` file for that tool to read; caveat: the tool
is Go (CLI or library), no npm package, nothing for the browser - the MCP
server would ship or call the binary.


# transpiler: a per-table schema in `databaseSetup`

## The problem

`run( )` returns `databaseSetup.schemas.sqlite` (and `pg`, `hdb`, …) as a
flat `string[]` of `CREATE TABLE` statements and `insert` as another list.
The builder knows the table each statement belongs to; the consumer no
longer does. The MCP server parses the SQL back (out of the written
`init.mjs`, even) to turn it into `CREATE TABLE IF NOT EXISTS` for a
database that outlives one run. The playground used to parse it too, to
attach DDL to `abap.DDIC`; it no longer needs the names
(abap2UI5/playground#154), so the per-table result is the weaker half of
this item and `ifNotExists` the part with a case.

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

