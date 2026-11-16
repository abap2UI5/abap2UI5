// The framework's JSON model, with the list binding of a WINDOWED table.
//
// A table bound with `window_bind_tab( val = mt_rows window = 100 )` does not travel
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
//
// THE ORDER IS THE BACKEND'S, and this binding does not know it. The app
// sets one with t_sort / t_filter of window_bind_tab( ), a binding of a view
// rendered before may have set one, and none of that is in aSorters or
// aFilters here. So a request says only what THIS binding was just told:
//   - a request for more rows says nothing - more rows of the same order;
//   - sort( ) names the sorters and nothing else, filter( ) the filters
//     and nothing else, so a column filter does not undo the app's sort.
// Every request used to carry aSorters and the filters, and the backend
// took them as the order: the first "More" after an app sort sent an empty
// list and the rows came back unsorted and unfiltered. The other way to
// mend that - the response hands the order over and the binding adopts and
// re-sends it - was not taken: a request then carries a copy of the order
// that may be stale by the time it is sent (kept behind a roundtrip in
// which the app changed the sort, it would undo that), and nothing here
// reads the order. The backend's half of this is
// z2ui5_cl_ui5_srv_window=>event_apply.
// What filter( ) sends is the binding's filter, and the backend ANDs it
// with the app's t_filter: neither replaces the other.
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

    // zero-pad a date part - hoisted so wireValue does not build the closure
    // anew for every Date of every filter it sends
    const pad = (n) => String(n).padStart(2, "0");

    // a filter value as the backend compares it: a Date as the model
    // carries a date (yyyy-MM-dd), everything else as it is
    function wireValue(value) {
      // by its tag, not instanceof: a Date of another realm (a frame) is one
      if (Object.prototype.toString.call(value) === "[object Date]") {
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
      this._z2ui5Restart(meta, { sort: true });
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
      this._z2ui5Restart(meta, { filter: true });
      return this;
    };

    // a new order: the first window of it. `said` is the part of the order
    // the binding was just told - see the header
    WindowListBinding.prototype._z2ui5Restart = function (meta, said) {
      this._z2ui5Wanted = Number(meta.SIZE) || 0;
      this._z2ui5Send(this._z2ui5Wanted, false, said);
    };

    // [path, count] asks for rows; a third argument names the sorters, a
    // fourth the filter groups - an argument left out (or empty, for the
    // sort of a request that names a filter) says nothing about that part
    WindowListBinding.prototype._z2ui5Send = function (count, noBusy, said) {
      const send = this.oModel._z2ui5WindowSend;
      if (typeof send !== "function") {
        Lib.logError(`WINDOW: no way to the server for /${this._z2ui5Name}`);
        return;
      }
      const args = [`/${this._z2ui5Name}`, String(count)];
      if (said?.sort) args[2] = JSON.stringify(sortWire(this.aSorters));
      if (said?.filter) {
        args[2] = args[2] ?? "";
        // the two filter types of a UI5 binding, Control and Application,
        // are ANDed as UI5 does it - together they are the binding's
        // filter, which the backend ANDs with the app's t_filter
        args[3] = JSON.stringify([
          ...filterGroups(this.aFilters),
          ...filterGroups(this.aApplicationFilters),
        ]);
      }
      send(args, noBusy);
    };

    // Two window requests of one table, the first still waiting behind a
    // roundtrip when the second comes (one slot, the last one wins -
    // AppState, oQueuedWindow): the second takes over what the first named
    // and it does not name itself. Since a request names only what the
    // binding was told, the request for more rows a table sends while its
    // sort( ) still waits would otherwise replace it, and the sort would be
    // lost without a word. Requests of two tables share nothing.
    function keepSaid(args, kept) {
      if (!Array.isArray(kept) || kept[0] !== args[0]) return args;
      const sort = args[2] || kept[2] || "";
      const filter = args[3] || kept[3] || "";
      const merged = [args[0], args[1]];
      if (sort || filter) merged[2] = sort;
      if (filter) merged[3] = filter;
      return merged;
    }

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
    WindowModel.keepSaid = keepSaid;

    return WindowModel;
  },
);
