// @ts-check
// Loads the real app/webapp/core/Lib.js through the generic loadModule
// helper (stubbed sap.ui.define), so the specs exercise the shipped
// implementation instead of a copy that could silently drift from the
// production code.
const { loadModule } = require("./loadModule");

function loadLib(overrides = {}) {
  // Lib reaches the shared state via its AppState dependency ONLY. The
  // stub's `state` is returned to the spec, never put into the sandbox as a
  // global: a `z2ui5` global there would let production code that reads one
  // pass these specs, and the frontend has had none since 2026-09-22.
  const { elements = {}, state = {}, ...rest } = overrides;
  // Lib.getElementById resolves control ids through sap.ui.core.Element;
  // the stub's registry lets a spec register elements to resolve.
  const Element = { getElementById: (sId) => elements[sId] || null };
  const { module, sandbox } = loadModule("core/Lib.js", {
    deps: {
      "z2ui5/core/AppState": { state },
      "sap/ui/core/Element": Element,
    },
    sandbox: {
      // window.location.origin anchors relative URL resolution.
      window: { location: { origin: "http://localhost:3000" } },
      ...rest,
    },
  });
  return { Lib: module, sandbox, state };
}

module.exports = { loadLib };
