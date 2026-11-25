// The custom controls of bundle/webapp/cc/, brought in when a view asks for
// them.
//
// They are the THIRD bundle of the frontend (tools/app2abap/trans2abap.js,
// CC_DIR): about a quarter of what a page used to load on its cold start,
// for controls about one app in forty uses. The frontend bundle
// (?z2ui5-bundle) carries none of them; the backend serves them as a script
// of their own on GET <node>?z2ui5-bundle=cc
// (z2ui5_cl_ui5_http_handler=>_http_get_cc) - sap.ui.require.preload( ) over
// every file of cc/, the same shape as the devtools bundle - and this
// module loads that script with a <script> element before the first view
// that needs it is built. actions/Slots awaits ensure( ) next to
// Env.loadViewLibraries( ) at each of its three builds - the MAIN view, a
// nested view, the fragment of a popup or popover - which are the only
// places of the frontend that turn XML into controls.
//
// WHAT counts as "needs it" (namesControls): a control enters a view through
// its XML, and XML can only name a class by a namespace. So the test is the
// text of the view, and it is deliberately wider than "an xmlns of z2ui5.cc":
//   - the namespace of the controls, under whatever prefix and on whatever
//     element it is declared (xmlns:z2ui5="z2ui5.cc", AGENTS.md rule 7);
//   - a module id of one (z2ui5/cc/<Name>) anywhere in the text - a
//     core:require, a template:require, JavaScript an app carries in its
//     view;
//   - the two sibling BSPs the frontend itself wires in (Component.init:
//     z2ui5_cci, the community controls, and z2ui5_ccc, the customer's own
//     artefacts), as a namespace or as a module path: code in them is not
//     ours to read, and a control there may be built on one of ours - it
//     names z2ui5/cc/<Name> as a dependency, which the loader would then
//     ask the node for.
// A false positive (a text that merely mentions the namespace) costs one
// cached request; a miss would cost the view. What the test cannot see is
// JavaScript from somewhere else again - a module in a namespace of its own
// that depends on a control. Nothing shipped does that; a view that needs
// it declares xmlns:z2ui5="z2ui5.cc".
//
// WHERE the controls come from, by deployment:
//   - the frontend came as the bundle (every deployment the backend serves:
//     its own page, the BSP and the launchpad, a host with the embed
//     control): the bundle's z2ui5/embed module carries the version of the
//     custom controls bundle it was generated with (ccBundle,
//     bundle/tail/embed.js) and the URL the frontend bundle itself was
//     loaded from (bundleUrl). The script is asked of that same node, under
//     that version: the controls are a part of THIS frontend - they call
//     its core/Lib and core/Env - so on a page that holds apps of several
//     backends they come from the backend the frontend came from, not from
//     the one the view came from, and the backend lets the browser keep
//     them for good (z2ui5_cl_ui5_http_handler=>_is_bundle_versioned). Only
//     where the bundle's own URL is not known (it was not loaded by a
//     <script> element of its own) the endpoint the roundtrips go to
//     (state.url) is asked, as devtools/DevTools.js asks for its bundle;
//   - the frontend's files are served one by one (the specs that boot
//     bundle/webapp as it is, a build of the classic app): there is no such
//     module, the UI5 loader finds cc/<Name>.js where it finds everything
//     else, and nothing is done here.
//
// ONCE PER PAGE, like Env's library loads: the ui5loader is one per page,
// so controls registered for one component are there for the next, and a
// second view - or a second component - finds the load done. A load in
// flight is shared. A load that FAILED is forgotten, so the next view tries
// again, and it rejects: the build that waited for it must not go on - the
// loader would ask the node for cc/<Name>.js, get the page, and report a
// syntax error in a file nobody wrote. The rejection carries the URL and
// surfaces where every failed view build does, in the error overlay
// (View1._processAfterRendering).
//
// Rule 13 holds: the script is a file of the backend's origin, allowed by
// script-src 'self' - no inline script, no eval.
sap.ui.define([], () => {
  "use strict";

  // The URL parameter of the backend's bundles, the value that picks the
  // custom controls, and the parameter their version travels in
  // (z2ui5_cl_ui5_http_handler=>c_bundle_param, c_bundle_cc,
  // c_bundle_version).
  const BUNDLE_PARAM = "z2ui5-bundle";
  const BUNDLE_CC = "cc";
  const VERSION_PARAM = "z2ui5-version";

  // The module the frontend bundle defines at its end (bundle/tail/embed.js)
  const EMBED_MODULE = "z2ui5/embed";

  // ...and the one the custom controls bundle defines at ITS end (CC_MARKER
  // in tools/app2abap/trans2abap.js): what tells this bundle from any other
  // answer the endpoint may give with a 200 - a logon page, a proxy's error
  // page - which a <script> element reports as loaded all the same.
  const BUNDLE_MODULE = "z2ui5/cc/bundle";

  // z2ui5.cc / z2ui5/cc, z2ui5_cci, z2ui5_ccc - see the header. The word
  // boundary keeps a longer name of somebody else's (z2ui5.ccx) out.
  const NAMES_CONTROLS = /z2ui5(?:[./]cc|_cc[ci])\b/;

  // whether the controls are in (page-wide), and the load in flight
  let loaded = false;
  let loading = null;

  function namesControls(xml) {
    return NAMES_CONTROLS.test(String(xml ?? ""));
  }

  // What the frontend bundle says about itself: the version of the custom
  // controls bundle it names and the URL it was loaded from. Null when the
  // frontend did not come as a bundle. The one-id form of sap.ui.require
  // only looks: it never asks the loader for the module.
  function frontendBundle() {
    try {
      const embed = sap.ui.require(EMBED_MODULE);
      const version = embed?.ccBundle;
      if (typeof version !== "string" || !version) return null;
      const url = embed.bundleUrl;
      return { version, url: typeof url === "string" && url ? url : null };
    } catch {
      return null;
    }
  }

  // The URL the bundle is loaded from: where the frontend bundle came from,
  // else the endpoint the roundtrips go to - see the header. Its own
  // parameters are kept (sap-client, a proxy's), the bundle parameter is
  // replaced, the hash dropped. Null when neither is known.
  function bundleUrl(ctx, frontend) {
    const base = frontend.url || ctx?.state?.url;
    if (!base) return null;
    try {
      const url = new URL(base, window.location.href);
      url.hash = "";
      url.searchParams.set(BUNDLE_PARAM, BUNDLE_CC);
      url.searchParams.set(VERSION_PARAM, frontend.version);
      return url.href;
    } catch {
      return null;
    }
  }

  function bundleArrived() {
    try {
      return Boolean(sap.ui.require(BUNDLE_MODULE));
    } catch {
      return false;
    }
  }

  // A script of the backend's origin, loaded with a <script> element - the
  // way the embed control loads ?z2ui5-bundle and DevTools.js its bundle.
  // Resolves once the bundle ran, rejects when it could not be fetched or
  // what came was not the bundle; the element of a failed load is removed,
  // the next try adds its own.
  /** @returns {Promise<void>} */
  function loadScript(url) {
    return new Promise((resolve, reject) => {
      const script = document.createElement("script");
      const fail = () => {
        script.remove();
        reject(
          new Error(
            `the custom controls this view uses could not be loaded: ${url}`,
          ),
        );
      };
      script.src = url;
      script.async = true;
      script.onerror = fail;
      // the bundle's module settles in the task after the script ran
      script.onload = () =>
        setTimeout(() => (bundleArrived() ? resolve() : fail()), 0);
      document.head.appendChild(script);
    });
  }

  // Resolves once the custom controls are registered with the loader - at
  // once for a view that names none, for a frontend whose files the loader
  // finds itself, and for every view after the first. Rejects when the
  // bundle could not be loaded (see the header).
  /** @returns {Promise<void>} */
  function ensure(ctx, xml) {
    if (loaded || !namesControls(xml)) return Promise.resolve();
    const frontend = frontendBundle();
    if (!frontend) return Promise.resolve();
    // brought in by somebody else - a host, a spec - with a script of its own
    if (bundleArrived()) {
      loaded = true;
      return Promise.resolve();
    }
    if (!loading) {
      const url = bundleUrl(ctx, frontend);
      const load = url
        ? loadScript(url)
        : Promise.reject(
            new Error(
              "the custom controls this view uses could not be loaded: no endpoint to load them from",
            ),
          );
      loading = load.then(
        () => {
          loaded = true;
          loading = null;
        },
        (e) => {
          loading = null;
          throw e;
        },
      );
    }
    return loading;
  }

  return { ensure, namesControls };
});
