/*
 * ecosystem-map — the reader of `.github/ecosystem.json`, shared by the three
 * scripts that act on it:
 *
 *   ecosystem-map.mjs       the shape check (npm run check:ecosystem), and
 *                           with --live whether every pin still holds
 *   ecosystem-canary.mjs    one consumer linted against this repository's main
 *                           (ecosystem-canary.yaml)
 *   release-ecosystem.mjs   the ecosystem release, dry-run by default
 *
 * The map is data, so the three cannot disagree about which repositories
 * exist, how each pins the framework or which ones are released with it.
 */
import { execFileSync } from "node:child_process";
import { readFileSync } from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

export const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..", "..", "..");
export const MAP_FILE = path.join(ROOT, ".github", "ecosystem.json");

export function loadMap(file = MAP_FILE) {
  return JSON.parse(readFileSync(file, "utf8"));
}

/* abaplint configs are JSON with comments and trailing commas. A character
 * walk rather than a regex, so a `//` inside a string ("https://...") stays a
 * string - the addons' rename.mjs reader itself, from its source here, rather
 * than a copy of it: the copy looped forever on an unclosed block comment
 * (indexOf -1, plus 1, back to the start) after the original was fixed. */
export { parseJsonc } from "../../shared/rename.mjs";

/* "https://github.com/abap2UI5/abap2UI5.git/" -> "abap2ui5/abap2ui5".
 * Lower case: GitHub names are case-insensitive, and the configs spell them
 * every way (abap2ui5-ext, abap2UI5-ext). */
export const repoKey = (url) =>
  String(url ?? "")
    .replace(/^.*github\.com[/:]/i, "")
    .replace(/\.git$/i, "")
    .replace(/\/+$/, "")
    .toLowerCase();

/* The names a repository answers to: its own and the ones it had. */
export const namesOf = (entry) => [entry.repo, ...(entry.formerly ?? [])].map((n) => n.toLowerCase());

/* The dependency entries of an abaplint config that point at `repo`. */
export function abaplintDeps(config, repo) {
  const want = repo.toLowerCase();
  return (config.dependencies ?? []).filter((d) => d.url && repoKey(d.url) === want);
}

/* A 702 pin is the downport of the framework, not its main line: the canary
 * leaves it alone and the release script reads it as the -702 tag. */
export const is702 = (ref) => /(^|-)702$/.test(String(ref ?? ""));

/* `git ls-remote`, which needs no token and answers for every public
 * repository - the one network call all three scripts can rely on. */
export function lsRemote(repo, ...patterns) {
  const out = execFileSync("git", ["ls-remote", `https://github.com/${repo}`, ...patterns], {
    encoding: "utf8",
    stdio: ["ignore", "pipe", "pipe"],
    timeout: 30_000,
  });
  return out
    .split("\n")
    .filter(Boolean)
    .map((line) => {
      const [sha, ref] = line.split("\t");
      return { sha, ref };
    });
}

/* The branch names of a repository. `--heads` has to precede the URL - after
 * it, git reads it as a pattern and matches nothing. */
export function headsOf(repo) {
  const out = execFileSync("git", ["ls-remote", "--heads", `https://github.com/${repo}`], {
    encoding: "utf8",
    stdio: ["ignore", "pipe", "pipe"],
    timeout: 30_000,
  });
  return new Set(out.split("\n").filter(Boolean).map((l) => l.split("\t")[1].replace("refs/heads/", "")));
}

export function defaultBranchOf(repo) {
  const out = execFileSync("git", ["ls-remote", "--symref", `https://github.com/${repo}`, "HEAD"], {
    encoding: "utf8",
    stdio: ["ignore", "pipe", "pipe"],
    timeout: 30_000,
  });
  const m = out.match(/^ref: refs\/heads\/(\S+)\s+HEAD/m);
  return m ? m[1] : null;
}
