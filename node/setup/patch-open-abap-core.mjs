// Pre-transpile patches for the pinned open-abap-core checkout under
// node/deps, applied before `abap_transpile` reads it (npm run auto_transpile).
// All of them are temporary shims for gaps filed upstream in backlog/items/
// (open-abap/open-abap-core); each goes away the moment the pinned SHA
// carries the fix - see "Removing it" below. It is idempotent (marker
// comment) and FAILS when the line it anchors on moves upstream.
//
// ONE patch is left and its number is 3. The numbering has holes because a
// shim is DELETED when upstream ships the fix, and the numbers of the rest
// stay as they are - the backlog item cites them by number, and renumbering a
// shim to close a gap in the counting is how a reference goes stale:
//
//   1. GONE - cl_abap_typedescr=>describe_by_name did not resolve an absolute
//      type name; open-abap/open-abap-core#1217 merged it (0800491).
//   2. GONE - `CALL TRANSFORMATION id` wrote character data UNESCAPED, so the
//      S-RTTI payload of a draft came back cut at its first `<`;
//      open-abap/open-abap-core#1193 merged it (c4bb873, the SHA this
//      repository now pins) as lcl_data_to_xml=>escape_text - which escapes
//      `&`, `<` and `>` in EVERY elementary value, where the shim covered only
//      the character-like ones.
//   4. GONE - lcl_escape=>unescape_value resolved `&amp;` FIRST, so an escaped
//      value that itself carried an escaped value (`&amp;lt;`) was resolved
//      twice and its markup read as elements; the same PR moved `&amp;` to the
//      end of the replacements.
//
// 3. The asXML roundtrip LOSES A LINE FEED
//    (backlog/items/open-abap-asxml-line-feed.md)
//
// The parser strips every literal LF from the document before it tokenizes it
// (cl_ixml, `REPLACE ALL OCCURRENCES OF |\n| IN lv_xml WITH ||`), so a string
// with a line break comes back as one line and a text area loses its breaks
// across the draft. 3a writes a LF as the character reference `&#10;` in
// upstream's escape_text, 3b lets lcl_escape=>unescape_value resolve that
// reference again. A system keeps the LF; so does the transpiled backend with
// the two in place.
//
// Removing it: bump the open-abap-core pin in node/setup/fetch-deps.mjs to a
// SHA that keeps a LF across the roundtrip, then delete this file together
// with its entry in `auto_transpile` in package.json and close the backlog
// item.
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

// 3a. the write side: a LF leaves as `&#10;`. Anchored on the tail of
//     upstream's escape_text - OUTSIDE its `IF rv_value CA '&<>'` guard,
//     because a value whose only special character is the line break does not
//     enter that branch
const MARKER3A = "* abap2UI5 patch 3a (node/setup/patch-open-abap-core.mjs)";
const ANCHOR3A = [
  "      REPLACE ALL OCCURRENCES OF '>' IN rv_value WITH '&gt;'.",
  "    ENDIF.",
].join("\n");
const PATCH3A = [
  ANCHOR3A,
  MARKER3A + ": a line feed as the",
  "* character reference the parser resolves - it drops a literal one",
  "    REPLACE ALL OCCURRENCES OF cl_abap_char_utilities=>newline IN rv_value WITH '&#10;'.",
].join("\n");

// 3b. the read side: resolve that reference again. It goes BEFORE upstream's
//     `&amp;` replacement, which stays last for the reason patch 4 was written
const MARKER3B = "* abap2UI5 patch 3b (node/setup/patch-open-abap-core.mjs)";
const ANCHOR3B = "    REPLACE ALL OCCURRENCES OF '&apos;' IN rv_value WITH |'|.\n";
const PATCH3B = [
  ANCHOR3B.trimEnd(),
  MARKER3B + ": the decimal character",
  "* reference of a line feed, the one form of it that reaches the parser",
  "    REPLACE ALL OCCURRENCES OF '&#10;' IN rv_value WITH cl_abap_char_utilities=>newline.",
  "",
].join("\n");

/* One entry per FILE, edits in application order. */
export const FILES = [
  {
    file: TRANSFORMATION,
    edits: [
      { label: "asXML line feed out", applied: MARKER3A, anchor: ANCHOR3A, patch: PATCH3A },
    ],
  },
  {
    file: IXML,
    edits: [
      { label: "asXML line feed in", applied: MARKER3B, anchor: ANCHOR3B, patch: PATCH3B },
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
