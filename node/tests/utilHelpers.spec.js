// @ts-check
const { test, expect } = require("@playwright/test");
const { loadLib } = require("./loadLibModule");

// Tests the security and session helpers shipped in app/webapp/core/Lib.js.
// The module is loaded via a stubbed sap.ui.define (see loadLibModule.js),
// with window.location.origin anchored to http://localhost:3000.

const ORIGIN = "http://localhost:3000";

test.describe("isValidRedirectURL (same-origin http/https only)", () => {
  const { Lib } = loadLib();

  test("accepts a relative URL", () => {
    expect(Lib.isValidRedirectURL("/sap/bc/ui5_ui5/index.html")).toBe(true);
  });

  test("accepts an absolute same-origin URL", () => {
    expect(Lib.isValidRedirectURL(`${ORIGIN}/path?x=1#frag`)).toBe(true);
  });

  test("blocks a different origin", () => {
    expect(Lib.isValidRedirectURL("https://evil.example.com/")).toBe(false);
  });

  test("blocks a different port on the same host", () => {
    expect(Lib.isValidRedirectURL("http://localhost:8080/")).toBe(false);
  });

  test("blocks javascript: URLs", () => {
    expect(Lib.isValidRedirectURL("javascript:alert(1)")).toBe(false);
  });

  test("blocks data: URLs", () => {
    expect(Lib.isValidRedirectURL("data:text/html,<b>x</b>")).toBe(false);
  });

  test("rejects empty and missing input", () => {
    expect(Lib.isValidRedirectURL("")).toBe(false);
    expect(Lib.isValidRedirectURL(undefined)).toBe(false);
    expect(Lib.isValidRedirectURL(null)).toBe(false);
  });
});

test.describe("isSafeRedirectProtocol (cross-origin allowed, http/https only)", () => {
  const { Lib } = loadLib();

  test("accepts a cross-origin https URL", () => {
    expect(Lib.isSafeRedirectProtocol("https://example.com/page")).toBe(true);
  });

  test("accepts a relative URL", () => {
    expect(Lib.isSafeRedirectProtocol("/local/path")).toBe(true);
  });

  test("blocks javascript: URLs", () => {
    expect(Lib.isSafeRedirectProtocol("javascript:alert(1)")).toBe(false);
  });

  test("blocks vbscript: URLs", () => {
    expect(Lib.isSafeRedirectProtocol("vbscript:msgbox(1)")).toBe(false);
  });

  test("blocks data: URLs", () => {
    expect(Lib.isSafeRedirectProtocol("data:text/html,<b>x</b>")).toBe(false);
  });
});

test.describe("isSafeDownloadURL (data/blob/http/https)", () => {
  const { Lib } = loadLib();

  test("accepts data: URLs", () => {
    expect(Lib.isSafeDownloadURL("data:image/png;base64,AAAA")).toBe(true);
  });

  test("accepts blob: URLs", () => {
    expect(Lib.isSafeDownloadURL(`blob:${ORIGIN}/123-456`)).toBe(true);
  });

  test("accepts http(s) and relative URLs", () => {
    expect(Lib.isSafeDownloadURL("https://example.com/file.pdf")).toBe(true);
    expect(Lib.isSafeDownloadURL("/files/report.pdf")).toBe(true);
  });

  test("blocks javascript: URLs", () => {
    expect(Lib.isSafeDownloadURL("javascript:alert(1)")).toBe(false);
  });

  test("rejects empty input", () => {
    expect(Lib.isSafeDownloadURL("")).toBe(false);
  });
});

test.describe("isValidContextId", () => {
  const { Lib } = loadLib();

  test("accepts a real session id", () => {
    expect(Lib.isValidContextId("SID:ANON:ldai1abc_ABC_00:xyz")).toBe(true);
  });

  test("rejects the empty string", () => {
    expect(Lib.isValidContextId("")).toBe(false);
  });

  test('rejects the literal string "undefined"', () => {
    expect(Lib.isValidContextId("undefined")).toBe(false);
  });

  test("rejects non-string values", () => {
    expect(Lib.isValidContextId(undefined)).toBe(false);
    expect(Lib.isValidContextId(null)).toBe(false);
    expect(Lib.isValidContextId(42)).toBe(false);
  });
});

test.describe("toText", () => {
  const { Lib } = loadLib();

  test("returns the empty string for null and undefined", () => {
    expect(Lib.toText(null)).toBe("");
    expect(Lib.toText(undefined)).toBe("");
  });

  test("stringifies other values, keeping falsy 0 and false", () => {
    expect(Lib.toText(0)).toBe("0");
    expect(Lib.toText(false)).toBe("false");
    expect(Lib.toText("abc")).toBe("abc");
  });
});

test.describe("deriveSystemType", () => {
  const { Lib } = loadLib();

  test("maps each device flag to its label, phone winning first", () => {
    expect(Lib.deriveSystemType({ phone: true, tablet: true })).toBe("phone");
    expect(Lib.deriveSystemType({ tablet: true })).toBe("tablet");
    expect(Lib.deriveSystemType({ combi: true })).toBe("combi");
  });

  test("falls back to desktop for no flags or a missing object", () => {
    expect(Lib.deriveSystemType({ desktop: true })).toBe("desktop");
    expect(Lib.deriveSystemType({})).toBe("desktop");
    expect(Lib.deriveSystemType(undefined)).toBe("desktop");
  });
});

test.describe("runCallbacks", () => {
  test("calls every callback with the given arguments", () => {
    const { Lib } = loadLib();
    const calls = [];
    Lib.runCallbacks(
      [
        (a, b) => calls.push(["one", a, b]),
        null,
        (a) => calls.push(["two", a]),
      ],
      1,
      2,
    );
    expect(calls).toEqual([
      ["one", 1, 2],
      ["two", 1],
    ]);
  });

  test("a throwing callback is logged and does not stop the others", () => {
    const { Lib, sandbox } = loadLib();
    const calls = [];
    Lib.runCallbacks([
      () => {
        throw new Error("boom");
      },
      () => calls.push("ok"),
    ]);
    expect(calls).toEqual(["ok"]);
    expect(sandbox.z2ui5.errors[0].error.message).toBe("boom");
  });

  test("tolerates a missing callback array", () => {
    const { Lib } = loadLib();
    expect(() => Lib.runCallbacks(undefined)).not.toThrow();
  });
});

test.describe("logError", () => {
  test("caps the error log at 100 entries, dropping the oldest", () => {
    const { Lib, sandbox } = loadLib();
    for (let i = 0; i < 150; i++) Lib.logError(`error ${i}`);
    expect(sandbox.z2ui5.errors.length).toBe(100);
    expect(sandbox.z2ui5.errors[0].message).toBe("error 50");
    expect(sandbox.z2ui5.errors[99].message).toBe("error 149");
  });

  test("stores the error object only when one was passed", () => {
    const { Lib, sandbox } = loadLib();
    Lib.logError("plain message");
    Lib.logError("with error", new Error("boom"));
    expect(sandbox.z2ui5.errors[0]).not.toHaveProperty("error");
    expect(sandbox.z2ui5.errors[1].error.message).toBe("boom");
    expect(sandbox.z2ui5.errors[1].ts).toBeTruthy();
  });
});
