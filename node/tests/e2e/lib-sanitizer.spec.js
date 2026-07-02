// @ts-check
const { test, expect } = require("@playwright/test");

// XSS regression tests for Lib.sanitizeMessageDetails, which turns
// backend-supplied HTML into safe markup for Messages.showBox. The function
// needs a real DOMParser/document, so it is exercised in the browser against
// the shipped z2ui5/core/Lib module loaded by the running app.

/** @param {import('@playwright/test').Page} page */
async function makeSanitize(page) {
  await page.goto("/");
  await page.waitForFunction(() => !!window["sap"]?.ui?.require);
  return (/** @type {string} */ html) =>
    page.evaluate(
      (input) =>
        new Promise((resolve) => {
          window["sap"].ui.require(["z2ui5/core/Lib"], (/** @type {any} */ Lib) =>
            resolve(Lib.sanitizeMessageDetails(input)),
          );
        }),
      html,
    );
}

test("strips script tags", async ({ page }) => {
  const sanitize = await makeSanitize(page);
  const result = await sanitize("<script>alert(1)</script>hello");
  expect(result).not.toContain("<script");
  expect(result).not.toContain("alert");
  expect(result).toContain("hello");
});

test("drops elements with event-handler attributes", async ({ page }) => {
  const sanitize = await makeSanitize(page);
  const result = await sanitize('<img src="x" onerror="alert(1)">click');
  expect(result).not.toContain("onerror");
  expect(result).toBe("click");
});

test("drops javascript: links", async ({ page }) => {
  const sanitize = await makeSanitize(page);
  const result = await sanitize('<a href="javascript:alert(1)">link</a>');
  expect(result).not.toContain("javascript:");
  expect(result).toBe("link");
});

test("keeps list structure but strips markup inside items", async ({
  page,
}) => {
  const sanitize = await makeSanitize(page);
  const result = await sanitize("<ul><li>first</li><li><b>second</b></li></ul>");
  expect(result).toBe("<ul><li>first</li><li>second</li></ul>");
});

test("neutralizes injected markup inside a list item", async ({ page }) => {
  const sanitize = await makeSanitize(page);
  const result = await sanitize(
    '<ul><li><img src="x" onerror="alert(1)">item</li></ul>',
  );
  expect(result).toBe("<ul><li>item</li></ul>");
});

test("does not duplicate nested list items", async ({ page }) => {
  const sanitize = await makeSanitize(page);
  const result = await sanitize(
    "<ul><li>parent<ul><li>child</li></ul></li></ul>",
  );
  expect(result).toBe("<ul><li>parentchild</li></ul>");
});

test("escapes HTML special characters in plain text", async ({ page }) => {
  const sanitize = await makeSanitize(page);
  const result = await sanitize("5 < 6 & 7 > 4");
  expect(result).toBe("5 &lt; 6 &amp; 7 &gt; 4");
});
