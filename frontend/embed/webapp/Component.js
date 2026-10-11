sap.ui.define(
  [
    "sap/ui/core/UIComponent",
    "sap/ui/model/json/JSONModel",
    "sap/ui/util/Mobile",
    "sap/m/MessageStrip",
    "abap2ui5/frontend/model/start",
  ],
  (UIComponent, JSONModel, Mobile, MessageStrip, start) => {
    "use strict";

    // The whole app: one view with one z2ui5.embed.Container, which loads
    // the abap2UI5 frontend from the backend and runs the app this
    // component picks (model/start.js) in it. Everything else - views,
    // popups, navigation between apps - comes from the backend.
    //
    // The component is z2ui5, as abap2UI5/frontend's was: a launchpad target
    // mapping names it, and it has to keep working. This file is the one
    // module of the app below z2ui5/ besides the manifest - the frontend
    // the control loads lives there too, and the control creates it under
    // the second name the bundle gives it (z2ui5.embed.frontend). The
    // app's own modules are abap2ui5/frontend/, the same folder under a
    // name of its own (sap.ui5/resourceRoots).
    return UIComponent.extend("z2ui5.Component", {
      metadata: {
        manifest: "json",
        interfaces: ["sap.ui.core.IAsyncContentCreation"],
      },

      init() {
        // The page's mobile setup, once per page with the settings of
        // whoever comes first: on a page of its own the full one, as
        // abap2UI5's own page does it - the embedded frontend leaves it to
        // its host. In the launchpad the shell came first, and this changes
        // nothing.
        Mobile.init();

        UIComponent.prototype.init.apply(this, arguments);

        // The endpoint is where the classic frontend of the branches
        // standard and cloud has it, sap.app/dataSources/http - and the
        // build of cloud_new turns it to the HTTP service path the same way
        // it does for cloud. Never from the URL or the launchpad (start.js).
        const config = this.getManifestEntry("/sap.ui5/config") || {};
        const http = this.getManifestEntry("/sap.app/dataSources/http") || {};
        this.setModel(
          new JSONModel(
            Object.assign(
              start(
                this.getComponentData(),
                window.location.search,
                config.defaultApp,
              ),
              { endpoint: http.uri || "", error: "" },
            ),
          ),
          "start",
        );
      },

      // Created by a z2ui5.embed.Container as the frontend - what the control
      // does with a backend whose bundle names no second name (1.146.0),
      // since this component is z2ui5 too. It would nest itself without end,
      // under the frontend's manifest, which the bundle has put in place of
      // this one by then: no root view, only what is missing.
      createContent() {
        if ((this.getComponentData() || {}).embedded === true) {
          return new MessageStrip({
            type: "Error",
            showIcon: true,
            text:
              "abap2UI5 could not start: this app needs abap2UI5 newer " +
              "than 1.146.0, whose bundle names the second name of the " +
              "frontend, z2ui5.embed.frontend",
          });
        }
        return UIComponent.prototype.createContent.apply(this, arguments);
      },
    });
  },
);
