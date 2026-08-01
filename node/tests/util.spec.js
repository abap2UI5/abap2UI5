// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");

// Tests the public z2ui5.Util date helpers - a documented public contract
// (exposed as the z2ui5.Util global), so their ABAP-date parsing must not
// change behavior. The implementations live in z2ui5/model/formatter;
// Util.js re-exports them as the legacy alias, and these tests exercise
// them through that alias on purpose.

const { module: Formatter } = loadModule("model/formatter.js");
const { module: Util } = loadModule("Util.js", {
  deps: { "z2ui5/model/formatter": Formatter },
});

test.describe("DateAbapDateToDateObject (ABAP date YYYYMMDD)", () => {
  test("parses year, month and day", () => {
    const d = Util.DateAbapDateToDateObject("20260702");
    expect(d.getFullYear()).toBe(2026);
    expect(d.getMonth()).toBe(6); // JS months are 0-based: July = 6
    expect(d.getDate()).toBe(2);
  });

  test("parses January without an off-by-one month", () => {
    const d = Util.DateAbapDateToDateObject("20250101");
    expect(d.getFullYear()).toBe(2025);
    expect(d.getMonth()).toBe(0);
    expect(d.getDate()).toBe(1);
  });

  test("parses December 31st", () => {
    const d = Util.DateAbapDateToDateObject("20251231");
    expect(d.getMonth()).toBe(11);
    expect(d.getDate()).toBe(31);
  });

  test("defaults the time to midnight", () => {
    const d = Util.DateAbapDateToDateObject("20260702");
    expect(d.getHours()).toBe(0);
    expect(d.getMinutes()).toBe(0);
    expect(d.getSeconds()).toBe(0);
  });

  test("handles a leap day", () => {
    const d = Util.DateAbapDateToDateObject("20240229");
    expect(d.getMonth()).toBe(1);
    expect(d.getDate()).toBe(29);
  });

  test("yields null for a date that carries no date", () => {
    // "00000000" is the INITIAL value of an ABAP DATS field and arrives on
    // every row with an unfilled date. Feeding it to the Date constructor
    // produced 1899-11-30 - a plausible-looking wrong date the app then
    // displayed as if it were real.
    expect(Util.DateAbapDateToDateObject("00000000")).toBeNull();
    // partially zeroed forms are no dates either
    expect(Util.DateAbapDateToDateObject("00000101")).toBeNull();
    expect(Util.DateAbapDateToDateObject("20250000")).toBeNull();
    expect(Util.DateAbapDateToDateObject("20250100")).toBeNull();
    // an empty / malformed value keeps yielding null rather than an
    // Invalid Date (which is truthy and only blows up inside a calendar)
    expect(Util.DateAbapDateToDateObject("")).toBeNull();
    expect(Util.DateAbapDateToDateObject("2025-01-01")).toBeNull();
    expect(Util.DateAbapDateToDateObject(undefined)).toBeNull();
  });
});

test.describe("DateAbapDateTimeToDateObject (ABAP date + time HHMMSS)", () => {
  test("parses date and time components", () => {
    const d = Util.DateAbapDateTimeToDateObject("20260702", "134501");
    expect(d.getFullYear()).toBe(2026);
    expect(d.getMonth()).toBe(6);
    expect(d.getDate()).toBe(2);
    expect(d.getHours()).toBe(13);
    expect(d.getMinutes()).toBe(45);
    expect(d.getSeconds()).toBe(1);
  });

  test("defaults to midnight when the time is omitted", () => {
    const d = Util.DateAbapDateTimeToDateObject("20260702");
    expect(d.getHours()).toBe(0);
    expect(d.getMinutes()).toBe(0);
    expect(d.getSeconds()).toBe(0);
  });

  test("parses the end of the day", () => {
    const d = Util.DateAbapDateTimeToDateObject("20251231", "235959");
    expect(d.getHours()).toBe(23);
    expect(d.getMinutes()).toBe(59);
    expect(d.getSeconds()).toBe(59);
  });

  test("yields null for a date that carries no date", () => {
    // same guard as the date-only helper - a filled time does not make an
    // initial date a date
    expect(Util.DateAbapDateTimeToDateObject("00000000")).toBeNull();
    expect(Util.DateAbapDateTimeToDateObject("00000000", "134501")).toBeNull();
    expect(Util.DateAbapDateTimeToDateObject("")).toBeNull();
  });
});

test.describe("DateCreateObject", () => {
  test("delegates to the Date constructor", () => {
    // no instanceof check: the module runs in its own vm realm, so its
    // Date constructor is not identical to the test runner's
    const d = Util.DateCreateObject("2026-07-02T13:45:01Z");
    expect(d.toISOString()).toBe("2026-07-02T13:45:01.000Z");
  });
});
