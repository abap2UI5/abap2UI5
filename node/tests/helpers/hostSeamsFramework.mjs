// The framework half of hostSeams.spec.js: what host.mjs's initialize()
// installs in the REAL transpiled framework - the user exit seam, the
// live-container serializer - and the draft sweep over both. A separate
// process for the same reason as concurrencyFramework.mjs: the transpiled
// tree and the runtime load natively here, and the spec reads plain JSON
// back. Started twice by the spec: once with the defaults, once with
// `--exit`, which hands initialize() the fixture exit node/srv/zcl_tst_exit.
//
// The flow is the app-stack hop of node/srv/zcl_tst_stack_a / _b: start A,
// CALL with a value B has to show, BACK with a second value A reads off the
// stack - state that has to survive three drafts.
//
// stdout: JSON { seams, flow, drafts, missing, sweep } (defaults) or
//         JSON { seams, page } (--exit)
import http from "node:http";
import { z2ui5_cl_ui5_user_exit } from "../../output/project/z2ui5_cl_ui5_user_exit.clas.mjs";
import { z2ui5_cl_ui5_app_cont } from "../../output/project/z2ui5_cl_ui5_app_cont.clas.mjs";
import { zcl_serializer_live } from "../../output/project/zcl_serializer_live.clas.mjs";
import { zcl_tst_exit } from "../../output/project/zcl_tst_exit.clas.mjs";
import { createApp, initialize, configureDraftSweep, sweepDrafts, DRAFT_SWEEP_MS } from "../../srv/host.mjs";

const withExit = process.argv.includes("--exit");

const exit = withExit ? await new zcl_tst_exit().constructor_() : undefined;
await initialize(withExit ? { exit, draftSweepMs: false } : {});

// the seams, read off the framework's class-data: transpiler output, so the
// shape (static attributes, `.get()`) is the transpiler's - the one place
// this repository couples to it on purpose (test-inventory.md)
const seams = {
  exitKnown: z2ui5_cl_ui5_user_exit.gv_exit_class_known.get(),
  exitClass: (await z2ui5_cl_ui5_user_exit.get_user_exit_class({ result: 1 })).get(),
  meIsShipped: z2ui5_cl_ui5_user_exit.gi_me.get() instanceof z2ui5_cl_ui5_user_exit,
  userExitIsFixture: z2ui5_cl_ui5_user_exit.gi_user_exit.get() instanceof zcl_tst_exit,
  serializerIsLive: z2ui5_cl_ui5_app_cont.gi_serializer.get() instanceof zcl_serializer_live,
  sweep: configureDraftSweep(),
  defaultSweepMs: DRAFT_SWEEP_MS,
};

const app = await createApp({ compression: false });
const server = http.createServer(app);
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
  return { status: r.status, json: r.status === 200 ? JSON.parse(text) : null, text: text.slice(0, 400) };
}

const db = globalThis.abap.context.databaseConnections["DEFAULT"];
async function draftRows() {
  const { rows } = await db.select({ select: "SELECT id, data FROM z2ui5_t_01" });
  return rows;
}

const out = { seams };
try {
  if (withExit) {
    // the page carries the fixture's theme: the exit was called, through the
    // shipped one (the page is complete - the defaults were seeded first)
    const r = await fetch(`${base}?app_start=zcl_tst_stack_a`);
    const page = await r.text();
    out.page = {
      status: r.status,
      theme: /data-sap-ui-theme="([^"]*)"/.exec(page)?.[1] ?? null,
      csp: page.includes("Content-Security-Policy"),
    };
  } else {
    const start = await post({ SEARCH: "?app_start=zcl_tst_stack_a" });
    const toB = await post({ ID: start.json.S_FRONT.ID, EVENT: "CALL" }, { INPUT: "live-call" });
    const back = await post({ ID: toB.json.S_FRONT.ID, EVENT: "BACK" }, { INPUT: "live-back" });
    out.flow = {
      statuses: [start.status, toB.status, back.status],
      appB: toB.json?.S_FRONT?.APP ?? null,
      shownInB: toB.json?.MODEL?.INPUT_FROM_A ?? null,
      appA: back.json?.S_FRONT?.APP ?? null,
      resultInA: back.json?.MODEL?.RESULT ?? null,
      restoredInA: back.json?.MODEL?.INPUT ?? null,
    };

    // every row's data is an id into the live table, never asXML, and every
    // id answers a container (the table can hold more ids than rows: a save
    // that lands on an existing row UPDATEs it, the id before is still kept)
    const rows = await draftRows();
    const live = await new zcl_serializer_live().constructor_();
    let answered = 0;
    for (const r of rows) {
      const cont = await live.z2ui5_if_ui5_serializer$parse({ val: String(r.data).trim(), result: 1 });
      if (cont.get() instanceof z2ui5_cl_ui5_app_cont) answered += 1;
    }
    out.drafts = {
      rows: rows.length,
      live: (await zcl_serializer_live.count_entries({ result: 1 })).get(),
      answered,
      allIds: rows.every((r) => /^[0-9A-F]{32}$/.test(String(r.data).trim())),
      anyXml: rows.some((r) => String(r.data).includes("<")),
    };

    // a container the live table no longer holds answers like a missing
    // draft row: the framework's error, not a crash
    await zcl_serializer_live.clear();
    const gone = await post({ ID: back.json.S_FRONT.ID, EVENT: "CALL" }, { INPUT: "after-clear" });
    out.missing = { status: gone.status, noDraft: gone.text.includes("NO_DRAFT_ENTRY_OF_PREVIOUS_REQUEST_FOUND") };

    // the sweep: a flow's drafts, the rows dated back past the expiry, one
    // sweepDrafts() - the rows go, the containers (young) stay; then the
    // serializer's own sweep with a clock past the expiry takes those too
    const again = await post({ SEARCH: "?app_start=zcl_tst_stack_a" });
    await post({ ID: again.json.S_FRONT.ID, EVENT: "CALL" }, { INPUT: "sweep" });
    const before = { rows: (await draftRows()).length, live: (await zcl_serializer_live.count_entries({ result: 1 })).get() };
    await db.execute("UPDATE z2ui5_t_01 SET timestampl = timestampl - 10000000");
    const first = await sweepDrafts();
    const afterRows = (await draftRows()).length;
    const future = new globalThis.abap.types.Packed({ length: 11, decimals: 7 });
    // the clock a day ahead, in the digits of a timestampl: past any expiry
    future.set(String(Number(new Date().toISOString().replace(/[-T:]/g, "").slice(0, 14)) + 1000000));
    const dropped = (await zcl_serializer_live.sweep({ iv_now: future, result: 1 })).get();
    out.sweep = {
      before,
      first,
      afterRows,
      dropped,
      left: (await zcl_serializer_live.count_entries({ result: 1 })).get(),
    };
  }
} finally {
  server.closeAllConnections?.();
  server.close();
}
process.stdout.write(JSON.stringify(out));
