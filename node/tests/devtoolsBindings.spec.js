// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");
const { loadLib } = require("./loadLibModule");

// Tests the real implementation shipped in app/webapp/devtools/Bindings.js
// - the Bindings tab, and its three checks that answer the most common
// developer questions: empty field, huge response, change does not
// arrive. devtools/Inspect.js re-exports formatBindings for the tab
// registry.

const SLOTS = [
  { key: "MAIN", ownsModel: true },
  { key: "NEST", ownsModel: false },
  { key: "NEST2", ownsModel: false },
  { key: "POPUP", ownsModel: true },
  { key: "POPOVER", ownsModel: true },
];

function fakeView({ xml, data, changedPaths } = {}) {
  const model = data
    ? {
        getData: () => data,
        // the marker ViewSlots.trackedModel resolves on - the seeded model
        // plays the framework-owned JSON model
        _z2ui5Tracked: true,
        _z2ui5ChangedPaths: changedPaths ? new Set(changedPaths) : undefined,
      }
    : undefined;
  return {
    mProperties: xml === undefined ? {} : { viewContent: xml },
    getModel: () => model,
  };
}

function loadBindings({ views = {}, slotXml = {} } = {}) {
  // the REAL core/Lib: buildDeltaFromPaths is the shipped function the
  // delta preview has to agree with - and its spec context is the one the
  // renderer takes first (core/Context.js); the slot stub answers for it
  const { Lib, ctx } = loadLib();
  const { module } = loadModule("devtools/Bindings.js", {
    // devtools/Format.js and devtools/SlotXml.js are loaded for real;
    // every other dependency is stubbed below
    autoLoad: true,
    deps: {
      "z2ui5/core/Lib": Lib,
      "z2ui5/core/ViewSlots": {
        slots: SLOTS,
        getView: (_ctx, key) => views[key],
        getViewXml: (_ctx, key) => slotXml[key],
        // mirrors the real resolver (core/ViewSlots.js): only a model
        // carrying the _z2ui5Tracked marker is the framework's
        trackedModel: (owner) => {
          const isOurs = (m) => (m?._z2ui5Tracked ? m : undefined);
          if (!owner?.getModel) return undefined;
          return isOurs(owner.getModel()) ?? isOurs(owner.getModel("http"));
        },
      },
    },
  });
  return { Bindings: module, ctx };
}

test.describe("Bindings diagnostics", () => {
  test("lists the paths bound in the view that the model does not have", () => {
    const { Bindings, ctx } = loadBindings({
      views: {
        MAIN: fakeView({
          xml:
            `<Input value="{/CUSTOMER}"/>` +
            `<Text text="{/CUSTOMR}"/>` +
            `<Table items="{/T_ITEMS}"/>`,
          data: { CUSTOMER: "x", T_ITEMS: [] },
        }),
      },
    });
    const out = Bindings.formatBindings(ctx, "MAIN");
    expect(out).toContain("BOUND IN THE VIEW BUT NOT IN THE MODEL");
    expect(out).toContain("/CUSTOMR");
    // the ones that DO exist are not reported as missing
    const missingBlock = out.slice(out.indexOf("BOUND IN THE VIEW"));
    expect(missingBlock).not.toContain("/CUSTOMER\n");
  });

  test("collects the path forms the view builder produces", () => {
    const { Bindings } = loadBindings();
    const { scrapeBindingAttributes } = Bindings._internals;
    const xml =
      `<Input value="{/A}"/>` +
      `<Text text="{path: '/B', formatter: 'x'}"/>` +
      `<Text text="{= \${/C} > 1 }"/>` +
      `<List items="{/D}"><Text text="{REL}"/></List>`;
    const found = scrapeBindingAttributes(xml);
    expect(found).toContain("A");
    expect(found).toContain("B");
    expect(found).toContain("C");
    expect(found).toContain("D");
    // a relative binding resolves against the row context and says nothing
    expect(found).not.toContain("REL");
    // parts lists continue after a comma, as objects or as strings
    const parts = scrapeBindingAttributes(
      `<Text text="{parts: ['/E', '/F'], formatter: 'x'}"/>` +
        `<Text text="{parts: [{path: '/G'}, {path: '/H'}]}"/>`,
    );
    expect(parts).toEqual(["E", "F", "G", "H"]);
  });

  // An absolute URL in a plain attribute is not a binding. Any quote
  // followed by "/" used to count, so src="/sap/public/..." reported /sap
  // as BOUND IN THE VIEW BUT NOT IN THE MODEL - in the section that is
  // meant to answer "why is my field empty", which trained the reader to
  // ignore it.
  test("does not read a URL-shaped attribute value as a binding", () => {
    const { Bindings } = loadBindings();
    const { scrapeBindingAttributes } = Bindings._internals;
    const xml =
      `<Image src="/sap/public/bc/ui5_ui5/logo.png"/>` +
      `<Link href="/some/page" text="{/TITLE}"/>` +
      `<html:iframe src="/sap/bc/ui5_ui5/ui2/ushell/shells/abap/FioriLaunchpad.html"/>`;
    expect(scrapeBindingAttributes(xml)).toEqual(["TITLE"]);
  });

  test("mentions the model attributes the view does not bind", () => {
    const { Bindings, ctx } = loadBindings({
      views: {
        MAIN: fakeView({
          xml: `<Input value="{/USED}"/>`,
          data: { USED: 1, UNUSED_A: 2, UNUSED_B: 3 },
        }),
      },
    });
    const out = Bindings.formatBindings(ctx, "MAIN");
    expect(out).toContain("2 model attribute(s) not bound");
    expect(out).toContain("UNUSED_A");
  });

  test("describes every attribute by type and shape", () => {
    const { Bindings, ctx } = loadBindings({
      views: {
        MAIN: fakeView({
          data: { NAME: "Miller AG", T_ITEMS: [1, 2], S_HEAD: { A: 1 } },
        }),
      },
    });
    const out = Bindings.formatBindings(ctx, "MAIN");
    expect(out).toContain("string  Miller AG");
    expect(out).toContain("table, 2 row(s)");
    expect(out).toContain("structure, 1 field(s)");
  });

  test("ranks the attributes by serialized size with their share", () => {
    const { Bindings, ctx } = loadBindings({
      views: {
        MAIN: fakeView({
          data: {
            SMALL: "x",
            BIG: Array.from({ length: 200 }, (_, i) => ({ COL: `row${i}` })),
          },
        }),
      },
    });
    const out = Bindings.formatBindings(ctx, "MAIN");
    expect(out).toContain("Model size:");
    expect(out).toContain("/BIG");
    expect(out).toContain("row(s)");
    // the heavy one is listed before the small one
    expect(out.indexOf("/BIG")).toBeLessThan(out.indexOf("/SMALL"));
  });

  test("previews the delta the next roundtrip will send", () => {
    const { Bindings, ctx } = loadBindings({
      views: {
        MAIN: fakeView({
          data: { NAME: "changed", OTHER: "untouched" },
          changedPaths: ["/NAME"],
        }),
      },
    });
    const out = Bindings.formatBindings(ctx, "MAIN");
    const marker = "Delta the next roundtrip will send";
    expect(out).toContain(marker);
    // the edited attribute carries the marker in the inventory above
    expect(out).toContain("* /NAME");
    // scope the assertion to the delta block: the untouched attribute is
    // listed above it, in the attribute inventory, and belongs there
    const deltaBlock = out.slice(out.indexOf(marker));
    expect(deltaBlock).toContain('"NAME": "changed"');
    expect(deltaBlock).not.toContain("untouched");
  });

  test("no delta preview when nothing was edited", () => {
    const { Bindings, ctx } = loadBindings({
      views: { MAIN: fakeView({ data: { A: 1 } }) },
    });
    expect(Bindings.formatBindings(ctx, "MAIN")).not.toContain(
      "Delta the next roundtrip",
    );
  });

  test("reports the slot it was asked for, and only that one", () => {
    const { Bindings, ctx } = loadBindings({
      views: {
        MAIN: fakeView({ data: { MAIN_ATTR: 1 } }),
        POPUP: fakeView({ data: { POPUP_ATTR: 2 } }),
      },
    });
    const out = Bindings.formatBindings(ctx, "POPUP");
    expect(out).toContain("Slot POPUP");
    expect(out).toContain("/POPUP_ATTR");
    expect(out).not.toContain("/MAIN_ATTR");
  });

  // NEST and NEST2 inherit MAIN's model by UI5 propagation; a slot without
  // a view has nothing to report either.
  test("says so for a slot that carries no model of its own", () => {
    const { Bindings, ctx } = loadBindings({
      views: { MAIN: fakeView({ data: { A: 1 } }) },
    });
    expect(Bindings.formatBindings(ctx, "NEST")).toContain(
      "no slot carries a model yet",
    );
    expect(Bindings.formatBindings(ctx, "POPUP")).toContain(
      "no slot carries a model yet",
    );
  });
});
