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

## Cutting a release

1. **`changelog.txt`** — move the `unreleased` entries under a heading:

   ```
   2026-08-16 v1.143.0
   -------------------
   ```

   The workflow reads exactly this section as the GitHub release notes, so what
   is written here is what everyone gets told changed. Keep the legend
   (`+ added`, `* fixed`, `! changed`, `- removed`).

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
  commit. The release job only tags it. If that branch is stale — the downport
  job failed, say — the `-702` release is stale with it, so check that
  `auto_downport` ran green on the release commit before tagging.
- **The addons.** `abap2UI5-addons/*` and the sample repositories are versioned
  on their own and are not touched here.

## After a release

- **The ecosystem can pin again.** Anything resolving the framework from `main`
  out of necessity rather than choice should name the new tag once it carries
  what that repository needs. `app-template`'s `abaplint.jsonc` is the standing
  case: it went to `main` because no tag carried the current builder, and
  1.143.0 is the first one that does.
- **`docs`** documents the version it describes; a release is the moment to
  check that what it teaches is in the tag.
