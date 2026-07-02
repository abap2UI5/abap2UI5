// @ts-check
const { test, expect } = require("@playwright/test");

// Exercises the fatal-error overlay (core/ErrorView) in a real browser:
// accessibility semantics, focus management and the optional Retry action.

/** @param {import('@playwright/test').Page} page */
async function showErrorView(page, withRetry) {
  await page.goto("/");
  await page.waitForFunction(() => !!window["sap"]?.ui?.require);
  await page.evaluate(
    (retry) =>
      new Promise((resolve) => {
        window["sap"].ui.require(
          ["z2ui5/core/ErrorView"],
          (/** @type {any} */ ErrorView) => {
            const options = retry
              ? { onRetry: () => (window["__retried"] = true) }
              : undefined;
            ErrorView.show("something broke", undefined, options);
            resolve(undefined);
          },
        );
      }),
    withRetry,
  );
}

test("is an accessible alertdialog with focus on the primary action", async ({
  page,
}) => {
  await showErrorView(page, false);

  const dialog = page.locator("#serverErrorContainer");
  await expect(dialog).toHaveAttribute("role", "alertdialog");
  await expect(dialog).toHaveAttribute("aria-modal", "true");
  await expect(dialog).toHaveAttribute("aria-labelledby", "serverErrorTitle");
  await expect(
    page.getByText("Application Error - Please Restart The App"),
  ).toBeVisible();
  await expect(page.getByRole("button", { name: "Refresh" })).toBeFocused();
});

test("offers no Retry action for client-side fatal errors", async ({
  page,
}) => {
  await showErrorView(page, false);

  await expect(page.getByRole("button", { name: "Retry" })).toHaveCount(0);
  await expect(page.getByRole("button", { name: "Refresh" })).toBeVisible();
  await expect(page.getByRole("button", { name: "Logout" })).toBeVisible();
});

test("Retry removes the overlay and runs the retry handler", async ({
  page,
}) => {
  await showErrorView(page, true);

  const retryButton = page.getByRole("button", { name: "Retry" });
  await expect(retryButton).toBeFocused();
  await retryButton.click();

  await expect(page.locator("#serverErrorContainer")).toHaveCount(0);
  expect(await page.evaluate(() => window["__retried"])).toBe(true);
});

test("keeps keyboard focus inside the overlay", async ({ page }) => {
  await showErrorView(page, false);

  // Focus starts on Refresh; Tab moves to Logout; another Tab must wrap
  // around to the first button instead of escaping into the page behind.
  await page.keyboard.press("Tab");
  await expect(page.getByRole("button", { name: "Logout" })).toBeFocused();
  await page.keyboard.press("Tab");
  await expect(page.getByRole("button", { name: "Refresh" })).toBeFocused();
});
