// @ts-check
// Loads the real app/webapp/cc/Util.js in Node by stubbing sap.ui.define,
// so the specs exercise the shipped implementation instead of a copy that
// could silently drift from the production code.
const fs = require('fs');
const path = require('path');
const vm = require('vm');

const UTIL_PATH = path.join(__dirname, '..', '..', 'app', 'webapp', 'cc', 'Util.js');

function loadUtil(overrides = {}) {
    const source = fs.readFileSync(UTIL_PATH, 'utf8');
    let exported;
    const sandbox = {
        sap: { ui: { define: (deps, factory) => { exported = factory(); } } },
        // Globals the helpers touch at runtime: z2ui5 receives the error
        // log, window.location.origin anchors relative URL resolution.
        z2ui5: {},
        URL,
        window: { location: { origin: 'http://localhost:3000' } },
        ...overrides,
    };
    vm.runInNewContext(source, sandbox, { filename: UTIL_PATH });
    if (!exported) {
        throw new Error('Util.js did not register via sap.ui.define');
    }
    return { Util: exported, sandbox };
}

module.exports = { loadUtil };
