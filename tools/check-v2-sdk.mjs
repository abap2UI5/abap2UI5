#!/usr/bin/env node
/*
 * check-v2-sdk — guards the hard-coded legacy-free bootstrap pin.
 *
 * The v2 branches load UI5 from a public CDN at the version pinned in
 * app2app_v2/patch-v2.mjs (SDK constant) — the one manually bumped external
 * URL in this repo. Two failure modes, both silent until a user hits them:
 * the pinned version disappears from the CDN, or it quietly ages while newer
 * legacy-free patches ship. This check fails on the first and on a newer
 * available legacy-free version, so the monthly run surfaces both as an
 * issue (report-scheduled-failure) instead of nobody noticing.
 */
import { SDK } from "./app2app_v2/patch-v2.mjs";

const pinned = /(\d+\.\d+\.\d+)-legacy-free/.exec(SDK)?.[1];
if (!pinned) {
  console.error(`check-v2-sdk: cannot parse a pinned x.y.z-legacy-free version out of SDK constant: ${SDK}`);
  process.exit(1);
}

// 1. the pinned bootstrap must still be served
const res = await fetch(SDK, { method: "HEAD" });
if (!res.ok) {
  console.error(`check-v2-sdk: pinned bootstrap gone — HTTP ${res.status} for ${SDK}`);
  process.exit(1);
}
console.log(`check-v2-sdk: pinned ${pinned}-legacy-free is reachable`);

// 2. is a newer legacy-free version available? Scraped tolerantly from the
// SDK's version overview — if the endpoint or its shape goes away, that is
// reported as a note, not a failure (the reachability check above is the
// hard part of this gate).
const cmp = (a, b) => {
  const pa = a.split(".").map(Number);
  const pb = b.split(".").map(Number);
  for (let i = 0; i < 3; i++) if (pa[i] !== pb[i]) return pa[i] - pb[i];
  return 0;
};
try {
  const overview = await (await fetch("https://sdk.openui5.org/versionoverview.json")).text();
  const seen = [...overview.matchAll(/(\d+\.\d+\.\d+)-legacy-free/g)].map((m) => m[1]);
  const newest = [...new Set(seen)].sort(cmp).pop();
  if (!newest) {
    console.log("check-v2-sdk: note — no legacy-free versions found in versionoverview.json, skipping the newer-version check");
  } else if (cmp(newest, pinned) > 0) {
    console.error(`check-v2-sdk: newer legacy-free version available: ${newest} (pinned: ${pinned}) — bump SDK in tools/app2app_v2/patch-v2.mjs`);
    process.exit(1);
  } else {
    console.log(`check-v2-sdk: pin is current (newest legacy-free seen: ${newest})`);
  }
} catch (e) {
  console.log(`check-v2-sdk: note — version overview not readable (${e.message}), skipping the newer-version check`);
}
