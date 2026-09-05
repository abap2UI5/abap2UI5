// Gate: every Z2UI5 object name written as a string literal - the argument of a
// dynamic lookup, a CREATE OBJECT TYPE (name), a CALL METHOD (name)= - names an
// object that this repository actually ships.
//
// Why this exists as a gate: a dynamic name is a string, so nothing resolves it.
// The compiler does not, abaplint does not, and the transpiler does not either -
// the lookups behind these literals read SEOCLASS / XCO, neither of which exists
// under `npm run unit`, so a literal naming nothing returns an empty table and
// every caller treats that as "the customer did not implement it". Green CI,
// silently dead feature.
//
// That is exactly how it bit us: #2564 renamed z2ui5_cl_exit to
// z2ui5_cl_ui5_user_exit and carried the rename into the *interface* literal in
// z2ui5_cl_ui5_user_exit=>get_user_exit_class, which became `Z2UI5_IF_USER_EXIT`
// - an interface that does not exist. The shipped interface is Z2UI5_IF_EXIT, so
// from that commit on no user exit was found in any system: no configured UI5
// bootstrap, no theme, no CSP override, and no error anywhere to say so. It was
// found by a user whose config class had stopped working, not by CI.
//
// A rename sweep is what makes this class of defect likely, and a rename sweep
// is precisely when nobody rereads a string literal.

import { fileURLToPath } from "url";
import { readFileSync } from "fs";
import { join } from "path";
import { walk } from "./lib/walk.mjs";

const ROOT = fileURLToPath(new URL("../../", import.meta.url));

// Names that are meant to be absent here: they belong to other repositories and
// the code around them asks first (rtti_check_class_exists) or is frozen. Each
// one needs the reason, so an entry cannot become a silent hole.
const EXTERNAL = new Map([
  [
    "Z2UI5_CL_APP_ICF_CONFIG",
    "ships in abap2UI5/abap2UI5-icf-config - guarded by rtti_check_class_exists",
  ],
  [
    "Z2UI5_CL_CC_DEMO_OUT",
    "sample custom control of the samples repository - referenced from frozen src/99",
  ],
  // the start page's sample tiles - each guarded by rtti_check_class_exists
  // and spelled in lower case, which is why the gate reads both cases
  ["Z2UI5_CL_SMP_APP_000", "ships in abap2UI5/samples - guarded by rtti_check_class_exists"],
  ["Z2UI5_CL_DEMO_APP_G00", "superseded name of the samples entry - guarded by rtti_check_class_exists"],
  ["Z2UI5_CL_SMPC_APP_000", "ships in abap2UI5/samples-controls - guarded by rtti_check_class_exists"],
  ["Z2UI5_CL_SMPC_APP_OVERVIEW", "superseded name of the samples-controls entry - guarded by rtti_check_class_exists"],
  ["Z2UI5_CL_SMPS_APP_000", "ships in abap2UI5/samples-stack - guarded by rtti_check_class_exists"],
  ["Z2UI5_CL_SMPS_APP_00", "superseded name of the samples-stack entry - guarded by rtti_check_class_exists"],
]);

// backtick literals are how this repository writes strings; the downported
// packages also carry single-quoted ones. Both cases: rtti_check_class_exists
// upper-cases its argument, and the start page spells its sample tiles in
// lower case - an upper-case-only scan let a lower-case typo there through
// with the #2564 shape and a green gate
const LITERAL = /[`'](Z2UI5_(?:CL|CX|IF)_[A-Z0-9_]+)[`']/gi;

const files = walk(ROOT, "src").filter(f => f.endsWith(".abap"));

// what the repository ships, by the file name - abapGit derives the object name
// from it, so the file name IS the object name (see check:abapgit, rule
// `clsname`). Every package counts, the frozen one included: src/99 still
// ships, and the superseded exit interface named from src/01 lives there
const shipped = new Set();
for (const file of files) {
  const base = file.slice(file.lastIndexOf("/") + 1);
  const match = base.match(/^(z2ui5_[a-z0-9_]+)\.(clas|intf)\.abap$/);
  if (match) shipped.add(match[1].toUpperCase());
}

// scanned: every package but the frozen one. src/99 is history only - never
// changed, so a gate that governs change has nothing to decide there, and
// its lower-case literals are event ids spelled like class names
const scanned = files.filter(f => !f.startsWith("src/99/"));

const findings = [];
for (const file of scanned) {
  const lines = readFileSync(join(ROOT, file), "utf8").split("\n");
  lines.forEach((line, index) => {
    if (line.trimStart().startsWith("*") || line.trimStart().startsWith('"')) return;
    for (const [, raw] of line.matchAll(LITERAL)) {
      const name = raw.toUpperCase();
      if (shipped.has(name) || EXTERNAL.has(name)) continue;
      findings.push({ file, line: index + 1, name });
    }
  });
}

if (findings.length > 0) {
  console.log("Dynamic name literal(s) naming an object this repository does not ship:");
  console.log("");
  for (const f of findings) {
    console.log(`  ${f.file}:${f.line}  ${f.name}`);
  }
  console.log("");
  console.log("Nothing resolves these at build time - the lookup behind them returns");
  console.log("an empty result at runtime and the caller reads that as 'not implemented'.");
  console.log("Fix the literal, or - if the object genuinely lives in another repository");
  console.log("- add it to EXTERNAL in this file with the reason.");
  process.exit(1);
}

const external = EXTERNAL.size === 1 ? "1 external name" : `${EXTERNAL.size} external names`;
console.log(
  `dynamic-name: ${scanned.length} file(s) checked, every literal resolves - OK (${external} allowed)`,
);
