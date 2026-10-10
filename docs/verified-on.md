# Verified on

What a release of abap2UI5 has been run on, and by whom. Two kinds of rows:
what the repository's own CI proves on every merge, and what people report
from real systems. The first kind is complete and current by construction.
The second is only as complete as the reports that come in — and a red row
with a linked issue is worth as much as a green one.

Report a system with the
[System report](https://github.com/abap2UI5/abap2UI5/issues/new?template=system_report.yml)
issue template. Every report becomes a row below, with the reporter's
company named only when the report says so.

## What CI verifies on every merge

A pull request does not merge until all of this is green. None of it needs an
SAP system, which is what makes it run on every change — and also what it
cannot prove: that a transport activates on a given kernel, that an ICF node
is configured, that a browser behind a corporate proxy loads the page.

| Claim | How it is verified | Where |
|---|---|---|
| Syntax on NW 7.02 | Every merge is downported by abaplint and linted against the 7.02 language version; the result is published as the `702` branch and the `-702` tag | [auto_downport](../.github/workflows/auto_downport.yaml), [ABAP_702](../.github/workflows/ABAP_702.yaml) |
| Syntax on Standard ABAP (7.50+) | abaplint with the standard-ABAP rule set | [abaplint](../.github/workflows/abaplint.yaml), [abap_standard.jsonc](../.github/abaplint/abap_standard.jsonc) |
| Syntax and API scope on ABAP Cloud | abaplint with the cloud rule set: released APIs only, no classic statements | [abaplint](../.github/workflows/abaplint.yaml), [abap_cloud.jsonc](../.github/abaplint/abap_cloud.jsonc) |
| The backend behaves as specified | The framework transpiled to JavaScript runs its ABAP unit tests on every merge; the count is on the README | [test](../.github/workflows/test.yaml) |
| Apps render and round-trip on UI5 1.71 and on the current release | Playwright browser tests drive the shell, the roundtrip, popups, navigation, the launchpad split and the error overlay on both UI5 builds | [test](../.github/workflows/test.yaml), [node/tests/e2e](../node/tests/e2e) |
| Nothing in the frontend uses an API UI5 2.x removes | The legacy-free 2.x bootstrap runs the frontend checks, and on the pinned current 1.x build a `[FUTURE FATAL]` log entry — what the next major release turns into an exception — fails the browser run | [UI5_2X](../.github/workflows/UI5_2X.yaml), [future-fatal.spec.js](../node/tests/e2e/future-fatal.spec.js) |
| Every view a shipped class builds loads in a real `XMLView.create` | The linter's headless render gate over this repository's own app classes | [render-gate](../.github/workflows/render-gate.yaml) |
| Every icon, control and module exists on 1.71 | Gates compare the shipped views and modules against the 1.71 inventory | [check_gates](../.github/workflows/check_gates.yaml) |
| abapGit imports the result byte for byte | Gate on file format, sidecars and package structure under `src/` | [check_gates](../.github/workflows/check_gates.yaml) |
| The public API did not change by accident | A normalized snapshot of `src/02` is compared on every pull request | [api-snapshot.json](../.github/api-snapshot.json) |

## Reported from real systems

One row per report. `Version` is the installed tag, `Result` is green or red
as reported, `Source` links the report. A red row stays until a release fixes
it, and then gets a second row for that release.

| Date | Version | ABAP release | UI5 | Use | Result | Reported by | Source |
|---|---|---|---|---|---|---|---|
| _no reports yet_ | | | | | | | |

### How a row gets here

1. Install a tag — not `main` — on your system, start the page, run your apps.
2. Open a [System report](https://github.com/abap2UI5/abap2UI5/issues/new?template=system_report.yml).
   Five fields, two minutes.
3. A maintainer adds the row and closes the report. Red reports get a linked
   issue first, so the row has something to point at.

What is deliberately not asked for: a company name (optional in the notes),
a screenshot, or a reason. A row that says "7.40 SP 26, 1.146.0-702, green,
production" is the whole point.

## Reading the two tables together

The first table is what the project guarantees; the second is what the world
reports. A release row that is green in CI and has no real-system row is not
unverified — it is verified on everything CI can reach and waiting for the
first report from a system it cannot. A release with a red row and a green CI
is the case the second table exists for: something a real kernel, a real
ICF configuration or a real browser does that the transpiled run did not.
That is the bug report that matters most, and this page is where it is
visible.
