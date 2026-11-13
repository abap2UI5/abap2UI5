// The end of the frontend bundle (GET <node>?z2ui5-bundle): the module a
// host finds the bundle by, and the one call it makes.
//
// tools/app2abap/trans2abap.js puts this file behind the preload of
// bundle/webapp, and z2ui5_cl_ui5_http_handler=>_http_get_bundle writes the
// one thing only a request knows into it - the path the node has on the
// system, in place of the token below.
//
// Not a module of bundle/webapp on purpose. Those are registered as a
// preload and run when somebody requires them; this one is DEFINED the
// moment the script has run, by name and without dependencies, because that
// is what the embedding control looks for (z2ui5.embed.Container,
// app_source/webapp/embed): it looks the module up and never asks the loader
// for it - a loader asked for a module nobody defined fetches z2ui5/embed.js,
// which no host has, and remembers the module as failed for the page's life.
// A logon page, or an abap2UI5 without the bundle, defines no such module.
sap.ui.define("z2ui5/embed", function () {
  "use strict";

  var installation = {
    // The second name the bundle registers the component under (its
    // Component.js and manifest.json under z2ui5/embed/frontend/, see
    // BUNDLE_CLOSE in tools/app2abap/trans2abap.js): a host whose own
    // component is z2ui5 has the first one taken.
    componentName: "z2ui5.embed.frontend",

    // What the component gets from the installation (Component.init):
    //   nodePath          the path of the bundle's request as the SYSTEM saw
    //                     it - /sap/bc/z2ui5. A proxy that puts the system
    //                     under a path prefix of its own serves the bundle
    //                     at <prefix>/sap/bc/z2ui5, and the two roots below,
    //                     absolute on the system, are not found on the
    //                     page's origin until that prefix is in front of
    //                     them: Component.init compares the host's endpoint
    //                     with this path and rebases them
    //   ccResourceRoot    the BSP of abap2UI5-addons/custom-controls
    //   cccResourceRoot   the BSP of the customer's own frontend artefacts
    //                     (abap2UI5-addons/custom-controls-customer)
    // @abap2ui5/embed-control 0.3.0 reads componentName and componentData
    // itself and creates the component with them.
    componentData: {
      nodePath: "@z2ui5-node-path@",
      ccResourceRoot: "/sap/bc/ui5_ui5/sap/z2ui5_cci",
      cccResourceRoot: "/sap/bc/ui5_ui5/sap/z2ui5_ccc",
    },

    // The one call the control makes: the app for these settings, as a
    // control to render. How it is made is the bundle's own module's
    // (z2ui5/core/Embed) - required here, not as a dependency: see above.
    create: function (settings) {
      return new Promise(function (resolve, reject) {
        sap.ui.require(
          ["z2ui5/core/Embed"],
          function (Embed) {
            resolve(Embed.create(settings, installation));
          },
          reject,
        );
      });
    },
  };
  return installation;
});
