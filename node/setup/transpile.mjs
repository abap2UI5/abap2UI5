#!/usr/bin/env node
/*
 * transpile.mjs - a host's own ABAP classes, transpiled against the package
 * and loaded on its runtime, in one command. Shipped in @abap2ui5/node-runtime
 * as setup/transpile.mjs and as the bin `abap2ui5-transpile`; npm.README.md,
 * "Your own apps", is the recipe it runs.
 *
 *   npx abap2ui5-transpile abap srv/apps        # abap/*.abap -> srv/apps/: yours, on the package's classes
 *
 * then, after the runtime has booted:  await import("./apps/index.mjs")
 *
 * WHY. Transpiling an app against the framework takes five things that all
 * have to agree with the package, and the README used to list them as steps
 * for the host to carry out by hand: the transpiler at the EXACT version
 * output/ was built with (transpiler output is tied to its runtime - the
 * package records it as `abap2ui5.transpiler`); open-abap-core, the standard
 * library the transpile type-checks against, at the COMMIT the framework was
 * built against (`abap2ui5.openAbapCore` - the transpiler's own fallback is
 * whatever HEAD is that day); a transpile config whose libraries point at the
 * package's downport/ and that checkout; the transpile; and own-apps.mjs
 * afterwards, because the transpiler writes a second copy of every library
 * object next to the host's classes. Three consumers (abap2UI5/mcp-server,
 * cap2UI5, cap2UI5/samples) implemented that recipe separately, and a fourth
 * would again. This file is the recipe.
 *
 * WHAT IT DOES.
 *   1. Reads the package's package.json: the transpiler version and the
 *      open-abap-core commit output/ was built with.
 *   2. Finds @abaplint/transpiler-cli in the project. Installed at that
 *      version: runs it. Installed at another version: stops - a transpile
 *      with another transpiler runs on this package's runtime by luck. Not
 *      installed: runs it through `npx -p @abaplint/transpiler-cli@<version>`
 *      and says how to install it (`--save-exact`, so a later `npm install`
 *      does not move it).
 *   3. Checks out open-abap-core at the recorded commit, once, into
 *      node_modules/.cache/abap2ui5-node-runtime/open-abap-core/<commit>
 *      (git fetch --depth 1 of that one commit). --core <dir> or
 *      ABAP2UI5_OPEN_ABAP_CORE names a checkout to use instead.
 *   4. Writes the transpile config (the README's, with the paths filled in)
 *      and runs the transpile into a folder below node_modules/.cache.
 *      --config <file> uses the host's own config instead; a library in it
 *      with the open-abap-core url and an empty folder is filled at the
 *      recorded commit all the same.
 *   5. Runs own-apps.mjs: the host's classes alone into the apps folder,
 *      their imports pointed at the package's output/.
 *
 * Every path the transpiler reads has to be below the project (it joins the
 * folders to its working directory), so the package has to be installed in
 * the project - which a host that imports it is anyway.
 *
 * Also a module: import { transpile, transpileConfig } from "@abap2ui5/node-runtime/setup/transpile.mjs".
 */
import fs from "node:fs";
import path from "node:path";
import { execFileSync } from "node:child_process";
import { createRequire } from "node:module";
import { fileURLToPath } from "node:url";
import { ownApps } from "./own-apps.mjs";

const PACKAGE = "@abap2ui5/node-runtime";
const TRANSPILER = "@abaplint/transpiler-cli";
export const OPEN_ABAP_CORE_URL = "https://github.com/open-abap/open-abap-core";
const PACKAGE_DIR = fileURLToPath(new URL("../", import.meta.url));
const CACHE = path.join("node_modules", ".cache", "abap2ui5-node-runtime");

const NPX = process.platform === "win32" ? "npx.cmd" : "npx";

/** A path as the transpiler reads a library folder: "/<relative to cwd>", forward slashes. */
function libFolder(cwd, dir) {
  return "/" + path.relative(cwd, dir).split(path.sep).join("/");
}

function below(cwd, dir) {
  const rel = path.relative(cwd, dir);
  return rel !== "" && !rel.startsWith("..") && !path.isAbsolute(rel);
}

/**
 * The transpile config for a host's classes: the README's "Your own apps"
 * config with the paths filled in. Pure.
 * @param {{ cwd: string, abap: string, output: string, packageDir?: string, core: string }} options
 *   every path absolute; `abap` the host's classes, `output` where the
 *   transpiler writes, `core` the open-abap-core checkout
 * @returns {object} the config, as abap_transpile.json holds it
 */
export function transpileConfig({ cwd, abap, output, packageDir = PACKAGE_DIR, core }) {
  for (const [what, dir] of [["the ABAP folder", abap], ["the output folder", output], ["the package", packageDir], ["open-abap-core", core]]) {
    if (!below(cwd, dir)) {
      throw new Error(`abap2ui5-transpile: ${what} (${dir}) is not below the project (${cwd}) - the transpiler reads every folder relative to the project; `
        + (what === "the package" ? `install ${PACKAGE} in the project (npm install ${PACKAGE})` : "move it below the project"));
    }
  }
  return {
    input_folder: path.relative(cwd, abap).split(path.sep).join("/"),
    output_folder: path.relative(cwd, output).split(path.sep).join("/"),
    libs: [
      { folder: libFolder(cwd, path.join(packageDir, "downport")), files: "/**/*.*" },
      { url: OPEN_ABAP_CORE_URL, folder: libFolder(cwd, core) },
    ],
    write_unit_tests: false,
    options: { ignoreSyntaxCheck: false, addFilenames: true, addCommonJS: true, unknownTypes: "runtimeError" },
  };
}

/**
 * How to run the transpiler the package names. Pure.
 * @param {{ version: string, installed?: { version: string, bin: string } | null }} options
 *   `installed` the project's @abaplint/transpiler-cli, when there is one
 * @returns {{ command: string, args: string[], note?: string }} the command
 *   to run with the config file appended
 */
export function transpilerCommand({ version, installed }) {
  if (!version) {
    throw new Error(`abap2ui5-transpile: this ${PACKAGE} does not record the transpiler it was built with (abap2ui5.transpiler) - 1.146.0 or later does`);
  }
  if (installed && installed.version !== version) {
    throw new Error(`abap2ui5-transpile: the project has ${TRANSPILER} ${installed.version}, and this ${PACKAGE} was built with ${version} - `
      + `transpiler output is tied to its runtime, so a transpile with another version runs here by luck. `
      + `Install the one the package names:\n  npm install --save-dev --save-exact ${TRANSPILER}@${version}`);
  }
  if (installed) return { command: process.execPath, args: [installed.bin] };
  return {
    command: NPX,
    args: ["--yes", "-p", `${TRANSPILER}@${version}`, "abap_transpile"],
    note: `${TRANSPILER} is not installed in the project - running it through npx at ${version}. `
      + `To keep it: npm install --save-dev --save-exact ${TRANSPILER}@${version}`,
  };
}

/** The package's manifest - package.json next to output/ in the package; in the
 * abap2UI5 checkout, where node/ has none on purpose, the template it is
 * packed from (which records no build, so the checks below say so). */
function manifest() {
  const packed = path.join(PACKAGE_DIR, "package.json");
  const template = fileURLToPath(new URL("./npm.package.json", import.meta.url));
  return JSON.parse(fs.readFileSync(fs.existsSync(packed) ? packed : template, "utf8"));
}

/** The project's @abaplint/transpiler-cli: its version and the abap_transpile bin, or null. */
function installedTranspiler(cwd) {
  try {
    const require = createRequire(path.join(cwd, "package.json"));
    const manifest = require.resolve(`${TRANSPILER}/package.json`);
    const pkg = JSON.parse(fs.readFileSync(manifest, "utf8"));
    const bin = typeof pkg.bin === "string" ? pkg.bin : pkg.bin?.abap_transpile;
    if (!bin) return null;
    return { version: pkg.version, bin: path.join(path.dirname(manifest), bin) };
  } catch {
    return null;
  }
}

function git(args, cwd) {
  return execFileSync("git", args, { cwd, encoding: "utf8", stdio: ["ignore", "pipe", "pipe"] }).trim();
}

/**
 * open-abap-core at one commit, in `dir`: fetched once, reused afterwards.
 * @param {{ dir: string, commit: string, log?: (line: string) => void }} options
 * @returns {string} dir
 */
export function ensureCore({ dir, commit, log = () => {} }) {
  if (!commit) {
    throw new Error(`abap2ui5-transpile: this ${PACKAGE} does not record the open-abap-core commit it was built against (abap2ui5.openAbapCore) - `
      + "1.146.0 or later does; name a checkout with --core <dir> or ABAP2UI5_OPEN_ABAP_CORE");
  }
  if (fs.existsSync(path.join(dir, ".git"))) {
    try {
      if (git(["rev-parse", "HEAD"], dir) === commit) return dir;
    } catch { /* re-fetch below */ }
  }
  log(`abap2ui5-transpile: open-abap-core ${commit.slice(0, 7)} -> ${dir}`);
  fs.rmSync(dir, { recursive: true, force: true });
  fs.mkdirSync(dir, { recursive: true });
  try {
    git(["init", "-q"], dir);
    git(["fetch", "-q", "--depth", "1", OPEN_ABAP_CORE_URL, commit], dir);
    git(["checkout", "-q", "FETCH_HEAD"], dir);
  } catch (e) {
    throw new Error(`abap2ui5-transpile: could not check out open-abap-core at ${commit} (git: ${e.stderr?.toString().trim() || e.message}) - `
      + "git and network access are needed once; or name a checkout with --core <dir> or ABAP2UI5_OPEN_ABAP_CORE", { cause: e });
  }
  return dir;
}

/** A host's own config: the open-abap-core library in it, when it has one with a folder. */
function coreLibOf(config) {
  return (config.libs || []).find((lib) => lib.url && /open-abap-core/.test(lib.url) && lib.folder) || null;
}

/**
 * Transpile a host's classes against the package and load them on its runtime.
 * @param {{ abap: string, apps: string, cwd?: string, config?: string, core?: string, output?: string, keep?: boolean, log?: (line: string) => void }} options
 *   `abap` the host's ABAP folder, `apps` where its transpiled classes go;
 *   `config` the host's own abap_transpile.json instead of the generated one;
 *   `core` an open-abap-core checkout to use; `output` where the transpiler
 *   writes (default below node_modules/.cache); `keep` leaves that folder
 * @returns {{ files: string[], modules: string[], output: string, config: string }}
 */
export function transpile({ abap, apps, cwd = process.cwd(), config, core, output, keep = false, log = () => {} }) {
  const cache = path.join(cwd, CACHE);
  const abapDir = path.resolve(cwd, abap);
  const appsDir = path.resolve(cwd, apps);
  if (!fs.existsSync(abapDir)) throw new Error(`abap2ui5-transpile: ${abapDir} does not exist`);
  const built = manifest().abap2ui5 || {};

  const coreDir = core || process.env.ABAP2UI5_OPEN_ABAP_CORE
    ? path.resolve(cwd, core || process.env.ABAP2UI5_OPEN_ABAP_CORE)
    : ensureCore({ dir: path.join(cache, "open-abap-core", built.openAbapCore || "unknown"), commit: built.openAbapCore, log });
  if (!fs.existsSync(coreDir)) throw new Error(`abap2ui5-transpile: open-abap-core checkout ${coreDir} does not exist`);

  let configPath;
  let outputDir;
  if (config) {
    configPath = path.resolve(cwd, config);
    const own = JSON.parse(fs.readFileSync(configPath, "utf8"));
    outputDir = path.resolve(cwd, own.output_folder);
    const lib = coreLibOf(own);
    if (lib && !fs.existsSync(path.join(cwd, lib.folder))) {
      ensureCore({ dir: path.join(cwd, lib.folder), commit: built.openAbapCore, log });
    }
  } else {
    outputDir = output ? path.resolve(cwd, output) : path.join(cache, "transpile-output");
    const generated = transpileConfig({ cwd, abap: abapDir, output: outputDir, core: coreDir });
    fs.mkdirSync(cache, { recursive: true });
    configPath = path.join(cache, "abap_transpile.json");
    fs.writeFileSync(configPath, JSON.stringify(generated, null, 2) + "\n");
  }

  const run = transpilerCommand({ version: built.transpiler, installed: installedTranspiler(cwd) });
  if (run.note) log(run.note);
  log(`abap2ui5-transpile: ${TRANSPILER} ${built.transpiler} on ${path.relative(cwd, configPath)}`);
  fs.rmSync(outputDir, { recursive: true, force: true });
  execFileSync(run.command, [...run.args, configPath], { cwd, stdio: "inherit" });

  const result = ownApps({ output: outputDir, apps: appsDir });
  if (!keep && !config) fs.rmSync(outputDir, { recursive: true, force: true });
  return { ...result, output: outputDir, config: configPath };
}

/* Run as the bin, not when imported. */
const invoked = process.argv[1] && fs.realpathSync(process.argv[1]) === fs.realpathSync(fileURLToPath(import.meta.url));
if (invoked) {
  const usage = "usage: abap2ui5-transpile <abap folder> <apps folder> [--config <abap_transpile.json>] [--core <open-abap-core checkout>] [--output <dir>] [--keep]";
  const positional = [];
  const opts = {};
  const argv = process.argv.slice(2);
  for (let i = 0; i < argv.length; i += 1) {
    const arg = argv[i];
    if (arg === "--keep") opts.keep = true;
    else if (["--config", "--core", "--output"].includes(arg) && argv[i + 1]) opts[arg.slice(2)] = argv[++i];
    else if (arg.startsWith("--")) {
      console.error(`abap2ui5-transpile: unknown option ${arg}\n${usage}`);
      process.exit(2);
    } else positional.push(arg);
  }
  if (positional.length !== 2) {
    console.error(usage);
    process.exit(2);
  }
  try {
    const [abap, apps] = positional;
    const { modules, files } = transpile({ abap, apps, ...opts, log: (line) => console.error(line) });
    console.log(`abap2ui5-transpile: ${modules.length} class(es) of your own into ${apps} (${files.length} files), `
      + `every other import on ${PACKAGE}: ${modules.join(", ")}\n`
      + `  load them after the runtime has booted:  await initialize(); await import("./${path.relative(process.cwd(), path.resolve(apps)).split(path.sep).join("/")}/index.mjs");`);
  } catch (e) {
    console.error(e.message);
    process.exit(1);
  }
}
