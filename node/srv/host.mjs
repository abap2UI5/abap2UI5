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
 *                    class constructors. Idempotent: every call returns the
 *                    first call's promise.
 *   createHandler()  the HTTP handler, (req, res) => Promise<void>. It hands
 *                    the request to ZCL_SICF (node/srv/zcl_sicf.clas.abap,
 *                    transpiled with the framework), the same class an ICF
 *                    node calls on an SAP system, through open-abap's
 *                    express-icf-shim. The shim reads express-SHAPED objects:
 *                    req.method, req.url, req.path, req.headers and req.body
 *                    as a Buffer; res.append(name, value) and
 *                    res.status(code).send(buffer). Express gives all of that
 *                    with express.raw() in front; another server adapts.
 *   createApp()      an express app with the raw body parser and the handler
 *                    on every path - what the dev server has always been.
 *   serve()          createApp() listening. Resolves with the http.Server.
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
 * THE FRONTEND needs nothing here. The GET branch of
 * z2ui5_cl_ui5_http_handler answers with the page and the whole UI5 component
 * embedded in it - every module, view and stylesheet, carried as ABAP
 * constants (src/01/03, generated from app/webapp) and transpiled with the
 * backend - so the page and the roundtrips come from the same commit by
 * construction, and the package carries no frontend files of its own. A
 * first cut shipped app/webapp as well; nothing in a Node host read it.
 */
import { initializeABAP } from "../output/init.mjs";
import { cl_express_icf_shim } from "../output/cl_express_icf_shim.clas.mjs";

/** The ICF handler class every request goes to - node/srv/zcl_sicf.clas.abap. */
export const HANDLER_CLASS = "ZCL_SICF";

let booted;

/**
 * Boot the ABAP runtime: the database, its schema and the framework. Once
 * per process; later calls return the same promise.
 * @returns {Promise<void>}
 */
export function initialize() {
  booted ??= initializeABAP();
  return booted;
}

/**
 * The HTTP handler. Boots the runtime on the first request when nothing
 * called initialize() before.
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
    await cl_express_icf_shim.run({ req, res, class: handlerClass });
  };
}

/**
 * An express app that serves the framework on every path.
 * @param {{ handlerClass?: string, bodyLimit?: string }} [options]
 * @returns {Promise<import("express").Express>}
 */
export async function createApp({ bodyLimit = "10mb", ...options } = {}) {
  const { default: express } = await import("express");
  const app = express();
  app.disable("x-powered-by");
  app.set("etag", false);
  app.use(express.raw({ type: "*/*", limit: bodyLimit }));
  app.all("/{*path}", createHandler(options));
  return app;
}

/**
 * Boot the runtime, then listen. The server is only announced once the
 * framework can answer, so "listening" means ready.
 * @param {{ port?: number | string, host?: string, handlerClass?: string, bodyLimit?: string }} [options]
 *   `host` unset binds every interface; "127.0.0.1" binds loopback only
 * @returns {Promise<import("node:http").Server>}
 */
export async function serve({ port = 3000, host, ...options } = {}) {
  const app = await createApp(options);
  await initialize();
  return new Promise((resolve, reject) => {
    const server = app.listen(port, host, () => resolve(server));
    server.on("error", reject);
  });
}
