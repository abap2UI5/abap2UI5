// @ts-check
// Loads the real app/webapp/core/Lib.js through the generic loadModule
// helper (stubbed sap.ui.define), so the specs exercise the shipped
// implementation instead of a copy that could silently drift from the
// production code.
const { loadModule } = require("./loadModule");

function loadLib(overrides = {}) {
  // Lib reaches the shared state via its AppState dependency. The stub's
  // `state` is the same object that is exposed as sandbox.z2ui5, so the
  // existing spec assertions on sandbox.z2ui5.errors keep observing what
  // the helpers write.
  const state = overrides.z2ui5 ?? {};
  const { module, sandbox } = loadModule("core/Lib.js", {
    deps: { "z2ui5/core/AppState": { state } },
    sandbox: {
      // window.location.origin anchors relative URL resolution.
      z2ui5: state,
      window: { location: { origin: "http://localhost:3000" } },
      ...overrides,
    },
  });
  return { Lib: module, sandbox };
}

module.exports = { loadLib };
