---
target: abaplint
title: 'Parse error for a literal that ends where the next token begins — ``arg = `x`s_ctrl = …``'
summary: the lexer ends a string literal at its closing delimiter and starts the next token right there, so source the SAP syntax check refuses ("There must be a space or equivalent character after …") is accepted with zero findings
priority: medium
state: open
first_seen: 2026-09-13
checked_upstream: 2026-09-13
upstream: abaplint/abaplint
evidence:
  - abap2UI5/samples-controls `z2ui5_cl_smpc_app_136` (`view_display`, the `toggle` wire) and `z2ui5_cl_smpc_app_588` (`view_display`, the `beforeNavigate` wire) — a user's Code Inspector run of variant SYNTAX_CHECK over a pulled `main` reported six errors on 2026-09-13, two of them the missing separator and four the follow-on "The statement ENDMETHOD is missing."; `npx abaplint` was green over the same tree (0 issues, 1299 files, 2.120.38, `check_syntax` on)
  - measured 2026-09-13 on 2.120.38, isolated two-file project, `check_syntax` + `parser_error` on, `syntax.version` v750: `m( a = `x`b = `y` ).` and `m( a = 'x'b = `y` ).` both produce 0 issues; the control probe (an undefined variable in the same method) fires
---

# Parse error for a literal that ends where the next token begins

## What happens

```abap
m( a = `x`b = `y` ).
m( a = 'x'b = `y` ).
```

A system answers with

> *There must be a space or equivalent character (":", ",", ".") after `x`.*

and, because the statement then never terminates, a second error on the
enclosing method:

> *The statement "ENDMETHOD" is missing.*

abaplint reports neither. Measured on 2.120.38 in a two-file project with
`parser_error` and `check_syntax` on and nothing else in it: **0 issues**. The
control probe — an undefined variable in the same method — fires, so the run is
not the empty-`rules` trap.

## Why it matters here

The two sites this came from are view wires in generated ABAP, where a literal
is followed by the next named parameter:

```abap
)->a( n = `toggle` v = client->_event( val = `TOGGLE`
        arg = `${$parameters>/expanded}`s_ctrl = VALUE #( … ) )
```

Nothing between writing that line and pulling it into a system says a word:
abaplint is green, the transpiler runs it (`@abaplint/runtime` gets a token
stream, not a character stream), and the unit tests pass. The class then does
not activate, and a user reports it — which is how these two were found, four
weeks after they were written.

## Proposed change

A closing string literal that is immediately followed by a **name character**
(`A-Z a-z 0-9 _`) is a parse error. The lexer already knows where the literal
ends; the check is the character after it.

All three delimiters have the hole:

| written | system |
|---|---|
| `` `x`y `` | rejected |
| `'x'y` | rejected |
| `\|x\|y` | rejected |

## What it must NOT report

- **The text symbol form `'text'(001)`.** This is the one suffix ABAP allows
  after a literal, and it opens a parenthesis — not a name character — so the
  narrow rule above already passes it. A rule written as "a literal must be
  followed by whitespace" would break every text symbol in every repository.
- **A doubled delimiter inside a literal** — ``` `it``s` ```, `'it''s'` — which
  is not a closing delimiter at all.
- **Anything inside a comment.** `" a note about `x`y` is prose.
- **The escaped delimiter of a string template**, `|a \| b|`.
- **A closing literal followed by a symbol**: `` `x`. ``, `` `x`) ``,
  `` `x`&&`y` ``. Only a name character is the error; the compiler's own
  message lists `:`, `,` and `.` as equivalents of the blank.

## Worked around here

`abap2UI5/samples-controls` gates it in `scripts/pattern-lint.mjs`
(`literal-no-separator`, 2026-09-13) — a one-line scan over the three
delimiters with the exemptions above, and a unit test that holds each
boundary. It is a kernel rule with nothing abap2UI5-specific about it, so it
belongs upstream rather than in four repositories' own linters; the local gate
goes the day a released abaplint reports it.
