#!/usr/bin/env node
/*
 * ecosystem-map — `.github/ecosystem.json` is well-formed, and (with --live)
 * still true.
 *
 * The map is the one place that says which repositories make up the
 * ecosystem, what each publishes, whether it is released with the core version
 * and how it pins what it depends on. Before it existed that knowledge was a
 * shell script with a hard-coded list (the release), a dozen abaplint configs
 * nobody read side by side, and the memory of whoever cut the last release.
 * Two programs act on it - the nightly canary and the ecosystem release - so a
 * malformed entry is a failed night or a wrong tag, and this gate is what
 * stops one from reaching main.
 *
 *   node .github/scripts/ecosystem-map.mjs          (npm run check:ecosystem)
 *        offline: the shape of every entry, and the core's own entry against
 *        this working tree (its pins are files here, so they can be compared
 *        without a network)
 *   node .github/scripts/ecosystem-map.mjs --live   (npm run check:ecosystem -- --live)
 *        additionally asks GitHub and npm: every default branch and published
 *        branch exists, every pin the map names still stands in the file it
 *        names with the value the map records, and the ref it names exists
 *        (a branch or tag by `git ls-remote`, a commit by the GitHub API -
 *        GITHUB_TOKEN / GH_TOKEN raise the rate limit, nothing needs one).
 *        It also lists, as "behind" and never as a finding, every npm pin
 *        on a package of the family (@abap2ui5/*, @cap2ui5/*) that the
 *        package's newest release does not satisfy.
 *
 * --live is NOT part of `npm run gates`: it reads forty repositories over the
 * network, and a pin that moved over there is news about that repository, not
 * a reason to fail a pull request here. A live finding means the map is stale
 * - correct the entry. An unreachable host is a note, never a finding (the
 * convention lib-ecosystem.mjs states for every cross-repository read).
 */
import { existsSync, readFileSync } from "node:fs";
import path from "node:path";
import {
  ROOT, MAP_FILE, loadMap, parseJsonc, abaplintDeps, lsRemote, headsOf, defaultBranchOf,
} from "./lib/ecosystem-map.mjs";

const LIVE = process.argv.includes("--live");
const RELEASE_MODES = ["core", "with-core", "own", "none"];
const STATUSES = ["active", "retired"];
const SHA = /^[0-9a-f]{40}$/;
const REPO = /^[A-Za-z0-9_.-]+\/[A-Za-z0-9_.-]+$/;

const problems = [];
const notes = [];
const behind = [];
let pinsChecked = 0;
const bad = (where, msg) => problems.push(`${where}: ${msg}`);

let map;
try {
  map = loadMap();
} catch (err) {
  console.error(`ecosystem-map: ${path.relative(ROOT, MAP_FILE)} is not readable JSON - ${err.message}`);
  process.exit(1);
}

/* ------------------------------------------------------------ the shape */

const onlyKeys = (where, obj, allowed) => {
  for (const k of Object.keys(obj)) if (!allowed.includes(k)) bad(where, `unknown key "${k}" (allowed: ${allowed.join(", ")})`);
};
const isStr = (v) => typeof v === "string" && v.trim() !== "";
const strOrNull = (v) => v === null || isStr(v);

onlyKeys("ecosystem.json", map, ["$comment", "schema", "core", "asOf", "kinds", "pinKinds", "repos"]);
if (map.schema !== 1) bad("ecosystem.json", `schema is ${map.schema}, this checker reads 1`);
if (!/^\d{4}-\d{2}-\d{2}$/.test(map.asOf ?? "")) bad("ecosystem.json", "asOf is not a date (YYYY-MM-DD)");
if (!map.kinds || typeof map.kinds !== "object") bad("ecosystem.json", "kinds is missing");
if (!map.pinKinds || typeof map.pinKinds !== "object") bad("ecosystem.json", "pinKinds is missing");
if (!Array.isArray(map.repos) || map.repos.length === 0) {
  bad("ecosystem.json", "repos is missing or empty");
  report();
}

const KINDS = Object.keys(map.kinds ?? {});
const VIAS = Object.keys(map.pinKinds ?? {});
const known = new Map();
for (const e of map.repos) {
  for (const n of [e.repo, ...(e.formerly ?? [])]) {
    if (typeof n !== "string") continue;
    if (known.has(n.toLowerCase())) bad(n, "listed twice (as a name or a former name)");
    known.set(n.toLowerCase(), e);
  }
}

for (const e of map.repos) {
  const at = e.repo ?? "(entry without repo)";
  onlyKeys(at, e, ["repo", "formerly", "checkout", "kind", "status", "defaultBranch", "branches", "release", "dependsOn", "check", "canary", "note"]);
  if (!REPO.test(e.repo ?? "")) bad(at, `repo must be owner/name`);
  if (e.formerly !== undefined && !(Array.isArray(e.formerly) && e.formerly.every((n) => REPO.test(n)))) bad(at, "formerly must be a list of owner/name");
  if (e.checkout !== undefined && !isStr(e.checkout)) bad(at, "checkout must be a directory name");
  if (!KINDS.includes(e.kind)) bad(at, `kind "${e.kind}" is not one of ${KINDS.join(", ")}`);
  if (!STATUSES.includes(e.status)) bad(at, `status "${e.status}" is not one of ${STATUSES.join(", ")}`);
  if (!isStr(e.defaultBranch)) bad(at, "defaultBranch is missing");
  if (!e.branches || typeof e.branches !== "object" || Array.isArray(e.branches)) {
    bad(at, "branches must be an object (branch -> the workflow that publishes it, or null when unknown)");
  } else {
    for (const [b, by] of Object.entries(e.branches)) {
      if (b === e.defaultBranch) bad(at, `branches lists the default branch ${b}`);
      if (!strOrNull(by)) bad(at, `branches.${b} must be a workflow path or null`);
    }
  }

  const r = e.release;
  if (!r || typeof r !== "object") bad(at, "release is missing");
  else {
    onlyKeys(`${at} release`, r, ["mode", "by", "tags", "doc", "note"]);
    if (!RELEASE_MODES.includes(r.mode)) bad(at, `release.mode "${r.mode}" is not one of ${RELEASE_MODES.join(", ")}`);
    if (r.mode === "core" && e.repo !== map.core) bad(at, `release.mode "core" belongs to ${map.core} alone`);
  }
  if (e.repo === map.core && r?.mode !== "core") bad(at, `the core's release.mode must be "core"`);

  if (!Array.isArray(e.dependsOn)) bad(at, "dependsOn must be a list");
  for (const [i, p] of (e.dependsOn ?? []).entries()) {
    const pat = `${at} dependsOn[${i}]`;
    onlyKeys(pat, p, ["repo", "via", "file", "field", "ref", "note"]);
    if (!REPO.test(p.repo ?? "")) bad(pat, "repo must be owner/name");
    else if (!known.has(p.repo.toLowerCase())) bad(pat, `${p.repo} is not a repository of this map`);
    else if (p.repo.toLowerCase() === e.repo.toLowerCase()) bad(pat, "a repository does not depend on itself");
    if (!VIAS.includes(p.via)) bad(pat, `via "${p.via}" is not one of ${VIAS.join(", ")}`);
    if (!isStr(p.file)) bad(pat, "file is missing - say WHERE the pin is written");
    if (!strOrNull(p.field)) bad(pat, "field must be a string or null");
    if (!strOrNull(p.ref)) bad(pat, "ref must be a string or null");
    if ((p.via === "deps-json" || p.via === "pin-file") && !SHA.test(p.ref ?? "")) bad(pat, `a ${p.via} pin is a 40-character commit`);
    if (p.via === "npm" && !isStr(p.ref)) bad(pat, "an npm pin names its version range");
    if (p.via === "npm" && !/^(dependencies|devDependencies|peerDependencies)\.@?[\w./-]+$/.test(p.field ?? "")) {
      bad(pat, "an npm pin's field is <block>.<package>, e.g. devDependencies.@abap2ui5/linter");
    }
    if (p.via === "abaplint" && p.field !== "dependencies[].branch") bad(pat, `an abaplint pin's field is "dependencies[].branch"`);
  }

  if (e.check !== null && !isStr(e.check)) bad(at, "check must be a command or null (null: the repository has none)");

  if (e.canary !== null) {
    const c = e.canary;
    if (!c || typeof c !== "object") bad(at, "canary must be null or { lint, rename }");
    else {
      onlyKeys(`${at} canary`, c, ["lint", "rename"]);
      if (!Array.isArray(c.lint) || c.lint.length === 0 || !c.lint.every(isStr)) bad(at, "canary.lint must name at least one abaplint config");
      if (typeof c.rename !== "boolean") bad(at, "canary.rename must be true or false");
      const corePins = (e.dependsOn ?? []).filter((p) => p.via === "abaplint" && p.repo === map.core);
      if (corePins.length === 0) bad(at, `a canary needs an abaplint pin on ${map.core} to point at main`);
      for (const f of c.lint ?? []) {
        if (!corePins.some((p) => p.file === f)) bad(at, `canary.lint names ${f}, which has no abaplint pin on ${map.core} in dependsOn`);
      }
    }
  }
  if (e.status === "retired" && (e.canary !== null || r?.mode === "with-core")) {
    bad(at, "a retired repository is neither canaried nor released");
  }
}

const core = map.repos.find((e) => e.repo === map.core);
if (!core) bad("ecosystem.json", `the core ${map.core} has no entry`);

/* -------------------------------------- the core's entry, against this tree
 * Its pins are files in this checkout, so the map can be held to them without
 * a network: a bump of the embed control or the linter range that forgets the
 * map fails here, in the same pull request. */
if (core) {
  for (const [b, by] of Object.entries(core.branches ?? {})) {
    if (by && !existsSync(path.join(ROOT, by))) bad(`${core.repo} branches.${b}`, `${by} does not exist here`);
  }
  if (core.release?.by && !existsSync(path.join(ROOT, core.release.by))) bad(`${core.repo} release.by`, `${core.release.by} does not exist here`);
  for (const p of core.dependsOn ?? []) {
    const file = path.join(ROOT, p.file);
    if (!existsSync(file)) { bad(`${core.repo} -> ${p.repo}`, `${p.file} does not exist here`); continue; }
    const text = readFileSync(file, "utf8");
    const finding = checkPinText(p, text);
    if (finding) bad(`${core.repo} -> ${p.repo} (${p.file})`, finding);
  }
}

/* What a file says about one pin, compared with the map. null = agrees. */
function checkPinText(p, text) {
  switch (p.via) {
    case "abaplint": {
      let config;
      try { config = parseJsonc(text); } catch (err) { return `not parseable as JSONC - ${err.message}`; }
      const deps = abaplintDeps(config, p.repo);
      const names = [p.repo, ...(known.get(p.repo.toLowerCase())?.formerly ?? [])];
      const all = names.flatMap((n) => abaplintDeps(config, n));
      if (all.length === 0 && deps.length === 0) return `has no dependency on ${p.repo}`;
      const branches = [...new Set(all.map((d) => d.branch ?? null))];
      if (!branches.includes(p.ref ?? null)) return `names branch ${branches.map((b) => JSON.stringify(b)).join(" / ")}, the map says ${JSON.stringify(p.ref)}`;
      return null;
    }
    case "deps-json": {
      let deps;
      try { deps = JSON.parse(text); } catch (err) { return `not JSON - ${err.message}`; }
      const hit = Object.entries(deps).find(([k]) => k.toLowerCase() === p.repo.toLowerCase());
      if (!hit) return `has no entry for ${p.repo}`;
      return hit[1]?.sha === p.ref ? null : `pins ${hit[1]?.sha}, the map says ${p.ref}`;
    }
    case "pin-file":
      return text.trim() === p.ref ? null : `holds ${text.trim().slice(0, 40)}, the map says ${p.ref}`;
    case "npm": {
      let pkg;
      try { pkg = JSON.parse(text); } catch (err) { return `not JSON - ${err.message}`; }
      const dot = p.field.indexOf(".");
      const block = p.field.slice(0, dot);
      const name = p.field.slice(dot + 1);
      const have = pkg[block]?.[name];
      if (have === undefined) return `has no ${name} in ${block}`;
      return have === p.ref ? null : `${p.field} is ${have}, the map says ${p.ref}`;
    }
    case "workflow":
    case "script":
      /* Only a commit can be looked for verbatim; a default-branch checkout
       * (ref null) or a version field written elsewhere is descriptive. */
      if (p.ref && SHA.test(p.ref) && !text.includes(p.ref)) return `does not contain ${p.ref}`;
      if (!text.toLowerCase().includes(p.repo.split("/")[1].toLowerCase()) && p.via === "workflow") return `does not name ${p.repo}`;
      return null;
    default:
      return null;
  }
}

/* ----------------------------------------------------------------- --live */

/* A pin on a package of the family that the newest release no longer
 * satisfies. Not a finding - the map records what the file says, and a pin
 * may lag on purpose - but after a core release it is the list of what was
 * not carried along: on 2026-11-27, a day after 1.151.0 shipped wire
 * protocol 3, the protocol suite still installed 1.150.0 and two embed
 * repositories older runtimes, and five sample corpora a linter two minors
 * behind (RELEASING.md, "After a release"). */
const OWN_SCOPES = /^@(abap2ui5|cap2ui5)\//;

/* Does the npm range `range` admit version `v`? true / false, or null when
 * the range is not one of the shapes the ecosystem writes (X.Y.Z, ^X.Y.Z,
 * ~X.Y.Z, >=X.Y.Z, >=X.Y.Z <A.B.C). No dependency on semver: a caret on
 * 0.x stays within the minor, as npm resolves it. */
function admits(range, v) {
  const num = (s) => s.split(".").map(Number);
  const cmp = (a, b) => { for (let i = 0; i < 3; i++) if (a[i] !== b[i]) return a[i] < b[i] ? -1 : 1; return 0; };
  const V = num(v);
  const r = range.trim();
  let m;
  if ((m = /^(\d+\.\d+\.\d+)$/.exec(r))) return cmp(V, num(m[1])) === 0;
  if ((m = /^\^(\d+\.\d+\.\d+)$/.exec(r))) {
    const L = num(m[1]);
    const upper = L[0] > 0 ? [L[0] + 1, 0, 0] : L[1] > 0 ? [0, L[1] + 1, 0] : [0, 0, L[2] + 1];
    return cmp(V, L) >= 0 && cmp(V, upper) < 0;
  }
  if ((m = /^~(\d+\.\d+\.\d+)$/.exec(r))) { const L = num(m[1]); return cmp(V, L) >= 0 && cmp(V, [L[0], L[1] + 1, 0]) < 0; }
  if ((m = /^>=\s*(\d+\.\d+\.\d+)(?:\s+<\s*(\d+\.\d+\.\d+))?$/.exec(r))) {
    return cmp(V, num(m[1])) >= 0 && (!m[2] || cmp(V, num(m[2])) < 0);
  }
  return null;
}

async function fetchText(url) {
  const headers = {};
  const token = process.env.GITHUB_TOKEN || process.env.GH_TOKEN;
  if (token && url.startsWith("https://api.github.com/")) headers.Authorization = `Bearer ${token}`;
  const res = await fetch(url, { headers, signal: AbortSignal.timeout(20_000) });
  return { status: res.status, text: res.ok ? await res.text() : "" };
}

const refCache = new Map();
function refExists(repo, ref) {
  const key = `${repo}@${ref}`;
  if (!refCache.has(key)) {
    refCache.set(key, lsRemote(repo, `refs/heads/${ref}`, `refs/tags/${ref}`).length > 0);
  }
  return refCache.get(key);
}

/* The API first (a token raises its limit of 60 an hour); when it refuses -
 * no token, a stale one, the limit spent - the commit page on github.com,
 * which answers 200 or 404 without one. */
async function commitExists(repo, sha) {
  const api = await fetchText(`https://api.github.com/repos/${repo}/commits/${sha}`);
  if (api.status === 200) return true;
  if (api.status === 404 || api.status === 422) return false;
  const page = await fetch(`https://github.com/${repo}/commit/${sha}`, { method: "HEAD", signal: AbortSignal.timeout(20_000) });
  if (page.status === 200) return true;
  if (page.status === 404) return false;
  throw new Error(`GitHub answered ${api.status} (API) and ${page.status} (commit page)`);
}

async function live() {
  let checked = 0;
  for (const e of map.repos) {
    if (e.status !== "active") continue;
    const at = e.repo;
    let heads;
    try {
      const def = defaultBranchOf(e.repo);
      if (def !== e.defaultBranch) bad(at, `default branch is ${def}, the map says ${e.defaultBranch}`);
      heads = headsOf(e.repo);
    } catch (err) {
      notes.push(`${at}: not reachable (${err.message.split("\n")[0]})`);
      continue;
    }
    for (const b of Object.keys(e.branches)) if (!heads.has(b)) bad(at, `branch ${b} does not exist`);

    for (const p of e.dependsOn) {
      const pat = `${at} -> ${p.repo} (${p.via}, ${p.file})`;
      try {
        if (["abaplint", "deps-json", "pin-file", "npm", "workflow", "script"].includes(p.via) && !p.file.endsWith("/")) {
          const { status, text } = await fetchText(`https://raw.githubusercontent.com/${e.repo}/${e.defaultBranch}/${p.file}`);
          if (status === 404) { bad(pat, `${p.file} does not exist on ${e.defaultBranch}`); continue; }
          if (status !== 200) { notes.push(`${pat}: raw read answered ${status}`); continue; }
          const finding = checkPinText(p, text);
          if (finding) bad(pat, finding);
        }
        if (p.ref && SHA.test(p.ref)) {
          if (!(await commitExists(p.repo, p.ref))) bad(pat, `commit ${p.ref} does not exist in ${p.repo}`);
        } else if (p.ref && p.via === "abaplint") {
          if (!refExists(p.repo, p.ref)) bad(pat, `${p.ref} is neither a branch nor a tag of ${p.repo}`);
        } else if (p.via === "npm") {
          const pkgName = p.field.slice(p.field.indexOf(".") + 1);
          const { status, text } = await fetchText(`https://registry.npmjs.org/${pkgName.replace("/", "%2f")}`);
          if (status === 404) bad(pat, `${pkgName} is not on the npm registry`);
          else if (status === 200 && /^\d+\.\d+\.\d+$/.test(p.ref) && !JSON.parse(text).versions?.[p.ref]) {
            bad(pat, `${pkgName}@${p.ref} is not published`);
          } else if (status === 200 && OWN_SCOPES.test(pkgName)) {
            const latest = JSON.parse(text)["dist-tags"]?.latest;
            if (latest && admits(p.ref, latest) === false) behind.push(`${e.repo}: ${pkgName} ${p.ref} - latest is ${latest} (${p.file})`);
          }
        }
        checked += 1;
      } catch (err) {
        notes.push(`${pat}: not checked (${err.message.split("\n")[0]})`);
      }
    }
  }
  return checked;
}

if (LIVE) pinsChecked = await live();
report();

function report() {
  for (const n of notes) console.log(`note: ${n}`);
  if (behind.length) {
    console.log(`behind: ${behind.length} pin(s) on @abap2ui5/* or @cap2ui5/* the newest release does not satisfy - not a finding; after a release, carry them along (RELEASING.md):`);
    for (const b of behind) console.log(`  ${b}`);
  }
  if (problems.length) {
    console.log(`ecosystem-map: ${problems.length} problem(s) in .github/ecosystem.json${LIVE ? " (live)" : ""}\n`);
    for (const p of problems) console.log(`  ${p}`);
    console.log(LIVE
      ? "\nA live finding means the map is stale: correct the entry to what the repository says today."
      : "\nThe pinKinds and kinds blocks at the top of the file say what each field means.");
    process.exit(1);
  }
  const repos = map.repos?.length ?? 0;
  console.log(`ecosystem-map: ${repos} repositories - shape OK, the core's pins match this tree`
    + (LIVE ? `; live: ${pinsChecked} pins checked against GitHub/npm, ${notes.length} not reachable` : ""));
  process.exit(0);
}
