// The one global the frontend reads: the UI5 core namespace (sap.ui.define,
// sap.ui.require, the 1.71 fallbacks in core/Env.js). Deliberately `any`:
// the published UI5 typings describe the CURRENT release, and checking this
// code against them would flag every 1.71 fallback and approve APIs that
// 1.71 does not have. There is no `z2ui5` global and none may be declared.
declare const sap: any;
