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
| `ownsPage` | boolean | `false` | Hands the page to the app - for a page that is this control and nothing else: the app then has what it has on a page of its own - the URL hash (hash routing, `set_push_state`, `hash_replace`, browser Back and Forward between routed apps, a route restored on reload), the document title and the favicon, the global busy indicator during a roundtrip, the browser's "leave page?" prompt for unsaved changes - and `app` may stay empty: the page's URL names the class. Off, they are your app's: the embedded app leaves the title, the favicon and the hash alone, is busy on its own area and raises no prompt. Leave it off when your page has more than the control - a Fiori elements object page. One such control per page. A change starts the app anew, like one of `app`, `endpoint` or `params` |
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
and its HTTP service (by default `/sap/bc/z2ui5`) active:

```
GET  /sap/bc/z2ui5?z2ui5-bundle   the frontend as one script - loaded once per page
POST /sap/bc/z2ui5                the roundtrips, one session per control
GET  /sap/bc/z2ui5                abap2UI5's own page - this control, in a minimal app
```

**From 0.4.0 on the control is a shell**: it loads the bundle and renders
what the bundle's `z2ui5/embed` module creates (`create( )`). How an app is
created - its component, its component data, its styles - comes from the
backend, so it always fits the backend it came from. That needs **the
abap2UI5 release after 1.148.0**, whose bundle has `create( )`; against an
older abap2UI5 the control fires `componentFailed` ("no abap2UI5 frontend
at ...") instead of starting, and there is no fallback. For abap2UI5 1.145.0
to 1.148.0 stay on `@abap2ui5/embed-control` 0.3.0, which keeps working
against newer backends too. The package records the floor in its
`package.json` (`abap2ui5.minBackend`).

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
  URL to your app - unless `ownsPage` hands the page
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
| `ui5.yaml` | Serves `src/` under `/thirdparty/z2ui5/embed/` |
| `CHANGELOG.md` | Every release |

## License

MIT
