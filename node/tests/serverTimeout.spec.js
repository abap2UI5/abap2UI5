// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");
const { specContext } = require("./loadLibModule");

// Tests the abort plumbing of one request (Server._openRequest): ONE
// AbortController per request, armed by a setTimeout - the client-side
// roundtrip timeout - and by whatever supersedes the request, with a flag
// that tells the two apart. And what the timeout turns into: the fetch
// rejects, readHttp reports the timeout with a Retry, and the Retry
// re-sends the same request.
//
// Until 2026-11 the same job had three code paths - AbortSignal.timeout,
// AbortSignal.any and a manual fallback for browsers without them - and
// with AbortSignal.timeout the timer could not be released: every finished
// request left a 600 s timer behind.

function loadForAbort() {
  const fetches = [];
  const errors = [];
  const busy = [];
  const controllers = [];
  // the sandbox's timers, recorded: fire( ) is the timeout elapsing
  const timers = [];
  const ctx = specContext({ oSentModel: null, url: "/sap/z2ui5" });
  const { module: Server } = loadModule("core/Server.js", {
    deps: {
      "sap/ui/core/BusyIndicator": {
        show: (delay) => busy.push(["show", delay]),
        hide: () => busy.push(["hide"]),
      },
      "z2ui5/core/Lib": {
        isValidContextId: () => false,
        byteLength: (s) => s.length,
        lazyByteLength: (s) => () => s.length,
      },
      "z2ui5/core/Session": { confirmSent: () => {} },
      "z2ui5/core/ErrorView": { reset: () => {} },
    },
    // NO AbortSignal in the sandbox: the module must not reach for
    // AbortSignal.timeout / AbortSignal.any - a browser without them (they
    // came in 2022 and 2024) runs the very same path as one with them
    sandbox: {
      AbortController: class {
        constructor() {
          this.signal = { aborted: false };
          controllers.push(this);
        }
        abort() {
          this.signal.aborted = true;
        }
      },
      setTimeout: (cb, ms) => {
        timers.push({ cb, ms, cleared: false });
        return timers.length;
      },
      clearTimeout: (handle) => {
        if (timers[handle - 1]) timers[handle - 1].cleared = true;
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
  // the timeout of request n elapses: its timer fires, which aborts the
  // request - and the fetch rejects the way a real one does on an abort
  const elapse = (n) => {
    expect(timers[n].cleared).toBe(false);
    timers[n].cb();
    fetches[n]?.reject(
      Object.assign(new Error("signal is aborted without reason"), {
        name: "AbortError",
      }),
    );
  };
  return { Server, ctx, fetches, errors, busy, controllers, timers, elapse };
}

const okResponse = () => ({
  ok: true,
  status: 200,
  headers: { get: () => null },
  json: async () => ({ S_FRONT: { ID: "X" } }),
});

const TIMEOUT_TEXT = "No backend response within 600 seconds - request aborted";

test.describe("one request, one abort", () => {
  test("one controller and one timer per request, the controller's signal on the fetch", async () => {
    const { Server, ctx, fetches, controllers, timers } = loadForAbort();
    const p = Server.readHttp(ctx, {}, null);

    expect(controllers).toHaveLength(1);
    expect(timers).toHaveLength(1);
    expect(timers[0].ms).toBe(600000);
    expect(fetches[0].opts.signal).toBe(controllers[0].signal);
    expect(ctx.server.inflight.size).toBe(1);

    fetches[0].resolve(okResponse());
    await p;
  });

  test("the timer is released when the request settles - answered", async () => {
    // with AbortSignal.timeout nothing could release it: a timer of ten
    // minutes outlived every request that had long been answered
    const { Server, ctx, fetches, controllers, timers } = loadForAbort();
    const p = Server.readHttp(ctx, {}, null);
    expect(timers[0].cleared).toBe(false);
    fetches[0].resolve(okResponse());
    await p;

    expect(timers[0].cleared).toBe(true);
    expect(controllers[0].signal.aborted).toBe(false);
    expect(ctx.server.inflight.size).toBe(0);
  });

  test("the timer is released when the request settles - failed", async () => {
    const { Server, ctx, fetches, timers } = loadForAbort();
    const p = Server.readHttp(ctx, {}, null);
    fetches[0].reject(new TypeError("Failed to fetch"));
    await p;

    expect(timers[0].cleared).toBe(true);
    expect(ctx.server.inflight.size).toBe(0);
  });

  test("a superseded request is aborted and its timer released at once", async () => {
    // at once, not when its fetch settles: nobody waits for it any more,
    // so it has no timeout left to report
    const { Server, ctx, fetches, errors, controllers, timers } =
      loadForAbort();
    const pA = Server.readHttp(ctx, {}, null);
    const pB = Server.readHttp(ctx, {}, null);

    expect(controllers[0].signal.aborted).toBe(true);
    expect(timers[0].cleared).toBe(true);
    expect(controllers[1].signal.aborted).toBe(false);
    expect(timers[1].cleared).toBe(false);
    expect(ctx.server.inflight.size).toBe(1);

    // the abort rejects the older fetch - silently, the newer one owns
    // the outcome
    fetches[0].reject(
      Object.assign(new Error("aborted"), { name: "AbortError" }),
    );
    fetches[1].resolve(okResponse());
    await Promise.all([pA, pB]);
    expect(errors).toEqual([]);
    expect(timers[1].cleared).toBe(true);
    expect(ctx.server.inflight.size).toBe(0);
  });

  test("reset( ) aborts the request in flight and releases its timer", async () => {
    const { Server, ctx, fetches, errors, controllers, timers } =
      loadForAbort();
    const p = Server.readHttp(ctx, {}, null);
    Server.reset(ctx);

    expect(controllers[0].signal.aborted).toBe(true);
    expect(timers[0].cleared).toBe(true);
    expect(ctx.server.inflight.size).toBe(0);

    fetches[0].reject(
      Object.assign(new Error("aborted"), { name: "AbortError" }),
    );
    await p;
    // the teardown's own abort is no timeout
    expect(errors).toEqual([]);
  });

  test("a body that cannot be serialized opens no request at all", async () => {
    const { Server, ctx, fetches, controllers, timers } = loadForAbort();
    const arg = {};
    arg.self = arg;
    await Server.readHttp(ctx, { S_FRONT: { T_EVENT_ARG: [arg] } }, null);

    expect(fetches).toHaveLength(0);
    expect(controllers).toHaveLength(0);
    expect(timers).toHaveLength(0);
    expect(ctx.server.inflight.size).toBe(0);
  });
});

// The abort path end to end: the timer fires, the request is aborted, fetch
// rejects with the AbortError, and the user gets the timeout message with a
// Retry that re-arms the busy state and sends the identical body - the
// request may never have reached the server, so a restart would lose the
// edit.
test.describe("the timeout -> responseError -> Retry path", () => {
  test("the timeout aborts the request and is reported, with a Retry", async () => {
    const { Server, ctx, fetches, errors, busy, controllers, timers, elapse } =
      loadForAbort();
    const body = { S_FRONT: { EVENT: "SAVE" }, MODEL: { A: 1 } };

    const p = Server.readHttp(ctx, body, { token: 1 });
    elapse(0);
    await p;

    expect(controllers[0].signal.aborted).toBe(true);
    expect(errors).toHaveLength(1);
    expect(errors[0].msg).toBe(TIMEOUT_TEXT);
    expect(typeof errors[0].options?.onRetry).toBe("function");
    expect(ctx.server.inflight.size).toBe(0);

    // Retry: busy again (responseError cleared it, and an unguarded click
    // during the retry would abort it silently), the same body out again -
    // as a request of its own, with a controller and a timer of its own
    ctx.state.isBusy = false;
    errors[0].options.onRetry();
    expect(ctx.state.isBusy).toBe(true);
    expect(busy).toEqual([["show", 0]]);
    expect(fetches).toHaveLength(2);
    expect(fetches[1].opts.body).toBe(fetches[0].opts.body);
    expect(JSON.parse(fetches[1].opts.body)).toEqual({ value: body });
    expect(fetches[1].opts.signal).toBe(controllers[1].signal);
    expect(controllers[1].signal.aborted).toBe(false);
    expect(timers[1].cleared).toBe(false);

    elapse(1);
    await fetches[1].promise.catch(() => {});
    await new Promise((r) => setTimeout(r, 0));
    // a second timeout offers a second Retry - the request is still the same
    expect(errors).toHaveLength(2);
    expect(errors[1].msg).toBe(TIMEOUT_TEXT);
    expect(typeof errors[1].options?.onRetry).toBe("function");
  });

  test("the Retry takes up the repeating timer the overlay ended", async () => {
    // responseError (stubbed here, serverRequestSeq spec) hands the repeat
    // it ended to the Retry object; the Retry re-sends the same draft id,
    // and the backend sends no running declarative timer again
    // (z2ui5_cl_ui5_handler=>main_end_timer) - so the Retry restores it
    const { Server, ctx, errors, elapse } = loadForAbort();
    const p = Server.readHttp(ctx, {}, null);
    elapse(0);
    await p;
    const repeat = { event: "POLL", delay: 10 };
    expect(errors[0].options.timerRepeat).toBeNull();
    errors[0].options.timerRepeat = repeat;

    errors[0].options.onRetry();

    expect(ctx.state.timerRepeat).toBe(repeat);
    expect(errors[0].options.timerRepeat).toBeNull();
  });

  test("a timeout of a request a newer one superseded says nothing", async () => {
    // cannot happen through the timer - _abortInflight released it - but a
    // request that timed out in the very tick it was superseded is stale
    // first: the newer request owns the outcome
    const { Server, ctx, fetches, errors, timers } = loadForAbort();
    const pA = Server.readHttp(ctx, {}, null);
    timers[0].cb();
    const pB = Server.readHttp(ctx, {}, null);
    fetches[0].reject(
      Object.assign(new Error("aborted"), { name: "AbortError" }),
    );
    fetches[1].resolve(okResponse());
    await Promise.all([pA, pB]);

    expect(errors).toEqual([]);
  });

  // The timeout guards the body reads too: when it fires after the headers
  // arrived, response.json( ) / .text( ) reject with the abort. Their
  // catches used to read that as a broken body - "Invalid JSON response" or
  // "could not read error body", without a Retry and without the word
  // timeout.
  const aborted = () =>
    Object.assign(new Error("signal is aborted without reason"), {
      name: "AbortError",
    });

  test("a timeout while the JSON body is read reports the timeout, with a Retry", async () => {
    const { Server, ctx, fetches, errors, timers } = loadForAbort();
    const p = Server.readHttp(ctx, { S_FRONT: { EVENT: "SAVE" } }, null);
    fetches[0].resolve({
      ok: true,
      status: 200,
      headers: { get: () => null },
      json: async () => {
        timers[0].cb();
        throw aborted();
      },
    });
    await p;

    expect(errors).toHaveLength(1);
    expect(errors[0].msg).toBe(TIMEOUT_TEXT);
    expect(typeof errors[0].options?.onRetry).toBe("function");
  });

  test("a timeout while an error body is read reports the timeout, with a Retry", async () => {
    const { Server, ctx, fetches, errors, timers } = loadForAbort();
    const p = Server.readHttp(ctx, {}, null);
    fetches[0].resolve({
      ok: false,
      status: 500,
      headers: { get: () => null },
      text: async () => {
        timers[0].cb();
        throw aborted();
      },
    });
    await p;

    expect(errors).toHaveLength(1);
    expect(errors[0].msg).toBe(TIMEOUT_TEXT);
    expect(typeof errors[0].options?.onRetry).toBe("function");
  });

  test("a broken body without a timeout is still reported as such", async () => {
    const { Server, ctx, fetches, errors } = loadForAbort();
    const p = Server.readHttp(ctx, {}, null);
    fetches[0].resolve({
      ok: true,
      status: 200,
      headers: { get: () => null },
      json: async () => {
        throw new SyntaxError("Unexpected token <");
      },
    });
    await p;

    expect(errors[0].msg).toBe("Invalid JSON response: Unexpected token <");
    expect(errors[0].options).toBeUndefined();
  });

  test("any other fetch failure is a network error, also with a Retry", async () => {
    const { Server, ctx, fetches, errors } = loadForAbort();
    const p = Server.readHttp(ctx, {}, null);
    fetches[0].reject(new TypeError("Failed to fetch"));
    await p;

    expect(errors[0].msg).toMatch(/^Network error: Failed to fetch - /);
    // the browser says no more than "Failed to fetch" - name the usual causes
    expect(errors[0].msg).toContain("expired logon session");
    expect(errors[0].msg).toContain("CORS");
    expect(errors[0].msg).toContain("offline");
    expect(typeof errors[0].options?.onRetry).toBe("function");
  });

  test("a failure that is no TypeError keeps its own message, without the hint", async () => {
    const { Server, ctx, fetches, errors } = loadForAbort();
    const p = Server.readHttp(ctx, {}, null);
    fetches[0].reject(new Error("something else"));
    await p;

    expect(errors[0].msg).toBe("Network error: something else");
  });

  test("an abort that is neither the timeout nor a supersede is not called a timeout", async () => {
    // the request asks its own flag, not the error's name: what aborts a
    // fetch that is still the newest and has not timed out is the browser
    // itself (a page being left) - a network failure with a Retry, not
    // "no backend response within 600 seconds" after two
    const { Server, ctx, fetches, errors, timers } = loadForAbort();
    const p = Server.readHttp(ctx, {}, null);
    fetches[0].reject(
      Object.assign(new Error("The operation was aborted."), {
        name: "AbortError",
      }),
    );
    await p;

    expect(errors).toHaveLength(1);
    expect(errors[0].msg).toBe("Network error: The operation was aborted.");
    expect(typeof errors[0].options?.onRetry).toBe("function");
    expect(timers[0].cleared).toBe(true);
  });
});
