// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");

// Tests the real app/webapp/cc/ScanInput.js - a sap.m.Input that carries the
// HTML `inputmode` as a property. What the specs pin down is the reason the
// control exists: the mode is re-written by the control itself on every
// render, so no re-render can lose it, and a bound mode reaches the live DOM
// without costing a re-render.

// Stands in for sap.m.Input: the pieces ScanInput actually builds on - the
// generated property accessors, the parent's rendering hook, and the inner
// <input> that getFocusDomRef() resolves to.
function inputStub() {
  function Base() {}
  Base.prototype.onAfterRendering = function () {
    this.baseAfterRendering = (this.baseAfterRendering || 0) + 1;
  };
  Base.prototype.setProperty = function (name, value, suppressInvalidate) {
    this.props[name] = value;
    this.propertyWrites.push({ name, value, suppressInvalidate });
    return this;
  };
  Base.prototype.getInputMode = function () {
    return this.props.inputMode;
  };
  Base.prototype.getFocusDomRef = function () {
    return this._dom;
  };
  Base.extend = function (_name, def) {
    function Ctrl() {
      this.props = { inputMode: "" };
      this.propertyWrites = [];
      this._dom = null;
    }
    Ctrl.prototype = Object.create(Base.prototype);
    Object.assign(Ctrl.prototype, def);
    return Ctrl;
  };
  return Base;
}

// The inner <input> UI5 builds anew on every render - which is exactly why an
// attribute written once does not survive.
function domStub() {
  const attrs = {};
  return {
    attrs,
    setAttribute: (k, v) => {
      attrs[k] = v;
    },
    removeAttribute: (k) => {
      delete attrs[k];
    },
  };
}

function load() {
  const Input = inputStub();
  const { module: ScanInput } = loadModule("cc/ScanInput.js", {
    deps: { "sap/m/Input": Input, "sap/m/InputRenderer": {} },
  });
  return { ScanInput };
}

// A control with a mode set, not rendered yet.
function control(mode) {
  const { ScanInput } = load();
  const ctrl = new ScanInput();
  if (mode !== undefined) ctrl.setInputMode(mode);
  return ctrl;
}

// One render: UI5 builds a NEW inner element, then calls onAfterRendering.
function render(ctrl) {
  ctrl._dom = domStub();
  ctrl.onAfterRendering();
  return ctrl._dom;
}

test("writes the mode onto the inner input when the control renders", () => {
  const ctrl = control("none");
  const dom = render(ctrl);
  expect(dom.attrs.inputmode).toBe("none");
});

test("still runs sap.m.Input's own rendering hook", () => {
  // forgetting the super call would break everything the base class does
  // after rendering, which no inputmode assertion would ever notice
  const ctrl = control("none");
  render(ctrl);
  expect(ctrl.baseAfterRendering).toBe(1);
});

test("re-applies the mode on every render", () => {
  // the whole point of the property: the DOM element the attribute sat on is
  // gone after a re-render, and the control writes it again by itself
  const ctrl = control("none");
  render(ctrl);
  const second = render(ctrl);
  expect(second.attrs.inputmode).toBe("none");
});

test("an unset mode leaves a plain sap.m.Input", () => {
  const ctrl = control();
  const dom = render(ctrl);
  expect(dom.attrs).toEqual({});
});

test("a mode set while rendered reaches the live DOM", () => {
  const ctrl = control();
  const dom = render(ctrl);
  ctrl.setInputMode("numeric");
  expect(dom.attrs.inputmode).toBe("numeric");
});

test("setting the mode does not invalidate the control", () => {
  // a bound mode must not re-render the input (and its suggestion list) on
  // every toggle - nothing UI5 renders depends on the value
  const ctrl = control();
  render(ctrl);
  ctrl.setInputMode("none");
  expect(ctrl.propertyWrites).toEqual([
    { name: "inputMode", value: "none", suppressInvalidate: true },
  ]);
});

test("clearing the mode removes the attribute again", () => {
  // a bound mode has to be reversible without the app removing anything
  const ctrl = control("none");
  const dom = render(ctrl);
  ctrl.setInputMode("");
  expect(dom.attrs.inputmode).toBeUndefined();
});

test("a mode set before the first render lands at that render", () => {
  const ctrl = control("none");
  expect(ctrl._dom).toBeNull();
  const dom = render(ctrl);
  expect(dom.attrs.inputmode).toBe("none");
});
