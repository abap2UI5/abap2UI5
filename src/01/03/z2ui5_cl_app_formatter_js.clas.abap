CLASS z2ui5_cl_app_formatter_js DEFINITION
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


CLASS z2ui5_cl_app_formatter_js IMPLEMENTATION.

  METHOD get.

    result = `// The frontend app's formatter module in the standard UI5 app layout` && |\n| &&
             `// (webapp/model/formatter.js, next to model/models.js) - shipped by the` && |\n| &&
             `// framework and shared by every abap2UI5 app. Wire it into an XML view via` && |\n| &&
             `// core:require (UI5 >= 1.74) and reference the functions by alias:` && |\n| &&
             `//` && |\n| &&
             `//   <mvc:View xmlns:core="sap.ui.core"` && |\n| &&
             `//             core:require="{Formatter: 'z2ui5/model/formatter'}">` && |\n| &&
             `//     ... state="{ parts: [{path: 'WEIGHT'}, {path: 'UNIT'}],` && |\n| &&
             `//                  formatter: 'Formatter.weightState' }"` && |\n| &&
             `//` && |\n| &&
             `// The module is also published as the z2ui5.Formatter global, so` && |\n| &&
             `// formatter: 'z2ui5.Formatter.weightState' keeps working on releases` && |\n| &&
             `// without core:require support.` && |\n| &&
             `//` && |\n| &&
             `// The set is CURATED and grows via framework PRs: every function here is a` && |\n| &&
             `// real, served script resource - CSP-clean, no runtime code generation (an` && |\n| &&
             `// eval-based register-a-JS-string API was rejected for exactly that` && |\n| &&
             `// reason). Scope: general-purpose value formatters that apps and demo-kit` && |\n| &&
             `// ports commonly need; keep app-specific one-offs out (expression bindings` && |\n| &&
             `// cover most of those).` && |\n| &&
             `//` && |\n| &&
             `// z2ui5.Util's date helpers are re-exported here so new code needs only` && |\n| &&
             `// this one module; z2ui5.Util itself stays the stable legacy alias.` && |\n| &&
             `sap.ui.define(["z2ui5/Util"], (Util) => {` && |\n| &&
             `  "use strict";` && |\n| &&
             `` && |\n| &&
             `  return {` && |\n| &&
             `    ...Util,` && |\n| &&
             `` && |\n| &&
             `    // Weight -> sap.ui.core.ValueState, the classic demo-kit formatter` && |\n| &&
             `    // (sap.m.sample.Table Formatter.js): thresholds in KG (< 1 Success,` && |\n| &&
             `    // < 5 Warning, else Error), a "G" unit is converted, non-numeric or` && |\n| &&
             `    // negative weights map to None.` && |\n| &&
             `    weightState(measure, unit) {` && |\n| &&
             `      let adjusted = parseFloat(measure);` && |\n| &&
             `      if (isNaN(adjusted)) return "None";` && |\n| &&
             `      if (unit === "G") adjusted = measure / 1000;` && |\n| &&
             `      if (adjusted < 0) return "None";` && |\n| &&
             `      if (adjusted < 1) return "Success";` && |\n| &&
             `      if (adjusted < 5) return "Warning";` && |\n| &&
             `      return "Error";` && |\n| &&
             `    },` && |\n| &&
             `  };` && |\n| &&
             `});` && |\n| &&
             `` && |\n| &&
              ``.

  ENDMETHOD.

ENDCLASS.
