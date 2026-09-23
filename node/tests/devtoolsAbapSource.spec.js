// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");
const { specContext } = require("./loadLibModule");
const { fakeDocument } = require("./fakeDocument");

// Tests the real implementation shipped in
// app/webapp/devtools/AbapSource.js - the running app's ABAP class as the
// developer tools reach it: the ADT source endpoint, the deep link at the
// line of the last event, and the frame for the inline preview.

// Which app runs is a fact of ONE component context (core/Context.js):
// every function takes it first and reads the last response off its state.
function loadAbapSource({
  responseData = null,
  oBody = null,
  eventLine = 0,
  windowStub,
  fetchImpl,
} = {}) {
  const ctx = specContext({ responseData, oBody });
  const { module } = loadModule("devtools/AbapSource.js", {
    deps: {
      "z2ui5/devtools/Inspect": { findEventLine: () => eventLine },
    },
    sandbox: {
      fetch: fetchImpl,
      // the inline preview is built as an element, not as a string
      document: fakeDocument(),
      window: windowStub || {
        location: { origin: "https://sap.example.com" },
        open() {},
      },
    },
  });
  return { AbapSource: module, ctx };
}

const APP = "Z2UI5_CL_MY_APP";
const EXPECTED_URL =
  "https://sap.example.com/sap/bc/adt/oo/classes/Z2UI5_CL_MY_APP/source/main";

test.describe("Source url", () => {
  test("builds the ADT source endpoint for the running app", () => {
    const { AbapSource, ctx } = loadAbapSource({ responseData: { S_FRONT: { APP } } });
    expect(AbapSource.sourceUrl(ctx)).toBe(EXPECTED_URL);
  });

  test("is empty when the app class name is unknown", () => {
    const { AbapSource, ctx } = loadAbapSource({ responseData: { S_FRONT: {} } });
    expect(AbapSource.sourceUrl(ctx)).toBe("");
    expect(AbapSource.appName(ctx)).toBe("");
  });

  test("frames the source for the inline preview", () => {
    const { AbapSource, ctx } = loadAbapSource({ responseData: { S_FRONT: { APP } } });
    const html = AbapSource.iframeHtml(ctx);
    expect(html).toContain(`src="${EXPECTED_URL}"`);
    expect(html).toMatch(/^<iframe .*><\/iframe>$/);
  });

  test("frames nothing when there is no class to frame", () => {
    const { AbapSource, ctx } = loadAbapSource({
      responseData: { S_FRONT: {} },
    });
    expect(AbapSource.iframeHtml(ctx)).toBe("");
  });
});

test.describe("ADT deep link", () => {
  test("plain class url without a cached source", () => {
    const { AbapSource, ctx } = loadAbapSource({ responseData: { S_FRONT: { APP } } });
    AbapSource._setCache(null);
    expect(AbapSource.adtUrl(ctx)).toBe(EXPECTED_URL);
  });

  // The inspector resolves the line; this module only has to turn it into
  // the anchor the ADT source endpoint understands.
  test("deep links at the event's line once the source is cached", () => {
    const { AbapSource, ctx } = loadAbapSource({
      responseData: { S_FRONT: { APP } },
      oBody: { S_FRONT: { EVENT: "SAVE" } },
      eventLine: 17,
    });
    AbapSource._setCache({ app: APP, source: "..." });
    expect(AbapSource.adtUrl(ctx)).toBe(`${EXPECTED_URL}#start=17,1`);
  });

  test("stays on the plain url when the event name is not found", () => {
    const { AbapSource, ctx } = loadAbapSource({
      responseData: { S_FRONT: { APP } },
      oBody: { S_FRONT: { EVENT: "SAVE" } },
      eventLine: 0,
    });
    AbapSource._setCache({ app: APP, source: "..." });
    expect(AbapSource.adtUrl(ctx)).not.toContain("#start=");
  });

  test("ignores a source cached for a different app class", () => {
    // a navigation swaps the app under the tools; the cached source must
    // not be attributed to the new one
    const { AbapSource, ctx } = loadAbapSource({
      responseData: { S_FRONT: { APP } },
      oBody: { S_FRONT: { EVENT: "SAVE" } },
      eventLine: 17,
    });
    AbapSource._setCache({ app: "ZCL_OTHER", source: "..." });
    expect(AbapSource.adtUrl(ctx)).not.toContain("#start=");
  });
});

test.describe("Opening in ADT", () => {
  test("opens the source top-level in a new tab", () => {
    const opened = [];
    const { AbapSource, ctx } = loadAbapSource({
      responseData: { S_FRONT: { APP } },
      windowStub: {
        location: { origin: "https://sap.example.com" },
        open: (url, target, features) => opened.push({ url, target, features }),
      },
    });
    AbapSource._setCache(null);
    AbapSource.openInAdt(ctx);
    // noopener keeps the new tab from reaching back into window.opener
    expect(opened).toEqual([
      { url: EXPECTED_URL, target: "_blank", features: "noopener,noreferrer" },
    ]);
  });

  test("does nothing when the app class name is unknown", () => {
    const opened = [];
    const { AbapSource, ctx } = loadAbapSource({
      responseData: { S_FRONT: {} },
      windowStub: {
        location: { origin: "https://sap.example.com" },
        open: (url) => opened.push(url),
      },
    });
    expect(AbapSource.openInAdt(ctx)).toBe(undefined);
    expect(opened).toEqual([]);
  });
});

test.describe("Fetching the source", () => {
  test("returns the class text and caches it per app class", async () => {
    let calls = 0;
    const { AbapSource, ctx } = loadAbapSource({
      responseData: { S_FRONT: { APP } },
      fetchImpl: async () => {
        calls += 1;
        return { ok: true, text: async () => "CLASS zcl DEFINITION." };
      },
    });
    AbapSource._setCache(null);
    expect(await AbapSource.fetchSource(ctx)).toBe("CLASS zcl DEFINITION.");
    // the ABAP Source view warms it, the ADT jump and the export read it -
    // one answer, one request
    expect(await AbapSource.fetchSource(ctx)).toBe("CLASS zcl DEFINITION.");
    expect(calls).toBe(1);
  });

  test("degrades to empty when the endpoint refuses", async () => {
    // the endpoint needs an authenticated, ADT-enabled session, which is
    // not always there - the export must still work without it
    const { AbapSource, ctx } = loadAbapSource({
      responseData: { S_FRONT: { APP } },
      fetchImpl: async () => ({ ok: false, text: async () => "denied" }),
    });
    AbapSource._setCache(null);
    expect(await AbapSource.fetchSource(ctx)).toBe("");
  });

  test("never throws when the request itself fails", async () => {
    const { AbapSource, ctx } = loadAbapSource({
      responseData: { S_FRONT: { APP } },
      fetchImpl: async () => {
        throw new Error("network down");
      },
    });
    AbapSource._setCache(null);
    expect(await AbapSource.fetchSource(ctx)).toBe("");
  });

  test("a failed fetch is retried, not remembered for the session", async () => {
    // one 401 before the developer has logged on to ADT used to leave
    // Report a Bug, Export and the ADT deep link sourceless for the rest
    // of the session - the failure was cached like an answer
    let ok = false;
    let calls = 0;
    const { AbapSource, ctx } = loadAbapSource({
      responseData: { S_FRONT: { APP } },
      fetchImpl: async () => {
        calls += 1;
        return { ok, text: async () => "CLASS zcl DEFINITION." };
      },
    });
    AbapSource._setCache(null);
    expect(await AbapSource.fetchSource(ctx)).toBe("");

    // the ADT logon happened in another tab; the next press must ask again
    ok = true;
    expect(await AbapSource.fetchSource(ctx)).toBe("CLASS zcl DEFINITION.");
    expect(calls).toBe(2);

    // and from there on the success is cached as before
    expect(await AbapSource.fetchSource(ctx)).toBe("CLASS zcl DEFINITION.");
    expect(calls).toBe(2);
  });

  test("does not call out at all without a class name", async () => {
    let calls = 0;
    const { AbapSource, ctx } = loadAbapSource({
      responseData: { S_FRONT: {} },
      fetchImpl: async () => {
        calls += 1;
        return { ok: true, text: async () => "" };
      },
    });
    expect(await AbapSource.fetchSource(ctx)).toBe("");
    expect(calls).toBe(0);
  });
});
