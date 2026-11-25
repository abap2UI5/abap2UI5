---
target: abap2ui5-linter
title: 'Report a link or bookmark built from the draft id instead of app_state_get_href( )'
summary: 'an app that builds its own share link or bookmark from get( )-s_draft-id points at a draft the default pruning deletes after two roundtrips, or one an unchanged timer tick never wrote - app_state_get_href( ) is the link the framework keeps alive'
priority: high
state: filed
filed: https://github.com/abap2UI5/linter/pull/204
first_seen: 2026-11-24
checked_upstream: 2026-11-24
evidence:
  - 'abap2UI5 04ead8ec (2026-11-24): draft_keep_per_chain is seeded with 2 - every save deletes the draft at depth 3 of the chain, so a draft id older than two roundtrips is gone'
  - 'abap2UI5 cdd2fb25 (2026-11-24): an unchanged timer tick answers with the id of the draft it continued and writes no row; the drafts of an app state link and of a route restore are the ones pruning never deletes (mt_draft_keep), and a tick that hands out an app state link always writes'
  - 'docs/agents/architecture-seams.md, "Fewer drafts": the id get( )-s_draft-id shows during an unchanged tick is minted and never written; a link is made with app_state_get_href( )'
  - 'docs/agents/building-apps.md section 7: client->app_state_get_href( ) returns the absolute, FLP-safe link to the current state'
  - '@abap2ui5/linter 0.11.0 has no rule reading s_draft; no issue in abap2UI5/linter (searched 2026-11-24)'
---

# Report a link or bookmark built from the draft id instead of app_state_get_href( )

## Motivation

`client->get( )-s_draft-id` is the id of the draft the current roundtrip
continues. It looks like the obvious thing to put into a link that brings a
user back to this state - and until 2026-11 it mostly worked, because a
draft lived until `draft_exp_time_in_hours` took it.

Since abap2UI5 04ead8ec the framework keeps two drafts per chain by default:
every save deletes the one at depth three. A link built from the current id
points at nothing two roundtrips later. Since cdd2fb25 an unchanged timer
tick writes no draft at all and answers with the id it continued. Neither
change is a bug: the drafts an app hands out on purpose - the one behind
`app_state_get_href( )` / `app_state_set_active( )` - are kept, and that is
the only way the framework can know which ones are handed out.

## Current behaviour

- `client->app_state_get_href( )` returns the absolute, FLP-safe link to the
  current state and marks its draft as kept.
- `get( )-s_draft-id` is readable by every app and says nothing about its
  lifetime.
- No rule reads it.

## Proposed rule

`draft-id-as-link`, severity warning.

Report a read of `s_draft-id` (also `s_draft-id_prev`) from `client->get( )`,
directly or through a variable that holds `get( )`, whose value flows, in
the same method, into

- a string template or concatenation that also contains `#`, `?`, `sap-`,
  `http` or a variable holding a URL, or
- a `follow_up_action( )` / view attribute that opens or copies a link
  (`OPEN_NEW_TAB`, `CLIPBOARD_COPY`, `URLHELPER`, an `href` or `src`
  attribute), or
- a database write (`INSERT`/`MODIFY`/`UPDATE` of an app table - a stored
  bookmark).

Message: this draft is pruned after two roundtrips; use
`client->app_state_get_href( )`, which keeps the draft behind the link.

## What it must not report

- Logging or tracing the id (`MESSAGE`, a log call, a text in the view).
- A comparison (`IF id = previous_id`) or a pass to the framework itself.
- Framework and developer-tool code that reads the id to inspect drafts.

## Example

```abap
DATA(lv_link) = |{ lv_flp_url }#/z2ui5-xapp-state={ client->get( )-s_draft-id }|.  " reported
client->follow_up_action( val = client->cs_event-clipboard_copy t_arg = VALUE #( ( lv_link ) ) ).

DATA(lv_link) = client->app_state_get_href( ).                                           " not reported
```
