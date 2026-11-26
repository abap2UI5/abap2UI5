---
target: abaplint
title: 'rename: function groups (FUGR) and their function modules'
summary: abaplint cannot rename a function group - it blocks the namespace rename of rfc-connector (a function group for its RFC entry points) today; the renamer would rename the group, its includes (L<group>TOP, ...), its function modules and every CALL FUNCTION of them
priority: high
state: open
upstream: abaplint/abaplint
first_seen: 2026-11-26
checked_upstream: 2026-11-26
evidence:
  - 'abaplint 2.120.120 Renamer.factory: no FUGR - "Renaming of FUGR not yet supported"'
  - 'audit 2026-11-26 (backlog item abap2ui5-addon-rename-gaps): rfc-connector has a function group and SUSH objects (not renameable) and Z2UI5_CL_RFC_CONNECTOR_HANDLER with 30 characters - no namespace rename'
  - 'gh search 2026-11-26 (repo:abaplint/abaplint, issues and pull requests: "rename function group", "renaming FUGR"): nothing'
---

# rename: function groups (FUGR)

## Why

Every repository of the abap2UI5 ecosystem has to be renameable into a
customer namespace. **rfc-connector** cannot be: its RFC entry points live in
a function group, and abaplint has no renamer for `FUGR`.

## Proposed

A `FUGR` renamer, used by a pattern of `type: "FUGR"`:

- the group (`<name>.fugr.xml`, the folder of its includes), its includes
  `L<group>TOP`, `L<group>UXX`, `L<group>U01`... and `SAPL<group>`;
- every function module matched by the same pattern (`FUNC` names are
  global like class names), with its `CALL FUNCTION 'NAME'` references - which
  are literals, so this needs the literal handling of #4719 or the renamer has
  to rewrite exactly the `CALL FUNCTION` operand;
- the 26-character limit of a function group name and 30 of a function module.

## Must not

Rename a `CALL FUNCTION` of a module that is not part of the renamed set
(SAP standard, another group).
