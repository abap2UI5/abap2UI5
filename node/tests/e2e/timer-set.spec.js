// @ts-check
// client->timer_set( ) in a real browser, against the transpiled backend: the
// app DECLARES its poll once and never arms, stops or re-arms it itself. The
// framework sends it as a repeating START_TIMER with the first display, sends
// nothing while it runs unchanged, stops it while a called popup app has the
// screen and arms it again when that app leaves; timer_stop( ) ends it and a
// new timer_set( ) brings it back. z2ui5_cl_ui5_handler=>main_end_timer has
// the reasoning.
//
// The fixture app lives in node/srv/zcl_tst_timer_set.clas.abap (POLL, POPUP,
// STOP, SET; the popup app is zcl_tst_popup_app) and is copied into the
// transpiled backend by `npm run auto_transpile`. Loaded via ./fixtures, so
// the page boots the pinned UI5 build of playwright.config.js.
const { test, expect } = require("./fixtures");

const polls = async (page) =>
  Number(await page.locator('[id$="txtPolls"]').textContent());

// Every POST that carries `"EVENT":"POLL"`, and every response that armed
// or stopped a timer.
function watch(page) {
  const seen = { polls: 0, starts: 0, stops: 0 };
  page.on("request", (request) => {
    if (
      request.method() === "POST" &&
      (request.postData() || "").includes('"EVENT":"POLL"')
    ) {
      seen.polls += 1;
    }
  });
  page.on("response", async (response) => {
    if (response.request().method() !== "POST") return;
    try {
      const text = await response.text();
      if (text.includes('["START_TIMER","POLL"')) seen.starts += 1;
      if (text.includes('["STOP_TIMER"]')) seen.stops += 1;
    } catch {
      // a response the page navigated away from - not counted
    }
  });
  return seen;
}

async function quiet(page, seen) {
  // a tick already in flight may still land
  await page.waitForTimeout(500);
  const at = seen.polls;
  await page.waitForTimeout(1200);
  expect(seen.polls).toBe(at);
}

test("a declared timer runs without being armed, pauses for a popup app and comes back", async ({
  page,
}) => {
  const seen = watch(page);
  await page.goto("/?app_start=zcl_tst_timer_set");

  // armed by the framework with the first display - no click
  await expect.poll(() => polls(page), { timeout: 15000 }).toBeGreaterThan(2);
  // sent once: the ticks' responses do not send it again
  expect(seen.starts).toBe(1);

  // the popup app has the screen: the caller's timer stops
  await page.locator('[id$="btnPopup"]').click();
  const dialog = page.locator(".sapMDialog");
  await expect(dialog).toBeVisible({ timeout: 15000 });
  await quiet(page, seen);

  // the popup app leaves: the timer is armed again, the app did nothing
  const before = await polls(page);
  await dialog.getByRole("button", { name: "Close" }).click();
  await expect(dialog).toBeHidden({ timeout: 15000 });
  await expect
    .poll(() => polls(page), { timeout: 15000 })
    .toBeGreaterThan(before + 1);
  expect(seen.starts).toBe(2);

  // timer_stop( ): no tick goes out any more ...
  await page.locator('[id$="btnStop"]').click();
  await quiet(page, seen);
  expect(seen.stops).toBeGreaterThan(0);

  // ... until timer_set( ) declares it again
  const stoppedAt = await polls(page);
  await page.locator('[id$="btnSet"]').click();
  await expect
    .poll(() => polls(page), { timeout: 15000 })
    .toBeGreaterThan(stoppedAt + 1);
});
