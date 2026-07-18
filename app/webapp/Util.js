// PUBLIC date helpers for apps: exposed as the z2ui5.Util global and as
// the z2ui5/Util module (used in XML view formatter strings). Part of the
// public contract - do not rename or change the existing functions.
// The implementations moved to z2ui5/model/formatter (the standard
// app-layout formatter module); this module stays as the stable legacy
// alias re-exporting exactly the original helpers. New code should
// reference the formatter module (core:require of z2ui5/model/formatter
// or the z2ui5.Formatter global).
sap.ui.define(["z2ui5/model/formatter"], (Formatter) => {
  "use strict";

  return {
    DateCreateObject: Formatter.DateCreateObject,
    DateAbapDateToDateObject: Formatter.DateAbapDateToDateObject,
    DateAbapDateTimeToDateObject: Formatter.DateAbapDateTimeToDateObject,
  };
});
