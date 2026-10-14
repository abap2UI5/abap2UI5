// @ts-check
const { test, expect } = require("@playwright/test");
const fs = require("fs");
const path = require("path");
const { pathToFileURL } = require("url");

// ---------------------------------------------------------------------
// node/srv/framework.mjs - which transpiled output srv/hostcore.mjs runs
// on. Two entry points bind one: srv/host.mjs the package's output/, and
// the host.mjs abap2ui5-transpile writes (hostEntry( )) a host's own. Held
// here: both import the same seven modules (FRAMEWORK_MODULES), the written
// entry claims its output before loading it, and a process refuses a
// second, different output. pack-npm --check runs both entries for real.
// ---------------------------------------------------------------------

const FRAMEWORK = path.join(__dirname, "..", "srv", "framework.mjs");
const HOST = path.join(__dirname, "..", "srv", "host.mjs");

/** A fresh instance of framework.mjs - its binding is module state. */
let fresh = 0;
const load = async () => import(`${pathToFileURL(FRAMEWORK).href}?fresh=${(fresh += 1)}`);

/** The `import { name } from "<prefix><file>"` lines of a module, as [name, file]. */
function staticImports(text, prefix) {
  const re = new RegExp(`^import \\{ (\\w+) \\} from "${prefix.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")}([^"]+)";$`, "gm");
  return [...text.matchAll(re)].map((m) => [m[1], m[2]]);
}

test("srv/host.mjs imports exactly FRAMEWORK_MODULES from ../output/, after its claim", async () => {
  const { FRAMEWORK_MODULES } = await load();
  const text = fs.readFileSync(HOST, "utf8");
  expect(staticImports(text, "../output/")).toEqual(FRAMEWORK_MODULES);
  const first = text.split("\n").find((line) => line.startsWith("import "));
  expect(first).toBe('import "./claim.mjs";');
});

test("hostEntry( ) writes the same imports from ./, claim.mjs first, and the package's exports", async () => {
  const { FRAMEWORK_MODULES, hostEntry } = await load();
  const written = hostEntry({ packageName: "@abap2ui5/node-runtime" });
  const host = written["host.mjs"];
  expect(staticImports(host, "./")).toEqual(FRAMEWORK_MODULES);
  expect(host.split("\n").find((line) => line.startsWith("import "))).toBe('import "./claim.mjs";');
  expect(host).toMatch(/^export \* from "@abap2ui5\/node-runtime\/srv\/hostcore\.mjs";$/m);
  expect(written["claim.mjs"]).toMatch(/^claimOutput\(new URL\("\.\/", import\.meta\.url\)\.href\);$/m);
});

test("the subpaths the written entry imports are exports of the package", async () => {
  const { hostEntry } = await load();
  const manifest = JSON.parse(fs.readFileSync(path.join(__dirname, "..", "setup", "npm.package.json"), "utf8"));
  const written = Object.values(hostEntry({ packageName: manifest.name })).join("\n");
  const subpaths = [...written.matchAll(/from "@abap2ui5\/node-runtime(\/[^"]+)"/g)].map((m) => `.${m[1]}`);
  expect(subpaths.length).toBeGreaterThan(0);
  for (const subpath of subpaths) expect(Object.keys(manifest.exports)).toContain(subpath);
});

test("one process, one output: the same claim again is fine, another one is refused", async () => {
  const { claimOutput } = await load();
  claimOutput("file:///a/output/");
  claimOutput("file:///a/output/");
  expect(() => claimOutput("file:///b/abap2ui5/")).toThrow(/file:\/\/\/a\/output\/ is already loaded[\s\S]*a process runs one output/);
});

test("bindFramework( ) wants its claim first, and all seven modules", async () => {
  const { FRAMEWORK_MODULES, bindFramework, claimOutput, framework } = await load();
  const modules = Object.fromEntries(FRAMEWORK_MODULES.map(([name]) => [name, {}]));
  expect(() => bindFramework(modules)).toThrow(/before claimOutput/);
  expect(() => framework()).toThrow(/no framework loaded/);
  claimOutput("file:///a/output/");
  const partial = { ...modules, zcl_serializer_live: undefined };
  expect(() => bindFramework(partial)).toThrow(/lacks zcl_serializer_live/);
  bindFramework(modules);
  expect(framework()).toBe(modules);
});
