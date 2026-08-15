// Gate: every Z2UI5 object name written in PROSE - the changelog, AGENTS.md,
// docs/, the skill catalogues, the README - names an object this repository
// actually ships.
//
// Why this exists as a gate: dynamic-name-gate does this for string literals in
// ABAP, for a reason that applies just as well one directory over. A rename
// sweep updates the code, because the code is what fails when it does not; the
// prose around it is updated by hand, and prose has no compiler.
//
// That is exactly how it stood: the `ui5` segment rename moved
// z2ui5_cl_core_srv_draft to z2ui5_cl_ui5_srv_draft, z2ui5_cl_app_startup to
// z2ui5_cl_ui5_app_start, z2ui5_cl_core_app to z2ui5_cl_ui5_app_cont - and the
// changelog still named all three, including in the not-yet-released section
// describing that very change. AGENTS.md named two classes under names that
// have not existed since. A reader looking any of them up finds nothing and has
// no way to tell whether the class was renamed, removed, or never existed.
//
// AGENTS.md states the principle this implements: prose is a request, a gate is
// a guarantee. Prose that names the code is code enough to check.

import { readdirSync, readFileSync, existsSync } from "fs";
import { join } from "path";

const ROOT = new URL("../../", import.meta.url).pathname;

// Where prose lives. Not src/ - that is dynamic-name-gate's job and it reads
// ABAP, not markdown.
const PROSE = [
  { dir: ".", depth: 0, ext: [".md", ".txt"] },
  { dir: "docs", depth: 9, ext: [".md"] },
  { dir: ".claude", depth: 9, ext: [".md"] },
  { dir: ".github", depth: 9, ext: [".md"] },
];

// A changelog is a record of the past, and an entry naming what a class was
// called in 2025 is right, not stale. Only the `unreleased` block describes
// what is shipping NOW - which is exactly where the stale names sat: the entry
// announcing the ui5 rename named three of the renamed classes by their old
// names. So the file is read to the first released heading and no further.
const CHANGELOG = "changelog.txt";
const RELEASED_HEADING = /^\d{4}-\d{2}-\d{2}\s+v\d/;

// Names that are meant to be absent: they belong to other repositories, or they
// are what a passage is explaining the absence OF. Each needs its reason, so an
// entry cannot become a silent hole.
const EXTERNAL = new Map([
  ["Z2UI5_CL_APP_ICF_CONFIG", "ships in abap2UI5/abap2UI5-icf-config"],
  ["Z2UI5_CL_CC_DEMO_OUT", "sample custom control of the samples repository"],
  ["Z2UI5_CL_SMP_APP_000", "the samples repository's overview app"],
  ["Z2UI5_CL_SMPC_APP_OVERVIEW", "the samples-controls overview app"],
  ["Z2UI5_CL_SMPS_APP_00", "the samples-stack overview app"],
  ["Z2UI5_CL_MY_CLASS", "placeholder in an AGENTS.md example"],
  ["Z2UI5_CL_MY_APP", "placeholder in an example"],
]);

// Whole families that live in the sample repositories. The removal plan counts
// their callers by name, which is the point of the plan - those names are not
// this repository's to ship.
const EXTERNAL_PATTERNS = [
  { re: /^Z2UI5_CL_(DEMO|SMP|SMPC|SMPS)_APP_/, why: "app classes of the sample repositories" },
];

// Names that no longer exist and are named ON PURPOSE, because the passage is
// about the rename itself. Each needs the file it may appear in, so recording
// one cannot quietly excuse the same stale name somewhere it IS wrong.
const HISTORICAL = new Map([
  ["Z2UI5_IF_CORE_TYPES", "AGENTS.md"],
  ["Z2UI5_CL_EXIT", "AGENTS.md"],
  ["Z2UI5_CL_A2UI5_HTTP", "AGENTS.md"],
  ["Z2UI5_CL_APP_STARTUP", "AGENTS.md"],
  ["Z2UI5_CL_APP_HELLO_WORLD", "AGENTS.md"],
  ["Z2UI5_CL_POPUP_CONTEXT", "AGENTS.md"],
  ["Z2UI5_CL_APP", "AGENTS.md"],
  ["Z2UI5_IF_ACTION", "docs/removal-plan.md"],
  // the removal plan records that this popup class was dropped in 1.142.0
  // without a replacement, as the reason not to repeat that for the other 17
  ["Z2UI5_CL_POP_BAL", "docs/removal-plan.md"],
]);

// Same idea, per file: the abap-check catalogue is a list of defects that
// shipped, so it names the objects as they were named when they broke - the
// file whose missing final newline is the evidence, and both halves of the
// #2564 rename, the old class name and the interface name the sweep invented.
const HISTORICAL_IN = new Map([
  [".claude/skills/abap-check/SKILL.md", new Set(["Z2UI5_IF_ACTION", "Z2UI5_CL_EXIT", "Z2UI5_IF_USER_EXIT"])],
]);

// A trailing underscore or a `*` after it means a PREFIX is being discussed
// (`z2ui5_cl_ui5_*`, the naming scheme itself), not an object - and a prefix
// names no object by design.
const NAME = /\bZ2UI5_(?:CL|CX|IF)_[A-Z0-9_]+\*?/gi;
const isPrefix = (raw) => raw.endsWith("_") || raw.endsWith("*");

function walk(dir, depth, ext, out = []) {
  const abs = join(ROOT, dir);
  if (!existsSync(abs)) return out;
  for (const entry of readdirSync(abs, { withFileTypes: true })) {
    if (entry.name === "node_modules" || entry.name === "build") continue;
    const rel = dir === "." ? entry.name : `${dir}/${entry.name}`;
    if (entry.isDirectory()) {
      if (depth > 0) walk(rel, depth - 1, ext, out);
    } else if (ext.some((e) => entry.name.endsWith(e))) {
      out.push(rel);
    }
  }
  return out;
}

// what the repository ships, by file name - abapGit derives the object name
// from it, so the file name IS the object name (same rule dynamic-name-gate
// uses)
const shipped = new Set();
(function collect(dir) {
  for (const entry of readdirSync(join(ROOT, dir), { withFileTypes: true })) {
    const rel = `${dir}/${entry.name}`;
    if (entry.isDirectory()) collect(rel);
    else {
      const m = entry.name.match(/^(z2ui5_[a-z0-9_]+)\.(clas|intf)\.abap$/);
      if (m) shipped.add(m[1].toUpperCase());
    }
  }
})("src");

const files = PROSE.flatMap(({ dir, depth, ext }) => walk(dir, depth, ext));

const findings = [];
for (const file of files) {
  let lines = readFileSync(join(ROOT, file), "utf8").split("\n");
  if (file === CHANGELOG) {
    const released = lines.findIndex((l) => RELEASED_HEADING.test(l));
    if (released > -1) lines = lines.slice(0, released);
  }
  lines.forEach((line, index) => {
    for (const raw of line.match(NAME) ?? []) {
      if (isPrefix(raw)) continue;
      const name = raw.toUpperCase();
      if (shipped.has(name) || EXTERNAL.has(name)) continue;
      if (EXTERNAL_PATTERNS.some((p) => p.re.test(name))) continue;
      if (HISTORICAL.get(name) === file) continue;
      if (HISTORICAL_IN.get(file)?.has(name)) continue;
      findings.push({ file, line: index + 1, name: raw });
    }
  });
}

if (findings.length > 0) {
  console.log("Prose naming an object this repository does not ship:");
  console.log("");
  for (const f of findings) console.log(`  ${f.file}:${f.line}  ${f.name}`);
  console.log("");
  console.log("A reader who looks one of these up finds nothing, and cannot tell whether");
  console.log("the object was renamed, removed, or never existed. Correct the name, or -");
  console.log("if it genuinely belongs to another repository - add it to EXTERNAL in this");
  console.log("file with the reason.");
  process.exit(1);
}

const external = EXTERNAL.size === 1 ? "1 external name" : `${EXTERNAL.size} external names`;
console.log(
  `prose-name: ${files.length} file(s) checked, every name resolves - OK (${external} allowed)`,
);
