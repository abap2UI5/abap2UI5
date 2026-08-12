sap.ui.define(
  [
    "sap/ui/core/mvc/XMLView",
    "sap/ui/core/Fragment",
    "sap/ui/model/json/JSONModel",
    "sap/ui/model/odata/v2/ODataModel",
    "z2ui5/core/Server",
    "z2ui5/core/Lib",
    "z2ui5/core/ViewSlots",
    "z2ui5/core/AppState",
  ],
  (
    XMLView,
    Fragment,
    JSONModel,
    ODataModel,
    Server,
    Lib,
    ViewSlots,
    AppState,
  ) => {
    "use strict";

    // ------------------------------------------------------------------
    // The VIEW_SLOTS action target: everything a backend response does to
    // the five view slots - destroy one, display one (each slot with its
    // own loader), push the model into the open ones - plus the
    // framework-owned JSON model with its change tracking, which the
    // displays create and the eB roundtrip reads back
    // (View1._pickModelForRoundtrip via resolveTrackedModel).
    // ------------------------------------------------------------------

    function applyStoredSizeLimit(viewKey, oModel) {
      if (!oModel) return;
      // For the root slots (MAIN/NEST/NEST2) this is the max limit across them,
      // since they share this one model; popup/popover get their own limit.
      const limit = Lib.effectiveSizeLimit(
        AppState.state.viewSizeLimits,
        viewKey,
      );
      if (limit !== undefined) oModel.setSizeLimit(limit);
    }

    // ------------------------------------------------------------------
    // Model change tracking - remembers which model paths the user edited
    // so the next roundtrip only ships the delta.
    // ------------------------------------------------------------------
    function trackChanges(oModel) {
      // Mark the model as framework-owned: updateModelIfRequired may only
      // reuse models that carry this change tracker.
      oModel._z2ui5Tracked = true;
      // Edited paths are tracked PER MODEL, not in one shared set: the main
      // view and a popup/popover each have their own JSON model, and a
      // roundtrip ships only the picked model's own edits. A single shared
      // set would build the delta of one model against another's data (a
      // path missing there serializes as `undefined` and clears the field
      // on the backend) and would drop the other model's still-unsent edits.
      oModel._z2ui5ChangedPaths = new Set();
      oModel.attachPropertyChange((e) => {
        const params = e.getParameters();
        const raw = params.path;
        const ctx = params.context;
        if (!raw) return;
        // Resolve relative paths against the binding context.
        const changedPath =
          ctx && !raw.startsWith("/") ? `${ctx.getPath()}/${raw}` : raw;
        if (changedPath.startsWith("/")) {
          oModel._z2ui5ChangedPaths.add(changedPath);
        }
      });
      return oModel;
    }

    // The framework-owned JSON model on a slot's view: the DEFAULT model
    // normally, but the NAMED "http" model when SWITCH_DEFAULT_MODEL_PATH put
    // an OData model in the default slot. Returns undefined when neither model
    // is ours (marked by _z2ui5Tracked).
    function resolveTrackedModel(oView) {
      const isOurs = (m) => (m?._z2ui5Tracked ? m : undefined);
      return isOurs(oView.getModel()) ?? isOurs(oView.getModel("http"));
    }

    function createViewModel() {
      const data = AppState.state.oResponse?.OVIEWMODEL;
      return trackChanges(new JSONModel(data));
    }

    // True when this response was superseded by a newer request while an
    // async view build was awaiting (undefined seq = no check, for callers
    // outside the system-action phase).
    function isSuperseded(seq) {
      return seq !== undefined && seq !== Server._requestSeq;
    }

    // ------------------------------------------------------------------
    // Display: popups, popovers, nested views, main view
    // ------------------------------------------------------------------

    // Shared load path of the two fragment slots (popup, popover): create
    // the slot's own JSON model, load the fragment and attach the model.
    // Returns null when the app was torn down while the fragment loaded or a
    // newer request superseded this response - we must not open a dialog the
    // backend no longer knows about.
    async function loadSlotFragment(slotKey, fragmentId, xml, seq) {
      const oModel = createViewModel();
      applyStoredSizeLimit(slotKey, oModel);
      const oFragment = await Fragment.load({
        definition: xml,
        controller: ViewSlots.getController(slotKey),
        id: fragmentId,
      });
      if (!Lib.isAlive(AppState.state.oApp) || isSuperseded(seq)) {
        oFragment.destroy();
        return null;
      }
      oFragment.setModel(oModel);
      return oFragment;
    }

    async function displayFragment(xml, seq) {
      const oFragment = await loadSlotFragment("POPUP", "popupId", xml, seq);
      if (!oFragment) return;
      // The shared device + message models are attached inside
      // ViewSlots.setView (the single funnel), so error paths that
      // destroy a view without reaching setView never register it.
      ViewSlots.setView("POPUP", oFragment);
      oFragment.open();
    }

    async function displayPopover(xml, openById, seq) {
      // No catch-all here on purpose: a malformed-XML load or render
      // failure must propagate to _processAfterRendering and surface the
      // fatal "App Terminated" overlay, exactly like displayFragment and
      // displayNestedView. The explicit returns below stay graceful - they
      // handle expected, non-error conditions (app torn down mid-load, or
      // the openBy anchor not being present), matching the parent-not-found
      // guard in displayNestedView.
      const oFragment = await loadSlotFragment(
        "POPOVER",
        "popoverId",
        xml,
        seq,
      );
      if (!oFragment) return;

      // Find the control to attach the popover to: any open slot first,
      // then the global UI5 control registry as a last resort.
      const oControl = ViewSlots.resolveById(openById);

      if (!oControl) {
        Lib.logError(`displayPopover: openBy control '${openById}' not found`);
        oFragment.destroy();
        return;
      }
      ViewSlots.setView("POPOVER", oFragment);
      oFragment.openBy(oControl);
    }

    async function displayNestedView(xml, slotKey, mOptions, seq) {
      // Nested views do NOT create their own model. They are inserted into
      // the MAIN control tree below and inherit its default JSON model via
      // UI5 model propagation, so every view binds against the same data with
      // one change tracker and one refresh per roundtrip - no duplicate
      // models pointing at the same data. The model passed to the XML
      // preprocessor here only feeds {template>...} bindings at build time;
      // it is the MAIN view's JSON model (the named "http" model when
      // SWITCH_DEFAULT_MODEL_PATH moved OData into the default slot, otherwise
      // the default model), mirroring displayView's template model.
      const oMainView = ViewSlots.getView("MAIN");
      const oTemplateModel =
        oMainView?.getModel("http") ?? oMainView?.getModel();
      const oView = await XMLView.create({
        definition: xml,
        controller: ViewSlots.getController(slotKey),
        preprocessors: { xml: { models: { template: oTemplateModel } } },
      });

      if (!Lib.isAlive(AppState.state.oApp) || isSuperseded(seq)) {
        oView.destroy();
        return;
      }

      // The options travel with the action that carries the XML, so they
      // always belong to the same response - there is no live global to
      // re-read and no way to mix this response's view with a newer
      // response's parent id and insert/destroy methods.
      const {
        id: ID,
        methodDestroy: METHOD_DESTROY,
        methodInsert: METHOD_INSERT,
      } = mOptions;

      const oParent = ViewSlots.byId("MAIN", ID);
      if (!oParent) {
        Lib.logError(
          `displayNestedView: parent control '${ID}' not found, nested view discarded`,
        );
        oView.destroy();
        return;
      }

      // METHOD_DESTROY is optional: only call it when the app asked for a
      // parent teardown method. An empty value used to reach oParent[""]()
      // and throw on every render (e.g. app 065 passes only method_insert).
      if (METHOD_DESTROY) {
        try {
          oParent[METHOD_DESTROY]();
        } catch (e) {
          Lib.logError(
            `displayNestedView: parent destroy method '${METHOD_DESTROY}' failed`,
            e,
          );
        }
      }
      try {
        oParent[METHOD_INSERT](oView);
      } catch (e) {
        Lib.logError("displayNestedView: parent insert method failed", e);
        oView.destroy();
        return;
      }
      ViewSlots.setView(slotKey, oView);
    }

    // Replace the main app view with the XML coming from the backend.
    async function displayView(xml, viewModel, reqSeq, mOptions = {}) {
      const oViewModel = trackChanges(new JSONModel(viewModel));

      const switchPath = mOptions.switchDefaultModelPath;

      // When the app wants OData as the default model, build it here and
      // keep the JSON model as the named "http" model.
      let oModel;
      if (switchPath) {
        oModel = new ODataModel({
          serviceUrl: switchPath,
          annotationURI: mOptions.switchDefaultModelAnnoUri || "",
        });
      } else {
        oModel = oViewModel;
      }
      applyStoredSizeLimit("MAIN", oModel);

      const oView = await XMLView.create({
        definition: xml,
        models: oModel,
        controller: ViewSlots.getController("MAIN"),
        id: "mainView",
        preprocessors: { xml: { models: { template: oViewModel } } },
      });

      // oModel covers oViewModel too when they are the same object (no
      // switchPath); with an OData default model both must go.
      const discardBuild = () => {
        oView.destroy();
        oModel.destroy();
        if (switchPath) oViewModel.destroy();
      };

      // Guard against the app being destroyed during the await above.
      if (!Lib.isAlive(AppState.state.oApp)) {
        discardBuild();
        return;
      }

      // A newer parallel request (check_allow_multi_req) superseded this one
      // while XMLView.create was awaiting - discard this rebuild instead of
      // letting an out-of-order resolve overwrite the newer view. Last-write
      // wins by request order, not by which create() happened to resolve last.
      // Only discard when a newer view actually took the slot: if the
      // superseding response was data-only, dropping this build too would
      // leave the app permanently blank - a slightly stale view is the
      // better outcome then.
      if (isSuperseded(reqSeq) && ViewSlots.getView("MAIN")) {
        discardBuild();
        return;
      }

      ViewSlots.setView("MAIN", oView);
      if (switchPath) oView.setModel(oViewModel, "http");
      AppState.state.oApp.removeAllPages();
      AppState.state.oApp.insertPage(oView);
    }

    // The MAIN rebuild is the one display that cannot simply run: it is
    // serialized through Server._viewBuild because XMLView.create claims
    // the fixed "mainView" id synchronously, so two overlapping builds
    // (a slow library load plus a parallel/multi-req response) would throw
    // "duplicate id". Each queued build re-checks that it has not been
    // superseded before it starts.
    function displayMain(xml, mOptions, seq) {
      Server._viewBuild = Promise.resolve(Server._viewBuild)
        .catch(() => {})
        .then(() => {
          if (isSuperseded(seq)) {
            return undefined;
          }
          // The implicit teardown of the previous MAIN view happens HERE,
          // in the same synchronous step that claims the fixed "mainView"
          // id (XMLView.create in displayView) - never earlier at action
          // time: an early destroy empties the slot while an OLDER queued
          // build may still be awaiting, which would let that stale build
          // slip past displayView's "a newer view took the slot" guard and
          // then crash THIS build on a duplicate id.
          ViewSlots.destroy("MAIN");
          return displayView(
            xml,
            AppState.state.oResponse?.OVIEWMODEL,
            seq,
            mOptions,
          );
        });
      return Server._viewBuild;
    }

    // Push the response's model into one slot, if it is open at all.
    function updateModelIfRequired(slotKey) {
      const oView = ViewSlots.getView(slotKey);
      if (!oView) return;

      // Reuse the existing model whenever it is ours: setData() keeps the
      // view's bindings alive and only refreshes what changed, while a new
      // model + setModel() destroys and recreates every binding - measured
      // ~3x slower with all values changed and ~150x slower when little
      // changed (see node/tests-examples/modelUpdate.bench.spec.js).
      // Never overwrite an OData default (switch mode) with a fresh JSON model.
      const tracked = resolveTrackedModel(oView);
      if (tracked) {
        applyStoredSizeLimit(slotKey, tracked);
        tracked.setData(AppState.state.oResponse?.OVIEWMODEL);
        return;
      }

      // No framework-owned model on this slot at all: bind a fresh default
      // JSON model (keeps the previous behavior for that edge case).
      const oModel = createViewModel();
      applyStoredSizeLimit(slotKey, oModel);
      oView.setModel(oModel);
    }

    // The one entry point of the VIEW_SLOTS action target (wired in
    // actions/ControlCall's GLOBAL_TARGETS). destroy is ViewSlots' own
    // method; display and updateModel live here, because loading a fragment
    // and owning the model is this module's job. `seq` is the stamp of the
    // request the processed response belongs to, threaded through the action
    // context (FrontendAction.runSystem) - a display superseded by a newer
    // request discards its build instead of overwriting the newer view.
    function action(method, slotKey, xml, mOptions, seq) {
      if (method === "destroy") {
        ViewSlots.destroy(slotKey);
        return undefined;
      }
      if (method === "updateModel") {
        // no slot is named - push into every OPEN slot that carries a
        // model of its own
        for (const slot of ViewSlots.slots) {
          if (slot.ownsModel) updateModelIfRequired(slot.key);
        }
        return undefined;
      }
      // display. A display REPLACES the slot, so tear down whatever it
      // holds first - implicitly, the backend sends no destroy action with
      // a display (destroying an empty slot is a no-op). MAIN tears down
      // inside its serialized build chain (see displayMain) - its slot may
      // still be claimed by an older awaiting build.
      if (slotKey === "MAIN") return displayMain(xml, mOptions, seq);
      ViewSlots.destroy(slotKey);
      if (slotKey === "POPUP") return displayFragment(xml, seq);
      if (slotKey === "POPOVER") {
        return displayPopover(xml, mOptions.openById, seq);
      }
      return displayNestedView(xml, slotKey, mOptions, seq);
    }

    // action is the module's entry point (the VIEW_SLOTS target);
    // resolveTrackedModel is what eB's model pick needs (View1.controller).
    // Everything else on this file is internal to the display machinery.
    return {
      action,
      resolveTrackedModel,
    };
  },
);
