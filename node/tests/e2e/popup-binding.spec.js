// @ts-check
// The reported gesture, at the wire level: a view with a bound table is
// displayed, one row is clicked, and the app answers with a POPUP only -
// no view_display( ). The main view stays as it is, so everything it shows
// has to survive in the MODEL the popup roundtrip carries: a display action
// always ships the full model, and the frontend pushes that model into
// EVERY open slot (actions/Slots.updateModelIfRequired). A model that comes
// back without the main view's table therefore empties the table BEHIND the
// dialog - which is exactly what "the view in the background loses all
// binding" looks like.
const { test, expect } = require("@playwright/test");

const APP = "zcl_tst_popup_bind";

function frontBody(sFront) {
  return {
    value: {
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

async function start(request) {
  return (
    await request.post("/", { data: frontBody({ SEARCH: `?app_start=${APP}` }) })
  ).json();
}

async function fireRowSelect(request, id, event = "ROW_SELECT") {
  return (
    await request.post("/", { data: frontBody({ ID: id, EVENT: event }) })
  ).json();
}

test("seeds the bound table on app start", async ({ request }) => {
  const body = await start(request);

  expect(slotAction(body, "display", "MAIN")).toBeDefined();
  expect(body.MODEL?.MT_TAB).toHaveLength(3);
});

test("keeps the main view's table in the model when a popup opens", async ({
  request,
}) => {
  const first = await start(request);
  const second = await fireRowSelect(request, first.S_FRONT.ID);

  // the roundtrip did what the app asked: a popup, and no main rebuild
  expect(slotAction(second, "display", "POPUP")).toBeDefined();
  expect(slotAction(second, "display", "MAIN")).toBeUndefined();

  // ...and the model it ships still describes the view underneath
  expect(second.MODEL?.MT_TAB).toHaveLength(3);
});

test("keeps it when the same roundtrip rebuilds the main view too", async ({
  request,
}) => {
  const first = await start(request);
  const second = await fireRowSelect(
    request,
    first.S_FRONT.ID,
    "ROW_SELECT_REBUILD",
  );

  // both slots ship, MAIN first - the frontend takes the standalone slots
  // down with a MAIN rebuild, so a popup queued after it still opens
  expect(slotAction(second, "display", "MAIN")).toBeDefined();
  expect(slotAction(second, "display", "POPUP")).toBeDefined();

  // ...and the rebuilt view is filled from the same full model
  expect(second.MODEL?.MT_TAB).toHaveLength(3);
});

// The reported shape, at the wire level: the row click hands over to a
// SEPARATE app that owns the dialog (client->nav_app_call). The response then
// names the CALLED app, carries only that app's model and displays no main
// view - so the caller's table view stays on screen with a model that has
// none of its binding paths. The frontend guard is what keeps it: a slot is
// only pushed to by the app that filled it (actions/Slots, view1Events.spec).
test("a called popup app answers with only its own model", async ({
  request,
}) => {
  const first = await start(request);
  const second = await fireRowSelect(
    request,
    first.S_FRONT.ID,
    "ROW_SELECT_CALL",
  );

  expect(second.S_FRONT.APP).toBe("ZCL_TST_POPUP_APP");
  expect(second.S_FRONT.APP).not.toBe(first.S_FRONT.APP);

  // a popup, and no main view - the caller's view is still the one on screen
  expect(slotAction(second, "display", "POPUP")).toBeDefined();
  expect(slotAction(second, "display", "MAIN")).toBeUndefined();

  // and the model that travels is the CALLEE's alone: the caller's table is
  // not in it, which is exactly why it must not be pushed into MAIN
  expect(second.MODEL).toBeDefined();
  expect(second.MODEL).not.toHaveProperty("MT_TAB");
  expect(second.MODEL?.MS_DATA_ROW?.CLASS).toBe("CL_APP_006");
});

// The popup app's OWN roundtrips while it is open - each one answers with
// its model only, and never with a main view:
//  - an event that changes the model and displays nothing (the framework
//    pushes the change by itself),
//  - a popup opening a second popup (the caller's table is two hops away),
//  - and the way back, hop by hop, until the caller re-displays its view.
test("a popup app's event without a display pushes only its own model", async ({
  request,
}) => {
  const first = await start(request);
  const called = await fireRowSelect(request, first.S_FRONT.ID, "ROW_SELECT_CALL");

  const upper = await fireRowSelect(request, called.S_FRONT.ID, "UPPER");
  expect(upper.S_FRONT.APP).toBe("ZCL_TST_POPUP_APP");
  expect(slotAction(upper, "display", "MAIN")).toBeUndefined();
  expect(slotAction(upper, "display", "POPUP")).toBeUndefined();
  // the automatic push: a MODEL key with the changed value, nothing else
  expect(upper.MODEL?.MS_DATA_ROW?.DESCR).toBe("LOGIN AND LOGOFF FROM RESOURCE");
  expect(upper.MODEL).not.toHaveProperty("MT_TAB");
});

test("a popup opening a popup, and the way back to the caller", async ({
  request,
}) => {
  const first = await start(request);
  const called = await fireRowSelect(request, first.S_FRONT.ID, "ROW_SELECT_CALL");

  // second hop: another instance of the popup app owns the POPUP slot now
  const chained = await fireRowSelect(request, called.S_FRONT.ID, "NEXT");
  expect(chained.S_FRONT.APP).toBe("ZCL_TST_POPUP_APP");
  expect(slotAction(chained, "display", "POPUP")).toBeDefined();
  expect(slotAction(chained, "display", "MAIN")).toBeUndefined();
  expect(chained.MODEL?.MS_DATA_ROW?.CLASS).toBe("CHAIN");
  expect(chained.MODEL).not.toHaveProperty("MT_TAB");

  // one hop back: the first popup app again, still no main view
  const back1 = await fireRowSelect(request, chained.S_FRONT.ID, "CLOSE");
  expect(back1.S_FRONT.APP).toBe("ZCL_TST_POPUP_APP");
  expect(slotAction(back1, "display", "MAIN")).toBeUndefined();
  expect(JSON.stringify(back1.MODEL ?? {})).not.toContain("MT_TAB");

  // and the last hop lands on the caller, which re-displays its table
  const back2 = await fireRowSelect(request, back1.S_FRONT.ID, "CLOSE");
  expect(back2.S_FRONT.APP).toBe(first.S_FRONT.APP);
  expect(slotAction(back2, "display", "MAIN")).toBeDefined();
  expect(back2.MODEL?.MT_TAB).toHaveLength(3);
});
