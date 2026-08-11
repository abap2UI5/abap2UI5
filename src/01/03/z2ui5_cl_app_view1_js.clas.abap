* =====================================================================
* GENERATED FILE - DO NOT EDIT (AGENTS.md rule 2)
* Embedded frontend resource, generated from app/webapp/ by
* .github/app2abap/trans2abap.js. Change the source under app/webapp/
* and run 'npm run app2abap' to regenerate; the check_app2abap CI gate
* fails any manual edit here.
* =====================================================================
CLASS z2ui5_cl_app_view1_js DEFINITION
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


CLASS z2ui5_cl_app_view1_js IMPLEMENTATION.

  METHOD get.

    result = `// The central view controller. One instance serves each of the five view` && |\n| &&
             `// slots (main view, two nested views, popup, popover - see` && |\n| &&
             `// core/ViewSlots.js). It builds the request for backend events (eB),` && |\n| &&
             `// dispatches frontend-only events (eF), renders the views and fragments a` && |\n| &&
             `// response asks for, and runs the post-render follow-ups.` && |\n| &&
             `sap.ui.define(` && |\n| &&
             `  [` && |\n| &&
             `    "sap/ui/core/mvc/Controller",` && |\n| &&
             `    "sap/ui/core/mvc/XMLView",` && |\n| &&
             `    "sap/ui/model/json/JSONModel",` && |\n| &&
             `    "sap/ui/core/BusyIndicator",` && |\n| &&
             `    "sap/m/MessageBox",` && |\n| &&
             `    "sap/ui/core/Fragment",` && |\n| &&
             `    "z2ui5/core/Server",` && |\n| &&
             `    "sap/ui/model/odata/v2/ODataModel",` && |\n| &&
             `    "z2ui5/core/Lib",` && |\n| &&
             `    "z2ui5/core/FrontendAction",` && |\n| &&
             `    "z2ui5/core/ViewSlots",` && |\n| &&
             `    "z2ui5/core/AppState",` && |\n| &&
             `  ],` && |\n| &&
             `  (` && |\n| &&
             `    Controller,` && |\n| &&
             `    XMLView,` && |\n| &&
             `    JSONModel,` && |\n| &&
             `    BusyIndicator,` && |\n| &&
             `    MessageBox,` && |\n| &&
             `    Fragment,` && |\n| &&
             `    Server,` && |\n| &&
             `    ODataModel,` && |\n| &&
             `    Lib,` && |\n| &&
             `    FrontendAction,` && |\n| &&
             `    ViewSlots,` && |\n| &&
             `    AppState,` && |\n| &&
             `  ) => {` && |\n| &&
             `    "use strict";` && |\n| &&
             `` && |\n| &&
             `    function applyStoredSizeLimit(viewKey, oModel) {` && |\n| &&
             `      if (!oModel) return;` && |\n| &&
             `      // For the root slots (MAIN/NEST/NEST2) this is the max limit across them,` && |\n| &&
             `      // since they share this one model; popup/popover get their own limit.` && |\n| &&
             `      const limit = Lib.effectiveSizeLimit(` && |\n| &&
             `        AppState.state.viewSizeLimits,` && |\n| &&
             `        viewKey,` && |\n| &&
             `      );` && |\n| &&
             `      if (limit !== undefined) oModel.setSizeLimit(limit);` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    return Controller.extend("z2ui5.controller.View1", {` && |\n| &&
             `      // ------------------------------------------------------------------` && |\n| &&
             `      // Model change tracking - remembers which model paths the user edited` && |\n| &&
             `      // so the next roundtrip only ships the delta.` && |\n| &&
             `      // ------------------------------------------------------------------` && |\n| &&
             `      _trackChanges(oModel) {` && |\n| &&
             `        // Mark the model as framework-owned: updateModelIfRequired may only` && |\n| &&
             `        // reuse models that carry this change tracker.` && |\n| &&
             `        oModel._z2ui5Tracked = true;` && |\n| &&
             `        // Edited paths are tracked PER MODEL, not in one shared set: the main` && |\n| &&
             `        // view and a popup/popover each have their own JSON model, and a` && |\n| &&
             `        // roundtrip ships only the picked model's own edits. A single shared` && |\n| &&
             `        // set would build the delta of one model against another's data (a` && |\n| &&
             `        // path missing there serializes as ``undefined`` and clears the field` && |\n| &&
             `        // on the backend) and would drop the other model's still-unsent edits.` && |\n| &&
             `        oModel._z2ui5ChangedPaths = new Set();` && |\n| &&
             `        oModel.attachPropertyChange((e) => {` && |\n| &&
             `          const params = e.getParameters();` && |\n| &&
             `          const raw = params.path;` && |\n| &&
             `          const ctx = params.context;` && |\n| &&
             `          if (!raw) return;` && |\n| &&
             `          // Resolve relative paths against the binding context.` && |\n| &&
             `          const changedPath =` && |\n| &&
             `            ctx && !raw.startsWith("/") ? ``${ctx.getPath()}/${raw}`` : raw;` && |\n| &&
             `          if (changedPath.startsWith("/")) {` && |\n| &&
             `            oModel._z2ui5ChangedPaths.add(changedPath);` && |\n| &&
             `          }` && |\n| &&
             `        });` && |\n| &&
             `        return oModel;` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      onAfterRendering() {` && |\n| &&
             `        if (AppState.state.oResponse && !AppState.state.oResponse._processed) {` && |\n| &&
             `          this._processAfterRendering();` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      // Runs once after each roundtrip's view has been rendered, in two` && |\n| &&
             `      // named phases: display pending fragments/views, then update the` && |\n| &&
             `      // browser history/hash.` && |\n| &&
             `      async _processAfterRendering() {` && |\n| &&
             `        // Hoisted out of the try block: the finally below must run the` && |\n| &&
             `        // follow-up JS of exactly THIS response. Re-reading the shared` && |\n| &&
             `        // AppState.state.oResponse there would - after a parallel request` && |\n| &&
             `        // replaced it during the awaits - consume (and clear) the newer` && |\n| &&
             `        // response's snippets before its own render.` && |\n| &&
             `        let oResponse;` && |\n| &&
             `        try {` && |\n| &&
             `          oResponse = AppState.state.oResponse;` && |\n| &&
             `          if (oResponse._processed) return;` && |\n| &&
             `          oResponse._processed = true;` && |\n| &&
             `` && |\n| &&
             `          const PARAMS = oResponse.PARAMS;` && |\n| &&
             `          if (!PARAMS) return;` && |\n| &&
             `` && |\n| &&
             `          // Stamp of the request this response belongs to: every await in` && |\n| &&
             `          // the display phase re-checks it, so a response superseded by a` && |\n| &&
             `          // parallel request (check_allow_multi_req, Back/Forward restore)` && |\n| &&
             `          // never attaches popups/nested views the backend no longer knows.` && |\n| &&
             `          const seq = Server._requestSeq;` && |\n| &&
             `          await this._runSystemActions(oResponse, seq);` && |\n| &&
             `          // The app may have been torn down (reset / FLP re-launch) while the` && |\n| &&
             `          // pending views loaded; don't mutate history or fire onAfterRendering` && |\n| &&
             `          // hooks against a dead app (the custom-JS phase below guards the same` && |\n| &&
             `          // way via isDestroyed).` && |\n| &&
             `          if (Lib.isDestroyed(this)) return;` && |\n| &&
             `          Lib.runCallbacks(AppState.state.onAfterRendering);` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          Lib.logError("_processAfterRendering: unexpected error", e);` && |\n| &&
             `          Server.responseError(e, "Unexpected Error Occurred - App Terminated");` && |\n| &&
             `        } finally {` && |\n| &&
             `          BusyIndicator.hide();` && |\n| &&
             `          AppState.state.isBusy = false;` && |\n| &&
             `          // Now that the view is rendered (and any busy indicator is gone),` && |\n| &&
             `          // run the follow-up JS snippets the backend asked for. Doing it here` && |\n| &&
             `          // - rather than as an early microtask - guarantees render-dependent` && |\n| &&
             `          // actions like SET_FOCUS find their target control in the DOM.` && |\n| &&
             `          this._runPendingCustomJs(oResponse);` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      // Phase 1: run the SYSTEM actions - the framework's own view-lifecycle` && |\n| &&
             `      // calls (destroy a slot, display one, push the model into it), in the` && |\n| &&
             `      // order the backend queued them. They run BEFORE anything an app` && |\n| &&
             `      // queued, and one at a time: a display is async, and the next action` && |\n| &&
             `      // may well be about the slot it is still building.` && |\n| &&
             `      async _runSystemActions(oResponse, seq) {` && |\n| &&
             `        const systemJs = oResponse?.PARAMS?.S_ACTION?.T_SYSTEM;` && |\n| &&
             `        if (!systemJs) return;` && |\n| &&
             `        // the slot handlers take the request stamp from here rather than` && |\n| &&
             `        // through the generic action signature, which carries only the` && |\n| &&
             `        // payload the backend sent` && |\n| &&
             `        this._systemSeq = seq;` && |\n| &&
             `        try {` && |\n| &&
             `          for (const item of systemJs) {` && |\n| &&
             `            if (Lib.isDestroyed(this)) return;` && |\n| &&
             `            await Server._runSystemJs(item, this);` && |\n| &&
             `          }` && |\n| &&
             `        } finally {` && |\n| &&
             `          this._systemSeq = undefined;` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      // The VIEW_SLOTS target of a system action. destroy is ViewSlots' own` && |\n| &&
             `      // method; display and updateModel live here, because loading a fragment` && |\n| &&
             `      // and owning the model is the controller's job.` && |\n| &&
             `      slotAction(method, slotKey, xml, mOptions) {` && |\n| &&
             `        const seq = this._systemSeq;` && |\n| &&
             `        if (method === "destroy") {` && |\n| &&
             `          ViewSlots.destroy(slotKey);` && |\n| &&
             `          return undefined;` && |\n| &&
             `        }` && |\n| &&
             `        if (method === "updateModel") {` && |\n| &&
             `          // no slot is named - push into every OPEN slot that carries a` && |\n| &&
             `          // model of its own` && |\n| &&
             `          for (const slot of ViewSlots.slots) {` && |\n| &&
             `            if (slot.ownsModel) this.updateModelIfRequired(slot.key);` && |\n| &&
             `          }` && |\n| &&
             `          return undefined;` && |\n| &&
             `        }` && |\n| &&
             `        // display. The teardown of whatever the slot held is its own action` && |\n| &&
             `        // and has already run, so there is nothing to decide here either -` && |\n| &&
             `        // only which loader the slot uses.` && |\n| &&
             `        if (slotKey === "MAIN") return this._displayMainView(xml, mOptions);` && |\n| &&
             `        if (slotKey === "POPUP") return this.displayFragment(xml, seq);` && |\n| &&
             `        if (slotKey === "POPOVER") {` && |\n| &&
             `          return this.displayPopover(xml, mOptions.openById, seq);` && |\n| &&
             `        }` && |\n| &&
             `        return this.displayNestedView(xml, slotKey, mOptions, seq);` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      // The MAIN rebuild is the one display that cannot simply run: it is` && |\n| &&
             `      // serialized through Server._viewBuild because XMLView.create claims` && |\n| &&
             `      // the fixed "mainView" id synchronously, so two overlapping builds` && |\n| &&
             `      // (a slow library load plus a parallel/multi-req response) would throw` && |\n| &&
             `      // "duplicate id". Each queued build re-checks that it has not been` && |\n| &&
             `      // superseded before it starts.` && |\n| &&
             `      _displayMainView(xml, mOptions) {` && |\n| &&
             `        const seq = this._systemSeq;` && |\n| &&
             `        Server._viewBuild = Promise.resolve(Server._viewBuild)` && |\n| &&
             `          .catch(() => {})` && |\n| &&
             `          .then(() => {` && |\n| &&
             `            if (seq !== undefined && seq !== Server._requestSeq) {` && |\n| &&
             `              return undefined;` && |\n| &&
             `            }` && |\n| &&
             `            return this.displayView(` && |\n| &&
             `              xml,` && |\n| &&
             `              AppState.state.oResponse?.OVIEWMODEL,` && |\n| &&
             `              seq,` && |\n| &&
             `              mOptions,` && |\n| &&
             `            );` && |\n| &&
             `          });` && |\n| &&
             `        return Server._viewBuild;` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      // eFS = "event frontend, system": the SYSTEM phase counterpart of eF.` && |\n| &&
             `      // It returns the handler's result so an async display can be awaited,` && |\n| &&
             `      // and lets errors propagate - see FrontendAction.executeSystem.` && |\n| &&
             `      eFS(...args) {` && |\n| &&
             `        return FrontendAction.executeSystem(this, args);` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      // Execute the follow-up JS snippets stashed by Server.responseSuccess.` && |\n| &&
             `      // Runs once per roundtrip, after the view has rendered.` && |\n| &&
             `      _runPendingCustomJs(oResponse) {` && |\n| &&
             `        const customJs = oResponse?._pendingCustomJs;` && |\n| &&
             `        if (oResponse) oResponse._pendingCustomJs = null;` && |\n| &&
             `        if (!customJs) return;` && |\n| &&
             `        if (Lib.isDestroyed(this)) return;` && |\n| &&
             `        for (const item of customJs) {` && |\n| &&
             `          Server._runCustomJs(item, this);` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      _createViewModel() {` && |\n| &&
             `        const data = AppState.state.oResponse?.OVIEWMODEL;` && |\n| &&
             `        return this._trackChanges(new JSONModel(data));` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      // ------------------------------------------------------------------` && |\n| &&
             `      // Display: popups, popovers, nested views, main view` && |\n| &&
             `      // ------------------------------------------------------------------` && |\n| &&
             `` && |\n| &&
             `      // Shared load path of the two fragment slots (popup, popover): create` && |\n| &&
             `      // the slot's own JSON model, load the fragment and attach the model.` && |\n| &&
             `      // Returns null when the app was torn down while the fragment loaded or a` && |\n| &&
             `      // newer request superseded this response - we must not open a dialog the` && |\n| &&
             `      // backend no longer knows about.` && |\n| &&
             `      async _loadSlotFragment(slotKey, fragmentId, xml, seq) {` && |\n| &&
             `        const oModel = this._createViewModel();` && |\n| &&
             `        applyStoredSizeLimit(slotKey, oModel);` && |\n| &&
             `        const oFragment = await Fragment.load({` && |\n| &&
             `          definition: xml,` && |\n| &&
             `          controller: ViewSlots.getController(slotKey),` && |\n| &&
             `          id: fragmentId,` && |\n| &&
             `        });` && |\n| &&
             `        if (!Lib.isAlive(AppState.state.oApp) || this._isSuperseded(seq)) {` && |\n| &&
             `          oFragment.destroy();` && |\n| &&
             `          return null;` && |\n| &&
             `        }` && |\n| &&
             `        oFragment.setModel(oModel);` && |\n| &&
             `        return oFragment;` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      async displayFragment(xml, seq) {` && |\n| &&
             `        const oFragment = await this._loadSlotFragment(` && |\n| &&
             `          "POPUP",` && |\n| &&
             `          "popupId",` && |\n| &&
             `          xml,` && |\n| &&
             `          seq,` && |\n| &&
             `        );` && |\n| &&
             `        if (!oFragment) return;` && |\n| &&
             `        // The shared device + message models are attached inside` && |\n| &&
             `        // ViewSlots.setView (the single funnel), so error paths that` && |\n| &&
             `        // destroy a view without reaching setView never register it.` && |\n| &&
             `        ViewSlots.setView("POPUP", oFragment);` && |\n| &&
             `        oFragment.open();` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      // True when this response was superseded by a newer request while an` && |\n| &&
             `      // async view build was awaiting (undefined seq = no check, for` && |\n| &&
             `      // custom-JS callers of the display helpers).` && |\n| &&
             `      _isSuperseded(seq) {` && |\n| &&
             `        return seq !== undefined && seq !== Server._requestSeq;` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      async displayPopover(xml, openById, seq) {` && |\n| &&
             `        // No catch-all here on purpose: a malformed-XML load or render` && |\n| &&
             `        // failure must propagate to _processAfterRendering and surface the` && |\n| &&
             `        // fatal "App Terminated" overlay, exactly like displayFragment and` && |\n| &&
             `        // displayNestedView. The explicit returns below stay graceful - they` && |\n| &&
             `        // handle expected, non-error conditions (app torn down mid-load, or` && |\n| &&
             `        // the openBy anchor not being present), matching the parent-not-found` && |\n| &&
             `        // guard in displayNestedView.` && |\n| &&
             `        const oFragment = await this._loadSlotFragment(` && |\n| &&
             `          "POPOVER",` && |\n| &&
             `          "popoverId",` && |\n| &&
             `          xml,` && |\n| &&
             `          seq,` && |\n| &&
             `        );` && |\n| &&
             `        if (!oFragment) return;` && |\n| &&
             `` && |\n| &&
             `        // Find the control to attach the popover to: any open slot first,` && |\n| &&
             `        // then the global UI5 control registry as a last resort.` && |\n| &&
             `        const oControl = ViewSlots.resolveById(openById);` && |\n| &&
             `` && |\n| &&
             `        if (!oControl) {` && |\n| &&
             `          Lib.logError(` && |\n| &&
             `            ``displayPopover: openBy control '${openById}' not found``,` && |\n| &&
             `          );` && |\n| &&
             `          oFragment.destroy();` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `        ViewSlots.setView("POPOVER", oFragment);` && |\n| &&
             `        oFragment.openBy(oControl);` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      async displayNestedView(xml, slotKey, mOptions, seq) {` && |\n| &&
             `        // Nested views do NOT create their own model. They are inserted into` && |\n| &&
             `        // the MAIN control tree below and inherit its default JSON model via` && |\n| &&
             `        // UI5 model propagation, so every view binds against the same data with` && |\n| &&
             `        // one change tracker and one refresh per roundtrip - no duplicate` && |\n| &&
             `        // models pointing at the same data. The model passed to the XML` && |\n| &&
             `        // preprocessor here only feeds {template>...} bindings at build time;` && |\n| &&
             `        // it is the MAIN view's JSON model (the named "http" model when` && |\n| &&
             `        // SWITCH_DEFAULT_MODEL_PATH moved OData into the default slot, otherwise` && |\n| &&
             `        // the default model), mirroring displayView's template model.` && |\n| &&
             `        const oMainView = ViewSlots.getView("MAIN");` && |\n| &&
             `        const oTemplateModel =` && |\n| &&
             `          oMainView?.getModel("http") ?? oMainView?.getModel();` && |\n| &&
             `        const oView = await XMLView.create({` && |\n| &&
             `          definition: xml,` && |\n| &&
             `          controller: ViewSlots.getController(slotKey),` && |\n| &&
             `          preprocessors: { xml: { models: { template: oTemplateModel } } },` && |\n| &&
             `        });` && |\n| &&
             `` && |\n| &&
             `        if (!Lib.isAlive(AppState.state.oApp) || this._isSuperseded(seq)) {` && |\n| &&
             `          oView.destroy();` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `` && |\n| &&
             `        // The options travel with the action that carries the XML, so they` && |\n| &&
             `        // always belong to the same response - there is no live global to` && |\n| &&
             `        // re-read and no way to mix this response's view with a newer` && |\n| &&
             `        // response's parent id and insert/destroy methods.` && |\n| &&
             `        const {` && |\n| &&
             `          id: ID,` && |\n| &&
             `          methodDestroy: METHOD_DESTROY,` && |\n| &&
             `          methodInsert: METHOD_INSERT,` && |\n| &&
             `        } = mOptions;` && |\n| &&
             `` && |\n| &&
             `        const oParent = ViewSlots.byId("MAIN", ID);` && |\n| &&
             `        if (!oParent) {` && |\n| &&
             `          Lib.logError(` && |\n| &&
             `            ``displayNestedView: parent control '${ID}' not found, nested view discarded``,` && |\n| &&
             `          );` && |\n| &&
             `          oView.destroy();` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `` && |\n| &&
             `        // METHOD_DESTROY is optional: only call it when the app asked for a` && |\n| &&
             `        // parent teardown method. An empty value used to reach oParent[""]()` && |\n| &&
             `        // and throw on every render (e.g. app 065 passes only method_insert).` && |\n| &&
             `        if (METHOD_DESTROY) {` && |\n| &&
             `          try {` && |\n| &&
             `            oParent[METHOD_DESTROY]();` && |\n| &&
             `          } catch (e) {` && |\n| &&
             `            Lib.logError(` && |\n| &&
             `              ``displayNestedView: parent destroy method '${METHOD_DESTROY}' failed``,` && |\n| &&
             `              e,` && |\n| &&
             `            );` && |\n| &&
             `          }` && |\n| &&
             `        }` && |\n| &&
             `        try {` && |\n| &&
             `          oParent[METHOD_INSERT](oView);` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          Lib.logError("displayNestedView: parent insert method failed", e);` && |\n| &&
             `          oView.destroy();` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `        ViewSlots.setView(slotKey, oView);` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      // Thin wrappers around the shared slot teardown in ViewSlots, kept` && |\n| &&
             `      // because existing apps may call them via custom JS.` && |\n| &&
             `      destroyPopup() {` && |\n| &&
             `        ViewSlots.destroy("POPUP");` && |\n| &&
             `      },` && |\n| &&
             `      destroyPopover() {` && |\n| &&
             `        ViewSlots.destroy("POPOVER");` && |\n| &&
             `      },` && |\n| &&
             `      destroyNestView() {` && |\n| &&
             `        ViewSlots.destroy("NEST");` && |\n| &&
             `      },` && |\n| &&
             `      destroyNestView2() {` && |\n| &&
             `        ViewSlots.destroy("NEST2");` && |\n| &&
             `      },` && |\n| &&
             `      destroyView() {` && |\n| &&
             `        ViewSlots.destroy("MAIN");` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      // ------------------------------------------------------------------` && |\n| &&
             `      // eF = "event frontend": handles frontend-only events triggered by` && |\n| &&
             `      // the backend response, without a roundtrip. The name is part of the` && |\n| &&
             `      // protocol - backend-generated view XML binds events to eB/eF - and` && |\n| &&
             `      // must not be renamed. The individual handlers live in` && |\n| &&
             `      // core/FrontendAction.js.` && |\n| &&
             `      // ------------------------------------------------------------------` && |\n| &&
             `      eF(...args) {` && |\n| &&
             `        FrontendAction.execute(this, args);` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      // ------------------------------------------------------------------` && |\n|.
    result = result &&
             `      // eBP = "event backend, prevent default": cancels the control's` && |\n| &&
             `      // built-in default for this event and then round-trips exactly like` && |\n| &&
             `      // eB. The backend emits it (instead of eB) for an event registered` && |\n| &&
             `      // with s_ctrl-check_prevent_default, passing $event as the first` && |\n| &&
             `      // argument - preventDefault() only works synchronously inside the` && |\n| &&
             `      // handler, so it cannot be a follow-up action from the response.` && |\n| &&
             `      // Example: sap.tnt NavigationListItem.press, where cancelling the` && |\n| &&
             `      // default suppresses the item selection and leaves the decision to` && |\n| &&
             `      // the backend. The name is part of the protocol - do not rename it.` && |\n| &&
             `      //` && |\n| &&
             `      // The second argument is the veto CONDITION, so the decision can be` && |\n| &&
             `      // made per firing instead of per wire: s_ctrl-check_prevent_default` && |\n| &&
             `      // sends the constant true, s_ctrl-prevent_default_expr sends an` && |\n| &&
             `      // expression UI5 resolves on each firing (e.g. "is this the one column` && |\n| &&
             `      // that must not be resized?"). Everything after it is the eB payload.` && |\n| &&
             `      // ------------------------------------------------------------------` && |\n| &&
             `      eBP(oEvent, bVeto, ...args) {` && |\n| &&
             `        // guard the call: a malformed wire (no $event) must still round-trip` && |\n| &&
             `        if (bVeto && typeof oEvent?.preventDefault === "function") {` && |\n| &&
             `          oEvent.preventDefault();` && |\n| &&
             `        }` && |\n| &&
             `        this.eB(...args);` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      // Ancestor-text breadcrumb of a control resolved in an event argument,` && |\n| &&
             `      // e.g. ``$controller.textPath(${$parameters>/item})`` on a menu's` && |\n| &&
             `      // itemSelected -> "Create New Site > Official Store". The parent-chain` && |\n| &&
             `      // walk happens on the live control tree, so no binding path can express` && |\n| &&
             `      // it; the separator defaults to " > ".` && |\n| &&
             `      textPath(oControl, sSeparator) {` && |\n| &&
             `        return Lib.getTextPath(oControl, sSeparator);` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      // ------------------------------------------------------------------` && |\n| &&
             `      // eB = "event backend": triggers a backend roundtrip with arguments.` && |\n| &&
             `      // The name is part of the protocol - backend-generated view XML binds` && |\n| &&
             `      // events to eB/eF - and must not be renamed.` && |\n| &&
             `      //` && |\n| &&
             `      // args[0] is the event array built by the backend (get_event):` && |\n| &&
             `      //   [0] event name` && |\n| &&
             `      //   [1] reserved placeholder, always false` && |\n| &&
             `      //   [2] "ignore busy" flag - background events (e.g. timers) skip the` && |\n| &&
             `      //       busy guard below` && |\n| &&
             `      //   [3] "use main view model" flag - events fired from a popup or` && |\n| &&
             `      //       popover controller that still target the main app's model;` && |\n| &&
             `      //       not emitted by the framework today, only by custom JS` && |\n| &&
             `      // ------------------------------------------------------------------` && |\n| &&
             `      eB(...args) {` && |\n| &&
             `        const [, , ignoreBusy, useMainModel] = args[0];` && |\n| &&
             `` && |\n| &&
             `        if (!navigator.onLine) {` && |\n| &&
             `          MessageBox.alert(` && |\n| &&
             `            "No internet connection! Please reconnect to the server and try again.",` && |\n| &&
             `          );` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `` && |\n| &&
             `        // A roundtrip is already in flight and this event's keystroke/click is` && |\n| &&
             `        // dropped. Surface the global busy indicator right away (0 delay)` && |\n| &&
             `        // instead of a separate, transient BusyDialog: it is the exact same` && |\n| &&
             `        // overlay the in-flight roundtrip hides on completion, so the user sees` && |\n| &&
             `        // one steady indicator until the response lands - not a modal flashing` && |\n| &&
             `        // in and straight back out over the (1s-delayed) global one. show() is` && |\n| &&
             `        // idempotent, so repeated drops during the same roundtrip are cheap.` && |\n| &&
             `        if (AppState.state.isBusy && !ignoreBusy) {` && |\n| &&
             `          BusyIndicator.show(0);` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `` && |\n| &&
             `        // A new roundtrip overrides any pending timer - timers that fired` && |\n| &&
             `        // already removed themselves before calling eB, so this only cancels` && |\n| &&
             `        // timers that are still waiting.` && |\n| &&
             `        for (const key in AppState.state.timers) {` && |\n| &&
             `          clearTimeout(AppState.state.timers[key]);` && |\n| &&
             `          delete AppState.state.timers[key];` && |\n| &&
             `        }` && |\n| &&
             `` && |\n| &&
             `        AppState.state.isBusy = true;` && |\n| &&
             `        BusyIndicator.show();` && |\n| &&
             `` && |\n| &&
             `        // The request body is built locally and handed explicitly through` && |\n| &&
             `        // Server.roundtrip/readHttp. It is mirrored to AppState.state.oBody right` && |\n| &&
             `        // away so onBeforeRoundtrip hooks and the developer tools see it.` && |\n| &&
             `        const oBody = {};` && |\n| &&
             `        AppState.state.oBody = oBody;` && |\n| &&
             `` && |\n| &&
             `        // Decide which view's model holds the data we need to send back. The` && |\n| &&
             `        // mapping is: main app controller -> main view, popup controller ->` && |\n| &&
             `        // popup view, etc.` && |\n| &&
             `        const oModel = this._pickModelForRoundtrip(useMainModel);` && |\n| &&
             `` && |\n| &&
             `        Lib.runCallbacks(AppState.state.onBeforeRoundtrip);` && |\n| &&
             `` && |\n| &&
             `        // If the user edited model paths, send only the delta to keep the` && |\n| &&
             `        // payload small. The edited paths live on the picked model itself` && |\n| &&
             `        // (set in _trackChanges), so onBeforeRoundtrip hooks that mark paths` && |\n| &&
             `        // dirty (e.g. the Scrolling control) must have run above first.` && |\n| &&
             `        const changedPaths = oModel?._z2ui5ChangedPaths;` && |\n| &&
             `        if (oModel && changedPaths?.size > 0) {` && |\n| &&
             `          const data = oModel.getData();` && |\n| &&
             `          if (data) {` && |\n| &&
             `            oBody.MODEL = Lib.buildDeltaFromPaths(changedPaths, data);` && |\n| &&
             `          }` && |\n| &&
             `        }` && |\n| &&
             `        // Remember which model this request carried so the winning response` && |\n| &&
             `        // clears exactly its edits (Server.readHttp) - a stale response clears` && |\n| &&
             `        // nothing, and edits in other models stay pending for their own send.` && |\n| &&
             `        AppState.state.oSentModel = oModel;` && |\n| &&
             `` && |\n| &&
             `        oBody.ID = AppState.state.oResponse?.ID;` && |\n| &&
             `        // Arguments travel as raw JSON values - the request body is` && |\n| &&
             `        // serialized exactly once in Server.readHttp. Object arguments are` && |\n| &&
             `        // turned into JSON strings by the backend when it fills` && |\n| &&
             `        // T_EVENT_ARG, so apps keep receiving them as strings; stringifying` && |\n| &&
             `        // them here as well would encode (and escape) the payload twice.` && |\n| &&
             `        // Control-valued arguments are marshalled into plain data first (see` && |\n| &&
             `        // Lib.normalizeEventArgs): a UI5 event parameter is often a control or` && |\n| &&
             `        // an array of controls, and JSON.stringify throws on the circular` && |\n| &&
             `        // parent/aggregation graph of a ManagedObject. Everything else passes` && |\n| &&
             `        // through untouched. normalizeEventArgs returns a fresh array, which` && |\n| &&
             `        // is what Server.roundtrip needs - it mutates ARGUMENTS via shift and` && |\n| &&
             `        // must not reach this call's own rest-parameter array.` && |\n| &&
             `        oBody.ARGUMENTS = Lib.normalizeEventArgs(args);` && |\n| &&
             `` && |\n| &&
             `        Server.roundtrip(oBody);` && |\n| &&
             `        Lib.runCallbacks(AppState.state.onAfterRoundtrip);` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      // The framework-owned JSON model on a slot's view: the DEFAULT model` && |\n| &&
             `      // normally, but the NAMED "http" model when SWITCH_DEFAULT_MODEL_PATH put` && |\n| &&
             `      // an OData model in the default slot. Returns undefined when neither model` && |\n| &&
             `      // is ours (marked by _z2ui5Tracked).` && |\n| &&
             `      _resolveTrackedModel(oView) {` && |\n| &&
             `        const isOurs = (m) => (m?._z2ui5Tracked ? m : undefined);` && |\n| &&
             `        return isOurs(oView.getModel()) ?? isOurs(oView.getModel("http"));` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      _pickModelForRoundtrip(useMainModel) {` && |\n| &&
             `        // useMainModel forces use of the main view's model even when called` && |\n| &&
             `        // from a popup/popover controller.` && |\n| &&
             `        const slotKey = useMainModel ? "MAIN" : ViewSlots.keyOfController(this);` && |\n| &&
             `        if (!slotKey) return undefined;` && |\n| &&
             `` && |\n| &&
             `        const oView = ViewSlots.getView(slotKey);` && |\n| &&
             `        if (!oView) return undefined;` && |\n| &&
             `` && |\n| &&
             `        // MAIN and its nested views (NEST/NEST2) share one framework-owned` && |\n| &&
             `        // JSON model, so a nested-slot event must resolve the tracked model` && |\n| &&
             `        // (not the propagated OData default, which has no getData()) or the` && |\n| &&
             `        // edit is silently dropped. The data and changedPaths delta are shared` && |\n| &&
             `        // across the root slots, so any of them yields the same model.` && |\n| &&
             `        if (Lib.isRootModelSlot(slotKey)) {` && |\n| &&
             `          return this._resolveTrackedModel(oView);` && |\n| &&
             `        }` && |\n| &&
             `` && |\n| &&
             `        // Popup/popover are standalone and return their own (default) model.` && |\n| &&
             `        return oView.getModel();` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      // Refresh a slot's model when the response signals an update for it` && |\n| &&
             `      // (CHECK_UPDATE_MODEL - the data-only roundtrip every app triggers` && |\n| &&
             `      // via client->view_model_update( )).` && |\n| &&
             `      // Only the three model-owning slots ever carry the flag: MAIN owns the` && |\n| &&
             `      // root model, POPUP/POPOVER own their own. NEST/NEST2 are inserted into` && |\n| &&
             `      // the MAIN control tree and inherit its model by propagation, so the` && |\n| &&
             `      // backend has no CHECK_UPDATE_MODEL for them at all and` && |\n| &&
             `      // nest_view_model_update( ) refreshes MAIN instead - which is why this` && |\n| &&
             `      // can setData unconditionally without refreshing one shared model twice.` && |\n| &&
             `      // Push the response's model into one slot, if it is open at all.` && |\n| &&
             `      updateModelIfRequired(slotKey) {` && |\n| &&
             `        const oView = ViewSlots.getView(slotKey);` && |\n| &&
             `        if (!oView) return;` && |\n| &&
             `` && |\n| &&
             `        // Reuse the existing model whenever it is ours: setData() keeps the` && |\n| &&
             `        // view's bindings alive and only refreshes what changed, while a new` && |\n| &&
             `        // model + setModel() destroys and recreates every binding - measured` && |\n| &&
             `        // ~3x slower with all values changed and ~150x slower when little` && |\n| &&
             `        // changed (see node/tests-examples/modelUpdate.bench.spec.js).` && |\n| &&
             `        // Never overwrite an OData default (switch mode) with a fresh JSON model.` && |\n| &&
             `        const tracked = this._resolveTrackedModel(oView);` && |\n| &&
             `        if (tracked) {` && |\n| &&
             `          applyStoredSizeLimit(slotKey, tracked);` && |\n| &&
             `          tracked.setData(AppState.state.oResponse?.OVIEWMODEL);` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `` && |\n| &&
             `        // No framework-owned model on this slot at all: bind a fresh default` && |\n| &&
             `        // JSON model (keeps the previous behavior for that edge case).` && |\n| &&
             `        const oModel = this._createViewModel();` && |\n| &&
             `        applyStoredSizeLimit(slotKey, oModel);` && |\n| &&
             `        oView.setModel(oModel);` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      // Replace the main app view with the XML coming from the backend.` && |\n| &&
             `      async displayView(xml, viewModel, reqSeq, mOptions = {}) {` && |\n| &&
             `        const oViewModel = this._trackChanges(new JSONModel(viewModel));` && |\n| &&
             `` && |\n| &&
             `        const switchPath = mOptions.switchDefaultModelPath;` && |\n| &&
             `` && |\n| &&
             `        // When the app wants OData as the default model, build it here and` && |\n| &&
             `        // keep the JSON model as the named "http" model.` && |\n| &&
             `        let oModel;` && |\n| &&
             `        if (switchPath) {` && |\n| &&
             `          oModel = new ODataModel({` && |\n| &&
             `            serviceUrl: switchPath,` && |\n| &&
             `            annotationURI: mOptions.switchDefaultModelAnnoUri || "",` && |\n| &&
             `          });` && |\n| &&
             `        } else {` && |\n| &&
             `          oModel = oViewModel;` && |\n| &&
             `        }` && |\n| &&
             `        applyStoredSizeLimit("MAIN", oModel);` && |\n| &&
             `` && |\n| &&
             `        const oView = await XMLView.create({` && |\n| &&
             `          definition: xml,` && |\n| &&
             `          models: oModel,` && |\n| &&
             `          controller: ViewSlots.getController("MAIN"),` && |\n| &&
             `          id: "mainView",` && |\n| &&
             `          preprocessors: { xml: { models: { template: oViewModel } } },` && |\n| &&
             `        });` && |\n| &&
             `` && |\n| &&
             `        // oModel covers oViewModel too when they are the same object (no` && |\n| &&
             `        // switchPath); with an OData default model both must go.` && |\n| &&
             `        const discardBuild = () => {` && |\n| &&
             `          oView.destroy();` && |\n| &&
             `          oModel.destroy();` && |\n| &&
             `          if (switchPath) oViewModel.destroy();` && |\n| &&
             `        };` && |\n| &&
             `` && |\n| &&
             `        // Guard against the app being destroyed during the await above.` && |\n| &&
             `        if (!Lib.isAlive(AppState.state.oApp)) {` && |\n| &&
             `          discardBuild();` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `` && |\n| &&
             `        // A newer parallel request (check_allow_multi_req) superseded this one` && |\n| &&
             `        // while XMLView.create was awaiting - discard this rebuild instead of` && |\n| &&
             `        // letting an out-of-order resolve overwrite the newer view. Last-write` && |\n| &&
             `        // wins by request order, not by which create() happened to resolve last.` && |\n| &&
             `        // Only discard when a newer view actually took the slot: if the` && |\n| &&
             `        // superseding response was data-only, dropping this build too would` && |\n| &&
             `        // leave the app permanently blank - a slightly stale view is the` && |\n| &&
             `        // better outcome then.` && |\n| &&
             `        if (` && |\n| &&
             `          reqSeq !== undefined &&` && |\n| &&
             `          reqSeq !== Server._requestSeq &&` && |\n| &&
             `          ViewSlots.getView("MAIN")` && |\n| &&
             `        ) {` && |\n| &&
             `          discardBuild();` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `` && |\n| &&
             `        ViewSlots.setView("MAIN", oView);` && |\n| &&
             `        if (switchPath) oView.setModel(oViewModel, "http");` && |\n| &&
             `        AppState.state.oApp.removeAllPages();` && |\n| &&
             `        AppState.state.oApp.insertPage(oView);` && |\n| &&
             `      },` && |\n| &&
             `    });` && |\n| &&
             `  },` && |\n| &&
             `);` && |\n| &&
             `` && |\n| &&
              ``.

  ENDMETHOD.

ENDCLASS.
