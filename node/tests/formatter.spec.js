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
  const { module: Formatter } = loadModule("model/formatter.js");
  const { module: Util } = loadModule("Util.js", {
    deps: { "z2ui5/model/formatter": Formatter },
  });
  return { Formatter, Util };
}

test.describe("Formatter module", () => {
  test("weightState maps KG weights to the ValueState thresholds", () => {
    const { Formatter } = load();
    expect(Formatter.weightState("0.2", "KG")).toBe("Success");
    expect(Formatter.weightState("4.5", "KG")).toBe("Warning");
    expect(Formatter.weightState("21", "KG")).toBe("Error");
  });

  test("weightState converts G and guards NaN/negative", () => {
    const { Formatter } = load();
    expect(Formatter.weightState("800", "G")).toBe("Success"); // 0.8 kg
    expect(Formatter.weightState("4500", "G")).toBe("Warning"); // 4.5 kg
    expect(Formatter.weightState("abc", "KG")).toBe("None");
    expect(Formatter.weightState("-1", "KG")).toBe("None");
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
