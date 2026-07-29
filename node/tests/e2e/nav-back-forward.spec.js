// @ts-check
const { test, expect } = require("@playwright/test");

// Reproduces the browser Back/Forward cycle over a FRESH-mode routed app
// (the z2ui5_cl_demo_app_468 / 469 scenario) against the transpiled backend:
// hub app with set_nav_routing(fresh) -> nav_app_call(detail) -> browser
// Back (hub restarts fresh) -> browser Forward (detail must come back).
//
// Regression coverage for the doubled route slash: hasher (the HashChanger's
// engine) prepends a "/" of its own, so slash-prefixed routes ended up as
// "#//app/X" in the URL. The frontend never noticed (reads come back
// trimmed), but the backend parses window.location.hash raw - the route no
// longer matched, every Back/Forward restore fell back to the "?app_start="
// boot query, and pressing Forward appeared to do nothing (the boot app was
// rendered again instead of the routed one).
//
// The fixture apps live in node/srv/zcl_tst_nav_*.clas.abap and are copied
// into the transpiled backend by `npm run auto_transpile`.

// Sandboxed environments without a route to the UI5 CDN can serve the
// framework from a local mirror (e.g. `ui5 serve`) by setting
// UI5_MIRROR_URL=http://localhost:8081 - requests to the CDN are then
// fulfilled locally, with the cachebuster segments stripped. A custom
// browser build can be picked via PW_CHROMIUM_PATH. CI sets neither and
// runs against the real CDN with the pinned Playwright browsers.
const MIRROR = process.env.UI5_MIRROR_URL;
if (process.env.PW_CHROMIUM_PATH) {
  test.use({
    launchOptions: { executablePath: process.env.PW_CHROMIUM_PATH },
  });
}

async function mirrorCdn(page) {
  if (!MIRROR) return;
  await page.route("https://sdk.openui5.org/**", async (route) => {
    const url = new URL(route.request().url());
    const path = url.pathname
      .replace(/\/sap-ui-cachebuster/g, "")
      .replace(/\/~[^/]*~[a-zA-Z0-9]*/g, "");
    try {
      const resp = await route.fetch({ url: `${MIRROR}${path}` });
      await route.fulfill({ response: resp });
    } catch (e) {
      await route.abort();
    }
  });
}

test("browser Back then Forward across a FRESH-mode nav_app_call", async ({
  page,
}) => {
  await mirrorCdn(page);

  await page.goto("/?app_start=zcl_tst_nav_hub");
  await expect(page.getByText("hub-marker")).toBeVisible({ timeout: 30000 });
  // the routed URL carries the canonical single-slash route
  expect(page.url()).toContain("#/app/ZCL_TST_NAV_HUB");
  expect(page.url()).not.toContain("#//");

  // forward navigation via backend nav_app_call pushes the detail route
  await page.getByRole("button", { name: "go-detail" }).click();
  await expect(page.getByText("detail-marker")).toBeVisible();
  expect(page.url()).toContain("#/app/ZCL_TST_NAV_DETAIL");
  expect(page.url()).not.toContain("#//");

  // browser Back -> the hub restarts fresh (FRESH mode routes by class only)
  await page.goBack();
  await expect(page.getByText("hub-marker")).toBeVisible();

  // browser Forward -> the detail app must be restored from its route
  await page.goForward();
  await expect(page.getByText("detail-marker")).toBeVisible();
});

test("browser Back then Forward across a KEEP-mode nav_app_call", async ({
  page,
}) => {
  await mirrorCdn(page);

  await page.goto("/?app_start=zcl_tst_nav_hub_keep");
  await expect(page.getByText("hubkeep-marker")).toBeVisible({
    timeout: 30000,
  });
  // KEEP routes carry the app-state draft: /app/<CLASS>/<DRAFT>
  expect(page.url()).toMatch(/#\/app\/ZCL_TST_NAV_HUB_KEEP\/[0-9A-F]{32}/);

  // put some state in, so Back has something to restore
  await page.getByRole("button", { name: /increment/ }).click();
  await expect(page.getByRole("button", { name: "increment (1)" })).toBeVisible();

  await page.getByRole("button", { name: "go-detail" }).click();
  await expect(page.getByText("detail-marker")).toBeVisible();
  expect(page.url()).toMatch(/#\/app\/ZCL_TST_NAV_DETAIL\/[0-9A-F]{32}/);

  // browser Back -> the hub comes back EXACTLY as the user left it
  await page.goBack();
  await expect(page.getByText("hubkeep-marker")).toBeVisible();
  await expect(page.getByRole("button", { name: "increment (1)" })).toBeVisible();

  // browser Forward -> the detail app must be restored from its draft route
  await page.goForward();
  await expect(page.getByText("detail-marker")).toBeVisible();
});
