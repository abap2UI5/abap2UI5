/*
 * unit-accelerated — `npm run unit` with accelerate() installed.
 *
 * node/srv/accelerate.mjs replaces @abaplint/runtime's LOOP-over-a-sorted-key
 * and CP with fast paths, and host.mjs's initialize() installs them for every
 * host - so what a host runs is the framework ON the fast paths, not on the
 * runtime `npm run unit` exercises. node/tests/accelerate.spec.js compares the
 * fast paths with the originals case by case; this runs the framework's own
 * suite on them (1300+ tests, the AJSON serializer and parser among them) and
 * has to pass exactly as `npm run unit` does.
 *
 * The same generated runner (output/index.mjs), booted the same way: its
 * `import "./init.mjs"` finds the runtime already booted here, and the fast
 * paths already in place.
 *
 *   npm run unit:accelerated     (needs the transpiled tree, like npm run unit)
 */
import "../output/init.mjs";
import { accelerate, RUNTIME_VERSION } from "../srv/accelerate.mjs";

if (!accelerate()) {
  console.error(`unit-accelerated: accelerate() installed nothing - the installed @abaplint/runtime is not ${RUNTIME_VERSION},`
    + " so this run would be `npm run unit` again. Revalidate node/srv/accelerate.mjs (node/tests/accelerate.spec.js says how).");
  process.exit(1);
}
console.log(`unit-accelerated: the fast paths of node/srv/accelerate.mjs are installed (@abaplint/runtime ${RUNTIME_VERSION})`);
await import("../output/index.mjs");
