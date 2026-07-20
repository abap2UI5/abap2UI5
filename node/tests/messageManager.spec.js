// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");

// Tests the real app/webapp/cc/MessageManager.js. The companion control keeps
// the UI5 message manager in sync with its two-way bound `items` table (the
// app's OWN messages): a reconcile adds the rows that are new, removes the
// control's own rows that are gone, and never touches messages it did not add
// (auto-collected binding validation).

// Minimal Control.extend stub (as in uiTableExt.spec.js).
function controlStub() {
  return {
    extend(_name, def) {
      function Ctrl() {}
      Object.assign(Ctrl.prototype, def);
      return Ctrl;
    },
  };
}

function load() {
  const callbacks = { onAfterRendering: [] };
  const messaging = {
    added: [],
    removed: [],
    addMessages: (m) => messaging.added.push(m),
    removeMessages: (m) => messaging.removed.push(m),
  };
  const PROCESSOR = { id: "defaultModel" };
  const view = { getModel: () => PROCESSOR };

  const Lib = {
    registerCallback: (name, fn) => {
      (callbacks[name] = callbacks[name] || []).push(fn);
    },
    unregisterCallback: (name, fn) => {
      if (callbacks[name])
        callbacks[name] = callbacks[name].filter((f) => f !== fn);
    },
    getMessaging: () => messaging,
  };
  const ViewSlots = {
    getView: () => view,
    containingSlotKey: () => "MAIN",
  };
  function Message(o) {
    Object.assign(this, o);
  }

  const { module: Ext } = loadModule("cc/MessageManager.js", {
    deps: {
      "sap/ui/core/Control": controlStub(),
      "sap/ui/core/message/Message": Message,
      "z2ui5/core/Lib": Lib,
      "z2ui5/core/ViewSlots": ViewSlots,
    },
  });

  return { Ext, callbacks, messaging, PROCESSOR };
}

// Instantiate with a tiny property store + a change counter.
function makeExt(env) {
  const ext = new env.Ext();
  const props = { items: undefined, checkInit: false };
  ext.getProperty = (n) => props[n];
  ext.setProperty = (n, v) => {
    props[n] = v;
    return ext;
  };
  env.changeCount = 0;
  ext.fireChange = () => {
    env.changeCount++;
  };
  return ext;
}

test.describe("MessageManager companion control", () => {
  test("init registers and exit unregisters the onAfterRendering hook", () => {
    const env = load();
    const ext = makeExt(env);
    ext.init();
    expect(env.callbacks.onAfterRendering).toHaveLength(1);
    ext.exit();
    expect(env.callbacks.onAfterRendering).toHaveLength(0);
  });

  test("adds a new app message as a Message with target + processor", () => {
    const env = load();
    const ext = makeExt(env);
    ext.init();
    ext.setup();
    ext.setItems([
      {
        MESSAGE: "A mandatory field is required",
        TYPE: "Error",
        TARGET: "/NAME",
        ADDITIONALTEXT: "Name",
        DESCRIPTION: "",
      },
    ]);
    expect(env.messaging.added).toHaveLength(1);
    expect(env.messaging.added[0]).toMatchObject({
      message: "A mandatory field is required",
      type: "Error",
      target: "/NAME",
      additionalText: "Name",
      processor: env.PROCESSOR,
    });
    expect(env.messaging.removed).toHaveLength(0);
  });

  test("reconciling the same table twice does not re-add (dedup by key)", () => {
    const env = load();
    const ext = makeExt(env);
    ext.init();
    ext.setup();
    const rows = [{ MESSAGE: "A", TYPE: "Error", TARGET: "/X" }];
    ext.setItems(rows);
    ext.setItems([{ MESSAGE: "A", TYPE: "Error", TARGET: "/X" }]); // same key
    expect(env.messaging.added).toHaveLength(1);
    expect(env.messaging.removed).toHaveLength(0);
  });

  test("removes the control's own row when it drops out of the table", () => {
    const env = load();
    const ext = makeExt(env);
    ext.init();
    ext.setup();
    ext.setItems([
      { MESSAGE: "A", TYPE: "Error", TARGET: "/X" },
      { MESSAGE: "B", TYPE: "Warning", TARGET: "/Y" },
    ]);
    expect(env.messaging.added).toHaveLength(2);
    ext.setItems([{ MESSAGE: "A", TYPE: "Error", TARGET: "/X" }]); // B gone
    expect(env.messaging.removed).toHaveLength(1);
    expect(env.messaging.removed[0]).toMatchObject({ message: "B" });
  });

  test("never removes messages it did not add (auto-collected validation)", () => {
    const env = load();
    // a validation message already sits in the manager, not added by the cc
    env.messaging.added.push({ message: "auto", type: "Error", foreign: true });
    const ext = makeExt(env);
    ext.init();
    ext.setup();
    ext.setItems([]); // empty app table
    expect(env.messaging.removed).toHaveLength(0); // the foreign message stays
  });

  test("defers reconcile until setup when items arrive before ready", () => {
    const env = load();
    const ext = makeExt(env);
    ext.init();
    // items set before onAfterRendering/setup: no messaging yet, no add
    ext.setItems([{ MESSAGE: "A", TYPE: "Error", TARGET: "/X" }]);
    expect(env.messaging.added).toHaveLength(0);
    ext.setup(); // becomes ready -> reconciles the stored items
    expect(env.messaging.added).toHaveLength(1);
  });
});
