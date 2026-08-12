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

function loadScrollFocus({ Element = {}, deps = {} } = {}) {
  return loadModule("core/ScrollFocus.js", {
    deps: { "sap/ui/core/Element": Element, ...deps },
  });
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
