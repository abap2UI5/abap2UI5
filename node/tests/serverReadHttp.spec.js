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
//   403 + X-CSRF-Token: Required
//                    a token layer in front (an SAP approuter, a Gateway)
//                    asks for a token: fetched once, the same body sent
//                    once more with it, kept for the POSTs after - and
//                    reported like any other 403 when no token comes back
//                    or the layer refuses again
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

test.describe("the X-CSRF-Token handshake", () => {
  const BODY = { S_FRONT: { EVENT: "SAVE" }, MODEL: { A: 1 } };

  // what an SAP approuter answers a POST without a valid token
  const refused = () =>
    response({
      ok: false,
      status: 403,
      text: "The request does not contain a x-csrf-token",
      headers: { "x-csrf-token": "Required" },
    });
  const token = (value) => response({ headers: { "x-csrf-token": value } });
  const good = (id) => response({ json: { S_FRONT: { ID: id, S_ACTION: {} } } });

  // let readHttp run up to its next fetch, or to its end
  async function flush() {
    for (let i = 0; i < 5; i++) await new Promise((r) => setTimeout(r, 0));
  }

  test("nothing is fetched and no token is sent while no layer asks", async () => {
    const env = load();
    await answer(env, good("x"));

    expect(env.fetches).toHaveLength(1);
    expect(env.fetches[0].opts.headers["X-CSRF-Token"]).toBeUndefined();
    expect(env.successes.map((s) => s.ID)).toEqual(["x"]);
  });

  test("a 403 asking for a token fetches one and sends the same body once more with it", async () => {
    const env = load();
    const p = env.Server.readHttp(env.ctx, BODY, null);
    env.fetches[0].resolve(refused());
    await flush();

    // the standard fetch: HEAD on the same URL, "Fetch" in the header
    expect(env.fetches).toHaveLength(2);
    expect(env.fetches[1].url).toBe("/sap/z2ui5");
    expect(env.fetches[1].opts.method).toBe("HEAD");
    expect(env.fetches[1].opts.headers).toEqual({ "X-CSRF-Token": "Fetch" });
    env.fetches[1].resolve(token("tok-1"));
    await flush();

    // the identical body again, now carrying the token
    expect(env.fetches).toHaveLength(3);
    expect(env.fetches[2].opts.method).toBe("POST");
    expect(env.fetches[2].opts.body).toBe(env.fetches[0].opts.body);
    expect(env.fetches[2].opts.headers["X-CSRF-Token"]).toBe("tok-1");
    env.fetches[2].resolve(good("x"));
    await p;

    expect(env.errors).toEqual([]);
    expect(env.successes.map((s) => s.ID)).toEqual(["x"]);
    expect(env.ctx.server.csrfToken).toBe("tok-1");
  });

  test("the token rides on every later POST without a second fetch", async () => {
    const env = load();
    env.ctx.server.csrfToken = "tok-1";
    await answer(env, good("y"));

    expect(env.fetches).toHaveLength(1);
    expect(env.fetches[0].opts.headers["X-CSRF-Token"]).toBe("tok-1");
    expect(env.successes.map((s) => s.ID)).toEqual(["y"]);
  });

  test("a token the layer stopped accepting is replaced by a fresh one", async () => {
    const env = load();
    env.ctx.server.csrfToken = "tok-old";
    const p = env.Server.readHttp(env.ctx, BODY, null);
    expect(env.fetches[0].opts.headers["X-CSRF-Token"]).toBe("tok-old");
    env.fetches[0].resolve(refused());
    await flush();
    env.fetches[1].resolve(token("tok-new"));
    await flush();
    expect(env.fetches[2].opts.headers["X-CSRF-Token"]).toBe("tok-new");
    env.fetches[2].resolve(good("z"));
    await p;

    expect(env.successes.map((s) => s.ID)).toEqual(["z"]);
  });

  test("the framework's own 403 carries no header, is final and fetches nothing", async () => {
    const env = load();
    await answer(
      env,
      response({
        ok: false,
        status: 403,
        text: "CSRF validation failed - cross-origin request rejected",
      }),
    );

    expect(env.fetches).toHaveLength(1);
    expect(env.errors).toEqual([
      {
        msg: "CSRF validation failed - cross-origin request rejected",
        title: undefined,
        options: undefined,
      },
    ]);
  });

  test("a layer that refuses the fresh token too ends in the overlay, not in a loop", async () => {
    const env = load();
    const p = env.Server.readHttp(env.ctx, BODY, null);
    env.fetches[0].resolve(refused());
    await flush();
    env.fetches[1].resolve(token("tok-1"));
    await flush();
    env.fetches[2].resolve(refused());
    await p;

    expect(env.fetches).toHaveLength(3);
    expect(env.errors).toHaveLength(1);
    expect(env.errors[0].msg).toBe("The request does not contain a x-csrf-token");
    expect(env.errors[0].options).toBeUndefined();
    expect(env.successes).toEqual([]);
  });

  for (const [what, answerFetch] of [
    ["an answer without a token", (call) => call.resolve(response())],
    [
      "a refused fetch",
      (call) => call.resolve(response({ ok: false, status: 403, text: "no" })),
    ],
    ["an answer that asks back", (call) => call.resolve(token("Required"))],
    ["a failed fetch", (call) => call.reject(new TypeError("Failed to fetch"))],
  ]) {
    test(`${what} reports the refusal that asked for the token, sends nothing more`, async () => {
      const env = load();
      const p = env.Server.readHttp(env.ctx, BODY, null);
      env.fetches[0].resolve(refused());
      await flush();
      answerFetch(env.fetches[1]);
      await p;

      expect(env.fetches).toHaveLength(2);
      expect(env.errors).toHaveLength(1);
      expect(env.errors[0].msg).toBe("The request does not contain a x-csrf-token");
      expect(env.ctx.server.csrfToken).toBe("");
    });
  }

  test("a request superseded during the fetch is not sent again and stays silent", async () => {
    const env = load();
    const p = env.Server.readHttp(env.ctx, BODY, null);
    env.fetches[0].resolve(refused());
    await flush();
    expect(env.fetches[1].opts.method).toBe("HEAD");

    // a newer request goes out while the token is on its way
    const newer = env.Server.readHttp(env.ctx, { S_FRONT: { EVENT: "NEXT" } }, null);
    expect(env.fetches).toHaveLength(3);
    env.fetches[1].resolve(token("tok-1"));
    await p;

    // the older body did not go out again, and nothing was reported for it
    expect(env.fetches).toHaveLength(3);
    expect(env.errors).toEqual([]);
    // the token is kept all the same - the POST after the newer one takes it
    expect(env.ctx.server.csrfToken).toBe("tok-1");
    // and the newer request's own answer is committed as usual
    env.fetches[2].resolve(good("n"));
    await newer;
    expect(env.successes.map((s) => s.ID)).toEqual(["n"]);
  });
});
