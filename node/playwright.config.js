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

   The version MUST be the FINAL patch of a RETIRED minor line: the CDN
   serves only the newest patch of each line and drops the rest, so a pin
   into a still-moving line (1.136.0 while the LTS line was at .20) 404s
   and every leg times out - that is how this comment learned it. Same
   reason the 1.71 leg pins 1.71.80, the last 1.71 patch ever. `npm view
   @openui5/sap.ui.core versions` shows where each line ended.

   Every spec boots it: the ones that share one page across their tests
   (error-view, lib-sanitizer - browser.newPage() in a beforeAll, where the
   page fixture does not reach) pin that page themselves with the fixture's
   pinUi5( ) and their project's options. Until 2026-11 they, and
   nav-back-forward and focus-after-enable, took `test` from
   @playwright/test and booted the evergreen CDN build. */
const PINNED_UI5_SRC =
  process.env.UI5_E2E_SRC ||
  'https://sdk.openui5.org/1.144.0/resources/sap-ui-core.js';

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
  /* Two workers on CI, not the generator's one. The backend behind every
     spec is one process that runs ONE request at a time (host.mjs,
     exclusive( )), so what workers overlap is the browser side only - the
     page boot, UI5's own module loading and rendering, which is most of a
     spec's wall time - and the roundtrips of two specs interleave in the
     queue the host keeps anyway. Measured on the chromium project offline
     (UI5_PINNED_RESOURCES): 2 workers end the leg in roughly two thirds of
     the time of 1, with no flake over repeated runs; more than 2 overlaps
     page boots on a two-core runner for little gain. The specs share no
     state beyond that backend: every page starts its own app and draft. */
  workers: process.env.CI ? 2 : undefined,
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
       shell boot that must always work on 1.71 - and the ones listed below.
       Every spec boots the pinned build of its project (the page fixture,
       or pinUi5( ) for a page a spec makes itself), so promoting one is a
       matter of verifying it against 1.71 and widening this testMatch.
       Runs as its own leg of the `browser` matrix in test.yaml; for
       sandboxes without CDN egress see UI5_PINNED_RESOURCES in
       tests/e2e/fixtures.js. */
    /* page-transition runs here too: the NavContainer calls it drives
       (to, insertPreviousPage, backToPage, the afterNavigate report) are
       the 1.71 API, and the demo views it opens are held to 1.71 by the
       linter - so the oldest release is where a regression would show.
       So does embedded: a host page that boots the pinned build itself and
       loads the frontend through ?z2ui5-bundle - a starting app took the
       host's focus on 1.71 as on the current release, through sap.m.App's
       first rendering and through its own SET_FOCUS.
       And message-box-details: sap.m.MessageBox fills the details text at
       creation on 1.71 and only on the link's press from 1.120 on, so the
       unfolded details are asked for on both ends of the range.
       And library-preload: the libraries a view names come as their
       bundles through sap.ui.getCore().loadLibraries there and through
       sap/ui/core/Lib.load on the current release - the request count is
       asked for on both.
       And cc-bundle: on 1.71 a popup's fragment is processed synchronously,
       so its controls are required before Fragment.load (Env.
       preloadFragmentModules) - a custom control among them is there only
       once its bundle is, and the order of the two is what 1.71 would
       break.
       And error-view, nav-back-forward, lib-sanitizer and
       focus-after-enable since they boot the pinned build (2026-11): the
       raw-DOM overlay and its focus trap, Back/Forward over the 1.71
       hash changer, the sanitizer's whitelist over 1.71's DOM, and a
       SET_FOCUS into a field the same roundtrip enabled - each passed on
       1.71.80 as it was.
       And start-failed: the page's component hooks into its root view
       (createContent, which 1.71 answers with the view and the current
       release with a promise of it) and loads sap.m.MessagePage at the
       point of use - both ends of the range have to say a failed start. */
    {
      name: 'ui5-1.71',
      testMatch: /e2e[/\\](error-view|nav-back-forward|lib-sanitizer|focus-after-enable|example|roundtrip|page-transition|embedded|message-box-details|library-preload|window|cc-bundle|cci-bundle|start-failed)\.spec\.js$/,
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

