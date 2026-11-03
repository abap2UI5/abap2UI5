// @ts-check
// The windowed table: _bind( val = mt_rows window = n ) sends the browser
// n rows of the table, and its list binding (core/WindowModel.js) asks the
// backend for more, sorts and filters there. The fixture app is
// node/srv/zcl_tst_window.clas.abap - 250 rows in a growing sap.m.Table
// (window 50) and in a sap.ui.table.Table (window 30).
//
// The first half drives the wire directly: what a response carries, what
// the framework event ___ZZZ_WIN does, and where a delta of a sorted
// window lands. The second half is the browser: growing, a search and a
// sort through BINDING_CALL, the column sort of sap.ui.table.
const { test, expect } = require("./fixtures");

const APP = "zcl_tst_window";
const EVENT = "___ZZZ_WIN";

function body(sFront, model) {
  return {
    value: {
      S_FRONT: {
        ORIGIN: "http://localhost:3000",
        PATHNAME: "/",
        SEARCH: "",
        ...sFront,
      },
      ...(model ? { MODEL: model } : {}),
    },
  };
}

async function post(request, sFront, model) {
  return (await request.post("/", { data: body(sFront, model) })).json();
}

async function start(request) {
  return post(request, { SEARCH: `?app_start=${APP}` });
}

function windowEvent(id, path, count, sort = [], filter = []) {
  return {
    ID: id,
    EVENT: EVENT,
    T_EVENT_ARG: [
      path,
      String(count),
      JSON.stringify(sort),
      JSON.stringify(filter),
    ],
  };
}

test.describe("the wire", () => {
  test("the first response carries one window and its state", async ({
    request,
  }) => {
    const first = await start(request);
    expect(first.MODEL.MT_ROWS).toHaveLength(50);
    expect(first.MODEL.MT_GRID).toHaveLength(30);
    expect(first.MODEL.__WINDOW.MT_ROWS).toEqual({
      TOTAL: 250,
      COUNT: 50,
      SIZE: 50,
    });
    expect(first.MODEL.MT_ROWS[0].ID).toBe(1);
  });

  test("the window event grows the window without the app", async ({
    request,
  }) => {
    const first = await start(request);
    const second = await post(
      request,
      windowEvent(first.S_FRONT.ID, "/MT_ROWS", 100),
    );
    expect(second.MODEL.MT_ROWS).toHaveLength(100);
    expect(second.MODEL.__WINDOW.MT_ROWS.COUNT).toBe(100);
    // the other table keeps its own window
    expect(second.MODEL.MT_GRID).toHaveLength(30);
    // no view was rebuilt - the framework answered, not the app
    const system = second.S_FRONT?.S_ACTION?.T_SYSTEM ?? [];
    expect(
      system.some((a) => a[0] === "VIEW_SLOTS" && a[1] === "display"),
    ).toBe(false);
  });

  test("sorts and filters all rows on the server", async ({ request }) => {
    const first = await start(request);
    const second = await post(
      request,
      windowEvent(
        first.S_FRONT.ID,
        "/MT_ROWS",
        50,
        [{ PATH: "PRICE", DESCENDING: true }],
        [[["NAME", "Contains", "item 1"]]],
      ),
    );
    const rows = second.MODEL.MT_ROWS;
    // Item 1, 10-19, 100-199: 111 rows match, the first window of them
    expect(second.MODEL.__WINDOW.MT_ROWS.TOTAL).toBe(111);
    expect(rows).toHaveLength(50);
    for (const row of rows) expect(row.NAME).toMatch(/^Item 1/);
    for (let i = 1; i < rows.length; i++) {
      expect(rows[i - 1].PRICE).toBeGreaterThanOrEqual(rows[i].PRICE);
    }
  });

  test("a delta of a sorted window lands in the row it was made in", async ({
    request,
  }) => {
    const first = await start(request);
    const sorted = await post(
      request,
      windowEvent(first.S_FRONT.ID, "/MT_ROWS", 50, [
        { PATH: "PRICE", DESCENDING: true },
      ]),
    );
    const top = sorted.MODEL.MT_ROWS[0];
    const third = sorted.MODEL.MT_ROWS[2];
    const checked = await post(
      request,
      { ID: sorted.S_FRONT.ID, EVENT: "CHECK" },
      {
        MT_ROWS: {
          __delta: { 0: { SELECTED: true }, 2: { SELECTED: true } },
        },
      },
    );
    // the app reads the table in its own order: by id
    const ids = [top.ID, third.ID].sort((a, b) => a - b);
    expect(checked.MODEL.MV_RESULT).toBe(`${ids[0]};${ids[1]};`);
    // and the response still shows the sorted window, the edits in it
    expect(checked.MODEL.MT_ROWS[0].ID).toBe(top.ID);
    expect(checked.MODEL.MT_ROWS[0].SELECTED).toBe(true);
  });

  test("a whole table sent back is refused, not written", async ({
    request,
  }) => {
    const first = await start(request);
    const second = await post(
      request,
      { ID: first.S_FRONT.ID, EVENT: "CHECK" },
      { MT_ROWS: [{ ID: 1, NAME: "x", PRICE: 0, SELECTED: true }] },
    );
    // nothing bound changed: no model goes out at all
    expect(second.MODEL?.MV_RESULT ?? "").toBe("");
    // and the table is the one it was - all 250 rows, row 1 untouched
    const third = await post(
      request,
      windowEvent(second.S_FRONT.ID, "/MT_ROWS", 50),
    );
    expect(third.MODEL.__WINDOW.MT_ROWS.TOTAL).toBe(250);
    expect(third.MODEL.MT_ROWS[0]).toMatchObject({
      ID: 1,
      NAME: "Item 1",
      SELECTED: false,
    });
  });
});

test.describe("the browser", () => {
  test("growing asks the server for the next window", async ({ page }) => {
    await page.goto(`/?app_start=${APP}`);
    await expect(page.getByText("Item 20", { exact: true })).toBeVisible({
      timeout: 30000,
    });
    await expect(page.locator("[id$='--total']")).toHaveText("250 rows");

    // 20 rows a page: the first More stays in the window of 50 the
    // browser holds, the second needs the next window
    const more = page.locator("[id$='--tab-trigger']");
    await more.click();
    await expect(page.getByText("Item 40", { exact: true })).toBeVisible();
    await expect(page.getByText("Item 51", { exact: true })).toHaveCount(0);
    const request = page.waitForRequest((r) =>
      (r.postData() ?? "").includes(EVENT),
    );
    await more.click();
    await request;
    await expect(page.getByText("Item 60", { exact: true })).toBeVisible();
  });

  test("a search and a sort run on the server", async ({ page }) => {
    await page.goto(`/?app_start=${APP}`);
    await expect(page.getByText("Item 20", { exact: true })).toBeVisible({
      timeout: 30000,
    });

    const search = page.locator("[id$='--search'] input");
    await search.fill("item 24");
    await search.press("Enter");
    // Item 24, 240-249: eleven rows, counted over the whole table
    await expect(page.locator("[id$='--total']")).toHaveText("11 rows");
    await expect(page.getByText("Item 245", { exact: true })).toBeVisible();
    await expect(page.getByText("Item 20", { exact: true })).toHaveCount(0);

    await page.locator("[id$='--sortPrice']").click();
    const firstRow = page.locator("[id$='--tab-tblBody'] tr").first();
    // the highest price of the eleven: ( id * 37 ) MOD 251
    const prices = [24, ...Array.from({ length: 10 }, (_, i) => 240 + i)].map(
      (id) => ({ id, price: (id * 37) % 251 }),
    );
    prices.sort((a, b) => b.price - a.price);
    await expect(
      firstRow.getByText(`Item ${prices[0].id}`, { exact: true }),
    ).toBeVisible();
  });

  test("sap.ui.table scrolls into the next window and sorts on the server", async ({
    page,
  }) => {
    await page.goto(`/?app_start=${APP}`);
    const grid = page.locator("[id$='--grid']");
    await expect(grid.getByText("Item 10", { exact: true })).toBeVisible({
      timeout: 30000,
    });

    // past the 30 rows the browser holds: the table asks for contexts the
    // binding does not have, and the binding asks the server
    const request = page.waitForRequest((r) =>
      (r.postData() ?? "").includes("/MT_GRID"),
    );
    await page.evaluate(() => {
      const table = sap.ui
        .getCore()
        .byId(document.querySelector("[id$='--grid']").id);
      table.setFirstVisibleRow(28);
    });
    await request;
    await expect(grid.getByText("Item 37", { exact: true })).toBeVisible();

    // the column sort goes to the binding, the binding to the server: the
    // largest name of all 250, not of the 30 the browser held
    await page.evaluate(() => {
      const table = sap.ui
        .getCore()
        .byId(document.querySelector("[id$='--grid']").id);
      table.setFirstVisibleRow(0);
      table.sort(table.getColumns()[0], "Descending");
    });
    await expect(grid.getByText("Item 99", { exact: true })).toBeVisible();
    await expect(grid.getByText("Item 98", { exact: true })).toBeVisible();
  });
});
