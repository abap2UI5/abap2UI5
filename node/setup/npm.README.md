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
| `createApp()` | The express app `serve()` listens with: `compress()`, the raw body parser and the handler on every path. Mount it under a path of your own app, or add middleware in front. `createApp({ compression: false })` leaves out the gzip (a proxy in front compresses anyway) |
| `createHandler()` | The request handler alone, `(req, res) => Promise<void>` - for a server that is not express (see below) |
| `initialize()` | Boot the ABAP runtime without serving: the SQLite database, the schema, the framework, then `accelerate()`. Once per process; every call returns the first call's promise |
| `accelerate()` | Install the runtime's fast paths for large tables (see [Performance](#performance)). `initialize()` calls it; a host that boots through `output/init.mjs` itself calls it after the boot - also importable alone, as `@abap2ui5/node-runtime/accelerate`. Returns `true` when they are installed |
| `compress()` | The gzip middleware `createApp()` puts in front, `(req, res, next)` - for an express app of your own that mounts `createHandler()` (see [Compression](#compression)); also importable alone, as `@abap2ui5/node-runtime/compress` |
| `HANDLER_CLASS` | `"ZCL_SICF"`, the `if_http_extension` class every request goes to |

`express` is an optional peer dependency, version 4 (from 4.21) or 5:
only `createApp()` and `serve()` load it, and they take whichever the host
has installed - a project that is on express 4 already (a CAP project, for
one) keeps its single copy.

### In an express app of your own

```js
import express from "express";
import { createApp } from "@abap2ui5/node-runtime";

const app = express();
app.use("/sap/bc/z2ui5", await createApp());
app.listen(3000);
// http://localhost:3000/sap/bc/z2ui5/?app_start=Z2UI5_CL_UI5_APP_HI_WORLD
```

The framework's app answers every method and path below the mount, the
same under express 4 and 5; routes of your own app next to the mount are
untouched.

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
other classes under abap2UI5's `src/`. The test apps abap2UI5's own browser
tests drive (`ZCL_TST_*`) are not in the package: nothing but the framework
and its handler `ZCL_SICF` can be started by `?app_start=`. Your apps are ABAP classes too, and
they have to be transpiled with the framework as a library. The package
carries the framework's sources for exactly that in `downport/`, and in its
`package.json` the two versions `output/` was built with: the transpiler
(`abap2ui5.transpiler`) and the commit of open-abap-core
(`abap2ui5.openAbapCore`). Use the same transpiler, so your output runs on
the runtime the package pins:

```bash
npm install --save-dev --save-exact @abaplint/transpiler-cli@$(node -p "require('@abap2ui5/node-runtime/package.json').abap2ui5.transpiler")
```

`--save-exact` because transpiler output is tied to its runtime: without it
npm records a caret range, and a later install moves the transpiler away from
the runtime this package pins.

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
# once: open-abap-core at the commit output/ was built against
CORE=$(node -p "require('@abap2ui5/node-runtime/package.json').abap2ui5.openAbapCore")
git init -q deps/open-abap-core
git -C deps/open-abap-core fetch -q --depth 1 https://github.com/open-abap/open-abap-core "$CORE"
git -C deps/open-abap-core checkout -q FETCH_HEAD

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
is what stands in for the ABAP standard library: the transpiler reads it from
`deps/open-abap-core` when that folder exists, and otherwise clones the `url`
into a temporary folder on every run - at whatever its HEAD is that day,
because the `url` takes no commit. Hence the checkout above, at the commit
the package records: your classes are type-checked against the same
standard library the framework was. Both libraries are there for the type
check; at runtime the package provides them. (1.145.0, the one version
published without `abap2ui5.openAbapCore`, was built against open-abap-core
`b2d219df61f8c077df7a038bc43d168f9f280fbf` - the pin in abap2UI5's
`node/setup/fetch-deps.mjs` at that tag.)

Import your own classes and nothing else from `output/`. The transpile writes
every object it read there, the libraries included - a second copy of the
framework and of open-abap-core, several hundred files - and your classes
need none of it: they resolve everything through the running runtime, so each
of your class files is imported on its own. A deployment has to carry the
files you import, so keep them inside the tree it ships - a CAP project's
`cds build`, for one, copies `srv/` but not a top-level `output/`.

## Performance

### Large tables

A roundtrip is linear in the size of its model - on an SAP system. The
transpiled framework runs on `@abaplint/runtime`, and two of its functions
made a roundtrip with one large table quadratic: a `LOOP AT ... WHERE` over
the primary key of a sorted table scans every row (the JSON serializer runs
one per node), and `CP` builds a regular expression per call that walks the
whole string behind a trailing `*` (the XML parser asks one per token, of the
rest of the draft). `accelerate()` replaces both with fast paths that answer
exactly what the runtime's own functions answer - binary search into the
sorted key and an early stop; the trailing wildcard dropped and the compiled
pattern cached - and hands every other case to the runtime's own code.
`initialize()`, and with it `serve()`, `createApp()` and `createHandler()`,
installs them. A host that boots through `output/init.mjs` itself adds one
line after its boot:

```js
import { initializeABAP } from "@abap2ui5/node-runtime/output/init.mjs";
import { accelerate } from "@abap2ui5/node-runtime/accelerate";

await initializeABAP();
accelerate();
```

In a CAP project (@cap2ui5/cds-plugin), the event roundtrip of an app whose
one table is bound to a `sap.m.Table` took 6.2 s for 1000 rows and 22.6 s
for 2000 - quadratic. With the fast paths 2000 rows take 1.8 s, 4000 rows
2.6 s and 8000 rows 4.4 s.

The fast paths are validated for the one `@abaplint/runtime` version this
package pins (`RUNTIME_VERSION`, exported next to `accelerate`). On any other
version - an `overrides` entry in the host's `package.json`, say -
`accelerate()` leaves the runtime alone, returns `false` and warns once.

### Compression

On an SAP system the framework asks the ICF to gzip every response, and the
page it answers a GET with - about 360 KB, the whole UI5 frontend embedded -
travels as about 85 KB. The express shim of a Node host has no such switch,
so `createApp()` puts `compress()` in front of the handler: gzip for every
text, JSON or JavaScript body of 1 KB or more, when the request's
`Accept-Encoding` allows it (`q=0` refuses), never for a `HEAD`, a 204 or a
304, nor for a body something else encoded already. Gzip only, because of the
page's `ETag`: the compressed page goes out as `"<tag>-gzip"` - Apache
mod_deflate's form, which the framework reads back - so the next load's
`If-None-Match` is answered with a 304, and the compressed page is kept per
tag instead of being compressed again. A roundtrip's JSON is compressed on
the thread pool, so no request waits on another's compression.

In an express app of your own that mounts `createHandler()`:

```js
import express from "express";
import { compress, createHandler } from "@abap2ui5/node-runtime";

const handle = createHandler();
const app = express();
app.use("/sap/bc/z2ui5", compress(), express.raw({ type: "*/*", limit: "10mb" }),
  (req, res, next) => { handle(req, res).catch(next); });
```

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
| `srv/accelerate.mjs` | `accelerate()` alone (`@abap2ui5/node-runtime/accelerate`) - it imports nothing from `output/` |
| `srv/compress.mjs` | `compress()` alone (`@abap2ui5/node-runtime/compress`) - `node:zlib` and nothing else |
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
