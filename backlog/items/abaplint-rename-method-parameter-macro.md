---
target: abaplint
title: 'rename: interface methods, method parameters and macros (known upstream)'
summary: the renamer's open bugs for interface methods (#3246), method parameters (#3134) and macros (#1466) - not hit by us, since the namespace rename renames objects only (CLAS, INTF, TABL) and src/ has no macro; recorded so the three are checked before a rename of members is ever planned
priority: low
state: filed
filed: https://github.com/abaplint/abaplint/issues/3246
upstream: abaplint/abaplint
first_seen: 2026-11-26
checked_upstream: 2026-11-26
evidence:
  - 'gh search 2026-11-26: abaplint/abaplint#3246 "renaming an interface method fails" open (2024-02-22); #3134 "renaming method parameter doesnt fully work" open (2023-10-17); #1466 "renaming, does not work well inside macros" open (2020-10-20)'
  - 'abap2UI5 main, 2026-11-26: rename.jsonc renames object names only (type CLAS|INTF|TABL, ^z2ui5_(.*)$); npm run rename green, 0 issues; no DEFINE in src/ - none of the three is hit by us'
---

# rename: interface methods, method parameters and macros

**Not hit by us.** The namespace rename changes object names; the members of
`z2ui5_if_client` and every other interface keep their names (they are the
public API, rule 5). No source of abap2UI5 defines a macro.

Recorded so that the three upstream issues are known before anyone plans a
rename of members (an API rename with abaplint, or an addon with macros).
Nothing to file - add evidence here if a repository of ours runs into one.
