#!/usr/bin/env node
/*
 * pack-frontend — app/webapp as the npm package @abap2ui5/frontend.
 *
 * The UI5 component z2ui5, for the consumers that do not get it from an ABAP
 * system: a UI5 app that embeds abap2UI5 apps (abap2UI5/embed builds on it), a
 * static host or a CDN. It is the THIRD delivery of app/webapp next to the
 * BSP/cloud branches of abap2UI5/frontend (tools/build-branches.mjs) and the
 * copy inside @abap2ui5/node (node/setup/pack-npm.mjs) - same files, same
 * commit, a different mechanism for a different consumer.
 *
 * What goes in, and where it comes from:
 *   package.json   frontend/npm/package.json, the version set to the
 *                  framework's (root package.json) and the commit recorded
 *                  under `abap2ui5`
 *   ui5.yaml       frontend/npm/ui5.yaml - a UI5 tooling project of type
 *                  module, /resources/z2ui5/ -> webapp/
 *   README.md      frontend/npm/README.md - the consumer documentation
 *   LICENSE        the repository's
 *   webapp/        app/webapp, UNCHANGED, plus
 *   webapp/Component-preload.js(.map)
 *                  built here with the UI5 CLI of app/ (npm --prefix app ci):
 *                  one request for the whole component instead of ~50. The
 *                  map is pointed at the unminified sources the package
 *                  ships under their own names, not at the -dbg copies that
 *                  exist only in the build output (the fix abap2UI5/embed's
 *                  sync-frontend.mjs made first).
 *
 * The BSP branches build their bundle differently (tools/app2bsp/preload.js)
 * because a BSP page name cannot carry a hyphen and a page line cannot be
 * longer than 255 characters. Neither limit exists on npm, so the package
 * ships the conventional Component-preload.js that UI5 requests by itself.
 *
 *   node tools/pack-frontend.mjs                 -> npm-package/abap2ui5-frontend-<version>.tgz
 *   node tools/pack-frontend.mjs --out <dir>     -> somewhere else
 *   node tools/pack-frontend.mjs --check         pack, then PROVE the tarball:
 *     install it into a scratch UI5 application the way a consumer would and
 *     run `ui5 build --all` there - the component and its preload have to
 *     arrive under dist/resources/z2ui5/. That is the README's claim, and only
 *     an install can check it: the working tree has every file whether or
 *     not `files` lists it.
 */
import { execFileSync } from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { createRequire } from "node:module";
import { fileURLToPath } from "node:url";

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const WIN = process.platform === "win32";
const NPM = WIN ? "npm.cmd" : "npm";
const WEBAPP = path.join(ROOT, "app", "webapp");
const DATA = path.join(ROOT, "frontend", "npm");

const pkg = JSON.parse(fs.readFileSync(path.join(ROOT, "package.json"), "utf8"));

// --- arguments --------------------------------------------------------------
let outDir = path.join(ROOT, "npm-package");
let check = false;
const args = process.argv.slice(2);
for (let i = 0; i < args.length; i += 1) {
  if (args[i] === "--out" && args[i + 1]) {
    outDir = path.resolve(args[i + 1]);
    i += 1;
  } else if (args[i] === "--check") {
    check = true;
  } else {
    console.error(`pack-frontend: unknown argument ${JSON.stringify(args[i])}`);
    console.error("  usage: node tools/pack-frontend.mjs [--out <dir>] [--check]");
    process.exit(2);
  }
}

// --- the UI5 CLI -------------------------------------------------------------
/* app/'s, the one every frontend gate already installs - resolved rather than
 * spawned through npx, so the version is the lockfile's and nothing is
 * downloaded behind the build's back. */
function ui5Cli() {
  try {
    return createRequire(path.join(ROOT, "app", "package.json")).resolve("@ui5/cli/bin/ui5.cjs");
  } catch {
    console.error("pack-frontend: the UI5 CLI is not installed - run `npm --prefix app ci` first");
    process.exit(1);
  }
}
const UI5 = ui5Cli();
const ui5 = (argv, cwd) => execFileSync(process.execPath, [UI5, ...argv], { cwd, stdio: "inherit" });

function gitHead() {
  try {
    return execFileSync("git", ["rev-parse", "HEAD"], { cwd: ROOT, stdio: ["ignore", "pipe", "ignore"] })
      .toString().trim() || null;
  } catch {
    return null;
  }
}

// --- the preload -------------------------------------------------------------
/* A throwaway application project around a copy of the webapp: app/ui5.yaml
 * is the Fiori dev project's, with middleware that has nothing to do with a
 * build, so it is not reused. Returns the two files to add to the package. */
function buildPreload(work) {
  const project = path.join(work, "preload");
  fs.cpSync(WEBAPP, path.join(project, "webapp"), { recursive: true });
  fs.writeFileSync(path.join(project, "package.json"),
    JSON.stringify({ name: "z2ui5-preload", version: "0.0.0", private: true }));
  fs.writeFileSync(path.join(project, "ui5.yaml"),
    ['specVersion: "4.0"', "metadata:", "  name: z2ui5-preload", "type: application", ""].join("\n"));
  const dist = path.join(project, "dist");
  console.log("pack-frontend: building Component-preload.js");
  ui5(["build", "--dest", dist, "--loglevel", "warn"], project);

  const bundle = path.join(dist, "Component-preload.js");
  if (!fs.existsSync(bundle)) {
    console.error("pack-frontend: ui5 build wrote no Component-preload.js");
    process.exit(1);
  }
  const files = { "Component-preload.js": fs.readFileSync(bundle, "utf8") };
  const mapFile = path.join(dist, "Component-preload.js.map");
  if (fs.existsSync(mapFile)) {
    const map = JSON.parse(fs.readFileSync(mapFile, "utf8"));
    for (const section of map.sections || [{ map }]) {
      // Foo-dbg.js -> Foo.js, App-dbg.controller.js -> App.controller.js
      section.map.sources = section.map.sources.map((s) => s.replace(/-dbg\.(?=[^/]*$)/, "."));
    }
    files["Component-preload.js.map"] = JSON.stringify(map);
  }
  return files;
}

// --- stage and pack ---------------------------------------------------------
const template = JSON.parse(fs.readFileSync(path.join(DATA, "package.json"), "utf8"));
delete template._comment;
template.version = pkg.version;
template.abap2ui5 = { commit: gitHead(), builtAt: new Date().toISOString() };

fs.mkdirSync(outDir, { recursive: true });
const work = fs.mkdtempSync(path.join(os.tmpdir(), "abap2ui5-frontend-"));
let tarball;
try {
  const preload = buildPreload(work);
  const stage = path.join(work, "stage");
  fs.mkdirSync(stage);
  fs.writeFileSync(path.join(stage, "package.json"), `${JSON.stringify(template, null, 2)}\n`);
  fs.copyFileSync(path.join(DATA, "ui5.yaml"), path.join(stage, "ui5.yaml"));
  fs.copyFileSync(path.join(DATA, "README.md"), path.join(stage, "README.md"));
  fs.copyFileSync(path.join(ROOT, "LICENSE"), path.join(stage, "LICENSE"));
  fs.cpSync(WEBAPP, path.join(stage, "webapp"), { recursive: true });
  for (const [name, content] of Object.entries(preload)) {
    fs.writeFileSync(path.join(stage, "webapp", name), content);
  }

  const packed = JSON.parse(
    execFileSync(NPM, ["pack", "--json", "--pack-destination", outDir], {
      cwd: stage, shell: WIN, stdio: ["ignore", "pipe", "inherit"], maxBuffer: 64 * 1024 * 1024,
    }).toString(),
  )[0];
  tarball = path.join(outDir, packed.filename);
  const files = new Set(packed.files.map((f) => f.path));

  /* Every file of app/webapp has to be in the tarball - it is a copy, not a
   * selection - plus the preload and the four package files. */
  const webappFiles = fs.readdirSync(WEBAPP, { recursive: true, withFileTypes: true })
    .filter((d) => d.isFile())
    .map((d) => path.relative(ROOT, path.join(d.parentPath ?? d.path, d.name)).split(path.sep).join("/").replace(/^app\//, ""));
  const MUST = ["package.json", "README.md", "LICENSE", "ui5.yaml", "webapp/Component-preload.js", ...webappFiles];
  const problems = MUST.filter((f) => !files.has(f)).map((f) => `${f} is not in the tarball`);
  if (!preload["Component-preload.js"].includes('sap.ui.predefine("z2ui5/Component"')) {
    problems.push("Component-preload.js does not define z2ui5/Component");
  }
  if (problems.length) {
    fs.rmSync(tarball, { force: true });
    console.error("pack-frontend: the tarball is not what a consumer expects - removed it:");
    for (const p of problems.slice(0, 20)) console.error(`  ${p}`);
    process.exit(1);
  }

  const kb = (packed.size / 1024).toFixed(0);
  const unpackedKb = (packed.unpackedSize / 1024).toFixed(0);
  console.log(`pack-frontend: ${path.relative(ROOT, tarball) || tarball} (${kb} kB packed, ${unpackedKb} kB unpacked, ${files.size} files)`);
  console.log(`  ${template.name}@${template.version}, commit ${template.abap2ui5.commit ?? "unknown"}`);
} finally {
  fs.rmSync(work, { recursive: true, force: true });
}

if (!check) process.exit(0);

// --- prove it ---------------------------------------------------------------
/* A UI5 application that has never heard of this repository, with the
 * tarball as its one dependency, built with `ui5 build --all`: the tooling
 * has to find the package through its ui5.yaml and copy the component,
 * preload included, into dist/resources/z2ui5/. No framework section in the
 * app's ui5.yaml, so nothing is downloaded from the UI5 CDN or npm for it. */
console.log("\npack-frontend --check: installing the tarball into a scratch UI5 app");
const scratch = fs.mkdtempSync(path.join(os.tmpdir(), "abap2ui5-frontend-check-"));
try {
  fs.writeFileSync(path.join(scratch, "package.json"),
    JSON.stringify({ name: "host", version: "0.0.0", private: true }, null, 2));
  fs.writeFileSync(path.join(scratch, "ui5.yaml"),
    ['specVersion: "4.0"', "metadata:", "  name: host", "type: application", ""].join("\n"));
  fs.mkdirSync(path.join(scratch, "webapp"));
  fs.writeFileSync(path.join(scratch, "webapp", "manifest.json"), JSON.stringify({
    "_version": "1.12.0",
    "sap.app": { id: "host", type: "application", applicationVersion: { version: "0.0.0" } },
  }, null, 2));
  fs.writeFileSync(path.join(scratch, "webapp", "Component.js"),
    'sap.ui.define(["sap/ui/core/UIComponent"], (C) => C.extend("host.Component", { metadata: { manifest: "json" } }));\n');
  execFileSync(NPM, ["install", "--no-audit", "--no-fund", tarball], { cwd: scratch, shell: WIN, stdio: "inherit" });
  ui5(["build", "--all", "--dest", "dist", "--loglevel", "warn"], scratch);

  const out = path.join(scratch, "dist", "resources", "z2ui5");
  const expect = ["Component.js", "manifest.json", "Component-preload.js", "core/Context.js", "view/App.view.xml"];
  const missing = expect.filter((f) => !fs.existsSync(path.join(out, f)));
  if (missing.length) {
    console.error(`pack-frontend --check: FAIL - ui5 build --all did not deliver ${missing.join(", ")} under dist/resources/z2ui5/`);
    process.exit(1);
  }
  const manifest = JSON.parse(fs.readFileSync(path.join(out, "manifest.json"), "utf8"));
  if (manifest["sap.app"]?.id !== "z2ui5") {
    console.error("pack-frontend --check: FAIL - dist/resources/z2ui5/manifest.json is not the z2ui5 component");
    process.exit(1);
  }
  console.log("ok  ui5 build --all of a consumer app delivers the component and its preload under resources/z2ui5/");
  console.log("pack-frontend --check: the tarball installs and builds");
} finally {
  fs.rmSync(scratch, { recursive: true, force: true });
}
