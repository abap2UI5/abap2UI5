CLASS z2ui5_cl_fw_cc_util DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CLASS-METHODS get_js
      RETURNING
        VALUE(result) TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_fw_cc_util IMPLEMENTATION.

  METHOD get_js.

    result = `sap.ui.define("z2ui5/Util" , ["sap/ui/core/Control"], (Control)=>{` && |\n| &&
             `        "use strict";` && |\n| &&
             `        return {` && |\n| &&
             `        DateCreateObject: (s) => new Date(s),` && |\n| &&
             `        DateAbapTimestampToDate: (sTimestamp) => new sap.gantt.misc.Format.abapTimestampToDate(sTimestamp),` && |\n| &&
             `        DateAbapDateToDateObject: (d) => new Date(d.slice(0, 4), parseInt(d.slice(4, 6)) - 1, d.slice(6, 8)),` && |\n| &&
             `        DateAbapDateTimeToDateObject: (d, t = '000000') => new Date(d.slice(0, 4), ` && |\n| &&
             `                   parseInt(d.slice(4, 6)) - 1, d.slice(6, 8), t.slice(0, 2), t.slice(2, 4), t.slice(4, 6)),` && |\n| &&
             `        };` && |\n| &&
             `  });`.

  ENDMETHOD.

ENDCLASS.
