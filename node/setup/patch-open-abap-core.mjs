// Pre-transpile patches for the pinned open-abap-core checkout under
// node/deps, applied before `abap_transpile` reads it (npm run auto_transpile).
// All of them are temporary shims for gaps filed upstream in backlog/items/
// (open-abap/open-abap-core); each goes away the moment the pinned SHA
// carries the fix - see "Removing this" below. Each is idempotent (marker
// comment) and FAILS when the line it anchors on moves upstream. Patches 3
// and 4 are the two further asXML gaps of the same backlog item as 2 - the
// line feeds the parser strips and the entity order on the way back - and
// are described where they are defined below.
//
// The numbering starts at 2 because patch 1 is GONE: it taught
// cl_abap_typedescr=>describe_by_name to resolve an absolute type name, and
// open-abap/open-abap-core#1217 merged it (0800491, the SHA this repository
// now pins). The numbers of the rest stay as they are - the backlog item
// cites them by number, and renaming a shim to close a gap in the counting
// is how a reference goes stale.
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
// Removing one: bump the open-abap-core pin in node/setup/fetch-deps.mjs
// to a SHA that carries the upstream fix, delete that patch below (the file
// once all are gone, together with its entry in `auto_transpile` in
// package.json) and close the backlog item.
import { fileURLToPath } from "node:url";
import { join } from "node:path";
// The read / idempotence / anchor / replace / write routine, shared with the
// abaplint-side patch script next to this one - only the edit tables and
// the two messages below are this shim's own.
import { patchFile, PatchError, reportEdits } from "./lib/anchored-patch.mjs";

const ROOT = fileURLToPath(new URL("../../", import.meta.url));
const CORE = join(ROOT, "node", "deps", "open-abap-core", "src");

const TRANSFORMATION = join(CORE, "kernel", "call_transformation", "kernel_call_transformation.clas.locals_imp.abap");
const IXML = join(CORE, "ixml", "cl_ixml.clas.locals_imp.abap");

// 2. asXML text escaping
const MARKER2 = "* abap2UI5 patch 2 (node/setup/patch-open-abap-core.mjs)";
const ANCHOR2 = [
  "        IF lo_type->type_kind = cl_abap_typedescr=>typekind_string AND <ref> IS INITIAL.",
  "          rv_xml = rv_xml && |<{ iv_name }/>|.",
  "        ELSE.",
  "          rv_xml = rv_xml &&",
  "            |<{ iv_name }>| &&",
  "            <ref> &&",
  "            |</{ iv_name }>|.",
  "        ENDIF.",
].join("\n");
const PATCH2 = [
  "        IF lo_type->type_kind = cl_abap_typedescr=>typekind_string AND <ref> IS INITIAL.",
  "          rv_xml = rv_xml && |<{ iv_name }/>|.",
  "        ELSEIF lo_type->type_kind = cl_abap_typedescr=>typekind_string",
  "            OR lo_type->type_kind = cl_abap_typedescr=>typekind_char.",
  MARKER2 + ": a character value is",
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
].join("\n");

// 3. asXML line feeds: the parser strips every literal LF from the document
//    before it reads it (cl_ixml, `REPLACE ALL OCCURRENCES OF |\n| IN lv_xml
//    WITH ||`), so a string with a line break came back as one line. Written
//    as the character reference and resolved on the way back, it survives - a
//    system keeps the LF of a text area across the draft
const MARKER3A = "* abap2UI5 patch 3a (node/setup/patch-open-abap-core.mjs)";
const ANCHOR3A = "          REPLACE ALL OCCURRENCES OF '>' IN lv_escaped WITH '&gt;'.\n";
const PATCH3A = [
  ANCHOR3A.trimEnd(),
  MARKER3A + ": a line feed as the",
  "* character reference the parser resolves - it drops a literal one",
  "          REPLACE ALL OCCURRENCES OF cl_abap_char_utilities=>newline IN lv_escaped WITH '&#10;'.",
  "",
].join("\n");

const MARKER3B = "* abap2UI5 patch 3b (node/setup/patch-open-abap-core.mjs)";
const ANCHOR3B = "    REPLACE ALL OCCURRENCES OF '&apos;' IN rv_value WITH |'|.\n";
const PATCH3B = [
  ANCHOR3B.trimEnd(),
  MARKER3B + ": the decimal character",
  "* reference of a line feed, the one form of it that reaches the parser",
  "    REPLACE ALL OCCURRENCES OF '&#10;' IN rv_value WITH cl_abap_char_utilities=>newline.",
  "",
].join("\n");

// 4. asXML entity order on the way back: unescape_value resolves `&amp;`
//    FIRST, so an escaped value that itself carries an escaped value (an
//    S-RTTI payload with `&lt;` inside, written as `&amp;lt;`) is resolved
//    twice and comes back as markup - the inner document then loses its text
//    to the tags. A parser resolves each reference once; `&amp;` has to be
//    the last replacement
const MARKER4A = "* abap2UI5 patch 4a (node/setup/patch-open-abap-core.mjs)";
const ANCHOR4A = [
  "    REPLACE ALL OCCURRENCES OF '&amp;' IN rv_value WITH '&'.",
  "    REPLACE ALL OCCURRENCES OF '&lt;' IN rv_value WITH '<'.",
  "",
].join("\n");
const PATCH4A = [
  MARKER4A + ": `&amp;` is resolved LAST,",
  "* below - first, it turned `&amp;lt;` into `<`",
  "    REPLACE ALL OCCURRENCES OF '&lt;' IN rv_value WITH '<'.",
  "",
].join("\n");

const MARKER4B = "* abap2UI5 patch 4b (node/setup/patch-open-abap-core.mjs)";
const ANCHOR4B = "    REPLACE ALL OCCURRENCES OF '&#10;' IN rv_value WITH cl_abap_char_utilities=>newline.\n";
const PATCH4B = [
  ANCHOR4B.trimEnd(),
  MARKER4B,
  "    REPLACE ALL OCCURRENCES OF '&amp;' IN rv_value WITH '&'.",
  "",
].join("\n");

/* One entry per FILE, edits in application order. Grouping by file is what
 * lets 3a anchor on the line patch 2 inserts and 4b on the one 3b inserts:
 * the text is carried in memory and written once at the end of the group. */
export const FILES = [
  {
    file: TRANSFORMATION,
    edits: [
      { label: "asXML text escape", applied: MARKER2, anchor: ANCHOR2, patch: PATCH2 },
      { label: "asXML line feed out", applied: MARKER3A, anchor: ANCHOR3A, patch: PATCH3A },
    ],
  },
  {
    file: IXML,
    edits: [
      { label: "asXML line feed in", applied: MARKER3B, anchor: ANCHOR3B, patch: PATCH3B },
      { label: "asXML entity order (remove)", applied: MARKER4A, anchor: ANCHOR4A, patch: PATCH4A },
      { label: "asXML entity order (append)", applied: MARKER4B, anchor: ANCHOR4B, patch: PATCH4B },
    ],
  },
];

try {
  for (const group of FILES) {
    reportEdits("patch-open-abap-core", group.file, patchFile({
      file: group.file,
      edits: group.edits,
      missingFile: (file) => `patch-open-abap-core: ${file} not found - run npm run deps first`,
      missingAnchor: (edit) =>
        `patch-open-abap-core: ${edit.label} - anchor not found, `
        + "the pinned open-abap-core changed, review the patch",
    }));
  }
} catch (e) {
  if (!(e instanceof PatchError)) throw e;
  console.error(e.message);
  process.exit(1);
}
