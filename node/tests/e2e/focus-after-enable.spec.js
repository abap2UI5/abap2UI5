// @ts-check
const { test, expect } = require("@playwright/test");

// Reproduces the samples app 443 scenario against the transpiled backend:
// ONE roundtrip re-enables a disabled input via its `enabled` binding AND
// sends the SET_FOCUS follow-up action. The follow-up actions run
// synchronously after the model update while UI5 re-renders the invalidated
// control only asynchronously, so the first focus attempt hits the OLD,
// still-disabled DOM - which the browser silently ignores. evSetFocus
// (app/webapp/core/FrontendAction.js) therefore re-applies the focus once
// after the control's pending re-render; this spec pins that down in a real
// browser, including the caret selection travelling with it.
//
// The fixture app lives in node/srv/zcl_tst_focus.clas.abap and is copied
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

test("SET_FOCUS lands in a field the same roundtrip re-enabled", async ({
  page,
}) => {
  await mirrorCdn(page);

  await page.goto("/?app_start=zcl_tst_focus");
  const inner = page.locator('input[id$="inpDocNum-inner"]');
  await expect(inner).toBeEnabled({ timeout: 30000 });
  await expect(inner).toHaveValue("86801398");

  // Step 1: lock the field via binding (view_model_update roundtrip)
  await page.locator('[id$="btnLock"]').click();
  await expect(inner).toBeDisabled();

  // Step 2: ONE roundtrip re-enables the field AND sends SET_FOCUS with a
  // caret selection of characters 0-4
  await page.locator('[id$="btnUnlock"]').click();
  await expect(inner).toBeEnabled();
  await expect(inner).toBeFocused();
  await expect
    .poll(async () =>
      inner.evaluate((el) => [
        /** @type {HTMLInputElement} */ (el).selectionStart,
        /** @type {HTMLInputElement} */ (el).selectionEnd,
      ]),
    )
    .toEqual([0, 4]);
});

test("reference: SET_FOCUS without an enabled change works directly", async ({
  page,
}) => {
  await mirrorCdn(page);

  await page.goto("/?app_start=zcl_tst_focus");
  const inner = page.locator('input[id$="inpDocNum-inner"]');
  await expect(inner).toBeEnabled({ timeout: 30000 });

  // no LOCK first: the DOM input is already enabled, so the focus must land
  // on the first attempt - the retry path stays idle
  await page.locator('[id$="btnUnlock"]').click();
  await expect(inner).toBeFocused();
  await expect
    .poll(async () =>
      inner.evaluate((el) => [
        /** @type {HTMLInputElement} */ (el).selectionStart,
        /** @type {HTMLInputElement} */ (el).selectionEnd,
      ]),
    )
    .toEqual([0, 4]);
});
