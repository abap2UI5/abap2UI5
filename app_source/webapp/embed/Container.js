// z2ui5.embed.Container - runs an abap2UI5 app inside any UI5 app.
//
//   <mvc:View xmlns:mvc="sap.ui.core.mvc" xmlns:z2ui5="z2ui5.embed">
//     <z2ui5:Container app="Z2UI5_CL_UI5_APP_HI_WORLD" height="400px"/>
//   </mvc:View>
//
// One way for every host: a freestyle app, a custom page or a custom section
// of Fiori elements, and abap2UI5's own page (the app next to this file).
//
// The control is a shell. It loads the abap2UI5 frontend from the backend the
// app talks to anyway,
//
//   GET  <endpoint>?z2ui5-bundle   the frontend as a script, once per page
//   POST <endpoint>                the roundtrips, one session per control
//
// asks the bundle for the app (the create( ) of its z2ui5/embed module) and
// renders what comes back. How the app is created - its component, its
// component data, its styles - is the bundle's, so it always fits the
// backend it came from, and nothing of it is decided here. What is left here
// is what has to happen before there is a bundle: where it may be loaded
// from, loading it, and when an app starts and ends.
//
// Every instance is its own abap2UI5 session; changing app, endpoint, params
// or ownsPage starts a NEW one, restart() does too, and destroying the
// control ends it.
//
// This file is the source of the control (it came from the repository
// abap2UI5/embed-control, npm @abap2ui5/embed-control 0.3.0, on 2026-11-13).
// It needs a backend whose bundle has create( ) - see the package's README.
sap.ui.define(["sap/ui/core/Control", "sap/base/Log"], (Control, Log) => {
  "use strict";

  // abap2UI5's own service node - the page, the roundtrips and the bundle
  const DEFAULT_ENDPOINT = "/sap/bc/z2ui5";

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
  // slash. The result is requested as an absolute URL, never as a path,
  // which the browser would resolve against the page's <base>. Only
  // http(s), and no path that begins with //: the parser drops "." and
  // ".." segments, so "/.//evil.example" comes out on this origin with the
  // path //evil.example - another host wherever that path is used on its
  // own. No query and no fragment: the bundle is asked for with a query of
  // its own, and the roundtrips go to the path.
  // Returns the URL - this origin and the path, without a trailing slash -
  // or null.
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

  // The bundle's module, when the bundle has run on this page. A look-up
  // that never loads: asking the loader for a module nobody defined would
  // make it fetch z2ui5/embed.js, which no app has, and remember the module
  // as failed for the page's life - a later bundle could never define it.
  // A logon page, or an abap2UI5 whose bundle has no create( ), answers
  // with nothing this finds.
  function loadedFrontend() {
    const embed = sap.ui.require("z2ui5/embed");
    return embed && typeof embed.create === "function" ? embed : null;
  }

  // The frontend is loaded once per page - UI5 has one z2ui5 namespace -
  // from the endpoint of the first control that starts; every later control
  // uses it and sends its roundtrips to its own endpoint. A <script>
  // element, not the module loader: the bundle is the answer of the
  // endpoint to a parameter, no module of its own path. A failed load is
  // forgotten, its script element removed, so the next start asks the
  // backend again.
  let frontend = null;

  function loadFrontend(endpoint, version) {
    if (!frontend && loadedFrontend()) {
      frontend = Promise.resolve(loadedFrontend());
    }
    if (!frontend) {
      frontend = new Promise((resolve, reject) => {
        const url =
          `${endpoint}?z2ui5-bundle` +
          (version ? `=${encodeURIComponent(version)}` : "");
        const script = document.createElement("script");
        const fail = () => {
          frontend = null;
          script.remove();
          reject(
            new Error(
              `no abap2UI5 frontend at ${url} - is the service active, ` +
                "the session valid and abap2UI5 recent enough?",
            ),
          );
        };
        script.src = url;
        script.onerror = fail;
        // the bundle's module settles in the task after the script ran
        script.onload = () =>
          setTimeout(() => {
            const embed = loadedFrontend();
            if (embed) resolve(embed);
            else fail();
          }, 0);
        document.head.appendChild(script);
      });
    }
    return frontend;
  }

  // UI5 1.x exports every class it creates as a global as well - here
  // window.z2ui5.embed.Container and its renderer. Nothing reads them, so
  // what the extend adds to window is taken off again below: the control
  // puts nothing on a z2ui5 global, which abap2UI5 dropped on purpose.
  /* ui5lint-disable no-project-globals --
     the two reads of window.z2ui5 in this file are how the control keeps
     the global AWAY: it looks at what UI5 put there and takes it off */
  const globalBefore = window.z2ui5;
  /* ui5lint-enable no-project-globals */
  const embedBefore = globalBefore && globalBefore.embed;

  const Container = Control.extend("z2ui5.embed.Container", {
    metadata: {
      properties: {
        // The ABAP class to run - it implements z2ui5_if_app. Nothing
        // starts while it is empty - unless the page is the app's
        // (ownsPage): then the page's URL names the class (?app_start=, or
        // a route in the hash), and without one the backend starts its
        // start page.
        app: { type: "string", defaultValue: "" },

        // Path of the abap2UI5 HTTP service on this server; empty means
        // /sap/bc/z2ui5. The frontend is loaded from it (the first control
        // on the page decides) and the roundtrips go to it.
        endpoint: { type: "string", defaultValue: "" },

        // Startup parameters for the app, { name: "value", ... } - or
        // { name: ["value", "value"] } for several values of one name. The
        // app reads them with client->get( )-t_comp_params.
        params: { type: "object", defaultValue: null },

        // Hands the page to the app - for a host whose page is this control
        // and nothing else. The app then has what it has on a page of its
        // own: the URL hash, the document title and the favicon, the global
        // busy indicator, the browser's "leave page?" prompt. Off, all of
        // them are the host's - right for a host with a page of its own
        // around the control (a Fiori elements object page). One such
        // control per page.
        ownsPage: { type: "boolean", defaultValue: false },

        // The version of the frontend bundle, when the host knows it - the
        // backend's own page does, it is told with the page. The bundle is
        // then asked for by it (?z2ui5-bundle=<version>), and the backend
        // lets the browser keep that answer without asking again. Empty,
        // the browser revalidates the bundle on every page load. It only
        // names what is loaded: a change starts nothing anew.
        bundleVersion: { type: "string", defaultValue: "" },

        width: { type: "sap.ui.core.CSSSize", defaultValue: "100%" },

        // The embedded app fills its area, so the height has to come from
        // somewhere: set it here, or place the control in a parent with a
        // height of its own.
        height: { type: "sap.ui.core.CSSSize", defaultValue: "100%" },
      },
      aggregations: {
        // what the bundle's create( ) handed back - the app
        _app: {
          type: "sap.ui.core.Control",
          multiple: false,
          visibility: "hidden",
        },
      },
      events: {
        // the component of the current app has been created
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
        // The app's root - a sap.m.Shell in many abap2UI5 views - walks up
        // the DOM from itself and sets height:100% on every ancestor that
        // has none, up to <html>, unless it meets an element marked as
        // root content. This area is the app's screen, so it is the root.
        rm.attr("data-sap-ui-root-content", "true");
        // the bundle's style for the area hangs on this class
        rm.class("z2ui5EmbedContainer");
        // the app's root and its absolutely positioned pages stay inside
        // the area the host gave the control
        rm.style("position", "relative");
        rm.style("overflow", "hidden");
        rm.style("width", control.getWidth());
        rm.style("height", control.getHeight());
        rm.openEnd();
        const app = control.getAggregation("_app");
        if (app) rm.renderControl(app);
        rm.close("div");
      },
    },

    // The size goes to the DOM, not through a rendering: a re-rendering of
    // the control re-renders every control of the app - UI5 1.71 rebuilds
    // their DOM, and a value the user was typing and the focus were gone
    // with the next height change (a host that binds the height to the
    // window size, a Fiori elements section that resizes).
    setWidth(value) {
      return this._setSize("width", value);
    },

    setHeight(value) {
      return this._setSize("height", value);
    },

    _setSize(name, value) {
      this.setProperty(name, value, true);
      const dom = this.getDomRef();
      if (dom) dom.style[name] = this.getProperty(name);
      return this;
    },

    setApp(value) {
      return this._setStart("app", value);
    },

    setEndpoint(value) {
      return this._setStart("endpoint", value);
    },

    setParams(value) {
      return this._setStart("params", value);
    },

    setOwnsPage(value) {
      return this._setStart("ownsPage", value);
    },

    // Starts the app anew with the current properties: the running session
    // ends, and the next rendering starts a fresh one - the app from
    // scratch, or one more try after componentFailed. A failed start is not
    // repeated by itself (a backend that is down would be asked on every
    // rendering), only by a change of a start property, or by this.
    restart() {
      this.destroyAggregation("_app");
      this._start = null;
      // the same property values again do not invalidate by themselves
      this.invalidate();
      return this;
    },

    // A change of what the current start was made of throws the running app
    // away, which ends its session - not a change of the property alone: a
    // binding hands over a new params object whenever the model says it
    // changed, and the same parameters must not restart the app and lose
    // its state.
    _setStart(name, value) {
      this.setProperty(name, value);
      if (this._start && this._start.key !== this._startKey()) this.restart();
      return this;
    },

    _startKey() {
      return JSON.stringify([
        this.getApp(),
        sameOriginUrl(this._endpoint()) || this._endpoint(),
        this.getParams(),
        this.getOwnsPage() === true,
      ]);
    },

    _endpoint() {
      return this.getEndpoint() || DEFAULT_ENDPOINT;
    },

    // The start is asynchronous: the frontend may still have to come from
    // the backend, and the component loads its manifest. A start that is no
    // longer the current one destroys what it made. Every failure reaches
    // the host the same way, from the promise chain after this rendering.
    onBeforeRendering() {
      // UI5 calls this hook for an invisible control too. Nothing starts
      // for an app nobody sees - a backend session for every hidden tab -
      // the rendering that shows the control starts it.
      if (!this.getVisible()) return;
      // no class to run - unless the page's URL names it (see app)
      if (!this.getApp() && this.getOwnsPage() !== true) return;
      if (this.getAggregation("_app") || this._start) return;
      const start = (this._start = { key: this._startKey() });
      const stale = () => this._exited || this._start !== start;

      const endpoint = sameOriginUrl(this._endpoint());
      const load = endpoint
        ? loadFrontend(endpoint, this.getBundleVersion())
        : Promise.reject(
            new Error(
              `endpoint '${this._endpoint()}' is not a path on this server, ` +
                "without a query or a fragment - the abap2UI5 frontend is " +
                "only loaded from there",
            ),
          );
      load
        .then((embed) =>
          stale()
            ? null
            : embed.create({
                app: this.getApp(),
                endpoint,
                params: this.getParams(),
                ownsPage: this.getOwnsPage() === true,
                host: this,
              }),
        )
        .then(
          (app) => {
            if (!app) return;
            if (stale()) {
              app.destroy();
              return;
            }
            this.setAggregation("_app", app);
            this.fireComponentCreated({
              component: app.getComponentInstance(),
            });
          },
          (reason) => {
            if (!stale()) this.fireComponentFailed({ reason });
          },
        )
        // an error of the host's handler of either event is logged, instead
        // of ending as an unhandled rejection nothing attributes to the
        // control
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
  });

  /* ui5lint-disable-next-line no-project-globals -- see globalBefore */
  if (!globalBefore) delete window.z2ui5;
  else if (!embedBefore) delete globalBefore.embed;
  else {
    delete embedBefore.Container;
    delete embedBefore.ContainerRenderer;
  }

  return Container;
});
