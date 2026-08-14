// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");

// Tests the real implementation shipped in
// app/webapp/devtools/Recorder.js (loaded via a stubbed sap.ui.define).
// The recorder observes the framework from the outside - through the
// onAfterRendering callback array and the browser's Resource Timing API -
// so the harness below stubs exactly those two surfaces and nothing else.

const PAGE_URL = "https://sap.example.com/ui5/index.html";
const BACKEND_PATH = "/sap/z2ui5";
const BACKEND_URL = "https://sap.example.com/sap/z2ui5";

function loadRecorder({ storage = {} } = {}) {
  // Callback arrays the recorder registers into, mirroring Lib's contract.
  const callbacks = {};
  const logged = [];
  const state = { responseData: null, oBody: null, errors: [] };

  const AppState = {
    state,
    getGlobal: (name) => (name === "url" ? BACKEND_PATH : undefined),
  };
  const Lib = {
    registerCallback(name, fn) {
      if (!callbacks[name]) callbacks[name] = [];
      callbacks[name].push(fn);
    },
    unregisterCallback(name, fn) {
      if (!callbacks[name]) return;
      callbacks[name] = callbacks[name].filter((f) => f !== fn);
    },
    logError(message) {
      logged.push(message);
    },
  };

  // Resource Timing double: `entries` is what getEntriesByName returns and
  // `deliver()` is what the PerformanceObserver hands over, so the ordering
  // of the two sources can be exercised independently.
  const entries = [];
  let observerCallback = null;
  const clock = { value: 0 };

  const performanceStub = {
    now: () => clock.value,
    getEntriesByName: (name) => entries.filter((e) => e.name === name),
  };

  class PerformanceObserverStub {
    constructor(callback) {
      observerCallback = callback;
    }
    observe() {}
    disconnect() {
      observerCallback = null;
    }
  }

  const sessionStorage = {
    getItem: (key) => (key in storage ? storage[key] : null),
    setItem: (key, value) => {
      storage[key] = value;
    },
    removeItem: (key) => {
      delete storage[key];
    },
  };

  const windowListeners = {};
  const windowStub = {
    location: { href: PAGE_URL },
    sessionStorage,
    // the history is written away on pagehide so it survives a reload
    addEventListener: (type, fn) => {
      windowListeners[type] = fn;
    },
    removeEventListener: (type) => {
      delete windowListeners[type];
    },
  };

  const { module } = loadModule("devtools/Recorder.js", {
    deps: {
      "z2ui5/core/AppState": AppState,
      "z2ui5/core/Lib": Lib,
    },
    sandbox: {
      window: windowStub,
      performance: performanceStub,
      PerformanceObserver: PerformanceObserverStub,
    },
  });

  // Append a finished backend request to the Resource Timing buffer.
  function addEntry({ start, end, bytes = 0 }) {
    entries.push({
      name: BACKEND_URL,
      startTime: start,
      responseEnd: end,
      decodedBodySize: bytes,
    });
  }

  // Hand the buffered entries to the observer, the way the browser does
  // when its callback task runs.
  function deliverToObserver() {
    if (observerCallback) observerCallback({ getEntries: () => entries });
  }

  function fireAfterRendering() {
    for (const fn of callbacks.onAfterRendering || []) fn();
  }

  return {
    Recorder: module,
    state,
    clock,
    storage,
    logged,
    addEntry,
    deliverToObserver,
    fireAfterRendering,
    callbacks,
    pagehide: () => windowListeners.pagehide?.(),
  };
}

// A response as Server.readHttp parks it in AppState.state.responseData.
function fakeResponse({
  id = "draft-new",
  app = "ZCL_APP",
  system = [],
  custom = [],
  model = undefined,
} = {}) {
  return {
    S_FRONT: { ID: id, APP: app, S_ACTION: { T_SYSTEM: system, T_CUSTOM: custom } },
    MODEL: model,
  };
}

function fakeRequest({ event = "SAVE", id = "draft-prev", model } = {}) {
  const body = { S_FRONT: { EVENT: event, ID: id } };
  if (model !== undefined) body.MODEL = model;
  return body;
}

test.describe("Tier 1 - metadata", () => {
  test("records one roundtrip with timing, sizes and action counts", () => {
    const h = loadRecorder();
    h.Recorder.install();

    h.state.oBody = fakeRequest({ event: "SAVE" });
    h.state.responseData = fakeResponse({
      system: ["a", "b"],
      custom: ["c"],
    });
    h.addEntry({ start: 100, end: 180, bytes: 2048 });
    h.clock.value = 200;
    h.fireAfterRendering();

    const [record] = h.Recorder.getRecords();
    expect(record.seq).toBe(1);
    expect(record.event).toBe("SAVE");
    expect(record.idSent).toBe("draft-prev");
    expect(record.idReceived).toBe("draft-new");
    expect(record.app).toBe("ZCL_APP");
    expect(record.backendMs).toBe(80);
    expect(record.renderMs).toBe(20);
    expect(record.totalMs).toBe(100);
    expect(record.respBytes).toBe(2048);
    expect(record.systemActions).toBe(2);
    expect(record.customActions).toBe(1);
    expect(record.rendered).toBe(true);
  });

  test("measures the serialized request size", () => {
    const h = loadRecorder();
    h.Recorder.install();
    const body = fakeRequest({ model: { NAME: "abc" } });
    h.state.oBody = body;
    h.state.responseData = fakeResponse();
    h.fireAfterRendering();

    const [record] = h.Recorder.getRecords();
    expect(record.reqBytes).toBe(JSON.stringify({ value: body }).length);
  });

  test("keeps no payloads unless recording is switched on", () => {
    const h = loadRecorder();
    h.Recorder.install();
    h.state.oBody = fakeRequest();
    h.state.responseData = fakeResponse({ model: { A: 1 } });
    h.fireAfterRendering();

    const [record] = h.Recorder.getRecords();
    expect(h.Recorder.isRecordingPayloads()).toBe(false);
    expect(record.request).toBe(null);
    expect(record.response).toBe(null);
  });

  test("records a roundtrip even without any Resource Timing entry", () => {
    const h = loadRecorder();
    h.Recorder.install();
    h.state.oBody = fakeRequest({ event: "REFRESH" });
    h.state.responseData = fakeResponse();
    h.fireAfterRendering();

    const [record] = h.Recorder.getRecords();
    expect(record.event).toBe("REFRESH");
    expect(record.backendMs).toBe(null);
    expect(record.respBytes).toBe(null);
    expect(record.rendered).toBe(true);
  });

  test("caps the ring at MAX_RECORDS and keeps the running numbers", () => {
    const h = loadRecorder();
    h.Recorder.install();
    const max = h.Recorder._internals.MAX_RECORDS;
    for (let i = 0; i < max + 5; i++) {
      h.state.oBody = fakeRequest({ event: `E${i}` });
      h.state.responseData = fakeResponse();
      h.fireAfterRendering();
    }
    const list = h.Recorder.getRecords();
    expect(list.length).toBe(max);
    // the ring dropped the first five, so numbering starts at 6
    expect(list[0].seq).toBe(6);
    expect(list[list.length - 1].seq).toBe(max + 5);
  });
});

test.describe("network pairing", () => {
  test("a request that never rendered is kept as its own row", () => {
    const h = loadRecorder();
    h.Recorder.install();
    // an aborted / failed roundtrip: observed on the wire, no render
    h.addEntry({ start: 10, end: 20, bytes: 64 });
    h.deliverToObserver();
    // far enough past UNPAIRED_FLUSH_MS that no render can still be coming
    h.clock.value = 10000;

    const list = h.Recorder.getRecords();
    expect(list.length).toBe(1);
    expect(list[0].rendered).toBe(false);
    expect(list[0].backendMs).toBe(10);
    expect(list[0].respBytes).toBe(64);
    expect(h.Recorder.formatHistory()).toContain("(no render)");
  });

  test("pairs the render with the request that finished before it", () => {
    const h = loadRecorder();
    h.Recorder.install();
    // an older, superseded request plus the one that actually rendered
    h.addEntry({ start: 10, end: 20, bytes: 10 });
    h.addEntry({ start: 100, end: 150, bytes: 500 });
    h.state.oBody = fakeRequest({ event: "GO" });
    h.state.responseData = fakeResponse();
    h.clock.value = 170;
    h.fireAfterRendering();

    const list = h.Recorder.getRecords();
    expect(list.length).toBe(2);
    // the superseded one is flushed first, keeping the timeline in order
    expect(list[0].rendered).toBe(false);
    expect(list[1].event).toBe("GO");
    expect(list[1].backendMs).toBe(50);
    expect(list[1].renderMs).toBe(20);
  });

  test("does not consume the same entry twice from both sources", () => {
    const h = loadRecorder();
    h.Recorder.install();
    h.addEntry({ start: 100, end: 150, bytes: 500 });
    // observer delivers first, then the render path sweeps synchronously
    h.deliverToObserver();
    h.state.oBody = fakeRequest();
    h.state.responseData = fakeResponse();
    h.clock.value = 160;
    h.fireAfterRendering();

    const list = h.Recorder.getRecords();
    expect(list.length).toBe(1);
    expect(list[0].rendered).toBe(true);
    expect(list[0].backendMs).toBe(50);
  });
});

test.describe("Tier 2 - payloads", () => {
  test("retains request and response once switched on", () => {
    const h = loadRecorder();
    h.Recorder.install();
    h.Recorder.setRecordingPayloads(true);
    expect(h.Recorder.isRecordingPayloads()).toBe(true);

    const body = fakeRequest();
    const response = fakeResponse({ model: { A: 1 } });
    h.state.oBody = body;
    h.state.responseData = response;
    h.fireAfterRendering();

    const [record] = h.Recorder.getRecords();
    // plain references, no clone - see the module header
    expect(record.request).toBe(body);
    expect(record.response).toBe(response);
  });

  test("the flag survives in sessionStorage", () => {
    const storage = {};
    const h = loadRecorder({ storage });
    h.Recorder.setRecordingPayloads(true);
    expect(storage[h.Recorder._internals.PAYLOAD_FLAG_KEY]).toBe("X");

    // a fresh module instance (page reload) sees the same flag
    const h2 = loadRecorder({ storage });
    expect(h2.Recorder.isRecordingPayloads()).toBe(true);
  });

  test("switching off drops what was already retained", () => {
    const h = loadRecorder();
    h.Recorder.install();
    h.Recorder.setRecordingPayloads(true);
    h.state.oBody = fakeRequest();
    h.state.responseData = fakeResponse({ model: { A: 1 } });
    h.fireAfterRendering();
    expect(h.Recorder.getRecords()[0].response).not.toBe(null);

    h.Recorder.setRecordingPayloads(false);
    const [record] = h.Recorder.getRecords();
    expect(record.request).toBe(null);
    expect(record.response).toBe(null);
    // the metadata row survives the payload drop
    expect(record.rendered).toBe(true);
  });

  test("evicts the oldest payloads when the byte budget is exceeded", () => {
    const h = loadRecorder();
    h.Recorder.install();
    h.Recorder.setRecordingPayloads(true);
    const budget = h.Recorder._internals.PAYLOAD_BUDGET_BYTES;
    // three roundtrips of ~60% of the budget each: the first must go
    const chunk = Math.round(budget * 0.6);
    for (let i = 0; i < 3; i++) {
      h.state.oBody = fakeRequest({ event: `E${i}` });
      h.state.responseData = fakeResponse({ model: { A: i } });
      h.addEntry({ start: i * 100, end: i * 100 + 10, bytes: chunk });
      h.clock.value = i * 100 + 20;
      h.fireAfterRendering();
    }
    const list = h.Recorder.getRecords();
    expect(list[0].response).toBe(null);
    expect(list[0].payloadEvicted).toBe(true);
    // the newest is always kept
    expect(list[list.length - 1].response).not.toBe(null);
    expect(h.Recorder.formatHistory()).toContain("evicted");
  });
});

test.describe("model diff", () => {
  function recordTwo(h, modelA, modelB) {
    h.Recorder.setRecordingPayloads(true);
    h.state.oBody = fakeRequest({ event: "FIRST" });
    h.state.responseData = fakeResponse({ model: modelA });
    h.fireAfterRendering();
    h.state.oBody = fakeRequest({ event: "SECOND" });
    h.state.responseData = fakeResponse({ model: modelB });
    h.fireAfterRendering();
  }

  test("reports changed, added and removed paths", () => {
    const h = loadRecorder();
    h.Recorder.install();
    recordTwo(
      h,
      { NAME: "old", GONE: 1, KEEP: "same" },
      { NAME: "new", ADDED: 2, KEEP: "same" },
    );
    const diff = h.Recorder.formatModelDiff();
    expect(diff).toContain("~ /NAME");
    expect(diff).toContain("before: old");
    expect(diff).toContain("after:  new");
    expect(diff).toContain("+ /ADDED");
    expect(diff).toContain("- /GONE");
    expect(diff).not.toContain("/KEEP");
  });

  test("walks into table rows", () => {
    const h = loadRecorder();
    h.Recorder.install();
    recordTwo(
      h,
      { TAB: [{ COL: "a" }, { COL: "b" }] },
      { TAB: [{ COL: "a" }, { COL: "z" }] },
    );
    const diff = h.Recorder.formatModelDiff();
    expect(diff).toContain("~ /TAB/1/COL");
    expect(diff).toContain("after:  z");
  });

  test("says so when both responses carry the same model", () => {
    const h = loadRecorder();
    h.Recorder.install();
    recordTwo(h, { A: 1 }, { A: 1 });
    expect(h.Recorder.formatModelDiff()).toContain("identical MODEL");
  });

  test("explains what to do when payload recording is off", () => {
    const h = loadRecorder();
    h.Recorder.install();
    h.state.oBody = fakeRequest();
    h.state.responseData = fakeResponse({ model: { A: 1 } });
    h.fireAfterRendering();
    expect(h.Recorder.formatModelDiff()).toContain("needs payload recording");
  });

  test("explains what to do with only one recorded response", () => {
    const h = loadRecorder();
    h.Recorder.install();
    h.Recorder.setRecordingPayloads(true);
    h.state.oBody = fakeRequest();
    h.state.responseData = fakeResponse({ model: { A: 1 } });
    h.fireAfterRendering();
    expect(h.Recorder.formatModelDiff()).toContain("needs two");
  });
});

test.describe("lifecycle", () => {
  test("install is idempotent and registers exactly one hook", () => {
    const h = loadRecorder();
    h.Recorder.install();
    h.Recorder.install();
    expect(h.callbacks.onAfterRendering.length).toBe(1);
  });

  test("uninstall unregisters the hook and clears the history", () => {
    const h = loadRecorder();
    h.Recorder.install();
    h.state.oBody = fakeRequest();
    h.state.responseData = fakeResponse();
    h.fireAfterRendering();
    expect(h.Recorder.getRecords().length).toBe(1);

    h.Recorder.uninstall();
    expect(h.callbacks.onAfterRendering.length).toBe(0);
    expect(h.Recorder.getRecords().length).toBe(0);
  });

  test("a throwing state never propagates out of the hook", () => {
    const h = loadRecorder();
    h.Recorder.install();
    // a body that cannot be serialized must not take the roundtrip down
    const circular = { S_FRONT: { EVENT: "X", ID: "1" } };
    circular.self = circular;
    h.state.oBody = circular;
    h.state.responseData = fakeResponse();
    h.fireAfterRendering();

    const [record] = h.Recorder.getRecords();
    expect(record.event).toBe("X");
    expect(record.reqBytes).toBe(null);
  });
});

test.describe("history rendering", () => {
  test("renders an empty history without a table", () => {
    const h = loadRecorder();
    h.Recorder.install();
    const text = h.Recorder.formatHistory();
    expect(text).toContain("no roundtrip recorded yet");
    expect(text).toContain("Payload recording: OFF");
  });

  test("renders one row per roundtrip with the event name", () => {
    const h = loadRecorder();
    h.Recorder.install();
    h.state.oBody = fakeRequest({ event: "BUTTON_SAVE" });
    h.state.responseData = fakeResponse();
    h.fireAfterRendering();
    const text = h.Recorder.formatHistory();
    expect(text).toContain("BUTTON_SAVE");
    expect(text).toContain("TOTAL");
  });

  test("summarises the timings so one slow event stands out", () => {
    const h = loadRecorder();
    h.Recorder.install();
    const rt = (event, start, end, bytes) => {
      h.state.oBody = fakeRequest({ event });
      h.state.responseData = fakeResponse();
      h.addEntry({ start, end, bytes });
      h.clock.value = end + 5;
      h.fireAfterRendering();
    };
    rt("FAST_A", 0, 20, 100);
    rt("SLOW", 100, 1100, 900000);
    rt("FAST_B", 2000, 2020, 100);

    const text = h.Recorder.formatHistory();
    expect(text).toContain("Summary");
    // avg over 20/1000/20 ms
    expect(text).toContain("avg 347 ms over 3 roundtrip(s)");
    expect(text).toContain("slowest #2 SLOW at 1000 ms");
    expect(text).toContain("largest #2 SLOW");
  });

  test("the summary counts the roundtrips that never rendered", () => {
    const h = loadRecorder();
    h.Recorder.install();
    h.state.oBody = fakeRequest({ event: "OK" });
    h.state.responseData = fakeResponse();
    h.addEntry({ start: 0, end: 10, bytes: 10 });
    h.clock.value = 20;
    h.fireAfterRendering();
    // a roundtrip observed on the wire that never rendered
    h.addEntry({ start: 100, end: 110, bytes: 10 });
    h.deliverToObserver();
    h.clock.value = 20000;

    expect(h.Recorder.formatHistory()).toContain(
      "1 roundtrip(s) never reached the render phase",
    );
  });

  test("labels the app start roundtrip, which carries no event", () => {
    const h = loadRecorder();
    h.Recorder.install();
    h.state.oBody = {};
    h.state.responseData = fakeResponse();
    h.fireAfterRendering();
    expect(h.Recorder.formatHistory()).toContain("(start)");
  });
});

test.describe("surviving a page reload", () => {
  test("writes the metadata away on pagehide and reads it back", () => {
    const storage = {};
    const first = loadRecorder({ storage });
    first.Recorder.install();
    first.state.oBody = fakeRequest({ event: "BEFORE_RELOAD" });
    first.state.responseData = fakeResponse();
    first.fireAfterRendering();
    first.pagehide();

    // a fresh module instance, as after the reload
    const second = loadRecorder({ storage });
    second.Recorder.install();
    const list = second.Recorder.getRecords();
    expect(list.length).toBe(1);
    expect(list[0].event).toBe("BEFORE_RELOAD");
    expect(list[0].previousLoad).toBe(true);
    expect(second.Recorder.formatHistory()).toContain("PREVIOUS page");
  });

  test("payloads never travel - only the metadata does", () => {
    const storage = {};
    const first = loadRecorder({ storage });
    first.Recorder.install();
    first.Recorder.setRecordingPayloads(true);
    first.state.oBody = fakeRequest();
    first.state.responseData = fakeResponse({ model: { A: 1 } });
    first.fireAfterRendering();
    first.pagehide();

    const second = loadRecorder({ storage });
    second.Recorder.install();
    const [record] = second.Recorder.getRecords();
    expect(record.response).toBe(undefined);
    expect(record.rendered).toBe(true);
  });

  test("numbering continues after the restored records", () => {
    const storage = {};
    const first = loadRecorder({ storage });
    first.Recorder.install();
    for (let i = 0; i < 3; i++) {
      first.state.oBody = fakeRequest({ event: `E${i}` });
      first.state.responseData = fakeResponse();
      first.fireAfterRendering();
    }
    first.pagehide();

    const second = loadRecorder({ storage });
    second.Recorder.install();
    second.state.oBody = fakeRequest({ event: "AFTER" });
    second.state.responseData = fakeResponse();
    second.fireAfterRendering();
    const list = second.Recorder.getRecords();
    expect(list[list.length - 1].seq).toBe(4);
  });

  test("the stored entry is consumed, not replayed on every load", () => {
    const storage = {};
    const first = loadRecorder({ storage });
    first.Recorder.install();
    first.state.oBody = fakeRequest();
    first.state.responseData = fakeResponse();
    first.fireAfterRendering();
    first.pagehide();

    loadRecorder({ storage }).Recorder.install();
    const third = loadRecorder({ storage });
    third.Recorder.install();
    expect(third.Recorder.getRecords().length).toBe(0);
  });
});

test.describe("app navigation", () => {
  test("reconstructs the app hops observed in this session", () => {
    const h = loadRecorder();
    h.Recorder.install();
    const hop = (app, event) => {
      h.state.oBody = fakeRequest({ event });
      h.state.responseData = fakeResponse({ app });
      h.fireAfterRendering();
    };
    hop("ZCL_START", "");
    hop("ZCL_START", "SEARCH");
    hop("ZCL_DETAIL", "OPEN_ITEM");
    hop("ZCL_START", "BACK");

    const text = h.Recorder.formatHistory();
    expect(text).toContain("App navigation observed this session");
    expect(text).toContain("start ZCL_START");
    expect(text).toContain("ZCL_START -> ZCL_DETAIL");
    expect(text).toContain("via OPEN_ITEM");
    expect(text).toContain("ZCL_DETAIL -> ZCL_START");
  });

  test("a session that never left one app reports no navigation", () => {
    const h = loadRecorder();
    h.Recorder.install();
    h.state.oBody = fakeRequest();
    h.state.responseData = fakeResponse({ app: "ZCL_ONLY" });
    h.fireAfterRendering();
    expect(h.Recorder.formatHistory()).not.toContain("App navigation");
  });
});

test.describe("view diff", () => {
  const display = (xml) => ["VIEW_SLOTS", "display", "MAIN", xml];

  function recordViews(h, xmlA, xmlB) {
    h.Recorder.setRecordingPayloads(true);
    h.state.oBody = fakeRequest({ event: "FIRST" });
    h.state.responseData = fakeResponse({ system: [display(xmlA)] });
    h.fireAfterRendering();
    h.state.oBody = fakeRequest({ event: "SECOND" });
    h.state.responseData = fakeResponse({ system: [display(xmlB)] });
    h.fireAfterRendering();
  }

  test("reports an inserted control as an addition", () => {
    const h = loadRecorder();
    h.Recorder.install();
    recordViews(
      h,
      "<View><Button text='a'/><Input/></View>",
      "<View><Button text='a'/><Text text='new'/><Input/></View>",
    );
    const diff = h.Recorder.formatViewDiff();
    expect(diff).toContain("+");
    expect(diff).toContain("Text text='new'");
    // the unchanged lines are not listed
    expect(diff).not.toContain("- <Input/>");
  });

  test("reports a changed attribute as a removal plus an addition", () => {
    const h = loadRecorder();
    h.Recorder.install();
    recordViews(
      h,
      "<View><Button text='old'/></View>",
      "<View><Button text='new'/></View>",
    );
    const diff = h.Recorder.formatViewDiff();
    expect(diff).toContain("Button text='old'");
    expect(diff).toContain("Button text='new'");
  });

  test("says so when the two rebuilds are identical", () => {
    const h = loadRecorder();
    h.Recorder.install();
    recordViews(h, "<View><A/></View>", "<View><A/></View>");
    expect(h.Recorder.formatViewDiff()).toContain("identical view XML");
  });

  test("a roundtrip that only pushed the model does not count", () => {
    const h = loadRecorder();
    h.Recorder.install();
    h.Recorder.setRecordingPayloads(true);
    h.state.oBody = fakeRequest();
    h.state.responseData = fakeResponse({ system: [display("<View/>")] });
    h.fireAfterRendering();
    // second roundtrip rebuilds nothing
    h.state.oBody = fakeRequest();
    h.state.responseData = fakeResponse({ system: [] });
    h.fireAfterRendering();
    expect(h.Recorder.formatViewDiff()).toContain("needs two");
  });

  test("explains what to do when payload recording is off", () => {
    const h = loadRecorder();
    h.Recorder.install();
    expect(h.Recorder.formatViewDiff()).toContain("needs payload recording");
  });

  test("ignores a display into another slot", () => {
    const h = loadRecorder();
    h.Recorder.install();
    h.Recorder.setRecordingPayloads(true);
    for (const xml of ["<Dialog a=1/>", "<Dialog a=2/>"]) {
      h.state.oBody = fakeRequest();
      h.state.responseData = fakeResponse({
        system: [["VIEW_SLOTS", "display", "POPUP", xml]],
      });
      h.fireAfterRendering();
    }
    expect(h.Recorder.formatViewDiff()).toContain("needs two");
  });
});
