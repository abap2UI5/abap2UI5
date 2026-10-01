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
// the service node as the SYSTEM has it - what the dev server answers on
const ENDPOINT = "/sap/bc/z2ui5";
// A proxy that puts the system under a path prefix of its own - the
// destination proxy of SAP Build Work Zone (/dynamic_dest/<name>/...), an
// approuter route: the page reaches the node as <prefix>/sap/bc/z2ui5, the
// system sees /sap/bc/z2ui5. Played by proxyWithPrefix below.
const PROXY_PREFIX = "/dynamic_dest/ABAP2UI5";
const CCI_ROOT = "/sap/bc/ui5_ui5/sap/z2ui5_cci";
const CCC_ROOT = "/sap/bc/ui5_ui5/sap/z2ui5_ccc";

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

// The prefixing proxy: every request under the prefix - the bundle, the
// roundtrips, a module of a sibling BSP - reaches the dev server without it,
// the way the proxy forwards it to the system.
async function proxyWithPrefix(page) {
  await page.route(
    (url) => url.pathname.startsWith(`${PROXY_PREFIX}/`),
    (route) => {
      const url = new URL(route.request().url());
      url.pathname = url.pathname.slice(PROXY_PREFIX.length);
      return route.continue({ url: url.href });
    },
  );
}

// The host page with UI5 booted and the frontend loaded from the backend -
// from `endpoint`, the node as the PAGE reaches it.
async function openHost(page, ui5Src, ui5Theme, endpoint = ENDPOINT) {
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
    endpoint,
  );
  await page.waitForFunction(() =>
    Boolean(window.sap.ui.require("z2ui5/embed")),
  );
}

// Create the component the way the control does and place it in #host1.
// Resolves with the component id once Component.create has resolved.
// `params` are further startup parameters of the app, one value each;
// `endpoint` is what the control passes as the backend URL.
function startApp(page, app, params = {}, endpoint = ENDPOINT) {
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
    [app, params, endpoint],
  );
}

// Where the loader would fetch a module of each sibling BSP from - the
// path on the page's origin, as the page resolves it.
function resourceRootPaths(page) {
  return page.evaluate(() => {
    const path = (name) =>
      new URL(window.sap.ui.require.toUrl(name), window.location.href)
        .pathname;
    return {
      cci: path("z2ui5_cci/Control.js"),
      ccc: path("z2ui5_ccc/Control.js"),
    };
  });
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

// UI5 1.x exports every class it creates as a global - the frontend's own
// built a window.z2ui5 (Component, controller, devtools, a cc.* per custom
// control) on every page it ran on, the global abap2UI5 removed on purpose.
// A host's window is not the frontend's: an embedded component takes them
// off again (core/Env.js ownClass).
test.describe("an embedded app and the host's window", () => {
  test("the frontend leaves no z2ui5 global on the host's page", async ({
    page,
    ui5Src,
    ui5Theme,
  }) => {
    test.skip(!ui5Src, "the host page boots the pinned UI5 build");
    await openHost(page, ui5Src, ui5Theme);
    const id = await startApp(page, "z2ui5_cl_ui5_app_hi_world");
    await waitForApp(page, id);
    expect(await page.evaluate(() => typeof window["z2ui5"])).toBe(
      "undefined",
    );
  });

  test("a z2ui5 object of the host's own keeps what it held, and only that", async ({
    page,
    ui5Src,
    ui5Theme,
  }) => {
    test.skip(!ui5Src, "the host page boots the pinned UI5 build");
    await page.addInitScript(() => {
      window["z2ui5"] = { hostData: 1 };
    });
    await openHost(page, ui5Src, ui5Theme);
    const id = await startApp(page, "z2ui5_cl_ui5_app_hi_world");
    await waitForApp(page, id);
    expect(await page.evaluate(() => JSON.stringify(window["z2ui5"]))).toBe(
      '{"hostData":1}',
    );
  });
});

// The custom controls (z2ui5_cci) and the customer's own frontend artefacts
// (z2ui5_ccc) live in BSPs next to the frontend, and the bundle hands their
// roots over as the SYSTEM's absolute paths. A page that reaches the node
// through a proxy with a path prefix of its own requested them on its own
// origin, where nothing is - an embedded app naming a control of either BSP
// failed to load it. The bundle now says which path the node has on the
// system (nodePath), and Component.init puts what the endpoint has in front
// of it - the proxy's prefix - in front of both roots.
test.describe("an embedded app and the sibling BSPs", () => {
  test.beforeEach(({ ui5Src }) => {
    test.skip(!ui5Src, "the host page boots the pinned UI5 build");
  });

  test("behind a prefixing proxy the roots carry the proxy's prefix", async ({
    page,
    ui5Src,
    ui5Theme,
  }) => {
    await proxyWithPrefix(page);
    const endpoint = `${PROXY_PREFIX}${ENDPOINT}`;
    await openHost(page, ui5Src, ui5Theme, endpoint);
    // the bundle came through the proxy and names the node's own path
    expect(
      await page.evaluate(
        () => window.sap.ui.require("z2ui5/embed").componentData.nodePath,
      ),
    ).toBe(ENDPOINT);
    // ... and the app runs through the proxy: its roundtrips go to the
    // prefixed endpoint
    const id = await startApp(page, "z2ui5_cl_ui5_app_hi_world", {}, endpoint);
    await waitForApp(page, id);
    expect(await resourceRootPaths(page)).toEqual({
      cci: `${PROXY_PREFIX}${CCI_ROOT}/Control.js`,
      ccc: `${PROXY_PREFIX}${CCC_ROOT}/Control.js`,
    });
  });

  test("on the node's own path the roots are the system's, as before", async ({
    page,
    ui5Src,
    ui5Theme,
  }) => {
    await openHost(page, ui5Src, ui5Theme);
    const id = await startApp(page, "z2ui5_cl_ui5_app_hi_world");
    await waitForApp(page, id);
    expect(await resourceRootPaths(page)).toEqual({
      cci: `${CCI_ROOT}/Control.js`,
      ccc: `${CCC_ROOT}/Control.js`,
    });
  });
});
