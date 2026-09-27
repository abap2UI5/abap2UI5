// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");
const { loadLib } = require("./loadLibModule");

// cc/Favicon.js (obsolete, replaced by cs_event-set_favicon): sets the
// browser tab icon from its bound `favicon` URL. The whole control is one
// setter, and since 2026-09-25 that setter IS the SET_FAVICON action of
// core/actions/Browser.js - the control hands the value over and keeps no
// copy of the logic. So what is pinned here runs through the REAL action
// module: the one decision in it is which <link> to write - a page that
// already declares an icon must have THAT link updated, not a second,
// competing one appended - which of the two the browser then honours is up
// to the browser. Also under test: the URL guard (Lib.isSafeDownloadURL -
// active schemes and empty values are refused), the invalidation
// suppression (an empty renderer means a re-render would achieve nothing)
// and Lib.toText, which turns an unbound property into "" rather than
// "undefined".
function load({ head = [] } = {}) {
  const links = head;
  const created = [];

  // The REAL Lib: the action's URL guard is Lib.isSafeDownloadURL, and a
  // hand-stub of it would just restate the expectation under test.
  const { Lib, state: libState } = loadLib();

  const document = {
    head: {
      // ~= matches one entry of the whitespace-separated rel list, which
      // is the selector the action uses.
      querySelector: (sel) => {
        expect(sel).toBe('link[rel~="icon"]');
        return (
          links.find((l) => String(l.rel).split(/\s+/).includes("icon")) ??
          null
        );
      },
      // appendChild is on the same head object the action queried.
      appendChild: (el) => links.push(el),
    },
    createElement: (tag) => {
      const el = { tagName: tag.toUpperCase(), rel: "", href: "" };
      created.push(el);
      return el;
    },
  };

  // the real action module the control delegates to; its other handlers'
  // dependencies are inert here
  const { module: Browser } = loadModule("core/actions/Browser.js", {
    deps: {
      "sap/m/MessageBox": {},
      "sap/m/library": { URLHelper: {} },
      "sap/ui/util/Storage": function () {},
      "z2ui5/core/Router": {},
      "z2ui5/core/Lib": Lib,
      "z2ui5/core/ViewSlots": {},
    },
    sandbox: { document },
  });

  const { module: FaviconDef } = loadModule("cc/Favicon.js", {
    deps: {
      "sap/ui/core/Control": { extend: (_name, def) => def },
      "z2ui5/core/Lib": Lib,
      "z2ui5/core/actions/Browser": Browser,
    },
    sandbox: { document },
  });

  const instance = () => {
    const inst = Object.create(FaviconDef);
    inst._set = [];
    inst.setProperty = (...args) => inst._set.push(args);
    return inst;
  };

  // Lib.logError records into ITS sandbox's shared state - expose it so the
  // refusal tests can assert the guard actually fired.
  return { instance, links, created, errors: () => libState.errors };
}

// rel="icon", the spelling the SET_FAVICON action creates too - the
// control used to write the legacy "shortcut icon", so which of the two a
// page carried depended on which side set the icon first
test("no icon link yet: one is created as rel='icon'", () => {
  const { instance, links, created } = load();

  instance().setFavicon("/img/a.ico");

  expect(created).toHaveLength(1);
  expect(links).toHaveLength(1);
  expect(links[0].rel).toBe("icon");
  expect(links[0].href).toBe("/img/a.ico");
});

test("an existing rel='shortcut icon' is updated, not duplicated", () => {
  const existing = { rel: "shortcut icon", href: "/old.ico" };
  const { instance, links, created } = load({ head: [existing] });

  instance().setFavicon("/new.ico");

  expect(created).toHaveLength(0);
  expect(links).toEqual([existing]);
  expect(existing.href).toBe("/new.ico");
});

// The reason the selector is rel~="icon" rather than rel="shortcut icon":
// a page declaring the modern spelling would otherwise keep its own link and
// get a second one appended on every app start.
test("the modern rel='icon' spelling is matched too", () => {
  const existing = { rel: "icon", href: "/old.png" };
  const { instance, links } = load({ head: [existing] });

  instance().setFavicon("/new.png");

  expect(links).toHaveLength(1);
  expect(existing.href).toBe("/new.png");
});

test("a multi-value rel list is matched on one of its entries", () => {
  const existing = { rel: "icon shortcut", href: "/old.png" };
  const { instance, links } = load({ head: [existing] });

  instance().setFavicon("/new.png");

  expect(links).toHaveLength(1);
  expect(existing.href).toBe("/new.png");
});

// A rel that only CONTAINS the word is not a match - "apple-touch-icon" is a
// different link and must keep its own href.
test("apple-touch-icon is not treated as the favicon link", () => {
  const other = { rel: "apple-touch-icon", href: "/touch.png" };
  const { instance, links, created } = load({ head: [other] });

  instance().setFavicon("/new.ico");

  expect(other.href).toBe("/touch.png");
  expect(created).toHaveLength(1);
  expect(links).toHaveLength(2);
});

// The URL guard (Lib.isSafeDownloadURL, the SET_FAVICON action's) refuses
// an empty value: an unbound property must not touch the page's icon
// links - and in particular never write the string "undefined".
test("an unset value is refused - no link is written", () => {
  const { instance, links, errors } = load();

  instance().setFavicon(undefined);

  expect(links).toHaveLength(0);
  expect(errors()).toHaveLength(1);
  expect(errors()[0].message).toContain("SET_FAVICON: refused unsafe URL");
});

// An active scheme is refused and an existing icon link keeps its href.
test("a javascript: URL is refused and logged", () => {
  const existing = { rel: "icon", href: "/keep.png" };
  const { instance, links, created, errors } = load({ head: [existing] });

  instance().setFavicon("javascript:alert(1)");

  expect(existing.href).toBe("/keep.png");
  expect(created).toHaveLength(0);
  expect(links).toHaveLength(1);
  expect(
    errors().some((e) => String(e.message).includes("refused unsafe URL")),
  ).toBe(true);
});

test("the property is written with invalidation suppressed", () => {
  const { instance } = load();
  const inst = instance();

  inst.setFavicon("/a.ico");

  // The renderer is empty, so a re-render would achieve nothing; the effect
  // above is the whole point of the control.
  expect(inst._set).toEqual([["favicon", "/a.ico", true]]);
});
