# CI/CD workflows (`.github/workflows/`)

> Extracted from `AGENTS.md`, which points here. What an agent has to know
> before it looks anything up is that these gates exist and that a green run
> is what a pull request needs; WHICH workflow decides WHICH rule is a lookup,
> and AGENTS.md is loaded into every session. Every fact below was in that
> file unchanged.

Grouped by purpose. Several groups below name the same workflow: the static
gates are one job (`check_gates.yaml`), one step per rule, because each of
them is a Node script that finishes in well under a second and nine separate
workflows spent about two minutes of CI on runner starts to run one second of
work. The steps are `if: ${{ !cancelled() }}`, so a pull request that trips
three of them reports all three at once instead of one per push. The groups
stay separate here because they are separate rules — the table describes what
is enforced, not how many runners enforce it. Every job takes its toolchain
from the composite action `.github/actions/setup` (Node version, pinned action
sha, the `npm ci` / `app` / `deps` installs).

| Group | Workflows | Purpose |
|---|---|---|
| **Frozen-path guard** | `check_gates.yaml` | Fails any PR that edits a file under `src/99/` in place, or deletes one whose object ships nowhere else under `src/` — the package is history only (see "Layered Design") |
| **API-contract guard** | `check_gates.yaml` | Fails any PR that removes or changes a public symbol of `src/02/` (rule 5); additions must be recorded in `.github/api-snapshot.json` via `node .github/scripts/api-snapshot.mjs --write` |
| **Compatibility checks** | `ABAP_702.yaml`, `abaplint.yaml` | Lint against each ABAP target environment. `abaplint.yaml` is the pull-request run (standard, cloud, house format, namespace rename); `ABAP_702.yaml` lints the downported 702 branch, which is why it stays separate — different ref, different trigger |
| **Frontend checks** | `UI5_2X.yaml` | Three steps over `app/webapp/`, each the npm script of the same name so CI and a local run are one spelling: `npm run check:ui5` (the UI5 linter via `.github/scripts/ui5lint-gate.mjs`, zero-error policy — accepted findings are suppressed at the source), `app`'s `npm run lint` (ESLint) and `npm run check:types` (`tsc`, no emit) |
| **Conventions** | `check_gates.yaml` | Every object name outside `src/02` (public contract) and `src/99` (frozen) carries the `ui5` segment — `z2ui5_cl_ui5_*` for the engine, `z2ui5_cl_ui5f_*` for the generated frontend. abaplint only checks the `z2ui5` prefix, so this is the gate that keeps a new segment from drifting in |
| **Dynamic names** | `check_gates.yaml` | Every `Z2UI5_*` object named by a string literal exists in `src/`. Nothing else resolves those names — the lookups behind them read SEOCLASS/XCO, which the transpiler does not have, so a literal naming nothing returns an empty result and the caller reads it as "not implemented" (how #2564 silently disabled every user exit) |
| **UI5 1.71 icons** | `check_gates.yaml` | Every `sap-icon://` name shipped under `src/` or `app/webapp/` exists in the 1.71 icon font. Nothing else checks an icon name: UI5 renders no icon for one it does not know and says nothing, so a post-1.71 glyph is invisible on the oldest supported release and green everywhere in CI (rule 21) |
| **Tests** | `test.yaml` | Unit tests, Node transpile tests, JS unit specs + Playwright browser tests, over one shared `transpile` job — all three used to run `downport` + `auto_transpile` themselves, which was the same work three times. The four Playwright projects are a matrix (`browser (chromium)` …); `test_browser` is the aggregate that stays requirable. The namespace-rename test lives in `abaplint.yaml`, which already had the toolchain it needs. Two jobs run the conformance suites of [abap2UI5/protocol](https://github.com/abap2UI5/protocol), checked out at a pinned commit of its main: `conformance_backend` packs `@abap2ui5/node-runtime` from the shared transpile (whose artifact carries `node/downport` for it), installs the tarball into the protocol package and runs its backend suite (`scripts/run-conformance.mjs node-runtime`, the `Z2UI5_CL_CONF_*` apps built by the protocol's own host script); `conformance_frontend` runs the frontend suite with the `ui5` adapter against `app/webapp` in Chromium. A MUST failure fails either job; bump the pinned ref deliberately, in both jobs |
| **Assertions** | `check_gates.yaml` | Every `FOR TESTING` method asserts something. A test that only calls the code proves it does not dump, and nothing in a green report distinguishes it from one that proves a behaviour — `z2ui5_cl_ui5_app_start`'s `test_first` was `factory( )` into a `##NEEDED` variable for as long as the class existed. The check is deliberately shallow (does the body assert, raise, or delegate to a helper of its own test class); judging an assertion's quality is a review's job |
| **Automation** | `auto_downport.yaml`, `auto_abaplint_fix.yaml`, `autofix.yaml` | `auto_downport.yaml` rebuilds the `702` branch on every push to `main` that touches `src/` or the downport tooling (paths-scoped - a docs-only push changes none of its inputs); it lints the rewritten tree with the 702 config **before** force-pushing, and its commit carries a `Source-Commit:` trailer naming the `main` commit it was built from - the provenance `release.yaml` asserts on before tagging the branch; `auto_abaplint_fix.yaml` is the weekly `abaplint --fix` pull request. `autofix.yaml` is the on-demand one: a `/fix` comment on a pull request (or the `autofix` label) runs every generator the gates check — `npm run app2abap`, `auto_abaplint`, `fmt:chains`, `backlog` — and commits the result back to the branch, so a PR that trips four gates is one command from green instead of four local toolchains. `/fix chains backlog` limits it to a subset; `abaplint` is a scope of its own because reaching that same `abaplint --fix` through `app2abap` costs the Fiori `npm ci` and a full `src/01/03` regeneration first (asking for both folds into one run). It replaced a workflow that ran the same regeneration on *every* push to *every* pull request, whose bot commit kept landing while the author was still working. Fork pull requests are refused with the local command line rather than half-served: the `GITHUB_TOKEN` cannot push to a fork's branch. `auto_downport` and `api-snapshot --write` are deliberately not in the set — the first rewrites the branch under review, the second would turn the API gate into a formality |
| **Generation** | `check_app2abap.yaml` | Drift gate on the pull request AND on `push: main`: it runs `npm run check:app2abap`, which regenerates `src/01/03/` from `app/webapp/` and fails when the command changes anything at all — measured before/after over the whole tree, not as a diff scoped to the generated paths, because `app2abap` ends in the unscoped autoformatter (the reasoning is `app2abap-gate.mjs`'s header). The fix paths are `npm run app2abap` locally or `/fix app2abap` on the PR (`autofix.yaml`). A `create_app2abap.yaml` used to regenerate from main after every push and open a bot PR - with this gate green on both sides it could only ever open an empty one, so it is gone |
| **Renamed variants** | `build-rename.yaml` | On demand (`workflow_dispatch`): rename all artifacts to a chosen namespace (max. 10 characters) via `abaplint --rename` with `.github/abaplint/rename.jsonc` and push the renamed sources to the branch `rename_<name>` (re-running updates the branch; no push without content changes) |
| **Mirroring** | `vendor-mirror.yaml` | Sync `src/00/01/` (AJSON) and `src/00/02/` (S-RTTI) from their upstream mirror repos and open a PR with the diff — one monthly workflow, one matrix leg per mirror, so a third mirror is a line rather than a file |
| **Release** | `release.yaml` | One tag push cuts both releases: `X.Y.Z` from `main` and `X.Y.Z-702` from the downported branch. It re-checks the tag against `package.json`, `z2ui5_if_app=>version` and `changelog.txt`, runs the full `npm run verify` on the tagged commit, and uses the changelog section as the release notes so the two cannot disagree. Releases were cut by hand before, and the cost showed downstream rather than here: the newest tag predates the view builder every sample repository teaches, so `app-template` cannot pin the framework to a tag at all. `RELEASING.md` is the human half |
| **Prebuilt backend** | `backend-prebuilt.yaml` | Dispatched by `release.yaml` right after it publishes a release (a `release: published` event from the workflow's own token starts no workflow, so the trigger of that name only serves a release made by hand), and on `workflow_dispatch` with a `tag` to re-attach for a past one or after a failed run: checks out the tag, runs `npm run downport`, `npm run auto_transpile` and `npm run unit` as the proof that the transpiled tree boots, then `npm run pack:backend` and attaches `backend-<version>.tar.gz` to that release (`gh release upload --clobber`). The tarball is `node/downport`, `node/output` and `node/deps` (without their `.git` directories) plus a `backend-manifest.json` at its root (version, commit, build time, node and transpiler versions, contents) — what `abap2UI5/mcp-server`'s `build_backend` otherwise produces itself in a tens-of-minutes first full build, so a consumer downloads it instead. **The asset name and the manifest are a contract that repository reads: renaming either is a change over there.** Only the `X.Y.Z` release gets it, not `X.Y.Z-702` (that release is the downported sources; the backend is built by downporting the same commit anyway). The asset appears a while after the release exists — `release.yaml` does not wait for it. The same job also packs and publishes the npm package `@abap2ui5/node-runtime` — the section below the table |
| **Chain layout and render** | `render-gate.yaml` | The linter's render gate over this repository's OWN app classes — a pull-request gate on `src/**`, `abap2ui5lint.jsonc` and `package-lock.json` (the lock decides WHICH linter renders), plus a push-to-main leg and `workflow_dispatch`. It is not the same test as `node/srv`'s Playwright suite: that proves the SHIPPED apps work end to end, this proves every view a class builds survives a real `XMLView.create`, including the ones no shipped app routes to. `@abap2ui5/linter-render` (`@abap2ui5/render-runtime` up to 0.7.0) is ~123 MB of UI5 and is installed in this job only, deliberately not as a devDependency |
| **Linter pin** | `bump-linter.yaml` | Weekly (Mondays, before the three sample corpora): moves `@abap2ui5/linter` in `package-lock.json` to `latest` and opens a pull request. It tracks `latest` rather than the declared range because the range is the thing being maintained — a linter release that adds rules is additive for the linter and breaking for a corpus, so a range that pins the corpus out of new rules is the failure, not the protection. Both halves run **before** the pull request exists (`check:abap2ui5` and `check:render`), so a rule regression fails the workflow instead of landing on `main`. Two jobs: the one that installs and runs the freshly published package holds `contents: read` and a checkout without credentials and hands the two changed files over as an artifact; the one that opens the pull request holds the write token and runs nothing from npm - a bad linter release fails the workflow, it cannot push |
| **Supply chain** | `dependency-review.yaml`, `npm-audit.yaml`, `codeql.yaml` | `dependency-review.yaml` reports on what a pull request ADDS to the dependency tree — a known-vulnerable package or a copyleft licence fails the change that introduces it, and nothing is said about what was already there (root and `app/` lockfiles both; `fail-on-severity: moderate`, because `low` would be red most weeks on a transitive dev-dependency advisory and train everyone to click past it). `npm-audit.yaml` is the other half - what the two lockfiles ALREADY carry, weekly and on lockfile changes, through `.github/scripts/npm-audit-gate.mjs` (`npm run check:audit`): the known high advisories are accepted in the script with the reason each one can stay (today all of them sit under `@ui5/cli` -> `@ui5/project`, where the only fix npm offers is a major downgrade), and the gate fails on a NEW high/critical one or on an accepted one whose fix has arrived, so the list only shrinks. `codeql.yaml` is static security analysis of the JavaScript this repository OWNS — `app/webapp/` (embedded verbatim into `src/01/03` and built into the delivery trees, so it runs in every user's browser), `.github/scripts/` (which decide whether a pull request merges) and `tools/` (which write what is delivered) — scoped by `paths` so the generated copies do not triple every finding. On pull requests, on `push: main` and monthly, because the query pack moves on its own schedule. Neither ui5lint nor ESLint models taint, and nothing else here looks for an injection path at all |
| **Coverage** | `coverage.yaml` | Monthly (and on dispatch): `npm run coverage` over the downported/transpiled tree, with the per-file table written to the job summary and kept as an artifact for 90 days. Deliberately not a gate and deliberately not per pull request — a threshold is a number a build starts optimising for, while the useful question is which file is low and whether that matters. It exists because the figure in "What the suite covers" (`docs/agents/commands.md`) was hand-measured and dated, which is the one kind of claim this repository gates everywhere else |
| **Removal blockers** | `removal-blockers.yaml` | Monthly (and on dispatch): the measurement half of `docs/removal-plan.md`'s ratchet — it checks out the four sibling corpora (`samples`, `samples-controls`, `samples-stack`, `app-template`) and runs `npm run blockers` over them, writing the caller count behind every tracked obsolete symbol to the job summary. A report, not a gate: the counts are about other repositories, and a count going up is a finding for a person, not for a build. It exists because every number in that plan was hand-measured once and silently wrong afterwards |
| **Backlog polling** | `backlog-filed.yaml` | Monthly (and on dispatch): `npm run backlog:filed` — what GitHub says about every backlog item with `state: filed`, written to the job summary. A report, not a gate: a `filed` item is a claim about another repository, and the backlog cannot see when that claim stops being true; the script existed and no workflow ran it, so the answer depended on somebody remembering the command. Deletes nothing — removing a shipped item is the same human step as creating one |
| **Downstream sync** | `trigger_local.yaml` | On every push to `main` it refreshes the `input/` copy in [abap2UI5-local](https://github.com/abap2UI5/abap2UI5-local) and pushes it to its `main` via deploy key (secret `ACTION_KEY_LOCAL`), which rebuilds its artifact branches |
| **Frontend delivery** | `frontend_check.yaml`, `frontend_deploy.yaml`, `check-v2-sdk.yaml` | `frontend_check.yaml` is the pre-merge gate the two-repository split made impossible: on every pull request touching `app/`, `frontend/`, `tools/` or the npm dependencies it builds a renamed variant, then the four delivery trees into the git-ignored `tools/out/` and checks the BSP page invariants over every tree there (`npm run check:frontend` = `frontend:build` + `tools/check-pages.mjs`, one spelling of the gate for CI and a local run), then lints the generated standard tree. No tree is committed in this repository — the durable copies are the `result/<branch>` folders on abap2UI5/frontend's `main`. `frontend_deploy.yaml` publishes into [frontend](https://github.com/abap2UI5/frontend) via deploy key (`ACTION_KEY_FRONTEND`; GitHub's SSH host keys are literals in the workflow with their fingerprints, not `ssh-keyscan`ned at run time - a job holding a write credential does not learn the host it pushes to from the network) — it runs the SAME build on `main`, stamps the provenance (`tools/branch-stamp.mjs`) and writes the four trees as `result/<branch>` folders into ONE commit on that repository's `main`, on every push to `main` here that touches what the build consumes, plus a monthly safety-net cron; frontend's own `deliver` workflow then fans each folder out into its branch as one commit parented on that `main` commit, so every published branch is always exactly one commit ahead of `main` over there and `main`'s history tracks every delivered change. A renamed `standard_<name>` (not tracked in `result/`, built on the spot) is pushed onto its branch directly on dispatch, parented on that `main` too. A run whose content matches what `result/` already carries pushes nothing — the candidate is stamped with the commit the published `VERSION` names, so a provenance-only difference is not a commit — and the commit that is written carries the subject of the `main` commit behind it. `check-v2-sdk.yaml` is the monthly guard on the CDN version the v2 branches bootstrap from (`tools/app2app_v2/patch-v2.mjs`) |

## The transpiled framework is a package (`@abap2ui5/node-runtime`)

> Extracted from `AGENTS.md`, which keeps the one-line statement (the manifest
> is `node/setup/npm.package.json`, deliberately not `node/package.json`)
> and points here.

`backend-prebuilt.yaml` packs the transpiled tree **twice**, from one build.
The release tarball (`backend-<version>.tar.gz`, `npm run pack:backend`) is the
first; `npm run pack:node-runtime` (`node/setup/pack-npm.mjs`) at the end of the
same job is the second: the npm package **`@abap2ui5/node-runtime`**,
assembled in a staging directory outside the checkout from `node/output`,
`node/setup/setup.mjs` (the hook `output/init.mjs` imports by the relative
path fixed in `node/setup/abap_transpile.json`), `node/setup/own-apps.mjs`
(the bin `abap2ui5-own-apps`: a host's own transpiled classes out of a
transpile's output, their imports pointed at the package's `output/` - the
transpile writes a second copy of every library object next to them, and
importing that copy replaced the package's `CX_ROOT`), `node/setup/transpile.mjs`
(the bin `abap2ui5-transpile`: the README's whole "Your own apps" recipe as one
command - the transpiler at the recorded version, open-abap-core at the
recorded commit, the config, the transpile, `own-apps` - so that mcp-server,
cap2UI5 and cap2UI5/samples stop carrying their own copy of it; `--check`
runs the host's classes through it), **`node/srv/host.mjs`** (the
entry point, below), `node/srv/*.d.ts` (hand-written TypeScript declarations
for the three entry points, named by `types` in the manifest and on every
`exports` entry; `pack-npm.mjs` copies an explicit list of files, so it also
checks that every file the manifest points at - a bin, `types`, an export
target - is in the tarball), `node/srv/accelerate.mjs` (`accelerate()`, which
installs nothing since `@abaplint/runtime` 2.13.96 and says whether the runtime
is linear on large tables - kept as the `./accelerate` subpath for the hosts
that call it), `node/srv/compress.mjs` (the gzip middleware `createApp()` puts in
front, and the `./compress` subpath), `node/downport` (so a host can
transpile its own app
classes with the framework as a library - the README's "Your own apps") and
`node/setup/npm.README.md`. `node/setup/npm.package.json` is its manifest.
**It is deliberately not `node/package.json`:** a `package.json` inside
`node/` makes that directory an npm package root, so `npm run <script>` from
there stops walking up to this repository's scripts — `cd node && npm run
express` answers *"Missing script"*, which is what `node/playwright.config.js`
starts its web server with, and all four browser projects fail to boot. The
version is the framework's, set at pack time (the committed
`0.0.0-set-at-pack` is deliberate); the two `@abaplint` dependencies are
pinned to the **exact** versions in `package-lock.json`, because transpiler
output is tied to its runtime; the transpiler version, the commit, the build
time and the open-abap-core commit the transpile read (`node/deps`, at its
`fetch-deps.mjs` pin) go into the manifest's `abap2ui5` field - the last so a
host type-checks its own apps against the same standard library.

**It carries no browser-test fixture.** `prepare-transpile` folds every
ABAP class of `node/srv` into the transpile, so `node/output` holds the
`zcl_tst_*` apps the Playwright projects drive and `output/init.mjs` loads
them at boot - packed as they were in 1.145.0, every host started them on
`?app_start=`. `pack-npm.mjs` leaves out every `node/srv` object but
`zcl_sicf` (derived from the folder, not from a prefix), strips their imports
and TADIR rows from `init.mjs` / `_init.mjs`, and refuses to pack when any
fixture name is still in a file name or a file of the tarball. The checkout
keeps them: `npm run express` and the browser projects run the unstripped
tree.

**It carries no unit tests and no source maps.** The manifest's `files`
leaves out `output/*.testclasses.mjs`, the generated runners `output/index.mjs`
and `output/_unit_open.mjs`, every `output/*.map` and
`downport/**/*.testclasses.abap`: the framework's own suite runs here
(`npm run unit`), nothing a host loads or transpiles against was in those
files, and they were a third of the 21 MB every CAP project and every MCP user
installed per release (1.146.0). `pack-npm.mjs` refuses a tarball that carries
any of them, as it refuses one missing a file a host expects.

**It carries no `webapp/`, on purpose.** The GET page the framework serves
embeds the whole component - every module, view and stylesheet - from the
constants in `src/01/03`, which are transpiled with everything else, so the
page and the roundtrips come from one commit by construction and a Node host
needs no frontend files.

**`node/srv/host.mjs` is the entry point, and `npm run express` runs through
it.** It exports `initialize()`, `createHandler()`, `createApp()`, `serve()`,
`exclusive()`, `withSession()`, `configureSessions()`, `sessionCount()`,
`accelerate()`, `compress()` and `HANDLER_CLASS`; `createHandler()`
queues the requests through `exclusive()` - one in the framework at a time,
because its per-request class-data and the shim's static server object exist
once per process here, not once per roll area (`node/tests/concurrency.spec.js`,
which `test_node` runs; the header of `host.mjs`, "ONE REQUEST AT A TIME", has the rest),
and runs each in its stateful session through `withSession()` - the host is
the ICF's session layer here: it keeps the sticky handler per `sap-contextid`
it issued and swaps it in and out around each request
(`node/tests/sessions.spec.js`, which `test_node` runs; "STATEFUL SESSIONS" in
the header of `host.mjs`); `initialize()` calls
`accelerate()`, which installs nothing - `@abaplint/runtime` from 2.13.96 on
has the linear LOOP ... WHERE over a sorted primary key and CP itself - and
warns once on an older runtime (`node/tests/accelerate.spec.js`; the file's
header has the rest); `createApp()`
puts `compress()` in front, the gzip the framework asks the ICF for and the
express shim cannot give it, under an Apache-style `"<tag>-gzip"` ETag the
framework's own `_check_etag_match` answers with a 304
(`node/tests/compress.spec.js`, whose framework half `test_node` runs); `express.mjs` is the lines that call `serve()` with
`PORT`/`HOST` and print the log line `mcp-server` waits for ("Listening on").
One code path for the dev server and the package, so what CI drives in the
browser projects is what a host installs. It is packed as `srv/host.mjs` next
to `output/` and `setup/` — the same neighbours it has in the checkout — so its
relative imports need no rewriting. `express` is an optional peer, imported
lazily by `createApp()`/`serve()` only, and its range is **`^4.21.0 ||
^5.0.0`**: `@sap/cds` and `@cap2ui5/cds-plugin` accept express 4, and a peer
range without the host's major makes npm nest a second express (and some
eighteen dependencies) just for this package. So `host.mjs` uses nothing one
major lacks - `app.use(handler)`, not express 5's `/{*path}` route syntax -
and its header says what else. `--check` installs the tarball into a scratch
project with the pinned `@abaplint/transpiler-cli` and, **once per range of
the express peer**, drives it: `serve()` answers GET / with the component
embedded - gzipped, and revalidated to a 304 by its `-gzip` tag - and a POST
roundtrip, `createApp()` does the same mounted under
`/sap/bc/z2ui5`, no `ZCL_TST_*` is registered, the classes the scratch
project transpiles against `downport/` and open-abap-core at the recorded
commit - an exception class of its own among them - load through
`abap2ui5-own-apps` with the package's `CX_ROOT` still in place, start, and
what they raise the framework catches, the runtime the package pins is linear on
large tables (`accelerate()` says so and changes nothing), and
`serve()` rejects on a port that is taken.

**Publishing is trusted publishing (OIDC), with a bootstrap.** The job holds
`id-token: write`, pins the npm that can publish that way, and hands the
tarball to `.github/scripts/npm-publish.mjs`. npm can only be pointed at a
workflow for a package that already exists, so the first version is published
by hand from the workflow artefact (RELEASING.md, "One-time setup — the npm
package"); until then the script ends in a **warning** and the run stays
green. Once the package exists, a failed publish is an error; a version
already there is a no-op, so a re-dispatch for a tag does not go red. A stored
`NPM_TOKEN` still works and takes precedence.

**The name.** Drafted first as `@abap2ui5/runtime` (next to the linter's
unrelated `@abap2ui5/render-runtime`), then as `@abap2ui5/node`; neither was
ever published. `node-runtime` says what a consumer does with it: run
abap2UI5 in Node.

Why a package AND a release tarball: the tarball is resolved by NAME from a
GitHub release and carries `node/deps` and `node/downport`, which is what a
tool that downloads and builds against it needs (`abap2UI5/mcp-server`). A
host that merely RUNS the framework — cap2UI5, a container, a serverless
function — is an ordinary Node project and already has `npm i`. Both ride
`backend-prebuilt.yaml` rather than `release.yaml` because the downport and
the transpile have already run there.

**A second package rides the same workflow: `@abap2ui5/bsp`** (`tools/bsp/`),
a UI5 app as an abapGit BSP and back — the code `frontend:build` writes the
BSP `Z2UI5` with, published so any other UI5 app can take the same way into a
system. Its job `bsp` in `backend-prebuilt.yaml` needs none of the transpile:
it tests the package (`npm run test:bsp`), packs it with the framework's
version and proves the tarball by installing it (`npm run pack:bsp -- --check`),
uploads it as an artefact and hands it to the same `npm-publish.mjs`, with the
same bootstrap — the first version by hand, then trusted publishing for
`backend-prebuilt.yaml` (RELEASING.md).

What the package promises is only what `host.mjs` and `output/init.mjs`
promise: everything else in `output/` is transpiler output, and its shape —
the static `ATTRIBUTES`/`METHODS` maps, `constructor_( )`, `~` becoming `$` —
is `@abaplint/transpiler`'s, not ours. A host that reaches into it couples to
the transpiler, and should say so in a test of its own.

> **Both downstream repositories are generated, never edited.** That rule is a
> prohibition rather than a lookup, so it stays in `AGENTS.md` (end of the
> "CI/CD Workflows" section) where it is in context before the mistake, and is
> deliberately not repeated here.
