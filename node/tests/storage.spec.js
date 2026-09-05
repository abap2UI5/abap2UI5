// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");

// cc/Storage.js: reads a value out of browser storage into its `value`
// property and fires `finished` only when the stored value actually differs.
// The equality check has to be by VALUE - sap/ui/util/Storage JSON-round-trips
// what it holds, so a structured payload comes back as a fresh object every
// read and a reference comparison would fire on every render (round-trip
// loop).
function load({ stored = null, value = "", type = "local" } = {}) {
  const errors = [];
  const built = [];
  const { module: StorageControl } = loadModule("cc/Storage.js", {
    deps: {
      "sap/ui/core/Control": { extend: (_name, def) => def },
      "sap/ui/util/Storage": class {
        constructor(storageType, prefix) {
          built.push({ storageType, prefix });
          this.get = () => stored;
        }
        static Type = { local: "local", session: "session" };
      },
      "z2ui5/core/Lib": {
        logError: (msg) => errors.push(msg),
        renderInvisibleSpan() {},
      },
    },
  });

  const fired = [];
  const instance = Object.create(StorageControl);
  instance._pendingRead = true;
  instance._props = { type, prefix: "p", key: "k", value };
  instance.getProperty = (name) => instance._props[name];
  instance.setProperty = (name, v) => (instance._props[name] = v);
  instance.fireFinished = (payload) => fired.push(payload);

  return { instance, fired, errors, built };
}

test("a changed string value fires finished once", () => {
  const { instance, fired } = load({ stored: "new", value: "old" });

  instance.onAfterRendering();

  expect(fired).toHaveLength(1);
  expect(fired[0].value).toBe("new");
  expect(instance.getProperty("value")).toBe("new");
});

test("an unchanged string value does not fire", () => {
  const { instance, fired } = load({ stored: "same", value: "same" });

  instance.onAfterRendering();

  expect(fired).toHaveLength(0);
});

test("a structurally equal object does NOT fire - no round-trip loop", () => {
  // the exact regression: same content, different object identity, which is
  // what a JSON round-trip through the storage always produces
  const { instance, fired } = load({
    stored: { FIELD1: 1, FIELD2: "text" },
    value: { FIELD1: 1, FIELD2: "text" },
  });

  instance.onAfterRendering();

  expect(fired).toHaveLength(0);
});

test("key order is not significant", () => {
  const { instance, fired } = load({
    stored: { FIELD2: "text", FIELD1: 1 },
    value: { FIELD1: 1, FIELD2: "text" },
  });

  instance.onAfterRendering();

  expect(fired).toHaveLength(0);
});

test("a genuinely different object still fires", () => {
  const { instance, fired } = load({
    stored: { FIELD1: 2, FIELD2: "text" },
    value: { FIELD1: 1, FIELD2: "text" },
  });

  instance.onAfterRendering();

  expect(fired).toHaveLength(1);
  expect(fired[0].value).toEqual({ FIELD1: 2, FIELD2: "text" });
});

test("an extra key makes the objects different", () => {
  const { instance, fired } = load({
    stored: { FIELD1: 1, FIELD2: "text", FIELD3: true },
    value: { FIELD1: 1, FIELD2: "text" },
  });

  instance.onAfterRendering();

  expect(fired).toHaveLength(1);
});

test("nested tables compare by value", () => {
  const rows = () => ({ ROWS: [{ K: "a" }, { K: "b" }] });
  const { instance, fired } = load({ stored: rows(), value: rows() });

  instance.onAfterRendering();

  expect(fired).toHaveLength(0);
});

test("a differing nested row fires", () => {
  const { instance, fired } = load({
    stored: { ROWS: [{ K: "a" }, { K: "c" }] },
    value: { ROWS: [{ K: "a" }, { K: "b" }] },
  });

  instance.onAfterRendering();

  expect(fired).toHaveLength(1);
});

test("a shorter array is not equal", () => {
  const { instance, fired } = load({
    stored: { ROWS: [{ K: "a" }] },
    value: { ROWS: [{ K: "a" }, { K: "b" }] },
  });

  instance.onAfterRendering();

  expect(fired).toHaveLength(1);
});

test("an array is never equal to an object", () => {
  const { instance, fired } = load({ stored: [], value: {} });

  instance.onAfterRendering();

  expect(fired).toHaveLength(1);
});

test("a missing key does not fire and does not clobber the bound value", () => {
  // the regression: an app binding a STRUCTURE used to get the plain "" of an
  // absent key written into its model field, which the backend could not
  // parse back onto a deep target
  const bound = { FIELD1: 1, FIELD2: "text" };
  const { instance, fired } = load({ stored: null, value: bound });

  instance.onAfterRendering();

  expect(fired).toHaveLength(0);
  expect(instance.getProperty("value")).toEqual(bound);
});

test("a missing key leaves a bound STRING untouched too", () => {
  const { instance, fired } = load({ stored: null, value: "keep me" });

  instance.onAfterRendering();

  expect(fired).toHaveLength(0);
  expect(instance.getProperty("value")).toBe("keep me");
});

test("an empty string IS a stored value and is reported", () => {
  const { instance, fired } = load({ stored: "", value: "old" });

  instance.onAfterRendering();

  expect(fired).toHaveLength(1);
  expect(fired[0].value).toBe("");
});

test("the read runs only once per render", () => {
  const { instance, fired } = load({ stored: "new", value: "old" });

  instance.onAfterRendering();
  instance.onAfterRendering();

  expect(fired).toHaveLength(1);
});

// The type is free text from the backend, and `LOCAL` is how an ABAP
// constant spells it. Both halves of the pair resolve it the same way -
// the write side is STORE_DATA (node/tests/browserActions.spec.js).
test("the storage type is matched case-insensitively", () => {
  const { instance, built, errors } = load({ stored: "v", type: "LOCAL" });

  instance.onAfterRendering();

  expect(built).toEqual([{ storageType: "local", prefix: "p" }]);
  expect(errors).toEqual([]);
});

test("an unknown type is logged and read from the session store", () => {
  const { instance, built, errors } = load({ stored: "v", type: "cookie" });

  instance.onAfterRendering();

  expect(built[0].storageType).toBe("session");
  expect(errors.some((m) => m.includes("unknown type 'cookie'"))).toBe(true);
});
