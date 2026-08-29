#!/usr/bin/env node
// verify-branches.mjs
// Compares the delivery trees a local build has put into tools/out/ against
// what is published in abap2UI5/frontend today - file for file, byte for
// byte. Run `npm run frontend:build` first; a branch with no build is
// skipped with a note.
//
// For the comparison to work byte for byte, the local copy is stamped just
// as the deploy stamps it (README banner and VERSION, see branch-stamp.mjs),
// and with the commit the published branch was built from.
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
const generated = out;

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

// A delivery branch is a few megabytes of ABAP; half a gigabyte is headroom
// that will not be reached, and a ceiling beats node's 1 MB default silently
// truncating a tree this compares byte for byte.
const MAX_ARCHIVE = 512 * 1024 * 1024;

function checkout(branch) {
    const dir = join(reference, branch);
    rmSync(dir, { recursive: true, force: true });
    mkdirSync(dir, { recursive: true });
    /* Two processes, no shell.
     *
     * The branch name comes from `process.argv` - the "[branch ...]" this
     * file's own usage line names - and went UNQUOTED into an `sh -c` string, so
     * `node tools/verify-branches.mjs "x; rm -rf ~"` ran the second half. The
     * directory was quoted with `JSON.stringify`, which is JSON quoting and
     * not shell quoting - inside double quotes a shell still expands `$foo`
     * and a backtick.
     *
     * Piping the archive through in memory needs no shell at all, and an
     * argument passed to `execFileSync` is an argument rather than syntax. */
    const archive = execFileSync("git", ["archive", `${REMOTE}/${branch}`], { cwd: core, maxBuffer: MAX_ARCHIVE });
    execFileSync("tar", ["-x", "-C", dir], { input: archive, maxBuffer: MAX_ARCHIVE });
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
        console.log(`${branch}: SKIPPED - tools/out/${branch} does not exist (npm run frontend:build)`);
        continue;
    }
    const expected = publishedSha(branch);
    if (expected && expected !== head) {
        console.log(`${branch}: SKIPPED - published from ${expected.slice(0, 12)}, this tree is ${head.slice(0, 12)}`);
        continue;
    }
    // The local build, stamped just as the deploy stamps it - otherwise
    // README banner and VERSION always differ, and the comparison would look
    // red where there is nothing.
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
