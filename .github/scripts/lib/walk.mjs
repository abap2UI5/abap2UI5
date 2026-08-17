/*
 * walk — every file under a directory, as repository-relative paths.
 *
 * Four gates had written this out themselves, and two of them
 * (abapgit-format-gate, extended-check-gate) were byte-identical. The other
 * two differed only in what they let through the `else` branch, which is a
 * filter over the result rather than a different traversal — so all four were
 * one function wearing four hats.
 *
 * Paths come back relative to `root` and joined with "/" rather than the
 * platform separator, because that is what every caller compares against:
 * the exclusion lists are written as `src/99/`, and a backslash there would
 * match nothing on Windows while matching everything the author expected on
 * Linux.
 */
import { readdirSync } from "node:fs";
import { join } from "node:path";

/**
 * @param {string} root  absolute path the returned paths are relative to
 * @param {string} dir   repository-relative directory to descend into
 * @returns {string[]}   every file below `dir`, as `dir/...` paths
 */
export function walk(root, dir, out = []) {
  // withFileTypes rather than a statSync per entry: readdir already knows,
  // and asking again is a syscall per file across a tree this size.
  for (const entry of readdirSync(join(root, dir), { withFileTypes: true })) {
    const rel = `${dir}/${entry.name}`;
    if (entry.isDirectory()) walk(root, rel, out);
    else out.push(rel);
  }
  return out;
}

/** The file name of a repository-relative path. */
export const baseName = (rel) => rel.slice(rel.lastIndexOf("/") + 1);

/** The directory of a repository-relative path. */
export const dirName = (rel) => rel.slice(0, rel.lastIndexOf("/"));
