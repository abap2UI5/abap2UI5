// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");

// Tests the real app/webapp/cc/Focus.js caret restore. After a roundtrip the
// Focus control re-applies the caret position captured before the request.
// Two guards keep the caret from snapping to the far left when the field
// value changed while the request was in flight (e.g. clear "X" then type):
//   1. Clamp: the restored range is bounded to the field's current length,
//      so an out-of-range range can no longer collapse the caret to 0.
//   2. Race guard: when the field is focused and its live caret already sits
//      past the restored (stale) position, keep the live caret instead of
//      yanking it left over text the user just entered.

function controlStub() {
  return {
    extend(_name, def) {
      function Ctrl() {}
      Object.assign(Ctrl.prototype, def);
      return Ctrl;
    },
  };
}

// Build a Focus instance wired to a target element and a stubbed document.
function load({ target, activeElement } = {}) {
  const errors = [];
  const Lib = { logError: (m) => errors.push(m) };
  const ViewSlots = { byIdOfOwner: () => target };
  const { module: Focus } = loadModule("cc/Focus.js", {
    deps: {
      "sap/ui/core/Control": controlStub(),
      "z2ui5/core/Lib": Lib,
      "z2ui5/core/ViewSlots": ViewSlots,
    },
    sandbox: { document: { activeElement } },
  });
  return { Focus, errors };
}

// A text input DOM stub with a live caret.
function inputDom({ value = "", selectionStart = 0, selectionEnd = 0 } = {}) {
  return {
    tagName: "INPUT",
    value,
    selectionStart,
    selectionEnd,
    focused: false,
    focus() {
      this.focused = true;
    },
  };
}

// A target UI5 element wrapping an input DOM ref, capturing applyFocusInfo.
function targetWithInput(dom) {
  const applied = [];
  return {
    applied,
    getFocusInfo: () => ({ id: "field" }),
    applyFocusInfo: (info) => applied.push(info),
    getFocusDomRef: () => dom,
    getDomRef: () => dom,
  };
}

// Drive onAfterRendering with the given captured selection props.
function run(Focus, target, { selectionStart, selectionEnd }) {
  const inst = new Focus();
  const props = { focusId: "field", selectionStart, selectionEnd };
  inst.getProperty = (k) => props[k];
  inst._pendingFocus = true;
  inst.onAfterRendering();
  return inst;
}

test("clamps a captured range beyond the current value length", () => {
  const dom = inputDom({ value: "ab", selectionStart: 2, selectionEnd: 2 });
  const target = targetWithInput(dom);
  const { Focus } = load({ target, activeElement: null });

  // Captured caret was 5/5 (from a longer value that has since been cleared).
  run(Focus, target, { selectionStart: "5", selectionEnd: "5" });

  expect(target.applied).toHaveLength(1);
  expect(target.applied[0].selectionStart).toBe(2);
  expect(target.applied[0].selectionEnd).toBe(2);
});

test("keeps the live caret when the user typed past the restored position", () => {
  const dom = inputDom({ value: "22", selectionStart: 2, selectionEnd: 2 });
  const target = targetWithInput(dom);
  // The field is the active element - user kept typing during the roundtrip.
  const { Focus } = load({ target, activeElement: dom });

  // Stale captured caret is 0 (e.g. from the clear "X" click).
  run(Focus, target, { selectionStart: "0", selectionEnd: "0" });

  // Race guard wins: no applyFocusInfo, focus re-asserted, live caret intact.
  expect(target.applied).toHaveLength(0);
  expect(dom.focused).toBe(true);
  expect(dom.selectionStart).toBe(2);
});

test("restores the clamped caret when the field is not focused", () => {
  const dom = inputDom({ value: "22", selectionStart: 0, selectionEnd: 0 });
  const target = targetWithInput(dom);
  // A different element holds focus - the roundtrip legitimately restores.
  const { Focus } = load({ target, activeElement: { tagName: "BODY" } });

  run(Focus, target, { selectionStart: "1", selectionEnd: "1" });

  expect(target.applied).toHaveLength(1);
  expect(target.applied[0].selectionStart).toBe(1);
  expect(target.applied[0].selectionEnd).toBe(1);
});

test("applies the raw selection for controls without a text field", () => {
  const target = {
    applied: [],
    getFocusInfo: () => ({ id: "btn" }),
    applyFocusInfo(info) {
      this.applied.push(info);
    },
    getFocusDomRef: () => ({ tagName: "BUTTON" }),
    getDomRef: () => ({ querySelector: () => null }),
  };
  const { Focus } = load({ target, activeElement: null });

  run(Focus, target, { selectionStart: "0", selectionEnd: "0" });

  expect(target.applied).toHaveLength(1);
  expect(target.applied[0].selectionStart).toBe(0);
});
