---
target: abaplint
title: 'Report INNER JOIN on a text table'
summary: 'joining a data table with its text table INNER drops every row that has no text in the logon language - the result silently misses data'
priority: medium
state: open
first_seen: 2026-10-12
checked_upstream: 2026-10-12
upstream: abaplint/abaplint
evidence:
  - 'abapOpenChecks check 076 (larshp/abapOpenChecks docs/_checks/76.md)'
  - 'probed 2026-10-12 against abaplint main after v2.120.75 with every default rule on (Config.getDefault, v750): no rule reports the bad example'
---

# Report INNER JOIN on a text table

Rows without a translation vanish.

```abap
SELECT a~matnr, t~maktx FROM mara AS a
  INNER JOIN makt AS t ON t~matnr = a~matnr
  INTO TABLE @DATA(lt).
```

Instead:

```abap
SELECT a~matnr, t~maktx FROM mara AS a
  LEFT OUTER JOIN makt AS t ON t~matnr = a~matnr AND t~spras = @sy-langu
  INTO TABLE @DATA(lt).
```

**Proposal.** Report INNER JOIN where the joined table is the text table of the other (foreign key with cardinality text table in the TABL XML, or a configured list for void SAP tables).

**Not reported.** LEFT OUTER JOIN; joins between two data tables.

**Where.** a new rule (or an option of the closest existing one). **Effort:** M.

**Source.** abapOpenChecks check 076.
