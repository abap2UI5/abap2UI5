#!/usr/bin/env node
// docs/agents/building-apps.md is the canonical, offline app-building
// reference — the one an agent without web access reads instead of the docs
// site. A method or constant it names that the API does not have sends every
// reader down the same wrong path, and prose cannot be trusted to age with
// the interface. So: every `client-><method>` and every `cs_event-` /
// `cs_view-` / `cs_nav_mode-` constant the guide mentions must exist in
// src/02/z2ui5_if_client.intf.abap.
//
// This checks that the names EXIST, not that the surrounding prose is right —
// the parameter names and semantics still need a human (or a careful agent).
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const ROOT = path.join(path.dirname(fileURLToPath(import.meta.url)), "..", "..");
const INTF = path.join(ROOT, "src", "02", "z2ui5_if_client.intf.abap");
const GUIDE = path.join(ROOT, "docs", "agents", "building-apps.md");

const intf = fs.readFileSync(INTF, "utf8");
const guide = fs.readFileSync(GUIDE, "utf8");

const methods = new Set(
  [...intf.matchAll(/^\s*METHODS\s+(\w+)/gim)].map((m) => m[1].toLowerCase()),
);
const constantsIn = (block) =>
  [...(intf.match(new RegExp(`BEGIN OF ${block}[\\s\\S]*?END OF ${block}`)) || [""])[0]
    .matchAll(/(\w+)\s+TYPE string VALUE/g)].map((m) => m[1].toLowerCase());
const constants = {
  "cs_event-": new Set(constantsIn("cs_event")),
  "cs_view-": new Set(constantsIn("cs_view")),
  "cs_nav_mode-": new Set(constantsIn("cs_nav_mode")),
};

const problems = [];

for (const m of guide.matchAll(/client->(\w+)/g)) {
  if (!methods.has(m[1].toLowerCase())) problems.push(`client->${m[1]} — no such method`);
}
for (const [prefix, known] of Object.entries(constants)) {
  for (const m of guide.matchAll(new RegExp(`${prefix}(\\w+)`, "g"))) {
    if (!known.has(m[1].toLowerCase())) problems.push(`${prefix}${m[1]} — no such constant`);
  }
}

// The other direction. The check above is one-way - it asks whether what the
// guide NAMES exists - so a method added to the interface and never written up
// is invisible to it. That is the direction that actually bit: `_bind_path( )`
// and the `arg` shorthand shipped in 1.144.0 and reached the changelog, the
// interface and the api snapshot, while the file every agent without web
// access reads as the API reference did not mention them at all, and nothing
// said so.
//
// A method is either named in the guide or recorded here with the reason it is
// not. Same shape as agents-commands-gate's declared omissions - the point is
// that leaving a method out becomes a decision somebody wrote down, instead of
// the default.
const UNDOCUMENTED = new Map([
  ["view_model_update", "obsolete - view_display( ) re-sends the model"],
  ["popup_model_update", "obsolete, as view_model_update"],
  ["popover_model_update", "obsolete, as view_model_update"],
  ["nest_view_model_update", "obsolete, as view_model_update"],
  ["nest2_view_model_update", "obsolete, as view_model_update"],
  ["_bind_edit", "compatibility-only alias of _bind( ), slated for removal"],
  ["_event_nav_app_leave", "internal wiring of nav_app_leave( )"],
  [
    "nest_view_display",
    "the nested-view family is named in section 7 as a capability; the per-slot"
      + " methods follow view_display( ) exactly and would repeat it five times",
  ],
  ["nest_view_destroy", "as nest_view_display"],
  ["nest2_view_display", "as nest_view_display"],
  ["nest2_view_destroy", "as nest_view_display"],
  ["view_destroy", "as nest_view_display - the slot form of popup_destroy( )"],
  ["popover_destroy", "as nest_view_display"],
  ["set_push_state", "browser-history detail of the routing block in section 7"],
  // These four SHOULD be in the guide, and the text for them is written. It is
  // not here yet because this file is mirrored into abap2UI5/app-template's
  // AGENTS.md, which generates its copy with `npm run agents` - so editing it
  // fails `npm run check:shared` until that regeneration lands, which is what
  // it did on main between #2685 and this change. The guide edit and the
  // app-template regeneration are one change, made when both repositories can
  // be touched. Drop these four entries then; the check below asks for them
  // again the moment somebody does.
  ["_bind_path", "PENDING the app-template mirror sync - named form of _bind( path = abap_true )"],
  ["get", "PENDING the app-template mirror sync - the request context, incl. t_model_skipped"],
  ["set_app_state_active", "PENDING the app-template mirror sync - the bookmarkable app-state hash"],
  ["set_session_stateful", "PENDING the app-template mirror sync - the sticky-session switch"],
  ["get_app", "reaches another app instance on the stack - get_app_prev( ) is the documented case"],
  ["check_app_prev_stack", "a stack predicate for get_app_prev( ), documented through it"],
]);

for (const m of methods) {
  if (UNDOCUMENTED.has(m)) continue;
  if (new RegExp(`client->${m}\\b`, "i").test(guide)) continue;
  problems.push(
    `client->${m} — on z2ui5_if_client but nowhere in the guide.`
      + " Document it, or record why not in UNDOCUMENTED in this script",
  );
}
for (const m of UNDOCUMENTED.keys()) {
  if (!methods.has(m)) {
    problems.push(`UNDOCUMENTED names client->${m}, which is not on the interface — drop the entry`);
  }
}

const unique = [...new Set(problems)];
if (unique.length) {
  console.error("check-guide-api: docs/agents/building-apps.md names API that does not exist:");
  for (const p of unique) console.error(`  ${p}`);
  console.error(
    "\nFix the guide (and docs/agents is mirrored into abap2UI5/app-template's AGENTS.md — " +
      "re-sync it there too).",
  );
  process.exit(1);
}
console.log(
  `check-guide-api: ${methods.size} client method(s) - every one the guide names exists, `
  + `and every one on the interface is documented or recorded (${UNDOCUMENTED.size} recorded) - OK`,
);
