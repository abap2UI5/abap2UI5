#!/usr/bin/env node
/*
 * pack-backend — the transpiled Node backend as ONE release asset.
 *
 * Why: abap2UI5/mcp-server boots every app against a transpiled Node backend
 * (its lib/runtime.mjs, `buildBackend`), and its first "full" build takes
 * tens of minutes because it downports and transpiles the whole framework
 * itself - the same work this repository's own pipeline already does on
 * every release: `npm run downport` writes node/downport/, `npm run
 * auto_transpile` writes node/output/, both over the pinned lib clones
 * `npm run deps` materialises in node/deps/. So the release ships that
 * output: backend-prebuilt.yaml runs this script on the tagged commit and
 * attaches the tarball to the GitHub release, and a consumer downloads what
 * was built here instead of building it again.
 *
 * What goes in, paths relative to the checkout root:
 *   node/downport/          the 7.02-downported sources the transpile ran over
 *   node/output/            the transpiled backend (init.mjs, index.mjs, ...)
 *   node/deps/              the three pinned lib clones - WITHOUT their .git
 *                           directories, which are most of their bytes and
 *                           nothing the runtime reads
 *   backend-manifest.json   at the tar ROOT (not under node/): version,
 *                           commit, build time, node and transpiler versions,
 *                           and the list of trees above
 *
 * CONTRACT: the asset name `backend-<version>.tar.gz`, the three directories
 * above at their checkout-relative paths, and the manifest's name, place and
 * keys are what abap2UI5/mcp-server reads: it unpacks the tarball with
 * `tar -xzf backend-<version>.tar.gz -C <abap2UI5 checkout>` and then reads
 * backend-manifest.json at the checkout ROOT (which is why .gitignore lists
 * it next to the trees). Renaming or moving any of the four is a change over
 * there first.
 *
 * `tar` through execFileSync with an ARGUMENT ARRAY, never a shell string -
 * the rule fetch-deps.mjs states for git, for the same reason. The CLI is on
 * ubuntu-latest, macOS and Windows 10+ (bsdtar there), and every flag below
 * is one all three accept: -czf, -C (positional, so the manifest can come
 * from a temp directory and the trees from the checkout), --exclude. The two
 * tars read an exclude pattern slightly differently, so the archive is listed
 * afterwards and refused when a .git directory got in - a wrong asset is
 * worse than none, because the consumer would trust it.
 *
 *   node node/setup/pack-backend.mjs               backend-<version>.tar.gz at the root
 *   node node/setup/pack-backend.mjs --out <file>  somewhere else
 *
 * Refuses (exit 1) when the trees are not there and names the scripts that
 * produce them - the courtesy require-transpiled.mjs pays `npm run unit`.
 */
import { execFileSync } from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { fileURLToPath } from "node:url";

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..", "..");
const MANIFEST = "backend-manifest.json";
const CONTENTS = ["node/downport", "node/output", "node/deps"];

const pkg = JSON.parse(fs.readFileSync(path.join(ROOT, "package.json"), "utf8"));

// --- arguments --------------------------------------------------------------
let out = path.join(ROOT, `backend-${pkg.version}.tar.gz`);
const args = process.argv.slice(2);
for (let i = 0; i < args.length; i += 1) {
  if (args[i] === "--out" && args[i + 1]) {
    out = path.resolve(args[i + 1]);
    i += 1;
  } else {
    console.error(`pack-backend: unknown argument ${JSON.stringify(args[i])}`);
    console.error("  usage: node node/setup/pack-backend.mjs [--out <file>]");
    process.exit(2);
  }
}

// --- the trees have to be there ---------------------------------------------
/* node/output/init.mjs rather than the directory: prepare-transpile clears
 * the directory before the transpiler writes it, so an empty node/output is
 * a transpile that did not finish, and packing it would ship a backend that
 * cannot boot. */
const REQUIRED = [
  { path: "node/downport", by: "npm run downport" },
  { path: "node/deps", by: "npm run deps (npm run downport runs it)" },
  { path: "node/output/init.mjs", by: "npm run auto_transpile" },
];
const missing = REQUIRED.filter((r) => !fs.existsSync(path.join(ROOT, r.path)));
if (missing.length) {
  console.error("pack-backend: nothing to pack - the built backend is not there.\n");
  for (const m of missing) console.error(`  ${m.path.padEnd(21)} missing - produced by: ${m.by}`);
  console.error("\nBuild it first, in this order:\n");
  console.error("    npm run downport         # copy src/, abaplint --fix the copy, strip whitespace (fetches node/deps)");
  console.error("    npm run auto_transpile   # ABAP -> mjs into node/output\n");
  console.error("Both together take a few minutes. Neither tree is committed (AGENTS.md, \"Build & Validation\").");
  process.exit(1);
}

// --- the manifest -----------------------------------------------------------
/* null when this is not a git checkout (a source tarball, say) rather than a
 * failure: the manifest says what it knows, and the consumer treats a missing
 * commit as "unknown", not as "broken". */
function gitHead() {
  try {
    const sha = execFileSync("git", ["rev-parse", "HEAD"], {
      cwd: ROOT,
      stdio: ["ignore", "pipe", "ignore"],
    }).toString().trim();
    return sha || null;
  } catch {
    return null;
  }
}

/* The transpiler that wrote node/output: the installed package first, the
 * lockfile when node_modules is not there - the lock is what `npm ci`
 * installs, so it names the same version. */
function transpilerVersion() {
  const name = "@abaplint/transpiler-cli";
  try {
    return JSON.parse(fs.readFileSync(path.join(ROOT, "node_modules", name, "package.json"), "utf8")).version;
  } catch {
    // not installed - the lockfile below knows the version anyway
  }
  try {
    const lock = JSON.parse(fs.readFileSync(path.join(ROOT, "package-lock.json"), "utf8"));
    return lock.packages?.[`node_modules/${name}`]?.version ?? null;
  } catch {
    return null;
  }
}

const manifest = {
  version: pkg.version,
  commit: gitHead(),
  builtAt: new Date().toISOString(),
  node: process.version,
  transpiler: transpilerVersion(),
  contents: CONTENTS,
};

// --- pack -------------------------------------------------------------------
fs.mkdirSync(path.dirname(out), { recursive: true });
const stage = fs.mkdtempSync(path.join(os.tmpdir(), "abap2ui5-backend-"));
try {
  fs.writeFileSync(path.join(stage, MANIFEST), `${JSON.stringify(manifest, null, 2)}\n`);
  /* --exclude before the members it applies to (both tars want it there),
   * the manifest from the staging directory so it lands at the archive root
   * rather than under node/, then the trees relative to the checkout. */
  execFileSync(
    "tar",
    ["-czf", out, "--exclude=.git", "-C", stage, MANIFEST, "-C", ROOT, ...CONTENTS],
    { stdio: ["ignore", "inherit", "inherit"] },
  );

  /* Listing the archive is the check that does not depend on which tar ran:
   * the manifest at the root, every tree present, no .git directory that
   * slipped past the pattern. */
  const entries = execFileSync("tar", ["-tzf", out], { maxBuffer: 256 * 1024 * 1024 })
    .toString()
    .split("\n")
    .filter(Boolean)
    .map((e) => e.replace(/\/$/, ""));
  const problems = [];
  if (!entries.includes(MANIFEST)) problems.push(`${MANIFEST} is not at the archive root`);
  for (const tree of CONTENTS) {
    if (!entries.some((e) => e === tree || e.startsWith(`${tree}/`))) {
      problems.push(`${tree} is not in the archive`);
    }
  }
  const git = entries.filter((e) => e === ".git" || e.endsWith("/.git") || e.includes("/.git/"));
  if (git.length) {
    problems.push(`${git.length} .git entr${git.length === 1 ? "y" : "ies"} got in (first: ${git[0]}) - the exclude did not take`);
  }
  if (problems.length) {
    fs.rmSync(out, { force: true });
    console.error("pack-backend: the archive is not what the consumer expects - removed it:");
    for (const p of problems) console.error(`  ${p}`);
    process.exit(1);
  }

  const mb = (fs.statSync(out).size / 1024 / 1024).toFixed(1);
  console.log(`pack-backend: ${path.relative(ROOT, out) || out} (${mb} MB, ${entries.length} entries)`);
  console.log(
    `  version ${manifest.version}, commit ${manifest.commit ?? "unknown"},`
    + ` transpiler ${manifest.transpiler ?? "unknown"}, node ${manifest.node}`,
  );
} finally {
  fs.rmSync(stage, { recursive: true, force: true });
}
