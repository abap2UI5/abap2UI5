sap.ui.define(
  [
    "sap/ui/core/mvc/Controller",
    "sap/ui/core/mvc/XMLView",
    "sap/ui/model/json/JSONModel",
    "sap/ui/core/BusyIndicator",
    "sap/m/MessageBox",
    "sap/m/MessageToast",
    "sap/ui/core/Fragment",
    "sap/m/BusyDialog",
    "sap/ui/VersionInfo",
    "z2ui5/core/Server",
    "sap/ui/model/odata/v2/ODataModel",
    "sap/ui/core/routing/HashChanger",
    "sap/ui/core/Element",
    "z2ui5/core/Lib",
    "z2ui5/core/FrontendAction",
  ],
  (
    Controller,
    XMLView,
    JSONModel,
    BusyIndicator,
    MessageBox,
    MessageToast,
    Fragment,
    BusyDialog,
    VersionInfo,
    Server,
    ODataModel,
    HashChanger,
    Element,
    Lib,
    FrontendAction,
  ) => {
    "use strict";

    // ------------------------------------------------------------------
    // Small utility helpers (module-private)
    // ------------------------------------------------------------------

    // Parse a value as integer milliseconds, falling back to `def` when the
    // input is empty / undefined.
    function parseMs(val, def) {
      return val ? +val : def;
    }

    // Helpers reused across calls; kept as module-level singletons.
    const _hashChanger = HashChanger.getInstance();

    // Single reusable BusyDialog flashed when the user clicks while a
    // roundtrip is already in flight (created lazily, kept for reuse).
    let _busyDialog = null;

    function applyStoredSizeLimit(viewKey, oModel) {
      if (!oModel || !z2ui5.viewSizeLimits) return;
      const limit = z2ui5.viewSizeLimits[viewKey];
      if (limit !== undefined) oModel.setSizeLimit(limit);
    }

    return Controller.extend("z2ui5.controller.View1", {
      // ------------------------------------------------------------------
      // Model change tracking - remembers which /XX/ paths the user edited
      // so the next roundtrip only ships the delta.
      // ------------------------------------------------------------------
      _trackChanges(oModel) {
        oModel.attachPropertyChange((e) => {
          const params = e.getParameters();
          const raw = params.path;
          const ctx = params.context;
          if (!raw) return;
          // Resolve relative paths against the binding context.
          let p;
          if (ctx && !raw.startsWith("/")) {
            p = `${ctx.getPath()}/${raw}`;
          } else {
            p = raw;
          }
          if (p.startsWith("/XX/")) {
            if (!z2ui5.xxChangedPaths) z2ui5.xxChangedPaths = new Set();
            z2ui5.xxChangedPaths.add(p);
          }
        });
        return oModel;
      },

      onInit() {
        z2ui5.oRouter.attachRouteMatched(() => {
          Server.roundtrip();
        });
      },

      onAfterRendering() {
        if (z2ui5.oResponse && !z2ui5.oResponse._processed) {
          this._processAfterRendering();
        }
      },

      // Runs once after each roundtrip's view has been rendered, in two
      // named phases: display pending fragments/views, then update the
      // browser history/hash.
      async _processAfterRendering() {
        try {
          const oResponse = z2ui5.oResponse;
          if (oResponse._processed) return;
          oResponse._processed = true;

          const PARAMS = oResponse.PARAMS;
          if (!PARAMS) return;

          await this._displayPendingViews(PARAMS);
          this._updateBrowserHistory(PARAMS, oResponse.ID);
          if (PARAMS.SET_NAV_BACK) history.back();

          Lib.runCallbacks(z2ui5.onAfterRendering);
        } catch (e) {
          Lib.logError("_processAfterRendering: unexpected error", e);
          Server.responseError(e, "Unexpected Error Occurred - App Terminated");
        } finally {
          BusyIndicator.hide();
          z2ui5.isBusy = false;
          // Now that the view is rendered (and any busy indicator is gone),
          // run the follow-up JS snippets the backend asked for. Doing it here
          // - rather than as an early microtask - guarantees render-dependent
          // actions like SET_FOCUS find their target control in the DOM.
          this._runPendingCustomJs();
        }
      },

      // Phase 1: open/destroy the popup, nested views and popover the
      // response asked for.
      async _displayPendingViews(PARAMS) {
        const S_POPUP = PARAMS.S_POPUP;
        const S_VIEW_NEST = PARAMS.S_VIEW_NEST;
        const S_VIEW_NEST2 = PARAMS.S_VIEW_NEST2;
        const S_POPOVER = PARAMS.S_POPOVER;

        if (S_POPUP?.CHECK_DESTROY) this.destroyPopup();
        if (S_POPOVER?.CHECK_DESTROY) this.destroyPopover();

        if (S_POPUP?.XML) {
          this.destroyPopup();
          await this.displayFragment(S_POPUP.XML, "oViewPopup");
        }

        if (!z2ui5.checkNestAfter && S_VIEW_NEST?.XML) {
          this.destroyNestView();
          await this.displayNestedView(
            S_VIEW_NEST.XML,
            "oViewNest",
            "S_VIEW_NEST",
            z2ui5.oControllerNest,
          );
          z2ui5.checkNestAfter = true;
        }

        if (!z2ui5.checkNestAfter2 && S_VIEW_NEST2?.XML) {
          this.destroyNestView2();
          await this.displayNestedView(
            S_VIEW_NEST2.XML,
            "oViewNest2",
            "S_VIEW_NEST2",
            z2ui5.oControllerNest2,
          );
          z2ui5.checkNestAfter2 = true;
        }

        if (S_POPOVER?.XML) {
          this.destroyPopover();
          await this.displayPopover(
            S_POPOVER.XML,
            "oViewPopover",
            S_POPOVER.OPEN_BY_ID,
          );
        }
      },

      // Phase 2: push the backend-requested URL and update the app-state
      // hash.
      _updateBrowserHistory(PARAMS, ID) {
        // Currently disabled: storing the rendered view + model in
        // history.state so a popstate could restore the view without a
        // backend hit. Cloning the full view XML and model data on every
        // roundtrip is expensive for large views and the restore is not
        // needed right now. Re-enable together with the popstate listener
        // in Component.js (_installPopstateListener).
        // const oView = z2ui5.oView;
        // let oState = {};
        // if (oView) {
        //   const model = oView.getModel();
        //   oState = {
        //     view: oView.mProperties.viewContent,
        //     model: model ? model.getData() : undefined,
        //     response: z2ui5.oResponse,
        //   };
        // }

        try {
          if (PARAMS.SET_PUSH_STATE) {
            const hash = _hashChanger.getHash();
            const newUrl = `${window.location.pathname}${window.location.search}#${hash}${PARAMS.SET_PUSH_STATE}`;
            history.pushState(null, "", newUrl);
          }
          // Disabled together with the state storing above - without a
          // state object this call was a pure no-op:
          // else {
          //   history.replaceState(oState, "", window.location.href);
          // }
          const newHash = PARAMS.SET_APP_STATE_ACTIVE
            ? `z2ui5-xapp-state=${ID || ""}`
            : "";
          _hashChanger.replaceHash(newHash);
        } catch (e) {
          Lib.logError("_updateBrowserHistory: history update failed", e);
        }
      },

      // Execute the follow-up JS snippets stashed by Server.responseSuccess.
      // Runs once per roundtrip, after the view has rendered.
      _runPendingCustomJs() {
        const customJs = z2ui5.pendingCustomJs;
        z2ui5.pendingCustomJs = null;
        if (!customJs) return;
        if (Lib.isDestroyed(this)) return;
        for (const item of customJs) {
          Server._runCustomJs(item, this);
        }
      },

      _createViewModel() {
        const data = z2ui5.oResponse?.OVIEWMODEL;
        return this._trackChanges(new JSONModel(data));
      },

      // ------------------------------------------------------------------
      // Display: popups, popovers, nested views, main view
      // ------------------------------------------------------------------

      async displayFragment(xml, viewProp) {
        const oModel = this._createViewModel();
        applyStoredSizeLimit("POPUP", oModel);
        const oFragment = await Fragment.load({
          definition: xml,
          controller: z2ui5.oControllerPopup,
          id: "popupId",
        });
        // The app might have been torn down while the fragment loaded.
        if (!Lib.isAlive(z2ui5.oApp)) {
          oFragment.destroy();
          return;
        }
        oFragment.setModel(oModel);
        oFragment.Fragment = Fragment;
        z2ui5[viewProp] = oFragment;
        oFragment.open();
      },

      async displayPopover(xml, viewProp, openById) {
        try {
          const oModel = this._createViewModel();
          applyStoredSizeLimit("POPOVER", oModel);
          const oFragment = await Fragment.load({
            definition: xml,
            controller: z2ui5.oControllerPopover,
            id: "popoverId",
          });
          if (!Lib.isAlive(z2ui5.oApp)) {
            oFragment.destroy();
            return;
          }
          oFragment.setModel(oModel);
          oFragment.Fragment = Fragment;

          // Find the control to attach the popover to. We search the main
          // view first, then any open popup / nested views, then the global
          // UI5 control registry as a last resort.
          let oControl = z2ui5.oView?.byId(openById);
          if (!oControl && z2ui5.oViewPopup?.Fragment) {
            oControl = z2ui5.oViewPopup.Fragment.byId("popupId", openById);
          }
          if (!oControl && z2ui5.oViewNest) {
            oControl = z2ui5.oViewNest.byId(openById);
          }
          if (!oControl && z2ui5.oViewNest2) {
            oControl = z2ui5.oViewNest2.byId(openById);
          }
          if (!oControl) {
            if (Element.getElementById) {
              oControl = Element.getElementById(openById);
            } else {
              /* ui5lint-disable no-globals, no-deprecated-api --
                 deliberate fallback for UI5 releases that do not provide
                 Element.getElementById yet (added in 1.119); the modern
                 API is used in the branch above. */
              if (sap.ui.getCore) {
                const core = sap.ui.getCore();
                if (core?.byId) oControl = core.byId(openById);
              }
              /* ui5lint-enable no-globals, no-deprecated-api */
            }
          }

          if (!oControl) {
            Lib.logError(
              `displayPopover: openBy control '${openById}' not found`,
            );
            oFragment.destroy();
            return;
          }
          z2ui5[viewProp] = oFragment;
          oFragment.openBy(oControl);
        } catch (e) {
          Lib.logError("displayPopover: failed", e);
        }
      },

      async displayNestedView(xml, viewProp, viewNestId, controller) {
        const oModel = this._createViewModel();
        applyStoredSizeLimit(Lib.slotKeyByParam(viewNestId), oModel);
        const oView = await XMLView.create({
          definition: xml,
          controller: controller,
          preprocessors: { xml: { models: { template: oModel } } },
        });

        if (!Lib.isAlive(z2ui5.oApp)) {
          oView.destroy();
          return;
        }
        oView.setModel(oModel);

        const nestParams =
          z2ui5.oResponse?.PARAMS && z2ui5.oResponse.PARAMS[viewNestId];
        if (!nestParams) {
          Lib.logError(`displayNestedView: missing PARAMS.${viewNestId}`);
          oView.destroy();
          return;
        }
        const { ID, METHOD_DESTROY, METHOD_INSERT } = nestParams;

        const oParent = z2ui5.oView?.byId(ID);
        if (!oParent) {
          Lib.logError(
            `displayNestedView: parent control '${ID}' not found, nested view discarded`,
          );
          oView.destroy();
          return;
        }

        try {
          oParent[METHOD_DESTROY]();
        } catch (e) {
          Lib.logError("displayNestedView: parent destroy method failed", e);
        }
        try {
          oParent[METHOD_INSERT](oView);
        } catch (e) {
          Lib.logError("displayNestedView: parent insert method failed", e);
          oView.destroy();
          return;
        }
        z2ui5[viewProp] = oView;
      },

      // Shared destroy logic: close (if dialog/popover) and destroy the view,
      // then clear the slot on z2ui5.
      _destroyView(prop, tryClose) {
        const view = z2ui5[prop];
        if (!view) return;
        if (tryClose) {
          try {
            if (view.close) view.close();
          } catch (e) {
            Lib.logError(`_destroyView: view.close() failed for ${prop}`, e);
          }
        }
        try {
          view.destroy();
        } catch (e) {
          Lib.logError(`_destroyView: view.destroy() failed for ${prop}`, e);
        }
        z2ui5[prop] = null;
      },

      destroyPopup() {
        this._destroyView("oViewPopup", true);
      },
      destroyPopover() {
        this._destroyView("oViewPopover", true);
      },
      destroyNestView() {
        this._destroyView("oViewNest");
      },
      destroyNestView2() {
        this._destroyView("oViewNest2");
      },
      destroyView() {
        this._destroyView("oView");
      },

      // ------------------------------------------------------------------
      // eF = "event frontend": handles frontend-only events triggered by
      // the backend response, without a roundtrip. The name is part of the
      // protocol - backend-generated view XML binds events to eB/eF - and
      // must not be renamed. The individual handlers live in
      // core/FrontendAction.js.
      // ------------------------------------------------------------------
      eF(...args) {
        FrontendAction.execute(this, args);
      },

      // ------------------------------------------------------------------
      // eB = "event backend": triggers a backend roundtrip with arguments.
      // The name is part of the protocol - backend-generated view XML binds
      // events to eB/eF - and must not be renamed.
      //
      // args[0] is the event array built by the backend:
      //   [0] event name
      //   [2] "ignore busy" flag - background events (e.g. timers) skip the
      //       busy guard below
      //   [3] "use main view model" flag - events fired from a popup or
      //       popover controller that still target the main app's model
      // ------------------------------------------------------------------
      eB(...args) {
        const [, , ignoreBusy, useMainModel] = args[0];

        if (!navigator.onLine) {
          MessageBox.alert(
            "No internet connection! Please reconnect to the server and try again.",
          );
          return;
        }

        // If a roundtrip is already in flight, briefly show a BusyDialog so
        // the user gets visual feedback instead of a silent click.
        if (z2ui5.isBusy && !ignoreBusy) {
          if (!_busyDialog) _busyDialog = new BusyDialog();
          _busyDialog.open();
          queueMicrotask(() => _busyDialog.close());
          return;
        }

        // A new roundtrip overrides any pending timer - timers that fired
        // already removed themselves before calling eB, so this only cancels
        // timers that are still waiting.
        if (z2ui5.timers) {
          for (const key in z2ui5.timers) {
            clearTimeout(z2ui5.timers[key]);
            delete z2ui5.timers[key];
          }
        }

        z2ui5.isBusy = true;
        BusyIndicator.show();
        z2ui5.oBody = { VIEWNAME: "MAIN" };

        // Decide which view's model holds the data we need to send back. The
        // mapping is: main app controller -> main view, popup controller ->
        // popup view, etc.
        const oModel = this._pickModelForRoundtrip(useMainModel);

        Lib.runCallbacks(z2ui5.onBeforeRoundtrip);

        // If the user edited /XX/ paths, send only the delta to keep the
        // payload small.
        if (oModel && z2ui5.xxChangedPaths?.size > 0) {
          const data = oModel.getData();
          const xx = data?.XX;
          if (xx) {
            z2ui5.oBody.XX = Lib.buildDeltaFromPaths(z2ui5.xxChangedPaths, xx);
          }
        }

        z2ui5.oBody.ID = z2ui5.oResponse?.ID;
        // Object arguments are stringified for transport; the event name in
        // args[0] is left as-is.
        z2ui5.oBody.ARGUMENTS = args.map((item, i) => {
          if (i > 0 && typeof item === "object") return JSON.stringify(item);
          return item;
        });

        Server.roundtrip();
        Lib.runCallbacks(z2ui5.onAfterRoundtrip);
      },

      _pickModelForRoundtrip(useMainModel) {
        // useMainModel forces use of the main view's model even when called
        // from a popup/popover controller.
        if (useMainModel || z2ui5.oController === this) {
          const sView = z2ui5.oResponse?.PARAMS
            ? z2ui5.oResponse.PARAMS.S_VIEW
            : null;
          if (sView?.SWITCH_DEFAULT_MODEL_PATH) {
            return z2ui5.oView?.getModel("http");
          }
          return z2ui5.oView?.getModel();
        }
        if (z2ui5.oControllerPopup === this) {
          return z2ui5.oViewPopup?.getModel();
        }
        if (z2ui5.oControllerPopover === this) {
          return z2ui5.oViewPopover?.getModel();
        }
        if (z2ui5.oControllerNest === this) {
          z2ui5.oBody.VIEWNAME = "NEST";
          return z2ui5.oViewNest?.getModel();
        }
        if (z2ui5.oControllerNest2 === this) {
          z2ui5.oBody.VIEWNAME = "NEST2";
          return z2ui5.oViewNest2?.getModel();
        }
        return undefined;
      },

      // Re-bind a model to one of the views when the response signals an
      // update is required for that particular slot.
      updateModelIfRequired(paramKey, oView) {
        const params = z2ui5.oResponse?.PARAMS;
        const slot = params?.[paramKey];
        if (!slot || !slot.CHECK_UPDATE_MODEL) return;

        const oModel = this._createViewModel();
        applyStoredSizeLimit(Lib.slotKeyByParam(paramKey), oModel);
        if (oView) oView.setModel(oModel);
      },

      async checkSDKcompatibility(err) {
        let gav;
        try {
          const info = await VersionInfo.load();
          gav = info.gav;
        } catch (e) {
          Lib.logError("checkSDKcompatibility: VersionInfo.load failed", e);
          return;
        }
        if (!gav || !gav.includes("com.sap.ui5")) {
          // openui5 doesn't ship some sap.com modules - tell the user which
          // module is missing so they know to switch to SAPUI5.
          const missingModule = err?._modules;
          Server.responseError(
            `openui5 SDK is loaded, module: ${missingModule} is not available in openui5`,
          );
          return;
        }
        Server.responseError(err);
      },

      // Display a toast or message box. Triggered for S_MSG_TOAST and
      // S_MSG_BOX entries in the server response.
      showMessage(msgType, params) {
        if (!params) return;
        const msg = params[msgType];
        if (!msg || msg.TEXT === undefined) return;

        if (msgType === "S_MSG_TOAST") {
          MessageToast.show(msg.TEXT, {
            duration: parseMs(msg.DURATION, 3000),
            width: msg.WIDTH || "15em",
            onClose: msg.ONCLOSE ? () => this.eB([msg.ONCLOSE]) : null,
            autoClose: !!msg.AUTOCLOSE,
            animationTimingFunction: msg.ANIMATIONTIMINGFUNCTION || "ease",
            animationDuration: parseMs(msg.ANIMATIONDURATION, 1000),
            closeonBrowserNavigation: !!msg.CLOSEONBROWSERNAVIGATION,
          });
          if (msg.CLASS) {
            const classes = msg.CLASS.trim().split(/\s+/).filter(Boolean);
            // Pick the newest toast (several can be open at once). The
            // element may not be in the DOM yet right after show(), so
            // retry once on the next animation frame.
            const applyClass = () => {
              const toasts = document.querySelectorAll(".sapMMessageToast");
              const toastEl = toasts[toasts.length - 1];
              if (toastEl) toastEl.classList.add(...classes);
              return !!toastEl;
            };
            if (!applyClass()) requestAnimationFrame(applyClass);
          }
          return;
        }

        if (msgType === "S_MSG_BOX") {
          const oParams = {
            styleClass: msg.STYLECLASS || "",
            title: msg.TITLE || "",
            onClose: msg.ONCLOSE
              ? (sAction) => this.eB([msg.ONCLOSE, sAction])
              : null,
            actions: msg.ACTIONS || "OK",
            emphasizedAction: msg.EMPHASIZEDACTION || "OK",
            initialFocus: msg.INITIALFOCUS || null,
            textDirection: msg.TEXTDIRECTION || "Inherit",
            details: msg.DETAILS ? Lib.sanitizeMessageDetails(msg.DETAILS) : "",
            closeOnNavigation: !!msg.CLOSEONNAVIGATION,
          };
          if (msg.ICON && msg.ICON !== "NONE") oParams.icon = msg.ICON;
          const showFn = MessageBox[msg.TYPE];
          if (showFn) showFn(msg.TEXT, oParams);
        }
      },

      // Replace the main app view with the XML coming from the backend.
      async displayView(xml, viewModel) {
        const oViewModel = this._trackChanges(new JSONModel(viewModel));

        const sView = z2ui5.oResponse?.PARAMS
          ? z2ui5.oResponse.PARAMS.S_VIEW
          : null;
        const switchPath = sView?.SWITCH_DEFAULT_MODEL_PATH;

        // When the app wants OData as the default model, build it here and
        // keep the JSON model as the named "http" model.
        let oModel;
        if (switchPath) {
          oModel = new ODataModel({
            serviceUrl: switchPath,
            annotationURI: sView.SWITCHDEFAULTMODELANNOURI || "",
          });
        } else {
          oModel = oViewModel;
        }
        applyStoredSizeLimit("MAIN", oModel);

        z2ui5.oView = await XMLView.create({
          definition: xml,
          models: oModel,
          controller: z2ui5.oController,
          id: "mainView",
          preprocessors: { xml: { models: { template: oViewModel } } },
        });

        // Guard against the app being destroyed during the await above.
        if (!Lib.isAlive(z2ui5.oApp)) {
          z2ui5.oView.destroy();
          if (switchPath) oModel.destroy();
          z2ui5.oView = null;
          return;
        }

        z2ui5.oView.setModel(z2ui5.oDeviceModel, "device");
        if (switchPath) z2ui5.oView.setModel(oViewModel, "http");
        z2ui5.oApp.removeAllPages();
        z2ui5.oApp.insertPage(z2ui5.oView);
      },
    });
  },
);
