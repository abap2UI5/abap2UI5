// @ts-check
const { test, expect } = require("@playwright/test");
const { loadEnv } = require("./loadLibModule");

// UI5 1.x exports every class it creates as a global as well
// (sap/ui/base/Metadata.createClass -> ObjectPath.set), so the frontend's
// own classes built a window.z2ui5 - z2ui5.Component, z2ui5.controller.*,
// z2ui5.devtools.DeveloperTools, z2ui5.cc.* - on every page, the global
// abap2UI5 removed on purpose (#2777). core/Env.js takes the exports off
// again on a page an EMBEDDED component runs on (dropClassGlobals, called by
// Component.init - componentData.spec.js), for every class a module handed
// to ownClass; a page of the app's own keeps them, because 1.71 looks a base
// class up by that name when something extends one of ours. The real Env,
// with a window of the spec's own.

// UI5's export of a class: every dotted segment an object, the class at
// the end - what ObjectPath.set does.
function exportGlobal(win, name, value) {
  const keys = name.split(".");
  const leaf = keys.pop();
  let holder = win;
  for (const key of keys) {
    if (!holder[key] || typeof holder[key] !== "object") holder[key] = {};
    holder = holder[key];
  }
  holder[leaf] = value;
}

// A class as Metadata.createClass leaves it: exported, with metadata that
// names it - and, for a control, its renderer, exported next to it.
function defineClass(win, name, { renderer } = {}) {
  const Class = function () {};
  const metadata = { getName: () => name };
  if (renderer) {
    metadata.getRendererName = () => `${name}Renderer`;
    metadata.getRenderer = () => renderer;
  }
  Class.getMetadata = () => metadata;
  exportGlobal(win, name, Class);
  if (renderer) exportGlobal(win, `${name}Renderer`, renderer);
  return Class;
}

function load(win = {}) {
  const loaded = loadEnv({ window: win });
  return { ...loaded, win };
}

test("on a page of the app's own the classes keep their export", () => {
  const { Env, win } = load();
  const Component = defineClass(win, "z2ui5.Component");
  expect(Env.ownClass(Component)).toBe(Component);
  expect(win.z2ui5.Component).toBe(Component);
});

test("on a host's page every class leaves window, and window.z2ui5 with them", () => {
  const { Env, win } = load();
  const renderer = { render() {} };
  const Component = Env.ownClass(defineClass(win, "z2ui5.Component"));
  const Tools = Env.ownClass(
    defineClass(win, "z2ui5.devtools.DeveloperTools", { renderer }),
  );
  expect(Object.keys(win.z2ui5).sort()).toEqual(["Component", "devtools"]);

  Env.dropClassGlobals();
  expect(win.z2ui5).toBeUndefined();

  // ... and a class defined after that, when an app's view first names a
  // custom control, keeps none either
  const Timer = defineClass(win, "z2ui5.cc.Timer", { renderer });
  expect(win.z2ui5.cc.Timer).toBe(Timer);
  expect(Env.ownClass(Timer)).toBe(Timer);
  expect(win.z2ui5).toBeUndefined();
  // the classes themselves are untouched - the modules return them
  expect(Component.getMetadata().getName()).toBe("z2ui5.Component");
  expect(Tools.getMetadata().getRenderer()).toBe(renderer);
});

// The host's page may have a z2ui5 object of its own before the frontend
// defined anything. It is the host's: what it holds stays, and the object
// stays even once our classes have left it empty.
test("a z2ui5 object the host had stays, with everything it held", () => {
  const hostOwn = { hostData: 1 };
  const { Env, win } = load({ z2ui5: hostOwn });
  Env.ownClass(defineClass(win, "z2ui5.Component"));
  Env.ownClass(defineClass(win, "z2ui5.controller.App"));
  Env.dropClassGlobals();
  expect(win.z2ui5).toBe(hostOwn);
  expect(win.z2ui5).toEqual({ hostData: 1 });

  const empty = {};
  const other = load({ z2ui5: empty });
  other.Env.ownClass(defineClass(other.win, "z2ui5.Component"));
  other.Env.dropClassGlobals();
  expect(other.win.z2ui5).toBe(empty);
});

// Only the value the export wrote goes: something else under the same name
// is not the frontend's to delete.
test("a value someone else put under a class's name is left alone", () => {
  const { Env, win } = load();
  const Component = Env.ownClass(defineClass(win, "z2ui5.Component"));
  expect(win.z2ui5.Component).toBe(Component);
  win.z2ui5.Component = "the host's";
  Env.dropClassGlobals();
  expect(win.z2ui5.Component).toBe("the host's");
});

test("a class it cannot read is logged, never thrown", () => {
  const { Env, Lib, win } = load();
  const Broken = function () {};
  Broken.getMetadata = () => {
    throw new Error("no metadata");
  };
  Env.ownClass(Broken);
  const Component = Env.ownClass(defineClass(win, "z2ui5.Component"));
  expect(() => Env.dropClassGlobals()).not.toThrow();
  expect(Lib.errors.map((e) => e.message)).toContain(
    "Env: removing a class's global export failed",
  );
  // the rest still went
  expect(win.z2ui5).toBeUndefined();
  expect(Component).toBeTruthy();
});

// ... which only works for a class that is handed over. Every module under
// app/webapp that defines one - a `.extend("z2ui5.` - has to pass it to
// Env.ownClass, or its global stays on a host's page: read off the sources,
// so a new custom control cannot forget it.
test("every class the frontend defines is handed to Env.ownClass", () => {
  const fs = require("fs");
  const path = require("path");
  const webapp = path.join(__dirname, "..", "..", "app", "webapp");
  const files = [];
  (function walk(dir) {
    for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
      const full = path.join(dir, entry.name);
      if (entry.isDirectory()) walk(full);
      else if (entry.name.endsWith(".js")) files.push(full);
    }
  })(webapp);
  const missing = [];
  let classes = 0;
  for (const file of files) {
    const source = fs.readFileSync(file, "utf8");
    for (const m of source.matchAll(
      /(?:const|let|var)\s+(\w+)\s*=\s*\w+\.extend\(\s*"z2ui5\./g,
    )) {
      classes += 1;
      if (!source.includes(`Env.ownClass(${m[1]})`)) {
        missing.push(`${path.relative(webapp, file)}: ${m[1]}`);
      }
    }
    // the shape that cannot be handed over at all
    if (/return\s+\w+\.extend\(\s*"z2ui5\./.test(source)) {
      missing.push(`${path.relative(webapp, file)}: returns the extend( )`);
    }
  }
  expect(missing).toEqual([]);
  // Component, the two controllers, the developer tools and the custom
  // controls - a scan that finds none has stopped scanning
  expect(classes).toBeGreaterThan(20);
});
