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

    result = `// @deprecated Use z2ui5/model/formatter instead (the z2ui5.Formatter` && |\n| &&
             `// global, or core:require of z2ui5/model/formatter). This module is kept` && |\n| &&
             `// only as a backward-compatible alias for existing apps and will not gain` && |\n| &&
             `// new functions - every helper here is re-exported from the formatter` && |\n| &&
             `// module, which is where new code should reference them.` && |\n| &&
             `//` && |\n| &&
             `// PUBLIC date helpers for apps: exposed as the z2ui5.Util global and as` && |\n| &&
             `// the z2ui5/Util module (used in XML view formatter strings). Part of the` && |\n| &&
             `// public contract - do not rename or change the existing functions.` && |\n| &&
             `// The implementations moved to z2ui5/model/formatter (the standard` && |\n| &&
             `// app-layout formatter module); this module stays as the stable legacy` && |\n| &&
             `// alias re-exporting exactly the original helpers.` && |\n| &&
             `sap.ui.define(["z2ui5/model/formatter"], (Formatter) => {` && |\n| &&
             `  "use strict";` && |\n| &&
             `` && |\n| &&
             `  return {` && |\n| &&
             `    DateCreateObject: Formatter.DateCreateObject,` && |\n| &&
             `    DateAbapDateToDateObject: Formatter.DateAbapDateToDateObject,` && |\n| &&
             `    DateAbapDateTimeToDateObject: Formatter.DateAbapDateTimeToDateObject,` && |\n| &&
             `  };` && |\n| &&
             `});` && |\n| &&
             `` && |\n| &&
              ``.

  ENDMETHOD.

ENDCLASS.
