---
target: open-abap
title: 'transpiler: an option that refuses WRITE ''@KERNEL …'' outside allow-listed objects - today any ABAP file can emit raw JavaScript into the host'
summary: 'a character literal starting with `@KERNEL ` is emitted verbatim as JavaScript, which is how open-abap-core reaches Node; the same door is open to every object the transpiler sees, so a host that compiles foreign ABAP (the MCP server, the playground) must scan the source itself and refuse - a transpiler option `kernel: { allow: ["open-abap-core"] }` (by lib or by object name pattern) would make the refusal a compile error'
priority: low
state: filed
filed: https://github.com/abaplint/transpiler/pull/2034
first_seen: 2026-10-22
upstream: abaplint/transpiler
evidence:
  - 'abap2UI5/mcp-server `lib/migrate.mjs:93-105` and `:131-138` (2026-10): migrated reports that contain `@KERNEL` are refused; `lib/runtime.mjs:2085-2095` and `:2122-2136` give child processes an environment allowlist because ''@KERNEL reaches process.env''; `CHANGELOG.md:616-657`; `SECURITY.md`'
  - 'abap2UI5/playground `src/runtime/lockdown.mjs:1-47` deletes `caches`, `indexedDB`, `Worker`, `SharedWorker` in the worker that runs user code, for the same reason'
  - 'read 2026-10-22 in abaplint/transpiler main 53a708f - `packages/transpiler/src/statements/write.ts` emits the literal after `@KERNEL ` as code with no option to restrict it'
  - 'prepared 2026-10-23 as `oblomov-dev/fork-transpiler` branch `feat/kernel-allowlist` (41e8631) on abaplint/transpiler main 3197186: option kernel.allow (regex list over object names, case-insensitive), a WRITE ''@KERNEL'' elsewhere is the validation issue kernel_not_allowed with file and row; option absent changes nothing; five tests, transpiler suite 413 green, CLI build and eslint clean'
  - 'filed 2026-10-23 as abaplint/transpiler#2034'
  - 'review 2026-10-28: larshp asked to add it in abaplint first. abaplint/abaplint#4499 adds the rule forbidden_kernel_write (allow: regex list over object names, empty = allow all) - merged 2026-10-28, not yet in a release on 2026-10-29 (latest @abaplint/core 2.120.90)'
  - 'abaplint/transpiler#2034 reworked 2026-10-28 (e51c401): kernel.allow switches the rule on in the validation config, an empty list maps to ["^$"] (allow none); the hand-written scan is gone. Marked in the PR to merge only after the @abaplint/core release; it then needs the core version bump. Suite 416 green against core built from abaplint main'
checked_upstream: 2026-10-29
---

# transpiler: an allowlist for `@KERNEL`

## The problem

`WRITE '@KERNEL <js>'.` is the transpiler's foreign-function interface:
the text is emitted as JavaScript. open-abap-core needs it; the user's
class in a hosted editor must not have it, because it runs with the
host's privileges (`process.env`, the file system, the network). Two
abap2UI5 hosts scan ABAP source for the string before compiling and
lock down the worker; a scan of source text is not a security boundary
(the literal can be built, `'@KERN' && 'EL …'` is not, but a code
reviewer should not have to prove that).

## Proposed change

```ts
interface ITranspilerOptions {
  kernel?: { allow: (string | RegExp)[] };   // object names or lib names
}
```

Default: everything allowed (today's behaviour). When set, a `@KERNEL`
literal in an object outside the list is a validation error, reported
like any other issue - by the abaplint rule `forbidden_kernel_write`
(abaplint/abaplint#4499), which the transpiler switches on in its
validation config. The CLI exposes it in `abap_transpile.json`, defaulting to the
`libs` when the option is present without a list.

## How to file

An issue against abaplint/transpiler; mark it as a hardening request.

