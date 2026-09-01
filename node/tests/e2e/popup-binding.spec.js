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
