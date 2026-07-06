// UI5 linter configuration. CI accepts no error budget (see
// .github/scripts/ui5lint-gate.mjs): design-accepted findings are switched
// off where they occur - in JS files inline via ui5lint-disable comments
// with a stated reason, and the files below as a whole, because JSON allows
// no comments or the findings are inherent to supporting old UI5 releases.
export default {
  ignores: [
    // Bootstrap page: uses the old spelling of the bootstrap parameters
    // (data-sap-ui-resourceroots, data-sap-ui-oninit, ...) on purpose -
    // the new spellings are not understood by the old UI5 releases
    // abap2UI5 still supports.
    "webapp/index.html",
    // manifest.json: satisfying no-outdated-manifest-version (_version 2)
    // and no-legacy-ui5-version-in-manifest (minUI5Version >= 1.136) would
    // declare the old UI5 bootstraps unsupported that abap2UI5 deliberately
    // keeps working (down to 1.71). JSON allows no inline suppression
    // comments, so the file is excluded until that support is dropped.
    "webapp/manifest.json",
  ],
};
