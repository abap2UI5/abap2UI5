// @ts-check
// The windowed table: window_bind_tab( val = mt_rows window = n ) sends the browser
// n rows of the table, and its list binding (core/WindowModel.js) asks the
// backend for more, sorts and filters there. The fixture app is
// node/srv/zcl_tst_window.clas.abap - 250 rows in a growing sap.m.Table
// (window 50) and in a sap.ui.table.Table (window 30).
//
// The first half drives the wire directly: what a response carries, what
// the framework event ___ZZZ_WIN does, and where a delta of a sorted
// window lands. The second half is the browser: growing, a search and a
// sort through BINDING_CALL, the column sort of sap.ui.table.
//
// The order of a windowed table is kept on the server, and a request
// names only the part of it the binding was told to change: `grow` is the
// request for more rows (the path and the count, nothing else), `sortBy`
// and `filterBy` what sort( ) and filter( ) of the binding send.
// `windowEvent` names both in every request, an empty list included - the
// wire of the frontend before that, which a page left open over an update
// still speaks.
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

function grow(id, path, count) {
  return { ID: id, EVENT: EVENT, T_EVENT_ARG: [path, String(count)] };
}

function sortBy(id, path, count, sort) {
  return {
    ID: id,
    EVENT: EVENT,
    T_EVENT_ARG: [path, String(count), JSON.stringify(sort)],
  };
}

function filterBy(id, path, count, filter) {
  return {
    ID: id,
    EVENT: EVENT,
    T_EVENT_ARG: [path, String(count), "", JSON.stringify(filter)],
  };
}

// the order the server sorts text in: without regard to case, by code unit
function byName(a, b) {
  const x = a.NAME.toUpperCase();
  const y = b.NAME.toUpperCase();
  return x < y ? -1 : x > y ? 1 : 0;
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

test.describe("window_bind_tab( ) of the app", () => {
  test("a table behind a data reference is windowed under its own path", async ({
    request,
  }) => {
    const first = await start(request);
    // REF #( mt_grid ) binds the attribute itself
    expect(first.MODEL.MT_GRID).toHaveLength(30);
    // an attribute TYPE REF TO data binds what it points to
    expect(first.MODEL.MR_TAB["*"]).toHaveLength(10);
    expect(first.MODEL.__WINDOW.MR_TAB["*"]).toEqual({
      TOTAL: 40,
      COUNT: 10,
      SIZE: 10,
    });
    const second = await post(
      request,
      windowEvent(first.S_FRONT.ID, "/MR_TAB/*", 20),
    );
    expect(second.MODEL.MR_TAB["*"]).toHaveLength(20);
    expect(second.MODEL.MR_TAB["*"][19].ID).toBe(20);
  });

  test("the app's sort applies, and a render with the same sort keeps the user's", async ({
    request,
  }) => {
    const first = await start(request);
    // the app passes ID descending
    const preset = await post(request, {
      ID: first.S_FRONT.ID,
      EVENT: "PRESET",
    });
    expect(preset.MODEL.MT_ROWS[0].ID).toBe(250);

    // the user sorts by name in the browser
    const user = await post(
      request,
      windowEvent(preset.S_FRONT.ID, "/MT_ROWS", 50, [
        { PATH: "NAME", DESCENDING: false },
      ]),
    );
    expect(user.MODEL.MT_ROWS[0].NAME).toBe("Item 1");
    expect(user.MODEL.MT_ROWS[1].NAME).toBe("Item 10");

    // the view rendered again with the app's unchanged sort: the user's stays
    const again = await post(request, {
      ID: user.S_FRONT.ID,
      EVENT: "RERENDER",
    });
    expect(again.MODEL.MT_ROWS[0].NAME).toBe("Item 1");
    expect(again.MODEL.MT_ROWS[1].NAME).toBe("Item 10");
  });
});

// Report: #3019 - the order the app passed survived until the first window
// request: every request carried the binding's own sorters and filters,
// empty for an order the app had set, and the server took them as the order
test.describe("the order is the server's, a request for rows keeps it", () => {
  test("an app-sorted list grows in the app's order, and a row and an edit follow it", async ({
    request,
  }) => {
    const first = await start(request);
    const preset = await post(request, {
      ID: first.S_FRONT.ID,
      EVENT: "PRESET",
    });
    expect(preset.MODEL.MT_ROWS.map((row) => row.ID)).toEqual(
      Array.from({ length: 50 }, (_v, i) => 250 - i),
    );

    const grown = await post(request, grow(preset.S_FRONT.ID, "/MT_ROWS", 100));
    // rows 51 to 100 continue the first window: ids 250 down to 151
    expect(grown.MODEL.MT_ROWS.map((row) => row.ID)).toEqual(
      Array.from({ length: 100 }, (_v, i) => 250 - i),
    );
    expect(grown.MODEL.__WINDOW.MT_ROWS).toEqual({
      TOTAL: 250,
      COUNT: 100,
      SIZE: 50,
    });

    // window_get_row( ): position 60 of what the browser shows is id 191
    const pressed = await post(request, {
      ID: grown.S_FRONT.ID,
      EVENT: "ROW",
      T_EVENT_ARG: ["/MT_ROWS/59"],
    });
    expect(pressed.MODEL.MV_RESULT).toBe("191");

    // a cell edited in a row past the first window lands in that row
    const checked = await post(
      request,
      { ID: pressed.S_FRONT.ID, EVENT: "CHECK" },
      { MT_ROWS: { __delta: { 59: { SELECTED: true } } } },
    );
    expect(checked.MODEL.MV_RESULT).toBe("191;");
    expect(checked.MODEL.MT_ROWS[59]).toMatchObject({
      ID: 191,
      SELECTED: true,
    });

    // the view rendered again with the same t_sort: the order and the rows
    // the browser holds stay
    const again = await post(request, {
      ID: checked.S_FRONT.ID,
      EVENT: "RERENDER",
    });
    expect(again.MODEL.MT_ROWS).toHaveLength(100);
    expect(again.MODEL.MT_ROWS[0].ID).toBe(250);
    expect(again.MODEL.MT_ROWS[99].ID).toBe(151);
  });

  test("an app-filtered list grows inside the app's filter", async ({
    request,
  }) => {
    const first = await start(request);
    // Item 2, 20-29, 200-250: 62 rows
    const filtered = await post(request, {
      ID: first.S_FRONT.ID,
      EVENT: "FILTER",
      T_EVENT_ARG: ["Item 2"],
    });
    expect(filtered.MODEL.__WINDOW.MT_ROWS.TOTAL).toBe(62);
    expect(filtered.MODEL.MT_ROWS).toHaveLength(50);

    const grown = await post(
      request,
      grow(filtered.S_FRONT.ID, "/MT_ROWS", 100),
    );
    expect(grown.MODEL.__WINDOW.MT_ROWS.TOTAL).toBe(62);
    expect(grown.MODEL.MT_ROWS).toHaveLength(62);
    for (const row of grown.MODEL.MT_ROWS) expect(row.NAME).toMatch(/^Item 2/);

    // a frontend from before names an empty filter in every request: that
    // is the binding's filter, not the app's - the app's still holds
    const old = await post(
      request,
      windowEvent(grown.S_FRONT.ID, "/MT_ROWS", 100),
    );
    expect(old.MODEL.__WINDOW.MT_ROWS.TOTAL).toBe(62);
  });

  test("the user's sort replaces the app's, grows, and gives way to a new one of the app", async ({
    request,
  }) => {
    const first = await start(request);
    const preset = await post(request, {
      ID: first.S_FRONT.ID,
      EVENT: "PRESET",
    });
    // the user sorts by name: sort( ) of the binding names the sort alone
    const user = await post(
      request,
      sortBy(preset.S_FRONT.ID, "/MT_ROWS", 50, [
        { PATH: "NAME", DESCENDING: false },
      ]),
    );
    expect(user.MODEL.MT_ROWS[0].NAME).toBe("Item 1");

    const grown = await post(request, grow(user.S_FRONT.ID, "/MT_ROWS", 100));
    expect(grown.MODEL.MT_ROWS).toHaveLength(100);
    expect(grown.MODEL.MT_ROWS[0].NAME).toBe("Item 1");
    expectSorted(grown.MODEL.MT_ROWS, byName);

    // the app passes another sort: it replaces the user's, from the first
    // window
    const price = await post(request, {
      ID: grown.S_FRONT.ID,
      EVENT: "PRESET_PRICE",
    });
    expect(price.MODEL.MT_ROWS).toHaveLength(50);
    expect(price.MODEL.MT_ROWS[0].PRICE).toBe(1);
    expectSorted(price.MODEL.MT_ROWS, (a, b) => a.PRICE - b.PRICE);

    // and the next rows are rows of the app's new order - the request does
    // not bring the user's sort back
    const more = await post(request, grow(price.S_FRONT.ID, "/MT_ROWS", 100));
    expect(more.MODEL.MT_ROWS).toHaveLength(100);
    expect(more.MODEL.MT_ROWS[0].PRICE).toBe(1);
    expectSorted(more.MODEL.MT_ROWS, (a, b) => a.PRICE - b.PRICE);
  });

  test("the app's filter and the binding's are ANDed, each replaced alone", async ({
    request,
  }) => {
    const first = await start(request);
    const app = await post(request, {
      ID: first.S_FRONT.ID,
      EVENT: "FILTER",
      T_EVENT_ARG: ["Item 2"],
    });
    expect(app.MODEL.__WINDOW.MT_ROWS.TOTAL).toBe(62);

    // a column filter of the user narrows it: Item 25, 205, 215, ... 245
    const user = await post(
      request,
      filterBy(app.S_FRONT.ID, "/MT_ROWS", 50, [[["NAME", "EndsWith", "5"]]]),
    );
    expect(user.MODEL.MT_ROWS.map((row) => row.ID)).toEqual([
      25, 205, 215, 225, 235, 245,
    ]);

    // a sort of the binding names no filter: both stay
    const sorted = await post(
      request,
      sortBy(user.S_FRONT.ID, "/MT_ROWS", 50, [
        { PATH: "ID", DESCENDING: true },
      ]),
    );
    expect(sorted.MODEL.MT_ROWS.map((row) => row.ID)).toEqual([
      245, 235, 225, 215, 205, 25,
    ]);

    // the app passes another filter: its own part changes, the user's
    // column filter and the user's sort stay - Item 15, 105, 115, ... 195
    const other = await post(request, {
      ID: sorted.S_FRONT.ID,
      EVENT: "FILTER",
      T_EVENT_ARG: ["Item 1"],
    });
    expect(other.MODEL.MT_ROWS.map((row) => row.ID)).toEqual([
      195, 185, 175, 165, 155, 145, 135, 125, 115, 105, 15,
    ]);

    // the user clears the column filter: what the app filters is left
    const cleared = await post(
      request,
      filterBy(other.S_FRONT.ID, "/MT_ROWS", 50, []),
    );
    expect(cleared.MODEL.__WINDOW.MT_ROWS.TOTAL).toBe(111);

    // and the app clears its own
    const all = await post(request, {
      ID: cleared.S_FRONT.ID,
      EVENT: "FILTER",
    });
    expect(all.MODEL.__WINDOW.MT_ROWS.TOTAL).toBe(250);
    expect(all.MODEL.MT_ROWS[0].ID).toBe(250);
  });
});

test.describe("window_get_row( )", () => {
  test("the row a sorted window shows is the table's row it names", async ({
    request,
  }) => {
    const first = await start(request);
    const sorted = await post(
      request,
      windowEvent(first.S_FRONT.ID, "/MT_ROWS", 50, [
        { PATH: "PRICE", DESCENDING: true },
      ]),
    );
    const third = sorted.MODEL.MT_ROWS[2];
    const pressed = await post(request, {
      ID: sorted.S_FRONT.ID,
      EVENT: "ROW",
      T_EVENT_ARG: ["/MT_ROWS/2"],
    });
    expect(pressed.MODEL.MV_RESULT).toBe(String(third.ID));
  });

  test("a position past the filter names no row", async ({ request }) => {
    const first = await start(request);
    const filtered = await post(
      request,
      windowEvent(first.S_FRONT.ID, "/MT_ROWS", 50, [], [
        [["NAME", "EQ", "Item 7"]],
      ]),
    );
    expect(filtered.MODEL.__WINDOW.MT_ROWS.TOTAL).toBe(1);
    const pressed = await post(request, {
      ID: filtered.S_FRONT.ID,
      EVENT: "ROW",
      T_EVENT_ARG: ["/MT_ROWS/1"],
    });
    expect(pressed.MODEL.MV_RESULT).toBe("none");
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

    // the app passes t_sort: the highest id first
    await page.locator("[id$='--preset']").click();
    await expect(tab.getByText("Item 250", { exact: true })).toBeVisible();
    await expect(tab.getByText("Item 231", { exact: true })).toBeVisible();

    // 20 rows a page: the second More needs the next window. The binding
    // was told no order, so the request names none - only the rows
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
      "100",
    ]);

    // rows 41 to 60 continue the order: ids 210 down to 191 - they came
    // back as Item 51 to 60 of the table's own order
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
