sap.ui.define(
  ["sap/ui/core/UIComponent", "sap/ui/model/json/JSONModel"],
  (UIComponent, JSONModel) => {
    "use strict";

    // The whole app: one view with one z2ui5.embed.Container
    // (embed/Container.js) in it. The control loads the abap2UI5 frontend
    // from the backend (?z2ui5-bundle) and runs the app in it; everything
    // else comes from the backend, the class to start included (the
    // backend reads it from the page's URL). Nothing is decided here: the
    // component only says where the backend is.
    // The component is z2ui5 - the name launchpad target mappings and links
    // have always named. Only this file and the manifest are below z2ui5/;
    // the view is abap2ui5/page/ (the same folder, sap.ui5/resourceRoots),
    // because z2ui5/ is the frontend's namespace too: the bundle the control
    // loads registers its modules there, and creates its own component under
    // a second name (z2ui5.embed.frontend).
    return UIComponent.extend("z2ui5.Component", {
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
        // It also tells the version of the frontend it serves (bundle), by
        // which the control asks for the bundle - the browser then keeps it.
        const data = this.getComponentData() || {};
        const local = data.checkLocal === true;

        const http = this.getManifestEntry("/sap.app/dataSources/http") || {};
        this.setModel(
          new JSONModel({
            endpoint: local ? window.location.pathname : http.uri || "",
            bundleVersion: local && data.bundle ? String(data.bundle) : "",
          }),
          "start",
        );
      },
    });
  },
);
