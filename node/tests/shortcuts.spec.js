// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");
const { specContext } = require("./loadLibModule");

// The pure halves of core/actions/Shortcuts.js, driven directly: the
// registry's dispatch through the keydown listener is pinned by
// frontendAction.spec.js, but the two functions every registration and
// every keystroke go through - normalizeShortcut (the spelling an app
// writes) and shortcutFromEvent (the spelling a keydown produces) - had no
// spec of their own, and the one rule that matters is that both produce
// the SAME string for the same combination. Also here: the scope
// precedence (control scope over slot scope over the unscoped entry, the
// innermost open slot first), which the composed spec only touches.

// A minimal document that records the keydown listener and can press a key.
function docStub() {
  const listeners = [];
  return {
    document: {
      addEventListener: (type, fn) => {
        if (type === "keydown") listeners.push(fn);
      },
      removeEventListener: (type, fn) => {
        const i = listeners.indexOf(fn);
        if (i >= 0) listeners.splice(i, 1);
      },
    },
    press: (key, mods = {}) => {
      let prevented = false;
      const oEvent = {
        key,
        ctrlKey: false,
        shiftKey: false,
        altKey: false,
        metaKey: false,
        ...mods,
        preventDefault: () => (prevented = true),
      };
      for (const fn of listeners) fn(oEvent);
      return prevented;
    },
  };
}

// `views` are the open slots (a key present means the slot is showing),
// `controls` the resolvable control ids with their open/visible state.
function load({ views = {}, controls = {} } = {}) {
  const doc = docStub();
  const errors = [];
  const fired = [];
  const ctx = specContext();
  const oController = { ctx, eB: (args) => fired.push(args) };
  const { module: Shortcuts } = loadModule("core/actions/Shortcuts.js", {
    sandbox: { document: doc.document },
    deps: {
      "z2ui5/core/Lib": {
        logError: (m) => errors.push(m),
        isControllerAlive: () => true,
      },
      "z2ui5/core/ViewSlots": {
        getView: (_ctx, key) => views[key] || null,
        resolveById: (_ctx, id) => controls[id] || null,
      },
    },
  });
  const register = (combo, event, scope) =>
    Shortcuts.handlers.KEYBOARD_SHORTCUT(
      oController,
      ["KEYBOARD_SHORTCUT", combo, event, scope].filter((a) => a !== undefined),
    );
  return { Shortcuts, register, press: doc.press, fired, errors, views };
}

test.describe("normalizeShortcut (the spelling an app writes)", () => {
  const cases = [
    ["Ctrl+Shift+S", "ctrl+shift+s"],
    // any order and casing of the modifiers, spaces around the +
    ["shift + CTRL + s", "ctrl+shift+s"],
    ["S+Ctrl", "ctrl+s"],
    // the aliases apps and UI5 use
    ["Control+Return", "ctrl+enter"],
    ["Cmd+K", "meta+k"],
    ["Command+K", "meta+k"],
    ["Option+Space", "alt+ "],
    ["Esc", "escape"],
    ["Del", "delete"],
    ["Ins", "insert"],
    // a bare key
    ["F2", "f2"],
    // the LAST key wins when several are named
    ["Ctrl+A+B", "ctrl+b"],
    // modifiers only name no key
    ["Ctrl+Shift", ""],
    ["Ctrl+", ""],
    ["", ""],
    [undefined, ""],
    [null, ""],
  ];
  for (const [combo, expected] of cases) {
    test(`${JSON.stringify(combo)} -> ${JSON.stringify(expected)}`, () => {
      const { Shortcuts } = load();
      expect(Shortcuts.normalizeShortcut(combo)).toBe(expected);
    });
  }

  // The + key itself: the separator is the key, so split( ) yields two empty
  // tokens at the end. That trailing PAIR is the key; a single trailing
  // empty ("Ctrl+", above) still names none.
  test("the + key is spelled with a trailing pair of separators", () => {
    const { Shortcuts } = load();
    expect(Shortcuts.normalizeShortcut("Ctrl++")).toBe("ctrl++");
    expect(Shortcuts.normalizeShortcut("Ctrl + +")).toBe("ctrl++");
    expect(Shortcuts.normalizeShortcut("Shift+Ctrl++")).toBe("ctrl+shift++");
    expect(Shortcuts.normalizeShortcut("+")).toBe("+");
  });

  test("a prototype name is not looked up on the alias table", () => {
    const { Shortcuts } = load();
    // `constructor` off the wire must not resolve to Object.prototype's
    expect(Shortcuts.normalizeShortcut("Ctrl+constructor")).toBe(
      "ctrl+constructor",
    );
  });
});

test.describe("shortcutFromEvent (the spelling a keydown produces)", () => {
  const event = (key, mods = {}) => ({
    key,
    ctrlKey: false,
    shiftKey: false,
    altKey: false,
    metaKey: false,
    ...mods,
  });

  test("the modifiers come out in the registry's order, the key lower-cased", () => {
    const { Shortcuts } = load();
    expect(
      Shortcuts.shortcutFromEvent(
        event("S", { metaKey: true, ctrlKey: true, shiftKey: true }),
      ),
    ).toBe("ctrl+shift+meta+s");
    expect(Shortcuts.shortcutFromEvent(event("Enter", { altKey: true }))).toBe(
      "alt+enter",
    );
  });

  test("a bare modifier press is no shortcut", () => {
    const { Shortcuts } = load();
    for (const key of ["Control", "Shift", "Alt", "Meta", ""]) {
      expect(Shortcuts.shortcutFromEvent(event(key, { ctrlKey: true }))).toBe(
        "",
      );
    }
    expect(Shortcuts.shortcutFromEvent({})).toBe("");
  });

  // the one rule that matters: registration and keydown agree
  test("agrees with normalizeShortcut for every spelling", () => {
    const { Shortcuts } = load();
    const pairs = [
      ["Ctrl+Shift+S", event("s", { ctrlKey: true, shiftKey: true })],
      ["Cmd+Return", event("Enter", { metaKey: true })],
      ["Esc", event("Escape")],
      ["Ctrl++", event("+", { ctrlKey: true })],
      ["+", event("+")],
      ["Alt+Space", event(" ", { altKey: true })],
    ];
    for (const [combo, oEvent] of pairs) {
      expect(Shortcuts.shortcutFromEvent(oEvent)).toBe(
        Shortcuts.normalizeShortcut(combo),
      );
    }
  });
});

test.describe("scope precedence", () => {
  test("a control scope wins over a slot scope while its control is open", () => {
    const controls = { myPopover: { isOpen: () => true } };
    const views = { POPOVER: {} };
    const { register, press, fired } = load({ controls, views });
    register("Ctrl+S", "SAVE");
    register("Ctrl+S", "SAVE_SLOT", "POPOVER");
    register("Ctrl+S", "SAVE_CONTROL", "myPopover");

    expect(press("s", { ctrlKey: true })).toBe(true);
    expect(fired).toEqual([["SAVE_CONTROL"]]);

    // the control closes: the slot scope is next
    controls.myPopover.isOpen = () => false;
    press("s", { ctrlKey: true });
    expect(fired).toEqual([["SAVE_CONTROL"], ["SAVE_SLOT"]]);

    // the slot closes: the unscoped entry
    delete views.POPOVER;
    press("s", { ctrlKey: true });
    expect(fired).toEqual([["SAVE_CONTROL"], ["SAVE_SLOT"], ["SAVE"]]);
  });

  test("the innermost open slot wins over an outer one", () => {
    const views = { MAIN: {}, POPUP: {}, POPOVER: {} };
    const { register, press, fired } = load({ views });
    register("F2", "EDIT_MAIN", "MAIN");
    register("F2", "EDIT_POPUP", "POPUP");
    register("F2", "EDIT_POPOVER", "POPOVER");

    press("F2");
    delete views.POPOVER;
    press("F2");
    delete views.POPUP;
    press("F2");
    expect(fired).toEqual([["EDIT_POPOVER"], ["EDIT_POPUP"], ["EDIT_MAIN"]]);
  });

  test("a control scope counts as open by visibility when it cannot open", () => {
    const controls = { panel: { getVisible: () => false } };
    const { register, press, fired } = load({ controls });
    register("F2", "EDIT");
    register("F2", "EDIT_PANEL", "panel");

    press("F2");
    controls.panel.getVisible = () => true;
    press("F2");
    expect(fired).toEqual([["EDIT"], ["EDIT_PANEL"]]);
  });

  test("a slot scope is matched case-insensitively, a control id keeps its case", () => {
    const controls = { MyPanel: { isOpen: () => true } };
    const views = { POPUP: {} };
    const { register, press, fired } = load({ controls, views });
    register("F2", "EDIT_POPUP", "popup");
    press("F2");
    register("F2", "EDIT_PANEL", "MyPanel");
    press("F2");
    expect(fired).toEqual([["EDIT_POPUP"], ["EDIT_PANEL"]]);
  });

  test("a combo with no eligible scope open fires nothing and cancels no default", () => {
    const { register, press, fired } = load();
    register("F2", "EDIT_POPUP", "POPUP");
    expect(press("F2")).toBe(false);
    expect(fired).toEqual([]);
  });
});

test("the + key round-trips from the registration to the keydown", () => {
  const { register, press, fired, errors } = load();
  register("Ctrl++", "ZOOM_IN");
  expect(errors).toEqual([]);
  expect(press("+", { ctrlKey: true })).toBe(true);
  expect(press("+")).toBe(false);
  expect(fired).toEqual([["ZOOM_IN"]]);
});
