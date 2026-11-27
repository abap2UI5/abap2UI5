#!/usr/bin/env node
/*
 * own-apps.mjs - a host's own transpiled classes, on the package's runtime.
 * Shipped in @abap2ui5/node-runtime as setup/own-apps.mjs and as the bin
 * `abap2ui5-own-apps`; until 1.147.0 npm.README.md, "Your own apps", was
 * the recipe it is one step of.
 *
 * DEPRECATED since abap2ui5-transpile transpiles the framework and the
 * host's classes together into one runtime of the host's own
 * (setup/transpile.mjs, "WHY ONE TRANSPILE"): one transpile, one transpiler
 * version, nothing to rewrite - the way the transpiler's maintainer asked
 * for (abaplint/transpiler#1999). This bin stays for the hosts that call it
 * (abap2UI5/protocol's conformance host transpiles with 2.13), unchanged.
 *
 *   npx abap_transpile abap_transpile.json     # abap/ -> output/project/, with "addCommonJS": true
 *   npx abap2ui5-own-apps output apps           # output/project/ -> apps/: your classes alone
 *
 * then, after the runtime has booted:  await import("./apps/index.mjs")
 *
 * WHY. @abaplint/transpiler-cli writes every object it read into the output
 * folder - the host's classes, and a second copy of the framework and of
 * open-abap-core next to them; it has no option to leave the libraries out.
 * From 2.14 on it writes one folder per origin: the host's classes into
 * output/project/, each library into a folder of its own (output/downport/,
 * output/open-abap-core/), and a transpiled class imports what it extends by
 * a RELATIVE path into that folder
 * (`const {cx_static_check} = await import("../open-abap-core/cx_static_check.clas.mjs")`),
 * so importing the host's class from output/ loads that second copy, whose
 * modules register themselves in abap.Classes again: a second CX_ROOT
 * replaces the package's, and from then on the framework's CATCH cx_root
 * compares against a class its own exceptions do not extend - they fly
 * through every handler. Without "addCommonJS" the transpiler writes no
 * imports at all, and a class that extends anything cannot even load.
 *
 * WHAT IT DOES. It keeps output/project/ - the host's classes, nothing else -
 * and points their imports of anything outside it at the package's export of
 * the same file, "@abap2ui5/node-runtime/output/<folder>/<file>" (the package
 * is indexed once, file name to folder: project/ for the framework,
 * open-abap-core/, express-icf-shim/): the very modules the package's boot
 * loaded, one instance of each. apps/index.mjs imports the kept classes in
 * the order the transpile's init.mjs does (it puts classes with a class
 * constructor last). An import it does not know the shape of, or of a file
 * the package does not have, stops it with the file and the line, instead
 * of a second copy at runtime.
 *
 * A transpiler before 2.14 writes everything flat into output/, the host's
 * classes next to the library copies. That output is read too: every file
 * the package has a module of the same name for is a library copy, and so
 * are the transpile's generated files (init.mjs, index.mjs, the _*.mjs);
 * the rest is the host's. Flat, a class of the host's named like one of the
 * package's cannot be told from a copy - it is left out, as it was before
 * 2.14. abap2UI5/protocol's conformance host transpiles with 2.13.
 *
 * From 2.14 on project/ holds one generated file beside the host's classes:
 * _ddic.mjs, the abap.DDIC entries of the host's tables and data elements
 * (each origin folder has one; the package's project/_ddic.mjs registers
 * the framework's). It is no class and replaces nothing - it adds the host's
 * keys to abap.DDIC - so it is kept, never taken for a class of the
 * package's name, and apps/index.mjs imports it before the classes, as the
 * transpile's init.mjs does. Refused as a shadowing class up to 1.149.0,
 * which stopped every host with a table or a data element of its own.
 *
 * Also a module: import { ownApps } from "@abap2ui5/node-runtime/setup/own-apps.mjs".
 */
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const PACKAGE = "@abap2ui5/node-runtime";
const RUNTIME_OUTPUT = fileURLToPath(new URL("../output/", import.meta.url));

/* The folder the transpiler writes the transpile's own input into (2.14 on). */
const PROJECT = "project";

/* The transpile's generated files: its boot, its unit-test runner, its DDIC. In a flat output never the
 * host's; in project/ the one there is (_ddic.mjs, the host's DDIC - see the header). */
const GENERATED = (file) => file.startsWith("_") || /^(init|index)\.mjs(\.map)?$/.test(file);

/* An import of another transpiled file, the shapes the transpiler writes -
 * each at the start of a line, so a string literal that reads like one is
 * never touched: `await import("./f")`, `const {x} = await import("../lib/f")`,
 * `import "./f"`. */
const IMPORT = /^([ \t]*(?:const\s*\{[^}\n]*\}\s*=\s*)?await\s+import\(\s*|[ \t]*import\s+(?:[^"\n]*\s+from\s+)?)"(\.\.?\/[^"\n]+\.mjs)"/gm;

/* Any relative module reference left afterwards - checked, not assumed. On
 * the start of a line, as the transpiler writes every import and export, so
 * an ABAP string literal holding such a text is not mistaken for one. */
const RELATIVE = /^[ \t]*(?:(?:const\s*\{[^}\n]*\}\s*=\s*)?await\s+import\s*\(\s*|import\s*\(\s*|import\s+(?:[^"\n]*\s+from\s+)?|export\s+[^"\n]*\s+from\s+)"(\.\.?\/[^"\n]+)"/gm;

const fileOf = (specifier) => decodeURIComponent(specifier);

/* Every module of the package's output/, by file name: the folder it is in.
 * One file name, one folder - the transpiler refuses an object that two
 * origins define, so the name says which module is meant. */
function packageIndex(runtimeOutput) {
  const index = new Map();
  for (const dir of fs.readdirSync(runtimeOutput, { withFileTypes: true })) {
    if (!dir.isDirectory()) continue;
    for (const file of fs.readdirSync(path.join(runtimeOutput, dir.name))) {
      if (file.endsWith(".mjs")) index.set(file, dir.name);
    }
  }
  return index;
}

/* The first line of the apps/index.mjs this tool writes - what tells a folder
 * it wrote from any other folder of the host's. */
const MARKER = `// Written by ${PACKAGE}'s abap2ui5-own-apps`;

const inside = (dir, parent) => {
  const rel = path.relative(parent, dir);
  return rel === "" || (!rel.startsWith("..") && !path.isAbsolute(rel));
};

/**
 * Empty the apps folder - only when it is one: missing, empty, or holding the
 * index.mjs this tool writes, and neither the transpile's output nor the
 * folder the host runs in (or a folder around either). The folder is removed
 * whole, so `abap2ui5-own-apps output .` would have taken the host's project
 * with it, and a typo'd folder of the host's anything in it. Mirrors
 * transpile.mjs (emptyOutput).
 */
function emptyApps(apps, output, cwd) {
  if (inside(output, apps)) {
    throw new Error(`own-apps: ${apps} is or holds the transpile output ${output} - name a folder of its own for your classes, it is emptied first`);
  }
  if (inside(cwd, apps)) {
    throw new Error(`own-apps: ${apps} is or holds the folder this runs in (${cwd}) - name a folder of its own for your classes, it is emptied first`);
  }
  if (!fs.existsSync(apps)) return;
  const entries = fs.readdirSync(apps);
  const index = path.join(apps, "index.mjs");
  const ours = entries.includes("index.mjs") && fs.readFileSync(index, "utf8").startsWith(MARKER);
  if (entries.length && !ours) {
    throw new Error(`own-apps: ${apps} is not empty and holds no index.mjs of abap2ui5-own-apps - name a folder of its own for your classes, it is emptied first`);
  }
  fs.rmSync(apps, { recursive: true, force: true });
}

/**
 * Copy the host's own files out of a transpile's output folder, their
 * imports of anything else pointed at the package.
 * @param {{ output: string, apps: string, runtimeOutput?: string, cwd?: string }} options
 *   `output` the transpile's output folder, `apps` where the host's files go
 *   (emptied first - only a folder this tool wrote, see emptyApps),
 *   `runtimeOutput` the package's output/ (default: the one next to this
 *   file), `cwd` the folder the host runs in (default: the process's)
 * @returns {{ files: string[], modules: string[] }} the files written, and
 *   the modules apps/index.mjs imports
 */
export function ownApps({ output, apps, runtimeOutput = RUNTIME_OUTPUT, cwd = process.cwd() }) {
  if (!fs.existsSync(output)) throw new Error(`own-apps: ${output} does not exist - run the transpile first`);
  const index = packageIndex(runtimeOutput);
  // a transpiler before 2.14: no project/, the host's classes flat among the library copies
  const flat = !fs.existsSync(path.join(output, PROJECT));
  const projectDir = flat ? output : path.join(output, PROJECT);
  const library = (f) => GENERATED(f) || index.has(f.replace(/\.map$/, ""));
  const own = fs.readdirSync(projectDir).filter((f) => /\.mjs(\.map)?$/.test(f))
    .filter((f) => !flat || !library(f)).sort();
  const local = new Set(own);
  if (!own.some((f) => f.endsWith(".mjs") && !GENERATED(f))) {
    throw new Error(`own-apps: ${flat ? `every file in ${output} is the package's own` : `${projectDir} is empty`}`
      + " - which of the classes are yours? "
      + "(the transpile's input_folder holds your classes, and it has to be a different folder from the libs)");
  }
  // the generated files of project/ (_ddic.mjs) are the host's too, and no class: they share the
  // package's file name in every origin folder and replace nothing (see the header)
  const shadowing = own.filter((f) => !GENERATED(f) && index.has(f));
  if (shadowing.length) {
    throw new Error(`own-apps: ${shadowing.length} of your class(es) have the name of one of the package's - `
      + `loaded, each would replace the package's in the runtime: ${shadowing.slice(0, 10).join(", ")}`);
  }

  const texts = new Map();
  const problems = [];
  for (const file of own) {
    let text = fs.readFileSync(path.join(projectDir, file), "utf8");
    if (file.endsWith(".mjs")) {
      text = text.replace(IMPORT, (match, lead, specifier) => {
        const target = path.posix.normalize(`${PROJECT}/${specifier}`);
        const name = target.split("/").pop();
        if (target === `${PROJECT}/${name}` && local.has(fileOf(name))) return match;
        const folder = index.get(fileOf(name));
        return folder ? `${lead}"${PACKAGE}/output/${folder}/${name}"` : match;
      });
      for (const m of text.matchAll(RELATIVE)) {
        if (!(m[1].startsWith("./") && !m[1].slice(2).includes("/") && local.has(fileOf(m[1].slice(2))))) {
          const line = text.slice(0, m.index).split("\n").length;
          problems.push(`${file}:${line} imports ${m[1]}, which is neither one of your classes nor a module of the package`);
        }
      }
    }
    texts.set(file, text);
  }
  if (problems.length) {
    throw new Error(`own-apps: ${problems.length} import(s) would load a second copy of the package's classes or nothing at all:\n  `
      + problems.slice(0, 10).join("\n  ") + "\n  (did @abaplint/transpiler change the shape of its output?)");
  }

  // the kept classes' main modules, in the order the transpile's init.mjs imports them
  const main = own.filter((f) => /^[^.]+\.[a-z0-9]+\.mjs$/i.test(f));
  const init = path.join(output, "init.mjs");
  const order = [];
  if (fs.existsSync(init)) {
    const imported = new RegExp(`^[ \\t]*(?:await\\s+import\\(|import\\s+)"\\./${flat ? "" : `${PROJECT}/`}([^"/\\n]+\\.mjs)"`, "gm");
    for (const m of fs.readFileSync(init, "utf8").matchAll(imported)) {
      const file = fileOf(m[1]);
      if (main.includes(file) && !order.includes(file)) order.push(file);
    }
  }
  for (const file of main) if (!order.includes(file)) order.push(file);
  // the host's DDIC before its classes, as init.mjs imports it (only project/ has one of the host's)
  const ddic = flat ? [] : own.filter((f) => GENERATED(f) && f.endsWith(".mjs"));

  emptyApps(path.resolve(apps), path.resolve(output), path.resolve(cwd));
  fs.mkdirSync(apps, { recursive: true });
  for (const [file, text] of texts) fs.writeFileSync(path.join(apps, file), text);
  fs.writeFileSync(path.join(apps, "index.mjs"), [
    `${MARKER} (setup/own-apps.mjs) - do not edit, it is`,
    "// written again with the classes. Import it after the runtime has booted (initialize()).",
    ...[...ddic, ...order].map((file) => `await import(${JSON.stringify(`./${encodeURI(file).replace(/#/g, "%23")}`)});`),
    "",
  ].join("\n"));
  return { files: [...texts.keys(), "index.mjs"], modules: order };
}

/* Run as the bin, not when imported. */
const invoked = process.argv[1] && fs.realpathSync(process.argv[1]) === fs.realpathSync(fileURLToPath(import.meta.url));
if (invoked) {
  const [output, apps] = process.argv.slice(2);
  if (!output || !apps) {
    console.error("usage: abap2ui5-own-apps <transpile output folder> <apps folder>");
    process.exit(2);
  }
  try {
    const { files, modules } = ownApps({ output: path.resolve(output), apps: path.resolve(apps) });
    console.log(`abap2ui5-own-apps: ${modules.length} class(es) of your own into ${apps} (${files.length} files),`
      + ` every other import on ${PACKAGE}: ${modules.join(", ")}`);
  } catch (e) {
    console.error(e.message);
    process.exit(1);
  }
}
