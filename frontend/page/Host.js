sap.ui.define(["sap/ui/util/Mobile"], (Mobile) => {
  "use strict";

  // The page the abap2UI5 service answers a GET with
  // (z2ui5_cl_ui5_http_handler=>_http_get) is a host like any other: one
  // z2ui5.embed.Container (@abap2ui5/embed-control) filling the page, which
  // loads the frontend from the node the page came from (?z2ui5-bundle) and
  // runs the app in it. The page carries this module and the control in its
  // one inline script and nothing of the frontend - the same way the
  // abap2UI5/frontend branches standard_new and cloud_new start it
  // (frontend/embed), so there is one way the frontend starts.
  //
  // Not below app/ on purpose: app/webapp/ is the frontend and goes into
  // the bundle, and app/ as a whole is the project the branches cloud and
  // cloud_v2 ship. tools/app2abap/trans2abap.js embeds this file as
  // z2ui5_cl_ui5f_host_js and the control from node_modules.
  //
  // The module id is abap2ui5/page/Host: z2ui5/ is the frontend's namespace
  // and z2ui5/embed/ the control's, and a module of the page below either
  // could meet one of the bundle's under the same name.

  // the app a page without ?app_start= starts - the start page
  const DEFAULT_APP = "Z2UI5_CL_UI5_APP_START";

  // the control's namespace, and the DOM element of the page it goes into
  const CONTROL = "z2ui5/embed";
  const AREA = "container";

  // Which class the page starts: ?app_start= of its URL, the name in any
  // case as the backend reads it (url_param_get lower-cases the names), the
  // value as it was given - the backend trims, upper-cases and unpacks a
  // namespace itself. The control always hands a class over
  // (startupParameters.app_start, which the backend reads before the URL),
  // so a page without the parameter names the start page here. A route in
  // the hash (#/app/<CLASS>) still wins on the backend: the page is the
  // app's (ownsPage), and the frontend sends the hash.
  function appStart(search) {
    for (const [name, value] of new URLSearchParams(search || "")) {
      if (name.toLowerCase() === "app_start" && value.trim() !== "") {
        return value;
      }
    }
    return DEFAULT_APP;
  }

  // The control shows nothing when the app cannot start - the bundle not
  // loaded, the component failed. Say so instead of a blank page.
  function showFailed(reason) {
    const text = `abap2UI5 could not start: ${(reason && reason.message) || reason}`;
    sap.ui.require(["sap/m/MessageStrip"], (MessageStrip) => {
      new MessageStrip({ type: "Error", showIcon: true, text })
        .addStyleClass("sapUiSmallMargin")
        .placeAt(AREA, "first");
    });
  }

  return {
    appStart,

    start() {
      // The node the page came from is the endpoint: the bundle is loaded
      // from it and the roundtrips go to it. Its path only - the control
      // takes a path on this server, without a query.
      const endpoint = window.location.pathname;

      // The page's mobile setup, once per page with the settings of
      // whoever comes first: the full one here, as on any page of the
      // app's own - the embedded frontend leaves it to its host
      // (Component.init of app/webapp).
      Mobile.init();

      // The control includes its stylesheet from its own namespace
      // (z2ui5/embed/Container.css). The namespace is mapped below the
      // node, where the handler answers that one path with the stylesheet
      // (_http_get_control_css) - every other GET of the node is the page.
      // Nothing else is fetched from the namespace: the control's module
      // is in the page's preload, the frontend's in the bundle's. Before
      // the control is required - it includes the stylesheet when its
      // module runs.
      sap.ui.loader.config({
        paths: { [CONTROL]: `${endpoint.replace(/\/+$/, "")}/embed` },
      });

      sap.ui.require([`${CONTROL}/Container`], (Container) => {
        new Container({
          app: appStart(window.location.search),
          endpoint,
          // the page is the control and nothing else, so the page is the
          // app's: the hash, the title, the favicon, the busy indicator,
          // the "leave page?" prompt
          ownsPage: true,
          height: "100%",
          componentFailed: (event) => showFailed(event.getParameter("reason")),
        }).placeAt(AREA);
      });
    },
  };
});
