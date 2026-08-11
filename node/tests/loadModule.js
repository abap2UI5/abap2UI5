// @ts-check
// Loads a real app/webapp module in Node by stubbing sap.ui.define, so the
// specs exercise the shipped implementation instead of a copy that could
// silently drift from the production code.
const fs = require("fs");
const path = require("path");
const vm = require("vm");

const WEBAPP_DIR = path.join(__dirname, "..", "..", "app", "webapp");

// Loads `relPath` (relative to app/webapp, e.g. "core/Lib.js").
//  - `deps`     stubs for the module's sap.ui.define dependencies, keyed by
//               dependency name (e.g. "z2ui5/core/Lib"); unstubbed
//               dependencies resolve to undefined
//  - `sandbox`  extra globals for the module; unless one is provided,
//               `window` is the sandbox global object itself, mirroring
//               the browser where window === globalThis
// Returns { module, sandbox } - the module's export and the live sandbox.
//
// With `autoLoad: true`, a z2ui5/* dependency that is NOT stubbed in `deps`
// is loaded for real from app/webapp (recursively, sharing this call's deps
// and sandbox), so a module composed from submodules - core/FrontendAction.js
// and its core/actions/* - is tested as the composition that ships. Without
// the flag (and for sap/* dependencies always), an unstubbed dependency
// resolves to undefined, exactly as before.
function loadModule(relPath, { deps = {}, sandbox = {}, autoLoad = false } = {}) {
  const context = {
    URL,
    // Timers are browser globals the modules legitimately use (deferred
    // retries, START_TIMER); a vm context has none of its own, so hand the
    // host's in - otherwise those paths die with "setTimeout is not defined".
    setTimeout,
    clearTimeout,
    setInterval,
    clearInterval,
    ...sandbox,
  };
  if (!("window" in context)) context.window = context;

  // one instance per module name and load() call - two modules requiring
  // z2ui5/core/Lib share the same live object, like the UI5 loader
  const loaded = new Map();

  function resolveDep(name) {
    if (name in deps) return deps[name];
    if (!autoLoad || !name.startsWith("z2ui5/")) return undefined;
    if (!loaded.has(name)) {
      loaded.set(name, run(`${name.slice("z2ui5/".length)}.js`));
    }
    return loaded.get(name);
  }

  function run(modulePath) {
    const source = fs.readFileSync(path.join(WEBAPP_DIR, modulePath), "utf8");
    let exported;
    // sap.ui.define is scoped per module run: the recursive dependency loads
    // below must not overwrite an outer module's capture mid-factory. Rebuilt
    // with spreads so sap members a spec seeded (e.g. sap.ui.require) survive.
    context.sap = {
      ...context.sap,
      ui: {
        ...context.sap?.ui,
        define: (depNames, factory) => {
          exported = factory(...depNames.map(resolveDep));
        },
      },
    };
    vm.runInNewContext(source, context, { filename: modulePath });
    if (!exported) {
      throw new Error(`${modulePath} did not register via sap.ui.define`);
    }
    return exported;
  }

  const module = run(relPath);
  return { module, sandbox: context };
}

module.exports = { loadModule };
