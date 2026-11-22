#!/usr/bin/env node
/*
 * generate-linter-manifest — the closed sets the abap2UI5 linter mirrors,
 * written down by the repository that owns them.
 *
 * @abap2ui5/linter judges an app against sets that are defined HERE: the
 * frontend action whitelists (core/actions/*.js), the curated formatters, the
 * companion controls and their properties, the events of z2ui5_if_client, the
 * message box types, and which objects are released, frozen or internal. It
 * has always found them by parsing this repository from the outside -
 * regular expressions over the generated src/01/03 classes, kept in the
 * linter - and that is the wrong side for the knowledge to live on:
 *
 *   - a module split here (the action JS, one class -> one per group) left
 *     the linter reading a file that defined none of the sets;
 *   - `ct_box_type` moving from z2ui5_cl_ui5_frontend to
 *     z2ui5_cl_ui5_srv_message made it report all seven box types as "gone
 *     upstream";
 *   - and in both cases the change was green here and wrong there, days later.
 *
 * So the direction is turned round. This script reads the sets from their
 * SOURCES - bundle/webapp for everything that is JavaScript, never the embedded
 * copy - and writes them as one JSON file, `.github/shared/linter-manifest.json`.
 * The linter reads that file (`check-upstream --manifest`) instead of finding
 * the sets itself. A layout change is then a change to THIS script, made in
 * the pull request that moves the source, and `--check` fails that pull
 * request while the committed manifest is stale.
 *
 * The shape is the linter's `deriveUpstream( )` (its scripts/check-upstream.mjs,
 * MANIFEST_SCHEMA): the two are meant to be equal for the same tree, and
 * `check:mirrors` (linter-mirror-gate.mjs) is what still compares the linter's
 * own reading against the working tree while both exist.
 *
 * A set this script cannot find is an ERROR, not an empty list: an empty list
 * in the manifest would tell the linter "upstream has none" and it would
 * report every correct use. REQUIRED below names the sets that may not be
 * empty.
 *
 *   node .github/scripts/generate-linter-manifest.mjs          write the manifest (npm run linter-manifest)
 *   node .github/scripts/generate-linter-manifest.mjs --check  fail if stale     (npm run check:linter-manifest)
 *
 * The readers are exported and tested by generate-linter-manifest.test.mjs
 * (npm run check:linter-manifest-readers) - the cases the linter's own
 * parsers were tested with before they moved here.
 */
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..", "..");
const OUT = path.join(ROOT, ".github", "shared", "linter-manifest.json");
const CHECK = process.argv.includes("--check");

/* The linter's MANIFEST_SCHEMA. Raised there and here together, when a key
 * changes its meaning or goes away - a new key is not a new version. */
const SCHEMA = 1;


/* ── where each set lives ─────────────────────────────────────────────── */

const FORMATTER = "bundle/webapp/model/formatter.js";
const CLIPBOARD = "bundle/webapp/model/clipboard.js";
const ACTIONS_DIR = "bundle/webapp/core/actions";
const CC_DIR = "bundle/webapp/cc";
const CLIENT_INTF = "src/02/z2ui5_if_client.intf.abap";
/* `ct_box_type` - the MessageBox display methods box_resolve( ) accepts. */
const BOX_TYPES = "src/01/02/z2ui5_cl_ui5_srv_message.clas.abap";
/* The frozen builder's companion-control helpers (one method per control). */
const XML_VIEW_CC = "src/99/z2ui5_cl_xml_view_cc.clas.abap";

/* ── small readers ────────────────────────────────────────────────────── */

/* The text between the brace at `open` and its partner. */
export function braceRegion(src, open) {
  let depth = 0;
  for (let i = open; i < src.length; i++) {
    if (src[i] === "{") depth++;
    else if (src[i] === "}" && --depth === 0) return src.slice(open + 1, i);
  }
  return src.slice(open + 1);
}

/* `//` comments dropped (`://` of a URL is not a comment start): a comment
 * documenting a payload shape carries `word:` pairs that are no keys. */
const noLineComments = (text) => text.replace(/(^|[^:])\/\/[^\n]*/g, "$1");

/* Where `const NAME =` is DECLARED: at the start of a line. The sources
 * also name these constants in comments ("`const GLOBAL_TARGETS = {` in the
 * embedded carrier"), and a plain search would be free to land on one. */
export function declarationOf(src, name) {
  const m = new RegExp(`^[ \\t]*const ${name} = `, "m").exec(src);
  return m ? m.index + m[0].length : -1;
}

const quoted = (text) => [...text.matchAll(/["'`]([^"'`]+)["'`]/g)].map((m) => m[1]);

/* The top-level keys of an object literal's body. */
export function objectKeys(body) {
  const out = [];
  let depth = 0;
  const re = /([A-Za-z_$][\w$]*)\s*:|[{}]/g;
  let m;
  const code = noLineComments(body);
  while ((m = re.exec(code)) !== null) {
    if (m[0] === "{") depth++;
    else if (m[0] === "}") depth--;
    else if (depth === 0) out.push(m[1]);
  }
  return out;
}

/* ── the sets ─────────────────────────────────────────────────────────── */

/* The exports of a formatter-style module: its object literal's shorthand
 * methods, which the modules write at four spaces. */
export function moduleExports(src) {
  return [...src.matchAll(/^ {4}(\w+)\((?:[^)]*)\)?\s*\{?/gm)]
    .map((m) => m[1])
    .filter((n) => !["function", "if", "for", "while", "return", "switch"].includes(n));
}

export function boxTypes(abap) {
  const at = abap.search(/\bct_box_type\s*=\s*VALUE\s+#\s*\(/i);
  if (at === -1) return [];
  const open = abap.indexOf("(", abap.indexOf("#", at));
  let depth = 0;
  let end = open;
  for (; end < abap.length; end++) {
    if (abap[end] === "(") depth++;
    else if (abap[end] === ")" && --depth === 0) break;
  }
  return [...abap.slice(open + 1, end).matchAll(/\(\s*[`']([a-z]+)[`']\s*\)/gi)].map((m) => m[1]);
}

/* Every VALUE of `z2ui5_if_client=>cs_event` - the names an app may wire. */
export function clientEvents(intf) {
  const m = intf.match(/BEGIN OF cs_event\b([\s\S]*?)\bEND OF cs_event\b/i);
  if (!m) return [];
  const code = m[1].split("\n").map((line) => line.replace(/^\s*".*$/, "")).join("\n");
  return [...new Set([...code.matchAll(/\bVALUE\s+(?:`([^`]+)`|'([^']+)')/gi)].map((x) => x[1] ?? x[2]))];
}

/* One companion control: its properties and events (the keys of the
 * metadata literals), the module it extends (the sap.ui.define dependency
 * behind the parameter `.extend("z2ui5.cc.…")` is called on), and its
 * `// OBSOLETE: …` header where it has one. */
export function companionControl(src) {
  const propsAt = src.search(/properties\s*:\s*\{/);
  const properties = propsAt === -1 ? [] : objectKeys(braceRegion(src, src.indexOf("{", propsAt)));
  let events = [];
  const metaAt = src.search(/metadata\s*:\s*\{/);
  if (metaAt !== -1) {
    const metadata = braceRegion(src, src.indexOf("{", metaAt));
    const eventsAt = metadata.search(/\bevents\s*:\s*\{/);
    if (eventsAt !== -1) events = objectKeys(braceRegion(metadata, metadata.indexOf("{", eventsAt)));
  }
  const obsolete = src.match(/^[ \t]*\/\/[ \t]*OBSOLETE:[ \t]*(.+)$/m)?.[1].trim() ?? null;
  return { properties, events, base: baseOf(src), obsolete };
}

export function baseOf(src) {
  const define = src.indexOf("sap.ui.define(");
  const open = define === -1 ? -1 : src.indexOf("[", define);
  const close = open === -1 ? -1 : src.indexOf("]", open);
  const paramsOpen = close === -1 ? -1 : src.indexOf("(", close);
  const paramsClose = paramsOpen === -1 ? -1 : src.indexOf(")", paramsOpen);
  if (paramsClose === -1) return null;
  const deps = quoted(src.slice(open + 1, close));
  const params = src.slice(paramsOpen + 1, paramsClose).split(",").map((p) => p.trim()).filter(Boolean);
  for (let at = src.indexOf(".extend(", paramsClose); at !== -1; at = src.indexOf(".extend(", at + 1)) {
    let start = at;
    while (start > 0 && /[\w$]/.test(src[start - 1])) start--;
    let arg = at + ".extend(".length;
    while (arg < src.length && /\s/.test(src[arg])) arg++;
    if ((src[arg] !== '"' && src[arg] !== "'") || !src.startsWith("z2ui5.cc.", arg + 1)) continue;
    const i = params.indexOf(src.slice(start, at));
    return i === -1 ? null : deps[i] ?? null;
  }
  return null;
}

/* helper method -> the control its `_generic( name = … ns = `z2ui5` )` writes */
export function frozenBuilderHelpers(abap) {
  const out = {};
  for (const m of abap.matchAll(/^\s*METHOD\s+(\w+)\s*\.([\s\S]*?)^\s*ENDMETHOD\s*\./gim)) {
    const call = m[2].match(/_generic\s*\(([\s\S]*?)\)/i);
    if (!call) continue;
    const name = call[1].match(/\bname\s*=\s*`(\w+)`/i);
    const ns = call[1].match(/\bns\s*=\s*`(\w+)`/i);
    if (name && ns && ns[1].toLowerCase() === "z2ui5") out[m[1].toLowerCase()] = name[1];
  }
  return out;
}

/* package -> the abapGit objects in it, from the file names under src/. */
export function objectsByPackage(root = ROOT) {
  const out = {};
  const walk = (rel) => {
    for (const e of fs.readdirSync(path.join(root, rel), { withFileTypes: true }).sort((a, b) => (a.name < b.name ? -1 : 1))) {
      if (e.isDirectory()) { walk(`${rel}/${e.name}`); continue; }
      if (e.name.includes(".testclasses.")) continue;
      const m = e.name.match(/^(z2ui5_\w+)\.(?:clas|intf)\.abap$/) || e.name.match(/^(z2ui5_\w+)\.(?:tabl|dtel|doma|ddls|enqu)\.xml$/);
      if (m) (out[rel] ??= []).push(m[1].toLowerCase());
    }
  };
  walk("src");
  return out;
}

/* NAME: { …, methods: { a: …, b: … } } for every entry of GLOBAL_TARGETS */
export function globalTargets(js) {
  const out = {};
  const at = declarationOf(js, "GLOBAL_TARGETS");
  if (at === -1) return out;
  const body = braceRegion(js, js.indexOf("{", at));
  const entryRe = /([A-Z][A-Z0-9_]*)\s*:\s*\{/g;
  let m;
  while ((m = entryRe.exec(body)) !== null) {
    const open = body.indexOf("{", m.index + m[0].length - 1);
    const entry = braceRegion(body, open);
    const methodsAt = entry.search(/methods\s*:\s*\{/);
    if (methodsAt !== -1) {
      const methods = noLineComments(braceRegion(entry, entry.indexOf("{", methodsAt)));
      out[m[1]] = [...methods.matchAll(/(\w+)\s*:/g)].map((x) => x[1]);
    }
    entryRe.lastIndex = open + entry.length + 2; // never match inside the entry
  }
  return out;
}

/* `const NAME = [ … ];` - the string literals of an array (a Set built from
 * one too: `new Set([ … ])`), comments dropped. */
export function stringList(js, name, terminator = "]") {
  const at = declarationOf(js, name);
  if (at === -1) return [];
  const end = js.indexOf(terminator, at);
  return end === -1 ? [] : quoted(noLineComments(js.slice(at, end)));
}

/* the shorthand-method DEFINITIONS of BINDING_METHODS (`filter(binding, …) {`) */
export function bindingMethods(js) {
  const at = declarationOf(js, "BINDING_METHODS");
  if (at === -1) return [];
  const body = braceRegion(js, js.indexOf("{", at));
  return [...body.matchAll(/(\w+)\s*\(\s*binding\b[^)]*\)\s*\{/g)].map((m) => m[1]);
}

/* the keys of EVERY `const handlers = { … }` - one dispatch table per module */
export function frontendEvents(js) {
  const out = [];
  for (const m of js.matchAll(/^[ \t]*const handlers = \{/gm)) {
    const body = braceRegion(js, m.index + m[0].length - 1);
    out.push(...[...body.matchAll(/^\s*([A-Z][A-Z0-9_]*)\s*:/gm)].map((x) => x[1]));
  }
  return [...new Set(out)];
}

/* an object literal's UPPER_CASE keys, one per line */
export function upperKeys(js, name) {
  const at = declarationOf(js, name);
  if (at === -1) return [];
  const body = braceRegion(js, js.indexOf("{", at));
  return [...body.matchAll(/^\s*([A-Z][A-Z0-9_]*)\s*:/gm)].map((m) => m[1]);
}

export function urlHelperActions(js) {
  const fn = /^[ \t]*function evUrlHelper\b/m.exec(js);
  if (!fn) return [];
  const body = braceRegion(js, js.indexOf("{", fn.index));
  const at = body.indexOf("actions = {");
  if (at === -1) return [];
  return [...braceRegion(body, body.indexOf("{", at)).matchAll(/^\s*([A-Z][A-Z0-9_]*)\s*:/gm)].map((m) => m[1]);
}

/* method -> the kinds of its arguments, from CONTROL_METHODS */
export function controlMethodKinds(js) {
  const at = declarationOf(js, "CONTROL_METHODS");
  if (at === -1) return {};
  const body = braceRegion(js, js.indexOf("{", at));
  const out = {};
  for (const m of body.matchAll(/^\s*(\w+)\s*:\s*\[([^\]]*)\]/gm)) out[m[1]] = quoted(m[2]);
  return out;
}

export function shortcutAliases(js) {
  const at = declarationOf(js, "SHORTCUT_ALIASES");
  if (at === -1) return {};
  const body = braceRegion(js, js.indexOf("{", at));
  const out = {};
  for (const m of body.matchAll(/(\w+)\s*:\s*["'`]([^"'`]*)["'`]/g)) out[m[1]] = m[2];
  return out;
}

/* ── the manifest ─────────────────────────────────────────────────────── */

/** The manifest of the tree at `root` (this repository by default). */
export function buildManifest(root = ROOT) {
  const read = (rel) => fs.readFileSync(path.join(root, rel), "utf8");
  const exists = (rel) => fs.existsSync(path.join(root, rel));
  const filesIn = (rel, re) => fs.readdirSync(path.join(root, rel)).filter((n) => re.test(n)).sort();
  const actions = filesIn(ACTIONS_DIR, /\.js$/).map((n) => read(`${ACTIONS_DIR}/${n}`)).join("\n");
  return {
    schema: SCHEMA,
    formatters: moduleExports(read(FORMATTER)),
    clipboardCallbacks: exists(CLIPBOARD) ? moduleExports(read(CLIPBOARD)) : [],
    messageBoxTypes: boxTypes(read(BOX_TYPES)),
    clientEvents: clientEvents(read(CLIENT_INTF)),
    companionControls: Object.fromEntries(filesIn(CC_DIR, /^\w+\.js$/).map((n) => [n.replace(/\.js$/, ""), companionControl(read(`${CC_DIR}/${n}`))])),
    frozenBuilderHelpers: exists(XML_VIEW_CC) ? frozenBuilderHelpers(read(XML_VIEW_CC)) : null,
    objects: objectsByPackage(root),
    globalTargets: globalTargets(actions),
    cssProperties: stringList(actions, "CSS_PROPERTIES", "];"),
    controlMethodDenyExact: stringList(actions, "CONTROL_METHOD_DENY_EXACT", "];"),
    controlMethodDenyPrefixes: stringList(actions, "CONTROL_METHOD_DENY_PREFIXES", "];"),
    bindingMethods: bindingMethods(actions),
    frontendEvents: frontendEvents(actions),
    filterOperators: stringList(actions, "FILTER_OPERATORS"),
    viewSlots: stringList(actions, "SHORTCUT_SLOTS"),
    shortcutModifiers: stringList(actions, "SHORTCUT_MODIFIERS"),
    shortcutAliases: shortcutAliases(actions),
    urlHelperActions: urlHelperActions(actions),
    controlMethodKinds: controlMethodKinds(actions),
    urlPolicies: upperKeys(actions, "URL_POLICIES"),
  };
}

/* The sets that may not come out empty: each exists today, and an empty one
 * means its source moved or changed shape - which is this script's to fix,
 * not something to hand the linter as "upstream has none". */
export const REQUIRED = [
  "formatters", "messageBoxTypes", "clientEvents", "companionControls", "objects", "globalTargets",
  "cssProperties", "controlMethodDenyExact", "controlMethodDenyPrefixes", "bindingMethods", "frontendEvents",
  "filterOperators", "viewSlots", "shortcutModifiers", "shortcutAliases", "urlHelperActions",
  "controlMethodKinds", "urlPolicies",
];

/** What is wrong with a manifest before it may be written: the required sets
 *  that came out empty, and the companion controls whose base is unreadable. */
export function problemsOf(manifest) {
  return [
    ...REQUIRED.filter((key) => !Object.keys(manifest[key] ?? {}).length)
      .map((key) => `found nothing for '${key}' - its source moved or changed shape; fix the reader in .github/scripts/generate-linter-manifest.mjs`),
    ...Object.entries(manifest.companionControls ?? {}).filter(([, cc]) => cc.base === null)
      .map(([name]) => `cannot read what ${CC_DIR}/${name}.js extends - the sap.ui.define / .extend shape changed`),
  ];
}

const invokedDirectly = process.argv[1] && fs.realpathSync(process.argv[1]) === fileURLToPath(import.meta.url);
if (invokedDirectly) {
  const manifest = buildManifest();
  const problems = problemsOf(manifest);
  if (problems.length) {
    for (const p of problems) console.error(`linter-manifest: ${p}`);
    process.exit(1);
  }
  const text = `${JSON.stringify(manifest, null, 2)}\n`;
  const rel = path.relative(ROOT, OUT).split(path.sep).join("/");

  if (CHECK) {
    const committed = fs.existsSync(OUT) ? fs.readFileSync(OUT, "utf8") : null;
    if (committed === text) {
      console.log(`linter-manifest: ${rel} matches the sources (${REQUIRED.length} sets, ${Object.keys(manifest.companionControls).length} companion controls)`);
      process.exit(0);
    }
    console.error(`linter-manifest: ${rel} is ${committed === null ? "missing" : "stale"} - a set the linter mirrors changed.`);
    if (committed !== null) {
      let was = {};
      try { was = JSON.parse(committed); } catch { /* reported as stale */ }
      for (const key of Object.keys(manifest)) {
        if (JSON.stringify(was[key]) !== JSON.stringify(manifest[key])) console.error(`  changed: ${key}`);
      }
    }
    console.error("Run `npm run linter-manifest` and commit the file: the linter reads it, so the change reaches it with this pull request.");
    process.exit(1);
  }

  fs.writeFileSync(OUT, text);
  console.log(`linter-manifest: wrote ${rel}`);
}
