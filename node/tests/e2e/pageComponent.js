// @ts-check
// The id of the FRONTEND's component on the backend GET page. The page is
// the app of app_source/webapp - a component with one view and one
// z2ui5.embed.Container (abap2UI5-addons/embed-ui5-control) in it - and the control
// creates the frontend's component without an id of its own - UI5 generates
// one - so a spec that needs the component asks the control for it: the one
// element of the page with the control's class, its hidden ComponentContainer,
// the instance in it. Resolves once the component exists.
//
// A function evaluated in the page, never a string: the GET page's CSP has
// no 'unsafe-eval'. The control by its DOM element on every supported
// release: Element.closestTo since 1.106, the core's registry before it.

/**
 * @param {import('@playwright/test').Page} page
 * @returns {Promise<string>}
 */
async function pageComponentId(page) {
  const handle = await page.waitForFunction(() => {
    const ui = /** @type {any} */ (window).sap?.ui;
    const Element = ui?.require?.("sap/ui/core/Element");
    const dom = document.querySelector(".z2ui5EmbedContainer");
    if (!Element || !dom) return false;
    const control = Element.closestTo
      ? Element.closestTo(dom)
      : ui.getCore().byId(dom.id);
    const component = control
      ?.getAggregation("_app")
      ?.getComponentInstance();
    return component ? component.getId() : false;
  });
  return /** @type {Promise<string>} */ (handle.jsonValue());
}

/**
 * Resolves once the page's app has settled: its component has processed a
 * response and no roundtrip is in flight (the busy state is released at the
 * end of View1._processAfterRendering, after the view was built and the
 * app's actions ran) - plus one animation frame. A definite signal, where a
 * spec that asserts that something did NOT happen used to wait a fixed
 * number of milliseconds: what the frontend loads for a view (the custom
 * controls bundle, before the build) or at its start (the developer tools
 * on an auto open) has been asked for by then, or never is.
 * @param {import('@playwright/test').Page} page
 */
async function appSettled(page) {
  const id = await pageComponentId(page);
  await page.waitForFunction((componentId) => {
    const Component = /** @type {any} */ (window).sap.ui.require(
      "sap/ui/core/Component",
    );
    const component = Component.getComponentById
      ? Component.getComponentById(componentId)
      : Component.get(componentId);
    const state = component?.ctx?.state;
    return Boolean(state?.oResponse) && !state.isBusy;
  }, id);
  await page.evaluate(
    () => new Promise((resolve) => requestAnimationFrame(() => resolve(true))),
  );
}

module.exports = { pageComponentId, appSettled };
