// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");
const { specContext, contextStub, bindContext } = require("./loadLibModule");

// core/actions/Slots.js - the VIEW_SLOTS action target, i.e. everything a
// backend response does to the five view slots. Under test here: the entry
// point `action( )` and the shape of its arguments. The options object is
// OPTIONAL on the wire (a display that needs none carries no fourth
// argument at all), and every slot has to survive that - MAIN used to be
// the only one that did, while the popover read `mOptions.openById` and the
// nested display destructured `mOptions` right away.
function load({ resolveById = null, byId = null } = {}) {
  const errors = [];
  const destroyed = [];
  const setViews = [];
  const opened = [];

  class JSONModel {
    constructor(data) {
      this.data = data;
    }
    attachPropertyChange() {}
    setSizeLimit() {}
    setData(data) {
      this.data = data;
    }
    getData() {
      return this.data;
    }
    destroy() {}
  }

  const fragment = {
    destroyed: false,
    setModel() {},
    destroy() {
      fragment.destroyed = true;
    },
    open() {
      opened.push("POPUP");
    },
    openBy(control) {
      opened.push(control);
    },
  };

  const view = {
    destroyed: false,
    setModel() {},
    destroy() {
      view.destroyed = true;
    },
  };

  const oApp = {
    pages: [],
    removeAllPages() {
      oApp.pages = [];
    },
    insertPage(page) {
      oApp.pages.push(page);
    },
  };

  // the slots work on the component's context; the request stamp the
  // display guards compare against is ctx.server.requestSeq
  const ctx = specContext({
    oApp,
    oResponse: { APP: "ZCL_APP", OVIEWMODEL: { A: 1 } },
  });
  ctx.server.requestSeq = 7;
  const state = ctx.state;

  const { module } = loadModule("core/actions/Slots.js", {
    deps: {
      "sap/ui/core/mvc/XMLView": { create: () => Promise.resolve(view) },
      "sap/ui/core/Fragment": { load: () => Promise.resolve(fragment) },
      "sap/ui/model/json/JSONModel": JSONModel,
      "sap/ui/model/odata/v2/ODataModel": class {},
      "z2ui5/core/Context": contextStub(ctx),
      "z2ui5/core/Lib": {
        logError: (m) => errors.push(m),
        // no view in this spec uses XML templating (Slots.templatePreprocessors)
        usesXmlTemplating: () => false,
        isAlive: () => true,
        isRootModelSlot: (key) => ["MAIN", "NEST", "NEST2"].includes(key),
        effectiveSizeLimit: () => undefined,
        whenRendered: (control, _owner, fn) => fn(control),
      },
      "z2ui5/core/Env": { preloadFragmentModules: async () => {} },
      "z2ui5/core/ViewSlots": {
        // the real module prefixes with the owner component; no owner here
        ownId: (_ctx, id) => id,
        fragmentIdOf: (_ctx, slot) => slot.fragmentId,
        slots: [
          { key: "MAIN", ownsModel: true },
          { key: "POPUP", ownsModel: true },
        ],
        destroy: (_ctx, key) => destroyed.push(key),
        setView: (_ctx, key, oView, xml) => setViews.push({ key, oView, xml }),
        getController: () => null,
        getView: () => null,
        getViewApp: () => undefined,
        getViewXml: () => "",
        trackedModel: () => undefined,
        resolveById: () => resolveById,
        byId: () => byId,
      },
    },
  });
  const Slots = bindContext(module, ctx, ["action"]);

  return {
    Slots,
    ctx,
    state,
    errors,
    destroyed,
    setViews,
    opened,
    fragment,
    view,
  };
}

test("destroy and updateModel need no options at all", () => {
  const { Slots, destroyed } = load();
  expect(Slots.action("destroy", "POPUP")).toBe(undefined);
  expect(destroyed).toEqual(["POPUP"]);
  expect(Slots.action("updateModel")).toBe(undefined);
});

test("a MAIN display without options remembers an empty set of them", async () => {
  const { Slots, state, setViews } = load();
  await Slots.action("display", "MAIN", "<mvc:View/>");

  expect(state.lastMainDisplayOptions).toEqual({});
  expect(setViews.map((entry) => entry.key)).toEqual(["MAIN"]);
});

test("a POPOVER display without options reports the missing anchor", async () => {
  // the openBy control is read OFF the options - without them this used to
  // die on a TypeError instead of the handled "anchor not found"
  const { Slots, errors, fragment } = load();
  await Slots.action("display", "POPOVER", "<Popover/>");

  expect(errors.some((m) => m.includes("openBy control"))).toBe(true);
  expect(fragment.destroyed).toBe(true);
});

test("a POPOVER display opens on the anchor the options name", async () => {
  const anchor = { id: "btn" };
  const { Slots, opened, setViews } = load({ resolveById: anchor });
  await Slots.action("display", "POPOVER", "<Popover/>", { openById: "btn" });

  expect(setViews.map((entry) => entry.key)).toEqual(["POPOVER"]);
  expect(opened).toEqual([anchor]);
});

test("a nested display without options reports the missing parent", async () => {
  // id / methodInsert are destructured from the options
  const { Slots, errors, view } = load();
  await Slots.action("display", "NEST", "<mvc:View/>");

  expect(errors.some((m) => m.includes("parent control"))).toBe(true);
  expect(view.destroyed).toBe(true);
});

test("a superseded display is dropped before anything is torn down", () => {
  const { Slots, destroyed } = load();
  // seq 1 against Server._requestSeq 7: a newer request owns the slots
  expect(Slots.action("display", "POPUP", "<Dialog/>", {}, 1)).toBe(undefined);
  expect(destroyed).toEqual([]);
});

// Every display under a FIXED id goes through ONE serialized build chain
// (ctx.server.viewBuild, Slots.chainBuild): XMLView.create claims the main
// view id synchronously and Fragment.load({ id }) does the same for the two
// fragment slots, so two overlapping builds of a slot throw "duplicate id" -
// and that throw is the fatal overlay. The MAIN rebuild has been chained for
// long; the fragment slots ran unchained, so a Back/Forward restore that
// landed while a popup was still loading started a second Fragment.load
// under the same id next to the first.
test.describe("the fragment slots build through the serialized chain", () => {
  function defer() {
    let resolve;
    const promise = new Promise((res) => {
      resolve = res;
    });
    return { promise, resolve };
  }

  // Let the queued microtasks (the chain's .then steps) run.
  const flush = () => new Promise((r) => setTimeout(r, 0));

  function loadDeferred() {
    const destroyed = [];
    const setViews = [];
    const loads = [];
    const fragments = [];
    function fragment(name) {
      const f = {
        name,
        destroyed: false,
        setModel() {},
        destroy() {
          f.destroyed = true;
        },
        open() {},
      };
      fragments.push(f);
      return f;
    }
    class JSONModel {
      attachPropertyChange() {}
      setSizeLimit() {}
      destroy() {}
    }
    const ctx = specContext({
      oApp: {},
      oResponse: { APP: "ZCL_APP", OVIEWMODEL: {} },
    });
    ctx.server.requestSeq = 7;
    const { module } = loadModule("core/actions/Slots.js", {
      deps: {
        "sap/ui/core/mvc/XMLView": {},
        "sap/ui/core/Fragment": {
          load: () => {
            const d = defer();
            loads.push(d);
            return d.promise;
          },
        },
        "sap/ui/model/json/JSONModel": JSONModel,
        "z2ui5/core/Context": contextStub(ctx),
        "z2ui5/core/Lib": {
          logError: () => {},
          usesXmlTemplating: () => false,
          isAlive: () => true,
          isRootModelSlot: (key) => ["MAIN", "NEST", "NEST2"].includes(key),
          effectiveSizeLimit: () => undefined,
        },
        "z2ui5/core/Env": { preloadFragmentModules: async () => {} },
        "z2ui5/core/ViewSlots": {
          ownId: (_ctx, id) => id,
          slots: [],
          destroy: (_ctx, key) => destroyed.push(key),
          setView: (_ctx, key, oView) => setViews.push({ key, oView }),
          getController: () => null,
          getView: () => null,
          resolveById: () => null,
        },
      },
    });
    const Slots = bindContext(module, ctx, ["action"]);
    return { Slots, ctx, destroyed, setViews, loads, fragment, flush };
  }

  test("a second popup display waits for the first fragment to load", async () => {
    const { Slots, destroyed, setViews, loads, fragment, flush } =
      loadDeferred();

    const p1 = Slots.action("display", "POPUP", "<Dialog/>", {}, 7);
    await flush();
    // the slot is replaced INSIDE the chain step, once the earlier builds
    // settled - never at action time
    expect(destroyed).toEqual(["POPUP"]);
    expect(loads).toHaveLength(1);

    const p2 = Slots.action("display", "POPUP", "<Dialog/>", {}, 7);
    await flush();
    // the second Fragment.load does not start while the first still holds
    // the fixed popup id
    expect(loads).toHaveLength(1);
    expect(destroyed).toEqual(["POPUP"]);

    loads[0].resolve(fragment("first"));
    await flush();
    expect(setViews.map((v) => v.oView.name)).toEqual(["first"]);
    expect(destroyed).toEqual(["POPUP", "POPUP"]);
    expect(loads).toHaveLength(2);

    loads[1].resolve(fragment("second"));
    await Promise.all([p1, p2]);
    expect(setViews.map((v) => v.oView.name)).toEqual(["first", "second"]);
  });

  test("a restore while a popup loads: the stale build is discarded, the restore's runs after it", async () => {
    const { Slots, ctx, destroyed, setViews, loads, fragment, flush } =
      loadDeferred();

    const p1 = Slots.action("display", "POPUP", "<Dialog/>", {}, 7);
    await flush();
    // the Back/Forward restore dispatches request 8 while the popup of
    // response 7 is still loading, and its response opens a popup too
    ctx.server.requestSeq = 8;
    const p2 = Slots.action("display", "POPUP", "<Dialog/>", {}, 8);
    await flush();
    expect(loads).toHaveLength(1);

    const stale = fragment("stale");
    loads[0].resolve(stale);
    await flush();
    // the superseded fragment never reaches the slot ...
    expect(stale.destroyed).toBe(true);
    expect(setViews).toEqual([]);
    // ... and only then does the restore's build claim the id
    expect(loads).toHaveLength(2);
    loads[1].resolve(fragment("restored"));
    await Promise.all([p1, p2]);
    expect(setViews.map((v) => v.oView.name)).toEqual(["restored"]);
    expect(destroyed).toEqual(["POPUP", "POPUP"]);
  });

  test("a popover display is chained the same way", async () => {
    const { Slots, destroyed, loads, flush } = loadDeferred();
    const p1 = Slots.action("display", "POPUP", "<Dialog/>", {}, 7);
    const p2 = Slots.action("display", "POPOVER", "<Popover/>", {}, 7);
    await flush();
    expect(destroyed).toEqual(["POPUP"]);
    expect(loads).toHaveLength(1);
    loads[0].resolve({ setModel() {}, destroy() {}, open() {} });
    await flush();
    expect(destroyed).toEqual(["POPUP", "POPOVER"]);
    expect(loads).toHaveLength(2);
    // the popover's anchor is not resolvable here - a handled miss, and the
    // chain stays usable for the next build either way
    loads[1].resolve({ setModel() {}, destroy() {}, openBy() {} });
    await Promise.all([p1, p2]);
  });
});

// The nested display hands the built view to a parent control by the two
// method names the app chose (methodDestroy, methodInsert). Both are calls
// into an app's control by name, and both are guarded on their own: a
// failing teardown is logged and the insert still runs, a failing insert
// is logged and the view is released - and never a slot entry for a view
// that is not in the tree.
test.describe("displayNestedView: the parent's destroy and insert methods", () => {
  function parent({ destroyThrows = false, insertThrows = false } = {}) {
    const calls = [];
    return {
      calls,
      destroyItems() {
        calls.push("destroyItems");
        if (destroyThrows) throw new Error("destroy boom");
      },
      addItem(view) {
        calls.push(["addItem", view]);
        if (insertThrows) throw new Error("insert boom");
      },
    };
  }

  test("a throwing methodDestroy is logged and the insert still runs", async () => {
    const oParent = parent({ destroyThrows: true });
    const { Slots, errors, setViews, view } = load({ byId: oParent });

    await Slots.action("display", "NEST", "<mvc:View/>", {
      id: "cont",
      methodDestroy: "destroyItems",
      methodInsert: "addItem",
    });

    expect(oParent.calls).toEqual(["destroyItems", ["addItem", view]]);
    expect(
      errors.some((m) => m.includes("parent destroy method 'destroyItems' failed")),
    ).toBe(true);
    expect(setViews.map((entry) => entry.key)).toEqual(["NEST"]);
    expect(view.destroyed).toBe(false);
  });

  test("a throwing methodInsert is logged and the view is released", async () => {
    const oParent = parent({ insertThrows: true });
    const { Slots, errors, setViews, view } = load({ byId: oParent });

    await Slots.action("display", "NEST2", "<mvc:View/>", {
      id: "cont",
      methodDestroy: "destroyItems",
      methodInsert: "addItem",
    });

    expect(oParent.calls).toEqual(["destroyItems", ["addItem", view]]);
    expect(errors.some((m) => m.includes("parent insert method failed"))).toBe(
      true,
    );
    expect(setViews).toEqual([]);
    expect(view.destroyed).toBe(true);
  });

  test("an empty methodDestroy is not called at all", async () => {
    // an empty value used to reach oParent[""]( ) and throw on every render
    const oParent = parent();
    const { Slots, errors, setViews } = load({ byId: oParent });

    await Slots.action("display", "NEST", "<mvc:View/>", {
      id: "cont",
      methodDestroy: "",
      methodInsert: "addItem",
    });

    expect(oParent.calls.map((c) => (Array.isArray(c) ? c[0] : c))).toEqual([
      "addItem",
    ]);
    expect(errors).toEqual([]);
    expect(setViews.map((entry) => entry.key)).toEqual(["NEST"]);
  });
});
