// @ts-check
// The community controls (abap2UI5-addons/custom-controls, the namespace
// z2ui5_cci) out of the node instead of a BSP: the addon generates its
// modules into classes, the backend serves them on
// ?z2ui5-bundle=cci&z2ui5-name=<names>
// (z2ui5_cl_ui5_http_handler=>_http_get_cci), and core/CustomControls.js
// loads, before a view is built, the controls that view names and no
// others - one request per view, nothing for a control asked for before.
// A node that does not serve them (the addon is not installed, or is one
// that still ships its BSP) costs one request per page, after which the
// UI5 loader is left to find the controls where it always did.
//
// The addon's class is stood in for by node/srv/z2ui5_cl_cci_bundle (two
// controls, one of them with a module it depends on, a script and a
// stylesheet); the app is node/srv/zcl_tst_cci. A control writes what it is
// onto its DOM node (data-cci), which a plain sap.m.Text does not have.
const { test, expect } = require("./fixtures");
const { appSettled } = require("./pageComponent");

const APP = "/?app_start=zcl_tst_cci";
const isCci = (url) => /[?&]z2ui5-bundle=cci(&|$)/.test(url);
const names = (url) => new URL(url).searchParams.get("z2ui5-name");
// a control asked of the loader as a file of the BSP's resource root
const isBspModule = (url) => /z2ui5_cci\/cc\/\w+\.js/.test(url);

function watchRequests(page) {
  /** @type {string[]} */
  const requests = [];
  page.on("request", (request) => requests.push(request.url()));
  return requests;
}

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

const control = (page, mark) => page.locator(`[data-cci="${mark}"]`);

test("a view loads the community controls it names, by control, and each of them once", async ({
  page,
}) => {
  const requests = watchRequests(page);
  /** @type {Record<string, string>[]} */
  const headers = [];
  page.on("response", (response) => {
    if (isCci(response.url())) headers.push(response.headers());
  });
  await watchCsp(page);
  await page.goto(APP);
  await page.getByText("no community control in this view").waitFor();
  await appSettled(page);
  // a view that names none has asked for none
  expect(requests.filter(isCci)).toEqual([]);

  await page
    .getByRole("button", { name: "main view with the first control" })
    .click();
  // the control, and the module it depends on, which nobody named
  await expect(control(page, "helper")).toBeVisible({ timeout: 30000 });
  let asked = requests.filter(isCci);
  expect(asked.map(names)).toEqual(["TstMark"]);
  // not asked for by a version - the frontend does not know the addon's -
  // so it is revalidated under the addon's digest
  expect(asked[0]).not.toMatch(/[?&]z2ui5-version=/);
  expect(headers[0]["cache-control"]).toBe("private, no-cache");
  expect(headers[0].etag).toBeTruthy();
  expect(headers[0]["content-type"]).toContain("application/javascript");

  // the second control in a popup: asked for alone
  await page
    .getByRole("button", { name: "popup with the second control" })
    .click();
  await expect(control(page, "other")).toBeVisible({ timeout: 30000 });
  await page.getByRole("button", { name: "Close" }).click();
  await expect(control(page, "other")).toBeHidden();
  asked = requests.filter(isCci);
  expect(asked.map(names)).toEqual(["TstMark", "TstOther"]);

  // both in one view: nothing left to ask for
  await page
    .getByRole("button", { name: "main view with both controls" })
    .click();
  await expect(control(page, "other")).toBeVisible();
  await expect(control(page, "helper")).toBeVisible();
  expect(requests.filter(isCci)).toHaveLength(2);

  // every module came from the node, none was asked of the BSP
  expect(requests.filter(isBspModule)).toEqual([]);
  // files of the page's origin, allowed by script-src 'self'
  expect(await violations(page)).toEqual([]);
});

test("a view that names two controls asks for both in one request", async ({
  page,
}) => {
  const requests = watchRequests(page);
  await page.goto(APP);
  await page.getByText("no community control in this view").waitFor();
  await page
    .getByRole("button", { name: "main view with both controls" })
    .click();
  await expect(control(page, "other")).toBeVisible({ timeout: 30000 });
  await expect(control(page, "helper")).toBeVisible();
  expect(requests.filter(isCci).map(names)).toEqual(["TstMark,TstOther"]);
});

test("a library file is served by its digest, a stylesheet as CSS, an unknown name as 404", async ({
  page,
}) => {
  await page.goto(APP);
  await page.getByText("no community control in this view").waitFor();
  const get = (query) =>
    page.evaluate(async (q) => {
      const response = await fetch(`${window.location.pathname}?${q}`);
      return {
        status: response.status,
        type: response.headers.get("content-type"),
        cache: response.headers.get("cache-control"),
        body: await response.text(),
      };
    }, query);

  // the way the addon asks: URLSearchParams encodes the slash
  const script = await get(
    "z2ui5-bundle=cci&z2ui5-name=lib%2Ftst.js&z2ui5-version=00000000000000a1",
  );
  expect(script.status).toBe(200);
  expect(script.type).toContain("application/javascript");
  expect(script.cache).toBe("private, max-age=31536000, immutable");
  expect(script.body).toBe('window.z2ui5CciTstLib="script";');

  const style = await get(
    "z2ui5-bundle=cci&z2ui5-name=lib/tst.css&z2ui5-version=00000000000000a2",
  );
  expect(style.status).toBe(200);
  expect(style.type).toContain("text/css");
  expect(style.cache).toBe("private, max-age=31536000, immutable");
  expect(style.body).toBe(".z2ui5CciTst{color:rgb(1,2,3)}");

  // another digest than the file's: answered, and revalidated
  const stale = await get(
    "z2ui5-bundle=cci&z2ui5-name=lib/tst.js&z2ui5-version=0000000000000000",
  );
  expect(stale.status).toBe(200);
  expect(stale.cache).toBe("private, no-cache");

  const unknown = await get("z2ui5-bundle=cci&z2ui5-name=lib/no-such.js");
  expect(unknown.status).toBe(404);
  expect(unknown.type).toContain("text/plain");
  expect(unknown.body).not.toContain("<!DOCTYPE");
});

test("a node that does not serve the controls is asked once per page, then the loader is", async ({
  page,
}) => {
  const requests = watchRequests(page);
  // what a backend without the addon's class answers
  await page.route(
    (url) => isCci(url.href),
    (route) => route.fulfill({ status: 404, body: "Not Found" }),
  );
  await page.goto(APP);
  await page.getByText("no community control in this view").waitFor();
  await page
    .getByRole("button", { name: "main view with the first control" })
    .click();
  // the view is built the way it always was: the loader goes after the
  // control's file under the resource root of the BSP
  await expect
    .poll(() => requests.filter(isBspModule).length, { timeout: 30000 })
    .toBeGreaterThan(0);
  expect(requests.filter(isCci)).toHaveLength(1);
});
