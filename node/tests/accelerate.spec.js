// @ts-check
const { test, expect } = require("@playwright/test");
const fs = require("fs");
const os = require("os");
const path = require("path");
const { execFileSync } = require("child_process");

// ---------------------------------------------------------------------
// node/srv/accelerate.mjs replaces two functions of @abaplint/runtime -
// LOOP AT ... WHERE over a sorted primary key, and CP/NP - with faster
// versions that have to answer EXACTLY what the originals answer. This spec
// holds them to that by running both on the same seeded random cases
// (helpers/accelerateDiff.mjs, in a child process) and comparing
// everything observable, and it pins the runtime version the fast paths were
// validated against, so a runtime bump is a red build that asks for a
// revalidation rather than a quiet change of what the framework computes.
//
// No transpiled tree needed: the runtime is a devDependency, and the tables
// and WHERE functions are built the way transpiled code builds them. The
// framework's own suite with the fast paths installed is `npm run
// unit:accelerated` (node/setup/unit-accelerated.mjs).
// ---------------------------------------------------------------------

const ROOT = path.join(__dirname, "..", "..");
const HELPER = path.join(__dirname, "helpers", "accelerateDiff.mjs");
const MODULE = path.join(ROOT, "node", "srv", "accelerate.mjs");

/** @type {any} */
let diff;
function differential() {
  diff ??= JSON.parse(execFileSync(process.execPath, [HELPER], {
    encoding: "utf8",
    maxBuffer: 64 * 1024 * 1024,
    env: { ...process.env, ACCELERATE_SEED: process.env.ACCELERATE_SEED || "1" },
  }));
  return diff;
}

test("the LOOP fast path yields what the runtime's loop yields, row for row", () => {
  const { loop } = differential();
  // every scenario: rows yielded and sy-tabix in the body, what the body did
  // (INSERT into and around the block, DELETE, APPEND in order, INSERT LINES
  // OF, the table assigned, EXIT, an exception, a nested loop over the same
  // table), sy-subrc and sy-tabix afterwards, the table afterwards
  expect(loop.mismatches, JSON.stringify(loop.mismatches[0], null, 1)).toEqual([]);
  // planFor( ) took exactly the scenarios it is meant to take - a WHERE with
  // an OR, a secondary key, an operand of another type or length went to the
  // original (same number of WHERE evaluations), the rest evaluated fewer
  expect(loop.misplanned, JSON.stringify(loop.misplanned[0], null, 1)).toEqual([]);
  expect(loop.scenarios).toBeGreaterThanOrEqual(4000);
  // the comparison is only worth something while the fast path does engage
  expect(loop.engaged).toBeGreaterThan(loop.scenarios / 3);
  expect(loop.whereFast).toBeLessThan(loop.whereOriginal / 2);
});

test("CP and NP answer what the runtime's answer, for every string and pattern", () => {
  const { cp } = differential();
  expect(cp.mismatches, JSON.stringify(cp.mismatches[0], null, 1)).toEqual([]);
  expect(cp.cases).toBeGreaterThanOrEqual(30000);
  // both outcomes are represented, not a suite of patterns that never match
  expect(cp.matched).toBeGreaterThan(cp.cases / 10);
  expect(cp.matched).toBeLessThan(cp.cases * 0.9);
});

test("accelerate() is idempotent", () => {
  const { installed, idempotent } = differential();
  expect(installed).toBe(true);
  expect(idempotent).toBe(true);
});

test("the fast paths are pinned to the runtime version package-lock.json installs", () => {
  const { validated, runtime } = differential();
  const lock = JSON.parse(fs.readFileSync(path.join(ROOT, "package-lock.json"), "utf8"));
  const locked = lock.packages["node_modules/@abaplint/runtime"].version;
  expect(runtime).toBe(locked);
  // RED ON A RUNTIME BUMP, on purpose. accelerate.mjs replaces two functions
  // of @abaplint/runtime and is correct for the version it was read off. When
  // the lockfile moves: diff build/src/statements/loop.js and
  // build/src/compare/cp.js (and types/table.js's loop bookkeeping) against
  // the old version, run this spec - its differential tests above compare
  // with the NEW originals - and move RUNTIME_VERSION in accelerate.mjs.
  // Until then the package would pin a runtime accelerate() refuses to touch.
  expect(validated, `@abaplint/runtime moved to ${locked}: revalidate node/srv/accelerate.mjs (see this test)`).toBe(locked);
});

test("on another runtime version accelerate() installs nothing and warns once", () => {
  // a copy of the module next to a runtime package.json of another version:
  // the module resolves the version from where it lies, as it does in the
  // installed package
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), "accelerate-guard-"));
  try {
    fs.mkdirSync(path.join(dir, "srv"));
    fs.copyFileSync(MODULE, path.join(dir, "srv", "accelerate.mjs"));
    fs.mkdirSync(path.join(dir, "node_modules", "@abaplint", "runtime"), { recursive: true });
    fs.writeFileSync(path.join(dir, "node_modules", "@abaplint", "runtime", "package.json"),
      JSON.stringify({ name: "@abaplint/runtime", version: "0.0.0-not-validated" }));
    const runtime = require.resolve("@abaplint/runtime");
    fs.writeFileSync(path.join(dir, "driver.mjs"), `
import runtime from ${JSON.stringify(require("url").pathToFileURL(runtime).href)};
globalThis.abap = new runtime.ABAP();
const warnings = [];
console.warn = (...args) => warnings.push(args.join(" "));
const { accelerate } = await import("./srv/accelerate.mjs");
const loop = globalThis.abap.statements.loop;
const compare = globalThis.abap.compare;
const first = accelerate();
const second = accelerate();
process.stdout.write(JSON.stringify({
  first, second, warnings,
  untouched: globalThis.abap.statements.loop === loop && globalThis.abap.compare === compare,
  forced: accelerate({ force: true }),
}));
`);
    const out = JSON.parse(execFileSync(process.execPath, [path.join(dir, "driver.mjs")], { encoding: "utf8" }));
    expect(out.first).toBe(false);
    expect(out.second).toBe(false);
    expect(out.untouched).toBe(true);
    expect(out.warnings).toHaveLength(1);
    expect(out.warnings[0]).toContain("0.0.0-not-validated");
    expect(out.forced).toBe(true);
  } finally {
    fs.rmSync(dir, { recursive: true, force: true });
  }
});

test("accelerate() without a booted runtime says what is missing", () => {
  const out = execFileSync(process.execPath, ["--input-type=module", "-e", `
const { accelerate } = await import(${JSON.stringify(require("url").pathToFileURL(MODULE).href)});
try { accelerate(); console.log("no error"); } catch (e) { console.log(e.message); }
`], { encoding: "utf8" });
  expect(out).toContain("call it after output/init.mjs has booted");
});
