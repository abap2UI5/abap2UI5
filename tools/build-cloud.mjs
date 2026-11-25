#!/usr/bin/env node
// build-cloud.mjs
// Builds the tree of the branch `cloud` - abap2UI5 for ABAP Cloud (BTP ABAP
// environment, S/4HANA Public Cloud) - from this repository:
//
//   src/     src/ of main without src/03, and cloud/src/03 in its place
//   app/     app_source/ as a Fiori project to deploy, its backend URL
//            turned to the HTTP service
//   .abapgit.xml, abaplint.jsonc, README.md, LICENSE
//
// main is Standard ABAP in exactly one package: src/03 holds an ICF node, its
// handler on if_http_extension and a BSP, none of which exists on ABAP Cloud.
// There the same service is an HTTP service with a handler on
// if_http_service_extension and the IAM objects around it (cloud/src/03), and
// the app is deployed instead of pulled, because abapGit brings no UI5 app
// into such a system. Everything else - src/00 to src/02 - is the
// same code on both, which `npm run check:cloud` holds.
//
// Until 2026-11 this was the branch cloud_new of abap2UI5/frontend, a
// repository of its own next to the backend. The HTTP service and the IAM
// objects keep the names they had there; the handler is
// z2ui5_cl_ui5_icf_handler, as on main (z2ui5_cl_lp_handler until then).
//
// The tree is built into the git-ignored tools/out/cloud - nothing generated
// is committed here. auto-cloud.yaml builds it on every push to main and
// publishes it as the branch; the same build runs on a pull request
// (delivery-check.yaml, `npm run cloud:build`), so what is published has
// been built once before from the same sources.
//
// Usage:  node tools/build-cloud.mjs

import { cpSync, existsSync, mkdirSync, readFileSync, readdirSync, rmSync, writeFileSync } from "node:fs";
import { dirname, join, relative, sep } from "node:path";
import { fileURLToPath } from "node:url";

const here = dirname(fileURLToPath(import.meta.url));
const core = join(here, "..");
const out = join(here, "out", "cloud");

const read = (file) => readFileSync(join(core, file), "utf8");
const posix = (p) => p.split(sep).join("/");

// ---------------------------------------------------------------- src/

rmSync(out, { recursive: true, force: true });
mkdirSync(out, { recursive: true });

// The Standard-ABAP package stays behind as a whole, descriptor included:
// cloud/src/03 brings its own.
const STANDARD_ONLY = "src/03";
cpSync(join(core, "src"), join(out, "src"), {
  recursive: true,
  filter: (file) => {
    const rel = posix(relative(core, file));
    return rel !== STANDARD_ONLY && !rel.startsWith(`${STANDARD_ONLY}/`);
  },
});
if (!existsSync(join(core, "cloud", STANDARD_ONLY, "package.devc.xml"))) {
  throw new Error(`cloud/${STANDARD_ONLY}/package.devc.xml not found - the package the cloud branch puts in place of ${STANDARD_ONLY}`);
}
cpSync(join(core, "cloud", STANDARD_ONLY), join(out, STANDARD_ONLY), { recursive: true });

// ---------------------------------------------------------------- .abapgit.xml

// main's descriptor with the ABAP language version of the branch: abapGit
// then refuses to pull it into a package of another language version, and
// keeps the version on what it serializes. Guarded - a descriptor this does
// not recognise is not patched by guessing.
const LANGUAGE_VERSION = " <ABAP_LANGUAGE_VERSION>cloudDevelopment</ABAP_LANGUAGE_VERSION>\n";
const descriptor = read(".abapgit.xml");
const close = "  </DATA>";
if (descriptor.includes("ABAP_LANGUAGE_VERSION") || descriptor.split(close).length !== 2) {
  throw new Error(".abapgit.xml: expected one </DATA> and no ABAP_LANGUAGE_VERSION");
}
writeFileSync(join(out, ".abapgit.xml"), descriptor.replace(close, `  ${LANGUAGE_VERSION}${close}`));

// ---------------------------------------------------------------- app/

/* Where the backend lives is decided by the kind of deployment - the two
 * stacks publish the same service under different paths:
 *
 *   Standard ABAP   /sap/bc/z2ui5           the ICF node of src/03/01
 *   ABAP Cloud      /sap/bc/http/sap/z2ui5  the HTTP service Z2UI5
 *                                           (cloud/src/03/01/z2ui5.http.xml)
 *
 * app_source/webapp/manifest.json carries the first, because that is where
 * development happens and what the BSP is built from. Deployed unchanged to
 * a cloud system the app sends its requests to an ICF node that does not
 * exist there: 403 ICFEUCONFORBIDDEN, with no hint what about (#2602).
 *
 * The guard is the point: a replacement that no longer found its path would
 * deliver the on-premise URL again, and the error would come back as a 403
 * in a user's system instead of here in the build. */
const ONPREM_URI = "/sap/bc/z2ui5";
const CLOUD_URI = "/sap/bc/http/sap/z2ui5";

// What app_source is developed and checked with here, not what somebody
// deploying the app needs - and .env, git-ignored, which holds a developer's
// logon to a system.
const APP_DEV_ONLY = new Set(["node_modules", "dist", "README.md", "ui5lint.config.mjs", ".prettierrc", ".env"]);
const app = join(core, "app_source");
cpSync(app, join(out, "app"), {
  recursive: true,
  filter: (file) => !APP_DEV_ONLY.has(posix(relative(app, file)).split("/")[0]),
});

const manifestFile = join(out, "app/webapp/manifest.json");
const manifest = JSON.parse(readFileSync(manifestFile, "utf8"));
const backend = manifest["sap.app"]?.dataSources?.http;
if (backend?.uri !== ONPREM_URI) {
  throw new Error(
    `app_source/webapp/manifest.json: sap.app.dataSources.http.uri is ${JSON.stringify(backend?.uri)}, `
    + `expected ${JSON.stringify(ONPREM_URI)} - the cloud branch rewrites it to ${CLOUD_URI} `
    + "and must not ship a path it did not recognise",
  );
}
backend.uri = CLOUD_URI;
writeFileSync(manifestFile, JSON.stringify(manifest, null, 2) + "\n");

// ---------------------------------------------------------------- abaplint.jsonc

// The branch's own lint configuration, for whoever works on the branch and
// for auto-cloud, which lints the tree with it before publishing: all of
// src/ in the Cloud syntax, against the released APIs - and the three
// interfaces of the HTTP service handler (if_http_service_extension and the
// request and response it takes), which that dependency, the intersection
// with 7.02, does not have. open-abap-core carries them; only those three
// files are read from it, so nothing else of a second API definition
// resolves.
const ABAPLINT = {
  global: { files: "/src/**/*.*" },
  dependencies: [
    {
      url: "https://github.com/abapedia/steampunk-2305-api-intersect-702",
      folder: "/deps",
      files: "/src/**/*.*",
    },
    {
      url: "https://github.com/open-abap/open-abap-core",
      folder: "/deps-http",
      files: "/src/http/if_{http_service_extension,web_http_request,web_http_response}.intf.*",
    },
  ],
  syntax: { version: "Cloud", errorNamespace: "." },
  rules: {
    begin_end_names: true,
    check_ddic: true,
    check_include: true,
    check_syntax: true,
    global_class: true,
    implement_methods: true,
    method_implemented_twice: true,
    parser_error: true,
    superclass_final: true,
    unknown_types: true,
    xml_bom: true,
    xml_consistency: true,
  },
};
writeFileSync(join(out, "abaplint.jsonc"), JSON.stringify(ABAPLINT, null, 2) + "\n");

// ---------------------------------------------------------------- the rest

const BANNER =
  "> ⚙️ **Generated branch `cloud`** — built from `main` of "
  + "[abap2UI5/abap2UI5](https://github.com/abap2UI5/abap2UI5) by its `auto-cloud` workflow. "
  + "Do not commit here; change the source on `main`.\n\n";
writeFileSync(join(out, "README.md"), BANNER + read("cloud/README.md"));
cpSync(join(core, "LICENSE"), join(out, "LICENSE"));

const entries = readdirSync(out, { recursive: true }).length;
console.log(`OK: cloud (${entries} entries) -> ${posix(relative(core, out))}`);
