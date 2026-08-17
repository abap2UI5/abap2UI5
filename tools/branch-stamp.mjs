#!/usr/bin/env node
// branch-stamp.mjs
// The provenance of a delivery branch: the core commit it was built from, and
// the framework version that goes with it - in the README banner and in
// VERSION.
//
// Why this is a step of its own and not part of the build: since build/ lives
// in the repository, the tree of a branch is COMMITTED before the commit it is
// meant to name exists. A stamp in the built tree would therefore be either
// impossible (its own commit) or always one commit old.
//
// So build-branches.mjs builds the content - deterministic, without a commit,
// without a timestamp, which is why it can be checked in at all - and this
// script stamps immediately before the push:
//
//     node tools/branch-stamp.mjs <dir> <branch> [sha]
//
// <dir> is the finished tree (build/<branch> or tools/out/<branch>), <sha> the
// core commit; without the argument GITHUB_SHA, otherwise HEAD. If no commit
// can be determined, the provenance line is left out instead of being wrong.
//
// What a pulled repository sees does not change through this: README and
// VERSION carry the same text as before, it just comes into being one step
// later. Deliberately no timestamp - identical sources have to produce
// identical trees, otherwise frontend_deploy.yaml pushes an empty rebuild on
// every run.

import { execFileSync } from "node:child_process";
import { readFileSync, writeFileSync } from "node:fs";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const here = dirname(fileURLToPath(import.meta.url));
const core = join(here, "..");

// First line of every generated README. build-branches.mjs writes it without
// the provenance line, this script replaces it with the same line including it.
export const BANNER_PREFIX = "> ⚙️ **Generated branch";

export function banner(branch, { sha = null, version = null } = {}) {
  const origin = sha
    ? ` Frontend state: \`abap2UI5/abap2UI5@${sha.slice(0, 12)}\`${version ? ` (framework ${version})` : ""} — see \`VERSION\`.`
    : "";
  return `${BANNER_PREFIX} \`${branch}\`** — built in ` +
    "[abap2UI5/abap2UI5](https://github.com/abap2UI5/abap2UI5) by its `frontend_deploy` workflow " +
    "and pushed here. Do not commit in this repository; changes belong into abap2UI5." + origin + "\n";
}

// The stamp still calls the commit "webapp mirror commit" and the banner still
// calls it the frontend state: it is the same value the old mirror commits
// carried, so nothing changes that anyone compares against.
export function versionStamp({ sha = null, version = null } = {}) {
  return [
    "Generated abap2UI5-frontend branch — provenance",
    `webapp mirror commit: ${sha ? `abap2UI5/abap2UI5@${sha}` : "unknown"}`,
    version ? `abap2UI5 framework version: ${version}` : null,
  ].filter(Boolean).join("\n") + "\n";
}

export function coreSha(explicit = null) {
  const given = explicit ?? process.env.GITHUB_SHA ?? "";
  if (/^[0-9a-f]{40}$/.test(given)) return given;
  try {
    return execFileSync("git", ["rev-parse", "HEAD"], { cwd: core, encoding: "utf8" }).trim() || null;
  } catch {
    // A shallow or detached checkout has none - then the provenance line is
    // left out instead of naming a wrong commit.
    return null;
  }
}

export function coreVersion() {
  try {
    const source = readFileSync(join(core, "src/02/z2ui5_if_app.intf.abap"), "utf8");
    return /CONSTANTS\s+version\s+TYPE\s+string\s+VALUE\s+`([^`]+)`/i.exec(source)?.[1] ?? null;
  } catch {
    return null;
  }
}

// Replace the README banner and write VERSION. The tree otherwise stays as it
// was built.
export function stamp(dir, branch, sha = null) {
  const provenance = { sha: coreSha(sha), version: coreVersion() };
  const readme = join(dir, "README.md");
  const lines = readFileSync(readme, "utf8").split("\n");
  // The line MUST be found: a silent failure would deliver a branch without a
  // provenance line, and nobody would notice.
  if (!lines[0].startsWith(BANNER_PREFIX)) {
    throw new Error(`${readme}: first line is not the generated banner`);
  }
  lines[0] = banner(branch, provenance).trimEnd();
  writeFileSync(readme, lines.join("\n"));
  writeFileSync(join(dir, "VERSION"), versionStamp(provenance));
  return provenance;
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  const [dir, branch, sha] = process.argv.slice(2);
  if (!dir || !branch) {
    console.error("Aufruf: node tools/branch-stamp.mjs <dir> <branch> [sha]");
    process.exit(1);
  }
  const { sha: used, version } = stamp(dir, branch, sha);
  console.log(`${branch}: stamped ${used ? used.slice(0, 12) : "(no commit)"}${version ? ` (framework ${version})` : ""}`);
}
