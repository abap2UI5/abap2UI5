// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");

// Tests the public z2ui5.Util date helpers shipped in app/webapp/Util.js.
// These are a documented public contract (exposed as the z2ui5.Util global),
// so their ABAP-date parsing must not change behavior.

const { module: Util } = loadModule("Util.js");

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
});

test.describe("DateCreateObject", () => {
  test("delegates to the Date constructor", () => {
    // no instanceof check: the module runs in its own vm realm, so its
    // Date constructor is not identical to the test runner's
    const d = Util.DateCreateObject("2026-07-02T13:45:01Z");
    expect(d.toISOString()).toBe("2026-07-02T13:45:01.000Z");
  });
});
