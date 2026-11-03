#!/usr/bin/env node
/*
 * update-deps.mjs - the monthly dependency update, the same file in every
 * repository of abap2UI5 and abap2UI5-addons. The workflow bump-deps
 * runs it on the last Sunday of the month and opens ONE pull request with
 * everything it changed; nothing else updates dependencies on a schedule.
 *
 *   node .github/scripts/update-deps.mjs [--actions] [--summary <file>]
 *
 * npm - every folder with a package.json and a package-lock.json (the root,
 * app/, ...): each outdated dependency goes to its latest version, keeping
 * the style of its range (^, ~ or exact); then `npm install` and `npm update`
 * refresh the lockfile. Left alone:
 *   - npm aliases (`"ui5-1.71-sap.m": "npm:@openui5/sap.m@1.71.81"`) - a pin
 *   - @types/node outside the major of engines.node
 *   - what package.json names in "updateDeps": { "skip": { "<name>": "<why>" } }
 * A dependency whose package.json names a "transpiler" version (the
 * @abap2ui5/node-runtime) pins @abaplint/transpiler-cli to it. A script
 * "deps:post" in package.json runs afterwards (regenerating what is built
 * from node_modules, e.g. a BSP).
 *
 * --actions - every `uses: owner/repo@<sha> # vX.Y.Z` in .github/ goes to the
 * owner/repo's latest release, pinned by its commit sha, the comment carrying
 * the tag. Needs `gh` and GH_TOKEN. A token that may push workflow files
 * (DEPS_TOKEN in the workflow) is what lets those changes into the PR.
 *
 * --summary <file> - a Markdown list of every change, for the PR body.
 */
import { execFileSync, spawnSync } from "node:child_process";
import { existsSync, readdirSync, readFileSync, statSync, writeFileSync } from "node:fs";
import { dirname, join, relative, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const ROOT = resolve(dirname(fileURLToPath(import.meta.url)), "../..");
const args = process.argv.slice(2);
const summaryFile = args.includes("--summary") ? args[args.indexOf("--summary") + 1] : undefined;
const lines = [];

// ------------------------------------------------------------------- npm
function packageDirs(dir, depth) {
  const out = [];
  if (existsSync(join(dir, "package.json")) && existsSync(join(dir, "package-lock.json"))) out.push(dir);
  if (depth === 0) return out;
  for (const name of readdirSync(dir)) {
    if (name === "node_modules" || name.startsWith(".")) continue;
    const p = join(dir, name);
    if (statSync(p).isDirectory()) out.push(...packageDirs(p, depth - 1));
  }
  return out;
}

function npmCmd(dir) {
  // a lockfile written by npm 11 carries "libc" fields npm 10 drops - keep
  // writing it with the npm that wrote it
  return readFileSync(join(dir, "package-lock.json"), "utf8").includes('"libc"') ? ["npx", "-y", "npm@11"] : ["npm"];
}

function run(cmd, dir, extra = []) {
  const r = spawnSync(cmd[0], [...cmd.slice(1), ...extra], { cwd: dir, encoding: "utf8", maxBuffer: 1 << 26 });
  return r;
}

for (const dir of packageDirs(ROOT, 2)) {
  const rel = relative(ROOT, dir) || ".";
  const npm = npmCmd(dir);
  const file = join(dir, "package.json");
  const raw = readFileSync(file, "utf8");
  const pkg = JSON.parse(raw);
  const skip = pkg.updateDeps?.skip ?? {};
  const engineMajor = Number((pkg.engines?.node ?? "").match(/\d+/)?.[0] ?? NaN);
  const outdated = JSON.parse(run(npm, dir, ["outdated", "--json"]).stdout || "{}");
  const changes = [];
  for (const [name, info] of Object.entries(outdated)) {
    if (name.includes(":") || skip[name]) continue;
    for (const section of ["dependencies", "devDependencies", "optionalDependencies"]) {
      const spec = pkg[section]?.[name];
      if (typeof spec !== "string" || !/^[\^~]?\d/.test(spec)) continue;
      let latest = info.latest;
      if (name === "@types/node" && engineMajor && Number(latest.split(".")[0]) !== engineMajor) latest = info.wanted;
      const next = (/^[\^~]/.test(spec) ? spec[0] : "") + latest;
      if (next !== spec) {
        pkg[section][name] = next;
        changes.push(`\`${name}\` ${spec} → ${next}`);
      }
    }
  }
  writeFileSync(file, JSON.stringify(pkg, null, raw.startsWith("{\n\t") ? "\t" : 2) + "\n");
  if (run(npm, dir, ["install", "--no-audit", "--no-fund"]).status !== 0) throw new Error(`${rel}: npm install failed`);

  // the transpiler a runtime package was built with
  const tdeps = ["dependencies", "devDependencies"].find((s) => pkg[s]?.["@abaplint/transpiler-cli"]);
  if (tdeps) {
    for (const name of Object.keys({ ...pkg.dependencies, ...pkg.devDependencies })) {
      const p = join(dir, "node_modules", name, "package.json");
      const want = existsSync(p) ? JSON.parse(readFileSync(p, "utf8")).transpiler : undefined;
      if (typeof want === "string" && /^\d/.test(want) && pkg[tdeps]["@abaplint/transpiler-cli"].replace(/^[\^~]/, "") !== want) {
        changes.push(`\`@abaplint/transpiler-cli\` → ${want} (the version \`${name}\` names)`);
        pkg[tdeps]["@abaplint/transpiler-cli"] = want;
        writeFileSync(file, JSON.stringify(pkg, null, raw.startsWith("{\n\t") ? "\t" : 2) + "\n");
        if (run(npm, dir, ["install", "--no-audit", "--no-fund"]).status !== 0) throw new Error(`${rel}: npm install failed`);
      }
    }
  }
  if (run(npm, dir, ["update", "--no-audit", "--no-fund"]).status !== 0) throw new Error(`${rel}: npm update failed`);
  if (pkg.scripts?.["deps:post"]) {
    const r = run(npm, dir, ["run", "deps:post"]);
    if (r.status !== 0) throw new Error(`${rel}: npm run deps:post failed\n${r.stdout}${r.stderr}`);
  }
  const skipped = Object.entries(skip).map(([n, why]) => `\`${n}\` stays (${why})`);
  console.log(`update-deps: ${rel} - ${changes.length} bumped`);
  if (changes.length || skipped.length) {
    lines.push(`**npm${rel === "." ? "" : ` (${rel})`}**`, "", ...changes.map((c) => `- ${c}`), ...skipped.map((s) => `- ${s}`), "");
  }
}
lines.push("The lockfiles are refreshed within the ranges as well (`npm update`).", "");

// -------------------------------------------------------- GitHub Actions
if (args.includes("--actions")) {
  const gh = (path) => JSON.parse(execFileSync("gh", ["api", path], { encoding: "utf8" }));
  const latest = new Map();
  const resolveLatest = (repo) => {
    if (!latest.has(repo)) {
      try {
        const tag = gh(`repos/${repo}/releases/latest`).tag_name;
        const sha = gh(`repos/${repo}/commits/${tag}`).sha;
        latest.set(repo, { tag, sha });
      } catch {
        latest.set(repo, undefined);
      }
    }
    return latest.get(repo);
  };
  const files = [];
  const walk = (d) => {
    if (!existsSync(d)) return;
    for (const n of readdirSync(d)) {
      const p = join(d, n);
      if (statSync(p).isDirectory()) walk(p);
      else if (/\.ya?ml$/.test(n)) files.push(p);
    }
  };
  walk(join(ROOT, ".github"));
  const changed = new Set();
  for (const f of files) {
    const text = readFileSync(f, "utf8");
    const next = text.replace(/(uses:\s*)([\w.-]+\/[\w.-]+)((?:\/[\w./-]+)?)@([0-9a-f]{40})(\s*#\s*)(v?[\w.-]+)/g,
      (all, pre, repo, sub, sha, hash, tag) => {
        const l = resolveLatest(repo);
        if (!l || l.sha === sha) return all;
        changed.add(`\`${repo}\` ${tag} → ${l.tag}`);
        return `${pre}${repo}${sub}@${l.sha}${hash}${l.tag}`;
      });
    if (next !== text) writeFileSync(f, next);
  }
  console.log(`update-deps: ${changed.size} action(s) moved`);
  if (changed.size) lines.push("**GitHub Actions**", "", ...[...changed].sort().map((c) => `- ${c}`), "");
}

if (summaryFile) writeFileSync(summaryFile, lines.join("\n"));
