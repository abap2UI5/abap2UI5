// @ts-check
const { test, expect } = require("./fixtures");

// The frontend in a page that belongs to a HOST app - a freestyle app, a
// custom page or a custom section of Fiori elements - through the real
// control: the host page below loads UI5 itself and holds one
// z2ui5.embed.Container (app_source/webapp/embed/Container.js, served to the
// page as a host's thirdparty/ folder would). The control loads the frontend
// through ?z2ui5-bundle and asks the bundle for the app. Nothing of the
// backend's own GET page is on it: what these specs pin is what an embedded
// app does to a page it does not own, and what the control does for its
// host.
//
// Everything evaluated in the page is a function, never a string (see
// two-components.spec.js).

const fs = require("fs");
const path = require("path");

// where the host page serves the control from, and the file it serves
const CONTROL_ROOT = "/z2ui5-embed-host/thirdparty/z2ui5/embed";
const CONTROL_FILE = path.join(
  __dirname,
  "..",
  "..",
  "..",
  "app_source",
  "webapp",
  "embed",
  "Container.js",
);

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

// The host page with UI5 booted and the control's namespace registered, the
// way a host app's manifest registers it. The frontend is not loaded here:
// the first control that starts loads it.
async function openHost(page, ui5Src, ui5Theme) {
  await page.route(
    (url) => url.pathname === HOST_PATH,
    (route) =>
      route.fulfill({
        contentType: "text/html",
        body: hostHtml(ui5Src, ui5Theme || "sap_horizon"),
      }),
  );
  await page.route(
    (url) => url.pathname === `${CONTROL_ROOT}/Container.js`,
    (route) =>
      route.fulfill({
        contentType: "application/javascript",
        body: fs.readFileSync(CONTROL_FILE, "utf8"),
      }),
  );
  await page.goto(HOST_PATH);
  await page.waitForFunction(() => Boolean(window.sap?.ui?.getCore));
  await page.evaluate(
    (root) =>
      new Promise((resolve) =>
        window.sap.ui.getCore().attachInit(() => {
          window.sap.ui.loader.config({ paths: { "z2ui5/embed": root } });
          resolve(true);
        }),
      ),
    CONTROL_ROOT,
  );
}

// Put a z2ui5.embed.Container into #host1 and start `app` in it. Resolves
// with the id of the app's component once the control reports it created,
// and rejects with the reason when the control reports the start failed.
// `params` are further startup parameters of the app; `endpoint` is the
// control's endpoint property; `host` are further properties a host sets
// (ownsPage, height).
function startApp(page, app, params = {}, endpoint = ENDPOINT, host = {}) {
  return page.evaluate(
    ([appName, params, endpoint, host]) =>
      new Promise((resolve, reject) => {
        window.sap.ui.require(
          ["z2ui5/embed/Container"],
          (Container) => {
            const control = new Container(
              "hostControl",
              Object.assign({ height: "100%" }, host, {
                app: appName,
                params,
                endpoint,
                componentCreated: (event) =>
                  resolve(event.getParameter("component").getId()),
                componentFailed: (event) =>
                  reject(
                    new Error(String(event.getParameter("reason").message)),
                  ),
              }),
            );
            control.placeAt("host1");
          },
          reject,
        );
      }),
    [app, params, endpoint, host],
  );
}

// The control of the host page.
const control = (page, fn, arg) =>
  page.evaluate(
    ([source, arg]) => {
      const Element = window.sap.ui.require("sap/ui/core/Element");
      const instance = Element.getElementById
        ? Element.getElementById("hostControl")
        : window.sap.ui.getCore().byId("hostControl");
      // a function handed over as its source is a string to evaluate - so
      // the few things the specs do with the control are named here
      if (source === "setApp") instance.setApp(arg);
      if (source === "setHeight") instance.setHeight(arg);
      if (source === "restart") instance.restart();
      return {
        component: instance
          .getAggregation("_app")
          ?.getComponentInstance()
          ?.getId(),
        height: instance.getDomRef()?.style.height,
      };
    },
    [fn, arg],
  );

// Where the loader would fetch a module of each sibling BSP from - the
// path on the page's origin, as the page resolves it.
function resourceRootPaths(page) {
  return page.evaluate(() => {
    const path = (name) =>
      new URL(window.sap.ui.require.toUrl(name), window.location.href).pathname;
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
      root: state?.oApp?.getMetadata().getName() ?? null,
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
    expect(await page.evaluate(() => typeof window["z2ui5"])).toBe("undefined");
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
    await openHost(page, ui5Src, ui5Theme);
    // the app runs through the proxy: the control loads the bundle from the
    // prefixed endpoint, and the roundtrips go there
    const id = await startApp(page, "z2ui5_cl_ui5_app_hi_world", {}, endpoint);
    await waitForApp(page, id);
    // the bundle came through the proxy and names the node's own path
    expect(
      await page.evaluate(
        () => window.sap.ui.require("z2ui5/embed").componentData.nodePath,
      ),
    ).toBe(ENDPOINT);
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

// sap/ui/util/Mobile.init( ) runs once per page with the settings of whoever
// calls first - sap.m.App, and a sap.m.Shell in the app's view. On a host's
// page without a sap.m.App of its own that put height: 100% on <html>, a
// viewport meta tag that disables zooming and a format-detection meta tag
// there - and on iOS took the host's scrolling. An embedded component makes
// the call first, with everything off (Component.init). And its root is a
// sap.m.NavContainer, not the full-screen sap.m.App (App.controller.js,
// createRoot).
test.describe("an embedded app and the host's page", () => {
  test("the frontend leaves <html> and the host's meta tags as they are", async ({
    page,
    ui5Src,
    ui5Theme,
  }) => {
    test.skip(!ui5Src, "the host page boots the pinned UI5 build");
    await openHost(page, ui5Src, ui5Theme);
    const pageSetup = () =>
      page.evaluate(() => ({
        htmlStyle: document.documentElement.getAttribute("style"),
        viewport: document.querySelectorAll("meta[name='viewport']").length,
        formatDetection: document.querySelectorAll(
          "meta[name='format-detection']",
        ).length,
      }));
    const before = await pageSetup();
    expect(before).toEqual({
      htmlStyle: null,
      viewport: 0,
      formatDetection: 0,
    });
    const id = await startApp(page, "z2ui5_cl_ui5_app_hi_world");
    await waitForApp(page, id);
    await expect(page.locator('input[id$="-inner"]').first()).toBeVisible();
    expect(await pageSetup()).toEqual(before);
    expect((await componentState(page, id)).root).toBe("sap.m.NavContainer");
  });
});

// The URL hash. The bundle's component leaves it to the host - a Fiori
// elements object page routes by it - and a routed app (zcl_tst_nav_hub,
// hash_routing FRESH) neither writes a route nor reads one. A host whose page
// is the one component and nothing else (the abap2UI5/frontend branches
// standard_new and cloud_new) hands it
// back with ownsPage, and the app routes as on its own page - a route
// per app, browser Back and Forward between them (nav-back-forward.spec.js
// on the backend's own page).
test.describe("an embedded app and the URL hash", () => {
  test.beforeEach(async ({ page, ui5Src, ui5Theme }) => {
    test.skip(!ui5Src, "the host page boots the pinned UI5 build");
    await openHost(page, ui5Src, ui5Theme);
  });

  test("a routed app leaves the host's hash alone", async ({ page }) => {
    await page.evaluate(() => {
      window.location.hash = "#Customers('1001')";
    });
    const id = await startApp(page, "zcl_tst_nav_hub");
    await waitForApp(page, id);
    await expect(page.getByText("hub-marker")).toBeVisible();
    await page.getByRole("button", { name: "go-detail" }).click();
    await expect(page.getByText("detail-marker")).toBeVisible();
    expect(new URL(page.url()).hash).toBe("#Customers('1001')");
  });

  test("handed the page, a routed app routes as on its own page", async ({
    page,
  }) => {
    const id = await startApp(page, "zcl_tst_nav_hub", {}, ENDPOINT, {
      ownsPage: true,
    });
    await waitForApp(page, id);
    // the page is the app's: the full-screen root, as on a page of its own
    expect((await componentState(page, id)).root).toBe("sap.m.App");
    await expect(page.getByText("hub-marker")).toBeVisible();
    await expect.poll(() => page.url()).toContain("#/app/ZCL_TST_NAV_HUB");

    await page.getByRole("button", { name: "go-detail" }).click();
    await expect(page.getByText("detail-marker")).toBeVisible();
    await expect.poll(() => page.url()).toContain("#/app/ZCL_TST_NAV_DETAIL");

    await page.goBack();
    await expect(page.getByText("hub-marker")).toBeVisible();
    await page.goForward();
    await expect(page.getByText("detail-marker")).toBeVisible();
  });
});

// What the control itself does for its host - the part that is not the
// bundle's: when an app starts and ends, how much room it has, and what the
// host hears when it cannot start.
test.describe("the control", () => {
  test.beforeEach(async ({ page, ui5Src, ui5Theme }) => {
    test.skip(!ui5Src, "the host page boots the pinned UI5 build");
    await openHost(page, ui5Src, ui5Theme);
  });

  test("another app ends the session and starts a new one in place", async ({
    page,
  }) => {
    const first = await startApp(page, "zcl_tst_nav_hub");
    await waitForApp(page, first);
    await expect(page.getByText("hub-marker")).toBeVisible();

    await control(page, "setApp", "zcl_tst_nav_detail");
    await expect(page.getByText("detail-marker")).toBeVisible();
    await expect(page.getByText("hub-marker")).toHaveCount(0);
    const second = (await control(page)).component;
    expect(second).toBeTruthy();
    expect(second).not.toBe(first);
  });

  test("restart starts the same app from scratch", async ({ page }) => {
    const first = await startApp(page, "zcl_tst_nav_hub");
    await waitForApp(page, first);
    await control(page, "restart");
    await expect
      .poll(async () => (await control(page)).component)
      .not.toBe(first);
    await expect(page.getByText("hub-marker")).toBeVisible();
  });

  test("a new height goes to the area without a new app", async ({ page }) => {
    const id = await startApp(page, "zcl_tst_focus");
    await waitForApp(page, id);
    const input = page.locator('input[id$="inpDocNum-inner"]');
    await input.click();
    await page.keyboard.type("4711");
    const state = await control(page, "setHeight", "300px");
    expect(state.height).toBe("300px");
    // the same session, and what the user typed is still there, focused
    expect(state.component).toBe(id);
    await expect(input).toHaveValue(/4711$/);
    await expect(input).toBeFocused();
  });

  test("an endpoint on another host is refused, and the host is told", async ({
    page,
  }) => {
    const requests = [];
    page.on("request", (r) => requests.push(r.url()));
    const reason = await startApp(
      page,
      "z2ui5_cl_ui5_app_hi_world",
      {},
      "https://evil.example/sap/bc/z2ui5",
    ).then(
      () => null,
      (e) => e.message,
    );
    expect(reason).toContain("is not a path on this server");
    expect(requests.some((url) => url.includes("evil.example"))).toBe(false);
  });

  test("a backend without the bundle fails the start with its endpoint", async ({
    page,
  }) => {
    await page.route(
      (url) => url.pathname === "/sap/bc/none",
      (route) => route.fulfill({ status: 404, body: "not found" }),
    );
    const reason = await startApp(
      page,
      "z2ui5_cl_ui5_app_hi_world",
      {},
      "/sap/bc/none",
    ).then(
      () => null,
      (e) => e.message,
    );
    expect(reason).toContain("no abap2UI5 frontend at");
    expect(reason).toContain("/sap/bc/none?z2ui5-bundle");
  });
});
