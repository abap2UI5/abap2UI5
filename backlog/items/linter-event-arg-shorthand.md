---
target: abap2ui5-linter
title: '`event-arg-out-of-range` counts only `t_arg`, so every `_event( arg = ... )` wire reads as sending zero arguments'
summary: 187 false positives across 125 of 637 ported classes the moment the corpus adopts the one-value shorthand — the rule extracts arguments from `t_arg = VALUE #( )` alone and has no case for `arg`
priority: high
state: filed
first_seen: 2026-08-29
checked_upstream: 2026-08-30
filed: https://github.com/abap2UI5/linter/pull/78
upstream: abap2UI5/linter
evidence:
  - measured on the swept samples-controls corpus, linter 0.5.1 — 187 `event-arg-out-of-range` errors in 125 failing files, every one of them on a wire that does send an argument
  - `lib/abap-rules.mjs:526` matches `/\bt_arg\s*=\s*VALUE\s+#?\s*\(/` and builds the argument list from that region only; a call spelling the same argument as `arg = x` produces an empty list
  - the shorthand ships in abap2UI5 as of the `_event( arg )` / `_bind_path( )` change - `arg = x` is folded into the same `string_table` by the framework and is asserted byte-identical to `t_arg = VALUE #( ( x ) )` in its unit tests
---

# `event-arg-out-of-range` does not know the `arg` shorthand

> **Fixed upstream, not yet released.**
> [abap2UI5/linter#78](https://github.com/abap2UI5/linter/pull/78) — *"Read
> abap2UI5's `arg` shorthand in the two event-argument rules"* — is merged and
> reports the same 187 false positives on the same corpus. It is **not in a
> published version yet**: npm `latest` is 0.5.1 (cut by #65, before #78), and
> `package.json` here pins `^0.5.1`, so `npm run check:abap2ui5` still runs the
> rule without the fix. Nothing is broken today because this repository's own
> app classes do not use the shorthand yet — the corpus that does is
> samples-controls. **Delete this item when a release past 0.5.1 ships and
> `bump-linter.yaml` pulls it in**; until then it records why the pinned
> linter and the framework's own API disagree.

## What happens

`z2ui5_if_client~_event( )` grew an optional `arg` parameter: the one-value
spelling of `t_arg`, folded into the same table by the client, so

```abap
client->_event( val = `ITEM_SELECT` arg = `${$parameters>/item}.getKey()` )
```

emits exactly the wire of

```abap
client->_event( val   = `ITEM_SELECT`
                t_arg = VALUE #( ( `${$parameters>/item}.getKey()` ) ) )
```

`checkEventArgs` reads the sent arguments out of the `t_arg = VALUE #( )`
region only (`lib/abap-rules.mjs:526`). For the first form it finds no region,
builds an empty argument list, and every `get_event_arg( )` in that event's
handler is reported:

```
426:30  error  get_event_arg( 1 ) in the handler of ITEM_SELECT, which sends 0 t_arg
               - the read comes back empty  event-arg-out-of-range
```

The read is correct and the wire is correct; only the rule's model of the
call is short one spelling.

## Scale

Converting the 273 single-argument wires of abap2UI5/samples-controls (637
ports) turns **187 correct wires into errors, in 125 files**. Every finding is
a false positive, and `event-arg-out-of-range` is a rule whose whole value is
that it is trustworthy — it exists to catch a read that really does come back
empty. This is the one failure mode it cannot afford.

## What a rule would need

Treat `arg = <expr>` in an `_event( )` call body as a one-element argument
list, appended behind the `t_arg` elements when both are present (the
framework appends in that order). Concretely, next to the existing `t_arg`
match:

```js
const am = callBody.match(/\barg\s*=\s*([`'])((?:[^`'])*)\1/);
if (am) args.push({ value: am[2], offset: base + am.index });
```

with the same "not statically knowable stays null" treatment
`literalElements` already applies to a variable or an expression, so a
`arg = lv_key` is counted as one argument of unknown value rather than
skipped.

Worth checking in the same pass whether any other rule reads `t_arg` by that
literal: the frontend-action rules do (`control_by_id` id resolution,
`keyboard_shortcut` scope), but those wires are `follow_up_action` /
`_event_client`, which deliberately did NOT get the `arg` parameter — their
`t_arg` is a positional protocol, not a value list. So the backend `_event( )`
path should be the only one affected.

## Until then

The corpus sweep that adopts the shorthand is held: the framework change is
additive and shipped, but samples-controls cannot take it while the rule
reports 187 errors on correct code, and switching `event-arg-out-of-range` off
corpus-wide to land a spelling change would trade a real correctness gate for
cosmetics.
