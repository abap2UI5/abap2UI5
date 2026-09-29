#!/usr/bin/env node
/*
 * own-apps.mjs - a host's own transpiled classes, on the package's runtime.
 * Shipped in @abap2ui5/node-runtime as setup/own-apps.mjs and as the bin
 * `abap2ui5-own-apps`; npm.README.md, "Your own apps", is the recipe it is
 * one step of.
 *
 *   npx abap_transpile abap_transpile.json     # abap/ -> output/, with "addCommonJS": true
 *   npx abap2ui5-own-apps output apps           # output/ -> apps/: your classes alone
 *
 * then, after the runtime has booted:  await import("./apps/index.mjs")
 *
 * WHY. @abaplint/transpiler-cli writes every object it read into the output
 * folder - the host's classes, and a second copy of the framework and of
 * open-abap-core next to them; it has no option to leave the libraries out.
 * And a transpiled class imports what it extends by a RELATIVE path
 * (`const {cx_static_check} = await import("./cx_static_check.clas.mjs")`),
 * so importing the host's class from output/ loads that second copy, whose
 * modules register themselves in abap.Classes again: a second CX_ROOT
 * replaces the package's, and from then on the framework's CATCH cx_root
 * compares against a class its own exceptions do not extend - they fly
 * through every handler. Without "addCommonJS" the transpiler writes no
 * imports at all, and a class that extends anything cannot even load.
 *
 * WHAT IT DOES. It keeps the files of output/ that are NOT the package's -
 * every object the package's own output/ has a file for is a library copy,
 * and so are the transpile's generated boot files (init.mjs, index.mjs, the
 * _*.mjs) - and points their imports of anything else at the package's
 * export, "@abap2ui5/node-runtime/output/<file>": the very modules the
 * package's boot loaded, one instance of each. apps/index.mjs imports the
 * kept classes in the order the transpile's init.mjs does (it puts classes
 * with a class constructor last). An import it does not know the shape of
 * stops it with the file and the line, instead of a second copy at runtime.
 *
 * Also a module: import { ownApps } from "@abap2ui5/node-runtime/setup/own-apps.mjs".
 */
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const PACKAGE = "@abap2ui5/node-runtime";
const RUNTIME_OUTPUT = fileURLToPath(new URL("../output/", import.meta.url));

/* The transpile's generated files: its boot, its unit-test runner. Never the host's. */
const GENERATED = (file) => file.startsWith("_") || /^(init|index)\.mjs(\.map)?$/.test(file);

/* An import of another transpiled file, the shapes the transpiler writes -
 * each at the start of a line, so a string literal that reads like one is
 * never touched: `await import("./f")`, `const {x} = await import("./f")`,
 * `import "./f"`. */
const IMPORT = /^([ \t]*(?:const\s*\{[^}\n]*\}\s*=\s*)?await\s+import\(\s*|[ \t]*import\s+(?:[^"\n]*\s+from\s+)?)"\.\/([^"/\n]+\.mjs)"/gm;

/* Any relative module reference left afterwards - checked, not assumed. On
 * the start of a line, as the transpiler writes every import and export
 * (all ~2200 in abap2UI5's node/output), so an ABAP string literal holding
 * such a text is not mistaken for one. */
const RELATIVE = /^[ \t]*(?:(?:const\s*\{[^}\n]*\}\s*=\s*)?await\s+import\s*\(\s*|import\s*\(\s*|import\s+(?:[^"\n]*\s+from\s+)?|export\s+[^"\n]*\s+from\s+)"\.\/([^"\n]+)"/gm;

const fileOf = (specifier) => decodeURIComponent(specifier);

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
  const packaged = new Set(fs.readdirSync(runtimeOutput));
  const produced = fs.readdirSync(output).filter((f) => /\.mjs(\.map)?$/.test(f));
  const own = produced.filter((f) => !GENERATED(f) && !packaged.has(f)).sort();
  const local = new Set(own);
  if (!own.some((f) => f.endsWith(".mjs"))) {
    throw new Error(`own-apps: every file in ${output} is the package's own - which of them are yours? `
      + "(the transpile's input_folder holds your classes, and it has to be a different folder from the libs)");
  }

  const texts = new Map();
  const problems = [];
  for (const file of own) {
    let text = fs.readFileSync(path.join(output, file), "utf8");
    if (file.endsWith(".mjs")) {
      text = text.replace(IMPORT, (match, lead, specifier) =>
        (local.has(fileOf(specifier)) ? match : `${lead}"${PACKAGE}/output/${specifier}"`));
      for (const m of text.matchAll(RELATIVE)) {
        if (!local.has(fileOf(m[1]))) {
          const line = text.slice(0, m.index).split("\n").length;
          problems.push(`${file}:${line} imports ./${m[1]} in a shape own-apps does not rewrite`);
        }
      }
    }
    texts.set(file, text);
  }
  if (problems.length) {
    throw new Error(`own-apps: ${problems.length} import(s) would load a second copy of the package's classes:\n  `
      + problems.slice(0, 10).join("\n  ") + "\n  (did @abaplint/transpiler change the shape of its output?)");
  }

  // the kept classes' main modules, in the order the transpile's init.mjs imports them
  const main = own.filter((f) => /^[^.]+\.[a-z0-9]+\.mjs$/i.test(f));
  const init = path.join(output, "init.mjs");
  const order = [];
  if (fs.existsSync(init)) {
    for (const m of fs.readFileSync(init, "utf8").matchAll(/^[ \t]*(?:await\s+import\(|import\s+)"\.\/([^"/\n]+\.mjs)"/gm)) {
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
