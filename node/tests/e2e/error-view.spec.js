// @ts-check
const { test, expect } = require("@playwright/test");

// Exercises the fatal-error overlay (core/ErrorView) in a real browser:
// accessibility semantics, focus management and the optional Retry action.
//
// One page is shared across the cases and the overlay is rebuilt per test:
// loading UI5 from the CDN once per test made the suite slow and
// timeout-flaky in CI.

/** @type {import('@playwright/test').Page} */
let page;

test.beforeAll(async ({ browser }) => {
  page = await browser.newPage();
  await page.goto("http://localhost:3000/");
  // window.z2ui5 is created by onInitComponent AFTER sap.ui.require.preload
  // registered the embedded z2ui5/* modules - waiting on sap.ui.require
  // alone races the preload and the require below would then try (and fail)
  // to fetch the module from the server.
  await page.waitForFunction(() => !!window["z2ui5"]);
});

test.afterAll(async () => {
  await page.close();
});

async function showErrorView(/** @type {boolean} */ withRetry) {
  await page.evaluate(
    (retry) =>
      new Promise((resolve) => {
        document.getElementById("serverErrorContainer")?.remove();
        window["__retried"] = false;
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

test("is an accessible alertdialog with focus on the primary action", async () => {
  await showErrorView(false);

  const dialog = page.locator("#serverErrorContainer");
  await expect(dialog).toHaveAttribute("role", "alertdialog");
  await expect(dialog).toHaveAttribute("aria-modal", "true");
  await expect(dialog).toHaveAttribute("aria-labelledby", "serverErrorTitle");
  await expect(
    page.getByText("Application Error - Please Restart The App"),
  ).toBeVisible();
  await expect(page.getByRole("button", { name: "Refresh" })).toBeFocused();
});

test("offers no Retry action for client-side fatal errors", async () => {
  await showErrorView(false);

  await expect(page.getByRole("button", { name: "Retry" })).toHaveCount(0);
  await expect(page.getByRole("button", { name: "Refresh" })).toBeVisible();
  await expect(page.getByRole("button", { name: "Logout" })).toBeVisible();
});

test("Retry removes the overlay and runs the retry handler", async () => {
  await showErrorView(true);

  const retryButton = page.getByRole("button", { name: "Retry" });
  await expect(retryButton).toBeFocused();
  await retryButton.click();

  await expect(page.locator("#serverErrorContainer")).toHaveCount(0);
  expect(await page.evaluate(() => window["__retried"])).toBe(true);
});

test("keeps keyboard focus inside the overlay", async () => {
  await showErrorView(false);

  // Focus starts on Refresh; Tab moves to Logout; another Tab must wrap
  // around to the first button instead of escaping into the page behind.
  await page.keyboard.press("Tab");
  await expect(page.getByRole("button", { name: "Logout" })).toBeFocused();
  await page.keyboard.press("Tab");
  await expect(page.getByRole("button", { name: "Refresh" })).toBeFocused();
});
