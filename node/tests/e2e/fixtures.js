// @ts-check
// Shared fixture for the browser e2e specs: lets a Playwright project pin
// the UI5 build the app boots with, turning the OpenUI5 1.71 compatibility
// rules (AGENTS.md rules 12, 13, 15-18) into an executable gate instead of
// reviewer lore (see the ui5-1.71 project in ../../playwright.config.js).
//
// The backend GET page hardcodes the evergreen CDN bootstrap and the
// default theme (z2ui5_cl_ui5_user_exit=>set_config_http_get). The `ui5Src` /
// `ui5Theme` project options rewrite those attributes in the served HTML
// before it reaches the browser; UI5 derives its resource root from the
// script tag's src, so rewriting the bootstrap URL is enough - every later
// module request follows it. A project that sets neither option gets the
// page untouched. All four projects pin ui5Src now - the default legs to
// the PINNED_UI5_SRC in ../../playwright.config.js (a moving evergreen CDN
// could turn a green pull request red without any change here), the
// ui5-1.71 leg to the oldest supported release.
//
// Offline runs: when the UI5 CDN is unreachable (sandboxed environments),
// point UI5_PINNED_RESOURCES at a local OpenUI5 `resources/` directory of
// the pinned release (e.g. assembled from the @openui5/* npm packages);
// every request under the pinned bootstrap's resources/ root is then
// served from that directory instead of the network.
const fs = require("fs");
const path = require("path");
const base = require("@playwright/test");

// The exact attributes the default exit writes into the GET page - keep in
// sync with z2ui5_cl_ui5_user_exit=>set_config_http_get.
const DEFAULT_BOOTSTRAP =
  'src="https://sdk.openui5.org/resources/sap-ui-cachebuster/sap-ui-core.js"';
const DEFAULT_THEME = 'data-sap-ui-theme="sap_horizon"';

const test = base.test.extend({
  // Full URL of the sap-ui-core.js to boot instead of the evergreen CDN
  // build (project option; unset = leave the page untouched).
  ui5Src: [undefined, { option: true }],
  // Theme to boot instead of the default - sap_horizon only exists since
  // UI5 1.102, so a pinned 1.71 run needs sap_fiori_3.
  ui5Theme: [undefined, { option: true }],
  page: async ({ page, ui5Src, ui5Theme }, use) => {
    if (ui5Src) {
      const localResources = process.env.UI5_PINNED_RESOURCES;
      if (localResources) {
        const resourceBase = ui5Src.replace(/sap-ui-core\.js$/, "");
        await page.route(
          (url) => url.href.startsWith(resourceBase),
          (route) => {
            const rel = decodeURIComponent(
              route.request().url().slice(resourceBase.length).split("?")[0],
            );
            const file = path.join(localResources, rel);
            // Guard the join against escaping the resources dir, and answer
            // a missing file (library-preload.js or the built theme css of
            // a source-only tree) with a plain 404 so the ui5loader falls
            // back instead of waiting on the unreachable network.
            if (
              file.startsWith(path.resolve(localResources) + path.sep) &&
              fs.existsSync(file)
            ) {
              return route.fulfill({ path: file });
            }
            return route.fulfill({ status: 404, body: "not found" });
          },
        );
      }
      await page.route(
        (url) => url.origin === "http://localhost:3000",
        async (route) => {
          if (route.request().resourceType() !== "document") {
            return route.fallback();
          }
          const response = await route.fetch();
          const contentType = response.headers()["content-type"] || "";
          if (!contentType.includes("text/html")) {
            return route.fulfill({ response });
          }
          let body = await response.text();
          body = body.split(DEFAULT_BOOTSTRAP).join(`src="${ui5Src}"`);
          if (ui5Theme) {
            body = body
              .split(DEFAULT_THEME)
              .join(`data-sap-ui-theme="${ui5Theme}"`);
          }
          return route.fulfill({ response, body });
        },
      );
    }
    await use(page);
  },
});

module.exports = { test, expect: base.expect };
