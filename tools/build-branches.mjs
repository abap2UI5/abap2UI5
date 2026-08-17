#!/usr/bin/env node
// build-branches.mjs
// Builds the generated output branches of abap2UI5/frontend from this
// repository (app/ + frontend/ + tools/):
//
//   cloud        app/ (webapp) + frontend/abap/cloud (ABAP artefacts), classic bootstrap
//   cloud_v2     like cloud, webapp patched to legacy-free (UI5 2.0)
//   standard     BSP Z2UI5 (app2bsp) + ICF handler, classic bootstrap
//   standard_v2  BSP Z2UI5 legacy-free (build-legacy-free.mjs)
//
// The two BSP branches additionally get the minified UI5 component preload
// bundle (app2bsp/preload.js), which folds the ~50 single requests of an app
// start into one and boots the app from it. The cloud branches ship the webapp
// as a source project instead - there the developer runs the build.
//
// Renamed BSP variants can be built in addition (for a parallel installation
// in the same SAP system, see tools/bsp_rename):
//
//   standard_<NAME>     like standard,    BSP/SICF/handler renamed to <NAME>
//   standard_v2_<NAME>  like standard_v2, BSP/SICF/handler renamed to <NAME>
//
// e.g. standard_zmyui5 -> BSP ZMYUI5. <NAME> may also be a namespace in
// abapGit file name notation ("/" -> "#"): standard_#abapgit#
// -> BSP /ABAPGIT/UI5, standard_#abapgit#x -> BSP /ABAPGIT/X (details in
// tools/bsp_rename). The frontend_deploy workflow builds and pushes
// such branches on demand.
//
// Usage:  node tools/build-branches.mjs [branch ...]
// Without arguments the four fixed branches are built; with arguments only
// the named ones (so a frontend_deploy run builds exactly its branch).
//
// Where the build goes is decided by the branch name, not by a switch:
//
//   the four fixed branches -> build/<branch>/      committed in the repository
//   everything else         -> tools/out/<branch>/  gitignored, scratch
//
// build/ is what frontend_deploy pushes into the delivery branches: a push
// copies a tree, it no longer builds it. That is why the tree is checked in
// here and verified against the sources by frontend_check - exactly like
// src/01/03 against app/webapp. What a branch delivers is therefore in the
// pull request before it is merged.
//
// The VERSION stamp does NOT belong in the built tree: it names the core
// commit the tree was built from, and that one is not even known yet when
// build/ is committed. tools/branch-stamp.mjs writes it at deploy time.
//
// The webapp comes from app/webapp of THIS repository - the single source.
// Everything else an output branch needs lives under frontend/:
//   frontend/abap/        ICF/BSP ABAP artefacts (cloud + standard), together
//                         with the abaplint config, which is turned to /src/
//                         in the branch
//   frontend/common/      files every branch inherits (README, LICENSE, ...)
// The scripts themselves live in tools/.
//
// The cloud branches deliver the complete Fiori project from app/ - the same
// project files this repository is developed with, not a second copy.

import { execFileSync } from "node:child_process";
import { cpSync, rmSync, mkdirSync, readFileSync, writeFileSync, readdirSync, existsSync } from "node:fs";
import { join, dirname, relative } from "node:path";
import { fileURLToPath } from "node:url";
import { patchIndexHtml, patchManifest } from "./app2app_v2/patch-v2.mjs";
// The banner without the provenance line; branch-stamp.mjs stamps the commit
// in at deploy time, because it does not exist yet here.
import { banner } from "./branch-stamp.mjs";

const here = dirname(fileURLToPath(import.meta.url));
const core = join(here, "..");
const webapp = join(core, "app/webapp");
// The data the build consumes - ABAP artefacts and the files every branch
// inherits - lives outside this folder; tools/ holds only what runs.
const data = join(core, "frontend");

// The four published branches land in the checked-in build/, every other name
// (renamed variant, trial run) in the gitignored tools/out/. No switch: this
// way an ad-hoc build cannot touch the committed tree, and the deploy always
// finds the four in the same place.
const generated = join(core, "build");
const scratch = join(here, "out");
const PUBLISHED = ["cloud", "cloud_v2", "standard", "standard_v2"];
const outDir = (branch) => join(PUBLISHED.includes(branch) ? generated : scratch, branch);

// Files every output branch inherits (no tooling, no CI); ones that are not
// (or no longer) there are skipped. README.md is deliberately missing here: it
// is written in initBranch with the banner prepended, not copied.
const COMMON = [".gitignore", "CODE_OF_CONDUCT.md", "LICENSE", "SECURITY.md"];

// abapGit descriptors as on the previous branches
const ABAPGIT_CLOUD = `﻿<?xml version="1.0" encoding="utf-8"?>
<asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0">
 <asx:values>
  <DATA>
   <MASTER_LANGUAGE>E</MASTER_LANGUAGE>
   <STARTING_FOLDER>/src/</STARTING_FOLDER>
   <FOLDER_LOGIC>PREFIX</FOLDER_LOGIC>
  </DATA>
 </asx:values>
</asx:abap>
`;
const ABAPGIT_STANDARD = `﻿<?xml version="1.0" encoding="utf-8"?>
<asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0">
 <asx:values>
  <DATA>
   <NAME>abap2UI5-frontend</NAME>
   <MASTER_LANGUAGE>E</MASTER_LANGUAGE>
   <STARTING_FOLDER>/src/</STARTING_FOLDER>
   <FOLDER_LOGIC>PREFIX</FOLDER_LOGIC>
  </DATA>
 </asx:values>
</asx:abap>
`;

function initBranch(branch, abapgitXml) {
  const dir = outDir(branch);
  rmSync(dir, { recursive: true, force: true });
  mkdirSync(dir, { recursive: true });
  for (const f of COMMON) if (existsSync(join(data, "common", f))) cpSync(join(data, "common", f), join(dir, f));
  writeFileSync(join(dir, "README.md"), banner(branch) + "\n" + readFileSync(join(data, "common/README.md"), "utf8"));
  writeFileSync(join(dir, ".abapgit.xml"), abapgitXml);
  // abaplint config from main, source path turned to the /src/ of the output
  // branches; without it the abaplint check on the output branches always
  // reports red
  // Same config that lints frontend/abap/cloud in place, with its glob turned
  // from the folder it sits in to the /src/ of an output branch. Guarded: a
  // silent miss would ship a config that lints nothing and reports green.
  const lint = readFileSync(join(data, "abap/cloud/abaplint.jsonc"), "utf8");
  const glob = '"files": "/**/*.*"';
  if (!lint.includes(glob)) throw new Error(`frontend/abap/cloud/abaplint.jsonc: ${glob} not found`);
  writeFileSync(join(dir, "abaplint.jsonc"), lint.replace(glob, '"files": "/src/**/*.*"'));
  return dir;
}

// Tested against the path RELATIVE to the repo: the absolute checkout path can
// itself carry a dist/ or .git segment (~/dist/abap2UI5), and then the test
// filters the root away and cpSync silently copies nothing.
const skipBuildArtifacts = (src) =>
  !/(^|\/)(node_modules|dist|\.git)(\/|$)/.test(relative(core, src));

// Quiet on success, never on failure: the discarded log is the only thing
// that says WHY a step failed (same pattern as runUi5Build in
// app2bsp/preload.js).
function runQuiet(args, cwd) {
  try {
    execFileSync("node", args, { cwd, stdio: ["ignore", "pipe", "pipe"] });
  } catch (error) {
    process.stderr.write(String(error.stdout ?? ""));
    process.stderr.write(String(error.stderr ?? ""));
    throw error;
  }
}

// The cloud branches ship the Fiori project from app/ - the same one this
// repository is developed with, so the two cannot drift apart. What they do
// NOT ship is the tooling that project is developed WITH: the linter and
// formatter configs run here, on a pull request, and a delivery branch is an
// installation source, not a development checkout. They are named rather than
// pattern-matched so a new project file has to be decided on, not silently
// delivered or silently dropped.
const DEV_ONLY = new Set([".editorconfig", ".prettierrc", "eslint.config.mjs", "ui5lint.config.mjs"]);
const skipDevProjectFiles = (src) => !DEV_ONLY.has(relative(join(core, "app"), src));

// abap/cloud carries the abaplint config that lints it in place. It belongs to
// this repository, not to the delivered package - the output branch gets its
// own copy at the root (see initBranch), with the glob turned to /src/.
const skipLintConfig = (src) => !src.endsWith("abaplint.jsonc");

/* Where the backend lives is decided by the kind of deployment - and the two
 * stacks publish the same service under different paths:
 *
 *   on premise   /sap/bc/z2ui5          SICF node (build/standard*)
 *   ABAP Cloud   /sap/bc/http/sap/z2ui5 HTTP service Z2UI5
 *                                       (frontend/abap/cloud/01/z2ui5.http.xml)
 *
 * app/webapp/manifest.json carries the on-premise path, because that is where
 * development happens and where the BSP variant is built from. The cloud
 * branches used to copy it along - and a Fiori deployment on Steampunk then
 * sends its POSTs to an ICF node that does not exist there: 403
 * ICFEUCONFORBIDDEN, with no hint what about (Issue #2602).
 *
 * Only the separately deployed webapp is affected. If the backend serves the
 * GET page itself, it sets `checkLocal` and App.controller takes
 * `window.location.href` - the manifest entry is then not read at all.
 *
 * The guard is the point: if the replacement no longer found its path, the
 * on-premise URL would silently be delivered again here, and the error would
 * come back as a 403 in a user's system instead of here in the build. */
const ONPREM_URI = "/sap/bc/z2ui5";
const CLOUD_URI = "/sap/bc/http/sap/z2ui5";

function patchCloudBackendUri(manifestJson) {
  const m = JSON.parse(manifestJson);
  const ds = m["sap.app"]?.dataSources?.http;
  if (ds?.uri !== ONPREM_URI) {
    throw new Error(
      `app/webapp/manifest.json: sap.app.dataSources.http.uri is ${JSON.stringify(ds?.uri)}, `
      + `expected ${JSON.stringify(ONPREM_URI)} - the cloud branches rewrite it to ${CLOUD_URI} `
      + "and must not ship a path they did not recognise",
    );
  }
  ds.uri = CLOUD_URI;
  return JSON.stringify(m, null, 2) + "\n";
}

// Webapp + ABAP cloud artefacts 1:1 from main; the backend URL is turned to
// the HTTP service path, and for cloud_v2 the webapp bootstrap is patched to
// legacy-free on top.
function buildCloudVariant(branch) {
  const dir = initBranch(branch, ABAPGIT_CLOUD);
  cpSync(join(core, "app"), join(dir, "app"), {
    recursive: true,
    filter: (src) => skipBuildArtifacts(src) && skipDevProjectFiles(src),
  });
  cpSync(join(data, "abap/cloud"), join(dir, "src"), { recursive: true, filter: skipLintConfig });
  const wa = join(dir, "app/webapp");
  const manifest = join(wa, "manifest.json");
  writeFileSync(manifest, patchCloudBackendUri(readFileSync(manifest, "utf8")));
  if (branch === "cloud_v2") {
    writeFileSync(join(wa, "index.html"), patchIndexHtml(readFileSync(join(wa, "index.html"), "utf8")));
    writeFileSync(manifest, patchManifest(readFileSync(manifest, "utf8")));
  }
}

// Classic BSP via app2bsp + ICF handler
function buildStandard(branch = "standard") {
  const dir = initBranch(branch, ABAPGIT_STANDARD);
  const work = join(scratch, "_work_standard");
  // Leftovers of an aborted run would otherwise be built in as well: cpSync
  // only merges on top, and a webapp file deleted in the meantime would stay
  // in the tree as a registered BSP page.
  rmSync(work, { recursive: true, force: true });
  cpSync(join(here, "app2bsp"), join(work, ".github/app2bsp"), { recursive: true });
  cpSync(webapp, join(work, "frontend/app/webapp"), { recursive: true, filter: skipBuildArtifacts });
  execFileSync("node", [".github/app2bsp/preload.js"], { cwd: work, stdio: "inherit" });
  runQuiet([".github/app2bsp/run.js"], work);
  cpSync(join(data, "abap/standard"), join(dir, "src"), { recursive: true });
  cpSync(join(work, "src/02"), join(dir, "src/02"), { recursive: true });
  rmSync(work, { recursive: true, force: true });
}

// Legacy-free BSP via build-legacy-free.mjs
function buildStandardV2(branch = "standard_v2") {
  const dir = initBranch(branch, ABAPGIT_STANDARD);
  const work = join(scratch, "_work_standard_v2");
  execFileSync("node", [join(here, "app2app_v2/build-legacy-free.mjs"), core, webapp, work],
    { stdio: "inherit" });
  cpSync(join(work, "src"), join(dir, "src"), { recursive: true });
  rmSync(work, { recursive: true, force: true });
}

const BUILDERS = {
  cloud: () => buildCloudVariant("cloud"),
  cloud_v2: () => buildCloudVariant("cloud_v2"),
  standard: () => buildStandard(),
  standard_v2: () => buildStandardV2(),
};

// standard_<NAME> / standard_v2_<NAME>: build the base, then rename the whole
// deployment identity (BSP, SICF node, handler class, file names) in the
// generated src tree to <NAME>. Name validation (max. 15 characters, Z/Y
// namespace warning, /NS/ names) is done by rename-bsp.mjs; it passes the
// #ns#name notation through unchanged.
function renamedBuilder(branch) {
  for (const base of ["standard_v2", "standard"]) {
    const prefix = `${base}_`;
    if (!branch.startsWith(prefix)) continue;
    const name = branch.slice(prefix.length);
    // An empty name ("standard_v2_") is an error - it must not fall through to
    // the shorter base and be built there with "v2_" as the name.
    if (!name) return null;
    const buildBase = base === "standard" ? buildStandard : buildStandardV2;
    return () => {
      buildBase(branch);
      execFileSync("node",
        [join(here, "bsp_rename/rename-bsp.mjs"), name, "--yes", "--dir", "src"],
        { cwd: outDir(branch), stdio: "inherit" });
    };
  }
  return null;
}

const requested = process.argv.slice(2);
const branches = requested.length ? requested : Object.keys(BUILDERS);
const builds = branches.map((b) => {
  // The same pattern as the guard in frontend_deploy.yaml - here once more,
  // because initBranch starts with rmSync on outDir(b) and a name like
  // "standard_x/../../.." would otherwise delete outside of build//tools/out,
  // before rename-bsp ever validates it.
  if (!/^[A-Za-z0-9_#]+$/.test(b)) {
    console.error(`Ungueltiger Branch-Name '${b}' - erlaubt sind nur [A-Za-z0-9_#]`);
    process.exit(1);
  }
  const build = BUILDERS[b] ?? renamedBuilder(b);
  if (!build) {
    console.error(`Unbekannter Branch '${b}' - erlaubt: ${Object.keys(BUILDERS).join(", ")}, standard_<name>, standard_v2_<name> (<name> auch als #ns#name)`);
    process.exit(1);
  }
  return build;
});
for (let i = 0; i < branches.length; i++) {
  builds[i]();
  const b = branches[i];
  const n = readdirSync(outDir(b), { recursive: true }).length;
  console.log(`OK: ${b} (${n} entries) -> ${relative(core, outDir(b))}`);
}
