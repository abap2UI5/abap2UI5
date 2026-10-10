// @ts-check
// The libraries a backend view names arrive as their PRELOAD BUNDLES. The
// manifest declares sap.m and sap.ui.core; every other library a view uses
// (sap.ui.table here) used to be resolved by UI5's XMLTemplateProcessor
// control by control, one module request each - a view with one
// sap.ui.table.Table was 37 requests at 40 ms round-trip time. The frontend
// loads the library first now (core/Env.js loadViewLibraries, called by
// actions/Slots before every view build), and the browser asks for the
// library's library-preload.js once instead.
//
// The fixture app is node/srv/zcl_tst_table.clas.abap, copied into the
// transpiled backend by `npm run auto_transpile`. Loaded via ./fixtures,
// so the page boots the pinned UI5 build of playwright.config.js (offline
// runs: UI5_PINNED_RESOURCES, which has to be a BUILT tree for this spec -
// a source-only tree has no bundles to ask for).
const { test, expect } = require("./fixtures");

test("a view's library comes as its preload bundle, not module by module", async ({
  page,
}) => {
  /** @type {string[]} */
  const tableRequests = [];
  page.on("request", (request) => {
    const url = request.url();
    if (url.includes("/sap/ui/table/")) tableRequests.push(url);
  });

  await page.goto("/?app_start=zcl_tst_table");
  // the rows are the column template cloned - found by their text
  await expect(page.getByText("Row 3")).toBeVisible({ timeout: 30000 });

  const preloads = tableRequests.filter((url) =>
    /\/sap\/ui\/table\/library-preload\.js(\?|$)/.test(url),
  );
  // the library's modules, one request each - what the bundle replaces;
  // library.js itself is what the loader asks for after the bundle
  const modules = tableRequests.filter(
    (url) =>
      /\.js(\?|$)/.test(url) &&
      !/\/library(-preload)?\.js(\?|$)/.test(url),
  );
  console.log(
    `sap.ui.table: ${tableRequests.length} request(s), ${preloads.length} bundle(s), ${modules.length} module(s)`,
  );
  expect(preloads).toHaveLength(1);
  expect(modules).toEqual([]);
});
