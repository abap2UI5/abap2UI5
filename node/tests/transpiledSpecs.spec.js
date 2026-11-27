// @ts-check
const { test, expect } = require("@playwright/test");
const fs = require("fs");
const path = require("path");
const yaml = require("js-yaml");

// Every spec that needs the transpiled backend runs somewhere in CI.
//
// Such a spec calls needsTranspiledBackend( ) (helpers/transpiledBackend.js)
// and skips in test_unit_js, which has no tree on purpose; the only CI job
// that has one is test_node in .github/workflows/test.yaml, which runs a
// list of them by name. A spec missing from that list skipped in every job
// and nobody noticed - efWireRoundtrip.spec.js and the framework half of
// hostGuard.spec.js did, while hostGuard's own comment said test_node ran
// it. This spec reads both sides: the specs that call the guard, and the
// specs test_node names.

const TESTS = __dirname;
const WORKFLOW = path.join(__dirname, "..", "..", ".github", "workflows", "test.yaml");

function specsThatNeedTheTree() {
  return fs
    .readdirSync(TESTS)
    .filter((name) => name.endsWith(".spec.js"))
    .filter((name) => /\bneedsTranspiledBackend\(test\)/.test(fs.readFileSync(path.join(TESTS, name), "utf8")))
    .map((name) => name.replace(/\.spec\.js$/, ""))
    .sort();
}

function specsTestNodeRuns() {
  const workflow = /** @type {any} */ (yaml.load(fs.readFileSync(WORKFLOW, "utf8")));
  const steps = workflow?.jobs?.test_node?.steps ?? [];
  const names = [];
  for (const step of steps) {
    const match = /playwright test -c node\/playwright-unit\.config\.js\s+(.+)$/m.exec(String(step.run ?? ""));
    if (match) names.push(...match[1].trim().split(/\s+/));
  }
  return names;
}

test("test_node runs every spec that needs the transpiled backend", () => {
  const needed = specsThatNeedTheTree();
  // three of the specs the guard was written for - a match that found none
  // would pass everything
  expect(needed).toEqual(expect.arrayContaining(["compress", "efWireRoundtrip", "hostGuard"]));
  const run = specsTestNodeRuns();
  expect(needed.filter((name) => !run.includes(name))).toEqual([]);
});

test("test_unit_js says it has no tree, so the guard skips there instead of failing", () => {
  const workflow = /** @type {any} */ (yaml.load(fs.readFileSync(WORKFLOW, "utf8")));
  const checkJs = (workflow?.jobs?.test_unit_js?.steps ?? []).find((step) => /npm run check:js/.test(String(step.run ?? "")));
  expect(checkJs?.env?.Z2UI5_NO_BACKEND).toBe("1");
});
