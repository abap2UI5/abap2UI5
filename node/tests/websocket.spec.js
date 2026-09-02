// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");
const { loadLib } = require("./loadLibModule");

// cc/Websocket.js: keeps a WebSocket to an ABAP push channel open and hands
// every inbound message to the backend. The contract under test:
//   - "delegate, never decide" (AGENTS.md rule 10): every failure is logged
//     via Lib.logError and reported through the `error` EVENT - the control
//     never throws and never surfaces UI of its own.
//   - destroyed-guards: a socket callback or the drain timer firing after the
//     control was torn down must be a silent no-op.
//   - the busy queue: while a roundtrip is in flight (AppState.state.isBusy)
//     nothing is delivered; items queue and drain one per retry, in order.
function load({ isBusy = false, origin = "https://host.example" } = {}) {
  const errors = [];
  // The real Lib so isDestroyed/renderInvisibleSpan/afterRoundtrip are the
  // shipped ones; only logError is replaced to capture the messages. Lib
  // and the control share ONE state object, the way they do in the app -
  // afterRoundtrip decides on the same isBusy the control's drain sees.
  const state = { isBusy };
  const Lib = { ...loadLib({ z2ui5: state }).Lib, logError: (m) => errors.push(m) };
  const sockets = [];
  let failConstruct = false;
  class FakeWebSocket {
    constructor(url) {
      if (failConstruct) throw new Error("constructor rejected");
      this.url = url;
      this.closed = false;
      sockets.push(this);
    }
    close() {
      this.closed = true;
    }
  }
  // Deterministic timers: the drain's deferral (setTimeout 0) is captured
  // and run by hand.
  const timers = [];
  let nextTimerId = 1;
  const runTimers = () => {
    const due = timers.splice(0);
    for (const t of due) t.fn();
  };
  // The roundtrip landing, as View1 runs it: the after-rendering hooks
  // (where afterRoundtrip calls back) BEFORE the busy flag clears
  const landRoundtrip = () => {
    Lib.runCallbacks(state.onAfterRendering);
    state.isBusy = false;
  };
  const { module: Websocket } = loadModule("cc/Websocket.js", {
    deps: {
      "sap/ui/core/Control": {
        extend(_name, def) {
          function Ctrl() {}
          Object.assign(Ctrl.prototype, def);
          return Ctrl;
        },
      },
      "z2ui5/core/Lib": Lib,
      "z2ui5/core/AppState": { state },
    },
    sandbox: {
      WebSocket: FakeWebSocket,
      location: { origin },
      setTimeout: (fn) => {
        const id = nextTimerId++;
        timers.push({ id, fn });
        return id;
      },
      clearTimeout: (id) => {
        const at = timers.findIndex((t) => t.id === id);
        if (at !== -1) timers.splice(at, 1);
      },
    },
  });

  function makeInstance(props = {}) {
    const inst = new Websocket();
    inst._props = {
      path: "",
      value: "",
      checkActive: true,
      checkRepeat: true,
      ...props,
    };
    inst.getProperty = (k) => inst._props[k];
    inst.setProperty = (k, v) => (inst._props[k] = v);
    inst.received = [];
    inst.errorEvents = [];
    inst.fireReceived = () => inst.received.push(inst._props.value);
    inst.fireError = (p) => inst.errorEvents.push(p);
    inst._destroyed = false;
    inst.isDestroyed = () => inst._destroyed;
    inst.init();
    return inst;
  }

  return {
    makeInstance,
    sockets,
    errors,
    state,
    runTimers,
    landRoundtrip,
    timers,
    setFailConstruct: (v) => (failConstruct = v),
  };
}

test("resolves a relative APC path against the page origin as wss", () => {
  const { makeInstance, sockets } = load({ origin: "https://host.example" });
  const inst = makeInstance({ path: "/sap/bc/apc/sap/demo" });

  inst.onAfterRendering();

  expect(sockets).toHaveLength(1);
  expect(sockets[0].url).toBe("wss://host.example/sap/bc/apc/sap/demo");
});

test("an http origin resolves to ws, a missing leading slash is added", () => {
  const { makeInstance, sockets } = load({ origin: "http://localhost:3000" });
  makeInstance({ path: "apc/demo" }).onAfterRendering();

  expect(sockets[0].url).toBe("ws://localhost:3000/apc/demo");
});

test("a full ws:// or wss:// URL is taken as is", () => {
  const { makeInstance, sockets } = load();
  makeInstance({ path: "wss://other.host/channel" }).onAfterRendering();

  expect(sockets[0].url).toBe("wss://other.host/channel");
});

test("no path or checkActive=false opens no connection", () => {
  const { makeInstance, sockets } = load();
  makeInstance({ path: "" }).onAfterRendering();
  makeInstance({ path: "/apc", checkActive: false }).onAfterRendering();

  expect(sockets).toHaveLength(0);
});

test("checkActive switched back on clears the give-up", () => {
  const { makeInstance, sockets } = load();
  const inst = makeInstance({ path: "/apc" });

  // five failed attempts: the control gives up on this endpoint
  for (let i = 0; i < 5; i++) {
    inst.onAfterRendering();
    sockets[sockets.length - 1].onclose({ code: 1006, reason: "" });
  }
  inst.onAfterRendering();
  expect(sockets).toHaveLength(5);

  // the ICF node was activated meanwhile and the app asks again by
  // toggling checkActive - the contract names it next to a path change,
  // and it used to do nothing
  inst._props.checkActive = false;
  inst.onAfterRendering();
  inst._props.checkActive = true;
  inst.onAfterRendering();
  expect(sockets).toHaveLength(6);
});

test("toggling checkActive off closes, back on reconnects", () => {
  const { makeInstance, sockets } = load();
  const inst = makeInstance({ path: "/apc" });

  inst.onAfterRendering();
  expect(sockets).toHaveLength(1);

  inst._props.checkActive = false;
  inst.onAfterRendering();
  expect(sockets[0].closed).toBe(true);

  inst._props.checkActive = true;
  inst.onAfterRendering();
  expect(sockets).toHaveLength(2);
});

test("a rebound path drops the old connection and opens the new one", () => {
  const { makeInstance, sockets } = load();
  const inst = makeInstance({ path: "/apc/one" });
  inst.onAfterRendering();

  inst._props.path = "/apc/two";
  inst.onAfterRendering();

  expect(sockets[0].closed).toBe(true);
  expect(sockets[1].url).toBe("wss://host.example/apc/two");
});

test("an inbound text message lands in `value` and fires received", () => {
  const { makeInstance, sockets } = load();
  const inst = makeInstance({ path: "/apc" });
  inst.onAfterRendering();

  sockets[0].onmessage({ data: "PING 1" });

  expect(inst._props.value).toBe("PING 1");
  expect(inst.received).toHaveLength(1);
  // checkRepeat=true keeps the connection open
  expect(sockets[0].closed).toBe(false);
});

test("checkRepeat=false closes the connection after the first message", () => {
  const { makeInstance, sockets } = load();
  const inst = makeInstance({ path: "/apc", checkRepeat: false });
  inst.onAfterRendering();

  sockets[0].onmessage({ data: "once" });

  expect(inst.received).toHaveLength(1);
  expect(sockets[0].closed).toBe(true);
});

test("checkRepeat=false stays closed across the next re-renders", () => {
  const { makeInstance, sockets } = load();
  const inst = makeInstance({ path: "/apc", checkRepeat: false });
  inst.onAfterRendering();
  sockets[0].onmessage({ data: "once" });
  expect(sockets[0].closed).toBe(true);

  // every roundtrip re-renders; "once" used to become "once per roundtrip"
  inst.onAfterRendering();
  inst.onAfterRendering();
  expect(sockets).toHaveLength(1);

  // the app asks again: checkActive toggled, or checkRepeat back on
  inst._props.checkActive = false;
  inst.onAfterRendering();
  inst._props.checkActive = true;
  inst.onAfterRendering();
  expect(sockets).toHaveLength(2);
});

test("a non-text message is logged and ignored - never thrown", () => {
  const { makeInstance, sockets, errors } = load();
  const inst = makeInstance({ path: "/apc" });
  inst.onAfterRendering();

  sockets[0].onmessage({ data: new ArrayBuffer(4) });

  expect(inst.received).toHaveLength(0);
  expect(errors.some((m) => m.includes("non-text message"))).toBe(true);
});

test("a throwing WebSocket constructor logs and fires the error event", () => {
  const { makeInstance, errors, setFailConstruct } = load();
  setFailConstruct(true);
  const inst = makeInstance({ path: "/apc" });

  // never throws - the failure is delegated to the backend via the event
  inst.onAfterRendering();

  expect(errors.some((m) => m.startsWith("Websocket:"))).toBe(true);
  expect(inst.errorEvents).toHaveLength(1);
  expect(inst.errorEvents[0].code).toBe("CONSTRUCT");
  expect(inst.errorEvents[0].message).toContain("wss://host.example/apc");
});

test("an unrequested close is logged and reported with its close code", () => {
  const { makeInstance, sockets, errors } = load();
  const inst = makeInstance({ path: "/apc" });
  inst.onAfterRendering();

  // handshake never completed (inactive ICF node, rejected auth, ...)
  sockets[0].onclose({ code: 1006, reason: "" });

  expect(inst.errorEvents).toHaveLength(1);
  expect(inst.errorEvents[0].code).toBe("1006");
  expect(inst.errorEvents[0].message).toContain("could not be established");
  expect(errors.some((m) => m.includes("(1006)"))).toBe(true);
});

test("a close after open reports 'was closed' and appends the reason", () => {
  const { makeInstance, sockets } = load();
  const inst = makeInstance({ path: "/apc" });
  inst.onAfterRendering();

  sockets[0].onopen();
  sockets[0].onclose({ code: 1011, reason: "server going down" });

  expect(inst.errorEvents[0].message).toContain("was closed");
  expect(inst.errorEvents[0].message).toContain("server going down");
});

test("exit() closes the socket and drops its handlers - no error event", () => {
  const { makeInstance, sockets } = load();
  const inst = makeInstance({ path: "/apc" });
  inst.onAfterRendering();

  inst.exit();

  expect(sockets[0].closed).toBe(true);
  // _disconnect nulls the handlers first, so the app-requested close can
  // never masquerade as a server-side one
  expect(sockets[0].onclose).toBe(null);
  expect(sockets[0].onmessage).toBe(null);
  expect(inst.errorEvents).toHaveLength(0);
});

test("a message reaching a destroyed control is dropped", () => {
  const { makeInstance, sockets } = load();
  const inst = makeInstance({ path: "/apc" });
  inst.onAfterRendering();

  inst._destroyed = true;
  sockets[0].onmessage({ data: "late" });

  expect(inst.received).toHaveLength(0);
  expect(inst._props.value).toBe("");
});

test("while the backend is busy nothing is delivered - the queue drains when the roundtrip lands", () => {
  const { makeInstance, sockets, state, runTimers, landRoundtrip, timers } =
    load({ isBusy: true });
  const inst = makeInstance({ path: "/apc" });
  inst.onAfterRendering();

  sockets[0].onmessage({ data: "first" });
  sockets[0].onmessage({ data: "second" });

  // busy: queued, not delivered - and no timer polls for the flag, the
  // control waits on the after-rendering hook
  expect(inst.received).toHaveLength(0);
  expect(timers).toHaveLength(0);
  expect(state.onAfterRendering).toHaveLength(1);

  // the roundtrip lands: the hook fires while the flag is still set, the
  // deferred drain runs past the reset and delivers exactly one item
  landRoundtrip();
  expect(inst.received).toHaveLength(0);
  runTimers();
  expect(inst.received).toEqual(["first"]);
  // the fired event started no roundtrip (nothing set the flag), so the
  // next item follows on the next tick instead of waiting for one
  runTimers();
  expect(inst.received).toEqual(["first", "second"]);
});

test("an item fired while idle is delivered without waiting for a roundtrip", () => {
  const { makeInstance, sockets, runTimers, timers } = load({ isBusy: false });
  const inst = makeInstance({ path: "/apc" });
  inst.onAfterRendering();

  sockets[0].onmessage({ data: "now" });
  expect(inst.received).toEqual(["now"]);
  expect(timers).toHaveLength(0);
  runTimers();
  expect(inst.received).toEqual(["now"]);
});

test("messages and errors share the queue and keep their order", () => {
  const { makeInstance, sockets, runTimers, landRoundtrip } = load({ isBusy: true });
  const inst = makeInstance({ path: "/apc" });
  inst.onAfterRendering();

  sockets[0].onmessage({ data: "msg" });
  sockets[0].onclose({ code: 1006, reason: "" });

  landRoundtrip();
  runTimers();
  expect(inst.received).toEqual(["msg"]);
  expect(inst.errorEvents).toHaveLength(0);
  runTimers();
  expect(inst.errorEvents).toHaveLength(1);
});

test("the deferred drain firing after destroy is a silent no-op", () => {
  const { makeInstance, sockets, runTimers, landRoundtrip } = load({ isBusy: true });
  const inst = makeInstance({ path: "/apc" });
  inst.onAfterRendering();
  sockets[0].onmessage({ data: "late" });

  inst._destroyed = true;
  landRoundtrip();
  runTimers();

  expect(inst.received).toHaveLength(0);
});

test("exit() cancels a pending wait for the roundtrip", () => {
  const { makeInstance, sockets, state } = load({ isBusy: true });
  const inst = makeInstance({ path: "/apc" });
  inst.onAfterRendering();
  sockets[0].onmessage({ data: "queued" });
  expect(state.onAfterRendering).toHaveLength(1);

  inst.exit();

  expect(state.onAfterRendering).toHaveLength(0);
});
