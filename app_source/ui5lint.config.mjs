// UI5 linter configuration (npm run check:ui5 in the repository root, which
// runs the linter installed in bundle/ over this project). There is no error
// budget: what is switched off is switched off here, with the reason.
export default {
  ignores: [
    // Bootstrap page: uses the old spelling of the bootstrap parameters
    // (data-sap-ui-resourceroots, data-sap-ui-oninit, ...) on purpose - the
    // new spellings are not understood by the old UI5 releases abap2UI5
    // still supports (down to 1.71).
    "webapp/index.html",
    // manifest.json: satisfying no-outdated-manifest-version (_version 2)
    // and no-legacy-ui5-version-in-manifest (minUI5Version >= 1.136) would
    // declare those releases unsupported, and "async" on the rootView is
    // what makes 1.71 create it asynchronously (it ignores
    // IAsyncContentCreation). JSON allows no inline suppression comments,
    // so the file is excluded, as in bundle/.
    "webapp/manifest.json",
  ],
};
