// Gate: a local test class that touches a PRIVATE or PROTECTED member of the
// class under test needs a `CLASS <global> DEFINITION LOCAL FRIENDS <ltcl>.`
// statement. Without it the class pool does not compile in a real SAP system.
//
// Why this exists as a gate and not as prose: neither abaplint nor the
// transpiler enforces visibility. The transpiler ignores it altogether (every
// member becomes a plain JS property), so `npm run unit` stays green on a class
// pool that a real system rejects with a syntax error. That is exactly how
// `ltcl_rtti` in z2ui5_cl_ui5_util_context reached main - it called the PRIVATE
// scan_flag_prefix( ) and had to be repaired after the fact.
//
// Deliberately limited to what can be decided from the source text alone:
// static access (`zcl_x=>member`) and instance access through a variable that
// is explicitly typed as the class under test. Anything reached dynamically or
// through a helper type is out of scope - the gate must not produce findings a
// developer cannot act on.
//
// A MEMBER is not only a method. `TYPES` and `ALIASES` are declarations with a
// visibility like any other, and a test class that names a PRIVATE type
// (`zcl_x=>ty_s_row`) needs the same LOCAL FRIENDS statement as one that calls
// a private method - the class pool does not activate without it either. The
// gate recorded neither until 2026-09, which left the widest hole exactly where
// it hurts most: the incident class this gate was WRITTEN for reaches a private
// type, so a test class of that shape passed here and failed on a real system.

import { globSync, readFileSync } from "fs";
import { basename, join } from "path";
import { fileURLToPath } from "url";

// cwd-independent on purpose - see assertion-gate.mjs, same failure mode
const ROOT = fileURLToPath(new URL("../../", import.meta.url));

const SECTIONS = { "PUBLIC SECTION": "PUBLIC", "PROTECTED SECTION": "PROTECTED", "PRIVATE SECTION": "PRIVATE" };

function parseVisibility(source) {
  // member name (lower case) -> section, for the definition part of the global class
  const members = new Map();
  let section = null;
  let inDefinition = false;
  let structDepth = 0;
  for (const raw of source.split("\n")) {
    const line = raw.trim().toUpperCase();
    if (!inDefinition) {
      if (/^CLASS\s+\S+\s+DEFINITION/.test(line)) {
        inDefinition = true;
        section = "PUBLIC";
      }
      continue;
    }
    if (line.startsWith("ENDCLASS")) break;
    const named = Object.keys(SECTIONS).find(s => line.startsWith(s));
    if (named) {
      section = SECTIONS[named];
      continue;
    }
    /* A structured block - `TYPES: BEGIN OF ty_s_x, … END OF ty_s_x.` and the
     * same shape for DATA/CONSTANTS. `BEGIN OF <name>` IS the member; its
     * components are not, because they are only reachable through it. Reading
     * them as members would put ordinary words (`NAME`, `REF`, `DATA`) into the
     * map with the block's visibility, and an unrelated `->name` in some test
     * class would become a finding nobody can act on. */
    const begin = line.match(/^(?:(?:CLASS-)?(?:TYPES|DATA|CONSTANTS)\b(?:\s*:)?\s+)?BEGIN\s+OF\s+(?:ENUM\s+)?([A-Z_0-9]+)/);
    if (begin) {
      if (structDepth === 0 && section && !members.has(begin[1].toLowerCase())) {
        members.set(begin[1].toLowerCase(), section);
      }
      structDepth += 1;
      continue;
    }
    if (/^END\s+OF\b/.test(line)) {
      if (structDepth > 0) structDepth -= 1;
      continue;
    }
    if (structDepth > 0) continue;
    /* TYPES and ALIASES are in this list for the reason the header gives: a
     * private TYPE named by a test class is the same activation error as a
     * private method called by one. The optional colon is what makes the FIRST
     * element of a chain (`TYPES: ty_a TYPE i,`) a declaration here rather than
     * a line the chained branch below has to guess at. */
    const declared = line.match(/^(CLASS-METHODS|METHODS|CLASS-DATA|DATA|CONSTANTS|CLASS-EVENTS|EVENTS|TYPES|ALIASES)\b(?:\s*:)?\s+([A-Z_0-9]+)/);
    if (declared) {
      if (!members.has(declared[2].toLowerCase())) members.set(declared[2].toLowerCase(), section);
      continue;
    }
    // continuation line of a chained declaration: `name TYPE ...` /
    // `name FOR TESTING` / the ALIASES form `name FOR intf~name`
    const chained = line.match(/^([A-Z_0-9]+)\s+(TYPE|LIKE|FOR|REDEFINITION|ABSTRACT|FINAL)\b/);
    if (chained && section && !members.has(chained[1].toLowerCase())) {
      members.set(chained[1].toLowerCase(), section);
    }
  }
  return members;
}

function parseFriends(source, globalClass) {
  const friends = new Set();
  const pattern = new RegExp(`CLASS\\s+${globalClass}\\s+DEFINITION\\s+LOCAL\\s+FRIENDS\\s+([^.]+)\\.`, "gi");
  for (const match of source.matchAll(pattern)) {
    for (const name of match[1].split(/[\s,]+/)) {
      if (name) friends.add(name.toLowerCase());
    }
  }
  return friends;
}

function parseInheritingClasses(source, globalClass) {
  // a local class inheriting from the class under test sees PROTECTED members
  const heirs = new Set();
  const pattern = new RegExp(`CLASS\\s+([A-Z_0-9]+)\\s+DEFINITION[^.]*INHERITING\\s+FROM\\s+${globalClass}\\b`, "gi");
  for (const match of source.matchAll(pattern)) heirs.add(match[1].toLowerCase());
  return heirs;
}

function parseRefVariables(source, globalClass) {
  // variables explicitly typed as the class under test
  const vars = new Set();
  const typed = new RegExp(`([A-Z_0-9]+)\\s+(?:TYPE|LIKE)\\s+REF\\s+TO\\s+${globalClass}\\b`, "gi");
  for (const match of source.matchAll(typed)) vars.add(match[1].toLowerCase());
  const inlineNew = new RegExp(`DATA\\(([A-Z_0-9]+)\\)\\s*=\\s*NEW\\s+${globalClass}\\s*\\(`, "gi");
  for (const match of source.matchAll(inlineNew)) vars.add(match[1].toLowerCase());
  return vars;
}

function currentLocalClass(lines, upto) {
  // the local class whose IMPLEMENTATION block contains line `upto`
  let current = null;
  for (let i = 0; i <= upto; i++) {
    const line = lines[i].trim().toUpperCase();
    const start = line.match(/^CLASS\s+([A-Z_0-9]+)\s+IMPLEMENTATION\b/);
    if (start) current = start[1].toLowerCase();
    else if (line.startsWith("ENDCLASS")) current = null;
  }
  return current;
}

/* One test class against its class under test. A function so the self-test
 * below can put synthetic sources through the SAME code path the real scan
 * uses - a self-test that exercised a copy of the logic would prove nothing
 * about the gate. */
function findingsFor(globalClass, definition, source) {
  const found = [];
  const members = parseVisibility(definition);
  const lines = source.split("\n");
  const friends = parseFriends(source, globalClass);
  const heirs = parseInheritingClasses(source, globalClass);
  const refVars = parseRefVariables(source, globalClass);

  const accessPatterns = [new RegExp(`${globalClass}=>([A-Z_0-9]+)`, "gi")];
  for (const variable of refVars) accessPatterns.push(new RegExp(`\\b${variable}->([A-Z_0-9]+)`, "gi"));

  for (let i = 0; i < lines.length; i++) {
    for (const pattern of accessPatterns) {
      pattern.lastIndex = 0;
      for (const match of lines[i].matchAll(pattern)) {
        const member = match[1].toLowerCase();
        const visibility = members.get(member);
        if (visibility !== "PRIVATE" && visibility !== "PROTECTED") continue;
        const local = currentLocalClass(lines, i);
        if (local === null) continue;
        if (friends.has(local)) continue;
        if (visibility === "PROTECTED" && heirs.has(local)) continue;
        found.push({ line: i + 1, local, member, visibility, globalClass });
      }
    }
  }
  return found;
}

/* Self-test: the detection, on sources written for it, before the tree is
 * scanned. A gate whose parser stops recognising a declaration goes SILENT -
 * it reports "no findings" over a member map that has lost the member, which
 * is the failure mode that let a private TYPE through for as long as this gate
 * has existed. A green run over the tree cannot tell that apart from a clean
 * tree; these cases can, and they cost microseconds.
 *
 * `expect` is `local:member` per finding, sorted. */
const SELF_TEST = [
  {
    name: "private method, no LOCAL FRIENDS - the case this gate was written for",
    definition: "CLASS zcl_x DEFINITION.\n  PUBLIC SECTION.\n  PRIVATE SECTION.\n    CLASS-METHODS helper.\nENDCLASS.",
    source: "CLASS ltcl DEFINITION FOR TESTING.\nENDCLASS.\nCLASS ltcl IMPLEMENTATION.\n  METHOD t. zcl_x=>helper( ). ENDMETHOD.\nENDCLASS.",
    expect: ["ltcl:helper"],
  },
  {
    name: "the same, with the LOCAL FRIENDS statement that repairs it",
    definition: "CLASS zcl_x DEFINITION.\n  PUBLIC SECTION.\n  PRIVATE SECTION.\n    CLASS-METHODS helper.\nENDCLASS.",
    source: "CLASS zcl_x DEFINITION LOCAL FRIENDS ltcl.\nCLASS ltcl DEFINITION FOR TESTING.\nENDCLASS.\nCLASS ltcl IMPLEMENTATION.\n  METHOD t. zcl_x=>helper( ). ENDMETHOD.\nENDCLASS.",
    expect: [],
  },
  {
    name: "private TYPES - a type is a member, and naming one needs LOCAL FRIENDS too",
    definition: "CLASS zcl_x DEFINITION.\n  PUBLIC SECTION.\n  PRIVATE SECTION.\n    TYPES ty_row TYPE string.\nENDCLASS.",
    source: "CLASS ltcl DEFINITION FOR TESTING.\nENDCLASS.\nCLASS ltcl IMPLEMENTATION.\n  METHOD t. DATA lv TYPE zcl_x=>ty_row. ENDMETHOD.\nENDCLASS.",
    expect: ["ltcl:ty_row"],
  },
  {
    name: "a private BEGIN OF block: the type is the member, its components are not",
    definition: [
      "CLASS zcl_x DEFINITION.",
      "  PUBLIC SECTION.",
      "    METHODS name.",
      "  PRIVATE SECTION.",
      "    TYPES:",
      "      BEGIN OF ty_s_row,",
      "        name TYPE string,",
      "      END OF ty_s_row.",
      "    TYPES ty_t_row TYPE STANDARD TABLE OF ty_s_row WITH EMPTY KEY.",
      "ENDCLASS.",
    ].join("\n"),
    source: "CLASS ltcl DEFINITION FOR TESTING.\nENDCLASS.\nCLASS ltcl IMPLEMENTATION.\n  METHOD t.\n    DATA lt TYPE zcl_x=>ty_t_row.\n    zcl_x=>name( ).\n  ENDMETHOD.\nENDCLASS.",
    expect: ["ltcl:ty_t_row"],
  },
  {
    name: "a chained private TYPES: every element of the chain is a member",
    definition: "CLASS zcl_x DEFINITION.\n  PUBLIC SECTION.\n  PRIVATE SECTION.\n    TYPES: ty_a TYPE i,\n           ty_b TYPE string.\nENDCLASS.",
    source: "CLASS ltcl DEFINITION FOR TESTING.\nENDCLASS.\nCLASS ltcl IMPLEMENTATION.\n  METHOD t.\n    DATA la TYPE zcl_x=>ty_a.\n    DATA lb TYPE zcl_x=>ty_b.\n  ENDMETHOD.\nENDCLASS.",
    expect: ["ltcl:ty_a", "ltcl:ty_b"],
  },
  {
    name: "a private ALIASES declaration is a member as well",
    definition: "CLASS zcl_x DEFINITION.\n  PUBLIC SECTION.\n  PRIVATE SECTION.\n    ALIASES run FOR zif_x~run.\nENDCLASS.",
    source: "CLASS ltcl DEFINITION FOR TESTING.\nENDCLASS.\nCLASS ltcl IMPLEMENTATION.\n  METHOD t. zcl_x=>run( ). ENDMETHOD.\nENDCLASS.",
    expect: ["ltcl:run"],
  },
  {
    name: "a PUBLIC type is nobody's business here",
    definition: "CLASS zcl_x DEFINITION.\n  PUBLIC SECTION.\n    TYPES ty_row TYPE string.\n  PRIVATE SECTION.\nENDCLASS.",
    source: "CLASS ltcl DEFINITION FOR TESTING.\nENDCLASS.\nCLASS ltcl IMPLEMENTATION.\n  METHOD t. DATA lv TYPE zcl_x=>ty_row. ENDMETHOD.\nENDCLASS.",
    expect: [],
  },
];

for (const testCase of SELF_TEST) {
  const got = findingsFor("zcl_x", testCase.definition, testCase.source)
    .map((f) => `${f.local}:${f.member}`)
    .sort();
  if (got.join(" ") !== [...testCase.expect].sort().join(" ")) {
    console.error(`Test class visibility: the gate's own self-test failed - "${testCase.name}"`);
    console.error(`  expected: ${testCase.expect.join(", ") || "(no finding)"}`);
    console.error(`  got:      ${got.join(", ") || "(no finding)"}`);
    console.error("");
    console.error("The detection changed. Until this case passes again, a green run over src/");
    console.error("says nothing - fix the parser, or the case if the expectation was wrong.");
    process.exit(1);
  }
}

const findings = [];

let scanned = 0;
for (const testFile of globSync(join(ROOT, "src/**/*.clas.testclasses.abap")).sort()) {
  scanned += 1;
  const globalClass = basename(testFile, ".clas.testclasses.abap");
  let definition;
  try {
    definition = readFileSync(testFile.replace(".clas.testclasses.abap", ".clas.abap"), "utf8");
  } catch {
    continue; // no class under test (e.g. an interface pool)
  }

  const source = readFileSync(testFile, "utf8");
  for (const f of findingsFor(globalClass, definition, source)) findings.push({ file: testFile, ...f });
}

if (findings.length > 0) {
  console.log("Local test classes access non-public members without LOCAL FRIENDS:");
  console.log("");
  for (const f of findings) {
    console.log(`  ${f.file}:${f.line}`);
    console.log(`    ${f.local} reads ${f.visibility} ${f.member}( ) of ${f.globalClass}`);
  }
  console.log("");
  const needed = new Map();
  for (const f of findings) needed.set(`${f.globalClass}|${f.local}`, f);
  console.log("Add before the IMPLEMENTATION block of the test class:");
  for (const f of needed.values()) {
    console.log(`  CLASS ${f.globalClass} DEFINITION LOCAL FRIENDS ${f.local}.`);
  }
  process.exit(1);
}

// zero scanned files means the glob found nothing - see assertion-gate.mjs
if (scanned === 0) {
  console.error("Test class visibility: no test classes found - nothing was checked");
  process.exit(1);
}

console.log(
  `Test class visibility: no findings (${scanned} test class file(s), `
  + `${SELF_TEST.length} self-test case(s) passed).`,
);
