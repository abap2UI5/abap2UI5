// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");

// Tests the public date helpers of z2ui5/model/formatter - a documented
// public contract, so their ABAP-date parsing must not change behavior.

const { module: Formatter } = loadModule("model/formatter.js");

test.describe("DateAbapDateToDateObject (ABAP date YYYYMMDD)", () => {
  test("parses year, month and day", () => {
    const d = Formatter.DateAbapDateToDateObject("20260702");
    expect(d.getFullYear()).toBe(2026);
    expect(d.getMonth()).toBe(6); // JS months are 0-based: July = 6
    expect(d.getDate()).toBe(2);
  });

  test("parses January without an off-by-one month", () => {
    const d = Formatter.DateAbapDateToDateObject("20250101");
    expect(d.getFullYear()).toBe(2025);
    expect(d.getMonth()).toBe(0);
    expect(d.getDate()).toBe(1);
  });

  test("parses December 31st", () => {
    const d = Formatter.DateAbapDateToDateObject("20251231");
    expect(d.getMonth()).toBe(11);
    expect(d.getDate()).toBe(31);
  });

  test("defaults the time to midnight", () => {
    const d = Formatter.DateAbapDateToDateObject("20260702");
    expect(d.getHours()).toBe(0);
    expect(d.getMinutes()).toBe(0);
    expect(d.getSeconds()).toBe(0);
  });

  test("handles a leap day", () => {
    const d = Formatter.DateAbapDateToDateObject("20240229");
    expect(d.getMonth()).toBe(1);
    expect(d.getDate()).toBe(29);
  });

  test("yields null for a date that carries no date", () => {
    // "00000000" is the INITIAL value of an ABAP DATS field and arrives on
    // every row with an unfilled date. Feeding it to the Date constructor
    // produced 1899-11-30 - a plausible-looking wrong date the app then
    // displayed as if it were real.
    expect(Formatter.DateAbapDateToDateObject("00000000")).toBeNull();
    // partially zeroed forms are no dates either
    expect(Formatter.DateAbapDateToDateObject("00000101")).toBeNull();
    expect(Formatter.DateAbapDateToDateObject("20250000")).toBeNull();
    expect(Formatter.DateAbapDateToDateObject("20250100")).toBeNull();
    // an empty / malformed value keeps yielding null rather than an
    // Invalid Date (which is truthy and only blows up inside a calendar)
    expect(Formatter.DateAbapDateToDateObject("")).toBeNull();
    expect(Formatter.DateAbapDateToDateObject("2025-1-1")).toBeNull();
    expect(Formatter.DateAbapDateToDateObject("0000-00-00")).toBeNull();
    expect(Formatter.DateAbapDateToDateObject(undefined)).toBeNull();
  });
});

test.describe("DateAbapDateTimeToDateObject (ABAP date + time HHMMSS)", () => {
  test("parses date and time components", () => {
    const d = Formatter.DateAbapDateTimeToDateObject("20260702", "134501");
    expect(d.getFullYear()).toBe(2026);
    expect(d.getMonth()).toBe(6);
    expect(d.getDate()).toBe(2);
    expect(d.getHours()).toBe(13);
    expect(d.getMinutes()).toBe(45);
    expect(d.getSeconds()).toBe(1);
  });

  test("defaults to midnight when the time is omitted", () => {
    const d = Formatter.DateAbapDateTimeToDateObject("20260702");
    expect(d.getHours()).toBe(0);
    expect(d.getMinutes()).toBe(0);
    expect(d.getSeconds()).toBe(0);
  });

  test("parses the end of the day", () => {
    const d = Formatter.DateAbapDateTimeToDateObject("20251231", "235959");
    expect(d.getHours()).toBe(23);
    expect(d.getMinutes()).toBe(59);
    expect(d.getSeconds()).toBe(59);
  });

  test("yields null for a date that carries no date", () => {
    // same guard as the date-only helper - a filled time does not make an
    // initial date a date
    expect(Formatter.DateAbapDateTimeToDateObject("00000000")).toBeNull();
    expect(
      Formatter.DateAbapDateTimeToDateObject("00000000", "134501"),
    ).toBeNull();
    expect(Formatter.DateAbapDateTimeToDateObject("")).toBeNull();
  });

  // a default parameter covers undefined only - a bound time field that is
  // null or empty in the model reached t.slice and threw inside the binding
  test("a null or empty time is midnight, not a throw", () => {
    for (const t of [null, ""]) {
      const d = Formatter.DateAbapDateTimeToDateObject("20260702", t);
      expect(d.getDate()).toBe(2);
      expect(d.getHours()).toBe(0);
      expect(d.getMinutes()).toBe(0);
    }
  });
});

test.describe("DateCreateObject", () => {
  test("delegates to the Date constructor", () => {
    // no instanceof check: the module runs in its own vm realm, so its
    // Date constructor is not identical to the test runner's
    const d = Formatter.DateCreateObject("2026-07-02T13:45:01Z");
    expect(d.toISOString()).toBe("2026-07-02T13:45:01.000Z");
  });
});

// A bound DATS / TIMS field reaches the model as "YYYY-MM-DD" / "HH:MM:SS"
// (ajson format_datetime, pinned by srv_model values_per_form); the raw
// digit forms come from CHAR / NUMC fields. Both mean the same value.
test.describe("the model's own date and time spelling", () => {
  test("a DATS field's YYYY-MM-DD is a date", () => {
    const d = Formatter.DateAbapDateToDateObject("2024-01-15");
    expect([d.getFullYear(), d.getMonth(), d.getDate()]).toEqual([2024, 0, 15]);
  });

  test("a TIMS field's HH:MM:SS is a time, with either date form", () => {
    for (const day of ["20240115", "2024-01-15"]) {
      const d = Formatter.DateAbapDateTimeToDateObject(day, "12:30:45");
      expect([d.getDate(), d.getHours(), d.getMinutes(), d.getSeconds()])
        .toEqual([15, 12, 30, 45]);
    }
  });

  test("DateCreateObject reads a bare day as the LOCAL day", () => {
    const d = Formatter.DateCreateObject("2024-01-15");
    expect([d.getFullYear(), d.getMonth(), d.getDate(), d.getHours()])
      .toEqual([2024, 0, 15, 0]);
  });
});

// The Date constructor reads a year below 100 as 19xx and rolls a day the
// month does not have into the next month. An ABAP date carries neither
// meaning: "00010101" is the low boundary of a validity range, and
// "20240230" is an unchecked value from somewhere else - shown as March 1,
// a real-looking wrong date.
test.describe("a year below 100 and a day the calendar does not have", () => {
  test("a year below 100 stays that year, in every helper", () => {
    const parts = (d) => [d.getFullYear(), d.getMonth(), d.getDate()];
    expect(parts(Formatter.DateAbapDateToDateObject("00010101"))).toEqual([
      1, 0, 1,
    ]);
    expect(
      parts(Formatter.DateAbapDateTimeToDateObject("00991231", "120000")),
    ).toEqual([99, 11, 31]);
    expect(parts(Formatter.DateCreateObject("0050-06-15"))).toEqual([
      50, 5, 15,
    ]);
  });

  test("a day the month does not have is no date, not the next month", () => {
    expect(Formatter.DateAbapDateToDateObject("20240230")).toBeNull();
    expect(Formatter.DateAbapDateToDateObject("20230229")).toBeNull();
    expect(Formatter.DateAbapDateToDateObject("20241301")).toBeNull();
    expect(
      Formatter.DateAbapDateTimeToDateObject("20240431", "080000"),
    ).toBeNull();
    expect(Formatter.DateCreateObject("2024-02-30")).toBeNull();
  });

  test("the time still lands on the day it was given", () => {
    const d = Formatter.DateAbapDateTimeToDateObject("00010101", "134501");
    expect([d.getFullYear(), d.getHours(), d.getMinutes(), d.getSeconds()])
      .toEqual([1, 13, 45, 1]);
  });
});
