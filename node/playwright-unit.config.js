// @ts-check
const { defineConfig } = require('@playwright/test');

/**
 * Minimal config for pure unit tests — no browser, no server needed.
 */
module.exports = defineConfig({
  testDir: './tests',
  testMatch: '**/*.spec.js',
  // tests/e2e/ holds the browser tests (they need Chromium + the dev server
  // on port 3000) and runs via playwright.config.js - everything else in
  // tests/ must stay runnable without a browser.
  testIgnore: '**/e2e/**',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: 0,
  reporter: 'html',
});
