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

    result = `// PUBLIC date helpers for apps: exposed as the z2ui5.Util global and as` && |\n| &&
             `// the z2ui5/Util module (used in XML view formatter strings). Part of the` && |\n| &&
             `// public contract - do not rename or change the existing functions.` && |\n| &&
             `sap.ui.define([], () => {` && |\n| &&
             `  "use strict";` && |\n| &&
             `` && |\n| &&
             `  // Splits an 8-character ABAP date string "YYYYMMDD" into the [year, month,` && |\n| &&
             `  // day] tuple JavaScript's Date constructor expects. Note: Date months are` && |\n| &&
             `  // 0-based, so we subtract 1 from the month component.` && |\n| &&
             `  function parseYmd(d) {` && |\n| &&
             `    return [` && |\n| &&
             `      Number(d.slice(0, 4)),` && |\n| &&
             `      Number(d.slice(4, 6)) - 1,` && |\n| &&
             `      Number(d.slice(6, 8)),` && |\n| &&
             `    ];` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  return {` && |\n| &&
             `    DateCreateObject(s) {` && |\n| &&
             `      return new Date(s);` && |\n| &&
             `    },` && |\n| &&
             `    DateAbapDateToDateObject(d) {` && |\n| &&
             `      return new Date(...parseYmd(d));` && |\n| &&
             `    },` && |\n| &&
             `    // t is an ABAP time string "HHMMSS"; if omitted we default to midnight.` && |\n| &&
             `    DateAbapDateTimeToDateObject(d, t = "000000") {` && |\n| &&
             `      return new Date(` && |\n| &&
             `        ...parseYmd(d),` && |\n| &&
             `        Number(t.slice(0, 2)),` && |\n| &&
             `        Number(t.slice(2, 4)),` && |\n| &&
             `        Number(t.slice(4, 6)),` && |\n| &&
             `      );` && |\n| &&
             `    },` && |\n| &&
             `  };` && |\n| &&
             `});` && |\n| &&
             `` && |\n| &&
              ``.

  ENDMETHOD.

ENDCLASS.
