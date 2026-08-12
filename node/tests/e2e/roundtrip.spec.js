// @ts-check
// Loaded via ./fixtures so the ui5-1.71 project can pin the UI5 build the
// browser-level tests below boot with; the request-level tests are
// bootstrap-independent and run unchanged in every project.
const { test, expect } = require("./fixtures");

// End-to-end coverage of the abap2UI5 roundtrip against the transpiled
// backend (node/srv/express.mjs): the POST wire contract (request parsing,
// app dispatch, draft persistence and session chaining) plus the UI5 shell
// booting in a real browser and issuing the initial roundtrip.
//
// The transpiled backend renders backend-built view XML since the
// interface-attribute access in check_on_init went through a typed
// variable (see the comment there) - the historical "never returns view
// XML" limitation is gone, and the tests below assert the full cycle:
// initial view XML, then an event roundtrip whose two-way model delta is
// applied before on_event and answered with the message box.

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

// The view XML of a response, read from the system action that displays the
// slot: ["VIEW_SLOTS","display","<slot>","<xml>",{...}?] in
// S_FRONT.S_ACTION.T_SYSTEM - the wire has no per-slot response fields.
function displayedXml(body, slot = "MAIN") {
  for (const item of body.S_FRONT?.S_ACTION?.T_SYSTEM ?? []) {
    const args = Array.isArray(item) ? item : [];
    if (args[0] === "VIEW_SLOTS" && args[1] === "display" && args[2] === slot) {
      return args[3];
    }
  }
  return undefined;
}

// The message-box APP action of a response:
// ["MESSAGE_BOX","<type>","<text>",{...}?] in T_CUSTOM.
function messageBoxText(body) {
  for (const item of body.S_FRONT?.S_ACTION?.T_CUSTOM ?? []) {
    const args = Array.isArray(item) ? item : [];
    if (args[0] === "MESSAGE_BOX") return args[2];
  }
  return undefined;
}

test("returns the backend-built view XML on app start", async ({ request }) => {
  const body = await (
    await request.post("/", {
      data: frontBody({ SEARCH: "?app_start=z2ui5_cl_app_hello_world" }),
    })
  ).json();

  const xml = displayedXml(body);
  expect(xml).toContain("<mvc:View");
  expect(xml).toContain('value="{/NAME}"');
  expect(xml).toContain("BUTTON_POST");
  // the two-way bound attribute is seeded in the model
  expect(body.MODEL).toHaveProperty("NAME");
});

test("applies the model delta before on_event and answers the event", async ({
  request,
}) => {
  const first = await (
    await request.post("/", {
      data: frontBody({ SEARCH: "?app_start=z2ui5_cl_app_hello_world" }),
    })
  ).json();

  // fire the hello-world button event, shipping the edited input value as
  // the two-way model delta - the backend must apply it to the app object
  // BEFORE on_event runs and answer with the message box
  const second = await (
    await request.post("/", {
      data: {
        value: {
          MODEL: { NAME: "Roundtrip" },
          S_FRONT: {
            ORIGIN: "http://localhost:3000",
            PATHNAME: "/",
            SEARCH: "",
            ID: first.S_FRONT.ID,
            EVENT: "BUTTON_POST",
          },
        },
      },
    })
  ).json();

  expect(messageBoxText(second)).toBe("Your name is Roundtrip");
  // an event roundtrip without view_display must not resend the view
  expect(displayedXml(second)).toBeUndefined();
});

test("rejects a broken request body with a framework error", async ({
  request,
}) => {
  const res = await request.post("/", { data: "no json at all" });

  // The single top-level catch in z2ui5_cl_http_handler=>_main turns the
  // parse failure into a 500 carrying the full exception dump, so the frontend
  // shows the real reason instead of the generic SAP ICF 500 page: a header
  // line naming the framework and version, the message, and one block per
  // entry of the previous chain.
  expect(res.status()).toBe(500);
  const body = await res.text();
  expect(body).toContain("abap2UI5");
  expect(body).toContain("Json parsing error");
  expect(body).toContain("exception chain");
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

test("renders the view, posts the input value and shows the message box", async ({
  page,
}) => {
  await page.goto("/?app_start=z2ui5_cl_app_hello_world");

  // the backend-built view really renders in the shell
  const input = page.locator("input").first();
  await input.waitFor();
  await input.fill("Browser");
  await page.getByRole("button", { name: "Post" }).click();

  // BUTTON_POST answers with message_box_display - a real dialog opens
  await expect(page.getByText("Your name is Browser")).toBeVisible();
});

test("does not append a dangling '#' to the URL after app start", async ({
  page,
}) => {
  // Regression: with the manifest routing gone, nothing initialized the
  // HashChanger's hasher singleton anymore, so the app-state cleanup in
  // Router.sync (replaceHash(""), run once per response by View1's
  // after-render phase) rewrote every started app's URL to ".../path#".
  // Component.init now initializes the HashChanger explicitly.
  const responsePromise = page.waitForResponse(
    (r) => r.request().method() === "POST",
  );
  await page.goto("/?app_start=z2ui5_cl_app_hello_world");
  await responsePromise;

  // Router.sync runs right after the system actions of
  // _processAfterRendering, which flags the response as processed right
  // before that phase - wait for the flag plus a settle tick so the
  // (synchronous) hash rewrite, if any, has happened before asserting.
  await page.waitForFunction(
    () => window.z2ui5?.oResponse?._processed === true,
  );
  await page.waitForTimeout(100);

  expect(page.url()).not.toContain("#");
});
