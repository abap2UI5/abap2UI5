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
  //
  // Both reach the backend as they did from the classic frontend on the
  // branches standard and cloud, so an app reads the same
  // client->get( )-t_comp_params after a switch to the _new branches: the
  // class as it was given (the backend trims, upper-cases and unpacks a
  // namespace itself), and of a parameter with several values the first one
  // - the launchpad convention the backend applies to the classic frontend's
  // startupParameters (the control would join them into one text instead).
  return function start(componentData, search, defaultApp) {
    const startup = (componentData && componentData.startupParameters) || {};
    const params = {};
    for (const name of Object.keys(startup)) {
      if (name === "app_start") continue;
      const value = [].concat(startup[name])[0];
      if (value != null) params[name] = value;
    }
    const given = (value) => value != null && String(value).trim() !== "";
    const fromLaunchpad = [].concat(startup.app_start || [])[0];
    const fromUrl = new URLSearchParams(search || "").get("app_start");
    const app = [fromLaunchpad, fromUrl, defaultApp].find(given);
    return {
      app: app === undefined ? "" : String(app),
      params: Object.keys(params).length ? params : null,
    };
  };
});
