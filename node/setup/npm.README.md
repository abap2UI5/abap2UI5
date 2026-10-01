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
(`abap2ui5.openAbapCore`).

`abap2ui5-transpile`, a bin of this package, does the rest. With your classes
in `abap/`:

```bash
npm install --save-dev --save-exact @abaplint/transpiler-cli@$(node -p "require('@abap2ui5/node-runtime/package.json').abap2ui5.transpiler")
npx abap2ui5-transpile abap apps        # abap/*.abap -> apps/: yours alone, on the package's classes
```

It checks out open-abap-core at the recorded commit - once, into
`node_modules/.cache/abap2ui5-node-runtime/` - writes the transpile config
below, runs the transpiler the package names (the installed one; through
`npx` at that version when the project has none; another version installed
is refused, with the install command that fixes it) and runs
`abap2ui5-own-apps` over the output. `--config abap_transpile.json` runs a
config of your own instead, `--core <dir>` uses an open-abap-core checkout of
your own (also `ABAP2UI5_OPEN_ABAP_CORE`), `--keep` leaves the transpiler's
output folder in place.

Then load `apps/` **after** the framework has booted - each class registers
itself in the running runtime:

```js
import { initialize, serve } from "@abap2ui5/node-runtime";

await initialize();
await import("./apps/index.mjs");
await serve({ port: 3000 });
// http://localhost:3000/?app_start=ZCL_MY_APP
```

### By hand

What the command does, step by step - for a build that cannot run it, or to
see what it decides. Use the same transpiler, so your output runs on
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
  "options": { "ignoreSyntaxCheck": false, "addFilenames": true, "addCommonJS": true, "unknownTypes": "runtimeError" }
}
```

```bash
# once: open-abap-core at the commit output/ was built against
CORE=$(node -p "require('@abap2ui5/node-runtime/package.json').abap2ui5.openAbapCore")
git init -q deps/open-abap-core
git -C deps/open-abap-core fetch -q --depth 1 https://github.com/open-abap/open-abap-core "$CORE"
git -C deps/open-abap-core checkout -q FETCH_HEAD

npx abap_transpile abap_transpile.json      # abap/*.abap -> output/: yours, and every library object
npx abap2ui5-own-apps output apps           # output/ -> apps/: yours alone, on the package's classes
```

Then `apps/` is loaded as above.

`abap2ui5-own-apps` (a bin of this package, `setup/own-apps.mjs`) is not
optional. The transpile writes every object it read into `output/` - a second
copy of the framework and of open-abap-core next to your classes, and the
transpiler has no option to leave them out - and with `addCommonJS` a class
imports what it extends by a relative path: your exception class,
`INHERITING FROM cx_static_check`, loads `output/cx_static_check.clas.mjs`
and with it a second `CX_ROOT`, which replaces the package's in the running
runtime. From then on the framework's `CATCH cx_root` compares against a
class its own exceptions do not extend, and every request fails. Without
`addCommonJS` there are no imports at all, and a class that extends anything
does not load. So `abap2ui5-own-apps` keeps the files that are not the
package's, points their imports of everything else at
`@abap2ui5/node-runtime/output/` - the modules the package already booted -
and writes `apps/index.mjs`, which imports your classes in the order the
transpile does. An import it cannot rewrite stops it, with the file and the
line.

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

Ship `apps/`, not `output/`: a deployment has to carry the files you import,
so keep them inside the tree it ships - a CAP project's `cds build`, for one,
copies `srv/` but not a top-level folder (`npx abap2ui5-transpile abap
srv/apps`, and `await import("./apps/index.mjs")` from a module in `srv/`).
Tables, data elements and the like of your own are kept too; their database
tables are not created in the package's SQLite - that is the host's
persistence (below).

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

What one table of n rows bound to a `sap.m.Table` costs a roundtrip - the
app fills the rows when it starts and shows them again on every event:

| Rows | Start, before | Start, with `accelerate()` | Event, before | Event, with `accelerate()` |
|---:|---:|---:|---:|---:|
| 1000 | 2.3 s | 0.9 s | 3.3 s | 1.4 s |
| 2000 | 5.4 s | 1.4 s | 8.8 s | 2.1 s |
| 4000 | 19.8 s | 1.7 s | 31.3 s | 3.2 s |

CPU time of one roundtrip on Node 22, each in a fresh process, measured with
[`node/tests-examples/rowsRoundtrip.bench.mjs`](https://github.com/abap2UI5/abap2UI5/blob/main/node/tests-examples/rowsRoundtrip.bench.mjs)
of abap2UI5. With the fast paths it stays linear further up: 4.5 s for the
event roundtrip of 8000 rows, 9.5 s for 16000. In a CAP project (@cap2ui5/cds-plugin), the event roundtrip took
6.2 s for 1000 rows and 22.6 s for 2000 before; with the fast paths 2000 rows
take 1.8 s, 4000 rows 2.6 s and 8000 rows 4.4 s.

The fast paths are validated for the one `@abaplint/runtime` version this
package pins (`RUNTIME_VERSION`, exported next to `accelerate`). On any other
version - an `overrides` entry in the host's `package.json`, say -
`accelerate()` leaves the runtime alone, returns `false` and warns once.

### Node 24

Node 22 is the floor, Node 24 the recommendation. The transpiled framework is
asynchronous through and through - every ABAP method is an async function -
and Node 24 runs it faster: in one run of the benchmark above, the event
roundtrip of 2000 rows took 1.4 s of CPU on Node 24 against 1.8 s on Node 22
(5.9 s against 8.1 s without the fast paths). The gap widens behind a host
that runs each request inside an `AsyncLocalStorage` context, as CAP does for
`cds.context`, because before Node 24 such a context costs something on every
promise: inside one (`--als` of the benchmark) the same roundtrip without the
fast paths took 11.9 s instead of 8.1 s on Node 22, and 5.5 s on Node 24. In
a CAP project the 2000 rows took 22.6 s on Node 22 and 11.0 s with nothing
but `NODE_OPTIONS=--experimental-async-context-frame` (Node 22.7 and later) -
the implementation Node 24 uses by default.

### Restarts

Importing `output/` - about 800 modules - and booting the runtime takes about
a second. `NODE_COMPILE_CACHE=<dir>` (Node 22.1 and later) keeps V8's compiled
code between restarts: with a warm cache the boot took a fifth less CPU here,
and 35 % less in a CAP project. The directory has to outlive the process - a
volume, in a container.

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
| `output/` | The transpiled framework: `init.mjs` boots the runtime, one `.mjs` per ABAP object. The UI5 frontend is in here too, as the constants the GET page is built from. Not in here: the framework's own unit tests (`*.testclasses.mjs`, the runner `index.mjs`) and the source maps - a third of the package nothing a host loads |
| `setup/setup.mjs` | The database hook `init.mjs` imports - SQLite, schema, initial data |
| `setup/own-apps.mjs` | The bin `abap2ui5-own-apps` - your transpiled classes out of a transpile's output, on the package's (see [Your own apps](#your-own-apps)) |
| `setup/transpile.mjs` | The bin `abap2ui5-transpile` - the whole of [Your own apps](#your-own-apps) in one command: the transpiler at the recorded version, open-abap-core at the recorded commit, the config, the transpile, `own-apps` |
| `srv/*.d.ts` | TypeScript declarations for the three entry points - `types` in `package.json` and on every export, nothing to install |
| `downport/` | The framework's ABAP, downported to 7.02 - what the transpile read, and what your own apps are transpiled against (without its local test classes) |

The shape of `output/` - the class constructors, the static `ATTRIBUTES` and
`METHODS` maps, `~` becoming `$` - is the transpiler's, not abap2UI5's. What
this package promises is the entry point above and that `init.mjs` boots;
code that reaches into `output/` couples to `@abaplint/transpiler` and should
say so in a test of its own.

## Versions

- The package version is the framework version (`z2ui5_if_app=>version`).
- `@abaplint/runtime` and `@abaplint/database-sqlite` are pinned to the exact
  versions the transpile ran with. Transpiler output is tied to its runtime.
- Node 22 or later; Node 24 recommended (see [Node 24](#node-24)).

## Related

- [`backend-<version>.tar.gz`](https://github.com/abap2UI5/abap2UI5/releases) on every
  release - the same transpile with the pinned library checkouts, for a tool
  that downloads and builds against it (what [abap2UI5/mcp-server](https://github.com/abap2UI5/mcp-server) does)
- [Documentation](https://abap2ui5.github.io/docs/)

## License

MIT
