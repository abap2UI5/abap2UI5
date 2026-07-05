// PUBLIC date helpers for apps: exposed as the z2ui5.Util global and as
// the z2ui5/Util module (used in XML view formatter strings). Part of the
// public contract - do not rename or change the existing functions.
sap.ui.define([], () => {
  "use strict";

  // Splits an 8-character ABAP date string "YYYYMMDD" into the [year, month,
  // day] tuple JavaScript's Date constructor expects. Note: Date months are
  // 0-based, so we subtract 1 from the month component.
  function parseYmd(d) {
    return [
      Number(d.slice(0, 4)),
      Number(d.slice(4, 6)) - 1,
      Number(d.slice(6, 8)),
    ];
  }

  return {
    DateCreateObject(s) {
      return new Date(s);
    },
    DateAbapDateToDateObject(d) {
      return new Date(...parseYmd(d));
    },
    // t is an ABAP time string "HHMMSS"; if omitted we default to midnight.
    DateAbapDateTimeToDateObject(d, t = "000000") {
      return new Date(
        ...parseYmd(d),
        Number(t.slice(0, 2)),
        Number(t.slice(2, 4)),
        Number(t.slice(4, 6)),
      );
    },
  };
});
