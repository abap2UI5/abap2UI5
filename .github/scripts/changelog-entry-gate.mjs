#!/usr/bin/env node
/*
 * changelog-entry-gate — a pull request that touches the public contract
 * carries a changelog entry.
 *
 * The pull-request template asks for "a line under `unreleased` when this
 * changes behaviour", and nothing checked it: the hash_* / app_state_*
 * client API families (PR #2693) shipped a whole new public surface with no
 * changelog line at all, and the template checkbox was ticked anyway.
 *
 * Deciding "changes behaviour" mechanically is not possible, but the sharpest
 * subset is: a diff that touches `src/02/**` (the public API - AGENTS.md
 * rule 5) or `.github/api-snapshot.json` (which only changes when that API
 * does) is a user-visible change by definition. For those, this gate requires
 * that `changelog.txt` gained at least one line under the standing
 * `unreleased` heading relative to the pull request's base.
 *
 * CI-only, on purpose: it needs a diff base, which the working tree does not
 * have - which is why it sits in run-gates.mjs's NOT_A_VERIFY_GATE rather
 * than in the local `npm run gates` set. check_gates.yaml runs it with
 * BASE_REF=origin/<base_ref> on pull requests only.
 *
 * Run: BASE_REF=origin/main node .github/scripts/changelog-entry-gate.mjs
 *      node .github/scripts/changelog-entry-gate.mjs origin/main
 */
import { execFileSync } from "node:child_process";
import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { join } from "path";

const ROOT = fileURLToPath(new URL("../../", import.meta.url));
const base = process.env.BASE_REF || process.argv[2];
if (!base) {
  console.error("changelog-entry-gate: no base ref - set BASE_REF or pass it as the first argument");
  process.exit(1);
}

const git = (...args) => execFileSync("git", args, { cwd: ROOT, encoding: "utf8" });

/* The three-dot form: what the PR adds relative to the merge base, not what
 * the base branch gained since - the same range the frozen-path gate reads. */
const changed = git("diff", "--name-only", `${base}...HEAD`).split("\n").filter(Boolean);

const needsEntry = changed.filter(
  (p) => p === ".github/api-snapshot.json" || p.startsWith("src/02/"),
);
if (needsEntry.length === 0) {
  console.log("changelog-entry-gate: the diff does not touch src/02/** or the api snapshot - no entry required");
  process.exit(0);
}

/* The entry lines under the `unreleased` heading: everything between it and
 * the next release heading, blank lines dropped. */
const unreleasedLines = (text) => {
  const lines = text.split("\n");
  const at = lines.findIndex(
    (l, i) => /^unreleased\s*$/.test(l) && /^-{5,}\s*$/.test(lines[i + 1] ?? ""),
  );
  if (at === -1) return null;
  const out = [];
  for (let i = at + 2; i < lines.length; i++) {
    if (/^\d{4}-\d{2}-\d{2} v\d+\.\d+\.\d+\s*$/.test(lines[i])) break;
    const t = lines[i].trim();
    if (t) out.push(t);
  }
  return out;
};

let baseSection = [];
try {
  baseSection = unreleasedLines(git("show", `${base}:changelog.txt`)) ?? [];
} catch {
  /* no changelog at the base - every current entry counts as new */
}
const headSection = unreleasedLines(readFileSync(join(ROOT, "changelog.txt"), "utf8"));

if (headSection === null) {
  console.error("changelog-entry-gate: changelog.txt has no `unreleased` heading (changelog-gate reports the details)");
  process.exit(1);
}

const baseSet = new Set(baseSection);
const gained = headSection.filter((l) => !baseSet.has(l));

if (gained.length === 0) {
  console.error("changelog-entry-gate: this pull request changes the public contract and says nothing about it.\n");
  console.error("  It touches:");
  for (const p of needsEntry) console.error(`    ${p}`);
  console.error("\n  A change to src/02/** or .github/api-snapshot.json is user-visible by");
  console.error("  definition - add a line under the `unreleased` heading in changelog.txt");
  console.error("  (legend: + added, ! changed, * fixed, - removed). The release cut");
  console.error("  publishes that section as the release notes, so what is not written");
  console.error("  there is what nobody is told changed.");
  process.exit(1);
}

console.log(`changelog-entry-gate: ${needsEntry.length} contract file(s) changed, ${gained.length} new unreleased entr(y/ies) - OK`);
