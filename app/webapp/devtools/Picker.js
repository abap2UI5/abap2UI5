// Control picker of the developer tools.
//
// Answers the question the developer tools could not answer before: "this
// control on the screen - which ABAP attribute feeds it, and what is in it
// right now?". The user clicks a control, and the picker reports its id,
// type, owning view slot, every binding it carries with the CURRENT value
// behind each path, and the backend events bound on it.
//
// Outside the framework like the rest of devtools/: it works purely
// against the public UI5 element API and the view-slot registry, and
// installs its own document listener only while a pick is running.
sap.ui.define(
  [
    "sap/ui/core/Element",
    "z2ui5/core/Lib",
    "z2ui5/core/ViewSlots",
    "z2ui5/devtools/Format",
  ],
  (Element, Lib, ViewSlots, Format) => {
    "use strict";

    // the framework event wire, shared with the inspectors (see Format)
    const { FRAMEWORK_CALL } = Format;

    // Preview length of a bound value in the report.
    const MAX_VALUE_CHARS = 80;

    // Highlight drawn over the control under the cursor while picking.
    const OVERLAY_ID = "z2ui5DevToolsPickerOverlay";

    let active = false;
    let onDone = null;
    let boundMove = null;
    let boundClick = null;
    let boundKey = null;
    // the DOM node under the cursor as of the last mousemove, and the frame
    // a highlight is scheduled for - see boundMove
    let lastNode = null;
    let frameId = 0;

    // The report of the last successful pick, so the Picked Control tab
    // can be rendered from the registry like every other tab.
    let lastPickReport = "";

    function truncate(value, max) {
      const text = String(value);
      return text.length <= max ? text : `${text.slice(0, max)}...`;
    }

    // Resolve the UI5 control that owns a DOM node. Element.closestTo
    // arrived in 1.106; on older releases walk up to the nearest node
    // carrying a UI5 id and look that up instead.
    function controlFromDom(node) {
      if (!node) return null;
      if (Element.closestTo) {
        try {
          return Element.closestTo(node) || null;
        } catch {
          return null;
        }
      }
      let current = node;
      while (current && current !== document.body) {
        const id = current.id;
        if (id) {
          const control = Lib.getElementById(id);
          if (control) return control;
        }
        current = current.parentElement;
      }
      return null;
    }

    function overlay() {
      let el = document.getElementById(OVERLAY_ID);
      if (!el) {
        el = document.createElement("div");
        el.id = OVERLAY_ID;
        el.style.position = "fixed";
        el.style.pointerEvents = "none";
        el.style.zIndex = "2147483647";
        el.style.background = "rgba(0, 112, 242, 0.25)";
        el.style.border = "2px solid #0070f2";
        el.style.borderRadius = "2px";
        el.style.display = "none";
        document.body.appendChild(el);
      }
      return el;
    }

    function highlight(control) {
      const el = overlay();
      const dom = control?.getDomRef?.();
      if (!dom) {
        el.style.display = "none";
        return;
      }
      const rect = dom.getBoundingClientRect();
      el.style.display = "block";
      el.style.left = `${rect.left}px`;
      el.style.top = `${rect.top}px`;
      el.style.width = `${rect.width}px`;
      el.style.height = `${rect.height}px`;
    }

    function removeOverlay() {
      document.getElementById(OVERLAY_ID)?.remove();
    }

    // The binding info UI5 keeps per property/aggregation, flattened to
    // { name, path, model, value }. Composite bindings (an expression over
    // several paths) contribute one row per part, which is exactly what a
    // developer chasing "which attribute is wrong" needs to see.
    function collectBindings(control) {
      const out = [];
      const infos = control.mBindingInfos || {};
      for (const [name, info] of Object.entries(infos)) {
        const parts = info.parts || (info.path !== undefined ? [info] : []);
        for (const part of parts) {
          const model = control.getModel(part.model);
          let value;
          try {
            value = model?.getProperty
              ? model.getProperty(
                  part.path,
                  control.getBindingContext(part.model),
                )
              : undefined;
          } catch {
            value = undefined;
          }
          out.push({
            name,
            path: part.path,
            model: part.model || "(default)",
            value,
          });
        }
      }
      return out;
    }

    // The XML a view slot was filled with - the two readers Inspect.slotXml
    // documents, in the same order.
    function slotXml(slotKey) {
      if (!slotKey) return "";
      return (
        ViewSlots.getView?.(slotKey)?.mProperties?.viewContent ||
        ViewSlots.getViewXml?.(slotKey) ||
        ""
      );
    }

    // The attributes of the element that declares this control in its
    // slot's XML, found by the control's LOCAL id (the view prefixes the
    // XML id with its own: "mainView--btn1"). Empty for a control the XML
    // gives no id, and for one outside a slot.
    function xmlAttributesOf(control, slotKey) {
      const localId = String(control.getId?.() || "")
        .split("--")
        .pop();
      const xml = slotXml(slotKey);
      if (!localId || !xml) return "";
      const idAttr = new RegExp(`\\sid\\s*=\\s*(?:"${localId}"|'${localId}')`);
      const at = xml.search(idAttr);
      if (at < 0) return "";
      const open = xml.lastIndexOf("<", at);
      const close = xml.indexOf(">", at);
      return open < 0 || close < 0 ? "" : xml.slice(open, close);
    }

    // Event handlers the backend bound on this control. UI5 keeps them in
    // mEventRegistry - but for a `.eB(['NAME'])` view attribute the
    // registered fFunction is EventHandlerResolver's generic wrapper, whose
    // source never contains the event name (it lives in a closure), so the
    // handler's source only answers for a handler attached in code. The
    // name is read where it IS written: off the element's attribute in the
    // slot XML the view was built from, `press=".eB(['SAVE'])"`.
    function collectEvents(control, slotKey) {
      const registry = control.mEventRegistry || {};
      const attributes = xmlAttributesOf(control, slotKey);
      const out = [];
      for (const [name, handlers] of Object.entries(registry)) {
        for (const handler of handlers || []) {
          let match = FRAMEWORK_CALL.exec(String(handler?.fFunction || ""));
          if (!match && attributes) {
            const attr = new RegExp(
              `\\s${name}\\s*=\\s*(?:"([^"]*)"|'([^']*)')`,
            ).exec(attributes);
            match = attr ? FRAMEWORK_CALL.exec(attr[1] ?? attr[2] ?? "") : null;
          }
          out.push(match ? `${name} -> ${match[1]}('${match[2]}')` : name);
        }
      }
      return out.sort();
    }

    function renderValue(value) {
      if (value === undefined) return "(no value at this path)";
      if (value === null) return "null";
      if (Array.isArray(value)) return `table, ${value.length} row(s)`;
      if (typeof value === "object") {
        return `structure, ${Object.keys(value).length} field(s)`;
      }
      if (value === "") return "(empty string)";
      return truncate(value, MAX_VALUE_CHARS);
    }

    // Build the report for a picked control. Exported so it can be unit
    // tested without a DOM pick.
    function describe(control) {
      if (!control) return "(no control found at that position)";
      const out = ["abap2UI5 Developer Tools - Picked control"];
      out.push("");
      out.push(`  Type        ${control.getMetadata?.().getName?.() || "?"}`);
      out.push(`  Id          ${control.getId?.() || "?"}`);
      const slotKey = ViewSlots.containingSlotKey?.(control);
      out.push(`  View slot   ${slotKey || "(not inside a view slot)"}`);

      const bindings = collectBindings(control);
      out.push("");
      out.push("Bindings");
      out.push("--------");
      if (!bindings.length) {
        out.push("  (this control carries no binding - it is static XML)");
      }
      for (const binding of bindings) {
        out.push(`  ${binding.name}`);
        out.push(`      path   ${binding.path}   [model ${binding.model}]`);
        out.push(`      value  ${renderValue(binding.value)}`);
      }

      const events = collectEvents(control, slotKey);
      out.push("");
      out.push("Events");
      out.push("------");
      if (!events.length) out.push("  (no event handler attached)");
      for (const event of events) out.push(`  ${event}`);

      out.push("");
      out.push(
        "  A binding path maps 1:1 onto the ABAP attribute the app bound" +
          " with client->_bind( ): /NAME is the attribute NAME.",
      );
      return out.join("\n");
    }

    function stop() {
      if (!active) return;
      active = false;
      document.removeEventListener("mousemove", boundMove, true);
      document.removeEventListener("click", boundClick, true);
      document.removeEventListener("keydown", boundKey, true);
      boundMove = null;
      boundClick = null;
      boundKey = null;
      if (frameId) {
        cancelAnimationFrame(frameId);
        frameId = 0;
      }
      lastNode = null;
      // the finished callback closes over the developer-tools control -
      // kept past the pick, it held a destroyed control across an FLP
      // navigation. Callers take it before they call stop( )
      onDone = null;
      removeOverlay();
    }

    // Start a pick. `callback` receives the report text for the control the
    // user clicks, or null when the pick was cancelled with Escape. The
    // listeners run in the CAPTURE phase and swallow the click, so picking
    // a button never also presses it.
    function start(callback) {
      if (active) return;
      active = true;
      onDone = callback;

      // mousemove fires at pointer rate, and each highlight is a control
      // lookup plus a getBoundingClientRect( ) - a forced layout. Nothing
      // to do while the pointer stays over the same node, and at most one
      // lookup-and-measure per frame otherwise.
      boundMove = (event) => {
        if (event.target === lastNode) return;
        lastNode = event.target;
        if (frameId) return;
        frameId = requestAnimationFrame(() => {
          frameId = 0;
          if (active) highlight(controlFromDom(lastNode));
        });
      };
      boundClick = (event) => {
        event.preventDefault();
        event.stopPropagation();
        const control = controlFromDom(event.target);
        let report;
        try {
          report = describe(control);
        } catch (e) {
          Lib.logError("DevTools Picker: describe failed", e);
          report = "(could not inspect that control)";
        }
        // Kept here rather than on the dialog: the Picked Control tab is
        // rendered from the tab registry like every other tab, and the
        // registry must be able to reach a tab's content without the
        // dialog handing it over.
        lastPickReport = report;
        const done = onDone;
        stop();
        if (done) done(report);
      };
      boundKey = (event) => {
        if (event.key !== "Escape") return;
        event.preventDefault();
        event.stopPropagation();
        const done = onDone;
        stop();
        if (done) done(null);
      };

      document.addEventListener("mousemove", boundMove, true);
      document.addEventListener("click", boundClick, true);
      document.addEventListener("keydown", boundKey, true);
    }

    return {
      start,
      stop,
      describe,
      isActive: () => active,
      // The report of the most recent successful pick, "" before the
      // first one. A cancelled pick (Escape) leaves the previous report
      // standing - the user did not ask to throw it away.
      lastReport: () => lastPickReport,
      _internals: { collectBindings, collectEvents, renderValue },
    };
  },
);
