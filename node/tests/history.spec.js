// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");

// cc/History.js (obsolete, replaced by the framework's set_push_state):
// rewrites the query string of the current URL via history.replaceState.
//
// Three things it has to get right, and each of them is a way a URL rewrite
// goes wrong quietly: it REPLACES rather than pushes (no new back-button
// entry), it hands the EXISTING history state object back rather than null
// (so state somebody else stored on the entry survives), and it keeps the
// current pathname (so the rewrite cannot navigate the page). The fourth is
// the custom-control contract from AGENTS.md rule 10 - log, never throw:
// replaceState throws on a cross-origin or opaque-origin document, and a
// throw here would take the whole rendering down with it.
function load({
  state = { keep: 1 },
  pathname = "/sap/bc/z2ui5",
  hash = "",
  throws = null,
} = {}) {
  const calls = [];
  const errors = [];

  const { module: HistoryDef } = loadModule("cc/History.js", {
    deps: {
      "sap/ui/core/Control": { extend: (_name, def) => def },
      "z2ui5/core/Lib": {
        toText: (v) => (v == null ? "" : String(v)),
        logError: (m, e) => errors.push([m, e]),
      },
    },
    sandbox: {
      history: {
        get state() {
          return state;
        },
        replaceState: (...args) => {
          calls.push(args);
          if (throws) throw throws;
        },
      },
      window: { location: { pathname, hash } },
    },
  });

  const instance = () => {
    const inst = Object.create(HistoryDef);
    inst._set = [];
    inst.setProperty = (...args) => inst._set.push(args);
    return inst;
  };

  return { instance, calls, errors };
}

test("the query string is written onto the current pathname", () => {
  const { instance, calls } = load({ pathname: "/sap/bc/z2ui5" });

  instance().setSearch("?app=z2ui5_cl_demo");

  expect(calls).toHaveLength(1);
  expect(calls[0][2]).toBe("/sap/bc/z2ui5?app=z2ui5_cl_demo");
});

test("replaceState, not pushState: the entry is rewritten, not added", () => {
  const { instance, calls } = load();
  instance().setSearch("?a=1");
  // Only replaceState exists on the stub - a pushState call would have
  // failed the load with a TypeError.
  expect(calls).toHaveLength(1);
});

// Passing null here would clobber whatever the router (or the launchpad
// shell) stored on this history entry.
test("the existing history state travels along, it is not cleared", () => {
  const existing = { z2ui5: "draft-42" };
  const { instance, calls } = load({ state: existing });

  instance().setSearch("?a=1");

  expect(calls[0][0]).toBe(existing);
  expect(calls[0][1]).toBe("");
});

test("an unset value clears the query string rather than writing 'undefined'", () => {
  const { instance, calls } = load({ pathname: "/x" });

  instance().setSearch(undefined);

  expect(calls[0][2]).toBe("/x");
});

test("a null value is the same empty query string", () => {
  const { instance, calls } = load({ pathname: "/x" });

  instance().setSearch(null);

  expect(calls[0][2]).toBe("/x");
});

// The hash is kept: core/Router.js owns it, and in the FLP the front of it
// is the SHELL's (#SO-action&/...). Rewriting the URL without it stranded
// the launchpad, and with routing active it dropped the
// #/app/<CLASS>/<DRAFT> route, so Back/Forward/Reload fell back to
// ?app_start=.
test("the current hash survives the rewrite", () => {
  const { instance, calls } = load({
    pathname: "/sap/bc/z2ui5",
    hash: "#/app/Z2UI5_CL_DEMO/abc",
  });

  instance().setSearch("?a=1");

  expect(calls[0][2]).toBe("/sap/bc/z2ui5?a=1#/app/Z2UI5_CL_DEMO/abc");
});

// AGENTS.md rule 10: a custom control logs and never throws. replaceState
// throws on an opaque origin (a file:// page, a sandboxed iframe), and a
// throw out of a property setter takes the rendering with it.
test("a throwing replaceState is logged, not propagated", () => {
  const boom = new Error("SecurityError");
  const { instance, errors } = load({ throws: boom });

  expect(() => instance().setSearch("?a=1")).not.toThrow();
  expect(errors).toHaveLength(1);
  expect(errors[0][0]).toContain("History.setSearch");
  expect(errors[0][1]).toBe(boom);
});

test("the property is still recorded when replaceState throws", () => {
  const { instance } = load({ throws: new Error("no") });
  const inst = instance();

  inst.setSearch("?a=1");

  // setProperty runs before the effect, so the control's own state stays
  // consistent with what the model bound to it.
  expect(inst._set).toEqual([["search", "?a=1", true]]);
});

test("the property is written with invalidation suppressed", () => {
  const { instance } = load();
  const inst = instance();

  inst.setSearch("?a=1");

  // Empty renderer: a re-render would achieve nothing, the URL rewrite is
  // the whole effect.
  expect(inst._set).toEqual([["search", "?a=1", true]]);
});
