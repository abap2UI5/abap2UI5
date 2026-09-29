sap.ui.define(
  [
    "sap/ui/core/Element",
    "z2ui5/core/Lib",
    "z2ui5/core/Env",
    "z2ui5/core/ViewSlots",
    "z2ui5/core/Context",
  ],
  (Element, Lib, Env, ViewSlots, Context) => {
    "use strict";

    // ------------------------------------------------------------------
    // Focus and scroll capture for the request: which control holds the
    // focus (with its caret) and which element the user last scrolled in
    // each view slot - the S_FOCUS / S_SCROLL blocks of S_FRONT, read by
    // Server.roundtrip on every event. The backend does not act on them
    // itself: it exposes them to the app (client->get( )), which echoes a
    // SET_FOCUS / SCROLL_TO follow-up action to restore after a re-render.
    // Per component: the records live on the context (`ctx.state.
    // lastScrolled`, `ctx.scroll`), and the document-level scroll listener
    // Component.init installs per context records only elements inside
    // that context's slots.
    //
    // And the other direction, for an EMBEDDED component (state.embedded):
    // whether the framework may MOVE the focus at all - see mayMoveFocus.
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
          // Env.getElementById carries the version fallback for the lookup
          return Env.getElementById(el.id);
        }
        el = el.parentElement;
      }
      return null;
    }

    // Strip the owning slot's id prefix from a control id so the backend
    // gets the id as the app declared it. Returns the id unchanged when the
    // control does not belong to that slot.
    //
    // The prefix comes from the slot's fragment id where it has one (POPUP
    // and POPOVER - see ViewSlots.slots), and only otherwise from the view
    // id. A fragment's inner controls are registered under the FRAGMENT id
    // ("popupId--input"), while the instance the slot holds is the fragment
    // ROOT control, whose own id is something else entirely (an auto-
    // generated "__dialog0", or "popupId--<rootId>"). Stripping that root
    // id therefore matched nothing: the same control was reported as
    // "input" in MAIN and as "popupId--input" in a dialog, and the
    // SET_FOCUS / SCROLL_TO the app echoed back resolves through
    // Fragment.byId, which prefixed the id a second time - so restoring
    // focus or the scroll position in a popup silently found no control.
    function stripSlotPrefix(ctx, fullId, slot) {
      const view = ViewSlots.getView(ctx, slot.key);
      if (!view) return fullId;
      const prefix = slot.fragmentId
        ? `${ViewSlots.fragmentIdOf(ctx, slot)}--`
        : `${view.getId()}--`;
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
    function getFocusInfo(ctx) {
      try {
        const active = document.activeElement;
        if (!active) return undefined;
        const ui5El = closestUi5Element(active);
        if (!ui5El) return undefined;
        // Embedded, a focus outside this component is the HOST's: the id of
        // a host control is none of the app's business, and an app that
        // echoes S_FOCUS back as SET_FOCUS would name the host's field
        if (ctx?.state?.embedded && !isInComponent(ctx, active)) {
          return undefined;
        }
        const fullId = ui5El.getId();
        let id = fullId;
        for (const slot of ViewSlots.slots) {
          const local = stripSlotPrefix(ctx, fullId, slot);
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
      } catch (e) {
        Lib.logError("getFocusInfo: focus capture failed", e);
        return undefined;
      }
    }

    // ------------------------------------------------------------------
    // The focus guard of an EMBEDDED component. The page is the host's, and
    // so is the keyboard focus on it: a starting app used to take it out of
    // the host field the user was typing in - sap.m.App's first rendering
    // (see App.controller) and the app's own SET_FOCUS alike. The framework
    // moves the focus in three places - SET_FOCUS (actions/ViewOps), a
    // CONTROL_BY_ID focus( ) (actions/ControlCall) and the obsolete
    // cc/Focus control - and each asks mayMoveFocus( ) right before it does.
    // Embedded, the answer is yes while the focus is IN this component, and
    // while it is nowhere (the body: a rebuild took the focused field away)
    // after the user's last focus or click went into it; a user in the
    // host's page keeps the focus, one working in the app gets every focus
    // action as on the app's own page. Not embedded, the answer is always
    // yes: the page is the app's.
    // ------------------------------------------------------------------

    // Is `node` part of this component: inside its own DOM (the root
    // control's), or inside something UI5 renders into its static area FOR
    // it - the popup and popover slots, the list of a Select, the calendar of
    // a DatePicker - which the control it belongs to answers (Context.of).
    // Never throws: a node nothing resolves is not the component's.
    function isInComponent(ctx, node) {
      if (!ctx || !node || node.nodeType !== 1) return false;
      try {
        const root = ctx.component?.getRootControl?.()?.getDomRef?.();
        if (root?.contains?.(node)) return true;
        const ui5El = closestUi5Element(node);
        return Boolean(ui5El) && Context.of(ui5El) === ctx;
      } catch (e) {
        Lib.logError("isInComponent: resolving the node failed", e);
        return false;
      }
    }

    function mayMoveFocus(ctx) {
      if (!ctx?.state?.embedded) return true;
      const active = document.activeElement;
      if (!active || active === document.body) {
        return ctx.focus.userInside;
      }
      return isInComponent(ctx, active);
    }

    // Record where the user's focus and clicks go, for the "nowhere" case
    // of mayMoveFocus: a focusin or a pointerdown inside the component
    // (keyboard and pointer alike) says the user works in it, one anywhere
    // else says they left it. Capture phase, so a host handler that stops
    // the event cannot hide it. Only embedded; Component.init installs it,
    // unwatchFocus (Component.exit) takes it off again.
    function watchFocus(ctx) {
      if (!ctx?.state?.embedded || ctx.focus.listener) return;
      const listener = (event) => {
        ctx.focus.userInside = isInComponent(ctx, event.target);
      };
      ctx.focus.listener = listener;
      document.addEventListener("focusin", listener, true);
      document.addEventListener("pointerdown", listener, true);
    }

    function unwatchFocus(ctx) {
      const listener = ctx?.focus?.listener;
      if (!listener) return;
      document.removeEventListener("focusin", listener, true);
      document.removeEventListener("pointerdown", listener, true);
      ctx.focus.listener = null;
    }

    // The per-element resolution cache of onScrollCapture (see there) is
    // `ctx.scroll` (core/Context.js) - per component, and observable by
    // the unit specs. The one way it is emptied: getScrollInfo releases it
    // once the node left the document, reset( ) on the component teardown.
    function clearScrollCache(ctx) {
      const cache = ctx.scroll;
      cache.target = undefined;
      cache.ui5El = undefined;
      cache.slotKey = undefined;
    }

    // Records which element the user actually scrolled, per view slot.
    // Bound to a single document-level capture-phase listener (installed
    // in Component.init): scroll events do not bubble, but they do fire
    // capture listeners on ancestors, so one listener observes every
    // scrollable container - no per-roundtrip walk over the control tree,
    // and no guessing which container "looks scrolled".
    function onScrollCapture(ctx, event) {
      const target = event.target;
      if (!target || target.nodeType !== 1) return;
      const _scrollCache = ctx.scroll;

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
          ? ViewSlots.containingSlotKey(ctx, ui5El)
          : undefined;
      }

      if (_scrollCache.slotKey) {
        ctx.state.lastScrolled[_scrollCache.slotKey] = {
          control: _scrollCache.ui5El,
          dom: target,
        };
      }
    }

    function getScrollInfo(ctx) {
      // Release the per-element resolution cache of onScrollCapture once
      // its DOM node left the document (view replaced/destroyed) - the
      // detached element and its control would otherwise stay referenced
      // until the user scrolls the next time.
      const _scrollCache = ctx.scroll;
      if (_scrollCache.target && !_scrollCache.target.isConnected) {
        clearScrollCache(ctx);
      }

      // Reads scrollLeft/scrollTop straight from the DOM element the user
      // last scrolled in each view slot (recorded by onScrollCapture).
      // X = scrollLeft, Y = scrollTop. Slots the user never scrolled are
      // absent from the result - restoring 0/0 would be a no-op anyway.
      const store = ctx.state.lastScrolled;
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

        const id = stripSlotPrefix(ctx, entry.control.getId(), slot);
        out[slot.key] = {
          ID: id,
          X: entry.dom.scrollLeft || 0,
          Y: entry.dom.scrollTop || 0,
        };
      }
      // Returning undefined lets JSON.stringify omit S_SCROLL entirely.
      return Object.keys(out).length ? out : undefined;
    }

    // Drop the per-element resolution cache on a component teardown
    // (Component.exit): getScrollInfo releases it on the next roundtrip,
    // and after an exit there is none - the detached node and its control
    // stayed referenced by this module until the next app's first scroll.
    function reset(ctx) {
      clearScrollCache(ctx);
    }

    // closestUi5Element and focusTextInput are pure resolution helpers,
    // exported for the unit specs (the cache is `ctx.scroll`).
    return {
      getFocusInfo,
      getScrollInfo,
      onScrollCapture,
      closestUi5Element,
      focusTextInput,
      isInComponent,
      mayMoveFocus,
      watchFocus,
      unwatchFocus,
      reset,
    };
  },
);
