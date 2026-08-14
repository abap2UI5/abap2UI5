// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");

// Tests Server._checkBuildDrift: the report that the frontend in the browser
// is not the frontend the backend ships.
//
// The three copies (backend via abapGit, the frontend it embeds in src/01/03,
// and the BSP frontend from abap2UI5/frontend - with the browser's cache on
// top) are installed independently, so they can drift with no symptom until a
// view misbehaves. The check turns that into a line in the developer tools.
//
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

  Server._checkBuildDrift({
    BACKEND_VERSION: "1.142.0",
    FRONTEND_VERSION: "1.142.0",
    FRONTEND_HASH: "aaaaaaaaaaaa",
  });

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

  Server._checkBuildDrift({
    BACKEND_VERSION: "1.142.0",
    FRONTEND_VERSION: "1.142.0",
    FRONTEND_HASH: "bbbbbbbbbbbb",
  });

  expect(errors).toHaveLength(1);
  expect(errors[0]).toContain("cached");
  expect(errors[0]).toContain("Ctrl+Shift+R");
  // both sides named, so the reader can tell which copy is the old one
  expect(errors[0]).toContain("aaaaaaaaaaaa");
  expect(errors[0]).toContain("bbbbbbbbbbbb");
});

test("a different version blames the un-upgraded BSP, not the cache", () => {
  const { Server, errors } = loadServer();

  Server._checkBuildDrift({
    BACKEND_VERSION: "1.143.0",
    FRONTEND_VERSION: "1.143.0",
    FRONTEND_HASH: "bbbbbbbbbbbb",
  });

  expect(errors).toHaveLength(1);
  expect(errors[0]).toContain("different release");
  expect(errors[0]).not.toContain("cached");
});

// backend_version and frontend_version travel in one abapGit pull, so they can
// only disagree when that pull was partial. Reported separately because the
// hash finding alone would send the reader to redeploy a BSP that is innocent.
test("backend and embedded frontend from different releases is its own finding", () => {
  const { Server, errors } = loadServer();

  Server._checkBuildDrift({
    BACKEND_VERSION: "1.143.0",
    FRONTEND_VERSION: "1.142.0",
    FRONTEND_HASH: "aaaaaaaaaaaa",
  });

  // the hash matches, so the BSP finding must stay silent - only the
  // incomplete-pull one fires
  expect(errors).toHaveLength(1);
  expect(errors[0]).toContain("incomplete");
});

test("a drifted frontend on an incompletely pulled backend reports both", () => {
  const { Server, errors } = loadServer();

  Server._checkBuildDrift({
    BACKEND_VERSION: "1.143.0",
    FRONTEND_VERSION: "1.142.0",
    FRONTEND_HASH: "bbbbbbbbbbbb",
  });

  expect(errors).toHaveLength(2);
});

// A backend that sends the container but not the values (an exit rewriting the
// response, a partially populated struct) must not produce "undefined" noise.
test("empty values never produce a finding", () => {
  const { Server, errors } = loadServer();

  Server._checkBuildDrift({
    BACKEND_VERSION: "",
    FRONTEND_VERSION: "",
    FRONTEND_HASH: "",
  });

  expect(errors).toEqual([]);
});
