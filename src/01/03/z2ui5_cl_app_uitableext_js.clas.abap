CLASS z2ui5_cl_app_uitableext_js DEFINITION
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


CLASS z2ui5_cl_app_uitableext_js IMPLEMENTATION.

  METHOD get.

    result = `sap.ui.define(["sap/ui/core/Control", "z2ui5/core/Lib"], (Control, Lib) => {` && |\n| &&
             `  "use strict";` && |\n| &&
             `` && |\n| &&
             `  const opSymbols = { EQ: "", NE: "!", LT: "<", LE: "<=", GT: ">", GE: ">=" };` && |\n| &&
             `  const filterDisplayFns = {` && |\n| &&
             `    Contains: (v) => ``*${v ?? ""}*``,` && |\n| &&
             `    StartsWith: (v) => ``^${v ?? ""}``,` && |\n| &&
             `    EndsWith: (v) => ``${v ?? ""}$``,` && |\n| &&
             `  };` && |\n| &&
             `` && |\n| &&
             `  return Control.extend("z2ui5.UITableExt", {` && |\n| &&
             `    metadata: {` && |\n| &&
             `      properties: {` && |\n| &&
             `        tableId: {` && |\n| &&
             `          type: "string",` && |\n| &&
             `        },` && |\n| &&
             `      },` && |\n| &&
             `    },` && |\n| &&
             `` && |\n| &&
             `    init() {` && |\n| &&
             `      this._beforeBound = () => {` && |\n| &&
             `        this.readFilter();` && |\n| &&
             `        this.readSort();` && |\n| &&
             `      };` && |\n| &&
             `      this._afterBound = () => {` && |\n| &&
             `        this.setFilter();` && |\n| &&
             `        this.setSort();` && |\n| &&
             `      };` && |\n| &&
             `      Lib.registerCallback("onBeforeRoundtrip", this._beforeBound);` && |\n| &&
             `      Lib.registerCallback("onAfterRoundtrip", this._afterBound);` && |\n| &&
             `    },` && |\n| &&
             `` && |\n| &&
             `    exit() {` && |\n| &&
             `      Lib.unregisterCallback("onBeforeRoundtrip", this._beforeBound);` && |\n| &&
             `      Lib.unregisterCallback("onAfterRoundtrip", this._afterBound);` && |\n| &&
             `    },` && |\n| &&
             `` && |\n| &&
             `    _getTable() {` && |\n| &&
             `      if (!z2ui5.oView) return undefined;` && |\n| &&
             `      return z2ui5.oView.byId(this.getProperty("tableId"));` && |\n| &&
             `    },` && |\n| &&
             `` && |\n| &&
             `    readFilter() {` && |\n| &&
             `      try {` && |\n| &&
             `        const table = this._getTable();` && |\n| &&
             `        const binding = table?.getBinding();` && |\n| &&
             `        // Prefer the public getFilters API (UI5 >= 1.96); older releases` && |\n| &&
             `        // only expose the private aFilters member.` && |\n| &&
             `        this.aFilters = !binding` && |\n| &&
             `          ? undefined` && |\n| &&
             `          : binding.getFilters` && |\n| &&
             `            ? binding.getFilters("Application")` && |\n| &&
             `            : binding.aFilters;` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        Lib.logError("UITableExt.readFilter failed", e);` && |\n| &&
             `      }` && |\n| &&
             `    },` && |\n| &&
             `` && |\n| &&
             `    _applyFilters(oTable, aFilters) {` && |\n| &&
             `      if (!aFilters) return;` && |\n| &&
             `      const binding = oTable.getBinding();` && |\n| &&
             `      if (!binding) return;` && |\n| &&
             `      binding.filter(aFilters);` && |\n| &&
             `      const columns = oTable.getColumns();` && |\n| &&
             `` && |\n| &&
             `      for (const oFilter of aFilters) {` && |\n| &&
             `        // Multi-filter? Pick the inner filter for the column lookup.` && |\n| &&
             `        let sProperty = oFilter.sPath;` && |\n| &&
             `        if (!sProperty && oFilter.aFilters?.[0]) {` && |\n| &&
             `          sProperty = oFilter.aFilters[0].sPath;` && |\n| &&
             `        }` && |\n| &&
             `        if (!sProperty) continue;` && |\n| &&
             `` && |\n| &&
             `        const operator = oFilter.sOperator;` && |\n| &&
             `        // Pick the most meaningful value to display in the column header.` && |\n| &&
             `        let vValue = oFilter.oValue1;` && |\n| &&
             `        if (vValue === undefined) vValue = oFilter.oValue2;` && |\n| &&
             `        if (vValue === undefined && oFilter.aFilters?.[0]) {` && |\n| &&
             `          vValue = oFilter.aFilters[0].oValue1;` && |\n| &&
             `        }` && |\n| &&
             `` && |\n| &&
             `        // Choose how to format the column header label for this operator.` && |\n| &&
             `        let displayFn;` && |\n| &&
             `        if (operator === "BT") {` && |\n| &&
             `          // "between" displays "from...to".` && |\n| &&
             `          displayFn = (v) => {` && |\n| &&
             `            const from = Lib.toText(v);` && |\n| &&
             `            const to = Lib.toText(oFilter.oValue2);` && |\n| &&
             `            return ``${from}...${to}``;` && |\n| &&
             `          };` && |\n| &&
             `        } else if (filterDisplayFns[operator]) {` && |\n| &&
             `          displayFn = filterDisplayFns[operator];` && |\n| &&
             `        } else {` && |\n| &&
             `          // Fallback: optional operator prefix (e.g. "!" for NE) + value.` && |\n| &&
             `          const prefix = opSymbols[operator] || "";` && |\n| &&
             `          displayFn = (v) => ``${prefix}${Lib.toText(v)}``;` && |\n| &&
             `        }` && |\n| &&
             `        const display = displayFn(vValue);` && |\n| &&
             `` && |\n| &&
             `        for (const oCol of columns) {` && |\n| &&
             `          if (oCol.getFilterProperty?.() === sProperty) {` && |\n| &&
             `            oCol.setFilterValue(display);` && |\n| &&
             `            oCol.setFiltered(!!display);` && |\n| &&
             `          }` && |\n| &&
             `        }` && |\n| &&
             `      }` && |\n| &&
             `    },` && |\n| &&
             `` && |\n| &&
             `    _applyToTable(applyFn, errorMsg) {` && |\n| &&
             `      try {` && |\n| &&
             `        const oTable = this._getTable();` && |\n| &&
             `        if (!oTable) return;` && |\n| &&
             `        Lib.whenRendered(oTable, this, () => applyFn(oTable));` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        Lib.logError(errorMsg, e);` && |\n| &&
             `      }` && |\n| &&
             `    },` && |\n| &&
             `` && |\n| &&
             `    setFilter() {` && |\n| &&
             `      this._applyToTable(` && |\n| &&
             `        (oTable) => this._applyFilters(oTable, this.aFilters),` && |\n| &&
             `        "UITableExt.setFilter failed",` && |\n| &&
             `      );` && |\n| &&
             `    },` && |\n| &&
             `` && |\n| &&
             `    readSort() {` && |\n| &&
             `      try {` && |\n| &&
             `        const table = this._getTable();` && |\n| &&
             `        const binding = table?.getBinding();` && |\n| &&
             `        // Private member access: ListBinding has no public getter for the` && |\n| &&
             `        // active sorters (unlike getFilters for filters).` && |\n| &&
             `        this.aSorters = binding ? binding.aSorters : undefined;` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        Lib.logError("UITableExt.readSort failed", e);` && |\n| &&
             `      }` && |\n| &&
             `    },` && |\n| &&
             `` && |\n| &&
             `    _applySorters(oTable, aSorters) {` && |\n| &&
             `      if (!aSorters) return;` && |\n| &&
             `      const binding = oTable.getBinding();` && |\n| &&
             `      if (!binding) return;` && |\n| &&
             `      binding.sort(aSorters);` && |\n| &&
             `` && |\n| &&
             `      const columns = oTable.getColumns();` && |\n| &&
             `      for (const [idx, srt] of aSorters.entries()) {` && |\n| &&
             `        for (const oCol of columns) {` && |\n| &&
             `          if (oCol.getSortProperty?.() === srt.sPath) {` && |\n| &&
             `            oCol.setSorted(true);` && |\n| &&
             `            oCol.setSortOrder(srt.bDescending ? "Descending" : "Ascending");` && |\n| &&
             `            // setSortIndex is only available on some column variants.` && |\n| &&
             `            if (oCol.setSortIndex) oCol.setSortIndex(idx);` && |\n| &&
             `          }` && |\n| &&
             `        }` && |\n| &&
             `      }` && |\n| &&
             `    },` && |\n| &&
             `` && |\n| &&
             `    setSort() {` && |\n| &&
             `      this._applyToTable(` && |\n| &&
             `        (oTable) => this._applySorters(oTable, this.aSorters),` && |\n| &&
             `        "UITableExt.setSort failed",` && |\n| &&
             `      );` && |\n| &&
             `    },` && |\n| &&
             `    renderer: { apiVersion: 2, render() {} },` && |\n| &&
             `  });` && |\n| &&
             `});` && |\n| &&
             `` && |\n| &&
              ``.

  ENDMETHOD.

ENDCLASS.
