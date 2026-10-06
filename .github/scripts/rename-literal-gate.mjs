#!/usr/bin/env node
/*
 * rename-literal-gate — no object this repository ships is NAMED by a string
 * literal in production code, because a namespace rename does not rewrite one.
 *
 * `npm run rename` and the build-rename workflow turn every z2ui5 object into
 * <namespace>_… with `abaplint --rename` (.github/abaplint/rename.jsonc).
 * That rewrites every REFERENCE - a TYPE REF TO, a static call, an INTERFACES
 * - and leaves every string literal exactly as it was. Five literals in
 * src/00-src/02 named shipped objects for a dynamic lookup or a comparison,
 * and in a renamed installation every one of them asked for the ORIGINAL
 * name:
 *
 *   z2ui5_cl_ui5_action=>app_create          `Z2UI5_IF_APP` - every app start
 *                                             refused ("does not implement")
 *   z2ui5_cl_ui5_app_start (home page check) `Z2UI5_IF_APP` - the same
 *   z2ui5_cl_ui5_user_exit=>exit_class_lookup `Z2UI5_IF_UI5_EXIT`,
 *                                             `Z2UI5_IF_EXIT` - no exit found
 *   z2ui5_cl_ui5_srv_monitor                  `Z2UI5_IF_UI5_MONITOR` - no monitor
 *   z2ui5_cl_ui5_srv_model=>diss_oref         `Z2UI5_CL_UI5_CLIENT` - the client
 *                                             graph walked into every draft
 *   z2ui5_cl_ui5_util_context=>xml_srtti_descr `Z2UI5_CL_SRT_TYPEDESCR`
 *
 * abaplint, the transpiler and the unit suite are all green over that: in
 * THIS namespace the literal and the object agree. Only a renamed system sees
 * the difference. The fix at each site is a typed, unbound reference handed
 * to z2ui5_cl_ui5_util_context=>rtti_get_ref_type_name( ), which the rename
 * does rewrite; this gate keeps a new literal from coming back.
 *
 * What counts as naming an object: a literal (backtick, single quote, or a
 * text segment of a string template) whose whole text is a shipped object's
 * name - optionally behind `\CLASS=` / `\INTERFACE=` / `\TYPE=` and optionally
 * followed by a component (`~meth`, `=>attr`, `->attr`, `-comp`). Prose that
 * merely mentions a name ("does not implement z2ui5_if_app") is not a lookup
 * and is not decided here - write it from the derived name where it matters.
 * Names that are NOT shipped here (the sample tiles, the config addon) are
 * dynamic-name-gate.mjs's business: a rename of this repository does not
 * rename them either, so they stay correct.
 *
 * Scope: src/00-src/02 production code. Not test classes (the unit suite is
 * not what a renamed installation runs), not src/99 (frozen, never changed),
 * not src/01/03 (generated from app/webapp, where "z2ui5/..." module ids are
 * frontend names, not ABAP objects).
 *
 *   node .github/scripts/rename-literal-gate.mjs                    the sources
 *   node .github/scripts/rename-literal-gate.mjs --renamed <dir>    a rename
 *        output (`npm run rename` writes .github/abaplint/output): the same
 *        scan over the RENAMED tree, for any literal still naming an object
 *        by its original name - the direct proof, run after the rename step
 */
import { existsSync, readFileSync, readdirSync, statSync } from "node:fs";
import { join, relative } from "node:path";
import { fileURLToPath } from "node:url";
import { walk } from "./lib/walk.mjs";

const ROOT = fileURLToPath(new URL("../../", import.meta.url));

// every object the repository ships, by file name (abapGit derives the
// object name from it) - src/99 included: it ships, and the rename renames
// it like everything else (z2ui5_if_exit is named from src/01)
const shipped = new Set();
for (const file of walk(ROOT, "src")) {
  const base = file.slice(file.lastIndexOf("/") + 1);
  const match = base.match(/^(z2ui5_[a-z0-9_]+)\.(clas|intf|tabl)\.(abap|xml)$/);
  if (match) shipped.add(match[1].toUpperCase());
}

// production code under src/00-src/02, relative to the folder that holds them
const inScope = (rel) =>
  rel.endsWith(".abap") &&
  /^(00|01|02)\//.test(rel) &&
  !rel.startsWith("01/03/") &&
  !rel.endsWith(".testclasses.abap");

// the text pieces of one line that are string literals; nothing after a `"`
// comment, nothing of a `*` comment line, and of a string template only the
// text outside its `{ … }` embedded expressions
function literalsOf(line) {
  if (line.startsWith("*")) return [];
  const out = [];
  let i = 0;
  while (i < line.length) {
    const ch = line[i];
    if (ch === '"') break;
    if (ch === "`" || ch === "'") {
      let body = "";
      i++;
      while (i < line.length) {
        if (line[i] === ch && line[i + 1] === ch) {
          body += ch;
          i += 2;
        } else if (line[i] === ch) {
          break;
        } else {
          body += line[i++];
        }
      }
      out.push(body);
      i++;
      continue;
    }
    if (ch === "|") {
      let text = "";
      let depth = 0;
      i++;
      while (i < line.length) {
        const c = line[i];
        if (depth === 0 && c === "\\") {
          text += line[i + 1] ?? "";
          i += 2;
          continue;
        }
        if (depth === 0 && c === "|") break;
        if (c === "{") {
          if (depth === 0) {
            out.push(text);
            text = "";
          }
          depth++;
        } else if (c === "}") {
          depth--;
        } else if (depth === 0) {
          text += c;
        }
        i++;
      }
      out.push(text);
      i++;
      continue;
    }
    i++;
  }
  return out;
}

const NAMING = /^(?:\\(?:class|interface|type)=)?(z2ui5_[a-z0-9_]+)(?:(?:~|=>|->|-)\S*)?$/i;

function scan(base, label) {
  const findings = [];
  const files = walk(base, ".").map((f) => f.replace(/^\.\//, ""));
  let checked = 0;
  for (const rel of files.filter(inScope)) {
    checked++;
    const lines = readFileSync(join(base, rel), "utf8").split("\n");
    lines.forEach((line, index) => {
      for (const body of literalsOf(line)) {
        const match = body.trim().match(NAMING);
        if (match && shipped.has(match[1].toUpperCase())) {
          findings.push(`  ${label}${rel}:${index + 1}  ${body.trim()}`);
        }
      }
    });
  }
  return { findings, checked };
}

// the folder of a rename output that holds 00/01/02 - abaplint writes it
// below the workspace's absolute path, so it is searched, not assumed
function findRenamedSrc(dir) {
  if (existsSync(join(dir, "02")) && existsSync(join(dir, "01"))) return dir;
  for (const entry of readdirSync(dir)) {
    const sub = join(dir, entry);
    if (entry === ".git" || !statSync(sub).isDirectory()) continue;
    const hit = findRenamedSrc(sub);
    if (hit) return hit;
  }
  return null;
}

const at = process.argv.indexOf("--renamed");
let result;
let what;
if (at > -1) {
  const dir = process.argv[at + 1];
  const src = dir && existsSync(dir) ? findRenamedSrc(dir) : null;
  if (!src) {
    console.log(`rename-literal: no renamed src tree under '${dir ?? ""}' - run the rename first`);
    process.exit(1);
  }
  const shown = relative(ROOT, src).startsWith("..") ? src : relative(ROOT, src);
  what = `the renamed tree ${shown}`;
  result = scan(src, `${shown}/`);
} else {
  what = "src/00-src/02";
  result = scan(join(ROOT, "src"), "src/");
}

if (result.findings.length > 0) {
  console.log(`String literal(s) naming an object this repository ships, in ${what}:`);
  console.log("");
  for (const f of result.findings) console.log(f);
  console.log("");
  console.log("A namespace rename (abaplint --rename) rewrites references, never literals,");
  console.log("so a renamed installation would look these up under the ORIGINAL name.");
  console.log("Name the object through a typed, unbound reference instead:");
  console.log("  DATA li_x TYPE REF TO z2ui5_if_x.");
  console.log("  ... z2ui5_cl_ui5_util_context=>rtti_get_ref_type_name( li_x ) ...");
  process.exit(1);
}

console.log(
  `rename-literal: ${result.checked} file(s) of ${what} checked, no literal names a shipped object - OK`,
);
