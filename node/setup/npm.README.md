# @abap2ui5/node-runtime

[abap2UI5](https://github.com/abap2UI5/abap2UI5) in a Node process - no SAP
system involved.

abap2UI5 builds UI5 apps purely in ABAP: a class implementing `z2ui5_if_app`
decides the view and handles every event. This package is that framework
transpiled to JavaScript by [@abaplint/transpiler](https://github.com/abaplint/transpiler)
over [open-abap](https://github.com/open-abap/open-abap), together with an HTTP
handler, an express server and the ABAP sources to transpile your own apps
against - all from one release commit of abap2UI5. The version of this package
is the version of the framework.

```bash
npm install @abap2ui5/node-runtime express
```

```js
import { serve } from "@abap2ui5/node-runtime";

await serve({ port: 3000 });
// http://localhost:3000/?app_start=Z2UI5_CL_UI5_APP_HI_WORLD
```

The browser needs nothing else: the page the framework answers a GET with
carries the whole UI5 frontend, from the same commit as the backend. Only
UI5 itself comes from the CDN.

## What you get

| Export | |
|---|---|
| `serve({ port, host })` | Boot the framework and listen. Resolves with the `http.Server` once it can answer. `host` unset binds every interface, `"127.0.0.1"` loopback only |
| `createApp()` | The express app `serve()` listens with: the raw body parser and the handler on every path. Mount it under a path of your own app, or add middleware in front |
| `createHandler()` | The request handler alone, `(req, res) => Promise<void>` - for a server that is not express (see below) |
| `initialize()` | Boot the ABAP runtime without serving: the SQLite database, the schema, the framework. Once per process; every call returns the first call's promise |
| `HANDLER_CLASS` | `"ZCL_SICF"`, the `if_http_extension` class every request goes to |

`express` is an optional peer dependency: only `createApp()` and `serve()`
load it.

### In an express app of your own

```js
import express from "express";
import { createApp } from "@abap2ui5/node-runtime";

const app = express();
app.use("/sap/bc/z2ui5", await createApp());
app.listen(3000);
```

### On another server

`createHandler()` returns a handler that reads an **express-shaped** request
and response - what open-abap's `express-icf-shim` translates into an ABAP
`if_http_server`: `req.method`, `req.url`, `req.path`, `req.headers`,
`req.body` as a `Buffer` (an empty one when the request has none), and
`res.append(name, value)`, `res.status(code).send(buffer)`. Any server that
provides those five members works; express with `express.raw({ type: "*/*" })`
in front provides them out of the box.

## Your own apps

The framework alone runs its own apps - `Z2UI5_CL_UI5_APP_HI_WORLD` and the
other classes under abap2UI5's `src/`. Your apps are ABAP classes too, and
they have to be transpiled with the framework as a library. The package
carries the framework's sources for exactly that in `downport/`, and the
transpiler version that wrote `output/` in its `package.json`
(`abap2ui5.transpiler`) - use that one, so your output runs on the runtime
the package pins:

```bash
npm install --save-dev @abaplint/transpiler-cli@$(node -p "require('@abap2ui5/node-runtime/package.json').abap2ui5.transpiler")
```

`abap_transpile.json`:

```json
{
  "input_folder": "abap",
  "output_folder": "output",
  "libs": [
    { "folder": "/node_modules/@abap2ui5/node-runtime/downport", "files": "/**/*.*" },
    { "url": "https://github.com/open-abap/open-abap-core", "folder": "/deps/open-abap-core" }
  ],
  "write_unit_tests": false,
  "options": { "ignoreSyntaxCheck": false, "addFilenames": true, "unknownTypes": "runtimeError" }
}
```

```bash
npx abap_transpile abap_transpile.json      # abap/*.abap -> output/*.mjs
```

Then load the result **after** the framework has booted - the transpiled
class registers itself in the running runtime:

```js
import { initialize, serve } from "@abap2ui5/node-runtime";

await initialize();
await import("./output/zcl_my_app.clas.mjs");
await serve({ port: 3000 });
// http://localhost:3000/?app_start=ZCL_MY_APP
```

The transpile type-checks your class against the framework (`ignoreSyntaxCheck`
is off), so a method that does not exist on `z2ui5_if_client` fails there
rather than at runtime. `files` is needed because the transpiler reads a
library below `/src/**` by default and `downport/` is flat. `open-abap-core`
is what stands in for the ABAP standard library; the transpiler clones it
into `deps/` on the first run.

## Persistence

The framework keeps the state of every app between roundtrips in a draft
table. In this package that table lives in an **in-memory SQLite database**
(`setup/setup.mjs`): a restart forgets every session, and two processes share
nothing. That is right for a dev server, a demo or a test, and a limit for
anything else. abap2UI5 offers a seam for a store of your own -
`z2ui5_if_ui5_draft_store`, set with `z2ui5_cl_ui5_srv_draft=>set_instance( )`
at startup - which you implement in ABAP and transpile like an app.
[cap2UI5](https://github.com/cap2UI5/cap2UI5) does exactly that for CAP: its
drafts are a CDS entity.

## What is inside

| Path | |
|---|---|
| `srv/host.mjs` | The entry point - everything above |
| `output/` | The transpiled framework: `init.mjs` boots the runtime, one `.mjs` per ABAP object, `index.mjs` the generated unit-test runner (`node node_modules/@abap2ui5/node-runtime/output/index.mjs` runs the framework's own suite). The UI5 frontend is in here too, as the constants the GET page is built from |
| `setup/setup.mjs` | The database hook `init.mjs` imports - SQLite, schema, initial data |
| `downport/` | The framework's ABAP, downported to 7.02 - what the transpile read, and what your own apps are transpiled against |

The shape of `output/` - the class constructors, the static `ATTRIBUTES` and
`METHODS` maps, `~` becoming `$` - is the transpiler's, not abap2UI5's. What
this package promises is the entry point above and that `init.mjs` boots;
code that reaches into `output/` couples to `@abaplint/transpiler` and should
say so in a test of its own.

## Versions

- The package version is the framework version (`z2ui5_if_app=>version`).
- `@abaplint/runtime` and `@abaplint/database-sqlite` are pinned to the exact
  versions the transpile ran with. Transpiler output is tied to its runtime.
- Node 22 or later.

## Related

- [`backend-<version>.tar.gz`](https://github.com/abap2UI5/abap2UI5/releases) on every
  release - the same transpile with the pinned library checkouts, for a tool
  that downloads and builds against it (what [abap2UI5/mcp-server](https://github.com/abap2UI5/mcp-server) does)
- [Documentation](https://abap2ui5.github.io/docs/)

## License

MIT
