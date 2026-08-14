#!/usr/bin/env node
// build-legacy-free.mjs
// Erzeugt den legacy-free (UI5 2.0) BSP-Stand 1:1 aus dem klassischen
// abap2UI5-Frontend (app/webapp) + minimalem Bootstrap-Patch.
//
//   app/webapp -> [Bootstrap-Patch] -> app2bsp/preload.js -> app2bsp/run.js [-> bsp_rename(--name)]
//
// Nur index.html + manifest.json werden angepasst (alles andere bleibt 1:1).
// Das Ergebnis hat dieselbe Paketstruktur wie der standard-Branch:
//   src/package.devc.xml  (Root-Paket)
//   src/01/               (ICF-Handler, aus abap/standard)
//   src/02/               (BSP-Seite)
// Die BSP heisst per Default Z2UI5 (wie das klassische Frontend, kein Rename);
// mit --name Z2UI5_V2 wird fuer eine Parallelinstallation umbenannt.
// Aufruf:  node frontend/app2app_v2/build-legacy-free.mjs <frontend-dir> <webapp> <out-dir> [--name Z2UI5_V2] [--own-backend]

import { execFileSync } from "node:child_process";
import { cpSync, rmSync, mkdirSync, readFileSync, writeFileSync, readdirSync } from "node:fs";
import { join } from "node:path";
// der einzige inhaltliche Eingriff: Bootstrap auf legacy-free umstellen
import { patchIndexHtml, patchManifest } from "./patch-v2.mjs";

const [frontendDir, cloudWebapp, outDir] = process.argv.slice(2);
const ownBackend = process.argv.includes("--own-backend");
const nameIdx = process.argv.indexOf("--name");
const bspName = nameIdx > -1 ? process.argv[nameIdx + 1] : "Z2UI5";
const renamed = bspName.toUpperCase() !== "Z2UI5";
const BSP_WIDTH = 255;

// BSP-Page-Format (255-Zeichen-Zeilen, kein Schluss-Newline) – wie app2bsp
function rePad(line) { return line.length <= BSP_WIDTH ? line.padEnd(BSP_WIDTH)
  : line.match(new RegExp(`.{1,${BSP_WIDTH}}`, "g")).map(x => x.padEnd(BSP_WIDTH)).join("\n"); }

const work = join(outDir, "_work");
rmSync(outDir, { recursive: true, force: true }); mkdirSync(work, { recursive: true });

// 1) Tooling + saubere cloud-Webapp bereitstellen
cpSync(join(frontendDir, "app2bsp"), join(work, ".github/app2bsp"), { recursive: true });
cpSync(join(frontendDir, "bsp_rename"), join(work, ".github/bsp_rename"), { recursive: true });
cpSync(cloudWebapp, join(work, "frontend/app/webapp"), { recursive: true });

// 2) Bootstrap-Patch
const wa = join(work, "frontend/app/webapp");
writeFileSync(join(wa, "index.html"), patchIndexHtml(readFileSync(join(wa, "index.html"), "utf8")));
writeFileSync(join(wa, "manifest.json"), patchManifest(readFileSync(join(wa, "manifest.json"), "utf8")));

// 3) preload.js  +  app2bsp  +  4) optionales Rename (nur mit --name, z.B. Z2UI5_V2)
execFileSync("node", [".github/app2bsp/preload.js"], { cwd: work, stdio: "inherit" });
execFileSync("node", [".github/app2bsp/run.js"], { cwd: work, stdio: "ignore" });
if (renamed) {
  execFileSync("node", [".github/bsp_rename/rename-bsp.mjs", bspName, "--dir", "src/02", "--yes"], { cwd: work, stdio: "ignore" });
}

// 5) Backend-Datasource: default geteilt (/sap/bc/z2ui5), --own-backend = /sap/bc/<name>
const bsp = join(work, "src/02");
if (renamed && !ownBackend) {
  const svc = `/sap/bc/${bspName.toLowerCase()}`;
  const mf = join(bsp, `${bspName.toLowerCase()}.wapa.manifest.json`);
  const fixed = readFileSync(mf, "utf8").split("\n")
    .map(l => l.includes(`"${svc}"`) ? rePad(l.replace(/ *$/, "").replace(svc, "/sap/bc/z2ui5")) : l)
    .join("\n");
  writeFileSync(mf, fixed);
}

// 6) Paketstruktur wie im standard-Branch: Root-Paket + 01 (ICF-Handler) + 02 (BSP)
cpSync(join(frontendDir, "abap/standard"), join(outDir, "src"), { recursive: true });
cpSync(bsp, join(outDir, "src/02"), { recursive: true });
rmSync(work, { recursive: true, force: true });
const n = readdirSync(join(outDir, "src/02")).length;
console.log(`OK: legacy-free BSP ${bspName.toUpperCase()} erzeugt (${n} Dateien) in ${join(outDir, "src/02")} ${renamed && ownBackend ? "[eigener Backend-Handler]" : "[Backend-Handler /sap/bc/z2ui5]"}`);
