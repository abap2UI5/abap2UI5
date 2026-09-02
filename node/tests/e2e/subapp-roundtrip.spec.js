// @ts-check
// Sample 338 at the wire level: a host app holds its sub-app in a REF TO
// object, creates it by class name, and the tabs switch between TWO classes
// whose attributes have different names. Each sub-app keeps a runtime-built
// table behind a generic reference, the same table under a second name, and
// a helper object holding a third reference to it - the shape that dumped
// in the binding search after a tab switch and came back empty after a
// failed restore. Every step here is one roundtrip against the transpiled
// backend; what is asserted is what the browser would have shown.
const { test, expect } = require("@playwright/test");

const HOST = "zcl_tst_host";
const POPUP = "ZCL_TST_POPUP_APP";

function frontBody(sFront, model) {
  return {
    value: {
      ...(model ? { MODEL: model } : {}),
      S_FRONT: {
        ORIGIN: "http://localhost:3000",
        PATHNAME: "/",
        SEARCH: "",
        ...sFront,
      },
    },
  };
}

function slotAction(body, method, slot) {
  for (const item of body.S_FRONT?.S_ACTION?.T_SYSTEM ?? []) {
    const args = Array.isArray(item) ? item : [];
    if (args[0] === "VIEW_SLOTS" && args[1] === method && args[2] === slot) {
      return args;
    }
  }
  return undefined;
}

function toasts(body) {
  const out = [];
  for (const item of body.S_FRONT?.S_ACTION?.T_CUSTOM ?? []) {
    const args = Array.isArray(item) ? item : [];
    if (args[0] === "MESSAGE_TOAST") out.push(args[1]);
  }
  return out;
}

async function post(request, sFront, model) {
  const res = await request.post("/", { data: frontBody(sFront, model) });
  // a 500 is the framework's own error page - its text names the cause
  expect(res.status(), await res.text()).toBe(200);
  return res.json();
}

test("renders sub-app A into the host on start", async ({ request }) => {
  const body = await post(request, { SEARCH: `?app_start=${HOST}` });

  expect(slotAction(body, "display", "MAIN")).toBeDefined();
  const model = JSON.stringify(body.MODEL);
  expect(model).toContain('"a-1"');
  expect(model).toContain('"a-2"');
  expect(toasts(body)).toEqual([]);
});

test("switches to a sub-app of another class and back", async ({
  request,
}) => {
  const start = await post(request, { SEARCH: `?app_start=${HOST}` });

  // tab 2: class B, attributes MT_DATA / MO_LAY instead of MT_TABLE /
  // MO_LAYOUT. The rows the host dissolved for A resolve to nothing now -
  // this is the roundtrip that dumped in attri_search
  const toB = await post(
    request,
    { ID: start.S_FRONT.ID, EVENT: "ONSELECTICONTABBAR" },
    { MV_SELECTEDKEY: "2" },
  );
  expect(slotAction(toB, "display", "MAIN")).toBeDefined();
  let model = JSON.stringify(toB.MODEL);
  expect(model).toContain('"b-1"');
  expect(model).not.toContain('"a-1"');
  expect(toasts(toB)).toEqual([]);

  // an event roundtrip on B without a switch: the restore of B's table
  // and the identity of its three references
  const stay = await post(request, {
    ID: toB.S_FRONT.ID,
    EVENT: "NOOP",
  });
  expect(toasts(stay)).toEqual([]);

  // back to tab 1: a NEW instance of A, restored next to B's rows
  const toA = await post(
    request,
    { ID: stay.S_FRONT.ID, EVENT: "ONSELECTICONTABBAR" },
    { MV_SELECTEDKEY: "1" },
  );
  expect(slotAction(toA, "display", "MAIN")).toBeDefined();
  model = JSON.stringify(toA.MODEL);
  expect(model).toContain('"a-1"');
  expect(model).not.toContain('"b-1"');
  expect(toasts(toA)).toEqual([]);
});

test("a popup app called from the sub-app leaves the host's view alone", async ({
  request,
}) => {
  const start = await post(request, { SEARCH: `?app_start=${HOST}` });
  const toB = await post(
    request,
    { ID: start.S_FRONT.ID, EVENT: "ONSELECTICONTABBAR" },
    { MV_SELECTEDKEY: "2" },
  );

  // the row click in B hands over to the popup app: its popup, no main
  // view, and a model that knows nothing of the host or of B
  const popup = await post(request, {
    ID: toB.S_FRONT.ID,
    EVENT: "SELECTION_CHANGE",
  });
  expect(popup.S_FRONT.APP).toBe(POPUP);
  expect(slotAction(popup, "display", "POPUP")).toBeDefined();
  expect(slotAction(popup, "display", "MAIN")).toBeUndefined();
  expect(JSON.stringify(popup.MODEL ?? {})).not.toContain('"b-1"');
  expect(popup.MODEL?.MS_DATA_ROW?.CLASS).toBe("ZCL_TST_SUB_B");

  // closing it brings the host back: it re-renders MAIN with B's table,
  // restored from the draft the hop saved - all three references one object
  const back = await post(request, {
    ID: popup.S_FRONT.ID,
    EVENT: "CLOSE",
  });
  expect(back.S_FRONT.APP).toBe(HOST.toUpperCase());
  expect(slotAction(back, "display", "MAIN")).toBeDefined();
  expect(JSON.stringify(back.MODEL)).toContain('"b-1"');
  expect(toasts(back)).toEqual([]);

  // ...and the same from A, on the tab that was created a second time
  const toA = await post(
    request,
    { ID: back.S_FRONT.ID, EVENT: "ONSELECTICONTABBAR" },
    { MV_SELECTEDKEY: "3" },
  );
  const popupA = await post(request, {
    ID: toA.S_FRONT.ID,
    EVENT: "SELECTION_CHANGE",
  });
  expect(popupA.S_FRONT.APP).toBe(POPUP);
  expect(popupA.MODEL?.MS_DATA_ROW?.CLASS).toBe("ZCL_TST_SUB_A");
  const backA = await post(request, {
    ID: popupA.S_FRONT.ID,
    EVENT: "CLOSE",
  });
  expect(JSON.stringify(backA.MODEL)).toContain('"a-1"');
  expect(toasts(backA)).toEqual([]);
});

// Sample 212: the embedded sub-app opens a popup of its own while the host
// holds the page. The response is the HOST's (its class, its model with the
// sub-app's table inside), it displays the popup and leaves MAIN alone -
// and closing it sends the destroy, nothing else.
test("a popup opened from inside the embedded sub-app", async ({ request }) => {
  const start = await post(request, { SEARCH: `?app_start=${HOST}` });

  const opened = await post(request, {
    ID: start.S_FRONT.ID,
    EVENT: "ROW_POPUP",
  });
  expect(opened.S_FRONT.APP).toBe(HOST.toUpperCase());
  expect(slotAction(opened, "display", "POPUP")).toBeDefined();
  expect(slotAction(opened, "display", "MAIN")).toBeUndefined();
  expect(slotAction(opened, "display", "POPUP")?.[3]).toContain("sub-app a");
  expect(JSON.stringify(opened.MODEL)).toContain('"a-1"');
  expect(toasts(opened)).toEqual([]);

  const closed = await post(request, {
    ID: opened.S_FRONT.ID,
    EVENT: "POPUP_CLOSE",
  });
  expect(slotAction(closed, "destroy", "POPUP")).toBeDefined();
  expect(slotAction(closed, "display", "MAIN")).toBeUndefined();
  expect(toasts(closed)).toEqual([]);
});
