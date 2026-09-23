// Gate: a class that reads a PRIVATE or PROTECTED member of ANOTHER class it is
// no friend (or, for PROTECTED, no subclass) of does not compile on a system.
//
// Why this exists: neither abaplint nor the transpiler checks attribute
// visibility across classes. `mv_session_sticky` was declared in the PRIVATE
// SECTION of z2ui5_cl_ui5_handler and written by z2ui5_cl_ui5_http_handler,
// read by z2ui5_cl_ui5_action and set in that class's test class - `npm run
// check`, `npm run unit` and every gate were green, and a user's system
// answered 'Field "MV_SESSION_STICKY" is unknown.' four times (2026-09-23).
// testclass-visibility-gate.mjs (npm run check_visibility) only ever looked at
// a test class against its OWN class under test, so production code reaching
// into a sibling class - and a test class reaching into a class it does not
// test - was nobody's.
//
// What is decided, from the source text alone:
//   access    `ref->member` where `ref` is the FIRST hop of a chain, and
//             `class=>member`
//   `ref`     resolved in the order ABAP resolves it: a declaration in the
//             method body (`DATA x TYPE REF TO c`, `DATA(x) = NEW c( )`,
//             `DATA(x) = CAST c( )`), a parameter of the method, an attribute
//             of the class or of one of its superclasses. Anything else -
//             a field symbol, `NEW #( )`, a generic reference, a chain after a
//             call - is not resolved and produces no finding, because a gate
//             must not report what a developer cannot act on.
//   legal     the same class; a class listed in FRIENDS / LOCAL FRIENDS of the
//             declaring class, a subclass of such a friend, or a class
//             implementing a friend interface; for PROTECTED also a subclass
//             of the declaring class
//
// Scope: all of src/, test classes included - the frozen src/99 and the
// upstream mirrors do not compile on a system with such an access either.
//
//   node .github/scripts/member-visibility-gate.mjs   (npm run check:members)

import { readFileSync } from "fs";
import { join } from "path";
import { fileURLToPath } from "url";
import { walk } from "./lib/walk.mjs";
import { statements, stripNoise } from "./lib/abap-statements.mjs";

const ROOT = fileURLToPath(new URL("../../", import.meta.url));

const DECL = /^(CLASS-METHODS|METHODS|CLASS-DATA|DATA|CONSTANTS|CLASS-EVENTS|EVENTS|TYPES|ALIASES)\b\s*:?\s*/i;
const REF_TYPED = /(\w+)\)?\s+(?:TYPE|LIKE)\s+REF\s+TO\s+(\w+)/gi;
const INLINE_TYPED = /\b(?:DATA|FINAL)\((\w+)\)\s*=\s*(?:NEW|CAST)\s+(\w+)\s*\(/gi;
// the FIRST hop only: nothing name-like, no `-`, `>` or `~` directly before
const INSTANCE_ACCESS = /(?<![\w>~\-<])([a-z_]\w*)->(\w+)/gi;
const STATIC_ACCESS = /(?<![\w>~\-<])([a-z_]\w*)=>(\w+)/gi;

/* Split a chained statement body at its top-level commas - `METHODS: a
 * IMPORTING x TYPE i, b.` is two elements, each with its own signature. The
 * code half is literal-free (stripNoise), so a comma inside a literal cannot
 * split an element. */
function chainElements(body) {
  const out = [];
  let depth = 0;
  let start = 0;
  for (let i = 0; i < body.length; i++) {
    const c = body[i];
    if (c === "(") depth += 1;
    else if (c === ")") depth -= 1;
    else if (c === "," && depth === 0) {
      out.push(body.slice(start, i));
      start = i + 1;
    }
  }
  out.push(body.slice(start));
  return out.map(e => e.trim()).filter(Boolean);
}

function poolOf(file) {
  const base = file.slice(file.lastIndexOf("/") + 1).toLowerCase();
  return base.slice(0, base.indexOf("."));
}

/* Pass 1: every class - global or local - with its members, the visibility
 * of each, its superclass, friends, interfaces, and the REF TO typing of its
 * attributes and method parameters. */
function collectClasses(files) {
  const classes = new Map(); // key -> class
  const localFriends = []; // { pool, target, friends }

  for (const { file, text } of files) {
    const pool = poolOf(file);
    const isClassPool = /\.clas\.[\w.]*abap$/i.test(file);
    let current = null;
    let section = null;
    let structDepth = 0;

    for (const stmt of statements(text)) {
      const code = stmt.text.split("\n").map(stripNoise).join(" ").replace(/\s*\.\s*$/, "").trim();

      const friendsStmt = /^CLASS\s+(\w+)\s+DEFINITION\s+LOCAL\s+FRIENDS\s+(.+)$/i.exec(code);
      if (friendsStmt) {
        localFriends.push({ pool, target: friendsStmt[1].toLowerCase(), friends: friendsStmt[2].toLowerCase().split(/[\s,]+/).filter(Boolean) });
        continue;
      }
      const def = /^CLASS\s+(\w+)\s+DEFINITION\b(.*)$/i.exec(code);
      if (def && !/\b(?:DEFERRED|LOAD)\b/i.test(def[2])) {
        const name = def[1].toLowerCase();
        const global = isClassPool && name === pool;
        const key = global || !isClassPool ? name : `${pool}/${name}`;
        const inherit = /\bINHERITING\s+FROM\s+(\w+)/i.exec(def[2]);
        const friends = /\b(?:GLOBAL\s+)?FRIENDS\s+(.+)$/i.exec(def[2]);
        current = {
          key,
          name,
          pool,
          superName: inherit ? inherit[1].toLowerCase() : null,
          friends: new Set(friends ? friends[1].toLowerCase().split(/[\s,]+/).filter(Boolean) : []),
          interfaces: new Set(),
          members: new Map(),
          attrTypes: new Map(),
          params: new Map(),
        };
        classes.set(key, current);
        section = "PUBLIC";
        structDepth = 0;
        continue;
      }
      if (!current) continue;
      if (/^ENDCLASS\b/i.test(code)) {
        current = null;
        continue;
      }
      const sec = /^(PUBLIC|PROTECTED|PRIVATE)\s+SECTION\b/i.exec(code);
      if (sec) {
        section = sec[1].toUpperCase();
        continue;
      }
      const intf = /^INTERFACES\s+(\w+)/i.exec(code);
      if (intf) {
        current.interfaces.add(intf[1].toLowerCase());
        continue;
      }
      const decl = DECL.exec(code);
      if (!decl) continue;
      const keyword = decl[1].toUpperCase();
      for (const element of chainElements(code.slice(decl[0].length))) {
        const begin = /^BEGIN\s+OF\s+(?:ENUM\s+)?(\w+)/i.exec(element);
        if (begin) {
          if (structDepth === 0 && !current.members.has(begin[1].toLowerCase())) {
            current.members.set(begin[1].toLowerCase(), section);
          }
          structDepth += 1;
          continue;
        }
        if (/^END\s+OF\b/i.test(element)) {
          if (structDepth > 0) structDepth -= 1;
          continue;
        }
        if (structDepth > 0) continue;
        const name = /^!?(\w+)/.exec(element);
        if (!name) continue;
        const member = name[1].toLowerCase();
        if (!current.members.has(member)) current.members.set(member, section);
        if (keyword.endsWith("METHODS")) {
          const params = new Map();
          for (const m of element.matchAll(REF_TYPED)) params.set(m[1].toLowerCase(), m[2].toLowerCase());
          current.params.set(member, params);
        } else if (keyword.endsWith("DATA")) {
          const typed = /^!?(\w+)\s+(?:TYPE|LIKE)\s+REF\s+TO\s+(\w+)/i.exec(element);
          if (typed) current.attrTypes.set(typed[1].toLowerCase(), typed[2].toLowerCase());
        }
      }
    }
  }

  for (const { pool, target, friends } of localFriends) {
    const cls = classes.get(target) ?? classes.get(`${pool}/${target}`);
    if (!cls) continue;
    for (const f of friends) cls.friends.add(`${pool}/${f}`);
  }
  return classes;
}

/* A class name as written inside `pool`: a local class of the pool shadows a
 * global class of the same name. */
function resolveClass(classes, pool, name) {
  return classes.get(`${pool}/${name}`) ?? classes.get(name) ?? null;
}

function ancestors(classes, cls) {
  const out = [];
  const seen = new Set();
  let c = cls;
  while (c && !seen.has(c.key)) {
    seen.add(c.key);
    out.push(c);
    c = c.superName ? resolveClass(classes, c.pool, c.superName) : null;
  }
  return out;
}

function isFriend(classes, declaring, accessor) {
  for (const a of ancestors(classes, accessor)) {
    // a friend is written by name: a global class as itself, a local one as
    // `pool/name` (LOCAL FRIENDS) or as its bare name in its own pool
    if (declaring.friends.has(a.key) || declaring.friends.has(a.name) && a.pool === declaring.pool) return true;
    for (const i of a.interfaces) if (declaring.friends.has(i)) return true;
  }
  return false;
}

function allowed(classes, declaring, accessor, visibility) {
  if (visibility !== "PRIVATE" && visibility !== "PROTECTED") return true;
  if (!accessor) return false;
  if (accessor.key === declaring.key) return true;
  if (isFriend(classes, declaring, accessor)) return true;
  if (visibility === "PROTECTED" && ancestors(classes, accessor).some(a => a.key === declaring.key)) return true;
  return false;
}

/* The member as declared: in the class itself or in the nearest ancestor. */
function findMember(classes, cls, member) {
  for (const a of ancestors(classes, cls)) {
    if (a.members.has(member)) return { declaring: a, visibility: a.members.get(member) };
  }
  return null;
}

/* Pass 2: every access in every method body and class definition. */
function findingsFor(files) {
  const classes = collectClasses(files);
  const found = [];

  for (const { file, text } of files) {
    const pool = poolOf(file);
    const isClassPool = /\.clas\.[\w.]*abap$/i.test(file);
    let accessor = null;
    let method = null;
    let locals = new Map();

    const typeOf = (variable) => {
      if (locals.has(variable)) return locals.get(variable);
      if (!accessor) return null;
      for (const a of ancestors(classes, accessor)) {
        const params = method ? a.params.get(method) : null;
        if (params?.has(variable)) return params.get(variable);
      }
      for (const a of ancestors(classes, accessor)) {
        if (a.attrTypes.has(variable)) return a.attrTypes.get(variable);
      }
      return null;
    };

    for (const stmt of statements(text)) {
      const code = stmt.text.split("\n").map(stripNoise).join(" ").replace(/\s*\.\s*$/, "").trim();

      if (/^CLASS\s+\w+\s+DEFINITION\s+LOCAL\s+FRIENDS\b/i.test(code)) continue;
      const block = /^CLASS\s+(\w+)\s+(DEFINITION|IMPLEMENTATION)\b(.*)$/i.exec(code);
      if (block) {
        if (/\b(?:DEFERRED|LOAD)\b/i.test(block[3])) continue;
        const name = block[1].toLowerCase();
        accessor = classes.get(isClassPool && name === pool ? name : `${pool}/${name}`) ?? classes.get(name) ?? null;
        method = null;
        locals = new Map();
        continue;
      }
      if (/^ENDCLASS\b/i.test(code)) {
        accessor = null;
        continue;
      }
      const meth = /^METHOD\s+([\w~]+)/i.exec(code);
      if (meth) {
        method = meth[1].toLowerCase();
        locals = new Map();
        continue;
      }
      if (/^ENDMETHOD\b/i.test(code)) {
        method = null;
        locals = new Map();
        continue;
      }

      if (method) {
        if (/^(?:DATA|STATICS|FINAL)\b/i.test(code)) {
          for (const m of code.matchAll(REF_TYPED)) locals.set(m[1].toLowerCase(), m[2].toLowerCase());
        }
        for (const m of code.matchAll(INLINE_TYPED)) locals.set(m[1].toLowerCase(), m[2].toLowerCase());
      }

      const report = (target, member, via) => {
        if (!target) return;
        const hit = findMember(classes, target, member);
        if (!hit) return;
        if (allowed(classes, hit.declaring, accessor, hit.visibility)) return;
        found.push({
          at: `${file}:${stmt.start}`,
          accessor: accessor ? accessor.name : "(outside any class)",
          member,
          visibility: hit.visibility,
          declaring: hit.declaring,
          via,
        });
      };

      for (const m of code.matchAll(INSTANCE_ACCESS)) {
        const variable = m[1].toLowerCase();
        if (variable === "me" || variable === "super") continue;
        const typeName = typeOf(variable);
        if (!typeName) continue;
        report(resolveClass(classes, pool, typeName), m[2].toLowerCase(), `${variable}->`);
      }
      for (const m of code.matchAll(STATIC_ACCESS)) {
        report(resolveClass(classes, pool, m[1].toLowerCase()), m[2].toLowerCase(), `${m[1].toLowerCase()}=>`);
      }
    }
  }
  return found;
}

/* Self-test: the detection, on sources written for it, before the tree is
 * scanned - a parser that stops recognising a declaration goes SILENT, and a
 * green run over src/ cannot tell that apart from a clean tree.
 *
 * `expect` is `accessor:member` per finding, sorted. */
const HANDLER = [
  "CLASS zcl_h DEFINITION PUBLIC FINAL.",
  "  PUBLIC SECTION.",
  "    DATA mv_public TYPE string.",
  "  PROTECTED SECTION.",
  "    DATA mv_prot TYPE string.",
  "  PRIVATE SECTION.",
  "    DATA mv_sticky TYPE abap_bool.",
  "    TYPES: BEGIN OF ty_s_row,",
  "             mv_public TYPE string,",
  "           END OF ty_s_row.",
  "ENDCLASS.",
  "CLASS zcl_h IMPLEMENTATION.",
  "ENDCLASS.",
].join("\n");

const SELF_TEST = [
  {
    name: "the incident: a private attribute read through an attribute typed REF TO the class",
    files: {
      "zcl_h.clas.abap": HANDLER,
      "zcl_a.clas.abap": "CLASS zcl_a DEFINITION PUBLIC.\n  PUBLIC SECTION.\n    DATA mo_handler TYPE REF TO zcl_h.\n    METHODS run.\nENDCLASS.\nCLASS zcl_a IMPLEMENTATION.\n  METHOD run.\n    IF mo_handler->mv_sticky = abap_false.\n    ENDIF.\n  ENDMETHOD.\nENDCLASS.",
    },
    expect: ["zcl_a:mv_sticky"],
  },
  {
    name: "the incident: written through an inline NEW, and through a parameter",
    files: {
      "zcl_h.clas.abap": HANDLER,
      "zcl_p.clas.abap": "CLASS zcl_p DEFINITION PUBLIC.\n  PUBLIC SECTION.\n    METHODS post.\n    METHODS take IMPORTING !val TYPE REF TO zcl_h.\nENDCLASS.\nCLASS zcl_p IMPLEMENTATION.\n  METHOD post.\n    DATA(lo_post) = NEW zcl_h( ).\n    lo_post->mv_sticky = abap_true.\n    lo_post->mv_public = `x`.\n  ENDMETHOD.\n  METHOD take.\n    val->mv_prot = `y`.\n  ENDMETHOD.\nENDCLASS.",
    },
    expect: ["zcl_p:mv_prot", "zcl_p:mv_sticky"],
  },
  {
    name: "the incident: a test class of ANOTHER class reaching in through a local DATA",
    files: {
      "zcl_h.clas.abap": HANDLER,
      "zcl_a.clas.testclasses.abap": "CLASS ltcl DEFINITION FOR TESTING.\n  PRIVATE SECTION.\n    METHODS t FOR TESTING.\nENDCLASS.\nCLASS ltcl IMPLEMENTATION.\n  METHOD t.\n    DATA lo_http TYPE REF TO zcl_h.\n    lo_http->mv_sticky = abap_true.\n  ENDMETHOD.\nENDCLASS.",
    },
    expect: ["ltcl:mv_sticky"],
  },
  {
    name: "a private type named statically from another class's definition",
    files: {
      "zcl_h.clas.abap": HANDLER,
      "zcl_a.clas.abap": "CLASS zcl_a DEFINITION PUBLIC.\n  PUBLIC SECTION.\n    DATA ms_row TYPE zcl_h=>ty_s_row.\nENDCLASS.\nCLASS zcl_a IMPLEMENTATION.\nENDCLASS.",
    },
    expect: ["zcl_a:ty_s_row"],
  },
  {
    name: "the same variable name typed differently in another method is not a finding",
    files: {
      "zcl_h.clas.abap": HANDLER,
      "zcl_o.clas.abap": "CLASS zcl_o DEFINITION PUBLIC.\n  PUBLIC SECTION.\n    DATA mv_sticky TYPE abap_bool.\n    METHODS a.\n    METHODS b.\nENDCLASS.\nCLASS zcl_o IMPLEMENTATION.\n  METHOD a.\n    DATA lo TYPE REF TO zcl_h.\n    lo->mv_public = `x`.\n  ENDMETHOD.\n  METHOD b.\n    DATA lo TYPE REF TO zcl_o.\n    lo->mv_sticky = abap_true.\n  ENDMETHOD.\nENDCLASS.",
    },
    expect: [],
  },
  {
    name: "own class, LOCAL FRIENDS and a global FRIENDS clause are legal",
    files: {
      "zcl_h.clas.abap": HANDLER.replace("PUBLIC FINAL.", "PUBLIC FINAL FRIENDS zcl_f.").replace("CLASS zcl_h IMPLEMENTATION.\nENDCLASS.", "CLASS zcl_h IMPLEMENTATION.\n  METHOD x.\n    DATA lo TYPE REF TO zcl_h.\n    lo->mv_sticky = abap_true.\n  ENDMETHOD.\nENDCLASS."),
      "zcl_h.clas.testclasses.abap": "CLASS ltcl DEFINITION DEFERRED.\nCLASS zcl_h DEFINITION LOCAL FRIENDS ltcl.\nCLASS ltcl DEFINITION FOR TESTING.\nENDCLASS.\nCLASS ltcl IMPLEMENTATION.\n  METHOD t.\n    DATA(lo) = NEW zcl_h( ).\n    lo->mv_sticky = abap_true.\n  ENDMETHOD.\nENDCLASS.",
      "zcl_f.clas.abap": "CLASS zcl_f DEFINITION PUBLIC.\n  PUBLIC SECTION.\n    DATA mo TYPE REF TO zcl_h.\nENDCLASS.\nCLASS zcl_f IMPLEMENTATION.\n  METHOD x.\n    mo->mv_sticky = abap_true.\n  ENDMETHOD.\nENDCLASS.",
    },
    expect: [],
  },
  {
    name: "a subclass reaches PROTECTED but not PRIVATE",
    files: {
      "zcl_h.clas.abap": HANDLER.replace(" FINAL.", "."),
      "zcl_s.clas.abap": "CLASS zcl_s DEFINITION PUBLIC INHERITING FROM zcl_h.\n  PUBLIC SECTION.\n    METHODS x.\nENDCLASS.\nCLASS zcl_s IMPLEMENTATION.\n  METHOD x.\n    DATA lo TYPE REF TO zcl_h.\n    lo->mv_prot = `a`.\n    lo->mv_sticky = abap_true.\n  ENDMETHOD.\nENDCLASS.",
    },
    expect: ["zcl_s:mv_sticky"],
  },
];

for (const testCase of SELF_TEST) {
  const files = Object.entries(testCase.files).map(([file, text]) => ({ file, text }));
  const got = findingsFor(files).map(f => `${f.accessor}:${f.member}`).sort();
  if (got.join(" ") !== [...testCase.expect].sort().join(" ")) {
    console.error(`member visibility: the gate's own self-test failed - "${testCase.name}"`);
    console.error(`  expected: ${testCase.expect.join(", ") || "(no finding)"}`);
    console.error(`  got:      ${got.join(", ") || "(no finding)"}`);
    console.error("");
    console.error("The detection changed. Until this case passes again, a green run over src/");
    console.error("says nothing - fix the parser, or the case if the expectation was wrong.");
    process.exit(1);
  }
}

const files = walk(ROOT, "src")
  .filter(f => f.endsWith(".abap"))
  .sort()
  .map(file => ({ file, text: readFileSync(join(ROOT, file), "utf8") }));

// zero scanned files means the walk found nothing - see assertion-gate.mjs
if (files.length === 0) {
  console.error("member visibility: no ABAP found under src/ - nothing was checked");
  process.exit(1);
}

const findings = findingsFor(files);
if (findings.length > 0) {
  console.log("member visibility: these accesses do not compile on a system.");
  console.log("");
  for (const f of findings) {
    console.log(`  ${f.at}`);
    console.log(`    ${f.accessor} reaches ${f.visibility} ${f.via}${f.member} of ${f.declaring.name}`);
  }
  console.log("");
  console.log("Move the member to the PUBLIC SECTION (READ-ONLY where only the owner writes it),");
  console.log("or - for a test class of the owner's own pool - add");
  console.log("  CLASS <owner> DEFINITION LOCAL FRIENDS <test class>.");
  process.exit(1);
}

console.log(`member visibility: ${files.length} file(s), ${SELF_TEST.length} self-test case(s) checked - OK`);
