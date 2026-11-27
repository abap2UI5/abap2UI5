---
target: abaplint
title: 'The 702 downport does not lower a string template with ALPHA = IN|OUT and WIDTH'
summary: '|{ lv_value ALPHA = IN WIDTH = iv_length }| stays a parser error at v702 - the downport handles a formatting that is exactly ALPHA = IN or ALPHA = OUT'
priority: low
state: open
first_seen: 2026-11-27
upstream: abaplint/abaplint
evidence:
  - 'abap-util/business-api 66dca94, 2026-11: rv_result = |{ lv_value ALPHA = IN WIDTH = iv_length }|. replaced by a WHILE loop, the form "7.02 does not take"'
  - 'probed 2026-11-27 against abaplint main after 2.120.122, syntax v702: parser_error and no fix, also with WIDTH = 10; rules/downport.ts stringTemplateAlpha matches a formatting of exactly ALPHA = IN or ALPHA = OUT'
---

# The 702 downport: `ALPHA` together with `WIDTH`

```abap
rv_result = |{ lv_value ALPHA = IN WIDTH = 10 }|.
```

Plain `ALPHA = IN` / `OUT` is lowered to the conversion exit. With `WIDTH`
next to it the template is left as it is and does not parse at v702.

## Proposal

For a literal width, call `CONVERSION_EXIT_ALPHA_INPUT` / `_OUTPUT` into a
`c` field of that length. A variable width has no simple 7.02 form
(`CREATE DATA` or a pad loop) - report it as not downportable instead of
leaving a parser error.

## Must not change

Plain `ALPHA = IN` / `OUT`, and `WIDTH` without `ALPHA` (valid on 7.02).

One site so far - low priority.
