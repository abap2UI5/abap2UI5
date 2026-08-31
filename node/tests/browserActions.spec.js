// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");
const { loadLib } = require("./loadLibModule");

// Tests the URL-shaped handlers of core/actions/Browser.js - the actions
// that can navigate away or hand data out of the app, through the REAL
// Lib validators (loadLibModule), so what is pinned here is the shipped
// guard chain, not a stub's opinion of it:
//   DOWNLOAD_B64_FILE  protocol guard, active data: MIME block, filename
//                      sanitizer, the attach-click-remove anchor dance
//   OPEN_NEW_TAB       same-origin guard, opener cleared on the new tab
//   URLHELPER          CR/LF header-injection block, REDIRECT protocol
//                      guard (external http/https allowed, schemes not)
function load() {
  // The real Lib: its sandbox origin anchors the same-origin checks.
  const { Lib, sandbox: libSandbox } = loadLib();

  const boxErrors = [];
  const urlHelperCalls = [];
  const anchors = [];
  const bodyOps = [];
  const opened = [];

  const historyBacks = [];
  const navBacks = [];
  const documentStub = {
    createElement: (tag) => {
      const el = {
        tagName: tag.toUpperCase(),
        href: "",
        download: undefined,
        clicks: 0,
        click() {
          this.clicks += 1;
        },
      };
      if (tag === "a") anchors.push(el);
      return el;
    },
    body: {
      appendChild: (el) => bodyOps.push(["append", el]),
      removeChild: (el) => bodyOps.push(["remove", el]),
    },
  };

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
      "sap/ui/util/Storage": function () {},
      "z2ui5/core/Router": {
        navBack: (fallback) => navBacks.push(fallback),
      },
      "z2ui5/core/Lib": Lib,
      "z2ui5/core/AppState": { state: {} },
    },
    sandbox: {
      document: documentStub,
      window: {
        // same origin the real Lib resolves against (loadLibModule)
        location: { origin: "http://localhost:3000", pathname: "/sap/z2ui5" },
        history: { back: () => historyBacks.push(1) },
        open: (url, target) => {
          const win = { opener: "the-parent-window" };
          opened.push({ url, target, win });
          return win;
        },
      },
    },
  });

  return {
    handlers: Browser.handlers,
    historyBacks,
    navBacks,
    anchors,
    bodyOps,
    opened,
    boxErrors,
    urlHelperCalls,
    errors: () => (libSandbox.z2ui5.errors || []).map((e) => e.message),
  };
}

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
  test("a same-origin URL opens in _blank with the opener cleared", () => {
    const { handlers, opened, boxErrors } = load();

    handlers.OPEN_NEW_TAB(null, ["OPEN_NEW_TAB", "/sap/z2ui5?app=demo"]);

    expect(boxErrors).toHaveLength(0);
    expect(opened).toHaveLength(1);
    expect(opened[0].url).toBe("/sap/z2ui5?app=demo");
    expect(opened[0].target).toBe("_blank");
    // the new tab must not be able to reach back via window.opener
    expect(opened[0].win.opener).toBe(null);
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
