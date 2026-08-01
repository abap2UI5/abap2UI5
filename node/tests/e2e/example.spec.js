// @ts-check
const { test, expect } = require("@playwright/test");

test("the app boots and sets the document title", async ({ page }) => {
  await page.goto("/");

  await expect(page).toHaveTitle(/abap2UI5/);
});
