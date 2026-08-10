// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");
const { loadLib } = require("./loadLibModule");

// cc/SmartMultiInputExt.js: invisible companion of a SmartMultiInput that
// mirrors token updates plus the select-option style range data. Under test:
// the inputInitialized promise machinery (inner controls are created lazily;
// exit must resolve pending waiters so nothing hangs), the ABAP-to-camelCase
// key normalization of setRangeData, the destroyed-guard after its await,
// and the range enrichment in onTokenUpdate.
function load({ input } = {}) {
  const { Lib, sandbox } = loadLib();
  const errors = [];
  Lib.logError = (m) => errors.push(m);

  const { module: SmartDef } = loadModule("cc/SmartMultiInputExt.js", {
    deps: {
      "sap/ui/core/Control": { extend: (_name, def) => def },
      "z2ui5/core/Lib": Lib,
      "z2ui5/core/ViewSlots": { byIdOfOwner: () => input ?? null },
    },
  });

  function makeInstance() {
    const inst = Object.create(SmartDef);
    inst._props = {
      multiInputId: "smart",
      addedTokens: null,
      removedTokens: null,
      rangeData: [],
      checkInit: false,
    };
    inst.getProperty = (k) => inst._props[k];
    inst.setProperty = (k, v) => (inst._props[k] = v);
    inst.changes = 0;
    inst.fireChange = () => inst.changes++;
    inst._destroyed = false;
    inst.isDestroyed = () => inst._destroyed;
    inst.init();
    return inst;
  }

  return { makeInstance, errors, state: sandbox.z2ui5 };
}

// A token stub with the data() get/set convention of sap.ui.core.Element.
function tokenStub(text) {
  const custom = {};
  return {
    text,
    setText(t) {
      this.text = t;
    },
    getText() {
      return this.text;
    },
    data(key, value) {
      if (arguments.length === 1) return custom[key];
      custom[key] = value;
      return this;
    },
  };
}

// The smart input as setRangeData consumes it.
function smartInputStub(tokens = []) {
  return {
    tokens,
    rangeDataCalls: [],
    setRangeData(data) {
      this.rangeDataCalls.push(data);
    },
    getTokens() {
      return this.tokens;
    },
  };
}

test("init registers the onAfterRendering hook, exit removes it", () => {
  const { makeInstance, state } = load();
  const inst = makeInstance();

  expect(state.onAfterRendering).toHaveLength(1);

  inst.exit();
  expect(state.onAfterRendering).toHaveLength(0);
});

test("setControl attaches both handlers exactly once", () => {
  const attached = { tokenUpdate: 0, innerCreated: 0 };
  const { makeInstance } = load({
    input: {
      attachTokenUpdate: () => attached.tokenUpdate++,
      attachInnerControlsCreated: () => attached.innerCreated++,
    },
  });
  const inst = makeInstance();

  inst.setControl();
  inst.setControl();

  expect(inst._props.checkInit).toBe(true);
  expect(attached).toEqual({ tokenUpdate: 1, innerCreated: 1 });
});

test("a throwing attach is logged, never thrown", () => {
  const { makeInstance, errors } = load({
    input: {
      attachTokenUpdate() {
        throw new Error("boom");
      },
    },
  });
  makeInstance().setControl();

  expect(errors.some((m) => m.includes("setControl: setup failed"))).toBe(true);
});

test("inputInitialized resolves once the inner controls exist", async () => {
  const { makeInstance } = load();
  const inst = makeInstance();
  const source = smartInputStub();

  const waiter = inst.inputInitialized();
  inst.onInnerControlsCreated({ getSource: () => source });

  expect(await waiter).toBe(source);
  // after the flag is set, new waiters resolve immediately
  expect(await inst.inputInitialized()).toBe(source);
});

test("exit resolves pending waiters with null so nothing hangs", async () => {
  const { makeInstance } = load();
  const inst = makeInstance();

  const waiter = inst.inputInitialized();
  inst.exit();

  expect(await waiter).toBe(null);
});

test("setRangeData normalizes ABAP keys to camelCase, keyField preserved", async () => {
  const { makeInstance } = load();
  const inst = makeInstance();
  const input = smartInputStub([tokenStub("old")]);
  inst.onInnerControlsCreated({ getSource: () => input });

  await inst.setRangeData([
    {
      KEYFIELD: "PRICE",
      OPERATION: "BT",
      VALUE1: "10",
      TOKENTEXT: "10...20",
      TOKENLONGKEY: "range_0",
    },
  ]);

  expect(input.rangeDataCalls[0]).toEqual([
    {
      keyField: "PRICE",
      operation: "BT",
      value1: "10",
      tokentext: "10...20",
      tokenlongkey: "range_0",
    },
  ]);
  // token caption + long key are applied explicitly (setRangeData does no
  // recalculation)
  expect(input.tokens[0].getText()).toBe("10...20");
  expect(input.tokens[0].data("longKey")).toBe("range_0");
  expect(input.tokens[0].data("range")).toBe(null);
  expect(inst._props.rangeData).toHaveLength(1);
});

test("setRangeData after destroy touches neither input nor tokens", async () => {
  const { makeInstance } = load();
  const inst = makeInstance();
  const input = smartInputStub();

  const pending = inst.setRangeData([{ KEYFIELD: "X" }]);
  inst._destroyed = true;
  inst.onInnerControlsCreated({ getSource: () => input });
  await pending;

  expect(input.rangeDataCalls).toHaveLength(0);
});

test("a throwing input.setRangeData is logged, never thrown", async () => {
  const { makeInstance, errors } = load();
  const inst = makeInstance();
  const input = {
    setRangeData() {
      throw new Error("invalid range");
    },
    getTokens: () => [],
  };
  inst.onInnerControlsCreated({ getSource: () => input });

  await inst.setRangeData([{ KEYFIELD: "X" }]);

  expect(errors.some((m) => m.includes("setRangeData failed"))).toBe(true);
});

test("onTokenUpdate enriches the ranges with token text and long key", () => {
  const { makeInstance } = load();
  const inst = makeInstance();
  const tokenA = tokenStub("=A");
  tokenA.data("longKey", "range_0");
  const source = {
    getTokens: () => [tokenA],
    getRangeData: () => [{ operation: "EQ", value1: "A" }],
  };

  inst.onTokenUpdate({
    getParameter: (name) => {
      if (name === "type") return "added";
      if (name === "addedTokens") {
        return [{ getKey: () => "range_0", getText: () => "=A" }];
      }
      return null;
    },
    getSource: () => source,
  });

  expect(inst._props.addedTokens).toEqual([{ KEY: "range_0", TEXT: "=A" }]);
  expect(inst._props.rangeData).toEqual([
    { operation: "EQ", value1: "A", tokenText: "=A", tokenLongKey: "range_0" },
  ]);
  expect(inst.changes).toBe(1);
});

test("a range without a matching token gets empty caption fields", () => {
  const { makeInstance } = load();
  const inst = makeInstance();
  const source = {
    getTokens: () => [],
    getRangeData: () => [{ operation: "EQ" }],
  };

  inst.onTokenUpdate({
    getParameter: (name) => (name === "type" ? "added" : []),
    getSource: () => source,
  });

  expect(inst._props.rangeData[0].tokenText).toBe("");
  expect(inst._props.rangeData[0].tokenLongKey).toBeUndefined();
});
