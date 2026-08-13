// Gate: a local test class that touches a PRIVATE or PROTECTED member of the
// class under test needs a `CLASS <global> DEFINITION LOCAL FRIENDS <ltcl>.`
// statement. Without it the class pool does not compile in a real SAP system.
//
// Why this exists as a gate and not as prose: neither abaplint nor the
// transpiler enforces visibility. The transpiler ignores it altogether (every
// member becomes a plain JS property), so `npm run unit` stays green on a class
// pool that a real system rejects with a syntax error. That is exactly how
// `ltcl_rtti` in z2ui5_cl_ui5_context reached main - it called the PRIVATE
// scan_flag_prefix( ) and had to be repaired after the fact.
//
// Deliberately limited to what can be decided from the source text alone:
// static access (`zcl_x=>member`) and instance access through a variable that
// is explicitly typed as the class under test. Anything reached dynamically or
// through a helper type is out of scope - the gate must not produce findings a
// developer cannot act on.

import { globSync, readFileSync } from "fs";
import { basename } from "path";

const SECTIONS = { "PUBLIC SECTION": "PUBLIC", "PROTECTED SECTION": "PROTECTED", "PRIVATE SECTION": "PRIVATE" };

function parseVisibility(source) {
  // member name (lower case) -> section, for the definition part of the global class
  const members = new Map();
  let section = null;
  let inDefinition = false;
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
    const declared = line.match(/^(CLASS-METHODS|METHODS|CLASS-DATA|DATA|CONSTANTS|CLASS-EVENTS|EVENTS)\s+([A-Z_0-9]+)/);
    if (declared) {
      if (!members.has(declared[2].toLowerCase())) members.set(declared[2].toLowerCase(), section);
      continue;
    }
    // continuation line of a chained declaration: `name TYPE ...` / `name FOR TESTING`
    const chained = line.match(/^([A-Z_0-9]+)\s+(TYPE|LIKE|FOR TESTING|REDEFINITION|ABSTRACT|FINAL)\b/);
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

const findings = [];

for (const testFile of globSync("src/**/*.clas.testclasses.abap").sort()) {
  const globalClass = basename(testFile, ".clas.testclasses.abap");
  let definition;
  try {
    definition = readFileSync(testFile.replace(".clas.testclasses.abap", ".clas.abap"), "utf8");
  } catch {
    continue; // no class under test (e.g. an interface pool)
  }

  const members = parseVisibility(definition);
  const source = readFileSync(testFile, "utf8");
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
        findings.push({ file: testFile, line: i + 1, local, member, visibility, globalClass });
      }
    }
  }
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

console.log("Test class visibility: no findings.");
