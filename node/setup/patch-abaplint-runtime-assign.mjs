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
// Block 2 (backlog/items/open-abap-asxml-private-attributes.md): the asXML
// writer and reader of open-abap-core (kernel_call_transformation,
// kernel_ixml_xml_to_data) reach the attributes of a serializable object by
// the same dynamic ASSIGN. A PRIVATE attribute is a `#field` in the
// transpiled class - the walker reads `undefined`, the writer's ASSERT on
// sy-subrc dies, and no object with a private attribute (every
// z2ui5_cl_ajson_mapping mapper, any app helper with one) survives a draft
// in the transpiled backend. A system serializes them. The walker falls
// back to the FRIENDS_ACCESS_INSTANCE the transpiler keeps for exactly this
// kind of access. It is wider than a system (a dynamic ASSIGN from outside
// the class reaches a private attribute here, subrc 4 there) - a test
// runtime trade-off, noted in the backlog item.
//
// Removing this: bump @abaplint/runtime in package.json to a version that
// answers subrc 4 for block 1 and open-abap-core to one whose serializer
// reaches private attributes for block 2, delete the block, and when both
// are gone delete this file, take it out of `auto_transpile` in
// package.json and close the backlog items.
import { readFileSync, writeFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { join } from "node:path";

const ROOT = fileURLToPath(new URL("../../", import.meta.url));
const FILE = join(ROOT, "node_modules", "@abaplint", "runtime", "build", "src", "statements", "assign.js");
const MARKER = "// abap2UI5 patch (node/setup/patch-abaplint-runtime-assign.mjs)";

// the read reports a missing file itself - an existsSync ahead of it is a
// check-then-use the file can change between (CodeQL js/file-system-race)
let source;
try {
  source = readFileSync(FILE, "utf8");
} catch (e) {
  if (e.code === "ENOENT") {
    console.error("patch-abaplint-runtime-assign: " + FILE + " not found - run npm ci first");
    process.exit(1);
  }
  throw e;
}

function apply(label, marker, anchor, patched) {
  if (source.includes(marker)) {
    console.log("patch-abaplint-runtime-assign: " + label + " already applied");
    return;
  }
  if (!source.includes(anchor)) {
    console.error("patch-abaplint-runtime-assign: " + label + " - anchor not found in assign.js - the installed runtime changed, review the patch");
    process.exit(1);
  }
  source = source.replace(anchor, patched);
  writeFileSync(FILE, source);
  console.log("patch-abaplint-runtime-assign: " + label + " applied to " + FILE);
}

// block 1: a missing component before a `*` segment is sy-subrc 4
apply("missing component", MARKER, `                    if (upperS === "*") {
                        // @ts-ignore
                        input.dynamicSource = input.dynamicSource.dereference();
                    }`, `                    if (upperS === "*") {
                        ${MARKER}: a segment
                        // before this one resolved to nothing - the name has no
                        // address, which is sy-subrc 4 and not a TypeError
                        if (input.dynamicSource === undefined || typeof input.dynamicSource.dereference !== "function") {
                            abap.builtin.sy.get().subrc.set(4);
                            return;
                        }
                        // @ts-ignore
                        input.dynamicSource = input.dynamicSource.dereference();
                    }`);

// block 2: a private attribute of an object, for the asXML serializer
const MARKER2 = "// abap2UI5 patch 2 (node/setup/patch-abaplint-runtime-assign.mjs)";
apply("private attribute", MARKER2, `                        // @ts-ignore
                        input.dynamicSource = source[componentName];
                    }`, `                        // @ts-ignore
                        input.dynamicSource = source[componentName];
                        ${MARKER2}: a private
                        // attribute is a #field - the asXML writer and reader of
                        // open-abap-core reach it through this ASSIGN, as the
                        // kernel of a system does
                        if (input.dynamicSource === undefined && source?.FRIENDS_ACCESS_INSTANCE?.[componentName] !== undefined) {
                            input.dynamicSource = source.FRIENDS_ACCESS_INSTANCE[componentName];
                        }
                    }`);
