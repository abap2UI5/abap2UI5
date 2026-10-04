// @ts-check
const { test, expect } = require("@playwright/test");
const fs = require("fs");
const path = require("path");
const { execFileSync } = require("child_process");

// ---------------------------------------------------------------------
// node/srv/host.mjs - one request at a time in the framework.
//
// The framework keeps per-request state in class-data, and the shim the
// host hands each request to keeps the ONE server object in a static (the
// reasoning is in host.mjs, "ONE REQUEST AT A TIME"). On an SAP system every
// request has a roll area of its own; in a Node process there is one, so
// the host queues the requests (exclusive()). Without the queue a request
// that really waits - here WAIT UP TO, a timer in the transpiled runtime;
// in a host an HTTP call or an asynchronous draft store - had the next
// request run inside it, on the same statics: two requests in the framework
// at once. The web components frontend ran its e2e tests with one worker
// because two interleaving roundtrips were seen to read each other's data.
//
// Several clients run the app-stack flow of node/srv/zcl_tst_stack_a / _b
// (samples z2ui5_cl_smp_app_024 / _025) against one server, in a child
// process (helpers/concurrencyFramework.mjs). Needs the transpiled tree and
// skips without it, like the framework half of compress.spec.js; test.yaml's
// test_node job runs it on one.
// ---------------------------------------------------------------------

const OUTPUT = path.join(__dirname, "..", "output", "init.mjs");
const FRAMEWORK = path.join(__dirname, "helpers", "concurrencyFramework.mjs");

test.skip(!fs.existsSync(OUTPUT), "needs the transpiled backend: npm run downport && npm run auto_transpile");

/** @type {any} */
let seen;
const framework = () =>
  (seen ??= JSON.parse(
    execFileSync(process.execPath, [FRAMEWORK], {
      encoding: "utf8",
      maxBuffer: 16 * 1024 * 1024,
      timeout: 120000,
    }),
  ));

test("a request that waits holds the others back - never two in the framework at once", () => {
  const run = framework();
  // the spec did put requests on the wire while the slow one was inside ...
  expect(run.maxArrived).toBeGreaterThan(1);
  // ... and the framework only ever had one of them in hand
  expect(run.maxInside).toBe(1);
});

test("every client gets its own data back through the app stack", () => {
  const run = framework();
  expect(run.flows.map((/** @type {any} */ f) => f.name)).toEqual(["slow", "fast1", "fast2", "fast3"]);
  for (const flow of run.flows) {
    expect(flow.errors, flow.name).toEqual([]);
  }
});
