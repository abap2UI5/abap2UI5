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

    result = `sap.ui.define(` && |\n| &&
             `  ["sap/ui/core/Control", "z2ui5/core/Lib", "z2ui5/core/ViewSlots"],` && |\n| &&
             `  (Control, Lib, ViewSlots) => {` && |\n| &&
             `    "use strict";` && |\n| &&
             `` && |\n| &&
             `    // Invisible companion control for a sap.ui.table.Table (referenced via` && |\n| &&
             `    // tableId): saves the user's filters and sort order before each` && |\n| &&
             `    // roundtrip and re-applies them - including the column indicators -` && |\n| &&
             `    // when the response rebuilt the table binding, which would otherwise` && |\n| &&
             `    // lose them.` && |\n| &&
             `    const opSymbols = { EQ: "", NE: "!", LT: "<", LE: "<=", GT: ">", GE: ">=" };` && |\n| &&
             `    const filterDisplayFns = {` && |\n| &&
             `      Contains: (v) => ``*${v ?? ""}*``,` && |\n| &&
             `      StartsWith: (v) => ``^${v ?? ""}``,` && |\n| &&
             `      EndsWith: (v) => ``${v ?? ""}$``,` && |\n| &&
             `    };` && |\n| &&
             `` && |\n| &&
             `    return Control.extend("z2ui5.cc.UITableExt", {` && |\n| &&
             `      metadata: {` && |\n| &&
             `        properties: {` && |\n| &&
             `          tableId: {` && |\n| &&
             `            type: "string",` && |\n| &&
             `          },` && |\n| &&
             `        },` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      init() {` && |\n| &&
             `        this._beforeBound = () => {` && |\n| &&
             `          this.readFilter();` && |\n| &&
             `          this.readSort();` && |\n| &&
             `        };` && |\n| &&
             `        this._afterBound = () => {` && |\n| &&
             `          this.setFilter();` && |\n| &&
             `          this.setSort();` && |\n| &&
             `        };` && |\n| &&
             `        Lib.registerCallback("onBeforeRoundtrip", this._beforeBound);` && |\n| &&
             `        Lib.registerCallback("onAfterRoundtrip", this._afterBound);` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      exit() {` && |\n| &&
             `        Lib.unregisterCallback("onBeforeRoundtrip", this._beforeBound);` && |\n| &&
             `        Lib.unregisterCallback("onAfterRoundtrip", this._afterBound);` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      _getTable() {` && |\n| &&
             `        return ViewSlots.byId("MAIN", this.getProperty("tableId"));` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      readFilter() {` && |\n| &&
             `        try {` && |\n| &&
             `          const table = this._getTable();` && |\n| &&
             `          const binding = table?.getBinding();` && |\n| &&
             `          // Remember the binding object we read from so the re-apply pass` && |\n| &&
             `          // can skip when that same binding is still in place (see` && |\n| &&
             `          // _applyFilters).` && |\n| &&
             `          this._filterBinding = binding;` && |\n| &&
             `          // Prefer the public getFilters API (UI5 >= 1.96); older releases` && |\n| &&
             `          // only expose the private aFilters member.` && |\n| &&
             `          this.aFilters = binding?.getFilters` && |\n| &&
             `            ? binding.getFilters("Application")` && |\n| &&
             `            : binding?.aFilters;` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          Lib.logError("UITableExt.readFilter failed", e);` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      _applyFilters(oTable, aFilters) {` && |\n| &&
             `        if (!aFilters) return;` && |\n| &&
             `        const binding = oTable.getBinding();` && |\n| &&
             `        if (!binding) return;` && |\n| &&
             `        // The re-apply pass (onAfterRoundtrip) runs synchronously right` && |\n| &&
             `        // after the request is dispatched, before the response can rebuild` && |\n| &&
             `        // the table. When the binding is still the exact object we read the` && |\n| &&
             `        // filters from, it already carries them and the column indicators` && |\n| &&
             `        // are in sync - re-running binding.filter() would re-evaluate the` && |\n| &&
             `        // whole client dataset for an identical result. Only re-apply when` && |\n| &&
             `        // the binding was replaced (e.g. a fresh view build produced a new,` && |\n| &&
             `        // unfiltered binding).` && |\n| &&
             `        if (binding === this._filterBinding) return;` && |\n| &&
             `        binding.filter(aFilters);` && |\n| &&
             `        const columns = oTable.getColumns();` && |\n| &&
             `` && |\n| &&
             `        for (const oFilter of aFilters) {` && |\n| &&
             `          // Multi-filter? Pick the inner filter for the column lookup.` && |\n| &&
             `          let sProperty = oFilter.sPath;` && |\n| &&
             `          if (!sProperty && oFilter.aFilters?.[0]) {` && |\n| &&
             `            sProperty = oFilter.aFilters[0].sPath;` && |\n| &&
             `          }` && |\n| &&
             `          if (!sProperty) continue;` && |\n| &&
             `` && |\n| &&
             `          const operator = oFilter.sOperator;` && |\n| &&
             `          // Pick the most meaningful value to display in the column header.` && |\n| &&
             `          let vValue = oFilter.oValue1;` && |\n| &&
             `          if (vValue === undefined) vValue = oFilter.oValue2;` && |\n| &&
             `          if (vValue === undefined && oFilter.aFilters?.[0]) {` && |\n| &&
             `            vValue = oFilter.aFilters[0].oValue1;` && |\n| &&
             `          }` && |\n| &&
             `` && |\n| &&
             `          // Choose how to format the column header label for this operator.` && |\n| &&
             `          let displayFn;` && |\n| &&
             `          if (operator === "BT") {` && |\n| &&
             `            // "between" displays "from...to".` && |\n| &&
             `            displayFn = (v) => {` && |\n| &&
             `              const from = Lib.toText(v);` && |\n| &&
             `              const to = Lib.toText(oFilter.oValue2);` && |\n| &&
             `              return ``${from}...${to}``;` && |\n| &&
             `            };` && |\n| &&
             `          } else if (filterDisplayFns[operator]) {` && |\n| &&
             `            displayFn = filterDisplayFns[operator];` && |\n| &&
             `          } else {` && |\n| &&
             `            // Fallback: optional operator prefix (e.g. "!" for NE) + value.` && |\n| &&
             `            const prefix = opSymbols[operator] || "";` && |\n| &&
             `            displayFn = (v) => ``${prefix}${Lib.toText(v)}``;` && |\n| &&
             `          }` && |\n| &&
             `          const display = displayFn(vValue);` && |\n| &&
             `` && |\n| &&
             `          for (const oCol of columns) {` && |\n| &&
             `            if (oCol.getFilterProperty?.() === sProperty) {` && |\n| &&
             `              oCol.setFilterValue(display);` && |\n| &&
             `              oCol.setFiltered(Boolean(display));` && |\n| &&
             `            }` && |\n| &&
             `          }` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      _applyToTable(applyFn, errorMsg) {` && |\n| &&
             `        try {` && |\n| &&
             `          const oTable = this._getTable();` && |\n| &&
             `          if (!oTable) return;` && |\n| &&
             `          Lib.whenRendered(oTable, this, () => applyFn(oTable));` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          Lib.logError(errorMsg, e);` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      setFilter() {` && |\n| &&
             `        this._applyToTable(` && |\n| &&
             `          (oTable) => this._applyFilters(oTable, this.aFilters),` && |\n| &&
             `          "UITableExt.setFilter failed",` && |\n| &&
             `        );` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      readSort() {` && |\n| &&
             `        try {` && |\n| &&
             `          const table = this._getTable();` && |\n| &&
             `          const binding = table?.getBinding();` && |\n| &&
             `          // Same binding reference the sort re-apply checks against (see` && |\n| &&
             `          // _applySorters).` && |\n| &&
             `          this._sortBinding = binding;` && |\n| &&
             `          // Private member access: ListBinding has no public getter for the` && |\n| &&
             `          // active sorters (unlike getFilters for filters).` && |\n| &&
             `          this.aSorters = binding ? binding.aSorters : undefined;` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          Lib.logError("UITableExt.readSort failed", e);` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      _applySorters(oTable, aSorters) {` && |\n| &&
             `        if (!aSorters) return;` && |\n| &&
             `        const binding = oTable.getBinding();` && |\n| &&
             `        if (!binding) return;` && |\n| &&
             `        // Same redundancy guard as _applyFilters: skip the re-sort when the` && |\n| &&
             `        // binding is unchanged since readSort - it still holds these sorters` && |\n| &&
             `        // and re-running binding.sort() would re-sort the whole dataset for` && |\n| &&
             `        // an identical result. Re-apply only after a binding rebuild.` && |\n| &&
             `        if (binding === this._sortBinding) return;` && |\n| &&
             `        binding.sort(aSorters);` && |\n| &&
             `` && |\n| &&
             `        const columns = oTable.getColumns();` && |\n| &&
             `        for (const [index, sorter] of aSorters.entries()) {` && |\n| &&
             `          for (const oCol of columns) {` && |\n| &&
             `            if (oCol.getSortProperty?.() === sorter.sPath) {` && |\n| &&
             `              oCol.setSorted(true);` && |\n| &&
             `              oCol.setSortOrder(` && |\n| &&
             `                sorter.bDescending ? "Descending" : "Ascending",` && |\n| &&
             `              );` && |\n| &&
             `              // setSortIndex is only available on some column variants.` && |\n| &&
             `              if (oCol.setSortIndex) oCol.setSortIndex(index);` && |\n| &&
             `            }` && |\n| &&
             `          }` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      setSort() {` && |\n| &&
             `        this._applyToTable(` && |\n| &&
             `          (oTable) => this._applySorters(oTable, this.aSorters),` && |\n| &&
             `          "UITableExt.setSort failed",` && |\n| &&
             `        );` && |\n| &&
             `      },` && |\n| &&
             `      renderer: { apiVersion: 2, render() {} },` && |\n| &&
             `    });` && |\n| &&
             `  },` && |\n| &&
             `);` && |\n| &&
             `` && |\n| &&
              ``.

  ENDMETHOD.

ENDCLASS.
