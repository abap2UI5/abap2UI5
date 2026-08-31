// Gate: a release is ready before it is tagged.
//
// A release here is three numbers and a changelog section, edited by hand in
// three files at three different moments:
//
//   package.json                        what the toolchain reads
//   src/02/z2ui5_if_app.intf.abap       what abapGit shows in a system, and
//                                       what frontend_deploy stamps
//   changelog.txt                       what a reader gets told changed
//
// `check:version` already holds the first two together. Nothing held the third
// to either, so a version could be bumped and tagged with every entry still
// sitting under `unreleased` - and the GitHub release then has nothing to say
// about itself. The reverse happens too: a changelog section written for a
// version the repository never bumped to.
//
// Run: node .github/scripts/release-gate.mjs           (checks the bump)
//      node .github/scripts/release-gate.mjs --tag v?  (also: this tag)
//
// The --tag form is what the release workflow runs, so the tag, the two
// version numbers and the changelog all have to name the same release before
// anything is published. Everything it checks is decided from the files, so it
// runs anywhere, including locally before pushing a tag.

import { fileURLToPath } from "url";
import { readFileSync } from "fs";
import { join } from "path";

const ROOT = fileURLToPath(new URL("../../", import.meta.url));
const CHANGELOG = "changelog.txt";
const INTERFACE = "src/02/z2ui5_if_app.intf.abap";

const argTag = (() => {
  const i = process.argv.indexOf("--tag");
  return i === -1 ? null : (process.argv[i + 1] || "").replace(/^v/, "");
})();

const problems = [];

const pkg = JSON.parse(readFileSync(join(ROOT, "package.json"), "utf8")).version;
const abap = readFileSync(join(ROOT, INTERFACE), "utf8")
  .match(/CONSTANTS\s+version\s+TYPE\s+string\s+VALUE\s+`([^`]+)`/i)?.[1] ?? null;
const changelog = readFileSync(join(ROOT, CHANGELOG), "utf8");

/* Section headings are `YYYY-MM-DD vX.Y.Z` over a rule of hyphens. The rule is
 * what separates a heading from a line of prose that happens to start with a
 * date. */
const sections = [...changelog.matchAll(/^(\d{4}-\d{2}-\d{2}) v(\d+\.\d+\.\d+)\s*\n-{5,}\s*$/gm)]
  .map((m) => ({ date: m[1], version: m[2] }));
const released = new Set(sections.map((s) => s.version));

// `check:version` owns this comparison; repeated because a release must not be
// cut on a tree where it is broken, and this script may run on its own.
if (abap && pkg !== abap) {
  problems.push(`package.json says ${pkg}, ${INTERFACE} says ${abap} - run npm run check:version`);
}

if (!released.has(pkg)) {
  problems.push(
    `${CHANGELOG} has no section for ${pkg}.\n`
    + `      The entries for it are still under \`unreleased\`. Give them a heading:\n`
    + `\n        <YYYY-MM-DD> v${pkg}\n        ${"-".repeat(19)}\n`,
  );
}

/* A section for a version ahead of the bump is the same mistake seen from the
 * other side, and it is the one that produces an empty release. */
for (const { version } of sections) {
  if (compare(version, pkg) > 0) {
    problems.push(`${CHANGELOG} has a section for ${version}, but the repository is at ${pkg}`);
  }
}

if (argTag !== null) {
  if (!/^\d+\.\d+\.\d+$/.test(argTag)) {
    problems.push(`the tag ${argTag} is not X.Y.Z - the 702 variant is tagged X.Y.Z-702 by the release job`);
  } else if (argTag !== pkg) {
    problems.push(`the tag says ${argTag}, package.json says ${pkg}`);
  }
}

function compare(a, b) {
  const x = a.split(".").map(Number);
  const y = b.split(".").map(Number);
  for (let i = 0; i < 3; i++) if (x[i] !== y[i]) return x[i] - y[i];
  return 0;
}

if (problems.length) {
  console.error(`This tree is not ready to be released as ${pkg}:\n`);
  for (const p of problems) console.error(`  - ${p}`);
  console.error("\nA release that cannot say what changed is worse than a late one.");
  process.exit(1);
}

console.log(
  `release gate: ${pkg} is bumped in package.json and ${INTERFACE}, and ${CHANGELOG} has its section`
  + (argTag !== null ? ` (tag ${argTag} agrees)` : ""),
);
