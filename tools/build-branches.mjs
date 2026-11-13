#!/usr/bin/env node
// build-branches.mjs
// Builds the generated output branches of abap2UI5/frontend from this
// repository (app/ + frontend/ + tools/):
//
//   cloud_new    frontend/embed (the embed app) + frontend/abap/cloud
//   standard_new BSP Z2UI5 of frontend/embed (app2bsp) + ICF handler
//
// The two _new branches carry no copy of the abap2UI5 frontend: the app in
// frontend/embed is one view with one z2ui5.embed.Container
// (@abap2ui5/embed-control), which loads the frontend from the backend it
// runs against (?z2ui5-bundle). Same names, same deployment identity as
// cloud and standard - they replace those installations - and the same
// split: standard_new the BSP itself, cloud_new the project for a Fiori
// deployment.
//
// cloud, cloud_v2, standard and standard_v2 - and the renamed variants
// standard_<NAME> and standard_v2_<NAME> - are NOT built from this tree any
// more (2026-11-13). They shipped bundle/webapp as a UI5 app of its own, and
// it no longer is one: it is the source of the bundle the backend serves
// (?z2ui5-bundle), without a page, a launchpad inbound or a start of its
// own. They are to be built from app_npm, the minimal app around the embed
// control; until then tools/app2bsp, tools/app2app_v2 and tools/bsp_rename
// are kept as they were for that build to pick up.
//
// Usage:  node tools/build-branches.mjs [branch ...]
// Without arguments the two fixed branches are built; with arguments only
// the named ones (so a frontend_deploy run builds exactly its branch).
//
// Everything is built into the gitignored tools/out/<branch>/ - no tree is
// committed in this repository. The published copies live in
// abap2UI5/frontend (result/<branch> on its main, fanned out into the
// branches): frontend_check rebuilds the trees from the sources on every
// pull request that touches them, and frontend_deploy rebuilds them once
// more at deploy time and ships that build. So the reviewed sources and the
// delivered bytes are tied together by the same build running in both
// places, not by a committed copy of its output.
//
// The VERSION stamp does NOT belong in the built tree: it names the core
// commit the tree was built from, which a pull-request build does not have.
// tools/branch-stamp.mjs writes it at deploy time.
//
// Everything an output branch needs lives under frontend/:
//   frontend/abap/        ICF/BSP ABAP artefacts (cloud + standard), together
//                         with the abaplint config, which is turned to /src/
//                         in the branch
//   frontend/common/      files every branch inherits (README, LICENSE, ...)
//   frontend/embed/       the embed app of the _new branches
// The scripts themselves live in tools/.

import { cpSync, rmSync, mkdirSync, readFileSync, writeFileSync, readdirSync, existsSync } from "node:fs";
import { join, dirname, relative, sep } from "node:path";
import { fileURLToPath } from "node:url";
// The banner without the provenance line; branch-stamp.mjs stamps the commit
// in at deploy time, because it does not exist yet here.
import { banner } from "./branch-stamp.mjs";
// The BSP itself is written by @abap2ui5/bsp (tools/bsp) - the same package
// an app of any other project takes to become a BSP.
import { app2bsp } from "./bsp/index.mjs";

const here = dirname(fileURLToPath(import.meta.url));
const core = join(here, "..");
// The data the build consumes - ABAP artefacts and the files every branch
// inherits - lives outside this folder; tools/ holds only what runs.
const data = join(core, "frontend");

// Every branch - published or renamed variant - lands in the gitignored
// tools/out/, so the deploy and the pull-request gate always find a build in
// the same place and nothing generated is ever committed here.
const scratch = join(here, "out");
const outDir = (branch) => join(scratch, branch);

// Files every output branch inherits (no tooling, no CI); ones that are not
// (or no longer) there are skipped. README.md is deliberately missing here: it
// is written in initBranch with the banner prepended, not copied.
const COMMON = [".gitignore", "CODE_OF_CONDUCT.md", "LICENSE", "SECURITY.md"];

// abapGit descriptors as on the previous branches
const ABAPGIT_CLOUD = `\uFEFF<?xml version="1.0" encoding="utf-8"?>
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
const ABAPGIT_STANDARD = `\uFEFF<?xml version="1.0" encoding="utf-8"?>
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

function initBranch(branch, abapgitXml, readme = "README.md") {
  const dir = outDir(branch);
  rmSync(dir, { recursive: true, force: true });
  mkdirSync(dir, { recursive: true });
  for (const f of COMMON) if (existsSync(join(data, "common", f))) cpSync(join(data, "common", f), join(dir, f));
  writeFileSync(join(dir, "README.md"), banner(branch) + "\n" + readFileSync(join(data, "common", readme), "utf8"));
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
//
// Normalised to forward slashes first: path.relative answers backslashes on
// Windows (a supported CLI platform, see pack-backend.mjs), and against those
// the pattern never matched - `app\node_modules` was copied into every cloud
// tree, hundreds of MB and the .git directories of any git dependency with it.
const posix = (p) => p.split(sep).join("/");
const skipBuildArtifacts = (src) =>
  !/(^|\/)(node_modules|dist|\.git)(\/|$)/.test(posix(relative(core, src)));

const skipLintConfig = (src) => !src.endsWith("abaplint.jsonc");

/* Where the backend lives is decided by the kind of deployment - and the two
 * stacks publish the same service under different paths:
 *
 *   on premise   /sap/bc/z2ui5          SICF node (the standard* branches)
 *   ABAP Cloud   /sap/bc/http/sap/z2ui5 HTTP service Z2UI5
 *                                       (frontend/abap/cloud/01/z2ui5.http.xml)
 *
 * bundle/webapp/manifest.json carries the on-premise path, because that is where
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

function patchCloudBackendUri(manifestJson, source) {
  const m = JSON.parse(manifestJson);
  const ds = m["sap.app"]?.dataSources?.http;
  if (ds?.uri !== ONPREM_URI) {
    throw new Error(
      `${source}: sap.app.dataSources.http.uri is ${JSON.stringify(ds?.uri)}, `
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
/* The _new branches: frontend/embed, the app around @abap2ui5/embed-control
 * (formerly the repository abap2UI5/frontend-new). Its BSP holds the app and
 * the control, nothing of the abap2UI5 frontend - the control loads that
 * from the backend (?z2ui5-bundle), so the branches do not follow every
 * release of it. Everything else is the old branches': the README's own
 * (common/README_new.md), the ABAP artefacts of frontend/abap, every name. */
const embed = join(data, "embed");
const EMBED_CONTROL = "@abap2ui5/embed-control";
// where the control's package serves it (its ui5.yaml) and the app's
// manifest registers it: a BSP answers every <app>/resources/ path from the
// system's UI5, so the control cannot sit there
const THIRDPARTY = "thirdparty/z2ui5/embed/";

function mustContain(file, text) {
  if (!readFileSync(file, "utf8").includes(text)) throw new Error(`${relative(core, file)}: '${text}' not found`);
}

// The control the BSP of standard_new carries comes from this repository's
// node_modules; cloud_new ships frontend/embed/package-lock.json, and a
// Fiori build of it installs the version that pins. They have to be the
// same release, or the two branches would deliver two different controls.
function embedControlSources() {
  const installed = join(core, "node_modules", EMBED_CONTROL);
  if (!existsSync(join(installed, "package.json"))) throw new Error(`${EMBED_CONTROL} is not installed - run npm ci first`);
  const { version } = JSON.parse(readFileSync(join(installed, "package.json"), "utf8"));
  const lock = JSON.parse(readFileSync(join(embed, "package-lock.json"), "utf8"));
  const pinned = lock.packages?.[`node_modules/${EMBED_CONTROL}`]?.version;
  if (version !== pinned) {
    throw new Error(`${EMBED_CONTROL}: ${version} installed, frontend/embed/package-lock.json pins ${pinned} - `
      + "bump both together (the root package.json and frontend/embed)");
  }
  mustContain(join(installed, "ui5.yaml"), `/${THIRDPARTY}: ./src/`);
  mustContain(join(embed, "webapp/manifest.json"), `"z2ui5.embed": "./${THIRDPARTY}"`);
  return join(installed, "src");
}

// What frontend/embed is developed and checked with here, not what a
// developer deploying the cloud_new project needs (see DEV_ONLY above) - and
// .env, git-ignored, which holds a developer's logon to a system
const EMBED_DEV_ONLY = new Set(["test", "AGENTS.md", "CLAUDE.md", ".env"]);
const skipEmbedDevFiles = (src) => !EMBED_DEV_ONLY.has(posix(relative(embed, src)));

// The BSP Z2UI5 of the embed app: its webapp with the control under
// thirdparty/, as `ui5 build` lays it out - nothing minified, no preload
// bundle, nothing patched. Every name as on standard.
function buildStandardNew(branch = "standard_new") {
  const dir = initBranch(branch, ABAPGIT_STANDARD, "README_new.md");
  const work = join(scratch, "_work_standard_new");
  rmSync(work, { recursive: true, force: true });
  cpSync(join(embed, "webapp"), work, { recursive: true });
  cpSync(embedControlSources(), join(work, THIRDPARTY), { recursive: true });
  cpSync(join(data, "abap/standard"), join(dir, "src"), { recursive: true });
  app2bsp({
    webapp: work,
    target: join(dir, "src/02"),
    name: "Z2UI5",
    text: "abap2UI5 frontend (generated)",
    icfText: "abap2UI5 - Frontend",
    packageText: "abap2UI5",
  });
  rmSync(work, { recursive: true, force: true });
}

// The embed app as a Fiori project in app/, next to the ABAP artefacts of
// cloud - deployed from there, as cloud's app/ is.
function buildCloudNew(branch = "cloud_new") {
  const dir = initBranch(branch, ABAPGIT_CLOUD, "README_new.md");
  embedControlSources();
  cpSync(embed, join(dir, "app"), {
    recursive: true,
    filter: (src) => skipBuildArtifacts(src) && skipEmbedDevFiles(src),
  });
  cpSync(join(data, "abap/cloud"), join(dir, "src"), { recursive: true, filter: skipLintConfig });
  // the endpoint is where cloud has it (sap.app/dataSources/http), and
  // turned to the HTTP service path by the same patch
  const manifest = join(dir, "app/webapp/manifest.json");
  writeFileSync(manifest, patchCloudBackendUri(readFileSync(manifest, "utf8"), "frontend/embed/webapp/manifest.json"));
}

const BUILDERS = {
  cloud_new: () => buildCloudNew(),
  standard_new: () => buildStandardNew(),
};

// standard_<NAME> / standard_v2_<NAME>: build the base, then rename the whole
// deployment identity (BSP, SICF node, handler class, file names) in the
// generated src tree to <NAME>. Name validation (max. 15 characters, Z/Y
// namespace warning, /NS/ names) is done by rename-bsp.mjs; it passes the
// #ns#name notation through unchanged. <NAME>__<BACKEND> additionally
// points the handler at a backend renamed to <BACKEND> (--backend, validated
// there as well). The abaplint config of the tree is pointed at the branch
// that carries the renamed backend, so a lint of the tree finds the class
// the handler calls (frontend_deploy lints the standard trees).
const RETIRED = /^(cloud|cloud_v2|standard|standard_v2)$|^standard(_v2)?_./;

const requested = process.argv.slice(2);
const branches = requested.length ? requested : Object.keys(BUILDERS);
const builds = branches.map((b) => {
  // The same pattern as the guard in frontend_deploy.yaml - here once more,
  // because initBranch starts with rmSync on outDir(b) and a name like
  // "standard_x/../../.." would otherwise delete outside of tools/out,
  // before rename-bsp ever validates it.
  if (!/^[A-Za-z0-9_#]+$/.test(b)) {
    console.error(`Invalid branch name '${b}' - only [A-Za-z0-9_#] is allowed`);
    process.exit(1);
  }
  const build = BUILDERS[b];
  if (!build) {
    console.error(
      RETIRED.test(b)
        ? `Branch '${b}' is not built from this tree any more - it shipped bundle/webapp as an app of its own (see the header)`
        : `Unknown branch '${b}' - allowed: ${Object.keys(BUILDERS).join(", ")}`,
    );
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
