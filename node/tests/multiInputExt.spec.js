// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");
const { loadLib } = require("./loadLibModule");

// cc/MultiInputExt.js: invisible companion of a sap.m.MultiInput that
// mirrors token updates into bindable properties (via the real
// Lib.applyTokenUpdate) and installs the free-text-to-token validator.
// Under test: the register/claim lifecycle, both token update directions,
// the validator, and the "log, never throw" guard around the attach calls.
function load({ input } = {}) {
  const { Lib, sandbox } = loadLib();
  const errors = [];
  Lib.logError = (m) => errors.push(m);

  class Token {
    constructor({ key, text }) {
      this.key = key;
      this.text = text;
    }
  }

  const { module: MultiInputExtDef } = loadModule("cc/MultiInputExt.js", {
    deps: {
      "sap/ui/core/Control": { extend: (_name, def) => def },
      "sap/m/Token": Token,
      "z2ui5/core/Lib": Lib,
      "z2ui5/core/ViewSlots": { byIdOfOwner: () => input ?? null },
    },
  });

  function makeInstance() {
    const inst = Object.create(MultiInputExtDef);
    inst._props = {
      MultiInputId: "multi",
      MultiInputName: "",
      addedTokens: null,
      removedTokens: null,
      checkInit: false,
    };
    inst.getProperty = (k) => inst._props[k];
    inst.setProperty = (k, v) => (inst._props[k] = v);
    inst.changes = 0;
    inst.fireChange = () => inst.changes++;
    return inst;
  }

  return { makeInstance, errors, state: sandbox.z2ui5, Token };
}

// A MultiInput stub recording the attached handler and validators.
function inputStub() {
  return {
    handlers: [],
    validators: [],
    attachTokenUpdate(fn) {
      this.handlers.push(fn);
    },
    addValidator(fn) {
      this.validators.push(fn);
    },
  };
}

const token = (key, text) => ({ getKey: () => key, getText: () => text });

const tokenUpdateEvent = (type, tokens) => ({
  getParameter: (name) => {
    if (name === "type") return type;
    if (name === (type === "removed" ? "removedTokens" : "addedTokens")) {
      return tokens;
    }
    return null;
  },
});

test("init registers the onAfterRendering hook, exit removes it", () => {
  const { makeInstance, state } = load();
  const inst = makeInstance();

  inst.init();
  expect(state.onAfterRendering).toHaveLength(1);

  inst.exit();
  expect(state.onAfterRendering).toHaveLength(0);
});

test("setControl attaches handler + validator exactly once", () => {
  const target = inputStub();
  const { makeInstance } = load({ input: target });
  const inst = makeInstance();
  inst.init();

  inst.setControl();
  inst.setControl();

  expect(inst._props.checkInit).toBe(true);
  expect(target.handlers).toHaveLength(1);
  expect(target.validators).toHaveLength(1);
});

test("the validator turns free text into a Token with key = text", () => {
  const target = inputStub();
  const { makeInstance, Token } = load({ input: target });
  const inst = makeInstance();
  inst.setControl();

  const created = target.validators[0]({ text: "blue" });

  expect(created).toBeInstanceOf(Token);
  expect(created.key).toBe("blue");
  expect(created.text).toBe("blue");
});

test("an unresolved target leaves the claim open", () => {
  const { makeInstance } = load({ input: null });
  const inst = makeInstance();

  inst.setControl();

  expect(inst._props.checkInit).toBe(false);
});

test("a throwing attach is logged, never thrown", () => {
  const { makeInstance, errors } = load({
    input: {
      attachTokenUpdate() {
        throw new Error("not a MultiInput");
      },
    },
  });
  makeInstance().setControl();

  expect(errors.some((m) => m.includes("setControl: setup failed"))).toBe(true);
});

test("added tokens are mirrored as {KEY, TEXT} and fire change", () => {
  const { makeInstance } = load();
  const inst = makeInstance();

  inst.onTokenUpdate(
    tokenUpdateEvent("added", [token("K1", "One"), token("K2", "Two")]),
  );

  expect(inst._props.addedTokens).toEqual([
    { KEY: "K1", TEXT: "One" },
    { KEY: "K2", TEXT: "Two" },
  ]);
  expect(inst._props.removedTokens).toEqual([]);
  expect(inst.changes).toBe(1);
});

test("removed tokens land in removedTokens, addedTokens is reset", () => {
  const { makeInstance } = load();
  const inst = makeInstance();

  inst.onTokenUpdate(tokenUpdateEvent("removed", [token("K1", "One")]));

  expect(inst._props.addedTokens).toEqual([]);
  expect(inst._props.removedTokens).toEqual([{ KEY: "K1", TEXT: "One" }]);
  expect(inst.changes).toBe(1);
});
