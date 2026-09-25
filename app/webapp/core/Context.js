// The context of ONE z2ui5.Component: everything that was module state
// until 2026-09-23 - the shared frontend state of core/AppState.js and the
// module-scoped records of Server, Session, Router, Shortcuts, ScrollFocus,
// ErrorView and the developer tools - lives on the object created here, so
// two components on one page (a launchpad in keep-alive mode, a host app
// embedding the framework twice) share none of it. Before, every module
// read one singleton, Component.init reset it for whoever came last, and
// the first instance failed later with "App Terminated", far from the
// cause.
//
// How a module finds its context - three anchors, one function (of):
//   the COMPONENT        Component.init creates the context and every
//                        slot view and fragment is built under its
//                        runAsOwner( ) (actions/Slots), so UI5's own
//                        Component.getOwnerComponentFor answers for every
//                        control inside them
//   a CONTROLLER         the five View1 controllers carry `ctx` from the
//                        moment App.controller creates them; every action
//                        handler receives the controller and reads it there
//   a CONTROL            a custom control asks of(this) - the owner
//                        component first, then the parent chain up to a
//                        slot view (registerView), for a control an app
//                        created outside the owner scope
// Everything below a controller or a component takes `ctx` as its first
// argument instead - the modules under core/ never resolve it on their own.
//
// What stays page-wide by nature, and deliberately: the URL hash (every
// routed instance reacts to it - an embedded instance is expected to leave
// routing off), document.title and the favicon, the global BusyIndicator
// and the UI5 messaging facade, the devtools' console capture, the
// unsaved-changes prompt of cc/Dirty and the raw fatal-error overlay (one
// at a time). Lib.logError's ring is a page-wide diagnostic for the same
// reason.
sap.ui.define(["z2ui5/core/AppState"], (AppState) => {
  "use strict";

  // component -> context: the registry `of` reads for a component and for
  // a control whose owner component it is. The component carries the same
  // context as its `ctx` field (Component.init), for a host that holds the
  // component and nothing else - a launchpad, the two-component e2e spec.
  const byComponent = new WeakMap();

  // slot view or fragment -> context, registered by ViewSlots.setView: the
  // fallback of `of` for a control that was not created under the owner
  // scope (an app's own custom control building children by hand), whose
  // parent chain still ends in a slot view.
  const byView = new WeakMap();

  function create(component) {
    const ctx = {
      component: component || null,
      id: typeof component?.getId === "function" ? component.getId() : "",
      // false after destroy( ): what Lib.isControllerAlive and every
      // deferred continuation ask before touching the state
      alive: true,
      state: AppState.createState(),
      // The per-instance module records. Each is documented where it is
      // used; the defaults sit here so a module never bootstraps its own.
      // core/Server.js - the request stamp, the fetches in flight, the
      // serialised MAIN build chain
      server: { requestSeq: 0, inflight: new Set(), viewBuild: null },
      // core/Session.js - the once-per-page-load send latches
      session: {
        configSent: false,
        liveSent: "",
        pending: null,
        locationSent: false,
      },
      // core/Router.js - the restore callback and the hashChanged listener
      router: { navigate: null, hashListener: null },
      // core/actions/Shortcuts.js - the document keydown listener
      shortcuts: { listener: null },
      // core/actions/Variants.js - the variant-init wait chains in flight
      variants: { activeInits: new Set() },
      // core/ScrollFocus.js - the per-element resolution cache
      scroll: { target: undefined, ui5El: undefined, slotKey: undefined },
      // core/ErrorView.js - the last dialog's inputs and the open dialog
      errorView: { title: "", details: "", options: {}, dialog: null },
      // devtools/DevTools.js - the tools instance and its listeners
      devtools: {},
    };
    if (component) byComponent.set(component, ctx);
    return ctx;
  }

  // The end of a context's life (Component.exit): every guard on it reads
  // "dead" from here on, and the state is rebuilt so the views, controllers
  // and the last response are released even where something still holds
  // the context itself.
  function destroy(ctx) {
    if (!ctx) return;
    ctx.alive = false;
    ctx.state = AppState.createState();
    if (ctx.component) byComponent.delete(ctx.component);
  }

  function registerView(ctx, view) {
    if (ctx && view && typeof view === "object") byView.set(view, ctx);
  }

  // Run fn with `ctx.component` as the current owner, so every control
  // created inside - synchronously or in the async continuation of a view
  // or fragment build, which UI5 itself carries the owner into - answers
  // Component.getOwnerComponentFor with it. Runs fn plainly when there is
  // no component (the unit specs).
  function runAsOwner(ctx, fn) {
    const component = ctx?.component;
    if (component && typeof component.runAsOwner === "function") {
      return component.runAsOwner(fn);
    }
    return fn();
  }

  function of(anchor) {
    if (!anchor || typeof anchor !== "object") return null;
    // a controller (App.controller sets it), or anything else that was
    // handed the context and carries it under this name
    if (anchor.ctx && anchor.ctx.state) return anchor.ctx;
    // the component itself
    const own = byComponent.get(anchor);
    if (own) return own;
    // a control created under the owner scope. Resolved through the
    // loader rather than a sap.ui.define dependency: this module has none,
    // so the specs load it without a stub, and the Component module is
    // loaded in every running app.
    const Component = sap.ui.require?.("sap/ui/core/Component");
    if (Component && typeof Component.getOwnerComponentFor === "function") {
      const owner = Component.getOwnerComponentFor(anchor);
      const found = owner && byComponent.get(owner);
      if (found) return found;
    }
    // ... else the parent chain up to a slot view. The tree is finite, but
    // never loop forever on a cyclic parent.
    let node = anchor;
    for (let i = 0; node && i < 200; i++) {
      const found = byView.get(node);
      if (found) return found;
      node = typeof node.getParent === "function" ? node.getParent() : null;
    }
    return null;
  }

  return { create, destroy, registerView, runAsOwner, of };
});
