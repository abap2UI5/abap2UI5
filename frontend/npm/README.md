# @abap2ui5/frontend

The frontend of [abap2UI5](https://github.com/abap2UI5/abap2UI5): the UI5
component `z2ui5` that renders whatever an abap2UI5 backend sends - views,
popups, messages, navigation. abap2UI5 builds UI5 apps purely in ABAP, and
this component is the one piece of JavaScript every such app runs in.

```bash
npm install @abap2ui5/frontend
```

The version of this package is the version of the framework. The files are
`app/webapp` of abap2UI5 at that release, unchanged, plus a
`Component-preload.js` built from them.

## Who needs this

Most people do not: an abap2UI5 installation serves its own frontend - the
backend's HTTP handler answers a GET with the page and the whole component
embedded, and the BSP branches of
[abap2UI5/frontend](https://github.com/abap2UI5/frontend) deliver it into an
SAP system. This package is for the cases where the frontend comes from
somewhere else:

- **A UI5 app that embeds abap2UI5 apps.** Add the package to the app's
  dependencies and the UI5 tooling serves the component under
  `resources/z2ui5/`. [`@abap2ui5/embed`](https://www.npmjs.com/package/@abap2ui5/embed)
  wraps that in a custom control; without it, a `ComponentContainer` does the
  same (below).
- **A static host or a CDN.** `webapp/` is the complete component.
- **A frontend of a pinned version** next to a backend of the same version, in
  a build that assembles the two itself.

A Node host that runs the backend too wants
[`@abap2ui5/node`](https://www.npmjs.com/package/@abap2ui5/node) instead: it
carries this same `webapp/` next to the transpiled backend, from the same
commit.

## Use it in a UI5 app

```bash
npm install @abap2ui5/frontend
```

Nothing else in the UI5 tooling: the package is a project of type `module`
(`ui5.yaml`), so `ui5 serve` serves it and `ui5 build --all` copies it into
`dist/resources/z2ui5/`. Then:

```js
sap.ui.require(["sap/ui/core/ComponentContainer"], (ComponentContainer) => {
  new ComponentContainer({
    name: "z2ui5",
    async: true,
    manifest: true,
    height: "100%",
    settings: {
      componentData: {
        endpoint: "/sap/bc/z2ui5",                        // optional, this is the default
        startupParameters: { app_start: ["ZCL_MY_APP"] }, // the ABAP class to run
      },
    },
  }).placeAt("content");
});
```

Inside the SAP Fiori launchpad the app's own `resources/` folder is not a
resource root, so the host app declares it in its `manifest.json`:

```json
"sap.ui5": { "resourceRoots": { "z2ui5": "./resources/z2ui5/" } }
```

**The backend has to share the page's origin.** abap2UI5 rejects a POST whose
`Origin` names another host than its own (its CSRF defense), so the browser
reaches the service through the page's origin - served from the same system,
through an approuter or destination, or behind the dev server's proxy.

## Versions

- Frontend and backend talk over a versioned wire protocol. When they do not
  fit, the app says so instead of rendering nothing: use the same version of
  this package as the abap2UI5 installed on the backend, or update the one that
  is behind.
- UI5 **1.71** and later, like abap2UI5 itself; UI5 2.x as well.

## What is inside

| Path | |
|---|---|
| `webapp/` | The component `z2ui5`: `Component.js`, `manifest.json`, `core/`, `controller/`, `view/`, `cc/` (the framework's custom controls), `model/`, `css/`, `devtools/` - and `index.html`, the standalone page |
| `webapp/Component-preload.js` | Every module of the component in one file, so a host loads it with one request instead of one per module; `Component-preload.js.map` points into the unminified sources next to it |
| `ui5.yaml` | The UI5 tooling project: `/resources/z2ui5/` is `webapp/` |

`package.json` records the abap2UI5 commit the files come from under
`abap2ui5.commit`.

## License

MIT
