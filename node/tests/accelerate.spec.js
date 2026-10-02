// @ts-check
const { test, expect } = require("@playwright/test");
const fs = require("fs");
const os = require("os");
const path = require("path");
const { execFileSync } = require("child_process");
const { pathToFileURL } = require("url");

// ---------------------------------------------------------------------
// node/srv/accelerate.mjs installs nothing any more: @abaplint/runtime from
// 2.13.96 on has the linear LOOP ... WHERE over a sorted primary key and CP
// itself (abaplint/transpiler#1950, #1933). accelerate() stays exported for
// the hosts that call it, and answers whether the runtime is linear. This
// spec holds it to that: true and untouched on the runtime the lockfile
// installs, false and one warning on an older one, and the package never
// pinning a runtime older than RUNTIME_VERSION.
//
// No transpiled tree needed: the runtime is a devDependency.
// ---------------------------------------------------------------------

const ROOT = path.join(__dirname, "..", "..");
const MODULE = path.join(ROOT, "node", "srv", "accelerate.mjs");

/** accelerate() in a child process, on the installed runtime or one claiming `version` */
function drive(version) {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), "accelerate-"));
  try {
    // a copy of the module next to a runtime package.json of that version:
    // the module resolves the version from where it lies, as it does in the
    // installed package
    fs.mkdirSync(path.join(dir, "srv"));
    fs.copyFileSync(MODULE, path.join(dir, "srv", "accelerate.mjs"));
    if (version) {
      fs.mkdirSync(path.join(dir, "node_modules", "@abaplint", "runtime"), { recursive: true });
      fs.writeFileSync(path.join(dir, "node_modules", "@abaplint", "runtime", "package.json"),
        JSON.stringify({ name: "@abaplint/runtime", version }));
    }
    const module = version ? "./srv/accelerate.mjs" : pathToFileURL(MODULE).href;
    fs.writeFileSync(path.join(dir, "driver.mjs"), `
import runtime from ${JSON.stringify(pathToFileURL(require.resolve("@abaplint/runtime")).href)};
globalThis.abap = new runtime.ABAP();
const warnings = [];
console.warn = (...args) => warnings.push(args.join(" "));
const { accelerate, RUNTIME_VERSION } = await import(${JSON.stringify(module)});
const loop = globalThis.abap.statements.loop;
const compare = globalThis.abap.compare;
const cp = globalThis.abap.compare.cp;
const first = accelerate();
const second = accelerate({ force: true });
process.stdout.write(JSON.stringify({
  first, second, warnings, RUNTIME_VERSION,
  untouched: globalThis.abap.statements.loop === loop && globalThis.abap.compare === compare && globalThis.abap.compare.cp === cp,
}));
`);
    return JSON.parse(execFileSync(process.execPath, [path.join(dir, "driver.mjs")], { encoding: "utf8" }));
  } finally {
    fs.rmSync(dir, { recursive: true, force: true });
  }
}

test("on the runtime the lockfile installs, accelerate() says linear and changes nothing", () => {
  const out = drive();
  expect(out.first).toBe(true);
  expect(out.second).toBe(true);
  expect(out.untouched).toBe(true);
  expect(out.warnings).toEqual([]);
});

test("the package never pins a runtime older than RUNTIME_VERSION", () => {
  const { RUNTIME_VERSION } = drive();
  const lock = JSON.parse(fs.readFileSync(path.join(ROOT, "package-lock.json"), "utf8"));
  const locked = lock.packages["node_modules/@abaplint/runtime"].version;
  const parts = (v) => v.split("-")[0].split(".").map(Number);
  const [l, r] = [parts(locked), parts(RUNTIME_VERSION)];
  const cmp = l[0] - r[0] || l[1] - r[1] || l[2] - r[2];
  expect(cmp, `package-lock.json installs @abaplint/runtime ${locked}, older than ${RUNTIME_VERSION}`).toBeGreaterThanOrEqual(0);
});

test("on an older runtime accelerate() says quadratic, changes nothing and warns once", () => {
  const out = drive("2.13.93");
  expect(out.first).toBe(false);
  expect(out.second).toBe(false);
  expect(out.untouched).toBe(true);
  expect(out.warnings).toHaveLength(1);
  expect(out.warnings[0]).toContain("2.13.93");
});

test("a newer runtime counts as linear", () => {
  const out = drive("2.14.0");
  expect(out.first).toBe(true);
  expect(out.warnings).toEqual([]);
});

test("accelerate() without a booted runtime says what is missing", () => {
  const out = execFileSync(process.execPath, ["--input-type=module", "-e", `
const { accelerate } = await import(${JSON.stringify(pathToFileURL(MODULE).href)});
try { accelerate(); console.log("no error"); } catch (e) { console.log(e.message); }
`], { encoding: "utf8" });
  expect(out).toContain("call it after output/init.mjs has booted");
});
