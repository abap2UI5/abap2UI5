// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");
const { specContext } = require("./loadLibModule");

// The focus guard of an EMBEDDED component (core/ScrollFocus.js): the page
// is the host's, and so is the keyboard focus on it. A starting app took
// it out of the host field the user was typing in - its SET_FOCUS as much
// as sap.m.App's first rendering. mayMoveFocus( ) is what SET_FOCUS, a
// CONTROL_BY_ID focus( ) and the obsolete cc/Focus control ask right before
// they move the focus (frontendAction.spec.js and focus.spec.js pin that
// they do); this spec pins the answer. The real module, with the UI5
// element registry and the context lookup stubbed: a DOM node carries the
// UI5 element that owns it (`ui5El`), and an element the context it
// belongs to (`owner`).

function node(name, { ui5El = null, inside = [] } = {}) {
  return {
    nodeType: 1,
    name,
    ui5El,
    // the nodes this one contains, itself included
    contains: (other) => other === ui5El || inside.includes(other),
  };
}

function load({ embedded = true } = {}) {
  const ctx = specContext({ embedded });
  const body = { nodeType: 1, name: "body" };
  const listeners = [];
  const doc = {
    body,
    activeElement: body,
    addEventListener: (type, fn, capture) =>
      listeners.push({ type, fn, capture }),
    removeEventListener: (type, fn, capture) => {
      const i = listeners.findIndex(
        (l) => l.type === type && l.fn === fn && l.capture === capture,
      );
      if (i >= 0) listeners.splice(i, 1);
    },
  };
  // the component's own DOM: the root control renders everything but what
  // UI5 puts into its static area
  const appField = node("appField");
  const root = node("root", { inside: [appField] });
  ctx.component = { getRootControl: () => ({ getDomRef: () => root }) };
  // a popup of the app (a Select's list in the static area): outside the
  // root DOM, owned by a control of this context
  const appPopupItem = node("appPopupItem", {
    ui5El: { owner: ctx, getId: () => "app--select-list" },
  });
  // the host's field, owned by a control of the host
  const hostField = node("hostField", {
    ui5El: { owner: null, getId: () => "host--input" },
  });
  const errors = [];
  const { module: ScrollFocus } = loadModule("core/ScrollFocus.js", {
    deps: {
      "sap/ui/core/Element": { closestTo: (dom) => dom.ui5El || null },
      "z2ui5/core/Lib": {
        logError: (m) => errors.push(m),
        readCaret: () => null,
        isTextInput: () => false,
      },
      "z2ui5/core/ViewSlots": { slots: [], getView: () => null },
      "z2ui5/core/Context": { of: (el) => el?.owner ?? null },
    },
    sandbox: { document: doc },
  });
  const fire = (type, target) => {
    for (const l of listeners.filter((x) => x.type === type)) {
      l.fn({ type, target });
    }
  };
  return {
    ScrollFocus,
    ctx,
    doc,
    listeners,
    errors,
    fire,
    nodes: { body, root, appField, appPopupItem, hostField },
  };
}

test("on a page of the app's own the answer is always yes", () => {
  const { ScrollFocus, ctx, doc, nodes } = load({ embedded: false });
  for (const active of [nodes.hostField, nodes.body, nodes.appField, null]) {
    doc.activeElement = active;
    expect(ScrollFocus.mayMoveFocus(ctx)).toBe(true);
  }
  // no context at all (a control of no component) is not embedded either
  expect(ScrollFocus.mayMoveFocus(null)).toBe(true);
});

test("embedded, a focus in the host's page is the host's", () => {
  const { ScrollFocus, ctx, doc, nodes } = load();
  doc.activeElement = nodes.hostField;
  expect(ScrollFocus.mayMoveFocus(ctx)).toBe(false);
});

test("embedded, a focus in the app - its DOM or a popup of it - may move", () => {
  const { ScrollFocus, ctx, doc, nodes } = load();
  doc.activeElement = nodes.appField;
  expect(ScrollFocus.mayMoveFocus(ctx)).toBe(true);
  doc.activeElement = nodes.appPopupItem;
  expect(ScrollFocus.mayMoveFocus(ctx)).toBe(true);
});

// The body: nothing is focused - a rebuild took the app's focused field
// away, or the host's page never focused anything. The user's last focus or
// click decides, and before the first one it was not the app.
test("embedded, a focus on the body follows where the user went last", () => {
  const { ScrollFocus, ctx, doc, nodes, fire } = load();
  ScrollFocus.watchFocus(ctx);
  doc.activeElement = nodes.body;
  expect(ScrollFocus.mayMoveFocus(ctx)).toBe(false);

  fire("pointerdown", nodes.appField);
  expect(ScrollFocus.mayMoveFocus(ctx)).toBe(true);

  // a Tab or a click into the host's page ...
  fire("focusin", nodes.hostField);
  expect(ScrollFocus.mayMoveFocus(ctx)).toBe(false);

  // ... and back into a popup of the app (focusin reaches it too)
  fire("focusin", nodes.appPopupItem);
  expect(ScrollFocus.mayMoveFocus(ctx)).toBe(true);

  fire("pointerdown", nodes.hostField);
  expect(ScrollFocus.mayMoveFocus(ctx)).toBe(false);
});

test("the recorder is on only embedded, once, and comes off again", () => {
  const standalone = load({ embedded: false });
  standalone.ScrollFocus.watchFocus(standalone.ctx);
  expect(standalone.listeners).toEqual([]);

  const { ScrollFocus, ctx, listeners } = load();
  ScrollFocus.watchFocus(ctx);
  ScrollFocus.watchFocus(ctx);
  // capture phase: a host handler that stops the event cannot hide it
  expect(listeners.map((l) => [l.type, l.capture])).toEqual([
    ["focusin", true],
    ["pointerdown", true],
  ]);
  ScrollFocus.unwatchFocus(ctx);
  expect(listeners).toEqual([]);
  expect(ctx.focus.listener).toBe(null);
  // idempotent - Component.exit may run on a context that never watched
  ScrollFocus.unwatchFocus(ctx);
  ScrollFocus.unwatchFocus(specContext());
});

test("isInComponent answers no, and never throws, for what nothing resolves", () => {
  const { ScrollFocus, ctx, nodes, errors } = load();
  expect(ScrollFocus.isInComponent(ctx, null)).toBe(false);
  expect(ScrollFocus.isInComponent(ctx, { nodeType: 3 })).toBe(false);
  expect(ScrollFocus.isInComponent(null, nodes.appField)).toBe(false);
  const throwing = {
    nodeType: 1,
    get ui5El() {
      throw new Error("registry gone");
    },
  };
  expect(ScrollFocus.isInComponent(ctx, throwing)).toBe(false);
  expect(errors).toEqual(["isInComponent: resolving the node failed"]);
});

// The other direction: S_FOCUS reports where the focus is. Embedded, a
// focus in the host's page is not reported at all - a host control's id is
// none of the app's business, and echoed back as SET_FOCUS it would name
// the host's field.
test("embedded, S_FOCUS leaves out a focus in the host's page", () => {
  const { ScrollFocus, ctx, doc, nodes } = load();
  doc.activeElement = nodes.hostField;
  expect(ScrollFocus.getFocusInfo(ctx)).toBe(undefined);
  doc.activeElement = nodes.appPopupItem;
  expect(ScrollFocus.getFocusInfo(ctx)).toEqual({ ID: "app--select-list" });

  const standalone = load({ embedded: false });
  standalone.doc.activeElement = standalone.nodes.hostField;
  expect(standalone.ScrollFocus.getFocusInfo(standalone.ctx)).toEqual({
    ID: "host--input",
  });
});
