// The framework half of concurrency.spec.js: several clients against ONE
// transpiled framework behind host.mjs's serve(), their requests in flight at
// the same time. A separate process for the same reason as efWire.mjs and
// compressFramework.mjs: the transpiled tree and the runtime load natively
// here, and the spec reads plain JSON back.
//
// The flows are the app-to-app hop of node/srv/zcl_tst_stack_a / _b (the
// shape of samples z2ui5_cl_smp_app_024 / _025): start A, CALL with the
// client's own value - which B has to show - then BACK with a second value,
// which A has to read off the stack. One flow takes CALL_SLOW instead, a
// request that waits a second in the middle (WAIT UP TO, a real timer), and
// the others run their whole flow while it waits.
//
// What is counted is how many requests are inside the framework at once -
// around cl_express_icf_shim.run, the call host.mjs makes per request, so a
// request waiting in the host's queue does not count and one the framework
// has in hand does. On an SAP system that number is one per roll area; here
// there is one roll area for the process, so it has to be one.
//
// stdout: JSON { flows: [{ name, errors }], maxInside, maxArrived }
import http from "node:http";
import { cl_express_icf_shim } from "../../output/cl_express_icf_shim.clas.mjs";
import { createApp, initialize } from "../../srv/host.mjs";

await initialize();

// host.mjs looks run( ) up on the class at every request
const run = cl_express_icf_shim.run;
let inside = 0;
let maxInside = 0;
cl_express_icf_shim.run = async function counted(...args) {
  inside += 1;
  maxInside = Math.max(maxInside, inside);
  try {
    return await run.apply(this, args);
  } finally {
    inside -= 1;
  }
};

const app = await createApp({ compression: false });
// ... and how many had ARRIVED at once - proof the spec did put a second
// request on the wire while the slow one was in the framework
let arrived = 0;
let maxArrived = 0;
const server = http.createServer((req, res) => {
  arrived += 1;
  maxArrived = Math.max(maxArrived, arrived);
  res.on("close", () => {
    arrived -= 1;
  });
  app(req, res);
});
await new Promise((resolve) => server.listen(0, "127.0.0.1", () => resolve(undefined)));
const base = `http://127.0.0.1:${server.address().port}/`;

async function post(sFront, model) {
  const r = await fetch(base, {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: JSON.stringify({
      value: {
        ...(model ? { MODEL: model } : {}),
        S_FRONT: { ORIGIN: base, PATHNAME: "/", SEARCH: "", ...sFront },
      },
    }),
  });
  const text = await r.text();
  if (r.status !== 200) throw new Error(`HTTP ${r.status}: ${text.slice(0, 300)}`);
  return JSON.parse(text);
}

async function flow(name, callEvent = "CALL") {
  const errors = [];
  try {
    const start = await post({ SEARCH: "?app_start=zcl_tst_stack_a" });
    const toB = await post({ ID: start.S_FRONT.ID, EVENT: callEvent }, { INPUT: `${name}-call` });
    if (toB.S_FRONT.APP !== "ZCL_TST_STACK_B") errors.push(`CALL answered by ${toB.S_FRONT.APP}`);
    if (toB.MODEL?.INPUT_FROM_A !== `${name}-call`) errors.push(`B shows ${JSON.stringify(toB.MODEL?.INPUT_FROM_A)}`);
    const back = await post({ ID: toB.S_FRONT.ID, EVENT: "BACK" }, { INPUT: `${name}-back` });
    if (back.S_FRONT.APP !== "ZCL_TST_STACK_A") errors.push(`BACK answered by ${back.S_FRONT.APP}`);
    if (back.MODEL?.RESULT !== `${name}-back`) errors.push(`A read ${JSON.stringify(back.MODEL?.RESULT)} off the stack`);
    if (back.MODEL?.INPUT !== `${name}-call`) errors.push(`A restored ${JSON.stringify(back.MODEL?.INPUT)}`);
  } catch (e) {
    errors.push(String(e.message || e).slice(0, 300));
  }
  return { name, errors };
}

const flows = [];
try {
  // the slow flow first; the fast ones start once its CALL_SLOW is out
  const slow = flow("slow", "CALL_SLOW");
  await new Promise((resolve) => setTimeout(resolve, 100));
  const fast = await Promise.all([flow("fast1"), flow("fast2"), flow("fast3")]);
  flows.push(await slow, ...fast);
} finally {
  server.closeAllConnections?.();
  server.close();
}
process.stdout.write(JSON.stringify({ flows, maxInside, maxArrived }));
