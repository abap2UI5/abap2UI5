// @ts-check
const { defineConfig } = require('@playwright/test');

/**
 * Minimal config for pure unit tests — no browser, no server needed.
 */
module.exports = defineConfig({
  testDir: './tests',
  testMatch: '**/*.spec.js',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: 0,
  reporter: 'html',
});
