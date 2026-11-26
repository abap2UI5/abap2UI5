#!/usr/bin/env node
/*
 * release-ecosystem — tag every repository that is released with the core
 * version, after the core release. DRY-RUN IS THE DEFAULT.
 *
 *   node .github/scripts/release-ecosystem.mjs <X.Y.Z>             print the plan
 *   node .github/scripts/release-ecosystem.mjs <X.Y.Z> --apply     perform it
 *        [--only <owner/name>[,<owner/name>...]]                  a subset
 *   (npm run release:ecosystem -- <X.Y.Z> [--apply])
 *
 * Which repositories: every active entry of `.github/ecosystem.json` whose
 * release.mode is "with-core". The core itself is not among them - its own
 * release.yaml cuts X.Y.Z and X.Y.Z-702 from one tag push (RELEASING.md) - and
 * neither are the repositories with a version line of their own (the linter,
 * mcp-server, the embed control: release.mode "own").
 *
 * What, per repository (the logic of the release-all.sh it replaces):
 *   X.Y.Z         on the head of its default branch, marked the latest release
 *   X.Y.Z-702     on the head of its branch 702, where the map lists one
 *   X.Y.Z-cloud   on the head of its branch cloud, where the map lists one
 * A tag that already exists is skipped, so the script can run again after a
 * partial run. A branch the map lists but GitHub does not have is reported
 * and skipped - run `npm run check:ecosystem -- --live` to correct the map.
 *
 * Reads go through `git ls-remote` (no token needed, so the dry run works
 * anywhere). Writes go through `gh release create`, i.e. the GitHub API as the
 * account `gh` is logged in with - `gh auth status` has to show one with write
 * access to every repository in the plan. `--apply` refuses to start while the
 * core's own tag X.Y.Z does not exist yet: the ecosystem release names a core
 * release, so it comes after it (RELEASING.md, "Release order").
 */
import { execFileSync } from "node:child_process";
import { loadMap, lsRemote, is702 } from "./lib/ecosystem-map.mjs";

const args = process.argv.slice(2);
const APPLY = args.includes("--apply");
const version = args.find((a) => !a.startsWith("--") && args[args.indexOf(a) - 1] !== "--only");
const onlyArg = args.includes("--only") ? args[args.indexOf("--only") + 1] : null;

if (!/^\d+\.\d+\.\d+$/.test(version ?? "")) {
  console.error("usage: release-ecosystem.mjs <X.Y.Z> [--apply] [--only <owner/name>[,...]]");
  process.exit(2);
}

const map = loadMap();
let repos = map.repos.filter((e) => e.status === "active" && e.release.mode === "with-core");
if (onlyArg) {
  const only = new Set(onlyArg.split(",").map((s) => s.trim().toLowerCase()));
  const unknown = [...only].filter((o) => !repos.some((e) => e.repo.toLowerCase() === o));
  if (unknown.length) {
    console.error(`release-ecosystem: not released with the core per .github/ecosystem.json: ${unknown.join(", ")}`);
    process.exit(2);
  }
  repos = repos.filter((e) => only.has(e.repo.toLowerCase()));
}

console.log(`release-ecosystem ${version} - ${APPLY ? "APPLY: tags and releases are created" : "dry run (nothing is written; --apply to perform)"}\n`);

/* The core first: the ecosystem release names a core release. */
const coreTagged = lsRemote(map.core, `refs/tags/${version}`).length > 0;
if (!coreTagged) {
  console.log(`! ${map.core} has no tag ${version} yet - cut the core release first (RELEASING.md).`);
  if (APPLY) {
    console.error("release-ecosystem: refusing --apply before the core release exists");
    process.exit(1);
  }
  console.log("");
}

if (APPLY) {
  try {
    execFileSync("gh", ["auth", "status"], { stdio: "ignore" });
  } catch {
    console.error("release-ecosystem: `gh auth status` fails - log in with an account that may push tags to every repository below");
    process.exit(1);
  }
}

let created = 0;
let planned = 0;
let skipped = 0;
const problems = [];

for (const e of repos) {
  console.log(e.repo);
  let state;
  try {
    state = lsRemote(e.repo, "refs/heads/*", "refs/tags/*");
  } catch (err) {
    problems.push(`${e.repo}: not reachable (${err.message.split("\n")[0]})`);
    console.log("  ! not reachable - skipped");
    continue;
  }
  const head = (b) => state.find((s) => s.ref === `refs/heads/${b}`)?.sha;
  const hasTag = (t) => state.some((s) => s.ref === `refs/tags/${t}`);

  const targets = [{ branch: e.defaultBranch, tag: version, latest: true }];
  for (const b of ["702", "cloud"]) {
    if (b in e.branches) targets.push({ branch: b, tag: `${version}-${b}`, latest: false });
  }

  for (const t of targets) {
    const sha = head(t.branch);
    if (!sha) {
      problems.push(`${e.repo}: the map lists branch ${t.branch}, GitHub does not have it`);
      console.log(`  ! branch ${t.branch} does not exist - ${t.tag} skipped`);
      continue;
    }
    if (hasTag(t.tag)) {
      skipped += 1;
      console.log(`  = ${t.tag} exists already - skipped`);
      continue;
    }
    if (!APPLY) {
      planned += 1;
      console.log(`  ~ would create ${t.tag} on ${t.branch} ${sha.slice(0, 8)}`);
      continue;
    }
    try {
      execFileSync("gh", [
        "release", "create", t.tag,
        "--repo", e.repo,
        "--target", sha,
        "--title", t.tag,
        "--notes", `Release ${t.tag} of ${e.repo}, for abap2UI5 ${version} (branch \`${t.branch}\`, ${sha.slice(0, 8)}).`,
        `--latest=${t.latest}`,
      ], { stdio: ["ignore", "ignore", "pipe"] });
      created += 1;
      console.log(`  + ${t.tag} on ${t.branch} ${sha.slice(0, 8)}`);
    } catch (err) {
      problems.push(`${e.repo}: ${t.tag} failed - ${String(err.stderr ?? err.message).trim().split("\n")[0]}`);
      console.log(`  ! ${t.tag} failed`);
    }
  }

  /* Not part of the release, but the moment to see it: a consumer that pins
   * the core to an older tag (RELEASING.md, "The ecosystem can pin again"). */
  const stale = e.dependsOn.filter((p) => p.repo === map.core && p.via === "abaplint"
    && /^\d+\.\d+\.\d+(-702)?$/.test(p.ref ?? "") && p.ref.replace(/-702$/, "") !== version);
  for (const p of stale) console.log(`  i pins ${map.core} at ${p.ref} in ${p.file}${is702(p.ref) ? "" : ` - ${version} once it carries what it needs`}`);
}

console.log(`\n${APPLY ? `${created} created` : `${planned} would be created`}, ${skipped} existed already, ${problems.length} problem(s)`);
for (const p of problems) console.log(`  ${p}`);
process.exit(problems.length ? 1 : 0);
