// The frontend app's formatter module in the standard UI5 app layout
// (webapp/model/formatter.js, next to model/models.js) - shipped by the
// framework and shared by every abap2UI5 app. Wire it into an XML view via
// core:require on the view root - available on every release abap2UI5
// supports (UI5 added it in 1.69; 1.71's XMLTemplateProcessor reads it) -
// and reference the functions by alias:
//
//   <mvc:View xmlns:core="sap.ui.core"
//             core:require="{Formatter: 'z2ui5/model/formatter'}">
//     ... dateValue="{ path: 'DATE', formatter: 'Formatter.DateCreateObject' }"
//
// core:require is the only way in. The module used to be published as the
// z2ui5.Formatter global as well (and its date helpers as z2ui5.Util); both
// globals went with the rest of the z2ui5 global on 2026-09-22.
//
// ---------------------------------------------------------------------
// ADMISSION CRITERIA - all three must hold, and they are not negotiable
// ---------------------------------------------------------------------
// abap2UI5 is a THIN FRONTEND: the backend decides, the frontend renders.
// Every function admitted here moves one decision from ABAP into JS, and
// taking it back out later breaks the apps that adopted it. So the set is
// CURATED and stays small - it is a marshalling layer, not a place to put
// logic that ABAP could just as well have finished:
//
//   1. ONE VALUE - the function formats exactly the value handed to it. A
//      function that reads other fields, other rows or the whole model to
//      decide something is a computation wearing a formatter's name; it
//      belongs in the app's ABAP model.
//   2. FRONTEND-ONLY - there is a technical reason it cannot be done in
//      ABAP: the result is a JavaScript type the JSON model cannot carry
//      ('js-type'), an icon-font glyph resolved from the loaded theme
//      ('icon-font'), or a browser locale/theme artefact ('locale-theme').
//      If ABAP can produce the finished value, ABAP produces it and the
//      view binds it directly.
//   3. NO DOMAIN VOCABULARY - no business statuses, thresholds, units or
//      classifications, and therefore no hardcoded ValueState or icon URI
//      here. Mapping "Available" to Success is classification, which is
//      backend work (bind state="{STATUS_STATE}" instead).
//
// Criteria 2 and 3 are machine-checked by
// .github/scripts/formatter-scope-gate.mjs (npm run check:formatter): the
// export surface must match that gate's manifest, every entry names its
// frontend-only reason, and the module must contain no ValueState or
// sap-icon:// literal. Criterion 1 is reviewer-enforced.
//
// Precedent, so the line is not re-litigated: weightState /
// weightStateByValue (parseFloat + KG conversion + thresholds) and the
// stock/delivery status packs (round2DP, dimensions, stockStatusState,
// stockStatusIcon, deliveryStatusState) were shipped and then REMOVED -
// the first for criterion 2 and 3, the rest for 2 or 3. Ports compute
// those in ABAP and bind the finished field.
//
// Everything here is a real, served script resource - CSP-clean, no
// runtime code generation (an eval-based register-a-JS-string API was
// rejected for exactly that reason).
//
// The names and behavior of the date helpers are a public contract - do
// not rename or change them.
sap.ui.define(["sap/ui/core/IconPool"], (IconPool) => {
  "use strict";

  // Splits an 8-character ABAP date string "YYYYMMDD" into the [year, month,
  // day] tuple JavaScript's Date constructor expects. Note: Date months are
  // 0-based, so we subtract 1 from the month component.
  /** @returns {[number, number, number]} */
  function parseYmd(value) {
    const d = abapDigits(value, ISO_DAY);
    return [
      Number(d.slice(0, 4)),
      Number(d.slice(4, 6)) - 1,
      Number(d.slice(6, 8)),
    ];
  }

  // True for an ABAP date that carries no date: the INITIAL value of a DATS
  // field is "00000000", and a row with an optional date ships it that way
  // (one template, so the attribute cannot be omitted per row). Handing it to
  // the Date constructor would silently produce 1899-11-30 - a plausible-
  // looking wrong date rather than an obvious error - so it is treated like
  // the empty string below and yields null, which is what "no date" means to
  // a UI5 date property. Anything that is not 8 digits is rejected too: an
  // Invalid Date is TRUTHY and only blows up much later inside a calendar
  // control (see DateCreateObject).
  // The model carries a bound DATS field as "YYYY-MM-DD" and a TIMS field
  // as "HH:MM:SS" - ajson's format_datetime, which the model serialization
  // keeps on - while a CHAR or NUMC field keeps the raw "YYYYMMDD" /
  // "HHMMSS". Both spellings mean the same value; the helpers below read
  // the digits. Taking only the raw form, a date bound straight from a
  // DATS field always came out as "no date", and a TIMS time as an Invalid
  // Date.
  function abapDigits(value, pattern) {
    const s = String(value ?? "");
    return pattern.test(s) ? s.replace(/[-:]/g, "") : s;
  }
  const ISO_DAY = /^\d{4}-\d{2}-\d{2}$/;
  const ISO_TIME = /^\d{2}:\d{2}:\d{2}$/;

  // The calendar day a "YYYYMMDD" / "YYYY-MM-DD" names, at LOCAL midnight -
  // or null when no such day exists. Two things the Date constructor gets
  // wrong for an ABAP date: a year below 100 is read as 19xx (the low
  // boundary "00010101" of a validity range became 1901-01-01), and a day
  // the month does not have rolls over (an unchecked "20240230" from a
  // foreign system showed as March 1 - a real-looking wrong date).
  // setFullYear takes the year as written, and a part that moved is a day
  // the calendar does not have, which is no date.
  function localDay(value) {
    const [year, month, day] = parseYmd(value);
    const date = new Date(2000, 0, 1);
    date.setFullYear(year, month, day);
    if (
      date.getFullYear() !== year ||
      date.getMonth() !== month ||
      date.getDate() !== day
    ) {
      return null;
    }
    return date;
  }

  function isNoAbapDate(d) {
    const s = abapDigits(d, ISO_DAY);
    if (!/^\d{8}$/.test(s)) return true;
    // a zero year, month or day is never a real date - "00000000" is the
    // initial DATS value, the partial forms turn up in half-filled records.
    // The test above guarantees eight digits, so a zero part IS the literal
    // "0000" / "00" - three string compares, no number parsing, on a path
    // a bound table runs once per row
    return (
      s.slice(0, 4) === "0000" ||
      s.slice(4, 6) === "00" ||
      s.slice(6, 8) === "00"
    );
  }

  return {
    // --- date helpers ---
    //
    // Criterion 2: 'js-type'. UI5 properties typed "object"
    // (DatePicker.dateValue, PlanningCalendar.startDate, a
    // CalendarAppointment's startDate/endDate) demand a real JS Date, and
    // JSON has no date type - so the ABAP model physically cannot carry
    // one. The conversion has to happen at the binding; model-level
    // auto-revival was rejected because it would silently retype every
    // timestamp field.
    //
    // An EMPTY input yields null, never an Invalid Date. A bound row with an
    // optional date field (one template, so the attribute cannot be omitted
    // per row) would otherwise hand `new Date("")` to the control: an Invalid
    // Date is TRUTHY, so a consumer that only checks for presence accepts it
    // and blows up much later - sap.ui.unified Month._checkDateEnabled ->
    // CalendarDate.fromLocalJSDate throws for every rendered day and takes
    // the whole view down. null is what "no date" means to a UI5 date
    // property, so the missing value stays a missing value.
    // A bare "YYYY-MM-DD" is a calendar day: new Date( ) reads that one
    // form as UTC midnight, which is the PREVIOUS day anywhere west of
    // Greenwich - it is built from its local parts instead, like the ABAP
    // date helpers below. A timestamp keeps the Date constructor.
    DateCreateObject(s) {
      if (!s) return null;
      if (ISO_DAY.test(String(s))) return localDay(s);
      return new Date(s);
    },
    DateAbapDateToDateObject(d) {
      if (isNoAbapDate(d)) return null;
      return localDay(d);
    },
    // t is an ABAP time string "HHMMSS"; an omitted, null or empty one
    // is midnight. A default parameter covers undefined only, and a bound
    // time field that is null in the model used to reach t.slice and throw
    // inside the binding.
    DateAbapDateTimeToDateObject(d, t) {
      if (isNoAbapDate(d)) return null;
      const date = localDay(d);
      if (!date) return null;
      const time = t ? abapDigits(t, ISO_TIME) : "000000";
      date.setHours(
        Number(time.slice(0, 2)),
        Number(time.slice(2, 4)),
        Number(time.slice(4, 6)),
      );
      return date;
    },

    // --- glyph resolution ---
    //
    // Criterion 2: 'icon-font'. Replace %%icon:sap-icon://<name>%%
    // placeholders in a formatted-text string with the inline-icon markup
    // MessageStrip formatted text expects (mirrors
    // sap.m.MessageStripUtilities.getInlineIcon). The glyph and its font
    // family come from the icon font of the LOADED THEME via IconPool -
    // the backend cannot know them, and hardcoding a codepoint in ABAP
    // would push a frontend detail into the backend, which is the thin-
    // frontend rule in reverse. CSP-clean, no code generation.
    //
    // The icon name travels in the data; this module hardcodes none. Plain
    // text passes through unchanged; an unknown icon name is dropped. Used
    // as a whole-string formatter on a MessageStrip text binding.
    expandInlineIcons(text) {
      if (!text) return "";
      return String(text).replace(
        /%%icon:(sap-icon:\/\/[^%]+)%%/g,
        (match, uri) => {
          const info = IconPool.getIconInfo(uri);
          if (!info) return "";
          return `<span class="sapMMsgStripInlineIcon" style="font-family:'${info.fontFamily}'">${info.content}</span>`;
        },
      );
    },
  };
});
