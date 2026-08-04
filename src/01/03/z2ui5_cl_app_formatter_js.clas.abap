* =====================================================================
* GENERATED FILE - DO NOT EDIT (AGENTS.md rule 2)
* Embedded frontend resource, generated from app/webapp/ by
* .github/app2abap/trans2abap.js. Change the source under app/webapp/
* and run 'npm run app2abap' to regenerate; the check_app2abap CI gate
* fails any manual edit here.
* =====================================================================
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
             `//     ... dateValue="{ path: 'DATE', formatter: 'Formatter.DateCreateObject' }"` && |\n| &&
             `//` && |\n| &&
             `// The module is also published as the z2ui5.Formatter global, so` && |\n| &&
             `// formatter: 'z2ui5.Formatter.DateCreateObject' keeps working on releases` && |\n| &&
             `// without core:require support.` && |\n| &&
             `//` && |\n| &&
             `// ---------------------------------------------------------------------` && |\n| &&
             `// ADMISSION CRITERIA - all three must hold, and they are not negotiable` && |\n| &&
             `// ---------------------------------------------------------------------` && |\n| &&
             `// abap2UI5 is a THIN FRONTEND: the backend decides, the frontend renders.` && |\n| &&
             `// Every function admitted here moves one decision from ABAP into JS, and` && |\n| &&
             `// taking it back out later breaks the apps that adopted it. So the set is` && |\n| &&
             `// CURATED and stays small - it is a marshalling layer, not a place to put` && |\n| &&
             `// logic that ABAP could just as well have finished:` && |\n| &&
             `//` && |\n| &&
             `//   1. ONE VALUE - the function formats exactly the value handed to it. A` && |\n| &&
             `//      function that reads other fields, other rows or the whole model to` && |\n| &&
             `//      decide something is a computation wearing a formatter's name; it` && |\n| &&
             `//      belongs in the app's ABAP model.` && |\n| &&
             `//   2. FRONTEND-ONLY - there is a technical reason it cannot be done in` && |\n| &&
             `//      ABAP: the result is a JavaScript type the JSON model cannot carry` && |\n| &&
             `//      ('js-type'), an icon-font glyph resolved from the loaded theme` && |\n| &&
             `//      ('icon-font'), or a browser locale/theme artefact ('locale-theme').` && |\n| &&
             `//      If ABAP can produce the finished value, ABAP produces it and the` && |\n| &&
             `//      view binds it directly.` && |\n| &&
             `//   3. NO DOMAIN VOCABULARY - no business statuses, thresholds, units or` && |\n| &&
             `//      classifications, and therefore no hardcoded ValueState or icon URI` && |\n| &&
             `//      here. Mapping "Available" to Success is classification, which is` && |\n| &&
             `//      backend work (bind state="{STATUS_STATE}" instead).` && |\n| &&
             `//` && |\n| &&
             `// Criteria 2 and 3 are machine-checked by` && |\n| &&
             `// .github/scripts/formatter-scope-gate.mjs (npm run check:formatter): the` && |\n| &&
             `// export surface must match that gate's manifest, every entry names its` && |\n| &&
             `// frontend-only reason, and the module must contain no ValueState or` && |\n| &&
             `// sap-icon:// literal. Criterion 1 is reviewer-enforced.` && |\n| &&
             `//` && |\n| &&
             `// Precedent, so the line is not re-litigated: weightState /` && |\n| &&
             `// weightStateByValue (parseFloat + KG conversion + thresholds) and the` && |\n| &&
             `// stock/delivery status packs (round2DP, dimensions, stockStatusState,` && |\n| &&
             `// stockStatusIcon, deliveryStatusState) were shipped and then REMOVED -` && |\n| &&
             `// the first for criterion 2 and 3, the rest for 2 or 3. Ports compute` && |\n| &&
             `// those in ABAP and bind the finished field.` && |\n| &&
             `//` && |\n| &&
             `// Everything here is a real, served script resource - CSP-clean, no` && |\n| &&
             `// runtime code generation (an eval-based register-a-JS-string API was` && |\n| &&
             `// rejected for exactly that reason).` && |\n| &&
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
             `  // True for an ABAP date that carries no date: the INITIAL value of a DATS` && |\n| &&
             `  // field is "00000000", and a row with an optional date ships it that way` && |\n| &&
             `  // (one template, so the attribute cannot be omitted per row). Handing it to` && |\n| &&
             `  // the Date constructor would silently produce 1899-11-30 - a plausible-` && |\n| &&
             `  // looking wrong date rather than an obvious error - so it is treated like` && |\n| &&
             `  // the empty string below and yields null, which is what "no date" means to` && |\n| &&
             `  // a UI5 date property. Anything that is not 8 digits is rejected too: an` && |\n| &&
             `  // Invalid Date is TRUTHY and only blows up much later inside a calendar` && |\n| &&
             `  // control (see DateCreateObject).` && |\n| &&
             `  function isNoAbapDate(d) {` && |\n| &&
             `    const s = String(d);` && |\n| &&
             `    if (!/^\d{8}$/.test(s)) return true;` && |\n| &&
             `    // a zero year, month or day is never a real date - "00000000" is the` && |\n| &&
             `    // initial DATS value, the partial forms turn up in half-filled records` && |\n| &&
             `    return (` && |\n| &&
             `      Number(s.slice(0, 4)) === 0 ||` && |\n| &&
             `      Number(s.slice(4, 6)) === 0 ||` && |\n| &&
             `      Number(s.slice(6, 8)) === 0` && |\n| &&
             `    );` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  return {` && |\n| &&
             `    // --- date helpers (the z2ui5.Util legacy contract) ---` && |\n| &&
             `    //` && |\n| &&
             `    // Criterion 2: 'js-type'. UI5 properties typed "object"` && |\n| &&
             `    // (DatePicker.dateValue, PlanningCalendar.startDate, a` && |\n| &&
             `    // CalendarAppointment's startDate/endDate) demand a real JS Date, and` && |\n| &&
             `    // JSON has no date type - so the ABAP model physically cannot carry` && |\n| &&
             `    // one. The conversion has to happen at the binding; model-level` && |\n| &&
             `    // auto-revival was rejected because it would silently retype every` && |\n| &&
             `    // timestamp field.` && |\n| &&
             `    //` && |\n| &&
             `    // An EMPTY input yields null, never an Invalid Date. A bound row with an` && |\n| &&
             `    // optional date field (one template, so the attribute cannot be omitted` && |\n| &&
             `    // per row) would otherwise hand ``new Date("")`` to the control: an Invalid` && |\n| &&
             `    // Date is TRUTHY, so a consumer that only checks for presence accepts it` && |\n| &&
             `    // and blows up much later - sap.ui.unified Month._checkDateEnabled ->` && |\n| &&
             `    // CalendarDate.fromLocalJSDate throws for every rendered day and takes` && |\n| &&
             `    // the whole view down. null is what "no date" means to a UI5 date` && |\n| &&
             `    // property, so the missing value stays a missing value.` && |\n| &&
             `    DateCreateObject(s) {` && |\n| &&
             `      if (!s) return null;` && |\n| &&
             `      return new Date(s);` && |\n| &&
             `    },` && |\n| &&
             `    DateAbapDateToDateObject(d) {` && |\n| &&
             `      if (isNoAbapDate(d)) return null;` && |\n| &&
             `      return new Date(...parseYmd(d));` && |\n| &&
             `    },` && |\n| &&
             `    // t is an ABAP time string "HHMMSS"; if omitted we default to midnight.` && |\n| &&
             `    DateAbapDateTimeToDateObject(d, t = "000000") {` && |\n| &&
             `      if (isNoAbapDate(d)) return null;` && |\n| &&
             `      return new Date(` && |\n| &&
             `        ...parseYmd(d),` && |\n| &&
             `        Number(t.slice(0, 2)),` && |\n| &&
             `        Number(t.slice(2, 4)),` && |\n| &&
             `        Number(t.slice(4, 6)),` && |\n| &&
             `      );` && |\n| &&
             `    },` && |\n| &&
             `` && |\n| &&
             `    // --- glyph resolution ---` && |\n| &&
             `    //` && |\n| &&
             `    // Criterion 2: 'icon-font'. Replace %%icon:sap-icon://<name>%%` && |\n| &&
             `    // placeholders in a formatted-text string with the inline-icon markup` && |\n| &&
             `    // MessageStrip formatted text expects (mirrors` && |\n| &&
             `    // sap.m.MessageStripUtilities.getInlineIcon). The glyph and its font` && |\n| &&
             `    // family come from the icon font of the LOADED THEME via IconPool -` && |\n| &&
             `    // the backend cannot know them, and hardcoding a codepoint in ABAP` && |\n| &&
             `    // would push a frontend detail into the backend, which is the thin-` && |\n| &&
             `    // frontend rule in reverse. CSP-clean, no code generation.` && |\n| &&
             `    //` && |\n| &&
             `    // The icon name travels in the data; this module hardcodes none. Plain` && |\n| &&
             `    // text passes through unchanged; an unknown icon name is dropped. Used` && |\n| &&
             `    // as a whole-string formatter on a MessageStrip text binding.` && |\n| &&
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
