// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");

// bundle/webapp/core/CustomControls.js - the custom controls of
// bundle/webapp/cc/ are a bundle of their own (?z2ui5-bundle=cc), loaded
// with a <script> element before the first view that names one is built.
// Under test: which views count, where the bundle is asked for, that it is
// asked for once per page, and that a load that fails rejects - the build
// that waited must not go on without its controls (the module header has
// the reasoning; actions/Slots awaits ensure( ), slotsAction.spec.js holds
// that half).

const VERSION = "0123456789abcdef";
const ENDPOINT = "http://localhost:3000/sap/bc/z2ui5";
const BUNDLE_URL = `${ENDPOINT}?z2ui5-bundle=cc&z2ui5-version=${VERSION}`;
const VIEW =
  '<mvc:View xmlns="sap.m" xmlns:mvc="sap.ui.core.mvc" xmlns:z2ui5="z2ui5.cc">' +
  "<z2ui5:Dirty/></mvc:View>";
const PLAIN = '<mvc:View xmlns="sap.m" xmlns:mvc="sap.ui.core.mvc"><Page/></mvc:View>';

// What a promise was rejected with, null when it resolved. (The module runs
// in a vm context, so its Error is not the spec's - the message is compared.)
const rejection = (promise) =>
  promise.then(
    () => null,
    (e) => e,
  );

// `bundled`: the frontend came as the bundle - its z2ui5/embed module is
// defined and names the version of the custom controls bundle. Without it
// the frontend's files are served one by one. `bundleUrl`: where the
// frontend bundle says it was loaded from (none: not by a script element
// of its own). `url`: the endpoint of the component's roundtrips.
function load({
  bundled = true,
  bundleUrl = undefined,
  url = ENDPOINT,
  href = ENDPOINT,
} = {}) {
  const modules = new Map();
  if (bundled) modules.set("z2ui5/embed", { ccBundle: VERSION, bundleUrl });
  const scripts = [];
  // the load's timeout (a minute) is held here instead of being scheduled:
  // `expire` runs it, the short timers run as they are
  const longTimers = new Map();
  let timerId = 0;
  const { module } = loadModule("core/CustomControls.js", {
    sandbox: {
      URL,
      setTimeout: (fn, ms) => {
        if (ms < 1000) return setTimeout(fn, ms);
        timerId += 1;
        longTimers.set(timerId, { fn, ms });
        return timerId;
      },
      clearTimeout: (id) => {
        if (longTimers.has(id)) longTimers.delete(id);
        else clearTimeout(id);
      },
      window: { location: { href } },
      sap: {
        ui: {
          // the one-id probe: a loaded module or undefined, never a fetch
          require: (name) => {
            if (typeof name !== "string") {
              throw new Error("the loader must not be asked for a module");
            }
            return modules.get(name);
          },
        },
      },
      document: {
        createElement: (tag) => {
          const el = { tag, removed: false };
          el.remove = () => {
            el.removed = true;
          };
          return el;
        },
        head: { appendChild: (el) => scripts.push(el) },
      },
    },
  });
  const ctx = { state: { url } };
  // the task after the script's load event, where the load settles
  const settle = () => new Promise((resolve) => setTimeout(resolve, 5));
  return {
    CustomControls: module,
    ctx,
    scripts,
    modules,
    settle,
    // the bundle ran: its marker module is defined, then the load event
    arrive: async (index = scripts.length - 1) => {
      modules.set("z2ui5/cc/bundle", {});
      scripts[index].onload();
      await settle();
    },
    // a 200 that is not the bundle - the load event without the marker
    arriveEmpty: async (index = scripts.length - 1) => {
      scripts[index].onload();
      await settle();
    },
    fail: async (index = scripts.length - 1) => {
      scripts[index].onerror();
      await settle();
    },
    longTimers,
    // the load's timeout runs out
    expire: async () => {
      for (const [id, { fn }] of [...longTimers]) {
        longTimers.delete(id);
        fn();
      }
      await settle();
    },
  };
}

test.describe("which views need the custom controls", () => {
  const { CustomControls } = load();
  const names = (xml) => CustomControls.namesControls(xml);

  test("the namespace of the controls, under any prefix and on any element", () => {
    expect(names(VIEW)).toBe(true);
    expect(names("<mvc:View xmlns:cc='z2ui5.cc'><cc:Storage/></mvc:View>")).toBe(true);
    expect(names('<core:FragmentDefinition xmlns="z2ui5.cc"><Tree/></core:FragmentDefinition>')).toBe(true);
    expect(
      names('<mvc:View xmlns="sap.m"><VBox><x:Websocket xmlns:x="z2ui5.cc"/></VBox></mvc:View>'),
    ).toBe(true);
  });

  test("a module id of a control - core:require, an app's own JavaScript in the view", () => {
    expect(
      names("<mvc:View xmlns=\"sap.m\" core:require=\"{ D: 'z2ui5/cc/Dirty' }\"/>"),
    ).toBe(true);
    expect(names('<html:script>sap.ui.require(["z2ui5/cc/InputExt"], f)</html:script>')).toBe(true);
  });

  test("the two sibling BSPs the frontend wires in, whose code may build on a control", () => {
    expect(names('<mvc:View xmlns:cci="z2ui5_cci.cc"><cci:SignaturePad/></mvc:View>')).toBe(true);
    expect(names('<mvc:View xmlns:c="z2ui5_ccc"><c:Mine/></mvc:View>')).toBe(true);
    expect(names("<mvc:View core:require=\"{ U: 'z2ui5_ccc/Util' }\"/>")).toBe(true);
  });

  test("nothing else of the frontend, and nobody else's longer name", () => {
    expect(names(PLAIN)).toBe(false);
    expect(names("")).toBe(false);
    expect(names(undefined)).toBe(false);
    expect(names("<mvc:View core:require=\"{ F: 'z2ui5/model/formatter' }\"/>")).toBe(false);
    expect(names('<mvc:View controllerName="z2ui5.controller.View1"/>')).toBe(false);
    expect(names('<mvc:View xmlns:x="z2ui5.ccx"/>')).toBe(false);
    expect(names('<mvc:View xmlns:x="z2ui5_cc"/>')).toBe(false);
  });
});

test.describe("the custom controls bundle", () => {
  test("a view that names no control asks for nothing", async () => {
    const h = load();
    await h.CustomControls.ensure(h.ctx, PLAIN);
    expect(h.scripts).toEqual([]);
  });

  test("is loaded from the endpoint, by its version, before ensure( ) resolves", async () => {
    const h = load();
    let settled = false;
    const done = h.CustomControls.ensure(h.ctx, VIEW).then(() => {
      settled = true;
    });
    await h.settle();
    expect(h.scripts.length).toBe(1);
    expect(h.scripts[0].tag).toBe("script");
    expect(h.scripts[0].src).toBe(BUNDLE_URL);
    expect(h.scripts[0].async).toBe(true);
    // the view build waits: nothing resolved while the script is on its way
    expect(settled).toBe(false);
    await h.arrive();
    await done;
    expect(settled).toBe(true);
  });

  test("comes from where the frontend bundle came from, not from the view's backend", async () => {
    // a page with apps of two backends: the frontend is the first one's,
    // and so are the controls - they are a part of that frontend
    const h = load({
      bundleUrl: "http://localhost:3000/sap/bc/z2ui5?z2ui5-bundle=8b869b8233e7a7aa",
      url: "/sap/bc/z2ui5_other?sap-client=100",
    });
    const done = h.CustomControls.ensure(h.ctx, VIEW);
    // the bundle parameter is replaced, not repeated
    expect(h.scripts[0].src).toBe(BUNDLE_URL);
    await h.arrive();
    await done;
  });

  test("without the bundle's own URL the endpoint of the roundtrips is asked", async () => {
    const h = load({ bundleUrl: "" });
    const done = h.CustomControls.ensure(h.ctx, VIEW);
    expect(h.scripts[0].src).toBe(BUNDLE_URL);
    await h.arrive();
    await done;
  });

  test("controls somebody else brought in are not loaded again", async () => {
    // a host or a spec that loaded ?z2ui5-bundle=cc with a script of its own
    const h = load();
    h.modules.set("z2ui5/cc/bundle", {});
    await h.CustomControls.ensure(h.ctx, VIEW);
    expect(h.scripts).toEqual([]);
  });

  test("keeps the endpoint's own parameters and drops the hash", async () => {
    const h = load({
      url: "/dynamic_dest/ABAP2UI5/sap/bc/z2ui5?sap-client=100#/route",
      href: "https://host.example/site#Shell-home",
    });
    const done = h.CustomControls.ensure(h.ctx, VIEW);
    expect(h.scripts[0].src).toBe(
      "https://host.example/dynamic_dest/ABAP2UI5/sap/bc/z2ui5?sap-client=100" +
        `&z2ui5-bundle=cc&z2ui5-version=${VERSION}`,
    );
    await h.arrive();
    await done;
  });

  test("a second view, and a second component, find it loaded - one request per page", async () => {
    const h = load();
    const first = h.CustomControls.ensure(h.ctx, VIEW);
    await h.arrive();
    await first;
    await h.CustomControls.ensure(h.ctx, VIEW);
    await h.CustomControls.ensure({ state: { url: "/sap/bc/z2ui5_other" } }, VIEW);
    expect(h.scripts.length).toBe(1);
  });

  test("two views that build while it loads share the one load", async () => {
    const h = load();
    const order = [];
    const main = h.CustomControls.ensure(h.ctx, VIEW).then(() => order.push("main"));
    const popup = h.CustomControls.ensure(h.ctx, VIEW).then(() => order.push("popup"));
    await h.settle();
    expect(h.scripts.length).toBe(1);
    expect(order).toEqual([]);
    await h.arrive();
    await Promise.all([main, popup]);
    expect(order).toEqual(["main", "popup"]);
  });

  test("a frontend whose files are served one by one loads no bundle - the loader finds the controls", async () => {
    const h = load({ bundled: false });
    await h.CustomControls.ensure(h.ctx, VIEW);
    expect(h.scripts).toEqual([]);
  });

  test("a bundle that cannot be fetched rejects with its URL, and the next view tries again", async () => {
    const h = load();
    const first = rejection(h.CustomControls.ensure(h.ctx, VIEW));
    await h.fail();
    expect((await first)?.message).toBe(
      `the custom controls this view uses could not be loaded: ${BUNDLE_URL}`,
    );
    // the element of the failed load is gone
    expect(h.scripts[0].removed).toBe(true);
    const second = h.CustomControls.ensure(h.ctx, VIEW);
    expect(h.scripts.length).toBe(2);
    await h.arrive();
    await second;
    // ...and what loaded stays loaded
    await h.CustomControls.ensure(h.ctx, VIEW);
    expect(h.scripts.length).toBe(2);
  });

  test("a 200 that is not the bundle - a logon page - is a failed load, not a loaded one", async () => {
    const h = load();
    const first = rejection(h.CustomControls.ensure(h.ctx, VIEW));
    await h.arriveEmpty();
    expect((await first)?.message).toContain("could not be loaded");
    expect(h.scripts[0].removed).toBe(true);
    const second = h.CustomControls.ensure(h.ctx, VIEW);
    expect(h.scripts.length).toBe(2);
    await h.arrive();
    await second;
  });

  test("a load that never answers rejects after a minute, and the next view tries again", async () => {
    // the view builds are one chain (actions/Slots): a load that never
    // settled stalled every later build of the component
    const h = load();
    const first = rejection(h.CustomControls.ensure(h.ctx, VIEW));
    expect([...h.longTimers.values()].map((t) => t.ms)).toEqual([60000]);
    await h.expire();
    expect((await first)?.message).toBe(
      `the custom controls this view uses could not be loaded (no answer within 60 seconds): ${BUNDLE_URL}`,
    );
    expect(h.scripts[0].removed).toBe(true);
    // a late load event of the abandoned element changes nothing
    h.scripts[0].onload();
    await h.settle();
    const second = h.CustomControls.ensure(h.ctx, VIEW);
    expect(h.scripts.length).toBe(2);
    await h.arrive();
    await second;
    // a load that settled cleared its timeout
    expect(h.longTimers.size).toBe(0);
  });

  test("without a URL of the bundle and without an endpoint there is nothing to load from - rejected, not skipped", async () => {
    const h = load({ url: null });
    const e = await rejection(h.CustomControls.ensure(h.ctx, VIEW));
    expect(e?.message).toContain("no endpoint to load them from");
    expect(h.scripts).toEqual([]);
  });
});
