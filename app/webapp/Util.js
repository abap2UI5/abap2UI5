sap.ui.define([], () => {
  "use strict";

  // Splits an 8-character ABAP date string "YYYYMMDD" into the [year, month,
  // day] tuple JavaScript's Date constructor expects. Note: Date months are
  // 0-based, so we subtract 1 from the month component.
  function parseDmy(d) {
    return [+d.slice(0, 4), +d.slice(4, 6) - 1, +d.slice(6, 8)];
  }

  return {
    DateCreateObject(s) {
      return new Date(s);
    },
    DateAbapDateToDateObject(d) {
      return new Date(...parseDmy(d));
    },
    // t is an ABAP time string "HHMMSS"; if omitted we default to midnight.
    DateAbapDateTimeToDateObject(d, t = "000000") {
      return new Date(
        ...parseDmy(d),
        +t.slice(0, 2),
        +t.slice(2, 4),
        +t.slice(4, 6),
      );
    },
  };
});
