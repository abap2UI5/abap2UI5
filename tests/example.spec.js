// @ts-check
const { test, expect } = require('@playwright/test');

test('first test', async ({ page }) => {
  await page.goto('/');

  // Expect a title "to contain" a substring.
  await expect(page).toHaveTitle(/abap2UI5/);

});
