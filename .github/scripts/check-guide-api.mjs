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
  `check-guide-api: every client method and cs_* constant the guide names exists (${methods.size} methods known) - OK`,
);
