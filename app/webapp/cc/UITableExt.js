sap.ui.define(
  ["sap/ui/core/Control", "z2ui5/core/Lib", "z2ui5/core/ViewSlots"],
  (Control, Lib, ViewSlots) => {
    "use strict";

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
          // Prefer the public getFilters API (UI5 >= 1.96); older releases
          // only expose the private aFilters member.
          this.aFilters = !binding
            ? undefined
            : binding.getFilters
              ? binding.getFilters("Application")
              : binding.aFilters;
        } catch (e) {
          Lib.logError("UITableExt.readFilter failed", e);
        }
      },

      _applyFilters(oTable, aFilters) {
        if (!aFilters) return;
        const binding = oTable.getBinding();
        if (!binding) return;
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
              oCol.setFiltered(!!display);
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
        binding.sort(aSorters);

        const columns = oTable.getColumns();
        for (const [idx, srt] of aSorters.entries()) {
          for (const oCol of columns) {
            if (oCol.getSortProperty?.() === srt.sPath) {
              oCol.setSorted(true);
              oCol.setSortOrder(srt.bDescending ? "Descending" : "Ascending");
              // setSortIndex is only available on some column variants.
              if (oCol.setSortIndex) oCol.setSortIndex(idx);
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
