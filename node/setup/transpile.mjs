#!/usr/bin/env node
/*
 * transpile.mjs - the framework and a host's own ABAP classes, transpiled
 * together into one runtime, in one command. Shipped in
 * @abap2ui5/node-runtime as setup/transpile.mjs and as the bin
 * `abap2ui5-transpile`; npm.README.md, "Your own apps", is the recipe it runs.
 *
 *   npx abap2ui5-transpile abap abap2ui5        # abap/*.abap + the framework -> abap2ui5/
 *
 * then import the package's exports from that output instead of from the
 * package - they run on it:
 *   import { serve } from "./abap2ui5/host.mjs";
 *
 * WHY ONE TRANSPILE. The package ships the framework transpiled (output/),
 * and a host's classes could be transpiled on their own against its sources
 * and loaded next to it. But the transpiler writes every library it reads
 * into the output again, and a transpiled class imports what it extends by
 * a relative path - so the host's classes loaded a second copy of the
 * framework and of open-abap-core, whose second CX_ROOT broke every CATCH.
 * Until 1.147.0 own-apps.mjs rewrote those imports after the transpile, and
 * abaplint/transpiler#1999 proposed a transpiler option to the same end.
 * The transpiler's maintainer preferred the other way round (#1999): one
 * transpile of everything, with one transpiler version, gives consistent
 * output and nothing to rewrite. So this file transpiles the framework's
 * sources (the package's downport/), open-abap-core and express-icf-shim at
 * the commits output/ was built against, and the host's classes, in one run
 * into one output folder - a complete runtime with the same layout as the
 * package's output/ (project/, open-abap-core/, express-icf-shim/, init.mjs),
 * whose host.mjs is the package's entry point bound to it. About ten seconds for
 * the framework's thousand objects; the playground, which recompiles on
 * every edit, compiles in-process against a registry and is not this path.
 *
 * WHAT IT DOES.
 *   1. Reads the package's package.json: the transpiler version and the
 *      open-abap-core and express-icf-shim commits output/ was built with.
 *   2. Finds @abaplint/transpiler-cli in the project. Installed at that
 *      version: runs it. Installed at another version: stops - transpiler
 *      output is tied to its runtime, and the package pins the runtime.
 *      Not installed: runs it through `npx -p @abaplint/transpiler-cli@<version>`
 *      and says how to install it (`--save-exact`, so a later `npm install`
 *      does not move it).
 *   3. Checks out open-abap-core and express-icf-shim at the recorded
 *      commits, once each, into
 *      node_modules/.cache/abap2ui5-node-runtime/<library>/<commit>
 *      (git fetch --depth 1 of that one commit). --core <dir> /
 *      ABAP2UI5_OPEN_ABAP_CORE and --shim <dir> / ABAP2UI5_EXPRESS_ICF_SHIM
 *      name checkouts to use instead.
 *   4. Writes the transpile config - the package's own build, with the
 *      host's folder as a second input - into node_modules/.cache and runs
 *      the transpile into the output folder, which it empties first (a
 *      folder that is not a transpile output it refuses to empty), and
 *      writes host.mjs into it: the package's exports, bound to that output
 *      (srv/framework.mjs, hostEntry( )).
 *      --config <file> runs the host's own config instead; a library in it
 *      with the open-abap-core or express-icf-shim url and a folder that
 *      does not exist is filled at the recorded commit all the same.
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
import { hostEntry } from "../srv/framework.mjs";

const PACKAGE = "@abap2ui5/node-runtime";
const TRANSPILER = "@abaplint/transpiler-cli";
export const OPEN_ABAP_CORE_URL = "https://github.com/open-abap/open-abap-core";
export const EXPRESS_ICF_SHIM_URL = "https://github.com/open-abap/express-icf-shim";
const PACKAGE_DIR = fileURLToPath(new URL("../", import.meta.url));
const CACHE = path.join("node_modules", ".cache", "abap2ui5-node-runtime");

const NPX = process.platform === "win32" ? "npx.cmd" : "npx";

/* The two git libraries of the transpile: where they come from, the key in
 * the package's `abap2ui5` record that names their commit, and the option
 * and variable that name a checkout of the host's own instead. */
const LIBRARIES = {
  core: { name: "open-abap-core", url: OPEN_ABAP_CORE_URL, recorded: "openAbapCore", option: "--core", env: "ABAP2UI5_OPEN_ABAP_CORE" },
  shim: { name: "express-icf-shim", url: EXPRESS_ICF_SHIM_URL, recorded: "expressIcfShim", option: "--shim", env: "ABAP2UI5_EXPRESS_ICF_SHIM" },
};

/** A path relative to `from`, forward slashes. */
function posixRelative(from, to) {
  return path.relative(from, to).split(path.sep).join("/");
}

/** A path as the transpiler reads a library folder: "/<relative to cwd>". */
function libFolder(cwd, dir) {
  return "/" + posixRelative(cwd, dir);
}

function below(cwd, dir) {
  const rel = path.relative(cwd, dir);
  return rel !== "" && !rel.startsWith("..") && !path.isAbsolute(rel);
}

/**
 * The transpile config for the framework and a host's classes: the
 * package's own build (abap2UI5's node/setup/abap_transpile.json without the
 * unit tests), with the host's folder as a second input. Pure.
 * @param {{ cwd: string, abap: string, output: string, packageDir?: string, core: string, shim: string }} options
 *   every path absolute; `abap` the host's classes, `output` where the
 *   transpiler writes, `core` and `shim` the two library checkouts
 * @returns {object} the config, as abap_transpile.json holds it
 */
export function transpileConfig({ cwd, abap, output, packageDir = PACKAGE_DIR, core, shim }) {
  const folders = [["the ABAP folder", abap], ["the output folder", output], ["the package", packageDir], ["open-abap-core", core], ["express-icf-shim", shim]];
  for (const [what, dir] of folders) {
    if (!below(cwd, dir)) {
      throw new Error(`abap2ui5-transpile: ${what} (${dir}) is not below the project (${cwd}) - the transpiler reads every folder relative to the project; `
        + (what === "the package" ? `install ${PACKAGE} in the project (npm install ${PACKAGE})` : "move it below the project"));
    }
  }
  const downport = path.join(packageDir, "downport");
  if (path.resolve(abap) === path.resolve(output) || below(output, abap) || below(abap, output)) {
    throw new Error(`abap2ui5-transpile: the output folder (${output}) and the ABAP folder (${abap}) overlap - the output folder is emptied before every transpile`);
  }
  return {
    input_folder: [posixRelative(cwd, abap), posixRelative(cwd, downport)],
    output_folder: posixRelative(cwd, output),
    libs: [
      { url: OPEN_ABAP_CORE_URL, folder: libFolder(cwd, core) },
      { url: EXPRESS_ICF_SHIM_URL, folder: libFolder(cwd, shim) },
    ],
    write_unit_tests: false,
    options: {
      ignoreSyntaxCheck: false,
      addFilenames: true,
      addCommonJS: true,
      unknownTypes: "runtimeError",
      populateTables: { reposrc: false },
      // init.mjs imports the database setup by this path, relative to itself
      setup: { filename: posixRelative(output, path.join(packageDir, "setup", "setup.mjs")), preFunction: "setup" },
    },
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
 * A git library at one commit, in `dir`: fetched once, reused afterwards.
 * @param {{ dir: string, commit: string, library?: { name: string, url: string, recorded: string, option: string, env: string }, log?: (line: string) => void }} options
 *   `library` one of LIBRARIES (default open-abap-core)
 * @returns {string} dir
 */
export function ensureCheckout({ dir, commit, library = LIBRARIES.core, log = () => {} }) {
  if (!commit) {
    throw new Error(`abap2ui5-transpile: this ${PACKAGE} does not record the ${library.name} commit it was built against (abap2ui5.${library.recorded}) - `
      + `name a checkout with ${library.option} <dir> or ${library.env}`);
  }
  if (fs.existsSync(path.join(dir, ".git"))) {
    try {
      if (git(["rev-parse", "HEAD"], dir) === commit) return dir;
    } catch { /* re-fetch below */ }
  }
  log(`abap2ui5-transpile: ${library.name} ${commit.slice(0, 7)} -> ${dir}`);
  fs.rmSync(dir, { recursive: true, force: true });
  fs.mkdirSync(dir, { recursive: true });
  try {
    git(["init", "-q"], dir);
    git(["fetch", "-q", "--depth", "1", library.url, commit], dir);
    git(["checkout", "-q", "FETCH_HEAD"], dir);
  } catch (e) {
    throw new Error(`abap2ui5-transpile: could not check out ${library.name} at ${commit} (git: ${e.stderr?.toString().trim() || e.message}) - `
      + `git and network access are needed once; or name a checkout with ${library.option} <dir> or ${library.env}`, { cause: e });
  }
  return dir;
}

/** open-abap-core at one commit - ensureCheckout( ) for that library. */
export function ensureCore({ dir, commit, log = () => {} }) {
  return ensureCheckout({ dir, commit, library: LIBRARIES.core, log });
}

/** A host's own config: its library with that url, when it names a folder. */
function libOf(config, library) {
  return (config.libs || []).find((lib) => lib.url && lib.url.replace(/\.git$/, "") === library.url && lib.folder) || null;
}

/**
 * Empty the output folder for a transpile - only when it is one: missing,
 * empty, or holding the init.mjs a transpile writes. Anything else is a
 * folder the host keeps something else in, and it is refused.
 */
function emptyOutput(dir) {
  if (!fs.existsSync(dir)) return;
  const entries = fs.readdirSync(dir);
  if (entries.length && !entries.includes("init.mjs")) {
    throw new Error(`abap2ui5-transpile: ${dir} is not empty and holds no transpile output (no init.mjs) - name a folder of its own for the output, it is emptied before every transpile`);
  }
  fs.rmSync(dir, { recursive: true, force: true });
}

/**
 * The output's entry point: host.mjs, the package's exports bound to this
 * output, with claim.mjs, its first import (srv/framework.mjs, hostEntry( )),
 * and its types - the package's.
 * @param {string} dir the transpile's output folder
 */
export function writeEntry(dir) {
  for (const [file, text] of Object.entries(hostEntry({ packageName: PACKAGE }))) fs.writeFileSync(path.join(dir, file), text);
  fs.writeFileSync(path.join(dir, "host.d.ts"), `// Written by abap2ui5-transpile - the types of ${PACKAGE}, which host.mjs re-exports.\nexport * from "${PACKAGE}";\n`);
}

/**
 * Transpile the framework and a host's classes into one runtime.
 * @param {{ abap: string, output: string, cwd?: string, config?: string, core?: string, shim?: string, log?: (line: string) => void }} options
 *   `abap` the host's ABAP folder, `output` the folder the runtime goes to
 *   (its host.mjs is what the host imports); `config` the host's own
 *   abap_transpile.json instead of the generated one (its output_folder
 *   wins); `core` and `shim` checkouts of the two libraries to use
 * @returns {{ output: string, config: string }}
 */
export function transpile({ abap, output, cwd = process.cwd(), config, core, shim, log = () => {} }) {
  const cache = path.join(cwd, CACHE);
  const built = manifest().abap2ui5 || {};
  const checkout = (key, given) => {
    const library = LIBRARIES[key];
    const named = given || process.env[library.env];
    const dir = named
      ? path.resolve(cwd, named)
      : ensureCheckout({ dir: path.join(cache, library.name, built[library.recorded] || "unknown"), commit: built[library.recorded], library, log });
    if (!fs.existsSync(dir)) throw new Error(`abap2ui5-transpile: ${library.name} checkout ${dir} does not exist`);
    return dir;
  };

  let configPath;
  let outputDir;
  if (config) {
    configPath = path.resolve(cwd, config);
    const own = JSON.parse(fs.readFileSync(configPath, "utf8"));
    outputDir = path.resolve(cwd, own.output_folder);
    for (const library of Object.values(LIBRARIES)) {
      const lib = libOf(own, library);
      if (lib && !fs.existsSync(path.join(cwd, lib.folder))) {
        ensureCheckout({ dir: path.join(cwd, lib.folder), commit: built[library.recorded], library, log });
      }
    }
  } else {
    const abapDir = path.resolve(cwd, abap);
    if (!fs.existsSync(abapDir)) throw new Error(`abap2ui5-transpile: ${abapDir} does not exist`);
    outputDir = path.resolve(cwd, output);
    const generated = transpileConfig({ cwd, abap: abapDir, output: outputDir, core: checkout("core", core), shim: checkout("shim", shim) });
    fs.mkdirSync(cache, { recursive: true });
    configPath = path.join(cache, "abap_transpile.json");
    fs.writeFileSync(configPath, JSON.stringify(generated, null, 2) + "\n");
  }

  const run = transpilerCommand({ version: built.transpiler, installed: installedTranspiler(cwd) });
  if (run.note) log(run.note);
  log(`abap2ui5-transpile: ${TRANSPILER} ${built.transpiler} on ${path.relative(cwd, configPath)}`);
  emptyOutput(outputDir);
  // npx.cmd is a batch file, and Node refuses to spawn one without a shell
  // since CVE-2024-27980 (spawnSync npx.cmd EINVAL on every Node >= 22) -
  // pack-npm.mjs runs npm.cmd the same way. Through the shell the arguments
  // are joined unquoted, so each one is quoted for a path with a blank
  const viaShell = run.command === NPX && process.platform === "win32";
  const args = [...run.args, configPath].map((a) => (viaShell ? `"${a}"` : a));
  execFileSync(run.command, args, { cwd, stdio: "inherit", shell: viaShell });
  if (!fs.existsSync(path.join(outputDir, "init.mjs"))) {
    throw new Error(`abap2ui5-transpile: the transpile wrote no ${path.join(outputDir, "init.mjs")}`);
  }
  writeEntry(outputDir);
  return { output: outputDir, config: configPath };
}

/* Run as the bin, not when imported. */
const invoked = process.argv[1] && fs.realpathSync(process.argv[1]) === fs.realpathSync(fileURLToPath(import.meta.url));
if (invoked) {
  const usage = "usage: abap2ui5-transpile <abap folder> <output folder> [--config <abap_transpile.json>] [--core <open-abap-core checkout>] [--shim <express-icf-shim checkout>]";
  const positional = [];
  const opts = {};
  const argv = process.argv.slice(2);
  for (let i = 0; i < argv.length; i += 1) {
    const arg = argv[i];
    if (["--config", "--core", "--shim"].includes(arg) && argv[i + 1]) opts[arg.slice(2)] = argv[++i];
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
    const [abap, output] = positional;
    const result = transpile({ abap, output, ...opts, log: (line) => console.error(line) });
    const rel = posixRelative(process.cwd(), result.output);
    console.log(`abap2ui5-transpile: the framework and your classes in ${rel}/ - import the package's exports from there:\n`
      + `  import { serve } from "./${rel}/host.mjs";`);
  } catch (e) {
    console.error(e.message);
    process.exit(1);
  }
}
