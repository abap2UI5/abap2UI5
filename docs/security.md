# Security model

What the framework guarantees, what the app has to do, what the operator has
to do, and what checks it all on every merge. [SECURITY.md](../SECURITY.md)
is the disclosure process and the list of deliberate design decisions; this
page is the map a security review starts from. Where a sentence below makes
a claim about the shipped code, it names the gate or the test that holds the
code to it.

## Trust boundaries

```
Browser (UI5 SPA)         ICF / HTTP service        App class          Database
───────────────── ──────▶ ─────────────────── ────▶ ────────── ──────▶ ─────────
 runs the frontend         SAP logon, session,       your ABAP,         Z2UI5_T_01
 untrusted input           authorization object      your checks        (serialized
 from the user             on the node                                   app state)
```

- **Authentication is SAP's.** abap2UI5 adds no user store, no token of its
  own and no session concept beyond the ICF session. A request that reaches
  the handler has already passed SAP logon; `sy-uname` is the user.
- **The browser is untrusted.** Everything that arrives in a POST — the
  event name, the model deltas, the draft id, the browser state — is treated
  as input. What the framework does with each is listed below.
- **The ABAP app is trusted.** An app's view, its bound values and its
  follow-up actions are executed in the user's browser as sent. Whoever can
  change app code can run code in the user's browser; that is what a UI
  framework is, not a flaw ([SECURITY.md](../SECURITY.md#security-model)).
- **The database row is the user's.** Serialized app state is bound to the
  user that created it.

## What the framework guarantees

| Guarantee | How | Held to the code by |
|---|---|---|
| A draft belongs to its creator | `UNAME` on `Z2UI5_T_01`, checked fail-closed on every read; a leaked or guessed draft id degrades to a fresh app start for anyone else | [draft-owner-gate](../.github/scripts/draft-owner-gate.mjs) (the blank-owner tolerance for rows written before the column existed carries a removal deadline the gate enforces) |
| A URL cannot load an arbitrary class | The app name from the URL or hash is refused before instantiation unless the class implements `z2ui5_if_app` — a type check, deliberately not an authorization check ([why](agents/decisions.md)) | Unit tests of `z2ui5_cl_ui5_action` |
| No string the page receives becomes code | The default Content Security Policy carries no `unsafe-eval` and, for scripts, no `unsafe-inline`; the one inline script (the embedded preload) is allowed by its SHA-256 hash. `data:` and `blob:` never reach `script-src`, and the only external hosts are the UI5 CDN hosts | [csp-default-gate](../.github/scripts/csp-default-gate.mjs) |
| Raw JavaScript from the backend is gone | A follow-up action is a JSON action with a name; a value that is not a known action name reaches the frontend as unknown and is not run. The `Function( )` path was removed in 2026 ([removal plan](removal-plan.md)) | The action registry in `app/webapp/core/FrontendAction.js` — an unknown action is logged, never evaluated |
| A backend action can call only what is whitelisted | `CONTROL_GLOBAL` and `CONTROL_BY_ID` call a method from a whitelist on a global object or a control; `BINDING_CALL` applies filters and sorters from a whitelist. A name outside the list is logged and dropped | [actionRunner.spec.js](../node/tests/actionRunner.spec.js) ([test inventory](agents/test-inventory.md)) |
| Message details cannot inject markup | HTML in message details passes a sanitizer that keeps a fixed set of formatting elements and drops everything else with its content | [lib-sanitizer.spec.js](../node/tests/e2e/lib-sanitizer.spec.js) (XSS regression suite) |
| A link in a message cannot leave the site unnoticed | The MessagePopover link policy `RELATIVE_ONLY` asks the URL parser whether a link is absolute, not a pattern on its spelling — `/\evil.com`, `\\evil.com` and a control character in `javascript:` were the cases ([changelog](../changelog.txt)) | [browserActions.spec.js](../node/tests/browserActions.spec.js) |
| A new window gets no handle on the app | `URLHELPER REDIRECT` with a new window opens with `noopener,noreferrer` on every UI5 release, including 1.71 to 1.83 where UI5's own helper does not | [browserActions.spec.js](../node/tests/browserActions.spec.js) |
| A download cannot smuggle an active document | `download_b64_file` refuses a `data:` URL with an active type (`text/html`, SVG, XML), also when disguised with whitespace or a tab in the scheme | [browserActions.spec.js](../node/tests/browserActions.spec.js) |
| The 500 body reflects no request data | The error page carries the exception chain for diagnosability, never the URL, host name, client or user; the user exit turns the details off for hardened installations | ABAP unit tests of the handler, and the protocol conformance check `error.no-reflection` |
| Response bodies are well-formed JSON | A control character in a bound value leaves as a `\u00XX` escape instead of breaking `JSON.parse` in the browser | ABAP unit tests of the handler |
| Standard CSRF handshake | The frontend answers a `403 X-CSRF-Token: Required` by fetching a token and retrying, so an installation behind an SAP approuter or a token layer with `csrfProtection` on works without configuration | `core/Server.js` |
| No supply-chain surprise in the toolchain | The three git dependencies are pinned by SHA; the two npm lockfiles are audited weekly against an accepted-advisory list with a reason per entry; dependency review runs on every pull request | [fetch-deps.mjs](../node/setup/fetch-deps.mjs), [npm-audit](../.github/workflows/npm-audit.yaml), [dependency-review](../.github/workflows/dependency-review.yaml) |
| Static analysis of every line of JavaScript that reaches a system | CodeQL over the shipped frontend, the CI gates and the generators, on every pull request and monthly | [codeql](../.github/workflows/codeql.yaml) |

## What the app has to do

The framework dispatches; the app decides. Three things are the app's, by
design, and no framework setting replaces them:

1. **Authorization.** Any user who can reach the ICF node can start any
   class implementing `z2ui5_if_app`. An app that needs an authority check
   performs it in its `main( )` — the same place a transaction or a report
   does — and renders an error or leaves when it fails. The framework has no
   central hook on purpose: the meaningful check is always app-specific, and
   a central one would be a false sense of security
   ([decision](agents/decisions.md)).
2. **Input validation.** Every attribute bound with `_bind( )` is writable
   from the client model; that is what two-way binding is. A value that
   drives a database write, a dynamic `WHERE` clause or a file name is
   validated in the app before it is used, exactly as a screen field would
   be. Host variables for SQL, no dynamic tokens built from bound strings.
3. **What it hands the browser.** HTML in a message, a URL in a link, a
   script in a custom control: the app decides what reaches the DOM. The
   sanitizer and the link policy are a net, not a substitute for not
   putting untrusted markup into a message in the first place.

## What the operator has to do

Defaults are chosen so that a fresh installation runs with zero
configuration. A productive one changes four of them, all through the user
exit (`z2ui5_if_ui5_exit`):

| Default | Productive setting | Why |
|---|---|---|
| UI5 is loaded from the public CDN (`sdk.openui5.org`) | Point `cs_config-src` at an on-stack or otherwise controlled UI5 | The CDN serves the entire JavaScript runtime into an authenticated session, and a cachebuster URL cannot be integrity-pinned |
| Error details are shown | `check_hide_error_details` on | The 500 body renders the public attributes of every exception in the chain, including SAP's and the customer's own classes |
| The CSP is a `<meta>` policy | A real `Content-Security-Policy` response header via `t_security_header` | A header is enforced before the first byte of the body is parsed |
| The ICF node is reachable by everyone with logon | Authorization object on the node, as for any service | Reachability of the node is the outer gate; the app's `main( )` is the inner one |

Draft rows are session-scoped and deleted by the framework's own cleanup on
app cold-start — there is no long-lived state and no schema to migrate
([decision](agents/decisions.md)).

## Reporting

A vulnerability goes to the
[GitHub security advisory form](https://github.com/abap2UI5/abap2UI5/security/advisories/new),
never to a public issue. Acknowledgement within three business days, initial
assessment within seven, a fix release with a published advisory —
[SECURITY.md](../SECURITY.md#response-timeline) has the process, and the
section below it lists what is a design decision rather than a finding, so a
report can check itself against it first.
