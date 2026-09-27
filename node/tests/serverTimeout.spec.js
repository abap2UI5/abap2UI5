// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");
const { specContext } = require("./loadLibModule");

// Tests Server.createTimeoutSignal: the client-side roundtrip timeout must
// work both with native AbortSignal.timeout and on older browsers via the
// manual AbortController + setTimeout fallback - and what the abort it
// fires turns into (the second block): the fetch rejects, readHttp reports
// the timeout with a Retry, and the Retry re-sends the same request.

function loadServer(sandbox) {
  return loadModule("core/Server.js", { sandbox }).module;
}

test("uses AbortSignal.timeout when available", () => {
  const Server = loadServer({
    AbortSignal: { timeout: (ms) => ({ native: true, ms }) },
  });

  const { signal, cancel } = Server.createTimeoutSignal(5000);

  expect(signal).toEqual({ native: true, ms: 5000 });
  expect(typeof cancel).toBe("function");
  expect(() => cancel()).not.toThrow();
});

test("falls back to AbortController + setTimeout without AbortSignal.timeout", () => {
  let timeoutCb;
  let timeoutMs;
  let clearedHandle;
  class FakeAbortController {
    constructor() {
      this.signal = { aborted: false };
    }
    abort() {
      this.signal.aborted = true;
    }
  }
  const Server = loadServer({
    AbortSignal: {}, // no .timeout - the pre-2022 browser case
    AbortController: FakeAbortController,
    setTimeout: (cb, ms) => {
      timeoutCb = cb;
      timeoutMs = ms;
      return 42;
    },
    clearTimeout: (handle) => {
      clearedHandle = handle;
    },
  });

  const { signal, cancel } = Server.createTimeoutSignal(1000);

  expect(timeoutMs).toBe(1000);
  expect(signal.aborted).toBe(false);

  // The timer firing must abort the signal - this is the hung-connection
  // backstop that was previously silently disabled on older browsers.
  timeoutCb();
  expect(signal.aborted).toBe(true);

  // cancel releases the timer so a settled roundtrip does not abort later.
  cancel();
  expect(clearedHandle).toBe(42);
});

// The abort path end to end: the timeout signal fires, fetch rejects with
// the TimeoutError (AbortSignal.timeout) or the AbortError (the manual
// fallback), and the user gets the timeout message with a Retry that
// re-arms the busy state and sends the identical body - the request may
// never have reached the server, so a restart would lose the edit.
test.describe("the abort -> responseError -> Retry path", () => {
  function loadForAbort() {
    const fetches = [];
    const errors = [];
    const busy = [];
    const ctx = specContext({ oSentModel: null, url: "/sap/z2ui5" });
    const { module: Server } = loadModule("core/Server.js", {
      deps: {
        "sap/ui/core/BusyIndicator": {
          show: (delay) => busy.push(["show", delay]),
          hide: () => busy.push(["hide"]),
        },
        "z2ui5/core/Lib": { isValidContextId: () => false },
        "z2ui5/core/Session": { confirmSent: () => {} },
        "z2ui5/core/ErrorView": { reset: () => {} },
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
        fetch: (url, opts) => {
          const call = { url, opts };
          call.promise = new Promise((resolve, reject) => {
            call.resolve = resolve;
            call.reject = reject;
          });
          fetches.push(call);
          return call.promise;
        },
      },
    });
    Server.responseSuccess = () => {};
    Server.responseError = (_ctx, msg, title, options) =>
      errors.push({ msg, title, options });
    return { Server, ctx, fetches, errors, busy };
  }

  for (const name of ["TimeoutError", "AbortError"]) {
    test(`a fetch rejected with ${name} reports the timeout, with a Retry`, async () => {
      const { Server, ctx, fetches, errors, busy } = loadForAbort();
      const body = { S_FRONT: { EVENT: "SAVE" }, MODEL: { A: 1 } };

      const p = Server.readHttp(ctx, body, { token: 1 });
      fetches[0].reject(Object.assign(new Error("signal aborted"), { name }));
      await p;

      expect(errors).toHaveLength(1);
      expect(errors[0].msg).toBe(
        "No backend response within 600 seconds - request aborted",
      );
      expect(typeof errors[0].options?.onRetry).toBe("function");

      // Retry: busy again (responseError cleared it, and an unguarded click
      // during the retry would abort it silently), the same body out again
      ctx.state.isBusy = false;
      errors[0].options.onRetry();
      expect(ctx.state.isBusy).toBe(true);
      expect(busy).toEqual([["show", 0]]);
      expect(fetches).toHaveLength(2);
      expect(fetches[1].opts.body).toBe(fetches[0].opts.body);
      expect(JSON.parse(fetches[1].opts.body)).toEqual({ value: body });
      fetches[1].reject(Object.assign(new Error("again"), { name }));
      await fetches[1].promise.catch(() => {});
      await new Promise((r) => setTimeout(r, 0));
      // a second timeout offers a second Retry - the request is still the same
      expect(errors).toHaveLength(2);
      expect(typeof errors[1].options?.onRetry).toBe("function");
    });
  }

  test("any other fetch failure is a network error, also with a Retry", async () => {
    const { Server, ctx, fetches, errors } = loadForAbort();
    const p = Server.readHttp(ctx, {}, null);
    fetches[0].reject(new TypeError("Failed to fetch"));
    await p;

    expect(errors[0].msg).toBe("Network error: Failed to fetch");
    expect(typeof errors[0].options?.onRetry).toBe("function");
  });

  test("the fetch is armed with the combined signal and the timer is released after", async () => {
    const released = [];
    const { Server, ctx, fetches } = loadForAbort();
    Server.createTimeoutSignal = () => ({
      signal: { aborted: false },
      cancel: () => released.push("cancel"),
    });
    const p = Server.readHttp(ctx, {}, null);
    expect(fetches[0].opts.signal).toBeDefined();
    expect(released).toEqual([]);
    fetches[0].reject(Object.assign(new Error("x"), { name: "TimeoutError" }));
    await p;
    // the finally releases the fallback timer whatever the outcome
    expect(released).toEqual(["cancel"]);
  });
});
