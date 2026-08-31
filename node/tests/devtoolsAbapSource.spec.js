// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");

// Tests the real implementation shipped in
// app/webapp/devtools/AbapSource.js - the running app's ABAP class as the
// developer tools reach it: the ADT source endpoint, the deep link at the
// line of the last event, and the frame for the inline preview.

function loadAbapSource({
  responseData = null,
  oBody = null,
  eventLine = 0,
  windowStub,
  fetchImpl,
} = {}) {
  const { module } = loadModule("devtools/AbapSource.js", {
    deps: {
      "z2ui5/core/AppState": { state: { responseData, oBody } },
      "z2ui5/devtools/Inspect": { findEventLine: () => eventLine },
    },
    sandbox: {
      fetch: fetchImpl,
      window: windowStub || {
        location: { origin: "https://sap.example.com" },
        open() {},
      },
    },
  });
  return module;
}

const APP = "Z2UI5_CL_MY_APP";
const EXPECTED_URL =
  "https://sap.example.com/sap/bc/adt/oo/classes/Z2UI5_CL_MY_APP/source/main";

test.describe("Source url", () => {
  test("builds the ADT source endpoint for the running app", () => {
    const AbapSource = loadAbapSource({ responseData: { S_FRONT: { APP } } });
    expect(AbapSource.sourceUrl()).toBe(EXPECTED_URL);
  });

  test("is empty when the app class name is unknown", () => {
    const AbapSource = loadAbapSource({ responseData: { S_FRONT: {} } });
    expect(AbapSource.sourceUrl()).toBe("");
    expect(AbapSource.appName()).toBe("");
  });

  test("frames the source for the inline preview", () => {
    const AbapSource = loadAbapSource({ responseData: { S_FRONT: { APP } } });
    expect(AbapSource.iframeHtml()).toContain(`src="${EXPECTED_URL}"`);
  });

  test("frames nothing when there is no class to frame", () => {
    expect(loadAbapSource({ responseData: { S_FRONT: {} } }).iframeHtml()).toBe(
      "",
    );
  });
});

test.describe("ADT deep link", () => {
  test("plain class url without a cached source", () => {
    const AbapSource = loadAbapSource({ responseData: { S_FRONT: { APP } } });
    AbapSource._setCache(null);
    expect(AbapSource.adtUrl()).toBe(EXPECTED_URL);
  });

  // The inspector resolves the line; this module only has to turn it into
  // the anchor the ADT source endpoint understands.
  test("deep links at the event's line once the source is cached", () => {
    const AbapSource = loadAbapSource({
      responseData: { S_FRONT: { APP } },
      oBody: { S_FRONT: { EVENT: "SAVE" } },
      eventLine: 17,
    });
    AbapSource._setCache({ app: APP, source: "..." });
    expect(AbapSource.adtUrl()).toBe(`${EXPECTED_URL}#start=17,1`);
  });

  test("stays on the plain url when the event name is not found", () => {
    const AbapSource = loadAbapSource({
      responseData: { S_FRONT: { APP } },
      oBody: { S_FRONT: { EVENT: "SAVE" } },
      eventLine: 0,
    });
    AbapSource._setCache({ app: APP, source: "..." });
    expect(AbapSource.adtUrl()).not.toContain("#start=");
  });

  test("ignores a source cached for a different app class", () => {
    // a navigation swaps the app under the tools; the cached source must
    // not be attributed to the new one
    const AbapSource = loadAbapSource({
      responseData: { S_FRONT: { APP } },
      oBody: { S_FRONT: { EVENT: "SAVE" } },
      eventLine: 17,
    });
    AbapSource._setCache({ app: "ZCL_OTHER", source: "..." });
    expect(AbapSource.adtUrl()).not.toContain("#start=");
  });
});

test.describe("Opening in ADT", () => {
  test("opens the source top-level in a new tab", () => {
    const opened = [];
    const AbapSource = loadAbapSource({
      responseData: { S_FRONT: { APP } },
      windowStub: {
        location: { origin: "https://sap.example.com" },
        open: (url, target, features) => opened.push({ url, target, features }),
      },
    });
    AbapSource._setCache(null);
    AbapSource.openInAdt();
    // noopener keeps the new tab from reaching back into window.opener
    expect(opened).toEqual([
      { url: EXPECTED_URL, target: "_blank", features: "noopener,noreferrer" },
    ]);
  });

  test("does nothing when the app class name is unknown", () => {
    const opened = [];
    const AbapSource = loadAbapSource({
      responseData: { S_FRONT: {} },
      windowStub: {
        location: { origin: "https://sap.example.com" },
        open: (url) => opened.push(url),
      },
    });
    expect(AbapSource.openInAdt()).toBe(undefined);
    expect(opened).toEqual([]);
  });
});

test.describe("Fetching the source", () => {
  test("returns the class text and caches it per app class", async () => {
    let calls = 0;
    const AbapSource = loadAbapSource({
      responseData: { S_FRONT: { APP } },
      fetchImpl: async () => {
        calls += 1;
        return { ok: true, text: async () => "CLASS zcl DEFINITION." };
      },
    });
    AbapSource._setCache(null);
    expect(await AbapSource.fetchSource()).toBe("CLASS zcl DEFINITION.");
    // the ABAP Source view warms it, the ADT jump and the export read it -
    // one answer, one request
    expect(await AbapSource.fetchSource()).toBe("CLASS zcl DEFINITION.");
    expect(calls).toBe(1);
  });

  test("degrades to empty when the endpoint refuses", async () => {
    // the endpoint needs an authenticated, ADT-enabled session, which is
    // not always there - the export must still work without it
    const AbapSource = loadAbapSource({
      responseData: { S_FRONT: { APP } },
      fetchImpl: async () => ({ ok: false, text: async () => "denied" }),
    });
    AbapSource._setCache(null);
    expect(await AbapSource.fetchSource()).toBe("");
  });

  test("never throws when the request itself fails", async () => {
    const AbapSource = loadAbapSource({
      responseData: { S_FRONT: { APP } },
      fetchImpl: async () => {
        throw new Error("network down");
      },
    });
    AbapSource._setCache(null);
    expect(await AbapSource.fetchSource()).toBe("");
  });

  test("does not call out at all without a class name", async () => {
    let calls = 0;
    const AbapSource = loadAbapSource({
      responseData: { S_FRONT: {} },
      fetchImpl: async () => {
        calls += 1;
        return { ok: true, text: async () => "" };
      },
    });
    expect(await AbapSource.fetchSource()).toBe("");
    expect(calls).toBe(0);
  });
});
