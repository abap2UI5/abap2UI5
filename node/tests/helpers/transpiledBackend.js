// @ts-check
// The guard of every spec that needs the transpiled backend (node/output,
// built by `npm run downport && npm run auto_transpile`, never committed).
//
// Locally a missing tree skips the spec: `npm run check:js` on a fresh
// checkout has none, and `npm run verify` builds it before the specs run.
// In CI a skip is how a spec stops running without anybody noticing -
// efWireRoundtrip.spec.js and the framework half of hostGuard.spec.js
// skipped in every CI job: test_unit_js has no tree, and test_node,
// which has one, did not run them. So where CI is set a missing tree FAILS
// the spec, unless the job says it has no tree on purpose
// (Z2UI5_NO_BACKEND=1 - test_unit_js in test.yaml); a spec that needs the
// tree then has to be listed in test_node, which downloads it.
const fs = require("fs");
const path = require("path");

const OUTPUT = path.join(__dirname, "..", "..", "output", "init.mjs");
const REASON = "needs the transpiled backend: npm run downport && npm run auto_transpile";

/**
 * Skip - or, in CI, fail - the tests of the calling scope (the file, or the
 * describe it is called in) when there is no transpiled backend.
 * @param {typeof import("@playwright/test").test} test
 */
function needsTranspiledBackend(test) {
  if (fs.existsSync(OUTPUT)) return;
  if (process.env.CI && process.env.Z2UI5_NO_BACKEND !== "1") {
    test.beforeAll(() => {
      throw new Error(
        `${OUTPUT} is missing - ${REASON}. In CI this spec must not skip: run it in a job ` +
          "that has the tree (test_node in .github/workflows/test.yaml), or set " +
          "Z2UI5_NO_BACKEND=1 in a job that has none on purpose",
      );
    });
    return;
  }
  test.skip(true, REASON);
}

module.exports = { needsTranspiledBackend, OUTPUT };
