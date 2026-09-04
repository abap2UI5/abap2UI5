// @ts-check
const { test, expect } = require("@playwright/test");

// XSS regression tests for Lib.sanitizeMessageDetails, which turns
// backend-supplied HTML into safe markup for the message-box display hook
// in core/actions/ControlCall.js. The function
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

test("drops a script inside a list item with its body", async () => {
  // a leading <script> is parked in <head> by the HTML parser and never
  // reaches the walk; one INSIDE the details does, and dropping only its tag
  // would print its source as text
  const result = await sanitize("<ul><li>a<script>alert(1)</script>b</li></ul>");
  expect(result).toBe("<ul><li>ab</li></ul>");
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

test("keeps a nested list nested", async () => {
  // The details are shown unfolded (ControlCall.expandBoxDetails), so this
  // IS the content of the box. Folding a subtree into its parent's line -
  // which taking each top-level item's textContent used to do - turned a
  // rendered structure into one run-on sentence.
  const result = await sanitize(
    "<ul><li>parent<ul><li>child</li></ul></li></ul>",
  );
  expect(result).toBe("<ul><li>parent<ul><li>child</li></ul></li></ul>");
});

test("keeps the tags a rendered data box is built from", async () => {
  // ul/ol/li/strong/em/p are what ui5_data_box_format( ) emits and what
  // sap.m.FormattedText keeps when it renders the result
  const result = await sanitize(
    "<ol><li><strong>NAME</strong>: <em>value</em></li></ol>",
  );
  expect(result).toBe("<ol><li><strong>NAME</strong>: <em>value</em></li></ol>");
});

test("an element that is not whitelisted loses its tag, not its text", async () => {
  const result = await sanitize("<div><span>kept</span></div>");
  expect(result).toBe("kept");
});

test("escapes HTML special characters in plain text", async () => {
  const result = await sanitize("5 < 6 & 7 > 4");
  expect(result).toBe("5 &lt; 6 &amp; 7 &gt; 4");
});
