// BINDING_CALL - the third member of the whitelisted call surface next to
// CONTROL_GLOBAL / CONTROL_BY_ID in core/actions/ControlCall.js, split off
// from it because it shares none of that module's machinery (method deny
// lists, argument kinds, pseudo methods) - only the boolean cast, which it
// borrows so both read an ABAP boolean the same way.
sap.ui.define(
  [
    "sap/ui/model/Filter",
    "sap/ui/model/FilterOperator",
    "sap/ui/model/Sorter",
    "z2ui5/core/Lib",
    "z2ui5/core/ViewSlots",
    "z2ui5/core/actions/ControlCall",
  ],
  (Filter, FilterOperator, Sorter, Lib, ViewSlots, ControlCall) => {
    "use strict";

    // ------------------------------------------------------------------
    // BINDING_CALL: apply a declarative filter/sorter to an aggregation
    // binding of a control resolved by id - the client-side equivalent of
    // the classic demo kit controller pattern
    // oList.getBinding("items").filter([new Filter(...)]). Same safety
    // boundary as CONTROL_BY_ID: only whitelisted binding methods,
    // only whitelisted filter operators, everything built from data
    // (path/operator/values), never from code strings.
    // ------------------------------------------------------------------

    const FILTER_OPERATORS = new Set([
      "BT",
      "Contains",
      "EndsWith",
      "EQ",
      "GE",
      "GT",
      "LE",
      "LT",
      "NB",
      "NE",
      "NotContains",
      "NotEndsWith",
      "NotStartsWith",
      "StartsWith",
    ]);

    const isEmpty = (v) => v == null || v === "";

    // binding method -> builder that turns the trailing params into the
    // aggregation-update call. A strict whitelist (unlike CONTROL_METHODS,
    // which now allows any non-denied public control method): an unlisted
    // binding method fails closed at the lookup.
    //   filter: params = [path, operator, value1, value2?]
    //   sort:   params = [path, descending?, group?] (ABAP bools "X"/"")
    // The backend arg serializer keeps empty args between filled ones as ''
    // placeholders but trims trailing empties, so all optionals sit at the
    // end and may arrive as undefined.
    // Compound form of the filter payload: ONE param carrying a JSON array
    // of groups, each group an array of [path, operator, value1, value2?]
    // rows - OR inside a group, AND across groups (the FacetFilter /
    // ViewSettingsDialog multi-facet shape). Data only: paths, whitelisted
    // operators and values - never code. An empty groups array clears.
    function buildFilterGroups(binding, json) {
      // the backend embeds a '['-starting argument as real JSON, so on that
      // path the groups arrive already parsed; only the XML-bound eF( )
      // string form still needs the parse
      let groups = json;
      if (typeof json === "string") {
        try {
          groups = JSON.parse(json);
        } catch {
          Lib.logError("BINDING_CALL: malformed filter groups JSON");
          return;
        }
      }
      if (!Array.isArray(groups)) {
        Lib.logError("BINDING_CALL: filter groups must be an array");
        return;
      }
      groups = groups.filter((g) => Array.isArray(g) && g.length);
      if (!groups.length) {
        binding.filter([]);
        return;
      }
      const outer = [];
      for (const group of groups) {
        const inner = [];
        for (const row of group) {
          const [path, operator, value1, value2] = Array.isArray(row)
            ? row
            : [];
          if (typeof path !== "string" || !FILTER_OPERATORS.has(operator)) {
            Lib.logError(
              `BINDING_CALL: bad filter row (path '${path}' / operator '${operator}')`,
            );
            return;
          }
          inner.push(
            new Filter(path, FilterOperator[operator], value1, value2),
          );
        }
        outer.push(new Filter(inner, false)); // OR inside the group
      }
      binding.filter([new Filter(outer, true)]); // AND across the groups
    }

    const BINDING_METHODS = {
      filter(binding, params) {
        const [path, operator, value1, value2] = params;
        // A single param that starts with '[' is the compound groups JSON -
        // a model path can never start with '[', so the sniff is
        // unambiguous and the positional single-filter form stays as-is. It
        // arrives as a real array when the backend embedded it as JSON, as a
        // string from the XML-bound eF( ) form.
        if (
          params.length === 1 &&
          (Array.isArray(path) ||
            (typeof path === "string" && path.trimStart().startsWith("[")))
        ) {
          buildFilterGroups(binding, path);
          return;
        }
        // No filter values at all -> clear the filter (the demo kit search
        // pattern: an emptied search field). A one-sided range (empty
        // value1 but a set value2, e.g. BT with only an upper bound) is a
        // real filter, so only clear when BOTH values are empty.
        if (isEmpty(value1) && isEmpty(value2)) {
          binding.filter([]);
          return;
        }
        if (!FILTER_OPERATORS.has(operator)) {
          Lib.logError(`BINDING_CALL: operator '${operator}' not allowed`);
          return;
        }
        binding.filter([
          new Filter(path, FilterOperator[operator], value1, value2),
        ]);
      },
      sort(binding, [path, descending, group]) {
        binding.sort([
          new Sorter(
            path,
            ControlCall.castArg("bool", descending),
            ControlCall.castArg("bool", group),
          ),
        ]);
      },
    };
    // Prototype-less, but written as a plain literal on purpose: the
    // abap2UI5 linter mirrors this set and finds it by the exact source text
    // `const BINDING_METHODS = {` in the embedded carrier (its
    // scripts/check-upstream.mjs). Wrapping the literal in a call made that
    // lookup miss, and the mirror check degraded to "SKIPPED, not verified" -
    // a cross-repository check that stops checking without failing. Same
    // effect, marker intact.
    Object.setPrototypeOf(BINDING_METHODS, null);

    // args: [_, id, aggregation, method, ...params]
    function evBindingCall(oController, args) {
      const [, id, aggregation, method] = args;
      const build = BINDING_METHODS[method];
      if (!build) {
        Lib.logError(`BINDING_CALL: method '${method}' not allowed`);
        return;
      }
      const binding = ViewSlots.resolveById(oController?.ctx, id)?.getBinding?.(
        aggregation,
      );
      if (!binding || typeof binding[method] !== "function") {
        Lib.logError(
          `BINDING_CALL: no '${aggregation}' binding with '${method}' on control '${id}'`,
        );
        return;
      }
      build(binding, args.slice(4));
    }

    // The events this module owns in the eF dispatch (see
    // core/FrontendAction.js, which merges the domain modules' handler maps).
    const handlers = {
      BINDING_CALL: evBindingCall,
    };

    return { handlers };
  },
);
