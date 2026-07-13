// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");

// Tests Server._closestUi5Element: resolving the UI5 element that owns a DOM
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

function loadServer({ Element = {}, deps = {} } = {}) {
  return loadModule("core/Server.js", {
    deps: { "sap/ui/core/Element": Element, ...deps },
  });
}

test("uses Element.closestTo when available", () => {
  const control = { id: "resolved" };
  const seen = [];
  const { module: Server } = loadServer({
    Element: {
      closestTo: (dom) => {
        seen.push(dom);
        return control;
      },
    },
  });

  const dom = fakeDomNode({ id: "x" });
  expect(Server._closestUi5Element(dom)).toBe(control);
  expect(seen).toEqual([dom]);
});

test("normalizes a closestTo miss to null", () => {
  const { module: Server } = loadServer({
    Element: { closestTo: () => undefined },
  });

  expect(Server._closestUi5Element(fakeDomNode({ id: "x" }))).toBe(null);
});

test("falls back to the data-sap-ui DOM walk without closestTo", () => {
  const control = { id: "page" };
  const { module: Server, sandbox } = loadServer();
  sandbox.sap.ui.getCore = () => ({
    byId: (id) => (id === "page" ? control : undefined),
  });

  const root = fakeDomNode({ id: "page", isControlRoot: true });
  const inner = fakeDomNode({ id: "page-cont", parent: root });

  expect(Server._closestUi5Element(inner)).toBe(control);
});

test("fallback returns null when no control root is found", () => {
  const { module: Server, sandbox } = loadServer();
  sandbox.sap.ui.getCore = () => ({ byId: () => undefined });

  const plain = fakeDomNode({ id: "no-control" });
  expect(Server._closestUi5Element(plain)).toBe(null);
});

test("onScrollCapture records the scrolled slot via the fallback", () => {
  const control = { id: "page" };
  const state = { lastScrolled: {} };
  const { module: Server, sandbox } = loadServer({
    deps: {
      "z2ui5/core/ViewSlots": {
        containingSlotKey: (el) => (el === control ? "MAIN" : undefined),
      },
      "z2ui5/core/AppState": { state },
    },
  });
  sandbox.sap.ui.getCore = () => ({
    byId: (id) => (id === "page" ? control : undefined),
  });

  const root = fakeDomNode({ id: "page", isControlRoot: true });
  const scrolled = fakeDomNode({ id: "page-cont", parent: root });
  Server.onScrollCapture({ target: scrolled });

  expect(state.lastScrolled.MAIN).toEqual({
    control,
    dom: scrolled,
  });
});

// The per-element resolution cache of onScrollCapture must not retain a
// detached DOM node (and its control) after the view was replaced - it is
// released on the next roundtrip's _getScrollInfo.

function loadServerWithScrollCache({ connected }) {
  const control = { id: "page" };
  const { module: Server, sandbox } = loadServer({
    deps: {
      "z2ui5/core/ViewSlots": {
        containingSlotKey: (el) => (el === control ? "MAIN" : undefined),
        slots: [],
      },
      "z2ui5/core/AppState": { state: { lastScrolled: {} } },
    },
  });
  sandbox.sap.ui.getCore = () => ({
    byId: (id) => (id === "page" ? control : undefined),
  });

  const root = fakeDomNode({ id: "page", isControlRoot: true });
  const scrolled = fakeDomNode({
    id: "page-cont",
    parent: root,
    isConnected: connected,
  });
  Server.onScrollCapture({ target: scrolled });
  return { Server, scrolled };
}

test("_getScrollInfo releases the scroll cache once its DOM node is detached", () => {
  const { Server, scrolled } = loadServerWithScrollCache({ connected: false });
  expect(Server._lastScrollTarget).toBe(scrolled);

  Server._getScrollInfo();

  expect(Server._lastScrollTarget).toBe(undefined);
  expect(Server._lastScrollUi5El).toBe(undefined);
  expect(Server._lastScrollSlotKey).toBe(undefined);
});

test("_getScrollInfo keeps the scroll cache while its DOM node is connected", () => {
  const { Server, scrolled } = loadServerWithScrollCache({ connected: true });

  Server._getScrollInfo();

  expect(Server._lastScrollTarget).toBe(scrolled);
});
