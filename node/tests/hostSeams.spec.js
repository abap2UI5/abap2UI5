// @ts-check
const { test, expect } = require("@playwright/test");
const fs = require("fs");
const path = require("path");
const { execFileSync } = require("child_process");

// ---------------------------------------------------------------------
// node/srv/host.mjs - the seams initialize() installs in the framework,
// and the draft sweep over them.
//
// The user exit: the framework finds it through a class-repository lookup
// that raises in this runtime, and a raised lookup is deliberately not
// latched on a system - so every get_instance( ) of every request paid the
// lookup again. initialize() installs the shipped defaults, or the host's
// own exit, through z2ui5_cl_ui5_user_exit=>set_instance( ) once. The
// draft: the asXML serializer walks the whole object graph with RTTI to
// save and to load; initialize() installs node/srv/zcl_serializer_live,
// which keeps the container itself behind an id. The sweep: the table and
// the live containers both expire by the exit's draft expiry, on a timer
// (host.mjs, THE SEAMS and DRAFT SWEEP).
//
// Against one REAL framework in a child process
// (helpers/hostSeamsFramework.mjs), twice: the defaults, and `--exit` with
// the fixture node/srv/zcl_tst_exit. Needs the transpiled tree and skips
// without it, like concurrency.spec.js; test.yaml's test_node job runs it.
// ---------------------------------------------------------------------

const OUTPUT = path.join(__dirname, "..", "output", "init.mjs");
const FRAMEWORK = path.join(__dirname, "helpers", "hostSeamsFramework.mjs");

test.skip(!fs.existsSync(OUTPUT), "needs the transpiled backend: npm run downport && npm run auto_transpile");

/** @type {Record<string, any>} */
const seen = {};
const run = (/** @type {string[]} */ args = []) =>
  (seen[args.join(" ")] ??= JSON.parse(
    execFileSync(process.execPath, [FRAMEWORK, ...args], {
      encoding: "utf8",
      maxBuffer: 16 * 1024 * 1024,
      timeout: 120000,
    }),
  ));

test("initialize() installs the shipped exit, latched as 'no exit installed'", () => {
  const { seams } = run();
  expect(seams.exitKnown).toBe("X");
  expect(seams.exitClass).toBe("");
  expect(seams.meIsShipped).toBe(true);
  expect(seams.userExitIsFixture).toBe(false);
});

test("initialize({ exit }) installs the host's exit, called through the shipped one", () => {
  const { seams, page } = run(["--exit"]);
  expect(seams.exitKnown).toBe("X");
  expect(seams.exitClass).toBe("ZCL_TST_EXIT");
  expect(seams.meIsShipped).toBe(true);
  expect(seams.userExitIsFixture).toBe(true);
  // the page shows the fixture's theme, with the defaults seeded first
  expect(page.status).toBe(200);
  expect(page.theme).toBe("sap_fiori_3");
  expect(page.csp).toBe(true);
  // draftSweepMs: false leaves the timer off
  expect(seams.sweep).toEqual({ intervalMs: 0 });
});

test("initialize() installs the live-container serializer and arms the sweep", () => {
  const { seams } = run();
  expect(seams.serializerIsLive).toBe(true);
  expect(seams.sweep).toEqual({ intervalMs: seams.defaultSweepMs });
  expect(seams.defaultSweepMs).toBe(5 * 60 * 1000);
});

test("a roundtrip with state goes through the live serializer - ids in the table, the objects behind them", () => {
  const { flow, drafts } = run();
  expect(flow.statuses).toEqual([200, 200, 200]);
  expect(flow.appB).toBe("ZCL_TST_STACK_B");
  expect(flow.shownInB).toBe("live-call");
  expect(flow.appA).toBe("ZCL_TST_STACK_A");
  expect(flow.resultInA).toBe("live-back");
  expect(flow.restoredInA).toBe("live-call");
  // three roundtrips, three drafts at least - each row an id, each id a container
  expect(drafts.rows).toBeGreaterThanOrEqual(3);
  expect(drafts.live).toBeGreaterThanOrEqual(drafts.rows);
  expect(drafts.answered).toBe(drafts.rows);
  expect(drafts.allIds).toBe(true);
  expect(drafts.anyXml).toBe(false);
});

test("an id the live table no longer holds is a missing draft, not a crash", () => {
  const { missing } = run();
  expect(missing.status).toBe(500);
  expect(missing.noDraft).toBe(true);
});

test("sweepDrafts() drops the expired rows, and the serializer's sweep the expired containers", () => {
  const { sweep } = run();
  expect(sweep.before.rows).toBeGreaterThan(0);
  expect(sweep.before.live).toBeGreaterThan(0);
  // the rows were dated back past the expiry: the store's cleanup took them
  expect(sweep.afterRows).toBe(0);
  // the containers are young - the same sweep kept them ...
  expect(sweep.first).toEqual({ dropped: 0, kept: sweep.before.live });
  // ... and a clock past the expiry takes them all
  expect(sweep.dropped).toBe(sweep.before.live);
  expect(sweep.left).toBe(0);
});
