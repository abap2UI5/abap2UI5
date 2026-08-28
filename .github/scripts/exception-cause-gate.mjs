// Gate: a raise inside a CATCH may not inline the caught exception's text into
// its own message.
//
//   CATCH cx_root INTO DATA(x).
//     RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error
//       EXPORTING val = |MY_ERROR - { x->get_text( ) }|.   " <- the finding
//
//   CATCH cx_root INTO DATA(x).
//     RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error
//       EXPORTING val      = `MY_ERROR`
//                 previous = x.                            " <- what to write
//
// Why it matters, and why prose was not enough. The framework has ONE
// top-level catch, and it renders what it caught with
// z2ui5_cx_ui5_util_error=>get_text_full - one block per link of the
// `previous` chain, each with the exception class, its own text, the source
// position it was raised at, the kernel error id and every public attribute
// that carries a value. That is what a 500 body carries, and it is what makes
// "it dumped" a report somebody can act on without reproducing it on the
// system.
//
// Inlining get_text( ) into a string template flattens all of that to one
// line: the chain stops at the raise, the position of the method that
// actually failed is gone, and so are the attributes that say WHICH value did
// not fit. The message is not even richer for it - get_text_full renders the
// caught exception's text anyway, one link down, next to everything else it
// knows.
//
// AGENTS.md has forbidden this since the exception class was written
// ("Never inline a cause into a message"), and five raises in
// z2ui5_cl_ui5_frontend did it anyway - the four option marshallers and the
// action builder, all five raising a z2ui5_cx_ajson_error whose position is
// the only thing that says which option was malformed. A rule nobody checks
// is a rule that comes back.
//
// Scope: this repository's own ABAP, the same three exclusions the other ABAP
// gates use - src/00/01 (AJSON) and src/00/02 (S-RTTI) are upstream mirrors,
// src/99 is frozen history.

import { readFileSync } from "fs";
import { join } from "path";
import { walk } from "./lib/walk.mjs";

const ROOT = new URL("../../", import.meta.url).pathname;

const EXCLUDED = [/^src\/99\//, /^src\/00\/01\//, /^src\/00\/02\//];

// Statement splitter: the same shape the extended-check gate uses. Comments
// are skipped rather than kept - nothing here is decided by a pseudo-comment.
function statements(source) {
  const out = [];
  let code = [];
  let start = 0;
  let line = 0;

  for (const raw of source.split("\n")) {
    line += 1;
    if (/^\*/.test(raw)) continue; // full-line comment
    if (code.length === 0) {
      if (raw.trim() === "" || raw.trim().startsWith('"')) continue;
      start = line;
    }
    code.push(raw);

    let quote = null;
    let end = -1;
    for (let i = 0; i < raw.length; i += 1) {
      const c = raw[i];
      if (quote) {
        if (c === quote) quote = null;
        continue;
      }
      if (c === "`" || c === "'") {
        quote = c;
        continue;
      }
      if (c === '"') break; // rest of the line is a comment
      if (c === ".") {
        end = i;
        break;
      }
    }
    if (end >= 0) {
      out.push({ start, text: code.join("\n") });
      code = [];
    }
  }
  if (code.length > 0) out.push({ start, text: code.join("\n") });
  return out;
}

const files = walk(ROOT, "src")
  .filter(f => f.endsWith(".abap"))
  .filter(f => !EXCLUDED.some(re => re.test(f)))
  .sort();

const findings = [];

for (const file of files) {
  const stmts = statements(readFileSync(join(ROOT, file), "utf8"));

  // TRY blocks nest, so the handler state is a stack: TRY pushes, CATCH and
  // CLEANUP mark the innermost open TRY as being in its handler, ENDTRY pops.
  const tryStack = [];

  for (const stmt of stmts) {
    const flat = stmt.text.replace(/\n/g, " ");

    if (/^\s*TRY\s*\.?\s*$/i.test(flat.trim())) {
      tryStack.push(false);
      continue;
    }
    if (/^\s*(CATCH|CLEANUP)\b/i.test(flat)) {
      if (tryStack.length > 0) tryStack[tryStack.length - 1] = true;
      continue;
    }
    if (/^\s*ENDTRY\b/i.test(flat)) {
      tryStack.pop();
      continue;
    }

    if (!tryStack.some(Boolean)) continue;
    if (!/^\s*RAISE\s+EXCEPTION\b/i.test(flat)) continue;

    // `val = ` up to the next parameter name or the end of the statement. A
    // get_text( ) anywhere in there is the caught exception being rendered
    // into the new message.
    const val = /\bval\s*=\s*(.*?)(?:\s+\w+\s*=|$)/is.exec(flat);
    if (!val) continue;
    if (!/\bget_text\s*\(\s*\)/i.test(val[1])) continue;

    findings.push({ at: `${file}:${stmt.start}`, val: val[1].trim().replace(/\.$/, "") });
  }
}

if (findings.length > 0) {
  console.log("exception cause: these raises flatten the chain they were handed.");
  console.log("");
  for (const f of findings) {
    console.log(`  ${f.at}`);
    console.log(`    val = ${f.val}`);
    console.log("      pass the message as `val` and the caught exception as `previous`;");
    console.log("      get_text_full( ) renders its text, position and attributes from there.");
  }
  console.log("");
  console.log('Background: AGENTS.md, "Exception handling", and z2ui5_cx_ui5_util_error.');
  process.exit(1);
}

console.log(`exception-cause: ${files.length} file(s) checked - OK`);
