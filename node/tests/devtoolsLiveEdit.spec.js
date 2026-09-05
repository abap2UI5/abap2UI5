// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");

// Tests the real implementation shipped in
// app/webapp/devtools/LiveEdit.js - the local, roundtrip-free
// re-render of a view slot from the developer tools editor.

// The REAL tab registry, with the modules it renders from stubbed away:
// LiveEdit resolves a tab's slot through Tabs.get(), so the mapping is
// pinned to the shipped table instead of to a copy in this spec (which is
// what the second table inside LiveEdit was).
function realTabs() {
  const { module } = loadModule("devtools/Tabs.js", {
    deps: {
      // Only the table is read here (Tabs.get), never a produce() - so
      // the modules a tab renders from stay empty stubs.
      "z2ui5/core/AppState": { state: {} },
      "z2ui5/core/ViewSlots": {
        getView: () => undefined,
        getViewXml: () => "",
      },
      "z2ui5/devtools/Format": {},
      "z2ui5/devtools/Inspect": {},
      "z2ui5/devtools/Picker": {},
      "z2ui5/devtools/Recorder": {},
    },
  });
  return module;
}

function loadLiveEdit({ views = {}, slotXml = {}, isBusy = false } = {}) {
  const calls = [];
  const logged = [];
  const destroyed = [];
  let failWith = null;

  const Slots = {
    action(method, slotKey, xml, mOptions, seq) {
      calls.push({ method, slotKey, xml, mOptions, seq });
      if (failWith) throw failWith;
      return Promise.resolve();
    },
  };
  const { module } = loadModule("devtools/LiveEdit.js", {
    deps: {
      "z2ui5/core/actions/Slots": Slots,
      "z2ui5/core/AppState": { state: { isBusy } },
      "z2ui5/core/Lib": { logError: (m) => logged.push(m) },
      "z2ui5/core/ViewSlots": {
        getView: (key) => views[key],
        getViewXml: (key) => slotXml[key],
        destroy: (key) => destroyed.push(key),
      },
      "z2ui5/devtools/Tabs": realTabs(),
    },
  });
  return {
    LiveEdit: module,
    calls,
    logged,
    fail: (e) => {
      failWith = e;
    },
  };
}

function fakeView({ xml, data } = {}) {
  let current = data;
  return {
    mProperties: xml === undefined ? {} : { viewContent: xml },
    getModel: () => ({
      getData: () => current,
      setData: (next) => {
        current = next;
      },
    }),
    _read: () => current,
  };
}

test.describe("tab to slot mapping", () => {
  test("maps the view tabs onto their slots", () => {
    const { LiveEdit } = loadLiveEdit();
    expect(LiveEdit.slotOfTab("VIEW")).toBe("MAIN");
    expect(LiveEdit.slotOfTab("POPUP")).toBe("POPUP");
    expect(LiveEdit.slotOfTab("POPOVER")).toBe("POPOVER");
    expect(LiveEdit.slotOfTab("NEST1")).toBe("NEST");
    expect(LiveEdit.slotOfTab("NEST2")).toBe("NEST2");
  });

  // The mapping IS the registry: every tab that names a slot and shows
  // its XML is editable, and nothing else - so a slot tab added to
  // Tabs.js is applicable without a second table being touched here.
  test("every XML sub-view of the registry is editable, no other tab is", () => {
    const { LiveEdit } = loadLiveEdit();
    const Tabs = realTabs();
    for (const tab of Tabs._internals.TABS) {
      const expected = tab.aspect === "XML" ? tab.slot : undefined;
      expect(LiveEdit.slotOfTab(tab.key)).toBe(expected);
    }
  });

  test("a non-view tab maps to nothing and cannot be applied", () => {
    const { LiveEdit } = loadLiveEdit();
    // MODEL names a slot in the registry, but shows the model rather than
    // the XML - there is nothing to render back into the slot.
    expect(LiveEdit.slotOfTab("MODEL")).toBe(undefined);
    expect(LiveEdit.slotOfTab("PICK")).toBe(undefined);
    expect(LiveEdit.canApply("MODEL")).toBe(false);
    expect(LiveEdit.canApply("HISTORY")).toBe(false);
    expect(LiveEdit.canApply("NOT_A_TAB")).toBe(false);
  });

  test("a view tab is only applicable while its slot is filled", () => {
    const empty = loadLiveEdit();
    expect(empty.LiveEdit.canApply("POPUP")).toBe(false);
    const filled = loadLiveEdit({ views: { POPUP: fakeView() } });
    expect(filled.LiveEdit.canApply("POPUP")).toBe(true);
  });
});

test.describe("apply", () => {
  test("re-renders the slot through the display action", async () => {
    const h = loadLiveEdit({ views: { MAIN: fakeView({ data: { A: 1 } }) } });
    const result = await h.LiveEdit.apply("VIEW", "<mvc:View/>");
    expect(h.calls.length).toBe(1);
    expect(h.calls[0].method).toBe("display");
    expect(h.calls[0].slotKey).toBe("MAIN");
    expect(h.calls[0].xml).toBe("<mvc:View/>");
    // no seq: this display belongs to no roundtrip and must not be
    // discarded by the superseded-request guard
    expect(h.calls[0].seq).toBe(undefined);
    expect(result).toContain("LOCAL preview");
  });

  test("carries the model over for a standalone slot", async () => {
    const view = fakeView({ data: { A: 1 } });
    const h = loadLiveEdit({ views: { POPUP: view } });
    await h.LiveEdit.apply("POPUP", "<Dialog/>");
    // the same view double is returned after the display, so the restored
    // data is observable on it
    expect(view._read()).toEqual({ A: 1 });
  });

  test("refuses an empty editor and a tab without a slot", async () => {
    const h = loadLiveEdit({ views: { MAIN: fakeView() } });
    expect(await h.LiveEdit.apply("VIEW", "   ")).toContain("empty");
    expect(await h.LiveEdit.apply("MODEL", "<x/>")).toContain("no view slot");
    expect(h.calls.length).toBe(0);
  });

  test("refuses a slot that is not filled", async () => {
    const h = loadLiveEdit();
    expect(await h.LiveEdit.apply("POPUP", "<Dialog/>")).toContain(
      "not filled",
    );
    expect(h.calls.length).toBe(0);
  });

  test("a broken XML reports the error instead of throwing", async () => {
    const h = loadLiveEdit({ views: { MAIN: fakeView() } });
    h.fail(new Error("Opening tag not closed"));
    const result = await h.LiveEdit.apply("VIEW", "<mvc:View>");
    expect(result).toContain("Could not build the view");
    expect(result).toContain("Opening tag not closed");
    expect(h.logged.length).toBe(1);
  });
});

test.describe("isBusy", () => {
  // originalXml( ) is gone with the private table: the dialog's Reset
  // reads the slot's XML through the tab registry (Tabs.render), so this
  // module no longer offers a second reader of the same string.
  test("the module exposes only what the dialog calls", () => {
    const { LiveEdit } = loadLiveEdit();
    expect(Object.keys(LiveEdit).sort()).toEqual([
      "apply",
      "canApply",
      "isBusy",
      "slotOfTab",
    ]);
  });

  test("reports a running roundtrip", () => {
    expect(loadLiveEdit({ isBusy: true }).LiveEdit.isBusy()).toBe(true);
    expect(loadLiveEdit().LiveEdit.isBusy()).toBe(false);
  });
});
