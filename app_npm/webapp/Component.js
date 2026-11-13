sap.ui.define(
  ["sap/ui/core/UIComponent", "sap/ui/model/json/JSONModel"],
  (UIComponent, JSONModel) => {
    "use strict";

    // The whole app: one view with one z2ui5.embed.Container in it. The control comes from npm (@abap2ui5/embed-control, served
    // and built under thirdparty/z2ui5/embed/); it loads the abap2UI5
    // frontend from the backend (?z2ui5-bundle) and runs the app in it.
    // Everything else comes from the backend, the class to start included
    // (the backend reads it from the page's URL). Nothing is decided here:
    // the component only says where the backend is.
    //
    // The same app as app_source, which carries the control's source instead.
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

        const http = this.getManifestEntry("/sap.app/dataSources/http") || {};
        this.setModel(new JSONModel({ endpoint: http.uri || "" }), "start");
      },
    });
  },
);
