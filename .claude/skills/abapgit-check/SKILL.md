---
name: abapgit-check
description: Check that changed abapGit files survive a pull into a real SAP system - the byte format of .clas.xml / .intf.xml / .abap sidecars (BOM, line endings, EOF newline), the metadata that must match the source, and the activation rules abaplint does not model (class_constructor visibility, LOCAL FRIENDS). Use after adding, renaming, moving or deleting any object under src/, after editing a .clas.xml or .intf.xml by hand, and before finishing any change that touches ABAP files - especially when an AI wrote them.
---

# Does this change come back unchanged from a real system?

`npm run verify` proves the code parses, lints and runs under the transpiler.
It does **not** prove the repository still round-trips through abapGit. Those
are different questions, and the second one only gets answered when somebody
pulls the repository into an SAP system — which is far too late.

Run the gate first, then read the part below it that the gate cannot decide:

```
npm run check:abapgit          # node .github/scripts/abapgit-format-gate.mjs
```

It covers all of `src/` — including `src/00` (`noIssues` in abaplint) and
`src/99` (outside abaplint's `global.files` entirely), which no other check in
this repository looks at byte for byte.

## Why abaplint does not catch this

abaplint parses ABAP. It has no model of abapGit's file format, so the sidecar
is only ever read for the few facts its rules name (`xml_consistency` compares
`<CLSNAME>`, `local_testclass_consistency` compares `<WITH_UNIT_TESTS>`) — the
bytes around them are invisible. Verified against abaplint 2.120: a
`.clas.xml` with the BOM stripped, the final newline removed **and** CRLF line
endings throughout produces **zero** findings.

The transpiler is worse: it ignores visibility altogether (every ABAP member
becomes a plain JS property), so `npm run unit` stays green on a class pool
that a real system rejects with a syntax error.

## What the gate checks, and the commit each rule comes from

**Byte format.** abapGit writes every file one specific way. Write it another
way and the file differs from what the system serializes back — permanently,
on every pull, for everyone.

| Rule | What abapGit does | Where it bit us |
|---|---|---|
| `bom` | `.xml` starts with the UTF-8 BOM `EF BB BF`; `.abap` never does | `8e272492`, `54bce5b6` — both titled "fix abapgit diffs", both a `.clas.xml` written without the BOM |
| `eof` | exactly one terminating `\n`, no blank line after it | `c7185c38` — `z2ui5_if_action.intf.xml` ended with `\ No newline at end of file` |
| `crlf` | LF only, everywhere | `.gitattributes` used to normalize this and was deleted in `b62ea07`; nothing enforces it now |
| `tab` | no tabs — the ABAP editor expands them, so the pulled source is not this file | — |
| `filename` | lower case; abapGit derives the object name from it | — |

**Structure.** A source file and its metadata sidecar are one object.

| Rule | Requirement |
|---|---|
| `sidecar` | every `*.clas.abap` / `*.intf.abap` has its `.xml`, and every `.xml` has its source. Metadata without source creates an empty object; source without metadata is not imported at all. The class-pool includes (`.testclasses`, `.locals_def`, `.locals_imp`, `.macros`) have no sidecar of their own |
| `package` | every folder under `src/` has a `package.devc.xml` — it *is* the package |
| `clsname` | `<CLSNAME>` equals the file name, upper-cased |
| `langu` | `<LANGU>` equals `<MASTER_LANGUAGE>` from `.abapgit.xml` (`E`). An object created while logged on in another language serializes with that language and diffs against every other developer |
| `unit-tests` | `<WITH_UNIT_TESTS>X</WITH_UNIT_TESTS>` exactly when a `.testclasses.abap` exists |

**Activation.**

| Rule | Requirement |
|---|---|
| `class-constructor` | `class_constructor` must be declared in the **PUBLIC SECTION**. ABAP requires it; the class pool does not activate otherwise. abaplint's `constructor_visibility_public` only looks at the instance `constructor` — verified: a `CLASS-METHODS class_constructor.` in a `PRIVATE SECTION` produces no abaplint finding. This is why `z2ui5_cl_ui5_frontend` fills `ct_box_type` lazily in `box_resolve( )` instead of in a static constructor (#2547) — see the comment on the attribute |

## What the gate cannot decide — check these by reading

The gate judges bytes and names. These need a reader:

- **Never hand-edit a `.clas.xml` to make it look tidier.** It is a
  serialization, not a config file. Element order, indentation and which
  optional elements are present all come from the serializer; "cleaning it up"
  creates exactly the diff this skill exists to prevent. If a sidecar looks
  wrong, fix the object in a system and commit what abapGit writes.

- **`<DESCRIPTIONS>` follows the components.** A class whose methods and
  attributes carry short texts in the system serializes them as `<SEOCOMPOTX>`
  entries in the sidecar. `b088c8a` ("fix xml") had to add 2 272 lines of them
  to `z2ui5_cl_xml_view.clas.xml` in one go, because the block had been missing
  while the class kept growing. When you add a component to a class whose
  sidecar has a `DESCRIPTIONS` block, the block is now incomplete — and when
  you *delete* one, its entry is stale. The gate cannot know which components
  have a description in the system; you have to look.

- **A test class touching PRIVATE/PROTECTED members needs
  `CLASS <global> DEFINITION LOCAL FRIENDS <ltcl>.`** Same failure mode as the
  static constructor — compiles here, syntax error on activation. This one
  *is* gated, separately: `npm run check_visibility`.

- **Extended check (SLIN/ATC) runs in real systems and not here.** POSIX regex,
  redundant `CONV`, `"!` doc-comment placement, unescaped `<`/`>`/`&` in ABAP
  Doc. The full list with the case that produced each one is in `AGENTS.md`,
  "Extended-check (SLIN/ATC) pitfalls".

- **`src/01/03/` is generated.** Never hand-edit it; run `npm run app2abap`.
  A manual fix there is reverted by the next generation, and `check:app2abap`
  fails the PR.

## When a pull does show diffs

Take the system's side. Commit the files exactly as abapGit serialized them,
then run `npm run check:abapgit` on the result — whatever it now flags is the
rule that was broken, and the fix belongs in this repository rather than in the
system. If the diff is in something the gate does not model, add the rule to
`.github/scripts/abapgit-format-gate.mjs` so the next one fails a PR instead of
a pull.
