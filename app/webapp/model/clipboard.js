// The frontend app's clipboard module (webapp/model/clipboard.js, next to
// model/formatter.js) - shipped by the framework and shared by every abap2UI5
// app. It holds the callbacks a UI5 control calls SYNCHRONOUSLY in the
// browser, which no roundtrip can answer. Wire it into an XML view via
// core:require (UI5 >= 1.74) and name the function in the function-typed
// property - UI5's XMLTemplateProcessor resolves the dotted name against the
// core:require aliases (DataType "function" -> parseValue), so no string
// ever becomes code:
//
//   <mvc:View xmlns:core="sap.ui.core" xmlns:plugins="sap.m.plugins"
//             xmlns:app="http://schemas.sap.com/sapui5/extension/sap.ui.core.CustomData/1"
//             core:require="{Clipboard: 'z2ui5/model/clipboard'}">
//     <Table ...>
//       <dependents>
//         <plugins:CellSelector/>
//         <plugins:CopyProvider id="copyProvider" extractData="Clipboard.extractData"/>
//       </dependents>
//       <columns>
//         <Column app:bindings="NAME,PRODUCT_ID" app:template="{0} ({1})"> ...
//
// ---------------------------------------------------------------------
// ADMISSION CRITERIA - the same three the formatter module states
// ---------------------------------------------------------------------
// abap2UI5 is a THIN FRONTEND. A function lives here only when
//
//   1. IT MARSHALS, IT DOES NOT DECIDE - it hands back data the view already
//      holds, in the shape the control's callback contract asks for. Which
//      fields a column copies and how the text/html variant reads is declared
//      by the app on the column (CustomData), never chosen here.
//   2. FRONTEND-ONLY - the control calls it synchronously in the browser
//      ('js-callback'), e.g. CopyProvider.extractData while the user presses
//      Ctrl+C, so the backend cannot be asked.
//   3. NO DOMAIN VOCABULARY - no business statuses, thresholds, units or
//      classifications.
//
// Criteria 2 and 3 are machine-checked by .github/scripts/formatter-scope-gate.mjs
// (npm run check:formatter) exactly like formatter.js: the export surface
// must match that gate's manifest, and no ValueState or sap-icon:// literal
// may appear. Criterion 1 is reviewer-enforced.
//
// The names and the CustomData keys (bindings, template) are a public
// contract - do not rename them. The keys are the ones the UI5 demo kit
// sample sap.m.sample.TableSelectCopy uses, so a demo kit view ports 1:1.
//
// sap.m.plugins.CopyProvider itself is @since 1.110 and is only ever named by
// an app's view; this module depends on nothing newer than 1.71.
sap.ui.define(["sap/base/strings/formatMessage"], (formatMessage) => {
  "use strict";

  // A cell value as the clipboard receives it: the CopyProvider stringifies
  // what it gets, so a missing field would otherwise arrive as the word
  // "undefined" or "null" in the user's spreadsheet.
  function toCellValue(v) {
    return v === undefined || v === null ? "" : v;
  }

  // The row's data source. For a bound table the CopyProvider hands over the
  // binding context; for a sap.m.Table whose items are NOT bound it hands
  // over the row itself, whose binding context (if any) carries the data.
  function contextOf(oContextOrRow) {
    if (!oContextOrRow) return null;
    if (typeof oContextOrRow.getProperty === "function") return oContextOrRow;
    if (typeof oContextOrRow.getBindingContext === "function") {
      return oContextOrRow.getBindingContext() || null;
    }
    return null;
  }

  return {
    // Criterion 2: 'js-callback'. The extractData property of
    // sap.m.plugins.CopyProvider (function-typed, mandatory - the plugin
    // throws on creation without it). Called once per selected cell with the
    // row context, the column and whether text/html is written as well.
    //
    // The column declares what it copies in CustomData, as in the demo kit:
    //   app:bindings  - comma-separated model paths, relative to the row
    //                   ("NAME,PRODUCT_ID"); each becomes one clipboard cell
    //   app:template  - optional formatMessage pattern for the text/html
    //                   variant ("{0} ({1})"); defaults to "{0}"
    // A column without app:bindings is not copied (undefined is the
    // CopyProvider's "skip this column").
    extractData(oContextOrRow, oColumn, bIncludeHtmlMimeType) {
      const sBindings =
        oColumn && typeof oColumn.data === "function"
          ? oColumn.data("bindings")
          : null;
      if (!sBindings) return undefined;
      const oContext = contextOf(oContextOrRow);
      const aCellData = String(sBindings)
        .split(",")
        .map((sPath) => sPath.trim())
        .filter(Boolean)
        .map((sPath) =>
          toCellValue(oContext ? oContext.getProperty(sPath) : undefined),
        );
      if (!bIncludeHtmlMimeType) return aCellData;
      return {
        text: aCellData,
        html: formatMessage(oColumn.data("template") || "{0}", aCellData),
      };
    },
  };
});
