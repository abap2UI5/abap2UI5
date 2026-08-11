sap.ui.define(
  [
    "sap/ui/core/Element",
    "z2ui5/core/Lib",
    "z2ui5/core/ViewSlots",
    "z2ui5/core/AppState",
  ],
  (Element, Lib, ViewSlots, AppState) => {
    "use strict";

    // ------------------------------------------------------------------
    // Focus and scroll capture for the request: which control holds the
    // focus (with its caret) and which element the user last scrolled in
    // each view slot - the S_FOCUS / S_SCROLL blocks of S_FRONT, read by
    // Server.roundtrip on every event. The backend does not act on them
    // itself: it exposes them to the app (client->get( )), which echoes a
    // SET_FOCUS / SCROLL_TO follow-up action to restore after a re-render.
    // ------------------------------------------------------------------

    // Resolve the UI5 element owning a DOM node. Element.closestTo exists
    // as of UI5 1.106; on older bootstraps walk up the DOM to the nearest
    // rendered control root (marked with the data-sap-ui attribute) and
    // resolve it via the core registry, so scroll and focus capture also
    // work there.
    function closestUi5Element(dom) {
      if (Element.closestTo) return Element.closestTo(dom) ?? null;
      let el = dom;
      while (el && el.getAttribute) {
        if (el.hasAttribute("data-sap-ui")) {
          // ui5lint-disable-next-line no-globals, no-deprecated-api -- only resolution path on UI5 < 1.106
          return sap.ui.getCore().byId(el.id) || null;
        }
        el = el.parentElement;
      }
      return null;
    }

    // Strip the owning view's "<viewId>--" prefix from a control id so the
    // backend gets the id as the app declared it. Returns the id unchanged
    // when it does not belong to that view.
    function stripViewPrefix(fullId, view) {
      if (!view) return fullId;
      const prefix = `${view.getId()}--`;
      return fullId.startsWith(prefix) ? fullId.slice(prefix.length) : fullId;
    }

    // Resolve the text field that carries the caret for the focused control:
    // the active element itself when it is already an <input>/<textarea>,
    // otherwise the control's focus DOM ref (or the first inner text field).
    // Returns null when the control has no text field (e.g. a button), so the
    // caller omits the selection instead of reporting a bogus 0.
    function focusTextInput(active, ui5El) {
      if (Lib.isTextInput(active)) return active;
      const focusRef = ui5El?.getFocusDomRef?.();
      if (Lib.isTextInput(focusRef)) return focusRef;
      const root = ui5El?.getDomRef?.();
      const inner = root?.querySelector?.("input, textarea");
      return Lib.isTextInput(inner) ? inner : null;
    }

    // Returning undefined when no UI5 control owns the focus lets
    // JSON.stringify omit S_FOCUS from the request entirely, matching
    // getScrollInfo (the backend treats a missing key like an empty one).
    function getFocusInfo() {
      try {
        const active = document.activeElement;
        if (!active) return undefined;
        const ui5El = closestUi5Element(active);
        if (!ui5El) return undefined;
        const fullId = ui5El.getId();
        let id = fullId;
        for (const slot of ViewSlots.slots) {
          const local = stripViewPrefix(fullId, ViewSlots.getView(slot.key));
          if (local !== fullId) {
            id = local;
            break;
          }
        }
        // Read the caret from the actual text field, not from
        // document.activeElement directly. Clicking an inner part of a
        // control (e.g. a SearchField's clear "X" button) can leave the
        // active element a non-text node. When no text field owns a
        // selection, omit SELECTION_* entirely so the backend restores
        // focus without forcing a caret position.
        const info = { ID: id };
        const caret = Lib.readCaret(focusTextInput(active, ui5El));
        if (caret) {
          info.SELECTION_START = caret.start;
          info.SELECTION_END = caret.end;
        }
        return info;
      } catch {
        return undefined;
      }
    }

    // The per-element resolution cache of onScrollCapture (see there).
    // An object rather than three locals so the unit specs can observe the
    // release behavior of getScrollInfo.
    const _scrollCache = {
      target: undefined,
      ui5El: undefined,
      slotKey: undefined,
    };

    // Records which element the user actually scrolled, per view slot.
    // Bound to a single document-level capture-phase listener (installed
    // in Component.init): scroll events do not bubble, but they do fire
    // capture listeners on ancestors, so one listener observes every
    // scrollable container - no per-roundtrip walk over the control tree,
    // and no guessing which container "looks scrolled".
    function onScrollCapture(event) {
      const target = event.target;
      if (!target || target.nodeType !== 1) return;

      // Scroll events fire up to once per frame per element while the user
      // drags, but the same DOM element keeps firing throughout a gesture.
      // Resolving the UI5 control (closestUi5Element) and walking it up to
      // its view slot (ViewSlots.containingSlotKey) is the expensive part,
      // so cache that resolution keyed by the element: it runs once per
      // scrolled element instead of once per event. Only the cheap
      // scroll-position record stays per event.
      if (target !== _scrollCache.target) {
        const ui5El = closestUi5Element(target);
        _scrollCache.target = target;
        _scrollCache.ui5El = ui5El;
        _scrollCache.slotKey = ui5El
          ? ViewSlots.containingSlotKey(ui5El)
          : undefined;
      }

      if (_scrollCache.slotKey) {
        AppState.state.lastScrolled[_scrollCache.slotKey] = {
          control: _scrollCache.ui5El,
          dom: target,
        };
      }
    }

    function getScrollInfo() {
      // Release the per-element resolution cache of onScrollCapture once
      // its DOM node left the document (view replaced/destroyed) - the
      // detached element and its control would otherwise stay referenced
      // until the user scrolls the next time.
      if (_scrollCache.target && !_scrollCache.target.isConnected) {
        _scrollCache.target = undefined;
        _scrollCache.ui5El = undefined;
        _scrollCache.slotKey = undefined;
      }

      // Reads scrollLeft/scrollTop straight from the DOM element the user
      // last scrolled in each view slot (recorded by onScrollCapture).
      // X = scrollLeft, Y = scrollTop. Slots the user never scrolled are
      // absent from the result - restoring 0/0 would be a no-op anyway.
      const store = AppState.state.lastScrolled;
      const out = {};
      for (const slot of ViewSlots.slots) {
        const entry = store[slot.key];
        if (!entry) continue;

        // Drop stale references, e.g. after the view was replaced. Also
        // drop a destroyed control whose DOM is still transiently
        // connected: entry.control.getId() below would throw and abort the
        // whole roundtrip (this method, unlike getFocusInfo, has no outer
        // try/catch).
        if (!entry.dom.isConnected || !Lib.isAlive(entry.control)) {
          delete store[slot.key];
          continue;
        }

        const id = stripViewPrefix(
          entry.control.getId(),
          ViewSlots.getView(slot.key),
        );
        out[slot.key] = {
          ID: id,
          X: entry.dom.scrollLeft || 0,
          Y: entry.dom.scrollTop || 0,
        };
      }
      // Returning undefined lets JSON.stringify omit S_SCROLL entirely.
      return Object.keys(out).length ? out : undefined;
    }

    // closestUi5Element and focusTextInput are pure resolution helpers,
    // exported (with the cache) for the unit specs.
    return {
      getFocusInfo,
      getScrollInfo,
      onScrollCapture,
      closestUi5Element,
      focusTextInput,
      _scrollCache,
    };
  },
);
