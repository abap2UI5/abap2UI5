// z2ui5.reuse.Container - runs an abap2UI5 app inside any UI5 app.
//
//   <mvc:View xmlns:z2ui5="z2ui5.reuse">
//     <z2ui5:Container app="Z2UI5_CL_UI5_APP_HI_WORLD" height="400px"/>
//   </mvc:View>
//
// A thin wrapper around a sap.ui.core.ComponentContainer that holds this
// frontend: the z2ui5 UIComponent next door (Component.js). It ships with the
// component - in the npm package @abap2ui5/embed-control, which is app/webapp,
// and in every delivery of the webapp - so a host installs one thing and the
// control and the component it wraps can never be of different releases.
// Nothing in the standalone page or the launchpad loads it; it is here for a
// HOST app that places abap2UI5 apps between its own controls.
//
// Everything the app shows and does - views, popups, events, navigation - is
// decided by the ABAP class on the backend. This control only decides WHICH
// class runs, against WHICH endpoint, and how much room it gets.
//
// Every instance is its own abap2UI5 session, a stateful roundtrip chain on
// the backend. So changing app, endpoint or params starts a NEW component
// rather than patching the running one, and destroying the control destroys
// the component, which ends the backend session (Component#exit).
//
// Written in abap2UI5/embed (formerly test-cc) as @abap2ui5/embed and moved
// here before that package was ever published: a 7 kB wrapper does not earn a
// package, a repository and a version pin of its own.
sap.ui.define(
  [
    "sap/ui/core/Control",
    "sap/ui/core/ComponentContainer",
    "sap/ui/dom/includeStylesheet",
  ],
  (Control, ComponentContainer, includeStylesheet) => {
    "use strict";

    // the component name - "sap.app/id" of manifest.json next door
    const COMPONENT = "z2ui5";

    // Once per page. A stylesheet rather than inline styles, so a host with
    // a strict Content-Security-Policy (no 'unsafe-inline') needs nothing
    // extra for it.
    includeStylesheet(
      sap.ui.require.toUrl("z2ui5/reuse/Container.css"),
      "z2ui5-reuse-container-css",
    );

    return Control.extend("z2ui5.reuse.Container", {
      metadata: {
        properties: {
          // The ABAP class to run - it implements z2ui5_if_app, e.g.
          // Z2UI5_CL_UI5_APP_HI_WORLD, which every abap2UI5 installation
          // has. Nothing starts while it is empty.
          app: { type: "string", defaultValue: "" },

          // URL of the abap2UI5 HTTP service, handed to the component as
          // componentData.endpoint. Empty means the component's own default,
          // /sap/bc/z2ui5 from its manifest. The backend rejects a POST whose
          // Origin is not its own host, so this has to be reachable from the
          // page's origin - a relative path behind the app's proxy, the
          // approuter or the launchpad, not another server's URL.
          endpoint: { type: "string", defaultValue: "" },

          // Startup parameters for the app, { name: "value", ... }. The app
          // reads them with client->get( )-t_comp_params.
          params: { type: "object", defaultValue: null },

          width: { type: "sap.ui.core.CSSSize", defaultValue: "100%" },

          // The embedded app fills its container, so the height has to come
          // from somewhere: set it here, or place the control in a parent
          // with a height of its own.
          height: { type: "sap.ui.core.CSSSize", defaultValue: "100%" },
        },
        aggregations: {
          _container: {
            type: "sap.ui.core.ComponentContainer",
            multiple: false,
            visibility: "hidden",
          },
        },
        events: {
          // the z2ui5 component of the current app has been created
          componentCreated: {
            parameters: { component: { type: "sap.ui.core.UIComponent" } },
          },
          // it could not be created - e.g. the frontend files are not served
          componentFailed: {
            parameters: { reason: { type: "object" } },
          },
        },
      },

      renderer: {
        apiVersion: 2,
        render(rm, control) {
          rm.openStart("div", control);
          rm.class("z2ui5ReuseContainer");
          rm.style("width", control.getWidth());
          rm.style("height", control.getHeight());
          rm.openEnd();
          const container = control.getAggregation("_container");
          if (container) rm.renderControl(container);
          rm.close("div");
        },
      },

      setApp(value) {
        return this._setStartProperty("app", value);
      },

      setEndpoint(value) {
        return this._setStartProperty("endpoint", value);
      },

      setParams(value) {
        return this._setStartProperty("params", value);
      },

      // The three properties the backend session is started with. A change
      // throws the running component away (which ends its session) and lets
      // the next rendering start a fresh one. A destroyed container fires
      // nothing any more, so an event of the replaced app cannot reach the
      // host after the new one started.
      _setStartProperty(name, value) {
        const before = this.getProperty(name);
        this.setProperty(name, value);
        if (this.getProperty(name) !== before) {
          this.destroyAggregation("_container");
        }
        return this;
      },

      onBeforeRendering() {
        if (this.getApp() && !this.getAggregation("_container")) {
          // suppress the invalidation: this rendering is about to render it
          this.setAggregation("_container", this._createContainer(), true);
        }
      },

      _createContainer() {
        return new ComponentContainer({
          name: COMPONENT,
          manifest: true,
          async: true,
          // the component lives and dies with this container - and so does
          // its backend session
          lifecycle: "Container",
          // the models of the host app stay out of the embedded app, which
          // brings its own
          propagateModel: false,
          // the same as the standalone abap2UI5 page (data-handle-validation)
          handleValidation: true,
          width: "100%",
          height: "100%",
          settings: { componentData: this._componentData() },
          componentCreated: (event) => {
            this.fireComponentCreated({
              component: event.getParameter("component"),
            });
          },
          componentFailed: (event) => {
            this.fireComponentFailed({ reason: event.getParameter("reason") });
          },
        });
      },

      // The component data of the app:
      //   startupParameters  what the backend reads - app_start picks the
      //                      class (z2ui5_cl_ui5_handler=>request_app_start),
      //                      every parameter reaches the app as
      //                      client->get( )-t_comp_params. Both in the
      //                      launchpad's shape, one array of values per name
      //   endpoint           the backend URL, read by the frontend and not
      //                      sent on (Component.init in abap2UI5 app/webapp)
      _componentData() {
        const startupParameters = {};
        for (const [name, value] of Object.entries(this.getParams() || {})) {
          startupParameters[name] = [String(value)];
        }
        startupParameters.app_start = [this.getApp()];
        const endpoint = this.getEndpoint();
        return endpoint
          ? { startupParameters, endpoint }
          : { startupParameters };
      },
    });
  },
);
