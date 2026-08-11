* =====================================================================
* GENERATED FILE - DO NOT EDIT (AGENTS.md rule 2)
* Embedded frontend resource, generated from app/webapp/ by
* .github/app2abap/trans2abap.js. Change the source under app/webapp/
* and run 'npm run app2abap' to regenerate; the check_app2abap CI gate
* fails any manual edit here.
* =====================================================================
CLASS z2ui5_cl_app_scrollfocus_js DEFINITION
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


CLASS z2ui5_cl_app_scrollfocus_js IMPLEMENTATION.

  METHOD get.

    result = `sap.ui.define(` && |\n| &&
             `  [` && |\n| &&
             `    "sap/ui/core/Element",` && |\n| &&
             `    "z2ui5/core/Lib",` && |\n| &&
             `    "z2ui5/core/ViewSlots",` && |\n| &&
             `    "z2ui5/core/AppState",` && |\n| &&
             `  ],` && |\n| &&
             `  (Element, Lib, ViewSlots, AppState) => {` && |\n| &&
             `    "use strict";` && |\n| &&
             `` && |\n| &&
             `    // ------------------------------------------------------------------` && |\n| &&
             `    // Focus and scroll capture for the request: which control holds the` && |\n| &&
             `    // focus (with its caret) and which element the user last scrolled in` && |\n| &&
             `    // each view slot - the S_FOCUS / S_SCROLL blocks of S_FRONT, read by` && |\n| &&
             `    // Server.roundtrip on every event. The backend does not act on them` && |\n| &&
             `    // itself: it exposes them to the app (client->get( )), which echoes a` && |\n| &&
             `    // SET_FOCUS / SCROLL_TO follow-up action to restore after a re-render.` && |\n| &&
             `    // ------------------------------------------------------------------` && |\n| &&
             `` && |\n| &&
             `    // Resolve the UI5 element owning a DOM node. Element.closestTo exists` && |\n| &&
             `    // as of UI5 1.106; on older bootstraps walk up the DOM to the nearest` && |\n| &&
             `    // rendered control root (marked with the data-sap-ui attribute) and` && |\n| &&
             `    // resolve it via the core registry, so scroll and focus capture also` && |\n| &&
             `    // work there.` && |\n| &&
             `    function closestUi5Element(dom) {` && |\n| &&
             `      if (Element.closestTo) return Element.closestTo(dom) ?? null;` && |\n| &&
             `      let el = dom;` && |\n| &&
             `      while (el && el.getAttribute) {` && |\n| &&
             `        if (el.hasAttribute("data-sap-ui")) {` && |\n| &&
             `          // Lib.getElementById carries the version fallback for the lookup` && |\n| &&
             `          return Lib.getElementById(el.id);` && |\n| &&
             `        }` && |\n| &&
             `        el = el.parentElement;` && |\n| &&
             `      }` && |\n| &&
             `      return null;` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // Strip the owning view's "<viewId>--" prefix from a control id so the` && |\n| &&
             `    // backend gets the id as the app declared it. Returns the id unchanged` && |\n| &&
             `    // when it does not belong to that view.` && |\n| &&
             `    function stripViewPrefix(fullId, view) {` && |\n| &&
             `      if (!view) return fullId;` && |\n| &&
             `      const prefix = ``${view.getId()}--``;` && |\n| &&
             `      return fullId.startsWith(prefix) ? fullId.slice(prefix.length) : fullId;` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // Resolve the text field that carries the caret for the focused control:` && |\n| &&
             `    // the active element itself when it is already an <input>/<textarea>,` && |\n| &&
             `    // otherwise the control's focus DOM ref (or the first inner text field).` && |\n| &&
             `    // Returns null when the control has no text field (e.g. a button), so the` && |\n| &&
             `    // caller omits the selection instead of reporting a bogus 0.` && |\n| &&
             `    function focusTextInput(active, ui5El) {` && |\n| &&
             `      if (Lib.isTextInput(active)) return active;` && |\n| &&
             `      const focusRef = ui5El?.getFocusDomRef?.();` && |\n| &&
             `      if (Lib.isTextInput(focusRef)) return focusRef;` && |\n| &&
             `      const root = ui5El?.getDomRef?.();` && |\n| &&
             `      const inner = root?.querySelector?.("input, textarea");` && |\n| &&
             `      return Lib.isTextInput(inner) ? inner : null;` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // Returning undefined when no UI5 control owns the focus lets` && |\n| &&
             `    // JSON.stringify omit S_FOCUS from the request entirely, matching` && |\n| &&
             `    // getScrollInfo (the backend treats a missing key like an empty one).` && |\n| &&
             `    function getFocusInfo() {` && |\n| &&
             `      try {` && |\n| &&
             `        const active = document.activeElement;` && |\n| &&
             `        if (!active) return undefined;` && |\n| &&
             `        const ui5El = closestUi5Element(active);` && |\n| &&
             `        if (!ui5El) return undefined;` && |\n| &&
             `        const fullId = ui5El.getId();` && |\n| &&
             `        let id = fullId;` && |\n| &&
             `        for (const slot of ViewSlots.slots) {` && |\n| &&
             `          const local = stripViewPrefix(fullId, ViewSlots.getView(slot.key));` && |\n| &&
             `          if (local !== fullId) {` && |\n| &&
             `            id = local;` && |\n| &&
             `            break;` && |\n| &&
             `          }` && |\n| &&
             `        }` && |\n| &&
             `        // Read the caret from the actual text field, not from` && |\n| &&
             `        // document.activeElement directly. Clicking an inner part of a` && |\n| &&
             `        // control (e.g. a SearchField's clear "X" button) can leave the` && |\n| &&
             `        // active element a non-text node. When no text field owns a` && |\n| &&
             `        // selection, omit SELECTION_* entirely so the backend restores` && |\n| &&
             `        // focus without forcing a caret position.` && |\n| &&
             `        const info = { ID: id };` && |\n| &&
             `        const caret = Lib.readCaret(focusTextInput(active, ui5El));` && |\n| &&
             `        if (caret) {` && |\n| &&
             `          info.SELECTION_START = caret.start;` && |\n| &&
             `          info.SELECTION_END = caret.end;` && |\n| &&
             `        }` && |\n| &&
             `        return info;` && |\n| &&
             `      } catch {` && |\n| &&
             `        return undefined;` && |\n| &&
             `      }` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // The per-element resolution cache of onScrollCapture (see there).` && |\n| &&
             `    // An object rather than three locals so the unit specs can observe the` && |\n| &&
             `    // release behavior of getScrollInfo.` && |\n| &&
             `    const _scrollCache = {` && |\n| &&
             `      target: undefined,` && |\n| &&
             `      ui5El: undefined,` && |\n| &&
             `      slotKey: undefined,` && |\n| &&
             `    };` && |\n| &&
             `` && |\n| &&
             `    // Records which element the user actually scrolled, per view slot.` && |\n| &&
             `    // Bound to a single document-level capture-phase listener (installed` && |\n| &&
             `    // in Component.init): scroll events do not bubble, but they do fire` && |\n| &&
             `    // capture listeners on ancestors, so one listener observes every` && |\n| &&
             `    // scrollable container - no per-roundtrip walk over the control tree,` && |\n| &&
             `    // and no guessing which container "looks scrolled".` && |\n| &&
             `    function onScrollCapture(event) {` && |\n| &&
             `      const target = event.target;` && |\n| &&
             `      if (!target || target.nodeType !== 1) return;` && |\n| &&
             `` && |\n| &&
             `      // Scroll events fire up to once per frame per element while the user` && |\n| &&
             `      // drags, but the same DOM element keeps firing throughout a gesture.` && |\n| &&
             `      // Resolving the UI5 control (closestUi5Element) and walking it up to` && |\n| &&
             `      // its view slot (ViewSlots.containingSlotKey) is the expensive part,` && |\n| &&
             `      // so cache that resolution keyed by the element: it runs once per` && |\n| &&
             `      // scrolled element instead of once per event. Only the cheap` && |\n| &&
             `      // scroll-position record stays per event.` && |\n| &&
             `      if (target !== _scrollCache.target) {` && |\n| &&
             `        const ui5El = closestUi5Element(target);` && |\n| &&
             `        _scrollCache.target = target;` && |\n| &&
             `        _scrollCache.ui5El = ui5El;` && |\n| &&
             `        _scrollCache.slotKey = ui5El` && |\n| &&
             `          ? ViewSlots.containingSlotKey(ui5El)` && |\n| &&
             `          : undefined;` && |\n| &&
             `      }` && |\n| &&
             `` && |\n| &&
             `      if (_scrollCache.slotKey) {` && |\n| &&
             `        AppState.state.lastScrolled[_scrollCache.slotKey] = {` && |\n| &&
             `          control: _scrollCache.ui5El,` && |\n| &&
             `          dom: target,` && |\n| &&
             `        };` && |\n| &&
             `      }` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function getScrollInfo() {` && |\n| &&
             `      // Release the per-element resolution cache of onScrollCapture once` && |\n| &&
             `      // its DOM node left the document (view replaced/destroyed) - the` && |\n| &&
             `      // detached element and its control would otherwise stay referenced` && |\n| &&
             `      // until the user scrolls the next time.` && |\n| &&
             `      if (_scrollCache.target && !_scrollCache.target.isConnected) {` && |\n| &&
             `        _scrollCache.target = undefined;` && |\n| &&
             `        _scrollCache.ui5El = undefined;` && |\n| &&
             `        _scrollCache.slotKey = undefined;` && |\n| &&
             `      }` && |\n| &&
             `` && |\n| &&
             `      // Reads scrollLeft/scrollTop straight from the DOM element the user` && |\n| &&
             `      // last scrolled in each view slot (recorded by onScrollCapture).` && |\n| &&
             `      // X = scrollLeft, Y = scrollTop. Slots the user never scrolled are` && |\n| &&
             `      // absent from the result - restoring 0/0 would be a no-op anyway.` && |\n| &&
             `      const store = AppState.state.lastScrolled;` && |\n| &&
             `      const out = {};` && |\n| &&
             `      for (const slot of ViewSlots.slots) {` && |\n| &&
             `        const entry = store[slot.key];` && |\n| &&
             `        if (!entry) continue;` && |\n| &&
             `` && |\n| &&
             `        // Drop stale references, e.g. after the view was replaced. Also` && |\n| &&
             `        // drop a destroyed control whose DOM is still transiently` && |\n| &&
             `        // connected: entry.control.getId() below would throw and abort the` && |\n| &&
             `        // whole roundtrip (this method, unlike getFocusInfo, has no outer` && |\n| &&
             `        // try/catch).` && |\n| &&
             `        if (!entry.dom.isConnected || !Lib.isAlive(entry.control)) {` && |\n| &&
             `          delete store[slot.key];` && |\n| &&
             `          continue;` && |\n| &&
             `        }` && |\n| &&
             `` && |\n| &&
             `        const id = stripViewPrefix(` && |\n| &&
             `          entry.control.getId(),` && |\n| &&
             `          ViewSlots.getView(slot.key),` && |\n| &&
             `        );` && |\n| &&
             `        out[slot.key] = {` && |\n| &&
             `          ID: id,` && |\n| &&
             `          X: entry.dom.scrollLeft || 0,` && |\n| &&
             `          Y: entry.dom.scrollTop || 0,` && |\n| &&
             `        };` && |\n| &&
             `      }` && |\n| &&
             `      // Returning undefined lets JSON.stringify omit S_SCROLL entirely.` && |\n| &&
             `      return Object.keys(out).length ? out : undefined;` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // closestUi5Element and focusTextInput are pure resolution helpers,` && |\n| &&
             `    // exported (with the cache) for the unit specs.` && |\n| &&
             `    return {` && |\n| &&
             `      getFocusInfo,` && |\n| &&
             `      getScrollInfo,` && |\n| &&
             `      onScrollCapture,` && |\n| &&
             `      closestUi5Element,` && |\n| &&
             `      focusTextInput,` && |\n| &&
             `      _scrollCache,` && |\n| &&
             `    };` && |\n| &&
             `  },` && |\n| &&
             `);` && |\n| &&
             `` && |\n| &&
              ``.

  ENDMETHOD.

ENDCLASS.
