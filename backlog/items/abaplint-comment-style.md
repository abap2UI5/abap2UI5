---
target: abaplint
title: 'Comment style: * comments, indentation, TODO markers, a space after the quote'
summary: 'four comment checks one rule can carry as options - * instead of ", comments not indented like the next statement, TODO/FIXME/XXX markers, no space after " (abaplint/abaplint#633 is exactly this ''Comment Style'' rule)'
priority: low
state: filed
filed: https://github.com/abaplint/abaplint/issues/633
first_seen: 2026-10-12
checked_upstream: 2026-10-12
upstream: abaplint/abaplint
evidence:
  - 'probed 2026-10-12 against abaplint main after v2.120.75 with every default rule on (Config.getDefault, v750): no rule reports the bad example'
---

# Comment style: * comments, indentation, TODO markers, a space after the quote

All four look at comment lines only and share one walk over the file; each is an option, off by default except where noted.

Merged on 2026-10-12 from the items `abaplint-asterisk-comments`, `abaplint-comment-indentation`, `abaplint-comment-markers`.

## Report * comments in code (Clean ABAP: comment with ", not *)

```abap
* explains the next line
    lv = 1.
```

**Proposal.** Report full-line comments starting with * inside procedures (option: everywhere); quick fix to ".

**Not reported.** Header comment blocks at the top of an include (option); generated code.

## Report " comments not indented like the statement that follows

```abap
  METHOD run.
" explains the return
    RETURN.
```

**Proposal.** Report full-line " comments whose column differs from the next statement's; quick fix re-indents. Could be an option of indentation.

**Not reported.** End-of-line comments; comments in empty branches; ABAP Doc (wrong_abapdoc_position).

## Report TODO, FIXME and XXX markers in comments

A marker in a comment is work that was left behind.

```abap
" TODO handle the empty case
```

**Proposal.** Report comments containing configurable markers (default TODO, FIXME, XXX), case-insensitive, as a word.

**Not reported.** Words that merely contain the marker ("todos"); ABAP Doc (option).

## Put a space after the " comment sign

abaplint/abaplint#1313 asks for the same.

```abap
"no space after the quote
lv = 1.
```

**Proposal.** Report full-line and end-of-line comments whose " is not followed by a blank; quick fix inserts it.

**Not reported.** ABAP Doc ("!), pseudo comments ("#EC), commented-out code.

**Where.** a new rule, one option per check. **Effort:** S.

An upstream request exists (https://github.com/abaplint/abaplint/issues/633); this item collects the cases and the scope for a pull request.
