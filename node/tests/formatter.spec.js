// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");

// Tests the curated formatter module app/webapp/Formatter.js (loaded via a
// stubbed sap.ui.define, with the real z2ui5/Util as its dependency). The
// module backs the z2ui5.Formatter global referenced by XML binding
// strings - functions here are a public contract, like z2ui5.Util.

function load() {
  const { module: Util } = loadModule("Util.js");
  const { module } = loadModule("Formatter.js", {
    deps: { "z2ui5/Util": Util },
  });
  return { Formatter: module, Util };
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

  test("re-exports the z2ui5.Util date helpers unchanged", () => {
    const { Formatter, Util } = load();
    expect(Formatter.DateCreateObject).toBe(Util.DateCreateObject);
    expect(Formatter.DateAbapDateToDateObject).toBe(
      Util.DateAbapDateToDateObject,
    );
    expect(Formatter.DateAbapDateTimeToDateObject).toBe(
      Util.DateAbapDateTimeToDateObject,
    );
  });
});
