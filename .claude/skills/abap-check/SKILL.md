---
name: abap-check
description: The catalogue of ABAP problems a green CI does not catch - abapGit round-trip and import failures (BOM, line endings, trailing whitespace, EOF newline, 255-character lines, metadata sidecars for CLAS and for DDLS/BDEF/TABL), activation errors abaplint does not model (class_constructor visibility, LOCAL FRIENDS, generic types on older releases, RAP and CDS), extended-check (SLIN/ATC) traps, downport and transpiler traps, and runtime breakage that only shows on a real system. Use before finishing any change under src/, after editing a .clas.xml or any other metadata sidecar, when a pull into a system produced unexpected diffs, an import error or an activation error - and add the case here whenever a new one is found.
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

**Every numbered section below carries a `Gate:` line**, the same idea as the
`Linter:` lines in `ui5-check` — but the answer here is rarely "a linter rule".
Most of this is decided by a script in *this* repository, which means a
consumer running nothing but `npx @abap2ui5/linter` is **not** covered by it. The
line says which of the three it is, because that is the difference between a
defect that cannot reach `main` and one that cannot reach `main` *here*:

| | |
|---|---|
| **linter** | an `abap2ui5lint` rule — travels to every repository that runs it |
| **this repo** | a script under `.github/scripts/` — covers this tree only |
| **abaplint** | a rule in `abaplint.jsonc` — covers repositories that enable it |
| **open** | nothing decides it; the entry is a thing you have to know |

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
  abaplint 2.120.24 with 73 rules active and `check_syntax` live: a `.clas.xml`
  with the BOM stripped, the terminating newline removed, CRLF line endings
  throughout **and** a raw apostrophe in `<DESCRIPT>` — four defects at once —
  produces **zero** findings. One of the four has since been closed upstream:
  `xml_bom` (2.120.32) flags a sidecar without the BOM and quick-fixes it in.
  The other three still produce nothing — re-measured on 2.120.33 with the
  three remaining defects in one sidecar, using `xml_bom` itself as the second
  control probe.
- **abaplint's `global.files` is not all of `src/`.** It covers `src/00`
  (with `noIssues`), `src/01` and `src/02` — `src/99` is never read at all.
- **The transpiler ignores visibility.** Every ABAP member becomes a plain JS
  property, so `npm run unit` stays green on a class pool a real system rejects
  with a syntax error.
- **Every check here runs against one release.** abaplint's default target is
  v750 and the transpiler is a JS runtime. Neither is 7.02, neither is a 7.40
  or low-SP 7.50 system, and neither is ABAP Cloud — and a good half of this
  catalogue is code that is valid on one of those and rejected by another.

### Measuring one of these against abaplint — read this first

Every "abaplint does not catch X" claim in this file was measured, and the
measurement has one trap that makes every result meaningless:

> **An abaplint config with no `rules` block runs NO rules.** Not the defaults —
> none. A run over a deliberately broken file then prints
> `0 issue(s) found, 3 file(s) analyzed`, which looks exactly like a confirmed
> gap and is nothing of the kind.

Three of four claims measured this way in one sitting came back "gap", and one
of them was wrong: `local_testclass_consistency` covers `<WITH_UNIT_TESTS>` in
**both** directions and says so in plain words. It had simply not been switched
on.

So: **enable the rules explicitly, and run a control probe first.** Break
something abaplint certainly catches — an undefined variable is the cheapest —
and only trust a zero once you have seen a one:

```jsonc
{ "global": { "files": "/src/**/*.*" },
  "syntax": { "version": "v750", "errorNamespace": "^(Z|Y)" },
  "rules": { "check_syntax": true, /* …and the rule you are testing… */ } }
```

Two more things that silently void a result: an `errorNamespace` that does not
match your test class's name, and a `syntax.version` too old for the syntax you
wrote (`DATA(x) = …` on `v702` is a parser error that masks everything after
it).

**Verified gaps as of abaplint 2.120.24** — measured this way, control probe
passed, nothing abap2UI5-specific about any of them, and therefore candidates
to push upstream rather than to reimplement here. The BOM half of the third row
is the one that *was* pushed upstream: it is `xml_bom` since 2.120.32, and the
row records what is left.

| Case | Why it matters |
|---|---|
| `CLASS-METHODS class_constructor.` in a PRIVATE SECTION | ABAP requires the static constructor in the public section; the class pool does not activate. `constructor_visibility_public` sees only the instance constructor |
| a test class calling a PRIVATE member without `CLASS <global> DEFINITION LOCAL FRIENDS <ltcl>.` | same activation failure; it has reached users twice (`cadfb7ae`, #2146) |
| the `.clas.xml` byte format — line endings, terminating newline, `&apos;` (the BOM is `xml_bom` since 2.120.32, and on here) | abapGit re-serializes it differently on every pull, for everyone |
| `INTO CORRESPONDING FIELDS OF TABLE @DATA(…)` under `syntax.version` v750 | 7.55 syntax; every older system refuses the class — reached a user via `abap2UI5/samples` app 348 (section 2) |
| a `VALUE` header default plus a per-row assignment of the same component | *"The component … was specified more than once"* — the system refuses the class; reached a user via `abap2UI5/samples-controls` app 241 (section 2) |

---

## 1. abapGit round trip — the file must come back byte-identical

Gated by `npm run check:abapgit`
(`.github/scripts/abapgit-format-gate.mjs`), over all of `src/`.

**Gate: this repo**, for the whole family — BOM, EOF newline, line endings,
tabs, `&apos;`, file names, sidecar pairing, `<CLSNAME>`, `<LANGU>`. Three of
them reach further: the 255-character line is **linter —
`source-line-too-long`** (an error on every app class it checks),
`<WITH_UNIT_TESTS>` plus `<CLSNAME>` are **abaplint —
`local_testclass_consistency`, `xml_consistency`** (measured, both directions),
and the BOM on an object's sidecar is **abaplint — `xml_bom`**, new in
2.120.32 and on here in `abaplint.jsonc`, in the three target configs and in
the autofix config, where its quick fix inserts the BOM rather than reporting
it. Trailing whitespace is **abaplint — `whitespace_end`**, per repository and
not everywhere; see below. Everything else in the table is this repository's
script and nothing else — and a consumer repository that has not turned
`xml_bom` on can still ship a BOM-less sidecar with a green CI.

abapGit writes every file one specific way. Write it another way and it
differs from what the system serializes back — permanently, on every pull, for
everyone.

| Rule | What abapGit does | Where it bit us |
|---|---|---|
| `bom` | `.xml` starts with the UTF-8 BOM `EF BB BF`; `.abap` never does | `8e272492`, `54bce5b6` — both titled "fix abapgit diffs", both a `.clas.xml` written without the BOM. Again in `abap2UI5/samples` `bc1f3d2` across 15 sidecars at once. The first half is **abaplint — `xml_bom`** now (one XML per object, `getXMLFile( )`, with a quick fix); the second half — a `.abap` file that carries a BOM — has no rule anywhere and stays this script's |
| `eof` | exactly one terminating `\n`, no blank line after it | `c7185c38` — `z2ui5_if_action.intf.xml` ended with `\ No newline at end of file` |
| `crlf` | LF only, everywhere | `.gitattributes` used to normalize this and was deleted in `b62ea07`; the gate is what enforces it now |
| `tab` | no tabs — the ABAP editor expands them, so the pulled source is not this file | — |
| `apos` | XML goes through the ABAP iXML renderer, which escapes the apostrophe as `&apos;` | `abap2UI5/samples` `702813e` "fix abapgit" — nine `.clas.xml` carried a raw `'` in `<DESCRIPT>` and came back changed on the next pull |
| `filename` | lower case; abapGit derives the object name from it | — |
| `sidecar` | every `*.clas.abap` / `*.intf.abap` has its `.xml`, and every `.xml` has its source. Metadata without source creates an empty object; source without metadata is not imported at all. The class-pool includes (`.testclasses`, `.locals_def`, `.locals_imp`, `.macros`) have no sidecar of their own | — |
| `package` | every folder under `src/` has a `package.devc.xml` — it *is* the package | — |
| `clsname` | `<CLSNAME>` equals the file name, upper-cased | — |
| `langu` | `<LANGU>` equals `<MASTER_LANGUAGE>` from `.abapgit.xml` (`E`). An object created while logged on in another language serializes with that language and diffs against every other developer | — |
| `unit-tests` | `<WITH_UNIT_TESTS>X</WITH_UNIT_TESTS>` exactly when a `.testclasses.abap` exists. **Also owned by abaplint's `local_testclass_consistency`, in both directions** — so in a repository that enables that rule this one is belt and braces, not the only gate | `d5eaaa79` "fix unit test metadata" — `z2ui5_cl_util_range` had the test include and not the flag |

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
  `npx @abap2ui5/linter` is covered too. Note what that does *not* replace — the
  linter reads app classes and views, not `.clas.xml` sidecars or `src/00` and
  `src/99`, so `check:abapgit` remains this repository's gate for the rest of
  the round-trip family.
- **Maximum statement length.** A single `result = VALUE #( … )` with a few
  hundred rows exceeds it. **Gate: none, and a character count is not one** —
  written against the linter on 2026-08-30, measured, and deleted. A view
  builder CHAIN is one statement by construction, so on the samples-controls
  corpus the median over-limit statement was 23,000 characters and the longest
  253,000, across 156 ports that all import fine. Length does not discriminate;
  do not re-propose the rule without a threshold somebody has measured. `abap2UI5/samples-controls#38` (`ee28671`): the
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

### Trailing whitespace — owned by a rule that is not in every repository

The ABAP editor strips a trailing blank when it saves, so a line that ends in
one comes back different on the next pull — the same defect as the rest of
this section, and the one most likely to be *written* here, because reflowing
a chain or a string template leaves blanks behind that no diff view shows.

It is not in the abapGit gate: in **this** repository abaplint's
`whitespace_end` already owns it for `src/01` and `src/02`, and the historical
blanks in mirrored `src/00` and frozen `src/99` are not ours to fix.

**That rule is per repository, and it is not everywhere.** `abap2UI5/samples`
had no `whitespace_end` in its `abaplint.jsonc` at all: the port of the corpus
to `z2ui5_cl_ui5_view_builder` (`#752`) left a trailing blank on seven lines in
seven app classes, all four CI workflows stayed green, and a maintainer had to
find and push them by hand — `b7edbc6` "fix abaplint diffs". The rule is
enabled there now, so that specific hole is closed.

So, before you finish in **any** repository: if its abaplint config does not
list `whitespace_end`, the check is yours.

```
grep -rnP '[ \t]+$' --include='*.abap' --include='*.xml' src/ && echo "trailing whitespace"
```

(`grep -E '[ \t]+$'` does **not** work — in a POSIX bracket expression `\t` is
a backslash and a `t`, so it matches every line ending in `t`, which is why a
scan can come back full of hits and still have found nothing. Use `-P`.) Strip
what it finds with `sed -i 's/[[:space:]]\+$//'` — that is all
`npm run strip_trailing_ws` does — and add `whitespace_end` to that
repository's abaplint config in the same pull request once the tree is clean.
That is what turns one fix into the last one.

## 2. Activation — compiles here, syntax error there

**Gate: this repo**, and it is the section with the widest hole. The private
`class_constructor` is `check:abapgit` — and, since 2026-08-30, `abap2ui5lint`'s
`class-constructor-visibility` as well, which is what carries it to a consumer
whose only gate is `npx @abap2ui5/linter`. `LOCAL FRIENDS` is
`npm run check_visibility` and stays here: it needs the test class and the main
class read together, which the linter does not do. Neither is an abaplint rule
— measured against 2.120.24 with 73 rules on and a control probe (see above),
both produce zero findings, which is why they are on the upstream shortlist
rather than reimplemented there. Generic types on older releases are **abaplint —
`downport`, `fully_type_itabs`, `cloud_types`** where a repository enables
them; the app-template core does, the sample repositories do not yet.

### The class pool

| Trap | Rule |
|---|---|
| **`class_constructor` must be in the PUBLIC SECTION** | ABAP requires it; the class pool does not activate otherwise. abaplint's `constructor_visibility_public` only looks at the instance `constructor` — verified: a `CLASS-METHODS class_constructor.` in a `PRIVATE SECTION` produces no finding. This is why `z2ui5_cl_ui5_frontend` fills `ct_box_type` lazily in `box_resolve( )` instead of in a static constructor (#2547) — see the comment on the attribute. Gated by `check:abapgit`, and by `abap2ui5lint`'s `class-constructor-visibility` |
| **`CREATE DATA … TYPE HANDLE` takes a data object, not a method call** | `CREATE DATA lr TYPE HANDLE cl_abap_structdescr=>create( lt_comp ).` is "No method can be specified in the current position" on a system - the operand has to be a variable holding the descriptor. abaplint parses the call as an expression and the transpiler runs it, so a test class shipped this way through every gate and a user's system reported it (2026-09-02, `ltcl_app_shapes` in `z2ui5_cl_ui5_srv_model`). Gated by `check:atc` (`handle_call`): a `TYPE HANDLE` operand with a `(` in it |
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

### VALUE constructor — a header default plus a per-row value is a syntax error

- **A component assigned before the first line spec cannot be assigned again
  inside a line.** `VALUE #( selectable = abap_true ( … ) ( … selectable =
  abap_false ) )` is refused by the system's syntax check with *"The component
  "SELECTABLE" was specified more than once."* — the header assignment is a
  default for ALL following lines, not an overridable one. Found by a user
  running Code Inspector variant SYNTAX_CHECK over a pulled
  `abap2UI5/samples-controls` main (2026-08-17): `z2ui5_cl_smpc_app_241`'s
  `model_init` carried it. Write the value per row instead — or close the
  header's scope with a second group, since the default only binds to the
  lines *after* it. abaplint 2.120.24 accepts the construct without a finding
  (`check_syntax` on, control probe fired) — its VALUE grammar does not model
  the one-assignment rule. **Gate: `abap2ui5lint`** —
  `value-header-default-reassigned` (2026-08-30), which follows the
  `source-line-too-long` precedent: for a consumer whose only gate is
  `npx @abap2ui5/linter`, a class that does not activate is the most severe thing
  this tool can find.

### Release-gated ABAP SQL — the syntax version switch does not gate it

- **`INTO CORRESPONDING FIELDS OF TABLE @DATA(…)` is 7.55 syntax.** Below that
  release the system refuses the class with *"Inline data declarations cannot
  be used together with INTO CORRESPONDING additions"*, plus one follow-up
  *"Field … is unknown"* for every later read of the never-declared table —
  three errors whose cause is the first one. Found by a user pulling
  `abap2UI5/samples` main (2026-08-17): `z2ui5_cl_smp_app_348` carried it in
  both of its SELECTs; fixed by declaring the tables with
  `DATA … TYPE STANDARD TABLE OF … WITH EMPTY KEY` and selecting
  `INTO CORRESPONDING FIELDS OF TABLE @lt_…` (samples `0d082a3`). abaplint
  stays green because its SELECT grammar puts no version gate on the inline
  declaration — measured on 2.120.24 with `check_syntax` and `downport` on at
  `syntax.version` v750: zero findings, control probe fired. Plain
  `INTO TABLE @DATA(…)` is fine from 7.40 on; it is only the combination with
  `CORRESPONDING` that is late. **Gate: `abap2ui5lint`** —
  `into-corresponding-inline-decl` (2026-08-30). Still worth having upstream in
  the `downport` rule or the version model; the linter carries it meanwhile
  because a systemless pipeline sees an activation error only when somebody
  imports the transport.

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

**Gate: this repo**, partially — `npm run check:atc`
(`.github/scripts/extended-check-gate.mjs`) decides the traps a script can
decide. The rest is **open** by construction: SLIN and ATC run in a system,
and no gate outside one can stand in for them.

**Backlog:** abaplint · abaplint-abapdoc-block-placement

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
  A LOOP that names a secondary key (`USING KEY … WHERE <key component> =`)
  is a keyed read and wants no pragma; the gate skips it. The one such key in
  the framework is `parent` on `z2ui5_if_ui5_types=>ty_t_attri` (2026-09) -
  its component is written before the row is inserted and never through a
  reference afterwards, which is the condition a secondary key component has
  to meet.
- **An empty `CATCH` block** wants `##NO_HANDLER` — that is how you say the
  empty handler is deliberate. `CATCH cx_root INTO DATA(x) ##NO_HANDLER.`
- **`FIND`/`REPLACE … REGEX` is POSIX**, which is deprecated. `FIND PCRE` only
  exists on >= 7.55 and this repo targets v750/7.02. Prefer plain string logic;
  when a regex is genuinely needed, carry `##REGEX_POSIX` (the vendored AJSON
  code does the same).
- **`"!` position.** A doc comment sits directly before the one declaration it
  documents — *inside* a chained statement, not before the chain keyword — and
  **never inside a parameter list**. Document parameters with
  `"! @parameter <name> | <text>` in the method's own block. SLIN reports it as
  "ABAP Doc comment is in the wrong position"; nothing breaks, the text is
  simply never shown, which is why it kept recurring: first
  `z2ui5_if_client=>cs_nav_mode` here, then `cs_status` in
  `abap2UI5/samples-stack` (`7459f39`), then **five findings on samples-stack's
  overview app from a user's system** (2026-08-17) — two blocks before
  `CONSTANTS:`, three comments between the parameters of one method. That
  third recurrence turned it into a gate: decided here by `check:atc`, in
  samples-stack by its own `npm run check:abapdoc`, both by the same purely
  structural test (what statement follows the block; what the code line above
  it ends with). The rule itself is proposed upstream — backlog:
  abaplint-abapdoc-block-placement, with a measured probe.

- **ABAP Doc is parsed as HTML.** A field symbol or a placeholder written as
  `<wa>`, `<row>`, `<CLASS>` inside a `"!` block is "HTML tag not supported"
  and "not closed" in a system, and the block renders wrong. Write
  `&lt;wa&gt;`. AGENTS.md carried the rule as prose, and three of them still
  shipped in `z2ui5_if_client` (#2705) until a user's system reported them
  (2026-09-02) - so it is a gate now: `check:atc` (`abapdoc_html`) reads every
  `"!` line for a complete tag-like token outside the tags ABAP Doc knows
  (`p em strong ul ol li h1-h3 br`). A comparison `a < b` is not a token and
  not a finding.

**Not gated — a script cannot decide these:**

- **`DATA( )` from a generic parameter** (`DATA(lv) = val` with
  `val TYPE clike`) is "the fixed type STRING is used for the generic type
  CLIKE": the inline declaration has to pick a type, and SLIN objects to the
  pick. Declare the variable (`DATA lv TYPE string.`) and assign. Found by a
  user's system in `z2ui5_cl_ui5_util_context=>url_param_get_tab` (2026-09-02).
  Deciding it needs the parameter's type, which the statement does not carry.
- **Re-raising a variable typed `cx_root`** (`CATCH cx_root INTO DATA(lx).
  … RAISE EXCEPTION lx.`) in a method whose signature declares no exception is
  "CX_STATIC_CHECK is not caught or declared in the RAISING clause" - the
  static type could be one. When the point is to run code on the way out and
  let the original exception travel on, use `CLEANUP` instead of
  catch-and-re-raise; it runs on the way to the outer handler and touches
  nothing (`z2ui5_cl_ui5_http_handler=>_http_post`, found by a user's system
  2026-09-02). Not gated: whether the re-raise leaves the method depends on the
  enclosing TRY blocks, and the same statement inside an outer `CATCH cx_root`
  is fine (`z2ui5_cl_ui5_srv_model=>main_json_to_attri`).

- **`SELECT` without a `WHERE` clause** wants `"#EC CI_NOWHERE`
  (`z2ui5_cl_ui5_srv_draft=>count_entries_total`, `43515c97`). Whether the
  missing `WHERE` is correct is a judgement, not a pattern — here it is
  deliberate ( the method reports the whole table's size ), so the pragma
  records the decision instead of hiding it. `count_entries` next to it *is*
  owner-scoped and needs no pragma.
- **`CREATE OBJECT … TYPE (name)` into a generic reference, then `CAST`,** is
  flagged as insecure object creation. Declare the typed reference and create
  into it directly (`b25388ff`):
  ```abap
  DATA li_app TYPE REF TO z2ui5_if_app.
  CREATE OBJECT li_app TYPE (lv_classname).
  ```
- **No redundant conversions.** Do not wrap a value in `CONV string( … )` when
  the source already has the target type — and not in `CONV i( … )` when the
  assignment target is already `TYPE i`: the assignment converts by itself,
  and SLIN warns *"Redundant conversion for type I"*. Found by a user on a
  real system (2026-08-17): `z2ui5_cl_smpc_app_295`'s
  `slider_value = CONV i( client->get_event_arg( ) )` in
  `abap2UI5/samples-controls`. abaplint's `value_conversion` /
  `unnecessary_pragma` do not cover it (measured on 2.120.24, control probe
  fired).

  **Now gated, and the earlier claim here was wrong.** This entry used to end
  "the type inference makes it undecidable for a text-level gate". It is
  undecidable in general and decidable for the shape SLIN actually flags, which
  is the only one that matters: the CONV is the WHOLE right-hand side of an
  assignment (`<name> = CONV i( x ).`) into a name the same file declares
  `TYPE i` — a `DATA`/`CLASS-DATA` line or a typed parameter. That is
  `abap2ui5lint`'s `redundant-conv-i` — promoted out of `samples-controls`'
  `scripts/pattern-lint.mjs` on 2026-08-30, scope boundaries and all, and
  retired there.

  Two boundaries the rule keeps, both learned by getting them wrong first:
  a CONV inside a comparison (`COND #( WHEN CONV i( x ) < 14 …`) or an
  arithmetic expression (`CONV i( x ) + 1`) is load-bearing or at least
  arguable and is NOT flagged — the first draft reported apps 350 and 353,
  which SLIN itself had left alone. And a CONV inside a string template
  (`|{ CONV i( x ) WIDTH = 2 }|`) is a real conversion.

  What the gate is worth, measured: a user's system reported nine findings
  (534, 546 ×2, 547 ×2, 548, 549, 566, 609) on 2026-08-23. The rule reproduced
  all nine **and found four more the system run had not** — 356 once, 363
  three times. A system run sees one package at a time; the gate sees the
  corpus.
- **An Open SQL literal is a host expression: `@( … )`.** In strict Open SQL
  every value in a WHERE comparison is escaped, a literal included — bare
  `WHERE id = \`TEST_COUNT_FOREIGN\`` becomes
  `WHERE id = @( \`TEST_COUNT_FOREIGN\` )`. Fixed by a user on a real system
  (2026-08-23, abap2UI5#2657) in `z2ui5_cl_ui5_srv_draft`'s test class; the
  transpiled tests and abaplint both accepted it.

  **Do not "fix" an internal table.** `DELETE lt_param WHERE n = \`app_start\``
  is ITAB syntax, where `@( )` is neither needed nor valid, and a grep for
  `WHERE <name> = <literal>` finds ten of those in this repository for the one
  real case. The discriminator is the statement: `DELETE FROM <dbtab>` /
  `SELECT … FROM <dbtab>` / `UPDATE` / `MODIFY` against a database table.
  Measured after the fix: that one line was the only bare literal in Open SQL
  across `src`.

- **`GET REFERENCE OF … INTO x` is the old spelling; write `x = REF #( … )`.**
  Same pull request, same reason — it is not released for ABAP Cloud, and
  nothing on this side reports it: `check:cloud` and the transpiled unit run
  are both green with it in place.

  Still standing in `src` after that fix, and worth deciding on rather than
  discovering later: four occurrences outside the upstream mirrors and the
  frozen package — `src/00/03/z2ui5_cl_ui5_util_context.clas.abap:878` and
  `src/01/02/z2ui5_cl_ui5_srv_model.clas.abap` at 325, 345 and 467. All four
  take a field symbol or a formal parameter, which `REF #( )` expresses
  directly. They were left alone deliberately: the pull request changed a test
  class, and rewriting three production reference paths in the model is a
  separate change with its own verification.

- **A RAP handler names the entity by its BDEF alias.** Where the behavior
  definition declares `alias Ticket`, an event handler's
  `FOR ENTITY EVENT ... FOR z2ui5_r_smps_tck~TicketCreated` draws "The alias
  Ticket from the behavior definition should be used instead" — twice on
  `z2ui5_cl_smps_evt_tck` (`abap2UI5/samples-stack`, found on a user's system
  2026-08-17). Write `FOR ticket~TicketCreated`. abaplint has no grammar for
  `FOR ENTITY EVENT` (section 6), so no rule can reach it.
- **A draft `Activate` wants `optimized`.** A plain `draft action Activate;`
  in a behavior definition draws "should be defined as optimized to enable
  optimized execution of determinations and validations" — samples-stack's
  ticket BO carried it while the travel BO one package over already had
  `draft action Activate optimized;` (same finding source, 2026-08-17).
  abaplint does not read BDEF sources at all.
- **ABAP Doc is parsed as HTML.** A literal `<`, `>` or `&` must be escaped as
  `&lt;`, `&gt;`, `&amp;`.

**Not gated: the BUNDLE.**
`check:atc` walks this repository's `src/` — that is its stated scope, and
over `src/` it holds: every `FIND`/`REPLACE … REGEX` here
carries `##REGEX_POSIX`, including the five in the vendored AJSON where the
pragma sits on the statement's CONTINUATION line (a line-based grep reports
those as missing; the gate flattens statements first, so it does not).

`abap2UI5-local` is a different artefact. `trigger_local.yaml` copies these
sources into that repository, where a script folds them into ONE class whose
"Local Implementations" hold everything. A user's system run on
`z2ui5_cl_abap2ui5_local` (2026-08-23) reported eight SLIN warnings against
that folded include — POSIX regex twice, ABAP Doc position, `<CLASS>` not
supported / not closed three times, a redundant `CONV string( )` — at character
OFFSETS (`@16232`, `@38704`), not at lines in any file here. All four kinds are
the families above, and all four are silenced in `src/` by a pragma, a
`##REGEX_POSIX`, or an escape. **They come back after the fold**, so what the
fold does to those annotations is the thing to establish; the sources on this
side are clean and no change here would move them. The `<CLASS>` pair is worth
looking at first: `<p class="shorttext synchronized">` is the standard ADT
shorttext form, and a tag scanner that splits on whitespace reads the attribute
name as a second tag — which would make it an artefact of the fold rather than
of the doc comment.

Not verified from here: `abap2UI5-local` was not attached to the session that
wrote this, so the bundler itself was not read. What IS measured is that
`src/` carries the annotations and that `check:atc` is green over it.

## 4. Downport and transpile — one source, three targets plus a JS runtime

**Gate: this repo** — `npm run verify` builds all three targets and runs the
transpiled tests. Nothing here is a linter rule and nothing here should be: the
downport is a build of this repository, not a property of somebody's app.

**Backlog:** open-abap · transpiler-reserved-js-identifiers
**Backlog:** abaplint · abaplint-downport-builtin-operand

Every framework file is downported to 7.02 (`npm run auto_downport`) and
transpiled to JS (`npm run auto_transpile`), and is linted against
`check:standard` and `check:cloud`. A construct can be valid ABAP and still
break one of those four.

- **Never put a 7.02 built-in function inside a table-expression key.** This is
  the sharpest case in this section, because all four checks were green and a
  user's system was not. `line_exists( mt_names[ table_line = to_upper( is_node-name ) ] )`
  is valid at v750; the downport rewrites it to
  `READ TABLE mt_names WITH KEY table_line = to_upper( is_node-name )`, carrying
  the call over verbatim, and a `WITH KEY` operand is not a general expression
  position before 7.40. A built-in function is only *read* as one where a string
  expression is allowed, so 7.02/7.31 falls back to the only other reading of
  `name( … )` — a functional method call — and the class pool dies with
  `SYNTAX_ERROR`, "method TO_UPPER is unknown". That class is
  `z2ui5_cl_ui5_client`, so every app on the system was down (#2664).
  **Hoist the call into a variable on the line above**; a plain assignment IS an
  expression position at 7.02, so the variable is the whole fix. Same for a
  `WITH [TABLE] KEY` you write yourself and for an internal-table `WHERE`.
  *Not* affected: a functional **method** call in those positions (that reading
  is what 7.02 already applies), and the pre-7.02 built-ins — the same
  downported method has `READ TABLE lt_parts INDEX lines( lt_parts )` ten lines
  above the failure and the compiler accepted it.
  **Gate:** `npm run check:downport` over `src/`, and the downport is asked to
  hoist it upstream (backlog below).
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

**Gate: mostly open.** Three entries have moved: **linter —
`live-event-roundtrip`** (a `liveChange` that drops events under fast input),
**`obsolete-binder`/`obsolete-model-update`/`obsolete-frontend-event`** (API
that is accepted and no longer evaluated) and **`non-released-api`** (naming
anything outside `src/02`).

One more lands in 0.2.0, and it is the sharpest case of this whole file: a
class that BUILDS its view with the frozen `z2ui5_cl_xml_view` used to be
skipped by the linter entirely — the run ended with `no checkable app classes`
and exit 0, which reads like approval while nothing had been looked at.
**`frozen-view-builder`** reports it instead. Not pinned here yet; this
repository's `src/99` will need it excluded when it is, since that package IS
the frozen legacy.

The rest needs a running system with real data and is written down here
precisely because no gate will catch it.

**Backlog:** abaplint · abaplint-subrc-after-assign, abaplint-delete-index-in-loop

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

  **But `IS ASSIGNED` is not a blind replacement.** A FAILED `ASSIGN` leaves the
  field symbol bound to whatever it pointed at before — verified in
  `@abaplint/runtime`'s `assign`, where every failure path sets `sy-subrc = 4`
  and returns without clearing the target. Inside a `LOOP`, or anywhere the
  same symbol was already assigned, `IS ASSIGNED` therefore reads TRUE for a
  failure, which is worse than the bug it replaces. `UNASSIGN <fs>.` before the
  `ASSIGN` where that can happen. Measured across the four repositories
  (2026-08-17): **42** sites take the drop-in, **17** are inside a loop and
  **2** re-assign — about one in three needs the `UNASSIGN`. The #1937 fix
  itself is a simple case: `<attri>` is declared at method start and assigned
  in two mutually exclusive branches.
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
- **`DELETE itab INDEX sy-tabix` inside a `LOOP AT` over the SAME table has two
  failure modes, and only the loud one is reliably visible.** Deleting the
  current row shifts every row after it while the loop's own cursor walks on,
  so the row *after* each deletion is skipped:

      LOOP AT tab INTO DATA(row).          " filters 10 rows, judges 5 of them
        IF <drop it>.
          DELETE tab INDEX sy-tabix.
        ENDIF.
      ENDLOOP.

  Where `sy-tabix` is merely STALE but positive, nothing dumps: the statement
  returns a plausible-looking, WRONG result — a filter that keeps rows it was
  told to drop. Where it has been reset to **0** — an inner loop that has
  ended, a `DO` between the `LOOP` and the `DELETE` — index 0 is a short dump,
  and `TABLE_INVALID_INDEX` is the ABAP runtime error's own name for it.

  Found by an e2e interaction driving samples-controls' app 352, whose
  `listClose` round-trip answered HTTP 500 with that error (2026-08-17).
  **Do not read that as the transpiler being stricter than a system** — it was
  checked, and it is not: `@abaplint/runtime` 2.13.59's `deleteInternal`
  raises for index 0 and sets `sy-subrc = 4` for an out-of-range one, which is
  what a real system does. The transpiled backend found this because it was
  exercised, not because it judges harder.

  A pattern search then found it **eight times** across the ecosystem: four
  ports in `abap2UI5/samples-controls` (352 twice, 354, 298, 377), three in
  `abap2UI5/samples` (`z2ui5_cl_smp_context`'s `filter_itab` and
  `itab_filter_by_val`, app 070), and one in the vendored ajson
  (`z2ui5_cl_ajson_filter_lib`, upstream — not patched here). Two of them were
  wrong twice over: in `filter_itab` the `sy-tabix` belonged to an INNER loop,
  so the index deleted was another table's, and elsewhere a `DO` loop between
  the `LOOP` and the `DELETE` clobbers it again.

  Build the result instead — collect what is kept and assign it back. It reads
  as what it does and has neither failure mode. `DELETE itab WHERE …` is fine
  too where the condition can be expressed there; `DELETE itab INDEX sy-tabix`
  right after a `READ TABLE` is correct and common (`z2ui5_cl_ajson`), which is
  why the shape cannot simply be banned.

- **Three environments, one source.** Code must work on NW 7.02, standard ABAP
  and ABAP Cloud (`check:standard`, `check:cloud`, `downport`). A statement
  that only exists in a newer release passes the default target and fails the
  others.
- **`app/webapp/` source must be 7-bit ASCII** — every frontend file is
  embedded verbatim into an ABAP class under `src/01/03/`, where abaplint's
  `7bit_ascii` rule applies. Build non-ASCII runtime strings at run time, never
  as a literal.

### Two the transpiled suite cannot see — found by a user's unit-test run (2026-09-02)

- **A failed conversion clears its target on a system.** `<comp> = 'abc'`
  into a packed field, `'seven'` into an integer: the exception
  (`CX_SY_CONVERSION_NO_NUMBER`) is catchable, but the target is already
  initial when the handler runs - and `to_abap( )` clears its container before
  it fills it. The transpiled runtime leaves the target untouched, so "the cell
  is skipped and the old value stands" (`z2ui5_cl_ui5_srv_model=>delta_apply_field`)
  held in `npm run unit` and three `z2ui5_cl_ui5_client` tests failed on a
  system with the refused cells at zero. The rule: whenever a write may be
  refused and the old value is promised, copy it aside first and put it back
  in the handler - `main_json_to_attri` already did, the delta path now does.
- **`ASSIGN dref->* TO <fs>` with a typed field symbol is a runtime error,
  not sy-subrc 4.** A sorted table assigned to a `TYPE STANDARD TABLE` field
  symbol dumps with `ASSIGN_TYPE_CONFLICT` on a system; the transpiler answers
  sy-subrc 4, and `test_skip_sorted_table` was even skipped in Node with a note
  saying the real system takes "the subrc branch". Decide the kind by RTTI
  (`cl_abap_tabledescr->table_kind`) BEFORE the ASSIGN
  (`z2ui5_cl_ui5_srv_model=>check_table_standard`); the skip entry is gone.

## 6. Blind spots — green, or red, for the wrong reason

**Gate: none, and that is the definition.** An entry lands in this section
because a check *passed* while the code was wrong, or *failed* while it was
right. A gate cannot cover it — if one could, the entry would have moved to a
numbered section above.

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
