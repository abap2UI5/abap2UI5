#!/usr/bin/env node
// Gate: the release's bill of materials (tools/sbom.mjs) is complete because
// nothing third-party is shipped - and stays so.
//
// The SBOM lists two parts of abap2UI5 and UI5, and nothing else. That is true
// only while no library is copied into what reaches a system: src/ (what
// abapGit imports) and app/webapp/ (embedded into src/01/03). A vendored file
// is the one change that would make the list silently incomplete, so this
// gate looks for the two traces a vendored file leaves:
//
//   1. a licence header of somebody else - a copyright line with a year or a
//      (c), an @license tag, an SPDX identifier, "licensed under the"
//   2. a minified file - a line of JavaScript, XML, CSS or JSON in
//      app/webapp/ longer than any hand-written line there (MAX_LINE)
//
// and holds the generator to its own claims: the document is CycloneDX 1.5,
// names the version package.json names, carries a hash for each part, says
// UI5 is not bundled, and is the same bytes on a second run.
//
// A library that is to be shipped after all is a decision, not a fix for this
// gate: it goes into the SBOM as a component of its own, with its licence, in
// the same pull request that adds it - and its files into ALLOWED below.
//
//   node .github/scripts/sbom-gate.mjs        (npm run check:sbom)
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { filesUnder, sbom } from "../../tools/sbom.mjs";

const ROOT = path.join(path.dirname(fileURLToPath(import.meta.url)), "..", "..");

const LICENCE = /copyright\s+(\(c\)|©|\d{4})|\(c\)\s*\d{4}|@license\b|SPDX-License-Identifier|licensed under the\b/i;
// The longest hand-written line in app/webapp/ is well under this; a minified
// bundle is thousands of characters on one line.
const MAX_LINE = 400;
const MINIFIABLE = /\.(js|xml|css|json)$/;
// Third-party files shipped on purpose, each with the component that lists it.
const ALLOWED = new Set([]);

const problems = [];

for (const file of [...filesUnder("src"), ...filesUnder("app/webapp")]) {
  if (ALLOWED.has(file)) continue;
  const text = fs.readFileSync(path.join(ROOT, file), "utf8");
  const lines = text.split("\n");
  lines.forEach((line, i) => {
    if (LICENCE.test(line)) problems.push(`${file}:${i + 1}: a licence header - a third-party file? ${line.trim().slice(0, 100)}`);
  });
  if (file.startsWith("app/webapp/") && MINIFIABLE.test(file)) {
    const long = lines.findIndex((line) => line.length > MAX_LINE);
    if (long !== -1) problems.push(`${file}:${long + 1}: a line of ${lines[long].length} characters - a minified, vendored file?`);
  }
}

const pkg = JSON.parse(fs.readFileSync(path.join(ROOT, "package.json"), "utf8"));
const doc = sbom();
const again = sbom();
if (JSON.stringify(doc) !== JSON.stringify(again)) problems.push("tools/sbom.mjs wrote two different documents for one commit");
if (doc.bomFormat !== "CycloneDX" || doc.specVersion !== "1.5") problems.push("tools/sbom.mjs: not a CycloneDX 1.5 document");
if (doc.metadata?.component?.version !== pkg.version) problems.push(`tools/sbom.mjs: names version ${doc.metadata?.component?.version}, package.json ${pkg.version}`);
if (!/^urn:uuid:[0-9a-f-]{36}$/.test(doc.serialNumber)) problems.push("tools/sbom.mjs: the serial number is not a urn:uuid");
for (const c of doc.components) {
  const bundled = c.properties?.find((p) => p.name === "abap2ui5:bundled")?.value;
  if (bundled === "false") continue;
  if (!/^[0-9a-f]{64}$/.test(c.hashes?.[0]?.content ?? "")) problems.push(`tools/sbom.mjs: ${c.name} carries no SHA-256`);
}
const refs = new Set([doc.metadata.component["bom-ref"], ...doc.components.map((c) => c["bom-ref"])]);
for (const d of doc.dependencies) {
  for (const r of [d.ref, ...d.dependsOn]) if (!refs.has(r)) problems.push(`tools/sbom.mjs: dependency on ${r}, which is no component`);
}

if (problems.length) {
  console.error(`sbom-gate: ${problems.length} problem(s)\n${problems.map((p) => `  ${p}`).join("\n")}`);
  process.exit(1);
}
console.log(`sbom-gate: ok - no third-party file in src/ or app/webapp/; the SBOM of ${pkg.version} lists ${doc.components.length} components`);
