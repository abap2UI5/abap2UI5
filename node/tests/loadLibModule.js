// @ts-check
// Loads the real app/webapp/core/Lib.js (and, via loadEnv, core/Env.js on
// top of it) through the generic loadModule helper (stubbed
// sap.ui.define), so the specs exercise the shipped implementation instead
// of a copy that could silently drift from the production code.
const { loadModule } = require("./loadModule");

// The context a spec's Lib runs in. The frontend state is per component
// (core/Context.js); a spec gets ONE context, built with the real
// AppState.createState( ) defaults plus the fields it seeds, and a Context
// stub whose `of( )` answers that one context for every anchor - the way the
// one component of a page owns every control in it. `state` is that
// context's state, the object the spec seeded (so its later writes are
// seen), `ctx` the context itself for the helpers that take one.
function specContext(seed = {}) {
  const { module: AppState } = loadModule("core/AppState.js");
  // the seed object IS the state - the spec keeps its own reference and
  // reads its later writes off it - filled up with the defaults it left out
  const state = seed;
  for (const [key, value] of Object.entries(AppState.createState())) {
    if (!(key in state)) state[key] = value;
  }
  return {
    component: null,
    id: "",
    alive: true,
    state,
    server: { requestSeq: 0, inflight: new Set(), viewBuild: null },
    session: {
      configSent: false,
      liveSent: "",
      pending: null,
      locationSent: false,
    },
    router: { navigate: null, hashListener: null },
    shortcuts: { listener: null },
    scroll: { target: undefined, ui5El: undefined, slotKey: undefined },
    errorView: { title: "", details: "", options: {}, dialog: null },
    devtools: {},
  };
}

// The Context stub around one spec context: every anchor resolves to it,
// runAsOwner runs the function plainly (no component), the rest is inert.
function contextStub(ctx) {
  return {
    of: () => ctx,
    create: () => ctx,
    destroy: (c) => {
      c.alive = false;
    },
    registerView: () => {},
    runAsOwner: (_c, fn) => fn(),
  };
}

function loadLib(overrides = {}) {
  const { state: seed = {}, ctx: given, ...rest } = overrides;
  const ctx = given || specContext(seed);
  const { module, sandbox } = loadModule("core/Lib.js", {
    deps: {
      "z2ui5/core/Context": contextStub(ctx),
    },
    sandbox: {
      // window.location.origin anchors relative URL resolution.
      window: { location: { origin: "http://localhost:3000" } },
      ...rest,
    },
  });
  // Lib.logError's ring is page-wide (Lib.errors), not a state field any
  // more; the specs that read the log off the state keep doing so through
  // this alias of the very same array.
  Object.defineProperty(ctx.state, "errors", {
    value: module.errors,
    enumerable: false,
    configurable: true,
  });
  return { Lib: module, sandbox, state: ctx.state, ctx, Context: contextStub(ctx) };
}

// core/Env.js - the UI5-release compatibility layer - over a real Lib that
// shares the same context. `sandbox` is ENV's module sandbox: that is where
// the probes read sap.ui.version / sap.ui.require / sap.ui.getCore, so a
// spec seeds or re-seeds those there.
function loadEnv(overrides = {}) {
  const { elements = {}, state = {}, ...rest } = overrides;
  const { Lib, ctx } = loadLib({ state });
  // Env.getElementById resolves control ids through sap.ui.core.Element;
  // the stub's registry lets a spec register elements to resolve.
  const Element = { getElementById: (sId) => elements[sId] || null };
  const { module, sandbox } = loadModule("core/Env.js", {
    deps: {
      "sap/ui/core/Element": Element,
      "z2ui5/core/Lib": Lib,
    },
    sandbox: rest,
  });
  return { Env: module, Lib, sandbox, state: ctx.state, ctx };
}

// A module whose functions take the context FIRST, bound to one spec
// context for the names given: `bound.getView("MAIN")` calls
// `module.getView(ctx, "MAIN")`. The other exports are handed through
// unchanged, so a spec written against the pre-context signatures keeps
// reading the way it did; what the binding adds is on record in
// context.spec.js, which drives the real signatures directly. Bound with
// `this` = the module, for the modules whose methods call each other
// through `this` (core/Server.js).
function bindContext(module, ctx, names) {
  const bound = { ...module };
  for (const name of names) {
    bound[name] = (...args) => module[name].call(module, ctx, ...args);
  }
  return bound;
}

// Action handlers take the calling controller first and read the context
// off it (`oController.ctx`). The handler specs pass `null` or a bare
// fixture there; this hands every handler a controller that carries the
// spec's context - the fixture itself when it already is one (its own
// fields, such as isDestroyed, stay), else a fresh one.
function withSpecController(handlers, ctx) {
  const carrying = (oController) => {
    if (oController && typeof oController === "object") {
      if (!oController.ctx) oController.ctx = ctx;
      return oController;
    }
    return { ctx };
  };
  const wrapped = Object.create(null);
  for (const name of Object.keys(handlers)) {
    wrapped[name] = (oController, ...args) =>
      handlers[name](carrying(oController), ...args);
  }
  return { handlers: wrapped, carrying };
}

module.exports = {
  loadLib,
  loadEnv,
  specContext,
  contextStub,
  bindContext,
  withSpecController,
};
