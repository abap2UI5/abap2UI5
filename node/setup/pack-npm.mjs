#!/usr/bin/env node
/*
 * pack-npm — the built framework as the npm package @abap2ui5/node-runtime.
 *
 * The SECOND delivery of one transpile, next to pack-backend.mjs's tarball:
 *   - the tarball (backend-<version>.tar.gz) is resolved by NAME from a
 *     GitHub release and carries node/deps and node/downport - what a tool
 *     that downloads and builds against it needs (abap2UI5/mcp-server).
 *   - the package is for a host that RUNS the framework - a CAP plugin, a
 *     container, a serverless function, a plain express app. Such a host is
 *     an ordinary Node project: it declares dependencies in package.json and
 *     `npm i` is the mechanism it already has.
 *
 * What goes in, and where it comes from:
 *   package.json      node/setup/npm.package.json, with the version set to
 *                     the framework's (root package.json) and the two
 *                     @abaplint dependencies pinned to the EXACT versions the
 *                     transpile ran with (the lockfile): transpiler output is
 *                     tied to its runtime, and a caret range would let `npm i`
 *                     pair this output with a runtime it was never run on
 *   README.md         node/setup/npm.README.md - the consumer documentation
 *   LICENSE           the repository's
 *   output/           node/output - the transpiled framework (init.mjs, the
 *                     classes, the generated unit-test runner index.mjs)
 *   setup/setup.mjs   node/setup/setup.mjs - the database hook output/init.mjs
 *                     imports by the relative path abap_transpile.json fixes
 *   srv/host.mjs      node/srv/host.mjs - the entry point (`exports["."]`).
 *                     Same neighbours as in the checkout, so its relative
 *                     imports need no rewriting - see its header
 *   downport/         node/downport - the 7.02-downported ABAP the transpile
 *                     read, so a host can transpile ITS OWN app classes with
 *                     the framework as a library (README, "Your own apps")
 *
 * No webapp/: the UI5 component is embedded in the page the framework serves
 * on GET (src/01/03, transpiled into output/ like everything else), so a Node
 * host needs no frontend files. @abap2ui5/embed-control is app/webapp as files,
 * for the hosts that do (tools/pack-frontend.mjs).
 *
 * Assembled in a STAGING directory outside the checkout: the manifest is
 * deliberately not node/package.json (its header says why), and `npm pack`
 * wants the manifest at the root of what it packs.
 *
 *   node node/setup/pack-npm.mjs                  -> npm-package/abap2ui5-node-runtime-<version>.tgz
 *   node node/setup/pack-npm.mjs --out <dir>      -> somewhere else
 *   node node/setup/pack-npm.mjs --check          pack, then PROVE the tarball:
 *     install it into a scratch project the way a host would and drive it -
 *     serve() has to answer GET / with the framework's page, the UI5 component
 *     embedded, and a class transpiled by the scratch project against downport/ has to register in the running runtime. The listing
 *     says what the tarball holds; only an install says whether it works.
 *
 * Refuses (exit 1) when the built trees are not there and names the scripts
 * that produce them - the courtesy require-transpiled.mjs pays `npm run unit`.
 */
import { execFileSync, spawnSync } from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { fileURLToPath } from "node:url";

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..", "..");
const WIN = process.platform === "win32";
const NPM = WIN ? "npm.cmd" : "npm";

const pkg = JSON.parse(fs.readFileSync(path.join(ROOT, "package.json"), "utf8"));
const lock = JSON.parse(fs.readFileSync(path.join(ROOT, "package-lock.json"), "utf8"));
const locked = (name) => lock.packages?.[`node_modules/${name}`]?.version ?? null;

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
    console.error(`pack-npm: unknown argument ${JSON.stringify(args[i])}`);
    console.error("  usage: node node/setup/pack-npm.mjs [--out <dir>] [--check]");
    process.exit(2);
  }
}

// --- the trees have to be there ---------------------------------------------
/* node/output/init.mjs rather than the directory: prepare-transpile clears
 * the directory before the transpiler writes it, so an empty node/output is
 * a transpile that did not finish. */
const REQUIRED = [
  { path: "node/downport", by: "npm run downport" },
  { path: "node/output/init.mjs", by: "npm run auto_transpile" },
  { path: "node/output/cl_express_icf_shim.clas.mjs", by: "npm run auto_transpile" },
  { path: "node/output/zcl_sicf.clas.mjs", by: "npm run auto_transpile" },
  { path: "node/setup/npm.README.md", by: "the checkout (the package README is committed)" },
];
const missing = REQUIRED.filter((r) => !fs.existsSync(path.join(ROOT, r.path)));
if (missing.length) {
  console.error("pack-npm: nothing to pack - the built framework is not there.\n");
  for (const m of missing) console.error(`  ${m.path.padEnd(42)} missing - produced by: ${m.by}`);
  console.error("\nBuild it first, in this order:\n");
  console.error("    npm run downport         # copy src/, abaplint --fix the copy, strip whitespace (fetches node/deps)");
  console.error("    npm run auto_transpile   # ABAP -> mjs into node/output\n");
  process.exit(1);
}

function gitHead() {
  try {
    return execFileSync("git", ["rev-parse", "HEAD"], { cwd: ROOT, stdio: ["ignore", "pipe", "ignore"] })
      .toString().trim() || null;
  } catch {
    return null;
  }
}

// --- the manifest -----------------------------------------------------------
const template = JSON.parse(fs.readFileSync(path.join(ROOT, "node/setup/npm.package.json"), "utf8"));
delete template._comment;
template.version = pkg.version;
for (const dep of Object.keys(template.dependencies)) {
  const v = locked(dep);
  if (!v) {
    console.error(`pack-npm: ${dep} is not in package-lock.json - the package cannot pin what the transpile ran with`);
    process.exit(1);
  }
  template.dependencies[dep] = v;
}
/* What a host needs to transpile its own apps against this build: the
 * transpiler that wrote output/, so the host's output matches it (README,
 * "Your own apps"). Recorded here rather than in prose that goes stale. */
template.abap2ui5 = {
  commit: gitHead(),
  builtAt: new Date().toISOString(),
  node: process.version,
  transpiler: locked("@abaplint/transpiler-cli"),
};

// --- stage and pack ---------------------------------------------------------
const COPIES = [
  ["node/output", "output"],
  ["node/setup/setup.mjs", "setup/setup.mjs"],
  ["node/srv/host.mjs", "srv/host.mjs"],
  ["node/downport", "downport"],
  ["node/setup/npm.README.md", "README.md"],
  ["LICENSE", "LICENSE"],
];

fs.mkdirSync(outDir, { recursive: true });
const stage = fs.mkdtempSync(path.join(os.tmpdir(), "abap2ui5-node-"));
let tarball;
try {
  fs.writeFileSync(path.join(stage, "package.json"), `${JSON.stringify(template, null, 2)}\n`);
  for (const [from, to] of COPIES) {
    const dest = path.join(stage, to);
    fs.mkdirSync(path.dirname(dest), { recursive: true });
    fs.cpSync(path.join(ROOT, from), dest, { recursive: true });
  }

  /* --json: the file list, so the check below reads what npm packed rather
   * than what this script believes it staged. */
  const packed = JSON.parse(
    execFileSync(NPM, ["pack", "--json", "--pack-destination", outDir], {
      cwd: stage, shell: WIN, stdio: ["ignore", "pipe", "inherit"], maxBuffer: 64 * 1024 * 1024,
    }).toString(),
  )[0];
  tarball = path.join(outDir, packed.filename);
  const files = new Set(packed.files.map((f) => f.path));

  const MUST = [
    "package.json", "README.md", "LICENSE",
    "srv/host.mjs", "setup/setup.mjs", "output/init.mjs", "output/index.mjs",
    "output/cl_express_icf_shim.clas.mjs", "output/zcl_sicf.clas.mjs",
    "downport/02/z2ui5_if_app.intf.abap",
  ];
  const problems = MUST.filter((f) => !files.has(f)).map((f) => `${f} is not in the tarball`);
  const stray = [...files].filter((f) => f.split("/").includes(".git") || f.startsWith("node_modules/") || f.startsWith("webapp/"));
  if (stray.length) problems.push(`${stray.length} stray entr${stray.length === 1 ? "y" : "ies"} (first: ${stray[0]})`);
  if (problems.length) {
    fs.rmSync(tarball, { force: true });
    console.error("pack-npm: the tarball is not what a host expects - removed it:");
    for (const p of problems) console.error(`  ${p}`);
    process.exit(1);
  }

  const mb = (packed.size / 1024 / 1024).toFixed(1);
  const unpackedMb = (packed.unpackedSize / 1024 / 1024).toFixed(1);
  console.log(`pack-npm: ${path.relative(ROOT, tarball) || tarball} (${mb} MB packed, ${unpackedMb} MB unpacked, ${files.size} files)`);
  console.log(
    `  ${template.name}@${template.version}, commit ${template.abap2ui5.commit ?? "unknown"},`
    + ` transpiler ${template.abap2ui5.transpiler ?? "unknown"}, runtime ${template.dependencies["@abaplint/runtime"]}`,
  );
} finally {
  fs.rmSync(stage, { recursive: true, force: true });
}

if (!check) process.exit(0);

// --- prove it ---------------------------------------------------------------
/* A scratch project with the tarball installed, driven the way a host drives
 * it. Two claims the README makes, each checked from the INSTALLED
 * package - the working tree has every file whether or not `files` lists it,
 * so nothing short of an install can catch a missing entry:
 *   1. serve() answers GET / with the framework's page and the UI5 component
 *      embedded in it (the handler, the shim, ZCL_SICF and the database hook
 *      all came along and boot, and the frontend needs no files of its own)
 *   2. a class transpiled BY THE HOST against downport/ registers in the
 *      running runtime - the "Your own apps" recipe, executed literally
 */
console.log("\npack-npm --check: installing the tarball into a scratch project");
const scratch = fs.mkdtempSync(path.join(os.tmpdir(), "abap2ui5-node-check-"));
const run = (cmd, argv, opts = {}) => {
  const r = spawnSync(cmd, argv, { cwd: scratch, shell: WIN, stdio: "inherit", ...opts });
  if (r.status !== 0) {
    console.error(`pack-npm --check: ${[cmd, ...argv].join(" ")} failed (exit ${r.status})`);
    process.exit(1);
  }
};
try {
  fs.writeFileSync(path.join(scratch, "package.json"), JSON.stringify({ name: "host", version: "0.0.0", private: true, type: "module" }, null, 2));
  run(NPM, ["install", "--no-audit", "--no-fund", tarball, `express@${locked("express")}`, `@abaplint/transpiler-cli@${locked("@abaplint/transpiler-cli")}`]);

  // 3. the host's own app, transpiled against the package - the README recipe
  fs.mkdirSync(path.join(scratch, "abap"), { recursive: true });
  fs.writeFileSync(path.join(scratch, "abap/zcl_host_app.clas.abap"), [
    "CLASS zcl_host_app DEFINITION PUBLIC FINAL CREATE PUBLIC.",
    "  PUBLIC SECTION.",
    "    INTERFACES z2ui5_if_app.",
    "ENDCLASS.",
    "",
    "CLASS zcl_host_app IMPLEMENTATION.",
    "  METHOD z2ui5_if_app~main.",
    "    DATA(view) = z2ui5_cl_ui5_view_builder=>factory(",
    "        )->ele( n = `View` ns = `mvc`",
    "            )->a( n = `xmlns`     v = `sap.m`",
    "            )->a( n = `xmlns:mvc` v = `sap.ui.core.mvc`",
    "            )->ele( `Page`",
    "                )->a( n = `title` v = `Hello from the host`",
    "                )->tag( `Text`",
    "                    )->a( n = `text` v = `Transpiled by the host, not by abap2UI5` ).",
    "    client->view_display( view->stringify( ) ).",
    "  ENDMETHOD.",
    "ENDCLASS.",
    "",
  ].join("\n"));
  fs.writeFileSync(path.join(scratch, "abap_transpile.json"), `${JSON.stringify({
    input_folder: "abap",
    output_folder: "output",
    libs: [
      { folder: "/node_modules/@abap2ui5/node-runtime/downport", files: "/**/*.*" },
      { url: "https://github.com/open-abap/open-abap-core", folder: "/deps/open-abap-core" },
    ],
    write_unit_tests: false,
    options: { ignoreSyntaxCheck: false, addFilenames: true, unknownTypes: "runtimeError" },
  }, null, 2)}\n`);
  run(WIN ? "npx.cmd" : "npx", ["abap_transpile", "abap_transpile.json"]);

  fs.writeFileSync(path.join(scratch, "check.mjs"), `
import { serve } from "@abap2ui5/node-runtime";
const fail = (what) => { console.error("FAIL: " + what); process.exit(1); };
const ok = (what) => console.log("ok  " + what);

const server = await serve({ port: 0, host: "127.0.0.1" });
try {
  const url = "http://127.0.0.1:" + server.address().port + "/";
  const res = await fetch(url);
  const body = await res.text();
  if (res.status !== 200) fail("GET / answered " + res.status);
  if (!/z2ui5/.test(body)) fail("GET / is not the abap2UI5 page:\\n" + body.slice(0, 400));
  if (!body.includes('"z2ui5/Component.js"') || !body.includes('"z2ui5/embed/Container.js"')) {
    fail("the page does not carry the UI5 component - the frontend is not embedded");
  }
  ok("serve() answers GET / with the framework's page, the UI5 component embedded (" + body.length + " bytes)");

  await import("./output/zcl_host_app.clas.mjs");
  if (!globalThis.abap?.Classes?.ZCL_HOST_APP) fail("ZCL_HOST_APP did not register in the runtime");
  ok("a class transpiled by the host against downport/ registers in the running runtime");
} finally {
  server.close();
}
`);
  run(process.execPath, ["check.mjs"]);
  console.log("pack-npm --check: the tarball installs and runs");
} finally {
  fs.rmSync(scratch, { recursive: true, force: true });
}
