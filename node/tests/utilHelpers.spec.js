// @ts-check
const { test, expect } = require("@playwright/test");
const { loadLib } = require("./loadLibModule");

// Tests the security and session helpers shipped in app/webapp/core/Lib.js.
// The module is loaded via a stubbed sap.ui.define (see loadLibModule.js),
// with window.location.origin anchored to http://localhost:3000.

const ORIGIN = "http://localhost:3000";

test.describe("isDestroyed (async-continuation guard, 1.71 floor)", () => {
  const { Lib } = loadLib();

  test("prefers the isDestroyed() method where the release has it", () => {
    expect(Lib.isDestroyed({ isDestroyed: () => true })).toBe(true);
    // the method (@since 1.93) wins over a stray flag
    expect(
      Lib.isDestroyed({ isDestroyed: () => false, bIsDestroyed: true }),
    ).toBe(false);
  });

  test("falls back to the bIsDestroyed flag on the 1.71 floor", () => {
    // ManagedObject#isDestroyed() is absent there - without the fallback a
    // destroyed control would read "alive" and the guards would misfire
    expect(Lib.isDestroyed({ bIsDestroyed: true })).toBe(true);
    expect(Lib.isDestroyed({})).toBe(false);
    expect(Lib.isDestroyed(null)).toBe(false);
  });
});

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

test.describe("getElementById", () => {
  const el = { id: "btn1" };

  test("resolves a known control id to its element", () => {
    const { Lib } = loadLib({ elements: { btn1: el } });
    expect(Lib.getElementById("btn1")).toBe(el);
  });

  test("returns null for an empty or unknown id", () => {
    const { Lib } = loadLib({ elements: { btn1: el } });
    expect(Lib.getElementById("")).toBeNull();
    expect(Lib.getElementById(undefined)).toBeNull();
    expect(Lib.getElementById("missing")).toBeNull();
  });
});

test.describe("getMessaging (version-independent messaging facade)", () => {
  test("prefers the sap/ui/core/Messaging module when loaded", () => {
    const { Lib, sandbox } = loadLib();
    const Messaging = { getMessageModel: () => ({}), registerObject: () => {} };
    sandbox.sap.ui.require = (name) =>
      name === "sap/ui/core/Messaging" ? Messaging : undefined;
    sandbox.sap.ui.getCore = () => {
      throw new Error("must not fall back when Messaging exists");
    };
    expect(Lib.getMessaging()).toBe(Messaging);
  });

  test("falls back to the MessageManager singleton on older releases", () => {
    const { Lib, sandbox } = loadLib();
    const mm = { getMessageModel: () => ({}) };
    sandbox.sap.ui.require = () => undefined;
    sandbox.sap.ui.getCore = () => ({ getMessageManager: () => mm });
    expect(Lib.getMessaging()).toBe(mm);
  });

  test("returns null when neither API exists (bare bootstrap)", () => {
    const { Lib, sandbox } = loadLib();
    sandbox.sap.ui.require = () => undefined;
    expect(Lib.getMessaging()).toBeNull();
  });
});

test.describe("hasMessagingModule (warm-load gate for sap/ui/core/Messaging)", () => {
  test("true from 1.118 on", () => {
    const { Lib, sandbox } = loadLib();
    sandbox.sap.ui.version = "1.142.0";
    expect(Lib.hasMessagingModule()).toBe(true);
  });

  test("false below 1.118, where the module would 404", () => {
    const { Lib, sandbox } = loadLib();
    sandbox.sap.ui.version = "1.71.0";
    expect(Lib.hasMessagingModule()).toBe(false);
  });

  // The legacy-free (UI5 2.x) build drops the sap.ui.version global, so the
  // probe reads undefined on a 1.142 runtime. Answering "false" there would
  // switch off the warm-load on the one build whose ONLY messaging API is
  // sap/ui/core/Messaging - message> model and handleValidation would go
  // silently dead. An unreadable version therefore means "modern".
  test("true when the version global is absent (legacy-free build)", () => {
    const { Lib, sandbox } = loadLib();
    delete sandbox.sap.ui.version;
    expect(Lib.hasMessagingModule()).toBe(true);
  });

  test("true when the version is unparsable", () => {
    const { Lib, sandbox } = loadLib();
    sandbox.sap.ui.version = "not-a-version";
    expect(Lib.hasMessagingModule()).toBe(true);
  });
});

test.describe("getTextPath (ancestor-text breadcrumb of a control)", () => {
  const { Lib } = loadLib();

  // a menu item chain: Menu > "Create New Site" > "Official Store". The Menu
  // itself has no getText, which is exactly where the walk has to stop.
  function item(text, parent) {
    return { getText: () => text, getParent: () => parent };
  }

  test("joins the item's own text with its ancestors', outermost first", () => {
    const root = { getParent: () => null }; // sap.m.Menu - no getText
    const level1 = item("Create New Site", root);
    expect(Lib.getTextPath(item("Official Store", level1))).toBe(
      "Create New Site > Official Store",
    );
  });

  test("a leaf without ancestors is just its own text", () => {
    expect(Lib.getTextPath(item("Save", { getParent: () => null }))).toBe(
      "Save",
    );
  });

  test("takes a custom separator and skips empty texts", () => {
    const top = item("A", { getParent: () => null });
    const middle = item("", top);
    expect(Lib.getTextPath(item("C", middle), " / ")).toBe("A / C");
  });

  test("returns an empty string for a control without getText", () => {
    expect(Lib.getTextPath({ getParent: () => null })).toBe("");
    expect(Lib.getTextPath(null)).toBe("");
  });

  test("survives a cyclic parent chain", () => {
    const node = { getText: () => "X", getParent: () => node };
    expect(Lib.getTextPath(node).split(" > ").length).toBe(100);
  });
});

test.describe("isTextInput / readCaret (caret capture)", () => {
  const { Lib } = loadLib();

  const field = (tagName, start, end) => ({
    tagName,
    selectionStart: start,
    selectionEnd: end,
  });

  test("recognizes input and textarea only", () => {
    expect(Lib.isTextInput(field("INPUT"))).toBe(true);
    expect(Lib.isTextInput(field("TEXTAREA"))).toBe(true);
    expect(Lib.isTextInput(field("BUTTON"))).toBe(false);
    expect(Lib.isTextInput(null)).toBe(false);
    expect(Lib.isTextInput(undefined)).toBe(false);
  });

  test("reads the caret of a text field", () => {
    expect(Lib.readCaret(field("INPUT", 2, 5))).toEqual({ start: 2, end: 5 });
    expect(Lib.readCaret(field("TEXTAREA", 0, 0))).toEqual({ start: 0, end: 0 });
  });

  test("returns null for a non-text element", () => {
    expect(Lib.readCaret(field("BUTTON", 1, 1))).toBeNull();
    expect(Lib.readCaret(null)).toBeNull();
  });

  // A caret at 0 must stay distinguishable from "no caret" - reporting the
  // missing one as 0 would snap the cursor to the far left on restore.
  test("returns null when the field exposes no selection", () => {
    expect(Lib.readCaret(field("INPUT", null, null))).toBeNull();
    expect(Lib.readCaret(field("INPUT", undefined, undefined))).toBeNull();
  });

  test("returns null when reading the selection throws", () => {
    const hostile = {
      tagName: "INPUT",
      get selectionStart() {
        throw new Error("unsupported input type");
      },
    };
    expect(Lib.readCaret(hostile)).toBeNull();
  });
});

test.describe("claimOnce (companion-control wiring guard)", () => {
  const { Lib } = loadLib();

  const control = () => {
    const props = { checkInit: false };
    return {
      getProperty: (name) => props[name],
      setProperty: (name, value) => {
        props[name] = value;
      },
      props,
    };
  };

  test("claims on the first render that resolved a target", () => {
    const owner = control();
    expect(Lib.claimOnce(owner, { id: "target" })).toBe(true);
    expect(owner.props.checkInit).toBe(true);
  });

  test("never claims twice - the render hook fires every roundtrip", () => {
    const owner = control();
    const target = { id: "target" };
    expect(Lib.claimOnce(owner, target)).toBe(true);
    expect(Lib.claimOnce(owner, target)).toBe(false);
    expect(Lib.claimOnce(owner, target)).toBe(false);
  });

  test("does not claim while the target is still unresolved", () => {
    const owner = control();
    expect(Lib.claimOnce(owner, null)).toBe(false);
    expect(owner.props.checkInit).toBe(false);
    // ... and still claims once the target shows up on a later render
    expect(Lib.claimOnce(owner, { id: "target" })).toBe(true);
  });
});
