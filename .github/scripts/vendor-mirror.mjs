#!/usr/bin/env node
// vendor-mirror - copies ajson (src/00/01) and S-RTTI (src/00/02) from the
// mirror repositories of abap-util into this repository, under this
// repository's names.
//
//   node .github/scripts/vendor-mirror.mjs <mirror-ajson> <mirror-srtti>
//   node .github/scripts/vendor-mirror.mjs <mirror-ajson> <mirror-srtti> --check
//
// The arguments are checkouts of abap-util/mirror-ajson and
// abap-util/mirror-srtti. Both mirrors rename their upstream project to
// abap-util's prefix (zabaputil_cl_ajson, zabaputil_cl_srt_typedescr) and
// apply their local patches; abap-util vendors them as they are. This
// repository takes only the objects it uses and renames each one to a name
// of its own - with the `ui5` segment every object outside src/02 carries
// (object-naming-gate.mjs), and at most 25 characters, so that the namespace
// rename (.github/abaplint/rename.jsonc) still fits the 30 of ABAP.
//
// The names are a table, not a pattern: `zabaputil_` -> `z2ui5_..._ui5_`
// would make z2ui5_cl_ui5_srt_complexdescr, 29 characters. Every object of a
// mirror has to be in the table or in DROPPED - an object upstream adds fails
// the run until somebody decides which of the two it is. A reference to a
// dropped object in a kept file fails it too: no `zabaputil_` may survive the
// copy.
//
// --check writes nothing and fails when src/00/01 or src/00/02 differ from
// what the mirrors give - the copy is never edited by hand (AGENTS.md rule 1).

import { readdirSync, readFileSync, writeFileSync, rmSync, existsSync } from "node:fs";
import { join } from "node:path";
import { fileURLToPath } from "node:url";

const ROOT = fileURLToPath(new URL("../../", import.meta.url));
const MAX_NAME = 25;

const MIRRORS = [
  {
    repo: "abap-util/mirror-ajson",
    target: "src/00/01",
    names: {
      zabaputil_cl_ajson: "z2ui5_cl_ui5_ajson",
      zabaputil_if_ajson: "z2ui5_if_ui5_ajson",
      zabaputil_if_ajson_types: "z2ui5_if_ui5_ajson_types",
      zabaputil_if_ajson_filter: "z2ui5_if_ui5_ajson_filter",
      zabaputil_if_ajson_mapping: "z2ui5_if_ui5_ajson_map",
      zabaputil_if_ajson_refinit: "z2ui5_if_ui5_ajson_rinit",
      // only ajson's own unit tests call it, and those run here as well
      zabaputil_cl_ajson_refinitlib: "z2ui5_cl_ui5_ajson_rilib",
      zabaputil_cx_ajson_error: "z2ui5_cx_ui5_ajson_error",
    },
    // nothing in this repository calls them since _bind( ) lost
    // custom_mapper and custom_filter (2026-11-28); the framework's upper-case
    // mapping is z2ui5_cl_ui5_util_json_fl, its omit_initial filters are local
    // classes of z2ui5_cl_ui5_client
    dropped: [
      "zabaputil_cl_ajson_mapping",
      "zabaputil_cl_ajson_filter_lib",
      "zabaputil_cl_ajson_utilities",
      "zabaputil_if_ajson_iterator",
    ],
  },
  {
    repo: "abap-util/mirror-srtti",
    target: "src/00/02",
    // `descr` goes: srt already says what the classes describe
    names: {
      zabaputil_cl_srt_typedescr: "z2ui5_cl_ui5_srt_type",
      zabaputil_cl_srt_datadescr: "z2ui5_cl_ui5_srt_data",
      zabaputil_cl_srt_elemdescr: "z2ui5_cl_ui5_srt_elem",
      zabaputil_cl_srt_complexdescr: "z2ui5_cl_ui5_srt_complex",
      zabaputil_cl_srt_structdescr: "z2ui5_cl_ui5_srt_struct",
      zabaputil_cl_srt_tabledescr: "z2ui5_cl_ui5_srt_table",
      zabaputil_cl_srt_refdescr: "z2ui5_cl_ui5_srt_ref",
      zabaputil_cl_srt_objectdescr: "z2ui5_cl_ui5_srt_object",
      zabaputil_cl_srt_classdescr: "z2ui5_cl_ui5_srt_class",
      zabaputil_cl_srt_intfdescr: "z2ui5_cl_ui5_srt_intf",
      zabaputil_cl_srt_aunit: "z2ui5_cl_ui5_srt_aunit",
      zabaputil_cx_srt: "z2ui5_cx_ui5_srt",
    },
    dropped: [],
  },
];

const args = process.argv.slice(2);
const check = args.includes("--check");
const sources = args.filter((a) => a !== "--check");
if (sources.length !== MIRRORS.length) {
  console.error("usage: vendor-mirror.mjs <mirror-ajson checkout> <mirror-srtti checkout> [--check]");
  process.exit(2);
}

const problems = [];

for (const [name, renamed] of MIRRORS.flatMap((m) => Object.entries(m.names))) {
  if (renamed.length > MAX_NAME) problems.push(`${renamed}: ${renamed.length} characters, at most ${MAX_NAME}`);
  if (!/^z2ui5_(cl|if|cx)_ui5_/.test(renamed)) problems.push(`${renamed}: not on the ui5 segment (for ${name})`);
}

// every renamed name of both mirrors, longest first: \b does not stop at `_`,
// so zabaputil_cl_ajson never matches inside zabaputil_cl_ajson_mapping anyway
const table = Object.fromEntries(MIRRORS.flatMap((m) => Object.entries(m.names)));
const pattern = new RegExp(
  `\\b(${Object.keys(table).sort((a, b) => b.length - a.length).join("|")})\\b`,
  "gi",
);
const rename = (text) =>
  text.replace(pattern, (hit) => {
    const to = table[hit.toLowerCase()];
    return hit === hit.toUpperCase() ? to.toUpperCase() : to;
  });

const objectOf = (file) => file.split(".")[0].toLowerCase();
const output = []; // { target, files: Map<name, content> }

MIRRORS.forEach((mirror, i) => {
  const src = join(sources[i], "src");
  if (!existsSync(src)) {
    problems.push(`${sources[i]}: no src/ - is it a checkout of ${mirror.repo}?`);
    return;
  }
  const files = readdirSync(src).filter((f) => f.toLowerCase().startsWith("zabaputil_"));
  const objects = new Set(files.map(objectOf));
  for (const o of objects) {
    if (!mirror.names[o] && !mirror.dropped.includes(o)) {
      problems.push(`${mirror.repo}: ${o} is new - add it to names or dropped in vendor-mirror.mjs`);
    }
  }
  for (const o of [...Object.keys(mirror.names), ...mirror.dropped]) {
    if (!objects.has(o)) problems.push(`${mirror.repo}: ${o} is listed here but not in the mirror any more`);
  }
  const out = new Map();
  for (const f of files) {
    const o = objectOf(f);
    if (!mirror.names[o]) continue;
    const content = rename(readFileSync(join(src, f), "utf8"));
    const left = content.match(/zabaputil_\w+/i);
    if (left) problems.push(`${f}: still names ${left[0]} - a dropped object, or one missing from names`);
    out.set(mirror.names[o] + f.slice(o.length), content);
  }
  output.push({ target: mirror.target, files: out });
});

if (problems.length) {
  for (const p of problems) console.error(`vendor-mirror: ${p}`);
  process.exit(1);
}

let drift = 0;
for (const { target, files } of output) {
  const dir = join(ROOT, target);
  const present = readdirSync(dir).filter((f) => f.startsWith("z"));
  if (check) {
    for (const f of present) {
      if (!files.has(f)) { console.error(`${target}/${f}: not in the mirror`); drift++; }
    }
    for (const [f, content] of files) {
      if (!present.includes(f)) { console.error(`${target}/${f}: missing`); drift++; }
      else if (readFileSync(join(dir, f), "utf8") !== content) { console.error(`${target}/${f}: differs from the mirror`); drift++; }
    }
    continue;
  }
  for (const f of present) rmSync(join(dir, f));
  for (const [f, content] of files) writeFileSync(join(dir, f), content);
  console.log(`vendor-mirror: ${target} - ${files.size} files`);
}

if (check) {
  if (drift) {
    console.error(`vendor-mirror: ${drift} difference(s) - run the script without --check and commit, never edit src/00/01 or src/00/02 by hand`);
    process.exit(1);
  }
  console.log("vendor-mirror: src/00/01 and src/00/02 match the mirrors");
}
