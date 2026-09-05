// Gate: the blank-owner draft tolerance carries its removal condition as a
// deadline a build can miss, not only as prose.
//
// z2ui5_cl_ui5_srv_draft binds every draft to the user that created it
// (UNAME on Z2UI5_T_01, fail-closed). Four paths deliberately tolerate a
// BLANK owner - rows written before the column existed - so no active
// session breaks on upgrade. That is a fail-open branch inside a fail-closed
// security control, and its own comment says what nothing enforced until
// this gate existed: "Nothing enforces the date; this note is what keeps it
// findable".
//
// Three of the four are reads; the fourth is the WRITE side, the blank-owner
// half of create( )'s INSERT-collision guard. It was outside this gate until
// 2026-09, and that is exactly the failure mode this gate exists for: a
// branch the gate does not name is a tolerance that outlives its own
// deadline with the build green - and the one that would have outlived it is
// the branch deciding whether one user may OVERWRITE another user's row.
//
// The deal this gate encodes: up to and including the grace version the
// tolerance MUST still be there (if the markers vanish or move, the gate has
// to learn the new anchors rather than pass silently on a grep that matches
// nothing). From the first release AFTER the grace version the tolerance
// MUST be gone - by then every installation that upgraded through a
// supported release has cycled its drafts (they expire in hours) and a blank
// owner can only mean a row the control should refuse.

import { fileURLToPath } from "url";
import { readFileSync } from "fs";
import { join } from "path";

const ROOT = fileURLToPath(new URL("../../", import.meta.url));

const SOURCE = "src/01/01/z2ui5_cl_ui5_srv_draft.clas.abap";

// the last version that still ships the tolerance. Chosen a handful of
// releases past 1.144.0 (current at the time this gate was written): drafts
// expire within hours, so a single upgrade cycle drains the legacy rows -
// the buffer is for installations that skip releases.
const GRACE_UNTIL = [1, 149];

// the four tolerated blank-owner branches: the reads in read( ),
// check_exists( ) and count_entries( ), and the write-side collision guard
// in create( ) - one anchor each, spelled exactly as the source does
const MARKERS = [
  "result-uname IS NOT INITIAL AND result-uname <> sy-uname",
  "ls_row-uname IS INITIAL OR ls_row-uname = sy-uname",
  "uname = @sy-uname OR uname = @space",
  "lv_owner IS NOT INITIAL AND lv_owner <> sy-uname",
];

const version = JSON.parse(readFileSync(join(ROOT, "package.json"), "utf8")).version;
const [major, minor] = version.split(".").map(Number);
const pastGrace =
  major > GRACE_UNTIL[0] || (major === GRACE_UNTIL[0] && minor > GRACE_UNTIL[1]);

const abap = readFileSync(join(ROOT, SOURCE), "utf8");
const present = MARKERS.filter((m) => abap.includes(m));

if (!pastGrace) {
  if (present.length !== MARKERS.length) {
    console.log(`draft-owner: only ${present.length} of ${MARKERS.length} blank-owner markers found in ${SOURCE}`);
    console.log("");
    console.log("The tolerated blank-owner branches moved or were rewritten. If they were");
    console.log("removed on purpose ahead of schedule: delete this gate's grace half and");
    console.log("keep the past-grace half. Otherwise teach MARKERS the new spelling -");
    console.log("a marker that matches nothing would let the deadline pass silently.");
    process.exit(1);
  }
  console.log(`draft-owner: blank-owner tolerance present, grace runs until v${GRACE_UNTIL.join(".")}.x (now ${version}) - OK`);
} else {
  if (present.length > 0) {
    console.log(`draft-owner: v${version} is past the grace version ${GRACE_UNTIL.join(".")}.x and ${SOURCE} still tolerates blank-owner drafts:`);
    console.log("");
    for (const m of present) console.log(`  ${m}`);
    console.log("");
    console.log("Every supported installation has cycled its drafts by now (they expire in");
    console.log("hours), so a blank owner can only be a row the owner binding should refuse.");
    console.log("Remove all four tolerances (read/check_exists/count_entries + the collision");
    console.log("guard in create( ) + the comment block naming this removal condition), then");
    console.log("delete this gate.");
    process.exit(1);
  }
  console.log(`draft-owner: tolerance removed and past grace - this gate can be deleted`);
}
