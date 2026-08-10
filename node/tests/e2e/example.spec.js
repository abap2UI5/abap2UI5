// @ts-check
const { test, expect } = require("./fixtures");

test("the app boots and sets the document title", async ({ page }) => {
  await page.goto("/");

  await expect(page).toHaveTitle(/abap2UI5/);
});

test("boots the exact UI5 build the project pins", async ({ page, ui5Src }) => {
  test.skip(!ui5Src, "only meaningful for pinned-UI5 projects");

  await page.goto("/");

  // Proves the fixture's bootstrap rewrite actually took effect - without
  // this assertion a broken rewrite would silently run the evergreen CDN
  // build and the pinned project would gate nothing.
  await page.waitForFunction(() => Boolean(window.sap?.ui?.version));
  const version = await page.evaluate(() => window.sap.ui.version);
  const pinned = /\/(\d+\.\d+\.\d+)\//.exec(ui5Src)?.[1];
  expect(version).toBe(pinned);
});
