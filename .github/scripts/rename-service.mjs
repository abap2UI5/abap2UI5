#!/usr/bin/env node
/*
 * rename-service - the second half of a namespace rename: src/03.
 *
 * `abaplint --rename` (rename.jsonc) renames classes, interfaces and tables
 * and every reference to them. src/03 is the part of the repository it cannot
 * do: an ICF node, a BSP with its own two ICF nodes, and the handler class the
 * first node names - object types abaplint does not rename, and names that
 * sit inside XML and file names rather than in ABAP references. rename.jsonc
 * leaves the package out for that reason, and tools/bsp_rename, which knows
 * these objects, renames it here.
 *
 *   node .github/scripts/rename-service.mjs <name>
 *
 * <name> is what build-rename takes: a customer name (zmyui5) or a
 * registered namespace with both slashes (/ca2ui5/). It has to be the name
 * the abaplint rename before it ran with - this script reads that run's
 * output (.github/abaplint/output), puts the renamed src/03 next to the
 * renamed src/00 to src/02 and lints the result: the handler calls
 * <prefix>cl_ui5_http_handler, and that call has to resolve in the tree that
 * is about to be pushed.
 *
 * Used by `npm run rename` (the pull-request gate, against the placeholder
 * name) and by build-rename.yaml (the real branches) - one way to build it.
 */
import { execFileSync } from "node:child_process";
import { cpSync, existsSync, readdirSync, rmSync, statSync, writeFileSync } from "node:fs";
import { join, relative, sep } from "node:path";
import { fileURLToPath } from "node:url";

const ROOT = fileURLToPath(new URL("../../", import.meta.url));
const OUTPUT = join(ROOT, ".github/abaplint/output");
const SERVICE = "03";

const name = (process.argv[2] ?? "").toLowerCase();
const customer = /^[a-z][a-z0-9_]{0,9}$/.test(name) && !name.endsWith("_");
const namespace = /^\/[a-z0-9][a-z0-9_]{0,7}\/$/.test(name);
if (!customer && !namespace) {
  console.error("Usage: node .github/scripts/rename-service.mjs <name>   (zmyui5, or a namespace: /ca2ui5/)");
  process.exit(1);
}
// what build-rename.yaml derives: a customer name takes the place of z2ui5,
// a namespace the place of z2ui5_
const prefix = customer ? `${name}_` : name;

// the renamed tree below abaplint's output folder: <output>/src from the
// root-level run config rename-run.mjs writes, <output>/<absolute path of
// the checkout>/src from an older run - the first folder named src in there
function renamedSrc(dir) {
  if (!existsSync(dir)) return null;
  for (const entry of readdirSync(dir)) {
    const path = join(dir, entry);
    if (!statSync(path).isDirectory()) continue;
    if (entry === "src") return path;
    const below = renamedSrc(path);
    if (below) return below;
  }
  return null;
}
const src = renamedSrc(OUTPUT);
if (!src) {
  console.error("rename-service: no renamed src folder under .github/abaplint/output - run the abaplint rename first");
  process.exit(1);
}

const target = join(src, SERVICE);
rmSync(target, { recursive: true, force: true });
cpSync(join(ROOT, "src", SERVICE), target, { recursive: true });

const run = (cmd, args) => execFileSync(cmd, args, { cwd: ROOT, stdio: ["ignore", "pipe", "inherit"], encoding: "utf8" });
run(process.execPath, ["tools/bsp_rename/rename-bsp.mjs", name, "--dir", target, "--backend", prefix, "--yes"]);

// nothing of the original identity may be left in a file NAME: a file that
// kept it is an object that kept it, and collides with the installation the
// rename exists to sit next to
const kept = readdirSync(target, { recursive: true })
  .map(String)
  .filter((file) => /(^|[\\/])z2ui5[ ._]/i.test(file));
if (kept.length) {
  console.error("rename-service: still named after the original:\n  " + kept.join("\n  "));
  process.exit(1);
}

// abap_service.jsonc, pointed at the renamed tree: the same rules, the
// renamed framework as the dependency
const posix = (p) => p.split(sep).join("/");
const rel = (p) => "/" + posix(relative(join(ROOT, ".github/abaplint"), p));
const config = {
  global: { files: `${rel(target)}/**/*.*` },
  dependencies: [
    {
      url: "https://github.com/open-abap/open-abap-core",
      folder: "/../../node/deps/open-abap-core",
      files: "/src/**/*.*",
    },
    { folder: rel(src), files: "/0[0-2]/**/*.*" },
  ],
  syntax: { version: "v750", errorNamespace: "." },
  rules: {
    begin_end_names: true,
    check_include: true,
    check_syntax: true,
    global_class: true,
    implement_methods: true,
    method_implemented_twice: true,
    parser_error: true,
    superclass_final: true,
    unknown_types: true,
    xml_bom: true,
    xml_consistency: true,
  },
};
const configFile = join(ROOT, ".github/abaplint/rename_service_run.jsonc");
writeFileSync(configFile, JSON.stringify(config, null, 2) + "\n");

const WIN = process.platform === "win32";
try {
  execFileSync(WIN ? "npx.cmd" : "npx", ["abaplint", posix(relative(ROOT, configFile))], {
    cwd: ROOT,
    stdio: "inherit",
    shell: WIN,
  });
} catch {
  console.error(`rename-service: the renamed ${SERVICE} does not lint against the renamed framework`);
  process.exit(1);
}
console.log(`rename-service: src/${SERVICE} renamed to ${name} (backend ${prefix}cl_ui5_http_handler) - OK`);
