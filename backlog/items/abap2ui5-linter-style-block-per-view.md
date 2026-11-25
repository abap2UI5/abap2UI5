---
target: abap2ui5-linter
title: 'Report a large <style> block rendered into every view'
summary: 'an app that puts its stylesheet into a core:HTML <style> of the view sends it with every view_display( ) - kilobytes per roundtrip for CSS that never changes; the installation''s styles_css writes it into the page once'
priority: low
state: filed
filed: https://github.com/abap2UI5/linter/pull/204
first_seen: 2026-11-24
checked_upstream: 2026-11-24
evidence:
  - 'a downstream app repository, review of 2026-11 - a colour palette of about 9 KB of CSS is rendered through core:HTML into every view the apps display, so it travels with every view_display( )'
  - 'src/02/z2ui5_if_ui5_exit.intf.abap, ty_s_http_config-styles_css: "CSS of the installation''s own, written into the page head as a <style> element of its own" - once per page load'
  - '@abap2ui5/linter 0.11.0: unescaped-brace-in-style and collapsed-brace-in-style judge whether the block parses, undefined-css-class whether a class is defined; none looks at where the block lives or what it costs; no issue in abap2UI5/linter (searched 2026-11-24)'
---

# Report a large <style> block rendered into every view

## Motivation

The usual way to give an abap2UI5 app its own CSS is a `core:HTML` control
whose `content` is a `<style>` block. It works, and the linter already
makes sure the braces are escaped. What nobody sees is the cost: the view
is XML sent with the response, so the stylesheet travels with every
`view_display( )` - and an app that rebuilds its view on every event sends
it on every roundtrip. A shared palette copied into each app's view is the
same kilobytes again for every app, every roundtrip.

Two cheaper places exist:

- the installation's exit, `z2ui5_if_ui5_exit=>ty_s_http_config-styles_css`,
  which the HTTP handler writes into the page head once per page load - the
  place for a palette every app shares;
- a view that is displayed once: a roundtrip that only changes data needs
  no `view_display( )`, the bound model updates the view.

## Current behaviour

- `unescaped-brace-in-style`, `collapsed-brace-in-style` and
  `undefined-css-class` judge the block's content.
- Nothing judges its size or how often it is sent.

## Proposed rule

`style-block-per-view`, severity hint.

Report a `<style>` block in a view (the `content` of a `core:HTML`, or a
native `html:style`) whose CSS is larger than a threshold (option
`maxBytes`, default 2048), when the class displays that view from an event
branch - not only from the init branch (`check_on_init` / the first
roundtrip).

Message: about N bytes of CSS are sent with every display of this view;
move a stylesheet that does not change into the exit's `styles_css`, or
display the view once and let the model update it.

## What it must not report

- A small block (under the threshold) - a rule or two for one control is
  the normal use.
- A view displayed only on init.
- A block whose content is built from data (a colour the user picked): it
  does change per roundtrip, and the size is the data's.

## Example

```abap
METHOD z2ui5_if_app~main.
  " … every event:
  client->view_display( view->stringify( ) ).   " the view carries a 9 KB <style> - reported
ENDMETHOD.
```
