#!/usr/bin/env node
/*
 * rename-run.mjs - the abaplint half of the namespace rename: the config
 * .github/abaplint/rename.jsonc with the placeholder prefix znamespace_
 * replaced, run with `abaplint --rename`, the renamed sources written to
 * .github/abaplint/output/src.
 *
 *   node .github/scripts/rename-run.mjs [<prefix>]     (default znamespace_,
 *        the worst case - what `npm run rename` checks; build-rename.yaml
 *        passes zmyui5_ or /ca2ui5/)
 *
 * Why not `abaplint .github/abaplint/rename.jsonc --rename` as before: from
 * @abaplint/cli 2.120.122 on, the rename output is <output>/<file relative
 * to the config's folder>. The config sits in .github/abaplint and the
 * sources two levels up, so the renamed tree went to
 * .github/abaplint/output/../../src = .github/src - outside the output
 * folder, where nothing looked for it (up to 2.120.121 it was
 * <output>/<absolute path>/src). The run config is therefore written at the
 * ROOT, its paths rebased onto the root, which gives <output>/src in every
 * version, and removed again after the run. rename.jsonc stays where it is
 * and as it is: abap2UI5/distributions reads it from there.
 *
 * The same reason, the same answer as the addons' rename.mjs
 * (.github/shared/rename.mjs), whose JSONC reader this uses.
 */
import { spawnSync } from "node:child_process";
import { existsSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { join, posix } from "node:path";
import { fileURLToPath } from "node:url";
import { parseJsonc } from "../shared/rename.mjs";

const ROOT = fileURLToPath(new URL("../../", import.meta.url));
const CONFIG_DIR = ".github/abaplint";
const OUTPUT = ".github/abaplint/output";
const RUN_CONFIG = join(ROOT, ".rename_run.json");
const prefix = process.argv[2] ?? "znamespace_";

const fail = (msg) => {
  console.error(`rename-run: ${msg}`);
  process.exit(1);
};

// a path of rename.jsonc ("/../../src/**/*.*") as the same path from the root
// ("/src/**/*.*")
const rebase = (p) => {
  const to = posix.normalize(posix.join(CONFIG_DIR, p.replace(/^\//, "")));
  if (to.startsWith("..")) fail(`${p} in rename.jsonc points outside the repository`);
  return `/${to}`;
};

const source = join(ROOT, CONFIG_DIR, "rename.jsonc");
const text = readFileSync(source, "utf8");
if (!text.includes("znamespace_")) fail("rename.jsonc carries no placeholder znamespace_");
const config = parseJsonc(text.split("znamespace_").join(prefix), source);

const files = config.global?.files;
config.global.files = Array.isArray(files) ? files.map(rebase) : rebase(files);
for (const d of config.dependencies ?? []) if (d.folder) d.folder = rebase(d.folder);
config.rename = { ...config.rename, output: OUTPUT };

const cli = join(ROOT, "node_modules/@abaplint/cli/abaplint");
if (!existsSync(cli)) fail("node_modules/@abaplint/cli not found - run npm ci first");
rmSync(join(ROOT, OUTPUT), { recursive: true, force: true });
writeFileSync(RUN_CONFIG, JSON.stringify(config, null, 2) + "\n");
let run;
try {
  run = spawnSync(process.execPath, [cli, RUN_CONFIG, "--rename"], { cwd: ROOT, stdio: "inherit" });
} finally {
  rmSync(RUN_CONFIG, { force: true });
}
if (run.error) fail(`abaplint did not run: ${run.error.message}`);
if (run.status !== 0) process.exit(run.status ?? 1);
if (!existsSync(join(ROOT, OUTPUT, "src"))) fail(`abaplint wrote no ${OUTPUT}/src`);
