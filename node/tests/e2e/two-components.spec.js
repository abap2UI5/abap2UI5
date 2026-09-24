// @ts-check
const { test, expect } = require("./fixtures");

// Two z2ui5.Component instances on ONE page, side by side - the case the
// per-component context (app/webapp/core/Context.js) exists for. Until
// 2026-09-23 the frontend state was a module singleton that Component.init
// reset for whoever came last, so the second instance silently corrupted
// the first, which failed later with "App Terminated". The served page
// boots one component (the backend GET page); this spec creates a second
// one next to it through UI5's own ComponentContainer, the way a launchpad
// in keep-alive mode or a host app would, and asks both.
//
// Everything evaluated in the page is a function, never a string: the GET
// page's CSP has no 'unsafe-eval', and Playwright runs a string expression
// through eval.

// The id the page's own component is created under: ComponentSupport
// prefixes the settings id "z2ui5" with the container's "container" (see
// index.html and the backend GET page).
const FIRST = "container-z2ui5";
const SECOND = "z2ui5-second";

// true once the component's main view is built - its context's MAIN slot
// holds the view. The component by id on every supported release:
// getComponentById since 1.120, the deprecated get( ) before it.
async function waitForMainView(page, id) {
  await page.waitForFunction((wanted) => {
    const Component = window.sap?.ui?.require?.("sap/ui/core/Component");
    if (!Component) return false;
    const component = Component.getComponentById
      ? Component.getComponentById(wanted)
      : Component.get(wanted);
    return Boolean(component?.ctx?.state.oView);
  }, id);
}

async function bootSecondComponent(page, componentData) {
  await page.evaluate(
    ([id, data]) => {
      const host = document.createElement("div");
      host.id = `${id}-host`;
      host.style.height = "50%";
      document.body.appendChild(host);
      return new Promise((resolve, reject) => {
        window.sap.ui.require(
          ["sap/ui/core/ComponentContainer"],
          (Container) => {
            try {
              const container = new Container({
                name: "z2ui5",
                id: `${id}-container`,
                settings: data ? { id, componentData: data } : { id },
                async: true,
                manifest: true,
                componentCreated: () => resolve(true),
              });
              container.placeAt(host);
            } catch (e) {
              reject(e);
            }
          },
          reject,
        );
      });
    },
    [SECOND, componentData],
  );
}

// What the page can say about one component: whether its context exists,
// whether its MAIN slot holds a view, and that view's id. Read through the
// component's own `ctx` field (Component.init) - the framework keeps no
// registry a test could ask instead.
function describeComponent(page, id) {
  return page.evaluate((wanted) => {
    const Component = window.sap.ui.require("sap/ui/core/Component");
    const component = Component.getComponentById
      ? Component.getComponentById(wanted)
      : Component.get(wanted);
    const ctx = component && component.ctx;
    return {
      found: Boolean(component),
      hasContext: Boolean(ctx),
      alive: ctx ? ctx.alive : null,
      mainViewId: ctx && ctx.state.oView ? ctx.state.oView.getId() : null,
      controllerCarriesContext: Boolean(
        ctx && ctx.state.oController && ctx.state.oController.ctx === ctx,
      ),
    };
  }, id);
}

test("two components on one page keep separate contexts and both render", async ({
  page,
}) => {
  await page.goto("/");
  // the first app has rendered its main view
  await waitForMainView(page, FIRST);
  const firstBefore = await describeComponent(page, FIRST);
  expect(firstBefore.hasContext).toBe(true);
  expect(firstBefore.mainViewId).toBeTruthy();

  await bootSecondComponent(page);
  // ... and the second one renders its own main view through its own
  // roundtrip, without touching the first
  await waitForMainView(page, SECOND);

  const first = await describeComponent(page, FIRST);
  const second = await describeComponent(page, SECOND);

  expect(second.found).toBe(true);
  expect(second.hasContext).toBe(true);
  expect(second.alive).toBe(true);
  // the first instance is untouched: still alive, same main view as before
  expect(first.alive).toBe(true);
  expect(first.mainViewId).toBe(firstBefore.mainViewId);
  // two contexts, two views under their own component's prefix
  expect(second.mainViewId).not.toBe(first.mainViewId);
  expect(first.mainViewId).toContain(`${FIRST}---mainView`);
  expect(second.mainViewId).toContain(`${SECOND}---mainView`);
  // each component's controllers carry that component's context
  expect(first.controllerCarriesContext).toBe(true);
  expect(second.controllerCarriesContext).toBe(true);
  // both main views are in the DOM
  await expect(page.locator(`[id$="${FIRST}---mainView"]`)).toHaveCount(1);
  await expect(page.locator(`[id$="${SECOND}---mainView"]`)).toHaveCount(1);
});

test("destroying the second component leaves the first one running", async ({
  page,
}) => {
  await page.goto("/");
  await waitForMainView(page, FIRST);
  await bootSecondComponent(page);
  await waitForMainView(page, SECOND);

  // A host tears an embedded component down through its container (the
  // container destroys the component and drops its DOM); destroying the
  // component alone would leave the container's rendering in place.
  const secondCtxAliveAfter = await page.evaluate((id) => {
    const Component = window.sap.ui.require("sap/ui/core/Component");
    const component = Component.getComponentById
      ? Component.getComponentById(id)
      : Component.get(id);
    const ctx = component.ctx;
    const Element = window.sap.ui.require("sap/ui/core/Element");
    const container = Element.getElementById
      ? Element.getElementById(`${id}-container`)
      : window.sap.ui.getCore().byId(`${id}-container`);
    container.destroy();
    return ctx.alive;
  }, SECOND);
  expect(secondCtxAliveAfter).toBe(false);

  const first = await describeComponent(page, FIRST);
  expect(first.alive).toBe(true);
  expect(first.mainViewId).toContain(`${FIRST}---mainView`);
  // the first app still answers a roundtrip: its start page is interactive
  await expect(page.locator(`[id$="${FIRST}---mainView"]`)).toHaveCount(1);
  await expect(page.locator(`[id$="${SECOND}---mainView"]`)).toHaveCount(0);
});

// A host app names the backend of the component it embeds through
// componentData.endpoint (Component.init, App.controller) - a service node
// not at the manifest's /sap/bc/z2ui5. The express server answers every
// path, so the roundtrip only succeeds if it went where the host said.
test("a host's componentData.endpoint is where that component's roundtrips go", async ({
  page,
}) => {
  await page.goto("/");
  await waitForMainView(page, FIRST);

  const posts = [];
  page.on("request", (request) => {
    if (request.method() === "POST") posts.push(request);
  });
  await bootSecondComponent(page, { endpoint: "/sap/bc/z2ui5_embedded" });
  await waitForMainView(page, SECOND);

  expect(posts.map((r) => new URL(r.url()).pathname)).toEqual([
    "/sap/bc/z2ui5_embedded",
  ]);
  // it configures the frontend and is not app data: it does not travel to
  // the backend inside the component data
  const body = JSON.parse(posts[0].postData() || "{}");
  expect(body.value.S_FRONT.CONFIG.ComponentData).toBeUndefined();

  // the first component still talks to the page it was served from
  const urls = await page.evaluate(
    (ids) =>
      ids.map((id) => {
        const Component = window.sap.ui.require("sap/ui/core/Component");
        const component = Component.getComponentById
          ? Component.getComponentById(id)
          : Component.get(id);
        return component.ctx.state.url;
      }),
    [FIRST, SECOND],
  );
  expect(urls[0]).toMatch(/^http:\/\/localhost:3000\//);
  expect(urls[1]).toBe("/sap/bc/z2ui5_embedded");
});
