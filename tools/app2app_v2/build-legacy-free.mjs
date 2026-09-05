#!/usr/bin/env node
// build-legacy-free.mjs
// Produces the legacy-free (UI5 2.0) BSP state 1:1 from the classic abap2UI5
// frontend (app/webapp) + a minimal bootstrap patch.
//
//   app/webapp -> [bootstrap patch] -> app2bsp/preload.js -> app2bsp/run.js [-> bsp_rename(--name)]
//
// Only index.html + manifest.json are adjusted (everything else stays 1:1).
// The result has the same package structure as the standard branch:
//   src/package.devc.xml  (root package)
//   src/01/               (ICF handler, from abap/standard)
//   src/02/               (BSP page)
// The BSP is called Z2UI5 by default (like the classic frontend, no rename);
// with --name Z2UI5_V2 it is renamed for a parallel installation. A renamed
// BSP shares the classic backend node /sap/bc/z2ui5 unless --own-backend is
// given, which keeps its own /sap/bc/<name> and renames src/01 with it so
// that node and its handler class actually ship. --own-backend without
// --name is a no-op: without a rename there is only one node.
// Usage:  node tools/app2app_v2/build-legacy-free.mjs <repo-root> <webapp> <out-dir> [--name Z2UI5_V2] [--own-backend]

import { execFileSync } from "node:child_process";
import { cpSync, rmSync, mkdirSync, readFileSync, writeFileSync, readdirSync } from "node:fs";
import { join, resolve } from "node:path";
// the only change in substance: switch the bootstrap to legacy-free
import { patchIndexHtml, patchManifest } from "./patch-v2.mjs";
// The name rules of the rename step itself, so the paths computed here cannot
// disagree with the files it writes.
import { deriveNames, toFileName } from "../bsp_rename/rename-bsp.mjs";

const [repoRoot, cloudWebapp, outDir] = process.argv.slice(2);
if (!repoRoot || !cloudWebapp || !outDir || [repoRoot, cloudWebapp, outDir].some((a) => a.startsWith("--"))) {
  console.error("Usage: node tools/app2app_v2/build-legacy-free.mjs <repoRoot> <cloudWebapp> <outDir> [--name <BSP>] [--own-backend]");
  process.exit(1);
}
const toolsDir = join(repoRoot, "tools");
const dataDir = join(repoRoot, "frontend");
const ownBackend = process.argv.includes("--own-backend");
const nameIdx = process.argv.indexOf("--name");
if (nameIdx > -1 && !process.argv[nameIdx + 1]) {
  console.error("--name needs a value (e.g. --name Z2UI5_V2)");
  process.exit(1);
}
const bspName = nameIdx > -1 ? process.argv[nameIdx + 1] : "Z2UI5";
// Derived by bsp_rename's own rule rather than by upper/lower-casing the
// argument: a namespaced name defaults /ABAPGIT/ to /ABAPGIT/UI5, accepts the
// abapGit `#ns#name` spelling, and puts the ICF node under /sap/bc/<ns>/<leaf>.
// Step 5 below read the raw argument instead and looked for a manifest file
// that a namespaced rename never writes.
let names;
try {
  names = deriveNames(bspName);
} catch (err) {
  console.error(err.message);
  process.exit(1);
}
const renamed = names.up !== "Z2UI5";
// The ICF node the renamed manifest points at - what --own-backend keeps.
const ownService = names.ns ? `/sap/bc/${names.nsLo}/${names.leafLo}` : `/sap/bc/${names.lo}`;
const BSP_WIDTH = 255;

// BSP page format (255-character lines, no trailing newline) - like app2bsp
function rePad(line) { return line.length <= BSP_WIDTH ? line.padEnd(BSP_WIDTH)
  : line.match(new RegExp(`.{1,${BSP_WIDTH}}`, "g")).map(x => x.padEnd(BSP_WIDTH)).join("\n"); }

const work = join(outDir, "_work");
rmSync(outDir, { recursive: true, force: true }); mkdirSync(work, { recursive: true });

// 1) provide the tooling + a clean cloud webapp
cpSync(join(toolsDir, "app2bsp"), join(work, ".github/app2bsp"), { recursive: true });
cpSync(join(toolsDir, "bsp_rename"), join(work, ".github/bsp_rename"), { recursive: true });
cpSync(cloudWebapp, join(work, "frontend/app/webapp"), { recursive: true });

// 2) bootstrap patch
const wa = join(work, "frontend/app/webapp");
writeFileSync(join(wa, "index.html"), patchIndexHtml(readFileSync(join(wa, "index.html"), "utf8")));
writeFileSync(join(wa, "manifest.json"), patchManifest(readFileSync(join(wa, "manifest.json"), "utf8")));

// 3) preload.js  +  app2bsp  +  4) optional rename (only with --name, e.g. Z2UI5_V2)
// Quiet on success, never on failure: the discarded log is the only thing
// that says WHY a step failed.
function runQuiet(args, cwd = work) {
  try {
    execFileSync("node", args, { cwd, stdio: ["ignore", "pipe", "pipe"] });
  } catch (error) {
    process.stderr.write(String(error.stdout ?? ""));
    process.stderr.write(String(error.stderr ?? ""));
    throw error;
  }
}
execFileSync("node", [".github/app2bsp/preload.js"], { cwd: work, stdio: "inherit" });
runQuiet([".github/app2bsp/run.js"]);
if (renamed) {
  runQuiet([".github/bsp_rename/rename-bsp.mjs", bspName, "--dir", "src/02", "--yes"]);
}

// 5) backend datasource: shared by default (/sap/bc/z2ui5), --own-backend keeps
//    the renamed node (and step 6 then ships it).
//    Both the node and the file name come from `names`, not from the raw
//    --name argument: for /ABAPGIT/UI5 bsp_rename writes the data source
//    "/sap/bc/abapgit/ui5" into #abapgit#ui5.wapa.manifest.json, and reading
//    the argument gave "/sap/bc//abapgit/ui5" and a file name with a "/" in
//    it - the readFileSync then died on a path that cannot exist.
const bsp = join(work, "src/02");
const manifestPage = join(bsp, `${toFileName(names.lo)}.wapa.manifest.json`);
if (renamed && !ownBackend) {
  const fixed = readFileSync(manifestPage, "utf8").split("\n")
    .map(l => l.includes(`"${ownService}"`) ? rePad(l.replace(/ *$/, "").replace(ownService, "/sap/bc/z2ui5")) : l)
    .join("\n");
  writeFileSync(manifestPage, fixed);
}

// 6) package structure as in the standard branch: root package + 01 (ICF handler) + 02 (BSP)
cpSync(join(dataDir, "abap/standard"), join(outDir, "src"), { recursive: true });
if (renamed && ownBackend) {
  // --own-backend promises the renamed BSP its OWN entry point, and until now
  // only the manifest said so: what src/01 carries is the SHIPPED z2ui5 ICF
  // node and Z2UI5_CL_LP_HANDLER, so the data source above named a node the
  // delivered tree does not contain and the app answered 404 on its first
  // roundtrip. Rename the backend package with the same tool the BSP went
  // through - it moves the SICF node, its file-name hash and the handler
  // class, and keeps z2ui5_cl_http_handler, which is the framework class the
  // handler calls and is installed once from abap2UI5 itself.
  // resolved: the tool copy is addressed from a DIFFERENT cwd than the
  // steps above run in, and `work` may be a relative path.
  runQuiet([resolve(work, ".github/bsp_rename/rename-bsp.mjs"), bspName, "--dir", "src/01", "--yes"], outDir);
}
cpSync(bsp, join(outDir, "src/02"), { recursive: true });
rmSync(work, { recursive: true, force: true });
const n = readdirSync(join(outDir, "src/02")).length;
const backend = renamed && ownBackend
  ? `[own backend handler ${ownService} -> ${names.handlerUp}]`
  : "[backend handler /sap/bc/z2ui5]";
console.log(`OK: legacy-free BSP ${names.up} generated (${n} files) in ${join(outDir, "src/02")} ${backend}`);
