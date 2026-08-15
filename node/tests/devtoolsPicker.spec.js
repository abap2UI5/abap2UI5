// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");

// Tests the real implementation shipped in
// app/webapp/devtools/Picker.js. describe() is the whole payload of
// the feature (the DOM pick around it only decides WHICH control it gets),
// so the specs drive it with UI5-shaped control doubles.

function loadPicker({ slotKey = "MAIN", closestTo } = {}) {
  const { module } = loadModule("devtools/Picker.js", {
    deps: {
      "sap/ui/core/Element": closestTo ? { closestTo } : {},
      "z2ui5/core/Lib": { logError() {}, getElementById: () => null },
      "z2ui5/core/ViewSlots": { containingSlotKey: () => slotKey },
    },
    sandbox: {
      document: {
        getElementById: () => null,
        createElement: () => ({ style: {}, classList: { add() {} } }),
        body: { appendChild() {}, removeChild() {} },
        addEventListener() {},
        removeEventListener() {},
      },
      window: { location: { href: "https://sap.example.com/" } },
    },
  });
  return module;
}

// A control double carrying the members the picker reads: metadata name,
// id, binding infos and the event registry.
function fakeControl({
  type = "sap.m.Input",
  id = "myInput",
  bindingInfos = {},
  events = {},
  modelData = {},
} = {}) {
  const model = {
    getProperty: (path) => {
      if (!path.startsWith("/")) return undefined;
      return modelData[path.slice(1)];
    },
  };
  return {
    getMetadata: () => ({ getName: () => type }),
    getId: () => id,
    mBindingInfos: bindingInfos,
    mEventRegistry: events,
    getModel: () => model,
    getBindingContext: () => undefined,
  };
}

test.describe("describe", () => {
  test("reports type, id and the owning view slot", () => {
    const Picker = loadPicker({ slotKey: "POPUP" });
    const out = Picker.describe(fakeControl());
    expect(out).toContain("sap.m.Input");
    expect(out).toContain("myInput");
    expect(out).toContain("POPUP");
  });

  test("resolves a simple binding to its current value", () => {
    const Picker = loadPicker();
    const control = fakeControl({
      bindingInfos: { value: { path: "/NAME" } },
      modelData: { NAME: "Berlin" },
    });
    const out = Picker.describe(control);
    expect(out).toContain("value");
    expect(out).toContain("/NAME");
    expect(out).toContain("Berlin");
  });

  test("lists every part of a composite binding separately", () => {
    const Picker = loadPicker();
    const control = fakeControl({
      bindingInfos: {
        text: { parts: [{ path: "/FIRST" }, { path: "/LAST" }] },
      },
      modelData: { FIRST: "Ada", LAST: "Lovelace" },
    });
    const out = Picker.describe(control);
    expect(out).toContain("/FIRST");
    expect(out).toContain("Ada");
    expect(out).toContain("/LAST");
    expect(out).toContain("Lovelace");
  });

  test("says so when a control carries no binding", () => {
    const Picker = loadPicker();
    expect(Picker.describe(fakeControl())).toContain("no binding");
  });

  test("reads the backend event name off the attached handler", () => {
    const Picker = loadPicker();
    const control = fakeControl({
      events: {
        press: [{ fFunction: function () { this.eB(["BUTTON_SAVE"]); } }],
      },
    });
    const out = Picker.describe(control);
    expect(out).toContain("press -> eB('BUTTON_SAVE')");
  });

  test("keeps an event whose handler is not a framework call", () => {
    const Picker = loadPicker();
    const control = fakeControl({
      events: { press: [{ fFunction: function () { return 1; } }] },
    });
    const out = Picker.describe(control);
    expect(out).toContain("press");
    // the event is listed by name only - no framework call to resolve
    expect(out).not.toContain("press ->");
  });

  test("a missing control yields a message, never a throw", () => {
    const Picker = loadPicker();
    expect(Picker.describe(null)).toContain("no control found");
  });

  test("a binding path with no value is reported as such", () => {
    const Picker = loadPicker();
    const control = fakeControl({
      bindingInfos: { value: { path: "/GONE" } },
      modelData: {},
    });
    expect(Picker.describe(control)).toContain("no value at this path");
  });

  test("describes tables and structures by shape, not by dumping them", () => {
    const Picker = loadPicker();
    const { renderValue } = Picker._internals;
    expect(renderValue([1, 2, 3])).toBe("table, 3 row(s)");
    expect(renderValue({ A: 1 })).toBe("structure, 1 field(s)");
    expect(renderValue("")).toBe("(empty string)");
    expect(renderValue(null)).toBe("null");
  });
});

test.describe("lifecycle", () => {
  test("is inactive until started and reports its state", () => {
    const Picker = loadPicker();
    expect(Picker.isActive()).toBe(false);
    Picker.start(() => {});
    expect(Picker.isActive()).toBe(true);
    Picker.stop();
    expect(Picker.isActive()).toBe(false);
  });

  test("starting twice does not stack a second pick", () => {
    const Picker = loadPicker();
    Picker.start(() => {});
    Picker.start(() => {});
    Picker.stop();
    expect(Picker.isActive()).toBe(false);
  });
});

// The report of the last pick lives here rather than on the dialog: the
// Picked Control tab is rendered from the tab registry like every other
// tab, and the registry has to reach a tab's content without the dialog
// handing it over.
test.describe("last report", () => {
  function loadPickerWithDom() {
    const listeners = [];
    const { module } = loadModule("devtools/Picker.js", {
      deps: {
        "sap/ui/core/Element": {},
        "z2ui5/core/Lib": { logError() {}, getElementById: () => null },
        "z2ui5/core/ViewSlots": { containingSlotKey: () => "MAIN" },
      },
      sandbox: {
        document: {
          getElementById: () => null,
          createElement: () => ({ style: {}, classList: { add() {} } }),
          body: { appendChild() {}, removeChild() {} },
          addEventListener: (type, fn) => listeners.push({ type, fn }),
          removeEventListener: (type, fn) => {
            const i = listeners.findIndex((l) => l.type === type && l.fn === fn);
            if (i >= 0) listeners.splice(i, 1);
          },
        },
        window: { location: { href: "https://sap.example.com/" } },
      },
    });
    const fire = (type) => {
      for (const l of listeners.filter((x) => x.type === type)) {
        l.fn({ target: null, preventDefault() {}, stopPropagation() {}, key: "Escape" });
      }
    };
    return { Picker: module, fire };
  }

  test("is empty before the first pick", () => {
    expect(loadPickerWithDom().Picker.lastReport()).toBe("");
  });

  test("holds the report of the control that was picked", () => {
    const { Picker, fire } = loadPickerWithDom();
    Picker.start(() => {});
    fire("click");
    // no control under the cursor still produces a report, and that is
    // what the tab has to show
    expect(Picker.lastReport()).toContain("no control found");
  });

  test("a cancelled pick leaves the previous report standing", () => {
    const { Picker, fire } = loadPickerWithDom();
    Picker.start(() => {});
    fire("click");
    const first = Picker.lastReport();
    Picker.start(() => {});
    fire("keydown"); // Escape
    expect(Picker.lastReport()).toBe(first);
  });
});
