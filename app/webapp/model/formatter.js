// The frontend app's formatter module in the standard UI5 app layout
// (webapp/model/formatter.js, next to model/models.js) - shipped by the
// framework and shared by every abap2UI5 app. Wire it into an XML view via
// core:require (UI5 >= 1.74) and reference the functions by alias:
//
//   <mvc:View xmlns:core="sap.ui.core"
//             core:require="{Formatter: 'z2ui5/model/formatter'}">
//     ... state="{ parts: [{path: 'WEIGHT'}, {path: 'UNIT'}],
//                  formatter: 'Formatter.weightState' }"
//
// The module is also published as the z2ui5.Formatter global, so
// formatter: 'z2ui5.Formatter.weightState' keeps working on releases
// without core:require support.
//
// The set is CURATED and grows via framework PRs: every function here is a
// real, served script resource - CSP-clean, no runtime code generation (an
// eval-based register-a-JS-string API was rejected for exactly that
// reason). Scope: general-purpose value formatters that apps and demo-kit
// ports commonly need; keep app-specific one-offs out (expression bindings
// cover most of those).
//
// This module also OWNS the public date helpers historically shipped as
// z2ui5.Util: the implementations live here, Util.js re-exports them as
// the stable legacy alias. Their names and behavior are a public contract
// - do not rename or change them.
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
    // --- date helpers (the z2ui5.Util legacy contract) ---
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

    // --- value formatters ---

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
