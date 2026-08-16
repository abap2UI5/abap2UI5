// What still stands between this repository and the removals in
// docs/removal-plan.md.
//
// Why a script: every blocker in that plan is a count of callers in ANOTHER
// repository, and every one of them was measured by hand. A hand-measured
// count is right on the day it is written and silently wrong afterwards - the
// plan said "samples: 336 of 343 classes use z2ui5_cl_xml_view, 0 use the
// successor" while samples had been fully migrated and the real number was 0.
// A maintainer reading that would conclude the migration had not started.
//
// This cannot be a CI gate: the sibling repositories are not checked out here,
// and adding them would make this repository depend on four others to run its
// own checks. It is a command you point at your checkouts before touching the
// plan, so re-measuring is one line instead of an afternoon.
//
//   node .github/scripts/removal-blockers.mjs ../samples ../samples-controls ../samples-stack ../app-template
//
// With no arguments it looks for the four siblings next to this repository.
// Counts are FILES containing the name, over *.abap under each repo's src/,
// which is the same thing the plan's numbers mean.

import { existsSync, readdirSync, readFileSync, statSync } from "fs";
import { join, resolve } from "path";

/* Each entry is a line of docs/removal-plan.md. `successor` is not a blocker -
 * it is there so a zero can be read as "migrated" rather than "not scanned". */
const NAMES = [
  { name: "z2ui5_cl_xml_view", note: "§2 blocker A - the legacy view builder" },
  { name: "z2ui5_cl_ui5_view_builder", note: "the successor (not a blocker - a control number)", successor: true },
  { name: "factory_plain", note: "§2 - obsolete inside the obsolete builder" },
  { name: "_bind_edit", note: "§1 - alias of _bind" },
  { name: "nest_view_model_update", note: "§1 - no-op" },
  { name: "nest2_view_model_update", note: "§1 - no-op" },
  { name: "cs_event-nav_container_to", note: "§1 - remapped onto control_by_id" },
  { name: "cs_event-wizard_set_next_step", note: "§1 - two control_by_id calls do the same" },
  { name: "custom_mapper", note: "§1 - hands app code a type from the AJSON mirror" },
  { name: "custom_filter", note: "§1 - same" },
  { name: "check_sticky", note: "§1 - mirror of z2ui5_cl_ui5_app_cont" },
  { name: "check_initialized", note: "§1 - same" },
];

const DEFAULTS = ["../samples", "../samples-controls", "../samples-stack", "../app-template"];
const repos = (process.argv.slice(2).length ? process.argv.slice(2) : DEFAULTS)
  .map((p) => resolve(p))
  .filter((p) => {
    if (existsSync(join(p, "src"))) return true;
    console.error(`skipping ${p} - no src/ there`);
    return false;
  });

if (!repos.length) {
  console.error("no repositories to scan. Pass the checkouts as arguments.");
  process.exit(2);
}

const walk = (dir, out = []) => {
  for (const entry of readdirSync(dir)) {
    const full = join(dir, entry);
    if (statSync(full).isDirectory()) walk(full, out);
    else if (full.endsWith(".abap")) out.push(full);
  }
  return out;
};

const sources = new Map(repos.map((r) => [r, walk(join(r, "src")).map((f) => readFileSync(f, "utf8").toLowerCase())]));

const label = (p) => p.split("/").pop();
const width = Math.max(...NAMES.map((n) => n.name.length));
console.log(`${"name".padEnd(width)}  ${repos.map((r) => label(r).padStart(17)).join("")}   total`);

let blockers = 0;
for (const { name, note, successor } of NAMES) {
  const needle = name.toLowerCase();
  const counts = repos.map((r) => sources.get(r).filter((s) => s.includes(needle)).length);
  const total = counts.reduce((a, b) => a + b, 0);
  if (!successor && total) blockers++;
  console.log(
    `${name.padEnd(width)}  ${counts.map((c) => String(c).padStart(17)).join("")}   ${String(total).padStart(5)}`
    + (successor || !total ? "" : `   <- ${note}`),
  );
}

console.log(
  `\n${blockers} of ${NAMES.filter((n) => !n.successor).length} names still have callers in the scanned repositories.`,
);
console.log("docs/ is NOT scanned - it is a separate repository and its own blocker.");
