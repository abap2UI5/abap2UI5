// @ts-check
// Benchmark: what does a data-only roundtrip cost in the frontend?
//
// On every CHECK_UPDATE_MODEL response (client->view_model_update( ) - the
// standard "refresh my data" call of every abap2UI5 app) the frontend
// currently builds a NEW JSONModel from the response data and calls
// view.setModel(), which destroys and recreates every binding of the view.
// The alternative is to reuse the existing model and call setData(), which
// keeps the bindings and only checks them for changes.
//
// This spec measures both approaches on a synthetic but representative
// view: an sap.m.Table (300 rows x 6 columns, 100 rendered via the default
// size limit, half the cells are Inputs) plus 20 bound scalar texts. Two
// data shapes are measured: every value changed, and a single cell changed
// (the common case - the backend resends a mostly identical model).
// It also times sap/ui/core/Element.closestTo on a deep table cell, the
// per-scroll-event cost driver of Server.onScrollCapture.
//
// Setup (not run in CI - reference material):
//   mkdir -p /tmp/ui5bench && cd /tmp/ui5bench && npm init -y && \
//     npm install @openui5/sap.ui.core @openui5/sap.m
//   BENCH_UI5_RESOURCES=/tmp/ui5bench/node_modules/@openui5/sap.ui.core/src:/tmp/ui5bench/node_modules/@openui5/sap.m/src \
//     npx playwright test -c node/playwright-bench.config.js
const { test } = require("@playwright/test");
const http = require("http");
const fs = require("fs");
const path = require("path");

const PORT = 4173;

const UI5_ROOTS = (
  process.env.BENCH_UI5_RESOURCES ||
  [
    "/tmp/ui5bench/node_modules/@openui5/sap.ui.core/src",
    "/tmp/ui5bench/node_modules/@openui5/sap.m/src",
  ].join(":")
).split(":");

const HTML = `<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <script id="sap-ui-bootstrap" src="/resources/sap-ui-core.js"
    data-sap-ui-libs="sap.m"
    data-sap-ui-async="true"
    data-sap-ui-compatVersion="edge"></script>
</head>
<body class="sapUiBody"><div id="content"></div></body>
</html>`;

const MIME = {
  ".js": "text/javascript",
  ".json": "application/json",
  ".css": "text/css",
  ".properties": "text/plain",
};

/** @type {http.Server} */
let server;

test.beforeAll(async () => {
  server = http.createServer((req, res) => {
    const url = (req.url || "/").split("?")[0];
    if (url === "/" || url === "/bench.html") {
      res.setHeader("content-type", "text/html");
      res.end(HTML);
      return;
    }
    if (url.startsWith("/resources/")) {
      const rel = url.slice("/resources/".length);
      for (const root of UI5_ROOTS) {
        const file = path.join(root, rel);
        if (fs.existsSync(file) && fs.statSync(file).isFile()) {
          res.setHeader(
            "content-type",
            MIME[path.extname(file)] || "application/octet-stream",
          );
          fs.createReadStream(file).pipe(res);
          return;
        }
      }
    }
    res.statusCode = 404;
    res.end();
  });
  await new Promise((resolve) => server.listen(PORT, () => resolve(null)));
});

test.afterAll(async () => {
  if (server) await new Promise((resolve) => server.close(() => resolve(null)));
});

test("model update: new JSONModel + setModel vs setData on existing model", async ({
  page,
}) => {
  test.setTimeout(300000);
  await page.goto(`http://localhost:${PORT}/bench.html`);

  const results = await page.evaluate(async () => {
    await new Promise((resolve) => sap.ui.getCore().attachInit(resolve));
    const [JSONModel, Table, Column, ColumnListItem, Text, Input, Page, App] =
      await new Promise((resolve) =>
        sap.ui.require(
          [
            "sap/ui/model/json/JSONModel",
            "sap/m/Table",
            "sap/m/Column",
            "sap/m/ColumnListItem",
            "sap/m/Text",
            "sap/m/Input",
            "sap/m/Page",
            "sap/m/App",
          ],
          (...mods) => resolve(mods),
        ),
      );

    const ROWS = 300;
    const COLS = 6;
    const SCALARS = 20;
    const WARMUP = 5;
    const N = 30;

    // Pre-build distinct datasets outside the timed region - in the real
    // flow the data arrives pre-parsed from the response JSON.
    function makeData(variant) {
      const TAB = [];
      for (let r = 0; r < ROWS; r++) {
        const row = {};
        for (let c = 0; c < COLS; c++) row["C" + c] = `v${variant}-${r}-${c}`;
        TAB.push(row);
      }
      const data = { TAB };
      for (let s = 0; s < SCALARS; s++) data["S" + s] = `sc${variant}-${s}`;
      return data;
    }
    const COUNT = WARMUP + N;
    // Every value differs from the previous iteration.
    const allChanged = Array.from({ length: COUNT }, (_, i) => makeData(i));
    // Structurally fresh objects, exactly one cell differs per iteration.
    const oneCell = Array.from({ length: COUNT }, (_, i) => {
      const data = makeData(0);
      data.TAB[10]["C2"] = `changed-${i}`;
      return data;
    });

    // Build the view: 20 bound scalars + the table.
    const table = new Table({
      columns: Array.from(
        { length: COLS },
        (_, c) => new Column({ header: new Text({ text: "C" + c }) }),
      ),
    });
    table.bindItems({
      path: "/TAB",
      template: new ColumnListItem({
        cells: Array.from({ length: COLS }, (_, c) =>
          c % 2 ? new Input({ value: `{C${c}}` }) : new Text({ text: `{C${c}}` }),
        ),
      }),
    });
    const scalars = Array.from(
      { length: SCALARS },
      (_, s) => new Text({ text: `{/S${s}}` }),
    );
    const page0 = new Page({ title: "bench", content: [...scalars, table] });
    new App({ pages: [page0] }).placeAt("content");

    const core = sap.ui.getCore();
    const flush = () => core.applyChanges();

    function stats(times) {
      times.sort((a, b) => a - b);
      const mid = Math.floor(times.length / 2);
      return {
        median: +times[mid].toFixed(2),
        mean: +(times.reduce((a, b) => a + b, 0) / times.length).toFixed(2),
        max: +times[times.length - 1].toFixed(2),
      };
    }

    // Mirrors View1._createViewModel + updateModelIfRequired today.
    function runSetModel(datasets) {
      const times = [];
      for (let i = 0; i < COUNT; i++) {
        const t0 = performance.now();
        const model = new JSONModel(datasets[i]);
        model.attachPropertyChange(() => {});
        page0.setModel(model);
        flush();
        const dt = performance.now() - t0;
        if (i >= WARMUP) times.push(dt);
      }
      return stats(times);
    }

    // The proposed reuse path.
    function runSetData(datasets) {
      const reused = new JSONModel(datasets[0]);
      reused.attachPropertyChange(() => {});
      page0.setModel(reused);
      flush();
      const times = [];
      for (let i = 0; i < COUNT; i++) {
        const t0 = performance.now();
        reused.setData(datasets[i]);
        flush();
        const dt = performance.now() - t0;
        if (i >= WARMUP) times.push(dt);
      }
      return stats(times);
    }

    const results = {};
    results.setModel_allChanged = runSetModel(allChanged);
    results.setData_allChanged = runSetData(allChanged);
    results.setModel_oneCell = runSetModel(oneCell);
    results.setData_oneCell = runSetData(oneCell);

    // Per-scroll-event cost of Server.onScrollCapture: Element.closestTo
    // on a deep DOM node inside the table.
    const Element = await new Promise((resolve) =>
      sap.ui.require(["sap/ui/core/Element"], resolve),
    );
    const cell = document.querySelector(".sapMListTbl input") ||
      document.querySelector("td");
    if (cell && Element.closestTo) {
      const M = 20000;
      const t0 = performance.now();
      for (let i = 0; i < M; i++) Element.closestTo(cell);
      results.closestTo_us_per_call = +(
        ((performance.now() - t0) / M) * 1000
      ).toFixed(2);
    }

    return results;
  });

  console.log("BENCH RESULTS (ms unless noted)");
  console.log(JSON.stringify(results, null, 2));
});
