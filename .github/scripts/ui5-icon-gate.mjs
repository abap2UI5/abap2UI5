// Gate: every `sap-icon://<name>` shipped by this repository exists in the SAP
// icon font of UI5 1.71 - the oldest release abap2UI5 supports.
//
// Why this exists as a gate and not as prose: an icon name is never checked by
// anything. UI5 resolves it at render time, and an unknown name is not an error
// - IconPool simply finds nothing and the control renders with no icon at all.
// Nothing in abaplint, in the ui5lint gate or in a browser console says a word,
// so the defect only shows up as "the icon is missing" on an old system, months
// later, reported by whoever happens to run 1.71. Two of them had shipped that
// way before this gate existed: the developer tools' help button and the
// legacy popups in src/99, all on `sap-icon://information`, a glyph the icon
// font gained after 1.71.
//
// The name list in ui5-icons-1.71.json is the icon registry of OpenUI5 1.71
// (sap/ui/core/IconPool.js, 655 names). It is a snapshot on purpose: 1.71 is
// closed for new features, so the set cannot grow. Icons added later are
// exactly what this gate is here to reject.
//
// Note on case: IconPool resolves `sap-icon://X` through URI.parse( ), which
// lower-cases the host part, so icon names are effectively case-insensitive
// and camelCase names are silently wrong. `sap-icon://textFormatting` renders
// nothing in EVERY release - the name is `text-formatting`. The gate compares
// lower-cased for the same reason.

import { readdirSync, readFileSync, statSync } from "fs";
import { join, relative } from "path";

const ROOT = new URL("../../", import.meta.url).pathname;

const ICONS = new Set(
  JSON.parse(readFileSync(join(ROOT, ".github/scripts/ui5-icons-1.71.json"), "utf8")),
);

// Where icons can be written: the ABAP sources and the frontend app that
// src/01/03 is generated from.
const SCAN = ["src", "app/webapp"];

// Directories this gate does not judge, with the reason shown in the report so
// the exemption is never a silent hole.
const EXEMPT = [
  ["src/99", "frozen package (AGENTS.md rule 1) - ships as-is until the removal plan retires it"],
];

// Icons that are already wrong inside an EXEMPT directory. Listed so the
// exemption does not hide them: the gate prints them as known findings and
// they are fixed when the frozen package is retired or unfrozen.
const KNOWN = [
  ["src/99/02/z2ui5_cl_pop_to_inform.clas.abap", "information", "message-information"],
  ["src/99/02/z2ui5_cl_pop_demo_output.clas.abap", "textFormatting", "text-formatting"],
];

const SOURCE = /\.(abap|xml|js|html|json)$/;
const ICON_URI = /sap-icon:\/\/([A-Za-z0-9_/-]+)/g;

function* files(dir) {
  for (const entry of readdirSync(join(ROOT, dir))) {
    const rel = `${dir}/${entry}`;
    if (statSync(join(ROOT, rel)).isDirectory()) yield* files(rel);
    else if (SOURCE.test(entry)) yield rel;
  }
}

const findings = [];
for (const scan of SCAN) {
  for (const file of files(scan)) {
    if (EXEMPT.some(([dir]) => file.startsWith(`${dir}/`))) continue;
    const source = readFileSync(join(ROOT, file), "utf8");
    for (const match of source.matchAll(ICON_URI)) {
      // a collection-qualified icon (sap-icon://collection/name) belongs to a
      // custom font this gate knows nothing about
      if (match[1].includes("/")) continue;
      if (ICONS.has(match[1].toLowerCase())) continue;
      const line = source.slice(0, match.index).split("\n").length;
      findings.push(`${file}:${line}  sap-icon://${match[1]} does not exist in UI5 1.71`);
    }
  }
}

for (const [dir, reason] of EXEMPT) console.log(`exempt: ${dir} - ${reason}`);
for (const [file, icon, fix] of KNOWN) {
  console.log(`known (exempt): ${file} uses sap-icon://${icon} - the 1.71 name is ${fix}`);
}

if (findings.length === 0) {
  console.log(`\nOK: every sap-icon:// name in ${SCAN.join(", ")} exists in UI5 1.71`);
  process.exit(0);
}

console.error(`\nFAIL: ${findings.length} icon(s) that UI5 1.71 does not have:\n`);
for (const finding of findings) console.error(`  ${finding}`);
console.error(
  "\nUI5 renders no icon at all for an unknown name - pick one that 1.71 already had.",
);
process.exit(1);
