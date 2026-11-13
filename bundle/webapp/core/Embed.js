sap.ui.define(
  ["sap/ui/core/Component", "sap/ui/core/ComponentContainer"],
  (Component, ComponentContainer) => {
    "use strict";

    // How the frontend is put into a host - a freestyle app, a custom page or
    // a custom section of Fiori elements, the backend's own page: all of them
    // hold one z2ui5.embed.Container (app_source/webapp/embed), and all of it
    // is decided here, in the bundle, so that the control stays a shell that
    // loads the bundle and renders what create( ) hands back. The control
    // reaches this module through the z2ui5/embed module of the bundle
    // (z2ui5_cl_ui5_http_handler=>_http_get_bundle), whose create( ) calls
    // the one below with what only the installation knows.
    //
    // What a host decides travels as `settings`:
    //   app        the ABAP class to run; none when the page is the app's and
    //              its URL names the class (ownsPage)
    //   endpoint   the backend URL, as the control resolved and checked it
    //   params     startup parameters of the app, { name: value | [values] }
    //   ownsPage   the page is this app and nothing else
    //   host       the control the app is rendered in - its owner component
    //              becomes the app component's owner

    // The class of the area the control renders (its renderer writes it).
    const AREA = "z2ui5EmbedContainer";

    // sap.m.Shell - the root of many abap2UI5 views, the hello world app's
    // too - limits the app width by a media query on the VIEWPORT: from
    // 1280px on, html.sap-desktop .sapMShellAppWidthLimited
    // .sapMShellCentralBox is 1280px wide and centered with left: 50% and a
    // negative margin. Inside an area narrower than the viewport that pushes
    // the app out to the left. There the area is the "screen", so the box
    // fills it. The selector has to outweigh sap.m's (0,3,1), hence the
    // doubled Shell class: (0,4,0). It was the control's stylesheet
    // (Container.css) until 2026-11-13.
    const STYLE =
      `.${AREA} .sapMShell.sapMShellAppWidthLimited .sapMShellCentralBox ` +
      "{ left: 0; margin-left: 0; width: 100%; }";
    const STYLE_ID = "z2ui5-embed-style";

    // Once per page. A constructed stylesheet where the browser has them -
    // no element a Content-Security-Policy could refuse - and a <style>
    // element before that (Safari up to 16.3).
    function installStyle() {
      if (document.getElementById(STYLE_ID)) return;
      const marker = document.createElement("meta");
      marker.id = STYLE_ID;
      document.head.appendChild(marker);
      try {
        const sheet = new CSSStyleSheet();
        sheet.replaceSync(STYLE);
        document.adoptedStyleSheets = [...document.adoptedStyleSheets, sheet];
      } catch (e) {
        const style = document.createElement("style");
        style.textContent = STYLE;
        document.head.appendChild(style);
      }
    }

    // The params as the backend gets them, in the launchpad's shape - one
    // array of values per name; an array is handed over as it is, so one
    // name can carry several values. A value that is no value (null,
    // undefined) is left out: it would reach the app as the text "null" or
    // "undefined"; a name left without a value is left out with it. An
    // object - a structure, a nested array - goes over as JSON, which the
    // app can read; String( ) would make it the text "[object Object]".
    // Sorted, so that the same parameters give the same result. app_start
    // is the class the host named (z2ui5_cl_ui5_handler=>request_app_start
    // reads it) and never a parameter of its own.
    function startupParameters(params, app) {
      const result = {};
      for (const name of Object.keys(params || {}).sort()) {
        if (name === "app_start") continue;
        const value = params[name];
        const values = (Array.isArray(value) ? value : [value])
          .filter((v) => v != null)
          .map((v) => (typeof v === "object" ? JSON.stringify(v) : String(v)));
        if (values.length) result[name] = values;
      }
      if (app) result.app_start = [app];
      return result;
    }

    // What the host itself was started with - a launchpad tile's parameters
    // (componentData.startupParameters of the host's component, one array of
    // values per name). They are the app's when the page is the app's
    // (ownsPage: the host is the control and nothing else - the app every
    // delivery of abap2UI5 starts with), and only then: the parameters of a
    // Fiori elements app are that app's, not its section's. app_start picks
    // the class when the control names none, every other one reaches the app
    // as client->get( )-t_comp_params - of several values the first, the
    // launchpad convention the backend has always applied. What the host
    // set on the control wins.
    function withHostStart(settings) {
      if (settings.ownsPage !== true || !settings.host) return settings;
      const owner = Component.getOwnerComponentFor(settings.host);
      const data = owner && owner.getComponentData && owner.getComponentData();
      const startup = (data && data.startupParameters) || {};
      const first = (name) => [].concat(startup[name])[0];
      const params = {};
      for (const name of Object.keys(startup)) {
        if (name !== "app_start" && first(name) != null) {
          params[name] = first(name);
        }
      }
      const app = settings.app || first("app_start") || "";
      return Object.assign({}, settings, {
        app: String(app),
        params: Object.assign(params, settings.params),
      });
    }

    // The component data of the app (Component.init reads it):
    //   the installation's own   embedded, nodePath, the paths of the
    //                            sibling BSPs z2ui5_cci / z2ui5_ccc
    //   startupParameters        what the backend reads - left out when
    //                            there are none
    //   endpoint                 the backend URL
    //   ownsPage                 only when the host set it
    function componentData(settings, installation) {
      const data = Object.assign({}, installation.componentData, {
        endpoint: settings.endpoint,
      });
      const parameters = startupParameters(settings.params, settings.app);
      if (Object.keys(parameters).length) data.startupParameters = parameters;
      if (settings.ownsPage === true) data.ownsPage = true;
      return data;
    }

    // Created in the owner component of the host control, as a
    // ComponentContainer would - the host's component, if there is one.
    //
    // Unless that owner is inactive: a host the launchpad keeps alive (UI5
    // 1.88+) is deactivated when the user leaves it, possibly while the
    // frontend is still loading, and runAsOwner refuses an inactive owner -
    // the app would never start. It starts without the owner then; an error
    // of Component.create itself comes back from that second call and fails
    // the start.
    function createComponent(settings, installation) {
      const create = () =>
        Component.create({
          // the second name the bundle registers the component under
          // (BUNDLE_CLOSE in tools/app2abap/trans2abap.js): a host whose own
          // component is z2ui5 has the first one taken
          name: installation.componentName,
          manifest: true,
          handleValidation: true,
          componentData: componentData(settings, installation),
        });
      const owner =
        settings.host && Component.getOwnerComponentFor(settings.host);
      if (owner) {
        try {
          return owner.runAsOwner(create);
        } catch (e) {
          // an inactive owner - see above
        }
      }
      return create();
    }

    return {
      startupParameters,
      componentData,
      withHostStart,

      // The app as a control for the host to render: a ComponentContainer
      // around a new component - a new backend session. The component lives
      // and dies with the container, and the models of the host stay out of
      // the app, which brings its own.
      create(settings, installation) {
        installStyle();
        return Promise.resolve(
          createComponent(withHostStart(settings), installation),
        ).then(
          (component) =>
            new ComponentContainer({
              lifecycle: "Container",
              propagateModel: false,
              width: "100%",
              height: "100%",
              component,
            }),
        );
      },
    };
  },
);
