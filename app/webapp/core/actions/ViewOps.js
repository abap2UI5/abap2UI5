sap.ui.define(["z2ui5/core/Lib", "z2ui5/core/ViewSlots"], (Lib, ViewSlots) => {
  "use strict";

  // ------------------------------------------------------------------
  // Actions against the running VIEWS and their models: focus, scrolling,
  // element binding, model size limits, the OData model switch and backend
  // timers. Every handler reads the state of the calling controller's
  // context (oController.ctx, core/Context.js).
  // ------------------------------------------------------------------

  // Animation duration (ms) mapped to a "smooth" scroll request; 0 means an
  // instant jump. Shared by every scroll path in evScrollTo.
  const SMOOTH_SCROLL_MS = 300;

  function evSetSizeLimit(oController, args) {
    // Two call shapes:
    //   ["SET_SIZE_LIMIT", "<limit>", "<viewKey>"]   -> set the limit
    //   ["SET_SIZE_LIMIT", "<viewKey>"]              -> reset the limit
    const hasLimit = args[2] !== undefined && args[2] !== "";
    const viewKey = hasLimit ? args[2] : args[1];
    const limit = hasLimit ? Number(args[1]) : NaN;

    const isValidLimit = Number.isFinite(limit) && limit > 0;
    const previous = oController.ctx.state.viewSizeLimits[viewKey];
    if (isValidLimit) {
      oController.ctx.state.viewSizeLimits[viewKey] = limit;
    } else {
      delete oController.ctx.state.viewSizeLimits[viewKey];
    }
    // The action is not one-shot - an app that sends it from its render
    // path re-sends it every roundtrip. When the stored limit did not
    // change, neither did the effective one (the max over the root
    // slots), and the forced refresh below would re-evaluate every
    // binding of the model for nothing.
    if (previous === oController.ctx.state.viewSizeLimits[viewKey]) return;

    // MAIN and the two nested views share one root model via propagation, so
    // resolve the model through MAIN for those slots and apply the effective
    // (largest) limit across them; popup/popover keep their own model/limit.
    const modelKey = Lib.isRootModelSlot(viewKey) ? "MAIN" : viewKey;
    // the TRACKED framework model, not blindly the default one: in switch
    // mode the default slot holds the ODATA model and the app's bound
    // tables live in the JSON model under http> - setting the limit on
    // the wrong one made SET_SIZE_LIMIT a silent no-op there
    const view = ViewSlots.getView(oController.ctx, modelKey);
    const model = view
      ? (ViewSlots.trackedModel(view) ?? view.getModel())
      : undefined;
    if (model) {
      const effective = Lib.effectiveSizeLimit(
        oController.ctx.state.viewSizeLimits,
        viewKey,
      );
      // 100 is the UI5 JSONModel default size limit.
      model.setSizeLimit(effective ?? 100);
      model.refresh(true);
    }
  }

  // Async because the client is loaded on first use (Lib.requireODataModel):
  // the promise is handed back through eF and awaited by the custom-action
  // runner, so an action queued behind this one in the same response still
  // finds the model in place.
  async function evSetODataModel(oController, args) {
    let oModel;
    try {
      const ODataModel = await Lib.requireODataModel();
      oModel = new ODataModel({
        serviceUrl: args[1],
        annotationURI: args[3] || "",
      });
      const oView = ViewSlots.getView(oController.ctx, "MAIN");
      if (oView) {
        const name = args[2] || undefined;
        // The client is created HERE, so the framework owes its destroy:
        // the app only names a service URL, it never hands us a model
        // object. Recorded in the one inventory of framework-created
        // OData clients (oController.ctx.state.odataClients), which is what the
        // next MAIN rebuild tears down - a NAMED client used to survive
        // the view it was set on, and the next re-issue then found
        // nothing to destroy and leaked a full client, $metadata request,
        // caches and queues included.
        const previous = oView.getModel(name);
        oView.setModel(oModel, name);
        oController.ctx.state.odataClients.add(oModel);
        // ...and the one this replaces goes now, for the same reason -
        // but only when the framework created it too.
        if (
          previous !== oModel &&
          oController.ctx.state.odataClients.has(previous)
        ) {
          oController.ctx.state.odataClients.delete(previous);
          previous.destroy();
        }
      } else {
        // No view to attach to - release the model instead of leaking it.
        oModel.destroy();
      }
    } catch (e) {
      Lib.logError(`SET_ODATA_MODEL: failed for '${args[1]}'`, e);
      // setModel (or the model construction) threw after the model opened
      // its metadata request - release it so it does not leak, and drop it
      // from the inventory again so the next rebuild does not double-free.
      oController.ctx.state.odataClients.delete(oModel);
      oModel?.destroy?.();
    }
  }

  // BIND_ELEMENT: element-bind a whole view slot (popup / popover / main) to
  // a row of a registered table, so the fragment's relative bindings ({Name},
  // {ProductPicUrl}, ...) resolve against that row - the abap2UI5 equivalent of
  // oControl.bindElement(oCtx.getPath()). args = [_, slot, index, path]; the path
  // comes from client->_bind( table ) (braces already stripped server-side and
  // again here defensively), the slot from the follow_up_action view param.
  function evBindElement(oController, args) {
    const slot = args[1] || "MAIN";
    const view = ViewSlots.getView(oController.ctx, slot);
    if (!view) {
      Lib.logError(`BIND_ELEMENT: no view for slot '${slot}'`);
      return;
    }
    const path = String(args[3] ?? "").replace(/[{}]/g, "");
    if (!path) {
      Lib.logError("BIND_ELEMENT: empty binding path");
      return;
    }
    view.bindElement(`${path}/${args[2]}`);
  }

  function evStartTimer(oController, args) {
    // Intentionally a single timer slot: args[0] is always the event
    // name "START_TIMER", so a new START_TIMER replaces the previous
    // one. At most one backend timer is pending at any time - this is
    // by design, not a bug.
    const timerKey = args[0];
    const callbackEvent = args[1];
    const delay = Number(args[2]) || 0;
    const timers = oController.ctx.state.timers;
    Lib.cancelTimer(timers[timerKey]);
    const fire = () => {
      delete timers[timerKey];
      // nothing cancels a pending timer on app teardown - an FLP close or
      // re-launch leaves it armed, so it must not fire the old app's event
      // into the new session
      if (!Lib.isControllerAlive(oController)) return;
      // A roundtrip in flight (a Back/Forward restore, a hash-listener
      // event, a popup's own event): the tick waits for it. It used to
      // dispatch right away as a background event, and Server.readHttp
      // treats every new request as superseding - it ABORTED the fetch in
      // flight, whose response was then dropped as stale: the user's
      // action was lost without any feedback. Waiting in the same single
      // slot keeps the poll chain alive (the reason the tick must not
      // simply be swallowed by the busy guard) without taking the request
      // down with it. Event-driven, not a retry timer: a 50 ms poll used to
      // wake the main thread twenty times a second for the whole roundtrip
      // (a 3 s backend call cost ~60 wakeups); afterRoundtrip fires once,
      // when the response has rendered, and the tick then fires on the
      // next macrotask like the Websocket queue drains (cc/Websocket).
      // The slot holds the cancel function meanwhile, which is why every
      // cancel goes through Lib.cancelTimer.
      if (oController.ctx.state.isBusy) {
        const cancel = Lib.afterRoundtrip(oController, () => {
          timers[timerKey] = setTimeout(fire, 0);
        });
        if (!(timerKey in timers)) timers[timerKey] = cancel;
        return;
      }
      // dispatch: between the check above and the dispatch nothing can
      // start a roundtrip, and a tick that lands during one waits on
      // afterRoundtrip instead of being dropped. Slot [2] of the event
      // array is the reserved placeholder View1.eB ignores (view1Events
      // spec) - it is kept for the wire shape, it switches nothing
      oController.eB([callbackEvent, false, true]);
    };
    timers[timerKey] = setTimeout(fire, delay);
  }

  // The three handlers below resolve their target with ViewSlots.resolveById
  // (not byId "MAIN"): it searches every open slot first, so controls in a
  // popup/popover/nested view are found, and falls back to the global
  // registry, so a fully-qualified id resolves too - ids that come from a
  // UI5 Message (getControlIds()) or any event carry the view prefix.
  //
  // An id that resolves to nothing is REPORTED, like every sibling handler
  // in this module reports its own miss (BIND_ELEMENT). The three
  // used to return silently, which is the one failure an app cannot see
  // from the outside: a focus that does not move and a view that does not
  // scroll look exactly like a control that ignored the call.
  function resolveTarget(oController, action, id) {
    const oElement = ViewSlots.resolveById(oController?.ctx, id);
    if (!oElement) Lib.logError(`${action}: no control '${id}'`);
    return oElement;
  }

  function evSetFocus(oController, args) {
    const oElement = resolveTarget(oController, "SET_FOCUS", args[1]);
    if (!oElement) return;

    const applyFocus = () => {
      try {
        const info = oElement.getFocusInfo();
        if (args[2] != null && args[2] !== "") {
          info.selectionStart = Number(args[2]);
        }
        if (args[3] != null && args[3] !== "") {
          info.selectionEnd = Number(args[3]);
        }
        oElement.applyFocusInfo(info);
      } catch (e) {
        Lib.logError(`SET_FOCUS: failed for '${args[1]}'`, e);
      }
    };

    // The control may still be missing from the DOM when SET_FOCUS runs
    // together with a fresh view build. Apply now if it is rendered,
    // otherwise once it is. Keyed: one pending focus per control, so a
    // SET_FOCUS in every response of a poll-driven app does not stack a
    // delegate per tick on a control that never re-renders (Lib.onNextRendering)
    Lib.whenRendered(
      oElement,
      oController,
      () => {
        // whenRendered's own owner guard is isDestroyed( ), which cannot
        // answer for a CONTROLLER (no ManagedObject - see Lib.isControllerAlive):
        // a focus deferred to the control's next rendering must not move it
        // once the app that asked for it is gone, the way the retry below
        // and the anchor wait in ControlCall already ask
        if (!Lib.isControllerAlive(oController)) return;
        applyFocus();
        const dom = oElement.getDomRef();
        if (dom && dom.contains(document.activeElement)) return;
        // The focus did not stick. A view_model_update in the same response
        // may have changed the control - e.g. re-enabled a locked input via
        // its `enabled` binding: the control already reports the new state,
        // but the DOM still carries the OLD rendering until UI5's async
        // re-render, and the browser silently ignores focus() on a disabled
        // element. Re-apply once after the pending re-render has replaced
        // the DOM.
        const prevActive = document.activeElement;
        // "Same place" by node OR by element id: when the re-render also
        // rebuilt the element that held the focus (the pressed button in the
        // same form), the focus sits on a NEW node of the SAME control
        // afterwards - that still counts as "the user did not move it".
        const samePlace = (el) =>
          el == null ||
          el === document.body ||
          el === prevActive ||
          Boolean(el.id && prevActive && el.id === prevActive.id);
        // one pending retry per control, like the outer wait (same reason)
        Lib.onNextRendering(
          oElement,
          () => {
            // Defer past the rendering task: when the re-render replaced the
            // focused element, UI5's FocusHandler restores its focus AFTER
            // all onAfterRendering delegates ran - focusing here would be
            // overridden right away.
            setTimeout(() => {
              if (!Lib.isControllerAlive(oController)) return;
              // Only when the focus was not actively moved elsewhere in
              // between - a re-render at some arbitrary later point must
              // never steal the user's focus.
              if (!samePlace(document.activeElement)) return;
              applyFocus();
            }, 0);
          },
          "focusRetry",
        );
      },
      "focus",
    );
  }

  function evScrollTo(oController, args) {
    // args[1] = control id
    // args[2] = scrollTop  (Y, vertical, px)
    // args[3] = scrollLeft (X, horizontal, px) - optional, default 0
    // args[4] = behavior - "auto" (default) | "smooth" | "instant"
    // Strategy: prefer the control's scroll delegate (sap.m.Page,
    // ScrollContainer etc. expose ScrollEnablement). The delegate knows
    // the real scroll container, which often is NOT the control's root
    // DOM element - so native Element.scrollTo on getDomRef() silently
    // does nothing on a Page. ScrollEnablement.scrollTo(x, y, time)
    // animates when time > 0, so "smooth" maps to a 300ms animation.
    // Native Element.scrollTo is only used as a fallback for controls
    // without a delegate.
    try {
      const oElement = resolveTarget(oController, "SCROLL_TO", args[1]);
      if (!oElement) return;
      const y = Number(args[2]) || 0;
      const x = Number(args[3]) || 0;
      const behavior = args[4] || "auto";
      const smooth = behavior === "smooth";

      let handled = false;
      try {
        const delegate = oElement.getScrollDelegate?.();
        if (delegate?.scrollTo) {
          // ScrollEnablement / iScroll delegate: scrollTo(x, y, time)
          delegate.scrollTo(x, y, smooth ? SMOOTH_SCROLL_MS : 0);
          handled = true;
        }
      } catch {
        // fall through
      }

      if (!handled) {
        const dom =
          document.getElementById(`${oElement.getId()}-inner`) ||
          oElement.getDomRef();
        if (dom?.scrollTo) {
          dom.scrollTo({ top: y, left: x, behavior });
        } else if (dom) {
          dom.scrollTop = y;
          dom.scrollLeft = x;
        } else if (oElement.scrollTo) {
          // sap.m.Page.scrollTo(y, time) - vertical only
          oElement.scrollTo(y, smooth ? SMOOTH_SCROLL_MS : 0);
        }
      }
    } catch (e) {
      Lib.logError(`SCROLL_TO: failed for '${args[1]}'`, e);
    }
  }

  function evScrollIntoView(oController, args) {
    // args[1] = control id
    // args[2] = behavior - "smooth" (default) | "auto" | "instant"
    // args[3] = block    - "start"  (default) | "center" | "end" | "nearest"
    // args[4] = inline   - "nearest" (default)| "start"  | "center" | "end"
    // Modern declarative scroll: bring a control into the viewport,
    // regardless of where the surrounding scroll container currently is.
    try {
      const oElement = resolveTarget(oController, "SCROLL_INTO_VIEW", args[1]);
      if (!oElement) return;
      const dom = oElement.getDomRef();
      if (!dom || !dom.scrollIntoView) return;
      dom.scrollIntoView({
        behavior: args[2] || "smooth",
        block: args[3] || "start",
        inline: args[4] || "nearest",
      });
    } catch (e) {
      Lib.logError(`SCROLL_INTO_VIEW: failed for '${args[1]}'`, e);
    }
  }

  // The events this module owns in the eF dispatch (see
  // core/FrontendAction.js, which merges the domain modules' handler maps).
  const handlers = {
    SET_SIZE_LIMIT: evSetSizeLimit,
    SET_ODATA_MODEL: evSetODataModel,
    BIND_ELEMENT: evBindElement,
    START_TIMER: evStartTimer,
    SET_FOCUS: evSetFocus,
    SCROLL_TO: evScrollTo,
    SCROLL_INTO_VIEW: evScrollIntoView,
  };

  return { handlers };
});
