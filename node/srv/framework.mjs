/*
 * framework.mjs - which transpiled framework srv/hostcore.mjs runs on.
 *
 * hostcore.mjs calls seven modules of a transpiled output: its init.mjs, the
 * shim and five classes of the framework. It does not import them itself,
 * because there are two outputs it can run on - the package's own output/,
 * and the complete output abap2ui5-transpile writes for a host that
 * transpiles its classes WITH the framework. An entry point imports the
 * seven statically and binds them here before hostcore.mjs runs anything:
 * srv/host.mjs for the package's output/, the host.mjs that
 * abap2ui5-transpile writes (hostEntry( ) below) for the host's.
 *
 * One process runs one output: the second output's init.mjs would replace
 * the first's runtime (globalThis.abap) and every class in it. So each entry
 * point's FIRST import is a claim module - srv/claim.mjs for the package's
 * output/, the claim.mjs abap2ui5-transpile writes next to the host's
 * host.mjs - which calls claimOutput( ) for its output. Evaluated before the
 * entry point's init.mjs, a second claim for another output throws while
 * the first runtime is still intact.
 */

/* The modules hostcore.mjs calls, as `[export, path below the output]` -
 * what srv/host.mjs imports and what hostEntry( ) writes. hostEntry.spec
 * holds the two to the same list. */
export const FRAMEWORK_MODULES = [
  ["initializeABAP", "init.mjs"],
  ["cl_express_icf_shim", "express-icf-shim/cl_express_icf_shim.clas.mjs"],
  ["z2ui5_cl_ui5_http_handler", "project/z2ui5_cl_ui5_http_handler.clas.mjs"],
  ["z2ui5_cl_ui5_user_exit", "project/z2ui5_cl_ui5_user_exit.clas.mjs"],
  ["z2ui5_cl_ui5_app_cont", "project/z2ui5_cl_ui5_app_cont.clas.mjs"],
  ["z2ui5_cl_ui5_srv_draft", "project/z2ui5_cl_ui5_srv_draft.clas.mjs"],
  ["zcl_serializer_live", "project/zcl_serializer_live.clas.mjs"],
];

let claimed;
let bound;

/**
 * Claim the process for one transpiled output - what a claim module does
 * before its entry point loads that output. The same output again is fine.
 * @param {string} output the output folder's URL
 */
export function claimOutput(output) {
  if (claimed !== undefined && claimed !== output) {
    throw new Error(`@abap2ui5/node-runtime: the framework of ${claimed} is already loaded, and ${output} would replace its runtime - `
      + "a process runs one output: import either @abap2ui5/node-runtime or the host.mjs of your abap2ui5-transpile output, not both");
  }
  claimed = output;
}

/**
 * Bind the transpiled framework hostcore.mjs runs on - the seven modules of
 * FRAMEWORK_MODULES of the output claimed before (claimOutput( )).
 * @param {Record<string, any>} modules the exports, by name
 */
export function bindFramework(modules) {
  if (claimed === undefined) throw new Error("@abap2ui5/node-runtime: bindFramework( ) before claimOutput( ) - an entry point's first import claims its output");
  const missing = FRAMEWORK_MODULES.map(([name]) => name).filter((name) => modules[name] === undefined);
  if (missing.length) throw new Error(`@abap2ui5/node-runtime: ${claimed} lacks ${missing.join(", ")}`);
  if (bound && bound.from === claimed) return;
  bound = { modules, from: claimed };
}

/** The bound framework's modules. */
export function framework() {
  if (!bound) {
    throw new Error("@abap2ui5/node-runtime: no framework loaded - import @abap2ui5/node-runtime, or the host.mjs of your abap2ui5-transpile output");
  }
  return bound.modules;
}

const WRITTEN = [
  "// Written by abap2ui5-transpile (@abap2ui5/node-runtime, setup/transpile.mjs) - do not edit,",
  "// it is written again with every transpile.",
];

/**
 * The two modules abap2ui5-transpile writes into a host's output folder:
 * host.mjs, the package's entry point bound to that output, and claim.mjs,
 * its first import. Pure.
 * @param {{ packageName?: string }} [options]
 * @returns {{ "host.mjs": string, "claim.mjs": string }} the modules' texts
 */
export function hostEntry({ packageName = "@abap2ui5/node-runtime" } = {}) {
  const framework = JSON.stringify(`${packageName}/srv/framework.mjs`);
  return {
    "host.mjs": [
      ...WRITTEN,
      "// The package's entry point, bound to this output: import serve, initialize, ... from here",
      "// instead of from the package. claim.mjs first - it refuses a second output before this",
      "// one's init.mjs would replace its runtime (srv/framework.mjs).",
      'import "./claim.mjs";',
      ...FRAMEWORK_MODULES.map(([name, file]) => `import { ${name} } from ${JSON.stringify(`./${file}`)};`),
      `import { bindFramework } from ${framework};`,
      "",
      `bindFramework({ ${FRAMEWORK_MODULES.map(([name]) => name).join(", ")} });`,
      "",
      `export * from ${JSON.stringify(`${packageName}/srv/hostcore.mjs`)};`,
      "",
    ].join("\n"),
    "claim.mjs": [
      ...WRITTEN,
      `import { claimOutput } from ${framework};`,
      "",
      'claimOutput(new URL("./", import.meta.url).href);',
      "",
    ].join("\n"),
  };
}
