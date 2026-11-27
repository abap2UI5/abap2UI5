// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");
const { specContext } = require("./loadLibModule");
const { fakeDocument } = require("./fakeDocument");

// Tests the real implementation shipped in
// bundle/webapp/devtools/AbapSource.js - the running app's ABAP class as the
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
  endpoint = null,
  endpointPrefix = null,
} = {}) {
  const ctx = specContext({ responseData, oBody, endpoint, endpointPrefix });
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

  // An embedded component may talk to a system on ANOTHER origin
  // (componentData.endpoint, Component.init): ADT lives next to the service
  // node, not next to the host page - built from the page's origin the url
  // 404ed there and the tab stayed blank
  test("takes the origin of the endpoint when the app talks to another origin", () => {
    const { AbapSource, ctx } = loadAbapSource({
      responseData: { S_FRONT: { APP } },
      endpoint: "https://abap.example.com:44300/sap/bc/z2ui5",
      windowStub: {
        location: {
          origin: "https://portal.example.com",
          href: "https://portal.example.com/host/index.html",
        },
        open() {},
      },
    });
    expect(AbapSource.sourceUrl(ctx)).toBe(
      "https://abap.example.com:44300/sap/bc/adt/oo/classes/Z2UI5_CL_MY_APP/source/main",
    );
  });

  test("a relative endpoint keeps the page's origin", () => {
    const { AbapSource, ctx } = loadAbapSource({
      responseData: { S_FRONT: { APP } },
      endpoint: "/proxy/sap/bc/z2ui5",
      windowStub: {
        location: {
          origin: "https://sap.example.com",
          href: "https://sap.example.com/index.html",
        },
        open() {},
      },
    });
    expect(AbapSource.sourceUrl(ctx)).toBe(EXPECTED_URL);
  });

  // Behind a proxy with a path prefix (the Work Zone destination proxy, an
  // approuter route) the system is reached through that prefix: the origin
  // alone left the proxy, and the tab, the ADT link and the source in Report
  // a Bug came back blank. state.endpointPrefix is what Component.init
  // derived - the Websocket control and the resource roots use the same.
  test("puts the proxy's path prefix in front, as the Websocket control does", () => {
    const page = {
      location: {
        origin: "https://portal.example.com",
        href: "https://portal.example.com/site/index.html",
      },
      open() {},
    };
    const prefixed = loadAbapSource({
      responseData: { S_FRONT: { APP } },
      endpoint: "/dynamic_dest/ABAP/sap/bc/z2ui5",
      endpointPrefix: "/dynamic_dest/ABAP",
      windowStub: page,
    });
    expect(prefixed.AbapSource.sourceUrl(prefixed.ctx)).toBe(
      "https://portal.example.com/dynamic_dest/ABAP/sap/bc/adt/oo/classes/Z2UI5_CL_MY_APP/source/main",
    );

    // a prefix on another origin carries that origin
    const remote = loadAbapSource({
      responseData: { S_FRONT: { APP } },
      endpoint: "https://abap.example.com/route/sap/bc/z2ui5",
      endpointPrefix: "https://abap.example.com/route",
      windowStub: page,
    });
    expect(remote.AbapSource.sourceUrl(remote.ctx)).toBe(
      "https://abap.example.com/route/sap/bc/adt/oo/classes/Z2UI5_CL_MY_APP/source/main",
    );
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
    AbapSource._setCache({ url: EXPECTED_URL, source: "..." });
    expect(AbapSource.adtUrl(ctx)).toBe(`${EXPECTED_URL}#start=17,1`);
  });

  test("stays on the plain url when the event name is not found", () => {
    const { AbapSource, ctx } = loadAbapSource({
      responseData: { S_FRONT: { APP } },
      oBody: { S_FRONT: { EVENT: "SAVE" } },
      eventLine: 0,
    });
    AbapSource._setCache({ url: EXPECTED_URL, source: "..." });
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
    AbapSource._setCache({
      url: EXPECTED_URL.replace(APP, "ZCL_OTHER"),
      source: "...",
    });
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

  // The class is edited in ADT while the app runs: the Source tab asks
  // again every time it is opened, and the deep link and the export read
  // that fetch - the cache used to hold the first answer for the page's life
  test("a refresh asks again and replaces the cached source", async () => {
    let text = "CLASS zcl DEFINITION. \"v1";
    let calls = 0;
    const { AbapSource, ctx } = loadAbapSource({
      responseData: { S_FRONT: { APP } },
      fetchImpl: async () => {
        calls += 1;
        return { ok: true, text: async () => text };
      },
    });
    AbapSource._setCache(null);
    await AbapSource.fetchSource(ctx);
    text = "CLASS zcl DEFINITION. \"v2";
    expect(await AbapSource.fetchSource(ctx, { refresh: true })).toBe(text);
    expect(calls).toBe(2);
    expect(AbapSource.cachedSource(ctx)).toBe(text);
    // a refresh that fails keeps what the last one fetched
    const failing = loadAbapSource({
      responseData: { S_FRONT: { APP } },
      fetchImpl: async () => ({ ok: false, text: async () => "" }),
    });
    failing.AbapSource._setCache({ url: EXPECTED_URL, source: "kept" });
    expect(
      await failing.AbapSource.fetchSource(failing.ctx, { refresh: true }),
    ).toBe("");
    expect(failing.AbapSource.cachedSource(failing.ctx)).toBe("kept");
  });

  // Two components on one page may talk to two systems that both have a
  // class of that name: keyed by the name, the second showed the first
  // one's source
  test("the same class on another system is fetched, not taken from the cache", async () => {
    const asked = [];
    const fetchImpl = async (url) => {
      asked.push(url);
      return { ok: true, text: async () => `source of ${new URL(url).host}` };
    };
    const { AbapSource, ctx } = loadAbapSource({
      responseData: { S_FRONT: { APP } },
      fetchImpl,
    });
    AbapSource._setCache(null);
    expect(await AbapSource.fetchSource(ctx)).toBe("source of sap.example.com");
    // the other component of the page, with an endpoint on another origin
    const other = { state: { ...ctx.state, endpoint: "https://abap.example.com/sap/bc/z2ui5" } };
    expect(AbapSource.cachedSource(other)).toBe(null);
    expect(await AbapSource.fetchSource(other)).toBe("source of abap.example.com");
    expect(asked.length).toBe(2);
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
