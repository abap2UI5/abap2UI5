// anchored-patch - the read / check / anchor / replace / write routine the
// three pre-build patch scripts in node/setup share.
//
// All three do the same thing to a file this repository does not own: find a
// verbatim ANCHOR in an installed dependency, put a patched version of it in
// place, and stay re-runnable, because each of them runs on every
// `npm run downport` / `auto_transpile` / `unit` / `express`. Three copies of
// one routine had grown three different answers to the same four questions:
//
//   what "already patched" means   the patched text itself, or a marker comment
//   what a missing anchor does     throw, or console.error + exit(1)
//   when the file is written       once at the end, or once per edit
//   how the file is read           read-and-catch, or existsSync-then-read -
//                                  a check-then-use the file can change between
//                                  (CodeQL js/file-system-race). Two of the
//                                  three carried a comment saying so and the
//                                  third did the race.
//
// So the routine lives here once and each script is its EDIT TABLE plus the
// two messages only it can write: what a missing FILE means (`npm install`,
// `npm ci`, `npm run deps`) and what a missing ANCHOR means - the dependency
// moved, or it SHIPPED the fix, which is the signal to delete the shim.
import { readFileSync, writeFileSync } from "node:fs";

/* Both failure modes carry a message the caller composed; the caller decides
 * whether that is a throw (an exported function somebody imports) or a line on
 * stderr and exit 1 (a script npm runs). */
export class PatchError extends Error {}

/**
 * Apply `edits` to one `file`, in order, and write it once.
 *
 * An edit is `{ label, anchor, patch, applied }`. `applied` is the text whose
 * presence proves the edit is already in place - a marker comment for a patch
 * that inserts one, and by default the patched text itself. Edits are applied
 * to the text carried in memory, so a later edit may anchor on what an
 * earlier one inserted (open-abap's line-feed patches do).
 *
 * @param {object}   spec
 * @param {string}   spec.file           path of the file to patch
 * @param {Array}    spec.edits          the edit table, in application order
 * @param {Function} spec.missingFile    (file) => message, for ENOENT
 * @param {Function} spec.missingAnchor  (edit, file) => message
 * @returns {{label: string, status: "applied"|"already"}[]} in edit order
 * @throws {PatchError} with exactly the message the caller composed
 */
export function patchFile({ file, edits, missingFile, missingAnchor }) {
  // The read reports a missing file itself - an existsSync ahead of it is a
  // check-then-use the file can change between, and says nothing the ENOENT
  // does not.
  let source;
  try {
    source = readFileSync(file, "utf8");
  } catch (e) {
    if (e.code === "ENOENT") throw new PatchError(missingFile(file));
    throw e;
  }

  const results = [];
  let changed = false;
  for (const edit of edits) {
    if (source.includes(edit.applied ?? edit.patch)) {
      results.push({ label: edit.label, status: "already" });
      continue;
    }
    if (!source.includes(edit.anchor)) throw new PatchError(missingAnchor(edit, file));
    source = source.replace(edit.anchor, () => edit.patch); // a `$&` in the patch is text
    results.push({ label: edit.label, status: "applied" });
    changed = true;
  }
  if (changed) writeFileSync(file, source);
  return results;
}

/* The per-edit report two of the three scripts print. The third sums its
 * edits up in one line instead and prints that itself. */
export function reportEdits(prefix, file, results) {
  for (const r of results) {
    console.log(r.status === "already"
      ? `${prefix}: ${r.label} already applied`
      : `${prefix}: ${r.label} applied to ${file}`);
  }
}
