---
name: abap-check
description: The catalogue of ABAP problems a green CI does not catch - abapGit round-trip and import failures (BOM, line endings, EOF newline, 255-character lines, metadata sidecars for CLAS and for DDLS/BDEF/TABL), activation errors abaplint does not model (class_constructor visibility, LOCAL FRIENDS, generic types on older releases, RAP and CDS), extended-check (SLIN/ATC) traps, downport and transpiler traps, and runtime breakage that only shows on a real system. Use before finishing any change under src/, after editing a .clas.xml or any other metadata sidecar, when a pull into a system produced unexpected diffs, an import error or an activation error - and add the case here whenever a new one is found.
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
object does not even import, because the class pool does not activate, because
the extended check fires, or because the runtime behaves differently there than
under the transpiler.

**This is a growing catalogue.** Every entry is a defect that actually reached
`main` and was found by hand afterwards — several of them by a user, after a
pull. When you hit a new one, add it (see the last section) — the point is that
nobody has to discover it twice.

Run first, in this order:

```
npm run check           # abaplint (fast inner loop)
npm run check:abapgit   # the abapGit round trip - covers src/00 and src/99 too
npm run check:atc       # the extended-check traps a script can decide
npm run check_visibility
npm run verify          # before any PR; includes all of the above
```

## Why the tooling here is blind to most of this

Four separate holes, worth knowing precisely:

- **abaplint parses ABAP, it does not model abapGit's file format.** The
  sidecar is only read for the few facts its rules name. Verified against
  abaplint 2.120: a `.clas.xml` with the BOM stripped, the terminating newline
  removed **and** CRLF line endings throughout produces **zero** findings.
- **abaplint's `global.files` is not all of `src/`.** It covers `src/00`
  (with `noIssues`), `src/01` and `src/02` — `src/99` is never read at all.
- **The transpiler ignores visibility.** Every ABAP member becomes a plain JS
  property, so `npm run unit` stays green on a class pool a real system rejects
  with a syntax error.
- **Every check here runs against one release.** abaplint's default target is
  v750 and the transpiler is a JS runtime. Neither is 7.02, neither is a 7.40
  or low-SP 7.50 system, and neither is ABAP Cloud — and a good half of this
  catalogue is code that is valid on one of those and rejected by another.

---

## 1. abapGit round trip — the file must come back byte-identical

Gated by `npm run check:abapgit`
(`.github/scripts/abapgit-format-gate.mjs`), over all of `src/`.

abapGit writes every file one specific way. Write it another way and it
differs from what the system serializes back — permanently, on every pull, for
everyone.

| Rule | What abapGit does | Where it bit us |
|---|---|---|
| `bom` | `.xml` starts with the UTF-8 BOM `EF BB BF`; `.abap` never does | `8e272492`, `54bce5b6` — both titled "fix abapgit diffs", both a `.clas.xml` written without the BOM. Again in `abap2UI5/samples` `bc1f3d2` across 15 sidecars at once |
| `eof` | exactly one terminating `\n`, no blank line after it | `c7185c38` — `z2ui5_if_action.intf.xml` ended with `\ No newline at end of file` |
| `crlf` | LF only, everywhere | `.gitattributes` used to normalize this and was deleted in `b62ea07`; the gate is what enforces it now |
| `tab` | no tabs — the ABAP editor expands them, so the pulled source is not this file | — |
| `apos` | XML goes through the ABAP iXML renderer, which escapes the apostrophe as `&apos;` | `abap2UI5/samples` `702813e` "fix abapgit" — nine `.clas.xml` carried a raw `'` in `<DESCRIPT>` and came back changed on the next pull |
| `filename` | lower case; abapGit derives the object name from it | — |
| `sidecar` | every `*.clas.abap` / `*.intf.abap` has its `.xml`, and every `.xml` has its source. Metadata without source creates an empty object; source without metadata is not imported at all. The class-pool includes (`.testclasses`, `.locals_def`, `.locals_imp`, `.macros`) have no sidecar of their own | — |
| `package` | every folder under `src/` has a `package.devc.xml` — it *is* the package | — |
| `clsname` | `<CLSNAME>` equals the file name, upper-cased | — |
| `langu` | `<LANGU>` equals `<MASTER_LANGUAGE>` from `.abapgit.xml` (`E`). An object created while logged on in another language serializes with that language and diffs against every other developer | — |
| `unit-tests` | `<WITH_UNIT_TESTS>X</WITH_UNIT_TESTS>` exactly when a `.testclasses.abap` exists | `d5eaaa79` "fix unit test metadata" — `z2ui5_cl_util_range` had the test include and not the flag |

### The size limits — where the *import* fails, not the diff

Both of these are ABAP limits, both were hit by generated code, and both fail
in the same nasty way: abapGit reports the error for that object and **carries
on**, so what stays behind in the system is an empty class stub. The tree looks
imported; the app is gone.

- **255 characters per source line.** Longer and the import dies with
  *"Literals across more than one line are not allowed"*.
  `abap2UI5/samples#669` (`8c8a04e`): a merged reorganization carried such
  lines, and it left `z2ui5_cl_demo_app_038` and `_378` as empty stubs and
  reverted a catalog class to an older state. Split long literals into `&&`
  chunks. Gated by `check:abapgit` (`linelen`); abaplint's `line_length` rule
  is off in this repository and would not cover `src/00` and `src/99` anyway.
  For scale: the longest line in `src/` today is 253.

  **Also gated outside this repository now**, which is what the samples case
  argues for: the abap2UI5 linter reports it as **`source-line-too-long`** (an
  error) on every app class it checks, so a consumer repo that runs nothing but
  `npx abap2ui5lint` is covered too. Note what that does *not* replace — the
  linter reads app classes and views, not `.clas.xml` sidecars or `src/00` and
  `src/99`, so `check:abapgit` remains this repository's gate for the rest of
  the round-trip family.
- **Maximum statement length.** A single `result = VALUE #( … )` with a few
  hundred rows exceeds it. `abap2UI5/samples-controls#38` (`ee28671`): the
  246-row catalog constructor of the overview app could not be imported at
  all. Split it — the second statement appends with `VALUE #( BASE result )`.
  No script decides this one; it is a character count over a whole statement
  and the threshold is not documented as a fixed number.

  The same PR carries the second lesson: the file was **generated**, the split
  was first made by hand, and the next `npm run overview` would have restored
  the over-length statement. **Fix the generator, then regenerate** — see
  section 6.

### Object types other than CLAS and INTF

**The metadata node name is the serializer's, and it is not guessable.** Each
abapGit serializer reads exactly one node, named after the internal structure
it fills. Write a plausible-looking node instead and it is silently *ignored* —
the object arrives with empty metadata and the import fails with a message that
usually points somewhere else:

- `abap2UI5/samples-stack` `92cb8a4` — the `.ddls.xml` files carried
  `<DD02BQ><STRUCOBJN>`; the DDLS serializer reads `<DDLS>` with `DDLNAME`,
  `DDLANGUAGE`, `DDTEXT` and `SOURCE_TYPE` (`W` for a CDS view entity). With
  the wrong node the name and description stayed empty and the import failed
  with *"Entity name and name of DDL source are not identical"* and
  *"Object description is missing"*.
- `abap2UI5/samples-stack` `0a0aba6` — the `.bdef.xml` files carried `<MAIN>`;
  the BDEF serializer reads `<BDEF>` (the `METADATA` substructure of
  `CL_BLUE_SOURCE_OBJECT_DATA=>TY_OBJECT_DATA`). Same silent-ignore, and
  because the behavior definitions share their names with the CDS entities the
  error *looked* like a DDLS problem. The follow-up *"Error updating where-used
  list for CLAS …"* was downstream: classes using EML cannot compile while the
  BDEF is missing.

**Rule: never hand-author a metadata sidecar for an object type you have not
exported from a real system.** Create the object once, let abapGit serialize
it, and commit that. This is the same rule as "never hand-edit a `.clas.xml`"
below, one step earlier.

### Two round-trip rules no gate can decide

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

### The class pool

| Trap | Rule |
|---|---|
| **`class_constructor` must be in the PUBLIC SECTION** | ABAP requires it; the class pool does not activate otherwise. abaplint's `constructor_visibility_public` only looks at the instance `constructor` — verified: a `CLASS-METHODS class_constructor.` in a `PRIVATE SECTION` produces no finding. This is why `z2ui5_cl_ui5_frontend` fills `ct_box_type` lazily in `box_resolve( )` instead of in a static constructor (#2547) — see the comment on the attribute. Gated by `check:abapgit` |
| **A test class touching PRIVATE/PROTECTED members needs `CLASS <global> DEFINITION LOCAL FRIENDS <ltcl>.`** | Same failure mode, and it reaches users: `ltcl_rtti` got to `main` without it and had to be repaired (`cadfb7ae`), and #2146 is a user reporting a shipped test class that calls the PROTECTED `request_json_to_abap`. The transpiler makes every member a plain JS property, so `npm run unit` is green on a class pool the system rejects. Gated by `npm run check_visibility` |

### Generic types on older releases — the recurring one

This class of defect has now bitten three times, twice reported by users after
a pull, and it is the single most likely thing to break a system that is not on
the newest release. abaplint's default target accepts all of it.

- **A generic `REF TO data` cannot be dereferenced inline.** `lr_ref->*` in an
  expression, and `ASSIGN COMPONENT … OF STRUCTURE mr_data->*`, both fail with
  *"A generic reference cannot be dereferenced (->) in the current statement"*.
  Reported on SAP_ABA 750 SP22 (#1922) and before that on another low release
  (#1856) — fixed in `a16e2465` (#1923) and `75bf5515` (#1857). **Assign it to
  a field symbol first**, then work on the field symbol:
  ```abap
  ASSIGN lr_ref->* TO FIELD-SYMBOL(<val>).
  ASSIGN COMPONENT lv_name OF STRUCTURE <val> TO FIELD-SYMBOL(<comp>).
  ```
- **The dynamic component selector needs a reference variable, not `TYPE any`.**
  `ASSIGN val->(lv_name) TO …` where `val` is `TYPE any` is rejected on NW 7.52
  and 7.02 with *"VAL is not a reference variable"* (#2409). Cast once —
  `DATA(lx) = CAST cx_root( val ).` — and address `lx->(lv_name)`.
- **`CORRESPONDING #( <generic> )` is not available.** Same commit
  (`a16e2465`): use `CLEAR` + `MOVE-CORRESPONDING`. abaplint's
  `prefer_corresponding` rule had to be switched off for the low-release config
  because it recommends the construct that does not compile there.

### RAP and CDS (`abap2UI5/samples-stack`)

The RAP objects activate, or do not, for reasons abaplint has no model of at
all — it cannot even parse some of the syntax (section 6).

- **A behavior pool needs `FOR BEHAVIOR OF`.** Without it the class is an
  ordinary `ABSTRACT FINAL` class that happens to contain a subclass of
  `cl_abap_behavior_handler`; it activates cleanly, RAP finds no handler, and
  **every** EML statement dumps on the first thing it asks for —
  `CX_RAP_HANDLER_NOT_IMPLEMENTED, Method: GLOBAL_AUTHORIZATION`, wrapped in
  `CX_SADL_DUMP_APPL_MODEL_ERROR`. The authorization check runs before every
  operation, which is why create, delete and data generation all failed
  identically while the apps themselves ran. `de43a84`.
- **`@Semantics.currencyCode: true` is DDIC-CDS only.** In a view entity it
  fails activation with *"Annotation Semantics.currencyCode is not allowed in
  view entities"*. A `CUKY` field derives the marker by itself, and the
  `@Semantics.amount.currencyCode` references are what establish the currency
  reference. `f07cba4`.
- **A draft table mirrors the CDS element names, not the persistent table's
  field names.** The BDEF `mapping` applies to the persistent table only, so
  the draft table is checked against the entity directly and every snake_case
  field is an error, starting with *"must have a key field 'TRAVELUUID' in
  position 2"*. `af1a928`. The draft-admin include additionally needs
  `<GROUPNAME>%ADMIN</GROUPNAME>` (`7459f39`).

### Do not depend on DDIC objects that are not everywhere

A sample that selects from `VBAK` compiles here — abaplint resolves it from the
API dependency — and is a **syntax error** in every system without SD.
`abap2UI5/abap2UI5#2286`, reported against the samples repository. Shipped
sample and framework code may only touch DDIC objects that exist in a bare
system, or must fetch data dynamically.

## 3. Extended check (SLIN/ATC) — runs in real systems, not here

Partly gated by `npm run check:atc`
(`.github/scripts/extended-check-gate.mjs`). Prose was tried first and did not
hold: `43515c97`, `0d9a7485`, `5b9e16ea` and `44642cbe` are four separate
sweeps of findings that had to be collected from a system afterwards. What a
script can decide is now a gate; the rest is below. The full list with the case
that produced each one also lives in `AGENTS.md`, "Extended-check (SLIN/ATC)
pitfalls".

**Gated:**

- **`LOOP AT … WHERE` over a standard table is a sequential read** and wants
  `"#EC CI_SORTSEQ` on the statement. Fifteen were annotated in the three
  sweeps above, and the gate found seven more that had accumulated since.
- **An empty `CATCH` block** wants `##NO_HANDLER` — that is how you say the
  empty handler is deliberate. `CATCH cx_root INTO DATA(x) ##NO_HANDLER.`
- **`FIND`/`REPLACE … REGEX` is POSIX**, which is deprecated. `FIND PCRE` only
  exists on >= 7.55 and this repo targets v750/7.02. Prefer plain string logic;
  when a regex is genuinely needed, carry `##REGEX_POSIX` (the vendored AJSON
  code does the same).

**Not gated — a script cannot decide these:**

- **`SELECT` without a `WHERE` clause** wants `"#EC CI_NOWHERE`
  (`z2ui5_cl_ui5_srv_draft=>count_entries`, `43515c97`). Whether the missing
  `WHERE` is correct is a judgement, not a pattern.
- **`CREATE OBJECT … TYPE (name)` into a generic reference, then `CAST`,** is
  flagged as insecure object creation. Declare the typed reference and create
  into it directly (`b25388ff`):
  ```abap
  DATA li_app TYPE REF TO z2ui5_if_app.
  CREATE OBJECT li_app TYPE (lv_classname).
  ```
- **No redundant conversions.** Do not wrap a value in `CONV string( … )` when
  the source already has the target type.
- **`"!` position.** A doc comment sits directly before the one declaration it
  documents — *inside* a chained statement, not before the chain keyword — and
  **never inside a parameter list**. Document parameters with
  `"! @parameter <name> | <text>` in the method's own block. This one recurs
  across repositories: `z2ui5_if_client=>cs_nav_mode` here, and again on
  `cs_status` in `abap2UI5/samples-stack` (`7459f39`), where the block sat
  before `CONSTANTS:` and therefore documented nothing.
- **ABAP Doc is parsed as HTML.** A literal `<`, `>` or `&` must be escaped as
  `&lt;`, `&gt;`, `&amp;`.

## 4. Downport and transpile — one source, three targets plus a JS runtime

Every framework file is downported to 7.02 (`npm run auto_downport`) and
transpiled to JS (`npm run auto_transpile`), and is linted against
`check:standard` and `check:cloud`. A construct can be valid ABAP and still
break one of those four.

- **Do not let an inline `DATA(…)` take its type from an offset/length
  expression.** `DATA(lv_field) = ls_attri->name+9.` made abaplint's
  `definitions_top` infer `TYPE name`, which is no DDIC type at v702, and
  `auto_downport` exited with an error — the whole downport pipeline, over one
  temporary variable. Inline the expression into its uses instead (`6b80329a`,
  #2268).
- **Do not combine an inline declaration with a table-typed `VALUE`
  constructor.** `DATA(lt_in) = VALUE STANDARD TABLE OF …` is a `parser_error`
  in the `abap_cloud` and `abap_standard` configs. Declare with `DATA`, then
  assign (`78d4731f`, #2128).
- **Transpiler-specific rewrites from the same PR** — each of these was green
  in ABAP and wrong or unsupported under the JS runtime:
  `SHIFT … DELETING LEADING/TRAILING` → `substring( )`; `CP` used as a
  containment test → `CS`; `IS NOT INITIAL` on an internal table →
  `lines( … ) > 0`; a local class type in `CREATE DATA … TYPE` → `LIKE`.
- **An ABAP name that is a reserved JS word breaks the transpiler.** The
  importing parameter `with` of `c_replace_all` was emitted as `let with = …`,
  illegal in strict mode, and the unit job went red. The fix was to add the
  word to `keywords` in `node/setup/abap_transpile.json` rather than rename a
  public parameter (`e3d8889c`, #2351) — check that list before renaming
  anything, and extend it rather than bending the ABAP API.
- **`xsdbool`, never `boolc`** — the downport converts `xsdbool` to `boolc`
  automatically, so writing `boolc` yourself breaks in the other direction.
- **Not every released class is released in ABAP Cloud.**
  `CAST cl_abap_elemdescr( … )->get_ddic_field( )` is not, and
  `z2ui5_cl_pop_table` had to derive the label from `absolute_name` plus a
  context helper instead (`bc230abe`). Framework code reaches system
  functionality only through `z2ui5_cl_ui5_util_context` for exactly this reason.

## 5. Runtime — green here, wrong there

- **After `ASSIGN`, check `IS ASSIGNED` — not `sy-subrc`.** A 7.40 SP7 system
  ran every abap2UI5 app into an endless loop because `sy-subrc` was still `4`
  from an earlier `READ TABLE` when `attri_get_val_ref` tested it: the dynamic
  `ASSIGN (lv_name)` sat in a branch that had not been taken, and on that
  release a successful `ASSIGN` did not reset it either. Reported by a user
  (#1937), fixed by testing the field symbol instead (`41890d59`):
  ```abap
  IF <attri> IS NOT ASSIGNED.
  ```
  The transpiler is more forgiving about `sy-subrc` than the release range this
  repository ships to, so no test here can reproduce it.
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
  `z2ui5_cl_ui5_util_context=>rtti_get_classes_intf_std`, which passes the table to
  `SEO_INTERFACE_IMPLEM_GET_ALL` — with `EMPTY KEY` it returns no implementers
  and user-exit discovery breaks without an error.
- **An unevaluated EML failure poisons the whole LUW.** In RAP, a failed EML
  statement whose `FAILED` is neither evaluated nor rolled back marks the
  transaction for abortion, and *every later statement in the same request*
  aborts — the request ends in `CX_SADL_DUMP_APPL_MODEL_ERROR` and the user
  sees the SAP 500 page, far away from the statement that caused it.
  `abap2UI5/samples-stack` `f7f0a02`: a `Discard` issued for instances that had
  no draft, deliberately ignoring `FAILED`, took down the whole data
  regeneration. Read first, act only on what exists, evaluate `FAILED`, and
  `ROLLBACK ENTITIES` when it is filled.
- **RAP action derived types have `%key`, `%is_draft` and `%pky` — but no
  `%tky`.** `EXECUTE … FROM VALUE #( ( %tky = … ) )` does not compile:
  *"No component exists with the name %TKY"*. Entity derived types (`READ`,
  `DELETE`, the response structures) do have it, which is why only the
  `EXECUTE` statements were flagged and the `READ ENTITIES` in the same class
  was not. `cebe6bd`.
- **Three environments, one source.** Code must work on NW 7.02, standard ABAP
  and ABAP Cloud (`check:standard`, `check:cloud`, `downport`). A statement
  that only exists in a newer release passes the default target and fails the
  others.
- **`app/webapp/` source must be 7-bit ASCII** — every frontend file is
  embedded verbatim into an ABAP class under `src/01/03/`, where abaplint's
  `7bit_ascii` rule applies. Build non-ASCII runtime strings at run time, never
  as a literal.

## 6. Blind spots — green, or red, for the wrong reason

- **Never skip a test with `IF sy-sysid = ` + backtick-`ABC`.** `ABC` is the
  system ID of the Node runtime, so the guard makes the method a silent no-op
  in `npm run unit` while it still runs in a real system — CI stays green over
  assertions nobody executes. A test that genuinely cannot run under the
  transpiler belongs in the `skip` list of `node/setup/abap_transpile.json`
  **with a note naming the missing runtime capability**; the runner then prints
  it as skipped instead of pretending it passed. (The remaining `sy-sysid`
  guards are all in the frozen `src/99` — they are history, not precedent.)
- **Generated code is not editable — fix the generator.** `src/01/03/` comes
  from `npm run app2abap` and a manual fix there is reverted by the next
  generation, with `check:app2abap` failing the PR. The same trap outside this
  repository, without a gate to catch it: in
  `abap2UI5/samples-controls#38` an over-length statement was first split by
  hand in a file produced by `scripts/generate-overview.mjs`, and the split had
  to be moved into the generator in a follow-up commit. Before editing any
  `src/` file, check whether something writes it.
- **A red linter is not always a real finding.** abaplint cannot parse RAP's
  `CLASS … DEFINITION PUBLIC FOR EVENTS OF <entity>` or `METHODS … FOR ENTITY
  EVENT`, so the class pool does not parse and *every* finding on the file —
  the structure error, the parser errors, the `check_syntax` follow-ups — is a
  consequence of that, not of the ABAP. It also cannot resolve superclasses
  that are not in the API dependency: `cl_apc_wsp_ext_stateless_base` is
  on-premise only and absent from `steampunk-2305-api`, which made the
  WebSocket handler *and its callers* report unknown references.
  `abap2UI5/samples-stack` `468af3d` sorted 25 findings into ten real ones and
  fifteen artefacts. **Never rewrite valid ABAP to satisfy a linter that cannot
  see it.** Suppress narrowly instead — per rule and per file, with the reason
  written next to the entry, and `global.noIssues` only when the error comes
  from the parser itself and no rule-level `exclude` can reach it. Scope it to
  the `.abap` files so the `.clas.xml` keeps its `object_naming` and
  `xml_consistency` coverage.

---

## When a pull does show diffs

Take the system's side. Commit the files exactly as abapGit serialized them,
then run `npm run check:abapgit` on the result — whatever it now flags is the
rule that was broken, and the fix belongs in this repository rather than in the
system.

When an **import** fails rather than diffs, read the message twice: the object
named in it is often not the broken one. A missing BDEF reports as a DDLS
problem and as a where-used-list error on unrelated classes; an over-length
line reports as a literal problem and leaves an empty class behind.

## Adding a new case

Keep the catalogue worth reading: one entry, one defect that actually happened.

1. **Put it in the right section** — 1 round trip and import, 2 activation,
   3 extended check, 4 downport/transpile, 5 runtime, 6 blind spots. A new kind
   of failure gets a new section.
2. **Name the evidence** — the commit, PR, issue or file where it bit us. An
   entry without a case is a rule somebody will delete as speculation. Say when
   it was a user who found it; those are the expensive ones.
3. **Say why the tooling missed it.** If the answer is "it did not, we just
   ignored it", the entry belongs in a lint config, not here.
4. **Gate it if a script can decide it.** Byte format, metadata and source text
   go in `.github/scripts/abapgit-format-gate.mjs`; statement-level checks that
   only a real system runs go in `.github/scripts/extended-check-gate.mjs`. Keep
   the prose entry as the reasoning. Test the rule both ways — inject the
   defect, see it fire, confirm the tree is clean again.
5. **If a script cannot decide it, say so in the entry** rather than leaving the
   reader wondering why it is not gated.
