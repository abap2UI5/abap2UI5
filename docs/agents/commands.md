# Build & validation commands

> Extracted from `AGENTS.md`, which keeps only the three headline commands
> and points here — that file is loaded into every session, and this inventory
> is what a reader looks up once they know a command exists. **The list below
> is held complete mechanically**: `npm run check:commands`
> (`.github/scripts/agents-commands-gate.mjs`) fails when an npm script in
> `package.json` is not named in this file, so a new script comes with a row
> here (or a declared omission in the gate, with the reason).

Install dependencies: `npm install` (frontend gates additionally need
`npm --prefix app ci` — `verify:full` runs that itself)

## Validation sequence

Three commands, all **non-destructive** — they never modify `src/` or
`abaplint.jsonc`. (One nuance: `verify`'s final app2abap drift gate re-runs
the `src/01/03/` generation in place — on an in-sync tree the output is
byte-identical, and a difference is exactly the drift the gate exists to
fail on.)

```bash
npm run check        # Fast inner loop: abaplint only (seconds) — run this while iterating
npm run gates        # The static gates (run-gates.mjs, one sub-second Node
                     # script per rule) in one process (~4s). Reports
                     # EVERY failure, not just the first, and names the npm script
                     # that reruns each one - the local half of what
                     # check_gates.yaml's per-step `!cancelled()` does in CI
npm run verify       # Gate before every PR (.github/scripts/run-verify.mjs):
                     # runs ALL independent checks first (abaplint, gates,
                     # chain layout, eslint, format, standard/cloud targets)
                     # CONCURRENTLY - buffered per member, reported in order,
                     # every failure at once - then the dependent pipeline
                     # in order: downport -> transpile -> unit -> JS unit
                     # specs -> app2abap drift gate (matches CI)
npm run verify:full  # the same runner with --full: verify + the frontend gates
                     # (ui5lint zero-error gate, the app eslint) as two more
                     # members; installs app/node_modules itself when it is
                     # missing. Run when app/webapp/ changed
```

`npm run verify` downports into `node/downport/` and runs the transpiled unit
tests from there, so the working tree stays exactly as you left it. Use
`npm run check` for the tight edit/validate loop and `npm run verify` before
opening a PR. Do **not** use `npm run auto_downport` for validation — see
AGENTS.md rule 9.
The app2abap drift gate needs the frontend toolchain and installs
`app/node_modules` itself when it is missing (only then — no reinstall on
every run).

**What `verify` still does not cover** (CI-only): the browser e2e tests
(`test.yaml`, the `browser` matrix — needs browsers + the UI5 CDN), the express
smoke test (`test.yaml`, `test_node`), and the namespace-rename test
(`abaplint.yaml`).

**One dependency is patched in place.** `npm run downport` runs
`node/setup/patch-abaplint-downport.mjs` first, which rewrites the installed
abaplint's table-expression outline to keep the ROW reference
(`READ TABLE ... ASSIGNING`) instead of copying it into a work area. Without it
`_bind( tab / tab_index )` - the cell binding - is refused in every downported
build. It is a temporary shim for a defect filed in `backlog/` against
abaplint; the script says what to delete when the fix ships, and it FAILS the
build rather than passing silently once its anchors stop matching.
`test_bind_tab_cell` (in `z2ui5_cl_ui5_client`'s test class) is the canary that
the shim still works.

**Three more, the same way.** `npm run auto_transpile` runs
`node/setup/patch-open-abap-core.mjs` and
`node/setup/patch-abaplint-runtime-assign.mjs` first. The former patches the
pinned open-abap-core checkout twice: `cl_abap_typedescr=>describe_by_name`
learns the absolute spelling of a type name (`\TYPE=STRING`,
`\TYPE-POOL=ABAP\TYPE=ABAP_BOOL`, the spelling S-RTTI resolves a serialized
component by), and the asXML writer of `CALL TRANSFORMATION id` escapes
character values (a string CONTAINING markup - the S-RTTI payload of every
draft with a generic data reference - came back truncated). The latter makes
the installed `@abaplint/runtime` answer sy-subrc 4 for a dynamic ASSIGN
through a component that does not exist, instead of a TypeError. Without the
three no draft that carries a TYPE HANDLE table restores in the transpiled
backend (`ltcl_test_app_root4->test_tab_ref_gen` was skipped for exactly
that) and a host that swaps its sub-app's class crashes the restore. All
three are filed in `backlog/`; each is idempotent and FAILS the transpile
when the line it anchors on moves upstream.

**Pinned git dependencies:** abaplint and the transpiler clone three upstream
repos (steampunk API intersection, open-abap-core, express-icf-shim). These
are pinned to fixed SHAs via `node node/setup/fetch-deps.mjs` (auto-run by
`check`/`downport`; materializes `node/deps/`, gitignored) so a build cannot
turn red because an upstream moved. Bump pins deliberately: `--print-latest`,
edit the SHAs in `fetch-deps.mjs`, `npm run verify`. Without network the tools
fall back to a floating HEAD clone — treat unexplained lint/transpile failures
in untouched code as a possible upstream move only in that fallback case.

## Other commands

| Command | Purpose |
|---|---|
| `npm run deps` | Fetch the three pinned git dependencies into `node/deps/` (auto-run by `check`/`downport`; `-- --print-latest` shows upstream HEADs for a pin bump) |
| `npm run check_visibility` | Fail when a local test class reads a PRIVATE/PROTECTED member of the class under test without `LOCAL FRIENDS` (part of `verify`, gated in `check_gates.yaml`; abaplint and the transpiler cannot see this) |
| `npm run check:abapgit` | The abapGit round-trip gate — byte format of every file under `src/` (BOM, LF, terminating newline, tabs, file-name case), sidecar/package completeness, `<CLSNAME>`/`<LANGU>`/`<WITH_UNIT_TESTS>` against the source, and `class_constructor` in the PUBLIC section. Covers `src/00` and `src/99`, which abaplint does not scan (part of `verify`, gated in `check_gates.yaml`; background in `.claude/skills/abap-check/SKILL.md`) |
| `npm run check:atc` | The extended-check (SLIN/ATC) gate — a sequential read without `"#EC CI_SORTSEQ` (`LOOP AT … WHERE`, `READ TABLE … WITH KEY`, and a table expression keyed on a component — the last two in production code only, since test classes hold 76 of the 86 matches and none of them is shipped), an empty `CATCH` without `##NO_HANDLER`, `FIND`/`REPLACE … REGEX` without `##REGEX_POSIX`, and an ABAP Doc block that documents nothing (before a chain keyword, inside a parameter list, before a section end). Scoped to this repository's own ABAP (`src/00/01`, `src/00/02` are upstream mirrors, `src/99` is frozen). abaplint models none of these (part of `verify`, gated in `check_gates.yaml`; background in `.claude/skills/abap-check/SKILL.md`) |
| `npm run check:cause` | Fail when a raise inside a `CATCH` inlines the caught exception's `get_text( )` into its own message instead of passing it as `previous` — that flattens the chain the single top-level catch renders into the 500 body (`.github/scripts/exception-cause-gate.mjs`; part of `verify`, gated in `check_gates.yaml`) |
| `npm run check:format` | The house-format gate — `.github/abaplint/auto_abaplint_fix.jsonc` with `--fix` left off, so the same rules that write the format decide whether it is there (indentation, keyword case, line length, parameter alignment, trailing whitespace, blank-line runs, space before colon/dot). `npm run auto_abaplint` is the fix (part of `verify`, gated in `abaplint.yaml`) |
| `npm run check:commands` | Fail when an npm script is not named in this file — this file is the command inventory AGENTS.md points every session at, so a command missing from it does not exist for the reader who needs it. Deliberate omissions are declared in the script with a reason (`.github/scripts/agents-commands-gate.mjs`; part of `verify`, gated in `check_gates.yaml`) |
| `npm run check:version` | Fail when `package.json`'s version and the `version` constant in `src/02/z2ui5_if_app.intf.abap` disagree — two files on purpose (one ships, one does not) and nothing but this holds them together (`.github/scripts/version-sync-gate.mjs`; part of `verify`, gated in `check_gates.yaml`) |
| `npm run check:conventions` | The rules in `.github/shared/CONVENTIONS.md` a script can decide — workflow file naming, the `CLAUDE.md` pointer, the npm-script names. This repository declares the ecosystem's conventions and broke most of them; the workflow names that predate the rule are exceptions **by name** and the list only shrinks (the gate prints the current count) (`.github/scripts/conventions-gate.mjs`; part of `verify`, gated in `check_gates.yaml`) |
| `npm run check:naming` | Fail when an object outside the public API (`src/02`) and the frozen package (`src/99`) carries no `ui5` / `ui5f` segment — abaplint's `object_naming` only checks the `Z2UI5_` prefix, so an object under `src/01` whose segment is anything but `ui5` / `ui5f` passes every lint otherwise (`.github/scripts/object-naming-gate.mjs`; part of `verify`, gated in `check_gates.yaml`) |
| `npm run check:dynamic` | Fail when a `Z2UI5_*` name written as a **string literal** (dynamic lookup, `CREATE OBJECT TYPE (name)`) resolves to no object in `src/` — nothing else resolves those, and a literal naming nothing reads as "not implemented" at runtime (`.github/scripts/dynamic-name-gate.mjs`; part of `verify`, gated in `check_gates.yaml`) |
| `npm run check:prose` | The same rule for **prose** — every `Z2UI5_*` name in the changelog, AGENTS.md, `docs/`, the skills and the README names an object this repository ships. A rename sweep fixes the code, because the code is what fails; prose has no compiler (`.github/scripts/prose-name-gate.mjs`; part of `verify`, gated in `check_gates.yaml`) |
| `npm run check:skills` | Fail when a linter rule id named in a skill's `Linter:` / `Gate:` line no longer exists — that is a claim about **another** repository, which renames and retires rules on its own schedule (`.github/scripts/skill-rule-gate.mjs`; part of `verify`, gated in `check_gates.yaml`) |
| `npm run check:scripts` | Fail when a repository of the ecosystem does not answer to `npm run check` and `npm test` — CONVENTIONS §3 as a program; five of ten answered "Missing script" until it existed (`.github/scripts/scripts-gate.mjs`; part of `verify`, gated in `check_gates.yaml`) |
| `npm run check:toolchain` | Fail when a repository of the ecosystem does not declare the same toolchain — `engines.node` `>=22`, `.nvmrc` `22`, a `license` — CONVENTIONS §4 as a program. It was the one section nothing decided, and seven of the nine repositories had no `.nvmrc` at all while `playground` asserted the version in prose and declared neither. Drift that predates the gate is named in its `EXCEPTIONS` list, which only shrinks (`.github/scripts/toolchain-gate.mjs`; part of `verify`, gated in `check_gates.yaml`) |
| `npm run check:shared` | Fail when a file this repository is the SOURCE of differs from the copy in a sibling repository (the list, and how each copy is compared, is the `.github/scripts/` row in `docs/agents/repository-map.md`) (`.github/scripts/shared-file-gate.mjs`; part of `verify`, gated in `check_gates.yaml`) |
| `npm run check:mirrors` | The other direction: `@abap2ui5/linter` hand-mirrors three closed sets defined here (the curated formatters, the frontend actions, the abapGit object layout) and is not a dependency of this repository, so a rename here is silent until its weekly sync files an issue days later (`.github/scripts/linter-mirror-gate.mjs`; part of `verify`, gated in `check_gates.yaml`) |
| `npm run check:samples-md` | Fail when a generated `SAMPLES.md` row stops matching the format `abap2UI5/mcp-server` and `abap2UI5/docs` parse — three generators, two readers, none in the same repository, and a reader that stops matching answers "there are no samples for that" instead of failing (`.github/scripts/samples-md-gate.mjs`; part of `verify`, gated in `check_gates.yaml`) |
| `npm run check:changelog` | Fail when `changelog.txt` and the release-notes page in `abap2UI5/docs` disagree about which releases exist or when they shipped. The two are deliberately different documents; they may not differ about the facts (`.github/scripts/changelog-gate.mjs`; part of `verify`, gated in `check_gates.yaml`) |
| `npm run check:changelog-entry` | CI-only PR gate: when the pull-request diff touches `.github/api-snapshot.json` or `src/02/**`, `changelog.txt` must have gained a line under the `unreleased` heading — a public-contract change is user-visible by definition. Needs a diff base (`BASE_REF` or first argument), which the working tree does not have, so it is deliberately not part of `npm run gates`/`verify` (`.github/scripts/changelog-entry-gate.mjs`; gated in `check_gates.yaml` on pull requests only) |
| `npm run check:modules` | Fail when a `sap.ui.define` dependency array in `app/webapp/` names a UI5 module outside the reviewed 1.71 list — the floor 404s it and the ui5loader drops the WHOLE component (AGENTS.md rule 12; `.github/scripts/frontend-module-gate.mjs`; part of `verify`, gated in `check_gates.yaml`) |
| `npm run check:eslint` | ESLint over the Node side of the repository — `.github/scripts/`, `tools/`, `node/`. `app/eslint.config.mjs` covers only `webapp/**`, so everything that BUILDS and CHECKS the frontend was uncovered; root `eslint.config.mjs` is the flat config (part of `verify`, gated in `check_gates.yaml`) |
| `npm run check:render` | The linter's **render** half over this repository's own app classes — every view a class builds survives a real `XMLView.create`. Needs `@abap2ui5/render-runtime` (~123 MB), which is installed by `render-gate.yaml` / `bump-linter.yaml` and deliberately not a devDependency, so this is not part of `verify` |
| `npm run backlog` | Regenerate the four backlog pages from `backlog/items/` and the skills' `**Backlog:**` lines; `check:backlog` is the `--check` half (see `backlog/README.md`) |
| `npm run backlog:probe` | Run an item's `<id>.probe.mjs` over the sibling checkouts — measure a proposed rule against the code it would judge, so a proposal carries its own false-positive count instead of asking a maintainer to take the author's word for it |
| `npm run backlog:mine` | Find candidates nobody wrote down: the `IMPROVISED` deviations in samples-controls' `meta/` sidecars are a record of what the framework could not express, kept weeks before anybody files anything |
| `npm run backlog:filed` | Ask GitHub what happened to every item with `state: filed` — the backlog cannot see when its own claim about another repository stops being true. Reports; deletes nothing |
| `npm run check:specs` | Fail when a spec under `node/tests/` is not in `docs/agents/test-inventory.md`, or the inventory names one that is gone — the list is how a reader finds out whether a frontend module is already covered, and one that quietly stops being complete answers "no spec" for a module that has one (`.github/scripts/spec-inventory-gate.mjs`; part of `verify`, gated in `check_gates.yaml`) |
| `npm run check:standard` / `check:cloud` | abaplint against the standard-ABAP / ABAP-Cloud target configs (part of `verify`) |
| `npm run check:js` | JS unit specs for the real `app/webapp` modules, no browser needed (part of `verify`) |
| `npm run check:frozen` | Fail when the branch touches the frozen `src/99/` (part of `verify`) |
| `npm run check:frozen-only` | Fail when anything in `src/00`–`src/02` calls a symbol marked `FROZEN-ONLY` in `z2ui5_cl_ui5_util_context` — those symbols exist only because the frozen `src/99` still calls them and go when it goes (the markers in the class are the count; a number here went stale the first time one was unmarked), so a framework caller turns one into a new blocker for that removal (`.github/scripts/frozen-only-gate.mjs`; part of `verify`, gated in `check_gates.yaml`) |
| `npm run check:icons` | Fail when a `sap-icon://` name under `src/` or `app/webapp/` is not in the UI5 1.71 icon font (`.github/scripts/ui5-icon-gate.mjs`; part of `verify`, gated in `check_gates.yaml`; see AGENTS.md rule 21) |
| `npm run check:ui5` | The ui5lint zero-error gate (`.github/scripts/ui5lint-gate.mjs`; part of `verify:full`, needs `app/node_modules`) |
| `npm run check:api` | The `src/02` public-API contract gate — compares against `.github/api-snapshot.json` (see AGENTS.md rule 5; part of `verify`, gated in `check_gates.yaml`) |
| `npm run check:guide` | Fail when `docs/agents/building-apps.md` names a client method or `cs_*` constant the API does not have (part of `verify`) |
| `npm run check:asserts` | Fail when a `FOR TESTING` method asserts nothing — it proves only that the code does not dump, while the report counts it as a passing test (`.github/scripts/assertion-gate.mjs`; part of `verify`, gated in `check_gates.yaml`). Same scope as `check:atc`: `src/00/01`, `src/00/02` are upstream mirrors and `src/99` is frozen |
| `npm run check:downport` | Fail when a 7.02 built-in function (`to_upper( )`, `substring( )`, …) stands in a table-expression key, a `WITH KEY` operand or an internal-table `WHERE` — positions that only become general expression positions at 7.40, so the downported statement does not compile on 7.02/7.31 (`.github/scripts/downport-operand-gate.mjs`; part of `verify`, gated in `check_gates.yaml`; #2664). Same scope as `check:atc` |
| `npm run check:pins` | Fail when a library in `node/setup/abap_transpile.json` has no sha pin in `node/setup/fetch-deps.mjs` — the transpiler would clone it at floating HEAD, the exact state the pins exist to rule out (`.github/scripts/transpile-pins-gate.mjs`; part of `verify`, gated in `check_gates.yaml`) |
| `npm run check:csp` | The default-CSP gate — every external host in the policy `z2ui5_cl_ui5_user_exit` ships comes from its own `lv_ui5_hosts` list (SECURITY.md: "only the UI5 CDN hosts, nothing else", after general-purpose CDNs once rode along), that list holds only reviewed UI5 CDN hosts, and `script-src` is explicit and carries no `data:`/`blob:` — a data: script source turns any HTML-injection foothold into script execution (`.github/scripts/csp-default-gate.mjs`; part of `verify`, gated in `check_gates.yaml`) |
| `npm run check:draftowner` | The blank-owner draft tolerance in `z2ui5_cl_ui5_srv_draft` (legacy rows readable during the upgrade transition) carries a removal deadline — this gate holds the tolerance present through the grace window and refuses it after, so the fail-open branch in a fail-closed security control cannot outlive its own comment (`.github/scripts/draft-owner-gate.mjs`; part of `verify`, gated in `check_gates.yaml`) |
| `npm run check:release` | The release-readiness gate — the tag, `package.json`, `z2ui5_if_app=>version` and `changelog.txt` all name the same version, and the `unreleased` section is empty (the cut MOVES the entries under the version heading; a copy would publish them again next release) (`.github/scripts/release-gate.mjs`; run by `release.yaml` before anything is published, and by hand before tagging). Not part of `verify`: a normal commit is not a release |
| `npm run blockers` | What still stands between this repository and `docs/removal-plan.md`, measured over sibling checkouts you point it at (`npm run blockers -- ../samples ../samples-controls ...`). Not a gate and not part of `verify` — the siblings are not checked out here. It exists because every blocker in that plan is a caller count in another repository, and a hand-measured count silently rots. `removal-blockers.yaml` checks the siblings out and runs it monthly into its job summary |
| `npm run coverage` | What `npm run unit` covers, **per ABAP file** — the transpiler's source maps point back at the `.clas.abap`, so a JS coverage tool measures ABAP lines with ABAP line numbers. Needs the transpiled tree (`npm run downport && npm run auto_transpile`). A report, not a gate, and not part of `verify` — see "What the suite covers" |
| `npm run check:abap2ui5` | The [abap2UI5-linter](https://github.com/abap2UI5/linter) over this repository's OWN app classes — the six under `src/01/04`/`src/02` plus the test-server apps in `node/srv`. They are what an app developer copies from, so the corpus shipped to be imitated is checked with the tool shipped for imitators. Its reason for being here is `chain-house-layout`, the builder-chain layout rule (one call per line, four spaces per level, the closing call in the column of the element it closes) — nothing else formats a chain, abaplint's `indentation` does not reach into one. `npm run fmt:chains` applies it. Config and the two rule decisions: `abap2ui5lint.jsonc` (part of `verify`, gated in `check_gates.yaml`) |
| `npm run check:formatter` | The curated-formatter scope gate — the exports of `app/webapp/model/formatter.js` must match the gate's justified manifest and the module must hardcode no ValueState/icon URI (see AGENTS.md rule 19; part of `verify`, gated in `check_gates.yaml`) |
| `npm run check:app2abap` | Regenerate `src/01/03/` from `app/webapp/` and fail on drift (mirrors `check_app2abap.yaml`; regenerates in place; installs `app/node_modules` when missing; part of `verify`) |
| `npm run downport` | Downport `src/` into `node/downport/` for 7.02 compatibility (non-destructive; the step `verify` runs) |
| `npm run auto_transpile` | Transpile the downported ABAP to JS into `node/output/` |
| `npm run unit` | Run the transpiled unit tests. **Needs the transpiled tree** (`npm run downport && npm run auto_transpile`) — it is generated, not committed, and `node/setup/require-transpiled.mjs` says so instead of letting node answer `MODULE_NOT_FOUND` on a file nobody wrote by hand. `test.yaml` never hits that: its `transpile` job builds the tree once and every downstream job unpacks it |
| `npx abaplint .github/abaplint/auto_abaplint_fix.jsonc --fix` | Auto-fix formatting |
| `npm run frontend:cloud` / `frontend:cloud_v2` / `frontend:standard` / `frontend:standard_v2` | Build ONE of the four delivery trees into `tools/out/` instead of all four (`npm run frontend:build` is all four). Thin wrappers around `frontend:build -- <branch>`, kept because the published frontend README (a shared file, `check:shared`) names them |
| `npm run frontend:verify` | Compare a local build in `tools/out/` against what is published in `abap2UI5/frontend` **today** — file for file, byte for byte, stamped the way the deploy stamps them. Not the same question as `check:frontend`, which asks whether the sources still produce a valid build |
| `npm run frontend:lint` | abaplint over `frontend/abap/cloud/` — the ICF/BSP handler sources this repository ships into the delivery branches (gated in `frontend_check.yaml`) |
| `npm test` | `npm run unit` plus the JS unit specs (`check:js`) — the two suites that run without a browser, so the outside developer's first `npm test` covers the frontend modules too. CONVENTIONS §3 asks every repository in the ecosystem to answer to it (`npm run check:scripts` is the gate). It carries the same transpiled-tree prerequisite, which is the whole reason the guard exists: §3 calls these the two names an outside developer types without reading anything first, so what they answer on a fresh clone is the repository's first impression |
| `npm run express` | Start dev server on port 3000 |
| `npm run app2abap` | **Canonical** full regeneration pipeline: Prettier (`app` format) → generate → abaplint normalize. Use this after editing `app/webapp/` so only truly-changed `src/01/03/` files differ |
| `npm run auto_app2abap` | Generate ABAP string constants from `app/webapp/` (raw, **un-normalized** — prefer `npm run app2abap` instead) |
| `npm run auto_abaplint` | Run the auto-fix config directly |
| `npm run rename` | Test namespace-rename transformation via abaplint |
| `npm run auto_downport` | **CI only** — destructive variant that rewrites `src/` in place to produce the `702` branch. Never run this to validate work (AGENTS.md rule 9) |
| `npm run syfixes` | Replace `RAISE EXCEPTION TYPE cx_sy_itab_line_not_found` with `ASSERT 1 = 0` in `node/downport/` (compatibility step for 7.02 downport; `node/setup/downport-fix.mjs`) |
| `npm run strip_trailing_ws` | Strip trailing whitespace from all `node/downport/**/*.abap` files (runs as part of `downport`; `node/setup/downport-fix.mjs`) |
| `npm run downport_config` | Generate the gitignored `.github/abaplint/downport_run.jsonc` from `abap_702.jsonc` (same rules, retargeted at `node/downport/`) |
| `npm run abaplintpathfix` | Rewrite abaplint file globs in `abaplint.jsonc` after the `auto_downport` copy (`node/setup/downport-fix.mjs`) |

## Frontend Tooling (`app/`)

The `app/` folder has its own `package.json` (name `z2ui5`, `sapuxLayer: CUSTOMER_BASE`) with UI5-specific dev dependencies (`@ui5/cli`, `@ui5/linter`, `@sap/ux-ui5-tooling`, `eslint`, `prettier`). Key scripts:

| Script (run inside `app/`) | Purpose |
|---|---|
| `npm start` / `npm run start-local` | Run locally via Fiori tools with FLP sandbox |
| `npm run build` | UI5 production build |
| `npm run format` / `format:check` | Prettier |
| `npm run lint` | ESLint on `webapp/**/*.js` (eslint:recommended + `eqeqeq` "smart", `prefer-const`, `no-new-func`) |

Config files: `eslint.config.mjs`, `ui5lint.config.mjs`, `.prettierrc`, `.editorconfig`, `ui5.yaml`, `ui5-local.yaml`.

## Testing

- **Unit tests:** Embedded in source files as `.testclasses.abap`, run via abaplint transpiler in Node.js
- **Browser tests:** Playwright in `node/tests/e2e/` — Chromium, Firefox, WebKit against localhost:3000 (config: `node/playwright.config.js`; run in CI by the `browser` matrix in `test.yaml`, against the shared `transpile` job's output), plus the pinned `ui5-1.71` project (Chromium, smoke + roundtrip specs against pinned OpenUI5 1.71 via the bootstrap rewrite in `node/tests/e2e/fixtures.js` — the executable part of the 1.71 rules, see the enforcement-status note). Covers the POST/draft wire contract (`roundtrip.spec.js`), XSS regression tests for `Lib.sanitizeMessageDetails` in a real DOM (`lib-sanitizer.spec.js`), the fatal-error overlay (`error-view.spec.js` — accessibility semantics, focus management, Retry action), browser history navigation (`nav-back-forward.spec.js`) and the shell smoke test (`example.spec.js`). The transpiled Node backend renders backend-built view XML (the historical "check_on_init always false" transpiler limitation is gone since the interface-attribute access goes through a typed variable — see the comment in `z2ui5_cl_ui5_client`'s `z2ui5_if_client~check_on_init`); `roundtrip.spec.js` asserts the full cycle: initial view XML, an event roundtrip whose model delta is applied before `on_event`, and — browser-level — filling the hello-world input and asserting the rendered message box
- **JS unit specs:** the specs under `node/tests/` load the **real** `app/webapp` modules through a stubbed `sap.ui.define` (`loadModule.js`, with stubbable module dependencies) — **never test a copied function**. Which module has which spec is the inventory in **`docs/agents/test-inventory.md`**, held complete by `npm run check:specs`; it grows with every frontend change and was once the longest line in AGENTS.md. Run them without a browser: `npx playwright test -c node/playwright-unit.config.js` (`npm run check:js`)
- **Unit test metadata:** When a class has a `.testclasses.abap` file, its `.clas.xml` **must** contain `<WITH_UNIT_TESTS>X</WITH_UNIT_TESTS>`. When a class has no test file, this flag **must not** be present. Mismatches cause `local_testclass_consistency` lint errors.
- **Never skip a test with `IF sy-sysid = ` + backtick-`ABC`.** `ABC` is the system ID of the Node runtime, so such a guard makes the method a silent no-op in `npm run unit` while it still runs in a real system — CI stays green over assertions nobody executes. A test that genuinely cannot run under the transpiler belongs in the `skip` list of `node/setup/abap_transpile.json` **with a note naming the missing runtime capability**; the runner then prints it as skipped instead of pretending it passed.
- **A test class touching PRIVATE/PROTECTED members of the class under test needs `CLASS <global> DEFINITION LOCAL FRIENDS <ltcl>.`** Neither abaplint nor the transpiler enforces visibility, so the class pool compiles here and fails on activation in a real system. Gated by `npm run check_visibility` (`.github/scripts/testclass-visibility-gate.mjs`).
- **Test SICF handler:** `node/srv/zcl_sicf.clas.abap` is copied into `node/downport/` during `auto_transpile` so the Node runtime has a minimal HTTP entry point.
- **Every `FOR TESTING` method has to assert something** — `npm run check:asserts`. A method that only calls the code proves it does not dump, and a green report cannot tell that apart from a proved behaviour. `z2ui5_cl_ui5_app_start`'s `test_first` was `factory( )` into a `##NEEDED` variable for as long as the class existed; it is now four tests over the model the first request renders. Judging an assertion's *quality* stays a review's job — the gate only asks whether one is there.

### What the suite covers

`npm run coverage` answers it per ABAP file: the transpiler emits source maps back to the `.clas.abap`, so a JavaScript coverage tool measures ABAP lines with ABAP line numbers. Scoped to the engine — `src/00/01` and `src/00/02` are upstream mirrors, `src/99` is frozen, and the `src/01/03` frontend carriers are one method returning a JS/XML literal each, 100% by construction and two thirds of the line count, which would flatter the number without saying anything about the engine.

**72.6% of the engine** (8,435 of 11,623 lines, 19 files) — measured by `coverage.yaml`, which runs `npm run coverage` monthly and writes the per-file table to its job summary, so the number here has a run behind it rather than a memory. It is a report and not a gate on purpose: a threshold is a number a build starts optimising for, while the useful question is always *which* file is low and whether that matters. Three are, and only one of them is a gap:

| File | Lines | Why |
|---|---|---|
| `src/00/03/z2ui5_cl_ui5_util_context.clas.abap` | 35% of 3,175 | **The real gap** — 2,056 uncovered lines, more than the rest of the engine's misses together. It is the door to everything utility-shaped (§ "Utilities"), and most of what it offers is called by *apps*, not by the engine the suite drives |
| `src/02/z2ui5_cl_ui5_http_handler.clas.abap` | 28% of 606, **of the downported copy** | The ICF entry point. The transpiled suite comes in through `z2ui5_cl_ui5_handler` (94%) because there is no ICF request to make; the browser tests drive the rest through `zcl_sicf`. **The "`_http_get( )` is never executed" reading was an artefact, and it is now explained** — see below. Read the 28% as coverage of `node/downport/02/…`, never as a per-line statement about `src/02/…` |
| `src/01/04/z2ui5_cl_ui5_app_hi_world.clas.abap` | 29% of 56 | A demo app. Its view is exercised by the browser tests, not by the unit suite |

**Coverage line numbers are the DOWNPORT's, not `src/`'s.** This cost a while
to see, because the two files share a basename and the report prints the
`src/` path:

```
node/output/z2ui5_cl_ui5_http_handler.clas.mjs.map
  sources: [ "../downport/02/z2ui5_cl_ui5_http_handler.clas.abap" ]
```

`c8` instruments the transpiled JS and maps back through that file — and the
downporter rewrites the source on the way. One `DATA(ls_config) = …` becomes
seven `DATA` declarations plus an assignment, `COND` becomes an `IF`, a string
template becomes a concatenation. The measurable numbers (re-measured
2026-08-30 — both files grow, so measure before citing):

| | `src/02/…` | `node/downport/02/…` |
|---|---:|---:|
| the file | 669 lines | **743** lines |
| `_http_get( )` starts at | 370 | **399** |
| `_http_get( )` is | 88 lines | **105** lines |

The right-hand column is the downported count — it never was `src/`'s.
So the covered ranges are real, and reading them against `src/` shifts them by
30-odd lines and growing: `_http_get( )` looked stone cold because the lines
that ran were the *downport's* (297-387 at the time), which land somewhere
else entirely in the source. The tests were fine all along.

What this does **not** settle is whether the cold-line count of the downported
file is the right statement coverage; that needs a run, and the figure is only
ever about that file. `npm run coverage -- --detail <file>` prints the cold ranges
against `node/downport/<rest>` and says so, which is why it reads that copy
rather than the source.
