// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");

// Tests the real implementation shipped in
// app/webapp/devtools/LiveEdit.js - the local, roundtrip-free
// re-render of a view slot from the developer tools editor.

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
    expect(LiveEdit.slotOfTab("NEST1")).toBe("NEST");
    expect(LiveEdit.slotOfTab("NEST2")).toBe("NEST2");
  });

  test("a non-view tab maps to nothing and cannot be applied", () => {
    const { LiveEdit } = loadLiveEdit();
    expect(LiveEdit.slotOfTab("MODEL")).toBe(undefined);
    expect(LiveEdit.canApply("MODEL")).toBe(false);
    expect(LiveEdit.canApply("HISTORY")).toBe(false);
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

test.describe("originalXml / isBusy", () => {
  test("returns the view's own XML, falling back to the recorded one", () => {
    const withView = loadLiveEdit({
      views: { MAIN: fakeView({ xml: "<live/>" }) },
      slotXml: { MAIN: "<recorded/>" },
    });
    expect(withView.LiveEdit.originalXml("VIEW")).toBe("<live/>");

    const xmlOnly = loadLiveEdit({ slotXml: { POPUP: "<recorded/>" } });
    expect(xmlOnly.LiveEdit.originalXml("POPUP")).toBe("<recorded/>");
    expect(xmlOnly.LiveEdit.originalXml("MODEL")).toBe("");
  });

  test("reports a running roundtrip", () => {
    expect(loadLiveEdit({ isBusy: true }).LiveEdit.isBusy()).toBe(true);
    expect(loadLiveEdit().LiveEdit.isBusy()).toBe(false);
  });
});
