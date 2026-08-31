---
target: abap2ui5-linter
title: 'The rebuild-survival check cannot see the `to( )` family - a NavContainer/FCL position `view_display( )` resets while a bound field still names the page'
summary: `control-state-lost-on-rebuild` judges only `set…( )` wires, so the containers whose position is moved by a NAVIGATION call (`to`, `backToPage`, `toDetail`, `toMaster`) are structurally outside it - and there the discriminator is not "the value is non-literal" but "a surviving bound field names a page id of that container"
priority: medium
state: open
first_seen: 2026-08-26
checked_upstream: 2026-08-30
upstream: abap2UI5/linter
evidence:
  - samples-controls app 585 - measured through the framework's own app-state restore - `selected_key` (two-way bound to SideNavigation.selectedKey) survived as `root2` while the NavContainer returned to its `initialPage="page2"`, so the side nav highlighted one item and the content pane showed another
  - the remedy is now written by hand in SEVEN ports - 167, 301, 302, 303, 558, 578, 585 - each ending `view_display( )` on a `control_by_id` `to( )` guarded by the field that survived. 578 is the `sap.f.FlexibleColumnLayout` one, 558 the one that needed no navigation trick at all (four of its handlers call `view_display( )` from `on_event`). Every one of them is a worked example rather than a live defect today, and nothing stops an eighth from being written without it
  - "the value is non-literal" does NOT discriminate here, and two ports prove it - app 242 wires `to` with `client->get_event_arg( )` and keeps a two-way bound `animation`; app 096 wires `toDetail` with `client->get_event_arg( )` and keeps a two-way bound `mode`. Both are correct: the surviving field names a TRANSITION and a SplitAppMode, not a page
  - apps 096/097 (`to`/`toMaster` at literal `detailDetail`/`master2`), 263 and 565 (`to` at literal `page1`/`page2`/`detail`) keep nothing that names a page either, so the class stays discriminating rather than blanket
  - `control-state-lost-on-rebuild` (linter v0.5.0, still v0.5.1) already covers the `set…( )` half this item used to ask for as well - `setActivePage`, `setSelectedSection`, `setNextStep`, `setCurrentStep` - so what is left is only the navigation family
  - the remedy this item used to call unwritable now exists for every container in the family: abap2UI5#2669 gave `to` a `pageId` argument kind (`app/webapp/core/actions/ControlCall.js`) and abap2UI5#2670 gave `backToPage` the same, both measured (apps 578 and 101)
  - this is the same defect shape as the confirmed 607, 249 and 534 fixes, all of which put the remedy at the tail of `view_display( )` guarded by the surviving state
---

# A bound field names a page the rebuilt view no longer shows - the half `control-state-lost-on-rebuild` cannot reach

> **Upstream check 2026-08-30: the gap is acknowledged there, not closed.**
> [abap2UI5/linter#66](https://github.com/abap2UI5/linter/pull/66) — *"Say at
> the collector why the navigation family is not in this rule"* — is merged and
> records at the collector why `to( )` and its relatives sit outside
> `control-state-lost-on-rebuild`. So the exclusion is deliberate and
> documented; what is still missing is the check this item proposes. File it as
> a pull request against that collector rather than as a fresh issue, and open
> with #66 so the reviewer sees it is the follow-up to their own note.

## What already ships, and what this asks for

`control-state-lost-on-rebuild` (v0.5.0) decides exactly this question for
`set…( )` wires: a `CONTROL_BY_ID` setter carrying a non-literal value, for a
member no binding can carry, issued only off the display path. Its docs lead
with the association cases - `setNextStep`, `setSelectedSection`,
**`setActivePage`**, `setCurrentStep` - and `setActivePage` is one of the
methods an earlier version of this item named in its own discriminator. That
part is **done**; nothing below re-asks for it.

What is left is the other way a container's position moves: a **navigation
call**. `to`, `backToPage`, `toDetail`, `toMaster` (and `back`, `backDetail`,
`backMaster`, `navigateBack`) are the whole vocabulary of `sap.m.NavContainer`,
`sap.m.SplitApp`/`SplitContainer`, `sap.f.FlexibleColumnLayout` and
`sap.tnt.ToolPage`, and none of them is a setter. The shipped collector matches

    /^set([A-Z]\w*)$/

on the wire's method name, so no navigation call can ever enter it. That is the
subject of this item.

## Motivation

abap2UI5 rebuilds the whole view on `view_display( )`. A NavContainer's current
page and an FCL column position are **live control state**: `view_display( )`
hands new XML to the `VIEW_SLOTS` action, whose `displayMain` destroys the MAIN
slot, and `XMLView.create` builds a fresh tree carrying what the XML declares -
`initialPage`, and nothing else. A two-way bound field is not: it is class state
and it survives.

When a port stores the position in such a field, the two disagree after every
rebuild, and the app tells the user something that is not on screen. That is the
shape of the `binding_call` filter loss (app 607), the badge bounds loss (app
249) and the wizard branch loss (app 534) - all three confirmed, all three fixed
by re-issuing from the display path.

`check_on_navigated( )` reaches `view_display( )` on a draft restore and on
return from a called app, neither of which has an upstream counterpart: a UI5
sample re-instantiated from scratch also lands on its first page, but it has no
bookmark that restores model state and not view state. So "the original does it
too" is not a defence here.

The seven ports that carry the remedy carry it as prose plus a guarded
`follow_up_action( )` at the tail of `view_display( )`. Nothing checks that an
eighth writes it, and nothing would notice if one of the seven lost it in a
refactor.

## What a rule would need to decide it

> a `CONTROL_BY_ID` wire whose method is a **navigation** call
> (`to`, `backToPage`, `toDetail`, `toMaster`) on a container whose position is
> not bindable, issued from a method that is **not** on the display path,
> **and** the class has a two-way bound field whose value can name one of that
> container's page ids, **and** no method on the display path re-issues a
> navigation call on the same container.

Three notes on writing it against what the linter already has:

- **The method list exists.** `frontend-actions.mjs` already exports
  `CONTROL_METHOD_ID_ARG` - `to`, `backToPage`, `toDetail`, `toMaster`, … -
  derived from `CONTROL_METHODS` in the framework's `ControlCall.js`, because
  those first arguments are control ids. The same list is the candidate set
  here.
- **The re-issue test has to key on the CONTAINER, not on id+setter.** The
  shipped rule silences a wire when the same `id|setter` pair is issued from
  the display path. For navigation that is right by container: app 585's
  handler navigates to `key`, its `view_display( )` re-issues `to` with
  `selected_key` - same container, same method, different argument, and that is
  the correct remedy, not a second finding.
- **The bindability test does not transfer.** The shipped rule asks whether a
  property named after the setter is bindable. There is no `to` property and no
  container exposes its current page as one, so that arm answers trivially and
  carries no information. The discriminating clause is the third one - a
  surviving field that names a page.

## What the rule must NOT do

- **It must not fire when nothing names a page.** Apps 096/097 keep only a
  SplitApp *mode*, 242 keeps only the *transition*, 263 keeps only a checkbox -
  a fresh first page is faithful there, and 263's whole subject is that a
  re-entry resets.
- **It must not reuse "the value is non-literal" as the discriminator.** This is
  the trap the `set…( )` rule does not have. For a setter, a non-literal value
  means class state the rebuild will contradict. For a navigation call it means
  nothing of the sort: apps 096 and 242 both navigate to
  `client->get_event_arg( )` - non-literal, read at the moment of the press,
  carried in no field - and both are correct. Conversely a *literal* target can
  still be a defect if a bound field names that same page. The literal/field
  distinction is on the wrong argument; the question is what the CLASS keeps.
- **It must not fire on a transient popup.** A `follow_up_action` on a popup
  control queued in the same round trip as `popup_display` is safe: the display
  actions are awaited before the custom actions, so the control exists by then.
  (The shipped rule already models this; the same exemption applies.)
- **It must not fire on a stack-relative call.** `back`, `backDetail`,
  `backMaster` and `navigateBack` move relative to a `_pageStack` the rebuild
  empties; re-issuing one from `view_display( )` is meaningless. They belong in
  the family for documentation, not in the candidate set.

## For whoever widens the `^set…( )` matcher

The exclusion this item is about is **structural, not decided**. Nothing in
`abap-rules.mjs` or `rule-docs.mjs` says "the navigation family is out of
scope"; it falls out of `/^set([A-Z]\w*)$/` being the collector's entry
condition. Widening that regex to admit `to`/`backToPage`/`toDetail`/`toMaster`
would look like a one-line generalisation and would be wrong on both remaining
tests - it would fire on apps 096 and 242 (non-literal target, surviving bound
field, correct code) and its `id|setter` re-issue key would report app 585's own
remedy. The navigation half needs the third clause above, which is a different
rule, not a wider matcher. Worth a comment at the collector either way, so the
line is visible before somebody crosses it.
