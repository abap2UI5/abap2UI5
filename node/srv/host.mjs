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
 *                    class constructors - installs the host's seams in the
 *                    framework (THE SEAMS, below) and starts the draft sweep
 *                    (DRAFT SWEEP, below). Idempotent: every call returns
 *                    the first call's promise, so the options of the first
 *                    call are the ones in force.
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
 *   withSession(req, res, fn)
 *                    runs fn - one request - in the stateful session the
 *                    request names, and hands the session id back on the
 *                    response (STATEFUL SESSIONS, below). createHandler()
 *                    puts it around every request; inside exclusive( ).
 *   sweepDrafts()    drops the expired drafts - the table's rows and the
 *                    live containers behind them - inside exclusive(); what
 *                    the timer of DRAFT SWEEP runs, for a host that would
 *                    rather run it itself.
 *   configureDraftSweep({ intervalMs })
 *                    how often the timer runs sweepDrafts() (0 stops it).
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
 * places and nothing is rewritten at pack time. Below output/ the transpiler
 * (2.14 on) writes one folder per origin: project/ for the framework,
 * open-abap-core/ and express-icf-shim/ for the two libraries.
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
 * STATEFUL SESSIONS. An app that calls client->set_session_stateful( ) is
 * kept in memory between its requests: the framework holds its handler in
 * z2ui5_cl_ui5_http_handler=>so_sticky_handler, and on an SAP system the ICF
 * gives the browser a session (sap-contextid) whose roll area keeps that
 * class-data - every other browser has a roll area, and a sticky handler, of
 * its own. In this process there is one class-data for all of them, and the
 * shim's set_session_stateful( ) is a no-op: the first app that went
 * stateful answered every later request of every client (the framework
 * takes the sticky handler whatever draft id a request names). The host is
 * the session layer here, the way the ICF is on an SAP system:
 *   - a stateful session is the sticky handler a response left behind. The
 *     host keeps it under a session id of its own (random, never one a client
 *     proposed) and sends that id back in the response header sap-contextid
 *     when the request asked for it (sap-contextid-accept: header - the UI5
 *     frontend always does), else as an HttpOnly cookie, the ICF's default;
 *   - a request that names a session the host keeps gets its sticky handler
 *     put back before the framework runs, any other request - no id, an id
 *     the host never issued, an expired one - runs with none, as a request
 *     in a new roll area would; after the request the class-data is cleared
 *     again, so nothing of one session is ever seen by the next request;
 *   - set_session_stateful( abap_false ) ends the session (the response
 *     leaves no sticky handler), so does the frontend's terminate ping (HEAD
 *     with sap-terminate: session) once the framework answered it, and a
 *     session idle for longer than its ttl (30 minutes, as rdisp/plugin_auto
 *     logout ends an ICF session); at most `max` sessions are kept, the least
 *     recently used goes first (configureSessions( ));
 *   - the framework never sees a session header: they are taken off the
 *     request before the shim reads it. Its own contextid handling is the
 *     ICF's cookie-to-header transform (set_response), which reads the
 *     response cookie the ICF sets - a call open-abap's HTTP entity does not
 *     implement, so a stateful app answered with a 500 here - and otherwise
 *     echoed whatever sap-contextid the request carried, a forged one too.
 * A host with users (cap2UI5) binds a session to its owner: withSession( )'s
 * `owner` - a request of another user that names the id runs without it.
 * Only the sticky handler is per session; the class-data of the apps
 * themselves is the process's, as before. node/tests/sessions.spec.js holds
 * it.
 *
 * THE SEAMS. The framework looks two things up in the class repository of
 * an SAP system that this runtime does not have: the user exit (the class
 * implementing z2ui5_if_ui5_exit) and, through it, the roundtrip monitor.
 * The exit lookup RAISES here (no SEO_INTERFACE_IMPLEM_GET_ALL), and a
 * raised lookup is deliberately not remembered on a system - a transient
 * repository error must not leave a sticky session on the shipped defaults
 * for good - so every z2ui5_cl_ui5_user_exit=>get_instance( ) of every
 * request walked the RTTI and the dynamic call again, three times per
 * POST. initialize() tells the framework once, through
 * z2ui5_cl_ui5_user_exit=>set_instance( ): the shipped exit (the defaults,
 * latched as "no exit installed"), or the host's own `exit` - an instance
 * of a transpiled ABAP class implementing z2ui5_if_ui5_exit, called through
 * the shipped exit the way a customer exit on a system is, so the defaults
 * are seeded first. And the draft: z2ui5_cl_ui5_app_cont turns the app
 * state into asXML through CALL TRANSFORMATION id and S-RTTI, which this
 * runtime reproduces with an RTTI walk of the whole object graph - to save
 * AND to load, on every click. In a process the object is still there on
 * the next request, so initialize() installs zcl_serializer_live
 * (node/srv/zcl_serializer_live.clas.abap, transpiled with the framework
 * and packed next to zcl_sicf): the draft row carries an id, the container
 * stays live behind it, and an id names the container as it IS - the
 * semantics of a stateful session for every app; the class comment has the
 * rest. node/tests/hostSeams.spec.js holds both.
 *
 * DRAFT SWEEP. Z2UI5_T_01 takes one row per roundtrip and is swept by the
 * framework only when an app cold-starts (z2ui5_cl_ui5_handler calls
 * cleanup( ) from factory_first_start, never per roundtrip - a maintainer
 * decision, docs/agents/decisions.md), and the live containers of
 * zcl_serializer_live are swept by nothing in the framework at all. On a
 * system the table is the database's and every process shares it; here it
 * is this process's memory, and a dev server nobody restarts, with apps
 * that never cold-start again, grew without bound. So initialize() arms a
 * timer: every `draftSweepMs` (5 minutes) sweepDrafts() runs the store's
 * cleanup( ) - the DELETE below the expiry the exit answers - and the
 * serializer's sweep( ) with the same expiry, inside exclusive(), so no
 * request is in the framework while it runs. The timer is unref'd: it
 * keeps no process alive that has nothing else to do. A sweep that fails
 * (the exit raising, say) is logged and the next one runs as scheduled.
 *
 * THE FRONTEND needs nothing here. The GET branch of
 * z2ui5_cl_ui5_http_handler answers with the page and the whole UI5 component
 * embedded in it - every module, view and stylesheet, carried as ABAP
 * constants (src/01/03, generated from app/webapp) and transpiled with the
 * backend - so the page and the roundtrips come from the same commit by
 * construction, and the package carries no frontend files of its own. A
 * first cut shipped app/webapp as well; nothing in a Node host read it.
 */
import { randomUUID } from "node:crypto";
import http from "node:http";
import { initializeABAP } from "../output/init.mjs";
import { cl_express_icf_shim } from "../output/express-icf-shim/cl_express_icf_shim.clas.mjs";
import { z2ui5_cl_ui5_http_handler } from "../output/project/z2ui5_cl_ui5_http_handler.clas.mjs";
import { z2ui5_cl_ui5_user_exit } from "../output/project/z2ui5_cl_ui5_user_exit.clas.mjs";
import { z2ui5_cl_ui5_app_cont } from "../output/project/z2ui5_cl_ui5_app_cont.clas.mjs";
import { z2ui5_cl_ui5_srv_draft } from "../output/project/z2ui5_cl_ui5_srv_draft.clas.mjs";
import { zcl_serializer_live } from "../output/project/zcl_serializer_live.clas.mjs";
import { accelerate } from "./accelerate.mjs";
import { compress } from "./compress.mjs";
import { hostGuard } from "./hostguard.mjs";

export { accelerate, RUNTIME_VERSION } from "./accelerate.mjs";
export { compress } from "./compress.mjs";
export { hostGuard } from "./hostguard.mjs";

/** The ICF handler class every request goes to - node/srv/zcl_sicf.clas.abap. */
export const HANDLER_CLASS = "ZCL_SICF";

let booted;

/** The default of `draftSweepMs`: five minutes. */
export const DRAFT_SWEEP_MS = 5 * 60 * 1000;

/**
 * Boot the ABAP runtime: the database, its schema and the framework, then
 * accelerate(), which warns once when the runtime is older than the one the
 * package names; then the host's seams (THE SEAMS above) and the draft
 * sweep (DRAFT SWEEP above). Once per process; later calls return the same
 * promise, with the first call's options in force.
 * @param {{ exit?: object, draftSweepMs?: number | false }} [options]
 *   `exit`: the host's own user exit - an instance of a transpiled ABAP class
 *   implementing z2ui5_if_ui5_exit (after its `constructor_()`), instead of
 *   the shipped defaults. `draftSweepMs`: how often the expired drafts are
 *   swept (default DRAFT_SWEEP_MS); 0 or false leaves the timer off.
 * @returns {Promise<void>}
 */
export function initialize({ exit, draftSweepMs = DRAFT_SWEEP_MS } = {}) {
  booted ??= initializeABAP().then(async () => {
    accelerate();
    await installSeams({ exit });
    configureDraftSweep({ intervalMs: draftSweepMs || 0 });
  });
  return booted;
}

/** The options of initialize() out of a wider options object (serve(), createApp(), createHandler()). */
function initOptions({ exit, draftSweepMs } = {}) {
  return { exit, ...(draftSweepMs !== undefined ? { draftSweepMs } : {}) };
}

/** The framework's class-data seams, set once per process - THE SEAMS above. */
async function installSeams({ exit }) {
  const io_exit = exit ?? (await new z2ui5_cl_ui5_user_exit().constructor_());
  await z2ui5_cl_ui5_user_exit.set_instance({ io_exit });
  const serializer = await new zcl_serializer_live().constructor_();
  await z2ui5_cl_ui5_app_cont.set_serializer({ serializer });
}

let sweepTimer;
const sweep = { intervalMs: 0 };

/**
 * Drop the expired drafts: the rows of the draft table (the store's
 * cleanup( ) - the DELETE below the expiry the exit answers, what the
 * framework runs on an app cold start) and the live containers of
 * zcl_serializer_live older than that same expiry. Inside exclusive(), so
 * it never runs while a request is in the framework. Resolves with how
 * many containers went and how many are kept.
 * @returns {Promise<{ dropped: number, kept: number }>}
 */
export function sweepDrafts() {
  return exclusive(async () => {
    const store = (await z2ui5_cl_ui5_srv_draft.get_instance({ result: 1 })).get();
    await store.z2ui5_if_ui5_draft_store$cleanup();
    const dropped = (await zcl_serializer_live.sweep({ result: 1 })).get();
    const kept = (await zcl_serializer_live.count_entries({ result: 1 })).get();
    return { dropped, kept };
  });
}

/**
 * Arm the timer that runs sweepDrafts() every `intervalMs` (DRAFT SWEEP
 * above) - or stop it with 0. Returns the interval in force. The timer is
 * unref'd and never keeps the process alive on its own.
 * @param {{ intervalMs?: number }} [options]
 * @returns {{ intervalMs: number }}
 */
export function configureDraftSweep({ intervalMs } = {}) {
  if (intervalMs === undefined) return { ...sweep };
  if (sweepTimer) {
    clearInterval(sweepTimer);
    sweepTimer = undefined;
  }
  sweep.intervalMs = Number.isFinite(intervalMs) && intervalMs > 0 ? intervalMs : 0;
  if (sweep.intervalMs > 0) {
    sweepTimer = setInterval(() => {
      sweepDrafts().catch((e) => console.warn(`abap2ui5: the draft sweep failed - ${e?.message ?? e}`));
    }, sweep.intervalMs);
    sweepTimer.unref();
  }
  return { ...sweep };
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

const SESSION_HEADER = "sap-contextid";
// session id -> { handler, owner, last } - see STATEFUL SESSIONS above
const sessions = new Map();
const sessionLimits = { ttlMs: 30 * 60 * 1000, max: 1000 };

/**
 * Set how long an idle stateful session is kept (`ttlMs`, default 30
 * minutes) and how many are kept at most (`max`, default 1000; the least
 * recently used goes first). Returns the limits now in force.
 * @param {{ ttlMs?: number, max?: number }} [limits]
 * @returns {{ ttlMs: number, max: number }}
 */
export function configureSessions({ ttlMs, max } = {}) {
  if (Number.isFinite(ttlMs) && ttlMs > 0) sessionLimits.ttlMs = ttlMs;
  if (Number.isInteger(max) && max > 0) sessionLimits.max = max;
  return { ...sessionLimits };
}

/** The number of stateful sessions this process keeps right now. */
export function sessionCount() {
  sweepSessions(Date.now());
  return sessions.size;
}

function sweepSessions(now) {
  for (const [id, s] of sessions) {
    if (now - s.last > sessionLimits.ttlMs) sessions.delete(id);
  }
  // a Map iterates in insertion order and a used session is re-inserted, so
  // the first entries are the least recently used
  for (const id of sessions.keys()) {
    if (sessions.size <= sessionLimits.max) break;
    sessions.delete(id);
  }
}

function headerOf(headers, name) {
  const v = headers?.[name];
  return Array.isArray(v) ? v[0] : v;
}

function cookieOf(header, name) {
  for (const part of String(header ?? "").split(";")) {
    const i = part.indexOf("=");
    if (i > 0 && part.slice(0, i).trim() === name) return part.slice(i + 1).trim();
  }
  return undefined;
}

/** The request's headers without the session layer's - what the framework sees. */
function withoutSessionHeaders(headers) {
  const out = { ...headers };
  delete out[SESSION_HEADER];
  delete out["sap-contextid-accept"];
  if (out.cookie !== undefined) {
    const rest = String(out.cookie)
      .split(";")
      .filter((part) => part.split("=")[0].trim() !== SESSION_HEADER)
      .join(";")
      .trim();
    if (rest) out.cookie = rest;
    else delete out.cookie;
  }
  return out;
}

/**
 * Run `fn` - one request through the shim - in the stateful session the
 * request names (header or cookie sap-contextid), and answer the session id
 * of the stateful session the request leaves behind. See STATEFUL SESSIONS
 * above. Call it inside exclusive( ): it swaps the framework's class-data,
 * which only one request may hold at a time. createHandler() does both.
 * @template T
 * @param {object} req  the express-shaped request; its session headers are
 *   taken off before `fn` runs
 * @param {object} res  the express-shaped response; the session id goes on
 *   it before the shim sends it
 * @param {() => T | Promise<T>} fn
 * @param {{ owner?: string }} [options] the user a session belongs to, for a
 *   host with users - a request of another user runs without the session
 * @returns {Promise<T>}
 */
export async function withSession(req, res, fn, { owner = "" } = {}) {
  const sticky = z2ui5_cl_ui5_http_handler.so_sticky_handler;
  const now = Date.now();
  sweepSessions(now);

  const headers = req.headers ?? {};
  const named = headerOf(headers, SESSION_HEADER) || cookieOf(headerOf(headers, "cookie"), SESSION_HEADER);
  const asHeader = String(headerOf(headers, "sap-contextid-accept") ?? "").toLowerCase() === "header";
  const terminate =
    String(req.method).toUpperCase() === "HEAD" &&
    String(headerOf(headers, "sap-terminate") ?? "").toLowerCase() === "session";
  const kept = named ? sessions.get(named) : undefined;
  // an id is only ever one the host issued, for this owner
  let id = kept && kept.owner === owner ? named : undefined;

  req.headers = withoutSessionHeaders(headers);
  if (id) sticky.set(kept.handler);
  else sticky.clear();

  let settled = false;
  // what the request left behind decides the session - read when the shim
  // sends the response (the handler has run by then), or after a request
  // that failed before it got there
  const settle = (answer) => {
    if (settled) return;
    settled = true;
    const status = Number(res.statusCode ?? 200);
    const handler = sticky.get();
    if (terminate && status < 300) {
      if (id) sessions.delete(id);
      return;
    }
    if (handler === undefined) {
      if (id) sessions.delete(id);
      return;
    }
    if (!id) id = `SID:ANON:${randomUUID().replaceAll("-", "").toUpperCase()}`;
    sessions.delete(id);
    sessions.set(id, { handler, owner, last: Date.now() });
    sweepSessions(Date.now());
    if (!answer || !sessions.has(id)) return;
    if (asHeader) res.append(SESSION_HEADER, id);
    else res.append("Set-Cookie", `${SESSION_HEADER}=${id}; Path=/; HttpOnly; SameSite=Lax`);
  };

  const hadOwnSend = Object.prototype.hasOwnProperty.call(res, "send");
  const send = res.send;
  res.send = function sendInSession(...args) {
    settle(true);
    return send.apply(this, args);
  };
  try {
    return await fn();
  } finally {
    settle(false);
    sticky.clear();
    if (hadOwnSend) res.send = send;
    else delete res.send;
  }
}

/**
 * The HTTP handler. Boots the runtime on the first request when nothing
 * called initialize() before, queues the requests (exclusive()) and keeps
 * the stateful sessions (withSession()).
 * @param {{ handlerClass?: string, exit?: object, draftSweepMs?: number | false }} [options]
 *   `handlerClass`: another if_http_extension class, transpiled into the
 *   same runtime, instead of ZCL_SICF; the rest is initialize()'s
 * @returns {(req: object, res: object) => Promise<void>}
 */
export function createHandler({ handlerClass = HANDLER_CLASS, ...options } = {}) {
  const init = initOptions(options);
  return async function handle(req, res) {
    await initialize(init);
    // express.raw() leaves req.body undefined on a request without one (every
    // GET); the shim reads it as a Buffer either way
    if (!req.body) req.body = Buffer.alloc(0);
    await exclusive(() => withSession(req, res, () => cl_express_icf_shim.run({ req, res, class: handlerClass })));
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
 * @param {{ handlerClass?: string, bodyLimit?: string, compression?: boolean | object, exit?: object, draftSweepMs?: number | false }} [options]
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
 *
 * hostGuard() goes in front of everything: only a request addressed to
 * 127.0.0.1, localhost, [::1], the bound address when it is a name, or a name
 * in `allowedHosts` - and, with an Origin, coming from a page there - is
 * answered; any other gets a 403 (srv/hostguard.mjs says why: DNS
 * rebinding). `allowedHosts: "*"` answers every request, as before.
 * @param {{ port?: number | string, host?: string, allowedHosts?: string | string[], handlerClass?: string, bodyLimit?: string, compression?: boolean | object, exit?: object, draftSweepMs?: number | false }} [options]
 *   `host` unset binds every interface; "127.0.0.1" binds loopback only
 * @returns {Promise<import("node:http").Server>}
 */
export async function serve({ port = 3000, host, allowedHosts, ...options } = {}) {
  const app = await createApp(options);
  const guard = hostGuard({ host, allowedHosts });
  await initialize(initOptions(options));
  return new Promise((resolve, reject) => {
    const server = http.createServer((req, res) => guard(req, res, () => app(req, res)));
    server.once("error", reject);
    server.listen(port, host, () => {
      server.off("error", reject);
      resolve(server);
    });
  });
}
