#!/usr/bin/env node
/*
 * rowsRoundtrip.bench.mjs - what one table of n rows costs a roundtrip of
 * the transpiled framework on @abaplint/runtime.
 *
 * Reference material, not a gate: the numbers are the machine's. It exists
 * because the cost was invisible until a CAP project bound 2000 rows and
 * waited 22 seconds, and "is it still linear?" deserves an answer anybody
 * can reproduce in one command. Until @abaplint/runtime 2.13.96 it was not:
 * on 2.13.93 the event roundtrip of 4000 rows took 28.4 s, and abap2UI5
 * installed fast paths of its own (node/srv/accelerate.mjs, now a no-op).
 * 2.13.96 is linear by itself - 2.0 s for the same roundtrip.
 *
 *   node node/tests-examples/rowsRoundtrip.bench.mjs              1000 2000 4000 rows
 *   node node/tests-examples/rowsRoundtrip.bench.mjs 500 8000     rows of your own
 *   node node/tests-examples/rowsRoundtrip.bench.mjs --delta 2000 the event carries one edited
 *        cell (MODEL: { MT_ROWS: { __delta: ... } }), as the frontend sends it
 *   node node/tests-examples/rowsRoundtrip.bench.mjs --als 2000   inside an AsyncLocalStorage
 *        context, as CAP runs a request; node flags go along to the measured
 *        process (node --experimental-async-context-frame <this file> --als)
 *
 * The app is ZCL_BENCH_ROWS below - `?app_start=zcl_bench_rows&rows=<n>`
 * fills a table of n rows (id, name, a packed price) bound to a sap.m.Table
 * and shows it again on every event, the shape the 22 seconds were measured
 * on. It is transpiled against node/downport and node/deps/open-abap-core on
 * the first run, like a host's own app (npm.README.md, "Your own apps"),
 * into a folder under os.tmpdir() that is reused while the source and the
 * transpiler stay the same.
 *
 * Every row count runs in a process of its own: the ABAP runtime is a
 * global, and a second measurement in the same process would start from the
 * first one's JIT. The roundtrips go through the express shim
 * as a host's would - the draft saved and restored, the model serialized -
 * but without an HTTP server, so the numbers are the framework's own:
 *   start   the first POST, ?app_start=...: the app fills its rows, the view
 *           and the whole table go out, the draft is written
 *   event   a POST with an event on that draft: the draft is read back (the
 *           XML parse), the app runs, view and model go out again
 *
 * Needs the transpiled tree (npm run downport && npm run auto_transpile).
 */
import { execFileSync, spawnSync } from "node:child_process";
import { createHash } from "node:crypto";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";
import zlib from "node:zlib";

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..", "..");
const OUT = path.join(ROOT, "node", "output");

const APP = `CLASS zcl_bench_rows DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.
    TYPES:
      BEGIN OF ty_s_row,
        id    TYPE i,
        name  TYPE string,
        price TYPE p LENGTH 9 DECIMALS 2,
      END OF ty_s_row.
    DATA mt_rows TYPE STANDARD TABLE OF ty_s_row WITH EMPTY KEY.
    DATA mv_rows TYPE i.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_bench_rows IMPLEMENTATION.
  METHOD z2ui5_if_app~main.
    DATA ls_get  TYPE z2ui5_if_client=>ty_s_get.
    DATA lv_rows TYPE string.
    DATA ls_row  TYPE ty_s_row.
    IF client->check_on_init( ).
      ls_get = client->get( ).
      FIND REGEX \`rows=(\\d+)\` IN ls_get-s_config-search SUBMATCHES lv_rows.
      mv_rows = lv_rows.
      DO mv_rows TIMES.
        ls_row-id    = sy-index.
        ls_row-name  = |row { sy-index }|.
        ls_row-price = sy-index / 100.
        APPEND ls_row TO mt_rows.
      ENDDO.
    ENDIF.
    client->view_display( |<mvc:View xmlns:mvc="sap.ui.core.mvc" xmlns="sap.m"><Page title="{ client->_bind( mv_rows ) } rows">| &&
      |<Table items="{ client->_bind( mt_rows ) }"><columns><Column><Text text="Id"/></Column><Column><Text text="Name"/></Column>| &&
      |<Column><Text text="Price"/></Column></columns><items><ColumnListItem><cells><Text text="\\{ID\\}"/><Text text="\\{NAME\\}"/>| &&
      |<Text text="\\{PRICE\\}"/></cells></ColumnListItem></items></Table></Page></mvc:View>| ).
  ENDMETHOD.
ENDCLASS.
`;

// --- the child: one process, one row count -------------------------------
if (process.argv[2] === "--child") {
  const [, , , rowsArg, appModule] = process.argv;
  const { initializeABAP } = await import(pathToFileURL(path.join(OUT, "init.mjs")).href);
  await initializeABAP();
  await import(pathToFileURL(appModule).href);
  const { cl_express_icf_shim } = await import(pathToFileURL(path.join(OUT, "cl_express_icf_shim.clas.mjs")).href);
  const search = `?app_start=zcl_bench_rows&rows=${rowsArg}`;
  // --als: every roundtrip inside an AsyncLocalStorage context, as CAP runs
  // a request (cds.context) - what that costs depends on the Node version
  const als = process.env.BENCH_ALS === "1" ? new (await import("node:async_hooks")).AsyncLocalStorage() : null;

  // one POST through the shim, express-shaped as host.mjs's handler hands it on
  const post = async (front, model) => {
    const body = Buffer.from(JSON.stringify({ value: { ...(model && { MODEL: model }), S_FRONT: { ORIGIN: "http://localhost", PATHNAME: "/", SEARCH: search, ...front } } }));
    const out = { status: 0, body: Buffer.alloc(0) };
    const res = {
      append() {},
      status(code) { out.status = code; return res; },
      send(buffer) { out.body = buffer; return res; },
    };
    const req = { method: "POST", url: "/", path: "/", headers: { "content-type": "application/json" }, body };
    const t0 = performance.now();
    const c0 = process.cpuUsage();
    await (als ? als.run({}, () => cl_express_icf_shim.run({ req, res, class: "ZCL_SICF" })) : cl_express_icf_shim.run({ req, res, class: "ZCL_SICF" }));
    const cpu = process.cpuUsage(c0);
    const ms = performance.now() - t0;
    if (out.status !== 200) throw new Error(`HTTP ${out.status}: ${out.body.toString("utf8").slice(0, 400)}`);
    return { ms, cpu: (cpu.user + cpu.system) / 1000, json: JSON.parse(out.body.toString("utf8")), bytes: out.body.length, gzip: zlib.gzipSync(out.body).length };
  };

  const start = await post({});
  if (start.json.S_FRONT?.APP !== "ZCL_BENCH_ROWS") throw new Error(`the app did not start: ${JSON.stringify(start.json).slice(0, 400)}`);
  // --delta: the event carries one edited cell, as the frontend sends it
  // (Lib.buildDeltaFromPaths) - the row delta the backend merges
  const delta = process.env.BENCH_DELTA === "1" ? { MT_ROWS: { __delta: { [String(Math.floor(Number(rowsArg) / 2))]: { NAME: "edited" } } } } : undefined;
  const event = await post({ ID: start.json.S_FRONT.ID, EVENT: "BENCH" }, delta);
  process.stdout.write(JSON.stringify({ start: start.ms, event: event.ms, startCpu: start.cpu, eventCpu: event.cpu,
    bytes: start.bytes, gzip: start.gzip, heap: process.memoryUsage().heapUsed }));
  process.exit(0);
}

// --- the parent -------------------------------------------------------------
const args = process.argv.slice(2);
const withAls = args.includes("--als");
const withDelta = args.includes("--delta");
const counts = args.filter((a) => /^\d+$/.test(a)).map(Number);
const ROWS = counts.length ? counts : [1000, 2000, 4000];

for (const need of ["node/output/init.mjs", "node/downport", "node/deps/open-abap-core"]) {
  if (!fs.existsSync(path.join(ROOT, need))) {
    console.error(`rowsRoundtrip.bench: ${need} is missing - build the tree first: npm run downport && npm run auto_transpile`);
    process.exit(1);
  }
}

/* The app, transpiled once per source and transpiler version. */
function transpiledApp() {
  const transpiler = JSON.parse(fs.readFileSync(path.join(ROOT, "node_modules/@abaplint/transpiler-cli/package.json"), "utf8")).version;
  const key = createHash("sha256").update(APP).update(transpiler).digest("hex").slice(0, 16);
  const dir = path.join(os.tmpdir(), `abap2ui5-bench-rows-${key}`);
  const module = path.join(dir, "zcl_bench_rows.clas.mjs");
  if (fs.existsSync(module)) return module;
  const work = fs.mkdtempSync(path.join(os.tmpdir(), "abap2ui5-bench-work-"));
  try {
    fs.mkdirSync(path.join(work, "abap"));
    fs.writeFileSync(path.join(work, "abap", "zcl_bench_rows.clas.abap"), APP);
    // lib folders resolve against the working directory - the repository
    fs.writeFileSync(path.join(work, "abap_transpile.json"), JSON.stringify({
      input_folder: path.join(work, "abap"),
      output_folder: path.join(work, "output"),
      libs: [
        { folder: "/node/downport", files: "/**/*.*" },
        { folder: "/node/deps/open-abap-core" },
      ],
      write_unit_tests: false,
      options: { ignoreSyntaxCheck: false, addFilenames: true, unknownTypes: "runtimeError" },
    }));
    console.log(`transpiling ZCL_BENCH_ROWS against node/downport (once, into ${dir}) ...`);
    execFileSync(process.execPath, [path.join(ROOT, "node_modules/@abaplint/transpiler-cli/abap_transpile"), path.join(work, "abap_transpile.json")],
      { cwd: ROOT, stdio: ["ignore", "ignore", "inherit"] });
    // the class alone: the rest of what the transpile wrote is a second copy
    // of the framework, and the class resolves everything through the runtime
    fs.mkdirSync(dir, { recursive: true });
    fs.copyFileSync(path.join(work, "output", "zcl_bench_rows.clas.mjs"), module);
    return module;
  } finally {
    fs.rmSync(work, { recursive: true, force: true });
  }
}

const app = transpiledApp();
const results = [];
const s = (ms) => (ms / 1000).toFixed(2).padStart(7) + " s";
console.log(`node ${process.version}, @abaplint/runtime ${JSON.parse(fs.readFileSync(path.join(ROOT, "node_modules/@abaplint/runtime/package.json"), "utf8")).version}`);
console.log(`${withAls ? "inside an AsyncLocalStorage context, " : ""}${withDelta ? "the event with one edited cell, " : ""}wall time (CPU time) of one roundtrip`);
console.log("  rows        start roundtrip         event roundtrip  response  gzipped");
for (const rows of ROWS) {
  // the parent's node flags go along (--experimental-async-context-frame, say)
  const run = spawnSync(process.execPath, [...process.execArgv, fileURLToPath(import.meta.url), "--child", String(rows), app],
    { cwd: ROOT, encoding: "utf8", maxBuffer: 16 * 1024 * 1024, env: { ...process.env, BENCH_ALS: withAls ? "1" : "", BENCH_DELTA: withDelta ? "1" : "" } });
  if (run.status !== 0) {
    console.error(`rows ${rows}: failed\n${run.stderr || run.stdout}`);
    process.exit(1);
  }
  const r = JSON.parse(run.stdout);
  results.push({ rows, ...r });
  console.log(`${String(rows).padStart(6)}  ${s(r.start)} (${s(r.startCpu).trim()})  ${s(r.event)} (${s(r.eventCpu).trim()})`
    + `  ${(r.bytes / 1024).toFixed(0).padStart(5)} KB  ${(r.gzip / 1024).toFixed(0).padStart(4)} KB`);
}
