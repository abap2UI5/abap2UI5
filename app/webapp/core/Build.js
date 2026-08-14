// =====================================================================
// GENERATED FILE - DO NOT EDIT (AGENTS.md rule 2)
// Build identity of the frontend artefacts, generated from app/webapp/ by
// .github/app2abap/trans2abap.js. Run 'npm run app2abap' to regenerate;
// the check_app2abap CI gate fails any manual edit here.
// =====================================================================
//
// What this is for: a running abap2UI5 app is assembled from copies that are
// installed separately and can drift apart - the backend (abapGit), the
// frontend the backend embeds (src/01/03, generated from these same sources),
// and the BSP frontend (abap2UI5/frontend), with the browser's cache on top.
// This module is what the copy in the browser answers with when core/Server.js
// asks which build it is; the backend sends the same two values for its own
// copy on the first roundtrip of a page load.
sap.ui.define([], () => {
  "use strict";

  return {
    // abap2UI5 release these artefacts were generated from - the version
    // constant of z2ui5_if_app at generation time. Unlike the ABAP half,
    // this copy DOES have to carry it: it travels into the BSP and into the
    // browser's cache, away from the backend, and is then the only thing
    // that can say how far behind it is.
    VERSION: "1.142.0",

    // Fingerprint over app/webapp/** (this file excluded). Two copies with
    // the same hash ARE the same frontend; a different hash under the same
    // VERSION is the signature of a stale cache or an un-redeployed BSP.
    HASH: "022710d7ce46",
  };
});
