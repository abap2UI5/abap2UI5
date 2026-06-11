// @ts-check
// Loads the real app/webapp/core/Lib.js through the generic loadModule
// helper (stubbed sap.ui.define), so the specs exercise the shipped
// implementation instead of a copy that could silently drift from the
// production code.
const { loadModule } = require("./loadModule");

function loadLib(overrides = {}) {
  const { module, sandbox } = loadModule("core/Lib.js", {
    sandbox: {
      // Globals the helpers touch at runtime: z2ui5 receives the error
      // log, window.location.origin anchors relative URL resolution.
      z2ui5: {},
      window: { location: { origin: "http://localhost:3000" } },
      ...overrides,
    },
  });
  return { Lib: module, sandbox };
}

module.exports = { loadLib };
