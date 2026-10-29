#!/usr/bin/env node
// The software bill of materials of a release: what goes into an SAP system
// when abap2UI5 is installed, as a CycloneDX 1.5 JSON document.
//
//   node tools/sbom.mjs [out.cdx.json]     (npm run sbom; stdout without a path)
//
// release.yaml attaches it to every release as `abap2ui5-<version>.cdx.json`,
// next to the source archives GitHub makes, so a review board gets the list
// with the version it reviews instead of a page that describes main.
//
// What is in it, and why it is short:
//
//   - the framework itself: the ABAP objects of src/ and the frontend of
//     app/webapp/ (embedded into src/01/03 as string constants, which is how
//     it reaches the system), each part with the SHA-256 of its files, so the
//     bytes a system imported can be held against the list
//   - UI5, the one thing it needs at runtime and does not carry: loaded by the
//     browser from the SAP system or a UI5 CDN, never bundled
//
// and nothing else, because nothing else is shipped: no third-party library is
// copied into src/ or app/webapp/. `.github/scripts/sbom-gate.mjs` holds the
// tree to that sentence on every pull request (a foreign licence header, a
// vendored minified file), so the list stays complete by construction rather
// than by somebody remembering it. The npm packages behind the CI and the
// generators are not in a system and not in this list; the npm package
// @abap2ui5/node-runtime has its own dependency list in its package.json.
//
// The document is a function of the commit: the timestamp is the commit's,
// the serial number is derived from version and commit, the hashes from the
// files. Two runs on one commit write the same bytes.
import { createHash } from "node:crypto";
import { execFileSync } from "node:child_process";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const ROOT = path.join(path.dirname(fileURLToPath(import.meta.url)), "..");

/** Every file under a directory, relative to ROOT, sorted. */
export function filesUnder(dir) {
  const out = [];
  const walk = (rel) => {
    for (const entry of fs.readdirSync(path.join(ROOT, rel), { withFileTypes: true })) {
      const child = path.posix.join(rel, entry.name);
      if (entry.isDirectory()) walk(child);
      else if (entry.isFile()) out.push(child);
    }
  };
  walk(dir);
  return out.sort();
}

/** SHA-256 over the files of a part: each path and its bytes, in path order. */
function treeHash(files) {
  const hash = createHash("sha256");
  for (const file of files) {
    hash.update(file);
    hash.update("\0");
    hash.update(fs.readFileSync(path.join(ROOT, file)));
    hash.update("\0");
  }
  return hash.digest("hex");
}

function git(...args) {
  try {
    return execFileSync("git", args, { cwd: ROOT, encoding: "utf8" }).trim();
  } catch {
    return "";
  }
}

/** A version-5-shaped UUID from a string, for a serial number that is the same on every run. */
function stableUuid(text) {
  const h = createHash("sha256").update(text).digest("hex");
  const variant = ((parseInt(h[16], 16) & 0x3) | 0x8).toString(16);
  return `${h.slice(0, 8)}-${h.slice(8, 12)}-5${h.slice(13, 16)}-${variant}${h.slice(17, 20)}-${h.slice(20, 32)}`;
}

export function sbom() {
  const pkg = JSON.parse(fs.readFileSync(path.join(ROOT, "package.json"), "utf8"));
  const version = pkg.version;
  const commit = git("rev-parse", "HEAD");
  const timestamp = git("log", "-1", "--format=%cI") || undefined;
  const ref = `pkg:github/abap2UI5/abap2UI5@${version}`;
  const repo = "https://github.com/abap2UI5/abap2UI5";

  const abap = filesUnder("src");
  const webapp = filesUnder("app/webapp");
  const part = (name, description, files, sub) => ({
    type: "library",
    "bom-ref": `${ref}#${sub}`,
    name,
    version,
    description,
    licenses: [{ license: { id: "MIT" } }],
    hashes: [{ alg: "SHA-256", content: treeHash(files) }],
    properties: [
      { name: "abap2ui5:path", value: sub },
      { name: "abap2ui5:files", value: String(files.length) },
      { name: "abap2ui5:hash-method", value: "SHA-256 over each file's path, NUL, bytes, NUL, in path order" },
    ],
  });

  return {
    bomFormat: "CycloneDX",
    specVersion: "1.5",
    serialNumber: `urn:uuid:${stableUuid(`${version}:${commit}`)}`,
    version: 1,
    metadata: {
      ...(timestamp ? { timestamp } : {}),
      tools: { components: [{ type: "application", name: "tools/sbom.mjs", version }] },
      component: {
        type: "framework",
        "bom-ref": ref,
        name: "abap2UI5",
        version,
        description: "UI5 apps written in ABAP: the framework's ABAP objects and the frontend embedded in them",
        licenses: [{ license: { id: "MIT" } }],
        purl: ref,
        externalReferences: [
          { type: "vcs", url: repo },
          { type: "website", url: "https://abap2ui5.github.io/docs/" },
          { type: "issue-tracker", url: `${repo}/issues` },
          { type: "security-contact", url: `${repo}/security/policy` },
          { type: "release-notes", url: `${repo}/releases/tag/${version}` },
        ],
        ...(commit ? { properties: [{ name: "abap2ui5:commit", value: commit }] } : {}),
      },
    },
    components: [
      part("abap2UI5 ABAP objects", "The ABAP packages Z2UI5 (src/00-99) an abapGit pull imports", abap, "src"),
      part("abap2UI5 frontend", "The UI5 frontend, shipped inside the ABAP objects of src/01/03 as string constants", webapp, "app/webapp"),
      {
        type: "framework",
        "bom-ref": "ui5",
        name: "UI5 (OpenUI5 or SAPUI5)",
        version: ">=1.71",
        scope: "required",
        description:
          "Loaded by the browser at runtime, never shipped: from the SAP system's own SAPUI5 or a UI5 CDN, " +
          "by default OpenUI5 from sdk.openui5.org. The SAP system's SAPUI5 is licensed with the system.",
        licenses: [{ license: { id: "Apache-2.0" } }],
        externalReferences: [
          { type: "website", url: "https://openui5.org" },
          { type: "vcs", url: "https://github.com/SAP/openui5" },
        ],
        properties: [{ name: "abap2ui5:bundled", value: "false" }],
      },
    ],
    dependencies: [
      { ref, dependsOn: [`${ref}#src`, `${ref}#app/webapp`, "ui5"] },
      { ref: `${ref}#src`, dependsOn: [`${ref}#app/webapp`] },
      { ref: `${ref}#app/webapp`, dependsOn: ["ui5"] },
      { ref: "ui5", dependsOn: [] },
    ],
  };
}

if (process.argv[1] && fileURLToPath(import.meta.url) === path.resolve(process.argv[1])) {
  const text = `${JSON.stringify(sbom(), null, 2)}\n`;
  const out = process.argv[2];
  if (out) {
    fs.writeFileSync(out, text);
    console.log(`sbom: ${out}`);
  } else {
    process.stdout.write(text);
  }
}
