#!/usr/bin/env node
/*
 * own-apps.mjs - a host's own transpiled classes, on the package's runtime.
 * Shipped in @abap2ui5/node-runtime as setup/own-apps.mjs and as the bin
 * `abap2ui5-own-apps`; npm.README.md, "Your own apps", is the recipe it is
 * one step of.
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
 * Also a module: import { ownApps } from "@abap2ui5/node-runtime/setup/own-apps.mjs".
 */
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const PACKAGE = "@abap2ui5/node-runtime";
const RUNTIME_OUTPUT = fileURLToPath(new URL("../output/", import.meta.url));

/* The folder the transpiler writes the transpile's own input into (2.14 on). */
const PROJECT = "project";

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

/**
 * Copy the host's own files out of a transpile's output folder, their
 * imports of anything else pointed at the package.
 * @param {{ output: string, apps: string, runtimeOutput?: string }} options
 *   `output` the transpile's output folder, `apps` where the host's files go
 *   (emptied first), `runtimeOutput` the package's output/ (default: the one
 *   next to this file)
 * @returns {{ files: string[], modules: string[] }} the files written, and
 *   the modules apps/index.mjs imports
 */
export function ownApps({ output, apps, runtimeOutput = RUNTIME_OUTPUT }) {
  if (!fs.existsSync(output)) throw new Error(`own-apps: ${output} does not exist - run the transpile first`);
  const projectDir = path.join(output, PROJECT);
  if (!fs.existsSync(projectDir)) {
    throw new Error(`own-apps: ${output} has no ${PROJECT}/ folder - it was written by a transpiler before 2.14, `
      + `and this ${PACKAGE} was built with the folder per origin 2.14 writes (abap2ui5.transpiler in its package.json names the version)`);
  }
  const index = packageIndex(runtimeOutput);
  const own = fs.readdirSync(projectDir).filter((f) => /\.mjs(\.map)?$/.test(f)).sort();
  const local = new Set(own);
  if (!own.some((f) => f.endsWith(".mjs"))) {
    throw new Error(`own-apps: ${projectDir} is empty - which of the classes are yours? `
      + "(the transpile's input_folder holds your classes, and it has to be a different folder from the libs)");
  }
  const shadowing = own.filter((f) => index.has(f));
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
    const imported = new RegExp(`^[ \\t]*(?:await\\s+import\\(|import\\s+)"\\./${PROJECT}/([^"/\\n]+\\.mjs)"`, "gm");
    for (const m of fs.readFileSync(init, "utf8").matchAll(imported)) {
      const file = fileOf(m[1]);
      if (main.includes(file) && !order.includes(file)) order.push(file);
    }
  }
  for (const file of main) if (!order.includes(file)) order.push(file);

  fs.rmSync(apps, { recursive: true, force: true });
  fs.mkdirSync(apps, { recursive: true });
  for (const [file, text] of texts) fs.writeFileSync(path.join(apps, file), text);
  fs.writeFileSync(path.join(apps, "index.mjs"), [
    `// Written by ${PACKAGE}'s abap2ui5-own-apps (setup/own-apps.mjs) - do not edit, it is`,
    "// written again with the classes. Import it after the runtime has booted (initialize()).",
    ...order.map((file) => `await import(${JSON.stringify(`./${encodeURI(file).replace(/#/g, "%23")}`)});`),
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
