// Gate: the default CSP allows only the UI5 CDN hosts, and script-src never
// carries data:/blob:.
//
// SECURITY.md makes both claims in prose ("the default CSP allows only the
// UI5 CDN hosts, nothing else"), and z2ui5_cl_ui5_user_exit is where they are
// either true or not: set_config_http_get builds the host list (lv_ui5_hosts)
// and the content_security_policy string (gv_csp_default) from it. General-purpose CDNs
// (jsdelivr, cdnjs) used to ride along in that policy although nothing the
// framework ships loads from them - every allowed script host is a host whose
// compromise is script execution in an authenticated SAP session - and
// nothing but a reader held the tightened list tight. The same source's own
// comment explains the second claim: a data: that reaches script-src is a
// textbook CSP bypass (any HTML-injection foothold escalates via
// <script src="data:...">), which is why script-src is explicit rather than
// left to the default-src fallback that carries data:/blob: for images.
//
// So this gate reads the ABAP textually (the way draft-owner-gate reads its
// source) and holds three things:
//
//   1. every source in lv_ui5_hosts is one of the REVIEWED UI5 CDN hosts -
//      a new host is one line here and a look, which is the whole ratchet
//   2. every external host token in the default policy comes from
//      lv_ui5_hosts (the two legacy `schemas` tokens are named exceptions,
//      confined to non-script directives; the list only shrinks)
//   3. script-src is an explicit directive, and every `scheme:` source stands
//      in a directive that is listed for it - script-src is in no such list
//
// If the anchors stop matching, the gate has to learn the new spelling rather
// than pass silently on a grep that matches nothing.

import { fileURLToPath } from "url";
import { readFileSync } from "fs";
import { join } from "path";

const ROOT = fileURLToPath(new URL("../../", import.meta.url));
const SOURCE = "src/01/04/z2ui5_cl_ui5_user_exit.clas.abap";

/* The UI5 CDN host families the default installation may bootstrap from or
 * fall back to - the reviewed list behind SECURITY.md's "only the UI5 CDN
 * hosts". A host that is not one of these does not belong in lv_ui5_hosts;
 * an exit that needs another host adds it in the exit, to the one directive
 * that needs it. */
const UI5_HOSTS = new Set([
  "ui5.sap.com", "*.ui5.sap.com",
  "sapui5.hana.ondemand.com", "*.sapui5.hana.ondemand.com",
  "openui5.hana.ondemand.com", "*.openui5.hana.ondemand.com",
  "sdk.openui5.org", "*.sdk.openui5.org",
]);

/* Host tokens in the shipped policy that are NOT UI5 CDN hosts. Every entry
 * is a decision somebody recorded once, with the directives it may appear in
 * - never script-src. The two `schemas` tokens predate the host tightening
 * and survived it; whether they still earn their place is a question for the
 * ABAP side, and removing them there removes them here in the same change. */
const LEGACY_TOKENS = new Map([
  ["schemas", ["default-src"]],
  ["*.schemas", ["default-src"]],
]);

/* Which directive may carry which `scheme:` source, closed and per directive.
 * The test used to be the open regex `^[a-z][a-z0-9+.-]*:$` with one exception
 * for script-src, which passed ANY scheme anywhere else: `connect-src 'self'
 * https:` allows the authenticated session to talk to every host on the
 * internet, and `style-src https:` is a step from there - both green in a gate
 * SECURITY.md names as the holder of "only the UI5 CDN hosts". A scheme source
 * is a wildcard over hosts, so it belongs in the same closed list the hosts
 * themselves are in.
 *
 * The two entries are what the SHIPPED default needs today and nothing else:
 * default-src carries data:/blob: for images, fonts and media, and worker-src
 * carries blob: because that is how a UI5 worker is started. A new one is a
 * line here and a look - the ratchet the host list already has. */
const SCHEME_SOURCES = new Map([
  ["default-src", new Set(["data:", "blob:"])],
  ["worker-src", new Set(["blob:"])],
]);

const abap = readFileSync(join(ROOT, SOURCE), "utf8");
const lines = abap.split("\n");
const problems = [];

/* Collect the pieces of one ABAP statement: from its anchor line to the line
 * whose code part ends the statement with `.`, skipping full-line comments. */
function statementLines(anchor) {
  const at = lines.findIndex((l) => l.includes(anchor));
  if (at === -1) return null;
  const out = [];
  for (let i = at; i < lines.length; i++) {
    const t = lines[i].trim();
    if (t.startsWith(`"`)) continue;
    out.push(lines[i]);
    if (/\.\s*$/.test(t)) break;
  }
  return out;
}

// --- 1. the host list ------------------------------------------------------

const hostStmt = statementLines("DATA(lv_ui5_hosts) =");
if (!hostStmt) {
  console.log(`csp-default: the lv_ui5_hosts anchor no longer matches in ${SOURCE}`);
  console.log("");
  console.log("The host list moved or was renamed. Teach this gate the new spelling -");
  console.log("an anchor that matches nothing would let the policy drift silently.");
  process.exit(1);
}
const declaredHosts = [];
for (const line of hostStmt) {
  for (const m of line.matchAll(/`([^`]*)`/g)) {
    declaredHosts.push(...m[1].split(/\s+/).filter(Boolean));
  }
}
for (const host of declaredHosts) {
  if (!UI5_HOSTS.has(host)) {
    problems.push(
      `lv_ui5_hosts names \`${host}\`, which is not a reviewed UI5 CDN host\n`
      + "    if it IS one: add it to UI5_HOSTS in this gate, with a look at what it serves\n"
      + "    if it is not: it does not belong in the DEFAULT policy - an exit adds it,\n"
      + "    to the one directive that needs it (SECURITY.md, \"the default CSP allows\n"
      + "    only the UI5 CDN hosts\")",
    );
  }
}

// --- 2. + 3. the policy ----------------------------------------------------

/* The policy is assembled once per roll area into the class-side
 * gv_csp_default (set_config_http_get runs on every request, and the string
 * is a constant), and cs_config-content_security_policy is then assigned
 * from it - so the statement that CARRIES the template is the constant's. */
const cspStmt = statementLines("gv_csp_default =");
if (!cspStmt) {
  console.log(`csp-default: the content_security_policy anchor no longer matches in ${SOURCE}`);
  console.log("");
  console.log("The default policy moved or was renamed. Teach this gate the new spelling -");
  console.log("an anchor that matches nothing would let the policy drift silently.");
  process.exit(1);
}
const template = cspStmt
  .map((l) => l.match(/\|(.*)\|/)?.[1] ?? "")
  .join("")
  .replace(/\{\s*lv_ui5_hosts\s*\}/g, "@UI5_HOSTS@");
const content = template.match(/content="([^"]*)"/)?.[1];
if (!content) {
  console.log(`csp-default: found the policy statement but no content="..." inside it in ${SOURCE}`);
  console.log("");
  console.log("Teach this gate the new shape of the policy string.");
  process.exit(1);
}

const directives = content.split(";").map((d) => d.trim()).filter(Boolean);
const seenLegacy = new Set();
const seenScheme = new Set();
let sawScriptSrc = false;

for (const directive of directives) {
  const [name, ...sources] = directive.split(/\s+/);
  if (name === "script-src") sawScriptSrc = true;
  for (const token of sources) {
    if (/^'.*'$/.test(token)) continue; // 'self', 'none', the unsafe-* keywords
    if (token === "@UI5_HOSTS@") continue; // the reviewed list, checked above
    if (/^[a-z][a-z0-9+.-]*:$/.test(token)) {
      // a scheme source (data:, blob:, and everything else a scheme can be).
      // Allowed only where SCHEME_SOURCES lists it: a scheme is a wildcard
      // over hosts, so an unlisted one is the host claim broken by another
      // spelling
      if (name === "script-src") {
        problems.push(
          `script-src carries \`${token}\` - a scheme source turns any HTML-injection\n`
          + "    foothold into script execution (<script src=\"data:...\">). It must not\n"
          + "    be there, which is why script-src is explicit rather than left to the\n"
          + "    default-src fallback that carries data:/blob: for images.",
        );
        continue;
      }
      const schemes = SCHEME_SOURCES.get(name);
      if (!schemes || !schemes.has(token)) {
        problems.push(
          `${name} carries the scheme source \`${token}\`, which is not listed for it\n`
          + `    ${schemes ? `only ${[...schemes].join(", ")} are listed here` : "no scheme source is listed for this directive"}\n`
          + "    A scheme is a wildcard over every host that speaks it - `connect-src\n"
          + "    https:` reaches the whole internet from an authenticated SAP session,\n"
          + "    which is the claim SECURITY.md makes about the DEFAULT policy (\"only the\n"
          + "    UI5 CDN hosts\") in another spelling. If the shipped default genuinely\n"
          + "    needs it: add it to SCHEME_SOURCES in this gate, with a look at what it\n"
          + "    opens. An installation that needs it adds it in its exit instead.",
        );
        continue;
      }
      seenScheme.add(`${name} ${token}`);
      continue;
    }
    // an external host token written directly into the policy
    const allowedIn = LEGACY_TOKENS.get(token);
    if (allowedIn) {
      seenLegacy.add(token);
      if (!allowedIn.includes(name)) {
        problems.push(
          `\`${token}\` appears in ${name}, but its exception covers only: ${allowedIn.join(", ")}\n`
          + "    a legacy token does not spread to new directives - least of all script-src",
        );
      }
      continue;
    }
    problems.push(
      `${name} names the host \`${token}\` outside lv_ui5_hosts\n`
      + "    every external host in the default policy comes from that one list\n"
      + "    (SECURITY.md). A host an installation needs is added by its exit,\n"
      + "    to the one directive that needs it - not to the shipped default.",
    );
  }
}

if (!sawScriptSrc) {
  problems.push(
    "the policy has no explicit script-src directive\n"
    + "    without it, default-src is the fallback for scripts - and default-src\n"
    + "    carries data:/blob: for images and fonts, which is the exact bypass\n"
    + "    the explicit split exists to prevent (see the comment in the source)",
  );
}

/* An exception nothing uses any more is a claim about the policy that has
 * stopped being true, and the next reader takes it for evidence. */
for (const token of LEGACY_TOKENS.keys()) {
  if (!seenLegacy.has(token)) {
    problems.push(
      `LEGACY_TOKENS lists \`${token}\`, but the policy no longer carries it - drop the entry`,
    );
  }
}
for (const [name, schemes] of SCHEME_SOURCES) {
  for (const token of schemes) {
    if (!seenScheme.has(`${name} ${token}`)) {
      problems.push(
        `SCHEME_SOURCES allows \`${token}\` in ${name}, but the policy no longer carries it\n`
        + "    - drop the entry, so the list stays what the default policy actually needs",
      );
    }
  }
}

if (problems.length) {
  console.log(`csp-default: ${problems.length} problem(s) with the default CSP in ${SOURCE}:`);
  console.log("");
  for (const p of problems) console.log(`  ${p}`);
  process.exit(1);
}

console.log(
  `csp-default: ${declaredHosts.length} UI5 CDN host(s), ${directives.length} directive(s), `
  + `${seenScheme.size} listed scheme source(s), script-src explicit and free of them - OK`,
);
