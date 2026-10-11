// @ts-check
// The developer tools out of the shell: the dialog, its fragment, the
// inspectors, the tabs and the picker are the DEVTOOLS BUNDLE - a second
// generated script the backend serves on ?z2ui5-bundle=devtools
// (z2ui5_cl_ui5f_preload=>get_devtools) - and devtools/DevTools.js loads
// it with a <script> element the first time the tools are opened. A plain
// app start never asks for it; Ctrl+F12 loads it once and opens the
// dialog; and nothing of it needs an inline script or eval - the shipped
// CSP sees no violation (AGENTS.md rule 13). The eager half - the
// facade, the console capture, the roundtrip recorder - stays in the
// shell's inline script, which is what the spec's first request proves.
const { test, expect } = require("./fixtures");

const APP = "/?app_start=z2ui5_cl_ui5_app_hi_world";
const isDevtoolsBundle = (url) => /[?&]z2ui5-bundle=devtools(&|$)/.test(url);

async function watchCsp(page) {
  await page.addInitScript(() => {
    const violations = [];
    Object.defineProperty(window, "__z2ui5CspViolations", {
      value: violations,
    });
    document.addEventListener("securitypolicyviolation", (e) =>
      violations.push(`${e.violatedDirective} ${e.blockedURI}`),
    );
  });
}

const violations = (page) =>
  page.evaluate(() => /** @type {any} */ (window).__z2ui5CspViolations);

test("a plain app start does not request the devtools bundle", async ({
  page,
}) => {
  /** @type {string[]} */
  const requests = [];
  page.on("request", (request) => requests.push(request.url()));
  await page.goto(APP);
  await page.locator("input").first().waitFor();
  // one roundtrip done, the page settled
  await page.waitForTimeout(500);
  expect(requests.filter(isDevtoolsBundle)).toEqual([]);
  // the eager half rides in the page itself: no request for it either
  expect(requests.filter((url) => url.includes("devtools/"))).toEqual([]);
});

test("Ctrl+F12 loads the devtools bundle once and opens the tools, under the shipped CSP", async ({
  page,
}) => {
  /** @type {string[]} */
  const requests = [];
  page.on("request", (request) => requests.push(request.url()));
  await watchCsp(page);
  await page.goto(APP);
  await page.locator("input").first().waitFor();

  await page.keyboard.press("Control+F12");
  const dialog = page.getByRole("dialog", { name: /Developer Tools/ });
  await expect(dialog).toBeVisible({ timeout: 30000 });
  await expect(dialog.getByText("Overview")).toBeVisible();

  const bundle = requests.filter(isDevtoolsBundle);
  expect(bundle).toHaveLength(1);
  // the bundle is a file of the page's origin, allowed by script-src
  // 'self': no inline script, no eval, nothing the CSP has to allow extra
  expect(await violations(page)).toEqual([]);
  // the modules came from the bundle, none of them was asked for on its
  // own (the ICF node would answer such a request with the page)
  expect(
    requests.filter(
      (url) => url.includes("z2ui5/devtools/") && !isDevtoolsBundle(url),
    ),
  ).toEqual([]);

  // close and reopen: the bundle is not asked for again
  await page.keyboard.press("Control+F12");
  await expect(dialog).toBeHidden();
  await page.keyboard.press("Control+F12");
  await expect(dialog).toBeVisible();
  expect(requests.filter(isDevtoolsBundle)).toHaveLength(1);
});
