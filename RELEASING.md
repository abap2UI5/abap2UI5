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
system**: `z2ui5_if_app=>version` is what abapGit shows and what
`frontend_deploy` stamps into the delivered frontend. `npm run check:version`
holds it to `package.json`, and `npm run check:release` holds both to the
changelog.

## One-time setup — the npm packages

Every release also publishes two npm packages (AGENTS.md, "The transpiled
framework is a package"): **`@abap2ui5/node`**, the transpiled framework for a
Node host, and **`@abap2ui5/frontend`**, the UI5 component. `backend-prebuilt.yaml`
packs both, proves each by installing it once (`--check`), uploads each as a
workflow artefact and publishes it by **trusted publishing** — OIDC, with
provenance, no token. npm lets a package be pointed at a workflow only once
the package exists, so the first version of each is published by hand, once,
by a maintainer of the npm organisation `abap2ui5` (which already owns
`@abap2ui5/linter`, `@abap2ui5/render-runtime` and `@abap2ui5/mcp-server`).
Until then the publish steps end in a warning naming this section, and the run
stays green.

The artefacts of that run ARE the bootstrap — nothing has to be built locally:

1. Cut the release as below and let `backend-prebuilt.yaml` finish (the
   `frontend` job takes minutes, `attach` about half an hour).
2. From the run's summary page, download the artefacts
   `abap2ui5-node-<version>` and `abap2ui5-frontend-<version>` and unzip
   them — each holds one `.tgz`.
3. Publish both:

   ```sh
   npm login
   npm publish ./abap2ui5-frontend-<version>.tgz --access public
   npm publish ./abap2ui5-node-<version>.tgz --access public
   ```

   (No `--provenance` here: npm generates an attestation only from a
   supported CI and aborts anywhere else. The bootstrap versions ship without
   it; every release the workflow cuts has it.)
4. On npmjs.com, for **each** of the two packages: **Settings → Trusted
   Publisher → GitHub Actions**, organisation `abap2UI5`, repository
   `abap2UI5`, workflow file `backend-prebuilt.yaml`, no environment.

From the next release on, the workflow publishes both with no token. An
`NPM_TOKEN` organisation secret is the fallback, not the plan.

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
   npm run check:release        # tag, both versions and the changelog agree
   npm run verify               # what the release job runs, in full
   git commit -am "Release 1.143.0"
   git tag 1.143.0 && git push --follow-tags
   ```

4. **Watch the run.** It re-checks everything on the tagged commit, prints the
   release notes before publishing them, then creates both releases.

5. **Open the matching section on the docs changelog page** —
   `docs/resources/changelog.md` in [abap2UI5/docs](https://github.com/abap2UI5/docs)
   needs a `## X.Y.Z` heading carrying the **same date** as the section you
   wrote in step 1. This is not a courtesy: `npm run check:changelog` compares
   the two and is part of `verify`, so until that page catches up **every pull
   request in this repository fails**, including ones that have nothing to do
   with the release. The two documents are deliberately different in what they
   say; they may not differ about which releases exist or when they shipped.

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
  every push, so at tag time it already holds the downport of the released
  commit. The release job only tags it — but it no longer tags it blind: the
  downport commit carries a `Source-Commit:` trailer naming the `main` commit
  it was built from, and the release job refuses to tag a `702` head whose
  trailer does not name the release commit. A stale branch (the downport job
  failed, or is still running) therefore fails the release with a message
  saying to wait for `auto_downport`, instead of shipping a stale `-702`
  release. Checking that `auto_downport` ran green before tagging is still
  good manners; it is just no longer the only thing standing between a failed
  downport and a wrong release.
- **The addons.** `abap2UI5-addons/*` and the sample repositories are versioned
  on their own and are not touched here.

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
- **The npm packages arrive with it.** The same `backend-prebuilt.yaml` run
  packs `@abap2ui5/node@<version>` and `@abap2ui5/frontend@<version>`, installs
  each once before it is uploaded (`--check`), and publishes both by trusted
  publishing — the frontend within minutes, its own job needs no transpile. A
  warning instead of a publish means the one-time setup above has not happened
  yet; an error means it has and the publish failed for a reason worth
  reading. A published version cannot be changed afterwards — fix forward with
  the next release, as with the tags.
- **The ecosystem can pin again.** Anything resolving the framework from `main`
  out of necessity rather than choice should name the new tag once it carries
  what that repository needs. `app-template`'s `abaplint.jsonc` is the standing
  case: it went to `main` because no tag carried the current builder, and
  1.143.0 is the first one that does.
- **`docs`** documents the version it describes; a release is the moment to
  check that what it teaches is in the tag.
