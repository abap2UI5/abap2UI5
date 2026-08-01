// Generates .github/index/z2ui5_cl_xml_view.md - a flat, greppable map of every
// public method of z2ui5_cl_xml_view.
//
// Why: the class is ~16k lines (one fluent wrapper per UI5 control), far past
// what any reader - human or AI - loads in one go. The index answers the two
// questions that actually come up ("does a wrapper for control X already
// exist?" and "where is method Y?") from a single small file, so the class
// itself is only ever read at an offset.
//
// Run via `npm run xml_view_index`. CI enforces that the committed index
// matches the source (check_xml_view_index.yaml).

import { readFileSync, writeFileSync, mkdirSync } from "node:fs";
import { dirname } from "node:path";

const SOURCE = "src/99/z2ui5_cl_xml_view.clas.abap";
const TARGET = ".github/index/z2ui5_cl_xml_view.md";

// "! <p class="shorttext synchronized" lang="en">sap.m.Button</p>
const SHORTTEXT = /^\s*"!\s*<p class="shorttext synchronized"[^>]*>(.*?)<\/p>\s*$/;
const DECLARATION = /^\s+(?:CLASS-)?METHODS\s+([a-z_0-9]+)\s*$/i;
// Single-line declarations without parameters, e.g. `METHODS stringify.`
const DECLARATION_SHORT = /^\s+(?:CLASS-)?METHODS\s+([a-z_0-9]+)\s*\.\s*$/i;
const IMPLEMENTATION = /^\s*METHOD\s+([a-z_0-9]+)\s*\.\s*$/i;

const lines = readFileSync(SOURCE, "utf8").split("\n");

// The class body is split into the DEFINITION (declarations, with the abapdoc)
// and the IMPLEMENTATION. Only the public declarations matter for the index.
const publicStart = lines.findIndex((l) => /^\s+PUBLIC SECTION\.\s*$/.test(l));
const publicEnd = lines.findIndex((l) => /^\s+PROTECTED SECTION\.\s*$/.test(l));
if (publicStart === -1 || publicEnd === -1) {
  throw new Error(`${SOURCE}: could not locate PUBLIC/PROTECTED SECTION`);
}

const methods = [];
let shorttext = "";

for (let i = publicStart; i < publicEnd; i++) {
  const line = lines[i];

  const doc = line.match(SHORTTEXT);
  if (doc) {
    shorttext = doc[1].trim();
    continue;
  }

  const decl = line.match(DECLARATION_SHORT) || line.match(DECLARATION);
  if (decl) {
    methods.push({ name: decl[1].toLowerCase(), shorttext, declLine: i + 1 });
    shorttext = "";
    continue;
  }

  // A blank line between the abapdoc block and the next declaration would mean
  // the shorttext belongs to nothing - drop it rather than misattribute it.
  if (line.trim() === "") shorttext = "";
}

// Second pass: implementation line per method.
const implLine = new Map();
for (let i = publicEnd; i < lines.length; i++) {
  const impl = lines[i].match(IMPLEMENTATION);
  if (impl) implLine.set(impl[1].toLowerCase(), i + 1);
}

const missing = methods.filter((m) => !implLine.has(m.name));
if (missing.length) {
  throw new Error(
    `${SOURCE}: no implementation found for: ${missing.map((m) => m.name).join(", ")}`
  );
}

const nameWidth = Math.max(...methods.map((m) => m.name.length));

// The description runs last and is left unpadded: the file is meant to be
// grepped, and trailing padding across 450 rows is pure weight.
const rows = methods
  .sort((a, b) => a.name.localeCompare(b.name))
  .map(
    (m) =>
      `${m.name.padEnd(nameWidth)}  ${String(m.declLine).padStart(5)}  ` +
      `${String(implLine.get(m.name)).padStart(5)}  ${m.shorttext}`
  );

const header = `# z2ui5_cl_xml_view - method index

GENERATED FILE - do not edit by hand. Run \`npm run xml_view_index\` to
regenerate; \`check_xml_view_index.yaml\` fails the PR when it drifts.

\`${SOURCE}\` is ${lines.length} lines long, so never read it whole. Grep this
index for the method or the UI5 control, then read the class at the offset:

\`\`\`
Read ${SOURCE} offset=<impl> limit=60   # the implementation
Read ${SOURCE} offset=<decl> limit=60   # the signature and its abapdoc
\`\`\`

${methods.length} public methods (the protected \`xml_get_parts\` helper is not listed).

\`\`\`
${"method".padEnd(nameWidth)}   decl   impl  control / purpose
${"-".repeat(nameWidth)}  -----  -----  -----------------
`;

mkdirSync(dirname(TARGET), { recursive: true });
writeFileSync(TARGET, `${header}${rows.join("\n")}\n\`\`\`\n`);

console.log(`${TARGET}: ${methods.length} methods indexed from ${SOURCE}`);
