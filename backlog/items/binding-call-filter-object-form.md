---
target: abap2ui5-linter
title: 'Report a binding_call filter payload written as an array of OBJECTS — it silently clears the binding instead of filtering it'
summary: '`[{"path":…,"operator":…,"value1":…}]` is dropped whole by buildFilterGroups and falls into binding.filter([]), so the filter is cleared and nothing is logged'
priority: high
state: open
first_seen: 2026-08-24
evidence:
  - samples-controls apps 454, 473, 510, 515 and 521 shipped seven such payloads. 473's suggestion filter and the four value-help dialogs all cleared their binding on every search instead of applying one
  - 473 looked correct on screen because Input.filterSuggests defaults to true, so UI5's own client-side filtering still narrowed the popup while the server-computed filter did nothing
  - app 022 already had the correct nested-array shape, and 473's sidecar cited 022 as its precedent while doing the opposite
---

## What happens

`BINDING_CALL` + `filter` with a **single** `[`-starting argument is the
compound-groups form. A group is an array of `[path, operator, value1, value2?]`
**arrays**:

```abap
" correct - app 022
json_groups = |[[["CATEGORY","EQ","{ category }"]]]|.
```

Seven sites across five ports wrote an array of **objects** instead:

```abap
" dead
|[\{"path":"NAME","operator":"Contains","value1":"{ term }"\}]|
```

`buildFilterGroups` (`src/01/03/z2ui5_cl_ui5f_ctrlcall_js.clas.abap`) does:

```js
groups = groups.filter((g) => Array.isArray(g) && g.length);
if (!groups.length) { binding.filter([]); return; }
```

An object fails `Array.isArray`, the group list empties, and control falls into
`binding.filter([])` — the filter is **cleared**, never applied.

## Why nothing reports it

The one guard that logs is `if (!Array.isArray(groups))` — and the root *is* an
array, so it passes. The per-group drop is silent by construction. No gate in
samples-controls parses an event-attribute payload either.

## Proposed rule

Report a `follow_up_action`/`_event` whose target is `BINDING_CALL`, whose third
positional argument is `filter`, and whose fourth argument is a single
`[`-starting literal whose parsed root elements are **not** arrays.

## What it must not report

- The **positional** form (`( path ) ( operator ) ( value1 )`), which is what a
  single filter should use and is not JSON at all.
- A correctly nested compound payload (`[[[…]]]`), including the empty `[]`
  clear.
- A `[`-starting argument on any other binding method — only `filter` takes the
  compound form.
- A payload built from a variable the rule cannot resolve statically: report
  only when the literal is readable, or the rule becomes a guessing game.
