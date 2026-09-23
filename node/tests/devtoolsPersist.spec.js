// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");

// Tests the real implementation shipped in app/webapp/devtools/Persist.js
// - the developer tools' one sessionStorage access. Three modules used to
// carry their own copy of the same guarded read and write; what is pinned
// is the contract they all rely on: a storage that throws or is missing
// answers the default and never the caller.

function loadPersist({ storage = {}, throwing = false, absent = false } = {}) {
  const fail = () => {
    throw new Error("SecurityError");
  };
  const sessionStorage = throwing
    ? { getItem: fail, setItem: fail, removeItem: fail }
    : {
        getItem: (k) => (k in storage ? storage[k] : null),
        setItem: (k, v) => {
          storage[k] = v;
        },
        removeItem: (k) => {
          delete storage[k];
        },
      };
  const { module } = loadModule("devtools/Persist.js", {
    sandbox: { window: absent ? {} : { sessionStorage } },
  });
  return { Persist: module, storage };
}

test.describe("strings", () => {
  test("reads back what was written and empty for nothing", () => {
    const { Persist } = loadPersist();
    expect(Persist.read("k")).toBe("");
    Persist.write("k", "HISTORY");
    expect(Persist.read("k")).toBe("HISTORY");
    Persist.remove("k");
    expect(Persist.read("k")).toBe("");
  });
});

test.describe("flags", () => {
  test("a switch is stored as the ABAP flag and absent when off", () => {
    const { Persist, storage } = loadPersist();
    expect(Persist.readFlag("f")).toBe(false);
    Persist.writeFlag("f", true);
    expect(storage.f).toBe("X");
    expect(Persist.readFlag("f")).toBe(true);
    Persist.writeFlag("f", false);
    expect("f" in storage).toBe(false);
    expect(Persist.readFlag("f")).toBe(false);
  });

  test("anything but the flag reads as off", () => {
    const { Persist } = loadPersist({ storage: { f: "true" } });
    expect(Persist.readFlag("f")).toBe(false);
  });
});

test.describe("lists carried across a reload", () => {
  test("a stored list is consumed on the first read", () => {
    const { Persist, storage } = loadPersist();
    Persist.saveList("l", [{ seq: 1 }, { seq: 2 }]);
    expect(JSON.parse(storage.l)).toEqual([{ seq: 1 }, { seq: 2 }]);
    expect(Persist.takeList("l")).toEqual([{ seq: 1 }, { seq: 2 }]);
    // consumed: a later load without a fresh write starts empty
    expect("l" in storage).toBe(false);
    expect(Persist.takeList("l")).toEqual([]);
  });

  test("an empty list writes nothing", () => {
    const { Persist, storage } = loadPersist();
    Persist.saveList("l", []);
    expect("l" in storage).toBe(false);
  });

  test("a stored text that is not a JSON array reads as nothing", () => {
    expect(loadPersist({ storage: { l: "{oops" } }).Persist.takeList("l")).toEqual(
      [],
    );
    expect(
      loadPersist({ storage: { l: '{"a":1}' } }).Persist.takeList("l"),
    ).toEqual([]);
  });
});

// sessionStorage throws in some embedded and privacy configurations, and
// a diagnostic tool must never be the thing that breaks the app.
test.describe("an unavailable storage", () => {
  test("a throwing storage answers the defaults and swallows the writes", () => {
    const { Persist } = loadPersist({ throwing: true });
    expect(Persist.read("k")).toBe("");
    expect(Persist.readFlag("f")).toBe(false);
    expect(Persist.takeList("l")).toEqual([]);
    expect(() => {
      Persist.write("k", "v");
      Persist.remove("k");
      Persist.writeFlag("f", true);
      Persist.saveList("l", [1]);
    }).not.toThrow();
  });

  test("a window without sessionStorage behaves the same", () => {
    const { Persist } = loadPersist({ absent: true });
    expect(Persist.read("k")).toBe("");
    expect(Persist.readFlag("f")).toBe(false);
    expect(Persist.takeList("l")).toEqual([]);
    expect(() => Persist.writeFlag("f", true)).not.toThrow();
  });
});
