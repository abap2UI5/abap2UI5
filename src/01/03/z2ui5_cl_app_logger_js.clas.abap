CLASS z2ui5_cl_app_logger_js DEFINITION
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


CLASS z2ui5_cl_app_logger_js IMPLEMENTATION.

  METHOD get.

    result = `sap.ui.define([], () => {` && |\n| &&
             `  "use strict";` && |\n| &&
             `` && |\n| &&
             `  // Append an entry to the global error log. We create the array on first use.` && |\n| &&
             `  // ``error`` is only added when defined, so the log never contains a stray` && |\n| &&
             `  // ``error: undefined`` field.` && |\n| &&
             `  function logError(message, error) {` && |\n| &&
             `    if (typeof z2ui5 === "undefined") return;` && |\n| &&
             `    if (!z2ui5.errors) z2ui5.errors = [];` && |\n| &&
             `    const entry = { message: message, ts: new Date().toISOString() };` && |\n| &&
             `    if (error !== undefined) entry.error = error;` && |\n| &&
             `    z2ui5.errors.push(entry);` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  return { logError: logError };` && |\n| &&
             `});` && |\n| &&
             `` && |\n| &&
              ``.

  ENDMETHOD.

ENDCLASS.
