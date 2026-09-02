// Pre-transpile patch: make the runtime's dynamic ASSIGN answer sy-subrc 4
// for a path through a component that does not exist, instead of dying with
// a TypeError on the segment after it.
//
// Runs against the INSTALLED @abaplint/runtime in this checkout, before the
// transpiled suite and the express backend use it (npm run auto_transpile).
// It is a temporary shim for a defect filed upstream as
// `backlog/items/transpiler-dynamic-assign-missing-component.md`
// (abaplint/transpiler); it goes away the moment the pinned runtime carries
// the fix - see "Removing this" below.
//
// Why:
//
//     ASSIGN ('MO_APP->MO_APP->MT_TABLE->*') TO <fs>.
//
// with MO_APP->MO_APP pointing at an object that has NO attribute MT_TABLE
// sets sy-subrc 4 on a system. The runtime walks the segments, reads the
// missing attribute as `undefined` and then calls `.dereference()` on it for
// the `*` segment - a TypeError no CATCH cx_root reaches.
//
// abap2UI5 resolves every attribute of a draft by such a dynamic name
// (z2ui5_cl_ui5_srv_model=>attri_get_val_ref), and a host app that swapped
// its REF TO object sub-app for an instance of another class leaves rows
// whose names resolve to nothing (sample 338). On a system those rows are
// skipped; in the transpiled backend the restore died, which is what kept
// ltcl_test_class_swap and the zcl_tst_host fixture out of the suite.
//
// Removing this: bump @abaplint/runtime in package.json to a version that
// answers subrc 4 here, delete this file, take it out of `auto_transpile`
// in package.json and close the backlog item.
import { readFileSync, writeFileSync, existsSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { join } from "node:path";

const ROOT = fileURLToPath(new URL("../../", import.meta.url));
const FILE = join(ROOT, "node_modules", "@abaplint", "runtime", "build", "src", "statements", "assign.js");
const MARKER = "// abap2UI5 patch (node/setup/patch-abaplint-runtime-assign.mjs)";

if (!existsSync(FILE)) {
  console.error("patch-abaplint-runtime-assign: " + FILE + " not found - run npm ci first");
  process.exit(1);
}

const source = readFileSync(FILE, "utf8");
if (source.includes(MARKER)) {
  console.log("patch-abaplint-runtime-assign: already applied");
  process.exit(0);
}

const anchor = `                    if (upperS === "*") {
                        // @ts-ignore
                        input.dynamicSource = input.dynamicSource.dereference();
                    }`;
if (!source.includes(anchor)) {
  console.error("patch-abaplint-runtime-assign: anchor not found in assign.js - the installed runtime changed, review the patch");
  process.exit(1);
}

const patched = `                    if (upperS === "*") {
                        ${MARKER}: a segment
                        // before this one resolved to nothing - the name has no
                        // address, which is sy-subrc 4 and not a TypeError
                        if (input.dynamicSource === undefined || typeof input.dynamicSource.dereference !== "function") {
                            abap.builtin.sy.get().subrc.set(4);
                            return;
                        }
                        // @ts-ignore
                        input.dynamicSource = input.dynamicSource.dereference();
                    }`;

writeFileSync(FILE, source.replace(anchor, patched));
console.log("patch-abaplint-runtime-assign: applied to " + FILE);
