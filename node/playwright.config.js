// @ts-check
const { defineConfig, devices } = require('@playwright/test');

/**
 * Read environment variables from file.
 * https://github.com/motdotla/dotenv
 */
// require('dotenv').config({ path: path.resolve(__dirname, '.env') });

/**
 * Custom project options (see tests/e2e/fixtures.js): ui5Src pins the UI5
 * bootstrap the served page boots with, ui5Theme the theme.
 * @typedef {{ ui5Src?: string, ui5Theme?: string }} Z2UI5TestOptions
 */

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
  // CI: 'list' puts per-test detail in the job log, where the html report
  // (written but not uploaded) would leave a failure opaque.
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
      use: { ...devices['Desktop Chrome'] },
    },

    {
      name: 'firefox',
      use: { ...devices['Desktop Firefox'] },
    },

    {
      name: 'webkit',
      use: { ...devices['Desktop Safari'] },
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

    /* Test against mobile viewports. */
    // {
    //   name: 'Mobile Chrome',
    //   use: { ...devices['Pixel 5'] },
    // },
    // {
    //   name: 'Mobile Safari',
    //   use: { ...devices['iPhone 12'] },
    // },

    /* Test against branded browsers. */
    // {
    //   name: 'Microsoft Edge',
    //   use: { ...devices['Desktop Edge'], channel: 'msedge' },
    // },
    // {
    //   name: 'Google Chrome',
    //   use: { ...devices['Desktop Chrome'], channel: 'chrome' },
    // },
  ],

  /* Run your local dev server before starting the tests */
   webServer: {
     command: 'npm run express',
     url: 'http://localhost:3000',
     reuseExistingServer: !process.env.CI,
   },
}));

