# @abap2ui5/embed-control

Run [abap2UI5](https://github.com/abap2UI5/abap2UI5) apps inside any UI5 app.

abap2UI5 builds UI5 apps purely in ABAP: an ABAP class implementing
`z2ui5_if_app` decides the view and handles every event. This package puts
such an app into **your** UI5 app as an ordinary control, next to your own
controls:

```xml
<mvc:View xmlns:mvc="sap.ui.core.mvc" xmlns:z2ui5="z2ui5.embed">
  <z2ui5:Container app="Z2UI5_CL_UI5_APP_HI_WORLD" height="400px"/>
</mvc:View>
```

The package is the control and nothing else. The abap2UI5 frontend it wraps
comes from the abap2UI5 installation the app talks to - so it always has the
version of that backend, and your app never carries a copy of it.

## Install

```bash
npm install @abap2ui5/embed-control
```

Then two entries in your app. `ui5.yaml` - so `ui5 build` copies the control
into your app (`ui5 serve` serves it anyway):

```yaml
builder:
  settings:
    includeDependency:
      - "@abap2ui5/embed-control"
```

`manifest.json` - where the control's namespace lives:

```json
"sap.ui5": {
  "resourceRoots": { "z2ui5.embed": "./thirdparty/z2ui5/embed/" }
}
```

The build puts it into `dist/thirdparty/z2ui5/embed/` and your deployment
takes it along like every other file of the app. Not under `resources/`: an
app deployed to an ABAP system answers every `<app>/resources/` path from the
UI5 library of the system. The relative resource root holds in a standalone
page and in the SAP Fiori launchpad alike.

Nothing else is deployed anywhere: the control is a plain module (no
component, no library), so no app index entry of an ABAP system is involved,
and any number of apps can carry their own copy.

## Use

In an XML view, as above, or in code:

```js
sap.ui.require(["z2ui5/embed/Container"], (Container) => {
  new Container({
    app: "ZCL_MY_ABAP2UI5_APP",
    params: { customer: "4711" },
    height: "600px",
  }).placeAt("content");
});
```

| Property | Type | Default | |
|---|---|---|---|
| `app` | string | | The ABAP class to run. Nothing starts while it is empty - unless `ownsPage` is set: then the page's URL names the class (`?app_start=`, or a route in the hash), and without one the backend starts its start page (0.4.0) |
| `endpoint` | string | `/sap/bc/z2ui5` | Path of the abap2UI5 HTTP service on this server - absolute, or relative to the page's address (a `<base>` does not apply), without a query or a fragment. The frontend is loaded from it, the roundtrips go to it. See [Backend](#backend) |
| `params` | object | | `{ name: "value" }`, read by the app with `client->get( )-t_comp_params`; `{ name: ["a", "b"] }` hands several values over under one name. A value that is `null` or `undefined` is left out; an object is handed over as JSON text |
| `ownsPage` | boolean | `false` | Hands the page to the app - for a page that is this control and nothing else: the app then has what it has on a page of its own - the URL hash (hash routing, `set_push_state`, `hash_replace`, browser Back and Forward between routed apps, a route restored on reload), the document title and the favicon, the global busy indicator during a roundtrip, the browser's "leave page?" prompt for unsaved changes. Off, they are your app's: the embedded app leaves the title, the favicon and the hash alone, is busy on its own area and raises no prompt. Leave it off when your page has more than the control - a Fiori elements object page. One such control per page. A change starts the app anew, like one of `app`, `endpoint` or `params`. Needs abap2UI5 1.147.0, which reads it (the control passes `ownsHash` with it); an older one ignores it |
| `ownsHash` | boolean | `false` | The older, narrower name of `ownsPage`: hands the page's URL hash to the app - for a page that is this control and nothing else, which routes by nothing: the app then routes as on a page of its own (hash routing, `set_push_state`, `hash_replace`, browser Back and Forward between routed apps, a route restored on reload). Leave it off when your app routes by the hash - a Fiori elements object page does. One such control per page. A change starts the app anew, like one of `app`, `endpoint` or `params`. Needs abap2UI5 1.147.0, which hands the whole page over for it, as for `ownsPage`; an older one ignores it |
| `width` | CSSSize | `100%` | |
| `height` | CSSSize | `100%` | The app fills its container - give it a height, or a parent that has one. A change of `width` or `height` resizes the area in place; the running app is not re-rendered |

| Event | Parameters | |
|---|---|---|
| `componentCreated` | `component` | The app's component exists (the first roundtrip is under way) |
| `componentFailed` | `reason` | It could not be created - the endpoint is not a path on this server, the frontend could not be loaded, or the component failed |

| Method | |
|---|---|
| `restart()` | Ends the running session and starts the app anew with the current `app`, `endpoint` and `params` - the app from scratch, or one more try after `componentFailed` |

Every control is its **own abap2UI5 session** - two controls with the same
class do not share state. Changing `app`, `endpoint` or `params` ends the
running session and starts a new one; `restart()` does the same with the
values as they are; destroying the control ends it too. All three are
ordinary properties, so they can be bound to your model - `params` is
compared by value with what the running app was started with, so a binding
that hands over the same parameters in a new object does not restart the
app, and an `endpoint` that names the same place in another spelling (a
trailing slash, a relative path) does not either.

Both events arrive asynchronously, after the rendering that started the
app - a refused endpoint included. A start that failed is not repeated by
itself: change one of the three properties, or call `restart()`. An
invisible control (`visible="false"`) starts nothing until it is shown; an
app that runs keeps running, with its state, while its control is hidden.

## Examples

Complete examples that use the package are in
[abap2UI5/samples-embed-control](https://github.com/abap2UI5/samples-embed-control),
on its branch `standard`, all taking the package from npm:

- `freestyle/` - a UI5 freestyle app with three controls, also as the BSP
  `Z2UI5_HOST` to try it on a system with a plain abapGit pull
- `fiori-elements/` - a Fiori elements app with the control in a **custom
  section of its object page**: the abap2UI5 app gets the key of the object
  on the page as a parameter
- `fiori-elements-v2/` - a Fiori elements app for **OData V2** with the
  control in an **object page extension**, and the **RAP service** it reads;
  on the branch `rap`, all of it for one abapGit pull on a system with RAP
- `card/` - a **UI Integration Card** for SAP Build Work Zone that runs any
  abap2UI5 app: the class is a card parameter, the backend a card
  destination

Its README walks through the places the package is wired in.

## Backend

The app runs on an ABAP system with
[abap2UI5 installed](https://abap2ui5.github.io/docs/configuration/installation.html)
and its HTTP service (by default `/sap/bc/z2ui5`) active. The control needs
**abap2UI5 1.145.0 or later**, whose service answers `?z2ui5-bundle` - in
Node that is `@abap2ui5/node-runtime` 1.145.0, in CAP
`@cap2ui5/cds-plugin` 0.3.1, which runs on it:

```
GET  /sap/bc/z2ui5?z2ui5-bundle   the frontend as one script - loaded once per page
POST /sap/bc/z2ui5                the roundtrips, one session per control
GET  /sap/bc/z2ui5                abap2UI5's own page, unchanged
```

An older abap2UI5 answers with its page; the control then fires
`componentFailed` ("no abap2UI5 frontend at ...") instead of starting.

**What 1.145.0 does not do yet.** abap2UI5 1.146.0 fixes all of these; with
1.145.0 itself plan for them:

- **The URL hash is the frontend's.** 1.145.0 clears the host's hash with the
  first roundtrip and after every one: a Fiori elements object page goes back
  to its list, SAP Build Work Zone leaves the page a card sits on. And a
  host hash shaped like abap2UI5's own deep link, `#/app/<CLASS>`, wins over
  the `app` property - that class starts instead. A host that routes by the
  hash - a Fiori elements app, an app with a UI5 router, SAP Build Work
  Zone - needs 1.146.0 or later, whose frontend knows it is
  embedded and leaves the hash to your app (abap2UI5 677e71b, #2808).
- **No CSRF token handshake.** An SAP approuter route checks CSRF tokens by
  default (`cds add approuter` generates such a route), and 1.145.0 sends
  none - every roundtrip is refused with 403 "X-CSRF-Token: Required". Give
  the route to the service `"csrfProtection": false`; abap2UI5's own origin
  check stays in place. 1.146.0 fetches the token on that
  403 (abap2UI5 #2802).

Every release is tested against abap2UI5's main and against 1.145.0
(`@abap2ui5/node-runtime` 1.145.0) - there without what needs the hash. The
package records the floor in its `package.json` (`abap2ui5.minBackend`), and
that is the version the test installs.

**The page and the service have to share an origin.** abap2UI5 rejects a
POST whose `Origin` names another host than its own (its CSRF defense), and
the control loads the frontend only from a path on this server - an
`endpoint` that resolves to another origin is refused, because what comes
back is code that runs in your page. So the browser reaches the service through your
app's origin:

- **deployed** - the app is served from the same system (BSP, launchpad), or
  an approuter / destination routes `/sap/bc/z2ui5` to it
- **`ui5 serve`** - a proxy middleware forwards `/sap` to the system, like
  `ui5-middleware-simpleproxy` in the
  [examples](https://github.com/abap2UI5/samples-embed-control/tree/main/freestyle).
  It rewrites `Host` and tells the backend the dev server's host in
  `X-Forwarded-Host`, which abap2UI5 compares the browser's `Origin` with
  (trusted by default; `check_trust_forwarded_host` in the user exit)

**Content-Security-Policy:** the frontend is a `<script src>` of your own
origin, and every module in it is a function - nothing is evaluated from a
string. A host with `script-src 'self'` and no `'unsafe-eval'` needs nothing
extra (UI5 1.71 itself still needs `'unsafe-eval'`).

## UI5 libraries

The embedded app loads whatever UI5 library its ABAP view names. With the UI5
CLI serving the framework (`framework:` in `ui5.yaml`), list every library
your ABAP apps use there, not only the ones your own views use - the hello
world app, for instance, needs `sap.ui.layout` - and `sap.ui.codeeditor`,
which abap2UI5's developer tools (Ctrl+F12 in the embedded app) need. A
library missing there fails in the browser console with a script load
error; an app deployed to a system has every library of that system.

## Supported UI5 versions

The same floor as abap2UI5: OpenUI5 / SAPUI5 **1.71** and later. The
freestyle example is tested on 1.71 and 1.136, the Fiori elements examples
for OData V4 and V2 on SAPUI5 1.136, the card on OpenUI5 1.136.

Your app's tooling: UI5 CLI 3 or 4 - the package's `ui5.yaml` is
specVersion 3.0, and every release is built with both.

## Known limitations

- **One frontend per page**: the first control that starts decides which
  endpoint the frontend comes from; every control still sends its roundtrips
  to its own endpoint. A control that shared that load with another
  endpoint of its own, and saw it fail, tries its own endpoint once. A
  bundle the host loaded itself - a `<script src="<endpoint>?z2ui5-bundle">`
  of its page, to have it warm - is taken as it is, not loaded again.
- **The host page's mobile setup, with abap2UI5 1.146.0 and earlier.**
  `sap.m.App`, the root of the embedded frontend, runs UI5's
  `sap/ui/util/Mobile.init` when it is created - once per page, with the
  settings of whoever calls it first. On a host page without a `sap.m.App`
  of its own that puts `height: 100%` on `<html>`, adds a viewport meta tag
  that disables zooming and a format-detection meta tag, and on iOS turns
  native scrolling off (`position: fixed` on `<html>`) and hides the
  browser's UI. abap2UI5 1.147.0 makes that call first,
  with everything off, so the host keeps its page; what stays on a phone or
  tablet is the web-app-capable meta tag `sap.m.App` sets on every
  rendering. From 1.147.0 on the root of an embedded app is a
  `sap.m.NavContainer`, which sets none of it; with `ownsPage` the root is
  the `sap.m.App` again, as on a page of the app's own. A host with a
  `sap.m.App` of its own is not affected on any release.
- **Custom controls from the sibling BSPs `z2ui5_cci` / `z2ui5_ccc`**
  (abap2UI5-addons/custom-controls, the customer's own library) behind a
  proxy that puts the system under a prefix of its own - SAP Build Work
  Zone's destination proxy, an approuter route with a prefix - need
  abap2UI5 1.147.0. Until then the bundle names their paths
  as the system has them, `/sap/bc/ui5_ui5/sap/z2ui5_cci`, which the host's
  origin does not have; from then on its bundle names the node it was
  requested under, and the frontend puts the prefix of the control's
  `endpoint` in front of the roots. Nothing in the control changes with it.
- abap2UI5 was built to own the whole page. Its embedded mode leaves the
  URL to your app (from 1.146.0 on) - unless `ownsHash` hands the hash
  back (from 1.147.0 on) - and, from 1.147.0 on as well, the document
  title, the favicon, the busy indicator and the "leave page?" prompt as
  well, unless `ownsPage` hands the page back; before that an embedded app
  shows the global busy indicator during a roundtrip and may set the
  document title and favicon when the ABAP app asks for it. The rest is
  still to come
  ([backlog item](https://github.com/abap2UI5/abap2UI5/blob/main/backlog/items/embed-as-reuse-component.md)).
  Up to 1.146.0 an embedded app renders its root as `sap.m.App`, the
  full-screen root: the theme's background of its own, and a height of
  100% on every ancestor up to the control's area. From 1.147.0 on
  it is a `sap.m.NavContainer` that only fills the area, unless
  `ownsPage` hands the page back. Before 1.146.0 the app also takes the
  focus when it starts, from wherever it is in your app - the root focuses
  the first field of its first page, and the ABAP app may set the focus as
  well.
- **Page-wide behaviour of the embedded frontend.** Its error dialog's
  "Restart" - and "Refresh" on its fatal error screen - reloads the whole
  page, your app included. Its developer tools wrap the `window.console`
  methods while an app runs (the browser console keeps working; its source
  links point to the wrapper) and listen for Ctrl+F12 on the document.
- **Keep-alive.** The embedded app's component belongs to your app's
  component, the owner of the control, and the abap2UI5 frontend does not
  support keep-alive: an app that declares it (`sap.ui5/keepAlive`, UI5
  1.88+) reports no keep-alive support while it has an embedded app, as UI5
  does for every nested component without it.

## What is inside

| Path | |
|---|---|
| `src/Container.js` | The control, `z2ui5.embed.Container` |
| `src/Container.css` | Its stylesheet, loaded by the control |
| `ui5.yaml` | Serves `src/` under `/thirdparty/z2ui5/embed/` |
| `CHANGELOG.md` | Every release |

## License

MIT
