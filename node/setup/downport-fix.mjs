#!/usr/bin/env node
/*
 * The two in-place rewrites `npm run downport` applies to node/downport/
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
    if (after === before) {
      console.log("abaplint-path: abaplint.jsonc carries no /../../src glob - nothing to do");
      return;
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

const mode = process.argv[2];
if (!Object.hasOwn(MODES, mode)) {
  console.error(`downport-fix: unknown mode ${JSON.stringify(mode)}`);
  console.error(`  expected one of: ${Object.keys(MODES).join(", ")}`);
  process.exit(1);
}
MODES[mode]();
