// @deprecated Use z2ui5/model/formatter instead (the z2ui5.Formatter
// global, or core:require of z2ui5/model/formatter). This module is kept
// only as a backward-compatible alias for existing apps and will not gain
// new functions - every helper here is re-exported from the formatter
// module, which is where new code should reference them.
//
// PUBLIC date helpers for apps: exposed as the z2ui5.Util global and as
// the z2ui5/Util module (used in XML view formatter strings). Part of the
// public contract - do not rename or change the existing functions.
// The implementations moved to z2ui5/model/formatter (the standard
// app-layout formatter module); this module stays as the stable legacy
// alias re-exporting exactly the original helpers.
sap.ui.define(["z2ui5/model/formatter"], (Formatter) => {
  "use strict";

  return {
    DateCreateObject: Formatter.DateCreateObject,
    DateAbapDateToDateObject: Formatter.DateAbapDateToDateObject,
    DateAbapDateTimeToDateObject: Formatter.DateAbapDateTimeToDateObject,
  };
});
