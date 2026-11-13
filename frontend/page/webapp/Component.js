sap.ui.define(
  ["sap/ui/core/UIComponent", "sap/ui/model/json/JSONModel"],
  (UIComponent, JSONModel) => {
    "use strict";

    // The page the abap2UI5 HTTP service answers a GET with
    // (z2ui5_cl_ui5_http_handler=>_http_get): a component with one view
    // whose one element is a z2ui5.embed.Container
    // (@abap2ui5/embed-control). The control loads the frontend from the
    // node (?z2ui5-bundle) and runs the app in it; everything else comes
    // from the backend. Nothing is decided here: which class starts is the
    // backend's word, handed over as component data (app). What this adds
    // is the one thing only the browser knows - how the page reached the
    // node.
    return UIComponent.extend("abap2ui5.page.Component", {
      metadata: {
        manifest: "json",
        interfaces: ["sap.ui.core.IAsyncContentCreation"],
      },

      init() {
        // The node is the page itself. The one path it answers below
        // itself is the control's stylesheet (<node>/embed/Container.css),
        // so the control's namespace is mapped there - before the view
        // loads the control, which includes the stylesheet when its
        // module runs.
        const node = window.location.pathname.replace(/\/+$/, "");
        sap.ui.loader.config({ paths: { "z2ui5/embed": `${node}/embed` } });

        UIComponent.prototype.init.apply(this, arguments);

        this.setModel(
          new JSONModel({
            app: (this.getComponentData() || {}).app,
            endpoint: node || "/",
          }),
          "start",
        );
      },
    });
  },
);
