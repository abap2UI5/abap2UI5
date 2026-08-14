// patch-v2.mjs
// Der Bootstrap-Patch klassisch -> legacy-free (UI5 2.0). Wird von
// build-legacy-free.mjs (standard_v2) und build-branches.mjs (cloud_v2)
// gemeinsam genutzt, damit beide v2-Varianten identisch gepatcht sind.

export const SDK = "https://sdk.openui5.org/1.142.0-legacy-free/resources/sap-ui-core.js";

export function patchIndexHtml(s) {
  return s
    .replace(/^\s*<meta http-equiv="X-UA-Compatible"[^>]*>\n/m, "")
    .replace(/(<title>abap2UI5<\/title>\n)/,
      `$1\n    <link rel="preconnect" href="https://sdk.openui5.org" crossorigin>\n    <link rel="dns-prefetch" href="https://sdk.openui5.org">\n`)
    .replace(/src="resources\/sap-ui-core\.js"/, `src="${SDK}"`)
    .replace(/data-sap-ui-resourceroots=/, "data-sap-ui-resource-roots=")
    .replace(/data-sap-ui-oninit=/, "data-sap-ui-on-init=")
    .replace(/data-sap-ui-compatVersion=/, "data-sap-ui-compat-version=")
    .replace(/(data-sap-ui-frameOptions="trusted")/, `data-sap-ui-frame-options="trusted"\n        data-sap-ui-libs="sap.m"`);
}

export function patchManifest(s) {
  const m = JSON.parse(s);
  m._version = "2.0.0";
  m["sap.ui5"].dependencies.minUI5Version = "1.136.0";
  return JSON.stringify(m, null, 2) + "\n";
}
