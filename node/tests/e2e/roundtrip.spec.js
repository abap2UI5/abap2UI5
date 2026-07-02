// @ts-check
const { test, expect } = require("@playwright/test");

// End-to-end coverage of the abap2UI5 roundtrip against the transpiled
// backend (node/srv/express.mjs): the POST wire contract (request parsing,
// app dispatch, draft persistence and session chaining) plus the UI5 shell
// booting in a real browser and issuing the initial roundtrip.
//
// Known limitation: the transpiled Node backend never returns backend-built
// view XML, because interface attributes read through an interface-typed
// reference (client->check_on_init reading z2ui5_if_app~check_initialized)
// resolve to a property that does not exist in the transpiled JS, so
// check_on_init( ) is always false there. Once that upstream
// @abaplint/transpiler issue is resolved, extend these tests to fill the
// hello world input and assert the rendered view/message box.

const HELLO_WORLD = "Z2UI5_CL_APP_HELLO_WORLD";

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

test("starts an app via app_start and answers with a draft id", async ({
  request,
}) => {
  const res = await request.post("/", {
    data: frontBody({ SEARCH: "?app_start=z2ui5_cl_app_hello_world" }),
  });

  expect(res.ok()).toBeTruthy();
  const body = await res.json();
  expect(body.S_FRONT.APP).toBe(HELLO_WORLD);
  expect(body.S_FRONT.ID).toMatch(/^[0-9A-F]{32}$/);
  expect(body).toHaveProperty("MODEL");
});

test("chains the session draft across roundtrips", async ({ request }) => {
  const first = await (
    await request.post("/", {
      data: frontBody({ SEARCH: "?app_start=z2ui5_cl_app_hello_world" }),
    })
  ).json();

  // A follow-up roundtrip referencing the draft id restores the same app
  // from the draft table and answers with a fresh draft id.
  const second = await (
    await request.post("/", { data: frontBody({ ID: first.S_FRONT.ID }) })
  ).json();

  expect(second.S_FRONT.APP).toBe(HELLO_WORLD);
  expect(second.S_FRONT.ID).toMatch(/^[0-9A-F]{32}$/);
  expect(second.S_FRONT.ID).not.toBe(first.S_FRONT.ID);
});

test("rejects a broken request body with a framework error", async ({
  request,
}) => {
  const res = await request.post("/", { data: "no json at all" });

  expect(res.status()).toBe(500);
  expect(await res.text()).toContain("abap2UI5");
});

test("boots the UI5 shell in the browser and issues the initial roundtrip", async ({
  page,
}) => {
  const responsePromise = page.waitForResponse(
    (r) => r.request().method() === "POST",
  );
  await page.goto("/?app_start=z2ui5_cl_app_hello_world");

  const response = await responsePromise;
  expect(response.status()).toBe(200);
  const body = await response.json();
  expect(body.S_FRONT.APP).toBe(HELLO_WORLD);
  expect(body.S_FRONT.ID).toMatch(/^[0-9A-F]{32}$/);
});
