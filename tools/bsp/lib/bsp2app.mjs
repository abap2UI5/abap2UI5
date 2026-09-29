// bsp2app.mjs - an abapGit BSP back to a UI5 app folder.
//
// The page directory (<bsp>.wapa.xml) names every page; each one is read
// from its page file and written under its own name, with the padding off
// (page.mjs says what that way back cannot restore). The path mapping is
// left out by default: it describes the BSP, not the app, and app2bsp
// writes it again.

import { existsSync, mkdirSync, readdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, join, resolve } from "node:path";
import { VALID_PAGE_NAME, pageFileName, toFile } from "./page.mjs";
import { MAPPING_PAGE } from "./app2bsp.mjs";

const unescapeXml = (value) =>
  value.replace(/&lt;/g, "<").replace(/&gt;/g, ">").replace(/&quot;/g, '"').replace(/&apos;/g, "'").replace(/&amp;/g, "&");

/** The page directories in `dir` - the `.wapa.xml` files, one per BSP. */
export function pageDirectories(dir) {
  return readdirSync(dir).filter((file) => file.endsWith(".wapa.xml")).sort();
}

/**
 * Reads one BSP's page directory: its name, its text and its pages, and the
 * prefix of its page files.
 */
export function readBsp(dir, descriptor) {
  const xml = readFileSync(join(dir, descriptor), "utf8");
  const field = (tag) => {
    const match = xml.match(new RegExp(`<${tag}>([^<]*)</${tag}>`));
    return match ? unescapeXml(match[1]) : "";
  };
  return {
    name: field("APPLNAME"),
    text: field("TEXT"),
    prefix: descriptor.slice(0, -"xml".length),
    pages: [...xml.matchAll(/<PAGENAME>([^<]+)<\/PAGENAME>/g)].map((m) => unescapeXml(m[1])),
  };
}

function findDescriptor(source, name) {
  const found = pageDirectories(source);
  if (name) {
    const wanted = `${name.toLowerCase()}.wapa.xml`;
    if (!found.includes(wanted)) throw new Error(`${source}: no BSP ${name.toUpperCase()} (${wanted})`);
    return wanted;
  }
  if (!found.length) throw new Error(`${source}: no BSP - no .wapa.xml page directory`);
  if (found.length > 1) {
    throw new Error(`${source}: ${found.length} BSPs (${found.join(", ")}) - name the one to convert`);
  }
  return found[0];
}

/**
 * Writes the pages of the BSP in `source` into `target` as an app folder.
 * `target` has to be empty or not exist yet, unless `overwrite` is set;
 * nothing in it is deleted either way.
 *
 *   name         which BSP, when `source` holds more than one
 *   keepMapping  write the path mapping page as well
 */
export function bsp2app({ source, target, name, keepMapping = false, overwrite = false }) {
  if (!existsSync(source)) throw new Error(`${source}: no such folder`);
  const bsp = readBsp(source, findDescriptor(source, name));
  if (!overwrite && existsSync(target) && readdirSync(target).length) {
    throw new Error(`${target} is not empty`);
  }

  const problems = [];
  const files = [];
  for (const page of bsp.pages) {
    if (!keepMapping && page.toLowerCase() === MAPPING_PAGE.toLowerCase()) continue;
    // a page name is a path below target - never let one leave it
    const out = resolve(target, page);
    if (!VALID_PAGE_NAME.test(page) || page.split("/").includes("..") || !out.startsWith(resolve(target))) {
      problems.push(`${page}: not a page name this can write`);
      continue;
    }
    const file = join(source, pageFileName(bsp.prefix, page));
    if (!existsSync(file)) {
      problems.push(`${page}: registered, but ${pageFileName(bsp.prefix, page)} is missing`);
      continue;
    }
    files.push([out, toFile(readFileSync(file, "utf8")), page]);
  }
  if (problems.length) {
    const error = new Error(`${source} cannot be converted:\n  ${problems.join("\n  ")}`);
    error.problems = problems;
    throw error;
  }

  for (const [out, content] of files) {
    mkdirSync(dirname(out), { recursive: true });
    writeFileSync(out, content, "utf8");
  }

  // files of this BSP that the directory does not register - the system
  // never received them, so they are no part of the app either
  const registered = new Set(bsp.pages.map((page) => pageFileName(bsp.prefix, page)));
  const unregistered = readdirSync(source).filter(
    (file) => file.startsWith(bsp.prefix) && file !== `${bsp.prefix}xml` && !registered.has(file),
  );
  return { name: bsp.name, text: bsp.text, pages: files.map(([, , page]) => page), unregistered };
}
