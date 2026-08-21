/*
 * Guard for the frozen legacy package src/99 (see AGENTS.md, "Layered Design").
 *
 * The production code of src/99 is frozen: it ships solely so existing
 * downstream installations keep compiling on upgrade, and none of it may
 * change here. The *.testclasses.abap files and the abapGit .clas.xml
 * sidecars are exempt - they run in CI and must follow the core internals
 * they assert on.
 *
 * Two things are allowed to make an object leave the package, and both
 * follow from what the freeze is for - an installation that upgrades from
 * the last release must keep compiling:
 *
 *   relocation   the same object still ships from another package under
 *                src/. abapGit installs the repository, not the folder, so
 *                nothing downstream notices.
 *   never shipped  the object is absent from the latest release tag, so it
 *                has never reached an installation in the first place.
 *
 * The same reasoning lets an object move the OTHER way, INTO the package: it
 * shipped from another package before and ships from src/99 now, so no
 * installation loses anything, and whatever the change did to it was done
 * while it was not yet frozen. That is how an object retires - z2ui5_if_types
 * went this way once the public API stopped naming its types.
 *
 * Anything edited in place is refused either way.
 *
 * Used by `npm run check:frozen` and by the check_gates workflow, so
 * the local run and CI decide the same way. Base and head default to
 * origin/main...HEAD and are overridden by BASE_SHA / HEAD_SHA.
 */
import { execFileSync } from "node:child_process";

const git = (...args) =>
  execFileSync("git", args, { encoding: "utf8" })
    .split("\n")
    .map((l) => l.trim())
    .filter(Boolean);

const EXEMPT = [
  ":(exclude)src/99/*.testclasses.abap",
  ":(exclude)src/99/*.clas.xml",
];

const head = process.env.HEAD_SHA || "HEAD";
let base = process.env.BASE_SHA;
if (!base) {
  try {
    execFileSync("git", ["fetch", "origin", "main", "--quiet"]);
  } catch {
    /* offline: fall through and use whatever origin/main is on disk */
  }
  base = "origin/main";
}
const range = process.env.BASE_SHA ? [base, head] : [`${base}...${head}`];

// Touched - added, modified or renamed within the package. Refused unless the
// file ARRIVED here (see below). (-d, lowercase, excludes deletions.)
const touched = git("diff", "--name-only", "--diff-filter=d", ...range, "--", "src/99", ...EXEMPT);

// Gone from src/99. Allowed only as a relocation or as a never-shipped object.
const deleted = git("diff", "--name-only", "--diff-filter=D", ...range, "--", "src/99", ...EXEMPT);

// One listing of the post-change tree; the object name IS the file name.
const tree = git("ls-tree", "-r", "--name-only", head, "--", "src");

// The tree as it was BEFORE the change, to tell an object that arrived in the
// package from one that was edited inside it.
const baseRef = process.env.BASE_SHA || git("merge-base", base, head)[0];
const before = git("ls-tree", "-r", "--name-only", baseRef, "--", "src");

// The latest release tag (plain x.y.z - the -702 downport tags carry the same
// objects) and the tree it shipped. No tag reachable (a shallow clone without
// tags) means the never-shipped test simply never fires.
const release = git("tag", "--list", "--sort=-v:refname").find((t) =>
  /^[0-9]+\.[0-9]+\.[0-9]+$/.test(t),
);
const shipped = release ? git("ls-tree", "-r", "--name-only", release, "--", "src") : [];

const basename = (f) => f.slice(f.lastIndexOf("/") + 1);
const has = (list, f) => list.some((p) => basename(p) === basename(f));
const outside99 = (list, f) =>
  list.find((p) => basename(p) === basename(f) && !p.startsWith("src/99/"));

// An object that shipped from another package before and sits here now moved
// IN. It was not frozen while it was changed, and it still ships - so nothing
// downstream notices, which is the whole test this gate applies.
const edited = [];
for (const f of touched) {
  const from = outside99(before, f);
  if (from) {
    console.log(`relocated into the package: ${from} -> ${f}`);
  } else {
    edited.push(f);
  }
}

const dropped = [];
for (const f of deleted) {
  if (has(tree, f)) {
    console.log(`relocated, still ships: ${f} -> ${tree.find((p) => basename(p) === basename(f))}`);
  } else if (release && !has(shipped, f)) {
    console.log(`never shipped (absent from ${release}), nothing to break: ${f}`);
  } else {
    dropped.push(f);
  }
}

if (edited.length || dropped.length) {
  console.error("FAIL: src/99 production code is frozen (AGENTS.md rule 1):");
  if (edited.length) {
    console.error("  changed in place - revert:");
    edited.forEach((f) => console.error(`    ${f}`));
  }
  if (dropped.length) {
    console.error("  deleted, and the object ships nowhere else - downstream stops compiling:");
    dropped.forEach((f) => console.error(`    ${f}`));
  }
  console.error("");
  console.error("src/99 is kept only so downstream apps keep compiling.");
  console.error("Moving an object to another package is fine; dropping a released one is not.");
  console.error("Test classes and .clas.xml sidecars are exempt. See AGENTS.md, 'Layered Design'.");
  process.exit(1);
}

console.log("src/99 frozen code intact.");
