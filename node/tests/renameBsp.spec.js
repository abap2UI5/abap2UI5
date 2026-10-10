// @ts-check
const { test, expect } = require("@playwright/test");
const path = require("path");
const { pathToFileURL } = require("url");

// tools/bsp_rename/rename-bsp.mjs - deriveBackend( ), the backend class a
// renamed BSP's ICF handler calls. It has to accept every name the
// build-rename workflow accepts (a customer name of at most 10 characters,
// or a namespace of at most 10 with both slashes), or a fully renamed stack
// cannot be built for a backend that exists.

const MODULE = path.join(__dirname, "..", "..", "tools", "bsp_rename", "rename-bsp.mjs");

/** @type {any} */
let mod;
const load = async () => (mod ??= await import(pathToFileURL(MODULE).href));

test("no --backend is no backend", async () => {
  const { deriveBackend } = await load();
  expect(deriveBackend(null)).toBeNull();
  expect(deriveBackend(undefined)).toBeNull();
});

test("a customer name, with or without its underscore", async () => {
  const { deriveBackend } = await load();
  for (const input of ["zmyui5", "ZMYUI5_", " zmyui5_ "]) {
    expect(deriveBackend(input)).toEqual({
      prefix: "zmyui5_",
      lo: "zmyui5_cl_http_handler",
      up: "ZMYUI5_CL_HTTP_HANDLER",
      branch: "rename_zmyui5",
    });
  }
});

test("a 10-character customer name is accepted, as build-rename accepts it", async () => {
  const { deriveBackend } = await load();
  const backend = deriveBackend("zabcdefghi");
  expect(backend.prefix).toBe("zabcdefghi_");
  expect(backend.lo).toBe("zabcdefghi_cl_http_handler");
  expect(backend.branch).toBe("rename_zabcdefghi");
  expect(() => deriveBackend("zabcdefghij")).toThrow(/max 10/);
});

test("a namespace, with slashes or in the file-name spelling", async () => {
  const { deriveBackend } = await load();
  for (const input of ["/CA2UI5/", "#ca2ui5#"]) {
    const backend = deriveBackend(input);
    expect(backend.prefix).toBe("/ca2ui5/");
    expect(backend.lo).toBe("/ca2ui5/cl_http_handler");
    expect(backend.branch).toBe("rename_ca2ui5");
  }
  expect(deriveBackend("/abcdefgh/").prefix).toBe("/abcdefgh/");
  expect(() => deriveBackend("/abcdefghi/")).toThrow(/max 10/);
});

test("the original name and malformed input are refused", async () => {
  const { deriveBackend } = await load();
  expect(() => deriveBackend("z2ui5")).toThrow(/original name/);
  expect(() => deriveBackend("")).toThrow(/needs a value/);
  expect(() => deriveBackend("1abc")).toThrow(/Invalid backend prefix/);
  expect(() => deriveBackend("/ca2ui5")).toThrow(/Invalid backend prefix/);
});
