---
target: abaplint
title: 'New rule: a statement longer than the 28 kilobytes a system accepts'
summary: 'one view-builder chain of about 40,000 characters failed to import on a 7.40 system ("The length of the current statement is greater than the allowed maximum length of 28 kilobytes") - CI green, the repository now measures it with a script of its own'
priority: medium
state: filed
filed: https://github.com/abaplint/abaplint/pull/4815
first_seen: 2026-11-27
checked_upstream: 2026-11-27
upstream: abaplint/abaplint
evidence:
  - 'abap2UI5/samples-controls 91b4497, 2026-11-25: the 702 branch did not import on a 7.40 system, a sample was one chained statement of about 40,000 characters; scripts/check-statement-size-702.mjs was added with a budget of 28,000 condensed characters'
  - 'measured there: a statement of 40,261 condensed characters failed, one of 20,433 passed; by raw characters a statement of 53,273 failed while one of 42,483 - mostly indentation - passed in the same pull, so only the condensed size separates them'
  - 'abaplint rules folder 2026-11-27: line_length and method_length are the closest, nothing measures a statement'
  - 'upstream search 2026-11-27 (open issues and pull requests of abaplint/abaplint): nothing on it; filed the same day as abaplint/abaplint#4815 - the rule statement_length with maxLength 28000, measured on the condensed statement in characters; whether the kernel counts characters or bytes, and a chain as a whole or per part, is still not known'
---

# New rule: a statement longer than the system accepts

```abap
view->page( ... )->text( `... 800 characters ...` )->text( `...` ) ... .
```

A statement has a maximum length - the message of the system names 28
kilobytes. A long method chain with literals reaches it, and nothing in a
file-based check says so: the file is valid ABAP, the import fails.

## Proposal

A rule `statement_length` with an option `maxLength` that reports a
statement whose **condensed** length exceeds it - comments dropped,
whitespace outside literals reduced to one blank.

## Must not report

By raw characters: indentation does not count for the system, and a rule
that counts it reports statements that import fine. Macro definitions.

## Open

The exact measure of the kernel is not known to us - 28,672 bytes is the
figure of the message, the two measured points are 20,433 (passed) and
40,261 (failed). The default should stay below the documented figure.
