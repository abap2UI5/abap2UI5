---
target: abap2ui5-linter
title: 'Report a start parameter read by hand instead of client->get_start_param( )'
summary: 'an app that reads its start parameter from url_param_get( ) or t_comp_params itself covers one way of being started and misses the others (URL, launchpad tile, launchpad intent); client->get_start_param( ) reads all three'
priority: low
state: filed
filed: https://github.com/abap2UI5/linter/pull/204
first_seen: 2026-11-24
checked_upstream: 2026-11-24
evidence:
  - 'abap2UI5 4eed97a1 (2026-11-24): client->get_start_param( name ) reads the URL query (sap-startup-params unpacked), then the launchpad startupParameters, then the query of the launchpad intent in the hash; the apps it replaced each carried their own copy of "url_param_get( s_config-search ), else t_comp_params, then to_upper"'
  - 'a downstream app repository, review of 2026-11 - seven hand-written copies of that read'
  - 'docs/agents/building-apps.md section 7 documents get_start_param( ) - prose only; @abap2ui5/linter 0.11.0 has no rule reading s_config-search or t_comp_params; no issue in abap2UI5/linter (searched 2026-11-24)'
---

# Report a start parameter read by hand instead of client->get_start_param( )

## Motivation

An app can be started three ways, and each carries its parameters
somewhere else: `?lgn=0001` on the URL, a `startupParameters` entry of a
launchpad tile, or the query of a launchpad intent `#Object-action?lgn=0001`.
An app that reads one source by hand works the way its author tested it and
silently starts empty the other ways. The copies that exist read two of the
three, upper-case the value whether or not the key wants it, and drift apart.

`client->get_start_param( name )` (abap2UI5 4eed97a1) reads all three in a
fixed order and matches the name in any case.

## Current behaviour

- The sources stay readable - `get( )-s_config-search`,
  `get( )-t_comp_params`, `get( )-s_config-hash` - and the old utility
  `url_param_get( )` still parses a query string.
- No rule reads them.

## Proposed rule

`start-param-by-hand`, severity hint.

Report, in a class implementing `z2ui5_if_app`:

- a read of `t_comp_params` from `client->get( )` (a `READ TABLE`, a table
  expression, a `LOOP AT`), or
- a call of a `url_param_get( )` whose URL argument is
  `client->get( )-s_config-search` (or a variable assigned from it).

Message: `client->get_start_param( name )` reads the URL, the tile and the
intent.

## What it must not report

- Reading `s_config-search` or `s_config-hash` for anything else (the
  origin, a route, a debug flag on the URL that a tile never sets) - only
  the `url_param_get( )` form above is reported.
- A class that is not an app (a helper or the framework itself).

## Example

```abap
DATA(lv_lgn) = z2ui5_cl_util=>url_param_get( val = `lgn` url = client->get( )-s_config-search ).  " reported
IF lv_lgn IS INITIAL.
  lv_lgn = VALUE #( client->get( )-t_comp_params[ n = `LGN` ]-v OPTIONAL ).                     " reported
ENDIF.

DATA(lv_lgn) = client->get_start_param( `lgn` ).                                                " not reported
```
