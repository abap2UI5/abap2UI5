# Conventions

The rules every repository in the abap2UI5 ecosystem follows. This file is the
source; `npm run check:shared` in this repository holds the copies in the
consumer repositories against it.

Why it exists: the same job was named three ways across sibling repositories
(`publish-702`, `auto_downport`, `create-package-branches`), `npm run check` ran
a different set of steps than CI in three repositories, and two repositories
linted with different abaplint versions. Every rule below was written after one
of those cost someone an afternoon.

## 1. Repository roles

Every repository is exactly one of four kinds, and its README says which in the
first paragraph.

| Role | Meaning | Examples |
| --- | --- | --- |
| **Source** | Humans and agents edit here. CI gates every change. | `abap2UI5`, `linter`, `web-abap2UI5` |
| **Channel** | Generated and pushed by a workflow. Never edit. | `frontend`, `web-abap2UI5-build`, `app-template` |
| **Product** | Ships on its own release cycle to npm, Marketplace or an action. | `linter`, `vscode-extension`, `mcp-server` |
| **Corpus** | A body of installable example code, installed on its own. | `samples`, `samples-controls`, `samples-stack` |

These rules bind the `abap2UI5-addons` organisation as well as `abap2UI5`. They
did not until 2026-08-20, and the drift that bought is the reason the sentence
is here: eleven repositories with their own workflow naming, three different
abaplint pins, no `check` script between them, not one scheduled run — and one
that shipped for ten days against a class that exists in no repository, behind
a green badge, because nothing re-ran its CI.

Rules that follow from the role:

- A channel repository carries a README whose first line says it is generated,
  names the workflow that writes it, and says where to file bugs. Its issues are
  disabled. A `-build` suffix in the repository name means channel, always.
- The role is what the README states, not what the name suggests. Only the
  `-build` suffix carries meaning; nothing else in a name is constrained. In
  particular `builder-cap2UI5`, `builder-cap2UI5-web` and `builder-abap2UI5-js`
  are sources that BUILD a channel — the opposite of a `-build` repository —
  and they keep their names.
- A source repository never carries a hand-maintained copy of content another
  repository owns. Either generate it, or gate it (section 5).

## 2. Workflows

- File name: lower kebab case. The extension follows whatever the repository
  already uses — a new workflow in a `.yaml` repository is `.yaml`; only a
  repository starting fresh picks `.yml`. A mass rename across a repository
  retitles every required status check at once, so rename only when the file is
  being reworked anyway, and say so in the pull request so branch protection
  can be moved with it.
- Gated in `abap2UI5` by `npm run check:conventions`, with the names that
  predate the rule listed as exceptions by name — including `UI5_2X.yaml`, the
  file this section names as its own bad example. The list only shrinks: an
  entry for a file that no longer exists fails, so a rename drops its exception
  in the same change. What the gate buys today is that the next workflow is
  named by the rule rather than by the exceptions around it.
- The `name:` must be recognisable from the file name. It is what branch
  protection and the checks list show, so a reader who sees a red check has to
  be able to find the file it came from. `ci.yml` → `CI` and
  `bump-linter.yml` → `Bump linter` are fine; `UI5.yaml` → `UI5_2X` was not,
  because nothing connects the two. Repositories whose workflows are technical
  gates use the file name verbatim; the JavaScript-side repositories use a
  readable sentence, and both are correct as long as the pairing is obvious.
- A workflow name never carries a count or a version ("samples-controls corpus
  (416 ports)"). It is the one string nothing re-measures, and it is on every
  pull request.
- Verb prefixes, in this order of preference: `check-` (proves a property),
  `build-`, `publish-`, `deploy-`, `bump-` (moves a pin), `release`, `test`.
  The same act carries the same verb in every repository.
- One concern per workflow file, so one badge means one thing. A workflow that
  bundles unrelated jobs turns every badge into "something, somewhere, is red".
- Third-party actions are pinned to a commit SHA with the version in a trailing
  comment: `uses: actions/checkout@3d3c42e5… # v7.0.1`. Dependabot is configured
  to group updates and to leave deliberately pinned actions alone.

## 3. npm scripts

- **Every repository has `check` and `test`.** They are the two names an
  outside developer types without reading anything first, and "Missing script"
  is a bad first answer. `check` exists in all twenty-two repositories as of
  2026-08-28; it reached the ten `abap2UI5` ones on 2026-08-18, and the eleven
  `abap2UI5-addons` ones when they were brought into these rules. `playground`
  was the twenty-second, added on 2026-08-28: it had never been on the gate's
  list, and it had no `check` at all — the rule holds only over the repositories
  somebody remembered to enumerate.
- `check` runs what CI runs on a pull request. A step that exists only in
  `package.json` is a step no pull request has to pass; a step that exists only
  in a workflow is one no contributor can run before pushing.
- A CI step `check` leaves out must need something a checkout does not have — a
  browser download, a full downport, a sibling repository's `main` — and the
  repository's `AGENTS.md` must name it and say why. Anything else and `check`
  quietly means something narrower in one repository than in the next, which is
  the failure this rule exists to prevent. Today: `vscode-extension` omits
  `test:web` (downloads VS Code web + chromium), `samples-controls` omits
  `gates:full` and the two downport lint configs, `web-abap2UI5` omits the
  Playwright e2e run, `playground` and `linter` omit the Chromium download their
  own tests then ask for by name, and `linter` also omits `codeql`, the
  composite-action job and the publish-shaped `package` job.
- `test` runs the repository's own tests. Where there is no separate test suite
  — the corpora are checked, not unit-tested — `test` is `npm run check`, so
  that the universal command still answers.
- The first two rules are gated: `npm run check:scripts` in this repository
  reads all twenty-two `package.json` files (sibling checkout, else raw main,
  else say so and pass) and fails naming any repository that has lost either
  script.
  Prose is not a thing that fails a pull request, which is why five of them
  drifted out of the rule before anyone noticed.
- Namespaces use a colon: `check:chains`, `fmt:chains`, `bump:linter`. No
  snake_case script names, no bare verbs for anything a namespace fits.
- Scripts that rewrite files are `fmt:*` or carry `--write`/`--fix`; their
  read-only counterpart is `check:*`. The same name means the same program in
  every repository.
- Node scripts are ESM `.mjs`, live in `scripts/`, and are runnable directly
  (`node scripts/<name>.mjs`).

## 4. Toolchain

- `engines.node` is `>=22` and `.nvmrc` says `22`. **Gated** since 2026-08-28 by
  `npm run check:toolchain` in this repository, which reads every repository on
  the list (sibling checkout, else raw `main`, else say so and pass). It was
  written because this section was the only one nothing decided, and the cost
  was measurable: **seven of the nine** repositories had no `.nvmrc`, and
  `playground` declared neither it nor `engines` while its AGENTS.md asserted
  "Node 22, matching the rest of the organisation" in prose. Drift that predates
  the gate is named in its `EXCEPTIONS` list, which only shrinks.
- `license` is set in every `package.json`; the LICENSE file is MIT and names
  the same holder across the organisation.
- `@abaplint/cli` and `@abap2ui5/linter` are on the same version in every
  repository that lints ABAP. A repository that pins deliberately (because it
  must match what another repository syntax-checks with) says so in a comment
  next to the pin.
- `@abap2ui5/linter` and `@abap2ui5/render-runtime` ship from one tag and are
  installed on the same minor line. A runtime older than the snapshot the linter
  was built against serves controls the gate then judges by metadata it does not
  have.

## 5. Shared content

Anything that exists in more than one repository is either generated or gated —
never both hand-maintained and copied.

- This repository owns the shared sources: `.github/abaplint/app-rules.json`,
  `.claude/skills/view-chain-layout/SKILL.md`, `docs/agents/building-apps.md`,
  `.github/shared/*`, and this file.
- `.github/scripts/shared-file-gate.mjs` holds every consumer against its
  source. It resolves a sibling checkout first, falls back to
  raw.githubusercontent, and passes with a message when neither is reachable —
  a gate that cannot see the source must not fail a pull request.
- A consumer that must differ declares the difference in the gate's deviation
  list, with a reason. An undeclared difference is indistinguishable from drift.
- Numbers quoted in prose (corpus sizes, app counts) are checked against the
  generated `SAMPLES.md` / `STATUS.md` that own them. Prose is not a place to
  keep a number nobody re-measures.

## 6. Documentation files

| File | Where | Contains |
| --- | --- | --- |
| `README.md` | every repository | What it is, who it is for, how to start. Understandable in 30 seconds by someone who has never seen the project. |
| `AGENTS.md` | every source repository | The single source of truth for agents. Opens with "Single source of truth for agents working on…". |
| `CLAUDE.md` | every repository that has `AGENTS.md` | A pointer to `AGENTS.md`, nothing else. Gated in `abap2UI5` by `check:conventions`. Claude Code reads `CLAUDE.md` and nothing else by that name, so guidance without one is invisible to it. |
| `CONTRIBUTING.md` | every source and corpus repository | How to propose a change, and what CI will check. |
| `SECURITY.md` | every repository that ships code | Where to report a vulnerability. |
| `CHANGELOG.md` | every product repository | Keep-a-Changelog format, `## Unreleased` on top. |
| `RELEASING.md` | every product repository | The human checklist; the mechanics live in `release.yml`. |

English for code, comments, commit messages, pull requests and issues. All text
files are LF-only, enforced by `.gitattributes` in every repository that carries
ABAP or generated trees.

## 7. Commits and pull requests

- Subject in the imperative, describing the outcome, not the mechanics: "Hold
  the corpus counts to the corpora that own them", not "update script".
- The pull request title becomes the squash subject; replace generated branch
  names before merging.
- Machine commits in pipeline repositories keep their verb prefix, and the
  prefixes mean the same thing everywhere: `mirror:` (copy an upstream tree in),
  `transpile:`, `prepare:`, `build:`, `trigger:` (poke a downstream repository),
  `deploy:` (publish an artifact).
- One topic per pull request.

## 8. ABAP naming

- Classes `^Z2UI5_C(L|X)`, interfaces `^Z2UI5_IF`, enforced by `abaplint.jsonc`.
- The segment after the prefix says which body of code an object belongs to:
  `z2ui5_cl_ui5_*` for the framework engine, `z2ui5_cl_smp_*` / `z2ui5_cl_smpc_*`
  / `z2ui5_cl_smps_*` for the three corpora. One segment means one thing; when a
  segment starts meaning two things, rename rather than overload it.
- Sample numbers are allocated per repository, not globally. The class prefix is
  what makes a number unique — prose names a sample by its class, never by its
  number alone.

## 9. Which abap2UI5 a repository builds against

Every repository outside the framework itself resolves abap2UI5 from somewhere,
and the wrong default is the same everywhere: an unpinned git dependency clones
the DEFAULT branch, so the repository silently builds against the development
tip. That hides two defects at once — code that only works on `main` passes,
and a framework change reddens repositories that did not change.

Which pin a repository takes follows from what it is FOR, not from taste:

| Purpose | Pins | Moved by |
| --- | --- | --- |
| **Teaches a reader** — documentation examples, the starter template, the hand-maintained corpora | the release **tag** | a weekly bump that re-runs the gates at the new release before opening the PR |
| **Canary** — the generated corpus, the playground | a commit **SHA** | a weekly bump that proves the new pin, with a separate nightly run against `main` tip |
| **Mirror** — the delivery and single-class builds | `main`, by push | the framework's own workflows; these repositories *are* the framework |

Rules:

- Nothing resolves the default branch implicitly. A repository that genuinely
  wants `main` says so with a key and a comment, so it reads as a decision.
- A repository that teaches pins the release its readers have. `main` is ahead
  of that by design: `z2ui5_cl_ui5_view_builder` was on `main` from 2026-08-12
  and in no release until 1.143.0 three weeks later, and for those three weeks
  five repositories could teach an API no reader could install.
- A pin nobody moves is its own defect. Every pin has a bump workflow that
  re-runs that repository's gates at the new version *before* the pull request
  exists, so a framework change that breaks a consumer fails in the bump rather
  than on somebody's unrelated pull request.
- One repository, one framework version. When several configs carry the pin,
  a gate holds them equal — a forgotten config linting against a different
  release is exactly the drift the pin was supposed to end.

One consequence of the tooling, stated rather than hidden: abaplint's
`"branch"` key feeds `git clone --branch`, which takes a branch name or a tag
and **never** a commit SHA. A repository pinned by SHA therefore cannot express
that pin to abaplint at all — and leaving the key off does not centralise the
pin, it removes it, because abaplint then clones the default branch.

So such a repository resolves the framework more than once, on purpose, and
says which reference answers which question. `samples-controls` is the worked
example: `A2UI5_PIN` (a SHA) for the transpiled backend and the e2e smoke, a
release tag in the abaplint configs for whether the corpus compiles against the
framework its readers installed, and `main` tip in the nightly e2e as the
upstream canary. Three references is fine; three references where two are
undeclared is not.
