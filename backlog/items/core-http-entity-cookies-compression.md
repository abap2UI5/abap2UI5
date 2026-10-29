---
target: open-abap
title: 'core: if_http_entity~get_cookies, get_cookie_field and set_compression are `* todo` stubs in cl_http_entity - a stateful app cannot read the ICF session cookie and a response cannot ask for gzip'
summary: '`cl_http_entity` clears `cookies`/`field_value` and returns from `get_cookies( )`, `get_cookie_field( )` and `set_compression( )`; abap2UI5''s contextid transform reads the response cookie the ICF set, so a stateful app answered 500 on the Node host until the host stripped the session headers and ran the session layer itself, and `SET_COMPRESSION` is called dynamically inside a `CATCH cx_root` because the shim lacks it'
priority: medium
state: open
first_seen: 2026-10-22
upstream: open-abap/open-abap-core
evidence:
  - 'read 2026-10-22 in open-abap-core main 239b817 - `src/http/cl_http_entity.clas.abap:82-85` (`get_cookie_field`: `* todo`, `CLEAR field_value`), `:87-89` (`set_compression`: `* todo`), `:115-118` (`get_cookies`: `* todo`, `CLEAR cookies`)'
  - 'abap2UI5 `node/srv/hostcore.mjs:125-130` (2026-10): the framework''s contextid transform ''reads the response cookie the ICF sets - a call open-abap''s HTTP entity does not implement, so a stateful app answered with a 500 here''; `node/tests/sessions.spec.js:17-19`; the host strips the session headers and keeps the sticky handler itself (`withSession`)'
  - 'abap2UI5 `src/02/z2ui5_cl_ui5_http_handler.clas.abap:1086-1095`: `CALL METHOD mo_response_onprem->(`SET_COMPRESSION`)` inside `CATCH cx_root` because ''the transpiled test backend''s response shim simply lacks the method''; `node/srv/compress.mjs:4-13` gzips in express instead'
checked_upstream: 2026-10-22
---

# core: cookies and compression on `cl_http_entity`

## What happens

Three methods of `cl_http_entity` are stubs:

| method | open-abap-core 239b817 | a system |
|---|---|---|
| `if_http_entity~get_cookies( )` | `CLEAR cookies` | the cookie table of the request / the `Set-Cookie`s of the response |
| `if_http_entity~get_cookie_field( )` | `CLEAR field_value` | one cookie's value |
| `if_http_entity~set_compression( )` | nothing | the response is gzip-encoded by the ICF |

abap2UI5's stateful mode reads the `sap-contextid` cookie the server
set on the response to carry it into the next request; on the Node host
that read answered initial and every stateful app returned 500, until
the host took the session layer over (`hostcore.mjs`, `withSession`).
`set_compression` is called through a dynamic `CALL METHOD` in a
`CATCH cx_root` so the transpiled backend survives it, and express gzips
instead.

## Proposed change

- `cl_http_entity` keeps a cookie table (`tihttpcki`); `set_cookie( )`
  appends, `get_cookies( )` returns it, `get_cookie_field( )` reads one;
  the request side is filled from the `Cookie` header by the shim
  (express-icf-shim already parses headers), the response side is
  written as `Set-Cookie` by it.
- `set_compression( )` records the wish on the entity; the shim's
  response writer gzips when it is set and the client accepts it, or
  simply ignores it - either is better than a missing method, which is a
  `CX_SY_DYN_CALL_ILLEGAL_METHOD` for a dynamic caller and a load error
  for a static one.

## How to file

An issue against open-abap/open-abap-core for the entity (the shim half
goes to open-abap/express-icf-shim and can reference it).

