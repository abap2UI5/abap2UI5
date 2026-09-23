// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");
const { specContext, contextStub } = require("./loadLibModule");

// Tests the real app/webapp/cc/MessageManager.js. The companion control keeps
// the UI5 message manager in sync with its bound `items` table (the
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

// `context: false` loads the control as one in no component (Context.of
// answers null): the slot view, and with it the processor, is out of reach.
function load({ context = true } = {}) {
  const callbacks = { onAfterRendering: [] };
  const errors = [];
  const ctx = specContext();
  const Context = context
    ? contextStub(ctx)
    : { ...contextStub(ctx), of: () => null };
  const messaging = {
    added: [],
    removed: [],
    addMessages: (m) => messaging.added.push(m),
    removeMessages: (m) => messaging.removed.push(m),
  };
  const PROCESSOR = { id: "defaultModel" };
  const view = { getModel: () => PROCESSOR };

  const Lib = {
    logError: (m) => errors.push(m),
    registerCallback: (name, fn) => {
      (callbacks[name] = callbacks[name] || []).push(fn);
    },
    unregisterCallback: (name, fn) => {
      if (callbacks[name])
        callbacks[name] = callbacks[name].filter((f) => f !== fn);
    },
    hookCallback(owner, name, method) {
      const bound = owner[method].bind(owner);
      this.registerCallback(name, bound);
      return () => this.unregisterCallback(name, bound);
    },
    getMessaging: () => messaging,
    // the one-shot claim the real Lib keeps in the control's checkInit
    claimOnce(owner, target) {
      if (!target || owner.getProperty("checkInit")) return false;
      owner.setProperty("checkInit", true, true);
      return true;
    },
  };
  // ctx-first, as ViewSlots takes them: the slot lookups record the
  // context they were asked for
  const slotLookups = [];
  const ViewSlots = {
    getView: (c, key) => {
      slotLookups.push([c, key]);
      return view;
    },
    containingSlotKey: (c) => (c === ctx ? "MAIN" : undefined),
  };
  function Message(o) {
    Object.assign(this, o);
  }

  const { module: Ext } = loadModule("cc/MessageManager.js", {
    deps: {
      "sap/ui/core/Control": controlStub(),
      "sap/ui/core/message/Message": Message,
      "z2ui5/core/Lib": Lib,
      // the stub carries the Env probes this module uses as well
      "z2ui5/core/Env": Lib,
      "z2ui5/core/ViewSlots": ViewSlots,
      "z2ui5/core/Context": Context,
    },
  });

  return { Ext, callbacks, messaging, PROCESSOR, ctx, slotLookups, errors };
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

  test("the processor is the model of the slot view in the control's own context", () => {
    const env = load();
    const ext = makeExt(env);
    ext.init();
    ext.setup();
    expect(env.slotLookups).toEqual([[env.ctx, "MAIN"]]);
    expect(ext._processor).toBe(env.PROCESSOR);
    expect(env.errors).toEqual([]);
  });

  // In no component there is no slot view to take the processor from: the
  // messages still reach the message manager (without a processor a target
  // sets no field's valueState), and the gap is logged, not thrown.
  test("in no component the messages carry no processor, logged", () => {
    const env = load({ context: false });
    const ext = makeExt(env);
    ext.init();
    expect(() => ext.setup()).not.toThrow();
    expect(env.slotLookups).toEqual([]);
    expect(ext._processor).toBeNull();
    expect(env.errors).toEqual([
      "MessageManager.setup: no component context, messages carry no processor",
    ]);

    ext.setItems([{ MESSAGE: "m", TYPE: "Error", TARGET: "/X" }]);
    expect(env.messaging.added).toHaveLength(1);
    expect(env.messaging.added[0].processor).toBeNull();
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

  // The Message carries six columns, and all six are its identity: a row
  // whose description or code changes while message/type/target stay the
  // same used to hit the existing key and keep the OLD long text (the
  // popover's drill-down) and the old group (MessageItem.groupName binds
  // {message>code}) until the message text itself changed.
  test("a changed description or code replaces the message", () => {
    const env = load();
    const ext = makeExt(env);
    ext.init();
    ext.setup();
    ext.setItems([
      { MESSAGE: "A", TYPE: "Error", TARGET: "/X", DESCRIPTION: "old", CODE: "G1" },
    ]);
    ext.setItems([
      { MESSAGE: "A", TYPE: "Error", TARGET: "/X", DESCRIPTION: "new", CODE: "G2" },
    ]);
    expect(env.messaging.removed).toHaveLength(1);
    expect(env.messaging.added).toHaveLength(2);
    expect(env.messaging.added[1]).toMatchObject({
      description: "new",
      code: "G2",
    });
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

  test("fires change only when a message was actually added or removed", () => {
    const env = load();
    const ext = makeExt(env);
    ext.init();
    ext.setup();

    ext.setItems([{ MESSAGE: "A", TYPE: "Error", TARGET: "/X" }]);
    expect(env.changeCount).toBe(1);

    // the same table again: nothing to add, nothing to remove. The table is
    // bound, so it arrives on EVERY roundtrip - firing change here
    // would make an app that answers the event with a roundtrip loop.
    ext.setItems([{ MESSAGE: "A", TYPE: "Error", TARGET: "/X" }]);
    expect(env.changeCount).toBe(1);

    // a real removal reports again
    ext.setItems([]);
    expect(env.changeCount).toBe(2);
  });

  test("a row without the ABAP columns cannot key itself apart", () => {
    // `items` is an ABAP table, so reconcile builds every Message from the
    // UPPER-case columns. The key used to fall back to lower-case twins
    // that the add path never reads: two such rows produced two different
    // keys for two identical (empty) messages, and the manager collected a
    // duplicate for a message that carries nothing.
    const env = load();
    const ext = makeExt(env);
    ext.init();
    ext.setup();
    ext.setItems([{ message: "one" }, { message: "two" }]);
    expect(env.messaging.added).toHaveLength(1);
    expect(env.messaging.added[0]).toMatchObject({ message: "", type: "Error" });
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
