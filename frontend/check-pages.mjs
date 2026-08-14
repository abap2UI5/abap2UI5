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
//     node frontend/check-pages.mjs [tree ...]     (default: every frontend/out/*)

import { readdirSync, readFileSync, existsSync, statSync } from "node:fs";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";
import { execFileSync } from "node:child_process";

const here = dirname(fileURLToPath(import.meta.url));
const out = join(here, "out");

const BSP_LINE_WIDTH = 255;
const VALID_PAGE_NAME = /^[A-Za-z0-9_./]+$/;

const problems = [];
const note = (tree, message) => problems.push(`${tree}: ${message}`);

function checkTree(tree) {
    // The cloud variants have a src/02 too - it holds ABAP, not a BSP. What
    // marks a BSP is the WAPA page directory.
    const src02 = join(out, tree, "src/02");
    if (!existsSync(src02)) return false;
    const descriptor = readdirSync(src02).find((name) => name.endsWith(".wapa.xml"));
    if (!descriptor) return false;
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
            try {
                execFileSync(process.execPath, ["--check", file], { stdio: "pipe" });
            } catch (error) {
                const detail = String(error.stderr ?? "").split("\n").find((l) => l.includes("Error")) ?? "";
                note(tree, `${page} is not valid JavaScript as stored (padding included) - ${detail.trim()}`);
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

const trees = process.argv.slice(2).length
    ? process.argv.slice(2)
    : (existsSync(out) ? readdirSync(out).filter((n) => !n.startsWith("_") && statSync(join(out, n)).isDirectory()) : []);

if (trees.length === 0) {
    console.error("check-pages: nothing to check - run frontend/build-branches.mjs first");
    process.exit(1);
}
for (const tree of trees) if (!checkTree(tree)) console.log(`${tree}: no BSP in this variant`);

if (problems.length) {
    console.error(`\ncheck-pages: ${problems.length} problem(s)`);
    for (const problem of problems) console.error(`  ${problem}`);
    process.exit(1);
}
console.log("check-pages: OK");
