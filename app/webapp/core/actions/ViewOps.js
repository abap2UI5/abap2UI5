sap.ui.define(
  [
    "sap/ui/model/odata/v2/ODataModel",
    "z2ui5/core/Lib",
    "z2ui5/core/ViewSlots",
    "z2ui5/core/AppState",
  ],
  (ODataModel, Lib, ViewSlots, AppState) => {
    "use strict";

    // how long a backend timer tick waits before asking again whether the
    // roundtrip it collided with has landed (evStartTimer)
    const TIMER_BUSY_RETRY_MS = 50;

    // ------------------------------------------------------------------
    // Actions against the running VIEWS and their models: focus, scrolling,
    // element binding, model size limits, the OData model switch, backend
    // timers and the app-registered z2ui5 custom functions.
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
      const previous = AppState.state.viewSizeLimits[viewKey];
      if (isValidLimit) {
        AppState.state.viewSizeLimits[viewKey] = limit;
      } else {
        delete AppState.state.viewSizeLimits[viewKey];
      }
      // The action is not one-shot - an app that sends it from its render
      // path re-sends it every roundtrip. When the stored limit did not
      // change, neither did the effective one (the max over the root
      // slots), and the forced refresh below would re-evaluate every
      // binding of the model for nothing.
      if (previous === AppState.state.viewSizeLimits[viewKey]) return;

      // MAIN and the two nested views share one root model via propagation, so
      // resolve the model through MAIN for those slots and apply the effective
      // (largest) limit across them; popup/popover keep their own model/limit.
      const modelKey = Lib.isRootModelSlot(viewKey) ? "MAIN" : viewKey;
      // the TRACKED framework model, not blindly the default one: in switch
      // mode the default slot holds the ODATA model and the app's bound
      // tables live in the JSON model under http> - setting the limit on
      // the wrong one made SET_SIZE_LIMIT a silent no-op there
      const view = ViewSlots.getView(modelKey);
      const model = view
        ? (ViewSlots.trackedModel(view) ?? view.getModel())
        : undefined;
      if (model) {
        const effective = Lib.effectiveSizeLimit(
          AppState.state.viewSizeLimits,
          viewKey,
        );
        // 100 is the UI5 JSONModel default size limit.
        model.setSizeLimit(effective ?? 100);
        model.refresh(true);
      }
    }

    function evSetODataModel(oController, args) {
      let oModel;
      try {
        oModel = new ODataModel({
          serviceUrl: args[1],
          annotationURI: args[3] || "",
        });
        const oView = ViewSlots.getView("MAIN");
        if (oView) {
          const name = args[2] || undefined;
          // The client is created HERE, so the framework owes its destroy:
          // the app only names a service URL, it never hands us a model
          // object. Recorded in the one inventory of framework-created
          // OData clients (AppState.state.odataClients), which is what the
          // next MAIN rebuild tears down - a NAMED client used to survive
          // the view it was set on, and the next re-issue then found
          // nothing to destroy and leaked a full client, $metadata request,
          // caches and queues included.
          const previous = oView.getModel(name);
          oView.setModel(oModel, name);
          AppState.state.odataClients.add(oModel);
          // ...and the one this replaces goes now, for the same reason -
          // but only when the framework created it too.
          if (
            previous !== oModel &&
            AppState.state.odataClients.has(previous)
          ) {
            AppState.state.odataClients.delete(previous);
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
        AppState.state.odataClients.delete(oModel);
        oModel?.destroy?.();
      }
    }

    // BIND_ELEMENT: element-bind a whole view slot (popup / popover / main) to
    // a row of a registered table, so the fragment's relative bindings ({Name},
    // {ProductPicUrl}, ...) resolve against that row - the abap2UI5 equivalent of
    // oControl.bindElement(oCtx.getPath()). args = [slot, index, path]; the path
    // comes from client->_bind( table ) (braces already stripped server-side and
    // again here defensively), the slot from the follow_up_action view param.
    function evBindElement(oController, args) {
      const slot = args[1] || "MAIN";
      const view = ViewSlots.getView(slot);
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

    function evImageEditorPopupClose(oController) {
      let image;
      try {
        const editor = ViewSlots.byId("POPUP", "imageEditor");
        if (editor) image = editor.getImagePngDataURL();
      } catch (e) {
        Lib.logError("IMAGE_EDITOR_POPUP_CLOSE: getImagePngDataURL failed", e);
      }
      ViewSlots.destroy("POPUP");
      oController.eB(["SAVE"], image);
    }

    function evStartTimer(oController, args) {
      // Intentionally a single timer slot: args[0] is always the event
      // name "START_TIMER", so a new START_TIMER replaces the previous
      // one. At most one backend timer is pending at any time - this is
      // by design, not a bug.
      const timerKey = args[0];
      const callbackEvent = args[1];
      const delay = Number(args[2]) || 0;
      const timers = AppState.state.timers;
      clearTimeout(timers[timerKey]);
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
        // action was lost without any feedback. Re-arming into the same
        // single slot keeps the poll chain alive (the reason the tick must
        // not simply be swallowed by the busy guard) without taking the
        // request down with it.
        if (AppState.state.isBusy) {
          timers[timerKey] = setTimeout(fire, TIMER_BUSY_RETRY_MS);
          return;
        }
        // dispatch as a background event (args[2] = ignore busy): between
        // the check above and the dispatch nothing can start a roundtrip,
        // and the flag keeps a tick from being dropped by a busy guard that
        // a stale state.isBusy would otherwise raise
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
    // in this module reports its own miss (BIND_ELEMENT, WIZARD_SET_NEXT_STEP,
    // Z2UI5). The three used to return silently, which is the one failure an
    // app cannot see from the outside: a focus that does not move and a view
    // that does not scroll look exactly like a control that ignored the call.
    function resolveTarget(action, id) {
      const oElement = ViewSlots.resolveById(id);
      if (!oElement) Lib.logError(`${action}: no control '${id}'`);
      return oElement;
    }

    function evSetFocus(oController, args) {
      const oElement = resolveTarget("SET_FOCUS", args[1]);
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
      // otherwise once it is.
      Lib.whenRendered(oElement, oController, () => {
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
        const delegate = {
          onAfterRendering: () => {
            oElement.removeEventDelegate(delegate);
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
        };
        oElement.addEventDelegate(delegate);
      });
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
        const oElement = resolveTarget("SCROLL_TO", args[1]);
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
        const oElement = resolveTarget("SCROLL_INTO_VIEW", args[1]);
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

    function evZ2ui5Custom(oController, args) {
      try {
        // Custom functions are registered by apps on the public z2ui5
        // global (js_loader popup), so resolve them via the facade.
        const fn = AppState.getGlobal(args[1]);
        if (typeof fn === "function") {
          fn(args.slice(2));
        } else {
          // Missing or not callable (e.g. the app never registered it via
          // the js_loader popup) - log it instead of failing silently or
          // with a generic TypeError.
          Lib.logError(`Z2UI5: 'z2ui5.${args[1]}' is not a function`);
        }
      } catch (e) {
        Lib.logError(`Z2UI5: '${args[1]}' failed`, e);
      }
    }

    function evWizardSetNextStep(oController, args) {
      try {
        // resolveById, not byId("MAIN", ...) - the rule this file states for
        // the three handlers above holds here too: a Wizard inside a popup,
        // popover or nested view is not in the MAIN slot, and the lookup
        // silently found nothing there
        const wiz = ViewSlots.resolveById(args[1]);
        const step = ViewSlots.resolveById(args[2]);
        const nextStep = ViewSlots.resolveById(args[3]);
        if (!wiz || !step) {
          Lib.logError(
            `WIZARD_SET_NEXT_STEP: '${args[1]}' / '${args[2]}' not found`,
          );
        }
        if (wiz && step) wiz.discardProgress(step);
        if (step && nextStep) step.setNextStep(nextStep);
      } catch (e) {
        Lib.logError(`WIZARD_SET_NEXT_STEP: failed for wizard '${args[1]}'`, e);
      }
    }

    // The events this module owns in the eF dispatch (see
    // core/FrontendAction.js, which merges the domain modules' handler maps).
    const handlers = {
      SET_SIZE_LIMIT: evSetSizeLimit,
      SET_ODATA_MODEL: evSetODataModel,
      BIND_ELEMENT: evBindElement,
      IMAGE_EDITOR_POPUP_CLOSE: evImageEditorPopupClose,
      START_TIMER: evStartTimer,
      SET_FOCUS: evSetFocus,
      SCROLL_TO: evScrollTo,
      SCROLL_INTO_VIEW: evScrollIntoView,
      Z2UI5: evZ2ui5Custom,
      WIZARD_SET_NEXT_STEP: evWizardSetNextStep,
    };

    return { handlers };
  },
);
