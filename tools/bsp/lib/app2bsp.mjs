// app2bsp.mjs - a UI5 app folder as an abapGit BSP.
//
// Every file of the folder becomes a page of the BSP, in the format abapGit
// reads (page.mjs), and the page directory registers each of them: a file
// missing from it is skipped in silence by the WAPA deserializer. Next to
// the pages: the UI5 repository's path mapping, the two ICF nodes the BSP is
// served under, and optionally the package description.
//
// What cannot survive the way into the system is refused, with every case
// named, instead of written:
//   - a file name CREATE_NEW_PAGE rejects (Component-preload.js) - the whole
//     BSP would fail to import
//   - two files that map to one page file (Component.js and component.js)
//   - a binary file (an image, a font) - a page is text
//   - a line over 255 characters - the system cuts it into chunks and
//     serves them back with newlines in between, which breaks a JavaScript
//     token, a JSON string or an XML attribute

import { existsSync, mkdirSync, readdirSync, readFileSync, writeFileSync } from "node:fs";
import { join, relative, sep } from "node:path";
import { LINE_WIDTH, VALID_PAGE_NAME, pageFileName, toPage } from "./page.mjs";
import { bspName, sicfFileName } from "./names.mjs";

export const MAPPING_PAGE = "UI5RepositoryPathMapping.xml";
const START_PAGE = "index.html";
const BOM = "\uFEFF";

const escapeXml = (value) =>
  String(value).replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");

function filesIn(dir, base = dir) {
  const files = [];
  for (const entry of readdirSync(dir, { withFileTypes: true })) {
    const path = join(dir, entry.name);
    if (entry.isDirectory()) files.push(...filesIn(path, base));
    else if (entry.isFile()) files.push(relative(base, path).split(sep).join("/"));
  }
  return files;
}

const utf8 = new TextDecoder("utf-8", { fatal: true });
function textOf(buffer) {
  if (buffer.includes(0)) return null;
  try {
    return utf8.decode(buffer);
  } catch {
    return null;
  }
}

// abapGit's WAPA serializer writes the start page with its MIME type and
// every other page as a page (PAGETYPE X)
function pageItem(appl, pageName, startPage) {
  const typeLines =
    pageName === startPage
      ? ["      <MIMETYPE>text/html</MIMETYPE>", "      <IS_START_PAGE>X</IS_START_PAGE>"]
      : ["      <PAGETYPE>X</PAGETYPE>"];
  return [
    "    <item>",
    "     <ATTRIBUTES>",
    `      <APPLNAME>${appl}</APPLNAME>`,
    `      <PAGEKEY>${escapeXml(pageName.toUpperCase())}</PAGEKEY>`,
    `      <PAGENAME>${escapeXml(pageName)}</PAGENAME>`,
    ...typeLines,
    "      <LAYOUTLANGU>E</LAYOUTLANGU>",
    "      <VERSION>A</VERSION>",
    "      <LANGU>E</LANGU>",
    "     </ATTRIBUTES>",
    "    </item>",
  ].join("\n");
}

function wapaXml(appl, text, pageNames, startPage) {
  const sorted = [...pageNames].sort((a, b) =>
    a.toUpperCase() < b.toUpperCase() ? -1 : a.toUpperCase() > b.toUpperCase() ? 1 : 0,
  );
  return (
    BOM +
    [
      '<?xml version="1.0" encoding="utf-8"?>',
      '<abapGit version="v1.0.0" serializer="LCL_OBJECT_WAPA" serializer_version="v1.0.0">',
      ' <asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0">',
      "  <asx:values>",
      "   <ATTRIBUTES>",
      `    <APPLNAME>${appl}</APPLNAME>`,
      "    <APPLCLAS>/UI5/CL_UI5_BSP_APPLICATION</APPLCLAS>",
      `    <APPLEXT>${appl}</APPLEXT>`,
      "    <SECURITY>X</SECURITY>",
      "    <ORIGLANG>E</ORIGLANG>",
      "    <MODIFLANG>E</MODIFLANG>",
      `    <TEXT>${escapeXml(text)}</TEXT>`,
      "   </ATTRIBUTES>",
      "   <PAGES>",
      ...sorted.map((page) => pageItem(appl, page, startPage)),
      "   </PAGES>",
      "  </asx:values>",
      " </asx:abap>",
      "</abapGit>",
      "",
    ].join("\n")
  );
}

/**
 * The UI5 repository's path mapping, as the UI5 repository upload writes it:
 * one entry per folder and per file, in code-point order, every file stored
 * as a BSP page ("B") under its own path.
 */
export function pathMapping(files) {
  const paths = new Set();
  for (const file of files) {
    const parts = file.split("/");
    for (let i = 1; i < parts.length; i++) paths.add(parts.slice(0, i).join("/"));
    paths.add(file);
  }
  const folders = new Set([...paths].filter((p) => !files.includes(p)));
  const entry = (path) => {
    const folder = folders.has(path);
    return [
      "  <MappingEntry",
      `   path              = "${path}"`,
      `   is_folder         = "${folder ? "X" : ""}"`,
      `   internal_rep      = "${folder ? "" : "B"}"`,
      `   internal_rep_path = "${folder ? "" : path}" />`,
      "",
    ].join("\n");
  };
  return [
    '<?xml version="1.0"?>',
    "",
    '<UI5RepMapping version="1.0" xmlns="sap.ui5.tools.repository.mapping">',
    " <MappingEntries>",
    "",
    ...[...paths].sort().map(entry),
    " </MappingEntries>",
    "</UI5RepMapping>",
  ].join("\n");
}

function sicfXml(appl, url, docu) {
  return (
    BOM +
    [
      '<?xml version="1.0" encoding="utf-8"?>',
      '<abapGit version="v1.0.0" serializer="LCL_OBJECT_SICF" serializer_version="v1.0.0">',
      ' <asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0">',
      "  <asx:values>",
      `   <URL>${url}</URL>`,
      "   <ICFSERVICE>",
      `    <ICF_NAME>${appl}</ICF_NAME>`,
      `    <ORIG_NAME>${appl.toLowerCase()}</ORIG_NAME>`,
      "   </ICFSERVICE>",
      "   <ICFDOCU>",
      `    <ICF_NAME>${appl}</ICF_NAME>`,
      "    <ICF_LANGU>E</ICF_LANGU>",
      `    <ICF_DOCU>${escapeXml(docu)}</ICF_DOCU>`,
      "   </ICFDOCU>",
      "  </asx:values>",
      " </asx:abap>",
      "</abapGit>",
      "",
    ].join("\n")
  );
}

export function packageXml(text) {
  return (
    BOM +
    [
      '<?xml version="1.0" encoding="utf-8"?>',
      '<abapGit version="v1.0.0" serializer="LCL_OBJECT_DEVC" serializer_version="v1.0.0">',
      ' <asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0">',
      "  <asx:values>",
      "   <DEVC>",
      `    <CTEXT>${escapeXml(text)}</CTEXT>`,
      "   </DEVC>",
      "  </asx:values>",
      " </asx:abap>",
      "</abapGit>",
      "",
    ].join("\n")
  );
}

/** The ICF nodes a UI5 app in a BSP is served under. */
export const sicfUrls = (name) => [
  `/sap/bc/bsp/sap/${name.toLowerCase()}/`,
  `/sap/bc/ui5_ui5/sap/${name.toLowerCase()}/`,
];

/**
 * Reads the app folder and returns every problem that keeps it from being a
 * BSP, or the pages it would become.
 */
export function readApp(webapp) {
  if (!existsSync(webapp)) throw new Error(`${webapp}: no such folder`);
  const files = filesIn(webapp).sort();
  const problems = [];
  const pages = new Map();
  const targets = new Map();
  for (const file of files) {
    if (file.toLowerCase() === MAPPING_PAGE.toLowerCase()) {
      problems.push(`${file}: the path mapping is written by app2bsp - remove it from the app`);
      continue;
    }
    if (!VALID_PAGE_NAME.test(file)) {
      problems.push(
        `${file}: a BSP page name has only letters, digits, "_", "." and "/" - the system rejects this one, and with it the whole BSP`,
      );
    }
    const target = pageFileName("", file);
    if (targets.has(target)) {
      problems.push(`${file} and ${targets.get(target)} would be the same page file ("${target}")`);
    }
    targets.set(target, file);
    const text = textOf(readFileSync(join(webapp, file)));
    if (text === null) {
      problems.push(`${file}: not a UTF-8 text file - a BSP page is text, binary files are not supported`);
      continue;
    }
    text.split(/\r\n|\r|\n/).forEach((line, index) => {
      if (line.length > LINE_WIDTH) {
        problems.push(
          `${file}:${index + 1}: ${line.length} characters - the system cuts a line after ${LINE_WIDTH}, which breaks the file`,
        );
      }
    });
    pages.set(file, text);
  }
  if (!files.length) problems.push(`${webapp}: no files`);
  return { pages, problems };
}

/**
 * Writes the BSP for `webapp` into `target`, which has to be empty or not
 * exist yet. Throws with every problem at once when the app cannot become a
 * BSP (see the header).
 *
 *   name         the BSP name (ZMYAPP) - also the ICF node names
 *   text         the BSP's short text, as SE80 shows it
 *   icfText      the ICF nodes' description (default: text)
 *   packageText  writes package.devc.xml with this description when set
 *   mapping      true: generate the path mapping; a string: that page as it
 *                is (already in page format); false: none
 *   sicf         false: no ICF nodes
 */
export function app2bsp({
  webapp,
  target,
  name,
  text = "UI5 app",
  icfText,
  packageText,
  mapping = true,
  sicf = true,
}) {
  const appl = bspName(name);
  const { pages, problems } = readApp(webapp);
  if (problems.length) {
    const error = new Error(`${webapp} cannot become a BSP:\n  ${problems.join("\n  ")}`);
    error.problems = problems;
    throw error;
  }
  if (existsSync(target) && readdirSync(target).length) {
    throw new Error(`${target} is not empty`);
  }
  mkdirSync(target, { recursive: true });

  const prefix = `${appl.toLowerCase()}.wapa.`;
  const written = [];
  const write = (file, content) => {
    writeFileSync(join(target, file), content, "utf8");
    written.push(file);
  };
  for (const [file, content] of pages) write(pageFileName(prefix, file), toPage(content));

  const pageNames = [...pages.keys()];
  if (mapping) {
    const page = typeof mapping === "string" ? mapping : toPage(pathMapping(pageNames));
    write(pageFileName(prefix, MAPPING_PAGE), page);
    pageNames.push(MAPPING_PAGE);
  }
  write(`${appl.toLowerCase()}.wapa.xml`, wapaXml(appl, text, pageNames, START_PAGE));
  if (sicf) {
    for (const url of sicfUrls(appl)) write(sicfFileName(appl, url), sicfXml(appl, url, icfText ?? text));
  }
  if (packageText !== undefined) write("package.devc.xml", packageXml(packageText));
  return { name: appl, files: written.sort(), pages: pageNames };
}
