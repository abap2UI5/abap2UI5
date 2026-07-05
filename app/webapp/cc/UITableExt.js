sap.ui.define(
  ["sap/ui/core/Control", "z2ui5/core/Lib", "z2ui5/core/ViewSlots"],
  (Control, Lib, ViewSlots) => {
    "use strict";

    // Invisible companion control for a sap.ui.table.Table (referenced via
    // tableId): saves the user's filters and sort order before each
    // roundtrip and re-applies them - including the column indicators -
    // when the response rebuilt the table binding, which would otherwise
    // lose them.
    const opSymbols = { EQ: "", NE: "!", LT: "<", LE: "<=", GT: ">", GE: ">=" };
    const filterDisplayFns = {
      Contains: (v) => `*${v ?? ""}*`,
      StartsWith: (v) => `^${v ?? ""}`,
      EndsWith: (v) => `${v ?? ""}$`,
    };

    return Control.extend("z2ui5.cc.UITableExt", {
      metadata: {
        properties: {
          tableId: {
            type: "string",
          },
        },
      },

      init() {
        this._beforeBound = () => {
          this.readFilter();
          this.readSort();
        };
        this._afterBound = () => {
          this.setFilter();
          this.setSort();
        };
        Lib.registerCallback("onBeforeRoundtrip", this._beforeBound);
        Lib.registerCallback("onAfterRoundtrip", this._afterBound);
      },

      exit() {
        Lib.unregisterCallback("onBeforeRoundtrip", this._beforeBound);
        Lib.unregisterCallback("onAfterRoundtrip", this._afterBound);
      },

      _getTable() {
        return ViewSlots.byId("MAIN", this.getProperty("tableId"));
      },

      readFilter() {
        try {
          const table = this._getTable();
          const binding = table?.getBinding();
          // Remember the binding object we read from so the re-apply pass
          // can skip when that same binding is still in place (see
          // _applyFilters).
          this._filterBinding = binding;
          // Prefer the public getFilters API (UI5 >= 1.96); older releases
          // only expose the private aFilters member.
          this.aFilters = binding?.getFilters
            ? binding.getFilters("Application")
            : binding?.aFilters;
        } catch (e) {
          Lib.logError("UITableExt.readFilter failed", e);
        }
      },

      _applyFilters(oTable, aFilters) {
        if (!aFilters) return;
        const binding = oTable.getBinding();
        if (!binding) return;
        // The re-apply pass (onAfterRoundtrip) runs synchronously right
        // after the request is dispatched, before the response can rebuild
        // the table. When the binding is still the exact object we read the
        // filters from, it already carries them and the column indicators
        // are in sync - re-running binding.filter() would re-evaluate the
        // whole client dataset for an identical result. Only re-apply when
        // the binding was replaced (e.g. a fresh view build produced a new,
        // unfiltered binding).
        if (binding === this._filterBinding) return;
        binding.filter(aFilters);
        const columns = oTable.getColumns();

        for (const oFilter of aFilters) {
          // Multi-filter? Pick the inner filter for the column lookup.
          let sProperty = oFilter.sPath;
          if (!sProperty && oFilter.aFilters?.[0]) {
            sProperty = oFilter.aFilters[0].sPath;
          }
          if (!sProperty) continue;

          const operator = oFilter.sOperator;
          // Pick the most meaningful value to display in the column header.
          let vValue = oFilter.oValue1;
          if (vValue === undefined) vValue = oFilter.oValue2;
          if (vValue === undefined && oFilter.aFilters?.[0]) {
            vValue = oFilter.aFilters[0].oValue1;
          }

          // Choose how to format the column header label for this operator.
          let displayFn;
          if (operator === "BT") {
            // "between" displays "from...to".
            displayFn = (v) => {
              const from = Lib.toText(v);
              const to = Lib.toText(oFilter.oValue2);
              return `${from}...${to}`;
            };
          } else if (filterDisplayFns[operator]) {
            displayFn = filterDisplayFns[operator];
          } else {
            // Fallback: optional operator prefix (e.g. "!" for NE) + value.
            const prefix = opSymbols[operator] || "";
            displayFn = (v) => `${prefix}${Lib.toText(v)}`;
          }
          const display = displayFn(vValue);

          for (const oCol of columns) {
            if (oCol.getFilterProperty?.() === sProperty) {
              oCol.setFilterValue(display);
              oCol.setFiltered(Boolean(display));
            }
          }
        }
      },

      _applyToTable(applyFn, errorMsg) {
        try {
          const oTable = this._getTable();
          if (!oTable) return;
          Lib.whenRendered(oTable, this, () => applyFn(oTable));
        } catch (e) {
          Lib.logError(errorMsg, e);
        }
      },

      setFilter() {
        this._applyToTable(
          (oTable) => this._applyFilters(oTable, this.aFilters),
          "UITableExt.setFilter failed",
        );
      },

      readSort() {
        try {
          const table = this._getTable();
          const binding = table?.getBinding();
          // Same binding reference the sort re-apply checks against (see
          // _applySorters).
          this._sortBinding = binding;
          // Private member access: ListBinding has no public getter for the
          // active sorters (unlike getFilters for filters).
          this.aSorters = binding ? binding.aSorters : undefined;
        } catch (e) {
          Lib.logError("UITableExt.readSort failed", e);
        }
      },

      _applySorters(oTable, aSorters) {
        if (!aSorters) return;
        const binding = oTable.getBinding();
        if (!binding) return;
        // Same redundancy guard as _applyFilters: skip the re-sort when the
        // binding is unchanged since readSort - it still holds these sorters
        // and re-running binding.sort() would re-sort the whole dataset for
        // an identical result. Re-apply only after a binding rebuild.
        if (binding === this._sortBinding) return;
        binding.sort(aSorters);

        const columns = oTable.getColumns();
        for (const [index, sorter] of aSorters.entries()) {
          for (const oCol of columns) {
            if (oCol.getSortProperty?.() === sorter.sPath) {
              oCol.setSorted(true);
              oCol.setSortOrder(
                sorter.bDescending ? "Descending" : "Ascending",
              );
              // setSortIndex is only available on some column variants.
              if (oCol.setSortIndex) oCol.setSortIndex(index);
            }
          }
        }
      },

      setSort() {
        this._applyToTable(
          (oTable) => this._applySorters(oTable, this.aSorters),
          "UITableExt.setSort failed",
        );
      },
      renderer: { apiVersion: 2, render() {} },
    });
  },
);
