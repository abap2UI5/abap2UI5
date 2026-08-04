// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");

// Tests the curated formatter module app/webapp/model/formatter.js (loaded
// via a stubbed sap.ui.define). The module backs
// core:require="{Formatter: 'z2ui5/model/formatter'}" and the
// z2ui5.Formatter global referenced by XML binding strings, and OWNS the
// date-helper implementations that z2ui5/Util re-exports as its legacy
// alias - everything here is a public contract.

function load() {
  const IconPool = {
    getIconInfo: (uri) =>
      uri === "sap-icon://unknown"
        ? null
        : { fontFamily: "SAP-icons", content: "GLYPH" },
  };
  const { module: Formatter } = loadModule("model/formatter.js", {
    deps: { "sap/ui/core/IconPool": IconPool },
  });
  const { module: Util } = loadModule("Util.js", {
    deps: { "z2ui5/model/formatter": Formatter },
  });
  return { Formatter, Util };
}

test.describe("Formatter module", () => {
  // The export surface is the contract, in both directions. Adding a function
  // moves a decision out of ABAP; removing one breaks the apps that bind it.
  // The module header states the three admission criteria and
  // .github/scripts/formatter-scope-gate.mjs enforces the two that a machine
  // can check - this assertion is the same list seen from the runtime, so a
  // silent addition fails here even in a change the gate's path filter misses.
  //
  // The functions that were shipped and then REMOVED, so nobody re-adds them:
  // weightState / weightStateByValue (parseFloat + KG conversion + Success/
  // Warning/Error thresholds) and the demo kit status pack (round2DP,
  // dimensions, stockStatusState, stockStatusIcon, deliveryStatusState).
  // Rounding a number, joining dimensions and mapping a business status to a
  // ValueState are all things ABAP can finish - abap2UI5 is a thin frontend,
  // so the app computes them in model_init and the view binds the result
  // (state="{STATUS_STATE}").
  test("the curated module exports exactly the justified set", () => {
    const { Formatter } = load();
    expect(Object.keys(Formatter).sort()).toEqual([
      "DateAbapDateTimeToDateObject",
      "DateAbapDateToDateObject",
      "DateCreateObject",
      "expandInlineIcons",
    ]);
  });

  test("expandInlineIcons replaces %%icon:...%% with inline-icon markup", () => {
    const { Formatter } = load();
    expect(
      Formatter.expandInlineIcons("A %%icon:sap-icon://sys-enter-2%% B"),
    ).toBe(
      'A <span class="sapMMsgStripInlineIcon" style="font-family:\'SAP-icons\'">GLYPH</span> B',
    );
  });

  test("expandInlineIcons passes plain text through and drops unknown/empty", () => {
    const { Formatter } = load();
    expect(Formatter.expandInlineIcons("just text")).toBe("just text");
    expect(Formatter.expandInlineIcons("")).toBe("");
    expect(Formatter.expandInlineIcons(null)).toBe("");
    expect(Formatter.expandInlineIcons("x %%icon:sap-icon://unknown%% y")).toBe(
      "x  y",
    );
  });

  test("the date helpers map an empty value to null, not to an Invalid Date", () => {
    const { Formatter } = load();
    // an Invalid Date is truthy, so a control that only checks for presence
    // would accept it and throw much later (sap.ui.unified Month) - a missing
    // optional date has to stay missing
    expect(Formatter.DateCreateObject("")).toBeNull();
    expect(Formatter.DateCreateObject(null)).toBeNull();
    expect(Formatter.DateCreateObject(undefined)).toBeNull();
    expect(Formatter.DateAbapDateToDateObject("")).toBeNull();
    expect(Formatter.DateAbapDateTimeToDateObject("")).toBeNull();
    expect(Formatter.DateAbapDateTimeToDateObject("", "134501")).toBeNull();
  });

  test("the date helpers still convert a filled value", () => {
    const { Formatter } = load();
    const d = Formatter.DateCreateObject("2026-07-02T13:45:01Z");
    expect(isNaN(d.getTime())).toBe(false);
    expect(d.toISOString()).toBe("2026-07-02T13:45:01.000Z");
    expect(Formatter.DateAbapDateToDateObject("20260702").getDate()).toBe(2);
    expect(
      Formatter.DateAbapDateTimeToDateObject("20260702", "134501").getHours(),
    ).toBe(13);
  });

  test("z2ui5/Util re-exports the date helpers as the legacy alias", () => {
    const { Formatter, Util } = load();
    expect(Util.DateCreateObject).toBe(Formatter.DateCreateObject);
    expect(Util.DateAbapDateToDateObject).toBe(
      Formatter.DateAbapDateToDateObject,
    );
    expect(Util.DateAbapDateTimeToDateObject).toBe(
      Formatter.DateAbapDateTimeToDateObject,
    );
    // the alias exposes exactly the original contract, nothing more
    expect(Object.keys(Util).sort()).toEqual([
      "DateAbapDateTimeToDateObject",
      "DateAbapDateToDateObject",
      "DateCreateObject",
    ]);
  });
});
