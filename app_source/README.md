# app_source/

The minimal UI5 app that runs abap2UI5: one view with one
`z2ui5.embed.Container` - the control of
[abap2UI5-addons/embed-ui5-control](https://github.com/abap2UI5-addons/embed-ui5-control), npm
`@abap2ui5/embed-control` - and nothing else.

| Path | |
|---|---|
| `webapp/index.html` | a standard UI5 page: the bootstrap and one component |
| `webapp/Component.js`, `manifest.json` | the component `z2ui5`, the name launchpad tiles and links have always named, with the launchpad entries in its manifest - it only says where the backend is (`sap.app/dataSources/http/uri`); the control is registered under `./thirdparty/z2ui5/embed/`, where the UI5 CLI serves and builds a dependency |
| `webapp/view/Main.view.xml` | the one view: one `z2ui5.embed.Container`, nothing around it - whether an app sits in a `sap.m.Shell` is that app's view's business, as it always was |
| `package.json`, `ui5.yaml`, `ui5-local.yaml` | the control as an npm dependency and `includeDependency`, so that `ui5 build` takes it into `dist/thirdparty/z2ui5/embed/`; `npm start` against an SAP system, `npm run start-local` against abap2UI5 in Node on `localhost:3000` |

The app carries nothing of the abap2UI5 frontend: the control loads it from
the backend (`GET <endpoint>?z2ui5-bundle`), so it always has the version of
the backend it talks to. Which class starts is the backend's decision - it
reads `?app_start=` or a route from the page's URL, and starts its start
page without one.

**The control is not developed here.** Its source, its tests and its npm
package are abap2UI5-addons/embed-ui5-control. This app needs `@abap2ui5/embed-control`
0.4.0 or later, the first version whose control is a shell the bundle
creates the app for; until 0.4.0 is on npm, `npm install` here fails, and
the folder has no lockfile for that reason.

## The page of the HTTP service, the BSP and the cloud app are this app

An ICF node serves no files, so `tools/app2abap/trans2abap.js` embeds
`Component.js`, `manifest.json` and the view into `src/01/03`, together with
the control, and the page the HTTP service answers a GET with
(`z2ui5_cl_ui5_http_handler=>_http_get`) carries them in its one inline
script. What differs on that page: the files are a preload in the page, and
the component is told that the page is the backend (`checkLocal`), so the
endpoint is the page's own path. `index.html` is not part of it - the
handler writes its own, with the exit's theme, bootstrap and
Content-Security-Policy.

The same run writes the whole folder, `index.html` included and the control
in `thirdparty/z2ui5/embed/`, as the BSP `Z2UI5` of `src/03/02` - the files
a launchpad on Standard ABAP loads. Never edit a page there; change the file
here and run `npm run app2abap`.

The control both take is the one `node/setup/fetch-deps.mjs` pins (a commit
of abap2UI5-addons/embed-ui5-control, checked out into `tools/deps/`), not the one npm
would install: what the backend serves does not depend on a registry.
Moving the pin is the way a new control reaches the backend.

The branch `cloud` carries this project as `app/`, to be deployed with the
SAP Fiori tools - there the control comes from npm like in any app - with one
change the build makes: the backend URL of the manifest is the HTTP
service's (`/sap/bc/http/sap/z2ui5`) instead of the ICF node's
(`tools/build-cloud.mjs`). The lint configuration and this README stay
behind.
