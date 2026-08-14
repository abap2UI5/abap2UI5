#!/usr/bin/env node
//
// rename-bsp.mjs - rename the abap2UI5 frontend BSP so it can be installed
// under a different name into the same SAP system (the way `frontend` is
// `Z2UI5` and `frontend-legacy-free` is `Z2UI5_V2`).
//
// The new name is either a plain name in the customer namespace (ZMYUI5) or
// a name in a registered /NS/ namespace:
//   * ZMYUI5      ->  BSP ZMYUI5,        handler ZMYUI5_CL_LP_HANDLER
//   * /ABAPGIT/   ->  BSP /ABAPGIT/UI5,  handler /ABAPGIT/CL_LP_HANDLER
//   * /ABAPGIT/X  ->  BSP /ABAPGIT/X,    handler /ABAPGIT/X_CL_LP_HANDLER
// (the abapGit file-name spelling #abapgit#ui5 is accepted as input too)
//
// WHAT IS RENAMED (the deployment identity - the things that collide in the
// SAP system when you try to install a second copy):
//   * BSP application object .................. Z2UI5      -> <NEW>
//   * SICF service nodes (3x) ................. /sap/bc/z2ui5, /sap/bc/bsp/sap/z2ui5,
//                                               /sap/bc/ui5_ui5/sap/z2ui5
//   * SMIM folder URL ......................... /SAP/BC/BSP/SAP/Z2UI5
//   * ICF handler class ....................... Z2UI5_CL_LP_HANDLER -> <NEW handler>
//   * manifest.json data source ............... /sap/bc/z2ui5  (points at the handler above)
//   * all on-disk file names .................. z2ui5.wapa.*, z2ui5_cl_lp_handler.*,
//                                               the SICF files (name field + URL hash);
//                                               "/" in namespaced object names becomes
//                                               "#" like abapGit serializes it
//
// For a namespaced name the SICF/SMIM paths follow the SAP convention for
// namespaced BSPs - the namespace replaces the "sap" path segment and is an
// ICF node of its own:
//   /sap/bc/bsp/sap/z2ui5      -> /sap/bc/bsp/abapgit/ui5
//   /sap/bc/ui5_ui5/sap/z2ui5  -> /sap/bc/ui5_ui5/abapgit/ui5
//   /sap/bc/z2ui5              -> /sap/bc/abapgit/ui5
// The namespace-level ICF nodes (/sap/bc/abapgit, ...) do not exist in a
// vanilla system, so the script GENERATES one extra .sicf.xml per parent
// node; abapGit creates them before the leaf nodes (alphabetical order).
// The /NS/ namespace itself must exist in the target system (SE03,
// changeable/with developer license) before pulling.
//
// WHAT IS DELIBERATELY KEPT (these are protocol contracts with the abap2UI5
// *backend*; renaming them breaks the app unless you also rebrand the backend):
//   * z2ui5_cl_http_handler ................... the backend framework class the handler calls
//   * the global runtime object `z2ui5` ....... window.z2ui5, z2ui5.oConfig, z2ui5[...]
//   * the event protocol constant `Z2UI5` ..... handlers map key in core/FrontendAction.js
//   * the UI5 framework namespace `z2ui5` ..... z2ui5/core/*, z2ui5/cc/*, custom controls
//                                               z2ui5.cc.* and the resourceroots key.
//     (legacy-free proves this: it renamed the BSP to z2ui5_v2 but KEPT the
//      controls as `z2ui5.*` and mapped resourceroots `"z2ui5": "./cc/"`,
//      because the backend-generated view XML references the z2ui5 namespace.)
//
// The optional --with-namespace flag ALSO rewrites the UI5 namespace
// (resourceroots, module paths, .extend(...), controllerName, custom controls,
// manifest id/viewPath/viewName). Only use it if you are rebranding the whole
// stack including the backend - otherwise custom controls and backend-generated
// views stop working. It is not available for /NS/ names (UI5 module ids
// cannot carry a SAP namespace).
//
// Usage:
//   node rename-bsp.mjs [NEW_NAME] [options]
//
// Options:
//   --dir <paths>        comma-separated roots to process (default: "src")
//   --with-namespace     also rewrite the UI5 namespace (advanced, see above)
//   --dry-run            show what would change, write nothing
//   --yes                skip the confirmation prompt
//   -h, --help           show this help
//
// Examples:
//   node rename-bsp.mjs ZMYUI5
//   node rename-bsp.mjs /abapgit/ --dry-run
//   node rename-bsp.mjs ZMYUI5 --with-namespace --yes
//

import { readFile, writeFile, rename, readdir, stat } from "node:fs/promises";
import { createHash } from "node:crypto";
import { join, basename, dirname } from "node:path";
import { createInterface } from "node:readline/promises";
import { stdin, stdout, argv, exit } from "node:process";

// ---------------------------------------------------------------------------
// The name that is currently baked into the repo.
// ---------------------------------------------------------------------------
const OLD_LO = "z2ui5";
const OLD_UP = "Z2UI5";
const OLD_HANDLER_LO = "z2ui5_cl_lp_handler";

// SICF on-disk file name layout used by abapGit: a 15-char left-justified
// ICF name field followed by a 25-char hash. The hash is the first 25 hex
// chars of SHA1 over the full ICF URL - e.g. sha1("/sap/bc/z2ui5/") starts
// with "aba643b150c02b2e28e7a7e17". Renaming the node changes its URL, so
// the hash must be recomputed from the renamed <URL> or abapGit re-serializes
// the service under a different file name after the pull (-> permanent diff).
const SICF_NAME_FIELD = 15;
const SICF_HASH_LEN = 25;

// Maximum length of an ICF service / BSP application name (for namespaced
// names this is the FULL name including the /NS/ slashes).
const MAX_NAME_LEN = 15;
// Maximum length of an ABAP class name (incl. namespace).
const MAX_CLASS_LEN = 30;
// Namespaces are registered with at most 8 characters between the slashes.
const MAX_NAMESPACE_LEN = 8;
// BSP object name used when only a namespace is given (/ABAPGIT/ -> /ABAPGIT/UI5).
const DEFAULT_NS_LEAF = "UI5";

// BSP pages (the z2ui5.wapa.<page> files under src/02 of the generated
// standard branches) are stored in the abapGit WAPA page format: every line
// space-padded to exactly 255 characters, longer lines wrapped into 255-char
// chunks, no trailing newline (see .github/app2bsp/run.js). A content edit
// changes line lengths, so edited page files must be re-padded afterwards.
const BSP_LINE_WIDTH = 255;

// ---------------------------------------------------------------------------
// Argument parsing
// ---------------------------------------------------------------------------
function parseArgs(args) {
  const opts = { dirs: ["src"], withNamespace: false, dryRun: false, yes: false, name: null, help: false };
  for (let i = 0; i < args.length; i++) {
    const a = args[i];
    if (a === "-h" || a === "--help") opts.help = true;
    else if (a === "--with-namespace") opts.withNamespace = true;
    else if (a === "--dry-run") opts.dryRun = true;
    else if (a === "--yes" || a === "-y") opts.yes = true;
    else if (a === "--dir") opts.dirs = (args[++i] || "").split(",").map((s) => s.trim()).filter(Boolean);
    else if (a.startsWith("-")) { console.error(`Unknown option: ${a}`); exit(2); }
    else if (opts.name === null) opts.name = a;
    else { console.error(`Unexpected argument: ${a}`); exit(2); }
  }
  return opts;
}

const HELP = `rename-bsp.mjs - rename the abap2UI5 frontend BSP (Z2UI5 -> <NEW>)

Usage:
  node rename-bsp.mjs [NEW_NAME] [options]

NEW_NAME is a plain name (ZMYUI5) or a name in a registered SAP namespace:
  /ABAPGIT/     ->  BSP /ABAPGIT/UI5, handler class /ABAPGIT/CL_LP_HANDLER
  /ABAPGIT/X    ->  BSP /ABAPGIT/X,   handler class /ABAPGIT/X_CL_LP_HANDLER
(#abapgit#ui5, the abapGit file-name spelling, is accepted as well)

Options:
  --dir <paths>        comma-separated roots to process (default: "src")
  --with-namespace     also rewrite the UI5 namespace (advanced; not for /NS/ names)
  --dry-run            show what would change, write nothing
  --yes                skip the confirmation prompt
  -h, --help           show this help

Renames the deployment identity (BSP object, SICF nodes, SMIM URL, handler
class, file names, manifest data source). For /NS/ names the SICF nodes move
to /sap/bc/<ns>/<name> etc. and the missing namespace-level ICF nodes are
generated; "/" becomes "#" in file names like abapGit serializes it. The UI5
framework namespace "z2ui5", the global "z2ui5" runtime object, the "Z2UI5"
event constant and the backend class z2ui5_cl_http_handler are KEPT, because
they are protocol contracts with the abap2UI5 backend. Use --with-namespace
only when you are rebranding the backend as well.`;

// ---------------------------------------------------------------------------
// Validation / name derivation
// ---------------------------------------------------------------------------
// Returns the full name set the transforms work with:
//   ns/nsLo ....... namespace without slashes (null for plain names)
//   up/lo ......... full BSP application name   (Z2UI5 / /ABAPGIT/UI5)
//   leafUp/leafLo . ICF node name, no slashes   (= up/lo for plain names)
//   handlerUp/Lo .. ICF handler class name
function deriveNames(input) {
  const name = input.trim().replace(/#/g, "/"); // accept the abapGit file-name spelling
  const warnings = [];

  const nsMatch = /^\/([A-Za-z0-9][A-Za-z0-9_]*)\/([A-Za-z][A-Za-z0-9_]*)?$/.exec(name);
  if (nsMatch) {
    const ns = nsMatch[1].toUpperCase();
    if (ns.length > MAX_NAMESPACE_LEN) {
      throw new Error(`Namespace "/${ns}/" is ${ns.length} chars; max ${MAX_NAMESPACE_LEN} between the slashes.`);
    }
    const leafUp = (nsMatch[2] || DEFAULT_NS_LEAF).toUpperCase();
    const up = `/${ns}/${leafUp}`;
    if (up.length > MAX_NAME_LEN) {
      throw new Error(`Name "${up}" is ${up.length} chars; max ${MAX_NAME_LEN} (ICF service / BSP name limit, incl. namespace).`);
    }
    // /NS/ alone: the handler is the only class, so it needs no BSP prefix
    const handlerUp = nsMatch[2] ? `/${ns}/${leafUp}_CL_LP_HANDLER` : `/${ns}/CL_LP_HANDLER`;
    if (handlerUp.length > MAX_CLASS_LEN) {
      throw new Error(`Handler class "${handlerUp}" is ${handlerUp.length} chars; max ${MAX_CLASS_LEN} (ABAP class name limit).`);
    }
    warnings.push(`namespace /${ns}/ must exist in the target system (SE03, with a developer/changeable license) before the abapGit pull.`);
    return {
      ns, nsLo: ns.toLowerCase(),
      up, lo: up.toLowerCase(),
      leafUp, leafLo: leafUp.toLowerCase(),
      handlerUp, handlerLo: handlerUp.toLowerCase(),
      warnings,
    };
  }

  if (name.includes("/")) {
    throw new Error(`Invalid name "${name}": a namespaced name must look like /NS/ or /NS/NAME (e.g. /ABAPGIT/ or /ABAPGIT/UI5).`);
  }
  if (!/^[A-Za-z][A-Za-z0-9_]*$/.test(name)) {
    throw new Error(`Invalid name "${name}": must start with a letter and contain only letters, digits or "_" (or /NS/NAME for a namespaced name).`);
  }
  if (name.length > MAX_NAME_LEN) {
    throw new Error(`Name "${name}" is ${name.length} chars; max ${MAX_NAME_LEN} (ICF service / BSP name limit).`);
  }
  const up = name.toUpperCase();
  const lo = name.toLowerCase();
  if (!/^[ZY]/.test(up)) {
    warnings.push(`"${up}" does not start with Z or Y - that is outside the SAP customer namespace.`);
  }
  return {
    ns: null, nsLo: null,
    up, lo,
    leafUp: up, leafLo: lo,
    handlerUp: `${up}_CL_LP_HANDLER`, handlerLo: `${lo}_cl_lp_handler`,
    warnings,
  };
}

// abapGit escapes the "/" of namespaced object names as "#" in file names.
const toFileName = (s) => s.replace(/\//g, "#");

// ---------------------------------------------------------------------------
// Content transforms (one per file category)
// ---------------------------------------------------------------------------
const escapeRe = (s) => s.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
const sicfHash = (url) => createHash("sha1").update(url).digest("hex").slice(0, SICF_HASH_LEN);

// The handler class token contains the BSP token as prefix, so it must be
// replaced FIRST - with a namespace the two are no longer prefix-compatible
// (Z2UI5_CL_LP_HANDLER -> /ABAPGIT/CL_LP_HANDLER, Z2UI5 -> /ABAPGIT/UI5).
function replaceHandler(content, N) {
  return content
    .split(OLD_HANDLER_LO.toUpperCase()).join(N.handlerUp)
    .split(OLD_HANDLER_LO).join(N.handlerLo);
}

// SICF node: URL, ICF_NAME/ORIG_NAME fields, handler class. For /NS/ names
// the namespace replaces the "sap" path segment (SAP convention for
// namespaced BSPs) and the remaining bare tokens are the ICF node name
// fields, which carry only the leaf name (no slashes allowed).
function transformSicf(content, N) {
  let c = replaceHandler(content, N);
  if (N.ns) {
    c = c
      .split(`/bsp/sap/${OLD_LO}/`).join(`/bsp/${N.nsLo}/${N.leafLo}/`)
      .split(`/ui5_ui5/sap/${OLD_LO}/`).join(`/ui5_ui5/${N.nsLo}/${N.leafLo}/`)
      .split(`/sap/bc/${OLD_LO}/`).join(`/sap/bc/${N.nsLo}/${N.leafLo}/`);
    return c.split(OLD_UP).join(N.leafUp).split(OLD_LO).join(N.leafLo);
  }
  return c.split(OLD_UP).join(N.up).split(OLD_LO).join(N.lo);
}

// SMIM folder: the MIME URL of a namespaced BSP is /SAP/BC/BSP/<NS>/<NAME>.
function transformSmim(content, N) {
  let c = replaceHandler(content, N);
  if (N.ns) {
    c = c
      .split(`/BSP/SAP/${OLD_UP}`).join(`/BSP/${N.ns}/${N.leafUp}`)
      .split(`/bsp/sap/${OLD_LO}`).join(`/bsp/${N.nsLo}/${N.leafLo}`);
  }
  return c.split(OLD_UP).join(N.up).split(OLD_LO).join(N.lo);
}

// BSP application descriptor (z2ui5.wapa.xml): APPLNAME/APPLEXT carry the
// full (possibly namespaced) application name.
function transformWapa(content, N) {
  return replaceHandler(content, N).split(OLD_UP).join(N.up).split(OLD_LO).join(N.lo);
}

// ABAP class source / metadata: rename ONLY our own handler class and KEEP
// the backend framework class z2ui5_cl_http_handler.
function transformClass(content, N) {
  return content.replace(new RegExp(OLD_HANDLER_LO, "gi"), (m) =>
    m === OLD_HANDLER_LO ? N.handlerLo : N.handlerUp);
}

// manifest.json: always repoint the data source at the renamed handler node.
// Under --with-namespace also rewrite the UI5 app namespace / FLP identifiers.
function transformManifest(content, N, withNamespace) {
  const target = N.ns ? `"/sap/bc/${N.nsLo}/${N.leafLo}"` : `"/sap/bc/${N.lo}"`;
  let out = content.replace(new RegExp(`"/sap/bc/${escapeRe(OLD_LO)}"`, "g"), target);
  if (withNamespace) {
    // every remaining z2ui5 in the manifest is a namespace / FLP identifier
    out = out.split(OLD_LO).join(N.lo);
  }
  return out;
}

// JS / view XML / fragment XML / index.html / css: only touched with
// --with-namespace. We rewrite the UI5 namespace strictly inside quoted
// module/namespace literals so the bare runtime global `z2ui5`, the `Z2UI5`
// event constant and keys like `z2ui5-xapp-state` are never affected.
function transformNamespace(content, NEW_LO) {
  return content
    .replace(new RegExp(`(["'])${escapeRe(OLD_LO)}/`, "g"), `$1${NEW_LO}/`) // "z2ui5/core/Lib"
    .replace(new RegExp(`(["'])${escapeRe(OLD_LO)}\\.`, "g"), `$1${NEW_LO}.`) // "z2ui5.cc.X", controllerName="z2ui5.controller.App"
    .replace(new RegExp(`(["'])${escapeRe(OLD_LO)}\\1`, "g"), `$1${NEW_LO}$1`) // "z2ui5"
    .replace(new RegExp(`module:${escapeRe(OLD_LO)}/`, "g"), `module:${NEW_LO}/`); // data-sap-ui-oninit="module:z2ui5/preload"
}

// A BSP page content file (fixed-width format, see BSP_LINE_WIDTH). The page
// directory z2ui5.wapa.xml is a normal abapGit XML and NOT in page format.
function isBspPageFile(name) {
  return name.startsWith(`${OLD_LO}.wapa.`) && name !== `${OLD_LO}.wapa.xml`;
}

// Re-pad a BSP page after a content edit. Only lines whose length deviates
// from 255 are touched (those are exactly the edited ones); an over-long line
// is re-wrapped into 255-char chunks like app2bsp/run.js does. Limitation:
// if the renamed token sits inside an already-wrapped logical line (>255
// chars) the chunk layout cannot be reconstructed - irrelevant in practice,
// since the only page edited without --with-namespace is the pretty-printed
// manifest.json whose lines are far below 255 chars.
function renormalizeBspPage(content) {
  const out = [];
  for (const line of content.split("\n")) {
    if (line.length === BSP_LINE_WIDTH) { out.push(line); continue; }
    const text = line.replace(/ +$/, "");
    if (text.length === 0) { out.push("".padEnd(BSP_LINE_WIDTH)); continue; }
    for (let o = 0; o < text.length; o += BSP_LINE_WIDTH) {
      out.push(text.slice(o, o + BSP_LINE_WIDTH).padEnd(BSP_LINE_WIDTH));
    }
  }
  return out.join("\n");
}

// Decide how a file's CONTENT must be transformed, based on its name.
function contentTransformFor(name, N, withNamespace) {
  const tf = rawTransformFor(name, N, withNamespace);
  if (tf && isBspPageFile(name)) return (c) => renormalizeBspPage(tf(c));
  return tf;
}

function rawTransformFor(name, N, withNamespace) {
  if (name.endsWith(".sicf.xml")) return (c) => transformSicf(c, N);
  if (name.endsWith(".smim.xml")) return (c) => transformSmim(c, N);
  if (name.endsWith(".wapa.xml")) return (c) => transformWapa(c, N); // BSP descriptor only
  if (name.endsWith(".clas.abap") || name.endsWith(".clas.xml")) return (c) => transformClass(c, N);
  if (name.endsWith("manifest.json")) return (c) => transformManifest(c, N, withNamespace);
  if (withNamespace && /\.(js|xml|html|css|json)$/.test(name)) return (c) => transformNamespace(c, N.lo);
  return null; // no content change
}

// ---------------------------------------------------------------------------
// File-name transform
// ---------------------------------------------------------------------------
// `content` is the (already transformed) file content - needed for SICF
// files, whose file-name hash is derived from the renamed <URL>.
function renamedBasename(name, N, content) {
  if (name.endsWith(".sicf.xml")) {
    const url = /<URL>([^<]+)<\/URL>/.exec(content ?? "")?.[1];
    const stem = name.slice(0, -".sicf.xml".length);
    const hash = url ? sicfHash(url) : stem.slice(-SICF_HASH_LEN); // no <URL> found: keep the old hash
    return N.leafLo.padEnd(SICF_NAME_FIELD, " ") + hash + ".sicf.xml";
  }
  const lower = name.toLowerCase();
  if (lower.startsWith(OLD_HANDLER_LO)) {
    return toFileName(N.handlerLo) + name.slice(OLD_HANDLER_LO.length);
  }
  if (lower.startsWith(OLD_LO)) {
    return toFileName(N.lo) + name.slice(OLD_LO.length);
  }
  return name; // GUID-named SMIM, package.devc.xml, ... keep
}

// ---------------------------------------------------------------------------
// Namespace-level ICF nodes (/NS/ names only)
// ---------------------------------------------------------------------------
// The renamed SICF leaf nodes live under /sap/bc/<ns>/, /sap/bc/bsp/<ns>/ and
// /sap/bc/ui5_ui5/<ns>/. Those parent nodes do not exist in a vanilla system
// and abapGit does not create intermediate nodes, so one .sicf.xml per parent
// is generated next to its leaf. abapGit pulls them before the leaves (its
// object list is sorted, "<ns>..." < "<leaf>..." only matters within one
// package - both land in the same one here).
function namespaceNodeFile(N, dir, parentUrl) {
  const content = `﻿<?xml version="1.0" encoding="utf-8"?>
<abapGit version="v1.0.0" serializer="LCL_OBJECT_SICF" serializer_version="v1.0.0">
 <asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0">
  <asx:values>
   <URL>${parentUrl}</URL>
   <ICFSERVICE>
    <ICF_NAME>${N.ns}</ICF_NAME>
    <ORIG_NAME>${N.nsLo}</ORIG_NAME>
   </ICFSERVICE>
   <ICFDOCU>
    <ICF_NAME>${N.ns}</ICF_NAME>
    <ICF_LANGU>E</ICF_LANGU>
    <ICF_DOCU>abap2UI5 - Namespace ${N.nsLo}</ICF_DOCU>
   </ICFDOCU>
  </asx:values>
 </asx:abap>
</abapGit>
`;
  const name = N.nsLo.padEnd(SICF_NAME_FIELD, " ") + sicfHash(parentUrl) + ".sicf.xml";
  return { path: join(dir, name), content };
}

// ---------------------------------------------------------------------------
// Directory walk
// ---------------------------------------------------------------------------
async function walk(dir, acc) {
  let entries;
  try {
    entries = await readdir(dir, { withFileTypes: true });
  } catch {
    return acc;
  }
  for (const e of entries) {
    const p = join(dir, e.name);
    if (e.isDirectory()) await walk(p, acc);
    else if (e.isFile()) acc.push(p);
  }
  return acc;
}

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------
async function main() {
  const opts = parseArgs(argv.slice(2));
  if (opts.help) { console.log(HELP); return; }

  let nameInput = opts.name;
  if (!nameInput) {
    const rl = createInterface({ input: stdin, output: stdout });
    nameInput = await rl.question("New BSP name (e.g. ZMYUI5 or /ABAPGIT/): ");
    rl.close();
  }

  let N;
  try {
    N = deriveNames(nameInput);
  } catch (err) {
    console.error(`\n  ${err.message}\n`);
    exit(1);
  }
  if (opts.withNamespace && N.ns) {
    console.error(`\n  --with-namespace cannot be combined with a /NS/ name: UI5 module ids cannot carry a SAP namespace.\n`);
    exit(1);
  }

  // Collect work.
  const files = [];
  for (const d of opts.dirs) await walk(d, files);
  if (files.length === 0) {
    console.error(`\n  No files found under: ${opts.dirs.join(", ")} (run from the repo root?)\n`);
    exit(1);
  }

  const contentChanges = [];
  const fileRenames = [];
  const fileCreates = []; // namespace-level ICF nodes, /NS/ names only
  const nsParentUrls = new Set();
  for (const path of files) {
    const name = basename(path);
    const tf = contentTransformFor(name, N, opts.withNamespace);
    let after = null;
    if (tf) {
      const before = await readFile(path, "utf8");
      after = tf(before);
      if (after !== before) contentChanges.push({ path, before, after });
    }
    const newName = renamedBasename(name, N, after);
    if (newName !== name) fileRenames.push({ path, to: join(dirname(path), newName) });
    if (N.ns && name.endsWith(".sicf.xml") && after) {
      // register the (new) parent namespace node of this renamed leaf
      const url = /<URL>([^<]+)<\/URL>/.exec(after)?.[1];
      const parentUrl = url?.replace(/[^/]+\/$/, "");
      if (parentUrl?.endsWith(`/${N.nsLo}/`) && !nsParentUrls.has(parentUrl)) {
        nsParentUrls.add(parentUrl);
        fileCreates.push({ ...namespaceNodeFile(N, dirname(path), parentUrl), url: parentUrl });
      }
    }
  }

  // Report.
  console.log(`\nRename abap2UI5 BSP:  ${OLD_UP}  ->  ${N.up}   (lowercase ${OLD_LO} -> ${N.lo})`);
  console.log(`ICF handler class:   ${OLD_HANDLER_LO.toUpperCase()}  ->  ${N.handlerUp}`);
  console.log(`Roots:               ${opts.dirs.join(", ")}`);
  console.log(`UI5 namespace:       ${opts.withNamespace ? `ALSO renamed (--with-namespace)` : "kept as z2ui5 (backend contract)"}`);
  for (const w of N.warnings) console.log(`  ! ${w}`);
  console.log(`\nContent edits (${contentChanges.length}):`);
  for (const c of contentChanges) console.log(`  ~ ${c.path}`);
  console.log(`\nFile renames (${fileRenames.length}):`);
  for (const r of fileRenames) console.log(`  > ${basename(r.path)}  ->  ${basename(r.to)}`);
  if (fileCreates.length) {
    console.log(`\nNew namespace-level ICF nodes (${fileCreates.length}):`);
    for (const f of fileCreates) console.log(`  + ${basename(f.path)}   (${f.url})`);
  }

  if (opts.withNamespace) {
    console.log(`\n  WARNING: --with-namespace rewrites the z2ui5 UI5 namespace (incl. custom`);
    console.log(`  controls z2ui5.cc.*). The abap2UI5 backend references that namespace in the`);
    console.log(`  view XML it generates - only use this if the backend is rebranded too.`);
  }

  if (contentChanges.length === 0 && fileRenames.length === 0 && fileCreates.length === 0) {
    console.log(`\nNothing to do.\n`);
    return;
  }
  if (opts.dryRun) {
    console.log(`\nDry run - nothing written.\n`);
    return;
  }
  if (!opts.yes) {
    const rl = createInterface({ input: stdin, output: stdout });
    const ans = (await rl.question(`\nApply these changes? [y/N] `)).trim().toLowerCase();
    rl.close();
    if (ans !== "y" && ans !== "yes") { console.log("Aborted."); return; }
  }

  // Apply: edit contents first (paths still original), then rename files,
  // then create the namespace nodes (their names collide with nothing).
  for (const c of contentChanges) await writeFile(c.path, c.after);
  for (const r of fileRenames) await rename(r.path, r.to);
  for (const f of fileCreates) await writeFile(f.path, f.content);

  console.log(`\nDone. ${contentChanges.length} files edited, ${fileRenames.length} files renamed` +
    (fileCreates.length ? `, ${fileCreates.length} namespace nodes created.` : `.`));
  console.log(`Review with "git status" / "git diff" before committing.\n`);
}

main().catch((err) => { console.error(err); exit(1); });
