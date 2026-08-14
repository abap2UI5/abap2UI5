// Gate: every file under src/ survives a round trip through a real SAP system
// via abapGit - it imports, it activates, and re-serializing it produces the
// byte-identical file. Anything else shows up as an activation error or as a
// pull diff on a tree that CI called green.
//
// Why this exists as a gate and not as prose: none of it is visible here.
// abaplint parses ABAP, it does not model abapGit's file format, and its
// `global.files` covers only src/00, src/01, src/02 with `noIssues` on src/00 -
// so src/00 and src/99 get no byte-level check at all. The transpiler ignores
// the metadata sidecars entirely. Every rule below is a bug that reached main
// and had to be repaired after somebody pulled the repository into a system:
//
//   BOM          8e272492, 54bce5b6 "fix abapgit diffs" - a .clas.xml written
//                without the UTF-8 BOM abapGit emits. Re-serializing puts the
//                BOM back, so the file differs on every pull, forever.
//   EOF newline  c7185c38 "fix abapgit diffs" - z2ui5_if_action.intf.xml ended
//                without a final newline. Same permanent diff.
//   class_ctor   The static constructor must be declared in the PUBLIC section
//                (ABAP language rule). abaplint's constructor_visibility_public
//                only looks at the instance `constructor` - a PRIVATE
//                `class_constructor` passes every lint we run and fails on
//                activation. Worked around in z2ui5_cl_ui5_frontend (#2547),
//                see the ct_box_type comment there.
//
// The rest (CRLF, tabs, filename case, sidecar pairing, CLSNAME, LANGU,
// WITH_UNIT_TESTS) is the same class of defect and costs nothing to check, so
// it is checked over all of src/ rather than over abaplint's subset.
//
// Deliberately NOT here: trailing whitespace. abaplint's `whitespace_end`
// already owns it for src/01 and src/02, and src/00 (mirrored) and src/99
// (frozen) are excluded from lint on purpose - flagging their historical
// trailing blanks would produce ~100 findings nobody is allowed to fix.

import { readdirSync, readFileSync } from "fs";
import { join } from "path";

const ROOT = new URL("../../", import.meta.url).pathname;

const findings = [];
const add = (file, rule, message) => findings.push({ file, rule, message });

// ---------------------------------------------------------------- collect

function walk(dir, out = []) {
  for (const entry of readdirSync(join(ROOT, dir), { withFileTypes: true })) {
    const rel = `${dir}/${entry.name}`;
    if (entry.isDirectory()) walk(rel, out);
    else out.push(rel);
  }
  return out;
}

const files = walk("src").sort();
const dirs = [...new Set(files.map(f => f.slice(0, f.lastIndexOf("/"))))];

// The repository's master language, as abapGit records it. Every serialized
// object must carry the same one - an object created in a system logged on in
// another language serializes with that language and diffs against everyone.
const masterLanguage =
  readFileSync(join(ROOT, ".abapgit.xml"), "utf8").match(/<MASTER_LANGUAGE>([^<]*)<\/MASTER_LANGUAGE>/)?.[1] ?? "E";

// ------------------------------------------------------- byte-level format

const BOM = Buffer.from([0xef, 0xbb, 0xbf]);

for (const file of files) {
  const buf = readFileSync(join(ROOT, file));
  const hasBom = buf.subarray(0, 3).equals(BOM);

  if (file.endsWith(".xml") && !hasBom) {
    add(file, "bom", "abapGit writes its XML with a UTF-8 BOM - without it the file differs on every pull");
  }
  if (file.endsWith(".abap") && hasBom) {
    add(file, "bom", "abapGit writes ABAP source without a BOM - the BOM would land in the first source line");
  }

  if (buf.includes(0x0d)) {
    add(file, "crlf", "carriage return - abapGit reads and writes LF only");
  }

  const body = hasBom ? buf.subarray(3) : buf;
  if (body.length === 0) {
    add(file, "eof", "empty file");
  } else if (body[body.length - 1] !== 0x0a) {
    add(file, "eof", "no newline at end of file - abapGit terminates every line, so re-serializing adds one");
  } else if (body.length > 1 && body[body.length - 2] === 0x0a) {
    add(file, "eof", "blank line at end of file - abapGit writes exactly one terminating newline");
  }

  if (/\.(abap|xml)$/.test(file) && buf.includes(0x09)) {
    add(file, "tab", "tab character - the ABAP editor expands tabs, so the pulled source differs from this file");
  }

  const name = file.slice(file.lastIndexOf("/") + 1);
  if (name !== name.toLowerCase()) {
    add(file, "filename", "abapGit derives the object name from a lower-case file name");
  }
}

// -------------------------------------------------------- sidecar pairing

// Object types that are a source file plus a metadata sidecar. The include
// suffixes (.testclasses, .locals_def, .locals_imp, .macros) belong to the
// class pool and have no sidecar of their own.
const INCLUDE = /\.clas\.(testclasses|locals_def|locals_imp|macros)\.abap$/;

for (const file of files) {
  if (!/\.(clas|intf|prog|fugr)\.abap$/.test(file)) continue;
  if (INCLUDE.test(file)) continue;
  const sidecar = `${file.slice(0, -5)}.xml`;
  if (!files.includes(sidecar)) {
    add(file, "sidecar", `no ${sidecar.slice(sidecar.lastIndexOf("/") + 1)} - abapGit needs the metadata to create the object`);
  }
}

for (const file of files) {
  if (!/\.(clas|intf)\.xml$/.test(file)) continue;
  const source = `${file.slice(0, -4)}.abap`;
  if (!files.includes(source)) {
    add(file, "sidecar", "metadata without source - abapGit would create an empty object");
  }
}

for (const dir of dirs) {
  if (!files.includes(`${dir}/package.devc.xml`)) {
    add(dir, "package", "no package.devc.xml - abapGit cannot create the package this folder stands for");
  }
}

// --------------------------------------------------------- xml consistency

for (const file of files) {
  if (!/\.(clas|intf)\.xml$/.test(file)) continue;
  const xml = readFileSync(join(ROOT, file), "utf8");
  const name = file.slice(file.lastIndexOf("/") + 1).replace(/\.(clas|intf)\.xml$/, "");

  const clsname = xml.match(/<CLSNAME>([^<]*)<\/CLSNAME>/)?.[1];
  if (clsname !== undefined && clsname !== name.toUpperCase()) {
    add(file, "clsname", `<CLSNAME>${clsname}</CLSNAME> does not match the file name (${name.toUpperCase()})`);
  }

  const langu = xml.match(/<LANGU>([^<]*)<\/LANGU>/)?.[1];
  if (langu !== undefined && langu !== masterLanguage) {
    add(file, "langu", `<LANGU>${langu}</LANGU> is not the repository master language (${masterLanguage})`);
  }

  if (file.endsWith(".clas.xml")) {
    const hasTests = files.includes(`${file.slice(0, -9)}.clas.testclasses.abap`);
    const flagged = /<WITH_UNIT_TESTS>X<\/WITH_UNIT_TESTS>/.test(xml);
    if (hasTests && !flagged) {
      add(file, "unit-tests", "a .testclasses.abap exists - the sidecar needs <WITH_UNIT_TESTS>X</WITH_UNIT_TESTS>");
    }
    if (!hasTests && flagged) {
      add(file, "unit-tests", "<WITH_UNIT_TESTS>X</WITH_UNIT_TESTS> without a .testclasses.abap file");
    }
  }
}

// ------------------------------------------------- class_constructor is public

// The static constructor must sit in the PUBLIC section - a global class pool
// with a PRIVATE one does not activate. Read section by section, over every
// class definition in the file: an include holds many local classes, and a
// `CLASS ... DEFINITION` opens in the public section implicitly.
function classConstructorSections(source) {
  const bad = [];
  let section = null;
  let line = 0;
  for (const raw of source.split("\n")) {
    line += 1;
    const text = raw.replace(/".*$/, "").trim().toUpperCase();
    if (/^CLASS\s+\S+\s+DEFINITION\b/.test(text)) {
      // DEFERRED and LOCAL FRIENDS are announcements, not definitions
      if (/\b(DEFERRED|LOCAL\s+FRIENDS)\b/.test(text)) continue;
      section = "PUBLIC";
      continue;
    }
    if (/^(ENDCLASS|CLASS\s+\S+\s+IMPLEMENTATION)\b/.test(text)) {
      section = null;
      continue;
    }
    if (section === null) continue;
    if (/^PUBLIC\s+SECTION\b/.test(text)) section = "PUBLIC";
    else if (/^PROTECTED\s+SECTION\b/.test(text)) section = "PROTECTED";
    else if (/^PRIVATE\s+SECTION\b/.test(text)) section = "PRIVATE";
    // `CLASS-METHODS class_constructor.` and the chained `CLASS-METHODS:` form,
    // where the name can also open a continuation line
    else if (/(^|\s|:|,)CLASS_CONSTRUCTOR\s*[.,]/.test(text) && section !== "PUBLIC") {
      bad.push({ line, section });
    }
  }
  return bad;
}

for (const file of files) {
  if (!file.endsWith(".abap")) continue;
  const source = readFileSync(join(ROOT, file), "utf8");
  if (!/class_constructor/i.test(source)) continue;
  for (const { line, section } of classConstructorSections(source)) {
    add(
      `${file}:${line}`,
      "class-constructor",
      `class_constructor declared in the ${section} section - ABAP requires the static constructor to be PUBLIC, and the class pool does not activate without it`,
    );
  }
}

// ---------------------------------------------------------------- report

if (findings.length > 0) {
  console.log("abapGit round trip: these files do not come back unchanged from a real system.");
  console.log("");
  const byRule = new Map();
  for (const f of findings) {
    if (!byRule.has(f.rule)) byRule.set(f.rule, []);
    byRule.get(f.rule).push(f);
  }
  for (const [rule, group] of byRule) {
    console.log(`  [${rule}]`);
    for (const f of group) console.log(`    ${f.file}\n      ${f.message}`);
    console.log("");
  }
  console.log("Background and the fix for each rule: .claude/skills/abap-check/SKILL.md");
  process.exit(1);
}

console.log(`abapgit-format: ${files.length} file(s) in ${dirs.length} package(s) checked - OK`);
