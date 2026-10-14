// @ts-check
const { test, expect } = require("@playwright/test");
const fs = require("fs");
const os = require("os");
const path = require("path");
const { pathToFileURL } = require("url");

// ---------------------------------------------------------------------
// node/setup/transpile.mjs - the bin `abap2ui5-transpile` of
// @abap2ui5/node-runtime: the framework and a host's classes transpiled
// together into one runtime, in one command. The transpile itself needs the
// transpiler and a network (open-abap-core, express-icf-shim) - pack-npm
// --check runs it end to end; what is tested here is the decisions around
// it, which are pure: the config it writes, which transpiler it runs and
// when it refuses, the folder rules, and the entry point it writes.
// ---------------------------------------------------------------------

const MODULE = path.join(__dirname, "..", "setup", "transpile.mjs");
const PACKAGE_DIR = path.join(__dirname, "..");

/** @type {any} */
let mod;
test.beforeAll(async () => {
  mod = await import(pathToFileURL(MODULE).href);
});

const cwd = path.resolve("/project");
const inside = (...p) => path.join(cwd, ...p);

const folders = { packageDir: inside("pkg"), core: inside("core"), shim: inside("shim") };

test.describe("transpileConfig", () => {
  test("transpiles the framework's downport/ and the host's classes into one output, the package's own build", () => {
    const config = mod.transpileConfig({
      cwd,
      abap: inside("abap"),
      output: inside("abap2ui5"),
      packageDir: inside("node_modules", "@abap2ui5", "node-runtime"),
      core: inside("node_modules", ".cache", "abap2ui5-node-runtime", "open-abap-core", "abc123"),
      shim: inside("node_modules", ".cache", "abap2ui5-node-runtime", "express-icf-shim", "def456"),
    });
    // both are the transpile's own input: they land in project/ together, as in the package's output/
    expect(config.input_folder).toEqual(["abap", "node_modules/@abap2ui5/node-runtime/downport"]);
    expect(config.output_folder).toBe("abap2ui5");
    expect(config.libs).toEqual([
      { url: mod.OPEN_ABAP_CORE_URL, folder: "/node_modules/.cache/abap2ui5-node-runtime/open-abap-core/abc123" },
      { url: mod.EXPRESS_ICF_SHIM_URL, folder: "/node_modules/.cache/abap2ui5-node-runtime/express-icf-shim/def456" },
    ]);
    expect(config.options).toEqual({
      ignoreSyntaxCheck: false,
      addFilenames: true,
      addCommonJS: true,
      unknownTypes: "runtimeError",
      populateTables: { reposrc: false },
      // init.mjs imports the database setup relative to itself
      setup: { filename: "../node_modules/@abap2ui5/node-runtime/setup/setup.mjs", preFunction: "setup" },
    });
    expect(config.write_unit_tests).toBe(false);
  });

  test("the setup path is relative to the output folder, however deep it is", () => {
    const config = mod.transpileConfig({ cwd, abap: inside("abap"), output: inside("srv", "abap2ui5"), ...folders });
    expect(config.options.setup.filename).toBe("../../pkg/setup/setup.mjs");
  });

  test("the package's own build: the same options as abap2UI5's node/setup/abap_transpile.json, without its unit tests", () => {
    const own = JSON.parse(fs.readFileSync(path.join(PACKAGE_DIR, "setup", "abap_transpile.json"), "utf8"));
    const config = mod.transpileConfig({ cwd, abap: inside("abap"), output: inside("out"), ...folders });
    const { skip, setup, ...options } = own.options;
    expect(skip.length).toBeGreaterThan(0); // unit-test skips - nothing a transpile without unit tests needs
    expect(config.options).toEqual({ ...options, setup: { ...setup, filename: config.options.setup.filename } });
    expect(own.libs.map((/** @type {{ url: string }} */ l) => l.url)).toEqual(config.libs.map((/** @type {{ url: string }} */ l) => l.url));
  });

  test("refuses a folder outside the project, naming it", () => {
    const outside = path.resolve("/elsewhere");
    expect(() => mod.transpileConfig({ cwd, abap: path.join(outside, "abap"), output: inside("out"), ...folders }))
      .toThrow(/the ABAP folder .* is not below the project/);
    expect(() => mod.transpileConfig({ cwd, abap: inside("abap"), output: inside("out"), ...folders, packageDir: path.join(outside, "pkg") }))
      .toThrow(/install @abap2ui5\/node-runtime in the project/);
    expect(() => mod.transpileConfig({ cwd, abap: inside("abap"), output: inside("out"), ...folders, core: outside }))
      .toThrow(/open-abap-core .* is not below the project/);
    expect(() => mod.transpileConfig({ cwd, abap: inside("abap"), output: inside("out"), ...folders, shim: outside }))
      .toThrow(/express-icf-shim .* is not below the project/);
  });

  test("the project itself is not a folder below the project", () => {
    expect(() => mod.transpileConfig({ cwd, abap: cwd, output: inside("out"), ...folders }))
      .toThrow(/the ABAP folder/);
  });

  test("refuses an output folder that overlaps the ABAP folder - it is emptied before every transpile", () => {
    expect(() => mod.transpileConfig({ cwd, abap: inside("abap"), output: inside("abap"), ...folders })).toThrow(/overlap/);
    expect(() => mod.transpileConfig({ cwd, abap: inside("abap"), output: inside("abap", "out"), ...folders })).toThrow(/overlap/);
    expect(() => mod.transpileConfig({ cwd, abap: inside("out", "abap"), output: inside("out"), ...folders })).toThrow(/overlap/);
  });
});

test.describe("transpilerCommand", () => {
  test("runs the installed transpiler when it is the version the package was built with", () => {
    const run = mod.transpilerCommand({ version: "2.13.93", installed: { version: "2.13.93", bin: "/p/node_modules/@abaplint/transpiler-cli/abap_transpile.js" } });
    expect(run.command).toBe(process.execPath);
    expect(run.args).toEqual(["/p/node_modules/@abaplint/transpiler-cli/abap_transpile.js"]);
    expect(run.note).toBeUndefined();
  });

  test("refuses another installed version and says which to install, exactly", () => {
    expect(() => mod.transpilerCommand({ version: "2.13.93", installed: { version: "2.13.94", bin: "x" } }))
      .toThrow(/has @abaplint\/transpiler-cli 2\.13\.94, and this @abap2ui5\/node-runtime was built with 2\.13\.93[\s\S]*--save-exact @abaplint\/transpiler-cli@2\.13\.93/);
  });

  test("falls back to npx at the pinned version when none is installed, and says how to keep it", () => {
    const run = mod.transpilerCommand({ version: "2.13.93", installed: null });
    expect(run.command).toMatch(/^npx/);
    expect(run.args).toEqual(["--yes", "-p", "@abaplint/transpiler-cli@2.13.93", "abap_transpile"]);
    expect(run.note).toMatch(/--save-exact @abaplint\/transpiler-cli@2\.13\.93/);
  });

  test("a package that records no transpiler version is refused", () => {
    expect(() => mod.transpilerCommand({ version: undefined, installed: null })).toThrow(/abap2ui5\.transpiler/);
  });
});

test.describe("ensureCore", () => {
  test("a checkout already at the commit is reused without touching git", () => {
    // no .git -> would fetch; with a .git whose HEAD matches -> returned as is.
    // Reproduce the "matches" half with a real tiny repository.
    const dir = fs.mkdtempSync(path.join(os.tmpdir(), "a2ui5-core-"));
    const { execFileSync } = require("child_process");
    const git = (/** @type {string[]} */ args) => execFileSync("git", args, { cwd: dir, encoding: "utf8", stdio: ["ignore", "pipe", "pipe"] }).trim();
    git(["init", "-q"]);
    git(["-c", "user.email=t@t", "-c", "user.name=t", "commit", "-q", "--allow-empty", "-m", "x"]);
    const head = git(["rev-parse", "HEAD"]);
    const lines = /** @type {string[]} */ ([]);
    expect(mod.ensureCore({ dir, commit: head, log: (/** @type {string} */ l) => lines.push(l) })).toBe(dir);
    expect(lines).toEqual([]);
    fs.rmSync(dir, { recursive: true, force: true });
  });

  test("no recorded commit: refused with the way out", () => {
    expect(() => mod.ensureCore({ dir: "/nowhere", commit: undefined })).toThrow(/abap2ui5\.openAbapCore[\s\S]*--core/);
  });

  test("express-icf-shim the same, with its own record and option", () => {
    const shim = { name: "express-icf-shim", url: mod.EXPRESS_ICF_SHIM_URL, recorded: "expressIcfShim", option: "--shim", env: "ABAP2UI5_EXPRESS_ICF_SHIM" };
    expect(() => mod.ensureCheckout({ dir: "/nowhere", commit: undefined, library: shim })).toThrow(/abap2ui5\.expressIcfShim[\s\S]*--shim/);
  });
});

test.describe("the bin", () => {
  test("usage on missing arguments, exit code 2", () => {
    const { spawnSync } = require("child_process");
    const r = spawnSync(process.execPath, [MODULE, "abap"], { encoding: "utf8" });
    expect(r.status).toBe(2);
    expect(r.stderr).toMatch(/usage: abap2ui5-transpile <abap folder> <output folder>/);
    const unknown = spawnSync(process.execPath, [MODULE, "abap", "apps", "--bogus"], { encoding: "utf8" });
    expect(unknown.status).toBe(2);
    expect(unknown.stderr).toMatch(/unknown option --bogus/);
  });

  test("a missing ABAP folder is reported, exit code 1", () => {
    const { spawnSync } = require("child_process");
    const r = spawnSync(process.execPath, [MODULE, "no-such-folder", "abap2ui5"], { encoding: "utf8", cwd: os.tmpdir() });
    expect(r.status).toBe(1);
    expect(r.stderr).toMatch(/no-such-folder does not exist/);
  });

  test("the manifest names it as a bin only once pack-npm packs it", () => {
    // pack-npm.mjs copies an explicit list of files, not the manifest's `files`;
    // a bin named in the manifest but not in that list is a dangling link in
    // every install (docs/agents/ci-workflows.md, "not yet packed"). So: either
    // both, or neither.
    const manifest = JSON.parse(fs.readFileSync(path.join(PACKAGE_DIR, "setup", "npm.package.json"), "utf8"));
    const named = manifest.bin["abap2ui5-transpile"] === "setup/transpile.mjs";
    const packed = fs.readFileSync(path.join(PACKAGE_DIR, "setup", "pack-npm.mjs"), "utf8").includes("transpile.mjs");
    expect(named).toBe(packed);
  });
});

test.describe("writeEntry", () => {
  test("writes host.mjs, its claim.mjs and host.d.ts into the output", () => {
    const dir = fs.mkdtempSync(path.join(os.tmpdir(), "a2ui5-entry-"));
    mod.writeEntry(dir);
    expect(fs.readdirSync(dir).sort()).toEqual(["claim.mjs", "host.d.ts", "host.mjs"]);
    expect(fs.readFileSync(path.join(dir, "host.mjs"), "utf8")).toMatch(/^import "\.\/claim\.mjs";$/m);
    expect(fs.readFileSync(path.join(dir, "host.d.ts"), "utf8")).toMatch(/^export \* from "@abap2ui5\/node-runtime";$/m);
    fs.rmSync(dir, { recursive: true, force: true });
  });
});
