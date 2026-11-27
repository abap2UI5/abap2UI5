sap.ui.define(
  ["sap/ui/core/UIComponent", "sap/ui/model/json/JSONModel", "sap/base/Log"],
  (UIComponent, JSONModel, Log) => {
    "use strict";

    // What the page says when the app could not be started. The control
    // reports a failed start only through its componentFailed event - the
    // endpoint is no path on this server, the bundle did not load (an
    // inactive ICF node, an expired launchpad session that answers with the
    // logon page, a proxy that blocks ?z2ui5-bundle), or the bundle could not
    // create the app. Nobody listened to it, so each of them was an empty
    // page and nothing in the console.
    //
    // There is no timeout: the control has no option for one, and a request
    // for the bundle that never answers fires no componentFailed at all. The
    // page stays empty until the browser gives the request up - its own
    // network timeout, minutes - and only then does this run.
    //
    // A sap.m.MessagePage when sap.m can be loaded - required here, at the
    // point of use, not as a dependency: the page needs nothing of sap.m
    // otherwise, and on 1.71 a dependency that cannot be loaded takes the
    // component down with it. Plain text in the control's area when it
    // cannot (the same expired session may keep the UI5 resources away).
    const TITLE = "abap2UI5 could not be started";
    const HINT = "Reload the page to try again.";

    function reasonText(reason) {
      return String((reason && reason.message) || reason || "unknown error");
    }

    function showPlain(container, text) {
      const dom = container.getDomRef();
      if (!dom) return;
      const box = document.createElement("div");
      box.setAttribute("role", "alert");
      box.style.padding = "2rem";
      box.style.fontFamily = "sans-serif";
      const head = document.createElement("h1");
      head.style.fontSize = "1.25rem";
      head.textContent = TITLE;
      const body = document.createElement("p");
      body.textContent = `${text} ${HINT}`;
      box.appendChild(head);
      box.appendChild(body);
      while (dom.firstChild) dom.removeChild(dom.firstChild);
      dom.appendChild(box);
    }

    // Into the control's own area, which stays empty after a failed start:
    // an XML view renders the controls of its XML, not one added to it
    // later, and the control starts nothing again by itself (only a restart
    // or a changed start property would render its area anew).
    function startFailed(container, reason) {
      const text = reasonText(reason);
      Log.error(
        `${TITLE}: ${text}`,
        String((reason && reason.stack) || ""),
        "z2ui5.Component",
      );
      sap.ui.require(
        /* ui5lint-disable-next-line no-deprecated-api --
           its successor, sap.m.IllustratedMessage, arrived in 1.98; the page
           runs on 1.71 */
        ["sap/m/MessagePage"],
        (MessagePage) => {
          const dom = container.getDomRef();
          if (!dom) return;
          // a UI area of its own, in an element of its own - the control's
          // element is the control's
          const area = document.createElement("div");
          area.id = `${container.getId()}-failed`;
          area.style.height = "100%";
          dom.appendChild(area);
          new MessagePage({
            showHeader: false,
            text: TITLE,
            description: `${text} ${HINT}`,
            icon: "sap-icon://message-error",
          }).placeAt(area);
        },
        () => showPlain(container, text),
      );
    }

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

      // The root view, to listen to its control. Not in init: UI5 creates
      // the root control after init has run. createContent hands the view
      // back on 1.71 and a promise of it where IAsyncContentCreation is
      // understood (1.89 on); either way its XML is still loading, which
      // loaded() waits for - before the control's first rendering, so before
      // a start can have failed.
      createContent() {
        const root = UIComponent.prototype.createContent.apply(this, arguments);
        Promise.resolve(root)
          .then((view) => view && view.loaded())
          .then((view) => {
            const container = view && view.byId("container");
            if (!container) return;
            container.attachComponentFailed((event) =>
              startFailed(container, event.getParameter("reason")),
            );
          })
          .catch((e) =>
            Log.error(
              "the page's view could not be prepared",
              String(e),
              "z2ui5.Component",
            ),
          );
        return root;
      },
    });
  },
);
