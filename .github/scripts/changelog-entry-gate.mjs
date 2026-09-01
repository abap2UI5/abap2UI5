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
 * that the pull request's own diff ADDED at least one entry line under the
 * standing `unreleased` heading. Added, not merely different: the first cut
 * compared the section against the base as a set of lines, and that also
 * "gains" a line when a pull request rewords an unrelated entry that was
 * already there - so a contract change could ride through on somebody
 * else's edit without writing anything down.
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

/* The line range of the `unreleased` section at HEAD: from below the heading
 * to the next release heading. 1-based, so it can be compared against the
 * new-file line numbers a diff hunk carries. */
const unreleasedRange = (text) => {
  const lines = text.split("\n");
  const at = lines.findIndex(
    (l, i) => /^unreleased\s*$/.test(l) && /^-{5,}\s*$/.test(lines[i + 1] ?? ""),
  );
  if (at === -1) return null;
  let end = lines.length;
  for (let i = at + 2; i < lines.length; i++) {
    if (/^\d{4}-\d{2}-\d{2} v\d+\.\d+\.\d+\s*$/.test(lines[i])) { end = i; break; }
  }
  return { from: at + 3, to: end }; // 1-based, first line after the hyphen rule
};

const range = unreleasedRange(readFileSync(join(ROOT, "changelog.txt"), "utf8"));
if (range === null) {
  console.error("changelog-entry-gate: changelog.txt has no `unreleased` heading (changelog-gate reports the details)");
  process.exit(1);
}

/* What counts is what THIS diff ADDED under the heading, not how the section
 * differs from the base as a set: the set difference also grows when a pull
 * request merely rewords an entry that was already there, which is how a
 * contract change once passed with nothing new written down. So read the diff
 * itself (zero context, so line numbers map exactly), and count entry lines
 * per hunk NET of the entry lines the same hunk removed - a reword is one
 * removed and one added and nets to zero, a new entry nets to one. */
const ENTRY = /^[+!*-] \S/;
const diff = git("diff", "--unified=0", `${base}...HEAD`, "--", "changelog.txt");

let gained = 0;
let newLine = 0;
let inUnreleased = false;
let hunkNet = 0;
const closeHunk = () => { gained += Math.max(0, hunkNet); hunkNet = 0; };
for (const line of diff.split("\n")) {
  const hunk = line.match(/^@@ -\d+(?:,\d+)? \+(\d+)(?:,(\d+))? @@/);
  if (hunk) {
    closeHunk();
    newLine = Number(hunk[1]);
    const count = hunk[2] === undefined ? 1 : Number(hunk[2]);
    const first = count === 0 ? newLine + 1 : newLine; // +N,0 means "after line N"
    inUnreleased = first <= range.to && first + Math.max(count, 1) - 1 >= range.from;
    continue;
  }
  if (!inUnreleased) continue;
  if (line.startsWith("+")) {
    if (newLine >= range.from && newLine <= range.to && ENTRY.test(line.slice(1).trim())) hunkNet += 1;
    newLine += 1;
  } else if (line.startsWith("-") && ENTRY.test(line.slice(1).trim())) {
    hunkNet -= 1;
  }
}
closeHunk();

if (gained === 0) {
  console.error("changelog-entry-gate: this pull request changes the public contract and says nothing about it.\n");
  console.error("  It touches:");
  for (const p of needsEntry) console.error(`    ${p}`);
  console.error("\n  A change to src/02/** or .github/api-snapshot.json is user-visible by");
  console.error("  definition - add a line under the `unreleased` heading in changelog.txt");
  console.error("  (legend: + added, ! changed, * fixed, - removed). Rewording an entry that");
  console.error("  is already there does not count - the diff has to ADD one. The release cut");
  console.error("  publishes that section as the release notes, so what is not written");
  console.error("  there is what nobody is told changed.");
  process.exit(1);
}

console.log(`changelog-entry-gate: ${needsEntry.length} contract file(s) changed, ${gained} unreleased entry line(s) added - OK`);
