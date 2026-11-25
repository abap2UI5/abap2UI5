---
target: abaplint
title: 'FOR ALL ENTRIES with ORDER BY <field list> is not reported - and select_add_order_by asks for it'
summary: 'with FOR ALL ENTRIES only ORDER BY PRIMARY KEY is allowed; SELECT f FROM t FOR ALL ENTRIES IN @x ... ORDER BY f does not activate ("F is invalid here"), check_syntax stays silent, and select_add_order_by reports the same statement without ORDER BY unless skipForAllEntries is set'
priority: high
state: filed
filed: https://github.com/oblomov-dev/fork-abaplint/pull/3
first_seen: 2026-11-25
checked_upstream: 2026-11-25
upstream: abaplint/abaplint#3131
evidence:
  - 'a downstream app repository, review of 2026-11: select_add_order_by switched on and every reported SELECT given an ORDER BY; nine FOR ALL ENTRIES field lists got ORDER BY <their fields>. An activation on the system (2026-11-25) refused all nine ("SDABW is invalid here (due to grammar)", "AUFKY ...", "RSRC ...", "BUSINESSPARTNER ...", "MEINH ...", "STOCK_DOCCAT ...", "WERKS ...") plus follow-up errors for every inline result table; abaplint (check_syntax and strict_sql on, 2.120.116) reported nothing. Fixed by removing the ORDER BY and setting select_add_order_by skipForAllEntries: true'
  - 'probed 2026-11-25 against abaplint 2.120.113 (check_syntax, strict_sql, parser_error on, open-abap-core): SELECT mandt, mtext FROM t000 FOR ALL ENTRIES IN @it_keys WHERE mandt = @it_keys-mandt ORDER BY mtext INTO TABLE @lt_res. - no finding; a control finding in the same class fired'
  - 'upstream: abaplint/abaplint#3131 (open) "select_add_order_by: cannot use order by with for all entries" - the rule side; nothing on check_syntax refusing the statement'
---

# FOR ALL ENTRIES with ORDER BY <field list> is not reported

```abap
SELECT sdabw, bezei FROM tvsakt
  FOR ALL ENTRIES IN @t_vttk
  WHERE spras = @sy-langu AND sdabw = @t_vttk-sdabw
  ORDER BY sdabw, bezei            " system: "SDABW is invalid here" - only PRIMARY KEY
  INTO TABLE @DATA(tvsakt).
```

## Current behaviour

- `check_syntax` accepts the statement; the system does not activate it.
- `select_add_order_by` reports the same SELECT without `ORDER BY` ("Add ORDER
  BY") unless `skipForAllEntries` is set - following it produces the error
  above whenever the field list does not hold the whole primary key.

## Proposal

1. `check_syntax`: with `FOR ALL ENTRIES`, refuse an `ORDER BY` other than
   `ORDER BY PRIMARY KEY` (and `PRIMARY KEY` only when the field list holds
   the key).
2. `select_add_order_by`: for a FOR ALL ENTRIES SELECT, suggest `ORDER BY
   PRIMARY KEY` only where it is allowed and skip it otherwise - or make
   `skipForAllEntries` the default.
