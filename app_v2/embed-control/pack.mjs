#!/usr/bin/env node
/*
 * pack.mjs - the control of app_v2/webapp/embed as the npm package
 * @abap2ui5/embed-control.
 *
 * The package is this folder's manifest, ui5.yaml, README and CHANGELOG
 * around the control's source, which is not kept here a second time: src/
 * of the package is app_v2/webapp/embed as it is. The version is the one
 * package.json names - the control has a release line of its own, apart
 * from the framework's (0.3.0 was the last one published from
 * abap2UI5/embed-control). Assembled in a staging directory, so nothing is
 * written into the checkout but the tarball.
 *
 *   node app_v2/embed-control/pack.mjs               -> npm-package/abap2ui5-embed-control-<version>.tgz
 *   node app_v2/embed-control/pack.mjs --out <dir>   -> somewhere else
 *
 * It packs and does not publish.
 */
import { execFileSync } from "node:child_process";
import { cpSync, mkdirSync, mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const here = dirname(fileURLToPath(import.meta.url));
const root = resolve(here, "..", "..");
const NPM = process.platform === "win32" ? "npm.cmd" : "npm";

let outDir = join(root, "npm-package");
const args = process.argv.slice(2);
for (let i = 0; i < args.length; i += 1) {
  if (args[i] === "--out" && args[i + 1]) outDir = resolve(args[++i]);
  else {
    console.error(`pack: unknown argument ${JSON.stringify(args[i])}`);
    console.error("  usage: node app_v2/embed-control/pack.mjs [--out <dir>]");
    process.exit(2);
  }
}

const staging = mkdtempSync(join(tmpdir(), "abap2ui5-embed-control-pack-"));
try {
  for (const file of ["package.json", "ui5.yaml", "README.md", "CHANGELOG.md"]) {
    cpSync(join(here, file), join(staging, file));
  }
  cpSync(join(root, "LICENSE"), join(staging, "LICENSE"));
  cpSync(join(here, "..", "webapp", "embed"), join(staging, "src"), { recursive: true });
  mkdirSync(outDir, { recursive: true });
  const out = execFileSync(NPM, ["pack", "--json", "--pack-destination", outDir], {
    cwd: staging,
    encoding: "utf8",
    stdio: ["ignore", "pipe", "inherit"],
    shell: process.platform === "win32",
  });
  const [{ filename }] = JSON.parse(out);
  console.log(`pack: ${join(outDir, filename)}`);
} finally {
  rmSync(staging, { recursive: true, force: true });
}
