# Releasing

Two tags, one push: **`X.Y.Z`** on `main` and **`X.Y.Z-702`** on the downported
branch. Everything mechanical lives in
[`.github/workflows/release.yaml`](.github/workflows/release.yaml); its header
comment is the reference. This file is the human checklist and the part no
workflow can decide.

## What a release is for

Merging to `main` is the release for anyone reading the repository, and for
abapGit — a pull of `main` installs what is there. A tag is for everyone else:
it is the only thing in this repository that does not move.

That matters more than it sounds. The whole ecosystem resolves the framework by
tag or by branch, so whenever `main` carries an API the newest tag does not,
every repository that teaches that API is teaching something no released
version can install — and anything that has to pin `main` instead of a tag gets
a check result that depends on the day it runs.

That is not hypothetical: `z2ui5_cl_ui5_view_builder` reached `main` on
**2026-08-12** while the newest tag was still **1.142.0 (2026-07-20)**, and for
those four days the samples, samples-controls, samples-stack, app-template and
the documentation all taught a builder no release carried. **1.143.0** closed
it. The gap is the cost of a skipped release, and it is paid by five other
repositories rather than by this one — which is why nothing here measures it.

**A release that is a chore gets skipped.** That is why it is a tag push now.

## How reversible is it?

A tag can be deleted and re-pushed, and a GitHub release can be edited. That is
the theory. In practice a tag that existed for an hour has been fetched by
somebody's CI, and abapGit users install by tag — so treat a published version
as final and fix forward with the next one.

The one thing that cannot be fixed forward is a **wrong version number in a
system**: `z2ui5_if_app=>version` is what abapGit shows and what the
generated branches carry with the source. `npm run check:version`
holds it to `package.json`, and `npm run check:release` holds both to the
changelog.

## One-time setup — the npm packages

Every release also publishes the transpiled framework as the npm package
**`@abap2ui5/node-runtime`** (`docs/agents/ci-workflows.md`, "The transpiled
framework is a package"). `backend-prebuilt.yaml` packs it, proves it by
installing it once (`--check`), uploads it as a workflow artefact and
publishes it by **trusted publishing** — OIDC, with provenance, no token. npm
lets a package be pointed at a workflow only once the package exists, so the
first version is published by hand, once, by a maintainer of the npm
organisation `abap2ui5` (which already owns `@abap2ui5/linter`,
`@abap2ui5/render-runtime` and `@abap2ui5/mcp-server`). Until then the publish
step ends in a warning naming this section, and the run stays green.

The artefact of that run IS the bootstrap — nothing has to be built locally:

1. Cut the release as below and let `backend-prebuilt.yaml` finish (about
   half an hour).
2. From the run's summary page, download the artefact
   `abap2ui5-node-runtime-<version>` and unzip it — it holds one `.tgz`.
3. Publish it:

   ```sh
   npm login
   npm publish ./abap2ui5-node-runtime-<version>.tgz --access public
   ```

   (No `--provenance` here: npm generates an attestation only from a
   supported CI and aborts anywhere else. The bootstrap version ships without
   it; every release the workflow cuts has it.)
4. On npmjs.com → `@abap2ui5/node-runtime` → **Settings → Trusted Publisher →
   GitHub Actions**: organisation `abap2UI5`, repository `abap2UI5`,
   workflow file `backend-prebuilt.yaml`, no environment.

From the next release on, the workflow publishes with no token. An
`NPM_TOKEN` organisation secret is the fallback, not the plan.

**`@abap2ui5/bsp`** (`tools/bsp/`, a UI5 app as an abapGit BSP and back) is
published by the job `bsp` of the same workflow and needs the same one-time
setup: the artefact is `abap2ui5-bsp-<version>` (`npm publish
./abap2ui5-bsp-<version>.tgz --access public`), and its Trusted Publisher
entry names the same workflow file, `backend-prebuilt.yaml`.

`@abap2ui5/embed-control` is not published from here: its source, its
release line and its publish workflow are
[abap2UI5-addons/embed-ui5-control](https://github.com/abap2UI5-addons/embed-ui5-control). What
abap2UI5 serves of it - the page's inline script and the BSP `Z2UI5` - is the
commit `node/setup/fetch-deps.mjs` pins; a new control reaches a release by
moving that pin and `npm run app2abap`.

## Cutting a release

1. **`changelog.txt`** — move the `unreleased` entries under a heading:

   ```
   2026-08-16 v1.143.0
   -------------------
   ```

   The workflow reads exactly this section as the GitHub release notes, so what
   is written here is what everyone gets told changed. Keep the legend
   (`+ added`, `* fixed`, `! changed`, `- removed`), and keep the (now empty)
   `unreleased` heading standing above the new section — the PR template
   points every change at it, and `npm run check:release` /
   `npm run check:changelog` fail without it.

2. **Bump both version numbers** — `package.json` and the `version` constant in
   `src/02/z2ui5_if_app.intf.abap`. They are two files on purpose (one ships,
   one does not) and nothing but the gate keeps them together.

3. **Check, then tag:**

   ```sh
   npm run check:release                        # tag, both versions and the changelog agree
   ABAP2UI5_RELEASING=1.143.0 npm run verify    # what the release job runs, in full
   git commit -am "Release 1.143.0"
   git tag 1.143.0
   git push origin main 1.143.0
   ```

   The tag is pushed by name: `git push --follow-tags` pushes annotated tags
   only, `git tag` without `-a` makes a lightweight one, and the push then
   reports `main -> main` while no tag arrives and no release runs.
   `ABAP2UI5_RELEASING` lets `check:changelog` accept that the docs page has no
   section for this version yet - it gets one in step 5.

4. **Watch the run.** It re-checks everything on the tagged commit, prints the
   release notes before publishing them, then creates both releases.

5. **Once the run is green, open the matching section on the docs changelog page** —
   `docs/resources/changelog.md` in [abap2UI5/docs](https://github.com/abap2UI5/docs)
   needs a `## X.Y.Z` heading carrying the **same date** as the section you
   wrote in step 1, and the site's navigation bar and deprecations page name
   the new version. After the release, not before: the docs site's own gate
   (`check:version`) accepts a version only once its GitHub release exists,
   and the release job's `check:changelog` lets exactly the version it
   releases be missing there. 1.146.0 went the other way round - the release
   waited for the docs section, that section was merged red, and the site
   named 1.145.0 until its next scheduled deploy ten hours later.

   Right after the release, though, not days later: `npm run check:changelog`
   compares the two and is part of `verify`, so until that page catches up
   **every pull request in this repository fails**, including ones that have
   nothing to do with the release. The two documents are deliberately
   different in what they say; they may not differ about which releases exist
   or when they shipped.

To rehearse without publishing, dispatch the workflow by hand from the Actions
tab: same gates, same notes, no tag and no release.

## What the workflow does NOT decide

- **When to release, and what the number is.** Nothing here computes a semver
  bump from the diff; `rule 5` breaks (a change to the `src/02` public API,
  recorded in `.github/api-snapshot.json`) are the ones that deserve a
  deliberate decision, and the API-contract gate is what surfaces them.
- **Whether `main` is worth releasing.** `npm run verify` says the tree is
  correct, not that it is a good moment.
- **The 702 content.** `auto_downport` rebuilds the `702` branch from `main` on
  every push, so at tag time it usually holds the downport of the released
  commit, and the release job tags that head. It checks first: every downport
  commit carries a `Source-Commit:` trailer naming the `main` commit it was
  built from, and the head is tagged only when that trailer names the release
  commit. When it does not, because `auto_downport` is still running or a push
  to `main` after the release commit has rebuilt the branch already (1.148.0:
  #2923 landed between the merge of the cut and the tag), the release job
  builds the downport of the release commit itself, the way `auto_downport`
  does, and tags that commit. The branch is force-pushed on every rebuild, so
  the earlier build is not in its history any more, and the rebuild is the
  same tree: for 1.148.0 it matched the head `auto_downport` had pushed, hash
  for hash. The branch itself stays `auto_downport`'s; the release job never
  pushes it. A downport that fails or does not lint fails the step, and with
  it the `-702` release.
- **The rest of the ecosystem.** This workflow tags this repository and
  nothing else. The repositories `.github/ecosystem.json` marks `with-core`
  (the corpora, the template, the docs, the protocol, the extension, the
  addons layout-management, popups, table-maintenance, custom-controls and
  custom-controls-customer, abap-util) get the same version from `npm run release:ecosystem`,
  by hand, after this release - see "Release order" below. The others are
  versioned on their own (`own`) or not at all (`none`).

## After a release

- **The prebuilt backend arrives later.** `release.yaml` dispatches
  `backend-prebuilt.yaml` right after publishing (a `release: published`
  event alone would not start it: GitHub runs no workflow for an event the
  workflow's own token produced). That run checks out the tag, downports, transpiles,
  runs the unit suite and attaches `backend-<version>.tar.gz` to the `X.Y.Z`
  release — tens of minutes after the release exists, so a release without
  that asset for a while is normal, and `release.yaml` does not wait for it.
  If the run failed, or a past release needs the asset, dispatch the workflow
  by hand with the tag: it rebuilds and re-attaches (`--clobber`). The asset
  name and its `backend-manifest.json` are what `abap2UI5/mcp-server`
  downloads instead of building the backend itself — renaming either is a
  change over there first. The `-702` release gets no asset: it is the
  downported sources, and the backend is built from the same commit anyway.
- **The npm package arrives with it.** The same `backend-prebuilt.yaml` run
  packs `@abap2ui5/node-runtime@<version>`, installs it once before it is
  uploaded (`--check`), and publishes it by trusted publishing. A warning
  instead of a publish means the one-time setup above has not happened yet;
  an error means it has and the publish failed for a reason worth reading.
  A published version cannot be changed afterwards — fix forward with the
  next release, as with the tags.
- **The ecosystem can pin again.** Anything resolving the framework from `main`
  out of necessity rather than choice should name the new tag once it carries
  what that repository needs. `app-template`'s `abaplint.jsonc` is the standing
  case: it went to `main` because no tag carried the current builder, and
  1.143.0 is the first one that does.
- **`docs`** documents the version it describes; a release is the moment to
  check that what it teaches is in the tag.
- **Carry the release along.** Once `@abap2ui5/node-runtime` (and, with
  step 2 of the release order, `@abap2ui5/linter`) is on npm, run
  `npm run check:ecosystem -- --live`: its "behind" list names every
  repository whose npm pin the new version does not satisfy, or whose
  lockfile still installs an older one under a range that would take it - a protocol
  suite measuring the previous wire, an embed testing an older runtime, a
  corpus linting with a linter that does not know what was just removed.
  Bump them, or say in the repository why it stays. Text that calls the
  release's content "unreleased" or "DEV only" (the protocol README, a
  linter message) goes stale at the same moment and is worth one search.

## Release order

Three releases carry the abap2UI5 name, and they go in this order:

1. **The core** - this repository, the tag push above. `release.yaml` cuts
   `X.Y.Z` and `X.Y.Z-702`, `backend-prebuilt.yaml` follows with the backend
   asset and `@abap2ui5/node-runtime`, and the docs changelog section is
   opened (step 5). Everything below names this version, so it comes first.
2. **The linter** - [abap2UI5/linter](https://github.com/abap2UI5/linter),
   only when the core release changed a set the linter mirrors
   (`npm run check:mirrors` here says when, `data/compat.json`
   `framework.mirrored` over there records the version it mirrors). Its own
   [RELEASING.md](https://github.com/abap2UI5/linter/blob/main/RELEASING.md)
   is the checklist; its own version line (`vX.Y.Z`). After the core,
   because it mirrors a released core; before the ecosystem, because the
   corpora and addons lint with it.
3. **The ecosystem** - every repository `.github/ecosystem.json` marks
   `with-core` gets `X.Y.Z` on the head of its default branch, and
   `X.Y.Z-702` / `X.Y.Z-cloud` on the head of those branches where it has
   them:

   ```sh
   npm run release:ecosystem -- X.Y.Z            # the plan: what would be tagged, on which commit
   npm run release:ecosystem -- X.Y.Z --apply    # do it (gh auth status: an account with write access)
   ```

   Existing tags are skipped, so a partial run is finished by running it
   again; `--only <owner/name>` narrows it. `--apply` refuses while the
   core's tag `X.Y.Z` does not exist. Tag heads that lint against the
   release: the last `ecosystem-canary.yaml` run says which consumers do not
   lint against `main`, and a head that does not is better fixed before it
   carries the version than after. The plan also lists the consumers that
   still pin an older core tag - the "ecosystem can pin again" step above.

**Every release script has a dry run, and it is the default where it can be.**
The core: dispatch `release.yaml` by hand from the Actions tab (same gates,
same notes, no tag, no release). The linter: *Actions -> Publish to npm ->
Run workflow* does everything except the publish. The ecosystem:
`npm run release:ecosystem -- X.Y.Z` without `--apply` writes nothing. A
release script added later follows the same rule - nothing is written
without an explicit flag, and the dry run prints exactly what the real run
would do.

## Deprecation policy

**Deprecate first, remove in a later release.** Anything an installation can
use - a public method, type or constant of `src/02` (rule 5), an object, a
frontend contract, a repository it installs from - goes through two releases:

1. **The deprecating release** marks it obsolete in the code (the comment or
   pragma at the declaration, naming the replacement), adds it to the
   [Deprecations](https://abap2ui5.github.io/docs/resources/deprecations)
   page of abap2UI5/docs and to `docs/removal-plan.md`, and opens a **GitHub
   issue** that names the replacement and says that an installation can stay
   on the previous release tag until it has migrated. The changelog line is a
   `!` that links the issue. Nothing breaks yet.
2. **A later release removes it.** Its changelog line starts with
   `BREAKING:` (`- BREAKING: ...`), and the release notes - which are that
   changelog section - link the deprecation issue, so whoever upgrades reads
   what replaces it and that the previous tag is the way to defer the
   migration. The API snapshot changes in the same commit
   (`node .github/scripts/api-snapshot.mjs --write`, recorded in
   `docs/agents/api-snapshot-exceptions.md` where rule 5 needs it).

The tags are what makes "stay on the previous release" an answer: an
abapGit installation can pull a tag, a consumer's abaplint config can pin one
(`.github/ecosystem.json` lists who does), and the nightly canary shows which
consumers a removal on `main` breaks before the release ships it.

**1.151.0 is the worked example - of the parts that worked and of the part
that this rule now fixes.** Its three removals each went through a GitHub
issue that named the replacement:
[#3036](https://github.com/abap2UI5/abap2UI5/issues/3036) (`_bind_edit( )`
and the `*_model_update( )` methods of the client: `_bind( )`, and nothing
at all for the no-ops), [#3045](https://github.com/abap2UI5/abap2UI5/issues/3045)
(the legacy view builder and popups of the former `src/99` move to
abap2UI5/abap2UI5-ext, a separate install with the same names) and
[#3023](https://github.com/abap2UI5/abap2UI5/issues/3023) (abap2UI5/frontend
merged into this repository: `src/03` and the branch `cloud`, one pull). The
deletion of the client methods carried a `BREAKING:` line. What it did not do: #3036 was opened
on 2026-11-22, the day the methods were deleted, so deprecation and removal
landed in the same release, and no changelog line links its issue.
From the next release on, the deprecation ships in one release and the removal in a
later one, and the line links the issue. The history is in
`docs/agents/decisions.md`.
