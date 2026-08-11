* =====================================================================
* GENERATED FILE - DO NOT EDIT (AGENTS.md rule 2)
* Embedded frontend resource, generated from app/webapp/ by
* .github/app2abap/trans2abap.js. Change the source under app/webapp/
* and run 'npm run app2abap' to regenerate; the check_app2abap CI gate
* fails any manual edit here.
* =====================================================================
CLASS z2ui5_cl_app_slots_js DEFINITION
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


CLASS z2ui5_cl_app_slots_js IMPLEMENTATION.

  METHOD get.

    result = `sap.ui.define(` && |\n| &&
             `  [` && |\n| &&
             `    "sap/ui/core/mvc/XMLView",` && |\n| &&
             `    "sap/ui/core/Fragment",` && |\n| &&
             `    "sap/ui/model/json/JSONModel",` && |\n| &&
             `    "sap/ui/model/odata/v2/ODataModel",` && |\n| &&
             `    "z2ui5/core/Server",` && |\n| &&
             `    "z2ui5/core/Lib",` && |\n| &&
             `    "z2ui5/core/ViewSlots",` && |\n| &&
             `    "z2ui5/core/AppState",` && |\n| &&
             `  ],` && |\n| &&
             `  (` && |\n| &&
             `    XMLView,` && |\n| &&
             `    Fragment,` && |\n| &&
             `    JSONModel,` && |\n| &&
             `    ODataModel,` && |\n| &&
             `    Server,` && |\n| &&
             `    Lib,` && |\n| &&
             `    ViewSlots,` && |\n| &&
             `    AppState,` && |\n| &&
             `  ) => {` && |\n| &&
             `    "use strict";` && |\n| &&
             `` && |\n| &&
             `    // ------------------------------------------------------------------` && |\n| &&
             `    // The VIEW_SLOTS action target: everything a backend response does to` && |\n| &&
             `    // the five view slots - destroy one, display one (each slot with its` && |\n| &&
             `    // own loader), push the model into the open ones - plus the` && |\n| &&
             `    // framework-owned JSON model with its change tracking, which the` && |\n| &&
             `    // displays create and the eB roundtrip reads back` && |\n| &&
             `    // (View1._pickModelForRoundtrip via resolveTrackedModel).` && |\n| &&
             `    // ------------------------------------------------------------------` && |\n| &&
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
             `    // ------------------------------------------------------------------` && |\n| &&
             `    // Model change tracking - remembers which model paths the user edited` && |\n| &&
             `    // so the next roundtrip only ships the delta.` && |\n| &&
             `    // ------------------------------------------------------------------` && |\n| &&
             `    function trackChanges(oModel) {` && |\n| &&
             `      // Mark the model as framework-owned: updateModelIfRequired may only` && |\n| &&
             `      // reuse models that carry this change tracker.` && |\n| &&
             `      oModel._z2ui5Tracked = true;` && |\n| &&
             `      // Edited paths are tracked PER MODEL, not in one shared set: the main` && |\n| &&
             `      // view and a popup/popover each have their own JSON model, and a` && |\n| &&
             `      // roundtrip ships only the picked model's own edits. A single shared` && |\n| &&
             `      // set would build the delta of one model against another's data (a` && |\n| &&
             `      // path missing there serializes as ``undefined`` and clears the field` && |\n| &&
             `      // on the backend) and would drop the other model's still-unsent edits.` && |\n| &&
             `      oModel._z2ui5ChangedPaths = new Set();` && |\n| &&
             `      oModel.attachPropertyChange((e) => {` && |\n| &&
             `        const params = e.getParameters();` && |\n| &&
             `        const raw = params.path;` && |\n| &&
             `        const ctx = params.context;` && |\n| &&
             `        if (!raw) return;` && |\n| &&
             `        // Resolve relative paths against the binding context.` && |\n| &&
             `        const changedPath =` && |\n| &&
             `          ctx && !raw.startsWith("/") ? ``${ctx.getPath()}/${raw}`` : raw;` && |\n| &&
             `        if (changedPath.startsWith("/")) {` && |\n| &&
             `          oModel._z2ui5ChangedPaths.add(changedPath);` && |\n| &&
             `        }` && |\n| &&
             `      });` && |\n| &&
             `      return oModel;` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // The framework-owned JSON model on a slot's view: the DEFAULT model` && |\n| &&
             `    // normally, but the NAMED "http" model when SWITCH_DEFAULT_MODEL_PATH put` && |\n| &&
             `    // an OData model in the default slot. Returns undefined when neither model` && |\n| &&
             `    // is ours (marked by _z2ui5Tracked).` && |\n| &&
             `    function resolveTrackedModel(oView) {` && |\n| &&
             `      const isOurs = (m) => (m?._z2ui5Tracked ? m : undefined);` && |\n| &&
             `      return isOurs(oView.getModel()) ?? isOurs(oView.getModel("http"));` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function createViewModel() {` && |\n| &&
             `      const data = AppState.state.oResponse?.OVIEWMODEL;` && |\n| &&
             `      return trackChanges(new JSONModel(data));` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // True when this response was superseded by a newer request while an` && |\n| &&
             `    // async view build was awaiting (undefined seq = no check, for callers` && |\n| &&
             `    // outside the system-action phase).` && |\n| &&
             `    function isSuperseded(seq) {` && |\n| &&
             `      return seq !== undefined && seq !== Server._requestSeq;` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // ------------------------------------------------------------------` && |\n| &&
             `    // Display: popups, popovers, nested views, main view` && |\n| &&
             `    // ------------------------------------------------------------------` && |\n| &&
             `` && |\n| &&
             `    // Shared load path of the two fragment slots (popup, popover): create` && |\n| &&
             `    // the slot's own JSON model, load the fragment and attach the model.` && |\n| &&
             `    // Returns null when the app was torn down while the fragment loaded or a` && |\n| &&
             `    // newer request superseded this response - we must not open a dialog the` && |\n| &&
             `    // backend no longer knows about.` && |\n| &&
             `    async function loadSlotFragment(slotKey, fragmentId, xml, seq) {` && |\n| &&
             `      const oModel = createViewModel();` && |\n| &&
             `      applyStoredSizeLimit(slotKey, oModel);` && |\n| &&
             `      const oFragment = await Fragment.load({` && |\n| &&
             `        definition: xml,` && |\n| &&
             `        controller: ViewSlots.getController(slotKey),` && |\n| &&
             `        id: fragmentId,` && |\n| &&
             `      });` && |\n| &&
             `      if (!Lib.isAlive(AppState.state.oApp) || isSuperseded(seq)) {` && |\n| &&
             `        oFragment.destroy();` && |\n| &&
             `        return null;` && |\n| &&
             `      }` && |\n| &&
             `      oFragment.setModel(oModel);` && |\n| &&
             `      return oFragment;` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    async function displayFragment(xml, seq) {` && |\n| &&
             `      const oFragment = await loadSlotFragment("POPUP", "popupId", xml, seq);` && |\n| &&
             `      if (!oFragment) return;` && |\n| &&
             `      // The shared device + message models are attached inside` && |\n| &&
             `      // ViewSlots.setView (the single funnel), so error paths that` && |\n| &&
             `      // destroy a view without reaching setView never register it.` && |\n| &&
             `      ViewSlots.setView("POPUP", oFragment);` && |\n| &&
             `      oFragment.open();` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    async function displayPopover(xml, openById, seq) {` && |\n| &&
             `      // No catch-all here on purpose: a malformed-XML load or render` && |\n| &&
             `      // failure must propagate to _processAfterRendering and surface the` && |\n| &&
             `      // fatal "App Terminated" overlay, exactly like displayFragment and` && |\n| &&
             `      // displayNestedView. The explicit returns below stay graceful - they` && |\n| &&
             `      // handle expected, non-error conditions (app torn down mid-load, or` && |\n| &&
             `      // the openBy anchor not being present), matching the parent-not-found` && |\n| &&
             `      // guard in displayNestedView.` && |\n| &&
             `      const oFragment = await loadSlotFragment(` && |\n| &&
             `        "POPOVER",` && |\n| &&
             `        "popoverId",` && |\n| &&
             `        xml,` && |\n| &&
             `        seq,` && |\n| &&
             `      );` && |\n| &&
             `      if (!oFragment) return;` && |\n| &&
             `` && |\n| &&
             `      // Find the control to attach the popover to: any open slot first,` && |\n| &&
             `      // then the global UI5 control registry as a last resort.` && |\n| &&
             `      const oControl = ViewSlots.resolveById(openById);` && |\n| &&
             `` && |\n| &&
             `      if (!oControl) {` && |\n| &&
             `        Lib.logError(``displayPopover: openBy control '${openById}' not found``);` && |\n| &&
             `        oFragment.destroy();` && |\n| &&
             `        return;` && |\n| &&
             `      }` && |\n| &&
             `      ViewSlots.setView("POPOVER", oFragment);` && |\n| &&
             `      oFragment.openBy(oControl);` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    async function displayNestedView(xml, slotKey, mOptions, seq) {` && |\n| &&
             `      // Nested views do NOT create their own model. They are inserted into` && |\n| &&
             `      // the MAIN control tree below and inherit its default JSON model via` && |\n| &&
             `      // UI5 model propagation, so every view binds against the same data with` && |\n| &&
             `      // one change tracker and one refresh per roundtrip - no duplicate` && |\n| &&
             `      // models pointing at the same data. The model passed to the XML` && |\n| &&
             `      // preprocessor here only feeds {template>...} bindings at build time;` && |\n| &&
             `      // it is the MAIN view's JSON model (the named "http" model when` && |\n| &&
             `      // SWITCH_DEFAULT_MODEL_PATH moved OData into the default slot, otherwise` && |\n| &&
             `      // the default model), mirroring displayView's template model.` && |\n| &&
             `      const oMainView = ViewSlots.getView("MAIN");` && |\n| &&
             `      const oTemplateModel =` && |\n| &&
             `        oMainView?.getModel("http") ?? oMainView?.getModel();` && |\n| &&
             `      const oView = await XMLView.create({` && |\n| &&
             `        definition: xml,` && |\n| &&
             `        controller: ViewSlots.getController(slotKey),` && |\n| &&
             `        preprocessors: { xml: { models: { template: oTemplateModel } } },` && |\n| &&
             `      });` && |\n| &&
             `` && |\n| &&
             `      if (!Lib.isAlive(AppState.state.oApp) || isSuperseded(seq)) {` && |\n| &&
             `        oView.destroy();` && |\n| &&
             `        return;` && |\n| &&
             `      }` && |\n| &&
             `` && |\n| &&
             `      // The options travel with the action that carries the XML, so they` && |\n| &&
             `      // always belong to the same response - there is no live global to` && |\n| &&
             `      // re-read and no way to mix this response's view with a newer` && |\n| &&
             `      // response's parent id and insert/destroy methods.` && |\n| &&
             `      const {` && |\n| &&
             `        id: ID,` && |\n| &&
             `        methodDestroy: METHOD_DESTROY,` && |\n| &&
             `        methodInsert: METHOD_INSERT,` && |\n| &&
             `      } = mOptions;` && |\n| &&
             `` && |\n| &&
             `      const oParent = ViewSlots.byId("MAIN", ID);` && |\n| &&
             `      if (!oParent) {` && |\n| &&
             `        Lib.logError(` && |\n| &&
             `          ``displayNestedView: parent control '${ID}' not found, nested view discarded``,` && |\n| &&
             `        );` && |\n| &&
             `        oView.destroy();` && |\n| &&
             `        return;` && |\n| &&
             `      }` && |\n| &&
             `` && |\n| &&
             `      // METHOD_DESTROY is optional: only call it when the app asked for a` && |\n| &&
             `      // parent teardown method. An empty value used to reach oParent[""]()` && |\n| &&
             `      // and throw on every render (e.g. app 065 passes only method_insert).` && |\n| &&
             `      if (METHOD_DESTROY) {` && |\n| &&
             `        try {` && |\n| &&
             `          oParent[METHOD_DESTROY]();` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          Lib.logError(` && |\n| &&
             `            ``displayNestedView: parent destroy method '${METHOD_DESTROY}' failed``,` && |\n| &&
             `            e,` && |\n| &&
             `          );` && |\n| &&
             `        }` && |\n| &&
             `      }` && |\n| &&
             `      try {` && |\n| &&
             `        oParent[METHOD_INSERT](oView);` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        Lib.logError("displayNestedView: parent insert method failed", e);` && |\n| &&
             `        oView.destroy();` && |\n| &&
             `        return;` && |\n| &&
             `      }` && |\n| &&
             `      ViewSlots.setView(slotKey, oView);` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // Replace the main app view with the XML coming from the backend.` && |\n| &&
             `    async function displayView(xml, viewModel, reqSeq, mOptions = {}) {` && |\n| &&
             `      const oViewModel = trackChanges(new JSONModel(viewModel));` && |\n| &&
             `` && |\n| &&
             `      const switchPath = mOptions.switchDefaultModelPath;` && |\n| &&
             `` && |\n| &&
             `      // When the app wants OData as the default model, build it here and` && |\n| &&
             `      // keep the JSON model as the named "http" model.` && |\n| &&
             `      let oModel;` && |\n| &&
             `      if (switchPath) {` && |\n| &&
             `        oModel = new ODataModel({` && |\n| &&
             `          serviceUrl: switchPath,` && |\n| &&
             `          annotationURI: mOptions.switchDefaultModelAnnoUri || "",` && |\n| &&
             `        });` && |\n| &&
             `      } else {` && |\n| &&
             `        oModel = oViewModel;` && |\n| &&
             `      }` && |\n| &&
             `      applyStoredSizeLimit("MAIN", oModel);` && |\n| &&
             `` && |\n| &&
             `      const oView = await XMLView.create({` && |\n| &&
             `        definition: xml,` && |\n| &&
             `        models: oModel,` && |\n| &&
             `        controller: ViewSlots.getController("MAIN"),` && |\n| &&
             `        id: "mainView",` && |\n| &&
             `        preprocessors: { xml: { models: { template: oViewModel } } },` && |\n| &&
             `      });` && |\n| &&
             `` && |\n| &&
             `      // oModel covers oViewModel too when they are the same object (no` && |\n| &&
             `      // switchPath); with an OData default model both must go.` && |\n| &&
             `      const discardBuild = () => {` && |\n| &&
             `        oView.destroy();` && |\n| &&
             `        oModel.destroy();` && |\n| &&
             `        if (switchPath) oViewModel.destroy();` && |\n| &&
             `      };` && |\n| &&
             `` && |\n| &&
             `      // Guard against the app being destroyed during the await above.` && |\n| &&
             `      if (!Lib.isAlive(AppState.state.oApp)) {` && |\n| &&
             `        discardBuild();` && |\n| &&
             `        return;` && |\n| &&
             `      }` && |\n| &&
             `` && |\n| &&
             `      // A newer parallel request (check_allow_multi_req) superseded this one` && |\n| &&
             `      // while XMLView.create was awaiting - discard this rebuild instead of` && |\n| &&
             `      // letting an out-of-order resolve overwrite the newer view. Last-write` && |\n| &&
             `      // wins by request order, not by which create() happened to resolve last.` && |\n| &&
             `      // Only discard when a newer view actually took the slot: if the` && |\n| &&
             `      // superseding response was data-only, dropping this build too would` && |\n| &&
             `      // leave the app permanently blank - a slightly stale view is the` && |\n| &&
             `      // better outcome then.` && |\n| &&
             `      if (isSuperseded(reqSeq) && ViewSlots.getView("MAIN")) {` && |\n| &&
             `        discardBuild();` && |\n| &&
             `        return;` && |\n| &&
             `      }` && |\n| &&
             `` && |\n| &&
             `      ViewSlots.setView("MAIN", oView);` && |\n| &&
             `      if (switchPath) oView.setModel(oViewModel, "http");` && |\n| &&
             `      AppState.state.oApp.removeAllPages();` && |\n| &&
             `      AppState.state.oApp.insertPage(oView);` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // The MAIN rebuild is the one display that cannot simply run: it is` && |\n| &&
             `    // serialized through Server._viewBuild because XMLView.create claims` && |\n| &&
             `    // the fixed "mainView" id synchronously, so two overlapping builds` && |\n| &&
             `    // (a slow library load plus a parallel/multi-req response) would throw` && |\n| &&
             `    // "duplicate id". Each queued build re-checks that it has not been` && |\n| &&
             `    // superseded before it starts.` && |\n| &&
             `    function displayMain(xml, mOptions, seq) {` && |\n| &&
             `      Server._viewBuild = Promise.resolve(Server._viewBuild)` && |\n| &&
             `        .catch(() => {})` && |\n| &&
             `        .then(() => {` && |\n| &&
             `          if (isSuperseded(seq)) {` && |\n| &&
             `            return undefined;` && |\n| &&
             `          }` && |\n| &&
             `          return displayView(` && |\n| &&
             `            xml,` && |\n| &&
             `            AppState.state.oResponse?.OVIEWMODEL,` && |\n| &&
             `            seq,` && |\n| &&
             `            mOptions,` && |\n| &&
             `          );` && |\n| &&
             `        });` && |\n| &&
             `      return Server._viewBuild;` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // Push the response's model into one slot, if it is open at all.` && |\n| &&
             `    function updateModelIfRequired(slotKey) {` && |\n| &&
             `      const oView = ViewSlots.getView(slotKey);` && |\n| &&
             `      if (!oView) return;` && |\n| &&
             `` && |\n| &&
             `      // Reuse the existing model whenever it is ours: setData() keeps the` && |\n| &&
             `      // view's bindings alive and only refreshes what changed, while a new` && |\n| &&
             `      // model + setModel() destroys and recreates every binding - measured` && |\n| &&
             `      // ~3x slower with all values changed and ~150x slower when little` && |\n| &&
             `      // changed (see node/tests-examples/modelUpdate.bench.spec.js).` && |\n| &&
             `      // Never overwrite an OData default (switch mode) with a fresh JSON model.` && |\n| &&
             `      const tracked = resolveTrackedModel(oView);` && |\n| &&
             `      if (tracked) {` && |\n| &&
             `        applyStoredSizeLimit(slotKey, tracked);` && |\n| &&
             `        tracked.setData(AppState.state.oResponse?.OVIEWMODEL);` && |\n| &&
             `        return;` && |\n| &&
             `      }` && |\n| &&
             `` && |\n| &&
             `      // No framework-owned model on this slot at all: bind a fresh default` && |\n| &&
             `      // JSON model (keeps the previous behavior for that edge case).` && |\n| &&
             `      const oModel = createViewModel();` && |\n| &&
             `      applyStoredSizeLimit(slotKey, oModel);` && |\n| &&
             `      oView.setModel(oModel);` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // The one entry point of the VIEW_SLOTS action target (wired in` && |\n| &&
             `    // actions/ControlCall's GLOBAL_TARGETS). destroy is ViewSlots' own` && |\n| &&
             `    // method; display and updateModel live here, because loading a fragment` && |\n| &&
             `    // and owning the model is this module's job. ``seq`` is the stamp of the` && |\n| &&
             `    // request the processed response belongs to, threaded through the action` && |\n| &&
             `    // context (FrontendAction.runSystem) - a display superseded by a newer` && |\n| &&
             `    // request discards its build instead of overwriting the newer view.` && |\n| &&
             `    function action(oController, method, slotKey, xml, mOptions, seq) {` && |\n| &&
             `      if (method === "destroy") {` && |\n| &&
             `        ViewSlots.destroy(slotKey);` && |\n| &&
             `        return undefined;` && |\n| &&
             `      }` && |\n| &&
             `      if (method === "updateModel") {` && |\n| &&
             `        // no slot is named - push into every OPEN slot that carries a` && |\n| &&
             `        // model of its own` && |\n| &&
             `        for (const slot of ViewSlots.slots) {` && |\n| &&
             `          if (slot.ownsModel) updateModelIfRequired(slot.key);` && |\n| &&
             `        }` && |\n| &&
             `        return undefined;` && |\n| &&
             `      }` && |\n| &&
             `      // display. The teardown of whatever the slot held is its own action` && |\n| &&
             `      // and has already run, so there is nothing to decide here either -` && |\n| &&
             `      // only which loader the slot uses.` && |\n| &&
             `      if (slotKey === "MAIN") return displayMain(xml, mOptions, seq);` && |\n| &&
             `      if (slotKey === "POPUP") return displayFragment(xml, seq);` && |\n| &&
             `      if (slotKey === "POPOVER") {` && |\n| &&
             `        return displayPopover(xml, mOptions.openById, seq);` && |\n| &&
             `      }` && |\n| &&
             `      return displayNestedView(xml, slotKey, mOptions, seq);` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    return {` && |\n| &&
             `      action,` && |\n| &&
             `      trackChanges,` && |\n| &&
             `      resolveTrackedModel,` && |\n| &&
             `      updateModelIfRequired,` && |\n| &&
             `      displayView,` && |\n| &&
             `      displayFragment,` && |\n| &&
             `      displayPopover,` && |\n| &&
             `      displayNestedView,` && |\n| &&
             `    };` && |\n| &&
             `  },` && |\n| &&
             `);` && |\n| &&
             `` && |\n| &&
              ``.

  ENDMETHOD.

ENDCLASS.
