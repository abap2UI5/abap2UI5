// z2ui5.embed.Container - runs an abap2UI5 app inside any UI5 app.
//
// This file is the source of the control (it came from the repository
// abap2UI5/embed-control, npm @abap2ui5/embed-control 0.3.0, on 2026-11-13);
// the app next to it is its smallest host, and the page the abap2UI5 HTTP
// service answers a GET with carries both (tools/app2abap/trans2abap.js).
//
//   <mvc:View xmlns:mvc="sap.ui.core.mvc" xmlns:z2ui5="z2ui5.embed">
//     <z2ui5:Container app="Z2UI5_CL_UI5_APP_HI_WORLD" height="400px"/>
//   </mvc:View>
//
// The abap2UI5 frontend - the z2ui5 UIComponent the control wraps - is not
// shipped with the control: it comes from the abap2UI5 service the app talks
// to anyway. Every abap2UI5 installation carries its frontend (embedded in
// the ABAP classes generated from app/webapp), so the frontend always has
// the version of the backend it runs against, and a host app carries nothing
// but this file and its stylesheet.
//
//   GET  <endpoint>?z2ui5-bundle   the frontend as a script, once per page
//   POST <endpoint>                the roundtrips, one session per control
//
// Without the parameter a GET of the endpoint is abap2UI5's own page, as
// always (z2ui5_cl_ui5_http_handler=>_http_get_bundle in abap2UI5).
//
// Everything the app shows and does is decided by the ABAP class on the
// backend. This control only decides WHICH class runs, against WHICH
// endpoint, and how much room it gets. Every instance is its own abap2UI5
// session; changing app, endpoint or params starts a NEW component, restart()
// does too, and destroying the control destroys the component, which ends
// the session.
sap.ui.define(
  [
    "sap/ui/core/Control",
    "sap/ui/core/Component",
    "sap/ui/core/ComponentContainer",
    "sap/ui/dom/includeStylesheet",
    "sap/base/Log",
  ],
  (Control, Component, ComponentContainer, includeStylesheet, Log) => {
    "use strict";

    // the component name - "sap.app/id" of abap2UI5's app/webapp/manifest.json.
    // A bundle that registers the component under a second name as well
    // names it in its z2ui5/embed module (componentName) - abap2UI5
    // 1.147.0: a page whose own component is z2ui5 (the BSP Z2UI5 of
    // abap2UI5's embed app, which a launchpad's target mappings name) has
    // defined z2ui5/Component itself, and the loader would never
    // hand out the frontend's under that name. The control takes the second
    // name whenever the bundle has one, so every page runs the frontend the
    // same way; an older bundle has none, and the frontend runs as z2ui5.
    const COMPONENT = "z2ui5";

    // abap2UI5's own service node - the page, the roundtrips and the bundle
    const DEFAULT_ENDPOINT = "/sap/bc/z2ui5";

    // the URL parameter that asks the node for the bundle instead of the page
    const BUNDLE_PARAM = "z2ui5-bundle";

    // A path on this server - and nothing else. What comes back from it is
    // CODE that runs in this page, so an endpoint naming another host (a
    // scheme, or //host) would hand the page to whoever controls the value -
    // a host that binds the property to a URL parameter, say. The roundtrips
    // have to stay on this origin anyway (abap2UI5's CSRF check).
    //
    // The value is parsed the way the browser parses it, and what is
    // requested is the result - never the raw string. A check on the string
    // misses what the URL parser does to it: it drops tabs and line breaks,
    // so "/\t/evil.example" is //evil.example, and reads a backslash as a
    // slash. A relative path resolves against the page's address. The
    // result is requested as an absolute URL, never as a path, which the
    // browser would resolve against the page's <base> - and that may name
    // another host than the one checked here. Only http(s): a blob: URL
    // carries the origin of the page that made it, a file: page has none to
    // compare, and neither is a path on a server. And no path that begins
    // with //: the parser drops "." and ".." segments, so "/.//evil.example"
    // and "..//evil.example" come out on this origin with the path
    // //evil.example - which is another host wherever that path is used on
    // its own, and a path no server has.
    // Returns the URL - this origin and the path, without a trailing slash -
    // or null when the endpoint is not on this origin, carries a query or a
    // fragment, or its path begins with //.
    function sameOriginUrl(endpoint) {
      let url;
      try {
        url = new URL(endpoint, window.location.href);
      } catch (e) {
        return null;
      }
      if (url.protocol !== "http:" && url.protocol !== "https:") return null;
      if (url.origin !== window.location.origin) return null;
      if (url.search || url.hash) return null;
      if (url.pathname.startsWith("//")) return null;
      return url.origin + (url.pathname.replace(/\/+$/, "") || "/");
    }

    // Why sameOriginUrl refused an endpoint - the reason of componentFailed.
    // One refusal is no other host: a query or a fragment on a path of this
    // server. The control takes neither - the bundle is asked for with a
    // query of its own, and the roundtrips go to the path - and says so,
    // instead of calling a path on this server something else.
    function endpointRefusal(endpoint) {
      let url;
      try {
        url = new URL(endpoint, window.location.href);
      } catch (e) {
        url = null;
      }
      const onThisServer =
        url &&
        (url.protocol === "http:" || url.protocol === "https:") &&
        url.origin === window.location.origin &&
        !url.pathname.startsWith("//");
      return new Error(
        onThisServer && (url.search || url.hash)
          ? `endpoint '${endpoint}' carries a query or a fragment - the ` +
              "control takes a path on this server, without either"
          : `endpoint '${endpoint}' is not a path on this server - the ` +
              "abap2UI5 frontend is only loaded from there",
      );
    }

    // The params as the backend gets them, in the launchpad's shape - one
    // array of values per name; an array is handed over as it is, so one name
    // can carry several values. A value that is no value (null, undefined)
    // is left out: it would reach the app as the text "null" or "undefined";
    // a name left without a value is left out with it. An object - a
    // structure, a nested array - goes over as JSON, which the app can read;
    // String( ) would make it the text "[object Object]". Sorted, so that
    // the same parameters give the same result.
    function startupParameters(params) {
      const result = {};
      for (const name of Object.keys(params || {}).sort()) {
        const value = params[name];
        const values = (Array.isArray(value) ? value : [value])
          .filter((v) => v != null)
          .map((v) => (typeof v === "object" ? JSON.stringify(v) : String(v)));
        if (values.length) result[name] = values;
      }
      return result;
    }

    // Once per page. A stylesheet rather than inline styles, so a host with
    // a strict Content-Security-Policy (no 'unsafe-inline') needs nothing
    // extra for it.
    includeStylesheet(
      sap.ui.require.toUrl("z2ui5/embed/Container.css"),
      "z2ui5-embed-container-css",
    );

    // The frontend is loaded once per page - UI5 has one z2ui5 namespace -
    // from the endpoint of the first control that starts. Every later
    // control uses it and sends its roundtrips to its own endpoint.
    //
    // A <script> element, not the module loader: the bundle is no module of
    // its own path but the answer of the endpoint to a parameter. It
    // registers the frontend's modules (sap.ui.require.preload, functions -
    // nothing is evaluated from a string) and defines z2ui5/embed, which
    // carries what only the installation knows. A logon page, or the page of
    // an abap2UI5 without the bundle, defines no such module: the script
    // either does not run (HTML under nosniff) or runs into nothing, and the
    // check below fails.
    //
    // The check looks the module up and never loads it: once the script
    // has run, the bundle's sap.ui.define has been handed to the loader,
    // which settles a module without dependencies before the next task.
    // Asking the loader for a module nobody defined would make it fetch
    // z2ui5/embed.js, which no app has (z2ui5/embed is the bundle's module;
    // this package lives below it, in z2ui5/embed/), and remember the module
    // as failed for the page's life - a later bundle could never define it.
    //
    // A failed load is forgotten, its script element removed: the next
    // start - a new control, or a change of app, endpoint or params - asks
    // the backend again, which may be back, or the session valid again. The
    // error names the endpoint the load came from (frontendEndpoint): a
    // control that shared the load of another control's endpoint tries its
    // own once (onBeforeRendering), instead of failing for a backend it
    // never talks to.
    let frontend = null;

    // The bundle's module, when the bundle has run on this page - the
    // look-up never loads (see above). A host may have loaded the bundle
    // itself, with a <script> of its page to have it warm before the first
    // control starts: that is the frontend of this page then, and loading
    // it again would only run it a second time, with the loader warning that
    // z2ui5/embed is defined twice.
    function loadedFrontend() {
      const embed = sap.ui.require("z2ui5/embed");
      return embed && embed.componentData ? embed : null;
    }

    function loadFrontend(endpoint) {
      if (!frontend) {
        const loaded = loadedFrontend();
        if (loaded) frontend = Promise.resolve(loaded);
      }
      if (!frontend) {
        frontend = new Promise((resolve, reject) => {
          const url = `${endpoint}?${BUNDLE_PARAM}`;
          const script = document.createElement("script");
          const fail = () => {
            frontend = null;
            script.remove();
            const error = new Error(
              `no abap2UI5 frontend at ${url} - is the service active, ` +
                "the session valid and abap2UI5 recent enough?",
            );
            error.frontendEndpoint = endpoint;
            reject(error);
          };
          script.src = url;
          script.onerror = fail;
          script.onload = () => {
            setTimeout(() => {
              const embed = loadedFrontend();
              if (embed) resolve(embed);
              else fail();
            }, 0);
          };
          document.head.appendChild(script);
        });
      }
      return frontend;
    }

    // UI5 exports every class it creates as a global as well - here
    // window.z2ui5.embed.Container and its renderer. Nothing reads them: the
    // module returns the class, XML views and sap.ui.require take it from
    // there, and the class keeps its renderer. So what the extend adds to
    // window is taken off again below: the control puts nothing on a z2ui5
    // global, which abap2UI5 dropped on purpose (#2777).
    const globalBefore = window.z2ui5;
    const embedBefore = globalBefore && globalBefore.embed;

    const Container = Control.extend("z2ui5.embed.Container", {
      metadata: {
        properties: {
          // The ABAP class to run - it implements z2ui5_if_app, e.g.
          // Z2UI5_CL_UI5_APP_HI_WORLD, which every abap2UI5 installation
          // has. Nothing starts while it is empty - unless the page is the
          // app's (ownsPage): then the page's URL names the class
          // (?app_start=, or a route in the hash), which the frontend sends
          // and the backend reads, and without one the backend starts its
          // start page. The control then hands no class over.
          app: { type: "string", defaultValue: "" },

          // Path of the abap2UI5 HTTP service on this server; empty means
          // DEFAULT_ENDPOINT, /sap/bc/z2ui5. The frontend is loaded from it
          // (the first control on the page decides) and the roundtrips go
          // to it.
          endpoint: { type: "string", defaultValue: "" },

          // Startup parameters for the app, { name: "value", ... } - or
          // { name: ["value", "value"] } for several values of one name.
          // The app reads them with client->get( )-t_comp_params.
          params: { type: "object", defaultValue: null },

          // Hands the page to the app - for a host whose page is this control
          // and nothing else. The app then has what it has on a page of its
          // own: the URL hash (hash routing, set_push_state / hash_replace,
          // browser Back and Forward between routed apps, a route restored on
          // reload), the document title and the favicon, the global busy
          // indicator, the browser's "leave page?" prompt for unsaved
          // changes. Off, all of them are the host's: the app leaves the
          // title, the favicon and the hash alone, is busy on its own area,
          // and raises no prompt for the host's page - right for a host with
          // a page of its own around the control (a Fiori elements object
          // page). One such control per page. abap2UI5 reads it as
          // componentData.ownsPage from 1.147.0 on; the control passes
          // ownsHash with it, which 1.147.0 reads the same way.
          ownsPage: { type: "boolean", defaultValue: false },

          // The older, narrower name of ownsPage: hands the page's URL hash
          // to the app - for a host whose page is
          // this control and nothing else, which routes by nothing. The app
          // then has what it has on a page of its own: hash routing,
          // set_push_state / hash_replace, browser Back and Forward between
          // routed apps, a route restored on reload. Off, the hash is the
          // host's, and the app neither reads nor writes it - right for a
          // host that routes by it (a Fiori elements object page). One such
          // control per page: the hash is page-wide. abap2UI5 reads it as
          // componentData.ownsHash from 1.147.0 on; an
          // older backend ignores it. From 1.147.0 on abap2UI5 hands the
          // whole page over for it, as for ownsPage -
          // its host is the same page.
          ownsHash: { type: "boolean", defaultValue: false },

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
          // it could not be created - the endpoint is not a path on this
          // server, the frontend could not be loaded, or the component failed
          componentFailed: {
            parameters: { reason: { type: "object" } },
          },
        },
      },

      renderer: {
        apiVersion: 2,
        render(rm, control) {
          rm.openStart("div", control);
          // The app's root - sap.m.App up to abap2UI5 1.146.0, and
          // sap.m.Shell in many abap2UI5 views - walks up the DOM from itself and sets height:100% on
          // every ancestor that has none, up to <html>, unless it meets an
          // element marked as root content, the way sap.m.Shell and
          // sap.ui.unified.SplitContainer mark theirs. Unmarked, the app
          // reached through the control into the host's layout - a UI
          // Integration Card grew to the height of the page. This area is
          // the app's screen, so it is the root.
          rm.attr("data-sap-ui-root-content", "true");
          rm.class("z2ui5EmbedContainer");
          rm.style("width", control.getWidth());
          rm.style("height", control.getHeight());
          rm.openEnd();
          const container = control.getAggregation("_container");
          if (container) rm.renderControl(container);
          rm.close("div");
        },
      },

      // The size goes to the DOM, not through a rendering: a re-rendering of
      // the control re-renders the ComponentContainer and with it every
      // control of the app - UI5 1.71 rebuilds their DOM, and a value the
      // user was typing and the focus were gone with the next height change
      // (a host that binds the height to the window size re-rendered the app
      // on every resize). The renderer writes both for the first rendering,
      // and for one the host causes.
      setWidth(value) {
        return this._setSizeProperty("width", value);
      },

      setHeight(value) {
        return this._setSizeProperty("height", value);
      },

      _setSizeProperty(name, value) {
        this.setProperty(name, value, true);
        const dom = this.getDomRef();
        if (dom) dom.style[name] = this.getProperty(name);
        return this;
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

      setOwnsHash(value) {
        return this._setStartProperty("ownsHash", value);
      },

      setOwnsPage(value) {
        return this._setStartProperty("ownsPage", value);
      },

      // Starts the app anew with the current app, endpoint and params: the
      // running session ends, and the next rendering starts a fresh one -
      // the app from scratch, or one more try after componentFailed. A
      // failed start is not repeated by itself (a backend that is down would
      // be asked on every rendering), only by a change of app, endpoint or
      // params, or by this.
      restart() {
        this._dropStart();
        return this;
      },

      // The properties the backend session is started with. A change
      // throws the running component away (which ends its session) and lets
      // the next rendering start a fresh one; a start still under way is
      // dropped, and a component it still creates is destroyed. A destroyed
      // container fires nothing any more, so an event of the replaced app
      // cannot reach the host.
      //
      // A change of what the current start was made of, not of the
      // property: the params by what the backend gets from them, not by
      // identity - a binding hands over a new object whenever the model says
      // it changed (model.refresh(true), a formatter), and the same
      // parameters must not restart the app and lose its state. And a params
      // object the host changed in place is no longer what the running app
      // got, although the property holds it already.
      _setStartProperty(name, value) {
        this.setProperty(name, value);
        if (this._start && this._start.key !== this._startKey()) {
          this._dropStart();
        }
        return this;
      },

      // The running component goes - which ends its session - and so does
      // a start under way (what it still creates is destroyed, see
      // onBeforeRendering); the next rendering starts afresh.
      _dropStart() {
        this.destroyAggregation("_container");
        this._start = null;
        // the same object again does not invalidate by itself
        this.invalidate();
      },

      // What a start is made of: the class, the endpoint as it is requested
      // - resolved, so that "/sap/bc/z2ui5", "/sap/bc/z2ui5/" and a relative
      // path to the same place are one start, not three - and the params as
      // the backend gets them, without an app_start of their own, which the
      // class overrides anyway (_componentData) - and whether the app owns
      // the hash or the page, which only a new component can change.
      _startKey() {
        const params = startupParameters(this.getParams());
        delete params.app_start;
        return JSON.stringify([
          this.getApp(),
          sameOriginUrl(this._endpoint()) || this._endpoint(),
          params,
          this.getOwnsHash() === true,
          this.getOwnsPage() === true,
        ]);
      },

      // The start is asynchronous: the frontend may still have to come from
      // the backend, and the component loads its manifest. The component is
      // created here, not by the ComponentContainer - a container destroyed
      // while its component is still being created hands the late
      // component to nobody, and it lives on with its backend session. A
      // start that is no longer the current one destroys what it made.
      //
      // Every failure reaches the host the same way, from the promise chain
      // after this rendering - a refused endpoint included: a handler that
      // then changes a model or the control does so outside the rendering
      // phase, whichever the failure was.
      onBeforeRendering() {
        // UI5 calls this hook for an invisible control too (it renders a
        // placeholder for it). Nothing starts for an app nobody sees - a
        // backend session for every hidden tab - the rendering that shows
        // the control starts it. An app that runs keeps running while the
        // control is hidden: only a change of app, endpoint or params,
        // restart( ) or the end of the control ends its session.
        if (!this.getVisible()) return;
        // no class to run - unless the page's URL names it (see app)
        if (!this.getApp() && this.getOwnsPage() !== true) return;
        if (this.getAggregation("_container") || this._start) return;
        const start = (this._start = { key: this._startKey() });
        const stale = () => this._exited || this._start !== start;

        const endpoint = sameOriginUrl(this._endpoint());
        const load = endpoint
          ? loadFrontend(endpoint).then(null, (reason) => {
              // The load this control shared came from another control's
              // endpoint and failed; its own may answer - tried once, as a
              // new load (loadFrontend forgot the failed one).
              const other = reason && reason.frontendEndpoint;
              if (other && other !== endpoint && !stale()) {
                return loadFrontend(endpoint);
              }
              throw reason;
            })
          : Promise.reject(endpointRefusal(this._endpoint()));
        load
          .then((embed) =>
            stale() ? null : this._createComponent(embed, endpoint),
          )
          .then(
            (component) => {
              if (!component) return;
              if (stale()) {
                component.destroy();
                return;
              }
              this.setAggregation(
                "_container",
                this._createContainer(component),
              );
              this.fireComponentCreated({ component });
            },
            (reason) => {
              if (!stale()) this.fireComponentFailed({ reason });
            },
          )
          // an error of the host's handler of either event - or, before it,
          // of the container - is logged, instead of ending as an unhandled
          // rejection that nothing attributes to the control
          .catch((error) =>
            Log.error(
              `z2ui5.embed.Container ${this.getId()}: a handler of ` +
                "componentCreated or componentFailed failed",
              String((error && error.stack) || error),
            ),
          );
      },

      exit() {
        this._exited = true;
      },

      _endpoint() {
        return this.getEndpoint() || DEFAULT_ENDPOINT;
      },

      // Created in the owner component of the control, as a
      // ComponentContainer would - the host's component, if there is one.
      //
      // Unless that owner is inactive: a host the launchpad keeps alive
      // (UI5 1.88+) is deactivated when the user leaves it, possibly while
      // the frontend is still loading, and runAsOwner refuses an inactive
      // owner - the app would never start. It starts without the owner
      // then; an error of Component.create itself comes back from that
      // second call and fails the start.
      _createComponent(embed, endpoint) {
        const create = () =>
          Component.create({
            name: embed.componentName || COMPONENT,
            manifest: true,
            // the same as the standalone abap2UI5 page (data-handle-validation)
            handleValidation: true,
            componentData: this._componentData(embed, endpoint),
          });
        const owner = Component.getOwnerComponentFor(this);
        if (owner) {
          try {
            return owner.runAsOwner(create);
          } catch (e) {
            // an inactive owner - see above
          }
        }
        return create();
      },

      _createContainer(component) {
        return new ComponentContainer({
          // the component lives and dies with this container - and so does
          // its backend session
          lifecycle: "Container",
          // the models of the host app stay out of the embedded app, which
          // brings its own
          propagateModel: false,
          width: "100%",
          height: "100%",
          component,
        });
      },

      // The component data of the app:
      //   startupParameters  what the backend reads - app_start picks the
      //                      class (z2ui5_cl_ui5_handler=>request_app_start;
      //                      left out when the control names none),
      //                      every parameter reaches the app as
      //                      client->get( )-t_comp_params. Both in the
      //                      launchpad's shape, one array of values per name
      //   endpoint           the backend URL, read by the frontend and not
      //                      sent on (Component.init in abap2UI5 app/webapp)
      //   ownsPage           only when the host set it: the page is the
      //                      app's (Component.init as well) - with ownsHash
      //                      next to it, which a 1.147.0 backend reads
      //   ownsHash           only when the host set it or ownsPage: the URL
      //                      hash is the app's (Component.init as well)
      //   z2ui5/embed        what the bundle hands over - the installation's
      //                      own settings, the paths of the sibling BSPs
      //                      z2ui5_cci/z2ui5_ccc
      _componentData(embed, endpoint) {
        const parameters = startupParameters(this.getParams());
        if (this.getApp()) parameters.app_start = [this.getApp()];
        else delete parameters.app_start;
        const data = Object.assign({}, embed.componentData, { endpoint });
        if (Object.keys(parameters).length) {
          data.startupParameters = parameters;
        }
        if (this.getOwnsPage() === true) data.ownsPage = true;
        if (this.getOwnsHash() === true || data.ownsPage) data.ownsHash = true;
        return data;
      },
    });

    if (!globalBefore) delete window.z2ui5;
    else if (!embedBefore) delete globalBefore.embed;
    else {
      delete embedBefore.Container;
      delete embedBefore.ContainerRenderer;
    }

    return Container;
  },
);
