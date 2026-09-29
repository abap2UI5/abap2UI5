/*
 * accelerate.mjs - two fast paths for @abaplint/runtime, installed on the
 * running ABAP runtime (globalThis.abap) by accelerate().
 *
 * WHY. A roundtrip that carries one table of n rows cost O(n^2) in the
 * transpiled framework, although the ABAP is linear - on an SAP system the
 * same app answers in milliseconds. Both quadratic spots are in the runtime
 * the transpiler targets, not in abap2UI5's code:
 *
 *   1. LOOP AT itab ... WHERE on a SORTED table over its PRIMARY key.
 *      statements/loop.js narrows the rows by binary search only for a
 *      secondary key; on the primary key it evaluates the WHERE on every
 *      row. z2ui5_cl_ajson's stringify walks mt_json_tree (SORTED UNIQUE KEY
 *      path name) with `LOOP ... USING KEY (lv_tab_key) WHERE path =
 *      iv_parent_path` once per node - n nodes times n rows.
 *   2. CP. compare/cp.js compiles `new RegExp("^" + pattern + "$", "iu")` on
 *      every call, and a trailing `*` becomes `[\s\S]*$`, which walks the
 *      whole string to confirm what the prefix already decided. open-abap's
 *      XML parser (cl_ixml, if_ixml_parser~parse) asks `lv_xml CP '<*'` and
 *      five more prefix patterns once per token, lv_xml being the REST of
 *      the document - every token rescans the draft XML behind it.
 *
 * Measured inside a CAP project (@cap2ui5/cds-plugin, @abap2ui5/node-runtime
 * 1.145.0): the event roundtrip of 2000 rows went from 22.6 s to 1.8 s, and
 * the numbers grow linearly from there (npm.README.md, "Performance").
 *
 * WHAT IS REPLACED, AND WHAT IS NOT. Both fast paths answer exactly what the
 * functions they replace answer, and hand everything else to them:
 *
 *   abap.statements.loop  takes over one shape only: a Table whose primary
 *     key is SORTED, looped over that key (usingKey undefined, "primary_key",
 *     or "" - the same path in loop.js), with a WHERE that is a pure
 *     conjunction naming the first key field with `=` (the transpiler's
 *     topEquals) and no FROM/TO/dynamic WHERE/AT LAST. Every other loop is
 *     the original's, called directly - not wrapped.
 *     It IS the original's loop body, with two ranges skipped whose WHERE
 *     cannot hold: the rows that sort before the value (found by binary
 *     search) and, once the scan reaches a row that sorts after it, every
 *     row from there to the end - it jumps straight to the end of the array,
 *     where the original's own end conditions take over (including its
 *     behaviour when a DELETE in the body left loopTo past the end). The
 *     loop is registered with table.startLoop()/unregisterLoop() like the
 *     original, so an INSERT or DELETE in the body shifts it the same way;
 *     sy-tabix, sy-subrc, the restore of sy-tabix on ENDLOOP, EXIT, RETURN
 *     and exceptions are the original's code.
 *   abap.compare.cp / np  derive the two strings exactly as cp.js does and
 *     translate the pattern exactly as it does (# escapes, + and *, the
 *     "iu" flags). Two changes: a trailing run of `*` and the `$` anchor are
 *     dropped - `^X[\s\S]*$` matches exactly when `^X` does - and the
 *     compiled RegExp is cached per pattern (bounded, oldest out first).
 *     np is `!cp` in the runtime, so it gets the same.
 *
 * WHAT THE LOOP FAST PATH RELIES ON - each checked where it can be, and the
 * rest is what the runtime itself already relies on:
 *   - The table is in key order. insertSorted() keeps it so, and READ TABLE
 *     ... WITH KEY on a sorted table already binary-searches in this runtime.
 *     ABAP forbids everything that breaks the order (an APPEND out of order,
 *     writing a key field through a field symbol); the runtime does not
 *     check those, so a program that does them gets a table READ TABLE
 *     already misreads, and now LOOP ... WHERE as well. One legal statement
 *     produces such a table in 2.13.93: VALUE #( ) of a sorted table type
 *     appends its rows unsorted, until an assignment sorts them.
 *   - The key comparison is a required conjunct of the WHERE: topEquals
 *     alone does not say so (the transpiler collects the `=` comparisons of
 *     `a = 1 OR b = 2` just the same), so the WHERE's source must contain
 *     no `||` and must compare that field (conjunctionOn).
 *   - Comparing the value with the key field orders consistently with the
 *     sort and agrees with the WHERE's abap.compare.eq - true for the type
 *     pairs comparatorFor() accepts; any other pair takes the original.
 *   - Evaluating the WHERE has no side effects and throws on no row, so not
 *     evaluating it on the skipped rows changes nothing. True for what the
 *     transpiler generates from a WHERE of comparisons. Two deliberate
 *     differences: a WHERE that would throw on a row outside the key range
 *     (a conversion error in another conjunct) does not throw here, and an
 *     operand that is an expression (a string template, a method call) is
 *     taken as it was at loop entry for the skip - both as on an SAP system,
 *     where the key range is all the kernel reads and a WHERE operand is
 *     evaluated once.
 *
 * THE VERSION. Everything above was read off, and is tested against, one
 * version of @abaplint/runtime: RUNTIME_VERSION. The package pins exactly
 * that version (pack-npm.mjs pins the lockfile's), and accelerate() on any
 * other version installs nothing and warns once. node/tests/accelerate.spec.js
 * fails when package-lock.json moves the runtime, so a bump has to revalidate:
 * re-read statements/loop.js and compare/cp.js for changes, run the spec
 * (its differential half compares the fast paths with the NEW originals),
 * and move RUNTIME_VERSION.
 *
 * This file imports nothing from output/: a host that boots through
 * output/init.mjs itself (@cap2ui5/cds-plugin) imports it as
 * "@abap2ui5/node-runtime/accelerate" and calls accelerate() after the boot;
 * host.mjs's initialize() does that for every host that boots through it.
 */
import { createRequire } from "node:module";

/** The @abaplint/runtime version the fast paths were validated against. */
export const RUNTIME_VERSION = "2.13.93";

/** On a replaced function or object: the original it replaced. */
const REPLACED = Symbol.for("@abap2ui5/node-runtime/accelerate");

/** Compiled CP patterns kept at most; the oldest goes first. */
const CP_CACHE_SIZE = 1000;

let warned = false;

function installedRuntimeVersion() {
  try {
    return createRequire(import.meta.url)("@abaplint/runtime/package.json").version;
  } catch {
    return null;
  }
}

/**
 * Install the fast paths on the running ABAP runtime. Idempotent: a second
 * call finds them installed and changes nothing.
 * @param {{ abap?: object, force?: boolean }} [options]
 *   `abap` the runtime instance (default: globalThis.abap, which
 *   output/init.mjs creates); `force` installs on a runtime version other
 *   than RUNTIME_VERSION - for revalidating a new version, not for a host
 * @returns {boolean} whether the fast paths are installed
 */
export function accelerate({ abap: runtime = globalThis.abap, force = false } = {}) {
  if (!runtime?.statements?.loop || !runtime?.compare?.cp || !runtime?.types?.Table) {
    throw new Error("accelerate(): no ABAP runtime to accelerate - call it after output/init.mjs has booted (initialize())");
  }
  const version = installedRuntimeVersion();
  if (version !== RUNTIME_VERSION && !force) {
    if (!warned) {
      warned = true;
      console.warn(`@abap2ui5/node-runtime: accelerate() left @abaplint/runtime ${version ?? "(not found)"} as it is -`
        + ` its fast paths are validated for ${RUNTIME_VERSION} only. A LOOP ... WHERE over a sorted primary key`
        + " and CP keep the runtime's own implementations (correct, quadratic on large tables).");
    }
    return false;
  }
  if (!runtime.statements.loop[REPLACED]) {
    runtime.statements.loop = sortedKeyLoop(runtime, runtime.statements.loop);
  }
  if (!runtime.compare[REPLACED]) {
    runtime.compare = cachedPatterns(runtime, runtime.compare);
  }
  return true;
}

// --- LOOP AT <sorted table> WHERE <first key field> = value ... -------------

function sortedKeyLoop(runtime, original) {
  const { Table, Structure, FieldSymbol } = runtime.types;
  const { eq, lt } = runtime.compare;
  const comparatorFor = comparators(runtime);

  /* The plan is made from what cannot change between this call and the
   * first next(): the table object, its options, its row type, the WHERE
   * function and the operand OBJECT. The rows and the operand's value are
   * read inside the generator, at the moment the original reads them. */
  function planFor(table, options) {
    const topEquals = options?.topEquals;
    if (topEquals === undefined || topEquals === null || typeof options.where !== "function") return null;
    if (options.from !== undefined || options.to !== undefined
      || options.dynamicWhere !== undefined || options.atLast !== undefined) return null;
    const usingKey = options.usingKey;
    // loop.js refreshes loopTo after every row only when usingKey is
    // undefined; "primary_key" and "" take the same primary path without it
    if (usingKey !== undefined && usingKey !== "primary_key" && usingKey !== "") return null;
    const target = table instanceof FieldSymbol ? table.getPointer() : table;
    if (!(target instanceof Table)) return null;
    const key = target.getOptions()?.primaryKey;
    if (key?.type !== "SORTED" || !Array.isArray(key.keyFields) || key.keyFields.length === 0) return null;
    // "" reads as "no secondary key" in loop.js only while no key has that name
    if (usingKey === "" && target.getKeyByName("") !== undefined) return null;
    const field = String(key.keyFields[0]).toLowerCase();
    if (!Object.hasOwn(topEquals, field)) return null;
    const rowType = target.getRowType();
    const structured = rowType instanceof Structure;
    // a structured row with a table_line key compares whole rows, and a
    // scalar row has no component - neither is taken
    if (structured === (field === "table_line")) return null;
    const sample = structured ? rowType.get()[field] : rowType;
    const compare = comparatorFor(sample, topEquals[field], eq, lt);
    if (compare === null || !conjunctionOn(options.where, field)) return null;
    return { target, field, structured, compare, refresh: usingKey === undefined };
  }

  function loop(table, options) {
    const plan = planFor(table, options);
    return plan === null ? original.call(this, table, options) : run(this, table, options, plan);
  }

  /* statements/loop.js's loop() for the planned shape, statement for
   * statement, with the two skips marked SKIP. */
  async function* run(self, table, options, plan) {
    if (table instanceof FieldSymbol && table.getPointer() !== plan.target) {
      // re-pointed (or unassigned) since the call: the original decides
      yield* original.call(self, table, options);
      return;
    }
    const target = plan.target;
    const length = target.getArrayLength();
    if (length === 0) {
      globalThis.abap.builtin.sy.get().subrc.set(4);
      return;
    }
    const array = target.array();
    const isStructured = array[0] instanceof Structure;
    if (isStructured !== plan.structured) {
      // rows that are not of the row type - nothing the plan was made for
      yield* original.call(self, table, options);
      return;
    }
    const { field, compare, refresh } = plan;
    const value = options.topEquals[field];
    const keyOf = isStructured ? (row) => row.get()[field] : (row) => row;

    // SKIP 1: the rows that sort before the value - the WHERE is false on
    // every one of them. Binary search for the first that does not.
    let lo = 0;
    let hi = length;
    while (lo < hi) {
      const mid = (lo + hi) >>> 1;
      if (compare(keyOf(array[mid]), value) < 0) lo = mid + 1;
      else hi = mid;
    }

    const loopController = target.startLoop(lo, length, array);
    let entered = false;
    const outerTabix = globalThis.abap.builtin.sy.get().tabix.get();
    try {
      while (loopController.index < loopController.loopTo) {
        if (loopController.index > array.length) {
          break;
        }
        const current = array[loopController.index];
        // SKIP 2: this row sorts after the value, and so does every row
        // behind it - the WHERE holds on none of them. Continue at the end
        // of the array, where the original's own end conditions decide
        // (a loopTo that DELETEs left past the end included).
        if (current !== undefined && compare(keyOf(current), value) > 0) {
          loopController.index = array.length;
          continue;
        }
        const row = isStructured ? current.get() : { table_line: current };
        if (await options.where(row) === false) {
          loopController.index++;
          continue;
        }
        globalThis.abap.builtin.sy.get().tabix.set(loopController.index + 1);
        entered = true;
        yield current;
        loopController.index++;
        if (refresh) {
          // extra rows might have been inserted inside the loop
          loopController.loopTo = array.length;
        }
      }
    } finally {
      target.unregisterLoop(loopController);
      globalThis.abap.builtin.sy.get().subrc.set(entered ? 0 : 4);
      globalThis.abap.builtin.sy.get().tabix.set(outerTabix);
    }
  }

  loop[REPLACED] = original;
  return loop;
}

/* The WHERE the transpiler generates is `async (I) => {return <cond>;}`,
 * <cond> joining the comparisons with && and ||. topEquals holds every
 * top-level `=` of it, also those of `a = 1 OR b = 2`, so it does not by
 * itself make the key comparison a condition every row has to meet. With no
 * || anywhere - a string literal holding one included, which errs on the
 * safe side - every top-level comparison is one. */
function conjunctionOn(where, field) {
  const source = Function.prototype.toString.call(where);
  return !source.includes("||") && source.includes(`abap.compare.eq(I.${field},`);
}

/* compare(x, v) -> -1 | 0 | 1 for a key field x and the WHERE operand v:
 * 0 exactly when the WHERE's abap.compare.eq(x, v) holds, and ordered as
 * the table sorts x (sort.js compareRows: lt, then eq, of the field values).
 * Only for pairs where both are provably true; null takes the original. */
function comparators(runtime) {
  const T = runtime.types;
  // one type on both sides: the table sorts x with the same lt/eq
  const SAME = new Set([T.String, T.Character, T.Integer, T.Integer8, T.Numc,
    T.Date, T.Time, T.Packed, T.Float, T.Hex, T.XString].filter(Boolean));
  // ...and for these the length has to match as well: eq compares two
  // lengths trimmed, lt compares them padded, and the two disagree
  const FIXED = new Set([T.Character, T.Numc, T.Hex].filter(Boolean));
  return function comparatorFor(sample, value, eq, lt) {
    if (value === null || typeof value !== "object" || sample === null || typeof sample !== "object") return null;
    const type = sample.constructor;
    if (type === value.constructor && SAME.has(type)) {
      if (FIXED.has(type) && sample.getLength() !== value.getLength()) return null;
      return (x, v) => (eq(x, v) ? 0 : lt(x, v) ? -1 : 1);
    }
    if (type === T.String && value.constructor === T.Character) {
      // `WHERE name = 'X'` on a string key: eq compares the string with
      // the literal's getTrimEnd(), and a string key sorts as JS strings do
      return (x, v) => {
        const s = v.getTrimEnd();
        const xs = x.get();
        return xs === s ? 0 : xs < s ? -1 : 1;
      };
    }
    return null;
  };
}

// --- CP / NP ----------------------------------------------------------------

function cachedPatterns(runtime, original) {
  const { Structure, FieldSymbol, Character } = runtime.types;
  const cache = new Map();

  /* compare/cp.js's cp(), with the RegExp from compile() */
  function cp(left, right) {
    let l;
    if (typeof left === "number" || typeof left === "string") {
      l = left.toString();
    } else if (left instanceof Structure) {
      l = left.getCharacter();
    } else if (left instanceof FieldSymbol) {
      if (left.getPointer() === undefined) {
        throw new Error("GETWA_NOT_ASSIGNED");
      }
      return cp(left.getPointer(), right);
    } else if (left instanceof Character) {
      l = left.getTrimEnd();
    } else {
      l = left.get().toString();
    }
    let r;
    if (typeof right === "string") {
      r = right.toString();
    } else if (right instanceof Character) {
      r = right.getTrimEnd();
    } else {
      r = right.get().toString().trimEnd();
    }
    let reg = cache.get(r);
    if (reg === undefined) {
      reg = compile(r);
      if (cache.size >= CP_CACHE_SIZE) cache.delete(cache.keys().next().value);
      cache.set(r, reg);
    }
    return reg.test(l);
  }

  function np(left, right) {
    return !cp(left, right);
  }

  return Object.create(original, {
    cp: { value: cp, enumerable: true },
    np: { value: np, enumerable: true },
    [REPLACED]: { value: original },
  });
}

function escapeRegExpCharacter(input) {
  return input.replace(/[\\^$.*+?()[\]{}|]/g, "\\$&");
}

/* compare/cp.js's translation, token for token. `end` is the pattern's
 * length after the last token that is not a `*`: whatever follows it is a
 * run of trailing `[\s\S]*`, which matches any rest of the string - so it
 * goes, and so does the `$` that made the engine walk to the end to say so. */
function compile(r) {
  let pattern = "";
  let end = 0;
  for (let i = 0; i < r.length; i++) {
    const current = r[i];
    if (current === "*") {
      pattern += "[\\s\\S]*";
      continue;
    }
    if (current === "#") {
      if (i + 1 < r.length) {
        const next = r[i + 1];
        pattern += next === "#" ? "#" : escapeRegExpCharacter(next);
        i++;
      } else {
        pattern += "#";
      }
    } else if (current === "+") {
      pattern += "[\\s\\S]";
    } else {
      pattern += escapeRegExpCharacter(current);
    }
    end = pattern.length;
  }
  const open = end < pattern.length;
  return new RegExp("^" + pattern.slice(0, end) + (open ? "" : "$"), "iu");
}
