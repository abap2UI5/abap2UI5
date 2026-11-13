sap.ui.define(
  ["sap/ui/core/UIComponent", "sap/ui/model/json/JSONModel"],
  (UIComponent, JSONModel) => {
    "use strict";

    // The whole app: one view - a sap.m.Shell with a z2ui5.embed.Container
    // in it. The control comes from npm (@abap2ui5/embed-control, served
    // and built under thirdparty/z2ui5/embed/); it loads the abap2UI5
    // frontend from the backend (?z2ui5-bundle) and runs the app in it.
    // Everything else comes from the backend, the class to start included
    // (the backend reads it from the page's URL). Nothing is decided here:
    // the component only says where the backend is.
    //
    // The same app as app_v2, which carries the control's source instead.
    return UIComponent.extend("abap2ui5.page.Component", {
      metadata: {
        manifest: "json",
        interfaces: ["sap.ui.core.IAsyncContentCreation"],
      },

      init() {
        UIComponent.prototype.init.apply(this, arguments);

        const http = this.getManifestEntry("/sap.app/dataSources/http") || {};
        this.setModel(new JSONModel({ endpoint: http.uri || "" }), "start");
      },
    });
  },
);
