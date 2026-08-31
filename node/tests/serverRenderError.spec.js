// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");

// Tests Server's error routing outside the inner try/catches of readHttp:
// readHttp is fire-and-forget, so an unexpected throw between those inner
// handlers (header handling, session bookkeeping, the success handler) must
// reach the fatal overlay via the outer catch instead of rejecting the
// promise silently with the busy indicator left spinning. And a failure in
// the render phase goes through showRenderError, which is what makes the
// openui5 SDK hint (_checkSDKcompatibility) reachable at all - View1's own
// catch delegates here instead of always showing the generic overlay.

function okResponse(id) {
  return {
    ok: true,
    headers: { get: () => null },
    json: async () => ({ S_FRONT: { ID: id, S_ACTION: {} }, MODEL: {} }),
  };
}

function load({ confirmSent = () => {} } = {}) {
  const errors = [];
  const fetchCalls = [];
  const appState = {
    getGlobal: (k) => (k === "url" ? "/url" : undefined),
    state: { oSentModel: null },
  };

  const { module: Server } = loadModule("core/Server.js", {
    deps: {
      "sap/ui/core/BusyIndicator": { show: () => {}, hide: () => {} },
      "z2ui5/core/Lib": {
        isValidContextId: () => false,
        logError: () => {},
      },
      "z2ui5/core/Session": { confirmSent },
      "z2ui5/core/AppState": appState,
    },
    sandbox: {
      AbortSignal: { any: () => ({}), timeout: () => ({}) },
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

  Server.responseError = (msg, title) => errors.push({ msg, title });
  return { Server, errors, fetchCalls, appState };
}

test("an unexpected throw after the inner handlers reaches the fatal overlay", async () => {
  const boom = new Error("confirmSent broke");
  const { Server, errors, fetchCalls } = load({
    confirmSent: () => {
      throw boom;
    },
  });

  const p = Server.readHttp({});
  fetchCalls[0].resolve(okResponse("A"));
  await p; // must settle instead of rejecting unhandled

  expect(errors).toHaveLength(1);
  expect(errors[0].msg).toBe(boom);
});

test("with parallel requests only the winning one surfaces the throw - one overlay", async () => {
  // The stale request returns at its isStale guard before ever reaching the
  // commit section, so a throwing confirmSent can only fire for the winner.
  const { Server, errors, fetchCalls } = load({
    confirmSent: () => {
      throw new Error("commit boom");
    },
  });

  const pA = Server.readHttp({}); // seq 1 - superseded
  const pB = Server.readHttp({}); // seq 2 -> newest
  fetchCalls[0].resolve(okResponse("A"));
  fetchCalls[1].resolve(okResponse("B"));
  await Promise.all([pA, pB]);

  expect(errors).toHaveLength(1);
  expect(`${errors[0].msg}`).toContain("commit boom");
});

test("a rejection escaping _processAfterRendering lands in responseSuccess's catch", async () => {
  const { Server, errors } = load();
  const boom = new Error("render broke");
  const controller = {
    _processAfterRendering: async () => {
      throw boom;
    },
  };
  const { module: ServerWithSlots } = loadModule("core/Server.js", {
    deps: {
      "sap/ui/core/BusyIndicator": { show: () => {}, hide: () => {} },
      "z2ui5/core/Lib": { logError: () => {} },
      "z2ui5/core/ViewSlots": { getController: () => controller },
      "z2ui5/core/AppState": { state: {} },
    },
  });
  ServerWithSlots.responseError = Server.responseError;

  await ServerWithSlots.responseSuccess({ S_ACTION: {} }, 1);

  expect(errors).toHaveLength(1);
  expect(errors[0].msg).toBe(boom);
});

test("showRenderError routes an openui5 script-load error to the SDK hint", () => {
  const { Server, errors } = load();
  const sdkCalls = [];
  Server._checkSDKcompatibility = (e) => sdkCalls.push(e);

  const sdkError = new Error(
    "failed to load 'sap/x' from https://sdk.openui5.org: script load error",
  );
  Server.showRenderError(sdkError, "title");
  expect(sdkCalls).toEqual([sdkError]);
  expect(errors).toHaveLength(0);

  const other = new Error("anything else");
  Server.showRenderError(other, "App Terminated");
  expect(errors).toEqual([{ msg: other, title: "App Terminated" }]);
});
