---
target: abap2ui5-linter
title: 'A bound field names a page, but the position is never re-issued after view_display - so the app contradicts itself'
summary: a NavContainer / FlexibleColumnLayout / ToolPage position is live control state a rebuilt view resets, while the bound `selectedKey`-family field that describes it is class state that survives; the discriminator is mechanical and a rule can carry it
priority: medium
state: open
first_seen: 2026-08-26
upstream: abap2UI5/linter
evidence:
  - samples-controls app 585 - measured through the framework's own app-state restore: `selected_key` (two-way bound to SideNavigation.selectedKey) survived as `root2` while the NavContainer returned to its `initialPage="page2"`, so the side nav highlighted one item and the content pane showed another
  - apps 302, 303, 167 are structurally identical (bound `selectedkey` + a NavContainer returning to its initialPage); app 301 is the sharpest, because TWO fields contradict the reset - `selectedkey` AND `page_text`, which the item-select handler writes onto the target page
  - app 558 needs no navigation trick at all - pressing "+" on the tab bar creates the tab, sets selected_tab/save_visible/cancel_visible, and drops the user on the product list, because four of its handlers call view_display( ) from on_event
  - the same sweep cleared 8 ports as legitimate (096, 097, 242, 263, 407, 012, 101, 565), so the class is discriminating rather than blanket - in each of those nothing survives that names a page
  - this is the same defect shape as the confirmed 607, 249 and 534 fixes, all of which put the remedy at the tail of view_display( ) guarded by the surviving state
---

# A bound field names a page the rebuilt view no longer shows

## Motivation

abap2UI5 rebuilds the whole view on `view_display( )`. A NavContainer's current
page, an FCL column position and a Carousel's active page are **live control
state**: `XMLView.create` puts them back to what the XML declares. A two-way
bound field is not - it is class state and it survives.

When a port stores the position in such a field, the two disagree after every
rebuild, and the app tells the user something that is not on screen. That is
exactly the shape of the `binding_call` filter loss (app 607), the badge bounds
loss (app 249) and the wizard branch loss (app 534) - all three confirmed and
all three fixed the same way.

`check_on_navigated( )` reaches `view_display( )` on a draft restore and on
return from a called app, neither of which has an upstream counterpart: a UI5
sample re-instantiated from scratch also lands on its first page, but it has no
bookmark that restores model state and not view state. So "the original does it
too" is not a defence here.

## What a rule would need to decide it

The discriminator found by the corpus sweep is mechanical, which is why this is
worth a rule rather than a checklist:

> a control whose position is not bindable (`NavContainer`, `sap.f.FlexibleColumnLayout`,
> `sap.tnt.ToolPage`, `sap.m.Carousel`) is moved by a `control_by_id`
> (`to`, `toDetail`, `toMaster`, `setActivePage`, …) issued from an event
> handler, **and** the class has a two-way bound field whose value names one of
> that control's page ids, **and** `view_display( )` does not re-issue the
> position.

The third clause is what separates a defect from a legitimate fresh start, and
it is the same test the `expandToLevel` ports (601, 602, 248, 365) and the
shortcut re-registration (232) already pass.

## What the rule must NOT do

- **It must not fire when nothing names a page.** Apps 096/097 keep only a
  SplitApp *mode*, 242 keeps only the *transition*, 263 keeps only a checkbox -
  a fresh first page is faithful there, and 263's whole subject is that a
  re-entry resets.
- **It must not fire on a transient popup.** A `follow_up_action` on a popup
  control queued in the same round trip as `popup_display` is safe: the display
  actions are awaited before the custom actions, so the control exists by then.
- **It must not demand a re-issue that cannot be written.** `sap.f.FlexibleColumnLayout.to`
  is currently a silent no-op through the whitelist (see
  `fcl-control-id-cast-in-to`), so for FCL ports the remedy does not exist yet
  and a finding would be unactionable until that is fixed.
