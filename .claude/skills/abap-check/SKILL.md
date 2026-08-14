---
name: abap-check
description: The catalogue of ABAP problems a green CI does not catch - abapGit round-trip diffs (BOM, line endings, EOF newline, metadata sidecars), activation errors abaplint does not model (class_constructor visibility, LOCAL FRIENDS), extended-check (SLIN/ATC) traps, and runtime breakage that only shows on a real system. Use before finishing any change under src/, after editing a .clas.xml or .intf.xml, when a pull into a system produced unexpected diffs or an activation error - and add the case here whenever a new one is found.
---

# What a green CI does not prove

> **Scope.** This skill is about ABAP that has to survive a real SAP system —
> it applies to framework code and to app code alike, and most of it applies to
> any repository shipped through abapGit. The *other* skill, `build-an-app`,
> is about writing an app **with** abap2UI5: the app class, the lifecycle, the
> view builder, binding, events. They compose — build with `build-an-app`,
> check with this one before you finish. The commands quoted below are this
> repository's; the rules behind them are not.

`npm run verify` proves the code parses, lints and runs under the transpiler.
Everything in this file is a way for that to be true while a real SAP system
still refuses the change — because the files come back different, because the
class pool does not activate, because the extended check fires, or because the
runtime behaves differently there than under the transpiler.

**This is a growing catalogue.** Every entry is a defect that actually reached
`main` and was found by hand afterwards. When you hit a new one, add it (see
the last section) — the point is that nobody has to discover it twice.

Run first, in this order:

```
npm run check           # abaplint (fast inner loop)
npm run check:abapgit   # the abapGit round trip - covers src/00 and src/99 too
npm run check_visibility
npm run verify          # before any PR; includes all of the above
```

## Why the tooling here is blind to most of this

Three separate holes, worth knowing precisely:

- **abaplint parses ABAP, it does not model abapGit's file format.** The
  sidecar is only read for the few facts its rules name. Verified against
  abaplint 2.120: a `.clas.xml` with the BOM stripped, the terminating newline
  removed **and** CRLF line endings throughout produces **zero** findings.
- **abaplint's `global.files` is not all of `src/`.** It covers `src/00`
  (with `noIssues`), `src/01` and `src/02` — `src/99` is never read at all.
- **The transpiler ignores visibility.** Every ABAP member becomes a plain JS
  property, so `npm run unit` stays green on a class pool a real system rejects
  with a syntax error.

---

## 1. abapGit round trip — the file must come back byte-identical

Gated by `npm run check:abapgit`
(`.github/scripts/abapgit-format-gate.mjs`), over all of `src/`.

abapGit writes every file one specific way. Write it another way and it
differs from what the system serializes back — permanently, on every pull, for
everyone.

| Rule | What abapGit does | Where it bit us |
|---|---|---|
| `bom` | `.xml` starts with the UTF-8 BOM `EF BB BF`; `.abap` never does | `8e272492`, `54bce5b6` — both titled "fix abapgit diffs", both a `.clas.xml` written without the BOM |
| `eof` | exactly one terminating `\n`, no blank line after it | `c7185c38` — `z2ui5_if_action.intf.xml` ended with `\ No newline at end of file` |
| `crlf` | LF only, everywhere | `.gitattributes` used to normalize this and was deleted in `b62ea07`; the gate is what enforces it now |
| `tab` | no tabs — the ABAP editor expands them, so the pulled source is not this file | — |
| `filename` | lower case; abapGit derives the object name from it | — |
| `sidecar` | every `*.clas.abap` / `*.intf.abap` has its `.xml`, and every `.xml` has its source. Metadata without source creates an empty object; source without metadata is not imported at all. The class-pool includes (`.testclasses`, `.locals_def`, `.locals_imp`, `.macros`) have no sidecar of their own | — |
| `package` | every folder under `src/` has a `package.devc.xml` — it *is* the package | — |
| `clsname` | `<CLSNAME>` equals the file name, upper-cased | — |
| `langu` | `<LANGU>` equals `<MASTER_LANGUAGE>` from `.abapgit.xml` (`E`). An object created while logged on in another language serializes with that language and diffs against every other developer | — |
| `unit-tests` | `<WITH_UNIT_TESTS>X</WITH_UNIT_TESTS>` exactly when a `.testclasses.abap` exists | — |

Two round-trip rules no gate can decide:

- **Never hand-edit a `.clas.xml` / `.intf.xml` to tidy it.** It is a
  serialization, not a config file. Element order, indentation and which
  optional elements are present all come from the serializer; "cleaning it up"
  creates exactly the diff this section exists to prevent. If a sidecar looks
  wrong, fix the object in a system and commit what abapGit writes.
- **`<DESCRIPTIONS>` follows the components.** A class whose methods and
  attributes carry short texts in the system serializes them as `<SEOCOMPOTX>`
  entries. `b088c8a` ("fix xml") had to add 2 272 lines of them to
  `z2ui5_cl_xml_view.clas.xml` in one go, because the block had been missing
  while the class kept growing. Add a component to a class whose sidecar has a
  `DESCRIPTIONS` block and the block is now incomplete; delete one and its
  entry is stale. The gate cannot know which components have a description in
  the system — you have to look.

Deliberately **not** gated: trailing whitespace. abaplint's `whitespace_end`
owns it for `src/01` and `src/02`, and the historical blanks in mirrored
`src/00` and frozen `src/99` are not ours to fix.

## 2. Activation — compiles here, syntax error there

| Trap | Rule |
|---|---|
| **`class_constructor` must be in the PUBLIC SECTION** | ABAP requires it; the class pool does not activate otherwise. abaplint's `constructor_visibility_public` only looks at the instance `constructor` — verified: a `CLASS-METHODS class_constructor.` in a `PRIVATE SECTION` produces no finding. This is why `z2ui5_cl_ui5_frontend` fills `ct_box_type` lazily in `box_resolve( )` instead of in a static constructor (#2547) — see the comment on the attribute. Gated by `check:abapgit` |
| **A test class touching PRIVATE/PROTECTED members needs `CLASS <global> DEFINITION LOCAL FRIENDS <ltcl>.`** | Same failure mode. `ltcl_rtti` reached `main` without it and had to be repaired (`cadfb7ae`). Gated by `npm run check_visibility` |

## 3. Extended check (SLIN/ATC) — runs in real systems, not here

A green `npm run check` does not prove their absence. The full list with the
case that produced each one lives in `AGENTS.md`, "Extended-check (SLIN/ATC)
pitfalls"; the short form:

- **POSIX regex is deprecated.** `FIND/REPLACE ... REGEX` is POSIX; `FIND PCRE`
  only exists on >= 7.55 and this repo targets v750/7.02. Prefer plain string
  logic; when a regex is genuinely needed, add `##REGEX_POSIX` to the statement
  (the vendored AJSON code does the same).
- **No redundant conversions.** Do not wrap a value in `CONV string( ... )`
  when the source already has the target type.
- **`"!` position.** A doc comment sits directly before the one declaration it
  documents — *inside* a chained statement, not before the chain keyword — and
  **never inside a parameter list**. Document parameters with
  `"! @parameter <name> | <text>` in the method's own block.
- **ABAP Doc is parsed as HTML.** A literal `<`, `>` or `&` must be escaped as
  `&lt;`, `&gt;`, `&amp;`.

## 4. Runtime — green here, wrong there

- **An object name inside a string literal is not a reference — a rename sweep
  will get it wrong and nothing will notice.** `#2564` renamed `z2ui5_cl_exit`
  to `z2ui5_cl_ui5_user_exit` and carried the rename into the *interface*
  literal of `get_user_exit_class`, which became `Z2UI5_IF_USER_EXIT` — an
  interface that does not exist; the shipped one is `Z2UI5_IF_EXIT`. From that
  commit on, no user exit was found in any system: no configured UI5 bootstrap,
  no theme, no CSP override, no error. Everything stayed green, because the
  lookups behind such literals read SEOCLASS/XCO — neither exists under
  `npm run unit`, so "names nothing" and "customer implemented nothing" produce
  the same empty table. Found by a user whose config class had stopped working.
  Gated by `npm run check:dynamic`
  (`.github/scripts/dynamic-name-gate.mjs`): every `Z2UI5_*` name in a string
  literal must exist under `src/`, with names owned by other repositories listed
  in `EXTERNAL` with their reason. **After any rename, reread the string
  literals** — and when adding a dynamic lookup for something outside this
  repository, put it in `EXTERNAL` rather than silencing the gate.
- **Never "modernize" `WITH DEFAULT KEY` to `WITH EMPTY KEY` on a table passed
  to a classic function module.** The key is part of the table type; an
  incompatible one makes `CALL FUNCTION` fail at runtime, silently when it sits
  inside a `TRY … CATCH` / `EXCEPTIONS` guard. Concrete case and the reason it
  must stay: the comment above `lt_impl` in
  `z2ui5_cl_ui5_context=>rtti_get_classes_intf_std`, which passes the table to
  `SEO_INTERFACE_IMPLEM_GET_ALL` — with `EMPTY KEY` it returns no implementers
  and user-exit discovery breaks without an error.
- **Three environments, one source.** Code must work on NW 7.02, standard ABAP
  and ABAP Cloud (`check:standard`, `check:cloud`, `downport`). A statement
  that only exists in a newer release passes the default target and fails the
  others.
- **`app/webapp/` source must be 7-bit ASCII** — every frontend file is
  embedded verbatim into an ABAP class under `src/01/03/`, where abaplint's
  `7bit_ascii` rule applies. Build non-ASCII runtime strings at run time, never
  as a literal.

## 5. Test blind spots — green for the wrong reason

- **Never skip a test with `IF sy-sysid = ` + backtick-`ABC`.** `ABC` is the
  system ID of the Node runtime, so the guard makes the method a silent no-op
  in `npm run unit` while it still runs in a real system — CI stays green over
  assertions nobody executes. A test that genuinely cannot run under the
  transpiler belongs in the `skip` list of `node/setup/abap_transpile.json`
  **with a note naming the missing runtime capability**; the runner then prints
  it as skipped instead of pretending it passed. (The remaining `sy-sysid`
  guards are all in the frozen `src/99` — they are history, not precedent.)
- **`src/01/03/` is generated.** Never hand-edit it; run `npm run app2abap`.
  A manual fix there is reverted by the next generation and `check:app2abap`
  fails the PR.

---

## When a pull does show diffs

Take the system's side. Commit the files exactly as abapGit serialized them,
then run `npm run check:abapgit` on the result — whatever it now flags is the
rule that was broken, and the fix belongs in this repository rather than in the
system.

## Adding a new case

Keep the catalogue worth reading: one entry, one defect that actually happened.

1. **Put it in the right section** — 1 round trip, 2 activation, 3 extended
   check, 4 runtime, 5 test blind spots. A new kind of failure gets a new
   section.
2. **Name the evidence** — the commit, PR or file where it bit us. An entry
   without a case is a rule somebody will delete as speculation.
3. **Say why the tooling missed it.** If the answer is "it did not, we just
   ignored it", the entry belongs in a lint config, not here.
4. **Gate it if a script can decide it.** Add the rule to
   `.github/scripts/abapgit-format-gate.mjs` (byte format, metadata, source
   text) so the next occurrence fails a PR instead of a pull, and keep the
   prose entry as the reasoning. Test the rule both ways — inject the defect,
   see it fire, confirm the tree is clean again.
