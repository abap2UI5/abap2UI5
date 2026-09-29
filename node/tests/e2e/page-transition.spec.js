// @ts-check
// Page transitions of the MAIN view, view_display( transition = ... ),
// against the transpiled backend and a real sap.m.App - on the pinned
// current release and, through the ui5-1.71 project, on OpenUI5 1.71.
// The test apps are node/srv/zcl_tst_anim_*.clas.abap: a hub with one
// button per transition, the page it opens (Back, Deeper, Re-render,
// Replace, a popup-as-app), an app with screens of its own, and the switch
// that turns hash routing on for the browser buttons. The same demo ships as
// the sample Z2UI5_CL_SMP_APP_531 of abap2UI5/samples.
//
// What is asserted is what the root NavContainer was asked to do - its
// to( ), insertPreviousPage( ) and backToPage( ) calls, spied on the
// instance - and what it reported (afterNavigate), plus that the leaving
// page is gone afterwards. That the CSS moves is UI5's business; that the
// framework asks for the right move, in the right direction, is this one's.
const { test, expect } = require("./fixtures");

const HUB = "zcl_tst_anim_hub";

async function start(page) {
  await page.goto(`/?app_start=${HUB}`);
  await expect(page.locator('[id$="--go-fade"]')).toBeVisible({
    timeout: 30000,
  });
  // record every navigation the framework asks the root container for.
  // The root sap.m.App is found by its class, not by an id: the component
  // id in front of it depends on the page that hosts the component
  await page.evaluate(() => {
    const app = sap.ui.getCore().byId(document.querySelector(".sapMApp").id);
    const calls = [];
    const moves = [];
    for (const name of ["to", "insertPreviousPage", "backToPage"]) {
      const original = app[name];
      app[name] = function (...args) {
        calls.push([name, ...args.slice(0, 2)]);
        return original.apply(this, args);
      };
    }
    app.attachAfterNavigate((e) =>
      moves.push({
        direction: e.getParameter("direction"),
        to: e.getParameter("toId"),
      }),
    );
    window.__transitions = { app, calls, moves };
  });
}

const calls = (page) => page.evaluate(() => window.__transitions.calls);
const moves = (page) => page.evaluate(() => window.__transitions.moves);

// the local ids of the MAIN views in the container right now
const mainViews = (page) =>
  page.evaluate(() =>
    window.__transitions.app
      .getPages()
      .map((p) => p.getId().split("---").pop()),
  );

async function settled(page) {
  await expect.poll(() => mainViews(page)).toHaveLength(1);
}

test("forward: the page comes in with its transition, the old one is gone after", async ({
  page,
}) => {
  await start(page);
  await page.locator('[id$="--go-fade"]').click();
  await expect(page.locator('[id$="--arrival"]')).toContainText(
    "arrived with: fade",
  );
  await settled(page);

  expect((await calls(page)).filter((c) => c[0] === "to")).toEqual([
    ["to", expect.stringMatching(/---mainView2$/), "fade"],
  ]);
  expect(await moves(page)).toEqual([
    { direction: "to", to: expect.stringMatching(/---mainView2$/) },
  ]);
  // the hub's page left the container once the move was done
  expect(await mainViews(page)).toEqual(["mainView2"]);
});

test("back: the page leaves with its arrival reversed - also after a re-render", async ({
  page,
}) => {
  await start(page);
  await page.locator('[id$="--go-flip"]').click();
  await expect(page.locator('[id$="--arrival"]')).toContainText("flip");
  await settled(page);

  // a re-render without a transition swaps the page in place...
  await page.locator('[id$="--rerender"]').click();
  await expect(page.locator('[id$="--arrival"]')).toContainText(
    "Rendered 2 time(s)",
  );
  await settled(page);
  expect((await calls(page)).filter((c) => c[0] === "to")).toHaveLength(1);

  // ...and the way back still reverses how the page ARRIVED
  await page.locator('[id$="--back"]').click();
  await expect(page.locator('[id$="--go-fade"]')).toBeVisible();
  await settled(page);

  const log = await calls(page);
  const back = log.slice(1);
  // the stamp: to( <the page on screen>, <its arrival> ) - no navigation
  expect(back[0]).toEqual(["to", expect.stringMatching(/---mainView$/), "flip"]);
  expect(back[1][0]).toBe("insertPreviousPage");
  expect(back[2][0]).toBe("backToPage");
  expect(back[2][1]).toMatch(/---mainView2$/);
  expect((await moves(page)).pop()).toEqual({
    direction: "backToPage",
    to: back[2][1],
  });
});

test("a return from a popup-as-app moves nothing", async ({ page }) => {
  await start(page);
  await page.locator('[id$="--go-slide"]').click();
  await expect(page.locator('[id$="--arrival"]')).toContainText("slide");
  await settled(page);
  const before = (await calls(page)).length;

  await page.locator('[id$="--popup"]').click();
  await page.locator('[id$="--close"]').click();
  await expect(page.locator('[id$="--arrival"]')).toBeVisible();
  await expect(page.locator('[id$="--close"]')).toHaveCount(0);
  await settled(page);

  // the page re-displayed in place - the popup app never took the screen
  expect((await calls(page)).length).toBe(before);
});

test("an app's own screens: Next forward, Previous backward", async ({
  page,
}) => {
  await start(page);
  // while the pages move, BOTH steps are in the DOM - the leaving one and
  // the arriving one - so a step is found by its text, not by its id alone
  const step = (n) =>
    page.locator('[id$="--step"]', { hasText: `Step ${n} of` });
  await page.locator('[id$="--wizard"]').click();
  await expect(step(1)).toBeVisible();
  await settled(page);

  await page.locator('[id$="--next"]').click();
  await expect(step(2)).toBeVisible();
  await settled(page);
  await page.locator('[id$="--previous"]').click();
  await expect(step(1)).toBeVisible();
  await settled(page);

  const directions = (await moves(page)).map((m) => m.direction);
  expect(directions).toEqual(["to", "to", "backToPage"]);
});

test("the browser buttons under hash routing: Back reverses, Forward repeats", async ({
  page,
}) => {
  await start(page);
  await page.locator('[id$="--routing"]').click();
  await expect(page).toHaveURL(/#\/app\/ZCL_TST_ANIM_HUB\//);

  await page.locator('[id$="--go-fade"]').click();
  await expect(page.locator('[id$="--arrival"]')).toContainText("fade");
  await expect(page).toHaveURL(/#\/app\/ZCL_TST_ANIM_PAGE\//);
  await settled(page);

  await page.goBack();
  await expect(page.locator('[id$="--go-fade"]')).toBeVisible();
  await settled(page);
  await page.goForward();
  await expect(page.locator('[id$="--arrival"]')).toContainText("fade");
  await settled(page);

  const directions = (await moves(page)).map((m) => m.direction);
  expect(directions).toEqual(["to", "backToPage", "to"]);
});
