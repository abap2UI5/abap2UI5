// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");

// Tests Server._checkBuildDrift: the report that the frontend in the browser
// is not the frontend the backend ships.
//
// The copies (backend via abapGit with the frontend it embeds, and the BSP
// frontend from abap2UI5/frontend - with the browser's cache on top) are
// installed independently, so they can drift with no symptom until a view
// misbehaves. The check turns that into a line in the developer tools.
//
// The hash is the finding; the version only says how far apart the two are.
// Everything here is a log assertion on purpose: a drifted frontend usually
// still runs, so the check must never throw, block or alter the roundtrip.

const LOADED = { VERSION: "1.142.0", HASH: "aaaaaaaaaaaa" };

function loadServer() {
  const errors = [];
  const Server = loadModule("core/Server.js", {
    deps: {
      "z2ui5/core/Build": LOADED,
      "z2ui5/core/Lib": { logError: (msg) => errors.push(msg) },
    },
  }).module;
  return { Server, errors };
}

test("a matching build logs nothing", () => {
  const { Server, errors } = loadServer();

  Server._checkBuildDrift({ VERSION: "1.142.0", FRONTEND_HASH: "aaaaaaaaaaaa" });

  expect(errors).toEqual([]);
});

// Every roundtrip after the first of a page load leaves S_BUILD off, and an
// older backend never sends it at all - neither may produce a finding.
test("a response without S_BUILD is a no-op", () => {
  const { Server, errors } = loadServer();

  Server._checkBuildDrift(undefined);

  expect(errors).toEqual([]);
});

// The case the whole check exists for: the release matches, so nothing else
// in the app would ever notice, but the bytes differ.
test("same version, different hash points at the cache first", () => {
  const { Server, errors } = loadServer();

  Server._checkBuildDrift({ VERSION: "1.142.0", FRONTEND_HASH: "bbbbbbbbbbbb" });

  expect(errors).toHaveLength(1);
  expect(errors[0]).toContain("cached");
  expect(errors[0]).toContain("Ctrl+Shift+R");
  // both fingerprints named, so the reader can tell which copy is the old one
  expect(errors[0]).toContain("aaaaaaaaaaaa");
  expect(errors[0]).toContain("bbbbbbbbbbbb");
});

test("a different version names both releases instead of blaming the cache", () => {
  const { Server, errors } = loadServer();

  Server._checkBuildDrift({ VERSION: "1.143.0", FRONTEND_HASH: "bbbbbbbbbbbb" });

  expect(errors).toHaveLength(1);
  expect(errors[0]).toContain("1.142.0");
  expect(errors[0]).toContain("1.143.0");
  expect(errors[0]).toContain("not upgraded");
  expect(errors[0]).not.toContain("cached");
});

// A newer release that somehow ships the identical webapp is not a drift -
// the hash is what decides, the version never fires on its own.
test("a differing version alone is not a finding", () => {
  const { Server, errors } = loadServer();

  Server._checkBuildDrift({ VERSION: "1.143.0", FRONTEND_HASH: "aaaaaaaaaaaa" });

  expect(errors).toEqual([]);
});

// A backend that sends the container but not the values (an exit rewriting the
// response, a partially populated struct) must not produce "undefined" noise.
test("an empty hash never produces a finding", () => {
  const { Server, errors } = loadServer();

  Server._checkBuildDrift({ VERSION: "", FRONTEND_HASH: "" });

  expect(errors).toEqual([]);
});
