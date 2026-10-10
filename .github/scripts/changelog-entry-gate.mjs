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
 * The second half: no pull request may LOSE an `unreleased` line. Twice
 * a squash merge resolved a conflict in changelog.txt by dropping the lines
 * the previous pull request had just added - #2853 replaced the six of
 * #2852 with its own, #2877 the two of #2875 and #2876 - and nothing
 * noticed until the release cut was being prepared. So a hunk that removes
 * more `unreleased` entry lines than it adds fails, naming every removed
 * line that is nowhere in the new changelog.txt. A reword (one out, one in)
 * passes, and so does the release cut, which moves the lines under a
 * version heading - they are still in the file. A deliberate removal (a
 * change reverted before its release) says so with a commit trailer
 * `Changelog-Removed: <why>` in the pull request.
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

const ENTRY = /^[+!*-] \S/;

/* The `unreleased` entry lines a diff removes without replacing them: per
 * hunk, the entry lines removed from the BASE's section (old line numbers)
 * against the entry lines the hunk adds; a hunk that removes more than it
 * adds reports its removed lines that `headText` no longer carries anywhere.
 * Pure, so the self-test below runs it on the two diffs that lost lines. */
export function lostLines(diffText, baseRange, headText) {
  if (!baseRange) return [];
  const present = new Set(headText.split("\n"));
  const lost = [];
  let oldLine = 0;
  let removed = [];
  let added = 0;
  const close = () => {
    if (removed.length > added) lost.push(...removed.filter((l) => !present.has(l)));
    removed = [];
    added = 0;
  };
  for (const line of diffText.split("\n")) {
    const hunk = line.match(/^@@ -(\d+)(?:,\d+)? \+\d+(?:,\d+)? @@/);
    if (hunk) {
      close();
      oldLine = Number(hunk[1]);
      continue;
    }
    if (line.startsWith("-") && !line.startsWith("---")) {
      const text = line.slice(1);
      if (oldLine >= baseRange.from && oldLine <= baseRange.to && ENTRY.test(text.trim())) removed.push(text);
      oldLine += 1;
    } else if (line.startsWith("+") && !line.startsWith("+++") && ENTRY.test(line.slice(1).trim())) {
      added += 1;
    }
  }
  close();
  return lost;
}

const SELF_TEST = [
  // #2877: the two lines of #2875/#2876 replaced by one new line
  ["@@ -15,2 +15 @@\n-+ a\n-+ b\n++ c", "+ c", ["+ a", "+ b"]],
  // a reword: one out, one in
  ["@@ -15 +15 @@\n-! x 2.14.2\n+! x 2.14.3", "! x 2.14.3", []],
  // the release cut that shows the lines as moved: still in the file
  ["@@ -15,2 +15 @@\n-+ a\n-+ b\n+\n@@ -20,0 +20,2 @@\n++ a\n++ b", "2026-10-11 v1.0.0\n+ a\n+ b", []],
  // a removal outside the base's `unreleased` section is not this gate's
  ["@@ -99 +98,0 @@\n-+ old", "", []],
];
for (const [diffText, head, expected] of SELF_TEST) {
  const got = lostLines(diffText, { from: 15, to: 30 }, head);
  if (JSON.stringify(got) !== JSON.stringify(expected)) {
    console.error(`changelog-entry-gate: the gate's own self-test failed\n  ${JSON.stringify(diffText)}`);
    console.error(`  expected: ${JSON.stringify(expected)}\n  got:      ${JSON.stringify(got)}`);
    process.exit(1);
  }
}

const headText = readFileSync(join(ROOT, "changelog.txt"), "utf8");
const range = unreleasedRange(headText);
if (range === null) {
  console.error("changelog-entry-gate: changelog.txt has no `unreleased` heading (changelog-gate reports the details)");
  process.exit(1);
}

const diff = git("diff", "--unified=0", `${base}...HEAD`, "--", "changelog.txt");

const mergeBase = git("merge-base", base, "HEAD").trim();
let baseText = "";
try {
  baseText = git("show", `${mergeBase}:changelog.txt`);
} catch { /* no changelog at the base - nothing to lose */ }
const lost = lostLines(diff, unreleasedRange(baseText), headText);
const trailer = /^Changelog-Removed:\s*\S/m.test(git("log", "--format=%B", `${mergeBase}..HEAD`));
if (lost.length && !trailer) {
  console.error("changelog-entry-gate: this pull request drops lines from the `unreleased` section.\n");
  for (const l of lost) console.error(`    ${l.length > 150 ? `${l.slice(0, 150)}...` : l}`);
  console.error("\n  They are in the base's changelog.txt and nowhere in this one - the shape a");
  console.error("  conflict resolution leaves behind (#2853, #2877 each lost the lines of the");
  console.error("  pull request merged just before). Put them back next to your own line. A");
  console.error("  deliberate removal - a change reverted before its release - says so with a");
  console.error("  commit trailer `Changelog-Removed: <why>`.");
  process.exit(1);
}
if (lost.length) console.log(`changelog-entry-gate: ${lost.length} unreleased line(s) removed, accepted by a Changelog-Removed trailer`);

const needsEntry = changed.filter(
  (p) => p === ".github/api-snapshot.json" || p.startsWith("src/02/"),
);
if (needsEntry.length === 0) {
  console.log("changelog-entry-gate: no unreleased line lost; the diff does not touch src/02/** or the api snapshot - no entry required");
  process.exit(0);
}

/* What counts is what THIS diff ADDED under the heading, not how the section
 * differs from the base as a set: the set difference also grows when a pull
 * request merely rewords an entry that was already there, which is how a
 * contract change once passed with nothing new written down. So read the diff
 * itself (zero context, so line numbers map exactly), and count entry lines
 * per hunk NET of the entry lines the same hunk removed - a reword is one
 * removed and one added and nets to zero, a new entry nets to one. */
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
