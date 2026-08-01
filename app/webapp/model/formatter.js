// The frontend app's formatter module in the standard UI5 app layout
// (webapp/model/formatter.js, next to model/models.js) - shipped by the
// framework and shared by every abap2UI5 app. Wire it into an XML view via
// core:require (UI5 >= 1.74) and reference the functions by alias:
//
//   <mvc:View xmlns:core="sap.ui.core"
//             core:require="{Formatter: 'z2ui5/model/formatter'}">
//     ... src="{ path: 'STATUS', formatter: 'Formatter.stockStatusIcon' }"
//
// The module is also published as the z2ui5.Formatter global, so
// formatter: 'z2ui5.Formatter.stockStatusIcon' keeps working on releases
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
sap.ui.define(["sap/ui/core/IconPool"], (IconPool) => {
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

  // True for an ABAP date that carries no date: the INITIAL value of a DATS
  // field is "00000000", and a row with an optional date ships it that way
  // (one template, so the attribute cannot be omitted per row). Handing it to
  // the Date constructor would silently produce 1899-11-30 - a plausible-
  // looking wrong date rather than an obvious error - so it is treated like
  // the empty string below and yields null, which is what "no date" means to
  // a UI5 date property. Anything that is not 8 digits is rejected too: an
  // Invalid Date is TRUTHY and only blows up much later inside a calendar
  // control (see DateCreateObject).
  function isNoAbapDate(d) {
    const s = String(d);
    if (!/^\d{8}$/.test(s)) return true;
    // a zero year, month or day is never a real date - "00000000" is the
    // initial DATS value, the partial forms turn up in half-filled records
    return (
      Number(s.slice(0, 4)) === 0 ||
      Number(s.slice(4, 6)) === 0 ||
      Number(s.slice(6, 8)) === 0
    );
  }

  // Product stock status -> its value state + status icon, kept as one
  // entry per status so the two formatters below cannot drift apart
  // (sap.m.sample.StandardListItemInfo / ObjectListItem Formatter.js).
  const STOCK_STATUS = {
    Available: { state: "Success", icon: "sap-icon://accept" },
    "Out of Stock": { state: "Warning", icon: "sap-icon://alert" },
    Discontinued: { state: "Error", icon: "sap-icon://decline" },
  };

  return {
    // --- date helpers (the z2ui5.Util legacy contract) ---
    //
    // An EMPTY input yields null, never an Invalid Date. A bound row with an
    // optional date field (one template, so the attribute cannot be omitted
    // per row) would otherwise hand `new Date("")` to the control: an Invalid
    // Date is TRUTHY, so a consumer that only checks for presence accepts it
    // and blows up much later - sap.ui.unified Month._checkDateEnabled ->
    // CalendarDate.fromLocalJSDate throws for every rendered day and takes
    // the whole view down. null is what "no date" means to a UI5 date
    // property, so the missing value stays a missing value.
    DateCreateObject(s) {
      if (!s) return null;
      return new Date(s);
    },
    DateAbapDateToDateObject(d) {
      if (isNoAbapDate(d)) return null;
      return new Date(...parseYmd(d));
    },
    // t is an ABAP time string "HHMMSS"; if omitted we default to midnight.
    DateAbapDateTimeToDateObject(d, t = "000000") {
      if (isNoAbapDate(d)) return null;
      return new Date(
        ...parseYmd(d),
        Number(t.slice(0, 2)),
        Number(t.slice(2, 4)),
        Number(t.slice(4, 6)),
      );
    },

    // --- value formatters ---
    //
    // Presentation only. Deriving a state from a raw measure (the demo kit's
    // weightState: parseFloat + KG conversion + Success/Warning/Error
    // thresholds) is BUSINESS LOGIC and does NOT belong here - abap2UI5 is a
    // thin frontend, so a port computes that in ABAP and binds the finished
    // value (state="{WEIGHT_STATE}"). The status -> ValueState/icon lookups
    // below only map an already-classified business status to a visual, which
    // is presentation.

    // Product stock status -> sap.ui.core.ValueState.
    stockStatusState(status) {
      return STOCK_STATUS[status]?.state ?? "None";
    },

    // Product stock status -> status icon.
    stockStatusIcon(status) {
      return STOCK_STATUS[status]?.icon ?? null;
    },

    // Round to two decimal places, always rendered with two digits
    // (sap.m.sample.TableBreadcrumb Formatter.js). Non-numeric input maps
    // to an empty cell rather than the literal "NaN".
    round2DP(value) {
      const n = parseFloat(value);
      if (isNaN(n)) return "";
      return (Math.round(n * 100) / 100).toFixed(2);
    },

    // Join the available dimensions with " x " and append the unit;
    // missing components are skipped (sap.m.sample.TableBreadcrumb
    // Formatter.js). A component is "missing" only when it is null/undefined
    // or empty string - a real 0 (a zero-size dimension) is kept, and the
    // unit is only appended when it is present.
    dimensions(width, depth, height, unit) {
      let display = [width, depth, height]
        .filter((component) => component != null && component !== "")
        .join(" x ");
      if (display && unit != null && unit !== "") display += ` ${unit}`;
      return display;
    },

    // Delivery status -> sap.ui.core.ValueState
    // (sap.m.sample.InitialPagePattern model/formatter.js).
    deliveryStatusState(status) {
      if (status === "Shipped") return "Success";
      if (status === "Failed Shipping") return "Error";
      return "None";
    },

    // Replace %%icon:sap-icon://<name>%% placeholders in a formatted-text
    // string with the inline-icon markup MessageStrip formatted text expects
    // (mirrors sap.m.MessageStripUtilities.getInlineIcon). The glyph is
    // resolved from the icon font via IconPool - CSP-clean, no code
    // generation. Plain text passes through unchanged; an unknown icon name
    // is dropped. Used as a whole-string formatter on a MessageStrip text
    // binding (sap.m.sample.MessageStripWithEnableFormattedText).
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
