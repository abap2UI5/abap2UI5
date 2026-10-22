---
target: open-abap
title: 'express-icf-shim: set_session_stateful( ) is a no-op and one static server object serves every request - the first stateful app answered every later request of every client until the host built the session layer itself'
summary: 'the shim swaps request and response on a single static `cl_http_server` and ignores `set_session_stateful( )`, so there is neither a per-request server instance nor a session: abap2UI5''s Node host serialises requests through an `exclusive( )` queue and keeps the sticky handler per `sap-contextid` in `withSession( )` - per-request instances and a session hook behind `set_session_stateful` (a callback the host implements, or a roll-area emulation keyed by cookie) belong in the shim'
priority: medium
state: open
first_seen: 2026-10-22
upstream: open-abap/express-icf-shim
evidence:
  - 'abap2UI5 `node/srv/hostcore.mjs:79-97` (2026-10): one request at a time because the shim swaps request and response on a static server; `:99-133`: ''the shim''s set_session_stateful( ) is a no-op: the first app that went stateful answered every later request of every client'' - `withSession( )` keeps the handler per host-issued `sap-contextid`; `node/tests/sessions.spec.js`'
  - 'the item `core-http-entity-cookies-compression` covers the entity half (cookies); this one is the shim''s request lifecycle'
checked_upstream: 2026-10-22
---

# express-icf-shim: request instances and a session hook

## The problem

The shim that gives transpiled ABAP an ICF-shaped server keeps one
static `cl_http_server` and swaps `request`/`response` on it per
request; `if_http_server~set_session_stateful( )` does nothing. Two
consequences abap2UI5's Node host had to engineer around:

1. **No concurrency.** Two requests in flight share the object; the host
   serialises everything through an `exclusive( )` queue.
2. **No session.** An app that goes stateful on a system gets its own
   roll area, addressed by `sap-contextid`. On the shim the first app that
   called `set_session_stateful( )` became the handler of every later
   request of every client, until the host stripped the session headers
   and kept the handler map itself (`withSession( )`).

## Proposed change

- a `cl_http_server` instance per request (the handler class is
  instantiated per request already; the server object should be too);
- `set_session_stateful( active )` records the wish on the instance, and
  the shim exposes a hook:
  ```js
  icf.sessions = { create(id) {…}, get(id) {…}, dispose(id) {…} }
  ```
  default implementation: an in-memory map keyed by a cookie the shim
  sets (`sap-contextid`), with the handler instance and a timeout;
  `set_session_stateful( abap_false )` disposes it. A host (abap2UI5)
  plugs its own store in.

## How to file

An issue against open-abap/express-icf-shim; cite `hostcore.mjs`.

