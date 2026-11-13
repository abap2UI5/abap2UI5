# app_source/

The minimal UI5 app that runs abap2UI5, and the source of the control it is
built on.

| Path | |
|---|---|
| `webapp/index.html` | a standard UI5 page: the bootstrap and one component |
| `webapp/Component.js`, `manifest.json` | the component `abap2ui5.page` - it only says where the backend is (`sap.app/dataSources/http/uri`) |
| `webapp/view/Main.view.xml` | the one view: a `sap.m.Shell` with one `z2ui5.embed.Container` in it |
| `webapp/embed/` | the control `z2ui5.embed.Container` - **the source**, a shell that loads the bundle and renders what the bundle creates (`bundle/webapp/core/Embed.js`); it came from abap2UI5/embed-control (npm `@abap2ui5/embed-control` 0.3.0) |
| `package.json`, `ui5.yaml`, `ui5-local.yaml` | `npm start` against an SAP system, `npm run start-local` against abap2UI5 in Node on `localhost:3000` |

The app carries nothing of the abap2UI5 frontend: the control loads it from
the backend (`GET <endpoint>?z2ui5-bundle`), so it always has the version of
the backend it talks to. Which class starts is the backend's decision - it
reads `?app_start=` or a route from the page's URL, and starts its start
page without one.

## The page of the HTTP service is this app

The page the abap2UI5 HTTP service answers a GET with
(`z2ui5_cl_ui5_http_handler=>_http_get`) is a variant of this app, not a
second one. An ICF node serves no files, so `tools/app2abap/trans2abap.js`
embeds `Component.js`, `manifest.json`, the view and the control into
`src/01/03` and the page carries them in its one inline script
(`npm run app2abap` after a change here). What differs on that page:

- the files are a preload in the page instead of files on a server
- the component is told that the page is the backend (`checkLocal`), so the
  endpoint is the page's own path

`index.html` is not part of that page - the handler writes its own, with
the exit's theme, bootstrap and Content-Security-Policy.
