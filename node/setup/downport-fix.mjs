#!/usr/bin/env node
/*
 * The in-place rewrites `npm run downport` applies to node/downport/
 * after abaplint has produced it, and the one it applies to abaplint.jsonc
 * after `auto_downport` has copied the 702 config over it.
 *
 * They were three `sed -i` one-liners in package.json, and all three were
 * GNU-only in two independent ways: BSD/macOS `sed -i` requires a backup
 * suffix argument (`sed -i '' …`), and `[[:space:]]\+` uses the GNU escape
 * for one-or-more, which BSD sed reads as a literal `+`. On macOS the first
 * failed loudly and the second silently stripped nothing - so `npm run
 * downport`, and with it `npm run verify`, could not run outside Linux at
 * all. package.json already declares `"node": ">=22"`; a Node script is the
 * portable form of a tool the repository is entitled to assume.
 *
 * Usage:
 *   node node/setup/downport-fix.mjs syfixes
 *   node node/setup/downport-fix.mjs strip-trailing-ws
 *   node node/setup/downport-fix.mjs abaplint-path
 *   node node/setup/downport-fix.mjs downport-config
 *   node node/setup/downport-fix.mjs copy-src
 *   node node/setup/downport-fix.mjs prepare-transpile
 *   node node/setup/downport-fix.mjs check-generic-like
 *   node node/setup/downport-fix.mjs assert-bool
 *   node node/setup/downport-fix.mjs check-702
 */
import { fileURLToPath } from "url";
import { readFileSync, writeFileSync, readdirSync, rmSync, cpSync } from "node:fs";
import { join } from "node:path";

const ROOT = fileURLToPath(new URL("../../", import.meta.url));
const DOWNPORT = join(ROOT, "node", "downport");

function abapFiles(dir) {
  const out = [];
  for (const entry of readdirSync(dir, { withFileTypes: true })) {
    const full = join(dir, entry.name);
    if (entry.isDirectory()) out.push(...abapFiles(full));
    else if (entry.isFile() && entry.name.endsWith(".abap")) out.push(full);
  }
  return out;
}

/* Rewrite every .abap under node/downport with `fn`, and report how many
 * files actually changed - a rewrite that matches nothing is how the BSD
 * `sed` version failed, silently. */
function rewriteDownport(label, fn) {
  let files;
  try {
    files = abapFiles(DOWNPORT);
  } catch (e) {
    if (e.code === "ENOENT") {
      console.error(`${label}: node/downport does not exist - run 'npm run downport'`);
      process.exit(1);
    }
    throw e;
  }
  let changed = 0;
  for (const file of files) {
    const before = readFileSync(file, "utf8");
    const after = fn(before);
    if (after !== before) {
      writeFileSync(file, after);
      changed += 1;
    }
  }
  console.log(`${label}: ${changed} of ${files.length} file(s) rewritten`);
}

const MODES = {
  /* 7.02 has no CX_SY_ITAB_LINE_NOT_FOUND to raise; the downported code
   * asserts instead. Leading space kept from the original expression so the
   * keyword is not matched inside a longer identifier. */
  syfixes: () =>
    rewriteDownport("syfixes", (text) =>
      text.replaceAll(" RAISE EXCEPTION TYPE cx_sy_itab_line_not_found", " ASSERT 1 = 0")),

  /* abaplint's --fix leaves trailing whitespace behind on rewritten lines,
   * and the 702 lint that follows rejects it. */
  "strip-trailing-ws": () =>
    rewriteDownport("strip-trailing-ws", (text) => text.replace(/[ \t\f\v\r]+$/gm, "")),

  /* `auto_downport` copies abap_702.jsonc over abaplint.jsonc. That config
   * is read from .github/abaplint/, so its glob reaches up two levels; at
   * the repository root the same glob has to be root-relative. */
  "abaplint-path": () => {
    const file = join(ROOT, "abaplint.jsonc");
    const before = readFileSync(file, "utf8");
    const after = before.replaceAll('"files": "/../../src/**/*.*"', '"files": "/src/**/*.*"');
    // Loud, never a silent pass: this mode runs right after abap_702.jsonc
    // was copied over abaplint.jsonc, so the glob IS there or the copy (or
    // the glob string in abap_702.jsonc) changed. "Nothing to do" here once
    // meant the 702 branch kept a config pointing at /../../src, over which
    // abaplint lints zero files and reports green.
    if (after === before) {
      console.error("abaplint-path: abaplint.jsonc carries no \"/../../src/**/*.*\" glob to rewrite");
      console.error("  expected the copy of .github/abaplint/abap_702.jsonc - did its \"files\" glob change? Then change the string here too.");
      process.exit(1);
    }
    writeFileSync(file, after);
    console.log("abaplint-path: abaplint.jsonc glob rewritten to /src/**/*.*");
  },

  /* The remaining shell one-liners of the downport pipeline, for the same
   * reason as the three modes above: `sed`, `rm -rf` and `cp -r` in
   * package.json are what kept `npm run downport` (and with it `verify`)
   * Linux-only. */

  /* Derive the gitignored downport_run.jsonc from abap_702.jsonc: same
   * rules, globs retargeted from src/ at node/downport/. Was a sed. */
  "downport-config": () => {
    const src = readFileSync(join(ROOT, ".github", "abaplint", "abap_702.jsonc"), "utf8");
    const out = src.replaceAll("/../../src/", "/../../node/downport/");
    writeFileSync(join(ROOT, ".github", "abaplint", "downport_run.jsonc"), out);
    console.log("downport-config: downport_run.jsonc written");
  },

  /* Fresh copy of src/ into node/downport/. Was `rm -rf && cp -r`. */
  "copy-src": () => {
    rmSync(DOWNPORT, { recursive: true, force: true });
    cpSync(join(ROOT, "src"), DOWNPORT, { recursive: true });
    console.log("copy-src: src/ copied to node/downport/");
  },

  /* The downport lowers `REF #( x )` in an operand position into
   *
   *   DATA temp1 LIKE REF TO x.
   *   GET REFERENCE OF x INTO temp1.
   *
   * and does so for a generically typed field symbol too, which a real
   * 7.02-7.4x system refuses: "The field "<TAB>" specified under LIKE either
   * does not have a type or has a generic type" - the whole class pool, test
   * include included, fails to compile. abaplint's own v702 check_syntax
   * passes that line (measured on 2.120.52: 0 issues over the tree that
   * carried two of them), so ABAP_702.yaml cannot see it and neither can the
   * source-side gates - `REF #( <tab> )` is valid at v750. This check reads
   * the downport's OUTPUT, the only place the shape exists.
   * Fix in src/: assign to a typed variable first (`lr = REF #( <tab> ).`
   * with `lr TYPE REF TO data`), then pass the variable - the downport turns
   * that into a plain `GET REFERENCE OF <tab> INTO lr`. */
  "check-generic-like": () => {
    const SELF_TEST = [
      ["METHOD m.\n  FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.\n  DATA temp1 LIKE REF TO <tab>.", 1],
      ["METHOD m.\n  FIELD-SYMBOLS <row> TYPE any.\n  DATA temp1 LIKE <row>.", 1],
      ["METHOD m.\n  FIELD-SYMBOLS <tab> TYPE ANY TABLE.\n  DATA temp1 LIKE LINE OF <tab>.", 1],
      // a concrete type is what LIKE needs, and a component is never generic here
      ["METHOD m.\n  FIELD-SYMBOLS <row> TYPE ty_s_row.\n  DATA temp1 LIKE REF TO <row>.", 0],
      ["METHOD m.\n  FIELD-SYMBOLS <tab> TYPE STANDARD TABLE OF ty_s_row.\n  DATA temp1 LIKE <tab>.", 0],
      // the typed declaration in the NEXT method must not see the generic one
      ["METHOD a.\n  FIELD-SYMBOLS <row> TYPE any.\nENDMETHOD.\nMETHOD b.\n  FIELD-SYMBOLS <row> TYPE ty_s_row.\n  DATA temp1 LIKE REF TO <row>.", 0],
    ];
    for (const [text, expected] of SELF_TEST) {
      const got = genericLikeFindings(text).length;
      if (got !== expected) {
        console.error("check-generic-like: self-test failed");
        console.error(`  ${text.replaceAll("\n", " | ")}`);
        console.error(`  expected ${expected} finding(s), got ${got}`);
        process.exit(1);
      }
    }
    const files = abapFiles(DOWNPORT);
    const findings = files.flatMap((file) =>
      genericLikeFindings(readFileSync(file, "utf8")).map((f) => ({ file: file.slice(DOWNPORT.length + 1), ...f })));
    if (findings.length) {
      console.error(`check-generic-like: ${findings.length} declaration(s) LIKE a generically typed field symbol:`);
      for (const f of findings) console.error(`  node/downport/${f.file}:${f.line}: ${f.text}`);
      console.error("  7.02-7.4x refuses these (\"specified under LIKE ... has a generic type\").");
      console.error("  In src/: assign REF #( <fs> ) to a variable TYPE REF TO data first and pass that.");
      process.exit(1);
    }
    console.log(`check-generic-like: ${files.length} file(s), no LIKE on a generic field symbol - OK`);
  },

  /* CL_ABAP_UNIT_ASSERT on 7.02 has no ASSERT_TRUE / ASSERT_FALSE (they
   * came with 7.40) - "Method ASSERT_TRUE does not exist", and the test
   * include takes the whole class pool down with it (#2947). abaplint does
   * not see it: its v702 check_syntax resolves the class against
   * open-abap-core, which has both. Main keeps the idiomatic calls; the
   * downport rewrites them into the ASSERT_EQUALS they mean:
   *
   *   assert_true( x )             -> assert_equals( exp = abap_true act = x )
   *   assert_false( act = x msg = m ) -> assert_equals( exp = abap_false act = x msg = m )
   *
   * ACT, MSG, LEVEL and QUIT exist on ASSERT_EQUALS with the same meaning. */
  "assert-bool": () => {
    const SELF_TEST = [
      ["    cl_abap_unit_assert=>assert_true( temp1 ).",
        "    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp1 )."],
      ["    cl_abap_unit_assert=>assert_false( act = lv_x msg = `a ) b` ).",
        "    cl_abap_unit_assert=>assert_equals( exp = abap_false act = lv_x msg = `a ) b` )."],
      ["    cl_abap_unit_assert=>assert_true(\n        z2ui5_cl_util=>x( |{ a( ) }| ) ). \" ) comment",
        "    cl_abap_unit_assert=>assert_equals( exp = abap_true act =\n        z2ui5_cl_util=>x( |{ a( ) }| ) ). \" ) comment"],
      // inside a literal - generated code, not a call - stays as it is
      ["    x = `cl_abap_unit_assert=>assert_true( y ).`.", null],
    ];
    for (const [text, expected] of SELF_TEST) {
      const got = rewriteAssertBool(text);
      if (got !== (expected ?? text)) {
        console.error("assert-bool: self-test failed");
        console.error(`  ${text.replaceAll("\n", " | ")}`);
        console.error(`  expected ${JSON.stringify(expected ?? text)}`);
        console.error(`  got      ${JSON.stringify(got)}`);
        process.exit(1);
      }
    }
    rewriteDownport("assert-bool", rewriteAssertBool);
  },

  /* The shapes a real 7.02 refuses and abaplint's v702 profile lets through
   * (#2947), read from the downport's OUTPUT - the tree that is installed.
   * Each finding names the fix in src/. */
  "check-702": () => {
    const SELF_TEST = [
      ["    cl_abap_unit_assert=>assert_true( x ).", 1],
      ["    get_root( )->xml_get_parts( CHANGING ct_parts = lt_parts ).", 1],
      ["    a=>b( )->c(\n      EXPORTING x = 1 ).", 1],
      ["    lo_root->xml_get_parts( CHANGING ct_parts = lt_parts ).", 0],
      ["    DATA lv_big TYPE int8.", 1],
      ["    INSERT substring( val = v off = 1 ) INTO TABLE result.", 1],
      ["    INSERT lv_part INTO TABLE result.", 0],
      [`    x = \`${"a".repeat(260)}\`.`, 1],
      ["    \" a comment about TYPE int8", 0],
    ];
    for (const [text, expected] of SELF_TEST) {
      const got = check702Findings(text).length;
      if (got !== expected) {
        console.error("check-702: self-test failed");
        console.error(`  ${text.replaceAll("\n", " | ")}`);
        console.error(`  expected ${expected} finding(s), got ${got}`);
        process.exit(1);
      }
    }
    const files = abapFiles(DOWNPORT);
    const findings = files.flatMap((file) =>
      check702Findings(readFileSync(file, "utf8")).map((f) => ({ file: file.slice(DOWNPORT.length + 1), ...f })));
    if (findings.length) {
      console.error(`check-702: ${findings.length} construct(s) a 7.02 system refuses:`);
      for (const f of findings) console.error(`  node/downport/${f.file}:${f.line}: ${f.why}\n      ${f.text}`);
      process.exit(1);
    }
    console.log(`check-702: ${files.length} file(s), no construct 7.02 refuses - OK`);
  },

  /* Clear node/output/ and drop the test-server sources into the downport
   * tree so the transpiler folds them in. Was `rm -rf && cp`. */
  "prepare-transpile": () => {
    rmSync(join(ROOT, "node", "output"), { recursive: true, force: true });
    let copied = 0;
    for (const entry of readdirSync(join(ROOT, "node", "srv"))) {
      if (entry.endsWith(".abap") || entry.endsWith(".clas.xml")) {
        cpSync(join(ROOT, "node", "srv", entry), join(DOWNPORT, entry));
        copied += 1;
      }
    }
    if (copied === 0) {
      console.error("prepare-transpile: no .abap/.clas.xml found in node/srv - nothing to fold in");
      process.exit(1);
    }
    console.log(`prepare-transpile: node/output cleared, ${copied} node/srv file(s) copied`);
  },
};

/* A field symbol typed generically - `TYPE any`, `TYPE data`, `TYPE STANDARD
 * TABLE`, ... - carries no static type a declaration could copy. */
const GENERIC_FS =
  /^TYPE\s+(?:any(?:\s+table)?|data|simple|clike|csequence|xsequence|numeric|c|n|x|p|decfloat|table|(?:standard|index|sorted|hashed)\s+table)\s*\.?$/i;
const FS_DECL = /^\s*FIELD-SYMBOLS\s+(<\w+>)\s+(.*?)\s*$/i;
const DATA_LIKE_FS = /^\s*DATA\s+\w+\s+LIKE\s+(?:REF\s+TO\s+|LINE\s+OF\s+)?(<\w+>)\s*\./i;

/* Every `DATA x LIKE [REF TO | LINE OF] <fs>` whose <fs> the same method
 * declares generically. Scoped per METHOD because the same name is `TYPE
 * any` in one test method and a concrete row type in the next. */
function genericLikeFindings(text) {
  const out = [];
  let decl = new Map();
  text.split("\n").forEach((line, i) => {
    if (/^\s*(?:METHOD|FORM|FUNCTION)\s/i.test(line)) decl = new Map();
    const fs = FS_DECL.exec(line);
    if (fs) decl.set(fs[1].toLowerCase(), fs[2]);
    const like = DATA_LIKE_FS.exec(line);
    if (like && GENERIC_FS.test(decl.get(like[1].toLowerCase()) ?? "")) {
      out.push({ line: i + 1, text: line.trim() });
    }
  });
  return out;
}

/* The index of the `)` that closes the `(` at `open`, skipping literals
 * ('...', `...`, |...| with its { } expressions) and " comments; -1 when
 * the text ends first. */
function closingParen(text, open) {
  let depth = 0;
  for (let i = open; i < text.length; i++) {
    const c = text[i];
    if (c === "'" || c === "`") {
      // a doubled delimiter is the escape, so a literal simply resumes
      i = text.indexOf(c, i + 1);
      if (i < 0) return -1;
    } else if (c === "|") {
      i = templateEnd(text, i);
      if (i < 0) return -1;
    } else if (c === "\"") {
      i = text.indexOf("\n", i);
      if (i < 0) return -1;
    } else if (c === "(") {
      depth += 1;
    } else if (c === ")") {
      depth -= 1;
      if (depth === 0) return i;
    }
  }
  return -1;
}

/* The index of the `|` that closes the string template at `start`. */
function templateEnd(text, start) {
  for (let i = start + 1; i < text.length; i++) {
    const c = text[i];
    if (c === "\\") i += 1;
    else if (c === "|") return i;
    else if (c === "{") {
      // an embedded expression: code again, up to its closing brace
      let depth = 1;
      for (i += 1; i < text.length && depth > 0; i++) {
        const d = text[i];
        if (d === "'" || d === "`") i = text.indexOf(d, i + 1);
        else if (d === "|") i = templateEnd(text, i);
        else if (d === "{") depth += 1;
        else if (d === "}") depth -= 1;
        if (i < 0) return -1;
      }
      i -= 1;
    }
  }
  return -1;
}

const ASSERT_BOOL = /^([ \t]*cl_abap_unit_assert=>)assert_(true|false)\(/gim;
const ASSERT_BOOL_NAMED = /^\s*(?:act|msg|level|quit)\s*=/i;

function rewriteAssertBool(text) {
  let out = "";
  let last = 0;
  for (const m of text.matchAll(ASSERT_BOOL)) {
    if (m.index < last) continue;
    const open = m.index + m[0].length - 1;
    const close = closingParen(text, open);
    if (close < 0) throw new Error(`assert-bool: no closing parenthesis for ${m[0].trim()}`);
    const args = text.slice(open + 1, close);
    const exp = m[2].toLowerCase() === "true" ? "abap_true" : "abap_false";
    const named = ASSERT_BOOL_NAMED.test(args) ? args.replace(/^ /, "") : `act =${args}`.replace(/^act = {2,}/, "act = ");
    out += `${text.slice(last, m.index)}${m[1]}assert_equals( exp = ${exp} ${named})`;
    last = close + 1;
  }
  return out + text.slice(last);
}

/* The statement-level shapes check-702 refuses, as [regex, why]. Comments
 * are blanked before they run; a literal can still match, which is what a
 * self-test entry and a finding would show. */
const BUILTIN_FUNCTIONS =
  "substring|substring_after|substring_before|substring_from|substring_to|condense|to_upper|to_lower|to_mixed|from_mixed|" +
  "concat_lines_of|replace|shift_left|shift_right|segment|match|repeat|reverse|escape|translate|strlen|xstrlen|lines|boolc|xsdbool|cmax|cmin|nmax|nmin|char_off|count|find";
const CHECK_702 = [
  [/^[ \t]*cl_abap_unit_assert=>assert_(?:true|false)\(/gim,
    "ASSERT_TRUE/ASSERT_FALSE do not exist on 7.02 - the assert-bool step should have rewritten this"],
  [/\)->[\w~]+\(\s*(?:EXPORTING|IMPORTING|CHANGING|RECEIVING)\b/gi,
    "EXPORTING/IMPORTING/CHANGING in a chained method call - in src/, assign the object to a variable first"],
  [/\bTYPE\s+int8\b/gi,
    "INT8 does not exist before 7.50 - in src/, use TYPE p LENGTH 16 DECIMALS 0 (or i where it fits)"],
  [new RegExp(`^[ \\t]*INSERT\\s+(?:${BUILTIN_FUNCTIONS})\\(`, "gim"),
    "a built-in function as the INSERT operand reads as a method call on 7.02 - in src/, assign it to a variable first"],
];

function check702Findings(text) {
  // blank full-line and end-of-line comments, keep the line structure
  const code = text.split("\n").map((line) => {
    if (line.startsWith("*")) return "";
    let quote = null;
    for (let i = 0; i < line.length; i++) {
      const c = line[i];
      if (quote) { if (c === quote) quote = null; } else if (c === "'" || c === "`" || c === "|") quote = c;
      else if (c === "\"") return line.slice(0, i);
    }
    return line;
  }).join("\n");
  const lineOf = (index) => code.slice(0, index).split("\n").length;
  const lines = text.split("\n");
  const out = [];
  for (const [re, why] of CHECK_702) {
    for (const m of code.matchAll(re)) {
      const line = lineOf(m.index);
      out.push({ line, why, text: lines[line - 1].trim() });
    }
  }
  // the 7.02 editor stores 255 characters a line and cuts the rest on import
  lines.forEach((line, i) => {
    if (line.length > 255) {
      out.push({ line: i + 1, why: `${line.length} characters - 7.02 cuts a source line at 255 on import`, text: `${line.slice(0, 80)}...` });
    }
  });
  return out.sort((a, b) => a.line - b.line);
}

const mode = process.argv[2];
if (!Object.hasOwn(MODES, mode)) {
  console.error(`downport-fix: unknown mode ${JSON.stringify(mode)}`);
  console.error(`  expected one of: ${Object.keys(MODES).join(", ")}`);
  process.exit(1);
}
MODES[mode]();
