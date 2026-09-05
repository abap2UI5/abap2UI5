#!/usr/bin/env node
// check-pages.mjs
// Checks the invariants of a generated BSP tree on the ARTEFACT, not on the
// source it was made from. Every rule here stands for a failure that reached a
// real system, or came within one step of it:
//
//   line length  a page line over 255 characters is chopped into 255-character
//                chunks on the way in, and the chunks come back with newlines
//                between them - which splits JavaScript tokens and literals
//   page name    CL_O2_API_PAGES=>CREATE_NEW_PAGE rejects a name outside
//                [A-Za-z0-9_./] with sy-subrc=2 (invalid_name), and abapGit
//                then fails the WHOLE object import - the BSP never arrives
//   registration a webapp file missing from the page directory is skipped in
//                silence by the WAPA deserializer
//   parse        the .js pages have to survive the 255-character padding, so
//                they are parsed as stored, padding included
//
//     node tools/check-pages.mjs [tree ...]
//
// Without arguments every tree a build has put into tools/out/ is checked;
// a named tree is looked for there.

import { readdirSync, readFileSync, existsSync, statSync } from "node:fs";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";
import { Script } from "node:vm";

const here = dirname(fileURLToPath(import.meta.url));
// The one place build-branches.mjs writes to: the gitignored tools/out/. It
// used to be searched as a LIST of candidate roots - one entry, walked with
// map/find and flatMap/Set, from when a build could still land in .github/.
// One root reads as one root.
const OUT = join(here, "out");

const treeDir = (tree) => (existsSync(join(OUT, tree)) ? join(OUT, tree) : null);

const treesIn = (root) =>
    existsSync(root)
        ? readdirSync(root).filter((n) => !n.startsWith("_") && statSync(join(root, n)).isDirectory())
        : [];

const BSP_LINE_WIDTH = 255;
const VALID_PAGE_NAME = /^[A-Za-z0-9_./]+$/;

const problems = [];
const note = (tree, message) => problems.push(`${tree}: ${message}`);

function checkTree(tree) {
    const dir = treeDir(tree);
    if (!dir) {
        note(tree, "not built - run tools/build-branches.mjs first");
        return true;
    }
    // The cloud variants have a src/02 too - it holds ABAP, not a BSP. What
    // marks a BSP is the WAPA page directory.
    const src02 = join(dir, "src/02");
    if (!existsSync(src02)) return false;
    const descriptors = readdirSync(src02).filter((name) => name.endsWith(".wapa.xml")).sort();
    if (descriptors.length === 0) return false;
    // A BSP tree has exactly ONE page directory; two would mean a rename or
    // merge left an old one behind - and which one gets checked would hang on
    // the readdir order.
    if (descriptors.length > 1) {
        note(tree, `more than one .wapa.xml page directory: ${descriptors.join(", ")}`);
        return true;
    }
    const descriptor = descriptors[0];
    const prefix = descriptor.slice(0, -"xml".length);
    const xml = readFileSync(join(src02, descriptor), "utf8");
    const pages = [...xml.matchAll(/<PAGENAME>([^<]+)<\/PAGENAME>/g)].map((m) => m[1]);

    for (const page of pages) {
        if (!VALID_PAGE_NAME.test(page)) {
            note(tree, `page name "${page}" carries a character CREATE_NEW_PAGE rejects (invalid_name)`);
        }
        const file = join(src02, prefix + page.replace(/\//g, "_-").toLowerCase());
        if (!existsSync(file)) {
            note(tree, `page "${page}" is registered but has no content file`);
            continue;
        }
        const content = readFileSync(file, "utf8");
        content.split("\n").forEach((line, index) => {
            if (line.length > BSP_LINE_WIDTH) {
                note(tree, `${page} line ${index + 1} is ${line.length} characters (max ${BSP_LINE_WIDTH})`);
            }
        });
        if (page.endsWith(".js")) {
            // compiled in-process (same parser `node --check` used, minus a
            // process start per page - ~56 pages x 2-3 trees was 100+ spawns).
            // The SOURCE is the stored file, padding included, on purpose.
            try {
                new Script(content, { filename: page });
            } catch (error) {
                note(tree, `${page} is not valid JavaScript as stored (padding included) - ${String(error).split("\n")[0]}`);
            }
        }
    }

    // Every content file has to be registered, or it is silently dropped.
    const registered = new Set(pages.map((p) => prefix + p.replace(/\//g, "_-").toLowerCase()));
    for (const file of readdirSync(src02)) {
        if (!file.startsWith(prefix) || file === descriptor) continue;
        if (!registered.has(file)) note(tree, `${file} is not registered in ${descriptor}`);
    }
    console.log(`${tree}: ${pages.length} pages checked`);
    return true;
}

const trees = process.argv.slice(2).length ? process.argv.slice(2) : treesIn(OUT);

if (trees.length === 0) {
    console.error("check-pages: nothing to check - run tools/build-branches.mjs first");
    process.exit(1);
}
for (const tree of trees) {
    if (checkTree(tree)) continue;
    // a `standard*` tree without a BSP is not a variant without one - it is
    // the BSP packaging silently missing from the one delivery that exists
    // to carry it. Only the cloud variants legitimately have no WAPA pages.
    if (tree.startsWith("standard")) {
        note(tree, "no BSP found - a standard tree MUST carry the packaged BSP (src/02 with a .wapa.xml)");
    } else {
        console.log(`${tree}: no BSP in this variant`);
    }
}

if (problems.length) {
    console.error(`\ncheck-pages: ${problems.length} problem(s)`);
    for (const problem of problems) console.error(`  ${problem}`);
    process.exit(1);
}
console.log("check-pages: OK");
