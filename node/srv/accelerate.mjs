/*
 * accelerate.mjs - kept for the hosts that call it; it installs nothing.
 *
 * Until @abaplint/runtime 2.13.96, two of its functions made a roundtrip with
 * one large table quadratic: LOOP AT ... WHERE over a sorted primary key
 * evaluated the WHERE on every row (z2ui5_cl_ajson's stringify runs one per
 * node), and CP compiled a regular expression per call that walked the whole
 * rest of a string behind a trailing * (open-abap's XML parser asks one per
 * token of the draft). The event roundtrip of 2000 rows took 22.6 s in a CAP
 * project. This file installed fast paths for both on the running runtime.
 *
 * Both changes are upstream now - abaplint/transpiler#1950 (the LOOP) and
 * #1933 (CP), released in 2.13.96 - and the runtime's own functions are as
 * fast as the fast paths were: node/tests-examples/rowsRoundtrip.bench.mjs
 * measures the event roundtrip of 4000 rows at 2.0 s on 2.13.96 alone, where
 * 2.13.93 took 28.4 s and 2.5 s with the fast paths. The package pins a
 * runtime from 2.13.96 on, so there is nothing left to install.
 *
 * accelerate() stays exported - here as the "./accelerate" subpath, and from
 * host.mjs - because hosts call it: @cap2ui5/cds-plugin after booting through
 * output/init.mjs itself, abap2UI5/mcp-server when the release exports it. It
 * answers what it always answered, whether the roundtrip is linear: true on
 * the runtime the package pins, false (and a warning, once) on an older one a
 * host forced in with an `overrides` entry.
 */
import { createRequire } from "node:module";

/** The first @abaplint/runtime version whose LOOP ... WHERE and CP are linear. */
export const RUNTIME_VERSION = "2.13.96";

let warned = false;

function installedRuntimeVersion() {
  try {
    return createRequire(import.meta.url)("@abaplint/runtime/package.json").version;
  } catch {
    return null;
  }
}

/** a >= b, for versions major.minor.patch (a pre-release suffix is ignored) */
function atLeast(a, b) {
  const [x, y] = [a, b].map((v) => v.split("-")[0].split(".").map(Number));
  for (let i = 0; i < 3; i++) {
    if ((x[i] ?? 0) !== (y[i] ?? 0)) return (x[i] ?? 0) > (y[i] ?? 0);
  }
  return true;
}

/**
 * Report whether the running ABAP runtime is linear on large tables. Installs
 * nothing: the runtime from RUNTIME_VERSION on has the fast LOOP and CP itself.
 * @param {{ abap?: object, force?: boolean }} [options]
 *   `abap` the runtime instance (default: globalThis.abap, which
 *   output/init.mjs creates); `force` is accepted and ignored, as there is
 *   nothing left to force
 * @returns {boolean} whether the installed runtime is RUNTIME_VERSION or newer
 */
export function accelerate({ abap: runtime = globalThis.abap } = {}) {
  if (!runtime?.statements?.loop || !runtime?.compare?.cp || !runtime?.types?.Table) {
    throw new Error("accelerate(): no ABAP runtime - call it after output/init.mjs has booted (initialize())");
  }
  const version = installedRuntimeVersion();
  if (version !== null && atLeast(version, RUNTIME_VERSION)) return true;
  if (!warned) {
    warned = true;
    console.warn(`@abap2ui5/node-runtime: @abaplint/runtime ${version ?? "(not found)"} is older than ${RUNTIME_VERSION} -`
      + " a LOOP ... WHERE over a sorted primary key and CP are quadratic on large tables there. Remove the overrides entry"
      + " that pins it, or install the version the package names.");
  }
  return false;
}
