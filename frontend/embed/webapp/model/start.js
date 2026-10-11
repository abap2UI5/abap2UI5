sap.ui.define([], () => {
  "use strict";

  // Which abap2UI5 app the page starts, and with which parameters - what the
  // classic frontend read itself, and what this app hands to the control:
  //
  //   launchpad   the intent's parameters (componentData.startupParameters,
  //               one array of values per name): app_start picks the class,
  //               every other one reaches the app as
  //               client->get( )-t_comp_params
  //   standalone  ?app_start= of the page's URL. The URL's other parameters
  //               need nothing from here: the frontend sends the page's
  //               search with every roundtrip, as it always did
  //   neither     sap.ui5/config/defaultApp of the manifest - the start page
  //
  // Only the class and the parameters come from the URL, never the endpoint:
  // the frontend is code, and it is loaded from that endpoint.
  return function start(componentData, search, defaultApp) {
    const startup = (componentData && componentData.startupParameters) || {};
    const params = {};
    for (const name of Object.keys(startup)) {
      if (name !== "app_start") params[name] = startup[name];
    }
    const fromLaunchpad = [].concat(startup.app_start || [])[0];
    const fromUrl = new URLSearchParams(search || "").get("app_start");
    const app = String(fromLaunchpad || fromUrl || defaultApp || "").trim();
    return {
      app: app.toUpperCase(),
      params: Object.keys(params).length ? params : null,
    };
  };
});
