// The framework's JSON model, with the list binding of a WINDOWED table.
//
// A table bound with `_bind_tab( val = mt_rows window = 100 )` does not travel
// whole: the response carries the first rows of it, in the order the
// binding asked for, and next to the model's data the state of the window
// under `/__WINDOW/<path>` - TOTAL (the rows the filter lets through), COUNT
// (the rows sent) and SIZE (one window). A list bound to that path gets a
// WindowListBinding, which
//   - answers getLength( ) with TOTAL, so a growing sap.m.Table shows
//     "More [100 / 10000]" and a sap.ui.table.Table a scrollbar for all rows;
//   - asks the backend for more rows when a control asks it for contexts
//     past the ones it holds (getContexts) - whole windows, at most TOTAL;
//   - sorts and filters on the backend instead of in the browser: sort( ) and
//     filter( ) - the column menu of sap.ui.table, a BINDING_CALL from the
//     app - send the sorters and the filter to the backend, which sorts and
//     filters ALL rows and answers with the first window of the new order.
// The request is the framework event EVENT through the slot's eB, so it
// carries the model delta like any roundtrip; the backend answers it without
// calling the app (z2ui5_cl_ui5_handler, cs_event_window) and pushes the
// model. Everything here is a thin executor (AGENTS.md rule 19): the binding
// says what it was asked, the backend decides what the rows are.
//
// Not windowed - the default, and a path without its `/__WINDOW` entry - the
// model and its bindings are JSONModel's own, unchanged.
//
// Sorters and filters written into the binding info of the view are not
// applied to a windowed list: the rows arrive in the order the backend gives,
// and the binding's sort( ) and filter( ) are the way to change it.
sap.ui.define(
  [
    "sap/ui/model/json/JSONModel",
    "sap/ui/model/json/JSONListBinding",
    "z2ui5/core/Lib",
    "z2ui5/core/Env",
  ],
  (JSONModel, JSONListBinding, Lib, Env) => {
    "use strict";

    // the framework event of a window request - z2ui5_if_ui5_types=>
    // cs_event_window on the backend, which dispatches on it
    const EVENT = "___ZZZ_WIN";
    // the model key of the window states - z2ui5_if_ui5_types=>
    // cv_window_model_key
    const META = "__WINDOW";

    // the name of a windowed list: its absolute path without the leading
    // slash, the way the backend writes it - `{/MT_ROWS}`, `{/MR_TAB/*}` for
    // a table behind a data reference, `{/MS_DATA/T_ROWS}` for one in a
    // structure. The window state mirrors it: /__WINDOW/MR_TAB/*. A path
    // relative to a context is no window
    function windowName(sPath, oContext) {
      if (oContext || typeof sPath !== "string") return undefined;
      const match = /^\/([^/].*?)\/?$/.exec(sPath);
      return match ? match[1] : undefined;
    }

    function toArray(value) {
      if (!value) return [];
      return Array.isArray(value) ? value : [value];
    }

    // a filter value as the backend compares it: a Date as the model
    // carries a date (yyyy-MM-dd), everything else as it is
    function wireValue(value) {
      // by its tag, not instanceof: a Date of another realm (a frame) is one
      if (Object.prototype.toString.call(value) === "[object Date]") {
        const pad = (n) => String(n).padStart(2, "0");
        return `${value.getFullYear()}-${pad(value.getMonth() + 1)}-${pad(value.getDate())}`;
      }
      return value ?? null;
    }

    function isSimple(oFilter) {
      return (
        !!oFilter &&
        !oFilter.aFilters &&
        !oFilter.fnTest &&
        typeof oFilter.sPath === "string"
      );
    }

    function filterRow(oFilter) {
      return [
        oFilter.sPath,
        oFilter.sOperator,
        wireValue(oFilter.oValue1),
        wireValue(oFilter.oValue2),
      ];
    }

    // The filters of a binding as the backend takes them: groups ANDed, the
    // conditions of a group ORed (z2ui5_if_ui5_types=>ty_t_window_filter).
    // UI5's own rule for a list of filters is kept: the ones on one path are
    // ORed, the paths ANDed. A multi-filter is taken apart when it has that
    // shape - an AND of single conditions or of ORs of them, an OR of single
    // conditions; anything deeper, or a filter with a test function, has no
    // wire form and is left out with a log line.
    function filterGroups(aFilters) {
      const groups = [];
      const byPath = new Map();
      const unsupported = () =>
        Lib.logError(
          "WINDOW: a filter of this shape is not sent to the server",
        );
      for (const oFilter of toArray(aFilters)) {
        if (isSimple(oFilter)) {
          if (!byPath.has(oFilter.sPath)) {
            const group = [];
            byPath.set(oFilter.sPath, group);
            groups.push(group);
          }
          byPath.get(oFilter.sPath).push(filterRow(oFilter));
          continue;
        }
        const children = Array.isArray(oFilter?.aFilters)
          ? oFilter.aFilters
          : null;
        if (!children) {
          unsupported();
          continue;
        }
        if (!oFilter.bAnd) {
          if (children.every(isSimple)) groups.push(children.map(filterRow));
          else unsupported();
          continue;
        }
        for (const child of children) {
          if (isSimple(child)) groups.push([filterRow(child)]);
          else if (
            Array.isArray(child?.aFilters) &&
            !child.bAnd &&
            child.aFilters.every(isSimple)
          )
            groups.push(child.aFilters.map(filterRow));
          else unsupported();
        }
      }
      return groups.filter((group) => group.length);
    }

    function sortWire(aSorters) {
      return toArray(aSorters)
        .filter((oSorter) => typeof oSorter?.sPath === "string")
        .map((oSorter) => ({
          PATH: oSorter.sPath,
          DESCENDING: !!oSorter.bDescending,
        }));
    }

    const WindowListBinding = Env.ownClass(
      JSONListBinding.extend("z2ui5.core.WindowListBinding", {
        constructor: function (
          oModel,
          sPath,
          oContext,
          aSorters,
          aFilters,
          mParameters,
        ) {
          // set before the base constructor runs: it calls update( ), and
          // with it applyFilter( ) / applySort( ) below
          this._z2ui5Name = windowName(sPath, oContext);
          this._z2ui5Wanted = 0;
          // the static sorters and filters of the binding info are not
          // applied - see the header
          JSONListBinding.call(
            this,
            oModel,
            sPath,
            oContext,
            undefined,
            undefined,
            mParameters,
          );
        },
      }),
    );

    // the window state of this list - undefined when it is no window
    WindowListBinding.prototype._z2ui5Meta = function () {
      if (!this._z2ui5Name) return undefined;
      return this.oModel.getProperty(`/${META}/${this._z2ui5Name}`);
    };

    // the rows the backend sorted and filtered arrive in that order: the
    // browser applies neither
    WindowListBinding.prototype.applyFilter = function (...args) {
      if (!this._z2ui5Meta()) {
        return JSONListBinding.prototype.applyFilter.apply(this, args);
      }
      this.iLength = this.aIndices.length;
      return undefined;
    };

    WindowListBinding.prototype.applySort = function (...args) {
      if (!this._z2ui5Meta()) {
        return JSONListBinding.prototype.applySort.apply(this, args);
      }
      return undefined;
    };

    // every model push may carry the rows asked for - the next getContexts
    // past the end asks again if they are not there
    WindowListBinding.prototype.update = function (...args) {
      this._z2ui5Wanted = 0;
      return JSONListBinding.prototype.update.apply(this, args);
    };

    WindowListBinding.prototype.getLength = function (...args) {
      const meta = this._z2ui5Meta();
      if (!meta) return JSONListBinding.prototype.getLength.apply(this, args);
      return Math.max(Number(meta.TOTAL) || 0, this.aIndices.length);
    };

    WindowListBinding.prototype.isLengthFinal = function () {
      return true;
    };

    WindowListBinding.prototype.getContexts = function (...args) {
      const meta = this._z2ui5Meta();
      if (meta) {
        const [iStart, iLength, iThreshold] = args;
        this._z2ui5Ensure(
          meta,
          (iStart || 0) + (iLength || 0) + (iThreshold || 0),
        );
      }
      return JSONListBinding.prototype.getContexts.apply(this, args);
    };

    // ask for the windows that cover `need` rows - once per need, and not
    // past TOTAL
    WindowListBinding.prototype._z2ui5Ensure = function (meta, need) {
      const loaded = this.aIndices.length;
      const total = Number(meta.TOTAL) || 0;
      const size = Number(meta.SIZE) || 1;
      if (need <= loaded || loaded >= total) return;
      const wanted = Math.min(total, Math.ceil(need / size) * size);
      if (wanted <= this._z2ui5Wanted) return;
      this._z2ui5Wanted = wanted;
      this._z2ui5Send(wanted, true);
    };

    WindowListBinding.prototype.sort = function (aSorters, ...rest) {
      const meta = this._z2ui5Meta();
      if (!meta) {
        return JSONListBinding.prototype.sort.call(this, aSorters, ...rest);
      }
      this.aSorters = toArray(aSorters);
      this._z2ui5Restart(meta);
      return this;
    };

    WindowListBinding.prototype.filter = function (aFilters, sFilterType) {
      const meta = this._z2ui5Meta();
      if (!meta) {
        return JSONListBinding.prototype.filter.call(
          this,
          aFilters,
          sFilterType,
        );
      }
      const list = toArray(aFilters);
      if (sFilterType === "Application") {
        this.aApplicationFilters = list;
      } else if (sFilterType === "Control") {
        this.aFilters = list;
      } else {
        this.aFilters = list;
        this.aApplicationFilters = [];
      }
      this._z2ui5Restart(meta);
      return this;
    };

    // a new order: the first window of it
    WindowListBinding.prototype._z2ui5Restart = function (meta) {
      this._z2ui5Wanted = Number(meta.SIZE) || 0;
      this._z2ui5Send(this._z2ui5Wanted, false);
    };

    WindowListBinding.prototype._z2ui5Send = function (count, noBusy) {
      const send = this.oModel._z2ui5WindowSend;
      if (typeof send !== "function") {
        Lib.logError(`WINDOW: no way to the server for /${this._z2ui5Name}`);
        return;
      }
      // the control's filters and the app's are ANDed, as UI5 does it
      const groups = [
        ...filterGroups(this.aFilters),
        ...filterGroups(this.aApplicationFilters),
      ];
      send(
        [
          `/${this._z2ui5Name}`,
          String(count),
          JSON.stringify(sortWire(this.aSorters)),
          JSON.stringify(groups),
        ],
        noBusy,
      );
    };

    const WindowModel = Env.ownClass(
      JSONModel.extend("z2ui5.core.WindowModel", {
        bindList(sPath, oContext, aSorters, aFilters, mParameters) {
          const name = windowName(sPath, oContext);
          if (name && this.getProperty(`/${META}/${name}`)) {
            return new WindowListBinding(
              this,
              sPath,
              oContext,
              aSorters,
              aFilters,
              mParameters,
            );
          }
          return JSONModel.prototype.bindList.call(
            this,
            sPath,
            oContext,
            aSorters,
            aFilters,
            mParameters,
          );
        },
      }),
    );

    WindowModel.EVENT = EVENT;
    // for the specs
    WindowModel.filterGroups = filterGroups;
    WindowModel.sortWire = sortWire;

    return WindowModel;
  },
);
