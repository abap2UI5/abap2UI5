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
//   abapdoc      "ABAP Doc comment is in the wrong position" - a "! block
//                before a chain keyword, inside a parameter list, or before a
//                section end attaches to no declaration and is never shown.
//                Third recurrence: z2ui5_if_client=>cs_nav_mode here, then
//                samples-stack's cs_status (7459f39), then five findings on
//                samples-stack's overview app from a user's system
//                (2026-08-17). Upstream rule proposed - backlog:
//                abaplint-abapdoc-block-placement.
//   abapdoc_html "HTML tag <wa> is not supported in ABAP Doc" - ABAP Doc is
//                parsed as HTML, so a placeholder or a field symbol written
//                as <name> is an unsupported, unclosed tag. AGENTS.md said
//                so in prose and three of them shipped in z2ui5_if_client
//                (#2705), found by a user's system on 2026-09-02.
//   handle_call  "No method can be specified in the current position" -
//                CREATE DATA ... TYPE HANDLE takes a data object, not a
//                method call; abaplint and the transpiler accept the call
//                (found by a user's system on 2026-09-02, in a test class
//                that was green through every gate).
//   preferred_   'Declare the parameter "VAL" as OPTIONAL. The addition
//   param        PREFERRED PARAMETER is ignored if non-optional parameters
//                are used' - the addition only picks the parameter a
//                short-form call fills when every IMPORTING parameter is
//                optional. Found on a user's system on 2026-09-05, hours
//                after z2ui5_cl_ui5_util_context=>msg_get_internal gained a
//                second, defaulted parameter that morning (#2719) and took
//                the addition along with it.
//
// Why a gate and not prose: abaplint models none of these. They are checks of a
// different tool, and prose in AGENTS.md did not stop the three "fix atc
// findings" commits from being needed.
//
// Scope: this repository's own ABAP. src/00/01 (AJSON) and src/00/02 (S-RTTI)
// are upstream mirrors and src/99 is frozen history - annotating them would
// create diffs nobody is allowed to make.

import { readFileSync } from "fs";
import { join } from "path";
import { fileURLToPath } from "url";
import { walk } from "./lib/walk.mjs";
// The statement splitter is shared with exception-cause-gate. It keeps
// comments rather than stripping them: the pseudo-comments this gate is about
// ("#EC ...) live in exactly the trailing comment of the statement they
// annotate.
import { statements, stripNoise } from "./lib/abap-statements.mjs";

const ROOT = fileURLToPath(new URL("../../", import.meta.url));

const EXCLUDED = [/^src\/99\//, /^src\/00\/01\//, /^src\/00\/02\//];

const findings = [];

const files = walk(ROOT, "src")
  .filter(f => f.endsWith(".abap"))
  .filter(f => !EXCLUDED.some(re => re.test(f)))
  .sort();

// An ABAP Doc block attaches to the ONE declaration directly below it. The
// statement splitter above strips comment lines, so this check reads the raw
// lines: a block before a chain keyword, inside a parameter list (the code
// line above it ends in neither `.` nor `:` nor `,`), or before a section end
// documents nothing. Only the class-pool main and interface sources carry
// declarations ABAP Doc can reach.
const CHAIN_KEYWORD =
  /^\s*(constants|data|types|methods|class-methods|class-data|events)\s*:\s*$/i;
const NOTHING_TO_DOCUMENT =
  /^\s*(end\s+of\b|endclass\b|endinterface\b|(public|protected|private)\s+section\b)/i;

function abapdocFindings(file, source) {
  const out = [];
  const src = source.split("\n");
  src.forEach((line, i) => {
    if (!/^\s*"!/.test(line)) return;
    if (/^\s*"!/.test(src[i - 1] || "")) return; // only the block's first line

    /* Walk up to the previous line of CODE. What is skipped is everything
     * that cannot end a statement: a blank line and a full-line comment -
     * `"` and `*` alike. The `*` half was missing, so a `*` note above a
     * correctly placed block became the "previous line", ended in no
     * terminator, and the block was reported as sitting in a parameter list.
     * The `"` half now includes `"!`, because an ABAP Doc block is not code
     * either. */
    let p = i - 1;
    while (p >= 0 && (!src[p].trim() || /^\s*[*"]/.test(src[p]))) p -= 1;
    /* ...and the code line's own TRAILING comment is not part of it. Testing
     * the raw line for its terminator made `DATA foo TYPE i. " why` end in a
     * `y`, which is the same false finding from the other side. */
    const prev = p >= 0 ? stripNoise(src[p]).trim() : "";

    let n = i + 1;
    while (n < src.length && (/^\s*"!/.test(src[n]) || !src[n].trim())) n += 1;
    const next = n < src.length ? src[n].trim() : "";

    const at = `${file}:${i + 1}`;
    if (prev && !/[.:,]$/.test(prev)) {
      out.push({
        at,
        rule: "abapdoc",
        message: '"! inside a parameter list documents nothing - use "! @parameter <name> | <text> in the method\'s own block',
      });
    } else if (CHAIN_KEYWORD.test(next)) {
      out.push({
        at,
        rule: "abapdoc",
        message: `"! before the chain keyword \`${next}\` documents nothing - move it inside the chain, directly before the member`,
      });
    } else if (NOTHING_TO_DOCUMENT.test(next)) {
      out.push({ at, rule: "abapdoc", message: `"! before \`${next}\` documents nothing` });
    }
  });
  return out;
}

/* Self-test: the placement rule, on the shapes that decide it, before a
 * single source file is read. The gate is green over src/ either way - the
 * findings it was written for were repaired in the change that added it - so
 * a rule that started reporting correctly placed blocks, or stopped reporting
 * misplaced ones, would be invisible here. Both halves below actually
 * happened: a `*` note and a trailing comment each made a correctly placed
 * block look like one sitting in a parameter list.
 *
 * `expect` is the number of findings on the snippet. */
const ABAPDOC_SELF_TEST = [
  {
    name: "a block directly before its declaration - the correct shape",
    source: 'CLASS zcl_x DEFINITION.\n  PUBLIC SECTION.\n    "! what it does\n    METHODS run.\nENDCLASS.',
    expect: 0,
  },
  {
    name: "the code line above ends in a TRAILING COMMENT",
    source: 'CLASS zcl_x DEFINITION.\n  PUBLIC SECTION.\n    DATA mv_a TYPE i. " the counter\n    "! what it does\n    METHODS run.\nENDCLASS.',
    expect: 0,
  },
  {
    name: "a `*` comment line sits between the code and the block",
    source: 'CLASS zcl_x DEFINITION.\n  PUBLIC SECTION.\n    DATA mv_a TYPE i.\n* a note about what follows\n    "! what it does\n    METHODS run.\nENDCLASS.',
    expect: 0,
  },
  {
    name: "inside a parameter list - the finding the rule exists for",
    source: 'CLASS zcl_x DEFINITION.\n  PUBLIC SECTION.\n    METHODS run\n      IMPORTING\n        "! the value\n        val TYPE i.\nENDCLASS.',
    expect: 1,
  },
  {
    name: "before the chain keyword instead of inside the chain",
    source: 'CLASS zcl_x DEFINITION.\n  PUBLIC SECTION.\n    "! the modes\n    CONSTANTS:\n      BEGIN OF cs_mode,\n        a TYPE string VALUE `A`,\n      END OF cs_mode.\nENDCLASS.',
    expect: 1,
  },
  {
    name: "before a section end, where there is nothing to document",
    source: 'CLASS zcl_x DEFINITION.\n  PUBLIC SECTION.\n    METHODS run.\n    "! orphaned\n  PROTECTED SECTION.\n  PRIVATE SECTION.\nENDCLASS.',
    expect: 1,
  },
];

/* Runs one self-test table. `run` turns a snippet into findings, `note` says
 * what a failure means for the rule under test - both rules below are green
 * over src/ by construction, so the note is the only thing that explains why
 * a passing gate is not the same as a working rule. */
function selfTest(cases, run, note) {
  for (const testCase of cases) {
    const got = run(testCase.source);
    if (got.length === testCase.expect) continue;
    console.error(`extended-check: the gate's own self-test failed - "${testCase.name}"`);
    console.error(`  expected ${testCase.expect} finding(s), got ${got.length}`);
    for (const f of got) console.error(`    ${f.at}: ${f.message}`);
    console.error("");
    console.error(note);
    process.exit(1);
  }
}

selfTest(
  ABAPDOC_SELF_TEST,
  source => abapdocFindings("selftest.clas.abap", source),
  "The ABAP Doc placement rule changed. A green run over src/ says nothing\n"
    + "while this case fails - src/ carries no misplaced block to fire on.",
);

/* PREFERRED PARAMETER names the input parameter that a short-form call
 * `meth( x )` fills - and it does that only when EVERY importing parameter is
 * optional. With a mandatory one in the list the addition is IGNORED, the
 * short form goes to that single mandatory parameter instead (the same
 * binding, which is why nothing breaks), and the compiler reports a warning
 * against the declaration: 'Declare the parameter "VAL" as OPTIONAL. The
 * addition PREFERRED PARAMETER is ignored if non-optional parameters are
 * used'.
 *
 * A user's system reported it on z2ui5_cl_ui5_util_context's private section
 * on 2026-09-05, hours after the change it came with. msg_get_internal had
 * carried one importing parameter and no addition until #2719 (that same
 * morning) gave it a second, defaulted one and added
 * `PREFERRED PARAMETER val` to keep the positional callers reading the same -
 * which they do without it, `val` being the one mandatory parameter.
 *
 * Why nothing here saw it: abaplint PARSES the addition (MethodDefImporting)
 * and no rule reads it. Measured on 2.120.38 - `npx abaplint` was green over
 * the declaration that produced the warning, 0 issues in 264 files.
 *
 * Scope: the IMPORTING block, which is where the addition lives and the only
 * list the message has ever named. Whether a mandatory EXPORTING or CHANGING
 * parameter counts too is left to a system rather than guessed at here. */
function importingParameters(block) {
  /* One parameter starts with its name - bare, escaped with `!` (the form
   * abapGit writes for a name that collides with a keyword; fourteen of them
   * in z2ui5_cl_ui5_util_context alone), or wrapped in VALUE( ) /
   * REFERENCE( ) - followed by
   * TYPE or LIKE, and runs to where the next one starts, so everything it can
   * carry (TYPE REF TO, a table type, OPTIONAL, DEFAULT <value>) stays inside
   * its own chunk. */
  const start = /(?:^|\s)!?(?:VALUE\s*\(\s*!?(\w+)\s*\)|REFERENCE\s*\(\s*!?(\w+)\s*\)|(\w+))\s+(?:TYPE|LIKE)\b/gi;
  const hits = [...block.matchAll(start)];
  return hits.map((hit, i) => ({
    name: hit[1] || hit[2] || hit[3],
    /* `WITH DEFAULT KEY` belongs to a table type, not to the parameter -
     * reading it as a default would make a mandatory table look optional. */
    text: block
      .slice(hit.index, i + 1 < hits.length ? hits[i + 1].index : block.length)
      .replace(/\bWITH\s+DEFAULT\s+KEY\b/gi, " "),
  }));
}

const AFTER_IMPORTING = /\b(?:EXPORTING|CHANGING|RETURNING|RAISING|EXCEPTIONS|PREFERRED\s+PARAMETER)\b/i;

function preferredParameterFindings(file, stmt) {
  /* The comment lines of a signature sit INSIDE the statement (the splitter
   * keeps them for the pseudo-comments this gate decides on), and a parameter
   * list is where this repository puts its reasoning - so read the code half
   * of every line, not the raw text. */
  const code = stmt.text.split("\n").map(stripNoise).join(" ");
  if (!/^\s*(?:CLASS-)?METHODS\b/i.test(code)) return [];

  const out = [];
  // a chained `METHODS: m1 ..., m2 ...` is ONE statement and each element
  // carries its own signature - read them apart before reading one
  for (const element of code.replace(/^\s*(?:CLASS-)?METHODS\s*:?/i, "").split(",")) {
    const preferred = /\bPREFERRED\s+PARAMETER\s+!?(\w+)/i.exec(element);
    if (!preferred) continue;
    const importing = /\bIMPORTING\b([^]*)$/i.exec(element);
    if (!importing) continue;
    const after = AFTER_IMPORTING.exec(importing[1]);
    const block = after ? importing[1].slice(0, after.index) : importing[1];
    const mandatory = importingParameters(block).filter(p => !/\b(?:OPTIONAL|DEFAULT)\b/i.test(p.text));
    if (mandatory.length === 0) continue;
    const named = mandatory.find(p => p.name.toUpperCase() === preferred[1].toUpperCase());
    const why = named ? "it is not optional itself" : `${mandatory[0].name} is not optional`;
    out.push({
      at: `${file}:${stmt.start}`,
      rule: "preferred_param",
      message: `PREFERRED PARAMETER ${preferred[1]} is ignored because ${why}, and the compiler warns - drop the addition (a short-form call fills the one mandatory parameter anyway) or declare every IMPORTING parameter OPTIONAL/DEFAULT`,
    });
  }
  return out;
}

const PREFERRED_SELF_TEST = [
  {
    name: "every importing parameter optional - the addition does what it says",
    source: 'CLASS zcl_x DEFINITION.\n  PUBLIC SECTION.\n    METHODS run\n      IMPORTING\n        val   TYPE i OPTIONAL\n        other TYPE i DEFAULT 1\n          PREFERRED PARAMETER val.\nENDCLASS.',
    expect: 0,
  },
  {
    name: "a mandatory parameter beside it - the finding the rule exists for",
    source: 'CLASS zcl_x DEFINITION.\n  PUBLIC SECTION.\n    METHODS run\n      IMPORTING\n        val   TYPE any\n        check TYPE abap_bool DEFAULT abap_true\n          PREFERRED PARAMETER val\n      RETURNING\n        VALUE(result) TYPE i.\nENDCLASS.',
    expect: 1,
  },
  {
    name: "a comment between the parameters, which is where this one hid",
    source: 'CLASS zcl_x DEFINITION.\n  PUBLIC SECTION.\n    METHODS run\n      IMPORTING\n        val   TYPE any\n        " why the second one is defaulted\n        check TYPE abap_bool DEFAULT abap_true\n          PREFERRED PARAMETER val.\nENDCLASS.',
    expect: 1,
  },
  {
    name: "the escaped `!name` form, which this repository writes",
    source: 'CLASS zcl_x DEFINITION.\n  PUBLIC SECTION.\n    METHODS run\n      IMPORTING\n        !val   TYPE any\n        !check TYPE abap_bool DEFAULT abap_true\n          PREFERRED PARAMETER !val.\nENDCLASS.',
    expect: 1,
  },
  {
    name: "no addition at all - a mandatory parameter is nobody's finding",
    source: 'CLASS zcl_x DEFINITION.\n  PUBLIC SECTION.\n    METHODS run\n      IMPORTING\n        val   TYPE any\n        check TYPE abap_bool DEFAULT abap_true.\nENDCLASS.',
    expect: 0,
  },
  {
    name: "WITH DEFAULT KEY is part of a table type, not a parameter default",
    source: 'CLASS zcl_x DEFINITION.\n  PUBLIC SECTION.\n    METHODS run\n      IMPORTING\n        it_tab TYPE STANDARD TABLE OF string WITH DEFAULT KEY\n        val    TYPE i OPTIONAL\n          PREFERRED PARAMETER val.\nENDCLASS.',
    expect: 1,
  },
  {
    name: "a chain - the addition is read against the element that carries it",
    source: 'CLASS zcl_x DEFINITION.\n  PUBLIC SECTION.\n    METHODS:\n      first\n        IMPORTING\n          val TYPE any,\n      second\n        IMPORTING\n          val TYPE i OPTIONAL\n            PREFERRED PARAMETER val.\nENDCLASS.',
    expect: 0,
  },
];

selfTest(
  PREFERRED_SELF_TEST,
  source => statements(source).flatMap(stmt => preferredParameterFindings("selftest.clas.abap", stmt)),
  "The PREFERRED PARAMETER rule changed. A green run over src/ says nothing\n"
    + "while this case fails - the one declaration it was written for was repaired\n"
    + "in the same change, and the seven uses left there are correct ones.",
);

// ABAP Doc is parsed as HTML. The tags it knows are the few below; anything
// else between < and > - a field symbol, a placeholder like #/app/<CLASS> -
// is "not supported" and "not closed" in a system, and the block renders
// wrong. Escape it as &lt;name&gt;. Only complete tag-like tokens are read,
// so a comparison (`a < b`) is not a finding.
const ABAPDOC_TAGS = new Set(["p", "em", "strong", "ul", "ol", "li", "h1", "h2", "h3", "br"]);
function abapdocHtmlFindings(file, source) {
  source.split(/\r?\n/).forEach((line, i) => {
    if (!/^\s*"!/.test(line)) return;
    const tags = [...line.matchAll(/<\/?([A-Za-z_][A-Za-z0-9_-]*)>/g)];
    for (const m of tags) {
      if (ABAPDOC_TAGS.has(m[1].toLowerCase())) continue;
      findings.push({
        at: `${file}:${i + 1}`,
        rule: "abapdoc_html",
        message: `ABAP Doc is parsed as HTML - <${m[1]}> is an unsupported, unclosed tag there; write &lt;${m[1]}&gt;`,
      });
    }
  });
}

for (const file of files) {
  const source = readFileSync(join(ROOT, file), "utf8");
  if (/\.(clas|intf)\.abap$/.test(file)) findings.push(...abapdocFindings(file, source));
  abapdocHtmlFindings(file, source);
  const stmts = statements(source);

  stmts.forEach((stmt, index) => {
    const flat = stmt.text.replace(/\n/g, " ");
    const at = `${file}:${stmt.start}`;

    findings.push(...preferredParameterFindings(file, stmt));

    // a LOOP that names a secondary key (USING KEY) reads through that key,
    // which is what the check asks for - z2ui5_if_ui5_types=>ty_t_attri
    // carries one for the child walks of the model service (2026-09)
    if (/^\s*LOOP\s+AT\b/i.test(flat) && /\bWHERE\b/i.test(flat) && !/CI_SORTSEQ/i.test(flat) && !/\bUSING\s+KEY\b/i.test(flat)) {
      findings.push({
        at,
        rule: "sortseq",
        message: 'LOOP AT ... WHERE is a sequential read - the extended check wants "#EC CI_SORTSEQ on the statement',
      });
    }

    // The SAME finding, reached the other two ways. LOOP AT ... WHERE was the
    // only shape this gate knew, so four production sequential reads shipped
    // without the pragma while the repository's own precedent
    // (z2ui5_cl_ui5_srv_model, the line_exists over mt_attri) carried it.
    //
    // Neither form can be decided perfectly from the text: whether a read is
    // sequential depends on the table's key, which is declared elsewhere. Two
    // scope decisions keep the rule honest rather than noisy:
    //   - `WITH TABLE KEY` is exempt - that is a primary-key read, not a free
    //     key, and it is the spelling used where a keyed table is meant.
    //   - test classes are exempt. They hold 76 of the 86 matches in this
    //     repository, almost all of them `lt_attri[ name = ... ]` inside an
    //     assertion, where the finding says nothing about the shipped code.
    //     Every recorded ATC incident came from production code.
    // An intentional sequential read opts out the same way as the LOOP AT
    // above: put "#EC CI_SORTSEQ on the statement.
    if (!/testclasses/.test(file) && !/CI_SORTSEQ/i.test(flat)) {
      if (/^\s*READ\s+TABLE\b/i.test(flat)
        && /\bWITH\s+KEY\b/i.test(flat)
        && !/\bWITH\s+TABLE\s+KEY\b/i.test(flat)) {
        findings.push({
          at,
          rule: "sortseq",
          message: 'READ TABLE ... WITH KEY is a sequential read - the extended check wants "#EC CI_SORTSEQ on the statement',
        });
      } else if (/\[\s*[A-Za-z_][\w-]*\s*=/.test(flat)) {
        findings.push({
          at,
          rule: "sortseq",
          message: 'a table expression keyed on a component is a sequential read - the extended check wants "#EC CI_SORTSEQ on the statement',
        });
      }
    }

    // the operand of TYPE HANDLE is a data object holding the descriptor -
    // a method call there is a syntax error on a system, and nothing before
    // a system objects: assign the descriptor to a variable first
    const handle = /^\s*CREATE\s+DATA\b.*\bTYPE\s+HANDLE\s+(.+)$/i.exec(flat.replace(/\s*\.\s*$/, ""));
    if (handle && /\(/.test(handle[1])) {
      findings.push({
        at,
        rule: "handle_call",
        message: "CREATE DATA ... TYPE HANDLE takes a data object - a method call here is a syntax error on a system; assign the descriptor to a variable first",
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

console.log(`extended-check: ${files.length} file(s), ${ABAPDOC_SELF_TEST.length + PREFERRED_SELF_TEST.length} self-test case(s) checked - OK`);
