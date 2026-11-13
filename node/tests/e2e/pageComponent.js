// @ts-check
// The id of the FRONTEND's component on the backend GET page. The page is
// the app of app_v2/webapp - a component with one view and one
// z2ui5.embed.Container in it - and the control
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
      ?.getAggregation("_container")
      ?.getComponentInstance();
    return component ? component.getId() : false;
  });
  return /** @type {Promise<string>} */ (handle.jsonValue());
}

module.exports = { pageComponentId };
