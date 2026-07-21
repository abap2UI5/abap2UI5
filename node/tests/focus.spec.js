// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");

// Tests the real app/webapp/cc/Focus.js caret restore. After a roundtrip the
// Focus control re-applies the caret position captured before the request.
// Two guards keep the caret from snapping to the far left when the field
// value changed while the request was in flight (e.g. clear "X" then type):
//   1. Clamp: the restored range is bounded to the field's current length,
//      so an out-of-range range can no longer collapse the caret to 0.
//   2. Race guard: when the live caret already sits past the restored (stale)
//      position, keep the live caret instead of yanking it left over text the
//      user just entered. The live caret is read from the still-focused field
//      when UI5 patched it in place, or from the onBeforeRendering snapshot
//      when a full view rebuild re-created the field (so it is no longer the
//      active element by the time the caret is restored).

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
  // Mirror the real lifecycle: the live-caret snapshot is taken in
  // onBeforeRendering (while the old, focused field is still in the DOM),
  // then consumed in onAfterRendering.
  inst.onBeforeRendering();
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
  // The field is still the active element - UI5 patched it in place while the
  // user kept typing during the roundtrip.
  const { Focus } = load({ target, activeElement: dom });

  // Stale captured caret is 0 (e.g. from the clear "X" click).
  run(Focus, target, { selectionStart: "0", selectionEnd: "0" });

  // Race guard wins: the live caret (2) is restored, not the stale captured 0.
  expect(target.applied).toHaveLength(1);
  expect(target.applied[0].selectionStart).toBe(2);
  expect(target.applied[0].selectionEnd).toBe(2);
});

test("keeps the live caret from the snapshot after a full view rebuild", () => {
  // The view was rebuilt: the field the user typed in was re-created, so the
  // restored control's input is a *different* element than the one that held
  // focus (and the caret) before the render.
  const newInput = inputDom({ value: "abc", selectionStart: 0, selectionEnd: 0 });
  const target = targetWithInput(newInput);
  // Before the render the old input was focused with the caret past the
  // captured position (user kept typing while the roundtrip was in flight).
  const oldInput = inputDom({ value: "abc", selectionStart: 3, selectionEnd: 3 });
  const { Focus } = load({ target, activeElement: oldInput });

  // Captured caret was the stale 1 from when the request was dispatched.
  run(Focus, target, { selectionStart: "1", selectionEnd: "1" });

  // The pre-render snapshot (3) wins over the stale captured 1, even though the
  // restored input is no longer the active element.
  expect(target.applied).toHaveLength(1);
  expect(target.applied[0].selectionStart).toBe(3);
  expect(target.applied[0].selectionEnd).toBe(3);
});

test("clamps the kept snapshot caret to the rebuilt value length", () => {
  // Same rebuild case, but the committed (intermediate) response shortened the
  // field value, so the snapshot caret is now out of range and must clamp.
  const newInput = inputDom({ value: "ab", selectionStart: 0, selectionEnd: 0 });
  const target = targetWithInput(newInput);
  const oldInput = inputDom({ value: "abcd", selectionStart: 4, selectionEnd: 4 });
  const { Focus } = load({ target, activeElement: oldInput });

  run(Focus, target, { selectionStart: "1", selectionEnd: "1" });

  expect(target.applied).toHaveLength(1);
  expect(target.applied[0].selectionStart).toBe(2);
  expect(target.applied[0].selectionEnd).toBe(2);
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
