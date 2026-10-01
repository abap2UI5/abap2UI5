// @ts-check
const { test, expect } = require("@playwright/test");
const fs = require("fs");
const os = require("os");
const path = require("path");
const { pathToFileURL } = require("url");

// ---------------------------------------------------------------------
// node/setup/transpile.mjs - the bin `abap2ui5-transpile` of
// @abap2ui5/node-runtime: a host's classes transpiled against the package
// and loaded on its runtime, in one command. The transpile itself needs the
// transpiler and a network (open-abap-core); what is tested here is the
// decisions around it, which are pure: the config it writes, which
// transpiler it runs and when it refuses, and the folder rule.
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

test.describe("transpileConfig", () => {
  test("writes the README's config with the paths relative to the project", () => {
    const config = mod.transpileConfig({
      cwd,
      abap: inside("abap"),
      output: inside("node_modules", ".cache", "abap2ui5-node-runtime", "transpile-output"),
      packageDir: inside("node_modules", "@abap2ui5", "node-runtime"),
      core: inside("node_modules", ".cache", "abap2ui5-node-runtime", "open-abap-core", "abc123"),
    });
    expect(config.input_folder).toBe("abap");
    expect(config.output_folder).toBe("node_modules/.cache/abap2ui5-node-runtime/transpile-output");
    expect(config.libs).toEqual([
      { folder: "/node_modules/@abap2ui5/node-runtime/downport", files: "/**/*.*" },
      { url: mod.OPEN_ABAP_CORE_URL, folder: "/node_modules/.cache/abap2ui5-node-runtime/open-abap-core/abc123" },
    ]);
    // the type check is on, and the imports own-apps needs are written
    expect(config.options).toEqual({ ignoreSyntaxCheck: false, addFilenames: true, addCommonJS: true, unknownTypes: "runtimeError" });
    expect(config.write_unit_tests).toBe(false);
  });

  test("the libraries never read below /src: the downport is flat", () => {
    const config = mod.transpileConfig({ cwd, abap: inside("abap"), output: inside("out"), packageDir: inside("pkg"), core: inside("core") });
    expect(config.libs[0].files).toBe("/**/*.*");
  });

  test("refuses a folder outside the project, naming it", () => {
    const outside = path.resolve("/elsewhere");
    expect(() => mod.transpileConfig({ cwd, abap: path.join(outside, "abap"), output: inside("out"), packageDir: inside("pkg"), core: inside("core") }))
      .toThrow(/the ABAP folder .* is not below the project/);
    expect(() => mod.transpileConfig({ cwd, abap: inside("abap"), output: inside("out"), packageDir: path.join(outside, "pkg"), core: inside("core") }))
      .toThrow(/install @abap2ui5\/node-runtime in the project/);
    expect(() => mod.transpileConfig({ cwd, abap: inside("abap"), output: inside("out"), packageDir: inside("pkg"), core: outside }))
      .toThrow(/open-abap-core .* is not below the project/);
  });

  test("the project itself is not a folder below the project", () => {
    expect(() => mod.transpileConfig({ cwd, abap: cwd, output: inside("out"), packageDir: inside("pkg"), core: inside("core") }))
      .toThrow(/the ABAP folder/);
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
});

test.describe("the bin", () => {
  test("usage on missing arguments, exit code 2", () => {
    const { spawnSync } = require("child_process");
    const r = spawnSync(process.execPath, [MODULE, "abap"], { encoding: "utf8" });
    expect(r.status).toBe(2);
    expect(r.stderr).toMatch(/usage: abap2ui5-transpile <abap folder> <apps folder>/);
    const unknown = spawnSync(process.execPath, [MODULE, "abap", "apps", "--bogus"], { encoding: "utf8" });
    expect(unknown.status).toBe(2);
    expect(unknown.stderr).toMatch(/unknown option --bogus/);
  });

  test("a missing ABAP folder is reported, exit code 1", () => {
    const { spawnSync } = require("child_process");
    const r = spawnSync(process.execPath, [MODULE, "no-such-folder", "apps"], { encoding: "utf8", cwd: os.tmpdir() });
    expect(r.status).toBe(1);
    expect(r.stderr).toMatch(/no-such-folder does not exist/);
  });

  test("is listed as a bin of the package, next to own-apps", () => {
    const manifest = JSON.parse(fs.readFileSync(path.join(PACKAGE_DIR, "setup", "npm.package.json"), "utf8"));
    expect(manifest.bin["abap2ui5-transpile"]).toBe("setup/transpile.mjs");
    expect(manifest.files).toContain("setup/transpile.mjs");
  });
});
