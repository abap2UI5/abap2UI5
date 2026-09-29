/* global abap */
// The differential half of accelerate.spec.js: every fast path of
// node/srv/accelerate.mjs against the @abaplint/runtime function it replaces,
// over seeded random cases. Each LOOP scenario runs twice on identical fresh
// tables - once with the runtime's loop, once with the fast one - and the
// two traces (rows yielded, sy-tabix in the body, everything the body did,
// sy-subrc/sy-tabix after, errors, the table afterwards) have to be equal.
// CP and NP are compared call for call.
//
// A separate process for the same reason as efWire.mjs: the runtime and the
// module under test load natively here, and the spec reads plain JSON back.
//
// env: ACCELERATE_SEED (default 1), ACCELERATE_LOOPS, ACCELERATE_CPS
// stdout: JSON { runtime, validated, loop: {...}, cp: {...}, idempotent }
import runtime from "@abaplint/runtime";
import { accelerate, RUNTIME_VERSION } from "../../srv/accelerate.mjs";
import { createRequire } from "node:module";

globalThis.abap = new runtime.ABAP();
const T = abap.types;
const SEED = Number(process.env.ACCELERATE_SEED || 1);
const LOOPS = Number(process.env.ACCELERATE_LOOPS || 4000);
const CPS = Number(process.env.ACCELERATE_CPS || 30000);

const original = { loop: abap.statements.loop, compare: abap.compare };
// force: the differential half has to run against a runtime the version pin
// does not know yet - that is when it is needed (the spec checks the pin)
const installed = accelerate({ force: true });
const fast = { loop: abap.statements.loop, compare: abap.compare };
const idempotent = accelerate({ force: true }) === true
  && abap.statements.loop === fast.loop && abap.compare === fast.compare;

// --- seeded randomness -------------------------------------------------------
function rng(seed) {
  let a = seed >>> 0;
  const next = () => {
    a = (a + 0x6D2B79F5) >>> 0;
    let t = a;
    t = Math.imul(t ^ (t >>> 15), t | 1);
    t ^= t + Math.imul(t ^ (t >>> 7), t | 61);
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
  return {
    next,
    int: (n) => Math.floor(next() * n),
    pick: (list) => list[Math.floor(next() * list.length)],
    chance: (p) => next() < p,
  };
}

const sy = () => abap.builtin.sy.get();
const show = (v) => (v === undefined ? "undefined" : typeof v === "bigint" ? `${v}n` : String(v));

// --- LOOP --------------------------------------------------------------------

/* The key types: how a key field is built, the values the rows draw from
 * (duplicates on purpose), and how an operand of the same or another type is
 * made. `top(i)` is a key above every domain value, for an APPEND that keeps
 * the order. */
const KEYS = {
  string: {
    make: () => new T.String(),
    domain: ["", "a", "b", "b ", "ba", "c", "\t", "d"],
    absent: ["0", "aa", "bb", "e"],
    top: (i) => `z${String(i).padStart(3, "0")}`,
  },
  integer: {
    make: () => new T.Integer(),
    domain: [-2, -1, 0, 1, 2, 3, 5],
    absent: [-9, 4, 9],
    top: (i) => 100 + i,
  },
  char3: {
    make: () => new T.Character(3),
    domain: ["", "a", "ab", "a\t", "b", "c"],
    absent: ["0", "aa", "d"],
    top: (i) => `z${String(i).padStart(2, "0")}`,
  },
  packed: {
    make: () => new T.Packed({ length: 8, decimals: 2 }),
    domain: [-1.5, 0, 0.25, 1, 1.5, 7],
    absent: [-3, 0.5, 9],
    top: (i) => 100 + i,
  },
};

/* The operand of `WHERE k = <operand>`, by kind: the key's own type (the
 * fast path), a Character literal against a string key (the fast path's one
 * mixed pair), and pairs it must hand to the original. */
const OPERANDS = {
  same: (key, raw) => key.make().set(raw),
  char: (key, raw) => new T.Character(Math.max(1, String(raw).length + 1)).set(String(raw)),
  char1: (key, raw) => new T.Character(1).set(String(raw)),
  string: (key, raw) => new T.String().set(String(raw)),
};

function scenario(seed) {
  const r = rng(seed);
  const keyName = r.pick(Object.keys(KEYS));
  const key = KEYS[keyName];
  const scalar = r.chance(0.25);
  const unique = r.chance(0.5);
  const twoFields = !scalar && r.chance(0.5);
  const size = r.pick([0, 1, 2, 3, 5, 8, 13, 21, 34]);
  const rows = [];
  for (let i = 0; i < size; i++) rows.push({ k: r.pick(key.domain), n: r.int(6) });
  // before, inside and after the rows, and absent
  const searched = r.chance(0.8) ? r.pick(key.domain) : r.pick(key.absent);
  let operandKind = "same";
  if (keyName === "string" && r.chance(0.3)) operandKind = "char";
  else if (r.chance(0.08)) operandKind = r.pick(["char1", "string"]);
  const shape = r.pick(scalar ? ["eq", "eq", "or", "not"] : ["eq", "eq", "and", "andFirst", "or", "not"]);
  const usingKey = r.pick(scalar ? [undefined, undefined, "primary_key", ""] : [undefined, undefined, "primary_key", "", "by_n"]);
  const viaFieldSymbol = r.chance(0.15);
  const buildWithLines = r.chance(0.2);
  const bodySeed = r.int(2 ** 31);
  return { seed, keyName, scalar, unique, twoFields, rows, searched, operandKind, shape, usingKey,
    viaFieldSymbol, buildWithLines, bodySeed };
}

function buildTable(sc) {
  const key = KEYS[sc.keyName];
  const rowType = sc.scalar
    ? key.make()
    : new T.Structure({ k: key.make(), n: new T.Integer(), s: new T.String() }, "ty_row");
  const keyFields = sc.scalar ? ["TABLE_LINE"] : sc.twoFields ? ["K", "N"] : ["K"];
  const options = {
    withHeader: false,
    keyType: "USER",
    primaryKey: { name: "primary_key", type: "SORTED", isUnique: sc.unique, keyFields },
    secondary: sc.scalar ? [] : [{ name: "by_n", type: "SORTED", isUnique: false, keyFields: ["N"] }],
  };
  const table = new T.Table(rowType, options, "ty_tab");
  const rowOf = (k, n) => {
    if (sc.scalar) return key.make().set(k);
    const row = rowType.clone();
    row.get().k.set(k);
    row.get().n.set(n);
    return row;
  };
  if (sc.buildWithLines) {
    // INSERT LINES OF: appended, then sorted by the runtime
    const source = new T.Table(rowType, { ...options, primaryKey: { ...options.primaryKey, type: "STANDARD", isUnique: false } }, "ty_src");
    for (const { k, n } of sc.rows) abap.statements.insertInternal({ table: source, data: rowOf(k, n) });
    if (!sc.unique) abap.statements.insertInternal({ table, data: source, lines: true });
    else for (const row of source.array()) abap.statements.insertInternal({ table, data: row });
  } else {
    for (const { k, n } of sc.rows) abap.statements.insertInternal({ table, data: rowOf(k, n) });
  }
  return { table, rowOf, key };
}

/* The WHERE functions have the transpiler's shape - `async (I) => {return
 * ...;}` - because the fast path reads that shape (accelerate.mjs,
 * conjunctionOn). `calls` counts evaluations, which the traces leave out:
 * evaluating fewer is the point. */
function whereFor(sc, operand, other, counter) {
  const n5 = new T.Integer().set(2);
  if (sc.scalar) {
    switch (sc.shape) {
      case "or": return {
        where: async (I) => {counter.calls++; return abap.compare.eq(I.table_line, operand) || abap.compare.eq(I.table_line, other);},
        topEquals: { table_line: other } };
      case "not": return {
        where: async (I) => {counter.calls++; return !abap.compare.eq(I.table_line, other) && abap.compare.eq(I.table_line, operand);},
        topEquals: { table_line: operand } };
      default: return {
        where: async (I) => {counter.calls++; return abap.compare.eq(I.table_line, operand);},
        topEquals: { table_line: operand } };
    }
  }
  switch (sc.shape) {
    case "and": return {
      where: async (I) => {counter.calls++; return abap.compare.eq(I.k, operand) && abap.compare.gt(I.n, n5);},
      topEquals: { k: operand } };
    case "andFirst": return {
      where: async (I) => {counter.calls++; return abap.compare.lt(I.n, n5) && abap.compare.eq(I.k, operand);},
      topEquals: { k: operand } };
    // `k = x OR n = 2`: the transpiler puts BOTH into topEquals
    case "or": return {
      where: async (I) => {counter.calls++; return abap.compare.eq(I.k, operand) || abap.compare.eq(I.n, n5);},
      topEquals: { k: operand, n: n5 } };
    case "not": return {
      where: async (I) => {counter.calls++; return !abap.compare.eq(I.k, other) && abap.compare.eq(I.k, operand);},
      topEquals: { k: operand } };
    default: return {
      where: async (I) => {counter.calls++; return abap.compare.eq(I.k, operand);},
      topEquals: { k: operand } };
  }
}

/* Would the fast path take this scenario? Written out independently of
 * accelerate.mjs, so a planFor() that takes too much or too little shows as
 * where-call counts that do not match the expectation. */
function expectFast(sc) {
  if (sc.shape === "or" || sc.usingKey === "by_n") return false;
  // the operand's own type, or a Character literal against a string key -
  // a String against a char key, or a char of another length, is not taken
  return sc.operandKind === "same" || sc.keyName === "string";
}

function snapshot(table, scalar) {
  return table.array().map((row) => (scalar ? show(row.get()) : `${show(row.get().k.get())}|${row.get().n.get()}|${row.get().s.get()}`));
}

async function runLoop(sc, ctx, depth, trace) {
  const { table, rowOf, key, r } = ctx;
  const raw = depth === 0 ? sc.searched : (r.chance(0.7) ? sc.searched : r.pick(key.domain));
  const operand = OPERANDS[sc.operandKind](key, raw);
  const other = key.make().set(r.pick(key.domain));
  const options = whereFor(sc, operand, other, ctx.counter);
  if (sc.usingKey !== undefined) options.usingKey = sc.usingKey;
  let target = table;
  if (sc.viaFieldSymbol) {
    target = new T.FieldSymbol(table);
    target.assign(table);
  }
  trace.push(`loop ${depth} ${show(raw)}`);
  try {
    for await (const row of abap.statements.loop(target, options)) {
      const tabix = sy().tabix.get();
      trace.push(`row ${tabix} ${sc.scalar ? show(row.get()) : `${show(row.get().k.get())}|${row.get().n.get()}`}`);
      const action = r.next();
      if (action < 0.12) {
        const k = r.chance(0.6) ? raw : r.pick(key.domain);
        const n = r.int(6);
        abap.statements.insertInternal({ table, data: rowOf(k, n) });
        trace.push(`insert ${show(k)}|${n} subrc ${sy().subrc.get()}`);
      } else if (action < 0.2) {
        await abap.statements.deleteInternal(table, { index: new T.Integer().set(tabix) });
        trace.push(`delete current subrc ${sy().subrc.get()}`);
      } else if (action < 0.26) {
        const len = table.getArrayLength();
        if (len > 0) {
          const index = 1 + r.int(len);
          await abap.statements.deleteInternal(table, { index: new T.Integer().set(index) });
          trace.push(`delete ${index} subrc ${sy().subrc.get()}`);
        }
      } else if (action < 0.3) {
        // APPEND in key order - legal on a sorted table - grows the array
        // at the end, where only a refreshed loopTo reaches it
        ctx.appends += 1;
        abap.statements.append({ source: rowOf(key.top(ctx.appends), 0), target: table });
        trace.push(`append tabix ${sy().tabix.get()}`);
      } else if (action < 0.34) {
        trace.push("exit");
        break;
      } else if (action < 0.37) {
        throw new Error(`body ${depth}`);
      } else if (action < 0.45 && depth < 2) {
        await runLoop(sc, ctx, depth + 1, trace);
        trace.push(`after inner tabix ${sy().tabix.get()} subrc ${sy().subrc.get()}`);
      } else if (action < 0.5 && !sc.scalar) {
        row.get().s.set(`m${depth}`);
      } else if (action < 0.55) {
        // INSERT LINES OF: the runtime appends and re-sorts in place without
        // moving a loop's index, so the scan can stand on a row that sorts
        // BEFORE the value afterwards - the original scans on from there
        const lines = new T.Table(table.getRowType(), { withHeader: false, keyType: "DEFAULT", primaryKey: { name: "primary_key", type: "STANDARD", isUnique: false, keyFields: [] } }, "ty_lines");
        const count = 1 + r.int(3);
        const added = [];
        for (let i = 0; i < count; i++) {
          const k = r.pick(key.domain);
          const n = r.int(6);
          added.push(`${show(k)}|${n}`);
          abap.statements.insertInternal({ table: lines, data: rowOf(k, n) });
        }
        abap.statements.insertInternal({ table, data: lines, lines: true });
        trace.push(`insert lines ${added.join(",")}`);
      } else if (action < 0.57) {
        // the whole table assigned: a new array, the loop keeps the old one
        const copy = table.clone();
        table.set(copy);
        trace.push("assigned");
      }
    }
  } catch (e) {
    trace.push(`error ${depth} ${e?.constructor?.name}: ${e?.message}`);
  }
  trace.push(`end ${depth} subrc ${sy().subrc.get()} tabix ${sy().tabix.get()}`);
}

async function traceOf(sc, impl) {
  abap.statements.loop = impl;
  const { table, rowOf, key } = buildTable(sc);
  const ctx = { table, rowOf, key, r: rng(sc.bodySeed), counter: { calls: 0 }, appends: 0 };
  sy().tabix.set(77);
  sy().subrc.set(3);
  const trace = [];
  await runLoop(sc, ctx, 0, trace);
  trace.push(`table ${snapshot(table, sc.scalar).join(",")}`);
  return { trace, calls: ctx.counter.calls };
}

const loop = { scenarios: 0, fastExpected: 0, engaged: 0, whereOriginal: 0, whereFast: 0, mismatches: [], misplanned: [] };
for (let i = 0; i < LOOPS; i++) {
  const sc = scenario(SEED * 1000003 + i);
  const a = await traceOf(sc, original.loop);
  const b = await traceOf(sc, fast.loop);
  loop.scenarios += 1;
  loop.whereOriginal += a.calls;
  loop.whereFast += b.calls;
  if (JSON.stringify(a.trace) !== JSON.stringify(b.trace)) {
    if (loop.mismatches.length < 5) loop.mismatches.push({ scenario: sc, original: a.trace, fast: b.trace });
    continue;
  }
  const expected = expectFast(sc);
  if (expected) loop.fastExpected += 1;
  if (b.calls < a.calls) loop.engaged += 1;
  if ((!expected && b.calls !== a.calls) || (expected && b.calls > a.calls)) {
    if (loop.misplanned.length < 5) loop.misplanned.push({ scenario: sc, expected, original: a.calls, fast: b.calls });
  }
}
abap.statements.loop = fast.loop;

// --- CP / NP -----------------------------------------------------------------

const ALPHABET = ["a", "A", "b", "B", "k", "K", "K", "s", "S", "ſ", "ß", "ẞ", "i", "I",
  "İ", "ı", "é", "É", " ", "\n", "\t", "😀", "\uD83D", ".", "(", ")", "[", "]",
  "\\", "^", "$", "|", "?", "{", "}", "-", "/", "<", ">", "!", "*", "+", "#", "x", "y"];

function text(r, max) {
  let s = "";
  const len = r.int(max + 1);
  for (let i = 0; i < len; i++) s += r.pick(ALPHABET);
  return s;
}

function patternFor(r, left) {
  if (left.length > 16) {
    // a long string only with few wildcards: a pattern derived from it would
    // carry dozens of `*`, and both implementations backtrack exponentially
    // on such a regex - the shapes cl_ixml asks, and a `*` in front
    const head = left.slice(0, 1 + r.int(3)).replace(/[*+#]/g, "#$&");
    return r.pick([`${head}*`, `${head}**`, `${head}+*`, `*${head}*`, `${head}`, "<*", "</*", "<?*", "<!--*", "*"]);
  }
  if (left.length > 0 && r.chance(0.5)) {
    // derived from the string, so a good share of cases match
    let p = "";
    for (const ch of left) {
      const x = r.next();
      if (x < 0.1) p += "+";
      else if (x < 0.18) p += "*";
      else if (x < 0.23) continue;
      else if ((ch === "*" || ch === "+" || ch === "#") && r.chance(0.7)) p += `#${ch}`;
      else if (x < 0.3) p += ch.toUpperCase();
      else if (x < 0.35) p += `#${ch}`;
      else p += ch;
    }
    return p + r.pick(["", "", "*", "**", "*", "+", "#", " "]);
  }
  let p = "";
  const len = r.int(7);
  for (let i = 0; i < len; i++) {
    const x = r.next();
    p += x < 0.2 ? "*" : x < 0.3 ? "+" : x < 0.4 ? `#${r.pick(ALPHABET)}` : r.pick(ALPHABET);
  }
  return p + r.pick(["", "*", "**", "#", "#*", "  "]);
}

function leftOf(r, s) {
  switch (r.int(8)) {
    case 0: return new T.String().set(s);
    case 1: return new T.Character(Math.max(1, s.length + r.int(3))).set(s);
    case 2: return new T.Character(Math.max(1, Math.floor(s.length / 2) || 1)).set(s);
    case 3: {
      const fs = new T.FieldSymbol(new T.String());
      fs.assign(new T.String().set(s));
      return fs;
    }
    case 4: {
      const st = new T.Structure({ a: new T.Character(2), b: new T.String() }, "ty_cp");
      st.get().a.set(s.slice(0, 2));
      st.get().b.set(s.slice(2));
      return st;
    }
    case 5: return r.chance(0.5) ? r.int(1000) : new T.Integer().set(r.int(1000) - 500);
    default: return s;
  }
}

function rightOf(r, p) {
  switch (r.int(4)) {
    case 0: return new T.Character(Math.max(1, p.length + r.int(3))).set(p);
    case 1: return new T.String().set(p);
    default: return p;
  }
}

const outcome = (fn) => {
  try {
    return `= ${fn()}`;
  } catch (e) {
    return `! ${e?.constructor?.name}: ${e?.message}`;
  }
};

const cp = { cases: 0, matched: 0, mismatches: [] };
const cr = rng(SEED * 7919 + 17);
const reuse = [];
for (let i = 0; i < CPS; i++) {
  const s = cr.chance(0.02) ? "<" + text(cr, 3).repeat(200) : text(cr, 12);
  const p = reuse.length > 50 && cr.chance(0.3) ? cr.pick(reuse) : patternFor(cr, s);
  if (reuse.length < 400) reuse.push(p);
  const left = leftOf(cr, s);
  const right = rightOf(cr, p);
  const a = outcome(() => original.compare.cp(left, right));
  const b = outcome(() => fast.compare.cp(left, right));
  const an = outcome(() => original.compare.np(left, right));
  const bn = outcome(() => fast.compare.np(left, right));
  cp.cases += 1;
  if (a === "= true") cp.matched += 1;
  if (a !== b || an !== bn) {
    if (cp.mismatches.length < 10) cp.mismatches.push({ left: s, pattern: p, original: [a, an], fast: [b, bn] });
  }
}
// an unassigned field symbol on the left, an undefined operand
for (const [left, right] of [[new T.FieldSymbol(new T.String()), "*"], [undefined, "a*"], ["a", undefined]]) {
  const a = outcome(() => original.compare.cp(left, right));
  const b = outcome(() => fast.compare.cp(left, right));
  cp.cases += 1;
  if (a !== b) cp.mismatches.push({ left: String(left), pattern: String(right), original: [a], fast: [b] });
}

process.stdout.write(JSON.stringify({
  runtime: createRequire(import.meta.url)("@abaplint/runtime/package.json").version,
  validated: RUNTIME_VERSION,
  installed,
  idempotent,
  seed: SEED,
  loop,
  cp,
}));
