#!/usr/bin/env node
// build-branches.mjs
// Baut aus dem main-Branch (einzige Quelle: app/webapp + abap/ + Tooling)
// die generierten Output-Branches:
//
//   cloud        app/ (Webapp) + abap/cloud (ABAP-Artefakte), klassischer Bootstrap
//   cloud_v2     wie cloud, Webapp auf legacy-free (UI5 2.0) gepatcht
//   standard     BSP Z2UI5 (app2bsp) + ICF-Handler, klassischer Bootstrap
//   standard_v2  BSP Z2UI5 legacy-free (build-legacy-free.mjs)
//
// The two BSP branches additionally get the minified UI5 component preload
// bundle (app2bsp/preload.js), which folds the ~50 single requests of an app
// start into one and boots the app from it. The cloud branches ship the webapp
// as a source project instead - there the developer runs the build.
//
// Zusaetzlich koennen umbenannte BSP-Varianten gebaut werden (fuer eine
// Parallelinstallation im selben SAP-System, siehe frontend/bsp_rename):
//
//   standard_<NAME>     wie standard,    BSP/SICF/Handler auf <NAME> umbenannt
//   standard_v2_<NAME>  wie standard_v2, BSP/SICF/Handler auf <NAME> umbenannt
//
// z.B. standard_zmyui5 -> BSP ZMYUI5. <NAME> darf auch ein Namespace in
// abapGit-Dateinamen-Schreibweise sein ("/" -> "#"): standard_#abapgit#
// -> BSP /ABAPGIT/UI5, standard_#abapgit#x -> BSP /ABAPGIT/X (Details in
// frontend/bsp_rename). Der Workflow frontend_deploy baut und pusht
// solche Branches on demand.
//
// Aufruf:  node frontend/build-branches.mjs [branch ...]
// Ohne Argumente werden die vier festen Branches gebaut; mit Argumenten nur
// die genannten (so baut jeder build_<branch>-Workflow genau seinen Branch).
// Output je Branch: frontend/out/<branch>/
//
// Die Webapp kommt aus app/webapp DIESES Repositories - die einzige Quelle.
// Alles andere, was ein Output-Branch braucht, liegt unter frontend/:
//   frontend/abap/        ICF-/BSP-ABAP-Artefakte (cloud + standard)
//   frontend/app/         Projektdateien der Fiori-Dev-Umgebung (ohne webapp)
//   frontend/common/      Dateien, die jeder Branch erbt (README, LICENSE, ...)
//   frontend/abaplint.jsonc  Lint-Config, im Branch auf /src/ gedreht

import { execFileSync } from "node:child_process";
import { cpSync, rmSync, mkdirSync, readFileSync, writeFileSync, readdirSync, existsSync } from "node:fs";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";
import { patchIndexHtml, patchManifest } from "./app2app_v2/patch-v2.mjs";

const here = dirname(fileURLToPath(import.meta.url));
const core = join(here, "..");
const webapp = join(core, "app/webapp");
const out = join(here, "out");

// Dateien, die jeder Output-Branch erbt (kein Tooling, kein CI);
// nicht (mehr) vorhandene werden uebersprungen
const COMMON = [".gitignore", "CODE_OF_CONDUCT.md", "LICENSE", "README.md", "SECURITY.md"];

// abapGit-Deskriptoren wie auf den bisherigen Branches
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

function banner(branch) {
  const workflow = BUILDERS[branch] ? `build_${branch}` : "build_rename";
  const origin = CORE_SHA
    ? ` Frontend state: \`abap2UI5/abap2UI5@${CORE_SHA.slice(0, 12)}\`${CORE_VERSION ? ` (framework ${CORE_VERSION})` : ""} — see \`VERSION\`.`
    : "";
  return `> ⚙️ **Generated branch \`${branch}\`** — built from [\`main\`](../../tree/main) by the ` +
    "`" + workflow + "` workflow. Do not commit here, changes belong into `main`." + origin + "\n\n";
}

// Provenance: which framework state this branch was built from. Both the
// commit and the framework version constant come from THIS repository, and are
// stamped into each generated branch so a pulled branch can be matched to a
// backend release. Deliberately no timestamp: identical sources must produce
// identical trees, or build_branch.yaml would push an empty rebuild on every
// run.
//
// The stamp still names the commit as "webapp mirror commit" and the branch
// banner still calls it the frontend state, because that is what a pulled
// branch out there says - the value is the same sha the mirror commits used to
// carry, so nothing a user compares against changes.
function coreSha() {
  // GITHUB_SHA is what the workflow builds from; the local HEAD is the
  // equivalent for a manual run. A shallow or detached checkout can leave
  // neither, and the stamp then simply omits the provenance line.
  if (/^[0-9a-f]{40}$/.test(process.env.GITHUB_SHA ?? "")) return process.env.GITHUB_SHA;
  try {
    return execFileSync("git", ["rev-parse", "HEAD"], { cwd: core, encoding: "utf8" }).trim() || null;
  } catch {
    return null;
  }
}

function coreVersion() {
  try {
    const source = readFileSync(join(core, "src/02/z2ui5_if_app.intf.abap"), "utf8");
    return /CONSTANTS\s+version\s+TYPE\s+string\s+VALUE\s+`([^`]+)`/i.exec(source)?.[1] ?? null;
  } catch {
    return null;
  }
}

const CORE_SHA = coreSha();
const CORE_VERSION = coreVersion();

function versionStamp() {
  return [
    "Generated abap2UI5-frontend branch — provenance",
    `webapp mirror commit: ${CORE_SHA ? `abap2UI5/abap2UI5@${CORE_SHA}` : "unknown"}`,
    CORE_VERSION ? `abap2UI5 framework version: ${CORE_VERSION}` : null,
  ].filter(Boolean).join("\n") + "\n";
}

function initBranch(branch, abapgitXml) {
  const dir = join(out, branch);
  rmSync(dir, { recursive: true, force: true });
  mkdirSync(dir, { recursive: true });
  for (const f of COMMON) if (existsSync(join(here, "common", f))) cpSync(join(here, "common", f), join(dir, f));
  writeFileSync(join(dir, "README.md"), banner(branch) + readFileSync(join(here, "common/README.md"), "utf8"));
  writeFileSync(join(dir, ".abapgit.xml"), abapgitXml);
  // abaplint-Config von main, Quellpfad auf /src/ der Output-Branches gedreht;
  // ohne sie meldet der abaplint-Check auf den Output-Branches immer rot
  writeFileSync(join(dir, "abaplint.jsonc"),
    readFileSync(join(here, "abaplint.jsonc"), "utf8").replaceAll("/abap/cloud/", "/src/"));
  return dir;
}

const skipBuildArtifacts = (src) =>
  !/(^|\/)(node_modules|dist|\.git)(\/|$)/.test(src);

// Webapp + ABAP-Cloud-Artefakte 1:1 von main; fuer cloud_v2 wird der
// Webapp-Bootstrap zusaetzlich auf legacy-free gepatcht.
function buildCloudVariant(branch) {
  const dir = initBranch(branch, ABAPGIT_CLOUD);
  cpSync(join(here, "app"), join(dir, "app"), { recursive: true, filter: skipBuildArtifacts });
  cpSync(webapp, join(dir, "app/webapp"), { recursive: true, filter: skipBuildArtifacts });
  cpSync(join(here, "abap/cloud"), join(dir, "src"), { recursive: true });
  if (branch === "cloud_v2") {
    const wa = join(dir, "app/webapp");
    writeFileSync(join(wa, "index.html"), patchIndexHtml(readFileSync(join(wa, "index.html"), "utf8")));
    writeFileSync(join(wa, "manifest.json"), patchManifest(readFileSync(join(wa, "manifest.json"), "utf8")));
  }
}

// Klassische BSP via app2bsp + ICF-Handler
function buildStandard(branch = "standard") {
  const dir = initBranch(branch, ABAPGIT_STANDARD);
  const work = join(out, "_work_standard");
  cpSync(join(here, "app2bsp"), join(work, ".github/app2bsp"), { recursive: true });
  cpSync(webapp, join(work, "frontend/app/webapp"), { recursive: true, filter: skipBuildArtifacts });
  execFileSync("node", [".github/app2bsp/preload.js"], { cwd: work, stdio: "inherit" });
  execFileSync("node", [".github/app2bsp/run.js"], { cwd: work, stdio: "ignore" });
  cpSync(join(here, "abap/standard"), join(dir, "src"), { recursive: true });
  cpSync(join(work, "src/02"), join(dir, "src/02"), { recursive: true });
  rmSync(work, { recursive: true, force: true });
}

// Legacy-free BSP via build-legacy-free.mjs
function buildStandardV2(branch = "standard_v2") {
  const dir = initBranch(branch, ABAPGIT_STANDARD);
  const work = join(out, "_work_standard_v2");
  execFileSync("node", [join(here, "app2app_v2/build-legacy-free.mjs"), here, webapp, work],
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

// standard_<NAME> / standard_v2_<NAME>: Basis bauen, dann die komplette
// Deployment-Identitaet (BSP, SICF-Knoten, Handler-Klasse, Dateinamen) im
// generierten src-Tree auf <NAME> umbenennen. Namensvalidierung (max. 15
// Zeichen, Z/Y-Namensraum-Warnung, /NS/-Namen) uebernimmt rename-bsp.mjs;
// die #ns#name-Schreibweise reicht es unveraendert durch.
function renamedBuilder(branch) {
  for (const base of ["standard_v2", "standard"]) {
    const prefix = `${base}_`;
    if (!branch.startsWith(prefix) || branch.length === prefix.length) continue;
    const name = branch.slice(prefix.length);
    const buildBase = base === "standard" ? buildStandard : buildStandardV2;
    return () => {
      buildBase(branch);
      execFileSync("node",
        [join(here, "bsp_rename/rename-bsp.mjs"), name, "--yes", "--dir", "src"],
        { cwd: join(out, branch), stdio: "inherit" });
    };
  }
  return null;
}

const requested = process.argv.slice(2);
const branches = requested.length ? requested : Object.keys(BUILDERS);
const builds = branches.map((b) => {
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
  writeFileSync(join(out, b, "VERSION"), versionStamp());
  const n = readdirSync(join(out, b), { recursive: true }).length;
  console.log(`OK: ${b} (${n} Eintraege) -> ${join(out, b)}`);
}
