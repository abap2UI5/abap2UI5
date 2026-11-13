# app_npm/

The minimal UI5 app that runs abap2UI5 - the same app as [`app_source`](../app_source),
with the control taken from npm instead of carried as source.

| Path | |
|---|---|
| `webapp/index.html` | a standard UI5 page: the bootstrap and one component |
| `webapp/Component.js`, `manifest.json` | the component `z2ui5`, the name launchpad tiles and links have always named, with the launchpad entries in its manifest - it only says where the backend is (`sap.app/dataSources/http/uri`) |
| `webapp/view/Main.view.xml` | the one view: one `z2ui5.embed.Container`, nothing around it - whether an app sits in a `sap.m.Shell` is that app's view's business, as it always was |
| `package.json` | the control: `@abap2ui5/embed-control` |
| `ui5.yaml`, `ui5-local.yaml` | `includeDependency`, so that `ui5 build` takes the control into `dist/thirdparty/z2ui5/embed/`; `npm start` against an SAP system, `npm run start-local` against abap2UI5 in Node on `localhost:3000` |

What differs from `app_source`: no `webapp/embed/`, the resourceRoot of
`z2ui5.embed` is `./thirdparty/z2ui5/embed/` (where the UI5 CLI serves and
builds a dependency), and the component has no branch for the page of the
HTTP service - that page is built from `app_source`.

## The control's version

The view sets no `app`: the control starts without one when it owns the
page, and the backend reads the class from the page's URL. That is
`@abap2ui5/embed-control` **0.4.0**, the first version built from this
repository (`npm run pack:embed-control` in the root, from
`app_source/webapp/embed`). Until it is published, install the packed tarball:

```bash
npm run pack:embed-control
```

```bash
npm --prefix app_npm install ./npm-package/abap2ui5-embed-control-0.4.0.tgz --no-save
```
