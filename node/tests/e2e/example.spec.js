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

test("boots under the shipped CSP without a violation", async ({ page }) => {
  // The page's one inline script runs by its hash alone - the default
  // script-src carries no 'unsafe-inline' (z2ui5_cl_ui5_http_handler=>
  // _csp_add_script_hash). A hash that stops matching the served script
  // keeps the component from ever starting, and anything the frontend
  // starts to need inline - a handler attribute, an injected <script>, a
  // javascript: URL - is refused. Both surface here, named, instead of as
  // a blank page in the next spec.
  await page.addInitScript(() => {
    const violations = [];
    Object.defineProperty(window, "__z2ui5CspViolations", {
      value: violations,
    });
    document.addEventListener("securitypolicyviolation", (e) =>
      violations.push(`${e.violatedDirective} ${e.blockedURI}`),
    );
  });
  await page.goto("/?app_start=z2ui5_cl_ui5_app_hi_world");

  // the backend-built view rendered - the component started and ran a
  // roundtrip, so everything that boots is covered
  await page.locator("input").first().waitFor();
  const violations = await page.evaluate(
    () => /** @type {any} */ (window).__z2ui5CspViolations,
  );
  expect(violations).toEqual([]);
});
