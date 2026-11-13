# Changelog

Every release of `@abap2ui5/embed-control`, newest first. The publish
workflow reads this file: the version being released needs a section of its
own, and nothing may be left under "Unreleased".

## Unreleased

## 0.4.0

- The package is built from the abap2UI5 repository now: the control's
  source is `app_v2/webapp/embed` there, next to its smallest host app
  (`node app_v2/embed-control/pack.mjs`). abap2UI5/embed-control published
  it up to 0.3.0.
- A control that owns the page (`ownsPage`) starts without `app` and hands
  no `app_start` over: the page's URL names the class then (`?app_start=`,
  or a route in the hash), which the backend reads from the roundtrip, and
  without one the backend starts its start page. Without `ownsPage` nothing
  starts while `app` is empty, as before.

## 0.3.0

- `ownsPage` (boolean, default `false`): hands the page to the app, as
  `componentData.ownsPage` - for a host whose page is the control and
  nothing else (abap2UI5's embed app). The app then has the URL hash, the
  document title and the favicon, the global busy indicator and the
  browser's "leave page?" prompt as on a page of its own; without it
  abap2UI5 1.147.0 leaves all of them to the host. The control passes
  `ownsHash` with it, which 1.147.0 reads the same way. A change starts
  the app anew, like one of `app`, `endpoint` or `params`.
- Docs: the embedded app's root is a `sap.m.NavContainer` from abap2UI5
  1.147.0 on (abap2UI5/abap2UI5#2913); the README's notes on the mobile
  setup and on the root say so. Nothing in the control changes.
- Docs: what 0.2.0 and these notes called "the release after 1.147.0" -
  `ownsPage`, the page left to the host, the `sap.m.NavContainer` root -
  is in 1.147.0: its tag went out on 2026-10-14 with all three in it.

## 0.2.0

- The component is created under the name the bundle's `z2ui5/embed`
  module gives (`componentName`) when it gives one - abap2UI5 1.147.0
  registers the frontend as `z2ui5.embed.frontend` as well. That lets a
  page whose own component is `z2ui5` embed it: the BSP `Z2UI5` of
  abap2UI5's embed app (the `standard_new` and `cloud_new` branches of
  abap2UI5/frontend), which existing launchpad target mappings name.
  An older bundle names none, and the frontend runs as `z2ui5` as before.
- `ownsHash` (boolean, default `false`): hands the page's URL hash to the
  app, as `componentData.ownsHash` - for a host whose page is the control
  and nothing else (abap2UI5's embed app). The app then routes as on a
  page of its own: hash routing, `set_push_state`, `hash_replace`, browser
  Back and Forward between routed apps, a route restored on reload. A change
  starts the app anew, like one of `app`, `endpoint` or `params`. Needs
  abap2UI5 1.147.0, which reads it; an older one ignores it.
- README: with the UI5 CLI serving the framework, `sap.ui.codeeditor` has
  to be among the libraries as well - abap2UI5's developer tools need it,
  and `ui5 serve` serves only what `ui5.yaml` names.
- `width` and `height` are applied to the control's area without a
  rendering. A change re-rendered the ComponentContainer and with it every
  control of the running app - on UI5 1.71 a value the user was typing and
  the focus were lost with it, and a host that binds the height to the
  window size re-rendered the app on every resize.
- A bundle the host loaded itself - a `<script>` of its page - is not loaded
  again: the control takes the `z2ui5/embed` module that is there. 0.1.1
  loaded it a second time, and UI5 warned that the module was defined twice.
- An object among the `params` - a structure, a nested array - is handed over
  as JSON text; 0.1.1 handed it over as the text `[object Object]`.
- An error thrown by a `componentCreated` or `componentFailed` handler is
  logged (`sap/base/Log`, with the control's id) instead of ending as an
  unhandled promise rejection that nothing attributes to the control.
- Node tests of the control (`npm test`, `test/container.test.mjs`): the
  endpoints it accepts and what it requests, what the component gets, when
  it starts, restarts and gives up - without a browser or a backend. The
  examples' Playwright tests in abap2UI5/samples-embed-control keep covering
  the shipped control against a live abap2UI5.
- README: the host page's mobile setup with abap2UI5 1.146.0 and earlier -
  `sap/ui/util/Mobile.init` through the embedded `sap.m.App`: `height: 100%`
  on `<html>`, a viewport meta tag, native scrolling off on iOS - listed
  under known limitations; abap2UI5 1.147.0 leaves the host's page
  alone. Nothing in the control changes with it.
- `restart()`: ends the running session and starts the app anew with the
  current `app`, `endpoint` and `params` - the app from scratch, or one more
  try after `componentFailed`. A failed start was repeated only by a change
  of one of the three properties.
- An `endpoint` that names the same place in another spelling - a trailing
  slash, a relative path, the default written out - no longer restarts the
  app: what a start is compared by is the endpoint as it is requested. Nor
  does an `app_start` in `params`, which `app` overrides anyway.
- An invisible control (`visible="false"`) starts nothing until it is
  shown. UI5 calls `onBeforeRendering` for the placeholder it renders, and
  0.1.1 started the app - and its backend session - for a control nobody
  saw. An app that runs keeps running while its control is hidden.
- `componentFailed` for a refused endpoint fired inside the rendering, every
  other failure after it. All of them arrive asynchronously now, so a
  handler that changes a model or the control never does so in the
  rendering phase.
- An `endpoint` with a query or a fragment is refused as before, and the
  reason says so (`carries a query or a fragment`) instead of calling a
  path on this server another host.
- `params` takes an array for a name, `{ ids: ["1", "2"] }`, as several
  values of that name - the launchpad's shape, which the backend reads;
  0.1.1 handed an array over as the text `"1,2"`.
- A control that shared the frontend load of another control's endpoint
  and saw it fail tries its own endpoint once, instead of failing for a
  backend it never talks to. The first control that starts still decides
  where the frontend comes from when that load succeeds.
- README: a custom control from the sibling BSPs `z2ui5_cci` / `z2ui5_ccc`
  behind a prefixing proxy (SAP Build Work Zone, an approuter route with a
  prefix) needs abap2UI5 1.147.0, whose bundle names the
  node it was requested under and whose frontend puts the prefix of the
  control's `endpoint` in front of the roots - listed under known
  limitations; nothing in the control changes with it.
- `scripts/consumer-check.mjs` runs npm through the node that started it
  (`npm_execpath`) instead of looking `npm` up on the PATH, which fails on
  Windows.
- `package.json` names the author (abap2UI5), as npm and the Best of UI5
  listing show it.
- `package.json` records the backend floor, `"abap2ui5": { "minBackend":
  "1.145.0" }` - the first abap2UI5 whose service answers `?z2ui5-bundle`,
  which the README names in prose. The CI's e2e leg against the floor
  installs the `@abap2ui5/node-runtime` of that version, so the two cannot
  drift. No `engines`: the package is a browser control with no Node code,
  and a UI5 CLI 3 consumer may install it on Node 16 or 18.
- The README lists the Fiori elements example for OData V2, with the RAP
  service it reads, and names the UI5 release it is tested on.
- The README links the proxy example in abap2UI5/samples-embed-control,
  where the examples are developed now.

## 0.1.1

- Security: an `endpoint` that the browser reads as another host - a tab
  or line break after the first slash (`"/\t/evil.example/..."`) - no longer
  passes the same-origin check. The endpoint is parsed the way the browser
  parses it, refused unless it lands on the page's origin, and only the
  resolved URL is requested. A relative `endpoint` now resolves against the
  page's address.
- An `endpoint` whose path begins with `//` once `.` and `..` segments are
  resolved - `"/.//evil.example/..."`, `"..//evil.example/..."` - is
  refused: no server has such a path, and on its own it names another host.
- A page with a `<base>` that names another host no longer sends the
  frontend request and the roundtrips there: the control requested the
  checked endpoint as a path, which the browser resolves against the
  `<base>`. It requests, and hands to the frontend, the absolute URL on the
  page's origin now.
- One failed load of the frontend - a backend that was down, a logon page
  instead of the bundle - no longer disables every control on the page for
  good. The failure is forgotten and the next start (a new control, or a
  change of `app`, `endpoint` or `params`) asks the backend again; the
  control no longer asks UI5's module loader for `z2ui5/embed`, which
  remembered the module as failed.
- A change of `app`, `endpoint` or `params`, or the control destroyed, while
  the component was still being created left that component running unseen,
  with its backend session. The control creates the component itself now and
  destroys it when the start it belongs to is no longer the current one.
- The component is created in the context of the control's owner - your
  app's component - as a `ComponentContainer` in a view creates it; 0.1.0
  created it without an owner. An app that declares keep-alive
  (`sap.ui5/keepAlive`, UI5 1.88+) therefore reports no keep-alive support
  while it has an embedded app: the abap2UI5 frontend does not support it,
  and 0.1.0 left the embedded app running while its host was inactive. A
  host deactivated while its app is still starting gets the app all the
  same, created without the owner.
- `params` are compared by value: a binding that hands over the same
  parameters in a new object (`model.refresh(true)`, a formatter) no longer
  restarts the app and loses its state. They are compared with what the
  running app was started with, so a params object changed in place and
  handed over again - as a copy or as the same object - does restart it
  (0.1.0 missed the same object). A parameter whose value is `null` or
  `undefined` is left out instead of reaching the app as the text "null" or
  "undefined".
- The control no longer leaves `window.z2ui5.embed` behind: UI5 exports
  every class it creates as a global, and abap2UI5 dropped its `z2ui5`
  global on purpose (#2777). The module returns the class, which is all that
  views and `sap.ui.require` use.
- README: the backend floor in Node and CAP too (`@abap2ui5/node-runtime`
  1.145.0, `@cap2ui5/cds-plugin` 0.3.1), what 1.145.0 does not do yet (the
  URL hash, a `#/app/<CLASS>` hash that wins over `app`, no CSRF token for an
  approuter route), the page-wide behaviour of the embedded frontend and
  that a starting app takes the focus from the host.
- The package carries this changelog.
- README: abap2UI5 1.146.0 is out - it names the release that leaves the URL
  hash to the host and answers an approuter's CSRF check, where it said "the
  first release after 1.145.0".

## 0.1.0

The first release.

- `z2ui5.embed.Container` runs an abap2UI5 app - an ABAP class implementing
  `z2ui5_if_app` - inside any UI5 app. Properties `app`, `endpoint`,
  `params`, `width` and `height`; events `componentCreated` and
  `componentFailed`. Every control is its own abap2UI5 session.
- The abap2UI5 frontend is not in the package: the control loads it once per
  page from the backend it talks to (`GET <endpoint>?z2ui5-bundle`, abap2UI5
  1.145.0 or later), and only from a path on the page's own server.
- Served and built under `thirdparty/z2ui5/embed/`, so it is found in an app
  deployed to an ABAP system too. UI5 1.71 and later; UI5 CLI 3 and 4.
- The control's area is the embedded app's root: `sap.m.App` and
  `sap.m.Shell` stop there instead of setting `height: 100%` on every
  ancestor up to `<html>` - the host's layout stays the host's, and a UI
  Integration Card keeps the height of its content.
