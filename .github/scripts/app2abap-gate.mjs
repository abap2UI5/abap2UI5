// Gate: `npm run app2abap` changed only what it is supposed to change.
//
// app2abap regenerates the frontend carriers (src/01/03) from app/webapp and
// then runs the repository's autoformatter over src/. The check used to be
//
//   npm run app2abap && git diff --exit-code -- src/01/03 app/webapp
//
// - it looked at the two paths the GENERATOR writes and at nothing else. The
// autoformatter is not scoped to those two paths, so anything it rewrote
// elsewhere was invisible here.
//
// That is not hypothetical. `auto_abaplint`'s `in_statement_indentation` and
// abap2ui5lint's `chain-house-layout` disagreed about the closing `)->end( )`
// of a view chain in src/01/04. `npm run verify` runs check:abap2ui5 BEFORE
// check:app2abap, so the run reported green, rewrote the file afterwards, and
// left the working tree carrying a change that the very same verify would
// reject on its next run. Two formatters fighting over one line, and every
// gate silent about it.
//
// So the question this asks is not "does src/01/03 match its source" but
// "did this command touch anything at all". Measured as a BEFORE/AFTER
// comparison rather than against git HEAD: a developer with unrelated work in
// progress must still be able to run `npm run verify`, and CI's tree is clean
// either way.
//
// Run: node .github/scripts/app2abap-gate.mjs   (npm run check:app2abap)

import { execFileSync } from "child_process";

const git = (...args) => execFileSync("git", args, { encoding: "utf8" });

/** Every path git considers modified, staged, or untracked, with its status.
 *
 * A rename is TWO NUL-separated fields in -z output ("R  <new>\0<old>"), so the
 * fields cannot simply be mapped one by one: the second one carries no status
 * byte and slicing three characters off it invents a path ("/99/x.abap" out of
 * "src/99/x.abap"), which the content hash below then reports as `gone` and git
 * prints a `fatal:` line for. Consume the source path with the entry it belongs
 * to instead - it is the pre-rename name, not a state of its own. */
const treeState = () => {
  const fields = git("status", "--porcelain", "-z").split("\0").filter(Boolean);
  const out = new Map();
  for (let i = 0; i < fields.length; i++) {
    const status = fields[i].slice(0, 2);
    out.set(fields[i].slice(3), status);
    if (/[RC]/.test(status)) i++; // skip the source path of a rename/copy
  }
  return out;
};

/* The content too, not just the path list: a file already modified before the
 * run can be modified FURTHER by it, and a path-only comparison would call
 * that unchanged. */
const contentOf = (paths) => {
  const out = new Map();
  for (const path of paths) {
    try {
      out.set(path, execFileSync("git", ["hash-object", "--", path], { encoding: "utf8" }).trim());
    } catch {
      out.set(path, "gone");
    }
  }
  return out;
};

const before = treeState();
const beforeContent = contentOf(before.keys());

execFileSync("npm", ["run", "app2abap"], { stdio: "inherit" });

const after = treeState();
const afterContent = contentOf(after.keys());

const touched = [];
for (const [path, status] of after) {
  if (!before.has(path)) { touched.push([path, `now ${status.trim()}`]); continue; }
  if (afterContent.get(path) !== beforeContent.get(path)) touched.push([path, "content changed"]);
}
for (const path of before.keys()) {
  if (!after.has(path)) touched.push([path, "no longer differs from HEAD"]);
}

if (touched.length) {
  console.error("check:app2abap: `npm run app2abap` changed the working tree.\n");
  for (const [path, what] of touched) console.error(`  ${path}  (${what})`);
  console.error(
    "\nEither the generated carriers are out of date - then commit what the"
    + "\ncommand just produced - or a formatter is rewriting a file somebody"
    + "\nelse's gate formats differently. The second kind is the one worth"
    + "\nchasing: see .github/abaplint/auto_abaplint_fix.jsonc, where the view"
    + "\nchain layout already needs three rules excluded for that reason.",
  );
  process.exit(1);
}

console.log(`check:app2abap: app2abap changed nothing (${before.size} pre-existing change(s) left alone)`);
