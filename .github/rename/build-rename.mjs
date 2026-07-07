#!/usr/bin/env node
// build-rename.mjs
// Builds a renamed variant of abap2UI5 (parallel installation in the same
// SAP system, see .github/rename/README.md): all ABAP artifacts are moved
// from the z2ui5 namespace to a new prefix (e.g. ZMYUI5) via the abaplint
// rename feature, and the result is assembled as a complete, installable
// abapGit project. The build_rename workflow pushes it to the branch
// rename_<name> (name lowercased); re-running with the same name updates
// the branch to the current main state.
//
// Usage:  node .github/rename/build-rename.mjs <NAME>
// Output: .github/out/rename_<name>/
//
// <NAME> must start with a letter, contain only letters/digits/underscore
// and be at most 9 characters (longer prefixes would push generated class
// names past the 30-character ABAP name limit even after truncation, see
// maxNamespace()). A warning is printed if it does not start with Z/Y
// (SAP customer namespace). Registered namespaces (/NS/) are not supported.

import { execFileSync } from "node:child_process";
import { cpSync, existsSync, mkdirSync, readdirSync, readFileSync, rmSync, statSync, unlinkSync, writeFileSync } from "node:fs";
import { basename, dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const OLD_NS = "z2ui5";
const ABAP_NAME_LIMIT = 30;

const repo = join(dirname(fileURLToPath(import.meta.url)), "../..");

// Files every output branch inherits from main (no tooling, no CI);
// missing ones are skipped
const COMMON = ["CODE_OF_CONDUCT.md", "LICENSE", "SECURITY.md", "changelog.txt"];

function fail(msg) {
  console.error(`Error: ${msg}`);
  process.exit(1);
}

// ---------------------------------------------------------------- objects

// Collect all global ABAP objects from src/ file names
// (<name>.clas.xml / .intf.xml / .tabl.xml -> CLAS / INTF / TABL)
function collectObjects(dir, result = []) {
  for (const entry of readdirSync(dir)) {
    const path = join(dir, entry);
    if (statSync(path).isDirectory()) {
      collectObjects(path, result);
      continue;
    }
    const m = entry.match(/^([a-z0-9_]+)\.(clas|intf|tabl)\.xml$/);
    if (!m) continue;
    result.push({ oldName: m[1], type: { clas: "CLAS", intf: "INTF", tabl: "TABL" }[m[2]] });
  }
  return result;
}

// New name for one object: swap the prefix; if the result exceeds the
// 30-character ABAP limit, truncate the stem and keep the last _suffix
// segment - the same scheme .github/app2abap/trans2abap.js uses when it
// generates the over-long z2ui5_cl_app_*_js names in the first place.
function newNameFor(oldName, ns) {
  let name = ns + oldName.slice(OLD_NS.length);
  if (name.length > ABAP_NAME_LIMIT) {
    const suffix = name.slice(name.lastIndexOf("_"));
    name = name.slice(0, ABAP_NAME_LIMIT - suffix.length) + suffix;
  }
  return name;
}

// ------------------------------------------------------------ validation

function validateNamespace(ns) {
  if (!/^[A-Za-z][A-Za-z0-9_]{0,8}$/.test(ns)) {
    fail(`invalid namespace '${ns}' (letter + letters/digits/underscore, max 9 characters)`);
  }
  if (ns.toLowerCase() === OLD_NS) {
    fail(`namespace '${ns}' is the original namespace - nothing to rename`);
  }
  if (!/^[zy]/i.test(ns)) {
    console.warn(`Warning: '${ns}' does not start with Z or Y (SAP customer namespace)`);
  }
}

// ----------------------------------------------------------------- build

function buildRenameConfig(objects, ns, outputFolder) {
  const patterns = [];
  // objects whose new name must be truncated get an explicit pattern;
  // patterns are applied first-match-wins, so they must come before the
  // generic catch-all
  for (const o of objects) {
    const newName = newNameFor(o.oldName, ns);
    if (newName !== ns + o.oldName.slice(OLD_NS.length)) {
      patterns.push({ type: o.type, oldName: `^${o.oldName}$`, newName });
    }
  }
  patterns.push({ type: "CLAS|INTF|TABL", oldName: `^${OLD_NS}(.*)$`, newName: `${ns}$1` });
  return {
    global: { files: "/src/**/*.*" },
    dependencies: [
      {
        url: "https://github.com/abapedia/steampunk-2305-api-intersect-702",
        files: "/src/**/*.*",
      },
    ],
    rename: { output: outputFolder, patterns },
    syntax: { version: "v750", errorNamespace: "." },
    rules: {
      allowed_object_types: { allowed: ["CLAS", "DEVC", "INTF", "TABL"] },
      allowed_object_naming: true,
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
      xml_consistency: true,
    },
  };
}

// abaplint renames the objects and every code/XML reference, but it cannot
// know about object names inside string literals. A few of those are
// functional on a renamed installation (dynamic RTTI/exit-class lookups,
// e.g. `Z2UI5_IF_EXIT` in z2ui5_cl_exit), so rewrite every string
// occurrence of a renamed object name in the ABAP sources. The embedded
// frontend under src/01/03 is excluded: its string constants are
// JavaScript/HTML where z2ui5 is the UI5 module namespace, which must not
// change. Other z2ui5 strings (UI5 namespace, URLs, texts) stay untouched
// because only complete object names are matched.
function rewriteStringLiterals(srcDir, renames) {
  // longest first so e.g. ..._util_api_c is never hit by the ..._util_api pattern
  const ordered = [...renames.entries()].sort((a, b) => b[0].length - a[0].length);
  const walk = (dir) => {
    for (const entry of readdirSync(dir)) {
      const path = join(dir, entry);
      if (statSync(path).isDirectory()) {
        if (dir === join(srcDir, "01") && entry === "03") continue;
        walk(path);
        continue;
      }
      if (!entry.endsWith(".abap")) continue;
      let text = readFileSync(path, "utf8");
      let changed = false;
      for (const [oldName, newName] of ordered) {
        const regex = new RegExp(`(?<![A-Za-z0-9_])${oldName}(?![A-Za-z0-9_])`, "gi");
        text = text.replace(regex, (match) => {
          changed = true;
          return match === match.toLowerCase() ? newName.toLowerCase() : newName.toUpperCase();
        });
      }
      if (changed) writeFileSync(path, text);
    }
  };
  walk(srcDir);
}

function banner(branch) {
  return `> ⚙️ **Generated branch \`${branch}\`** — built from [\`main\`](../../tree/main) by the ` +
    "`build_rename` workflow. Do not commit here, changes belong into `main`.\n\n";
}

function main() {
  const args = process.argv.slice(2);
  if (args.length !== 1 || args[0].startsWith("-")) {
    console.error("Usage: node .github/rename/build-rename.mjs <NAME>   (e.g. ZMYUI5)");
    process.exit(1);
  }
  const ns = args[0].toLowerCase();
  validateNamespace(ns);

  const branch = `rename_${ns}`;
  const outDir = join(repo, ".github/out", branch);

  // old name -> new name for all objects; abort on truncation collisions
  const objects = collectObjects(join(repo, "src"));
  const renames = new Map();
  const taken = new Map();
  for (const o of objects) {
    if (!o.oldName.startsWith(OLD_NS)) fail(`unexpected object name '${o.oldName}'`);
    const newName = newNameFor(o.oldName, ns);
    const clash = taken.get(newName);
    if (clash !== undefined) fail(`name collision after truncation: '${o.oldName}' and '${clash}' both map to '${newName}'`);
    taken.set(newName, o.oldName);
    renames.set(o.oldName, newName);
  }

  // run the abaplint rename; the config must sit in the repo root so the
  // renamed files land under <renameOut>/src (abaplint resolves the output
  // folder and the file paths relative to the config location)
  const configPath = join(repo, "rename_build.abaplint.jsonc");
  const renameOut = "output/rename_build";
  writeFileSync(configPath, JSON.stringify(buildRenameConfig(objects, ns, renameOut), null, 2));
  try {
    execFileSync(process.execPath, [join(repo, "node_modules/@abaplint/cli/abaplint"), configPath, "--rename"],
      { cwd: repo, stdio: ["ignore", "ignore", "inherit"] });
  } finally {
    unlinkSync(configPath);
  }
  const renamedSrc = join(repo, renameOut, "src");
  if (!existsSync(renamedSrc)) fail(`abaplint rename produced no ${renameOut}/src folder`);

  rewriteStringLiterals(renamedSrc, renames);

  // assemble the output branch: renamed src + abapGit/abaplint descriptors
  // + the common files every generated branch inherits from main
  rmSync(outDir, { recursive: true, force: true });
  mkdirSync(outDir, { recursive: true });
  cpSync(renamedSrc, join(outDir, "src"), { recursive: true });
  rmSync(join(repo, renameOut), { recursive: true, force: true });
  for (const f of COMMON) if (existsSync(join(repo, f))) cpSync(join(repo, f), join(outDir, f));
  writeFileSync(join(outDir, "README.md"), banner(branch) + readFileSync(join(repo, "README.md"), "utf8"));
  writeFileSync(join(outDir, ".abapgit.xml"),
    readFileSync(join(repo, ".abapgit.xml"), "utf8")
      .replace("Z2UI5_IF_APP", renames.get(`${OLD_NS}_if_app`).toUpperCase()));
  // abaplint config so the abaplint check works on the output branch
  // (naming rules and exceptions turned to the new namespace)
  writeFileSync(join(outDir, "abaplint.jsonc"),
    readFileSync(join(repo, "abaplint.jsonc"), "utf8")
      .replaceAll("Z2UI5", ns.toUpperCase())
      .replaceAll("z2ui5", ns));

  console.log(`OK: ${branch} (${objects.length} objects renamed) -> ${outDir}`);
}

main();
