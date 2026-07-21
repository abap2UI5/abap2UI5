// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");

// Tests Server.readHttp request sequencing (last-write-wins). When parallel
// requests are allowed (check_allow_multi_req), responses can arrive out of
// order. Only the newest dispatched request may commit its result; a slower
// older response is dropped so it can never overwrite a newer view/caret/
// session id. In the default blocking mode only one request is in flight, so
// the single response always commits.

function defer() {
  let resolve, reject;
  const promise = new Promise((res, rej) => {
    resolve = res;
    reject = rej;
  });
  return { promise, resolve, reject };
}

function okResponse(id) {
  return {
    ok: true,
    headers: { get: () => null },
    json: async () => ({ S_FRONT: { ID: id, PARAMS: {} }, MODEL: {} }),
  };
}

// Fake AbortController that records whether it was aborted, so the specs can
// assert that a superseded request's fetch is actually cancelled.
class FakeAbortController {
  constructor() {
    this.aborted = false;
    this.signal = { aborted: false };
  }
  abort() {
    this.aborted = true;
    this.signal.aborted = true;
  }
}

function load() {
  const fetchCalls = [];
  const successes = [];
  const errors = [];
  const controllers = [];
  const appState = {
    getGlobal: (k) => (k === "url" ? "/url" : undefined),
    state: { xxChangedPaths: new Set() },
  };

  const { module: Server } = loadModule("core/Server.js", {
    deps: {
      "z2ui5/core/Lib": { isValidContextId: () => false },
      "z2ui5/core/AppState": appState,
    },
    sandbox: {
      AbortSignal: { any: () => ({}), timeout: () => ({}) },
      AbortController: class extends FakeAbortController {
        constructor() {
          super();
          controllers.push(this);
        }
      },
      fetch: (_url, opts) => {
        const d = defer();
        d.signal = opts?.signal;
        fetchCalls.push(d);
        return d.promise;
      },
    },
  });

  // Spy on the commit handlers instead of running the real render.
  Server.responseSuccess = (r) => successes.push(r);
  Server.responseError = (m) => errors.push(m);

  return { Server, fetchCalls, successes, errors, controllers, appState };
}

// Let queued microtasks (the awaits inside readHttp) run.
const flush = () => new Promise((r) => setTimeout(r, 0));

test("drops the older response when a newer request went out (older resolves first)", async () => {
  const { Server, fetchCalls, successes } = load();

  const pA = Server.readHttp({}); // seq 1
  const pB = Server.readHttp({}); // seq 2 -> newest

  fetchCalls[0].resolve(okResponse("A")); // older resolves first
  await flush();
  fetchCalls[1].resolve(okResponse("B"));
  await Promise.all([pA, pB]);

  expect(successes).toHaveLength(1);
  expect(successes[0].ID).toBe("B");
});

test("drops the older response when the newer one resolves first", async () => {
  const { Server, fetchCalls, successes } = load();

  const pA = Server.readHttp({}); // seq 1
  const pB = Server.readHttp({}); // seq 2 -> newest

  fetchCalls[1].resolve(okResponse("B")); // newest resolves first
  await flush();
  fetchCalls[0].resolve(okResponse("A")); // stale, must be ignored
  await Promise.all([pA, pB]);

  expect(successes).toHaveLength(1);
  expect(successes[0].ID).toBe("B");
});

test("a superseded request's network error is swallowed (no overlay)", async () => {
  const { Server, fetchCalls, successes, errors } = load();

  const pA = Server.readHttp({}); // seq 1
  const pB = Server.readHttp({}); // seq 2 -> newest

  fetchCalls[0].reject(new Error("boom")); // stale request fails
  await flush();
  fetchCalls[1].resolve(okResponse("B"));
  await Promise.all([pA, pB]);

  expect(errors).toHaveLength(0); // stale failure not surfaced
  expect(successes).toHaveLength(1);
  expect(successes[0].ID).toBe("B");
});

test("dispatching a newer request aborts the older one still in flight", async () => {
  const { Server, fetchCalls, controllers } = load();

  const pA = Server.readHttp({}); // seq 1, controller[0]
  expect(controllers[0].aborted).toBe(false);

  const pB = Server.readHttp({}); // seq 2 -> aborts the older request
  expect(controllers[0].aborted).toBe(true); // A's fetch cancelled
  expect(controllers[1].aborted).toBe(false); // B stays live

  // A's fetch rejects with the abort; the stale guard swallows it silently.
  fetchCalls[0].reject(
    Object.assign(new Error("aborted"), { name: "AbortError" }),
  );
  fetchCalls[1].resolve(okResponse("B"));
  await Promise.all([pA, pB]);
});

test("a superseded response keeps the pending delta paths so the newest request carries them", async () => {
  const { Server, fetchCalls, successes, appState } = load();
  // A delta edit is pending (the /XX/ path the first request shipped).
  appState.state.xxChangedPaths = new Set(["/XX/PRODUCT"]);
  const pending = appState.state.xxChangedPaths;

  const pA = Server.readHttp({}); // seq 1 - carried /XX/PRODUCT
  const pB = Server.readHttp({}); // seq 2 - newest (also carried it, rebuilt)

  // The older response arrives but is stale: it must NOT clear the delta,
  // otherwise the edit would be lost once the newer request wins.
  fetchCalls[0].resolve(okResponse("A"));
  await flush();
  expect(appState.state.xxChangedPaths).toBe(pending); // untouched, still pending

  // Only the newest response commits and clears the accumulated delta.
  fetchCalls[1].resolve(okResponse("B"));
  await Promise.all([pA, pB]);
  expect(successes).toHaveLength(1);
  expect(appState.state.xxChangedPaths).not.toBe(pending);
  expect(appState.state.xxChangedPaths.size).toBe(0);
});

test("the single response commits in the default (non-parallel) case", async () => {
  const { Server, fetchCalls, successes } = load();

  const p = Server.readHttp({}); // seq 1, nothing newer
  fetchCalls[0].resolve(okResponse("only"));
  await p;

  expect(successes).toHaveLength(1);
  expect(successes[0].ID).toBe("only");
});
