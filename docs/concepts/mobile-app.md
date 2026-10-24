# Packaged mobile app

## What exists

[abap2UI5/mobile-shell](https://github.com/abap2UI5/mobile-shell) is a
proof of concept: a generic native app for iOS and Android that knows one
URL, shows the regular frontend in a webview and offers a small bridge
(`window.abap2ui5Native`) to the barcode scanner, push notifications and a
biometric confirmation. The framework ships `z2ui5.cc.NativeBridgeScan` for
its scanner. It has no releases; onboarding through the SAP BTP SDK and push
need accounts with SAP, Google and Apple. Its `PLAN.md` has the state of
every phase.

## What "packaged" means here

An organization rolls the app out the way it rolls out every other app on
managed devices: one build with its own name and icon, distributed through
its device management, configured remotely with the system's URL - and a
user who opens it lands in the launchpad or one app, logged on, without
typing an address.

## The first cut

1. **A release.** One tagged build of the shell per platform, with the
   bridge contract versioned (`v1`) and the release notes saying which
   framework release carries which bridge controls.
2. **A white-label build.** The name, the icon and the default URL as build
   inputs, so an organization builds its own app from a release without
   forking - a documented workflow in the shell's repository.
3. **Managed configuration first.** The URL, the app lock and screenshot
   protection from the device management (the shell already reads them);
   QR onboarding for devices without it.
4. **The offline queue inside the shell.** The shell controls its webview,
   so it can keep UI5 and the frontend in its own cache - the "load the page
   without a network" step of the [offline queue](offline.md) has its
   easiest home here.

## What it must not become

- **A second frontend.** Every screen still comes from the ABAP class; a
  change to an app never needs a new release in an app store.
- **Native code an app depends on.** The bridge offers device features; a
  view without the shell renders and works with what the browser can do
  (the scan control's placeholder is the pattern).

## Open questions

- Which of the SAP mobile stack is required (SAP Mobile Services for
  onboarding and push) and which is optional (an organization with its own
  MDM and identity provider)?
- Who builds and signs the release - the project, or each organization from
  the white-label workflow?
