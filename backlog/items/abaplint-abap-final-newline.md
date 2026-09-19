---
target: abaplint
title: 'Report a source file that does not end with exactly one newline'
summary: 'abapGit serializes every file with one terminating newline; a file written without it shows `\ No newline at end of file` in every diff and comes back changed on the next pull — the round-trip family has `xml_bom`, `7bit_ascii` and `whitespace_end` upstream and nothing for the file end'
priority: low
state: open
first_seen: 2026-09-19
upstream: abaplint/abaplint
evidence:
  - abap2UI5 `c7185c38` — an interface sidecar ended with `\ No newline at end of file` and diffed on every pull until fixed; abap-check §1 carries the `eof` row of the abapGit round-trip family, gated in abap2UI5 by `npm run check:abapgit` (a repository script)
  - the abap2UI5-linter carries it since 2026-09 (`missing-final-newline`, with a fix) — for the files it collects, which are app classes
  - measured 2026-09-19 on abaplint 2.120.52 with every rule on — a `.clas.abap` with no terminating newline produces no finding; `whitespace_end` reports trailing blanks on a line, `line_break_style` the CR, `7bit_ascii` the BOM, and no rule looks at the last byte
---

# Report a source file that does not end with exactly one newline

## What happens

abapGit writes every file one specific way — LF only, no BOM on `.abap`, no
trailing blanks, exactly one terminating newline. A file committed without
the final newline (an editor default, a generator writing `join('\n')`) is
re-serialized differently by abapGit on the next pull, for everyone, forever:
the diff never settles.

## Why no existing rule catches it

The round-trip family is covered piecemeal: `xml_bom` (the sidecar BOM),
`7bit_ascii` (which happens to catch a BOM on an `.abap`), `whitespace_end`
(trailing blanks per line), `line_break_style` (CRLF). The last byte of the
file is nobody's.

## Proposed rule

A file-level rule — `final_newline`, beside `whitespace_end` — reporting a
file whose content does not end with exactly one `\n` (missing, or more than
one: abapGit writes no blank line after the last statement either). Quick
fix: append the newline / trim the extra ones. Applies to `.abap` and the
XML sidecars alike, since abapGit serializes both.

## What it must NOT report

- an empty file;
- anything that is not part of an abapGit-serialized object (the rule
  belongs to the file set abaplint already reads).

## Example

```text
" bad:  … ENDCLASS.<EOF>
" good: … ENDCLASS.\n<EOF>
```

<!-- probe:start — written by `npm run backlog:probe`, do not edit by hand -->

## Measured

`abaplint-abap-final-newline.probe.mjs` — a file not ending with exactly one newline, with the correctly terminated files counted per repository.
Run **2026-09-19** against `abap2UI5` (not checked out: samples, samples-controls, samples-stack).

**Would fire on 0 site(s)** in 0 repositories:

_none_

**Must NOT fire on 1 site(s)** that match the shape and are correct:

| Repository | Where | |
|---|---|---|
| abap2UI5 | `(all .abap files)` | 200 files end with exactly one newline |

**Where the detector is an approximation of the rule:**

- Only .abap files are read; the XML sidecars the rule would cover too are out of this scan's reach.
- Repositories gated by abapgit-format-gate.mjs answer 0 by construction - the number says the gate works, not that the rule is unneeded elsewhere.

<!-- probe:end -->
