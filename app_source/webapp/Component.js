sap.ui.define(
  ["sap/ui/core/UIComponent", "sap/ui/model/json/JSONModel"],
  (UIComponent, JSONModel) => {
    "use strict";

    // The whole app: one view - a sap.m.Shell with a z2ui5.embed.Container
    // (embed/Container.js) in it. The control loads the abap2UI5 frontend
    // from the backend (?z2ui5-bundle) and runs the app in it; everything
    // else comes from the backend, the class to start included (the
    // backend reads it from the page's URL). Nothing is decided here: the
    // component only says where the backend is.
    return UIComponent.extend("abap2ui5.page.Component", {
      metadata: {
        manifest: "json",
        interfaces: ["sap.ui.core.IAsyncContentCreation"],
      },

      init() {
        UIComponent.prototype.init.apply(this, arguments);

        // The backend is the data source of the manifest - unless the page
        // IS the backend: the page the abap2UI5 HTTP service answers a GET
        // with carries this app in its inline script
        // (z2ui5_cl_ui5_http_handler=>_http_get) and says so on the top
        // level of the component data (checkLocal). The endpoint is that
        // page's own path then.
        const local = (this.getComponentData() || {}).checkLocal === true;

        const http = this.getManifestEntry("/sap.app/dataSources/http") || {};
        this.setModel(
          new JSONModel({
            endpoint: local ? window.location.pathname : http.uri || "",
          }),
          "start",
        );
      },
    });
  },
);
