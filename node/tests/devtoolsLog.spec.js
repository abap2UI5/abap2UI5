// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");
const { specContext } = require("./loadLibModule");

// Tests the real implementation shipped in app/webapp/devtools/Log.js -
// the Log tab. The framework error log, the console capture and the
// backend messages used to be three tabs. They are three views of one
// timeline, and splitting them forced the developer to correlate them by
// hand; the merge, the ordering and the origin column are what is pinned.
// devtools/Inspect.js re-exports formatLog and reads collectLog/countLevels
// for the Overview's summary line (devtoolsInspect.spec.js).

// The framework's error ring is page-wide (Lib.errors) and so is the
// console capture; the recorded roundtrips belong to the component context
// (core/Context.js) the renderers take first.
function loadLog({
  errors = [],
  consoleEntries = [],
  consoleDropped = 0,
  records = [],
} = {}) {
  const ctx = specContext();
  const { module } = loadModule("devtools/Log.js", {
    deps: {
      "z2ui5/core/Lib": { errors },
      // Capture and rendering are split: Console hands over the entries,
      // Log merges them with the framework log and the backend messages.
      "z2ui5/devtools/Console": {
        getEntries: () => consoleEntries,
        getDropped: () => consoleDropped,
      },
      "z2ui5/devtools/Recorder": { getRecords: () => records },
    },
  });
  return { Log: module, ctx };
}

test.describe("Log - the merged timeline", () => {
  test("interleaves all three sources chronologically", () => {
    const { Log, ctx } = loadLog({
      errors: [{ ts: "2026-01-01T10:00:02.000Z", message: "framework says" }],
      consoleEntries: [
        {
          ts: "2026-01-01T10:00:01.000Z",
          level: "warn",
          source: "ui5",
          text: "binding problem",
        },
        {
          ts: "2026-01-01T10:00:04.000Z",
          level: "error",
          source: "uncaught",
          text: "boom",
        },
      ],
      records: [
        {
          seq: 1,
          ts: "2026-01-01T10:00:03.000Z",
          messages: [
            { target: "MESSAGE_TOAST", method: "show", text: "saved" },
          ],
        },
      ],
    });
    const out = Log.formatLog(ctx);
    // one timeline, oldest first, regardless of which source produced it
    const order = ["binding problem", "framework says", "saved", "boom"];
    let previous = -1;
    for (const needle of order) {
      const at = out.indexOf(needle);
      expect(at).toBeGreaterThan(previous);
      previous = at;
    }
  });

  test("names the origin of every entry", () => {
    const { Log, ctx } = loadLog({
      errors: [{ ts: "2026-01-01T10:00:00.000Z", message: "x" }],
      consoleEntries: [
        {
          ts: "2026-01-01T10:00:01.000Z",
          level: "log",
          source: "console",
          text: "y",
        },
      ],
      records: [
        {
          seq: 1,
          ts: "2026-01-01T10:00:02.000Z",
          messages: [{ target: "MESSAGE_BOX", method: "error", text: "z" }],
        },
      ],
    });
    const out = Log.formatLog(ctx);
    expect(out).toContain("framework");
    expect(out).toContain("console");
    expect(out).toContain("box.error");
  });

  test("keeps the stack trace of a framework log entry", () => {
    const error = new Error("kaboom");
    error.stack = "Error: kaboom\n    at doThing (Websocket.js:42)";
    const { Log, ctx } = loadLog({
      errors: [
        {
          ts: "2026-01-01T10:00:00.000Z",
          message: "Websocket: send failed",
          error,
        },
      ],
    });
    const out = Log.formatLog(ctx);
    expect(out).toContain("Websocket: send failed");
    expect(out).toContain("at doThing (Websocket.js:42)");
  });

  test("falls back to the string form for a non-Error throwable", () => {
    const { Log, ctx } = loadLog({
      errors: [{ ts: "2026-01-01T10:00:00.000Z", message: "m", error: "plain" }],
    });
    expect(Log.formatLog(ctx)).toContain("plain");
  });

  test("derives the level of a backend message from its method", () => {
    const messagesAt = (method, target = "MESSAGE_BOX") => {
      const { Log, ctx } = loadLog({
        records: [
          {
            seq: 1,
            ts: "2026-01-01T10:00:00.000Z",
            messages: [{ target, method, text: "t" }],
          },
        ],
      });
      return Log.formatLog(ctx);
    };
    expect(messagesAt("error")).toContain("ERROR");
    expect(messagesAt("warning")).toContain("WARN");
    expect(messagesAt("success")).toContain("INFO");
    expect(messagesAt("show", "MESSAGE_TOAST")).toContain("INFO");
  });

  test("counts the entries by level and reports dropped ones", () => {
    const { Log, ctx } = loadLog({
      consoleEntries: [
        {
          ts: "2026-01-01T10:00:00.000Z",
          level: "error",
          source: "console",
          text: "a",
        },
        {
          ts: "2026-01-01T10:00:01.000Z",
          level: "warn",
          source: "console",
          text: "b",
        },
        {
          ts: "2026-01-01T10:00:02.000Z",
          level: "warn",
          source: "console",
          text: "c",
        },
      ],
      consoleDropped: 7,
    });
    const out = Log.formatLog(ctx);
    expect(out).toContain("1 error, 2 warn");
    expect(out).toContain("7 older console entries dropped");
  });

  test("marks the entries carried across a page reload", () => {
    const { Log, ctx } = loadLog({
      consoleEntries: [
        {
          ts: "2026-01-01T10:00:00.000Z",
          level: "error",
          source: "uncaught",
          text: "died before the reload",
          previousLoad: true,
        },
      ],
    });
    const out = Log.formatLog(ctx);
    expect(out).toContain("died before the reload");
    expect(out).toContain("PREVIOUS page load");
  });

  test("an empty timeline says so", () => {
    const { Log, ctx } = loadLog();
    expect(Log.formatLog(ctx)).toContain("nothing logged yet");
  });

  // What the Overview reads: the merged entries and their level counts,
  // without the rendering around them.
  test("collectLog and countLevels serve the Overview's summary", () => {
    const { Log, ctx } = loadLog({
      errors: [{ ts: "2026-01-01T10:00:01.000Z", message: "x" }],
      consoleEntries: [
        {
          ts: "2026-01-01T10:00:00.000Z",
          level: "warn",
          source: "ui5",
          text: "y",
        },
      ],
    });
    const entries = Log.collectLog(ctx);
    expect(entries.map((entry) => entry.source)).toEqual(["ui5", "framework"]);
    expect(Log.countLevels(entries)).toEqual({
      error: 1,
      warn: 1,
      info: 0,
      log: 0,
      debug: 0,
    });
  });
});
