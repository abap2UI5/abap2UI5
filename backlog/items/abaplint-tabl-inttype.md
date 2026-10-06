---
target: abaplint
title: 'xml_consistency: a TABL field whose INTTYPE does not match its DATATYPE'
summary: 'an INT4 field serialized as `<INTTYPE>I</INTTYPE>` - abapGit writes `X` - shows a diff on every pull; abaplint reads DATATYPE only'
priority: low
state: open
first_seen: 2026-10-06
upstream: abaplint/abaplint
evidence:
  - abap2UI5-addons/admin-cockpit, 2026-10-06 - a user's pull showed a diff for every table with INT4 fields (Z2UI5_T_CK_ACT, _AGG, _ALR, _LOG; 27 fields): the system serializes `<INTTYPE>X</INTTYPE>`, the hand-written sidecars had `I`; fixed in abap2UI5-addons/admin-cockpit#6
  - the sidecars of real exports agree: `abap-cloud-gui/tools/report2cloud/test/ddic/spfli.tabl.xml` and `sflight.tabl.xml` carry `X` for INT4
  - measured 2026-10-06 on abaplint 2.120.64 with `xml_consistency` on - no finding
---

# xml_consistency: INTTYPE that does not match DATATYPE

## What happens

```xml
<DD03P>
 <FIELDNAME>CNT</FIELDNAME>
 <INTTYPE>I</INTTYPE>      <!-- abapGit writes X for INT4 -->
 <INTLEN>000004</INTLEN>
 <DATATYPE>INT4</DATATYPE>
 ...
```

The table activates. abapGit serializes the field back with
`<INTTYPE>X</INTTYPE>`, so every pull lists the table as changed, and the
diff hides real changes.

## Proposed check

In `xml_consistency`, for a DD03P with a built-in `DATATYPE` and an
`INTTYPE`, report an `INTTYPE` that is not the one the dictionary writes for
that type. Confirmed pairs: `CHAR` - `C`, `INT4` - `X`, `DEC` - `P`, `STRG` -
`g`. Report only confirmed pairs; leave the others alone until a system
export confirms them.

## What it must NOT report

- A field typed by a data element (`ROLLNAME`, no `INTTYPE`).
- A `DATATYPE` that is not in the confirmed list.
