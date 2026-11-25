---
target: abap2ui5-linter
title: 'unescaped-brace-in-style: ABAP string-template interpolation and a( t = ) are not unescaped braces'
summary: 'unescaped-brace-in-style reads the { x } of an ABAP string template as literal CSS braces, and ignores that a( t = ) already escapes binding braces - an error-level false positive on correct code'
priority: medium
state: filed
filed: https://github.com/abap2UI5/linter/pull/202
first_seen: 2026-11-25
checked_upstream: 2026-11-25
evidence:
  - '@abap2ui5/linter 0.11.3 on oblomov-dev/S5S_DEV (DEV 2bcdc50): /kro/ui501_cl_app_view, methods xml_build_style and xml_build_column_sort_css - i_xml->tag( n = `HTML` ns = `core` )->a( n = `content` t = |<style type="text/css">{ i_css }</style>| ) reported twice as "2 unescaped brace(s) in a <style> block (…{ i_css }…)" (error)'
  - 'the braces are the ABAP interpolation of the variable, not part of the CSS; the CSS rules inside lv_css are written as \{ \} in the template; and a( t = ) passes the value through z2ui5_cl_ui5_view_builder=>escape_literal (z2ui5_cl_ui5_util_context=>ui5_escape_binding_literal), which escapes the binding braces anyway'
  - 'baselined as a false positive in S5S_DEV abap2ui5lint-baseline.json; abap2UI5/linter open issues and PRs checked 2026-11-25 (#195, #196, #197): nothing on this'
---

# unescaped-brace-in-style: ABAP string templates and a( t = )

```abap
" correct - reported as "2 unescaped brace(s) in a <style> block (…{ lv_css }…)"
i_xml->tag( n  = `HTML`
            ns = `core`
    )->a( n = `content` t = |<style type="text/css">{ lv_css }</style>| ).
```

## Motivation

Two separate misreadings stack up here:

1. **String templates.** In `|...{ lv_css }...|` the braces delimit an
   embedded expression; they never reach the XML. A literal brace in a
   template is written `\{` / `\}`. The rule counts the source braces
   instead of the braces the template produces.
2. **`a( t = )`.** The `t` parameter of `z2ui5_cl_ui5_view_builder->a( )`
   is text: the builder escapes it with `escape_literal( )` so UI5's
   binding parser does not read braces. Whatever the value holds, the
   rendered attribute has no unescaped braces.

## Proposal

- When the style text comes from an ABAP string template, evaluate the
  template's literal parts only: `{ expr }` is an opaque value (unknown
  content), `\{` / `\}` are literal braces. Report only literal braces that
  are not escaped.
- When the value is passed as `t =` of `a( )` (or another builder parameter
  that escapes binding syntax), do not report at all - the framework escapes.
- An opaque interpolated value may still be worth a hint when it is passed
  with `v =` (unescaped) - its content is unknown to the linter.

## Must not change

- `a( n = `content` v = `<style>.x { color: red }</style>` )` - literal,
  unescaped braces passed with `v` - is still an error.
- A `<style>` element in a raw `*.view.xml` / `*.fragment.xml` is judged as
  today.
