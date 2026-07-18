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
             `// The implementations moved to z2ui5/model/formatter (the standard` && |\n| &&
             `// app-layout formatter module); this module stays as the stable legacy` && |\n| &&
             `// alias re-exporting exactly the original helpers. New code should` && |\n| &&
             `// reference the formatter module (core:require of z2ui5/model/formatter` && |\n| &&
             `// or the z2ui5.Formatter global).` && |\n| &&
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
