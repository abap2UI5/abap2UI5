// check.mjs - the invariants of an abapGit BSP, checked on the artefact.
//
// The same rules as abap2UI5's tools/check-pages.mjs, which checks the
// delivery trees; every one stands for a failure that reached a real system:
//
//   page name     CREATE_NEW_PAGE rejects a name outside [A-Za-z0-9_./], and
//                 abapGit then fails the import of the whole BSP
//   line length   a page line over 255 characters comes back cut into
//                 chunks with newlines in between
//   registration  a page file missing from the page directory is skipped in
//                 silence by the WAPA deserializer
//   parse         a .js page has to be valid JavaScript as stored, padding
//                 included

import { existsSync, readdirSync, readFileSync, statSync } from "node:fs";
import { join, relative } from "node:path";
import { Script } from "node:vm";
import { LINE_WIDTH, VALID_PAGE_NAME, pageFileName } from "./page.mjs";
import { pageDirectories, readBsp } from "./bsp2app.mjs";

/** The problems of every BSP in `dir` (not below it). */
export function checkBspFolder(dir) {
  const problems = [];
  let pages = 0;
  for (const descriptor of pageDirectories(dir)) {
    const bsp = readBsp(dir, descriptor);
    const note = (message) => problems.push(`${bsp.name || descriptor}: ${message}`);
    for (const page of bsp.pages) {
      pages += 1;
      if (!VALID_PAGE_NAME.test(page)) {
        note(`page name "${page}" carries a character CREATE_NEW_PAGE rejects (invalid_name)`);
      }
      const file = join(dir, pageFileName(bsp.prefix, page));
      if (!existsSync(file)) {
        note(`page "${page}" is registered but has no content file`);
        continue;
      }
      const content = readFileSync(file, "utf8");
      content.split("\n").forEach((line, index) => {
        if (line.length > LINE_WIDTH) {
          note(`${page} line ${index + 1} is ${line.length} characters (max ${LINE_WIDTH})`);
        }
      });
      if (page.endsWith(".js")) {
        try {
          new Script(content, { filename: page });
        } catch (error) {
          note(`${page} is not valid JavaScript as stored (padding included) - ${String(error).split("\n")[0]}`);
        }
      }
    }
    const registered = new Set(bsp.pages.map((page) => pageFileName(bsp.prefix, page)));
    for (const file of readdirSync(dir)) {
      if (file.startsWith(bsp.prefix) && file !== descriptor && !registered.has(file)) {
        note(`${file} is not registered in ${descriptor}`);
      }
    }
  }
  return { problems, pages, bsps: pageDirectories(dir).length };
}

/** Every BSP in `root` and below, as { folder, problems, pages }. */
export function checkBsps(root) {
  const results = [];
  const walk = (dir) => {
    if (pageDirectories(dir).length) results.push({ folder: relative(root, dir) || ".", ...checkBspFolder(dir) });
    for (const entry of readdirSync(dir)) {
      if (entry === "node_modules" || entry.startsWith(".")) continue;
      const path = join(dir, entry);
      if (statSync(path).isDirectory()) walk(path);
    }
  };
  walk(root);
  return results;
}
