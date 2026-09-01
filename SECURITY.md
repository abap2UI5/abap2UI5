# Security Policy

## Supported Versions

| Version | Supported |
|---|---|
| Latest release | Yes |
| Previous releases | No |

We recommend always using the latest version of abap2UI5. "Latest release"
is the newest entry on the [releases page](https://github.com/abap2UI5/abap2UI5/releases);
an installation reads its own version from the `version` constant in
`z2ui5_if_app`.

## Reporting a Vulnerability

We take security issues seriously. If you discover a security vulnerability, please report it responsibly.

**Do not open a public GitHub issue for security vulnerabilities.**

Instead, please use the GitHub Security Advisory ["Report a Vulnerability"](https://github.com/abap2UI5/abap2UI5/security/advisories/new) tab.

### What to Include

- A description of the vulnerability
- Steps to reproduce the issue
- The potential impact
- Any suggested fixes (optional)

### Response Timeline

- **Acknowledgment:** Within 3 business days
- **Initial assessment:** Within 7 business days
- **Resolution target:** Depends on severity, typically within 30 days

### Process

1. Report the vulnerability via GitHub Security Advisory
2. We will acknowledge receipt and begin investigation
3. We will work with you to understand and validate the issue
4. A fix will be developed and tested
5. A security advisory will be published with the fix release

## Scope

This policy applies to the abap2UI5 core framework (`src/` directory). For vulnerabilities in dependencies or related repositories, please report them to the respective maintainers.

Note that the UI5 frontend under `app/webapp/` is **in scope here**, even
though it looks like a separate deliverable: it is authored in this
repository and vendored into `src/01/03/` as the embedded frontend every
installation serves.

## Security Model

The following are deliberate design decisions of the framework, not
vulnerabilities. A report that reduces to one of them will be answered with
this section - which is exactly why it exists here, where external reporters
look first.

- **A draft id is not a secret, and does not have to be.** It travels in
  bookmark URLs and the clipboard app-state. Access to the serialized app
  state is bound to the creating user (`UNAME` on `Z2UI5_T_01`, enforced
  fail-closed on read, existence checks and the create/upsert path); a
  leaked or guessed id degrades to a fresh app start for anyone else.
- **App-start authorization is the app's job.** Any class implementing
  `z2ui5_if_app` can be started via URL parameter or hash route; the
  framework performs no `AUTHORITY-CHECK` of its own. An app that needs one
  performs it in its `main( )` method.
- **The backend response is trusted by the frontend.** `follow_up_action`
  deliberately lets the ABAP app hand the browser JavaScript to execute;
  every bound attribute is writable from the client by design. Whoever can
  change ABAP app code can run code in the user's browser - that is the
  product, not a flaw.
- **Error details are visible by default.** The 500 body renders the full
  exception chain (class names, source positions, kernel ids, and the
  public attributes of every exception in the chain) for diagnosability;
  hardened installations turn this off via the user exit
  (`check_hide_error_details`). Host name, client and user are never part
  of the body. Be aware that the attribute dump renders whatever a
  customer's or SAP's exception classes carry - an installation whose
  exceptions hold sensitive payloads belongs in the hardened camp.
- **The default CSP carries `unsafe-inline`/`unsafe-eval`** because UI5 1.71
  requires them; an exit can replace the whole policy, including switching
  to a real `Content-Security-Policy` response header via
  `t_security_header`. `data:`/`blob:` sources are confined to the non-script
  directives (an explicit `script-src` shadows the `default-src` fallback).
- **The default bootstrap loads UI5 from a public CDN**
  (`sdk.openui5.org`) so a fresh installation runs with zero configuration.
  That makes the CDN a trusted party of the DEFAULT setup: it serves the
  entire JS runtime into an authenticated SAP session, and no integrity
  pinning is possible against a cachebuster URL. Productive installations
  should repoint `cs_config-src` in their exit to an on-stack or otherwise
  controlled UI5 (`/sap/public/bc/ui5_ui5/resources/sap-ui-core.js` on
  systems that ship it) - the default CSP allows only the UI5 CDN hosts,
  nothing else.

## Credit

We appreciate responsible disclosure and will credit reporters in the security advisory (unless you prefer to remain anonymous).
