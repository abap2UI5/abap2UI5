#!/usr/bin/env node
/*
 * ecosystem-canary — does a consumer of the framework still lint against THIS
 * repository's main?
 *
 * Every addon and corpus pins the framework in its abaplint configs - most of
 * them `main`, some a release tag (`.github/ecosystem.json` says which). A
 * change here that breaks one of them shows up over THERE, on the next pull
 * request somebody opens in that repository, as a red build nobody in it
 * caused. For a repository pinned to a tag it shows up later still: on the day
 * it moves the pin, with weeks of framework changes to dig through. The
 * canary moves that discovery to the night after the change, and into this
 * repository's issue tracker, where the change was made.
 *
 * Per consumer, in a checkout of its default branch (CI workspace only -
 * nothing is committed or pushed):
 *   1. every abaplint pin on the core that is not the 702 line (the map's
 *      dependsOn, via "abaplint") is pointed at --ref (default `main`); the
 *      file is rewritten as plain JSON, its comments dropped
 *   2. abaplint runs over each config of the entry's canary.lint
 *   3. when canary.rename is true, the repository's own `npm run rename` -
 *      the namespace rename clones the framework from the same configs, so it
 *      sees main too
 * abaplint only: no npm install of the consumer, no unit run, no browser.
 *
 *   node .github/scripts/ecosystem-canary.mjs --matrix
 *        the consumers as a GitHub Actions matrix (JSON on stdout)
 *   node .github/scripts/ecosystem-canary.mjs --repo <owner/name> --dir <checkout>
 *        [--ref main] [--abaplint <bin>] [--out <result.json>]
 *        one consumer; exit 1 when it breaks. --abaplint defaults to this
 *        repository's node_modules/.bin/abaplint
 *   node .github/scripts/ecosystem-canary.mjs --report <dir>
 *        the result files of a run as one Markdown report on stdout; with
 *        GITHUB_OUTPUT set it also writes failed=<count>
 *
 * (npm run ecosystem:canary -- <arguments>)
 */
import { spawnSync } from "node:child_process";
import { existsSync, mkdirSync, readFileSync, readdirSync, realpathSync, symlinkSync, writeFileSync, appendFileSync } from "node:fs";
import path from "node:path";
import { ROOT, loadMap, parseJsonc, abaplintDeps, is702 } from "./lib/ecosystem-map.mjs";

const args = process.argv.slice(2);
const arg = (name, fallback) => {
  const i = args.indexOf(name);
  return i >= 0 && args[i + 1] !== undefined ? args[i + 1] : fallback;
};
const map = loadMap();
const consumers = map.repos.filter((e) => e.status === "active" && e.canary);

if (args.includes("--matrix")) {
  const include = consumers.map((e) => ({ repo: e.repo, branch: e.defaultBranch, name: e.repo.split("/")[1] }));
  process.stdout.write(JSON.stringify({ include }));
  process.exit(0);
}

if (args.includes("--report")) {
  report(arg("--report"));
  process.exit(0);
}

const repo = arg("--repo");
const dir = arg("--dir") && path.resolve(arg("--dir"));
const ref = arg("--ref", "main");
const abaplint = path.resolve(arg("--abaplint", path.join(ROOT, "node_modules", ".bin", "abaplint")));
const out = arg("--out");
if (!repo || !dir) {
  console.error("usage: ecosystem-canary.mjs --repo <owner/name> --dir <checkout> [--ref main] [--abaplint <bin>] [--out <file>]");
  console.error("       ecosystem-canary.mjs --matrix | --report <dir>");
  process.exit(2);
}
const entry = consumers.find((e) => e.repo.toLowerCase() === repo.toLowerCase());
if (!entry) {
  console.error(`ecosystem-canary: ${repo} has no canary entry in .github/ecosystem.json`);
  process.exit(2);
}
if (!existsSync(abaplint)) {
  console.error(`ecosystem-canary: no abaplint at ${abaplint} - npm ci here, or pass --abaplint`);
  process.exit(2);
}

const result = { repo: entry.repo, branch: entry.defaultBranch, ref, rewrites: [], steps: [] };

/* 1. the pins */
const corePins = entry.dependsOn.filter((p) => p.via === "abaplint" && p.repo === map.core && !is702(p.ref));
const coreNames = [map.core, ...(map.repos.find((e) => e.repo === map.core).formerly ?? [])];
for (const file of [...new Set(corePins.map((p) => p.file))]) {
  const full = path.join(dir, file);
  if (!existsSync(full)) {
    result.steps.push({ name: `pin ${file}`, ok: false, tail: `${file} does not exist - .github/ecosystem.json is stale for ${entry.repo}` });
    continue;
  }
  const config = parseJsonc(readFileSync(full, "utf8"));
  const deps = coreNames.flatMap((n) => abaplintDeps(config, n));
  if (deps.length === 0) {
    result.steps.push({ name: `pin ${file}`, ok: false, tail: `${file} has no dependency on ${map.core} - .github/ecosystem.json is stale for ${entry.repo}` });
    continue;
  }
  for (const d of deps) {
    result.rewrites.push({ file, from: d.branch ?? null, to: ref });
    d.branch = ref;
  }
  writeFileSync(full, `${JSON.stringify(config, null, 2)}\n`);
}

/* 2. the lint */
const tail = (text, n = 40) => text.trim().split("\n").slice(-n).join("\n");
const run = (name, cmd, cmdArgs, env = {}) => {
  console.log(`\n=== ${entry.repo}: ${name}`);
  const r = spawnSync(cmd, cmdArgs, {
    cwd: dir,
    encoding: "utf8",
    maxBuffer: 1 << 28,
    env: { ...process.env, ...env },
  });
  // stderr first: abaplint writes its banner and clone log there, and the
  // findings to stdout - so the tail of the report ends on the findings.
  const text = `${r.stderr ?? ""}${r.stdout ?? ""}${r.error ? `\n${r.error.message}` : ""}`;
  console.log(tail(text, 200));
  result.steps.push({ name, ok: r.status === 0, tail: tail(text) });
};

if (result.steps.every((s) => s.ok)) {
  for (const config of entry.canary.lint) run(`abaplint ${config}`, abaplint, [config]);

  /* 3. the rename - the repository's own script, which finds abaplint as
   * node_modules/@abaplint/cli/abaplint (the shared rename.mjs, which starts
   * it with `node <cli>`), in node_modules/.bin (older rename scripts) or on
   * the PATH (an `abaplint ... --rename` script). The consumer's dependencies
   * are not installed, so all three are given the one abaplint this run lints
   * with: the package directory the --abaplint binary resolves into, linked
   * whole, so the cli finds its build next to it. */
  if (entry.canary.rename) {
    const modules = path.join(dir, "node_modules");
    const cliPackage = path.dirname(realpathSync(abaplint));
    if (!existsSync(path.join(modules, "@abaplint", "cli", "abaplint"))) {
      mkdirSync(path.join(modules, "@abaplint"), { recursive: true });
      symlinkSync(cliPackage, path.join(modules, "@abaplint", "cli"), "dir");
    }
    const bin = path.join(modules, ".bin");
    if (!existsSync(path.join(bin, "abaplint"))) {
      mkdirSync(bin, { recursive: true });
      symlinkSync(abaplint, path.join(bin, "abaplint"));
    }
    run("npm run rename", "npm", ["run", "rename", "--silent"], {
      PATH: `${path.dirname(abaplint)}${path.delimiter}${process.env.PATH}`,
    });
  }
}

result.ok = result.steps.length > 0 && result.steps.every((s) => s.ok);
if (out) writeFileSync(out, `${JSON.stringify(result, null, 2)}\n`);
console.log(`\necosystem-canary: ${entry.repo} against ${map.core}@${ref} - ${result.ok ? "OK" : "BROKEN"}`
  + ` (${result.steps.map((s) => `${s.name}: ${s.ok ? "ok" : "FAILED"}`).join(", ")})`);
process.exit(result.ok ? 0 : 1);

/* ----------------------------------------------------------- the report */

function report(resultDir) {
  const files = existsSync(resultDir)
    ? readdirSync(resultDir, { recursive: true }).filter((f) => String(f).endsWith(".json"))
    : [];
  const results = files.map((f) => JSON.parse(readFileSync(path.join(resultDir, String(f)), "utf8")));
  const byRepo = new Map(results.map((r) => [r.repo, r]));
  const lines = [];
  let failed = 0;
  lines.push(`Every consumer in \`.github/ecosystem.json\` with a \`canary\` entry, at its default branch, with its abaplint pins on ${map.core} pointed at \`main\` (in the CI workspace only).`);
  lines.push("");
  lines.push("| Consumer | Pins moved | Result |");
  lines.push("|---|---|---|");
  for (const e of consumers) {
    const r = byRepo.get(e.repo);
    if (!r) {
      failed += 1;
      lines.push(`| ${e.repo} | - | no result (the job did not finish) |`);
      continue;
    }
    if (!r.ok) failed += 1;
    const moved = [...new Set(r.rewrites.filter((w) => w.from !== w.to).map((w) => `${w.from ?? "default"} -> ${w.to}`))].join(", ") || "already main";
    const verdict = r.ok ? "OK" : `**broken**: ${r.steps.filter((s) => !s.ok).map((s) => s.name).join(", ")}`;
    lines.push(`| ${e.repo} | ${moved} | ${verdict} |`);
  }
  for (const r of results.filter((x) => !x.ok)) {
    lines.push("");
    lines.push(`### ${r.repo}`);
    for (const s of r.steps.filter((x) => !x.ok)) {
      lines.push("");
      lines.push(`\`${s.name}\`:`);
      lines.push("```");
      lines.push(s.tail.split("\n").slice(-25).join("\n"));
      lines.push("```");
    }
  }
  console.log(lines.join("\n"));
  if (process.env.GITHUB_OUTPUT) appendFileSync(process.env.GITHUB_OUTPUT, `failed=${failed}\n`);
}
