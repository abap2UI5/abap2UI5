// The Bindings tab of the developer tools - a slot's model attributes,
// and the three checks that answer the most common developer questions.
//
//   empty field        the paths the view binds that the model does NOT
//                      have (a typo, a renamed ABAP attribute, a missing
//                      client->_bind( ))
//   huge response      the attributes ranked by serialized size
//   change not sent    the paths the user edited, and the delta the next
//                      roundtrip will actually put on the wire
//
// Split out of devtools/Inspect.js, which re-exports formatBindings for
// the tab registry. Outside the framework like the rest of devtools/: it
// only reads the slot's model and XML of the component context it is
// handed (core/Context.js, ctx first) and renders them as text.
sap.ui.define(
  [
    "z2ui5/core/Lib",
    "z2ui5/core/ViewSlots",
    "z2ui5/devtools/Format",
    "z2ui5/devtools/SlotXml",
  ],
  (Lib, ViewSlots, Format, SlotXml) => {
    "use strict";

    const { truncate, formatBytes, section, describeValue } = Format;

    // An absolute binding path in view XML: a `{/A` binding, `${/A` in
    // an expression, path:'/A', parts:['/A','/B'] (the comma continues a
    // parts list). Any quote followed by "/" used to count, which read
    // src="/sap/public/..." and href="/some/page" as bindings of /sap and
    // /some and reported them as missing from the model
    const BINDING_PATH =
      /(?:\{\s*|\$\{\s*|path\s*:\s*['"]|parts\s*:\s*\[\s*['"]|,\s*['"])\/([A-Za-z_][A-Za-z0-9_]*)/g;

    // The typed description of a model attribute: "string  Miller AG",
    // "table, 12 row(s)" - see Format.describeValue.
    function describeAttribute(value) {
      return describeValue(value, { typed: true });
    }

    function formatSlotBindings(ctx, slotKey) {
      const view = ViewSlots.getView(ctx, slotKey);
      if (!view) return [];
      // the TRACKED framework model - in switch mode the default model is
      // the app's OData client and a bare getModel( ) read came back empty
      const model = ViewSlots.trackedModel(view);
      const data = model?.getData?.();
      if (!data) return [];
      const out = [section(`Slot ${slotKey}`)];
      // The edited-path set the next roundtrip will ship as its delta.
      // Slots.trackChanges parks it on the model itself; nothing surfaces
      // it today, which is why "why was my edit not sent" is hard to answer.
      // read only below, so the model's own set serves as is - no copy
      const dirty = model._z2ui5ChangedPaths || new Set();
      // a table edit is tracked on the deep path, so an attribute is dirty
      // when any tracked path starts with it: the attribute is the first
      // segment (`/TAB/0/COL` -> TAB, the rule buildDeltaFromPaths applies).
      // Derived once - the loop below used to materialise the whole set
      // and scan it per attribute, attributes x edited paths on every render
      const dirtyAttrs = new Set(
        Array.from(dirty, (p) => p.split("/")[1]).filter(Boolean),
      );
      const keys = Object.keys(data).sort();
      if (!keys.length) out.push("  (model is empty)");
      for (const key of keys) {
        const path = `/${key}`;
        const isDirty = dirtyAttrs.has(key);
        out.push(
          `  ${isDirty ? "*" : " "} ${path.padEnd(30)}${describeAttribute(data[key])}`,
        );
      }
      if (dirty.size) {
        out.push("");
        out.push("  Edited paths queued for the next roundtrip:");
        for (const path of Array.from(dirty).sort()) out.push(`    ${path}`);
      }
      out.push(...formatPendingDelta(dirty, data));
      out.push(...formatBindingCheck(ctx, slotKey, data));
      out.push(...formatSizeRanking(data));
      return out;
    }

    // Absolute model paths bound in a view's XML. Only the ABSOLUTE ones
    // ("{/NAME}", "{path: '/NAME'}", "${/NAME}" inside an expression) can be
    // checked against the model - a relative binding inside an aggregation
    // template ("{COL}") resolves against the row context and says nothing
    // on its own, so it is deliberately not collected.
    //
    // Returns the top-level ATTRIBUTE of each path ("/TAB/0/COL" -> "TAB"),
    // because that is what client->_bind( ) creates and what the model has
    // as a key.
    function scrapeBindingAttributes(xml) {
      if (!xml) return [];
      const found = new Set();
      // a "/" only where a BINDING starts an absolute path: {/A}, ${/A} in
      // an expression, path:'/A', parts:['/A','/B'] - see BINDING_PATH
      for (const match of xml.matchAll(BINDING_PATH)) found.add(match[1]);
      return Array.from(found).sort();
    }

    // The check that answers "why is my field empty": every absolute path
    // the view binds, against the attributes the model actually carries. A
    // renamed ABAP attribute, a typo, or a forgotten client->_bind( ) all
    // land here, and nothing else in the tools makes them visible.
    function formatBindingCheck(ctx, slotKey, data) {
      const bound = scrapeBindingAttributes(SlotXml.slotXml(ctx, slotKey));
      if (!bound.length) return [];
      const missing = bound.filter((name) => !(name in data));
      const out = [];
      if (missing.length) {
        out.push("");
        out.push("  BOUND IN THE VIEW BUT NOT IN THE MODEL:");
        for (const name of missing) out.push(`    /${name}`);
        out.push(
          "    -> a typo, a renamed ABAP attribute, or a missing" +
            " client->_bind( ).",
        );
      }
      // The other direction is worth one line, not a list: an unbound
      // attribute is wasted payload, not a defect.
      const boundSet = new Set(bound);
      const unused = Object.keys(data).filter((name) => !boundSet.has(name));
      if (unused.length) {
        out.push("");
        out.push(
          `  ${unused.length} model attribute(s) not bound in this view:` +
            ` ${unused.slice(0, 12).join(", ")}` +
            `${unused.length > 12 ? ", ..." : ""}`,
        );
      }
      return out;
    }

    // Serialized size of one model attribute. This is the number that
    // explains a large response - and the ranking below turns "the response
    // is 800 KB" into "/T_ITEMS is 92 % of it".
    function attributeSize(value) {
      try {
        const json = JSON.stringify(value);
        return json === undefined ? 0 : json.length;
      } catch {
        return 0;
      }
    }

    function formatSizeRanking(data) {
      const sizes = Object.keys(data)
        .map((name) => ({ name, size: attributeSize(data[name]) }))
        .sort((a, b) => b.size - a.size);
      const total = sizes.reduce((sum, entry) => sum + entry.size, 0);
      if (!total) return [];
      const out = ["", `  Model size: ${formatBytes(total)} serialized`];
      // Only the heavy end is interesting; a long tail of small scalars
      // would bury it.
      for (const entry of sizes.slice(0, 8)) {
        if (!entry.size) continue;
        const share = Math.round((entry.size * 100) / total);
        const rows = Array.isArray(data[entry.name])
          ? `, ${data[entry.name].length} row(s)`
          : "";
        out.push(
          `    ${`/${entry.name}`.padEnd(30)}${formatBytes(entry.size).padStart(8)}` +
            `  ${String(share).padStart(3)}%${rows}`,
        );
      }
      return out;
    }

    // The delta the NEXT roundtrip will actually put on the wire, built
    // with the very function the framework uses for it
    // (Lib.buildDeltaFromPaths). Answers "why does my change not arrive in
    // the backend" BEFORE the roundtrip instead of after it.
    function formatPendingDelta(dirty, data) {
      if (!dirty.size) return [];
      const out = ["", "  Delta the next roundtrip will send:"];
      try {
        const delta = Lib.buildDeltaFromPaths(dirty, data);
        const json = JSON.stringify(delta, null, 2);
        for (const line of truncate(json, 1200).split("\n")) {
          out.push(`    ${line}`);
        }
      } catch (e) {
        Lib.logError("DevTools Bindings: building the delta preview failed", e);
        out.push("    (could not be built)");
      }
      return out;
    }

    // The report for ONE slot - the one the developer tools' slot selector
    // shows; the tab registry renders every model-owning slot as its own
    // tab. A slot that owns no model (NEST and NEST2 inherit MAIN's) or
    // holds no view yet reports that nothing carries a model.
    function formatBindings(ctx, slotKey) {
      const out = ["abap2UI5 Developer Tools - Model bindings"];
      out.push("");
      out.push(
        "  A '*' marks an attribute the user edited: those paths travel as" +
          " the delta of the next roundtrip.",
      );
      out.push(
        "  MAIN, NEST and NEST2 share one model by UI5 propagation, so they" +
          " are listed once, under MAIN.",
      );
      const slot = ViewSlots.slots.find(
        (entry) => entry.key === slotKey && entry.ownsModel,
      );
      const lines = slot ? formatSlotBindings(ctx, slot.key) : [];
      if (lines.length) {
        out.push(...lines);
      } else {
        out.push("\n  (no slot carries a model yet)");
      }
      return out.join("\n");
    }

    return {
      formatBindings,
      // exposed for the unit specs
      _internals: { scrapeBindingAttributes },
    };
  },
);
