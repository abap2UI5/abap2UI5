// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");
const { specContext, withBusy } = require("./loadLibModule");

// Tests Server's error routing outside the inner try/catches of readHttp:
// readHttp is fire-and-forget, so an unexpected throw between those inner
// handlers (header handling, session bookkeeping, the success handler) must
// reach the fatal overlay via the outer catch instead of rejecting the
// promise silently with the busy indicator left spinning. And a failure in
// the render phase goes through showRenderError, which is what makes the
// openui5 SDK hint (_checkSDKcompatibility) reachable at all - View1's own
// catch delegates here instead of always showing the generic overlay. At the
// end, the overlay's own two: that responseError always takes the busy
// indicator down, and what _checkSDKcompatibility answers for each SDK.

function okResponse(id) {
  return {
    ok: true,
    headers: { get: () => null },
    json: async () => ({ S_FRONT: { ID: id }, MODEL: {} }),
  };
}

function load({ confirmSent = () => {} } = {}) {
  const errors = [];
  const fetchCalls = [];
  const ctx = specContext({ oSentModel: null, url: "/url" });
  const appState = { state: ctx.state };

  const { module: Server } = loadModule("core/Server.js", {
    deps: {
      "z2ui5/core/Lib": withBusy({
        isValidContextId: () => false,
        logError: () => {},
        byteLength: (s) => s.length,
        lazyByteLength: (s) => () => s.length,
      }, { show: () => {}, hide: () => {} }),
      "z2ui5/core/Session": { confirmSent },
    },
    sandbox: {
      AbortController: class {
        constructor() {
          this.signal = { aborted: false };
        }
        abort() {
          this.signal.aborted = true;
        }
      },
      fetch: () => {
        let resolve;
        const promise = new Promise((res) => {
          resolve = res;
        });
        fetchCalls.push({ resolve });
        return promise;
      },
    },
  });

  Server.responseError = (_ctx, msg, title) => errors.push({ msg, title });
  return { Server, ctx, errors, fetchCalls, appState };
}

test("an unexpected throw after the inner handlers reaches the fatal overlay", async () => {
  const boom = new Error("confirmSent broke");
  const { Server, ctx, errors, fetchCalls } = load({
    confirmSent: () => {
      throw boom;
    },
  });

  const p = Server.readHttp(ctx, {});
  fetchCalls[0].resolve(okResponse("A"));
  await p; // must settle instead of rejecting unhandled

  expect(errors).toHaveLength(1);
  expect(errors[0].msg).toBe(boom);
});

test("with parallel requests only the winning one surfaces the throw - one overlay", async () => {
  // The stale request returns at its isStale guard before ever reaching the
  // commit section, so a throwing confirmSent can only fire for the winner.
  const { Server, ctx, errors, fetchCalls } = load({
    confirmSent: () => {
      throw new Error("commit boom");
    },
  });

  const pA = Server.readHttp(ctx, {}); // seq 1 - superseded
  const pB = Server.readHttp(ctx, {}); // seq 2 -> newest
  fetchCalls[0].resolve(okResponse("A"));
  fetchCalls[1].resolve(okResponse("B"));
  await Promise.all([pA, pB]);

  expect(errors).toHaveLength(1);
  expect(`${errors[0].msg}`).toContain("commit boom");
});

test("a rejection escaping _processAfterRendering lands in responseSuccess's catch", async () => {
  const { Server, ctx, errors } = load();
  const boom = new Error("render broke");
  const controller = {
    _processAfterRendering: async () => {
      throw boom;
    },
  };
  const { module: ServerWithSlots } = loadModule("core/Server.js", {
    deps: {
      "z2ui5/core/Lib": withBusy({ logError: () => {} }, { show: () => {}, hide: () => {} }),
      "z2ui5/core/ViewSlots": { getController: () => controller },
    },
  });
  ServerWithSlots.responseError = Server.responseError;

  await ServerWithSlots.responseSuccess(ctx, {}, 1);

  expect(errors).toHaveLength(1);
  expect(errors[0].msg).toBe(boom);
});

test("showRenderError routes an openui5 script-load error to the SDK hint", () => {
  const { Server, ctx, errors } = load();
  const sdkCalls = [];
  Server._checkSDKcompatibility = (_ctx, e) => sdkCalls.push(e);

  const sdkError = new Error(
    "failed to load 'sap/x' from https://sdk.openui5.org: script load error",
  );
  Server.showRenderError(ctx, sdkError, "title");
  expect(sdkCalls).toEqual([sdkError]);
  expect(errors).toHaveLength(0);

  const other = new Error("anything else");
  Server.showRenderError(ctx, other, "App Terminated");
  expect(errors).toEqual([{ msg: other, title: "App Terminated" }]);
});

// ---------------------------------------------------------------------
// The REAL responseError (the specs above stub it) and the REAL
// _checkSDKcompatibility, with only what lies below them stubbed: the busy
// indicator (through the real Lib.showBusy / hideBusy, withBusy), the
// fatal-error overlay (core/ErrorView) and sap/ui/VersionInfo.
// ---------------------------------------------------------------------

function loadWithOverlay({ versionInfo, fetchImpl } = {}) {
  const busy = [];
  const overlays = [];
  const logged = [];
  const ctx = specContext({ oSentModel: null, url: "/url" });
  const { module: Server } = loadModule("core/Server.js", {
    deps: {
      "z2ui5/core/Lib": withBusy(
        {
          isValidContextId: () => false,
          logError: (msg) => logged.push(msg),
          byteLength: (s) => s.length,
          lazyByteLength: (s) => () => s.length,
          cancelPendingTimers: () => {},
        },
        { show: () => busy.push("show"), hide: () => busy.push("hide") },
      ),
      "z2ui5/core/Session": { confirmSent: () => {} },
      "z2ui5/core/ErrorView": {
        show: (_ctx, response, title, options) =>
          overlays.push({ response, title, options }),
        reset: () => {},
      },
      "sap/ui/VersionInfo": versionInfo,
    },
    sandbox: {
      AbortController: class {
        constructor() {
          this.signal = { aborted: false };
        }
        abort() {
          this.signal.aborted = true;
        }
      },
      fetch: fetchImpl || (() => Promise.reject(new TypeError("Failed to fetch"))),
    },
  });
  return { Server, ctx, busy, overlays, logged };
}

test.describe("responseError takes the busy indicator down", () => {
  test("called directly while a roundtrip shows it", () => {
    const { Server, ctx, busy, overlays } = loadWithOverlay();
    ctx.state.isBusy = true;
    busy.push("show");

    Server.responseError(ctx, "boom");

    expect(busy.at(-1)).toBe("hide");
    expect(ctx.state.isBusy).toBe(false);
    expect(overlays).toHaveLength(1);
  });

  test("on every path into it: a network failure, a render error, a failed SDK probe", async () => {
    const { Server, ctx, busy, overlays } = loadWithOverlay({
      versionInfo: {
        load: async () => {
          throw new Error("no sap-ui-version.json");
        },
      },
    });

    // the roundtrip shows the indicator, the fetch fails
    ctx.state.isBusy = true;
    busy.push("show");
    await Server.readHttp(ctx, {});
    expect(overlays).toHaveLength(1);
    expect(busy.at(-1)).toBe("hide");

    // a view that failed to render
    busy.push("show");
    Server.showRenderError(ctx, new Error("render broke"));
    expect(overlays).toHaveLength(2);
    expect(busy.at(-1)).toBe("hide");

    // an openui5 script-load error whose SDK cannot be determined
    busy.push("show");
    await Server._checkSDKcompatibility(ctx, new Error("x: script load error"));
    expect(overlays).toHaveLength(3);
    expect(busy.at(-1)).toBe("hide");
  });

  test("on a host's page it is the component's own busy state that goes", () => {
    const { Server, ctx, busy } = loadWithOverlay();
    const calls = [];
    const root = {
      setBusyIndicatorDelay: () => {},
      setBusy: (value) => calls.push(value),
    };
    ctx.state.ownsPage = false;
    ctx.state.oApp = root;

    Server.responseError(ctx, "boom");

    expect(calls).toEqual([false]);
    // the page-wide indicator is the host's: left alone
    expect(busy).toEqual([]);
  });
});

// _checkSDKcompatibility answers a view that failed to load a module: on
// openui5 the overlay names the module openui5 does not have, on SAPUI5 the
// original error is shown, and when VersionInfo cannot be read the original
// error is shown as well - never swallowed.
test.describe("_checkSDKcompatibility", () => {
  const loadError = () =>
    new Error(
      "failed to load 'sap/ndc/BarcodeScannerButton.js' from https://sdk.openui5.org: script load error",
    );

  test("on openui5: names the module openui5 lacks", async () => {
    const { Server, ctx, overlays } = loadWithOverlay({
      versionInfo: {
        load: async () => ({ gav: "com.sap.openui5.dist:sdk:1.144.0:war" }),
      },
    });

    await Server._checkSDKcompatibility(ctx, loadError());

    expect(overlays).toHaveLength(1);
    expect(overlays[0].response).toBe(
      "openui5 SDK is loaded, module: sap/ndc/BarcodeScannerButton.js is not available in openui5",
    );
  });

  test("on SAPUI5: the original error, not the openui5 hint", async () => {
    const { Server, ctx, overlays } = loadWithOverlay({
      versionInfo: {
        load: async () => ({ gav: "com.sap.ui5.dist:sdk:1.144.0:war" }),
      },
    });
    const err = loadError();

    await Server._checkSDKcompatibility(ctx, err);

    expect(overlays).toHaveLength(1);
    expect(overlays[0].response).toBe(err);
  });

  test("VersionInfo.load throws: the original error, logged and shown", async () => {
    const { Server, ctx, overlays, logged } = loadWithOverlay({
      versionInfo: {
        load: async () => {
          throw new Error("no sap-ui-version.json");
        },
      },
    });
    const err = loadError();

    await Server._checkSDKcompatibility(ctx, err);

    expect(overlays).toHaveLength(1);
    expect(overlays[0].response).toBe(err);
    expect(logged).toContain("_checkSDKcompatibility: VersionInfo.load failed");
  });
});
