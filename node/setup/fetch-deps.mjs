#!/usr/bin/env node
// Pins the three git dependencies that abaplint and the transpiler would
// otherwise clone at floating HEAD on every run (the abaplint dependency
// config and abap_transpile.json only take a URL, so the same commit could
// lint/build green today and red tomorrow because an upstream moved - an
// agent then cannot tell its own change from upstream drift).
//
// Both tools check a local folder BEFORE falling back to the URL clone, so
// this script materializes each dependency at its pinned SHA under
// node/deps/<name>/ (gitignored). It is wired into `npm run check` and
// `npm run auto_transpile`; a no-op (~50ms) when everything is already at
// the pinned SHA. Without network and without node/deps the tools fall back
// to their old floating-clone behavior.
//
//   node node/setup/fetch-deps.mjs                 fetch/refresh the pins
//   node node/setup/fetch-deps.mjs --print-latest  show upstream HEADs (to bump)
//
// To bump a pin: run --print-latest, replace the sha below, run the script,
// then `npm run verify` - the bump is an ordinary reviewed commit.
import { execSync } from "node:child_process";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const ROOT = path.join(path.dirname(fileURLToPath(import.meta.url)), "..", "..");
const DEPS_DIR = path.join(ROOT, "node", "deps");

const PINS = [
  {
    name: "steampunk-2305-api-intersect-702",
    url: "https://github.com/abapedia/steampunk-2305-api-intersect-702",
    sha: "cf8ca6123601e503d6aa040e6f4dfe2d374904d6",
  },
  {
    name: "open-abap-core",
    url: "https://github.com/open-abap/open-abap-core",
    sha: "48335c7351ad72265f7272177e1e3e2fec259a16",
  },
  {
    name: "express-icf-shim",
    url: "https://github.com/open-abap/express-icf-shim",
    sha: "1835598128890620bd7e25021568f888cfe857d9",
  },
];

const run = (cmd, cwd) => execSync(cmd, { cwd, stdio: ["ignore", "pipe", "pipe"] }).toString().trim();

if (process.argv.includes("--print-latest")) {
  for (const p of PINS) {
    const head = run(`git ls-remote ${p.url} HEAD`).split("\t")[0];
    const mark = head === p.sha ? "(pinned = latest)" : `(pinned: ${p.sha})`;
    console.log(`${p.name}: ${head} ${mark}`);
  }
  process.exit(0);
}

let failures = 0;
for (const p of PINS) {
  const dir = path.join(DEPS_DIR, p.name);
  try {
    if (fs.existsSync(path.join(dir, ".git")) && run("git rev-parse HEAD", dir) === p.sha) {
      continue; // already at the pin
    }
    fs.rmSync(dir, { recursive: true, force: true });
    fs.mkdirSync(dir, { recursive: true });
    run("git init --quiet", dir);
    run(`git remote add origin ${p.url}`, dir);
    run(`git fetch --quiet --depth 1 origin ${p.sha}`, dir);
    run("git checkout --quiet --detach FETCH_HEAD", dir);
    console.log(`fetch-deps: ${p.name} @ ${p.sha.slice(0, 12)}`);
  } catch (e) {
    // no network / fetch failed: leave nothing half-checked-out behind so the
    // tools fall back to their URL clone instead of reading a broken folder
    fs.rmSync(dir, { recursive: true, force: true });
    failures++;
    console.error(`fetch-deps: WARN could not pin ${p.name} (${String(e.message).split("\n")[0]}) - tools will fall back to a floating clone`);
  }
}
if (!failures) console.log("fetch-deps: all dependencies at pinned SHAs");
