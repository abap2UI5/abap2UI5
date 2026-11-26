---
target: abaplint
title: 'downport: report the objects and statements that have no 7.02 form (EML, behavior pools, CDS, RAP)'
summary: samples-stack has to downport to 7.02 like every repository, but after abaplint --fix at v702 its RAP packages keep MODIFY/READ/COMMIT/ROLLBACK ENTITIES (parser errors), behavior pools on cl_abap_behavior_handler, xco classes, and DDLS/BDEF/SRVD/SRVB the downport never looks at - nothing says which objects cannot be downported, so a repository cannot drop them the way abap2UI5 drops its BSP
priority: high
state: open
upstream: abaplint/abaplint
first_seen: 2026-11-26
checked_upstream: 2026-11-26
evidence:
  - 'samples-stack origin/main 7538290, 2026-11-26: a copy of src/ linted with abaplint 2.120.120 at v702 (downport, check_syntax, parser_error), --fix run four times: parser errors on MODIFY/READ/COMMIT/ROLLBACK ENTITIES remain in src/03, 04, 05, 11, 12 and 13 (e.g. 03: 18 MODIFY, 7 READ, 10 COMMIT, 25 ROLLBACK), "Super class cl_abap_behavior_handler not found" (5), "Unknown class xco_cp_xlsx" (8), "Cannot downport, inferred type is void" (5); the packages without EML (01, 02, 06-10, 14) show no such statement'
  - 'samples-stack AGENTS.md: "No 7.02 downport. EML sets the floor at 1909" - against the requirement that every repository of the ecosystem downports to 7.02'
  - 'abap2UI5 main: node/setup/downport-fix.mjs drop-bsp removes src/03/02 from the 702 tree by hand, because nothing in the downport says a BSP with a UI5 > 7.02 app has no 7.02 form'
  - 'gh search 2026-11-26 (repo:abaplint/abaplint, open issues "downport"): #3503 downport EXACT, #3735 cx_sy_itab_line_not_found, #3505 SQL literals - nothing on EML or object types; #4517 (merged 2026-11-03) reports what cannot be downported inside a statement'
---

# downport: report what has no 7.02 form

## Why

Every repository of the abap2UI5 ecosystem has to downport to 7.02.
samples-stack is the one that cannot, and it is not a defect of the downport
that EML does not exist on 7.02. What is missing is the **answer to "what
does not downport"**: today it is a few hundred parser and syntax errors
spread over a tree, and a repository has to read them to decide which
packages it can deliver for 7.02.

## Proposed

A downport mode (or a rule, `downport_unavailable`) that reports per OBJECT:

- object types that do not exist at the target version (`DDLS`, `BDEF`,
  `SRVD`, `SRVB`, `G4BA`, `HTTP`, `SIA*`, ... at v702), and
- objects whose code needs something with no downport: EML
  (`MODIFY/READ/COMMIT/ROLLBACK ENTITIES`), a behavior pool
  (`cl_abap_behavior_handler`), a released-API class that has no 7.02
  counterpart (`xco_cp_*`),

with the transitive closure (a class that calls such an object). A repository
then drops exactly those objects from its 7.02 tree, the way abap2UI5 drops
its BSP, and delivers the rest - for samples-stack the packages 01, 02 and
06-10, 14 look downportable.

## Must not

Report an object whose statements `--fix` can lower (the 824 `downport`
findings of the same run that `--fix` removed).
