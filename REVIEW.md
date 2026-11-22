# REVIEW.md — scope of reviews, audits and improvement work

What a code review, a security audit or an improvement proposal on this
repository must leave alone. Claude Code Review reads this file; any other
reviewer should read it too. The root [`AGENTS.md`](AGENTS.md) keeps a one-line
version of each item under "Design Decisions & Known Non-Issues", and
[`docs/agents/decisions.md`](docs/agents/decisions.md) has what was measured
and why each proposal was declined.

## Out of scope

When reviewing, auditing, or proposing improvements to this repository, treat the following as **out of scope** — do not report findings in them, refactor them, or otherwise invest in them:

- **The production code of `src/99/`, and the legacy classes that left it.** `src/99` is gone from this repository since 2026-11-17 (`AGENTS.md`, "Layered Design"). The XML view builder, the popups, the handler shim and the legacy utilities ship from the extension repository now - frozen there as they were here, kept solely so existing downstream installations keep compiling. Do **not** report, harden, refactor or extend any of it, and do not propose bringing a class back. For example, the unescaped single quote in the dynamic `WHERE` builders of `z2ui5_cl_util_ext` is a **non-issue**, and the ~16K-line size of `z2ui5_cl_xml_view` is not a finding either.
- **The `_bind` "mass assignment" question** — binding was **intentionally unified** (`AGENTS.md`, "Data Binding"): every bound attribute is writable from the client `MODEL`. Its former alias `_bind_edit` was **removed on 2026-11-22**. A proposal to split binding again — a separate "editable" flag or method so `_bind` becomes display-only while only that one writes back — is explicitly **rejected**: it would reintroduce exactly the distinction that was deliberately removed and break the many apps that rely on `_bind` round-tripping. Treat "an attribute exposed via `_bind` is writable from the client model" as **by design**, not a vulnerability.
- **A secondary index on `Z2UI5_T_01-TIMESTAMPL`** — see the draft-cleanup entry in `docs/agents/decisions.md`: rejected as not worth the per-write index-maintenance cost.
- **The commit of a sticky app's LUW on a draft write** — see "The draft of a sticky app" in `docs/agents/decisions.md`: `set_session_stateful( )` keeps the LUW across ordinary event roundtrips only; a route or app-state link carrying the draft id, every `nav_app_call( )` / `nav_app_leave( )` and the first-start cleanup commit, and `z2ui5_if_client=>set_session_stateful` says so. That is **documented behaviour**, not a finding; the seam for an installation that needs otherwise is its own `z2ui5_if_ui5_draft_store`.
- **The "no app-start authorization" question** — see the app-start entry in `docs/agents/decisions.md`. That any authenticated user reaching the ICF node can instantiate any `z2ui5_if_app` class is **by design**: authorization lives in the app's own `z2ui5_if_app~main` (like a transaction guarding itself), not in a framework `AUTHORITY-CHECK` or a `check_app_start_allowed` exit. Do not report the missing central hook as a vulnerability, and do not add one.

## Known non-issues

Every entry under "Design Decisions & Known Non-Issues" in `AGENTS.md` was
proposed, measured and declined. Re-reporting one is not a finding; arguing
with one means arguing with its entry in `docs/agents/decisions.md`.
