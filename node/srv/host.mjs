/*
 * host.mjs - abap2UI5 in a Node process: the entry point of the npm package
 * @abap2ui5/node-runtime, and what node/srv/express.mjs starts the dev server
 * with.
 *
 * A host that runs the framework needs four things, and this module is the
 * one place that knows where they are:
 *
 *   initialize()     boots the ABAP runtime once - the SQLite database and
 *                    the schema (setup/setup.mjs), then the framework's
 *                    class constructors - and installs accelerate()'s fast
 *                    paths on it. Idempotent: every call returns the first
 *                    call's promise.
 *   createHandler()  the HTTP handler, (req, res) => Promise<void>. It hands
 *                    the request to ZCL_SICF (node/srv/zcl_sicf.clas.abap,
 *                    transpiled with the framework), the same class an ICF
 *                    node calls on an SAP system, through open-abap's
 *                    express-icf-shim. The shim reads express-SHAPED objects:
 *                    req.method, req.url, req.path, req.headers and req.body
 *                    as a Buffer; res.append(name, value) and
 *                    res.status(code).send(buffer). Express gives all of that
 *                    with express.raw() in front; another server adapts.
 *   createApp()      an express app (4 or 5) with compress() (gzip - the
 *                    compression the framework asks the ICF for), the raw
 *                    body parser and the handler on every path - what the
 *                    dev server has always been.
 *   serve()          createApp() listening. Resolves with the http.Server.
 *   exclusive(fn)    runs fn once no other request of this process is in
 *                    the framework - what createHandler() puts around every
 *                    request (ONE REQUEST AT A TIME, below). For a host that
 *                    calls the shim itself.
 *
 * accelerate() (srv/accelerate.mjs, re-exported here) installs nothing any
 * more: @abaplint/runtime from 2.13.96 on is linear on large tables itself
 * (LOOP ... WHERE over a sorted primary key, CP), where it used to install
 * fast paths for both. It stays exported for the hosts that call it -
 * @cap2ui5/cds-plugin after booting through output/init.mjs itself - and
 * initialize() still calls it, so a host that forces an older runtime in
 * hears about it once.
 *
 * `express` is imported lazily and only by createApp/serve: it is an
 * optional peer of the package, so a host that mounts createHandler() on a
 * server of its own never loads it.
 *
 * THE PATHS. This file is packed into the package as srv/host.mjs, next to
 * output/ and setup/ - the same neighbours it has here (node/srv next to
 * node/output and node/setup), so `../output/init.mjs` resolves in both
 * places and nothing is rewritten at pack time.
 *
 * ONE REQUEST AT A TIME. On an SAP system every request runs in a roll area
 * of its own: the class-data the framework keeps per request - the user
 * exit's request context, the app-load buffer, the sticky handler - and sy
 * are that request's alone. In this process there is one set of all of it,
 * and the shim adds its own: cl_express_icf_shim keeps the ONE server object
 * in a static and swaps its request and response entities at the start of
 * every run. That holds while a request runs from start to end without
 * handing the event loop back, and SQLite (sql.js) is synchronous behind its
 * async API, so with nothing else in play it did. It stops holding the
 * moment a request really waits - WAIT UP TO (a timer), an HTTP call, a
 * draft store on an asynchronous database: the next request then runs in the
 * middle of the waiting one, on the same server object, the same sy, the
 * same open database transaction (WAIT commits it, a failed roundtrip rolls
 * it back - another request's writes with it). So the handler queues: a
 * request enters the framework when the one before it has left, the way a
 * single work process takes them. A request that waits holds the others up
 * for as long as it waits - which is the price of the shared state, not of
 * the queue. node/tests/concurrency.spec.js holds it, against flows of the
 * app stack with a request that waits in the middle.
 *
 * THE FRONTEND needs nothing here. The GET branch of
 * z2ui5_cl_ui5_http_handler answers with the page and the whole UI5 component
 * embedded in it - every module, view and stylesheet, carried as ABAP
 * constants (src/01/03, generated from app/webapp) and transpiled with the
 * backend - so the page and the roundtrips come from the same commit by
 * construction, and the package carries no frontend files of its own. A
 * first cut shipped app/webapp as well; nothing in a Node host read it.
 */
import http from "node:http";
import { initializeABAP } from "../output/init.mjs";
import { cl_express_icf_shim } from "../output/cl_express_icf_shim.clas.mjs";
import { accelerate } from "./accelerate.mjs";
import { compress } from "./compress.mjs";

export { accelerate, RUNTIME_VERSION } from "./accelerate.mjs";
export { compress } from "./compress.mjs";

/** The ICF handler class every request goes to - node/srv/zcl_sicf.clas.abap. */
export const HANDLER_CLASS = "ZCL_SICF";

let booted;

/**
 * Boot the ABAP runtime: the database, its schema and the framework, then
 * accelerate(), which warns once when the runtime is older than the one the
 * package names. Once per process; later calls return the same promise.
 * @returns {Promise<void>}
 */
export function initialize() {
  booted ??= initializeABAP().then(() => {
    accelerate();
  });
  return booted;
}

// the request in the framework, or the last one queued behind it - module
// level, not per handler: every createHandler() of the process drives the
// same statics, so they queue on one line
let queue = Promise.resolve();

/**
 * Run `fn` once every request queued before it has left the framework, and
 * hold the next one back until `fn` has settled - see ONE REQUEST AT A TIME
 * above. A rejection is handed to the caller and does not stop the queue.
 * createHandler() runs every request through it; a host that calls
 * cl_express_icf_shim.run() itself (cap2UI5) wraps that call in it.
 * @template T
 * @param {() => T | Promise<T>} fn
 * @returns {Promise<T>}
 */
export function exclusive(fn) {
  const run = queue.then(() => fn());
  queue = run.then(
    () => undefined,
    () => undefined,
  );
  return run;
}

/**
 * The HTTP handler. Boots the runtime on the first request when nothing
 * called initialize() before, and queues the requests (exclusive()).
 * @param {{ handlerClass?: string }} [options] another if_http_extension
 *   class, transpiled into the same runtime, instead of ZCL_SICF
 * @returns {(req: object, res: object) => Promise<void>}
 */
export function createHandler({ handlerClass = HANDLER_CLASS } = {}) {
  return async function handle(req, res) {
    await initialize();
    // express.raw() leaves req.body undefined on a request without one (every
    // GET); the shim reads it as a Buffer either way
    if (!req.body) req.body = Buffer.alloc(0);
    await exclusive(() => cl_express_icf_shim.run({ req, res, class: handlerClass }));
  };
}

/**
 * An express app that serves the framework on every path.
 *
 * Express 4 AND 5 - the peer range says both, because a host picks its own
 * express (@sap/cds and cap2UI5 accept `^4 || ^5`), and a peer range that
 * excludes the host's major makes npm install a second express just for
 * this package. So nothing here may be one major's syntax only:
 *   - app.use(handler), not app.all("/{*path}", ...): the named wildcard is
 *     express 5's path syntax, and express 4 reads it as a literal path that
 *     no request matches. use() without a path matches every method and
 *     path in both, and inside a mounted sub-app it sees the same stripped
 *     req.url / req.path the route did.
 *   - the rejection goes to next() by hand: express 5 forwards a rejected
 *     handler promise to its error handling, express 4 ignores it and the
 *     request hangs with an unhandled rejection.
 * compress() first: z2ui5_cl_ui5_http_handler asks the ICF to gzip every
 * response and the shim cannot, so without it the ~360 KB page and every
 * roundtrip went out uncompressed. `compression: false` leaves it out (a
 * proxy in front that compresses anyway); an object is compress()'s options.
 * @param {{ handlerClass?: string, bodyLimit?: string, compression?: boolean | object }} [options]
 * @returns {Promise<import("express").Express>}
 */
export async function createApp({ bodyLimit = "10mb", compression = true, ...options } = {}) {
  const { default: express } = await import("express");
  const app = express();
  app.disable("x-powered-by");
  app.set("etag", false);
  if (compression) app.use(compress(compression === true ? {} : compression));
  app.use(express.raw({ type: "*/*", limit: bodyLimit }));
  const handle = createHandler(options);
  app.use((req, res, next) => {
    handle(req, res).catch(next);
  });
  return app;
}

/**
 * Boot the runtime, then listen. The server is only announced once the
 * framework can answer, so "listening" means ready.
 *
 * node:http rather than app.listen(): express 5 also calls the listen
 * callback with the ERROR (a port in use), which read as "listening" and
 * resolved with a server that never bound; express 4 does not. Listening on
 * a plain http.Server behaves the same under both.
 * @param {{ port?: number | string, host?: string, handlerClass?: string, bodyLimit?: string, compression?: boolean | object }} [options]
 *   `host` unset binds every interface; "127.0.0.1" binds loopback only
 * @returns {Promise<import("node:http").Server>}
 */
export async function serve({ port = 3000, host, ...options } = {}) {
  const app = await createApp(options);
  await initialize();
  return new Promise((resolve, reject) => {
    const server = http.createServer(app);
    server.once("error", reject);
    server.listen(port, host, () => {
      server.off("error", reject);
      resolve(server);
    });
  });
}
