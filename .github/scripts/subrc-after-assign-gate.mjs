// Gate: `sy-subrc` after a plain dynamic `ASSIGN`.
//
// On some releases a SUCCESSFUL `ASSIGN` does not reset `sy-subrc`, so a test
// on it reads FALSE for an assignment that worked and TRUE for one that did
// not. `IS [NOT] ASSIGNED` is the check that holds on all of them. The
// framework calls it #1937 and the reasoning, the three fix shapes and the
// upstream rule request are written out once in
// backlog/items/abaplint-subrc-after-assign.md.
//
// Why a gate here rather than only that item: the item asks abaplint for the
// rule, and until it lands nothing stops a NEW one. Forty of them were found
// and repaired across abap2UI5, samples, samples-controls and samples-stack
// (2026-09-16) - nine loop-carried, where a stale `sy-subrc` does not skip a
// value but writes the PREVIOUS iteration's under the current one's name. Not
// one was found by a person reading the code; they were found by the
// detector next to the backlog item, which is what this gate runs.
//
// It runs THAT detector rather than a copy: it already draws the line this
// gate needs (`ASSIGN COMPONENT ... OF STRUCTURE` is the negative - there
// `sy-subrc` IS the documented check, and "fixing" it is how a wrong-branch
// bug becomes a silently-taken one), and two implementations of that line
// would eventually disagree. When abaplint ships the rule, the item and this
// gate go together.
//
// Scope: the packages this repository may change. src/00/01 (AJSON) and
// src/00/02 (S-RTTI) are upstream mirrors and src/99 is frozen history - the
// sixteen sites left there are counted by the backlog item and are nobody's
// to repair here.
//
// Run:  npm run check:subrc

import { fileURLToPath } from "url";
import { run } from "../../backlog/items/abaplint-subrc-after-assign.probe.mjs";

const ROOT = fileURLToPath(new URL("../../", import.meta.url));

const FROZEN = [/^src\/99\//, /^src\/00\/01\//, /^src\/00\/02\//];

const { sites } = run([{ repo: "abap2UI5", dir: ROOT }]);
const ours = sites.filter(s => !FROZEN.some(re => re.test(s.file)));

if (ours.length > 0) {
  console.log("sy-subrc after a dynamic ASSIGN (#1937): these read a flag the assign may not have set.");
  console.log("");
  for (const s of ours) console.log(`  ${s.file}:${s.line}\n      ${s.text}`);
  console.log("");
  console.log("Use `IS [NOT] ASSIGNED`. A site marked [in-loop] or [reassigned] needs");
  console.log("`UNASSIGN <fs>.` BEFORE the assign as well - a failed assign leaves the");
  console.log("previous binding in place, so IS ASSIGNED reads TRUE for the failure.");
  console.log("");
  console.log("Background and the three fix shapes: backlog/items/abaplint-subrc-after-assign.md");
  process.exit(1);
}

console.log(`check:subrc: ${sites.length - ours.length} site(s) in the frozen and mirrored packages, 0 in this repository's own - OK`);
