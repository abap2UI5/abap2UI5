// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");
const { specContext, contextStub } = require("./loadLibModule");

// Page transitions of the MAIN view - view_display( transition ), played by
// the root sap.m.App (a NavContainer) in core/actions/Slots.js. Under test:
// which navigation a display turns into, that the leaving page stays up
// until the container reports the move done, and what the page's arrival
// is afterwards - the thing a later way back reverses.
//
// The container is a fake that keeps the parts of sap.m.NavContainer the
// transition relies on, as read in the 1.71.80 and 1.152.0 sources:
//  - a page stack whose entries carry the transition that brought a page
//  - to( <the current page>, t ) on a one-page stack stamps that entry and
//    navigates nowhere (the router's initial-page case, with a warning)
//  - insertPreviousPage( id, t ) puts an entry below the current one
//  - backToPage( id ) plays the transition of the entry it LEAVES, reversed
//  - removePage( ) drops the page's entries from the stack
//  - afterNavigate names the page it navigated to (toId); "show" ends
//    synchronously, every other transition when the spec says so
function fakeApp() {
  const app = {
    rendered: true,
    pages: [],
    stack: [],
    played: [],
    warnings: [],
    listeners: [],
    pending: null,
    getDomRef: () => (app.rendered ? {} : null),
    getPage: (id) => app.pages.find((p) => p.getId() === id) || null,
    getCurrentPage() {
      if (!app.stack.length && app.pages.length) {
        app.stack.push({ id: app.pages[0].getId(), isInitial: true });
      }
      const top = app.stack[app.stack.length - 1];
      return top ? app.getPage(top.id) : undefined;
    },
    addPage(page) {
      if (!app.pages.includes(page)) app.pages.push(page);
    },
    insertPage(page) {
      app.pages.push(page);
    },
    removePage(page) {
      app.pages = app.pages.filter((p) => p !== page);
      app.stack = app.stack.filter((e) => e.id !== page.getId());
    },
    removeAllPages() {
      for (const page of app.pages) app.removePage(page);
      app.pages = [];
    },
    attachAfterNavigate(fn) {
      app.listeners.push(fn);
    },
    detachAfterNavigate(fn) {
      app.listeners = app.listeners.filter((f) => f !== fn);
    },
    to(id, transition) {
      const current = app.getCurrentPage();
      if (current && current.getId() === id) {
        app.warnings.push(`Cannot navigate to page ${id}`);
        if (app.stack.length === 1) app.stack[0].transition = transition;
        return;
      }
      app.stack.push({ id, transition });
      app.animate("to", transition, current.getId(), id);
    },
    insertPreviousPage(id, transition) {
      const index = app.stack.length - 1;
      const info = { id, transition };
      if (index === 0) {
        info.isInitial = true;
        delete app.stack[0].isInitial;
      }
      app.stack.splice(index, 0, info);
    },
    backToPage(id) {
      const from = app.stack.pop();
      while (app.stack.length && app.stack[app.stack.length - 1].id !== id) {
        app.stack.pop();
      }
      // an entry without a transition reverses the container default
      app.animate("back", from.transition || "slide", from.id, id);
    },
    animate(direction, transition, fromId, toId) {
      app.played.push({ direction, transition, fromId, toId });
      const done = () => {
        const event = { getParameter: (n) => (n === "toId" ? toId : undefined) };
        for (const fn of app.listeners.slice()) fn(event);
      };
      if (transition === "show") done();
      else app.pending = done;
    },
    // the CSS transition ends
    complete() {
      const done = app.pending;
      app.pending = null;
      if (done) done();
    },
  };
  return app;
}

function makeView(id) {
  const dom = { style: {} };
  return {
    destroyed: false,
    getId: () => id,
    getDomRef: () => dom,
    setModel() {},
    getModel() {},
    destroy() {
      this.destroyed = true;
    },
  };
}

// The real ViewSlots and Slots on one spec context, the container above as
// the root sap.m.App. `display(options, app)` runs one MAIN display for a
// response of `app`; `timers` holds what the transition armed as its safety
// net, so a spec can let it fire.
function load() {
  const app = fakeApp();
  const errors = [];
  const built = [];
  const timers = [];
  const ctx = specContext({ oApp: app });
  const state = ctx.state;

  class JSONModel {
    constructor(data) {
      this.data = data;
    }
    attachPropertyChange() {}
    setSizeLimit() {}
    destroy() {}
  }
  const Lib = {
    logError: (m) => errors.push(m),
    usesXmlTemplating: () => false,
    isAlive: (o) => Boolean(o) && !o.destroyed,
    isRootModelSlot: (key) => ["MAIN", "NEST", "NEST2"].includes(key),
    effectiveSizeLimit: () => undefined,
  };
  const sandbox = {
    setTimeout: (fn, ms) => {
      timers.push({ fn, ms });
      return timers.length;
    },
    clearTimeout: () => {},
  };
  const { module: ViewSlots } = loadModule("core/ViewSlots.js", {
    deps: {
      "sap/ui/core/Fragment": { byId: () => undefined },
      "z2ui5/core/Lib": Lib,
      "z2ui5/core/Env": { getMessaging: () => undefined },
      "z2ui5/core/Context": contextStub(ctx),
    },
    sandbox,
  });
  const { module: Slots } = loadModule("core/actions/Slots.js", {
    deps: {
      "sap/ui/core/mvc/XMLView": {
        create: async (cfg) => {
          const view = makeView(cfg.id);
          built.push(view);
          return view;
        },
      },
      "sap/ui/core/Fragment": {},
      "sap/ui/model/json/JSONModel": JSONModel,
      "z2ui5/core/Lib": Lib,
      "z2ui5/core/Env": { preloadFragmentModules: async () => {} },
      "z2ui5/core/ViewSlots": ViewSlots,
      "z2ui5/core/Context": contextStub(ctx),
    },
    sandbox,
  });
  const display = (options = {}, appClass = "ZCL_APP") => {
    state.oResponse = { APP: appClass, OVIEWMODEL: { A: 1 } };
    return Slots.action(ctx, "display", "MAIN", "<mvc:View/>", options);
  };
  // the move ends - and whatever waited for it runs
  const complete = async () => {
    app.complete();
    await Promise.resolve();
  };
  return { app, ctx, state, errors, built, timers, display, complete };
}

test.describe("forward", () => {
  test("the new page is built under the other id and comes in with its transition", async () => {
    const env = load();
    await env.display({}, "ZCL_A");
    const first = env.state.oView;
    expect(first.getId()).toBe("mainView");
    expect(env.app.played).toEqual([]);

    await env.display({ transition: "fade", appInstance: "B" }, "ZCL_B");
    const second = env.state.oView;
    // both ids are in use at once while the pages move
    expect(second.getId()).toBe("mainView2");
    expect(env.app.played).toEqual([
      { direction: "to", transition: "fade", fromId: "mainView", toId: "mainView2" },
    ]);
  });

  test("the leaving page stays up, frozen, until the container reports the move done", async () => {
    const env = load();
    await env.display({}, "ZCL_A");
    const first = env.state.oView;
    await env.display({ transition: "flip", appInstance: "B" }, "ZCL_B");

    expect(first.destroyed).toBe(false);
    expect(env.app.pages).toHaveLength(2);
    // an event from it would run under the new page's model and draft
    expect(first.getDomRef().style.pointerEvents).toBe("none");
    expect(env.state.mainTransition).not.toBeNull();

    await env.complete();
    expect(first.destroyed).toBe(true);
    expect(env.app.pages).toEqual([env.state.oView]);
    expect(env.state.mainTransition).toBeNull();
    expect(env.state.mainArrival).toBe("flip");
    expect(env.state.mainInstance).toBe("B");
  });

  test("the slot holds the new page from the start - the old one is detached, not destroyed", async () => {
    const env = load();
    await env.display({}, "ZCL_A");
    const first = env.state.oView;
    await env.display({ transition: "slide", appInstance: "B" }, "ZCL_B");
    expect(env.state.oView).not.toBe(first);
    expect(env.state.slotApp.MAIN).toBe("ZCL_B");
  });

  test("show ends at once - no page is left behind", async () => {
    const env = load();
    await env.display({}, "ZCL_A");
    const first = env.state.oView;
    await env.display({ transition: "show", appInstance: "B" }, "ZCL_B");
    expect(first.destroyed).toBe(true);
    expect(env.state.mainTransition).toBeNull();
    expect(env.state.mainArrival).toBe("show");
  });

  test("the next page change alternates the id back", async () => {
    const env = load();
    await env.display({}, "ZCL_A");
    await env.display({ transition: "fade", appInstance: "B" }, "ZCL_B");
    await env.complete();
    await env.display({ transition: "fade", appInstance: "C" }, "ZCL_C");
    expect(env.state.oView.getId()).toBe("mainView");
  });

  test("the OData clients of the leaving page die with it, not before", async () => {
    const env = load();
    await env.display({}, "ZCL_A");
    const client = {
      destroyed: false,
      destroy() {
        this.destroyed = true;
      },
    };
    env.state.odataClients.add(client);
    await env.display({ transition: "fade", appInstance: "B" }, "ZCL_B");
    expect(client.destroyed).toBe(false);
    expect(env.state.odataClients.size).toBe(0);
    await env.complete();
    expect(client.destroyed).toBe(true);
  });

  test("the standalone slots go at once, as with the plain swap", async () => {
    const env = load();
    await env.display({}, "ZCL_A");
    const popup = {
      destroyed: false,
      close() {},
      destroy() {
        this.destroyed = true;
      },
    };
    env.state.oViewPopup = popup;
    await env.display({ transition: "fade", appInstance: "B" }, "ZCL_B");
    expect(popup.destroyed).toBe(true);
    expect(env.state.oViewPopup).toBeNull();
  });

  test("a move that never reports back ends on the safety timeout", async () => {
    const env = load();
    await env.display({}, "ZCL_A");
    const first = env.state.oView;
    await env.display({ transition: "fade", appInstance: "B" }, "ZCL_B");
    expect(env.timers).toHaveLength(1);
    env.timers[0].fn();
    expect(first.destroyed).toBe(true);
    expect(env.state.mainTransition).toBeNull();
  });

  test("a safety timeout after the component went down leaves the container alone", async () => {
    const env = load();
    await env.display({}, "ZCL_A");
    const first = env.state.oView;
    await env.display({ transition: "fade", appInstance: "B" }, "ZCL_B");
    // Component.exit destroyed the root App mid-move - its event registry
    // is gone, and touching it would throw out of a timer
    env.app.destroyed = true;
    env.app.detachAfterNavigate = () => {
      throw new Error("detach on a destroyed container");
    };
    env.timers[0].fn();
    expect(env.errors).toEqual([]);
    expect(first.destroyed).toBe(true);
    expect(env.state.mainTransition).toBeNull();
  });

  test("the next MAIN display waits for the move in flight", async () => {
    const env = load();
    await env.display({}, "ZCL_A");
    await env.display({ transition: "fade", appInstance: "B" }, "ZCL_B");
    expect(env.built).toHaveLength(2);

    const third = env.display({ transition: "slide", appInstance: "C" }, "ZCL_C");
    await Promise.resolve();
    await Promise.resolve();
    // nothing built while two pages are still in the container
    expect(env.built).toHaveLength(2);

    await env.complete();
    await third;
    expect(env.built).toHaveLength(3);
    expect(env.app.played.map((p) => p.transition)).toEqual(["fade", "slide"]);
  });
});

test.describe("back - the page being left plays its arrival in reverse", () => {
  test("a return through nav_app_leave reverses how the page came", async () => {
    const env = load();
    await env.display({ transition: "slide", appInstance: "A" }, "ZCL_A");
    await env.display({ transition: "fade", appInstance: "B" }, "ZCL_B");
    await env.complete();

    // the caller comes back, naming its OWN transition
    await env.display(
      { transition: "slide", navBack: true, appInstance: "A" },
      "ZCL_A",
    );
    expect(env.app.played[1]).toEqual({
      direction: "back",
      transition: "fade",
      fromId: "mainView2",
      toId: "mainView",
    });
    await env.complete();
    // ...which is what IT will leave with on its own way back
    expect(env.state.mainArrival).toBe("slide");
    expect(env.state.mainInstance).toBe("A");
    expect(env.app.pages).toEqual([env.state.oView]);
  });

  test("the arrival survives the same app re-rendering its screen", async () => {
    const env = load();
    await env.display({}, "ZCL_A");
    await env.display({ transition: "flip", appInstance: "B" }, "ZCL_B");
    await env.complete();
    // the called app re-renders without a transition - a plain swap, which
    // resets the container's stack: the arrival is kept all the same...
    await env.display({}, "ZCL_B");
    expect(env.state.mainArrival).toBe("flip");

    // ...and written back into the container before the way back
    await env.display({ navBack: true, appInstance: "A" }, "ZCL_A");
    expect(env.app.played[env.app.played.length - 1]).toMatchObject({
      direction: "back",
      transition: "flip",
    });
  });

  test("a page that came without a transition leaves without one", async () => {
    const env = load();
    await env.display({}, "ZCL_A");
    await env.display({}, "ZCL_B");
    await env.display({ navBack: true, appInstance: "A" }, "ZCL_A");
    expect(env.app.played).toEqual([]);
    expect(env.app.pages).toEqual([env.state.oView]);
  });

  test("a return from a popup-as-app leaves the caller's page where it is", async () => {
    const env = load();
    // the caller's page is on screen, arrived with slide
    await env.display({ transition: "slide", appInstance: "C" }, "ZCL_C");
    // a popup app came and went without touching MAIN; the caller is back
    await env.display(
      { transition: "slide", navBack: true, appInstance: "C" },
      "ZCL_C",
    );
    expect(env.app.played).toEqual([]);
    // a plain swap of the same app keeps the arrival
    expect(env.state.mainArrival).toBe("slide");
  });

  test("without instances on both sides the app class decides the owner", async () => {
    const env = load();
    await env.display({ transition: "slide" }, "ZCL_C");
    await env.display({ transition: "slide", navBack: true }, "ZCL_C");
    expect(env.app.played).toEqual([]);
  });

  test("the app's own step back (transition_back) plays even on its own page", async () => {
    const env = load();
    await env.display({ appInstance: "W" }, "ZCL_WIZARD");
    await env.display({ transition: "slide", appInstance: "W" }, "ZCL_WIZARD");
    await env.complete();
    await env.display(
      { transition: "slide", transitionBack: true, appInstance: "W" },
      "ZCL_WIZARD",
    );
    expect(env.app.played[1]).toMatchObject({
      direction: "back",
      transition: "slide",
    });
  });

  test("a browser Back through a route is a way back", async () => {
    const env = load();
    await env.display({}, "ZCL_A");
    await env.display({ transition: "fade", appInstance: "B" }, "ZCL_B");
    await env.complete();
    // what core/Router.onHashChanged leaves for the restore it starts
    env.state.navFromHash = true;
    env.state.navDirection = "back";
    await env.display({ transition: "slide", appInstance: "A" }, "ZCL_A");
    expect(env.app.played[1]).toMatchObject({
      direction: "back",
      transition: "fade",
    });
  });

  test("a browser Forward is a forward move with the page's own transition", async () => {
    const env = load();
    await env.display({}, "ZCL_A");
    env.state.navFromHash = true;
    env.state.navDirection = "forward";
    await env.display({ transition: "fade", appInstance: "B" }, "ZCL_B");
    expect(env.app.played[0]).toMatchObject({ direction: "to", transition: "fade" });
  });
});

test.describe("the plain swap stays what it was", () => {
  test("a display without a transition swaps the page in place", async () => {
    const env = load();
    await env.display({}, "ZCL_A");
    const first = env.state.oView;
    await env.display({}, "ZCL_B");
    expect(first.destroyed).toBe(true);
    expect(env.state.oView.getId()).toBe("mainView");
    expect(env.app.played).toEqual([]);
    expect(env.state.mainTransition).toBeNull();
  });

  test("the first display has nothing to leave - its transition is remembered", async () => {
    const env = load();
    await env.display({ transition: "fade", appInstance: "A" }, "ZCL_A");
    expect(env.app.played).toEqual([]);
    expect(env.state.mainArrival).toBe("fade");
    expect(env.state.mainInstance).toBe("A");
  });

  test("a container that is not rendered cannot move - the page is swapped", async () => {
    const env = load();
    await env.display({}, "ZCL_A");
    env.app.rendered = false;
    await env.display({ transition: "fade", appInstance: "B" }, "ZCL_B");
    expect(env.app.played).toEqual([]);
    expect(env.app.pages).toEqual([env.state.oView]);
  });

  test("another app's plain page drops the arrival", async () => {
    const env = load();
    await env.display({ transition: "fade" }, "ZCL_A");
    await env.display({}, "ZCL_B");
    expect(env.state.mainArrival).toBe("");
  });

  test("a re-display outside a roundtrip reuses the options without the transition", async () => {
    const env = load();
    await env.display(
      {
        switchDefaultModelPath: "",
        transition: "fade",
        transitionBack: true,
        navBack: true,
        appInstance: "A",
      },
      "ZCL_A",
    );
    // devtools LiveEdit re-displays with these - it must not navigate
    expect(env.state.lastMainDisplayOptions).toEqual({
      switchDefaultModelPath: "",
    });
  });
});
