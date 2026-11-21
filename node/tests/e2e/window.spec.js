// @ts-check
// The windowed table: window_bind_tab( val = mt_rows total = mv_total
// event = `ROWS` window = n ) sends the rows the APP has loaded and the
// window state next to them; the list binding (core/WindowModel.js) asks
// the app for more rows, and for the first window of a new sort or filter.
// The app - node/srv/zcl_tst_window.clas.abap - loads, sorts, filters and
// counts itself, the way an OData service would: 250 rows in a growing
// sap.m.Table (window 50, event ROWS), a sap.ui.table.Table (window 30,
// event GRID) and a list behind a data reference (40 rows, window 10,
// event TAB).
//
// The first half drives the wire directly: what a response carries, what
// the framework event ___ZZZ_WIN turns into. The second half is the
// browser: growing, a search and a sort through BINDING_CALL, the column
// sort of sap.ui.table.
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

// what WindowModel sends: [path, app event, reason, skip, top] - and for
// SORT and FILTER the binding's sorters and filter groups
function more(id, path, event, skip, top) {
  return {
    ID: id,
    EVENT: EVENT,
    T_EVENT_ARG: [path, event, "MORE", String(skip), String(top)],
  };
}

function restart(id, path, event, reason, top, sort = [], filter = []) {
  return {
    ID: id,
    EVENT: EVENT,
    T_EVENT_ARG: [
      path,
      event,
      reason,
      "0",
      String(top),
      JSON.stringify(sort),
      JSON.stringify(filter),
    ],
  };
}

function expectSorted(rows, compare) {
  for (let i = 1; i < rows.length; i++) {
    expect(
      compare(rows[i - 1], rows[i]),
      `rows ${i - 1} and ${i}`,
    ).toBeLessThanOrEqual(0);
  }
}

test.describe("the wire", () => {
  test("the first response carries the loaded rows and the window state", async ({
    request,
  }) => {
    const first = await start(request);
    expect(first.MODEL.MT_ROWS).toHaveLength(50);
    expect(first.MODEL.MT_GRID).toHaveLength(30);
    expect(first.MODEL.__WINDOW.MT_ROWS).toEqual({
      TOTAL: 250,
      COUNT: 50,
      SIZE: 50,
      EVENT: "ROWS",
    });
    expect(first.MODEL.MT_ROWS[0].ID).toBe(1);
  });

  test("MORE is the app's event: it appends the next rows", async ({
    request,
  }) => {
    const first = await start(request);
    const second = await post(
      request,
      more(first.S_FRONT.ID, "/MT_ROWS", "ROWS", 50, 50),
    );
    expect(second.MODEL.MT_ROWS).toHaveLength(100);
    expect(second.MODEL.MT_ROWS[99].ID).toBe(100);
    expect(second.MODEL.__WINDOW.MT_ROWS.COUNT).toBe(100);
    // the other table keeps its rows
    expect(second.MODEL.MT_GRID).toHaveLength(30);
    // no view was rebuilt - the app only loaded rows
    const system = second.S_FRONT?.S_ACTION?.T_SYSTEM ?? [];
    expect(
      system.some((a) => a[0] === "VIEW_SLOTS" && a[1] === "display"),
    ).toBe(false);
  });

  test("SORT and FILTER hand the app the binding's state; the total follows the app", async ({
    request,
  }) => {
    const first = await start(request);
    const second = await post(
      request,
      restart(
        first.S_FRONT.ID,
        "/MT_ROWS",
        "ROWS",
        "FILTER",
        50,
        [{ PATH: "PRICE", DESCENDING: true }],
        [[["NAME", "Contains", "item 1"]]],
      ),
    );
    const rows = second.MODEL.MT_ROWS;
    // Item 1, 10-19, 100-199: 111 rows match, the first window of them -
    // the total is the app's attribute, read anew without a new view
    expect(second.MODEL.__WINDOW.MT_ROWS.TOTAL).toBe(111);
    expect(rows).toHaveLength(50);
    for (const row of rows) expect(row.NAME).toMatch(/^Item 1/);
    expectSorted(rows, (a, b) => b.PRICE - a.PRICE);
  });

  test("a delta lands in the row the browser shows - the table is what it shows", async ({
    request,
  }) => {
    const first = await start(request);
    const sorted = await post(
      request,
      restart(first.S_FRONT.ID, "/MT_ROWS", "ROWS", "SORT", 50, [
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
    expect(checked.MODEL.MV_RESULT).toBe(`${top.ID};${third.ID};`);
    expect(checked.MODEL.MT_ROWS[0].ID).toBe(top.ID);
    expect(checked.MODEL.MT_ROWS[0].SELECTED).toBe(true);
  });

  test("a row pressed is the row of the table with that index", async ({
    request,
  }) => {
    const first = await start(request);
    const sorted = await post(
      request,
      restart(first.S_FRONT.ID, "/MT_ROWS", "ROWS", "SORT", 50, [
        { PATH: "PRICE", DESCENDING: true },
      ]),
    );
    const pressed = await post(request, {
      ID: sorted.S_FRONT.ID,
      EVENT: "ROW",
      T_EVENT_ARG: ["/MT_ROWS/2"],
    });
    expect(pressed.MODEL.MV_RESULT).toBe(String(sorted.MODEL.MT_ROWS[2].ID));
  });

  test("a draft parsed back holds the loaded rows and the window state", async ({
    request,
  }) => {
    // This host hands out the live app the first time a draft id comes in;
    // the same id once more is parsed from the draft - the path every
    // request takes on a system
    const first = await start(request);
    const grown = await post(
      request,
      more(first.S_FRONT.ID, "/MT_ROWS", "ROWS", 50, 50),
    );
    await post(request, { ID: grown.S_FRONT.ID, EVENT: "CHECK" });
    const parsed = await post(request, { ID: grown.S_FRONT.ID, EVENT: "CHECK" });
    expect(parsed.MODEL?.MT_ROWS ?? grown.MODEL.MT_ROWS).toHaveLength(100);
    const next = await post(
      request,
      more(grown.S_FRONT.ID, "/MT_ROWS", "ROWS", 100, 50),
    );
    expect(next.MODEL.MT_ROWS).toHaveLength(150);
    expect(next.MODEL.__WINDOW.MT_ROWS).toEqual({
      TOTAL: 250,
      COUNT: 150,
      SIZE: 50,
      EVENT: "ROWS",
    });
  });
});

test.describe("the app owns the order", () => {
  test("a table behind a data reference is windowed under its own path", async ({
    request,
  }) => {
    const first = await start(request);
    expect(first.MODEL.MR_TAB["*"]).toHaveLength(10);
    expect(first.MODEL.__WINDOW.MR_TAB["*"]).toEqual({
      TOTAL: 40,
      COUNT: 10,
      SIZE: 10,
      EVENT: "TAB",
    });
    const second = await post(
      request,
      more(first.S_FRONT.ID, "/MR_TAB/*", "TAB", 10, 10),
    );
    expect(second.MODEL.MR_TAB["*"]).toHaveLength(20);
    expect(second.MODEL.MR_TAB["*"][19].ID).toBe(20);
  });

  test("an app-sorted list grows in the app's order", async ({ request }) => {
    const first = await start(request);
    const preset = await post(request, {
      ID: first.S_FRONT.ID,
      EVENT: "PRESET",
    });
    expect(preset.MODEL.MT_ROWS.map((row) => row.ID)).toEqual(
      Array.from({ length: 50 }, (_v, i) => 250 - i),
    );
    const grown = await post(
      request,
      more(preset.S_FRONT.ID, "/MT_ROWS", "ROWS", 50, 50),
    );
    expect(grown.MODEL.MT_ROWS.map((row) => row.ID)).toEqual(
      Array.from({ length: 100 }, (_v, i) => 250 - i),
    );
  });

  test("an app filter and a column filter are the app's to combine", async ({
    request,
  }) => {
    const first = await start(request);
    // Item 2, 20-29, 200-250: 62 rows
    const app = await post(request, {
      ID: first.S_FRONT.ID,
      EVENT: "FILTER",
      T_EVENT_ARG: ["Item 2"],
    });
    expect(app.MODEL.__WINDOW.MT_ROWS.TOTAL).toBe(62);
    // a column filter of the user narrows it: Item 25, 205, 215, ... 245
    const user = await post(
      request,
      restart(app.S_FRONT.ID, "/MT_ROWS", "ROWS", "FILTER", 50, [], [
        [["NAME", "EndsWith", "5"]],
      ]),
    );
    expect(user.MODEL.MT_ROWS.map((row) => row.ID)).toEqual([
      25, 205, 215, 225, 235, 245,
    ]);
    expect(user.MODEL.__WINDOW.MT_ROWS.TOTAL).toBe(6);
  });
});

test.describe("the browser", () => {
  test("growing asks the server for the next window", async ({ page }) => {
    await page.goto(`/?app_start=${APP}`);
    // the texts of the sap.m.Table - the other lists show items too
    const tab = page.locator("[id$='--tab']");
    await expect(tab.getByText("Item 20", { exact: true })).toBeVisible({
      timeout: 30000,
    });
    await expect(page.locator("[id$='--total']")).toHaveText("250 rows");

    // 20 rows a page: the first More stays in the window of 50 the
    // browser holds, the second needs the next window
    const more = page.locator("[id$='--tab-trigger']");
    await more.click();
    await expect(tab.getByText("Item 40", { exact: true })).toBeVisible();
    await expect(tab.getByText("Item 51", { exact: true })).toHaveCount(0);
    const request = page.waitForRequest((r) =>
      (r.postData() ?? "").includes(EVENT),
    );
    await more.click();
    await request;
    await expect(tab.getByText("Item 60", { exact: true })).toBeVisible();
  });

  test("a list the app sorted grows in the app's order", async ({ page }) => {
    await page.goto(`/?app_start=${APP}`);
    const tab = page.locator("[id$='--tab']");
    await expect(tab.getByText("Item 20", { exact: true })).toBeVisible({
      timeout: 30000,
    });

    // the list under the tables asks for its second window as it renders;
    // a click while that roundtrip runs is dropped, like any click
    await expect(
      page.locator("[id$='--list']").getByText("Item 20", { exact: true }),
    ).toBeVisible();

    // the app sorts: the highest id first
    await page.locator("[id$='--preset']").click();
    await expect(tab.getByText("Item 250", { exact: true })).toBeVisible();
    await expect(tab.getByText("Item 231", { exact: true })).toBeVisible();

    // 20 rows a page: the second More needs the next window - the app's
    // event, MORE, after the 50 rows loaded
    const more = page.locator("[id$='--tab-trigger']");
    await more.click();
    await expect(tab.getByText("Item 211", { exact: true })).toBeVisible();
    const request = page.waitForRequest((r) =>
      (r.postData() ?? "").includes(EVENT),
    );
    await more.click();
    const sent = JSON.parse((await request).postData() ?? "{}");
    expect((sent.value ?? sent).S_FRONT.T_EVENT_ARG).toEqual([
      "/MT_ROWS",
      "ROWS",
      "MORE",
      "50",
      "50",
    ]);

    // rows 41 to 60 continue the app's order: ids 210 down to 191
    await expect(tab.getByText("Item 191", { exact: true })).toBeVisible();
    await expect(tab.getByText(/^Item \d+$/)).toHaveText(
      Array.from({ length: 60 }, (_v, i) => `Item ${250 - i}`),
    );
  });

  test("a search and a sort run on the server", async ({ page }) => {
    await page.goto(`/?app_start=${APP}`);
    const tab = page.locator("[id$='--tab']");
    await expect(tab.getByText("Item 20", { exact: true })).toBeVisible({
      timeout: 30000,
    });

    const search = page.locator("[id$='--search'] input");
    await search.fill("item 24");
    await search.press("Enter");
    // Item 24, 240-249: eleven rows, counted over the whole table
    await expect(page.locator("[id$='--total']")).toHaveText("11 rows");
    await expect(tab.getByText("Item 245", { exact: true })).toBeVisible();
    await expect(tab.getByText("Item 20", { exact: true })).toHaveCount(0);

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
