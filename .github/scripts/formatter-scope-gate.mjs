#!/usr/bin/env node
// app/webapp/model/formatter.js is the ONE place where the framework ships
// JavaScript that an app's view calls to turn a model value into what the
// control shows. abap2UI5 is a thin frontend, so that set is a marshalling
// layer, not a home for logic ABAP could have finished. Every function
// admitted moves a decision from ABAP into JS, and removing it later breaks
// the apps that adopted it - the stock/delivery status pack was shipped and
// pulled again exactly that way.
//
// Prose did not hold the line, so this gate does. It enforces the two
// admission criteria that can be checked mechanically (the module header
// states all three):
//
//   2. FRONTEND-ONLY - the export surface must match MANIFEST below, and
//      every entry has to name the technical reason it cannot live in ABAP,
//      chosen from a CLOSED set. Adding a function means adding it here with
//      a reason; if none of the reasons is true, the function belongs in the
//      app's ABAP model, not in this module.
//   3. NO DOMAIN VOCABULARY - the module must contain no hardcoded UI5
//      ValueState and no sap-icon:// URI as a STRING LITERAL. That is the
//      exact shape of the functions that were removed: a lookup table from a
//      business status to a visual. Classification is backend work; the view
//      binds the finished field.
//
// Criterion 1 (a function formats exactly the one value handed to it, it does
// not read other fields or rows) needs a reader and stays reviewer-enforced.
//
// Comments and regex literals are NOT scanned - only real string literals -
// so the header may discuss "sap-icon://" and expandInlineIcons may match it
// in a regex. Run: npm run check:formatter
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const ROOT = path.join(path.dirname(fileURLToPath(import.meta.url)), "..", "..");
const MODULE = path.join(ROOT, "app", "webapp", "model", "formatter.js");

// The closed set of reasons a formatter may live in the frontend at all.
// Do not extend it without the same scrutiny as the module itself: a new
// reason is a new class of logic leaving the backend.
const REASONS = {
  "js-type":
    "the result is a JavaScript type the JSON model cannot carry (a real Date for an object-typed UI5 property)",
  "icon-font":
    "the result is a glyph of the loaded theme's icon font, which only the browser knows",
  "locale-theme":
    "the result depends on the browser's locale or the loaded theme, not on the data",
};

// The complete, justified export surface. An export missing here, or an entry
// without a matching export, fails the gate.
const MANIFEST = {
  DateCreateObject: "js-type",
  DateAbapDateToDateObject: "js-type",
  DateAbapDateTimeToDateObject: "js-type",
  expandInlineIcons: "icon-font",
};

// UI5 ValueState members. A formatter that returns one of these classified
// the data, which is what the backend is for.
const VALUE_STATES = ["None", "Success", "Warning", "Error", "Information"];

// Walks the source and returns every STRING literal (single-quoted,
// double-quoted, template) with its line. Comments and regex literals are
// skipped, so prose and patterns mentioning a forbidden token do not trip the
// gate - only a value the module would actually hand to a control does.
function stringLiterals(src) {
  const out = [];
  let line = 1;
  // the last significant character of code, used to tell a regex literal
  // (`/foo/`) from a division: after a value, `/` divides; otherwise it opens
  // a regex
  let prev = "";
  for (let i = 0; i < src.length; i++) {
    const c = src[i];
    if (c === "\n") {
      line++;
      continue;
    }
    if (c === "/" && src[i + 1] === "/") {
      while (i < src.length && src[i] !== "\n") i++;
      i--;
      continue;
    }
    if (c === "/" && src[i + 1] === "*") {
      i += 2;
      while (i < src.length && !(src[i] === "*" && src[i + 1] === "/")) {
        if (src[i] === "\n") line++;
        i++;
      }
      i++;
      continue;
    }
    if (c === "/" && !/[\w)\]]/.test(prev)) {
      // regex literal - skip it, honouring escapes and character classes
      i++;
      let inClass = false;
      while (i < src.length) {
        if (src[i] === "\\") i++;
        else if (src[i] === "[") inClass = true;
        else if (src[i] === "]") inClass = false;
        else if (src[i] === "/" && !inClass) break;
        else if (src[i] === "\n") line++;
        i++;
      }
      prev = "/";
      continue;
    }
    if (c === '"' || c === "'" || c === "`") {
      const startLine = line;
      let value = "";
      i++;
      while (i < src.length && src[i] !== c) {
        if (src[i] === "\\") {
          value += src[i + 1] ?? "";
          i += 2;
          continue;
        }
        if (src[i] === "\n") line++;
        value += src[i];
        i++;
      }
      out.push({ value, line: startLine });
      prev = c;
      continue;
    }
    if (!/\s/.test(c)) prev = c;
  }
  return out;
}

const src = fs.readFileSync(MODULE, "utf8");
const problems = [];

// --- criterion 2: the export surface matches the justified manifest -------
// the returned object literal of sap.ui.define; its keys are shorthand
// methods (`name(args) {`) or properties (`name: `)
const returned = src.slice(src.lastIndexOf("\n  return {"));
const exported = new Set(
  [...returned.matchAll(/^\s{4}(\w+)\s*[(:]/gm)].map((m) => m[1]),
);

for (const name of exported) {
  if (!(name in MANIFEST)) {
    problems.push(
      `${name} is exported but not in the gate's MANIFEST. Add it with the reason it cannot be ` +
        `computed in ABAP (${Object.keys(REASONS).join(" | ")}) - and if none of them is true, ` +
        `the function is app logic: compute it in the app's ABAP model and bind the finished value.`,
    );
  }
}
for (const [name, reason] of Object.entries(MANIFEST)) {
  if (!exported.has(name)) {
    problems.push(
      `${name} is in the MANIFEST but no longer exported - removing a published formatter breaks ` +
        `every app that binds it; drop it from the manifest only together with a changelog entry.`,
    );
  }
  if (!(reason in REASONS)) {
    problems.push(
      `${name} claims the reason "${reason}", which is not one of ${Object.keys(REASONS).join(" | ")}.`,
    );
  }
}

// --- criterion 3: no domain vocabulary in a string literal ----------------
for (const { value, line } of stringLiterals(src)) {
  if (VALUE_STATES.includes(value)) {
    problems.push(
      `line ${line}: the literal "${value}" is a UI5 ValueState. Deriving a state from data is ` +
        `classification, which belongs in ABAP - bind state="{MY_STATE}" from a model field instead ` +
        `(precedent: weightState and the stock/delivery status pack were removed for this).`,
    );
  }
  if (value.includes("sap-icon://")) {
    problems.push(
      `line ${line}: the literal "${value}" hardcodes an icon URI. Which icon stands for which ` +
        `business value is a backend decision - let the icon name travel in the data.`,
    );
  }
}

if (problems.length) {
  console.error(
    "formatter-scope-gate: app/webapp/model/formatter.js violates the admission criteria in its header:",
  );
  for (const p of problems) console.error(`  - ${p}`);
  console.error(
    "\nabap2UI5 is a thin frontend: the backend decides, the frontend renders.",
  );
  process.exit(1);
}

console.log(
  `formatter-scope-gate: ${Object.keys(MANIFEST).length} curated formatters, each justified, ` +
    `no ValueState or icon URI hardcoded - OK`,
);
