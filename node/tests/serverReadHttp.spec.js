// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");
const { specContext, loadLib } = require("./loadLibModule");

// Server.readHttp's ANSWER side - what a response that is not a good one
// turns into. Every branch ends in responseError with a message the user
// can read, and one of them also with a Retry:
//   HTTP != 2xx      the body as the error text, the status when the body is
//                    empty or unreadable; Retry on a 502/503/504 (the gateway
//                    or dispatcher answering for a backend that did not - the
//                    request may never have reached it), never on a 500 (the
//                    backend itself, a dump - re-sending would dump again)
//   invalid JSON     "Invalid JSON response: ..."
//   no S_FRONT       "Invalid response: missing S_FRONT"
//   PROTOCOL         a number that is present and differs is reported; an
//                    absent one is a backend older than the field and let
//                    through
// The sequencing (a stale response is dropped) is serverRequestSeq.spec.js,
// the timeout abort serverTimeout.spec.js.

function response({
  ok = true,
  status = 200,
  text = "",
  json,
  headers = {},
  textThrows = false,
} = {}) {
  return {
    ok,
    status,
    headers: { get: (name) => headers[name] ?? null },
    text: async () => {
      if (textThrows) throw new Error("stream reset");
      return text;
    },
    json: async () => {
      if (json === undefined) throw new SyntaxError("Unexpected token <");
      return json;
    },
  };
}

function load() {
  const fetches = [];
  const errors = [];
  const successes = [];
  const busy = [];
  const ctx = specContext({ oSentModel: null, url: "/sap/z2ui5" });
  const { Lib } = loadLib({ ctx });
  const { module: Server } = loadModule("core/Server.js", {
    deps: {
      "sap/ui/core/BusyIndicator": {
        show: (delay) => busy.push(["show", delay]),
        hide: () => busy.push(["hide"]),
      },
      // the real Lib: the sap-contextid adoption below runs through its
      // isValidContextId
      "z2ui5/core/Lib": Lib,
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
  Server.responseSuccess = (_ctx, r) => successes.push(r);
  Server.responseError = (_ctx, msg, title, options) =>
    errors.push({ msg, title, options });
  return { Server, ctx, fetches, errors, successes, busy };
}

// one request, one answer, settled
async function answer(env, res, body = { S_FRONT: { EVENT: "SAVE" } }) {
  const p = env.Server.readHttp(env.ctx, body, null);
  env.fetches[0].resolve(res);
  await p;
}

test.describe("HTTP status outside 2xx", () => {
  test("the body is the error text, and a 500 offers no Retry", async () => {
    const env = load();
    await answer(env, response({ ok: false, status: 500, text: "ABAP dump" }));

    expect(env.errors).toEqual([
      { msg: "ABAP dump", title: undefined, options: undefined },
    ]);
    expect(env.successes).toEqual([]);
  });

  for (const status of [502, 503, 504]) {
    test(`a ${status} offers a Retry that re-sends the same body`, async () => {
      const env = load();
      const body = { S_FRONT: { EVENT: "SAVE" }, MODEL: { A: 1 } };
      await answer(env, response({ ok: false, status, text: "gateway" }), body);

      expect(env.errors).toHaveLength(1);
      expect(env.errors[0].msg).toBe("gateway");
      expect(typeof env.errors[0].options?.onRetry).toBe("function");

      // the overlay's Retry: busy again, the exact same request out again
      env.errors[0].options.onRetry();
      expect(env.ctx.state.isBusy).toBe(true);
      expect(env.busy).toEqual([["show", 0]]);
      expect(env.fetches).toHaveLength(2);
      expect(env.fetches[1].opts.body).toBe(env.fetches[0].opts.body);
      expect(JSON.parse(env.fetches[1].opts.body)).toEqual({ value: body });
      env.fetches[1].resolve(
        response({ json: { S_FRONT: { ID: "ok", S_ACTION: {} } } }),
      );
      await env.fetches[1].promise;
      await new Promise((r) => setTimeout(r, 0));
      expect(env.successes.map((s) => s.ID)).toEqual(["ok"]);
    });
  }

  test("an empty error body falls back to the status code", async () => {
    const env = load();
    await answer(env, response({ ok: false, status: 503, text: "" }));

    expect(env.errors[0].msg).toBe("HTTP 503");
    expect(typeof env.errors[0].options?.onRetry).toBe("function");
  });

  test("an unreadable error body says so, with the status", async () => {
    const env = load();
    await answer(env, response({ ok: false, status: 500, textThrows: true }));

    expect(env.errors[0].msg).toBe("HTTP 500: could not read error body");
    expect(env.errors[0].options).toBeUndefined();
  });

  test("a 401/403/404 is reported without a Retry", async () => {
    for (const status of [401, 403, 404]) {
      const env = load();
      await answer(env, response({ ok: false, status, text: "no" }));
      expect(env.errors[0].options).toBeUndefined();
    }
  });
});

test.describe("a 2xx that is no response", () => {
  test("invalid JSON is reported with the parser's message", async () => {
    const env = load();
    await answer(env, response({ json: undefined }));

    expect(env.errors).toHaveLength(1);
    expect(env.errors[0].msg).toBe("Invalid JSON response: Unexpected token <");
    expect(env.errors[0].options).toBeUndefined();
    expect(env.successes).toEqual([]);
  });

  test("a JSON body without S_FRONT is reported", async () => {
    const env = load();
    await answer(env, response({ json: { MODEL: {} } }));

    expect(env.errors[0].msg).toBe("Invalid response: missing S_FRONT");
    expect(env.successes).toEqual([]);
  });

  test("a null JSON body is reported the same way", async () => {
    const env = load();
    await answer(env, response({ json: null }));

    expect(env.errors[0].msg).toBe("Invalid response: missing S_FRONT");
  });
});

test.describe("the wire version (S_FRONT.PROTOCOL)", () => {
  test("a different number is a mismatch, reported with both numbers", async () => {
    const env = load();
    await answer(
      env,
      response({ json: { S_FRONT: { ID: "x", PROTOCOL: 1, S_ACTION: {} } } }),
    );

    expect(env.errors).toHaveLength(1);
    expect(env.errors[0].msg).toBe(
      "Protocol mismatch: this frontend speaks " +
        env.Server.PROTOCOL +
        ", the backend answered 1. Update whichever of the two is older - they ship together.",
    );
    expect(env.successes).toEqual([]);
  });

  test("the same number passes", async () => {
    const env = load();
    await answer(
      env,
      response({
        json: {
          S_FRONT: { ID: "x", PROTOCOL: env.Server.PROTOCOL, S_ACTION: {} },
        },
      }),
    );

    expect(env.errors).toEqual([]);
    expect(env.successes.map((s) => s.ID)).toEqual(["x"]);
  });

  test("an absent number is a backend older than the field and passes", async () => {
    const env = load();
    await answer(env, response({ json: { S_FRONT: { ID: "x", S_ACTION: {} } } }));

    expect(env.errors).toEqual([]);
    expect(env.successes.map((s) => s.ID)).toEqual(["x"]);
  });
});

test.describe("the session id header", () => {
  test("a valid sap-contextid is adopted, a missing one keeps the last", async () => {
    const env = load();
    await answer(
      env,
      response({
        headers: { "sap-contextid": "SID:ANON:host:abc" },
        json: { S_FRONT: { ID: "x", S_ACTION: {} } },
      }),
    );
    expect(env.ctx.state.contextId).toBe("SID:ANON:host:abc");

    const p = env.Server.readHttp(env.ctx, {}, null);
    env.fetches[1].resolve(
      response({ json: { S_FRONT: { ID: "y", S_ACTION: {} } } }),
    );
    await p;
    expect(env.ctx.state.contextId).toBe("SID:ANON:host:abc");
    // ... and travelled with the second request
    expect(env.fetches[1].opts.headers["sap-contextid"]).toBe(
      "SID:ANON:host:abc",
    );
    expect(env.fetches[0].opts.headers["sap-contextid"]).toBeUndefined();
  });
});
