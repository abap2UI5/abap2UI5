// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");
const { loadLib } = require("./loadLibModule");

// cc/Favicon.js (obsolete, replaced by cs_event-set_favicon): sets the
// browser tab icon from its bound `favicon` URL. The whole control is one
// setter, and the one decision in it is which <link> to write: a page that
// already declares an icon must have THAT link updated, not a second,
// competing one appended - which of the two the browser then honours is up
// to the browser. Also under test: the URL guard (same validator as the
// SET_FAVICON action - active schemes and empty values are refused), the
// invalidation suppression (an empty renderer means a re-render would
// achieve nothing) and Lib.toText, which turns an unbound property into ""
// rather than "undefined".
function load({ head = [] } = {}) {
  const links = head;
  const created = [];

  // The REAL Lib: the control's URL guard is Lib.isSafeDownloadURL, and a
  // hand-stub of it would just restate the expectation under test.
  const { Lib, sandbox: libSandbox } = loadLib();

  const { module: FaviconDef, sandbox } = loadModule("cc/Favicon.js", {
    deps: {
      "sap/ui/core/Control": { extend: (_name, def) => def },
      "z2ui5/core/Lib": Lib,
    },
    sandbox: {
      document: {
        head: {
          // ~= matches one entry of the whitespace-separated rel list, which
          // is the selector the control uses.
          querySelector: (sel) => {
            expect(sel).toBe('link[rel~="icon"]');
            return (
              links.find((l) => String(l.rel).split(/\s+/).includes("icon")) ??
              null
            );
          },
        },
        createElement: (tag) => {
          const el = { tagName: tag.toUpperCase(), rel: "", href: "" };
          created.push(el);
          return el;
        },
      },
    },
  });

  // appendChild is on the same head object the control queried.
  sandbox.document.head.appendChild = (el) => links.push(el);

  const instance = () => {
    const inst = Object.create(FaviconDef);
    inst._set = [];
    inst.setProperty = (...args) => inst._set.push(args);
    return inst;
  };

  // Lib.logError records into ITS sandbox's shared state - expose it so the
  // refusal tests can assert the guard actually fired.
  return { instance, links, created, errors: () => libSandbox.z2ui5.errors };
}

test("no icon link yet: one is created as rel='shortcut icon'", () => {
  const { instance, links, created } = load();

  instance().setFavicon("/img/a.ico");

  expect(created).toHaveLength(1);
  expect(links).toHaveLength(1);
  expect(links[0].rel).toBe("shortcut icon");
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

// The URL guard (Lib.isSafeDownloadURL, same as the SET_FAVICON action)
// refuses an empty value: an unbound property must not touch the page's
// icon links - and in particular never write the string "undefined".
test("an unset value is refused - no link is written", () => {
  const { instance, links, errors } = load();

  instance().setFavicon(undefined);

  expect(links).toHaveLength(0);
  expect(errors()).toHaveLength(1);
  expect(errors()[0].message).toContain("Favicon");
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
