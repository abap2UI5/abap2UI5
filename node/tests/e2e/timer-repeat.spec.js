// @ts-check
// START_TIMER's optional fourth argument in a real browser, against the
// transpiled backend: a timer armed with the repeat flag `X` is armed again by
// the browser after every applied response - its own tick's, and a user
// event's in between - so the app arms it once and never again. STOP_TIMER
// ends it, as a follow-up action of a roundtrip and as the roundtrip-free wire
// of a press. A repeating tick that changes nothing is answered with the draft
// it continued (z2ui5_cl_ui5_handler=>main_end_reuse) and goes on all the
// same. evStartTimer / resumeRepeatTimer in bundle/webapp/core/actions/ViewOps.js
// have the reasoning.
//
// The fixture app lives in node/srv/zcl_tst_timer.clas.abap (ARM_REPEAT,
// ARM_IDLE, STOP, POLL, IDLE) and is copied into the transpiled backend by
// `npm run auto_transpile`. Loaded via ./fixtures, so the page boots the
// pinned UI5 build of playwright.config.js.
const { test, expect } = require("./fixtures");

async function openApp(page) {
  await page.goto("/?app_start=zcl_tst_timer");
  await expect(page.locator('[id$="txtPolls"]')).toHaveText("0", {
    timeout: 30000,
  });
}

const polls = async (page) =>
  Number(await page.locator('[id$="txtPolls"]').textContent());

// Every POST that carries `"EVENT":"<name>"` - the requests the timer sent.
function countRequests(page, event) {
  const seen = { count: 0 };
  page.on("request", (request) => {
    if (
      request.method() === "POST" &&
      (request.postData() || "").includes(`"EVENT":"${event}"`)
    ) {
      seen.count += 1;
    }
  });
  return seen;
}

test("a repeating timer ticks on without being armed again, through a click, until it is stopped", async ({
  page,
}) => {
  await openApp(page);
  const sent = countRequests(page, "POLL");

  // armed once - the app never arms it again
  await page.locator('[id$="btnArmRepeat"]').click();
  await expect.poll(() => polls(page), { timeout: 15000 }).toBeGreaterThan(2);

  // a click in between does not end it: its response arms the next tick
  await page.locator('[id$="btnClick"]').click();
  await expect(page.locator('[id$="txtClicks"]')).toHaveText("1", {
    timeout: 15000,
  });
  const afterClick = await polls(page);
  await expect
    .poll(() => polls(page), { timeout: 15000 })
    .toBeGreaterThan(afterClick + 1);

  // stopped by the app: no tick goes out any more
  await page.locator('[id$="btnStop"]').click();
  await page.waitForTimeout(400);
  const stoppedAt = sent.count;
  await page.waitForTimeout(1200);
  expect(sent.count).toBe(stoppedAt);
});

test("a repeating timer stops in the browser on the roundtrip-free STOP_TIMER wire", async ({
  page,
}) => {
  await openApp(page);
  const sent = countRequests(page, "POLL");

  await page.locator('[id$="btnArmRepeat"]').click();
  await expect.poll(() => polls(page), { timeout: 15000 }).toBeGreaterThan(1);

  await page.locator('[id$="btnStopLocal"]').click();
  // a tick already in flight may still land
  await page.waitForTimeout(400);
  const stoppedAt = sent.count;
  await page.waitForTimeout(1200);
  expect(sent.count).toBe(stoppedAt);
});

test("a repeating tick that changes nothing ticks on, each continuing the draft it was answered with", async ({
  page,
}) => {
  await openApp(page);
  // the id each IDLE tick continued, and the id it was answered with. The
  // Node host keeps its drafts behind a serializer of its own, so an
  // unchanged tick is answered with a new id here (db_check_unchanged
  // compares the shipped serializer's text only; the reuse is held by the
  // handler's ABAP unit, tick_repeat_reuses_id) - what holds on both is the
  // chain: the browser arms the next tick on the id the last response named
  const sent = [];
  const answered = [];
  page.on("response", async (response) => {
    const request = response.request();
    const body = request.postData() || "";
    if (request.method() !== "POST" || !body.includes('"EVENT":"IDLE"')) {
      return;
    }
    // every tick says it is one (S_FRONT.TIMER)
    expect(body).toContain('"TIMER":true');
    try {
      sent.push(
        JSON.parse(body)?.S_FRONT?.ID ?? JSON.parse(body)?.value?.S_FRONT?.ID,
      );
      answered.push((await response.json())?.S_FRONT?.ID);
    } catch {
      // a response the page navigated away from - not counted
    }
  });

  await page.locator('[id$="btnArmIdle"]').click();
  await expect
    .poll(() => answered.length, { timeout: 15000 })
    .toBeGreaterThan(3);

  // the app armed it once and changed nothing since: still ticking, and
  // every tick continued the id the previous one was answered with
  expect(answered[0]).toBeTruthy();
  for (let i = 1; i < answered.length; i++) {
    expect(sent[i]).toBe(answered[i - 1]);
  }
});
