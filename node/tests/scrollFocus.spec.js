// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");

// Tests ScrollFocus.closestUi5Element: resolving the UI5 element that owns a DOM
// node must work on UI5 >= 1.106 via Element.closestTo and on older
// bootstraps (e.g. 1.71) via the DOM-walk fallback, so scroll and focus
// capture are not silently skipped there.

function fakeDomNode({
  id,
  isControlRoot = false,
  parent = null,
  isConnected = false,
} = {}) {
  return {
    nodeType: 1,
    id,
    parentElement: parent,
    isConnected,
    hasAttribute: (name) => name === "data-sap-ui" && isControlRoot,
    getAttribute: () => null,
  };
}

function loadScrollFocus({ Element = {}, deps = {}, sandbox = {} } = {}) {
  return loadModule("core/ScrollFocus.js", {
    deps: { "sap/ui/core/Element": Element, ...deps },
    sandbox,
  });
}

// The two fragment slots: their inner controls are registered under the
// FRAGMENT id, while the instance the slot holds is the fragment ROOT
// control, whose own id is an unrelated auto-generated one.
const SLOTS_WITH_POPUP = [{ key: "MAIN" }, { key: "POPUP", fragmentId: "popupId" }];

function slotViews(key) {
  if (key === "MAIN") return { getId: () => "mainView" };
  if (key === "POPUP") return { getId: () => "__dialog0" };
  return undefined;
}

test("uses Element.closestTo when available", () => {
  const control = { id: "resolved" };
  const seen = [];
  const { module: ScrollFocus } = loadScrollFocus({
    Element: {
      closestTo: (dom) => {
        seen.push(dom);
        return control;
      },
    },
  });

  const dom = fakeDomNode({ id: "x" });
  expect(ScrollFocus.closestUi5Element(dom)).toBe(control);
  expect(seen).toEqual([dom]);
});

test("normalizes a closestTo miss to null", () => {
  const { module: ScrollFocus } = loadScrollFocus({
    Element: { closestTo: () => undefined },
  });

  expect(ScrollFocus.closestUi5Element(fakeDomNode({ id: "x" }))).toBe(null);
});

test("falls back to the data-sap-ui DOM walk without closestTo", () => {
  const control = { id: "page" };
  const { module: ScrollFocus } = loadScrollFocus({
    deps: {
      "z2ui5/core/Lib": {
        getElementById: (id) => (id === "page" ? control : null),
      },
    },
  });

  const root = fakeDomNode({ id: "page", isControlRoot: true });
  const inner = fakeDomNode({ id: "page-cont", parent: root });

  expect(ScrollFocus.closestUi5Element(inner)).toBe(control);
});

test("fallback returns null when no control root is found", () => {
  const { module: ScrollFocus } = loadScrollFocus({
    deps: { "z2ui5/core/Lib": { getElementById: () => null } },
  });

  const plain = fakeDomNode({ id: "no-control" });
  expect(ScrollFocus.closestUi5Element(plain)).toBe(null);
});

test("onScrollCapture records the scrolled slot via the fallback", () => {
  const control = { id: "page" };
  const state = { lastScrolled: {} };
  const { module: ScrollFocus } = loadScrollFocus({
    deps: {
      "z2ui5/core/ViewSlots": {
        containingSlotKey: (el) => (el === control ? "MAIN" : undefined),
      },
      "z2ui5/core/AppState": { state },
      "z2ui5/core/Lib": {
        getElementById: (id) => (id === "page" ? control : null),
      },
    },
  });

  const root = fakeDomNode({ id: "page", isControlRoot: true });
  const scrolled = fakeDomNode({ id: "page-cont", parent: root });
  ScrollFocus.onScrollCapture({ target: scrolled });

  expect(state.lastScrolled.MAIN).toEqual({
    control,
    dom: scrolled,
  });
});

// The per-element resolution cache of onScrollCapture must not retain a
// detached DOM node (and its control) after the view was replaced - it is
// released on the next roundtrip's getScrollInfo.

function loadScrollFocusWithScrollCache({ connected }) {
  const control = { id: "page" };
  const { module: ScrollFocus } = loadScrollFocus({
    deps: {
      "z2ui5/core/ViewSlots": {
        containingSlotKey: (el) => (el === control ? "MAIN" : undefined),
        slots: [],
      },
      "z2ui5/core/AppState": { state: { lastScrolled: {} } },
      "z2ui5/core/Lib": {
        getElementById: (id) => (id === "page" ? control : null),
      },
    },
  });

  const root = fakeDomNode({ id: "page", isControlRoot: true });
  const scrolled = fakeDomNode({
    id: "page-cont",
    parent: root,
    isConnected: connected,
  });
  ScrollFocus.onScrollCapture({ target: scrolled });
  return { ScrollFocus, scrolled };
}

test("getScrollInfo releases the scroll cache once its DOM node is detached", () => {
  const { ScrollFocus, scrolled } = loadScrollFocusWithScrollCache({ connected: false });
  expect(ScrollFocus._scrollCache.target).toBe(scrolled);

  ScrollFocus.getScrollInfo();

  expect(ScrollFocus._scrollCache.target).toBe(undefined);
  expect(ScrollFocus._scrollCache.ui5El).toBe(undefined);
  expect(ScrollFocus._scrollCache.slotKey).toBe(undefined);
});

test("getScrollInfo keeps the scroll cache while its DOM node is connected", () => {
  const { ScrollFocus, scrolled } = loadScrollFocusWithScrollCache({ connected: true });

  ScrollFocus.getScrollInfo();

  expect(ScrollFocus._scrollCache.target).toBe(scrolled);
});

// S_FOCUS / S_SCROLL must carry the id the app declared, in every slot.
// The strip used to key off the slot view's own id, which for a fragment
// slot is the dialog root and matches none of its inner controls: the same
// control was reported as "input" in MAIN and as "popupId--input" in a
// dialog, and the SET_FOCUS / SCROLL_TO the app echoed back was resolved
// through Fragment.byId - prefixing it a second time, so nothing was found.

test("getFocusInfo reports a control inside a popup fragment by its bare id", () => {
  const input = { tagName: "INPUT" };
  const control = {
    getId: () => "popupId--input",
    getFocusDomRef: () => input,
  };
  const { module: ScrollFocus } = loadScrollFocus({
    Element: { closestTo: () => control },
    deps: {
      "z2ui5/core/ViewSlots": {
        slots: SLOTS_WITH_POPUP,
        getView: slotViews,
      },
      "z2ui5/core/Lib": {
        isTextInput: () => false,
        readCaret: () => null,
        logError: () => {},
      },
    },
    sandbox: { document: { activeElement: input } },
  });

  expect(ScrollFocus.getFocusInfo().ID).toBe("input");
});

test("getScrollInfo strips the view id in MAIN and the fragment id in POPUP", () => {
  const list = { getId: () => "mainView--list" };
  const table = { getId: () => "popupId--table" };
  const { module: ScrollFocus } = loadScrollFocus({
    deps: {
      "z2ui5/core/ViewSlots": {
        slots: SLOTS_WITH_POPUP,
        getView: slotViews,
      },
      "z2ui5/core/AppState": {
        state: {
          lastScrolled: {
            MAIN: {
              control: list,
              dom: { isConnected: true, scrollLeft: 0, scrollTop: 80 },
            },
            POPUP: {
              control: table,
              dom: { isConnected: true, scrollLeft: 12, scrollTop: 240 },
            },
          },
        },
      },
      "z2ui5/core/Lib": { isAlive: () => true },
    },
  });

  expect(ScrollFocus.getScrollInfo()).toEqual({
    MAIN: { ID: "list", X: 0, Y: 80 },
    POPUP: { ID: "table", X: 12, Y: 240 },
  });
});
