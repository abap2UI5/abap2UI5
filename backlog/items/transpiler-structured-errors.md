---
target: open-abap
title: 'transpiler: validation failures are thrown as one Error whose message is every issue joined by newline - a host that wants file, line and text per issue parses the string with a regex'
summary: '`run( )` collects abaplint issues and throws `new Error(messages.join("\n"))`; the playground splits the message and matches `/^(.*), file:\/\/\/([^:]+):(\d+)$/` to get its editor markers back, which breaks with the next change of the text format'
priority: low
state: open
first_seen: 2026-10-22
upstream: abaplint/transpiler
evidence:
  - 'abap2UI5/playground `src/editor/transpile-core.mjs:287-300` (2026-10): the thrown message is split on newline and matched with `/^(.*), file:\/\/\/([^:]+):(\d+)$/` to produce editor markers'
  - 'read 2026-10-22 in abaplint/transpiler main 53a708f - `packages/transpiler/src/index.ts:125`: `throw new Error(messages.join("\n"))`; the `abaplint.Issue` objects that produced the messages are dropped there'
  - 'prepared 2026-10-22 as `oblomov-dev/fork-transpiler` branch `feat/validation-error-issues` (81f3973) on abaplint/transpiler main 53a708f: the change plus tests, green in the package suites and the transpiler''s integration tests; the fourteen prepared branches merged together transpile open-abap-core main 239b817 and pass its whole unit suite (1172 tests).'
checked_upstream: 2026-10-22
---

# transpiler: throw the issues, not their text

## The problem

`Transpiler.run( )` validates the registry and, on failure, throws
`new Error(messages.join("\n"))` (`packages/transpiler/src/index.ts:125`).
Each message is already formatted (`text, file:///name:line`). A host that
shows the errors in an editor has to parse that back - the abap2UI5
playground does, with a regex, which is a contract on a string nobody
declared stable.

## Proposed change

```ts
export class TranspilerValidationError extends Error {
  public readonly issues: readonly abaplint.Issue[];
}
```

thrown from the same place with the same `message` (so nothing that reads
the text breaks), carrying the `Issue` list the message was built from.
`Issue` has filename, start/end position, key and severity.

## Test

One test in `test/` that transpiles an object with a syntax error and
expects `e instanceof TranspilerValidationError && e.issues.length === 1`.

## How to file

A small PR against abaplint/transpiler.

