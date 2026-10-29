---
target: open-abap
title: 'core: cl_abap_message_digest, cl_abap_hmac, cl_system_uuid and GENERATE_SEC_RANDOM do `await import("crypto")` - in a browser every roundtrip of abap2UI5 1.147+ fails with ''crypto.createHash is not available'' unless the host ships a hand-written SHA-256'
summary: 'the hash and UUID kernel code imports Node''s `crypto` module and uses its synchronous API; browsers have `globalThis.crypto` (WebCrypto, async digest, `randomUUID`, `getRandomValues`) and no `createHash`, so the playground bundles a JS SHA-256 and a UUID fallback and the web build a crypto polyfill - kernel code that uses WebCrypto when present (with a pure-JS fallback for the synchronous callers) would run everywhere'
priority: medium
state: open
first_seen: 2026-10-22
upstream: open-abap/open-abap-core
evidence:
  - 'abap2UI5/playground `src/runtime/node-crypto-shim.mjs:1-18` (2026-10-14, bump-sources): from abap2UI5 1.147.0 every roundtrip hashes through `crypto.createHash(…)`, every app answered ''Network error: crypto.createHash is not available''; the shim implements SHA-256 in JS (`:46-186`) and `randomUUID` over `getRandomValues` for non-secure contexts (`:28-40`); `docs/design/build-traps.md:60-67`; abap2UI5/web-abap2UI5-build bundles the feross `buffer` and a crypto polyfill'
  - 'read 2026-10-22 in open-abap-core main 239b817 - `src/abap/hash/cl_abap_message_digest.clas.abap:239-240`, `src/abap/hash/cl_abap_hmac.clas.abap:54-56`, `src/fugr/openabap.fugr.generate_sec_random.abap:5`: `WRITE ''@KERNEL const crypto = await import("crypto");''` followed by `crypto.createHash(…)`; `cl_system_uuid` falls back to `window.crypto.randomUUID` only when the import fails'
checked_upstream: 2026-10-22
---

# core: hashing and UUIDs without Node's `crypto`

## What happens

In a browser (the abap2UI5 playground, the web build, a service worker):

```
Network error: crypto.createHash is not available
```

on every roundtrip since abap2UI5 1.147.0 hashes its draft state.
`cl_abap_message_digest`, `cl_abap_hmac` and `GENERATE_SEC_RANDOM` do
`await import("crypto")` and call the Node API (`createHash`,
`createHmac`, `randomBytes`); `cl_system_uuid` tries the same first.
Browsers have WebCrypto: `crypto.subtle.digest` (async),
`crypto.getRandomValues`, `crypto.randomUUID` (secure contexts). The
playground now carries a hand-written SHA-256 and a UUID fallback; the
web build a polyfill. Both are copies of what the kernel code could do
itself.

## Proposed change

In the four kernel sites: prefer `globalThis.crypto` when it exists.
- digests: `await crypto.subtle.digest(alg, bytes)` - the ABAP methods
  are already `async` in the transpiled output, so an `await` is free;
  map `SHA1`/`SHA256`/`SHA512`/`MD5` names (MD5 is not in WebCrypto; keep
  the Node path or a small JS MD5 for it).
- HMAC: `crypto.subtle.importKey("raw", …, {name: "HMAC", hash})` + `sign`.
- random: `crypto.getRandomValues`; UUID: `crypto.randomUUID` when
  present, else v4 from `getRandomValues`.
- `Buffer`: the kernel lines use `Buffer.from(…, "hex")`; `Uint8Array`
  plus a hex helper removes the second polyfill the browser builds carry.

Node 22 has `globalThis.crypto` too, so one path serves both.

## How to file

An issue against open-abap/open-abap-core with the playground's shim as
the reference implementation to replace.

