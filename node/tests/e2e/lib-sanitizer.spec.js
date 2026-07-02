// @ts-check
const { test, expect } = require("@playwright/test");

// XSS regression tests for Lib.sanitizeMessageDetails, which turns
// backend-supplied HTML into safe markup for Messages.showBox. The function
// needs a real DOMParser/document, so it is exercised in the browser against
// the shipped z2ui5/core/Lib module loaded by the running app.
//
// One page is shared across all cases (the sanitizer is a pure function):
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

function sanitize(/** @type {string} */ html) {
  return page.evaluate(
    (input) =>
      new Promise((resolve) => {
        window["sap"].ui.require(
          ["z2ui5/core/Lib"],
          (/** @type {any} */ Lib) => resolve(Lib.sanitizeMessageDetails(input)),
        );
      }),
    html,
  );
}

test("strips script tags", async () => {
  const result = await sanitize("<script>alert(1)</script>hello");
  expect(result).not.toContain("<script");
  expect(result).not.toContain("alert");
  expect(result).toContain("hello");
});

test("drops elements with event-handler attributes", async () => {
  const result = await sanitize('<img src="x" onerror="alert(1)">click');
  expect(result).not.toContain("onerror");
  expect(result).toBe("click");
});

test("drops javascript: links", async () => {
  const result = await sanitize('<a href="javascript:alert(1)">link</a>');
  expect(result).not.toContain("javascript:");
  expect(result).toBe("link");
});

test("keeps list structure but strips markup inside items", async () => {
  const result = await sanitize("<ul><li>first</li><li><b>second</b></li></ul>");
  expect(result).toBe("<ul><li>first</li><li>second</li></ul>");
});

test("neutralizes injected markup inside a list item", async () => {
  const result = await sanitize(
    '<ul><li><img src="x" onerror="alert(1)">item</li></ul>',
  );
  expect(result).toBe("<ul><li>item</li></ul>");
});

test("does not duplicate nested list items", async () => {
  const result = await sanitize(
    "<ul><li>parent<ul><li>child</li></ul></li></ul>",
  );
  expect(result).toBe("<ul><li>parentchild</li></ul>");
});

test("escapes HTML special characters in plain text", async () => {
  const result = await sanitize("5 < 6 & 7 > 4");
  expect(result).toBe("5 &lt; 6 &amp; 7 &gt; 4");
});
