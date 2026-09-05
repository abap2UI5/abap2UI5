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
        this._unhooks = [
          Lib.hookCallback(this, "onBeforeRoundtrip", "readBackend"),
          // onAfterRENDERING, not onAfterRoundtrip: the latter fires
          // right after the request DISPATCH (see View1.eB), long before a
          // rebuild could have produced the fresh unfiltered binding this
          // re-apply exists for - the pass was unreachable there. After the
          // rendering the new binding exists and the compare below decides.
          Lib.hookCallback(this, "onAfterRendering", "applyBackend"),
        ];
      },

      exit() {
        this._unhooks.forEach((unhook) => unhook());
      },

      // The table is resolved ONCE per pass here and handed down: every
      // _getTable( ) is a parent-chain walk over the five view slots
      // (ViewSlots.byIdOfOwner), and the two reads plus the two applies
      // used to walk it four times per roundtrip.
      readBackend() {
        const table = this._getTable();
        this.readFilter(table);
        this.readSort(table);
      },

      // The ONE apply path. There used to be a second, imperative one -
      // setFilter( )/setSort( ) with their own _applyToTable deferral - and it
      // lost its last caller when the hooks moved to readBackend/applyBackend:
      // nothing in app/webapp called it, and no backend-driven control call
      // can (it is not in the ControlCall whitelists). All it still pinned was
      // a deferral the app never takes, while the dedupe below - the one the
      // app runs on every roundtrip - went unpinned. Re-apply stays here.
      applyBackend() {
        try {
          const oTable = this._getTable();
          if (!oTable) return;
          // One deferral for both applies, and none while one is already
          // waiting: whenRendered leaves a rendering delegate on a table
          // without DOM (a collapsed tab, a closed popup) until it fires,
          // and two of them per roundtrip piled up on such a table - all
          // firing, and re-applying, on the eventual render. The callback
          // reads the CURRENT filters/sorters when it runs, so the one
          // pending deferral applies what the latest readBackend recorded.
          if (this._applyPending) return;
          this._applyPending = true;
          Lib.whenRendered(oTable, this, () => {
            this._applyPending = false;
            this._applyGuarded(oTable, this.aFilters, "_applyFilters");
            this._applyGuarded(oTable, this.aSorters, "_applySorters");
          });
        } catch (e) {
          this._applyPending = false;
          Lib.logError("UITableExt.applyBackend failed", e);
        }
      },

      // The deferred half of applyBackend runs outside its try/catch (a
      // later onAfterRendering); guard each apply on its own so a throw
      // is logged (log, never throw) and the other apply still runs.
      _applyGuarded(oTable, aValues, method) {
        try {
          this[method](oTable, aValues);
        } catch (e) {
          Lib.logError(`UITableExt.${method} failed`, e);
        }
      },

      _getTable() {
        return ViewSlots.byIdOfOwner(this, this.getProperty("tableId"));
      },

      readFilter(oTable) {
        try {
          const table = oTable ?? this._getTable();
          const binding = table?.getBinding();
          // Remember the binding object we read from so the re-apply pass
          // can skip when that same binding is still in place (see
          // _applyFilters).
          this._filterBinding = binding;
          // Prefer the public getFilters API (UI5 >= 1.96); older releases
          // only expose the private aFilters member. The column filter row
          // is applied by sap.ui.table.Column.filter( ) as FilterType.CONTROL
          // (1.71 and 1.120 alike), and the private aFilters IS the control
          // filter array - so the public call has to ask for "Control" too.
          // "Application" answered the app's own binding filters (usually
          // none), and on every release with getFilters the user's column
          // filter was gone after a view rebuild while 1.71 kept it.
          this.aFilters = binding?.getFilters
            ? binding.getFilters("Control")
            : binding?.aFilters;
        } catch (e) {
          Lib.logError("UITableExt.readFilter failed", e);
        }
      },

      _applyFilters(oTable, aFilters) {
        if (!aFilters) return;
        const binding = oTable.getBinding();
        if (!binding) return;
        // The re-apply pass runs on onAfterRendering (see init), i.e. AFTER
        // a response may have rebuilt the table. When the binding is still
        // the exact object we read the filters from, it already carries
        // them and the column indicators are in sync - re-running
        // binding.filter() would re-evaluate the whole client dataset for
        // an identical result. Only re-apply when the binding was replaced
        // (a fresh view build produced a new, unfiltered binding).
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

      readSort(oTable) {
        try {
          const table = oTable ?? this._getTable();
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

      renderer: Lib.EMPTY_RENDERER,
    });
  },
);
