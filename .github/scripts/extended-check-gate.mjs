// Gate: the extended program check (SLIN / ATC) runs in real systems and not
// here. Every rule below is a finding that a green `npm run check` did not
// prevent, was found by running the check in a system, and was repaired
// afterwards by adding the pseudo-comment or the pragma the check asks for:
//
//   sortseq      43515c97, 0d9a7485, 5b9e16ea "fix atc findings" / "fix cloud
//                atc findings" - LOOP AT over a STANDARD table with a WHERE
//                condition is a sequential read; the check wants
//                "#EC CI_SORTSEQ on the statement. Fifteen of them were
//                annotated in those three commits alone.
//   no_handler   43515c97 - an empty CATCH block. The check flags a handler
//                that does nothing; ##NO_HANDLER is how you say it is
//                deliberate.
//   regex_posix  44642cbe "fix: resolve extended-check warnings" - FIND and
//                REPLACE ... REGEX are POSIX, which is deprecated. FIND PCRE
//                needs >= 7.55 and this repo targets v750/7.02, so the
//                statement stays and carries ##REGEX_POSIX (the convention the
//                vendored AJSON code follows).
//
// Why a gate and not prose: abaplint models none of these. They are checks of a
// different tool, and prose in AGENTS.md did not stop the three "fix atc
// findings" commits from being needed.
//
// Scope: this repository's own ABAP. src/00/01 (AJSON) and src/00/02 (S-RTTI)
// are upstream mirrors and src/99 is frozen history - annotating them would
// create diffs nobody is allowed to make.

import { readdirSync, readFileSync } from "fs";
import { join } from "path";

const ROOT = new URL("../../", import.meta.url).pathname;

const EXCLUDED = [/^src\/99\//, /^src\/00\/01\//, /^src\/00\/02\//];

const findings = [];

function walk(dir, out = []) {
  for (const entry of readdirSync(join(ROOT, dir), { withFileTypes: true })) {
    const rel = `${dir}/${entry.name}`;
    if (entry.isDirectory()) walk(rel, out);
    else out.push(rel);
  }
  return out;
}

// Split ABAP source into statements. Comments are kept, not stripped: the
// pseudo-comments this gate is about ("#EC ...) live in exactly the trailing
// comment of the statement they annotate.
function statements(source) {
  const out = [];
  let code = [];
  let start = 0;
  let line = 0;

  for (const raw of source.split("\n")) {
    line += 1;
    if (/^\*/.test(raw)) continue; // full-line comment: not part of any statement
    if (code.length === 0) {
      // Between statements, an indented `"` line is a comment of its own. Only
      // once a statement is open can such a line be a continuation of it.
      if (raw.trim() === "" || raw.trim().startsWith('"')) continue;
      start = line;
    }
    code.push(raw);

    // find the statement terminator: a period outside a string and outside the
    // trailing comment
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

const files = walk("src")
  .filter(f => f.endsWith(".abap"))
  .filter(f => !EXCLUDED.some(re => re.test(f)))
  .sort();

for (const file of files) {
  const stmts = statements(readFileSync(join(ROOT, file), "utf8"));

  stmts.forEach((stmt, index) => {
    const flat = stmt.text.replace(/\n/g, " ");
    const at = `${file}:${stmt.start}`;

    if (/^\s*LOOP\s+AT\b/i.test(flat) && /\bWHERE\b/i.test(flat) && !/CI_SORTSEQ/i.test(flat)) {
      findings.push({
        at,
        rule: "sortseq",
        message: 'LOOP AT ... WHERE is a sequential read - the extended check wants "#EC CI_SORTSEQ on the statement',
      });
    }

    if (/^\s*(FIND|REPLACE)\b/i.test(flat) && /\bREGEX\b/i.test(flat) && !/REGEX_POSIX/i.test(flat)) {
      findings.push({
        at,
        rule: "regex_posix",
        message: "REGEX is POSIX and deprecated - prefer plain string logic, or carry ##REGEX_POSIX",
      });
    }

    if (/^\s*CATCH\b/i.test(flat) && !/##NO_HANDLER/i.test(flat)) {
      const next = stmts[index + 1];
      if (next && /^\s*(ENDTRY|CATCH|CLEANUP)\b/i.test(next.text.replace(/\n/g, " "))) {
        findings.push({
          at,
          rule: "no_handler",
          message: "empty CATCH block - say it is deliberate with ##NO_HANDLER, or handle the exception",
        });
      }
    }
  });
}

if (findings.length > 0) {
  console.log("extended check (SLIN/ATC): these statements fire in a real system.");
  console.log("");
  const byRule = new Map();
  for (const f of findings) {
    if (!byRule.has(f.rule)) byRule.set(f.rule, []);
    byRule.get(f.rule).push(f);
  }
  for (const [rule, group] of byRule) {
    console.log(`  [${rule}]`);
    for (const f of group) console.log(`    ${f.at}\n      ${f.message}`);
    console.log("");
  }
  console.log("Background and the fix for each rule: .claude/skills/abap-check/SKILL.md, section 3");
  process.exit(1);
}

console.log(`extended-check: ${files.length} file(s) checked - OK`);
