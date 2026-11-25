// @ts-check
// The custom controls out of the frontend bundle: the files of
// bundle/webapp/cc are the CUSTOM CONTROLS BUNDLE - a third generated script
// the backend serves on ?z2ui5-bundle=cc (z2ui5_cl_ui5f_preload=>get_cc) -
// and core/CustomControls.js loads it with a <script> element before the
// first view that names a control is built. A page whose views name none
// never asks for it; the first view that does loads it once, whichever way
// that view reaches the screen (the MAIN view, a nested view, a popup), and
// every later one finds it there. None of it needs an inline script or
// eval - the shipped CSP sees no violation (AGENTS.md rule 13) - and a
// bundle that cannot be loaded ends in the error overlay, not in a view
// without its control.
//
// The app is node/srv/zcl_tst_cc: every display carries a z2ui5:InputExt,
// a sap.m.Input that writes its inputMode property onto the inner <input>
// (numeric in the MAIN view, tel in the popup, decimal in the nested view) -
// a plain sap.m.Input renders no inputmode at all, so the attribute is the
// control at work.
const { test, expect } = require("./fixtures");

const APP = "/?app_start=zcl_tst_cc";
const isCcBundle = (url) => /[?&]z2ui5-bundle=cc(&|$)/.test(url);
// a control asked of the loader as a file of its own - what must never
// happen: the node answers every GET with the page
const isCcModule = (url) => /\/cc\/\w+\.js/.test(url);

async function watchCsp(page) {
  await page.addInitScript(() => {
    const violations = [];
    Object.defineProperty(window, "__z2ui5CspViolations", {
      value: violations,
    });
    document.addEventListener("securitypolicyviolation", (e) =>
      violations.push(`${e.violatedDirective} ${e.blockedURI}`),
    );
  });
}

const violations = (page) =>
  page.evaluate(() => /** @type {any} */ (window).__z2ui5CspViolations);

function watchRequests(page) {
  /** @type {string[]} */
  const requests = [];
  page.on("request", (request) => requests.push(request.url()));
  return requests;
}

const control = (page, mode) => page.locator(`input[inputmode="${mode}"]`);

test("the start page does not request the custom controls bundle", async ({
  page,
}) => {
  const requests = watchRequests(page);
  await page.goto("/");
  await page.locator("input").first().waitFor();
  // one roundtrip done, the page settled
  await page.waitForTimeout(500);
  expect(requests.filter(isCcBundle)).toEqual([]);
  expect(requests.filter(isCcModule)).toEqual([]);
  // ...and no control is registered: the frontend bundle carries none
  expect(
    await page.evaluate(
      () => /** @type {any} */ (window).sap.ui.require("z2ui5/cc/InputExt") === undefined,
    ),
  ).toBe(true);
});

test("a popup is the first view with a control: the bundle is loaded once, every later view finds it", async ({
  page,
}) => {
  const requests = watchRequests(page);
  /** @type {Record<string, string>[]} */
  const headers = [];
  page.on("response", (response) => {
    if (isCcBundle(response.url())) headers.push(response.headers());
  });
  await watchCsp(page);
  await page.goto(APP);
  await page.getByText("no custom control in this view").waitFor();
  await page.waitForTimeout(300);
  // an app whose view names no control has not asked for them
  expect(requests.filter(isCcBundle)).toEqual([]);

  await page.getByRole("button", { name: "popup with a control" }).click();
  await expect(control(page, "tel")).toBeVisible({ timeout: 30000 });
  await expect(control(page, "tel")).toHaveValue("4711");
  const bundle = requests.filter(isCcBundle);
  expect(bundle).toHaveLength(1);
  // asked for by its version, so the browser may keep it for good
  expect(bundle[0]).toMatch(/[?&]z2ui5-version=[0-9a-f]{16}(&|$)/);
  expect(headers[0]["cache-control"]).toBe(
    "private, max-age=31536000, immutable",
  );
  expect(headers[0]["content-type"]).toContain("application/javascript");

  await page.getByRole("button", { name: "Close" }).click();
  await expect(control(page, "tel")).toBeHidden();

  // a nested view, then the MAIN view itself - the bundle is there
  await page
    .getByRole("button", { name: "nested view with a control" })
    .click();
  await expect(control(page, "decimal")).toBeVisible();
  await page.getByRole("button", { name: "main view with a control" }).click();
  await expect(control(page, "numeric")).toBeVisible();
  await expect(control(page, "numeric")).toHaveValue("4711");

  expect(requests.filter(isCcBundle)).toHaveLength(1);
  // the controls came from the bundle, none was asked for on its own
  expect(requests.filter(isCcModule)).toEqual([]);
  // a file of the page's origin, allowed by script-src 'self'
  expect(await violations(page)).toEqual([]);
});

test("the very first view of an app names a control", async ({ page }) => {
  const requests = watchRequests(page);
  await page.goto(`${APP}&cc=main`);
  await expect(control(page, "numeric")).toBeVisible({ timeout: 30000 });
  await expect(control(page, "numeric")).toHaveValue("4711");
  expect(requests.filter(isCcBundle)).toHaveLength(1);
  expect(requests.filter(isCcModule)).toEqual([]);
});

test("a nested view is the first view with a control", async ({ page }) => {
  const requests = watchRequests(page);
  await page.goto(APP);
  await page.getByText("no custom control in this view").waitFor();
  await page
    .getByRole("button", { name: "nested view with a control" })
    .click();
  await expect(control(page, "decimal")).toBeVisible({ timeout: 30000 });
  expect(requests.filter(isCcBundle)).toHaveLength(1);
  expect(requests.filter(isCcModule)).toEqual([]);
});

test("a bundle that cannot be loaded ends in the error overlay, and says what was missing", async ({
  page,
}) => {
  const requests = watchRequests(page);
  await page.route(
    (url) => isCcBundle(url.href),
    (route) => route.abort(),
  );
  await page.goto(APP);
  await page.getByText("no custom control in this view").waitFor();
  await page.getByRole("button", { name: "popup with a control" }).click();
  await expect(
    page.getByText(/the custom controls this view uses could not be loaded/),
  ).toBeVisible({ timeout: 30000 });
  // the view was not built without its control, and the loader was not
  // sent after the control's file
  await expect(control(page, "tel")).toHaveCount(0);
  expect(requests.filter(isCcModule)).toEqual([]);
});
