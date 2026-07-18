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

  test("weightStateByValue maps unit-less weights to the 1000/2000 thresholds", () => {
    const { Formatter } = load();
    expect(Formatter.weightStateByValue("999")).toBe("Success");
    expect(Formatter.weightStateByValue("1500")).toBe("Warning");
    expect(Formatter.weightStateByValue("2000")).toBe("Error");
    expect(Formatter.weightStateByValue("abc")).toBe("None");
    expect(Formatter.weightStateByValue("-1")).toBe("None");
  });

  test("stockStatusState/-Icon map the stock status", () => {
    const { Formatter } = load();
    expect(Formatter.stockStatusState("Available")).toBe("Success");
    expect(Formatter.stockStatusState("Out of Stock")).toBe("Warning");
    expect(Formatter.stockStatusState("Discontinued")).toBe("Error");
    expect(Formatter.stockStatusState("Unknown")).toBe("None");
    expect(Formatter.stockStatusIcon("Available")).toBe("sap-icon://accept");
    expect(Formatter.stockStatusIcon("Out of Stock")).toBe("sap-icon://alert");
    expect(Formatter.stockStatusIcon("Discontinued")).toBe(
      "sap-icon://decline",
    );
    expect(Formatter.stockStatusIcon("Unknown")).toBeNull();
  });

  test("round2DP always renders two decimal places", () => {
    const { Formatter } = load();
    expect(Formatter.round2DP(3.14159)).toBe("3.14");
    expect(Formatter.round2DP(2)).toBe("2.00");
    expect(Formatter.round2DP("10.005")).toBe("10.01");
  });

  test("dimensions joins available components and appends the unit", () => {
    const { Formatter } = load();
    expect(Formatter.dimensions(10, 20, 30, "cm")).toBe("10 x 20 x 30 cm");
    expect(Formatter.dimensions(10, 0, 30, "cm")).toBe("10 x 30 cm");
    expect(Formatter.dimensions(0, 0, 0, "cm")).toBe("");
  });

  test("deliveryStatusState maps the delivery status", () => {
    const { Formatter } = load();
    expect(Formatter.deliveryStatusState("Shipped")).toBe("Success");
    expect(Formatter.deliveryStatusState("Failed Shipping")).toBe("Error");
    expect(Formatter.deliveryStatusState("Pending")).toBe("None");
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
