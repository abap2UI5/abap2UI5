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
 *                     classes, the generated unit-test runner index.mjs),
 *                     WITHOUT the browser-test fixtures (below)
 *   setup/setup.mjs   node/setup/setup.mjs - the database hook output/init.mjs
 *                     imports by the relative path abap_transpile.json fixes
 *   srv/host.mjs      node/srv/host.mjs - the entry point (`exports["."]`).
 *                     Same neighbours as in the checkout, so its relative
 *                     imports need no rewriting - see its header
 *   srv/accelerate.mjs  node/srv/accelerate.mjs - the runtime fast paths
 *                     host.mjs installs, also `exports["./accelerate"]` for a
 *                     host that boots through output/init.mjs itself
 *   srv/compress.mjs  node/srv/compress.mjs - the gzip middleware createApp()
 *                     puts in front, also `exports["./compress"]`
 *   downport/         node/downport - the 7.02-downported ABAP the transpile
 *                     read, so a host can transpile ITS OWN app classes with
 *                     the framework as a library (README, "Your own apps"),
 *                     again without the fixtures
 *
 * The browser-test fixtures stay in the checkout. node/srv holds the ICF
 * handler every host needs (zcl_sicf) next to the apps the Playwright
 * projects drive (zcl_tst_*), and prepare-transpile folds ALL of node/srv
 * into node/downport - so the fixtures are in node/output, and output/init.mjs
 * imports them and seeds their TADIR rows at boot. Packed as they are, every
 * host - a CAP project in production included - would start them on
 * ?app_start=ZCL_TST_HOST (1.145.0 shipped ten). They are left out HERE
 * rather than transpiled apart, because `npm run express` and the browser
 * projects need them in the very tree this script packs: their files are not
 * copied, and init.mjs / _init.mjs lose the import and the TADIR row of each
 * (stripFixtures). What counts as a fixture is DERIVED from node/srv - every
 * ABAP object there except SHIPPED_SRV - so a new fixture is left out
 * whatever it is called, and the pack fails when any fixture name is still
 * anywhere in the tarball, file name or content.
 *
 * No webapp/: the UI5 component is embedded in the page the framework serves
 * on GET (src/01/03, transpiled into output/ like everything else), so a Node
 * host needs no frontend files.
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
 *     embedded, and a POST roundtrip; createApp() mounted under /sap/bc/z2ui5
 *     the same; no fixture may start; and a class transpiled by the scratch
 *     project against downport/ (and open-abap-core at the recorded commit)
 *     has to register in the running runtime. All of it under express 5 AND
 *     express 4 - the peer range promises both. The listing says what the
 *     tarball holds; only an install says whether it works.
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

function gitHead(dir = ROOT) {
  try {
    return execFileSync("git", ["rev-parse", "HEAD"], { cwd: dir, stdio: ["ignore", "pipe", "ignore"] })
      .toString().trim() || null;
  } catch {
    return null;
  }
}

/* The open-abap-core checkout the transpile read: node/deps/open-abap-core,
 * which fetch-deps.mjs materializes at its pin (`npm run downport` runs it).
 * Read from the checkout, not from the pin list, because that folder is what
 * the transpiler actually used. Without it (a local build that fell back to
 * the transpiler's floating clone - CI fails before that) nothing is known,
 * and null says so rather than naming a pin nobody built against. */
const DEPS_CORE = path.join(ROOT, "node/deps/open-abap-core");
const openAbapCore = fs.existsSync(path.join(DEPS_CORE, ".git")) ? gitHead(DEPS_CORE) : null;
if (!openAbapCore) {
  console.warn("pack-npm: WARN node/deps/open-abap-core is not a checkout - abap2ui5.openAbapCore is recorded as null");
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
 * transpiler that wrote output/, so the host's output matches it, and the
 * open-abap-core commit output/ was built against, so the host type-checks
 * against the same standard library rather than whatever its HEAD is that
 * day (README, "Your own apps"). Recorded here rather than in prose that
 * goes stale. */
template.abap2ui5 = {
  commit: gitHead(),
  builtAt: new Date().toISOString(),
  node: process.version,
  transpiler: locked("@abaplint/transpiler-cli"),
  openAbapCore,
};

// --- the browser-test fixtures ---------------------------------------------
/* Every ABAP object in node/srv that is not listed here is a fixture of the
 * repository's own browser tests and stays out of the package (header). */
const SHIPPED_SRV = new Set(["zcl_sicf"]);
const FIXTURES = [...new Set(
  fs.readdirSync(path.join(ROOT, "node/srv"))
    .filter((f) => f.endsWith(".abap"))
    .map((f) => f.split(".")[0].toLowerCase()),
)].filter((name) => !SHIPPED_SRV.has(name)).sort();

/* A file that belongs to a fixture: `<name>.<anything>` - the transpiled
 * class, its source map, the downported source and its .clas.xml. */
const isFixtureFile = (file) => FIXTURES.includes(path.basename(file).split(".")[0].toLowerCase());

/* init.mjs (and _init.mjs, the same boot for the open unit runner) name
 * every transpiled object twice: an `insert.push(`INSERT INTO "tadir" ...`)`
 * that registers it and an import that loads it - `await import("./<name>
 * .clas.mjs")` in init.mjs, a static `import "./<name>.clas.mjs"` in
 * _init.mjs. Both lines go for every fixture. Transpiler output, so the shape is
 * not ours: each fixture must lose exactly one import here, and the scan
 * after packing fails on any name left behind - a changed shape stops the
 * pack instead of shipping half-stripped boot code. */
function stripFixtures(file) {
  const before = fs.readFileSync(file, "utf8");
  const upper = new Set(FIXTURES.map((n) => n.toUpperCase()));
  let text = before.replace(/^[ \t]*insert\.push\(`[^`]*`\);[ \t]*\r?\n/gm, (stmt) => {
    const m = /VALUES\s*\(\s*'R3TR'\s*,\s*'[A-Z0-9]{4}'\s*,\s*'([^']+)'/.exec(stmt);
    return m && upper.has(m[1].toUpperCase()) ? "" : stmt;
  });
  const missed = [];
  for (const name of FIXTURES) {
    const line = new RegExp(
      `^(?:await import\\("\\./${name}\\.[a-z]+\\.mjs"\\)|import "\\./${name}\\.[a-z]+\\.mjs");[ \t]*(?:\\r?\\n|$)`, "gm");
    const hits = text.match(line)?.length ?? 0;
    if (hits !== 1) missed.push(`${name} (${hits} imports)`);
    text = text.replace(line, "");
  }
  if (missed.length) {
    // thrown, not process.exit(): the finally below still removes the stage
    throw new Error(`pack-npm: ${path.basename(file)} does not import every fixture exactly once`
      + ` (was node/output transpiled from this node/srv? did the transpiler's shape change?): ${missed.join(", ")}`);
  }
  fs.writeFileSync(file, text);
}

// --- stage and pack ---------------------------------------------------------
const COPIES = [
  ["node/output", "output", isFixtureFile],
  ["node/setup/setup.mjs", "setup/setup.mjs"],
  ["node/srv/host.mjs", "srv/host.mjs"],
  ["node/srv/accelerate.mjs", "srv/accelerate.mjs"],
  ["node/srv/compress.mjs", "srv/compress.mjs"],
  ["node/downport", "downport", isFixtureFile],
  ["node/setup/npm.README.md", "README.md"],
  ["LICENSE", "LICENSE"],
];
/* The boot files that name the fixtures, relative to the stage. _init.mjs
 * only exists when the transpile wrote the open unit runner. */
const BOOT_FILES = ["output/init.mjs", "output/_init.mjs"];

fs.mkdirSync(outDir, { recursive: true });
const stage = fs.mkdtempSync(path.join(os.tmpdir(), "abap2ui5-node-"));
let tarball;
try {
  fs.writeFileSync(path.join(stage, "package.json"), `${JSON.stringify(template, null, 2)}\n`);
  for (const [from, to, skip] of COPIES) {
    const dest = path.join(stage, to);
    fs.mkdirSync(path.dirname(dest), { recursive: true });
    fs.cpSync(path.join(ROOT, from), dest, { recursive: true, filter: (src) => !(skip && skip(src)) });
  }
  for (const boot of BOOT_FILES) {
    if (fs.existsSync(path.join(stage, boot))) stripFixtures(path.join(stage, boot));
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
    "srv/host.mjs", "srv/accelerate.mjs", "srv/compress.mjs", "setup/setup.mjs", "output/init.mjs", "output/index.mjs",
    "output/cl_express_icf_shim.clas.mjs", "output/zcl_sicf.clas.mjs",
    "downport/02/z2ui5_if_app.intf.abap",
  ];
  const problems = MUST.filter((f) => !files.has(f)).map((f) => `${f} is not in the tarball`);
  const stray = [...files].filter((f) => f.split("/").includes(".git") || f.startsWith("node_modules/") || f.startsWith("webapp/"));
  if (stray.length) problems.push(`${stray.length} stray entr${stray.length === 1 ? "y" : "ies"} (first: ${stray[0]})`);
  /* No fixture by file name, and none by content: every packed file of the
   * code trees is read back from the stage (what npm packed is what is
   * there) and searched for each fixture name and for the ZCL_TST_ prefix,
   * case-insensitively. README.md is left out of the content scan - it
   * names the prefix to say the fixtures are not there. */
  const fixtureRe = new RegExp(`\\b(?:zcl_tst_\\w*${FIXTURES.map((n) => `|${n}`).join("")})\\b`, "i");
  const leaked = [];
  for (const f of files) {
    const hit = fixtureRe.exec(f)
      ?? (f === "README.md" ? null : fixtureRe.exec(fs.readFileSync(path.join(stage, f), "latin1")));
    if (hit) leaked.push(`${f} (${hit[0]})`);
  }
  if (leaked.length) {
    problems.push(`${leaked.length} file(s) carry a browser-test fixture, first: ${leaked.slice(0, 3).join(", ")}`);
  }
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
    + ` transpiler ${template.abap2ui5.transpiler ?? "unknown"}, runtime ${template.dependencies["@abaplint/runtime"]},`
    + ` open-abap-core ${openAbapCore ?? "unknown"}`,
  );
  console.log(`  left out ${FIXTURES.length} browser-test fixture(s) of node/srv: ${FIXTURES.join(", ")}`);
} finally {
  fs.rmSync(stage, { recursive: true, force: true });
}

if (!check) process.exit(0);

// --- prove it ---------------------------------------------------------------
/* A scratch project with the tarball installed, driven the way a host drives
 * it. The claims the README makes, each checked from the INSTALLED
 * package - the working tree has every file whether or not `files` lists it,
 * so nothing short of an install can catch a missing entry:
 *   1. serve() answers GET / with the framework's page and the UI5 component
 *      embedded in it (the handler, the shim, ZCL_SICF and the database hook
 *      all came along and boot, and the frontend needs no files of its own),
 *      gzipped under the tag "<tag>-gzip" that the framework revalidates to
 *      a 304, and a POST starts an app and chains its draft
 *   2. createApp() mounted under /sap/bc/z2ui5 of the host's own express app
 *      does the same there - the README's "In an express app of your own"
 *   3. no browser-test fixture is registered or starts
 *   4. a class transpiled BY THE HOST against downport/ and open-abap-core at
 *      the recorded commit registers in the running runtime and starts - the
 *      "Your own apps" recipe, executed literally
 *   5. serve() rejects on a port that is taken instead of resolving
 *   6. the runtime the package pins is the one accelerate() was validated
 *      for: serve() installed the fast paths, and the "./accelerate" subpath
 *      a host that boots itself imports finds them installed
 * All of it once per range of the express peer: a host brings its own
 * express, and the range is a promise about each major it names.
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
  run(NPM, ["install", "--no-audit", "--no-fund", tarball, `@abaplint/transpiler-cli@${locked("@abaplint/transpiler-cli")}`]);

  // 4. the host's own app, transpiled against the package - the README recipe
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
  /* open-abap-core at the commit the package records, the README's
   * three-line checkout - without one the transpiler clones the url's HEAD */
  if (openAbapCore) {
    const core = path.join(scratch, "deps/open-abap-core");
    fs.mkdirSync(core, { recursive: true });
    run("git", ["init", "--quiet"], { cwd: core });
    run("git", ["fetch", "--quiet", "--depth", "1", "https://github.com/open-abap/open-abap-core", openAbapCore], { cwd: core });
    run("git", ["checkout", "--quiet", "FETCH_HEAD"], { cwd: core });
  }
  run(WIN ? "npx.cmd" : "npx", ["abap_transpile", "abap_transpile.json"]);

  fs.writeFileSync(path.join(scratch, "check.mjs"), `
import { createRequire } from "node:module";
import express from "express";
import { serve, createApp, initialize } from "@abap2ui5/node-runtime";
const fail = (what) => { console.error("FAIL: " + what); process.exit(1); };
const ok = (what) => console.log("ok  " + what);
const expressVersion = createRequire(import.meta.url)("express/package.json").version;
console.log("express " + expressVersion);

const post = async (base, pathname, front) => {
  const res = await fetch(base + pathname, {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: JSON.stringify({ value: { S_FRONT: { ORIGIN: base, PATHNAME: pathname, SEARCH: "", ...front } } }),
  });
  const text = await res.text();
  let json = null;
  try { json = JSON.parse(text); } catch { /* not JSON - the caller decides */ }
  return { status: res.status, json, text };
};

/* GET the page, then a POST app start and a follow-up on its draft id */
const roundtrip = async (base, pathname, what) => {
  const res = await fetch(base + pathname);
  const page = await res.text();
  if (res.status !== 200) fail(what + ": GET " + pathname + " answered " + res.status);
  if (!/z2ui5/.test(page)) fail(what + ": GET " + pathname + " is not the abap2UI5 page:\\n" + page.slice(0, 400));
  if (!page.includes('"z2ui5/Component.js"')) {
    fail(what + ": the page does not carry the UI5 component - the frontend is not embedded");
  }
  // fetch asked for gzip (and decoded it): compress() answered, and the
  // framework reads the tag it sent back
  const etag = res.headers.get("etag") ?? "";
  if (res.headers.get("content-encoding") !== "gzip" || !etag.endsWith('-gzip"')) {
    fail(what + ": GET " + pathname + " is not gzipped under a -gzip tag (" + res.headers.get("content-encoding") + ", " + etag + ")");
  }
  const again = await fetch(base + pathname, { headers: { "if-none-match": etag } });
  if (again.status !== 304) fail(what + ": If-None-Match " + etag + " answered " + again.status + ", not 304");
  const first = await post(base, pathname, { SEARCH: "?app_start=z2ui5_cl_ui5_app_hi_world" });
  if (first.status !== 200 || first.json?.S_FRONT?.APP !== "Z2UI5_CL_UI5_APP_HI_WORLD") {
    fail(what + ": POST app_start answered " + first.status + ": " + first.text.slice(0, 400));
  }
  const second = await post(base, pathname, { ID: first.json.S_FRONT.ID });
  if (second.json?.S_FRONT?.APP !== "Z2UI5_CL_UI5_APP_HI_WORLD" || second.json.S_FRONT.ID === first.json.S_FRONT.ID) {
    fail(what + ": the follow-up POST did not restore the draft: " + second.text.slice(0, 400));
  }
  ok(what + ": GET " + pathname + " is the page with the component embedded (" + page.length + " bytes, gzipped, revalidates to a 304), POST starts an app and chains its draft");
};

const server = await serve({ port: 0, host: "127.0.0.1" });
const port = server.address().port;
const base = "http://127.0.0.1:" + port;
try {
  await roundtrip(base, "/", "serve()");

  const classes = Object.keys(globalThis.abap?.Classes ?? {});
  if (!classes.includes("ZCL_SICF")) fail("ZCL_SICF is not registered - the handler every request goes to");
  const fixtures = classes.filter((c) => /^ZCL_TST_/i.test(c));
  if (fixtures.length) fail("browser-test fixtures are registered: " + fixtures.join(", "));
  const fixture = await post(base, "/", { SEARCH: "?app_start=ZCL_TST_HOST" });
  if (fixture.json?.S_FRONT?.APP === "ZCL_TST_HOST") fail("?app_start=ZCL_TST_HOST starts the browser-test fixture");
  ok("no browser-test fixture is registered, and ?app_start=ZCL_TST_HOST starts nothing");

  await initialize();
  await import("./output/zcl_host_app.clas.mjs");
  if (!globalThis.abap?.Classes?.ZCL_HOST_APP) fail("ZCL_HOST_APP did not register in the runtime");
  const own = await post(base, "/", { SEARCH: "?app_start=zcl_host_app" });
  if (own.json?.S_FRONT?.APP !== "ZCL_HOST_APP" || !own.text.includes("Hello from the host")) {
    fail("the host's own app does not start: " + own.text.slice(0, 400));
  }
  ok("a class transpiled by the host against downport/ registers in the running runtime and starts");

  const { accelerate: viaSubpath, RUNTIME_VERSION } = await import("@abap2ui5/node-runtime/accelerate");
  const loop = globalThis.abap.statements.loop;
  if (!viaSubpath()) fail("accelerate() installs nothing on the runtime the package pins - it is validated for " + RUNTIME_VERSION);
  if (globalThis.abap.statements.loop !== loop) fail("serve() did not install the fast paths - accelerate() installed them afterwards");
  ok("serve() runs on the fast paths of accelerate() (@abaplint/runtime " + RUNTIME_VERSION + "), and the ./accelerate subpath finds them installed");

  const taken = await serve({ port, host: "127.0.0.1" }).then((s) => { s.close(); return null; }, (e) => e);
  if (!taken) fail("serve() on a port in use resolved instead of rejecting");
  ok("serve() on a port in use rejects (" + taken.code + ")");
} finally {
  server.close();
}

const host = express();
host.get("/health", (req, res) => { res.send("up"); });
host.use("/sap/bc/z2ui5", await createApp());
const mounted = await new Promise((resolve, reject) => {
  const s = host.listen(0, "127.0.0.1", () => resolve(s)).on("error", reject);
});
try {
  const mountedBase = "http://127.0.0.1:" + mounted.address().port;
  await roundtrip(mountedBase, "/sap/bc/z2ui5/", "createApp() under /sap/bc/z2ui5");
  if ((await (await fetch(mountedBase + "/health")).text()) !== "up") fail("the host's own route next to the mount does not answer");
  ok("the host's own routes next to the mount still answer");
} finally {
  mounted.close();
}
`);
  const ranges = String(template.peerDependencies?.express ?? "").split("||").map((r) => r.trim()).filter(Boolean);
  if (!ranges.length) {
    console.error("pack-npm --check: the manifest names no express peer range to check against");
    process.exit(1);
  }
  for (const range of ranges) {
    console.log(`\npack-npm --check: express ${range}`);
    run(NPM, ["install", "--no-audit", "--no-fund", `express@${range}`]);
    run(process.execPath, ["check.mjs"]);
  }
  console.log(`pack-npm --check: the tarball installs and runs (express ${ranges.join(", ")})`);
} finally {
  fs.rmSync(scratch, { recursive: true, force: true });
}
