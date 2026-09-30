// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");

// Tests the clipboard module app/webapp/model/clipboard.js (loaded via a
// stubbed sap.ui.define). The module backs
// core:require="{Clipboard: 'z2ui5/model/clipboard'}" and
// <plugins:CopyProvider extractData="Clipboard.extractData"/> - the export
// name and the two CustomData keys are a public contract.

// formatMessage stand-in: positional {n} placeholders, enough for the module
// (the real sap/base/strings/formatMessage also handles quoting)
function formatMessage(sPattern, aValues) {
  return sPattern.replace(/\{(\d+)\}/g, (m, i) => String(aValues[Number(i)]));
}

function load() {
  const { module: Clipboard } = loadModule("model/clipboard.js", {
    deps: { "sap/base/strings/formatMessage": formatMessage },
  });
  return { Clipboard };
}

// a column carrying app:bindings / app:template CustomData
function column(mData) {
  return { data: (sKey) => mData[sKey] };
}

// a binding context over a plain row object
function context(oRow) {
  return { getProperty: (sPath) => oRow[sPath] };
}

test.describe("Clipboard module", () => {
  // Same contract as the formatter module: the export surface is gated by
  // .github/scripts/formatter-scope-gate.mjs and seen here from the runtime.
  test("the module exports exactly the justified set", () => {
    const { Clipboard } = load();
    expect(Object.keys(Clipboard).sort()).toEqual(["extractData"]);
  });

  test("extractData copies the paths the column declares, one cell each", () => {
    const { Clipboard } = load();
    const oCol = column({ bindings: "NAME,PRODUCT_ID" });
    const oCtx = context({ NAME: "Notebook", PRODUCT_ID: "HT-1000" });
    expect(Clipboard.extractData(oCtx, oCol, false)).toEqual([
      "Notebook",
      "HT-1000",
    ]);
  });

  test("extractData adds the html variant from the column template", () => {
    const { Clipboard } = load();
    const oCtx = context({ NAME: "Notebook", PRODUCT_ID: "HT-1000" });
    expect(
      Clipboard.extractData(
        oCtx,
        column({ bindings: "NAME,PRODUCT_ID", template: "{0} ({1})" }),
        true,
      ),
    ).toEqual({
      text: ["Notebook", "HT-1000"],
      html: "Notebook (HT-1000)",
    });
    // without a template the first value stands for the cell, as upstream
    expect(
      Clipboard.extractData(oCtx, column({ bindings: "NAME" }), true),
    ).toEqual({ text: ["Notebook"], html: "Notebook" });
  });

  test("a column without app:bindings is skipped", () => {
    const { Clipboard } = load();
    const oCtx = context({ NAME: "Notebook" });
    // undefined is the CopyProvider's "do not copy this column"
    expect(Clipboard.extractData(oCtx, column({}), false)).toBeUndefined();
    expect(Clipboard.extractData(oCtx, null, false)).toBeUndefined();
  });

  test("a missing field becomes an empty cell, not the word undefined", () => {
    const { Clipboard } = load();
    const oCtx = context({ NAME: null });
    expect(
      Clipboard.extractData(oCtx, column({ bindings: "NAME, PRICE" }), false),
    ).toEqual(["", ""]);
  });

  test("an unbound sap.m.Table row is read through its binding context", () => {
    const { Clipboard } = load();
    const oRow = {
      getBindingContext: () => context({ NAME: "Notebook" }),
    };
    expect(
      Clipboard.extractData(oRow, column({ bindings: "NAME" }), false),
    ).toEqual(["Notebook"]);
    const oBare = { getBindingContext: () => undefined };
    expect(
      Clipboard.extractData(oBare, column({ bindings: "NAME" }), false),
    ).toEqual([""]);
  });
});
