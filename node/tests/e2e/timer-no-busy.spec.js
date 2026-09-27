// @ts-check
// START_TIMER's optional third argument in a real browser, against the
// transpiled backend: a tick armed with `X` (abap_true) there is the
// check_no_busy of _event( ) for a timer tick, and its roundtrip leaves the
// global busy indicator down. Without it a tick raises the indicator like any
// roundtrip, after UI5's one-second default delay, so a poll whose backend
// call took longer flashed the full-screen overlay (samples-controls
// demo_004's carousel, ticks of 1.1-1.4 s). evStartTimer in
// app/webapp/core/actions/ViewOps.js has the reasoning.
//
// The transpiled backend answers in milliseconds, so the spec makes the
// tick slow: the TICK request is held back past the default delay before it
// goes on to the server, and the indicator's own `open` event - the overlay
// itself, not a call to show( ) - says whether it came up meanwhile. The
// plain tick is the reference that proves the probe sees an overlay at all.
//
// The fixture app lives in node/srv/zcl_tst_timer.clas.abap and is copied
// into the transpiled backend by `npm run auto_transpile`. Loaded via
// ./fixtures, so the page boots the pinned UI5 build of playwright.config.js
// (offline runs: UI5_PINNED_RESOURCES, see fixtures.js).
const { test, expect } = require("./fixtures");

// well past BusyIndicator's 1000 ms default delay
const TICK_HOLD_MS = 1600;

async function openApp(page) {
  // Hold every TICK roundtrip back; every other request goes on to the
  // fixture's own routes untouched. The count restarts HERE, once the tick
  // is in flight: an overlay the ARM press's own roundtrip may have raised
  // on a slow runner is closed again before the tick is even armed.
  await page.route(
    (url) => url.origin === "http://localhost:3000",
    async (route) => {
      const request = route.request();
      const isTick =
        request.method() === "POST" &&
        (request.postData() || "").includes('"EVENT":"TICK"');
      if (!isTick) return route.fallback();
      await page.evaluate(() => {
        window["__z2ui5BusyOpened"] = 0;
      });
      await new Promise((resolve) => setTimeout(resolve, TICK_HOLD_MS));
      return route.fallback();
    },
  );

  await page.goto("/?app_start=zcl_tst_timer");
  await expect(page.locator('[id$="txtTicks"]')).toHaveText("0", {
    timeout: 30000,
  });

  await page.evaluate(() => {
    window["__z2ui5BusyOpened"] = 0;
    sap.ui.require("sap/ui/core/BusyIndicator").attachOpen(() => {
      window["__z2ui5BusyOpened"] += 1;
    });
  });
}

const busyOpened = (page) => page.evaluate(() => window["__z2ui5BusyOpened"]);

test("a START_TIMER tick armed with the no-busy flag leaves the busy indicator down", async ({
  page,
}) => {
  await openApp(page);

  await page.locator('[id$="btnArmSilent"]').click();

  // the tick went out, was held past the delay and landed
  await expect(page.locator('[id$="txtTicks"]')).toHaveText("1", {
    timeout: 15000,
  });
  expect(await busyOpened(page)).toBe(0);
});

test("reference: a plain START_TIMER tick raises it after the default delay", async ({
  page,
}) => {
  await openApp(page);

  await page.locator('[id$="btnArmPlain"]').click();

  await expect(page.locator('[id$="txtTicks"]')).toHaveText("1", {
    timeout: 15000,
  });
  expect(await busyOpened(page)).toBeGreaterThan(0);
});
