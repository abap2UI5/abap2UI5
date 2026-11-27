---
target: abaplint
title: 'Report tables that have a replacement object on S/4HANA (MARD, MSEG, MBEW ...)'
summary: 'SLIN "The table MARD has a replacement object and hence should no longer be used" at 20+ sites of one consumer system - a configurable table list, like forbidden_void_type for types, would catch it'
priority: low
state: open
first_seen: 2026-11-24
checked_upstream: 2026-11-24
upstream: abaplint/abaplint
evidence:
  - 'one activation of a consumer system on S/4HANA (2026-11-24) warned "The table <name> has a replacement object and hence should no longer be used" for MARD, MCHB, MBEW, EBEW, MARC, MKPF, MSEG, MSKA, MSLB, MSKU, MKOL and /SAPAPO/MATMAP - more than 20 sites'
  - 'probed 2026-11-24 against abaplint 2.120.116, every rule on from `abaplint --default`, open-abap-core as dependency, an isolated syntax-clean project with a control finding firing: SELECT * FROM mard WHERE werks = ''1000'' INTO TABLE @DATA(lt_mard) with MARD as a TABL in the project - only check_subrc and select_add_order_by'
---

# Report tables that have a replacement object on S/4HANA (MARD, MSEG, MBEW ...)

```abap
SELECT * FROM mard                     " SLIN: The table MARD has a replacement object
  WHERE werks = '1000'                 "       and hence should no longer be used
  INTO TABLE @DATA(lt_mard).
```

On S/4HANA the inventory management tables (MARD, MCHB, MKPF, MSEG, ...) and
the valuation tables (MBEW, EBEW, ...) are served through replacement objects
(compatibility CDS views on MATDOC, the NSDM_* views); reading the table name
still works, the extended check says it should not be used. Which tables have
one is SAP data a project cannot derive, so it is a configured list.

**Proposal.** An option on an existing rule rather than a new one - the shape
is `forbidden_void_type` for database tables: a list of table names (or
patterns) that are reported in `SELECT ... FROM`, `JOIN`, `UPDATE`,
`INSERT`, `MODIFY`, `DELETE` and as a `TYPE` of a table, with an optional
replacement text per entry. `forbidden_identifier` is too coarse (it reads
tokens, not SQL sources); `db_operation_in_loop` and the `select_*` rules
are about something else.

**Not reported.** The replacements themselves (`NSDM_E_MARD`, the I_* CDS
views); a table not on the list; a type referring to a data element of the
same name.

**Where.** `forbidden_void_type` (a `tables` option) or a sibling rule.
**Effort:** S.

**Source.** A consumer system, one activation on S/4HANA.

**Overlap.** abaplint-release-api-availability asks for a per-release list of
SAP APIs that do not EXIST on a release; this is the inverse - objects that
exist and should not be used there. The same configured-list mechanism could
carry both; they are kept as two items because the data and the message
differ.
