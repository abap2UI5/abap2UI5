---
target: abap2ui5-linter
title: 'non-released-api: a z2ui5_t_<n> table the linted repository defines itself is reported as the framework''s'
summary: 'the rule reads every z2ui5_t_<n> as the framework''s own table, also when the repository under lint ships the TABL itself - the abap2UI5-addons number their tables in that family (z2ui5_t_05 - _33), so an addon linted with allClasses gets one warning per table access'
priority: medium
state: open
first_seen: 2026-11-02
upstream: abap2UI5/linter
evidence:
  - 'abap2UI5-addons/admin-cockpit, 2026-11-02 - its nine tables were renumbered Z2UI5_T_20 - Z2UI5_T_28 (one numbering all addons share); with "allClasses": true the linter (0.8.5) reported 23 non-released-api warnings, each on a table whose .tabl.xml is in the same src/ folder, and the CI failed on warning. Frozen in an abap2ui5lint-baseline.json as the workaround (branch claude/addon-repo-namespaces-dnjqev)'
  - 'lib/released-api.mjs, INTERNAL_AREAS: `[/^z2ui5_t_\d+$/, { area: ''src/01'', what: ''the framework''s own database tables'' }]` - a name check only, nothing asks whether the object exists in the linted paths'
checked_upstream: 2026-11-02
---

# non-released-api: a repository's own z2ui5_t_<n> table is reported as the framework's

`non-released-api` reports every `z2ui5_t_<n>` as one of the framework's own
database tables (`INTERNAL_AREAS` in `lib/released-api.mjs`). That holds for
an app, which has no business reading `z2ui5_t_01`. It does not hold for a
repository that ships the table itself: the abap2UI5-addons number their
tables in the same family (`z2ui5_t_05`, `_06`, `_11` - `_33`; abap2UI5's
AGENTS.md keeps those numbers off the framework's list).

```abap
" admin-cockpit, src/01 - z2ui5_t_26.tabl.xml is in src/01 as well
MODIFY z2ui5_t_26 FROM @ls_row.
" -> warning: z2ui5_t_26 is not part of abap2UI5's released API (src/02) -
"    the framework's own database tables (src/01)
```

With `"allClasses": true` and `"failOn": "warning"` that is one failing
finding per access - 23 in admin-cockpit.

**Proposal.** Before the verdict, look the name up among the objects of the
linted paths (the linter already walks them): an object the repository
defines is its own, whatever its prefix, and gets no `non-released-api`
finding. The same lookup would cover a repository that ships a
`z2ui5_cl_ui5_*`-named class of its own.

**Still reported.**
- `z2ui5_t_01` (and any other `z2ui5_t_<n>`) in a repository that does not
  define it - the case the rule exists for.
- A framework class the repository merely references.

**Workaround in use.** A baseline holding only the `non-released-api`
entries of the repository's own tables.
