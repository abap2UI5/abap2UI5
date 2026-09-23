// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");

// Tests the real implementation shipped in
// app/webapp/devtools/Console.js - the in-app capture of what you
// would otherwise open the browser's devtools for. The three sources are
// driven directly: the patched console methods, the window error /
// rejection listeners, and UI5's own log listener.

function loadConsole({ storage = {} } = {}) {
  const nativeCalls = [];
  const windowListeners = {};
  let ui5Listener = null;

  const consoleStub = {};
  for (const name of ["log", "info", "warn", "error", "debug"]) {
    consoleStub[name] = (...args) => nativeCalls.push({ name, args });
  }

  const Log = {
    addLogListener: (l) => {
      ui5Listener = l;
    },
    removeLogListener: () => {
      ui5Listener = null;
    },
  };

  const { module } = loadModule("devtools/Console.js", {
    // devtools/Persist.js (the guarded sessionStorage access) is loaded
    // for real - it is the module's only dependency, so autoLoad reaches
    // only that one
    autoLoad: true,
    sandbox: {
      window: {
        console: consoleStub,
        sessionStorage: {
          getItem: (k) => (k in storage ? storage[k] : null),
          setItem: (k, v) => {
            storage[k] = v;
          },
          removeItem: (k) => {
            delete storage[k];
          },
        },
        addEventListener: (type, fn) => {
          windowListeners[type] = fn;
        },
        removeEventListener: (type) => {
          delete windowListeners[type];
        },
      },
      sap: { ui: { require: (name) => (name === "sap/base/Log" ? Log : null) } },
    },
  });

  return {
    Console: module,
    nativeCalls,
    consoleStub,
    windowListeners,
    ui5: (entry) => ui5Listener?.onLogEntry(entry),
    hasUi5Listener: () => ui5Listener !== null,
  };
}

test.describe("console capture", () => {
  test("captures a call and still calls the native method through", () => {
    const h = loadConsole();
    h.Console.install();
    h.consoleStub.log("hello", 42);

    // the browser console keeps working exactly as before
    expect(h.nativeCalls).toEqual([{ name: "log", args: ["hello", 42] }]);
    const [entry] = h.Console.getEntries();
    expect(entry.level).toBe("log");
    expect(entry.source).toBe("console");
    expect(entry.text).toBe("hello 42");
  });

  test("captures every level", () => {
    const h = loadConsole();
    h.Console.install();
    for (const name of ["log", "info", "warn", "error", "debug"]) {
      h.consoleStub[name](name);
    }
    expect(h.Console.getEntries().map((e) => e.level)).toEqual([
      "log",
      "info",
      "warn",
      "error",
      "debug",
    ]);
  });

  test("keeps an Error's stack, which is the point of capturing it", () => {
    const h = loadConsole();
    h.Console.install();
    const err = new Error("kaboom");
    err.stack = "Error: kaboom\n    at doThing (App.js:12)";
    h.consoleStub.error("failed:", err);
    expect(h.Console.getEntries()[0].text).toContain("at doThing (App.js:12)");
  });

  test("renders objects, and survives a circular one", () => {
    const h = loadConsole();
    h.Console.install();
    const circular = { a: 1 };
    circular.self = circular;
    h.consoleStub.log({ x: 1 }, circular);
    const text = h.Console.getEntries()[0].text;
    expect(text).toContain('{"x":1}');
    expect(text).toContain("[Circular]");
  });

  // A value reachable twice is not a cycle. A flat "everything seen" set
  // reported the SECOND sibling as "[Circular]" - a wrong answer in the one
  // log a developer without F12 has, and the exact defect devtools/Format.js
  // documents for its own serializer.
  test("a value referenced twice in sibling branches is not circular", () => {
    const h = loadConsole();
    const shared = { id: 7, name: "shared" };
    const text = h.Console._internals.renderArg({ a: shared, b: shared });
    expect(text).not.toContain("[Circular]");
    expect(text).toBe('{"a":{"id":7,"name":"shared"},"b":{"id":7,"name":"shared"}}');
  });

  // ...and a real cycle still is one, whichever shape it takes - including
  // a self-referencing array long enough to be replaced by its head, where
  // the chain has to be followed through the replacement copy.
  test("a self-referencing long array is still reported as circular", () => {
    const h = loadConsole();
    const max = h.Console._internals.MAX_ITEMS;
    const arr = Array.from({ length: max + 5 }, (_, i) => i);
    arr[0] = arr;
    const text = h.Console._internals.renderArg(arr);
    expect(text).toContain("[Circular]");
    expect(text).toContain("5 more");
  });

  test("bounds a long array instead of serializing every row", () => {
    const h = loadConsole();
    const max = h.Console._internals.MAX_ITEMS;
    const rows = Array.from({ length: 100 }, (_, i) => ({ i, name: `row ${i}` }));
    const text = h.Console._internals.renderArg({ rows }, 0);
    expect(text).toContain(`"i":${max - 1}`);
    expect(text).not.toContain(`"i":${max}`);
    expect(text).toContain(`${100 - max} more`);
    // an array within the bound is untouched
    expect(h.Console._internals.renderArg([1, 2, 3], 0)).toBe("[1,2,3]");
  });

  test("bounds the OUTPUT of a wide object, not just the walk", () => {
    const h = loadConsole();
    const { MAX_ITEMS, MAX_TEXT_CHARS, renderArg } = h.Console._internals;
    const n = 3000;
    const big = {};
    for (let i = 0; i < n; i++) big[`k${i}`] = { i };
    const text = renderArg(big);

    // The head is kept verbatim, and the rest is ONE marker naming how many
    // were dropped - the treatment a long array already got. Dropped, not
    // emitted with a marker value: a replacer cannot remove a key, but
    // returning a COPY of the object can, which is exactly how the array
    // branch has always worked.
    expect(text).toContain('"k0":{"i":0}');
    expect(text).toContain(`... ${n - MAX_ITEMS} more`);
    expect(text).not.toContain(`"k${n - 1}"`);

    // The point of all of it: what a console.log of a wide lookup costs.
    // Before the width cap this was 63,654 characters - built in full on
    // every call and then thrown away by the MAX_TEXT_CHARS cut.
    expect(text.length).toBeLessThan(MAX_TEXT_CHARS);

    // a small object is untouched
    expect(renderArg({ a: { b: 1 } })).toBe('{"a":{"b":1}}');
  });

  test("the node budget still bounds a DEEP graph the width cap cannot see", () => {
    const h = loadConsole();
    const { MAX_NODES, renderArg } = h.Console._internals;
    // Narrow at every level - no object or array is ever wider than
    // MAX_ITEMS - so only the node budget can stop this one.
    let node = { leaf: true };
    for (let i = 0; i < MAX_NODES * 2; i++) node = { i, next: node };
    const text = renderArg(node);
    expect(text).toContain("[...]");
  });

  test("a throwing getter cannot break the call it observes", () => {
    const h = loadConsole();
    h.Console.install();
    const nasty = {
      get boom() {
        throw new Error("nope");
      },
    };
    // must not throw out of the console call
    h.consoleStub.log(nasty);
    expect(h.nativeCalls.length).toBe(1);
    expect(h.Console.getEntries().length).toBe(1);
  });

  test("caps a huge argument instead of putting it all in the ring", () => {
    const h = loadConsole();
    h.Console.install();
    const max = h.Console._internals.MAX_TEXT_CHARS;
    h.consoleStub.log("x".repeat(max * 3));
    const text = h.Console.getEntries()[0].text;
    expect(text.length).toBeLessThan(max + 100);
    expect(text).toContain("chars)");
  });

  test("caps the ring and reports how many were dropped", () => {
    const h = loadConsole();
    h.Console.install();
    const max = h.Console._internals.MAX_ENTRIES;
    for (let i = 0; i < max + 10; i++) h.consoleStub.log(`m${i}`);
    expect(h.Console.getEntries().length).toBe(max);
    // the oldest are gone, the newest survive
    expect(h.Console.getEntries()[0].text).toBe("m10");
    // the count is exposed so the log can say entries were dropped
    expect(h.Console.getDropped()).toBe(10);
  });
});

test.describe("uncaught errors", () => {
  test("captures an uncaught error with its position", () => {
    const h = loadConsole();
    h.Console.install();
    h.windowListeners.error({
      message: "boom",
      filename: "App.js",
      lineno: 7,
      colno: 3,
      error: { stack: "Error: boom\n    at x (App.js:7:3)" },
    });
    const [entry] = h.Console.getEntries();
    expect(entry.source).toBe("uncaught");
    expect(entry.level).toBe("error");
    expect(entry.text).toContain("at x (App.js:7:3)");
    expect(entry.text).toContain("App.js:7:3");
  });

  test("captures an unhandled promise rejection", () => {
    const h = loadConsole();
    h.Console.install();
    h.windowListeners.unhandledrejection({ reason: new Error("late") });
    const [entry] = h.Console.getEntries();
    expect(entry.source).toBe("rejection");
    expect(entry.text).toContain("late");
  });

  test("a rejection with a non-Error reason still lands", () => {
    const h = loadConsole();
    h.Console.install();
    h.windowListeners.unhandledrejection({ reason: "just a string" });
    expect(h.Console.getEntries()[0].text).toBe("just a string");
  });
});

test.describe("UI5 log", () => {
  test("registers an official listener - nothing is patched there", () => {
    const h = loadConsole();
    h.Console.install();
    expect(h.hasUi5Listener()).toBe(true);
  });

  test("maps the UI5 numeric levels onto the console ones", () => {
    const h = loadConsole();
    h.Console.install();
    // the values of sap/base/Log.Level: FATAL 0, ERROR 1, WARNING 2, INFO 3,
    // DEBUG 4, TRACE 5 - a table that started at 1 recorded every WARNING
    // as an error
    h.ui5({ level: 0, message: "fatal" });
    h.ui5({ level: 1, message: "error" });
    h.ui5({ level: 2, message: "warning" });
    h.ui5({ level: 3, message: "info" });
    h.ui5({ level: 4, message: "debug" });
    h.ui5({ level: 5, message: "trace" });
    expect(h.Console.getEntries().map((e) => e.level)).toEqual([
      "error",
      "error",
      "warn",
      "info",
      "debug",
      "debug",
    ]);
  });

  test("keeps the component and the details of a UI5 entry", () => {
    const h = loadConsole();
    h.Console.install();
    h.ui5({
      level: 2,
      message: "Property 'x' does not exist",
      details: "sap.m.Input",
      component: "sap.ui.base.ManagedObject",
    });
    const [entry] = h.Console.getEntries();
    expect(entry.source).toBe("ui5");
    expect(entry.text).toContain("[sap.ui.base.ManagedObject]");
    expect(entry.text).toContain("Property 'x' does not exist");
    expect(entry.text).toContain("sap.m.Input");
  });
});

// One sap/base/Log call the way the real one runs: the listeners are
// notified FIRST, and the same entry is then echoed to console.* as
// "<date> <time> <message> - <details> <component>" (Log.js, unchanged
// since 1.71). Both are captured sources, which is what made every UI5
// entry land in the ring twice.
function emitUi5(h, entry, method = "warn", extraArgs = []) {
  h.ui5(entry);
  const line =
    `${entry.date || ""} ${entry.time || ""} ${entry.message || ""} - ` +
    `${entry.details || ""} ${entry.component || ""}`;
  h.consoleStub[method](line, ...extraArgs);
}

test.describe("no double capture of a UI5 entry", () => {
  const ENTRY = {
    level: 2,
    date: "2026-09-05",
    time: "10:11:12.345678",
    message: "Property 'x' does not exist",
    details: "sap.m.Input",
    component: "sap.ui.base.ManagedObject",
  };

  test("the console echo of a UI5 entry does not land a second time", () => {
    const h = loadConsole();
    h.Console.install();
    emitUi5(h, ENTRY);

    const entries = h.Console.getEntries();
    expect(entries.length).toBe(1);
    // the listener entry is the one kept - it has the component and the
    // details as fields, the echo flattens them into one line
    expect(entries[0].source).toBe("ui5");
    expect(entries[0].text).toContain("[sap.ui.base.ManagedObject]");
    // the browser console still saw the echo - nothing is suppressed there
    expect(h.nativeCalls.length).toBe(1);
  });

  test("an Error handed to Log as the details is still one entry", () => {
    // Log echoes `logText, "\n", oError` for that case - three arguments
    const h = loadConsole();
    h.Console.install();
    const err = new Error("boom");
    err.stack = "Error: boom\n    at x (App.js:1:1)";
    emitUi5(h, { ...ENTRY, level: 1, details: String(err) }, "error", [
      "\n",
      err,
    ]);
    expect(h.Console.getEntries().length).toBe(1);
    expect(h.Console.getEntries()[0].source).toBe("ui5");
  });

  test("a real console call right after a UI5 entry still lands", () => {
    const h = loadConsole();
    h.Console.install();
    emitUi5(h, ENTRY);
    h.consoleStub.log("app says hello");
    const entries = h.Console.getEntries();
    expect(entries.map((e) => e.source)).toEqual(["ui5", "console"]);
    expect(entries[1].text).toBe("app says hello");
  });

  test("a console call that is no echo is kept even when one was expected", () => {
    // the echo is only dropped when the line IS it: a UI5 entry whose level
    // has no captured console method (TRACE) must not swallow the next call
    const h = loadConsole();
    h.Console.install();
    h.ui5({ ...ENTRY, level: 5 });
    h.consoleStub.log("unrelated");
    expect(h.Console.getEntries().map((e) => e.text)).toEqual([
      "[sap.ui.base.ManagedObject] Property 'x' does not exist - sap.m.Input",
      "unrelated",
    ]);
  });
});

test.describe("lifecycle", () => {
  test("install is idempotent", () => {
    const h = loadConsole();
    h.Console.install();
    h.Console.install();
    h.consoleStub.log("once");
    // a doubly-wrapped console would capture the same call twice
    expect(h.Console.getEntries().length).toBe(1);
  });

  test("uninstall restores the native methods and drops the buffer", () => {
    const h = loadConsole();
    const before = h.consoleStub.log;
    h.Console.install();
    expect(h.consoleStub.log).not.toBe(before);
    h.consoleStub.log("captured");

    h.Console.uninstall();
    expect(h.consoleStub.log).toBe(before);
    expect(h.hasUi5Listener()).toBe(false);
    expect(h.windowListeners.error).toBe(undefined);
    expect(h.Console.getEntries().length).toBe(0);

    // a call after uninstall is no longer captured
    h.consoleStub.log("after");
    expect(h.Console.getEntries().length).toBe(0);
  });

});

test.describe("open on error", () => {
  test("stays silent while the option is off", () => {
    const h = loadConsole();
    const raised = [];
    h.Console.install();
    h.Console.setOnError(() => raised.push(true));
    h.consoleStub.error("boom");
    expect(h.Console.isAlertOnError()).toBe(false);
    expect(raised.length).toBe(0);
  });

  test("announces an error once the option is on", () => {
    const h = loadConsole();
    const raised = [];
    h.Console.install();
    h.Console.setAlertOnError(true);
    h.Console.setOnError((entry) => raised.push(entry));
    h.consoleStub.error("boom");
    expect(raised.length).toBe(1);
    expect(raised[0].text).toBe("boom");
    // only errors announce - a warning must not pop the dialog
    h.consoleStub.warn("careful");
    expect(raised.length).toBe(1);
  });

  test("a throwing subscriber cannot break the capture", () => {
    const h = loadConsole();
    h.Console.install();
    h.Console.setAlertOnError(true);
    h.Console.setOnError(() => {
      throw new Error("subscriber broke");
    });
    h.consoleStub.error("boom");
    expect(h.Console.getEntries().length).toBe(1);
  });
});

test.describe("surviving a page reload", () => {
  test("carries the errors across, marked as a previous load", () => {
    const storage = {};
    const first = loadConsole({ storage });
    first.Console.install();
    first.consoleStub.error("died here");
    first.consoleStub.log("noise");
    first.windowListeners.pagehide();

    const second = loadConsole({ storage });
    second.Console.install();
    const entries = second.Console.getEntries();
    // only the errors travel - the noise is not worth the storage
    expect(entries.length).toBe(1);
    expect(entries[0].text).toBe("died here");
    expect(entries[0].previousLoad).toBe(true);
  });

  test("the stored entries are consumed, not replayed forever", () => {
    const storage = {};
    const first = loadConsole({ storage });
    first.Console.install();
    first.consoleStub.error("once");
    first.windowListeners.pagehide();

    loadConsole({ storage }).Console.install();
    const third = loadConsole({ storage });
    third.Console.install();
    expect(third.Console.getEntries().length).toBe(0);
  });

  test("nothing to carry writes nothing", () => {
    const storage = {};
    const h = loadConsole({ storage });
    h.Console.install();
    h.consoleStub.log("just a log");
    h.windowListeners.pagehide();
    expect(Object.keys(storage).length).toBe(0);
  });
});
