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
//                that attaches to no declaration is never shown. abaplint now
//                decides this: wrong_abapdoc_position (2.120.51,
//                abaplint/abaplint#4286, written from the case this
//                repository put on abaplint/abaplint#1951), enabled in
//                abaplint.jsonc, reports the block before a chain keyword,
//                inside a statement, and before ENDCLASS / ENDINTERFACE / a
//                SECTION - the three shapes that recurred here.
//                ONE shape is left to this gate, measured against 2.120.51 on
//                2026-09-13: a block directly before `END OF`, inside the
//                chain it belongs to, which the rule does not report. That is
//                all the check below still does.
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
//   deref_call   "->*" chained onto a call - `row_ref( iv_name )->*`. The
//                dereferencing operator wants a data reference VARIABLE in
//                front of it; the result of a functional method call is not
//                one on the releases this repo targets. abaplint parses it
//                at v750 and the
//                transpiler runs it, so a test class shipped with it and a
//                user on SAP_ABA 750 SP33 reported the syntax error (#2722).
//   preferred_   'Declare the parameter "VAL" as OPTIONAL. The addition
//   param        PREFERRED PARAMETER is ignored if non-optional parameters
//                are used' - the addition only picks the parameter a
//                short-form call fills when every IMPORTING parameter is
//                optional. Found on a user's system on 2026-09-05, hours
//                after z2ui5_cl_ui5_util_context=>msg_get_internal gained a
//                second, defaulted parameter that morning (#2719) and took
//                the addition along with it.
//   range_row    'Specification "OPTION" is missing in the selection
//                structure' / '"eq" is not a permitted value for component
//                "OPTION" in a selection structure' - a VALUE row of a range
//                table (sign/option/low/high) without an option, or with a
//                literal the system does not know. Syntax warnings on a
//                user's system on 2026-09-23, from a test class of
//                z2ui5_cl_ui5_util_context that feeds deliberately odd rows.
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

/* An ABAP Doc block attaches to the ONE declaration directly below it, and
 * abaplint's `wrong_abapdoc_position` now reports every placement where there
 * is no such declaration - except one: a block directly before `END OF`,
 * inside the chain that opened with `BEGIN OF`. Measured against 2.120.51 on
 * 2026-09-13 over the six shapes this gate used to decide; that is the only
 * one it answered and the rule did not, so it is the only one left here.
 *
 * No site of that shape has ever been found - 0 across abap2UI5, samples,
 * samples-controls, samples-stack and linter on the same day. It is kept
 * rather than deleted because the check already existed and SLIN reports the
 * shape; it is NOT in backlog/, because a rule request without a case that
 * happened is exactly what backlog/README.md refuses to stock.
 *
 * The statement splitter above strips comment lines, so this reads the raw
 * lines. Only the class-pool main and interface sources carry declarations
 * ABAP Doc can reach. */
const BEFORE_END_OF = /^\s*end\s+of\b/i;

/* ...and a SECOND shape the rule does not report, reported from a system's
 * SYNTAX_CHECK on 2026-09-16: a plain `"` comment BETWEEN the block and the
 * declaration. z2ui5_if_client's check_on_navigated carried four such lines -
 * a note to whoever edits the framework, deliberately not ABAP Doc so the
 * documentation site would not print it - and they detached the sixteen-line
 * block above them from the METHODS below. The note belongs ABOVE the block,
 * where it breaks nothing.
 *
 * abaplint's wrong_abapdoc_position reports the block before a chain keyword,
 * inside a statement, and before ENDCLASS / ENDINTERFACE / a SECTION. A
 * comment is none of those: it is not a statement at all, so the rule walks
 * past it to the declaration and finds the block correctly placed. */
const PLAIN_COMMENT = /^\s*(?:"(?!!)|\*)/;

function abapdocFindings(file, source) {
  const out = [];
  const src = source.split("\n");
  src.forEach((line, i) => {
    if (!/^\s*"!/.test(line)) return;
    if (/^\s*"!/.test(src[i - 1] || "")) return; // only the block's first line

    let n = i + 1;
    while (n < src.length && (/^\s*"!/.test(src[n]) || !src[n].trim())) n += 1;
    const next = n < src.length ? src[n].trim() : "";

    if (BEFORE_END_OF.test(next)) {
      out.push({
        at: `${file}:${i + 1}`,
        rule: "abapdoc",
        message: `"! before \`${next}\` documents nothing - the last component of the structure is above it, not below`,
      });
      return;
    }

    if (n < src.length && PLAIN_COMMENT.test(src[n])) {
      out.push({
        at: `${file}:${i + 1}`,
        rule: "abapdoc",
        message: `a plain comment sits between this "! block and the declaration below it, which detaches the block - move the comment ABOVE the block`,
      });
    }
  });
  return out;
}

/* Self-test: the one shape this gate still decides, plus the shapes it handed
 * to abaplint - those have to come back EMPTY here, so that a revival of the
 * old logic shows up as a failure rather than as silent duplication. The gate
 * is green over src/ either way (the findings it was written for were
 * repaired in the change that added it), so without this a rule that stopped
 * reporting would be invisible.
 *
 * `expect` is the number of findings on the snippet. */
const ABAPDOC_SELF_TEST = [
  {
    name: "a block directly before its declaration - the correct shape",
    source: 'CLASS zcl_x DEFINITION.\n  PUBLIC SECTION.\n    "! what it does\n    METHODS run.\nENDCLASS.',
    expect: 0,
  },
  {
    name: "directly before END OF - the shape abaplint does not report",
    source: 'CLASS zcl_x DEFINITION.\n  PUBLIC SECTION.\n    CONSTANTS:\n      BEGIN OF cs_mode,\n        a TYPE string VALUE `A`,\n      "! orphaned\n      END OF cs_mode.\nENDCLASS.',
    expect: 1,
  },
  {
    name: "inside a parameter list - abaplint's now, not this gate's",
    source: 'CLASS zcl_x DEFINITION.\n  PUBLIC SECTION.\n    METHODS run\n      IMPORTING\n        "! the value\n        val TYPE i.\nENDCLASS.',
    expect: 0,
  },
  {
    name: "before the chain keyword - abaplint's now, not this gate's",
    source: 'CLASS zcl_x DEFINITION.\n  PUBLIC SECTION.\n    "! the modes\n    CONSTANTS:\n      BEGIN OF cs_mode,\n        a TYPE string VALUE `A`,\n      END OF cs_mode.\nENDCLASS.',
    expect: 0,
  },
  {
    name: "before a section end - abaplint's now, not this gate's",
    source: 'CLASS zcl_x DEFINITION.\n  PUBLIC SECTION.\n    METHODS run.\n    "! orphaned\n  PROTECTED SECTION.\n  PRIVATE SECTION.\nENDCLASS.',
    expect: 0,
  },
  {
    name: "a plain comment between the block and its declaration - the 2026-09-16 case",
    source: 'INTERFACE zif_x PUBLIC.\n  "! what it answers\n  " a note to whoever edits this\n  METHODS run.\nENDINTERFACE.',
    expect: 1,
  },
  {
    name: "the same note ABOVE the block - the repaired shape",
    source: 'INTERFACE zif_x PUBLIC.\n  " a note to whoever edits this\n  "! what it answers\n  METHODS run.\nENDINTERFACE.',
    expect: 0,
  },
  {
    name: "a blank line between them is not a comment and detaches nothing",
    source: 'INTERFACE zif_x PUBLIC.\n  "! what it answers\n\n  METHODS run.\nENDINTERFACE.',
    expect: 0,
  },
  {
    name: "a `*` comment detaches it just as well",
    source: 'INTERFACE zif_x PUBLIC.\n  "! what it answers\n* a note\n  METHODS run.\nENDINTERFACE.',
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
  "The ABAP Doc placement check changed. A green run over src/ says nothing\n"
    + "while this case fails - src/ carries no misplaced block to fire on.\n"
    + "If a shape marked \"abaplint's now\" started firing again, the check has\n"
    + "grown back into what wrong_abapdoc_position already reports.",
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

// `->*` chained straight onto a call - `row_ref( iv_name )->*`, and the same
// shape after a constructor expression. The dereferencing operator takes a
// data reference VARIABLE; the result of a call is not one, so a 7.50 system
// answers with a syntax error while everything here is green - abaplint
// parses the chain at v750 and the
// transpiler has no notion of the restriction. #2722, in the test class of
// z2ui5_cl_ui5_srv_model, reported by a user on SAP_ABA 750 SP33. The fix is
// the same one `handle_call` asks for: give the reference its own variable on
// the line above, then dereference that.
//
// Read per line, not per statement: a chain cannot be broken between the `)`
// and the `->`, so anything the line scan cannot see is not this shape.
const DEREF_CALL = /\)\s*->\*/;
function derefCallFindings(file, source) {
  const out = [];
  source.split(/\r?\n/).forEach((line, i) => {
    if (!DEREF_CALL.test(stripNoise(line))) return;
    out.push({
      at: `${file}:${i + 1}`,
      rule: "deref_call",
      message: "->* takes a data reference variable - dereferencing a call result is a syntax error on 7.50; assign the reference to a variable first",
    });
  });
  return out;
}

const DEREF_SELF_TEST = [
  {
    name: "the #2722 line itself",
    source: "    result = row_ref( iv_name )->*.",
    expect: 1,
  },
  {
    name: "a constructor expression is the same shape",
    source: "    DATA(ls_row) = REF #( lt_tab[ 1 ] )->*.",
    expect: 1,
  },
  {
    name: "the repaired form - the reference has its own variable",
    source: "    DATA(lr_row) = row_ref( iv_name ).\n    result = lr_row->*.",
    expect: 0,
  },
  {
    name: "an ordinary dereference of an attribute chain",
    source: "    ASSIGN mo_app->mo_inner->mr_shared->* TO <tab>.",
    expect: 0,
  },
  {
    name: "a table expression on a dereferenced table - `]` is not `(`",
    source: "    DATA(ls) = mr_attri->*[ name = iv_name ].",
    expect: 0,
  },
  {
    name: "a closing paren that ends something else on the line",
    source: "    IF ( lv_a = lv_b ) AND lr_row->* IS NOT INITIAL.",
    expect: 0,
  },
  {
    name: "the shape inside a string literal is text, not code",
    source: "    cl_abap_unit_assert=>assert_equals( exp = `MR_A( 1 )->*` act = lv_name ).",
    expect: 0,
  },
  {
    name: "the shape inside a comment is not code either",
    source: "    \" row_ref( iv_name )->* is what 7.50 refuses",
    expect: 0,
  },
];

selfTest(
  DEREF_SELF_TEST,
  source => derefCallFindings("selftest.clas.testclasses.abap", source),
  "The chained-dereference rule changed. A green run over src/ says nothing while\n"
    + "this case fails - the one site it was written for was repaired in the same\n"
    + "change, so src/ carries no example of the shape.",
);

/* The SELECT rule is decided inside the statement loop below rather than in a
 * function of its own, like the other statement rules - so its self-test runs
 * the same way the gate does: split a snippet into statements and apply the
 * test. src/ carries one annotated SELECT and no bare one, so a green run
 * over src/ would not tell a working rule from a deleted one. */
function nowhereFindings(file, source) {
  const out = [];
  for (const stmt of statements(source)) {
    const flat = stmt.text.replace(/\n/g, " ");
    if (!/^\s*SELECT\b/i.test(flat)) continue;
    if (/\bWHERE\b/i.test(flat) || /CI_NOWHERE/i.test(flat)) continue;
    out.push({ at: `${file}:${stmt.start}`, rule: "nowhere", message: "" });
  }
  return out;
}

const NOWHERE_SELF_TEST = [
  {
    name: "a full read that says so - the count_entries_total shape",
    source: '    SELECT COUNT( * ) FROM z2ui5_t_01                     "#EC CI_NOWHERE\n      INTO @result.',
    expect: 0,
  },
  {
    name: "the same read without the pseudo-comment",
    source: "    SELECT COUNT( * ) FROM z2ui5_t_01\n      INTO @result.",
    expect: 1,
  },
  {
    name: "a WHERE anywhere in the statement, on any of its lines",
    source: "    SELECT SINGLE * FROM z2ui5_t_01\n      WHERE id = @id\n      INTO @result.",
    expect: 0,
  },
  {
    name: "the multi-line field list the sample repositories write",
    source: "    SELECT id,\n           id_prev\n      FROM z2ui5_t_01\n      ORDER BY PRIMARY KEY\n      INTO TABLE @lt_rows\n      UP TO 5 ROWS.",
    expect: 1,
  },
  {
    name: "a SELECT named in a comment is not a statement",
    source: '    " a SELECT FROM z2ui5_t_01 without a WHERE reads everything\n    result = 1.',
    expect: 0,
  },
];

selfTest(
  NOWHERE_SELF_TEST,
  source => nowhereFindings("selftest.clas.abap", source),
  "The SELECT-without-WHERE rule changed. A green run over src/ says nothing\n"
    + "while this case fails - the one full read here carries the pseudo-comment,\n"
    + "so src/ has no bare SELECT for the rule to fire on.",
);

// ABAP Doc is parsed as HTML. The tags it knows are the few below; anything
// else between < and > - a field symbol, a placeholder like #/app/<CLASS> -
// is "not supported" and "not closed" in a system, and the block renders
// wrong. Escape it as &lt;name&gt;. Only complete tag-like tokens are read,
// so a comparison (`a < b`) is not a finding.
/* A TEXT SYMBOL (`'text'(001)`) handed straight to a PARAMETER. It is a
 * CHARACTER literal, so a formal parameter typed `string` answers
 * `'...'(001) is not type-compatible with formal parameter V` - a
 * SYNTAX_ERROR of the whole class, reported from a system's SYNTAX_CHECK on
 * 2026-09-16 against samples/z2ui5_cl_smp_app_519, the sample whose subject
 * is translatable texts. abaplint, the transpiler and the unit suite were all
 * green on it: none of them models the compatibility rule for a text-symbol
 * literal.
 *
 * A PARAMETER binding only. `lv_x = 'y'(001).` is an assignment and a plain
 * conversion, correct on every release; a symbol inside a string template is
 * correct too, an embedded expression being a general expression position.
 * What separates them on the text is whether the binding sits inside an open
 * paren - so the parens BEFORE it are counted, over the code half of the
 * statement, and a `(001)` inside a literal cannot skew that count because
 * only the text before the match is read.
 *
 * The fix is a variable, which is also what an app using a text twice writes. */
const TEXT_SYMBOL_ARG = /\b\w+\s*=\s*'[^']*'\(\d{3}\)/;

function textSymbolFindings(file, source) {
  const out = [];
  for (const stmt of statements(source)) {
    const flat = stmt.text.replace(/\n/g, " ");
    const at = flat.search(TEXT_SYMBOL_ARG);
    if (at === -1) continue;
    const before = stripNoise(flat.slice(0, at));
    const depth = (before.match(/\(/g) ?? []).length - (before.match(/\)/g) ?? []).length;
    if (depth <= 0) continue;
    out.push({
      at: `${file}:${stmt.start}`,
      rule: "text_symbol_arg",
      message: 'a text symbol is a CHARACTER literal - passing one to a parameter typed `string` is "not type-compatible with formal parameter" on a system; read it into a variable and pass that',
    });
  }
  return out;
}

const TEXT_SYMBOL_SELF_TEST = [
  {
    name: "the app_519 chain itself - the finding the rule exists for",
    source: "page->ele( `VBox`\n    )->tag( `Label`\n        )->a( n = `text` v = 'Your name'(001)\n        )->a( n = `labelFor` v = `nameInput` ).",
    expect: 1,
  },
  {
    name: "an assignment to a variable - the repaired shape",
    source: "lv_name = 'Your name'(001).",
    expect: 0,
  },
  {
    name: "inside a string template - a general expression position",
    source: "client->message_box_display( |{ 'Hello'(004) } { name }| ).",
    expect: 0,
  },
  {
    name: "the variable passed instead",
    source: "page->tag( `Label` )->a( n = `text` v = lv_name ).",
    expect: 0,
  },
  {
    name: "any other call, not just the view builder",
    source: "DATA(lv) = zcl_x=>m( val = 'Greet'(003) ).",
    expect: 1,
  },
];

selfTest(
  TEXT_SYMBOL_SELF_TEST,
  source => textSymbolFindings("selftest.clas.abap", source),
  "The text-symbol rule changed. A green run over src/ says nothing while this\n"
    + "case fails - this repository has no text symbol at all, the sample that had\n"
    + "them is a sibling checkout.",
);

/* A ROW OF A RANGE TABLE - a structure with the components sign, option, low
 * and high - is a "selection structure" to the syntax check, whatever it is
 * declared as, and a VALUE row of one is checked against the fixed domain of
 * those components: a row without an option answers 'Specification "OPTION"
 * is missing in the selection structure', and a literal outside the domain -
 * a lower-case `eq` included - '"eq" is not a permitted value for component
 * "OPTION" in a selection structure'. Warnings, not errors, but warnings a
 * user's system lists on every pull (2026-09-23, three of them from
 * ltcl_test's test_token_odd_option in z2ui5_cl_ui5_util_context, which feeds
 * exactly such rows on purpose). abaplint knows no selection structures.
 *
 * Decided on the text: a row is the innermost `( ... )` of a statement with a
 * VALUE in it that assigns `low` and at least one of `sign` / `option`. A
 * component given as a header default before the rows (`VALUE #( sign = `I`
 * option = `EQ` ( low = ... ) )`) counts as given. Only LITERALS are judged -
 * a variable or constant is the documented way to feed an odd value to a
 * test, and it is what the repaired test does. */
const RANGE_SIGNS = new Set(["I", "E"]);
const RANGE_OPTIONS = new Set(["EQ", "NE", "BT", "NB", "CP", "NP", "GT", "GE", "LT", "LE"]);

/* The code of one line with its trailing comment cut and its literals KEPT -
 * stripNoise drops literal content, and the content is what this rule reads. */
function codeKeepingLiterals(line) {
  let mode = "code";
  for (let i = 0; i < line.length; i += 1) {
    const c = line[i];
    if (mode === "code") {
      if (c === "`") mode = "tick";
      else if (c === "'") mode = "quote";
      else if (c === "|") mode = "tmpl";
      else if (c === '"') return line.slice(0, i);
    } else if (mode === "tick" && c === "`") mode = "code";
    else if (mode === "quote" && c === "'") mode = "code";
    else if (mode === "tmpl") {
      if (c === "\\") i += 1;
      else if (c === "|") mode = "code";
    }
  }
  return line;
}

function rangeRowFindings(file, source) {
  const out = [];
  for (const stmt of statements(source)) {
    const text = stmt.text.split("\n").map(codeKeepingLiterals).join(" ");
    if (!/\bVALUE\b/i.test(text)) continue;
    // literals out of the way of the paren walk, their content kept aside
    const literals = [];
    const masked = text.replace(/`(?:[^`]|``)*`|'(?:[^']|'')*'/g, (lit) => {
      literals.push(lit.slice(1, -1));
      return `\u0000${literals.length - 1}\u0000`;
    });
    const rows = [...masked.matchAll(/\(([^()]*)\)/g)].map(m => m[1]);
    const header = masked.replace(/\([^()]*\)/g, " ");
    for (const row of rows) {
      if (!/\blow\s*=/i.test(row)) continue;
      if (!/\b(?:sign|option)\s*=/i.test(row)) continue;
      for (const [component, domain] of [["sign", RANGE_SIGNS], ["option", RANGE_OPTIONS]]) {
        const given = new RegExp(`\\b${component}\\s*=\\s*(\\S+)`, "i").exec(row);
        if (!given) {
          if (new RegExp(`\\b${component}\\s*=`, "i").test(header)) continue;
          out.push({
            at: `${file}:${stmt.start}`,
            rule: "range_row",
            message: `a range row without ${component.toUpperCase()} - "Specification ${component.toUpperCase()} is missing in the selection structure" on a system; give it, or build the row field by field`,
          });
          continue;
        }
        const literal = /^\u0000(\d+)\u0000$/.exec(given[1]);
        if (!literal) continue;
        const value = literals[Number(literal[1])];
        if (domain.has(value)) continue;
        out.push({
          at: `${file}:${stmt.start}`,
          rule: "range_row",
          message: `"${value}" is not a permitted value for component ${component.toUpperCase()} in a selection structure - use ${[...domain].join("/")}, or feed an odd value through a variable`,
        });
      }
    }
  }
  return out;
}

const RANGE_ROW_SELF_TEST = [
  {
    name: "the three rows of the incident - missing, lower-case and unknown option",
    source: "lt_range = VALUE #( ( sign = `I` low = `X` )\n                    ( sign = `I` option = `eq` low = `Y` )\n                    ( sign = `I` option = `ZZ` low = `Z` ) ).",
    expect: 3,
  },
  {
    name: "well-formed rows, single quotes as well",
    source: "lt_range = VALUE #( ( sign = `I` option = `EQ` low = `X` )\n                    ( sign = 'E' option = 'BT' low = `1` high = `9` ) ).",
    expect: 0,
  },
  {
    name: "sign and option as header defaults for every row",
    source: "lt_range = VALUE #( sign = `I` option = `EQ` ( low = `A` ) ( low = `B` ) ).",
    expect: 0,
  },
  {
    name: "a variable for the odd value - the repaired shape",
    source: "lt_range = VALUE #( ( sign = `I` option = lv_option low = `Y` ) ).",
    expect: 0,
  },
  {
    name: "an invalid sign",
    source: "ls_range = VALUE #( sign = `X` option = `EQ` low = `A` ).",
    expect: 1,
  },
  {
    name: "no range row at all - a structure without sign or option",
    source: "ls_row = VALUE #( name = `eq` low = `A` ).",
    expect: 0,
  },
];

selfTest(
  RANGE_ROW_SELF_TEST,
  source => rangeRowFindings("selftest.clas.abap", source),
  "The range-row rule changed. A green run over src/ says nothing while this\n"
    + "case fails - src/ carries no malformed range row to fire on.",
);

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
  findings.push(...derefCallFindings(file, source));
  findings.push(...textSymbolFindings(file, source));
  findings.push(...rangeRowFindings(file, source));
  const stmts = statements(source);

  stmts.forEach((stmt, index) => {
    const flat = stmt.text.replace(/\n/g, " ");
    /* The SHAPE of a statement is decided on its code - comments cut off,
     * literal content dropped - and only the pragma / pseudo-comment presence
     * on the raw text, because that is where a "#EC lives. On the raw text a
     * `[ name = value ]` inside a backtick literal was a sequential read, a
     * comment inside a SELECT saying "no WHERE needed" satisfied the WHERE
     * test, and a trailing comment on CREATE DATA ... TYPE HANDLE defeated
     * the period strip and made a plain variable look like a call. */
    const code = stmt.text.split("\n").map(stripNoise).join(" ");
    const at = `${file}:${stmt.start}`;

    findings.push(...preferredParameterFindings(file, stmt));

    // a LOOP that names a secondary key (USING KEY) reads through that key,
    // which is what the check asks for - z2ui5_if_ui5_types=>ty_t_attri
    // carries one for the child walks of the model service (2026-09)
    if (/^\s*LOOP\s+AT\b/i.test(code) && /\bWHERE\b/i.test(code) && !/CI_SORTSEQ/i.test(flat) && !/\bUSING\s+KEY\b/i.test(code)) {
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
      // a BINARY SEARCH is a keyed read on a sorted standard table, not a
      // sequential one - the check does not report it
      if (/^\s*READ\s+TABLE\b/i.test(code)
        && /\bWITH\s+KEY\b/i.test(code)
        && !/\bWITH\s+TABLE\s+KEY\b/i.test(code)
        && !/\bBINARY\s+SEARCH\b/i.test(code)) {
        findings.push({
          at,
          rule: "sortseq",
          message: 'READ TABLE ... WITH KEY is a sequential read - the extended check wants "#EC CI_SORTSEQ on the statement',
        });
      } else if (/\[\s*[A-Za-z_][\w-]*\s*=/.test(code)) {
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
    const handle = /^\s*CREATE\s+DATA\b.*\bTYPE\s+HANDLE\s+(.+)$/i.exec(code.replace(/\s*\.\s*$/, ""));
    if (handle && /\(/.test(handle[1])) {
      findings.push({
        at,
        rule: "handle_call",
        message: "CREATE DATA ... TYPE HANDLE takes a data object - a method call here is a syntax error on a system; assign the descriptor to a variable first",
      });
    }

    // A SELECT with no WHERE reads the whole table. AGENTS.md has named the
    // trap in prose since z2ui5_cl_ui5_srv_draft=>count_entries was bitten by
    // it, and prose is what let thirty-six of them ship across the two sample
    // repositories (annotated 2026-09-16) - the shape a script can decide
    // outright, which is what this gate is for. An intentional full read says
    // so with the pseudo-comment, the way count_entries_total does.
    //
    // A SELECT whose target is a SUBQUERY or a join carries its own WHERE
    // inside; the test is on the statement as a whole, so either spelling
    // satisfies it, and a missing one is a finding wherever it sits.
    if (/^\s*SELECT\b/i.test(code) && !/\bWHERE\b/i.test(code) && !/CI_NOWHERE/i.test(flat)) {
      findings.push({
        at,
        rule: "nowhere",
        message: 'SELECT without a WHERE clause reads the whole table - the extended check wants "#EC CI_NOWHERE on the statement',
      });
    }

    if (/^\s*(FIND|REPLACE)\b/i.test(code) && /\bREGEX\b/i.test(code) && !/REGEX_POSIX/i.test(flat)) {
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

console.log(`extended-check: ${files.length} file(s), ${ABAPDOC_SELF_TEST.length + PREFERRED_SELF_TEST.length + DEREF_SELF_TEST.length + NOWHERE_SELF_TEST.length + TEXT_SYMBOL_SELF_TEST.length + RANGE_ROW_SELF_TEST.length} self-test case(s) checked - OK`);
