#!/usr/bin/env node
// check-identity.mjs
// A system switches between the delivery branches by pulling another one
// into the same abapGit repository: standard -> standard_new and back,
// cloud -> cloud_v2 -> cloud_new. Whatever points at the installation from
// outside has to keep working across such a switch - a launchpad target
// mapping (component z2ui5, inbound z2ui5-display, URL
// /sap/bc/ui5_ui5/sap/z2ui5), a bookmark or a link from another system
// (/sap/bc/ui5_ui5/sap/z2ui5/index.html?app_start=..., /sap/bc/z2ui5), the
// sibling BSPs z2ui5_cci and z2ui5_ccc. So every branch keeps the deployment
// identity of the one it replaces, and this checks that on the built trees
// in tools/out/, against standard and cloud:
//
//   abapGit      .abapgit.xml, and every file of src/ that is not a BSP page
//                - packages, class, ICF nodes, HTTP service, IAM objects -
//                byte for byte. The one difference allowed: the handler of
//                the _new branches calls z2ui5_cl_ui5_http_handler, of which
//                the frozen z2ui5_cl_http_handler the others call is an empty
//                subclass
//   BSP          its attributes (name, class, text, ...), not its pages
//   manifest     sap.app/id, the data source (the endpoint), the inbounds,
//                sap.cloud, the services, the sibling resource roots
//   index.html   the component the page starts and its settings, the theme
//
//     node tools/check-identity.mjs
//
// Run after `npm run frontend:build` (`npm run check:frontend` does both).
// A branch that is not built is reported, not skipped.

import { existsSync, readdirSync, readFileSync } from "node:fs";
import { dirname, join, relative } from "node:path";
import { fileURLToPath } from "node:url";
import { readBsp } from "./bsp/lib/bsp2app.mjs";
import { pageFileName, toFile } from "./bsp/lib/page.mjs";

const here = dirname(fileURLToPath(import.meta.url));
const OUT = join(here, "out");

// each branch against the one whose installation it replaces
const PAIRS = [
  ["standard", ["standard_v2", "standard_new"]],
  ["cloud", ["cloud_v2", "cloud_new"]],
];

const HANDLER = "src/01/z2ui5_cl_lp_handler.clas.abap";
const sameCall = (source) => source.replace("z2ui5_cl_http_handler=>run(", "z2ui5_cl_ui5_http_handler=>run(");

const problems = [];
const note = (branch, message) => problems.push(`${branch}: ${message}`);

function files(dir) {
  return readdirSync(dir, { recursive: true, withFileTypes: true })
    .filter((entry) => entry.isFile())
    .map((entry) => relative(dir, join(entry.parentPath, entry.name)).split("\\").join("/"));
}

// src/ without the BSP pages - the page directory itself stays, its
// attributes are compared below
const abapFiles = (dir) =>
  existsSync(join(dir, "src"))
    ? files(dir).filter((f) => f.startsWith("src/") && !(/\.wapa\./.test(f) && !f.endsWith(".wapa.xml"))).sort()
    : [];

function bspDir(dir) {
  const src02 = join(dir, "src/02");
  if (!existsSync(src02)) return null;
  const descriptor = readdirSync(src02).find((f) => f.endsWith(".wapa.xml"));
  return descriptor ? { dir: src02, descriptor } : null;
}

// the page directory up to its pages: the BSP's own attributes
const bspAttributes = (xml) => xml.slice(0, xml.indexOf("<PAGES>"));

// what the app is - from the BSP's pages, or the Fiori project in app/
function appFile(dir, name) {
  const bsp = bspDir(dir);
  if (bsp) {
    const { prefix, pages } = readBsp(bsp.dir, bsp.descriptor);
    if (!pages.includes(name)) return null;
    return toFile(readFileSync(join(bsp.dir, pageFileName(prefix, name)), "utf8"));
  }
  const file = join(dir, "app/webapp", name);
  return existsSync(file) ? readFileSync(file, "utf8") : null;
}

function manifestIdentity(json) {
  const m = JSON.parse(json);
  const roots = m["sap.ui5"]?.resourceRoots ?? {};
  return {
    id: m["sap.app"]?.id,
    dataSources: m["sap.app"]?.dataSources,
    crossNavigation: m["sap.app"]?.crossNavigation,
    cloud: m["sap.cloud"],
    services: m["sap.ui5"]?.services,
    siblings: { z2ui5_cci: roots.z2ui5_cci, z2ui5_ccc: roots.z2ui5_ccc },
  };
}

// the attributes of the page that decide what starts, whatever the
// bootstrap around them looks like (the legacy-free one spells its own
// settings differently)
function pageIdentity(html) {
  const attr = (name) => new RegExp(`${name}=("[^"]*"|'[^']*')`).exec(html)?.[1] ?? null;
  return {
    component: attr("data-name"),
    id: attr("data-id"),
    settings: attr("data-settings"),
    theme: attr("data-sap-ui-theme"),
  };
}

function compare(branch, label, reference, candidate) {
  const a = JSON.stringify(reference);
  const b = JSON.stringify(candidate);
  if (a !== b) note(branch, `${label} differs\n      reference: ${a}\n      here:      ${b}`);
}

function checkPair(base, branch) {
  const ref = join(OUT, base);
  const dir = join(OUT, branch);
  for (const [name, path] of [[base, ref], [branch, dir]]) {
    if (!existsSync(path)) {
      note(name, "not built - run npm run frontend:build first");
      return;
    }
  }

  const read = (root, file) => readFileSync(join(root, file), "utf8");
  if (read(ref, ".abapgit.xml") !== read(dir, ".abapgit.xml")) note(branch, `.abapgit.xml differs from ${base}'s`);

  const refFiles = abapFiles(ref);
  const ownFiles = abapFiles(dir);
  for (const f of refFiles.filter((x) => !ownFiles.includes(x))) note(branch, `${f} of ${base} is missing - pulling ${branch} would delete it`);
  for (const f of ownFiles.filter((x) => !refFiles.includes(x))) note(branch, `${f} is not in ${base} - a new object`);
  for (const f of refFiles.filter((x) => ownFiles.includes(x))) {
    const a = read(ref, f);
    const b = read(dir, f);
    if (f.endsWith(".wapa.xml")) {
      if (bspAttributes(a) !== bspAttributes(b)) note(branch, `the attributes of the BSP (${f}) differ from ${base}'s`);
    } else if (f === HANDLER ? sameCall(a) !== sameCall(b) : a !== b) {
      note(branch, `${f} differs from ${base}'s`);
    }
  }

  for (const name of ["manifest.json", "index.html"]) {
    const a = appFile(ref, name);
    const b = appFile(dir, name);
    if (a === null || b === null) {
      note(a === null ? base : branch, `no ${name}`);
      continue;
    }
    if (name === "manifest.json") compare(branch, `manifest.json (against ${base})`, manifestIdentity(a), manifestIdentity(b));
    else compare(branch, `index.html (against ${base})`, pageIdentity(a), pageIdentity(b));
  }
}

let checked = 0;
for (const [base, branches] of PAIRS) {
  for (const branch of branches) {
    checkPair(base, branch);
    checked++;
  }
}

if (problems.length) {
  console.error(`check-identity: ${problems.length} problem(s) - a system switching branches would notice:\n`);
  for (const p of problems) console.error(`  ${p}`);
  process.exit(1);
}
console.log(`check-identity: ${checked} branch(es) keep the identity of standard and cloud - OK`);
