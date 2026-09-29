#!/usr/bin/env node
// cli.mjs - the command line of @abap2ui5/bsp. `abap2ui5-bsp help` for the
// commands; README.md has the whole story.

import { existsSync, readdirSync, rmSync, writeFileSync } from "node:fs";
import { join } from "node:path";
import { argv, exit } from "node:process";
import { app2bsp, readApp, sicfUrls } from "./lib/app2bsp.mjs";
import { bsp2app } from "./lib/bsp2app.mjs";
import { checkBsps } from "./lib/check.mjs";
import { bspName, isSapName, sicfFileName } from "./lib/names.mjs";

const HELP = `abap2ui5-bsp - a UI5 app as an abapGit BSP, and back

  abap2ui5-bsp app2bsp [webapp] --name ZMYAPP [--out bsp] [--text "My app"]
      The app folder (default: webapp) as the BSP ZMYAPP, with its two ICF
      nodes, in an abapGit repository folder (default: bsp): .abapgit.xml
      and src/. Push that folder to git and pull it with abapGit.

  abap2ui5-bsp bsp2app [folder] [--out webapp] [--name ZMYAPP] [--keep-mapping] [--force]
      The BSP in the folder (default: src) - what abapGit serializes - as an
      app folder (default: webapp).

  abap2ui5-bsp check [folder]
      The page rules of every BSP in the folder (default: .) and below.
`;

function parse(args) {
  const options = { positional: [] };
  for (let i = 0; i < args.length; i++) {
    const arg = args[i];
    if (arg === "--keep-mapping" || arg === "--force") options[arg.slice(2)] = true;
    else if (["--name", "--out", "--text", "--package-text"].includes(arg)) {
      if (args[i + 1] === undefined) usage(`${arg} needs a value`);
      options[arg.slice(2)] = args[++i];
    } else if (arg.startsWith("-")) usage(`unknown option ${arg}`);
    else options.positional.push(arg);
  }
  return options;
}

function usage(message) {
  console.error(`abap2ui5-bsp: ${message}\n\n${HELP}`);
  exit(2);
}

function fail(error) {
  console.error(`abap2ui5-bsp: ${error.message}`);
  exit(1);
}

const ABAPGIT_XML = `\uFEFF<?xml version="1.0" encoding="utf-8"?>
<asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0">
 <asx:values>
  <DATA>
   <MASTER_LANGUAGE>E</MASTER_LANGUAGE>
   <STARTING_FOLDER>/src/</STARTING_FOLDER>
   <FOLDER_LOGIC>PREFIX</FOLDER_LOGIC>
  </DATA>
 </asx:values>
</asx:abap>
`;

// src/ is replaced on every run - but only when all it holds is what an
// earlier run wrote for this BSP; anything else in there is somebody's
function clearPreviousOutput(src, name) {
  if (!existsSync(src)) return;
  const lo = name.toLowerCase();
  const ours = new Set(["package.devc.xml", ...sicfUrls(name).map((url) => sicfFileName(name, url))]);
  const foreign = readdirSync(src).filter((file) => !ours.has(file) && !file.startsWith(`${lo}.wapa.`));
  if (foreign.length) {
    fail(new Error(`${src} holds files this command did not write (${foreign.slice(0, 3).join(", ")}${foreign.length > 3 ? ", ..." : ""}) - choose another --out`));
  }
  for (const file of readdirSync(src)) rmSync(join(src, file));
}

function runApp2bsp(options) {
  const webapp = options.positional[0] ?? "webapp";
  const out = options.out ?? "bsp";
  let name;
  try {
    name = bspName(options.name);
  } catch (error) {
    usage(error.message);
  }
  const text = options.text ?? `${name} - UI5 app`;
  // every problem before anything is replaced: a run that cannot write the
  // BSP leaves the last one where it is
  const { problems } = readApp(webapp);
  if (problems.length) fail(new Error(`${webapp} cannot become a BSP:\n  ${problems.join("\n  ")}`));
  const src = join(out, "src");
  clearPreviousOutput(src, name);
  const result = app2bsp({ webapp, target: src, name, text, packageText: options["package-text"] ?? text });
  const abapgit = join(out, ".abapgit.xml");
  if (!existsSync(abapgit)) writeFileSync(abapgit, ABAPGIT_XML);

  console.log(`BSP ${name}: ${result.pages.length - 1} files of ${webapp} and the path mapping -> ${src}`);
  if (isSapName(name)) console.log(`  note: ${name} is outside the customer namespace (Z*, Y*)`);
  console.log(`
Next:
  1. push ${out} to a git repository
  2. abapGit: New Online (or Offline, with the folder as a ZIP), a package of
     your own, Pull - it creates the BSP ${name} and its ICF nodes
  3. SICF: activate ${sicfUrls(name).join(" and ")}
  4. open /sap/bc/ui5_ui5/sap/${name.toLowerCase()}/index.html`);
}

function runBsp2app(options) {
  const source = options.positional[0] ?? "src";
  const target = options.out ?? "webapp";
  const result = bsp2app({
    source,
    target,
    name: options.name,
    keepMapping: options["keep-mapping"],
    overwrite: options.force,
  });
  console.log(`BSP ${result.name}: ${result.pages.length} pages -> ${target}`);
  if (result.text) console.log(`  its text: ${result.text} (app2bsp --text)`);
  for (const file of result.unregistered) {
    console.log(`  skipped ${file}: not registered in the page directory, so never in the system either`);
  }
  console.log(
    "\nThe pages come back as the system stores them: no spaces at line ends, one newline at the end of every file.",
  );
}

function runCheck(options) {
  const root = options.positional[0] ?? ".";
  const results = checkBsps(root);
  if (!results.length) fail(new Error(`${root}: no BSP found (no .wapa.xml)`));
  let problems = 0;
  for (const result of results) {
    console.log(`${result.folder}: ${result.bsps} BSP, ${result.pages} pages checked`);
    for (const problem of result.problems) console.error(`  ${problem}`);
    problems += result.problems.length;
  }
  if (problems) fail(new Error(`${problems} problem(s)`));
  console.log("check: OK");
}

const COMMANDS = { app2bsp: runApp2bsp, bsp2app: runBsp2app, check: runCheck };
const [command, ...rest] = argv.slice(2);
if (!command || command === "help" || command === "--help" || command === "-h") {
  console.log(HELP);
  exit(command ? 0 : 2);
}
if (!COMMANDS[command]) usage(`unknown command ${command}`);
try {
  COMMANDS[command](parse(rest));
} catch (error) {
  fail(error);
}
