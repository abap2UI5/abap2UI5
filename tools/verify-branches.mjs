#!/usr/bin/env node
// verify-branches.mjs
// Compares the committed delivery trees in build/ against what is published in
// abap2UI5/frontend today - file for file, byte for byte.
//
// Gebaut wird hier nichts mehr: build/ IST der Baum, den frontend_deploy
// pusht, und dass er zu den Quellen passt, prueft frontend_check
// (`npm run check:frontend`). Was hier laeuft, ist der andere Vergleich - der
// committete Baum gegen den, der draussen liegt. Damit das byteweise
// aufgeht, wird die Kopie wie beim Deploy gestempelt (README-Banner und
// VERSION, siehe branch-stamp.mjs), und zwar mit dem Commit, aus dem der
// veroeffentlichte Branch gebaut wurde.
//
// This is the acceptance test for the move of the frontend build into this
// repository: the branches are an INSTALLATION SOURCE. People's abapGit repos
// point at `cloud`, `cloud_v2`, `standard`, `standard_v2` and at renamed
// variants, so the tree a branch carries may not change just because the build
// moved. A difference here is either a regression or a deliberate content
// change that has to be argued for - never noise.
//
//     node tools/verify-branches.mjs [branch ...]
//
// Needs a git remote for the frontend repository; it is added on the fly as a
// read-only remote when missing. With no branch arguments the four published
// branches are checked. Exits non-zero on the first difference.

import { execFileSync } from "node:child_process";
import { cpSync, rmSync, mkdirSync, readdirSync, statSync, readFileSync, existsSync } from "node:fs";
import { join, dirname, relative } from "node:path";
import { fileURLToPath } from "node:url";
import { stamp } from "./branch-stamp.mjs";

const here = dirname(fileURLToPath(import.meta.url));
const core = join(here, "..");
const out = join(here, "out");
const reference = join(out, "_published");
const stamped = join(out, "_stamped");
const generated = join(core, "build");

const REMOTE = "frontend-published";
const REMOTE_URL = "https://github.com/abap2UI5/frontend.git";
const DEFAULT = ["cloud", "cloud_v2", "standard", "standard_v2"];

const git = (...args) => execFileSync("git", args, { cwd: core, encoding: "utf8" }).trim();

function ensureRemote() {
    const remotes = git("remote").split("\n");
    if (!remotes.includes(REMOTE)) git("remote", "add", REMOTE, REMOTE_URL);
}

// The published branch was built from ONE core commit - comparing against it
// only means anything when this working tree is that commit. The sha is in the
// branch's VERSION stamp.
function publishedSha(branch) {
    const stamp = git("show", `${REMOTE}/${branch}:VERSION`);
    return /abap2UI5\/abap2UI5@([0-9a-f]{40})/.exec(stamp)?.[1] ?? null;
}

function checkout(branch) {
    const dir = join(reference, branch);
    rmSync(dir, { recursive: true, force: true });
    mkdirSync(dir, { recursive: true });
    execFileSync("sh", ["-c", `git archive ${REMOTE}/${branch} | tar -x -C ${JSON.stringify(dir)}`], { cwd: core });
    return dir;
}

function filesIn(dir) {
    const found = [];
    const walk = (current) => {
        for (const entry of readdirSync(current, { withFileTypes: true })) {
            const full = join(current, entry.name);
            if (entry.isDirectory()) walk(full);
            else if (entry.isFile()) found.push(relative(dir, full));
        }
    };
    if (existsSync(dir)) walk(dir);
    return found.sort();
}

function compare(branch, built, published) {
    const a = new Set(filesIn(published));
    const b = new Set(filesIn(built));
    const differences = [];
    for (const file of [...a].filter((f) => !b.has(f))) differences.push(`missing:  ${file}`);
    for (const file of [...b].filter((f) => !a.has(f))) differences.push(`extra:    ${file}`);
    for (const file of [...a].filter((f) => b.has(f))) {
        if (!readFileSync(join(published, file)).equals(readFileSync(join(built, file)))) {
            const size = (dir) => statSync(join(dir, file)).size;
            differences.push(`content:  ${file} (published ${size(published)} bytes, built ${size(built)} bytes)`);
        }
    }
    return differences;
}

const branches = process.argv.slice(2).length ? process.argv.slice(2) : DEFAULT;
ensureRemote();
git("fetch", "--quiet", REMOTE, ...branches);

const head = git("rev-parse", "HEAD");
let failed = false;

for (const branch of branches) {
    if (!existsSync(join(generated, branch))) {
        console.log(`${branch}: SKIPPED - build/${branch} does not exist (npm run frontend:build)`);
        continue;
    }
    const expected = publishedSha(branch);
    if (expected && expected !== head) {
        console.log(`${branch}: SKIPPED - published from ${expected.slice(0, 12)}, this tree is ${head.slice(0, 12)}`);
        continue;
    }
    // Die committete Kopie, gestempelt wie beim Deploy - sonst unterscheiden
    // sich README-Banner und VERSION immer, und der Vergleich saehe rot aus,
    // wo nichts ist.
    const built = join(stamped, branch);
    rmSync(built, { recursive: true, force: true });
    mkdirSync(built, { recursive: true });
    cpSync(join(generated, branch), built, { recursive: true });
    stamp(built, branch, expected);

    const differences = compare(branch, built, checkout(branch));
    if (differences.length === 0) {
        console.log(`${branch}: identical to the published branch`);
    } else {
        failed = true;
        console.log(`${branch}: ${differences.length} difference(s)`);
        for (const line of differences.slice(0, 20)) console.log(`    ${line}`);
        if (differences.length > 20) console.log(`    ... and ${differences.length - 20} more`);
    }
}

rmSync(reference, { recursive: true, force: true });
rmSync(stamped, { recursive: true, force: true });
if (failed) process.exit(1);
