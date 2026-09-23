#!/usr/bin/env node
/*
 * npm-audit-gate — the advisories the dependency trees already carry, judged
 * against a list that says why each one is still there.
 *
 * dependency-review.yaml judges what a pull request ADDS to the tree, and
 * says nothing about what was already in it. That is the right shape for a
 * pull-request gate, and it has a hole exactly where `npm audit` looks: an
 * advisory published for a package the lockfile has carried for a year
 * fails no pull request, because no pull request added it. Until this gate
 * existed nothing ran `npm audit` here at all - the root tree had four high
 * advisories and app/ six, all in the UI5 build tooling, and nothing said so.
 *
 * A plain `npm audit --audit-level=high` would say so every Monday and be
 * red until @ui5/project moves, which trains everyone to click past it - the
 * same failure dependency-review.yaml's threshold comment describes. So the
 * known advisories are ACCEPTED below, each with the reason it can stay, and
 * the gate fails on two things only:
 *
 *   - a high or critical advisory that is NOT on the list: new, so somebody
 *     has to look at it and either fix it or write down why not
 *   - an ACCEPTED entry the audit no longer reports for that tree: the fix
 *     arrived, so the entry goes - the list only shrinks on its own accord,
 *     an accepted advisory cannot outlive the reason it was accepted for
 *
 * Both lockfiles are read, the same two dependency-review.yaml reads: the
 * root one and app/package-lock.json, which is where @ui5/cli, the UI5
 * linter and Prettier come from. `npm audit` needs no node_modules - it
 * sends the lockfile to the registry's bulk advisory endpoint - which is
 * why the workflow around this runs no install.
 *
 * When the registry is not reachable the run SAYS SO and passes, the way
 * the other gates that read over the network do (shared-file-gate,
 * scripts-gate): a gate must not go red because a host is unreachable, and
 * it must not claim to have verified something it did not. npm-audit.yaml
 * runs it where the registry is reachable.
 *
 *   node .github/scripts/npm-audit-gate.mjs        (npm run check:audit)
 */
import { spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";
import { join } from "node:path";

const ROOT = fileURLToPath(new URL("../../", import.meta.url));

/* the two dependency trees; "" is the repository root */
const TREES = ["", "app"];

/* what the gate fails on - moderate and below stay out for the reason
 * dependency-review.yaml gives for its own threshold */
const LEVELS = new Set(["high", "critical"]);

/* Advisories at or above the threshold that are known and accepted. Keyed by
 * the GHSA id `npm audit` reports; `trees` names the lockfile(s) that carry
 * it, so an advisory fixed in one tree and not the other is noticed. Every
 * entry needs the reason, so an entry cannot become a silent hole - and the
 * reason has to name why the fix is not simply taken. */
const ACCEPTED = new Map([
  ["GHSA-w4pp-8pjf-rmxw", {
    trees: ["", "app"],
    reason: "pacote: DoS via addGitSha. Reached only through @ui5/cli -> @ui5/project, "
      + "build-time and fed by the lockfile, never by user input. npm's only fix is "
      + "@ui5/cli 2.x, a major downgrade; waits for @ui5/project to move its pacote range",
  }],
  ["GHSA-52v5-jr5w-gjxr", {
    trees: ["", "app"],
    reason: "sigstore: certificateOIDs constraints not enforced. Same chain (@ui5/project -> "
      + "pacote -> sigstore); the provenance verification it weakens is not something the "
      + "build relies on - the lockfile pins by integrity hash. Same fix path as above",
  }],
  ["GHSA-3jxr-9vmj-r5cp", {
    trees: ["app"],
    reason: "brace-expansion 3.x/4.x/5.x: DoS via exponential expansion. Transitive under "
      + "@ui5/cli in app/ only; the patterns it expands are the UI5 tooling's own globs, "
      + "not input. No non-major fix in the @ui5/* range yet",
  }],
  ["GHSA-mh99-v99m-4gvg", {
    trees: ["app"],
    reason: "brace-expansion: DoS via unbounded expansion length - same package, same chain "
      + "and same reasoning as GHSA-3jxr-9vmj-r5cp",
  }],
  ["GHSA-rgw5-rvv9-x895", {
    trees: ["app"],
    reason: "brace-expansion: DoS via unbounded intermediate arrays - same package, same "
      + "chain and same reasoning as GHSA-3jxr-9vmj-r5cp",
  }],
]);

const problems = [];
const notes = [];

/* npm audit exits 1 when it finds anything, so the exit code is not the
 * signal - the JSON is. A registry that could not be asked comes back as an
 * `error` object (ENOAUDIT, network) rather than a report. */
function audit(tree) {
  const cwd = join(ROOT, tree);
  const npm = process.platform === "win32" ? "npm.cmd" : "npm";
  const run = spawnSync(npm, ["audit", "--json"], { cwd, encoding: "utf8", shell: process.platform === "win32" });
  if (run.error) return { note: `npm could not be started: ${run.error.message}` };
  let json;
  try {
    json = JSON.parse(run.stdout);
  } catch {
    return { note: `npm audit printed no JSON (exit ${run.status})${run.stderr ? `: ${run.stderr.trim().split("\n")[0]}` : ""}` };
  }
  if (json.error) return { note: `${json.error.code ?? "error"}: ${json.error.summary ?? json.error.detail ?? "npm audit failed"}` };
  if (!json.vulnerabilities) return { note: "npm audit answered without a vulnerabilities report" };
  return { json };
}

/* the advisories behind a report: one entry per GHSA id, at the highest
 * severity it is reported with. `via` mixes advisory objects with plain
 * package names (the transitive path); only the objects carry an id. */
function advisories(json) {
  const found = new Map();
  for (const entry of Object.values(json.vulnerabilities)) {
    for (const via of entry.via ?? []) {
      if (typeof via !== "object" || !via.url) continue;
      const id = String(via.url).split("/").pop();
      if (!/^GHSA-/.test(id)) continue;
      const known = found.get(id);
      if (!known || rank(via.severity) > rank(known.severity)) {
        found.set(id, { id, severity: via.severity, name: via.name, title: via.title });
      }
    }
  }
  return found;
}

const ORDER = ["info", "low", "moderate", "high", "critical"];
const rank = (s) => ORDER.indexOf(s);

let checked = 0;
for (const tree of TREES) {
  const label = tree === "" ? "package-lock.json" : `${tree}/package-lock.json`;
  const { json, note } = audit(tree);
  if (note) { notes.push(`${label}: not checked (${note})`); continue; }
  checked++;

  const found = advisories(json);
  const above = [...found.values()].filter((a) => LEVELS.has(a.severity));
  const accepted = [...ACCEPTED].filter(([, v]) => v.trees.includes(tree)).map(([id]) => id);

  for (const a of above) {
    if (ACCEPTED.get(a.id)?.trees.includes(tree)) continue;
    problems.push(`${label}: ${a.severity} ${a.id} in ${a.name} - ${a.title}\n`
      + `    not accepted for this tree: fix it (npm audit fix, or move the dependency that pulls it in),\n`
      + `    or add it to ACCEPTED in .github/scripts/npm-audit-gate.mjs with the reason it can stay`);
  }
  for (const id of accepted) {
    if (found.has(id) && LEVELS.has(found.get(id).severity)) continue;
    problems.push(`${label}: ${id} is ACCEPTED for this tree but the audit no longer reports it at high/critical\n`
      + `    the fix arrived (or the advisory was downgraded) - drop the tree from its entry, or the entry`);
  }

  const counts = json.metadata?.vulnerabilities ?? {};
  console.log(`${label}: ${above.length} high/critical advisory(ies), ${accepted.length} accepted `
    + `(${ORDER.map((l) => `${l} ${counts[l] ?? 0}`).join(", ")})`);
  for (const a of above) {
    if (ACCEPTED.get(a.id)?.trees.includes(tree)) console.log(`  accepted ${a.severity.padEnd(8)} ${a.id}  ${a.name}`);
  }
}

for (const n of notes) console.log(`npm-audit-gate: ${n}`);

if (problems.length) {
  console.log(`\nnpm-audit-gate: ${problems.length} problem(s)\n`);
  for (const p of problems) console.log(`  ${p}\n`);
  process.exit(1);
}
if (checked === 0) {
  console.log("npm-audit-gate: nothing could be checked - the registry was not reachable; passing without a verdict");
  process.exit(0);
}
console.log(`npm-audit-gate: ${checked} of ${TREES.length} tree(s) checked, nothing above the accepted list`);
