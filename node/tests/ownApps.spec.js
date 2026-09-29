// @ts-check
const { test, expect } = require("@playwright/test");
const fs = require("fs");
const os = require("os");
const path = require("path");
const { pathToFileURL } = require("url");

// ---------------------------------------------------------------------
// node/setup/own-apps.mjs - the bin abap2ui5-own-apps of
// @abap2ui5/node-runtime. A transpile writes the host's classes AND a second
// copy of every library object into one folder, and the host's classes
// import what they extend relatively; imported as they are, they load that
// copy and a second CX_ROOT replaces the package's. The helper keeps the
// host's files and points every other import at the package.
//
// Here on a synthetic transpile output, in the transpiler's import shapes -
// the whole recipe, with a real transpile and the framework catching what an
// app raises, is `npm run pack:node-runtime -- --check`.
// ---------------------------------------------------------------------

const MODULE = path.join(__dirname, "..", "setup", "own-apps.mjs");

/** @type {any} */
let mod;
const load = async () => (mod ??= await import(pathToFileURL(MODULE).href));

function tree(files) {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), "own-apps-"));
  for (const [name, text] of Object.entries(files)) fs.writeFileSync(path.join(dir, name), text);
  return dir;
}

test("keeps the host's files and points every other import at the package", async () => {
  const { ownApps } = await load();
  // what the package's output/ holds
  const runtimeOutput = tree({ "cx_root.clas.mjs": "", "cx_static_check.clas.mjs": "", "#ui2#cl_json.clas.mjs": "", "init.mjs": "", "index.mjs": "" });
  const output = tree({
    // the transpile's copies of the libraries - not the host's
    "cx_root.clas.mjs": "// a second copy",
    "cx_static_check.clas.mjs": "// a second copy",
    "#ui2#cl_json.clas.mjs": "// a second copy",
    // its generated files - not the host's either
    "init.mjs": 'await import("./zcl_app.clas.mjs");\nawait import("./zcx_app_error.clas.mjs");\nawait import("./zcl_a_first.clas.mjs");\n',
    "_init.mjs": 'import "./zcl_app.clas.mjs";\n',
    "index.mjs": 'import "./init.mjs";\n',
    // the host's
    "zcx_app_error.clas.mjs": 'const {cx_static_check} = await import("./cx_static_check.clas.mjs");\n'
      + 'const {cx_root} = await import("./cx_root.clas.mjs");\nclass zcx_app_error extends cx_static_check {}\n'
      + 'abap.Classes["ZCX_APP_ERROR"] = zcx_app_error;\nexport {zcx_app_error};\n',
    "zcl_app.clas.mjs": 'await import("./zcl_app.clas.locals.mjs");\nconst {zcx_app_error} = await import("./zcx_app_error.clas.mjs");\n'
      + 'const {cl_json} = await import("./%23ui2%23cl_json.clas.mjs");\n'
      + 'const text = `await import("./cx_root.clas.mjs")`;\nexport {};\n',
    "zcl_app.clas.locals.mjs": 'const {cx_root} = await import("./cx_root.clas.mjs");\nexport {};\n',
    "zcl_app.clas.mjs.map": "{}",
    "zcl_a_first.clas.mjs": "export {};\n",
  });
  const apps = path.join(os.tmpdir(), `own-apps-out-${process.pid}-${Date.now()}`);
  try {
    const { files, modules } = ownApps({ output, apps, runtimeOutput });
    expect(files.sort()).toEqual(["index.mjs", "zcl_a_first.clas.mjs", "zcl_app.clas.locals.mjs", "zcl_app.clas.mjs",
      "zcl_app.clas.mjs.map", "zcx_app_error.clas.mjs"]);
    expect(fs.readdirSync(apps).sort()).toEqual(files.sort());
    // the order of the transpile's init.mjs, not the alphabet
    expect(modules).toEqual(["zcl_app.clas.mjs", "zcx_app_error.clas.mjs", "zcl_a_first.clas.mjs"]);

    const error = fs.readFileSync(path.join(apps, "zcx_app_error.clas.mjs"), "utf8");
    expect(error).toContain('await import("@abap2ui5/node-runtime/output/cx_static_check.clas.mjs")');
    expect(error).toContain('await import("@abap2ui5/node-runtime/output/cx_root.clas.mjs")');
    const app = fs.readFileSync(path.join(apps, "zcl_app.clas.mjs"), "utf8");
    // the host's own files stay relative, and a name with # keeps its encoding
    expect(app).toContain('await import("./zcl_app.clas.locals.mjs")');
    expect(app).toContain('await import("./zcx_app_error.clas.mjs")');
    expect(app).toContain('await import("@abap2ui5/node-runtime/output/%23ui2%23cl_json.clas.mjs")');
    // a string literal that reads like an import is text, not an import
    expect(app).toContain('const text = `await import("./cx_root.clas.mjs")`;');
    expect(fs.readFileSync(path.join(apps, "zcl_app.clas.locals.mjs"), "utf8"))
      .toContain('await import("@abap2ui5/node-runtime/output/cx_root.clas.mjs")');
    expect(fs.readFileSync(path.join(apps, "index.mjs"), "utf8").split("\n").filter((l) => l.startsWith("await")))
      .toEqual(['await import("./zcl_app.clas.mjs");', 'await import("./zcx_app_error.clas.mjs");', 'await import("./zcl_a_first.clas.mjs");']);
  } finally {
    for (const dir of [runtimeOutput, output, apps]) fs.rmSync(dir, { recursive: true, force: true });
  }
});

test("stops on an import it does not know how to point at the package", async () => {
  const { ownApps } = await load();
  const runtimeOutput = tree({ "cx_root.clas.mjs": "" });
  const output = tree({
    "cx_root.clas.mjs": "",
    "zcl_app.clas.mjs": 'export {x} from "./cx_root.clas.mjs";\n',
  });
  const apps = path.join(os.tmpdir(), `own-apps-out-${process.pid}-${Date.now()}-2`);
  try {
    expect(() => ownApps({ output, apps, runtimeOutput })).toThrow(/zcl_app\.clas\.mjs:1 imports \.\/cx_root\.clas\.mjs/);
    expect(fs.existsSync(apps)).toBe(false);
  } finally {
    for (const dir of [runtimeOutput, output, apps]) fs.rmSync(dir, { recursive: true, force: true });
  }
});

test("says so when nothing in the output is the host's", async () => {
  const { ownApps } = await load();
  const runtimeOutput = tree({ "cx_root.clas.mjs": "" });
  const output = tree({ "cx_root.clas.mjs": "", "init.mjs": "" });
  try {
    expect(() => ownApps({ output, apps: path.join(output, "apps"), runtimeOutput })).toThrow(/which of them are yours/);
  } finally {
    for (const dir of [runtimeOutput, output]) fs.rmSync(dir, { recursive: true, force: true });
  }
});
