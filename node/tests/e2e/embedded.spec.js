// @ts-check
const { test, expect } = require("./fixtures");

// The frontend the way @abap2ui5/embed-control runs it: in a page that
// belongs to a HOST app. The host page below loads UI5 itself, the frontend
// through ?z2ui5-bundle (a <script>, as the control does) and creates the
// component with the component data the bundle's z2ui5/embed module hands
// over - embedded: true - plus the app to start and the endpoint. Nothing
// of the backend's own GET page is on it: what these specs pin is what an
// embedded app does to a page it does not own.
//
// Everything evaluated in the page is a function, never a string (see
// two-components.spec.js).

const HOST_PATH = "/z2ui5-embed-host.html";
const ENDPOINT = "/sap/bc/z2ui5";

// The host: UI5 from the build the project pins (the fixture routes it to a
// local tree where there is no CDN), one input of its own, and an area for
// the app. No CSP - the host page is the host's.
function hostHtml(ui5Src, theme) {
  return `<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>host</title>
<script id="sap-ui-bootstrap" src="${ui5Src}"
  data-sap-ui-theme="${theme}" data-sap-ui-libs="sap.m"
  data-sap-ui-compatVersion="edge" data-sap-ui-async="true"></script>
</head>
<body class="sapUiBody">
<input id="hostInput" aria-label="host input">
<div id="host1" style="height: 420px"></div>
</body>
</html>`;
}

// The host page with UI5 booted and the frontend loaded from the backend.
async function openHost(page, ui5Src, ui5Theme) {
  await page.route(
    (url) => url.pathname === HOST_PATH,
    (route) =>
      route.fulfill({
        contentType: "text/html",
        body: hostHtml(ui5Src, ui5Theme || "sap_horizon"),
      }),
  );
  await page.goto(HOST_PATH);
  await page.waitForFunction(() => Boolean(window.sap?.ui?.getCore));
  await page.evaluate(
    () =>
      new Promise((resolve) =>
        window.sap.ui.getCore().attachInit(() => resolve(true)),
      ),
  );
  // once per page, the way the control loads it
  await page.evaluate(
    (endpoint) =>
      new Promise((resolve, reject) => {
        const script = document.createElement("script");
        script.src = `${endpoint}?z2ui5-bundle`;
        script.onload = () => resolve(true);
        script.onerror = () => reject(new Error("no bundle"));
        document.head.appendChild(script);
      }),
    ENDPOINT,
  );
  await page.waitForFunction(() =>
    Boolean(window.sap.ui.require("z2ui5/embed")),
  );
}

// Create the component the way the control does and place it in #host1.
// Resolves with the component id once Component.create has resolved.
// `params` are further startup parameters of the app, one value each.
function startApp(page, app, params = {}) {
  return page.evaluate(
    ([appName, extra, endpoint]) =>
      new Promise((resolve, reject) => {
        const embed = window.sap.ui.require("z2ui5/embed");
        window.sap.ui.require(
          ["sap/ui/core/Component", "sap/ui/core/ComponentContainer"],
          (Component, ComponentContainer) => {
            const startupParameters = { app_start: [appName] };
            for (const [name, value] of Object.entries(extra)) {
              startupParameters[name] = [value];
            }
            Component.create({
              name: "z2ui5",
              manifest: true,
              handleValidation: true,
              componentData: Object.assign({}, embed.componentData, {
                startupParameters,
                endpoint,
              }),
            }).then((component) => {
              new ComponentContainer({
                component,
                lifecycle: "Container",
                height: "100%",
              }).placeAt("host1");
              resolve(component.getId());
            }, reject);
          },
          reject,
        );
      }),
    [app, params, ENDPOINT],
  );
}

// The component by id on every supported release: getComponentById since
// 1.120, the deprecated get( ) before it.
function componentState(page, id) {
  return page.evaluate((wanted) => {
    const Component = window.sap.ui.require("sap/ui/core/Component");
    const component = Component.getComponentById
      ? Component.getComponentById(wanted)
      : Component.get(wanted);
    const state = component?.ctx?.state;
    return {
      rendered: Boolean(state?.oView && state.oResponse && !state.isBusy),
    };
  }, id);
}

// The app's first roundtrip has rendered its view, its follow-up actions
// ran, and a frame went by - everything a start does to the page is done.
async function waitForApp(page, id) {
  await expect
    .poll(async () => (await componentState(page, id)).rendered)
    .toBe(true);
  await page.evaluate(
    () =>
      new Promise((resolve) =>
        requestAnimationFrame(() => setTimeout(() => resolve(true), 50)),
      ),
  );
}

test.describe("an embedded app and the focus", () => {
  test.beforeEach(async ({ page, ui5Src, ui5Theme }) => {
    test.skip(!ui5Src, "the host page boots the pinned UI5 build");
    await openHost(page, ui5Src, ui5Theme);
  });

  // sap.m.App focuses the first input of the first page it renders
  // (NavContainer autoFocus) - on the host's page that is the host's field,
  // while the user may be typing in it.
  test("a starting app leaves the focus in the host's field", async ({
    page,
  }) => {
    const hostInput = page.locator("#hostInput");
    await hostInput.click();
    await page.keyboard.type("ab");
    const id = await startApp(page, "zcl_tst_focus");
    await waitForApp(page, id);
    await expect(page.locator('input[id$="inpDocNum-inner"]')).toBeVisible();
    await expect(hostInput).toBeFocused();
    await page.keyboard.type("cd");
    await expect(hostInput).toHaveValue("abcd");
  });

  // ... and neither does the app's own SET_FOCUS in its first response,
  // the way an app puts the cursor into its first field
  // (zcl_tst_focus, started with focus_on_start)
  test("the app's SET_FOCUS does not take the focus from the host", async ({
    page,
  }) => {
    const hostInput = page.locator("#hostInput");
    await hostInput.click();
    const id = await startApp(page, "zcl_tst_focus", { focus_on_start: "X" });
    await waitForApp(page, id);
    await expect(hostInput).toBeFocused();
  });

  // Once the user works in the app, the app's focus actions work as they do
  // on its own page: the roundtrip of a click inside re-enables the field
  // and focuses it (the focus-after-enable scenario, embedded).
  test("inside the app, SET_FOCUS moves the focus as before", async ({
    page,
  }) => {
    const id = await startApp(page, "zcl_tst_focus");
    await waitForApp(page, id);
    const inner = page.locator('input[id$="inpDocNum-inner"]');
    await page.locator('[id$="btnLock"]').click();
    await expect(inner).toBeDisabled();
    await page.locator('[id$="btnUnlock"]').click();
    await expect(inner).toBeEnabled();
    await expect(inner).toBeFocused();
  });
});
