// @ts-check
const { defineConfig, devices } = require('@playwright/test');

/**
 * Custom project options (see tests/e2e/fixtures.js): ui5Src pins the UI5
 * bootstrap the served page boots with, ui5Theme the theme.
 * @typedef {{ ui5Src?: string, ui5Theme?: string }} Z2UI5TestOptions
 */

/* The UI5 build the three default browser legs boot for the fixture-based
   specs (example, roundtrip - see tests/e2e/fixtures.js). Pinned for the
   same reason node/setup/fetch-deps.mjs pins its git dependencies by sha: the
   backend page hardcodes the EVERGREEN CDN bootstrap, so a UI5 release could
   turn a green pull request red without any change in this repository - and
   `retries: 2` then hid the flake instead of naming it. Bump deliberately
   (edit here, run the suite), or override for one run via UI5_E2E_SRC.
   The specs that create their own pages (error-view, nav-back-forward,
   lib-sanitizer, focus-after-enable) bypass the fixture's rewrite and still
   boot the evergreen build - the ui5-1.71 project comment below describes
   how to port one onto the shared page fixture. */
const PINNED_UI5_SRC =
  process.env.UI5_E2E_SRC ||
  'https://sdk.openui5.org/1.136.0/resources/sap-ui-core.js';

/**
 * @see https://playwright.dev/docs/test-configuration
 */
module.exports = defineConfig(
  /** @type {import('@playwright/test').PlaywrightTestConfig<Z2UI5TestOptions>} */ ({
  testDir: './tests',
  /* Browser tests live in tests/e2e/ and need the dev server on port 3000;
     everything else in tests/ is a unit spec run via playwright-unit.config.js */
  testMatch: '**/e2e/**/*.spec.js',
  /* UI5 loads from the CDN on every fresh page - give slow CI runners more
     headroom than the 30s default before a test counts as hung */
  timeout: 60000,
  /* Run tests in files in parallel */
  fullyParallel: true,
  /* Fail the build on CI if you accidentally left test.only in the source code. */
  forbidOnly: !!process.env.CI,
  /* Retry on CI only */
  retries: process.env.CI ? 2 : 0,
  /* Opt out of parallel tests on CI. */
  workers: process.env.CI ? 1 : undefined,
  /* Reporter to use. See https://playwright.dev/docs/test-reporters */
  // CI: 'list' puts per-test detail in the job log; the html report and the
  // first-retry trace below are uploaded by test.yaml's browser matrix when a
  // leg fails, so a flake that only reproduces in CI can be opened afterwards.
  reporter: process.env.CI ? [['list'], ['html']] : 'html',
  /* Shared settings for all the projects below. See https://playwright.dev/docs/api/class-testoptions. */
  use: {
    /* Base URL to use in actions like `await page.goto('/')`. */
    baseURL: 'http://localhost:3000',

    /* Collect trace when retrying the failed test. See https://playwright.dev/docs/trace-viewer */
    trace: 'on-first-retry',
  },

  /* Configure projects for major browsers */
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'], ui5Src: PINNED_UI5_SRC },
    },

    {
      name: 'firefox',
      use: { ...devices['Desktop Firefox'], ui5Src: PINNED_UI5_SRC },
    },

    {
      name: 'webkit',
      use: { ...devices['Desktop Safari'], ui5Src: PINNED_UI5_SRC },
    },

    /* Pinned OpenUI5 1.71 gate: the oldest supported release, run as an
       executable check for the 1.71 compatibility rules (AGENTS.md rules
       12, 13, 15-18) instead of reviewer lore. tests/e2e/fixtures.js
       rewrites the served page's bootstrap src to the pinned build and the
       theme to one that exists in 1.71 (sap_horizon needs >= 1.102).
       Scoped to the shell smoke + roundtrip specs - the wire contract and
       shell boot that must always work on 1.71. The remaining e2e specs
       (error-view, nav-back-forward, lib-sanitizer, focus-after-enable)
       are excluded because they load `test` from @playwright/test and
       create their own pages via browser.newPage() in beforeAll, which
       bypasses the fixture's page rewrite - under this project they would
       silently boot the evergreen CDN build and gate nothing. To promote
       one, port it to ./tests/e2e/fixtures and to the shared page fixture
       first, then verify it against 1.71 and widen this testMatch. Runs as
       its own leg of the `browser` matrix in test.yaml; for sandboxes
       without CDN egress see UI5_PINNED_RESOURCES in tests/e2e/fixtures.js. */
    {
      name: 'ui5-1.71',
      testMatch: /e2e[/\\](example|roundtrip)\.spec\.js$/,
      use: {
        ...devices['Desktop Chrome'],
        /* newest 1.71 patch on the CDN at pin time - bump deliberately */
        ui5Src: 'https://sdk.openui5.org/1.71.80/resources/sap-ui-core.js',
        ui5Theme: 'sap_fiori_3',
      },
    },
  ],

  /* Run your local dev server before starting the tests */
   webServer: {
     command: 'npm run express',
     url: 'http://localhost:3000',
     reuseExistingServer: !process.env.CI,
   },
}));

