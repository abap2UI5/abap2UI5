# REVIEW.md — scope of reviews, audits and improvement work

What a code review, a security audit or an improvement proposal on this
repository must leave alone. Claude Code Review reads this file; any other
reviewer should read it too. The root [`AGENTS.md`](AGENTS.md) keeps a one-line
version of each item under "Design Decisions & Known Non-Issues", and
[`docs/agents/decisions.md`](docs/agents/decisions.md) has what was measured
and why each proposal was declined.

## Out of scope

When reviewing, auditing, or proposing improvements to this repository, treat the following as **out of scope** — do not report findings in them, refactor them, or otherwise invest in them:

- **The production code of `src/99/`.** It is **frozen legacy code** (`AGENTS.md`, "Layered Design"): no in-repo consumers, kept solely so existing downstream installations keep compiling. Do **not** report, harden, refactor or extend it. For example, the unescaped single quote in the dynamic `WHERE` builders of `z2ui5_cl_util_ext` is a **non-issue** here, and the ~16K-line size of `z2ui5_cl_xml_view` is not a finding either. Only the `*.testclasses.abap` files under `src/99/` are maintained — they run in CI and may need adapting when core internals they assert on change.
- **The `_bind` / `_bind_edit` "mass assignment" question** — binding was **intentionally unified** (`AGENTS.md`, "Data Binding"): `_bind` and `_bind_edit` behave identically and every bound attribute is writable from the client `MODEL`. `_bind_edit` is a **compatibility-only alias of `_bind`** and is slated for **removal (~1 year out)**. A proposal to split them again — a separate "editable" flag so `_bind` becomes display-only while only `_bind_edit` writes back — is explicitly **rejected**: it would reintroduce exactly the distinction that was deliberately removed and break the many apps that rely on `_bind` round-tripping. Treat "an attribute exposed via `_bind` is writable from the client model" as **by design**, not a vulnerability.
- **A secondary index on `Z2UI5_T_01-TIMESTAMPL`** — see the draft-cleanup entry in `docs/agents/decisions.md`: rejected as not worth the per-write index-maintenance cost.
- **The "no app-start authorization" question** — see the app-start entry in `docs/agents/decisions.md`. That any authenticated user reaching the ICF node can instantiate any `z2ui5_if_app` class is **by design**: authorization lives in the app's own `z2ui5_if_app~main` (like a transaction guarding itself), not in a framework `AUTHORITY-CHECK` or a `check_app_start_allowed` exit. Do not report the missing central hook as a vulnerability, and do not add one.

## Known non-issues

Every entry under "Design Decisions & Known Non-Issues" in `AGENTS.md` was
proposed, measured and declined. Re-reporting one is not a finding; arguing
with one means arguing with its entry in `docs/agents/decisions.md`.
