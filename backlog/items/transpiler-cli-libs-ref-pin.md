---
target: open-abap
title: 'transpiler-cli: libs[] takes a URL and no commit - a build is reproducible only with a pre-materialised clone, which abap2UI5 keeps in sync with a gate of its own'
summary: '`abap_transpile.json` `libs: [{url}]` clones the default branch at build time, so the same commit of the consumer builds green today and red tomorrow when open-abap-core moves; abap2UI5 pre-clones each lib at a SHA into `node/deps` (`fetch-deps.mjs`), points `libs[].folder` at it, and runs `transpile-pins-gate.mjs` to keep the two lists equal - a `ref` next to `url` is the whole request'
priority: medium
state: open
first_seen: 2026-10-22
upstream: abaplint/transpiler
evidence:
  - 'abap2UI5 `node/setup/fetch-deps.mjs:2-7` (2026-09): ''abap_transpile.json only take a URL, so the same commit could … build green today and red tomorrow''; `node/setup/transpile.mjs:196-224`, `pack-npm.mjs:174-216` record and re-fetch the commits for hosts; `.github/scripts/transpile-pins-gate.mjs` (`check_gates.yaml:111-117`) keeps the config and the pins in sync'
  - 'abap2UI5/mcp-server `lib/npm-backend.mjs` clones open-abap-core ''at a pinned sha'' itself for the same reason; abap2UI5/playground `tools/build-framework.mjs` uses a `deps/` folder'
  - 'read 2026-10-22 in abaplint/transpiler main 53a708f - `packages/cli/src/types.ts` libs: `url?`, `folder?`, `files?`, `exclude_filter?`; `packages/cli/src/git_clone.ts` clones with no revision; `libraries.ts:56-67`'
  - 'prepared 2026-10-22 as `oblomov-dev/fork-transpiler` branch `feat/cli-libs-ref` (338b6d8) on abaplint/transpiler main 53a708f: the change plus tests, green in the package suites and the transpiler''s integration tests; the fourteen prepared branches merged together transpile open-abap-core main 239b817 and pass its whole unit suite (1172 tests); abap2UI5 itself, downported and transpiled with that stack (`node/setup/abap_transpile.json`, open-abap-core pinned at 9c1271b with the compare_tables correction), passes `npm run unit` in full (1558 tests).'
checked_upstream: 2026-10-22
---

# transpiler-cli: pin a library to a commit

## The problem

```json
"libs": [{ "url": "https://github.com/open-abap/open-abap-core" }]
```

is a moving target: the CLI clones the default branch when it runs. Every
abap2UI5 host that needs a reproducible build has grown the same
machinery - a pre-clone at a SHA, `folder` instead of `url`, and a gate
that checks the two agree - because the config cannot say which commit.

## Proposed change

```json
"libs": [{ "url": "https://github.com/open-abap/open-abap-core", "ref": "9c1271b" }]
```

`ref` is a commit, tag or branch; `git_clone.ts` fetches it
(`git fetch --depth 1 origin <ref> && git checkout FETCH_HEAD`, with a
fallback to a full fetch for a bare SHA an old server will not serve
shallow). The CLI prints the resolved commit of every lib at the end of
the run and writes it into the output manifest, so a lock file is
possible on top.

## How to file

A PR against abaplint/transpiler, `packages/cli`; small.

