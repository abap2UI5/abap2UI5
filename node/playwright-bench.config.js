// @ts-check
const { defineConfig } = require('@playwright/test');

/**
 * Config for the performance benchmarks in tests-examples/ (reference
 * material, not run in CI). Needs a Chromium binary and a local OpenUI5
 * runtime - see the setup comment in modelUpdate.bench.spec.js.
 *
 *   BENCH_CHROMIUM       path to a Chromium executable (optional when the
 *                        default Playwright browsers are installed)
 *   BENCH_UI5_RESOURCES  colon-separated roots that contain the UI5
 *                        resources (sap-ui-core.js, sap/, ...)
 */
module.exports = defineConfig({
  testDir: './tests-examples',
  testMatch: '**/*.bench.spec.js',
  fullyParallel: false,
  retries: 0,
  reporter: 'list',
  use: {
    launchOptions: {
      executablePath: process.env.BENCH_CHROMIUM || undefined,
    },
  },
});
