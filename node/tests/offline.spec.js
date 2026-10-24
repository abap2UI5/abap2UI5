// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");
const { specContext } = require("./loadLibModule");

// The offline queue's store (core/Offline.js): which events may wait, what
// is kept under which key, and that a storage the browser refuses costs the
// queue, never the app. The sending is Server.replayOffline's and is driven
// end to end by the offline-queue e2e spec.

function memoryStorage({ broken = false } = {}) {
  const data = new Map();
  return {
    data,
    getItem: (k) => {
      if (broken) throw new Error("denied");
      return data.has(k) ? data.get(k) : null;
    },
    setItem: (k, v) => {
      if (broken) throw new Error("quota");
      data.set(k, String(v));
    },
    removeItem: (k) => data.delete(k),
  };
}

function load(storage = memoryStorage()) {
  const listeners = [];
  const window = {
    localStorage: storage,
    addEventListener: (type, fn) => listeners.push({ type, fn }),
    removeEventListener: (type, fn) => {
      const i = listeners.findIndex((l) => l.type === type && l.fn === fn);
      if (i >= 0) listeners.splice(i, 1);
    },
  };
  const errors = [];
  const { module: Offline } = loadModule("core/Offline.js", {
    deps: { "z2ui5/core/Lib": { logError: (m) => errors.push(m) } },
    sandbox: { window },
  });
  const ctx = specContext({ url: "/sap/bc/z2ui5" });
  return { Offline, ctx, storage, listeners, errors };
}

const body = (event) => ({ S_FRONT: { ID: "d1", EVENT: event } });

test("only the events the app named may queue", () => {
  const { Offline, ctx } = load();
  expect(Offline.canQueue(ctx, body("SAVE"))).toBe(false);
  Offline.configure(ctx, ["SAVE", ""], "kept", () => {});
  expect(Offline.canQueue(ctx, body("SAVE"))).toBe(true);
  expect(Offline.canQueue(ctx, body("OTHER"))).toBe(false);
  expect(Offline.canQueue(ctx, {})).toBe(false);
});

test("kept bodies wait in order under the endpoint, and take empties the store", () => {
  const { Offline, ctx, storage } = load();
  expect(Offline.queue(ctx, body("SAVE"))).toBe(1);
  expect(Offline.queue(ctx, body("SAVE"))).toBe(2);
  expect([...storage.data.keys()]).toEqual(["z2ui5-offline:/sap/bc/z2ui5"]);
  const taken = Offline.take(ctx);
  expect(taken.map((e) => e.body.S_FRONT.EVENT)).toEqual(["SAVE", "SAVE"]);
  expect(storage.data.size).toBe(0);
  // what could not be sent goes back in front of what was kept meanwhile
  Offline.queue(ctx, { S_FRONT: { EVENT: "LATER" } });
  Offline.putBack(ctx, taken.slice(1));
  expect(Offline.take(ctx).map((e) => e.body.S_FRONT.EVENT)).toEqual(["SAVE", "LATER"]);
});

test("a storage the browser refuses keeps nothing and says so", () => {
  const { Offline, ctx, errors } = load(memoryStorage({ broken: true }));
  expect(Offline.queue(ctx, body("SAVE"))).toBe(0);
  expect(Offline.pending(ctx)).toBe(0);
  expect(errors.length).toBeGreaterThan(0);
});

test("one online listener per component, gone with the teardown, the queue kept", () => {
  const { Offline, ctx, listeners, storage } = load();
  let calls = 0;
  Offline.configure(ctx, ["SAVE"], "", () => calls++);
  Offline.configure(ctx, ["SAVE"], "", () => calls++);
  expect(listeners.filter((l) => l.type === "online")).toHaveLength(1);
  listeners[0].fn();
  expect(calls).toBe(1);
  Offline.queue(ctx, body("SAVE"));
  Offline.reset(ctx);
  expect(listeners).toHaveLength(0);
  expect(Offline.canQueue(ctx, body("SAVE"))).toBe(false);
  expect(storage.data.size).toBe(1);
});
