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
| **Product** | Ships on its own release cycle to npm, Marketplace or an action. | `linter`, `vscode-extension`, `ai-mcp` |
| **Corpus** | A body of installable example code, installed on its own. | `samples`, `samples-controls`, `samples-stack` |

Rules that follow from the role:

- A channel repository carries a README whose first line says it is generated,
  names the workflow that writes it, and says where to file bugs. Its issues are
  disabled. A `-build` suffix in the repository name means channel, always.
- No repository name uses a `builder-` prefix. The prefix reads as a synonym of
  the `-build` suffix while meaning its opposite.
- A source repository never carries a hand-maintained copy of content another
  repository owns. Either generate it, or gate it (section 5).

## 2. Workflows

- File name: lower kebab case. The extension follows whatever the repository
  already uses — a new workflow in a `.yaml` repository is `.yaml`; only a
  repository starting fresh picks `.yml`. A mass rename across a repository
  retitles every required status check at once, so rename only when the file is
  being reworked anyway, and say so in the pull request so branch protection
  can be moved with it.
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

- `check` runs exactly what CI runs on a pull request — no more, no less. A step
  that exists only in `package.json` is a step no pull request has to pass; a
  step that exists only in a workflow is one no contributor can run before
  pushing.
- `test` runs the repository's own tests. If CI has no separate test step,
  `test` and `check` may be the same command, but both must exist.
- Namespaces use a colon: `check:chains`, `fmt:chains`, `bump:linter`. No
  snake_case script names, no bare verbs for anything a namespace fits.
- Scripts that rewrite files are `fmt:*` or carry `--write`/`--fix`; their
  read-only counterpart is `check:*`. The same name means the same program in
  every repository.
- Node scripts are ESM `.mjs`, live in `scripts/`, and are runnable directly
  (`node scripts/<name>.mjs`).

## 4. Toolchain

- `engines.node` is `>=22` and `.nvmrc` says `22`.
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
| `CLAUDE.md` | every repository that has `AGENTS.md` | A pointer to `AGENTS.md`, nothing else. |
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
