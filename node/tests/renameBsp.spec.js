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
      lo: "zmyui5_cl_ui5_http_handler",
      up: "ZMYUI5_CL_UI5_HTTP_HANDLER",
      branch: "rename_zmyui5",
    });
  }
});

test("a 10-character customer name is accepted, as build-rename accepts it", async () => {
  const { deriveBackend } = await load();
  const backend = deriveBackend("zabcdefghi");
  expect(backend.prefix).toBe("zabcdefghi_");
  expect(backend.lo).toBe("zabcdefghi_cl_ui5_http_handler");
  expect(backend.branch).toBe("rename_zabcdefghi");
  expect(() => deriveBackend("zabcdefghij")).toThrow(/max 10/);
});

test("a namespace, with slashes or in the file-name spelling", async () => {
  const { deriveBackend } = await load();
  for (const input of ["/CA2UI5/", "#ca2ui5#"]) {
    const backend = deriveBackend(input);
    expect(backend.prefix).toBe("/ca2ui5/");
    expect(backend.lo).toBe("/ca2ui5/cl_ui5_http_handler");
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

// transformSicf( ) / transformSmim( ): the paths and the bare tokens in one
// pass. In two, a namespace that holds the old name (/Z2UI5/) had its
// segment of the freshly written url renamed again - /sap/bc/ui5/ui5/ - and
// with it lost its three namespace nodes, which are generated for a url
// ending in the namespace.
const NODE = (url, name, handler) =>
  `<URL>${url}</URL><ICF_NAME>${name.toUpperCase()}</ICF_NAME><ORIG_NAME>${name}</ORIG_NAME>` +
  (handler ? `<ICFHANDLER>${handler}</ICFHANDLER>` : "");

test("the ICF nodes of a namespace keep the namespace in their url", async () => {
  const { deriveNames, transformSicf } = await load();
  for (const ns of ["kro", "abapgit", "z2ui5"]) {
    const N = deriveNames(`/${ns}/`);
    expect(transformSicf(NODE("/sap/bc/z2ui5/", "z2ui5", "Z2UI5_CL_UI5_ICF_HANDLER"), N)).toBe(
      NODE(`/sap/bc/${ns}/ui5/`, "ui5", `/${ns.toUpperCase()}/CL_UI5_ICF_HANDLER`),
    );
    expect(transformSicf(NODE("/sap/bc/bsp/sap/z2ui5/", "z2ui5"), N)).toBe(NODE(`/sap/bc/bsp/${ns}/ui5/`, "ui5"));
    expect(transformSicf(NODE("/sap/bc/ui5_ui5/sap/z2ui5/", "z2ui5"), N)).toBe(NODE(`/sap/bc/ui5_ui5/${ns}/ui5/`, "ui5"));
  }
});

test("the ICF nodes of a customer name, also one that keeps the prefix", async () => {
  const { deriveNames, transformSicf } = await load();
  for (const name of ["zmyui5", "z2ui5_v2"]) {
    const N = deriveNames(name);
    expect(transformSicf(NODE("/sap/bc/z2ui5/", "z2ui5", "Z2UI5_CL_UI5_ICF_HANDLER"), N)).toBe(
      NODE(`/sap/bc/${name}/`, name, `${name.toUpperCase()}_CL_UI5_ICF_HANDLER`),
    );
    expect(transformSicf(NODE("/sap/bc/bsp/sap/z2ui5/", "z2ui5"), N)).toBe(NODE(`/sap/bc/bsp/sap/${name}/`, name));
  }
});

test("the MIME folder of a namespace, also one that holds the old name", async () => {
  const { deriveNames, transformSmim } = await load();
  for (const ns of ["KRO", "Z2UI5"]) {
    const N = deriveNames(`/${ns}/`);
    expect(transformSmim("<URL>/SAP/BC/BSP/SAP/Z2UI5</URL>", N)).toBe(`<URL>/SAP/BC/BSP/${ns}/UI5</URL>`);
    expect(transformSmim("/sap/bc/bsp/sap/z2ui5", N)).toBe(`/sap/bc/bsp/${ns.toLowerCase()}/ui5`);
  }
});
