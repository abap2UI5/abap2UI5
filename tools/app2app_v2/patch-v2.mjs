// patch-v2.mjs
// The bootstrap patch classic -> legacy-free (UI5 2.0). Shared by
// build-legacy-free.mjs (standard_v2) and build-branches.mjs (cloud_v2), so
// that both v2 variants are patched identically.

export const SDK = "https://sdk.openui5.org/1.142.0-legacy-free/resources/sap-ui-core.js";

// Every replacement is an assumption about app/webapp/index.html. If it no
// longer holds, carrying on silently would be the worst outcome:
// cloud_v2/standard_v2 would then deliver the classic bootstrap, and no gate
// would see it - the wrongly built tree is consistent with the sources, after
// all. Whoever rewords index.html rewords the assumption here along with it.
function mustPatch(s, re, replacement, what) {
  if (!re.test(s)) {
    throw new Error(`patch-v2: ${what} not found - the v2 patch no longer matches app/webapp/index.html`);
  }
  return s.replace(re, replacement);
}

export function patchIndexHtml(s) {
  // Cleaned up if present: app/webapp has lost the IE compat meta line itself
  // in the meantime - its absence is not an error here, only its reappearance
  // would be removed.
  s = s.replace(/^\s*<meta http-equiv="X-UA-Compatible"[^>]*>\n/m, "");
  s = mustPatch(s, /(<title>abap2UI5<\/title>\n)/,
    `$1\n    <link rel="preconnect" href="https://sdk.openui5.org" crossorigin>\n    <link rel="dns-prefetch" href="https://sdk.openui5.org">\n`,
    "the <title>abap2UI5</title> line");
  s = mustPatch(s, /src="resources\/sap-ui-core\.js"/, `src="${SDK}"`,
    'the src="resources/sap-ui-core.js" bootstrap');
  s = mustPatch(s, /data-sap-ui-resourceroots=/, "data-sap-ui-resource-roots=",
    "data-sap-ui-resourceroots");
  s = mustPatch(s, /data-sap-ui-oninit=/, "data-sap-ui-on-init=",
    "data-sap-ui-oninit");
  s = mustPatch(s, /data-sap-ui-compatVersion=/, "data-sap-ui-compat-version=",
    "data-sap-ui-compatVersion");
  s = mustPatch(s, /(data-sap-ui-frameOptions="trusted")/,
    `data-sap-ui-frame-options="trusted"\n        data-sap-ui-libs="sap.m"`,
    'data-sap-ui-frameOptions="trusted"');
  return s;
}

export function patchManifest(s) {
  const m = JSON.parse(s);
  m._version = "2.0.0";
  m["sap.ui5"].dependencies.minUI5Version = "1.136.0";
  return JSON.stringify(m, null, 2) + "\n";
}
