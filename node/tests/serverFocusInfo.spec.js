// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");

// Tests Server._focusTextInput / _getFocusInfo: the caret must be read from
// the control's real <input>/<textarea>, not from document.activeElement
// directly. Clicking a SearchField's clear "X" button can make the active
// element a non-text node whose selectionStart is undefined - reporting that
// as 0 would later snap the caret to the far left. When no text field owns a
// selection, SELECTION_* is omitted so focus is restored without a caret.

function loadServer({ Element = {}, deps = {}, sandbox = {} } = {}) {
  return loadModule("core/Server.js", {
    deps: { "sap/ui/core/Element": Element, ...deps },
    sandbox,
  });
}

test("_focusTextInput returns the active element when it is a text field", () => {
  const { module: Server } = loadServer();
  const input = { tagName: "INPUT" };
  expect(Server._focusTextInput(input, {})).toBe(input);
});

test("_focusTextInput falls back to the control's focus DOM ref", () => {
  const { module: Server } = loadServer();
  const button = { tagName: "SPAN" };
  const focusRef = { tagName: "INPUT" };
  const ui5El = { getFocusDomRef: () => focusRef };
  expect(Server._focusTextInput(button, ui5El)).toBe(focusRef);
});

test("_focusTextInput falls back to the first inner text field", () => {
  const { module: Server } = loadServer();
  const button = { tagName: "SPAN" };
  const inner = { tagName: "TEXTAREA" };
  const ui5El = {
    getFocusDomRef: () => ({ tagName: "DIV" }),
    getDomRef: () => ({ querySelector: () => inner }),
  };
  expect(Server._focusTextInput(button, ui5El)).toBe(inner);
});

test("_focusTextInput returns null for a control without a text field", () => {
  const { module: Server } = loadServer();
  const button = { tagName: "SPAN" };
  const ui5El = {
    getFocusDomRef: () => ({ tagName: "BUTTON" }),
    getDomRef: () => ({ querySelector: () => null }),
  };
  expect(Server._focusTextInput(button, ui5El)).toBe(null);
});

// _getFocusInfo integration: with a text input focused, the caret is reported;
// with a non-text active element (clear button), SELECTION_* is omitted.

function loadForFocusInfo({ activeElement, control }) {
  return loadServer({
    Element: { closestTo: () => control },
    deps: {
      "z2ui5/core/ViewSlots": { slots: [] },
    },
    sandbox: { document: { activeElement } },
  });
}

test("_getFocusInfo reports the caret from the focused text field", () => {
  const input = { tagName: "INPUT", selectionStart: 3, selectionEnd: 3 };
  const control = { getId: () => "field", getFocusDomRef: () => input };
  const { module: Server } = loadForFocusInfo({ activeElement: input, control });

  const info = Server._getFocusInfo();
  expect(info.ID).toBe("field");
  expect(info.SELECTION_START).toBe(3);
  expect(info.SELECTION_END).toBe(3);
});

test("_getFocusInfo omits the caret when the active element is not a text field", () => {
  const button = { tagName: "SPAN" };
  const control = {
    getId: () => "search",
    getFocusDomRef: () => ({ tagName: "BUTTON" }),
    getDomRef: () => ({ querySelector: () => null }),
  };
  const { module: Server } = loadForFocusInfo({
    activeElement: button,
    control,
  });

  const info = Server._getFocusInfo();
  expect(info.ID).toBe("search");
  expect("SELECTION_START" in info).toBe(false);
  expect("SELECTION_END" in info).toBe(false);
});
