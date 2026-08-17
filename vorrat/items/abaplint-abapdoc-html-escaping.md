---
target: abaplint
title: 'Report an unescaped `<`, `>` or `&` in ABAP Doc'
summary: ABAP Doc is rendered as HTML, so a literal angle bracket swallows the rest of the sentence in the tooltip while the source looks right
priority: low
state: open
upstream: abaplint/abaplint
evidence:
  - abap2UI5's own doc comments need `&lt;`/`&gt;`/`&amp;` and the rule is carried as prose in the `abap-check` skill because nothing checks it
  - the failure is invisible in the source and visible only in the ADT/SE80 tooltip, which is not where anybody reviews
---

# Report an unescaped `<`, `>` or `&` in ABAP Doc

## What happens

ABAP Doc is rendered as HTML by ADT and SE80. A literal angle bracket is
therefore read as the start of a tag:

```abap
"! Returns the app if the release is < 7.50, otherwise initial.
```

The tooltip shows *"Returns the app if the release is"* and drops everything
after the `<`, because the rest of the sentence is parsed as an unclosed
element. A `&` starts an entity reference and mangles whatever follows it.

Nothing about the source looks wrong, and the rendering happens in a tool the
author is not looking at while writing. So the documentation is lost quietly,
and stays lost — nobody re-reads a tooltip they have already written.

## Proposed rule

Report a bare `<`, `>` or `&` in a `"!` comment, excluding:

- an already-escaped entity (`&lt;`, `&gt;`, `&amp;`, `&#…;`);
- the ABAP Doc tag syntax itself (`@parameter`, `@raising`, `{@link …}`);
- text inside `<em>`/`<strong>`/`<p>` and the other tags ABAP Doc documents as
  supported — this is HTML on purpose, and a rule that reported deliberate
  markup would be wrong.

The exclusion list is what makes this writable at all, and also why the
severity should be low: the distinction between markup and a stray bracket is
the whole rule.

## Suggested severity

A warning, off by default if that fits abaplint's conventions. The cost of a
false positive here (an author escaping a tag they meant) is higher than the
cost of the defect in most code bases.
