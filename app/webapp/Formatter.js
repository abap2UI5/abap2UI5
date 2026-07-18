// The frontend app's formatter module - the file an original UI5 app would
// keep as model/formatter.js, shipped by the framework and shared by every
// abap2UI5 app. Exposed as the z2ui5.Formatter global and as the
// z2ui5/Formatter module (core:require), so XML binding strings reference
// the functions directly:
//
//   state="{ parts: [{path: 'WEIGHT'}, {path: 'UNIT'}],
//            formatter: 'z2ui5.Formatter.weightState' }"
//
// The set is CURATED and grows via framework PRs: every function here is a
// real, served script resource - CSP-clean, no runtime code generation (an
// eval-based register-a-JS-string API was rejected for exactly that
// reason). Scope: general-purpose value formatters that apps and demo-kit
// ports commonly need; keep app-specific one-offs out (expression bindings
// cover most of those).
//
// z2ui5.Util's date helpers are re-exported here so new code needs only
// this one module; z2ui5.Util itself stays the stable legacy alias.
sap.ui.define(["z2ui5/Util"], (Util) => {
  "use strict";

  return {
    ...Util,

    // Weight -> sap.ui.core.ValueState, the classic demo-kit formatter
    // (sap.m.sample.Table Formatter.js): thresholds in KG (< 1 Success,
    // < 5 Warning, else Error), a "G" unit is converted, non-numeric or
    // negative weights map to None.
    weightState(measure, unit) {
      let adjusted = parseFloat(measure);
      if (isNaN(adjusted)) return "None";
      if (unit === "G") adjusted = measure / 1000;
      if (adjusted < 0) return "None";
      if (adjusted < 1) return "Success";
      if (adjusted < 5) return "Warning";
      return "Error";
    },
  };
});
