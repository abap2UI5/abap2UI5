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
             `sap.ui.define(["sap/ui/core/IconPool"], (IconPool) => {` && |\n| &&
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
             `  // Product stock status -> its value state + status icon, kept as one` && |\n| &&
             `  // entry per status so the two formatters below cannot drift apart` && |\n| &&
             `  // (sap.m.sample.StandardListItemInfo / ObjectListItem Formatter.js).` && |\n| &&
             `  const STOCK_STATUS = {` && |\n| &&
             `    Available: { state: "Success", icon: "sap-icon://accept" },` && |\n| &&
             `    "Out of Stock": { state: "Warning", icon: "sap-icon://alert" },` && |\n| &&
             `    Discontinued: { state: "Error", icon: "sap-icon://decline" },` && |\n| &&
             `  };` && |\n| &&
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
             `` && |\n| &&
             `    // The demo kit's second weightState shape (sap.m.sample.TableEditable` && |\n| &&
             `    // Formatter.js and five sibling Table samples): a single unit-less` && |\n| &&
             `    // value, thresholds < 1000 Success, < 2000 Warning, else Error;` && |\n| &&
             `    // non-numeric or negative values map to None.` && |\n| &&
             `    weightStateByValue(value) {` && |\n| &&
             `      const adjusted = parseFloat(value);` && |\n| &&
             `      if (isNaN(adjusted) || adjusted < 0) return "None";` && |\n| &&
             `      if (adjusted < 1000) return "Success";` && |\n| &&
             `      if (adjusted < 2000) return "Warning";` && |\n| &&
             `      return "Error";` && |\n| &&
             `    },` && |\n| &&
             `` && |\n| &&
             `    // Product stock status -> sap.ui.core.ValueState.` && |\n| &&
             `    stockStatusState(status) {` && |\n| &&
             `      return STOCK_STATUS[status]?.state ?? "None";` && |\n| &&
             `    },` && |\n| &&
             `` && |\n| &&
             `    // Product stock status -> status icon.` && |\n| &&
             `    stockStatusIcon(status) {` && |\n| &&
             `      return STOCK_STATUS[status]?.icon ?? null;` && |\n| &&
             `    },` && |\n| &&
             `` && |\n| &&
             `    // Round to two decimal places, always rendered with two digits` && |\n| &&
             `    // (sap.m.sample.TableBreadcrumb Formatter.js). Non-numeric input maps` && |\n| &&
             `    // to an empty cell rather than the literal "NaN".` && |\n| &&
             `    round2DP(value) {` && |\n| &&
             `      const n = parseFloat(value);` && |\n| &&
             `      if (isNaN(n)) return "";` && |\n| &&
             `      return (Math.round(n * 100) / 100).toFixed(2);` && |\n| &&
             `    },` && |\n| &&
             `` && |\n| &&
             `    // Join the available dimensions with " x " and append the unit;` && |\n| &&
             `    // missing components are skipped (sap.m.sample.TableBreadcrumb` && |\n| &&
             `    // Formatter.js). A component is "missing" only when it is null/undefined` && |\n| &&
             `    // or empty string - a real 0 (a zero-size dimension) is kept, and the` && |\n| &&
             `    // unit is only appended when it is present.` && |\n| &&
             `    dimensions(width, depth, height, unit) {` && |\n| &&
             `      let display = [width, depth, height]` && |\n| &&
             `        .filter((component) => component != null && component !== "")` && |\n| &&
             `        .join(" x ");` && |\n| &&
             `      if (display && unit != null && unit !== "") display += `` ${unit}``;` && |\n| &&
             `      return display;` && |\n| &&
             `    },` && |\n| &&
             `` && |\n| &&
             `    // Delivery status -> sap.ui.core.ValueState` && |\n| &&
             `    // (sap.m.sample.InitialPagePattern model/formatter.js).` && |\n| &&
             `    deliveryStatusState(status) {` && |\n| &&
             `      if (status === "Shipped") return "Success";` && |\n| &&
             `      if (status === "Failed Shipping") return "Error";` && |\n| &&
             `      return "None";` && |\n| &&
             `    },` && |\n| &&
             `` && |\n| &&
             `    // Replace %%icon:sap-icon://<name>%% placeholders in a formatted-text` && |\n| &&
             `    // string with the inline-icon markup MessageStrip formatted text expects` && |\n| &&
             `    // (mirrors sap.m.MessageStripUtilities.getInlineIcon). The glyph is` && |\n| &&
             `    // resolved from the icon font via IconPool - CSP-clean, no code` && |\n| &&
             `    // generation. Plain text passes through unchanged; an unknown icon name` && |\n| &&
             `    // is dropped. Used as a whole-string formatter on a MessageStrip text` && |\n| &&
             `    // binding (sap.m.sample.MessageStripWithEnableFormattedText).` && |\n| &&
             `    expandInlineIcons(text) {` && |\n| &&
             `      if (!text) return "";` && |\n| &&
             `      return String(text).replace(` && |\n| &&
             `        /%%icon:(sap-icon:\/\/[^%]+)%%/g,` && |\n| &&
             `        (match, uri) => {` && |\n| &&
             `          const info = IconPool.getIconInfo(uri);` && |\n| &&
             `          if (!info) return "";` && |\n| &&
             `          return ``<span class="sapMMsgStripInlineIcon" style="font-family:'${info.fontFamily}'">${info.content}</span>``;` && |\n| &&
             `        },` && |\n| &&
             `      );` && |\n| &&
             `    },` && |\n| &&
             `  };` && |\n| &&
             `});` && |\n| &&
             `` && |\n| &&
              ``.

  ENDMETHOD.

ENDCLASS.
