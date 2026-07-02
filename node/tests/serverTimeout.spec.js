// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");

// Tests Server.createTimeoutSignal: the client-side roundtrip timeout must
// work both with native AbortSignal.timeout and on older browsers via the
// manual AbortController + setTimeout fallback.

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
