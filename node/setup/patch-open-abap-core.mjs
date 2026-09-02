// Pre-transpile patches for the pinned open-abap-core checkout under
// node/deps, applied before `abap_transpile` reads it (npm run auto_transpile).
// Both are temporary shims for gaps filed upstream in backlog/items/
// (open-abap/open-abap-core); each goes away the moment the pinned SHA
// carries the fix - see "Removing this" below. Both are idempotent (marker
// comment) and FAIL when the line they anchor on moves upstream.
//
// 1. cl_abap_typedescr=>describe_by_name and ABSOLUTE type names
//    (backlog/items/open-abap-describe-by-name-absolute.md)
//
// S-RTTI (src/00/02, the draft's way of carrying a runtime-built type across
// the roundtrip) serializes each elementary component by its absolute name
// and, on the way back, asks describe_by_name( absolute_name ) for every
// component that is not anonymous. On a system `\TYPE=STRING` answers with
// the string descriptor. In the NodeJS runtime the same call reaches
// CREATE DATA with the absolute name and dies with type_not_found - so no
// draft that carries a TYPE HANDLE table whose line was built from a NAMED
// structure could be restored in the transpiled backend. That is the shape
// of every runtime-typed sample (a DDIC structure's components plus SELKZ),
// and it is why ltcl_test_app_root4->test_tab_ref_gen was skipped in
// node/setup/abap_transpile.json for years. The patch re-enters
// describe_by_name with the part after the last `\TYPE=` - `STRING`, `I`,
// `ABAP_BOOL` - which the runtime already resolves.
//
// 2. CALL TRANSFORMATION id writes elementary values UNESCAPED
//    (backlog/items/open-abap-asxml-text-escape.md)
//
// The asXML writer (kernel_call_transformation, lcl_data_to_xml=>run)
// concatenates a string value into the element as it is, while the parser
// resolves &lt; &gt; &amp; on the way back. A value that CONTAINS markup -
// the S-RTTI payload every draft with a generic data reference carries in
// mt_attri-srtti_data - comes back truncated at its first `<`, and the
// restore fails on it. The patch escapes `&`, `<` and `>` in character-like
// values, which is what a system does.
//
// Removing either: bump the open-abap-core pin in node/setup/fetch-deps.mjs
// to a SHA that carries the upstream fix, delete that patch below (the file
// once both are gone, together with its entry in `auto_transpile` in
// package.json) and close the backlog item.
import { readFileSync, writeFileSync, existsSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { join } from "node:path";

const ROOT = fileURLToPath(new URL("../../", import.meta.url));
const CORE = join(ROOT, "node", "deps", "open-abap-core", "src");

function patch(label, file, marker, anchor, replacement) {
  if (!existsSync(file)) {
    console.error(`patch-open-abap-core: ${file} not found - run npm run deps first`);
    process.exit(1);
  }
  const source = readFileSync(file, "utf8");
  if (source.includes(marker)) {
    console.log(`patch-open-abap-core: ${label} already applied`);
    return;
  }
  if (!source.includes(anchor)) {
    console.error(`patch-open-abap-core: ${label} - anchor not found, the pinned open-abap-core changed, review the patch`);
    process.exit(1);
  }
  writeFileSync(file, source.replace(anchor, replacement));
  console.log(`patch-open-abap-core: ${label} applied to ${file}`);
}

// 1. describe_by_name with an absolute name
{
  const marker = "* abap2UI5 patch 1 (node/setup/patch-open-abap-core.mjs)";
  const anchor = "* note, p_name might be internal name, so check and skip these,";
  const lines = [
    marker + ": an ABSOLUTE type name of a",
    "* built-in or dictionary type - the spelling S-RTTI resolves a serialized",
    "* descriptor by - is looked up by its relative part, as a system does",
    "    DATA lv_absolute TYPE string.",
    "    DATA lv_offset   TYPE i.",
    "    lv_absolute = p_name.",
    "    IF lv_absolute CP '\\TYPE*' AND lv_absolute NA '%'.",
    "      FIND FIRST OCCURRENCE OF '\\TYPE=' IN lv_absolute MATCH OFFSET lv_offset.",
    "      IF sy-subrc = 0.",
    "        lv_offset = lv_offset + 6.",
    "        lv_absolute = lv_absolute+lv_offset.",
    "        type = describe_by_name( lv_absolute ).",
    "        RETURN.",
    "      ENDIF.",
    "    ENDIF.",
    "",
  ];
  patch("describe_by_name", join(CORE, "rtti", "cl_abap_typedescr.clas.abap"), marker, anchor, lines.join("\n") + anchor);
}

// 2. asXML text escaping
{
  const marker = "* abap2UI5 patch 2 (node/setup/patch-open-abap-core.mjs)";
  const anchor = [
    "        IF lo_type->type_kind = cl_abap_typedescr=>typekind_string AND <ref> IS INITIAL.",
    "          rv_xml = rv_xml && |<{ iv_name }/>|.",
    "        ELSE.",
    "          rv_xml = rv_xml &&",
    "            |<{ iv_name }>| &&",
    "            <ref> &&",
    "            |</{ iv_name }>|.",
    "        ENDIF.",
  ].join("\n");
  const lines = [
    "        IF lo_type->type_kind = cl_abap_typedescr=>typekind_string AND <ref> IS INITIAL.",
    "          rv_xml = rv_xml && |<{ iv_name }/>|.",
    "        ELSEIF lo_type->type_kind = cl_abap_typedescr=>typekind_string",
    "            OR lo_type->type_kind = cl_abap_typedescr=>typekind_char.",
    marker + ": a character value is",
    "* written ESCAPED, as a system writes it and as the parser reads it back",
    "          DATA lv_escaped TYPE string.",
    "          lv_escaped = <ref>.",
    "          REPLACE ALL OCCURRENCES OF '&' IN lv_escaped WITH '&amp;'.",
    "          REPLACE ALL OCCURRENCES OF '<' IN lv_escaped WITH '&lt;'.",
    "          REPLACE ALL OCCURRENCES OF '>' IN lv_escaped WITH '&gt;'.",
    "          rv_xml = rv_xml &&",
    "            |<{ iv_name }>| &&",
    "            lv_escaped &&",
    "            |</{ iv_name }>|.",
    "        ELSE.",
    "          rv_xml = rv_xml &&",
    "            |<{ iv_name }>| &&",
    "            <ref> &&",
    "            |</{ iv_name }>|.",
    "        ENDIF.",
  ];
  patch("asXML text escape", join(CORE, "kernel", "call_transformation", "kernel_call_transformation.clas.locals_imp.abap"), marker, anchor, lines.join("\n"));
}
