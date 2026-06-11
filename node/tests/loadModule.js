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
function loadModule(relPath, { deps = {}, sandbox = {} } = {}) {
  const source = fs.readFileSync(path.join(WEBAPP_DIR, relPath), "utf8");
  let exported;
  const context = {
    sap: {
      ui: {
        define: (depNames, factory) => {
          exported = factory(...depNames.map((name) => deps[name]));
        },
      },
    },
    URL,
    ...sandbox,
  };
  if (!("window" in context)) context.window = context;
  vm.runInNewContext(source, context, { filename: relPath });
  if (!exported) {
    throw new Error(`${relPath} did not register via sap.ui.define`);
  }
  return { module: exported, sandbox: context };
}

module.exports = { loadModule };
