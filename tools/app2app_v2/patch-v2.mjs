// patch-v2.mjs
// Der Bootstrap-Patch klassisch -> legacy-free (UI5 2.0). Wird von
// build-legacy-free.mjs (standard_v2) und build-branches.mjs (cloud_v2)
// gemeinsam genutzt, damit beide v2-Varianten identisch gepatcht sind.

export const SDK = "https://sdk.openui5.org/1.142.0-legacy-free/resources/sap-ui-core.js";

// Jede Ersetzung ist eine Annahme ueber app/webapp/index.html. Trifft sie
// nicht mehr zu, waere stilles Weiterlaufen der schlimmste Ausgang:
// cloud_v2/standard_v2 lieferten dann den klassischen Bootstrap aus, und kein
// Gate saehe es - der falsch gebaute Baum ist ja konsistent zu den Quellen.
// Wer index.html umformuliert, formuliert die Annahme hier mit um.
function mustPatch(s, re, replacement, what) {
  if (!re.test(s)) {
    throw new Error(`patch-v2: ${what} not found - the v2 patch no longer matches app/webapp/index.html`);
  }
  return s.replace(re, replacement);
}

export function patchIndexHtml(s) {
  // Aufgeraeumt, falls vorhanden: die IE-Compat-Meta-Zeile hat app/webapp
  // inzwischen selbst verloren - ihr Fehlen ist hier kein Fehler, nur ihr
  // Wiederauftauchen wuerde entfernt.
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
