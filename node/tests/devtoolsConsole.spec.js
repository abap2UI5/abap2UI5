// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");

// Tests the real implementation shipped in
// app/webapp/core/devtools/Console.js - the in-app capture of what you
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

  const { module } = loadModule("core/devtools/Console.js", {
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
    expect(h.Console.format()).toContain("10 older dropped");
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
    h.ui5({ level: 1, message: "fatal" });
    h.ui5({ level: 2, message: "error" });
    h.ui5({ level: 3, message: "warning" });
    h.ui5({ level: 4, message: "info" });
    h.ui5({ level: 5, message: "debug" });
    expect(h.Console.getEntries().map((e) => e.level)).toEqual([
      "error",
      "error",
      "warn",
      "info",
      "debug",
    ]);
  });

  test("keeps the component and the details of a UI5 entry", () => {
    const h = loadConsole();
    h.Console.install();
    h.ui5({
      level: 3,
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

  test("hasErrors reports whether anything failed", () => {
    const h = loadConsole();
    h.Console.install();
    h.consoleStub.log("fine");
    expect(h.Console.hasErrors()).toBe(false);
    h.consoleStub.error("broken");
    expect(h.Console.hasErrors()).toBe(true);
  });
});

test.describe("rendering", () => {
  test("an empty console says so", () => {
    const h = loadConsole();
    h.Console.install();
    expect(h.Console.format()).toContain("nothing logged yet");
  });

  test("counts the entries by level", () => {
    const h = loadConsole();
    h.Console.install();
    h.consoleStub.error("a");
    h.consoleStub.warn("b");
    h.consoleStub.warn("c");
    expect(h.Console.format()).toContain("1 error, 2 warn");
  });

  test("indents a stack trace under its message", () => {
    const h = loadConsole();
    h.Console.install();
    const err = new Error("boom");
    err.stack = "Error: boom\n    at a (X.js:1)\n    at b (Y.js:2)";
    h.consoleStub.error(err);
    const lines = h.Console.format().split("\n");
    const first = lines.findIndex((l) => l.includes("Error: boom"));
    expect(lines[first + 1]).toContain("at a (X.js:1)");
    expect(lines[first + 2]).toContain("at b (Y.js:2)");
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
    expect(second.Console.format()).toContain("died here");
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
