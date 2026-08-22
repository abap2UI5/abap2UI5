---
target: abap2ui5
title: '`MultiInputExt` should also cover the SUGGESTION-ROW validator, not only the free-text one'
summary: the companion control installs a hardcoded free-text validator and ignores `args.suggestionObject`, so a MultiInput with TABULAR suggestions - the demo kit's own copy-pasted idiom - has to round-trip to build a token the original builds on the client
priority: medium
state: open
first_seen: 2026-08-22
upstream: abap2UI5/abap2UI5
evidence:
  - samples-controls apps 612 (`MultiInputFilteringSuggestions`, two MultiInputs) and 613 (`MultiInputGrouping`, one) each carry the same `addValidator` body from the demo kit and each ports it as a `suggestionItemSelected` round trip (batch b51, 2026-08-22)
  - app 040 (`MultiInput`) already uses `z2ui5.cc.MultiInputExt` for the FREE-TEXT half of the same API, so the control and its wiring exist - only the suggestion branch is missing
  - app 501 (`MultiInputValidators`) is the third port whose whole subject is `addValidator`; its three variants are all free-text and are IMPROVISED as round trips
---

# `MultiInputExt` should also cover the SUGGESTION-ROW validator

## What exists today

`app/webapp/cc/MultiInputExt.js` is the invisible companion control for a
`sap.m.MultiInput`. Besides mirroring token updates it installs exactly one
validator:

```js
input.addValidator(({ text }) => new Token({ key: text, text }));
```

That is the **free-text** branch of `sap.m.MultiInput.addValidator`: the user
types something, presses Enter, and the string becomes a token whose key and
text are both that string. App 040 is ported 1:1 with it.

## What the demo kit does that this misses

`addValidator`'s callback receives `{ text, suggestedToken, suggestionObject }`.
`suggestionObject` is set when the user picked a **suggestion row** rather than
typing free text, and the demo kit uses that branch verbatim in more than one
sample:

```js
oMultiInput.addValidator(function (args) {
  if (args.suggestionObject) {
    var key  = args.suggestionObject.getCells()[0].getText();
    var text = key + "(" + args.suggestionObject.getCells()[3].getText() + ")";
    return new Token({ key: key, text: text });
  }
  return null;
});
```

Byte-for-byte the same block appears in `MultiInputFilteringSuggestions`
(twice) and in `MultiInputGrouping`. With tabular suggestions
(`suggestionRows` + `suggestionColumns`) there is no default token at all —
without such a validator, picking a row does not produce one.

The current control's callback ignores `suggestionObject` entirely, so on a
tabular MultiInput it either produces nothing useful or falls through to the
free-text shape.

## What a port has to do instead

Bind a `tokens` table, wire `suggestionItemSelected` and rebuild the token in
ABAP:

```abap
)->a( n = `tokens`                 v = client->_bind( t_tokens )
)->a( n = `suggestionItemSelected` v = client->_event(
        val   = `ADD_TOKEN`
        t_arg = VALUE #( ( `${$parameters>/selectedRow}.getCells()[0].getText()` ) ) )
```

It works and it is what apps 612 and 613 ship. The costs are that a token the
original creates on the client now costs a round trip, and that the `tokens`
attribute plus the `tokens` aggregation are EXTRA vs the original view — in the
sample the tokens only ever exist client-side, so the ports carry an
`IMPROVISED` deviation for a view that is otherwise 1:1.

## Proposed change

Two new properties on `z2ui5.cc.MultiInputExt`, both optional, both inert when
unset — so app 040 and every existing use are untouched:

| Property | Meaning |
|---|---|
| `TokenKeyCell` | index of the suggestion row's cell whose text becomes the token KEY |
| `TokenTextCells` | indices whose texts compose the token TEXT |

and one extra branch in the installed validator:

```js
input.addValidator((args) => {
  if (args.suggestionObject) {
    const cells = args.suggestionObject.getCells();
    const keyIdx = this.getProperty("TokenKeyCell");
    if (keyIdx === undefined || keyIdx === null) return null;
    const key = cells[keyIdx].getText();
    const rest = (this.getProperty("TokenTextCells") || [])
      .map((i) => cells[i].getText());
    return new Token({ key, text: rest.length ? `${key}(${rest.join(" ")})` : key });
  }
  return new Token({ key: args.text, text: args.text });
});
```

The `key(rest)` shape is the demo kit's, and it is the shape all three
occurrences use — which is the argument for baking it rather than inventing a
template mini-language. If a second shape ever shows up, a `TokenTextPattern`
string can be added then, with a case behind it.

## What it must NOT do

- **Not change the free-text branch.** An `addValidator` with no
  `TokenKeyCell` set must behave exactly as it does today; app 040 is the
  regression test.
- **Not reach past `getCells()`.** A suggestion row is a `ColumnListItem` and
  its cells are the sample's own controls; anything deeper is the same
  internal-DOM boundary `pr/control-inline-style` already drew.
- **Not silently swallow a bad index.** An out-of-range cell index should be
  reported the way `Lib.logError` reports the rest of this control's setup
  failures, not turn into `undefined` in a token text.

## Why it is worth doing at all

The round trip is not wrong, and this is not a blocker — it is that the
framework already carries the companion control, already installs a validator
through it, and covers one of the API's two branches. The second branch is a
handful of lines in a file that exists, and it closes the `IMPROVISED`
deviation on every tabular-suggestion port at once.
