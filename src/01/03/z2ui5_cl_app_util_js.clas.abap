CLASS z2ui5_cl_app_util_js DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CLASS-METHODS get
      RETURNING
        VALUE(result) TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cl_app_util_js IMPLEMENTATION.

  METHOD get.

    result = `sap.ui.define([], () => {` && |\n| &&
             `  "use strict";` && |\n| &&
             `` && |\n| &&
             `  // Splits an 8-character ABAP date string "YYYYMMDD" into the [year, month,` && |\n| &&
             `  // day] tuple JavaScript's Date constructor expects. Note: Date months are` && |\n| &&
             `  // 0-based, so we subtract 1 from the month component.` && |\n| &&
             `  function parseDmy(d) {` && |\n| &&
             `    return [+d.slice(0, 4), +d.slice(4, 6) - 1, +d.slice(6, 8)];` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  return {` && |\n| &&
             `    DateCreateObject(s) {` && |\n| &&
             `      return new Date(s);` && |\n| &&
             `    },` && |\n| &&
             `    DateAbapDateToDateObject(d) {` && |\n| &&
             `      return new Date(...parseDmy(d));` && |\n| &&
             `    },` && |\n| &&
             `    // t is an ABAP time string "HHMMSS"; if omitted we default to midnight.` && |\n| &&
             `    DateAbapDateTimeToDateObject(d, t = "000000") {` && |\n| &&
             `      return new Date(` && |\n| &&
             `        ...parseDmy(d),` && |\n| &&
             `        +t.slice(0, 2),` && |\n| &&
             `        +t.slice(2, 4),` && |\n| &&
             `        +t.slice(4, 6),` && |\n| &&
             `      );` && |\n| &&
             `    },` && |\n| &&
             `  };` && |\n| &&
             `});` && |\n| &&
             `` && |\n| &&
              ``.

  ENDMETHOD.

ENDCLASS.
