# Description

<!-- A clear description of what this PR changes and why the change is needed. -->

## How to test

<!-- Steps to verify the change: app snippet, test to run, or scenario to click through. -->

## Checklist

- [ ] `npm run verify` passes (`npm run verify:full` when `app/webapp/` changed)
- [ ] Unit tests added/updated where it makes sense (`.testclasses.abap` / `node/tests/`)
- [ ] No manual edits under `src/00/01/`, `src/00/02/` or `src/01/03/` (see AGENTS.md)
- [ ] Public API in `src/02/` only changed additively
- [ ] `changelog.txt` has a line under `unreleased` when this changes behaviour
      (a `- BREAKING:` line for a rule-5 break) — the release cut moves that
      section under the version heading and publishes it as the release notes,
      so what is not written here is what nobody is told changed
- [ ] Changes were made via abapGit: yes / no
