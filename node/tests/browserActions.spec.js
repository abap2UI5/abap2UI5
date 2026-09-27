// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");
const { loadLib, withSpecController } = require("./loadLibModule");

// Tests the URL-shaped handlers of core/actions/Browser.js - the actions
// that can navigate away or hand data out of the app, through the REAL
// Lib validators (loadLibModule), so what is pinned here is the shipped
// guard chain, not a stub's opinion of it:
//   DOWNLOAD_B64_FILE  protocol guard, active data: MIME block, filename
//                      sanitizer, the attach-click-remove anchor dance
//   OPEN_NEW_TAB       same-origin guard, opened with noopener,noreferrer
//   URLHELPER          CR/LF header-injection block, REDIRECT protocol
//                      guard (external http/https allowed, schemes not)
//   LOCATION_RELOAD    same-origin guard before the navigation
//   SYSTEM_LOGOUT      the launchpad logout, the BSP terminate iframe with
//                      its load / safety-net finish, the ICF logoff fallback
//   PLAY_AUDIO         protocol guard, a rejected play( ) caught into the log
// `pathname` is the page's path (a BSP path switches SYSTEM_LOGOUT to the
// iframe terminate), `oLaunchpad` the launchpad record of the context.
function load({ pathname = "/sap/z2ui5", oLaunchpad = null } = {}) {
  // The real Lib: its sandbox origin anchors the same-origin checks.
  const { Lib, state: libState, ctx } = loadLib({ state: { oLaunchpad } });

  const boxErrors = [];
  const urlHelperCalls = [];
  const anchors = [];
  const frames = [];
  const bodyOps = [];
  const opened = [];
  const timers = [];
  const audios = [];

  const historyBacks = [];
  const navBacks = [];
  const stores = [];
  const documentStub = {
    createElement: (tag) => {
      const el = {
        tagName: tag.toUpperCase(),
        href: "",
        src: "",
        style: {},
        download: undefined,
        clicks: 0,
        listeners: {},
        removed: false,
        click() {
          this.clicks += 1;
        },
        addEventListener(type, fn) {
          this.listeners[type] = fn;
        },
        remove() {
          this.removed = true;
        },
      };
      if (tag === "a") anchors.push(el);
      if (tag === "iframe") frames.push(el);
      return el;
    },
    body: {
      appendChild: (el) => bodyOps.push(["append", el]),
      removeChild: (el) => bodyOps.push(["remove", el]),
    },
  };
  const location = { origin: "http://localhost:3000", pathname, href: "" };
  // what a play( ) answers is decided per test (playResult), so both the
  // autoplay-policy rejection and the synchronous throw are reachable
  let playResult = () => Promise.resolve();
  class Audio {
    constructor(src) {
      this.src = src;
      audios.push(this);
    }
    play() {
      return playResult(this);
    }
  }

  const { module: Browser } = loadModule("core/actions/Browser.js", {
    deps: {
      "sap/m/MessageBox": { error: (msg) => boxErrors.push(msg) },
      "sap/m/library": {
        URLHelper: {
          redirect: (...a) => urlHelperCalls.push(["redirect", ...a]),
          triggerEmail: (...a) => urlHelperCalls.push(["triggerEmail", ...a]),
          triggerSms: (...a) => urlHelperCalls.push(["triggerSms", ...a]),
          triggerTel: (...a) => urlHelperCalls.push(["triggerTel", ...a]),
        },
      },
      // Records what STORE_DATA built and wrote; Type mirrors the two
      // members sap/ui/util/Storage really carries.
      "sap/ui/util/Storage": Object.assign(
        class {
          constructor(storageType, prefix) {
            stores.push({ storageType, prefix, ops: [] });
            this._ops = stores[stores.length - 1].ops;
          }
          put(key, value) {
            this._ops.push(["put", key, value]);
          }
          remove(key) {
            this._ops.push(["remove", key]);
          }
        },
        { Type: { local: "local", session: "session" } },
      ),
      "z2ui5/core/Router": {
        navBack: (_ctx, fallback) => navBacks.push(fallback),
      },
      "z2ui5/core/Lib": Lib,
      // STORE_DATA resolves a model-path payload the way SET_SIZE_LIMIT
      // does - through the TRACKED framework model when there is one
      "z2ui5/core/ViewSlots": {
        trackedModel: (owner) => owner?.__tracked,
      },
    },
    sandbox: {
      document: documentStub,
      Audio,
      // the 1.5 s safety net of the BSP terminate is recorded, not waited for
      setTimeout: (fn, ms) => {
        timers.push({ fn, ms });
        return timers.length;
      },
      window: {
        // same origin the real Lib resolves against (loadLibModule)
        location,
        history: { back: () => historyBacks.push(1) },
        // a browser answers null for a "noopener" open - there is no
        // window handle to reach back to, which is the point
        open: (url, target, features) => {
          opened.push({ url, target, features });
          return null;
        },
      },
    },
  });

  return {
    // the handlers read the context off the calling controller; the
    // specs' bare fixtures get the spec's one
    handlers: withSpecController(Browser.handlers, ctx).handlers,
    stores,
    historyBacks,
    navBacks,
    anchors,
    frames,
    bodyOps,
    opened,
    boxErrors,
    urlHelperCalls,
    location,
    timers,
    audios,
    setPlayResult: (fn) => {
      playResult = fn;
    },
    errors: () => (libState.errors || []).map((e) => e.message),
  };
}

test.describe("LOCATION_RELOAD", () => {
  test("a same-origin URL is navigated to", () => {
    const { handlers, location, boxErrors } = load();
    handlers.LOCATION_RELOAD(null, ["LOCATION_RELOAD", "/sap/z2ui5?app=x"]);
    expect(location.href).toBe("/sap/z2ui5?app=x");
    expect(boxErrors).toEqual([]);
  });

  test("a cross-origin or javascript: URL is refused with a MessageBox", () => {
    const { handlers, location, boxErrors } = load();
    handlers.LOCATION_RELOAD(null, ["LOCATION_RELOAD", "https://evil.example/"]);
    handlers.LOCATION_RELOAD(null, ["LOCATION_RELOAD", "javascript:alert(1)"]);
    expect(location.href).toBe("");
    expect(boxErrors).toHaveLength(2);
    expect(boxErrors[0]).toContain("Invalid redirect URL");
  });
});

test.describe("SYSTEM_LOGOUT", () => {
  test("outside a BSP path it goes straight to the ICF logoff", () => {
    const { handlers, location, frames } = load();
    handlers.SYSTEM_LOGOUT({}, ["SYSTEM_LOGOUT"]);
    expect(frames).toEqual([]);
    expect(location.href).toBe("/sap/public/bc/icf/logoff");
  });

  test("an explicit same-origin logout URL replaces the ICF one", () => {
    const { handlers, location } = load();
    handlers.SYSTEM_LOGOUT({}, ["SYSTEM_LOGOUT", "/sap/bc/logoff?x=1"]);
    expect(location.href).toBe("/sap/bc/logoff?x=1");
  });

  test("a cross-origin logout URL is refused with a MessageBox", () => {
    const { handlers, location, boxErrors } = load();
    handlers.SYSTEM_LOGOUT({}, ["SYSTEM_LOGOUT", "https://evil.example/out"]);
    expect(location.href).toBe("");
    expect(boxErrors[0]).toContain("Invalid logout URL");
  });

  test("inside the launchpad its own logout wins when no URL is given", () => {
    const logouts = [];
    const { handlers, location } = load({
      oLaunchpad: { Container: { logout: () => logouts.push(1) } },
    });
    handlers.SYSTEM_LOGOUT({}, ["SYSTEM_LOGOUT"]);
    expect(logouts).toEqual([1]);
    expect(location.href).toBe("");

    // an EXPLICIT URL is the app's decision and bypasses the shell; an
    // empty string is "no URL" for both branches
    handlers.SYSTEM_LOGOUT({}, ["SYSTEM_LOGOUT", ""]);
    expect(logouts).toEqual([1, 1]);
    handlers.SYSTEM_LOGOUT({}, ["SYSTEM_LOGOUT", "/sap/bc/logoff"]);
    expect(logouts).toEqual([1, 1]);
    expect(location.href).toBe("/sap/bc/logoff");
  });

  test("a throwing launchpad logout falls back to the redirect", () => {
    const { handlers, location, errors } = load({
      oLaunchpad: {
        Container: {
          logout: () => {
            throw new Error("shell gone");
          },
        },
      },
    });
    handlers.SYSTEM_LOGOUT({}, ["SYSTEM_LOGOUT"]);
    expect(errors()).toContain("SYSTEM_LOGOUT: ushell logout failed");
    expect(location.href).toBe("/sap/public/bc/icf/logoff");
  });

  // Hosted as a BSP application the ICF logoff alone leaves the stateful
  // BSP context alive: a hidden iframe first hits the BSP path with
  // ?sap-sessioncmd=logoff, and the redirect follows its load
  test("on a BSP path the terminate iframe loads first, then the redirect", () => {
    const { handlers, location, frames, bodyOps, timers } = load({
      pathname: "/sap/bc/bsp/sap/z2ui5/index.html",
    });
    handlers.SYSTEM_LOGOUT({}, ["SYSTEM_LOGOUT"]);

    expect(frames).toHaveLength(1);
    const frame = frames[0];
    expect(frame.src).toBe("/sap/bc/bsp/sap/z2ui5/index.html?sap-sessioncmd=logoff");
    expect(frame.style.display).toBe("none");
    expect(bodyOps).toEqual([["append", frame]]);
    // nothing navigates before the terminate answered
    expect(location.href).toBe("");
    expect(timers.map((t) => t.ms)).toEqual([1500]);

    frame.listeners.load();
    expect(frame.removed).toBe(true);
    expect(location.href).toBe("/sap/public/bc/icf/logoff");

    // the safety net firing afterwards is a no-op: one finish
    location.href = "";
    timers[0].fn();
    expect(location.href).toBe("");
  });

  test("the safety net redirects when the terminate never answers", () => {
    const { handlers, location, frames, timers } = load({
      pathname: "/sap/bc/bsp/sap/z2ui5/index.html",
    });
    handlers.SYSTEM_LOGOUT({}, ["SYSTEM_LOGOUT", "/sap/bc/logoff"]);
    expect(location.href).toBe("");

    timers[0].fn();
    expect(frames[0].removed).toBe(true);
    expect(location.href).toBe("/sap/bc/logoff");
    // ... and the late load event is the same no-op
    location.href = "";
    frames[0].listeners.load();
    expect(location.href).toBe("");
  });

  test("a refused logout URL still removes the iframe - no leak per attempt", () => {
    const { handlers, location, frames, boxErrors } = load({
      pathname: "/sap/bc/bsp/sap/z2ui5/index.html",
    });
    handlers.SYSTEM_LOGOUT({}, ["SYSTEM_LOGOUT", "https://evil.example/out"]);
    frames[0].listeners.load();
    expect(frames[0].removed).toBe(true);
    expect(location.href).toBe("");
    expect(boxErrors[0]).toContain("Invalid logout URL");
  });

  test("an iframe the document refuses is logged and the redirect still runs", () => {
    const env = load({ pathname: "/sap/bc/bsp/sap/z2ui5/index.html" });
    const { handlers, location, errors } = env;
    // body.appendChild throws (a document torn down mid-logout)
    env.bodyOps.push = () => {
      throw new Error("no body");
    };
    handlers.SYSTEM_LOGOUT({}, ["SYSTEM_LOGOUT"]);
    expect(errors()).toContain("SYSTEM_LOGOUT: BSP terminate iframe failed");
    expect(location.href).toBe("/sap/public/bc/icf/logoff");
  });
});

test.describe("PLAY_AUDIO", () => {
  test("a same-origin, a cross-origin http(s) and a data: source play", () => {
    const { handlers, audios, errors } = load();
    handlers.PLAY_AUDIO(null, ["PLAY_AUDIO", "/sounds/ping.mp3"]);
    handlers.PLAY_AUDIO(null, ["PLAY_AUDIO", "https://cdn.example/ping.mp3"]);
    handlers.PLAY_AUDIO(null, ["PLAY_AUDIO", "data:audio/mp3;base64,QQ=="]);
    expect(audios.map((a) => a.src)).toEqual([
      "/sounds/ping.mp3",
      "https://cdn.example/ping.mp3",
      "data:audio/mp3;base64,QQ==",
    ]);
    expect(errors()).toEqual([]);
  });

  test("an active scheme and an empty source are blocked before any Audio exists", () => {
    const { handlers, audios, errors } = load();
    handlers.PLAY_AUDIO(null, ["PLAY_AUDIO", "javascript:alert(1)"]);
    handlers.PLAY_AUDIO(null, ["PLAY_AUDIO", ""]);
    expect(audios).toEqual([]);
    expect(errors().filter((m) => m === "PLAY_AUDIO: blocked unsafe audio URL")).toHaveLength(2);
  });

  test("a play( ) rejected by the autoplay policy is logged, never unhandled", async () => {
    const { handlers, errors, setPlayResult } = load();
    setPlayResult(() => Promise.reject(new Error("NotAllowedError")));
    handlers.PLAY_AUDIO(null, ["PLAY_AUDIO", "/sounds/ping.mp3"]);
    await new Promise((r) => setTimeout(r, 0));
    expect(errors()).toContain("PLAY_AUDIO: failed for '/sounds/ping.mp3'");
  });

  test("a play( ) that throws synchronously is logged the same way", () => {
    const { handlers, errors, setPlayResult } = load();
    setPlayResult(() => {
      throw new Error("no audio device");
    });
    handlers.PLAY_AUDIO(null, ["PLAY_AUDIO", "/sounds/ping.mp3"]);
    expect(errors()).toContain("PLAY_AUDIO: failed for '/sounds/ping.mp3'");
  });

  test("a play( ) that answers nothing (an old engine) is fine", () => {
    const { handlers, errors, setPlayResult } = load();
    setPlayResult(() => undefined);
    handlers.PLAY_AUDIO(null, ["PLAY_AUDIO", "/sounds/ping.mp3"]);
    expect(errors()).toEqual([]);
  });
});

test.describe("HASH_BACK", () => {
  test("hands the back decision to the router, nothing else", () => {
    // the app-side onNavBack of a UI5 router app's back button: Router.navBack
    // owns the whole go(-1)-or-fallback decision (only the router touches the
    // hash), this handler only forwards
    const { handlers, navBacks, historyBacks, opened, boxErrors } = load();
    handlers.HASH_BACK({}, ["HASH_BACK"]);
    expect(navBacks).toEqual([undefined]);
    expect(historyBacks).toEqual([]);
    expect(opened).toEqual([]);
    expect(boxErrors).toEqual([]);
  });

  test("the optional fallback hash travels along", () => {
    const { handlers, navBacks } = load();
    handlers.HASH_BACK({}, ["HASH_BACK", "/home"]);
    expect(navBacks).toEqual(["/home"]);
  });
});

// The write half of the browser-storage pair; the read half is the
// cc/Storage control (node/tests/storage.spec.js). Both resolve the type
// the same way, which is the point: a write that lands in another store
// than the read is a value nobody ever sees again.
test.describe("STORE_DATA", () => {
  test("the type is matched case-insensitively", () => {
    const { handlers, stores } = load();
    handlers.STORE_DATA(null, [
      "STORE_DATA",
      { TYPE: "LOCAL", PREFIX: "p", KEY: "k", VALUE: "v" },
    ]);
    expect(stores).toHaveLength(1);
    expect(stores[0].storageType).toBe("local");
    expect(stores[0].ops).toEqual([["put", "k", "v"]]);
  });

  test("an unknown type is logged and written to the session store", () => {
    const { handlers, stores, errors } = load();
    handlers.STORE_DATA(null, [
      "STORE_DATA",
      { TYPE: "cookie", PREFIX: "p", KEY: "k", VALUE: "v" },
    ]);
    expect(stores[0].storageType).toBe("session");
    expect(errors().some((m) => m.includes("unknown type 'cookie'"))).toBe(
      true,
    );
  });

  test("an empty value removes the key instead of storing it", () => {
    const { handlers, stores, errors } = load();
    handlers.STORE_DATA(null, [
      "STORE_DATA",
      { TYPE: "session", PREFIX: "p", KEY: "k", VALUE: "" },
    ]);
    expect(stores[0].ops).toEqual([["remove", "k"]]);
    expect(errors()).toEqual([]);
  });

  // A follow-up action queued from a HANDLER carries the payload as the model
  // PATH of the structure: T_CUSTOM is pure data, so the `${/S_STORAGE}` that
  // a view wire has UI5 resolve at view-build time arrives here as a literal
  // string. Before it was read as a path, every field destructured to
  // undefined and the write was a silent no-op - the samples-controls
  // Shopping Cart demo wrote its cart on every change and stored nothing.
  const controllerWithModel = (data, tracked) => {
    const model = { getProperty: (path) => data[path] };
    const view = { getModel: () => (tracked ? undefined : model) };
    if (tracked) view.__tracked = model;
    return { getView: () => view };
  };

  for (const raw of ["${/S_STORAGE}", "{/S_STORAGE}", "/S_STORAGE"]) {
    test(`the payload '${raw}' is resolved against the view model`, () => {
      const { handlers, stores, errors } = load();
      const oController = controllerWithModel({
        "/S_STORAGE": { TYPE: "local", PREFIX: "", KEY: "CART", VALUE: { A: 1 } },
      });
      handlers.STORE_DATA(oController, ["STORE_DATA", raw]);
      expect(stores).toHaveLength(1);
      expect(stores[0].storageType).toBe("local");
      expect(stores[0].ops).toEqual([["put", "CART", { A: 1 }]]);
      expect(errors()).toEqual([]);
    });
  }

  test("the TRACKED model wins over the default one", () => {
    const { handlers, stores } = load();
    const oController = controllerWithModel(
      { "/S_STORAGE": { TYPE: "local", PREFIX: "", KEY: "CART", VALUE: "v" } },
      true,
    );
    handlers.STORE_DATA(oController, ["STORE_DATA", "${/S_STORAGE}"]);
    expect(stores[0].ops).toEqual([["put", "CART", "v"]]);
  });

  test("a string that is no model path is logged, not written", () => {
    const { handlers, stores, errors } = load();
    handlers.STORE_DATA(controllerWithModel({}), ["STORE_DATA", "S_STORAGE"]);
    expect(stores).toEqual([]);
    expect(
      errors().some((m) =>
        m.includes("is neither a payload nor a model path"),
      ),
    ).toBe(true);
  });

  test("a path with nothing bound under it is logged, not written", () => {
    const { handlers, stores, errors } = load();
    handlers.STORE_DATA(controllerWithModel({}), ["STORE_DATA", "${/NOPE}"]);
    expect(stores).toEqual([]);
    expect(
      errors().some((m) => m.includes("nothing bound at the model path")),
    ).toBe(true);
  });
});

test.describe("DOWNLOAD_B64_FILE", () => {
  test("a javascript: URL is blocked before any anchor exists", () => {
    const { handlers, anchors, errors } = load();

    handlers.DOWNLOAD_B64_FILE(null, [
      "DOWNLOAD_B64_FILE",
      "javascript:alert(1)",
      "x.txt",
    ]);

    expect(anchors).toHaveLength(0);
    expect(errors()).toContain("DOWNLOAD_B64_FILE: blocked unsafe URL");
  });

  // data: passes the protocol guard on purpose (generated downloads), so
  // the MIME block is the line of defense against a drive-by: active HTML
  // behind an attacker-chosen .html filename.
  test("an active data: MIME type (text/html) is blocked", () => {
    const { handlers, anchors, errors } = load();

    handlers.DOWNLOAD_B64_FILE(null, [
      "DOWNLOAD_B64_FILE",
      "data:text/html;base64,PHNjcmlwdD4=",
      "invoice.html",
    ]);

    expect(anchors).toHaveLength(0);
    expect(errors()).toContain(
      "DOWNLOAD_B64_FILE: blocked active data: MIME type",
    );
  });

  test("an octet-stream data: URL downloads via attach, click, remove", () => {
    const { handlers, anchors, bodyOps } = load();
    const url = "data:application/octet-stream;base64,QQ==";

    handlers.DOWNLOAD_B64_FILE(null, ["DOWNLOAD_B64_FILE", url, "report.pdf"]);

    expect(anchors).toHaveLength(1);
    const a = anchors[0];
    expect(a.href).toBe(url);
    expect(a.download).toBe("report.pdf");
    expect(a.clicks).toBe(1);
    // Firefox only honours the click while the anchor is in the document
    expect(bodyOps).toEqual([
      ["append", a],
      ["remove", a],
    ]);
  });

  test("the filename sanitizer neutralizes path separators and control chars", () => {
    const { handlers, anchors } = load();

    handlers.DOWNLOAD_B64_FILE(null, [
      "DOWNLOAD_B64_FILE",
      "data:application/pdf;base64,QQ==",
      'a\\b/c:d*e?f"g<h>i|jk.txt',
    ]);

    expect(anchors[0].download).toBe("a_b_c_d_e_f_g_h_i_j_k.txt");
  });

  test("a missing filename becomes '', never the string 'undefined'", () => {
    const { handlers, anchors } = load();

    handlers.DOWNLOAD_B64_FILE(null, [
      "DOWNLOAD_B64_FILE",
      "data:application/pdf;base64,QQ==",
    ]);

    expect(anchors[0].download).toBe("");
  });
});

test.describe("OPEN_NEW_TAB", () => {
  test("a same-origin URL opens in _blank with noopener and noreferrer", () => {
    const { handlers, opened, boxErrors } = load();

    expect(() =>
      handlers.OPEN_NEW_TAB(null, ["OPEN_NEW_TAB", "/sap/z2ui5?app=demo"]),
    ).not.toThrow();

    expect(boxErrors).toHaveLength(0);
    expect(opened).toHaveLength(1);
    expect(opened[0].url).toBe("/sap/z2ui5?app=demo");
    expect(opened[0].target).toBe("_blank");
    // the new tab must not be able to reach back via window.opener, and
    // must not learn this page's URL (the draft id rides in its hash) -
    // both are the browser's job through the features string, and the
    // null the browser then returns is not touched
    expect(opened[0].features).toBe("noopener,noreferrer");
  });

  test("a cross-origin URL is refused with a MessageBox, nothing opens", () => {
    const { handlers, opened, boxErrors } = load();

    handlers.OPEN_NEW_TAB(null, ["OPEN_NEW_TAB", "https://evil.example/x"]);

    expect(opened).toHaveLength(0);
    expect(boxErrors).toHaveLength(1);
    expect(boxErrors[0]).toContain("Invalid URL");
  });

  test("a javascript: URL is refused the same way", () => {
    const { handlers, opened, boxErrors } = load();

    handlers.OPEN_NEW_TAB(null, ["OPEN_NEW_TAB", "javascript:alert(1)"]);

    expect(opened).toHaveLength(0);
    expect(boxErrors).toHaveLength(1);
  });
});

test.describe("URLHELPER", () => {
  // mailto:/sms:/tel: targets go to URLHelper as-is; a CR/LF smuggled into
  // a recipient or subject can inject extra headers in some mail clients.
  test("a CR/LF in any parameter blocks the call before URLHelper", () => {
    const { handlers, urlHelperCalls, errors } = load();

    handlers.URLHELPER(null, [
      "URLHELPER",
      "TRIGGER_EMAIL",
      { EMAIL: "a@b.c", SUBJECT: "hi\r\nBcc: everyone@evil.example" },
    ]);

    expect(urlHelperCalls).toHaveLength(0);
    expect(errors()).toContain("URLHELPER: blocked CR/LF in parameters");
  });

  test("TRIGGER_EMAIL hands the clean params to URLHelper in order", () => {
    const { handlers, urlHelperCalls } = load();

    handlers.URLHELPER(null, [
      "URLHELPER",
      "TRIGGER_EMAIL",
      {
        EMAIL: "a@b.c",
        SUBJECT: "report",
        BODY: "see attachment",
        CC: "c@b.c",
        BCC: "d@b.c",
        NEW_WINDOW: true,
      },
    ]);

    expect(urlHelperCalls).toEqual([
      [
        "triggerEmail",
        "a@b.c",
        "report",
        "see attachment",
        "c@b.c",
        "d@b.c",
        true,
      ],
    ]);
  });

  test("REDIRECT to an external https target is allowed", () => {
    const { handlers, urlHelperCalls, boxErrors } = load();

    handlers.URLHELPER(null, [
      "URLHELPER",
      "REDIRECT",
      { URL: "https://help.sap.com/abap2ui5", NEW_WINDOW: true },
    ]);

    expect(boxErrors).toHaveLength(0);
    expect(urlHelperCalls).toEqual([
      ["redirect", "https://help.sap.com/abap2ui5", true],
    ]);
  });

  test("REDIRECT with a javascript: URL is refused with a MessageBox", () => {
    const { handlers, urlHelperCalls, boxErrors } = load();

    handlers.URLHELPER(null, [
      "URLHELPER",
      "REDIRECT",

      { URL: "javascript:alert(1)" },
    ]);

    expect(urlHelperCalls).toHaveLength(0);
    expect(boxErrors).toHaveLength(1);
    expect(boxErrors[0]).toContain("Only http/https protocols are allowed");
  });

  test("an unknown sub-action is a silent no-op", () => {
    const { handlers, urlHelperCalls, boxErrors } = load();

    handlers.URLHELPER(null, ["URLHELPER", "TRIGGER_FAX", { TEL: "1" }]);

    expect(urlHelperCalls).toHaveLength(0);
    expect(boxErrors).toHaveLength(0);
  });
});
