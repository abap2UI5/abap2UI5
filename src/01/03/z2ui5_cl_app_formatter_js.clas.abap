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
             `// This module also OWNS the public date helpers historically shipped as` && |\n| &&
             `// z2ui5.Util: the implementations live here, Util.js re-exports them as` && |\n| &&
             `// the stable legacy alias. Their names and behavior are a public contract` && |\n| &&
             `// - do not rename or change them.` && |\n| &&
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
             `    // --- date helpers (the z2ui5.Util legacy contract) ---` && |\n| &&
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
             `` && |\n| &&
             `    // --- value formatters ---` && |\n| &&
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
