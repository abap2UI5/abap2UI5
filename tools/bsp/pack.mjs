#!/usr/bin/env node
/*
 * pack.mjs - tools/bsp as the npm package @abap2ui5/bsp.
 *
 * The package is this folder as it is - no build, no dependencies - with the
 * version set to the framework's (root package.json; the committed
 * 0.0.0-set-at-pack is deliberate, as for @abap2ui5/node-runtime) and the
 * repository's LICENSE next to it. Assembled in a staging directory, so
 * nothing is written into the checkout but the tarball.
 *
 *   node tools/bsp/pack.mjs                  -> npm-package/abap2ui5-bsp-<version>.tgz
 *   node tools/bsp/pack.mjs --out <dir>      -> somewhere else
 *   node tools/bsp/pack.mjs --check          pack, then PROVE the tarball: install
 *     it into a scratch project the way an app would, and run the three commands
 *     through its bin and the API through its export. The listing says what the
 *     tarball holds; only an install says whether it works.
 */
import { execFileSync } from "node:child_process";
import { cpSync, mkdirSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const here = dirname(fileURLToPath(import.meta.url));
const root = resolve(here, "..", "..");
const NPM = process.platform === "win32" ? "npm.cmd" : "npm";

let outDir = join(root, "npm-package");
let check = false;
const args = process.argv.slice(2);
for (let i = 0; i < args.length; i += 1) {
  if (args[i] === "--out" && args[i + 1]) outDir = resolve(args[++i]);
  else if (args[i] === "--check") check = true;
  else {
    console.error(`pack: unknown argument ${JSON.stringify(args[i])}`);
    console.error("  usage: node tools/bsp/pack.mjs [--out <dir>] [--check]");
    process.exit(2);
  }
}

const run = (command, commandArgs, cwd) =>
  execFileSync(command, commandArgs, { cwd, encoding: "utf8", stdio: ["ignore", "pipe", "inherit"] });

const version = JSON.parse(readFileSync(join(root, "package.json"), "utf8")).version;
const manifest = JSON.parse(readFileSync(join(here, "package.json"), "utf8"));
const staging = mkdtempSync(join(tmpdir(), "abap2ui5-bsp-pack-"));
let tarball;
try {
  for (const file of manifest.files.filter((f) => f !== "LICENSE")) cpSync(join(here, file), join(staging, file), { recursive: true });
  cpSync(join(root, "LICENSE"), join(staging, "LICENSE"));
  writeFileSync(join(staging, "package.json"), JSON.stringify({ ...manifest, version }, null, 2) + "\n");
  mkdirSync(outDir, { recursive: true });
  const [{ filename }] = JSON.parse(run(NPM, ["pack", "--json", "--pack-destination", outDir], staging));
  tarball = join(outDir, filename);
  console.log(`pack: ${tarball}`);
} finally {
  rmSync(staging, { recursive: true, force: true });
}

if (check) {
  const scratch = mkdtempSync(join(tmpdir(), "abap2ui5-bsp-check-"));
  try {
    writeFileSync(join(scratch, "package.json"), '{ "private": true, "type": "module" }\n');
    run(NPM, ["install", tarball, "--no-audit", "--no-fund"], scratch);
    mkdirSync(join(scratch, "webapp", "view"), { recursive: true });
    writeFileSync(join(scratch, "webapp", "index.html"), "<!DOCTYPE html>\n<html></html>\n");
    writeFileSync(join(scratch, "webapp", "view", "Main.view.xml"), '<mvc:View xmlns:mvc="sap.ui.core.mvc"/>\n');

    const bin = join(scratch, "node_modules", ".bin", process.platform === "win32" ? "abap2ui5-bsp.cmd" : "abap2ui5-bsp");
    run(bin, ["app2bsp", "--name", "ZCHECK"], scratch);
    run(bin, ["check", "bsp"], scratch);
    run(bin, ["bsp2app", "bsp/src", "--out", "back"], scratch);
    const same = readFileSync(join(scratch, "back", "view", "Main.view.xml"), "utf8") === readFileSync(join(scratch, "webapp", "view", "Main.view.xml"), "utf8");
    if (!same) throw new Error("bsp2app did not give back view/Main.view.xml");

    writeFileSync(join(scratch, "api.mjs"), 'import { app2bsp, bsp2app, checkBsps } from "@abap2ui5/bsp";\nconsole.log([app2bsp, bsp2app, checkBsps].every((f) => typeof f === "function"));\n');
    if (run(process.execPath, ["api.mjs"], scratch).trim() !== "true") throw new Error("the package's export is incomplete");
    console.log(`pack: ${tarball} installs, its bin runs app2bsp, check and bsp2app, its export loads`);
  } finally {
    rmSync(scratch, { recursive: true, force: true });
  }
}
