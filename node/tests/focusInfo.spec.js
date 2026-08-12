// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");
const { loadLib } = require("./loadLibModule");

// Tests ScrollFocus.focusTextInput / getFocusInfo: the caret must be read from
// the control's real <input>/<textarea>, not from document.activeElement
// directly. Clicking a SearchField's clear "X" button can make the active
// element a non-text node whose selectionStart is undefined - reporting that
// as 0 would later snap the caret to the far left. When no text field owns a
// selection, SELECTION_* is omitted so focus is restored without a caret.

function loadScrollFocus({ Element = {}, deps = {}, sandbox = {} } = {}) {
  return loadModule("core/ScrollFocus.js", {
    deps: {
      "sap/ui/core/Element": Element,
      // the real Lib - the text-field detection and the caret read under
      // test live there, so a stub would test a copy
      "z2ui5/core/Lib": loadLib().Lib,
      ...deps,
    },
    sandbox,
  });
}

test("focusTextInput returns the active element when it is a text field", () => {
  const { module: ScrollFocus } = loadScrollFocus();
  const input = { tagName: "INPUT" };
  expect(ScrollFocus.focusTextInput(input, {})).toBe(input);
});

test("focusTextInput falls back to the control's focus DOM ref", () => {
  const { module: ScrollFocus } = loadScrollFocus();
  const button = { tagName: "SPAN" };
  const focusRef = { tagName: "INPUT" };
  const ui5El = { getFocusDomRef: () => focusRef };
  expect(ScrollFocus.focusTextInput(button, ui5El)).toBe(focusRef);
});

test("focusTextInput falls back to the first inner text field", () => {
  const { module: ScrollFocus } = loadScrollFocus();
  const button = { tagName: "SPAN" };
  const inner = { tagName: "TEXTAREA" };
  const ui5El = {
    getFocusDomRef: () => ({ tagName: "DIV" }),
    getDomRef: () => ({ querySelector: () => inner }),
  };
  expect(ScrollFocus.focusTextInput(button, ui5El)).toBe(inner);
});

test("focusTextInput returns null for a control without a text field", () => {
  const { module: ScrollFocus } = loadScrollFocus();
  const button = { tagName: "SPAN" };
  const ui5El = {
    getFocusDomRef: () => ({ tagName: "BUTTON" }),
    getDomRef: () => ({ querySelector: () => null }),
  };
  expect(ScrollFocus.focusTextInput(button, ui5El)).toBe(null);
});

// getFocusInfo integration: with a text input focused, the caret is reported;
// with a non-text active element (clear button), SELECTION_* is omitted.

function loadForFocusInfo({ activeElement, control }) {
  return loadScrollFocus({
    Element: { closestTo: () => control },
    deps: {
      "z2ui5/core/ViewSlots": { slots: [] },
    },
    sandbox: { document: { activeElement } },
  });
}

test("getFocusInfo reports the caret from the focused text field", () => {
  const input = { tagName: "INPUT", selectionStart: 3, selectionEnd: 3 };
  const control = { getId: () => "field", getFocusDomRef: () => input };
  const { module: ScrollFocus } = loadForFocusInfo({ activeElement: input, control });

  const info = ScrollFocus.getFocusInfo();
  expect(info.ID).toBe("field");
  expect(info.SELECTION_START).toBe(3);
  expect(info.SELECTION_END).toBe(3);
});

test("getFocusInfo omits the caret when the active element is not a text field", () => {
  const button = { tagName: "SPAN" };
  const control = {
    getId: () => "search",
    getFocusDomRef: () => ({ tagName: "BUTTON" }),
    getDomRef: () => ({ querySelector: () => null }),
  };
  const { module: ScrollFocus } = loadForFocusInfo({
    activeElement: button,
    control,
  });

  const info = ScrollFocus.getFocusInfo();
  expect(info.ID).toBe("search");
  expect("SELECTION_START" in info).toBe(false);
  expect("SELECTION_END" in info).toBe(false);
});
