// @ts-check
// Loaded via ./fixtures so the default legs boot the PINNED_UI5_SRC of
// ../../playwright.config.js. Not part of the ui5-1.71 leg: 1.71 has no
// future flag and logs no "[FUTURE FATAL]" entries, so there it would pass
// without checking anything.
const { test, expect } = require("./fixtures");

// UI5's strict error handling, as an executable check. From 1.120.2 on, what
// the next major release turns into an exception is logged today with a
// "[FUTURE FATAL]" marker (sap/base/future.js) - and is otherwise easy to
// miss, because it is logged at the level of the original finding, which
// for many of them is WARNING - below ERROR, the default log level of the
// optimized build the CDN serves. SAP's best-practice guide for legacy-free
// code asks for exactly this: run with sap-ui-log-level=WARNING and look for
// the marker. The URL parameter is
// read by every release abap2UI5 supports and changes nothing but logging.
//
// Deliberately NOT sap-ui-xx-future=true: that turns each finding into a
// thrown error somewhere inside the framework, so a test would see whatever
// broke next instead of the finding itself. The log carries the message.
//
// A failure here names a frontend module or a view the framework's own apps
// build. Fix it the 1.71-safe way (AGENTS.md rules 10, 12 and 13) - the
// legacy call usually exists because 1.71 has no successor yet, and then
// the fix goes through core/Env.js, not around it.

const LOG_LEVEL = "sap-ui-log-level=WARNING";

/** Collects every console line carrying the future marker. */
function collectFutureFatal(page) {
  const found = [];
  page.on("console", (msg) => {
    if (msg.text().includes("[FUTURE FATAL]")) found.push(msg.text());
  });
  return found;
}

test("the start app boots without a FUTURE FATAL", async ({ page }) => {
  const found = collectFutureFatal(page);
  const responsePromise = page.waitForResponse(
    (r) => r.request().method() === "POST",
  );
  await page.goto(`/?${LOG_LEVEL}`);
  await responsePromise;
  await page.locator("input").first().waitFor();

  expect(found).toEqual([]);
});

test("an event roundtrip with a message box runs without a FUTURE FATAL", async ({
  page,
}) => {
  const found = collectFutureFatal(page);
  await page.goto(`/?app_start=z2ui5_cl_ui5_app_hi_world&${LOG_LEVEL}`);

  const input = page.locator("input").first();
  await input.waitFor();
  await input.fill("Future");
  await page.getByRole("button", { name: "Post" }).click();
  await expect(page.getByText("Your name is Future")).toBeVisible();

  expect(found).toEqual([]);
});
