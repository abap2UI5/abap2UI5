import { test } from "node:test";
import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { runInThisContext } from "node:vm";

// webapp/model/start.js as UI5 would load it, with sap.ui.define stubbed -
// what the page starts, decided before UI5 is involved. In this realm, so
// that the objects it returns compare with the ones below.
const source = readFileSync(
  new URL("../webapp/model/start.js", import.meta.url),
  "utf8",
);
let start;
globalThis.sap = { ui: { define: (_deps, factory) => (start = factory()) } };
runInThisContext(source, { filename: "webapp/model/start.js" });
delete globalThis.sap;

const DEFAULT = "Z2UI5_CL_UI5_APP_START";

test("nothing given: the default app, no params", () => {
  assert.deepEqual(start(undefined, "", DEFAULT), {
    app: DEFAULT,
    params: null,
  });
});

test("standalone: app_start of the URL, upper-cased and trimmed", () => {
  assert.deepEqual(
    start(undefined, "?sap-client=100&app_start=%20z2ui5_cl_my_app", DEFAULT),
    { app: "Z2UI5_CL_MY_APP", params: null },
  );
});

test("launchpad: app_start of the intent, the rest as params", () => {
  const componentData = {
    startupParameters: {
      app_start: ["z2ui5_cl_my_app"],
      matnr: ["4711"],
      plant: ["1000", "2000"],
    },
  };
  assert.deepEqual(start(componentData, "", DEFAULT), {
    app: "Z2UI5_CL_MY_APP",
    params: { matnr: ["4711"], plant: ["1000", "2000"] },
  });
});

test("launchpad: the intent wins over the URL", () => {
  const componentData = { startupParameters: { app_start: ["Z_FROM_FLP"] } };
  assert.equal(
    start(componentData, "?app_start=Z_FROM_URL", DEFAULT).app,
    "Z_FROM_FLP",
  );
});

test("launchpad without app_start: the URL, then the default", () => {
  const componentData = { startupParameters: { matnr: ["4711"] } };
  assert.deepEqual(start(componentData, "", DEFAULT), {
    app: DEFAULT,
    params: { matnr: ["4711"] },
  });
  assert.equal(start(componentData, "?app_start=z_x", DEFAULT).app, "Z_X");
});

test("an empty app_start is none", () => {
  assert.equal(start(undefined, "?app_start=", DEFAULT).app, DEFAULT);
  assert.equal(
    start({ startupParameters: { app_start: [""] } }, "", DEFAULT).app,
    DEFAULT,
  );
});
