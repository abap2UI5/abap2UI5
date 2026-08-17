---
target: abaplint
title: 'Report an ABAP Doc block that documents nothing'
summary: a `"!` block before a chain keyword, or inside a parameter list, silently documents no declaration at all — SLIN accepts it and the text is simply never shown
priority: medium
state: open
upstream: abaplint/abaplint
evidence:
  - abap2UI5 `z2ui5_if_client=>cs_nav_mode` — the block sat before `CONSTANTS:` and documented nothing
  - the identical mistake in `abap2UI5/samples-stack` on `cs_status` (`7459f39`), found only by reading the file
  - it recurs across repositories because nothing anywhere reports it — the text is present, so the author has no reason to look again
---

# Report an ABAP Doc block that documents nothing

## What happens

An ABAP Doc block documents **the one declaration directly below it**. In a
chained statement that means inside the chain, not before the chain keyword:

```abap
"! Navigation modes.            <-- documents nothing
CONSTANTS:
  BEGIN OF cs_nav_mode,
    ...
```

```abap
CONSTANTS:
  "! Navigation modes.          <-- documents cs_nav_mode
  BEGIN OF cs_nav_mode,
    ...
```

The same applies inside a parameter list: a `"!` between two parameters
documents nothing, because a parameter is documented from the method's own
block with `"! @parameter <name> | <text>`.

Neither form is an error anywhere. The text is in the source, it reads like
documentation to a human scanning the file, and it is simply never attached to
anything — so the object ships undocumented while looking documented.

## Why no existing rule catches it

The `abapdoc` rule checks for the **existence** of ABAP Doc on public methods,
interface methods and class/interface definitions. A block that exists but
attaches to nothing is indistinguishable from a block that was never written,
from that rule's point of view — and if the object is one `abapdoc` does not
require documentation for, nothing looks at all.

## Proposed rule

Report a `"!` block whose following statement is not a declaration it can
document:

- immediately before a chain keyword (`CONSTANTS:`, `DATA:`, `TYPES:`,
  `METHODS:`) rather than before the first chain member;
- inside a parameter list;
- immediately before `ENDCLASS`, `ENDINTERFACE`, `PUBLIC SECTION.`,
  `PROTECTED SECTION.` or `PRIVATE SECTION.`.

Each is a purely structural test on the statement following the comment block,
which abaplint's statement model already gives it.

## Suggested severity

A warning. Nothing breaks — that is the point, and it is why it needs a rule
rather than a convention.
