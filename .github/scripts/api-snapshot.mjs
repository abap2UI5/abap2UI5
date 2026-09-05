#!/usr/bin/env node
// Machine gate for AGENTS.md rule 5: the public API under src/02/ is a stable
// contract consumed by thousands of downstream apps - existing public methods,
// attributes, constants and types must never be removed or changed (additive
// changes are allowed, but must be recorded so they become part of the guarded
// contract).
//
// The committed snapshot .github/api-snapshot.json holds one normalized
// signature per public symbol. Modes:
//
//   node .github/scripts/api-snapshot.mjs          compare against the snapshot
//                                                  (exit 1 on removed, changed
//                                                  OR unrecorded-added symbols)
//   node .github/scripts/api-snapshot.mjs --write  regenerate the snapshot
//                                                  (run after an intentional
//                                                  additive change; the diff of
//                                                  the snapshot then shows the
//                                                  API change for review)
//
// A "changed" or "removed" finding is a rule-5 violation - do not update the
// snapshot to silence it; restore the signature instead. Renames count as
// remove + add. The parser is deliberately simple (definitions only, comments
// stripped, whitespace normalized); if it ever mis-parses a construct, fix the
// parser in the same change and note it here.
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const ROOT = path.join(path.dirname(fileURLToPath(import.meta.url)), "..", "..");
const SRC02 = path.join(ROOT, "src", "02");
const SNAPSHOT = path.join(ROOT, ".github", "api-snapshot.json");

function stripComments(code) {
  return code
    .split("\n")
    .map((line) => {
      const t = line.trimStart();
      if (t.startsWith("*") || t.startsWith('"')) return "";
      // inline " comment - safe here because src/02 definition literals use
      // backticks/single quotes; only strip when not inside a literal
      let out = "";
      let inTick = false;
      let inQuote = false;
      for (let i = 0; i < line.length; i++) {
        const c = line[i];
        if (c === "`" && !inQuote) inTick = !inTick;
        else if (c === "'" && !inTick) inQuote = !inQuote;
        else if (c === '"' && !inTick && !inQuote) break;
        out += c;
      }
      return out;
    })
    .join("\n");
}

// split a section body into period-terminated statements (periods inside
// literals are respected)
function statements(body) {
  const out = [];
  let cur = "";
  let inTick = false;
  let inQuote = false;
  for (const c of body) {
    if (c === "`" && !inQuote) inTick = !inTick;
    else if (c === "'" && !inTick) inQuote = !inQuote;
    if (c === "." && !inTick && !inQuote) {
      if (cur.trim()) out.push(cur.trim());
      cur = "";
    } else {
      cur += c;
    }
  }
  return out;
}

const norm = (s) => s.replace(/\s+/g, " ").trim().toLowerCase();

const KIND_RE =
  /^(class-methods|methods|class-data|data|constants|types|interfaces|aliases|class-events|events)\b/i;

// expand a chained declaration (KEYWORD: a ..., b ...) into single statements
function unchain(stmt) {
  const m = stmt.match(KIND_RE);
  if (!m) return [stmt];
  const kw = m[0];
  let rest = stmt.slice(m[0].length).trim();
  if (!rest.startsWith(":")) return [stmt];
  rest = rest.slice(1);
  const parts = [];
  let depth = 0;
  let cur = "";
  let inTick = false;
  let inQuote = false;
  for (const c of rest) {
    if (c === "`" && !inQuote) inTick = !inTick;
    else if (c === "'" && !inTick) inQuote = !inQuote;
    if (!inTick && !inQuote) {
      if (c === "(") depth++;
      if (c === ")") depth--;
      if (c === "," && depth === 0) {
        parts.push(cur);
        cur = "";
        continue;
      }
    }
    cur += c;
  }
  if (cur.trim()) parts.push(cur);
  return parts.map((p) => `${kw} ${p.trim()}`);
}

// group BEGIN OF ... END OF blocks (TYPES / CONSTANTS / DATA / CLASS-DATA)
// into one entry per structure - a member change then reads as a change of
// the whole named block
function groupTypes(stmts) {
  const BEGIN = /^(types|constants|class-data|data)\s+begin\s+of\s+(?:enum\s+)?(\S+)/i;
  const END = /^(?:types|constants|class-data|data)\s+end\s+of\s+(?:enum\s+)?(\S+)/i;
  const out = [];
  let block = null;
  let blockKind = null;
  let blockName = null;
  let depth = 0;
  for (const s of stmts) {
    const begin = s.match(BEGIN);
    const end = s.match(END);
    if (block === null && begin) {
      block = [s];
      blockKind = begin[1].toLowerCase().replace(/\s+/g, "-");
      blockName = begin[2];
      depth = 1;
      continue;
    }
    if (block !== null) {
      block.push(s);
      if (begin) depth++;
      if (end) {
        depth--;
        if (depth === 0) {
          out.push({ kind: blockKind, name: blockName.toLowerCase(), sig: block.join(" . ") });
          block = null;
        }
      }
      continue;
    }
    out.push(s);
  }
  if (block !== null)
    out.push({ kind: blockKind, name: blockName.toLowerCase(), sig: block.join(" . ") });
  return out;
}

function publicBody(file, code) {
  if (file.endsWith(".intf.abap")) {
    const m = code.match(/^\s*interface\b[\s\S]*?\.\s*$/im);
    const start = code.search(/^\s*interface\b.*?\.\s*$/im);
    const from = m ? code.indexOf(".", start) + 1 : 0;
    const to = code.search(/^\s*endinterface\b/im);
    return code.slice(from, to === -1 ? undefined : to);
  }
  const pub = code.search(/^\s*public\s+section\s*\./im);
  if (pub === -1) return "";
  const from = code.indexOf(".", pub) + 1;
  const rest = code.slice(from);
  const end = rest.search(/^\s*(protected\s+section|private\s+section|endclass)\b/im);
  return end === -1 ? rest : rest.slice(0, end);
}

/*
 * The ONE public symbol whose value is supposed to change, and does so on every
 * release: z2ui5_if_app=>version. Recorded with its literal, it makes every
 * release a "changed" finding - a rule-5 violation the release is not, and the
 * loudest possible false alarm on the one commit nobody wants noise on.
 *
 * The snapshot was created 2026-08-12; the newest tag at the time was 1.142.0
 * from 2026-07-21, so this gate had never seen a release when it was written.
 * The first one to reach it would have been told to "restore the signature".
 *
 * So the value is normalised away and the SIGNATURE is what is guarded - the
 * constant still cannot be removed, renamed or retyped. Its value already has
 * two gates of its own: check:version holds it to package.json, check:release
 * holds both to changelog.txt. A third copy here buys nothing.
 *
 * Deliberately this one symbol and no other: a constant's value is often part
 * of the contract (the cs_event names are), so nothing else is neutralised.
 */
const VERSION_CONSTANT = { file: "z2ui5_if_app.intf.abap", kind: "constants", name: "version" };

const releaseNeutral = (file, kind, name, entry) =>
  (file === VERSION_CONSTANT.file
    && kind === VERSION_CONSTANT.kind
    && name.toLowerCase() === VERSION_CONSTANT.name)
    ? entry.replace(/value\s+`[^`]*`/i, "value `<the release>`")
    : entry;

function extract() {
  const api = {};
  for (const f of fs.readdirSync(SRC02).sort()) {
    if (!f.endsWith(".intf.abap") && !f.endsWith(".clas.abap")) continue;
    if (f.endsWith(".testclasses.abap")) continue;
    const code = stripComments(fs.readFileSync(path.join(SRC02, f), "utf8"));
    const body = publicBody(f, code);
    const stmts = statements(body).flatMap(unchain);
    for (const entry of groupTypes(stmts)) {
      if (typeof entry === "object") {
        api[`${f}#${entry.kind}:${entry.name}`] = norm(entry.sig);
        continue;
      }
      const m = entry.match(KIND_RE);
      if (!m) continue; // PUBLIC SECTION noise (e.g. pragmas)
      const kind = m[0].toLowerCase().replace(/\s+/g, "-");
      const nameM = entry.slice(m[0].length).match(/^\s*:?\s*([a-z0-9_~/]+)/i);
      if (!nameM) continue;
      api[`${f}#${kind}:${nameM[1].toLowerCase()}`] = norm(releaseNeutral(f, kind, nameM[1], entry));
    }
  }
  return api;
}

const current = extract();

if (process.argv.includes("--write")) {
  fs.writeFileSync(SNAPSHOT, JSON.stringify(current, null, 2) + "\n");
  console.log(`api-snapshot: ${Object.keys(current).length} public symbols written`);
  process.exit(0);
}

if (!fs.existsSync(SNAPSHOT)) {
  console.error("api-snapshot: no snapshot found - run with --write once to create it");
  process.exit(1);
}
const snap = JSON.parse(fs.readFileSync(SNAPSHOT, "utf8"));

// Rule 5 allows one kind of signature change: a NEW OPTIONAL PARAMETER on an
// existing method ("new optional parameters" / "additive changes are allowed").
// Plain string equality cannot see that, so a compatible addition used to be
// reported as a rule-5 violation. Classify a signature that ONLY APPENDS
// optional/defaulted importing parameters - same clause order, nothing
// reordered, every other clause byte-identical - as an addition instead. Any
// other difference (a removed parameter, a changed type or default, a
// reordering, a new MANDATORY parameter) stays a violation.
// `preferred parameter x` is counted with the TRAILING clauses, not with the
// importing list: it is a modifier naming an existing parameter, not a
// parameter of its own, and it always trails the importing list. Left in the
// head it made every method that has one unable to grow an optional parameter
// - the appended parameter lands BEFORE the modifier, so the head no longer
// starts with the old head and a compatible addition was reported as a rule-5
// violation (`_event`, the first method to hit it). Changing WHICH parameter
// is preferred still differs in the tail and stays a violation.
const CLAUSE_TAIL = /(\s(?:exporting|changing|returning|raising|preferred parameter)\s[\s\S]*)$/;
function isAdditiveOptionalParams(oldSig, newSig) {
  const oldTail = oldSig.match(CLAUSE_TAIL)?.[1] ?? "";
  const newTail = newSig.match(CLAUSE_TAIL)?.[1] ?? "";
  if (oldTail !== newTail) return false;
  const oldHead = oldSig.slice(0, oldSig.length - oldTail.length);
  const newHead = newSig.slice(0, newSig.length - newTail.length);
  if (!newHead.startsWith(`${oldHead} `)) return false;
  let appended = newHead.slice(oldHead.length);
  // a method that had no importing parameter at all (parameterless, or
  // returning-only) grows its first one WITH the keyword: `methods foo` to
  // `methods foo importing x type y optional`. The keyword is no parameter,
  // so it is taken off before the per-parameter walk - which read
  // ` importing` as a parameter named importing without a type and reported
  // the first optional parameter of such a method as a rule-5 violation
  if (!/\simporting\s/.test(oldHead) && appended.startsWith(" importing ")) {
    appended = appended.slice(" importing".length);
  }
  return appendedParamsAllOptional(appended);
}

// Each appended parameter must be optional or carry a default - walked one
// parameter at a time rather than asked of the whole list at once.
//
// The list form was /^(?: [a-z_0-9]+ type .+?(?: optional| default \S+))+$/,
// which nests a lazy `.+?` inside a `+`. The two can split the same text in
// exponentially many ways, and on a signature that ALMOST matches the engine
// tries all of them before reporting failure - so a method whose parameters
// this gate cannot classify hangs the gate instead of failing it. CodeQL
// names it js/redos.
//
// Same language, one parameter per step: each must end at ` optional` or a
// default, and the next must begin where it stops.
const APPENDED_PARAM = /^ [a-z_0-9]+ type .+?(?: optional| default \S+)(?= [a-z_0-9]+ type |$)/;
function appendedParamsAllOptional(appended) {
  let rest = appended;
  if (!rest) return false;
  while (rest) {
    const m = APPENDED_PARAM.exec(rest);
    if (!m) return false;
    rest = rest.slice(m[0].length);
  }
  return true;
}

// The same rule for a public STRUCTURE TYPE: appending a component at the end
// is additive - every existing `VALUE #( a = ... )` and every field access
// still compiles, and a caller that never sets the new component gets its
// initial value. Only an APPEND counts: a removed, renamed, retyped or
// reordered component changes the meaning of code that already exists and
// stays a violation.
function isAdditiveTypeComponents(oldSig, newSig) {
  const END = / types end of [a-z_0-9]+\.?$/;
  const oldEnd = oldSig.match(END)?.[0];
  if (!oldEnd || newSig.match(END)?.[0] !== oldEnd) return false;
  const oldHead = oldSig.slice(0, oldSig.length - oldEnd.length);
  const newHead = newSig.slice(0, newSig.length - oldEnd.length);
  if (!newHead.startsWith(`${oldHead} `)) return false;
  const appended = newHead.slice(oldHead.length);
  return /^(?: types [a-z_0-9]+ type [^.]+ \.)+$/.test(appended);
}

const isAdditive = (oldSig, newSig) =>
  isAdditiveOptionalParams(oldSig, newSig) || isAdditiveTypeComponents(oldSig, newSig);

const removed = Object.keys(snap).filter((k) => !(k in current));
const differing = Object.keys(snap).filter((k) => k in current && current[k] !== snap[k]);
const changed = differing.filter((k) => !isAdditive(snap[k], current[k]));
const extended = differing.filter((k) => isAdditive(snap[k], current[k]));
const added = Object.keys(current).filter((k) => !(k in snap));

for (const k of removed) console.error(`REMOVED (rule-5 violation): ${k}\n  was: ${snap[k]}`);
for (const k of changed)
  console.error(`CHANGED (rule-5 violation): ${k}\n  was: ${snap[k]}\n  now: ${current[k]}`);
for (const k of extended)
  console.error(
    `EXTENDED additively (allowed, but unrecorded): ${k}\n  was: ${snap[k]}\n  now: ${current[k]}\n  run: node .github/scripts/api-snapshot.mjs --write  (and commit the snapshot so the addition is reviewed + guarded)`,
  );
for (const k of added)
  console.error(
    `ADDED (allowed, but unrecorded): ${k}\n  run: node .github/scripts/api-snapshot.mjs --write  (and commit the snapshot so the addition is reviewed + guarded)`,
  );

if (removed.length || changed.length || extended.length || added.length) {
  console.error(
    `api-snapshot: ${removed.length} removed, ${changed.length} changed, ${extended.length} extended, ${added.length} unrecorded - FAIL`,
  );
  process.exit(1);
}
console.log(`api-snapshot: ${Object.keys(current).length} public symbols unchanged - OK`);
