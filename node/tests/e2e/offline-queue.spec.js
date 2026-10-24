// @ts-check
const { test, expect } = require("@playwright/test");

// The offline queue (app/webapp/core/Offline.js, cs_event-offline_queue)
// against the transpiled backend: an event the app lets queue waits in the
// browser while the backend cannot be reached and is sent once it can, in
// order, each on the draft the previous one left. Every other event fails as
// it always did. The page itself still needs the network to load - what is
// tested is a page that was loaded and then lost its network.
//
// The fixture app lives in node/srv/zcl_tst_offline.clas.abap: SAVE appends
// the input to `saved` and empties the field; SAVE is the one event it lets
// queue, with the toast "Saved offline - &1 waiting".

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

async function start(page) {
  await mirrorCdn(page);
  await page.goto("/?app_start=zcl_tst_offline");
  const input = page.locator('input[id$="inpValue-inner"]');
  await expect(input).toBeEditable({ timeout: 30000 });
  return input;
}

async function save(page, input, value) {
  await input.fill(value);
  await page.locator('[id$="btnSave"]').click();
}

const saved = (page) => page.locator('[id$="txtSaved"]');
const toast = (page) => page.locator(".sapMMessageToast");
const overlay = (page) =>
  page.getByRole("alertdialog", { name: "Application Error" });

test("a queued event waits while offline and is sent in order once online", async ({
  page,
  context,
}) => {
  const input = await start(page);
  await save(page, input, "A");
  await expect(saved(page)).toHaveText("A");

  await context.setOffline(true);
  await save(page, input, "B");
  await expect(toast(page).last()).toHaveText("Saved offline - 1 waiting");
  await save(page, input, "C");
  await expect(toast(page).last()).toHaveText("Saved offline - 2 waiting");
  await expect(overlay(page)).toHaveCount(0);
  // nothing reached the backend yet
  await expect(saved(page)).toHaveText("A");

  await context.setOffline(false);
  await expect(saved(page)).toHaveText("A,B,C", { timeout: 30000 });
  await expect(input).toHaveValue("");
  expect(
    await page.evaluate(() =>
      Object.keys(localStorage).filter((k) => k.startsWith("z2ui5-offline:")),
    ),
  ).toEqual([]);
});

test("an event the app did not name fails as before, with Retry", async ({
  page,
  context,
}) => {
  await start(page);
  await context.setOffline(true);
  await page.locator('[id$="btnOther"]').click();
  await expect(overlay(page)).toBeVisible({ timeout: 30000 });
  await expect(page.getByRole("button", { name: "Retry" })).toBeVisible();
  expect(
    await page.evaluate(() =>
      Object.keys(localStorage).filter((k) => k.startsWith("z2ui5-offline:")),
    ),
  ).toEqual([]);
});

test("what was queued survives a reload and is sent by the next start", async ({
  page,
}) => {
  const input = await start(page);
  // the backend unreachable while the browser still reports a network, so
  // no "online" event comes to send the queue from this page: the request
  // fails the way an unreachable host fails, with fetch's TypeError
  const unreachable = (route) =>
    route.request().method() === "POST" ? route.abort() : route.continue();
  await page.route("**/*", unreachable);
  await save(page, input, "B");
  await expect(toast(page).last()).toHaveText("Saved offline - 1 waiting");

  // the backend back, and the tab reloaded: the new start of the app sends
  // what the old page kept
  await page.unroute("**/*", unreachable);
  await page.reload();
  await expect(saved(page)).toHaveText("B", { timeout: 30000 });
});
