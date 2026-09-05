// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");

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

  const state = {
    oApp,
    oResponse: { APP: "ZCL_APP", OVIEWMODEL: { A: 1 } },
    odataClients: new Set(),
    viewSizeLimits: {},
  };

  const { module: Slots } = loadModule("core/actions/Slots.js", {
    deps: {
      "sap/ui/core/mvc/XMLView": { create: () => Promise.resolve(view) },
      "sap/ui/core/Fragment": { load: () => Promise.resolve(fragment) },
      "sap/ui/model/json/JSONModel": JSONModel,
      "sap/ui/model/odata/v2/ODataModel": class {},
      "z2ui5/core/Server": { _requestSeq: 7, _viewBuild: null },
      "z2ui5/core/Lib": {
        logError: (m) => errors.push(m),
        isAlive: () => true,
        isRootModelSlot: (key) => ["MAIN", "NEST", "NEST2"].includes(key),
        effectiveSizeLimit: () => undefined,
        whenRendered: (control, _owner, fn) => fn(control),
      },
      "z2ui5/core/ViewSlots": {
        slots: [
          { key: "MAIN", ownsModel: true },
          { key: "POPUP", ownsModel: true },
        ],
        destroy: (key) => destroyed.push(key),
        setView: (key, oView, xml) => setViews.push({ key, oView, xml }),
        getController: () => null,
        getView: () => null,
        getViewApp: () => undefined,
        getViewXml: () => "",
        trackedModel: () => undefined,
        resolveById: () => resolveById,
        byId: () => byId,
      },
      "z2ui5/core/AppState": { state },
    },
  });

  return { Slots, state, errors, destroyed, setViews, opened, fragment, view };
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
