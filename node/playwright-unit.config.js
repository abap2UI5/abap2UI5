// @ts-check
const { defineConfig } = require('@playwright/test');

/**
 * Minimal config for pure unit tests — no browser, no server needed.
 */
module.exports = defineConfig({
  testDir: './tests',
  testMatch: '**/*.spec.js',
  // example.spec.js is a browser test (needs Chromium + the dev server on
  // port 3000) and runs via playwright.config.js - everything else in
  // tests/ must stay runnable without a browser.
  testIgnore: '**/example.spec.js',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: 0,
  reporter: 'html',
});
