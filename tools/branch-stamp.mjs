#!/usr/bin/env node
// branch-stamp.mjs
// Die Provenienz eines Delivery-Branches: der Core-Commit, aus dem er gebaut
// wurde, und die Framework-Version dazu - im README-Banner und in VERSION.
//
// Warum das ein eigener Schritt ist und nicht Teil des Builds: seit build/ im
// Repository liegt, wird der Baum eines Branches COMMITTET, bevor es den
// Commit gibt, den er nennen soll. Ein Stempel im gebauten Baum waere damit
// entweder unmoeglich (der eigene Commit) oder immer einen Commit alt.
//
// Also baut build-branches.mjs den Inhalt - deterministisch, ohne Commit, ohne
// Zeitstempel, deshalb ueberhaupt einchecken - und dieses Skript stempelt
// unmittelbar vor dem Push:
//
//     node tools/branch-stamp.mjs <dir> <branch> [sha]
//
// <dir> ist der fertige Baum (build/<branch> oder tools/out/<branch>), <sha>
// der Core-Commit; ohne Argument GITHUB_SHA, sonst HEAD. Ohne ermittelbaren
// Commit bleibt die Herkunftsangabe weg statt falsch zu sein.
//
// Was ein gepulltes Repository sieht, aendert sich dadurch nicht: README und
// VERSION tragen denselben Text wie vorher, er entsteht nur einen Schritt
// spaeter. Deliberately no timestamp - identische Quellen muessen identische
// Baeume ergeben, sonst pusht frontend_deploy.yaml bei jedem Lauf einen
// leeren Rebuild.

import { execFileSync } from "node:child_process";
import { readFileSync, writeFileSync } from "node:fs";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const here = dirname(fileURLToPath(import.meta.url));
const core = join(here, "..");

// Erste Zeile jedes generierten README. build-branches.mjs schreibt sie ohne
// Herkunftsangabe, dieses Skript ersetzt sie durch dieselbe Zeile mit.
export const BANNER_PREFIX = "> ⚙️ **Generated branch";

export function banner(branch, { sha = null, version = null } = {}) {
  const origin = sha
    ? ` Frontend state: \`abap2UI5/abap2UI5@${sha.slice(0, 12)}\`${version ? ` (framework ${version})` : ""} — see \`VERSION\`.`
    : "";
  return `${BANNER_PREFIX} \`${branch}\`** — built in ` +
    "[abap2UI5/abap2UI5](https://github.com/abap2UI5/abap2UI5) by its `frontend_deploy` workflow " +
    "and pushed here. Do not commit in this repository; changes belong into abap2UI5." + origin + "\n";
}

// Der Stempel nennt den Commit weiterhin "webapp mirror commit" und das Banner
// weiterhin den Frontend-Stand: es ist derselbe Wert, den die alten
// Mirror-Commits trugen, also aendert sich nichts, wogegen jemand vergleicht.
export function versionStamp({ sha = null, version = null } = {}) {
  return [
    "Generated abap2UI5-frontend branch — provenance",
    `webapp mirror commit: ${sha ? `abap2UI5/abap2UI5@${sha}` : "unknown"}`,
    version ? `abap2UI5 framework version: ${version}` : null,
  ].filter(Boolean).join("\n") + "\n";
}

export function coreSha(explicit = null) {
  const given = explicit ?? process.env.GITHUB_SHA ?? "";
  if (/^[0-9a-f]{40}$/.test(given)) return given;
  try {
    return execFileSync("git", ["rev-parse", "HEAD"], { cwd: core, encoding: "utf8" }).trim() || null;
  } catch {
    // Ein flacher oder detachter Checkout hat keinen - dann bleibt die
    // Herkunftsangabe weg, statt einen falschen Commit zu nennen.
    return null;
  }
}

export function coreVersion() {
  try {
    const source = readFileSync(join(core, "src/02/z2ui5_if_app.intf.abap"), "utf8");
    return /CONSTANTS\s+version\s+TYPE\s+string\s+VALUE\s+`([^`]+)`/i.exec(source)?.[1] ?? null;
  } catch {
    return null;
  }
}

// README-Banner ersetzen und VERSION schreiben. Der Baum bleibt sonst, wie er
// gebaut wurde.
export function stamp(dir, branch, sha = null) {
  const provenance = { sha: coreSha(sha), version: coreVersion() };
  const readme = join(dir, "README.md");
  const lines = readFileSync(readme, "utf8").split("\n");
  // Gefunden werden MUSS die Zeile: ein stiller Fehlschlag wuerde einen Branch
  // ohne Herkunftsangabe ausliefern, und niemandem faellt es auf.
  if (!lines[0].startsWith(BANNER_PREFIX)) {
    throw new Error(`${readme}: first line is not the generated banner`);
  }
  lines[0] = banner(branch, provenance).trimEnd();
  writeFileSync(readme, lines.join("\n"));
  writeFileSync(join(dir, "VERSION"), versionStamp(provenance));
  return provenance;
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  const [dir, branch, sha] = process.argv.slice(2);
  if (!dir || !branch) {
    console.error("Aufruf: node tools/branch-stamp.mjs <dir> <branch> [sha]");
    process.exit(1);
  }
  const { sha: used, version } = stamp(dir, branch, sha);
  console.log(`${branch}: stamped ${used ? used.slice(0, 12) : "(no commit)"}${version ? ` (framework ${version})` : ""}`);
}
