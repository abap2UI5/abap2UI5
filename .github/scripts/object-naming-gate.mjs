// Gate: every object name outside the public API and the frozen package carries
// the `ui5` segment - `z2ui5_cl_ui5_*` / `z2ui5_if_ui5_*` for the engine,
// `z2ui5_cl_ui5f_*` for the generated frontend artefacts in src/01/03.
//
// Why this exists as a gate and not as prose: abaplint's `object_naming` rule
// only checks the `^Z2UI5_C(L|X)` / `^Z2UI5_IF` prefix, so a new
// `z2ui5_cl_foo_bar` under src/01 passes every lint we run. Two segments had
// already drifted before this gate existed - the embedded frontend artefacts sat
// under `z2ui5_cl_app_*`, colliding with the real ABAP apps in src/02, and the
// engine under `z2ui5_cl_core_*`. Renaming those cost two sweeps over ~140
// files; catching the next one costs a failed PR.
//
// Not covered on purpose:
//   src/02  - the public API is a stable contract (AGENTS.md rule 5), its names
//             cannot be changed to satisfy a convention
//   src/99  - frozen production code (rule 1); it ships as-is until the
//             removal plan retires it
//   MIRRORED - src/00/01 (ajson) and src/00/02 (S-RTTI) are force-synced from
//             their mirror repositories by mirror.yaml, which does
//             `rm <target>/z*` + `cp <mirror>/src/z*`. A rename here is reverted
//             on the next scheduled run unless the mirror repos are renamed too,
//             and their interfaces sit in the signature of z2ui5_if_client~_bind

import { readdirSync } from "fs";
import { join } from "path";

const ROOT = new URL("../../", import.meta.url).pathname;

// directories whose names this gate does not judge, with the reason shown on a
// finding so the exemption is never a silent hole
const EXEMPT = [
  ["src/02", "public API - a stable contract, see AGENTS.md rule 5"],
  ["src/99", "frozen package - ships as-is until the removal plan retires it"],
  ["src/00/01", "mirrored from abap2UI5/ajson_mirror by mirror_ajson.yaml"],
  ["src/00/02", "mirrored from abap2UI5/srtti_mirror by mirror_srtti.yaml"],
];

// Nothing is pending: every layer outside EXEMPT is on the ui5 segment. If a
// rename ever has to wait on something, list it here with the blocker rather
// than adding the directory to EXEMPT - an exemption is permanent, this is not.
const PENDING = [];

// DDIC tables carry no layer segment (z2ui5_t_01, z2ui5_t_91): renaming one is a
// data migration in every installed system, not a rename. Judged by prefix only.
const TABLE = /^z2ui5_t_[0-9]+$/;

const OBJECT = /\.(clas|intf|tabl)\.xml$/;
const WANTED = /^z2ui5_(cl|cx|if)_ui5f?_/;

function walk(dir, out = []) {
  for (const entry of readdirSync(join(ROOT, dir), { withFileTypes: true })) {
    const rel = `${dir}/${entry.name}`;
    if (entry.isDirectory()) walk(rel, out);
    else if (OBJECT.test(entry.name)) out.push({ dir, name: entry.name.replace(OBJECT, "") });
  }
  return out;
}

const skipped = [...EXEMPT, ...PENDING];
const inSkipped = (dir) => skipped.some(([p]) => dir === p || dir.startsWith(`${p}/`));

const findings = [];
for (const { dir, name } of walk("src")) {
  if (inSkipped(dir)) continue;
  if (TABLE.test(name)) continue;
  if (WANTED.test(name)) continue;
  findings.push({ dir, name });
}

if (findings.length > 0) {
  console.log("Object names outside the public API must carry the `ui5` segment:");
  console.log("");
  for (const f of findings) {
    console.log(`  ${f.dir}/${f.name}`);
  }
  console.log("");
  console.log("Expected z2ui5_cl_ui5_* / z2ui5_cx_ui5_* / z2ui5_if_ui5_* (engine and");
  console.log("internal layers), or z2ui5_cl_ui5f_* for a generated frontend artefact");
  console.log("under src/01/03 - those names come from CLASS_NAME_STEMS in");
  console.log(".github/app2abap/trans2abap.js, not from this file.");
  console.log("");
  console.log("Exempt by design:");
  for (const [prefix, why] of EXEMPT) console.log(`  ${prefix.padEnd(10)} ${why}`);
  if (PENDING.length > 0) {
    console.log("Scheduled, not exempt:");
    for (const [prefix, why] of PENDING) console.log(`  ${prefix.padEnd(10)} ${why}`);
  }
  process.exit(1);
}

const checked = walk("src").filter(({ dir }) => !inSkipped(dir)).length;
const pending = PENDING.length > 0 ? `, ${PENDING.map(([p]) => p).join(" + ")} still scheduled` : "";
console.log(`object-naming: ${checked} object(s) checked, all on the ui5 segment - OK${pending}`);
