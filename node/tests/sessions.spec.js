// @ts-check
const { test, expect } = require("@playwright/test");
const fs = require("fs");
const path = require("path");
const { execFileSync } = require("child_process");

// ---------------------------------------------------------------------
// node/srv/host.mjs - stateful sessions (withSession(), around every
// request of createHandler()).
//
// An app that calls client->set_session_stateful( ) is kept in memory
// between its requests: the framework holds its handler in the class-data
// z2ui5_cl_ui5_http_handler=>so_sticky_handler. On an SAP system that
// class-data lives in the browser's roll area; in a Node process there is
// one for every client, and the shim's set_session_stateful( ) is a no-op -
// so the first app that went stateful answered every later request of every
// client. On top of that the framework's ICF cookie-to-header transform
// called an HTTP-entity method open-abap does not implement: a stateful app
// was answered with a 500 at all. The host keeps the sticky handler per
// session id now (the header of host.mjs, "STATEFUL SESSIONS").
//
// Client A runs node/srv/zcl_tst_sticky (stateful from its first start,
// counts its events in the instance the session keeps), client B runs
// zcl_tst_stack_a without a session, against one server in a child process
// (helpers/sessionsFramework.mjs). Needs the transpiled tree and skips
// without it, like concurrency.spec.js; test.yaml's test_node job runs it.
// ---------------------------------------------------------------------

const OUTPUT = path.join(__dirname, "..", "output", "init.mjs");
const FRAMEWORK = path.join(__dirname, "helpers", "sessionsFramework.mjs");

test.skip(!fs.existsSync(OUTPUT), "needs the transpiled backend: npm run downport && npm run auto_transpile");

/** @type {any} */
let seen;
const steps = () =>
  (seen ??= JSON.parse(
    execFileSync(process.execPath, [FRAMEWORK], {
      encoding: "utf8",
      maxBuffer: 16 * 1024 * 1024,
      timeout: 120000,
    }),
  ).steps);

test("a stateful app starts, and its response names the session the host keeps for it", () => {
  const s = steps();
  expect(s.aStart.status).toBe(200);
  expect(s.aStart.app).toBe("ZCL_TST_STICKY");
  expect(s.aStart.contextId).toMatch(/^SID:ANON:[0-9A-F]{32}$/);
});

test("another client without the session gets its own app - never the stateful one", () => {
  const s = steps();
  expect(s.bStart.app).toBe("ZCL_TST_STACK_A");
  expect(s.bStart.contextId).toBeNull();
  expect(s.bStart2.app).toBe("ZCL_TST_STACK_A");
});

test("the session's own requests reach the instance it keeps, with the same id", () => {
  const s = steps();
  expect([s.aHit.app, s.aHit.hits]).toEqual(["ZCL_TST_STICKY", 1]);
  expect([s.aHit2.app, s.aHit2.hits]).toEqual(["ZCL_TST_STICKY", 2]);
  expect(s.aHit.contextId).toBe(s.aStart.contextId);
  expect(s.aHit2.contextId).toBe(s.aStart.contextId);
});

test("an id the host never issued is no session - and is not echoed back", () => {
  const s = steps();
  expect(s.forged.app).toBe("ZCL_TST_STACK_A");
  expect(s.forged.contextId).toBeNull();
});

test("set_session_stateful( abap_false ) ends the session", () => {
  const s = steps();
  expect(s.aStop.status).toBe(200);
  expect(s.aStop.contextId).toBeNull();
  // the old id now runs a request without the session, like a new roll area
  expect(s.afterStop.app).toBe("ZCL_TST_STACK_A");
  expect(s.afterStop.contextId).toBeNull();
});

test("the frontend's terminate ping ends the session", () => {
  const s = steps();
  expect(s.cStart.contextId).toMatch(/^SID:ANON:/);
  expect(s.cStart.contextId).not.toBe(s.aStart.contextId);
  expect(s.terminate.status).toBe(200);
  // a stateful app skips the draft save, so with its session gone its draft
  // id names nothing - what an SAP system answers once the session ended
  expect(s.afterTerminate.status).toBe(500);
  expect(s.afterTerminate.contextId).toBeNull();
});

test("without sap-contextid-accept the session travels as an HttpOnly cookie, as the ICF's does", () => {
  const s = steps();
  expect(s.dStart.contextId).toBeNull();
  expect(s.dStart.cookie).toMatch(/^sap-contextid=SID:ANON:[0-9A-F]{32}; Path=\/; HttpOnly; SameSite=Lax$/);
  // the cookie among others comes back - the same session, its instance
  expect([s.dHit.app, s.dHit.hits]).toEqual(["ZCL_TST_STICKY", 1]);
  expect(s.dHit.cookie).toBe(s.dStart.cookie);
});
