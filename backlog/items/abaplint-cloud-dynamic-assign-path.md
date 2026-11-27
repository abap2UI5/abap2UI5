---
target: abaplint
title: 'no_dynamic_stuff assignOldVariantCloud: also a variable whose path is built in the same method (a string template)'
summary: 'abaplint#4826 (merged 2026-11-27) reports ASSIGN (name) with a path under Cloud when name is a literal or a constant; the abap2UI5 case - lv_path = |MO_APP->{ name }|. ASSIGN (lv_path) TO <fs>. - is a variable and needs data flow'
priority: low
state: open
first_seen: 2026-11-11
checked_upstream: 2026-11-27
upstream: abaplint/abaplint
evidence:
  - 'extended check on an ABAP Cloud trial system, 2026-11-11: six times "Syntax check warning. The old variant of <dynamic-object> should not be used in the current ABAP language version. Internal message code: MESSAGE G3Q" on z2ui5_cl_ui5_srv_model - its six `ASSIGN (lv_path) TO …`, each over a path built as |MO_APP->{ name }|. Left as they are: the statement behaves differently per release (abap2UI5#1937) and no system was at hand to test a rewrite on'
  - 'probed 2026-11-11 against abaplint 2.120.92 with every default rule on (abaplint -d, v750 and Cloud): `ASSIGN (lv_path) TO <any>` and `ASSIGN mo_app->(iv_name) TO <any>` draw the same two findings, no_dynamic_stuff and check_subrc - nothing tells the old variant from the one the cloud accepts'
  - 'tracker search 2026-11-11 ("dynamic assign cloud", "ASSIGN dynamic obsolete"): no issue'
  - 'filed 2026-11-27 as abaplint/abaplint#4826 (syntax 4/4): option assignOldVariantCloud of no_dynamic_stuff, for a literal or a constant holding a path; a variable built from a string template - the abap2UI5 case - needs data flow and is not covered'
  - 'abaplint/abaplint#4826 merged 2026-11-27: option assignOldVariantCloud of no_dynamic_stuff, a literal or a constant holding a path. Left open: a variable assigned once in the same method from a literal or a string template - the six statements of z2ui5_cl_ui5_srv_model, which this item started from'
---

# Report the old dynamic ASSIGN (name) with a component path in ABAP Cloud

A dynamic ASSIGN has two shapes. The old one takes the whole operand as
text, selectors included; the newer ones keep the static part static and
make only one name dynamic:

```abap
" old: the path is text
lv_path = |MO_APP->{ lv_name }|.
ASSIGN (lv_path) TO <any>.

" accepted: the object is named statically, the attribute dynamically
ASSIGN mo_app->(lv_name) TO <any>.
```

ABAP for Cloud Development still compiles the old shape and reports it as a
syntax check warning on every statement. `no_dynamic_stuff` treats both
shapes alike, so a project that has to keep dynamic access - a framework
that binds an app's attributes by name - gets no help in telling the one the
cloud objects to from the one it accepts.

**Proposal.** With syntax version Cloud, report `ASSIGN (name) TO …` whose
name is not a plain data object name. Decidable cases:

- the name is a literal, or a variable assigned once in the same method from
  a literal or a string template, and that text contains a selector (`->`,
  `=>`, `-`) - report, and name the rewrite (`oref->(attr)`,
  `struc-(comp)`, `dref->*`);
- the name is a parameter or anything else whose content is not known -
  report with a weaker wording, as an option that is off by default.

**Not reported.**

- `ASSIGN oref->(name)`, `ASSIGN class=>(name)`, `ASSIGN (class)=>(name)`,
  `ASSIGN struc-(comp)`, `ASSIGN COMPONENT … OF STRUCTURE`, `ASSIGN dref->*`.
- Any syntax version other than Cloud: on an old release the newer shapes do
  not all exist, and the old one is the portable form.

**Where.** an option of `no_dynamic_stuff`, or a new rule next to
`cloud_types`. **Effort:** S for the literal and template case, M with the
one-assignment tracking.

**Source.** ABAP keyword documentation, ASSIGN - dynamic_dobj; the syntax
check warning of ABAP for Cloud Development (message G3Q).
