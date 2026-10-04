// The framework half of sessions.spec.js: stateful sessions against ONE
// transpiled framework behind host.mjs's serve(). A separate process for the
// same reason as concurrencyFramework.mjs: the transpiled tree loads natively
// here, and the spec reads plain JSON back.
//
// Client A starts node/srv/zcl_tst_sticky, which switches the stateful
// session on; client B - another browser, no sap-contextid - starts
// zcl_tst_stack_a. On an SAP system B lands in a roll area of its own; the
// Node process has one set of class-data, so the framework's sticky handler
// (z2ui5_cl_ui5_http_handler=>so_sticky_handler) answered B with A's app
// until the host kept it per session.
//
// stdout: JSON { steps: { <name>: { status, app, contextId, hits } } }
import http from "node:http";
import { createApp, initialize } from "../../srv/host.mjs";

await initialize();
const app = await createApp({ compression: false });
const server = http.createServer(app);
await new Promise((resolve) => server.listen(0, "127.0.0.1", () => resolve(undefined)));
const base = `http://127.0.0.1:${server.address().port}/`;

async function post(sFront, { contextId, model, cookie } = {}) {
  // cookie: the ICF's default transport - no sap-contextid-accept, the id
  // goes back as a cookie
  const headers = { "content-type": "application/json" };
  if (cookie === undefined) headers["sap-contextid-accept"] = "header";
  else if (cookie) headers.cookie = `theme=x; ${cookie}; lang=EN`;
  if (contextId) headers["sap-contextid"] = contextId;
  const r = await fetch(base, {
    method: "POST",
    headers,
    body: JSON.stringify({
      value: {
        ...(model ? { MODEL: model } : {}),
        S_FRONT: { ORIGIN: base, PATHNAME: "/", SEARCH: "", ...sFront },
      },
    }),
  });
  const text = await r.text();
  let json = null;
  try {
    json = JSON.parse(text);
  } catch {
    /* an error body */
  }
  return {
    status: r.status,
    app: json?.S_FRONT?.APP ?? null,
    id: json?.S_FRONT?.ID ?? null,
    hits: json?.MODEL?.HITS ?? json?.MODEL?.["/HITS"] ?? null,
    contextId: r.headers.get("sap-contextid"),
    cookie: r.headers.get("set-cookie"),
    text: r.status === 200 ? undefined : text.slice(0, 300),
  };
}

const steps = {};
const aStart = (steps.aStart = await post({ SEARCH: "?app_start=zcl_tst_sticky" }));
steps.bStart = await post({ SEARCH: "?app_start=zcl_tst_stack_a" });
const aHit = (steps.aHit = await post({ ID: aStart.id, EVENT: "HIT" }, { contextId: aStart.contextId }));
steps.aHit2 = await post({ ID: aHit.id, EVENT: "HIT" }, { contextId: aStart.contextId });
// a session id the host never issued is no session: a stateless request
steps.forged = await post({ SEARCH: "?app_start=zcl_tst_stack_a" }, { contextId: "SID:FORGED:0000" });
// B again, after A's events - still B's own app
steps.bStart2 = await post({ SEARCH: "?app_start=zcl_tst_stack_a" });
// A switches the session off: no id any more, and B stays unaffected
steps.aStop = await post({ ID: steps.aHit2.id, EVENT: "STOP" }, { contextId: aStart.contextId });
steps.afterStop = await post({ SEARCH: "?app_start=zcl_tst_stack_a" }, { contextId: aStart.contextId });

// a second stateful session, then the frontend's terminate HEAD ends it
const cStart = (steps.cStart = await post({ SEARCH: "?app_start=zcl_tst_sticky" }));
const term = await fetch(base, {
  method: "HEAD",
  headers: { "sap-terminate": "session", "sap-contextid": cStart.contextId ?? "", "sap-contextid-accept": "header" },
});
steps.terminate = { status: term.status };
steps.afterTerminate = await post({ ID: cStart.id, EVENT: "HIT" }, { contextId: cStart.contextId });

// the cookie transport: the id goes out as an HttpOnly cookie and comes back in one
const dStart = (steps.dStart = await post({ SEARCH: "?app_start=zcl_tst_sticky" }, { cookie: "" }));
const cookie = (dStart.cookie ?? "").split(";")[0];
steps.dHit = await post({ ID: dStart.id, EVENT: "HIT" }, { cookie });

server.close();
process.stdout.write(`${JSON.stringify({ steps })}\n`);
process.exit(0);
