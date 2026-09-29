// frontend-bsp.mjs - abap2UI5's own frontend as the BSP Z2UI5, through
// @abap2ui5/bsp (tools/bsp). What build-branches.mjs and
// app2app_v2/build-legacy-free.mjs call where they ran run.js.
//
// The texts and the path mapping are what the delivered branches have always
// carried, so the published trees stay byte for byte what they were. The
// mapping in particular is the checked-in page in static_files/, not the one
// @abap2ui5/bsp would generate: it lists files the webapp no longer has, and
// replacing it is a change to every delivered branch of its own.
//
// run.js itself stays, unchanged and self-contained: abap2UI5/embed-control's
// scripts/build-bsp.mjs copies this folder into a working directory and runs
// it there, where tools/bsp is not next to it. It goes once that build calls
// @abap2ui5/bsp.

import { readFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import { app2bsp } from "../bsp/index.mjs";

const here = dirname(fileURLToPath(import.meta.url));

export function writeFrontendBsp(webapp, target) {
  return app2bsp({
    webapp,
    target,
    name: "Z2UI5",
    text: "abap2UI5 frontend (generated)",
    icfText: "abap2UI5 - Frontend",
    packageText: "abap2UI5",
    mapping: readFileSync(join(here, "static_files", "z2ui5.wapa.ui5repositorypathmapping.xml"), "utf8"),
  });
}
