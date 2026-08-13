* =====================================================================
* GENERATED FILE - DO NOT EDIT (AGENTS.md rule 2)
* Embedded frontend resource, generated from app/webapp/ by
* .github/app2abap/trans2abap.js. Change the source under app/webapp/
* and run 'npm run app2abap' to regenerate; the check_app2abap CI gate
* fails any manual edit here.
* =====================================================================
CLASS z2ui5_cl_ui5f_variants_js DEFINITION
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


CLASS z2ui5_cl_ui5f_variants_js IMPLEMENTATION.

  METHOD get.

    result = `sap.ui.define(["z2ui5/core/Lib", "z2ui5/core/ViewSlots"], (Lib, ViewSlots) => {` && |\n| &&
             `  "use strict";` && |\n| &&
             `` && |\n| &&
             `  // ------------------------------------------------------------------` && |\n| &&
             `  // sap.ui.comp variant management wiring - the two initialisation` && |\n| &&
             `  // actions that place what only an app controller would otherwise set:` && |\n| &&
             `  // SMART_VARIANT_INIT anchors the personalizable control a` && |\n| &&
             `  // SmartVariantManagement works against, FILTER_BAR_VARIANT_INIT wires a` && |\n| &&
             `  // classic FilterBar's variant callbacks. Everything here is` && |\n| &&
             `  // load-order-sensitive; see the per-function comments.` && |\n| &&
             `  // ------------------------------------------------------------------` && |\n| &&
             `` && |\n| &&
             `  // SMART_VARIANT_INIT waits for the smart controls to register themselves at` && |\n| &&
             `  // the SmartVariantManagement - that happens once their OData metadata has` && |\n| &&
             `  // loaded, so the wait has to survive a slow service (5s) but must not run` && |\n| &&
             `  // forever when no smart control is there at all.` && |\n| &&
             `  const SMART_VARIANT_INIT_TRIES = 50;` && |\n| &&
             `  const SMART_VARIANT_INIT_DELAY = 100;` && |\n| &&
             `` && |\n| &&
             `  // The anchor. setPersControler() is sap.ui.comp's own setter and does` && |\n| &&
             `  // more than assign the field: it also creates the control promise that` && |\n| &&
             `  // initialise() insists on. A page variant never gets that call -` && |\n| &&
             `  // addPersonalizableControl() returns early for isPageVariant() and only` && |\n| &&
             `  // the single-control case reaches setPersControler() - which is exactly` && |\n| &&
             `  // why a controller-less app ends up with no anchor and no promise.` && |\n| &&
             `  function anchorPersoControl(oSVM, target) {` && |\n| &&
             `    // a runtime that anchors the control itself is left alone` && |\n| &&
             `    if (oSVM._oPersoControl) return;` && |\n| &&
             `    if (typeof oSVM.setPersControler === "function") {` && |\n| &&
             `      oSVM.setPersControler(target);` && |\n| &&
             `    } else {` && |\n| &&
             `      // older runtimes without the setter: the field alone still carries` && |\n| &&
             `      // the write path (saving), which is better than nothing` && |\n| &&
             `      oSVM._oPersoControl = target;` && |\n| &&
             `    }` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  // With the anchor in place the load flow still has to be started once.` && |\n| &&
             `  // A smart control does that itself when it registers - but only then,` && |\n| &&
             `  // and it may already have tried (and aborted) before the anchor existed.` && |\n| &&
             `  // So wait for the control's wrapper and initialise it if nobody has:` && |\n| &&
             `  // a wrapper is required (initialise answers "unknown control" without` && |\n| &&
             `  // one) and an initialised wrapper must be left alone ("already executed").` && |\n| &&
             `  function ensureInitialised(oSVM, target, attempt, fnCallback) {` && |\n| &&
             `    if (Lib.isDestroyed(oSVM)) return;` && |\n| &&
             `    const wrapper = oSVM._getControlWrapper` && |\n| &&
             `      ? oSVM._getControlWrapper(target)` && |\n| &&
             `      : null;` && |\n| &&
             `    if (!wrapper) {` && |\n| &&
             `      if (attempt < SMART_VARIANT_INIT_TRIES) {` && |\n| &&
             `        setTimeout(` && |\n| &&
             `          () => ensureInitialised(oSVM, target, attempt + 1, fnCallback),` && |\n| &&
             `          SMART_VARIANT_INIT_DELAY,` && |\n| &&
             `        );` && |\n| &&
             `      }` && |\n| &&
             `      return;` && |\n| &&
             `    }` && |\n| &&
             `    if (wrapper.bInitialized) return;` && |\n| &&
             `    oSVM.initialise(fnCallback || (() => {}), target);` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  // SMART_VARIANT_INIT: place the anchor sap.ui.comp variant management needs` && |\n| &&
             `  // and that only an app controller would otherwise set - the personalizable` && |\n| &&
             `  // control the SmartVariantManagement works against (_oPersoControl).` && |\n| &&
             `  // args = [_, svmId, controlId?].` && |\n| &&
             `  //` && |\n| &&
             `  // Why an anchor and not a call: SmartVariantManagement.initialise(fn, control)` && |\n| &&
             `  // aborts its load flow when ``_oPersoControl`` is missing ("no personalizable` && |\n| &&
             `  // component available") and marks that control's wrapper as done - a second` && |\n| &&
             `  // call answers "already executed". The smart controls call initialise on` && |\n| &&
             `  // themselves as soon as their metadata arrives, so an anchor set too late` && |\n| &&
             `  // buys nothing: saving works (it only reads the field) but stored variants` && |\n| &&
             `  // are never loaded. Hence: set the field as EARLY as the control exists, and` && |\n| &&
             `  // leave the initialise call to the smart control, which then finds the` && |\n| &&
             `  // anchor in place. Only when no control id was given does this wait for the` && |\n| &&
             `  // registration list and call initialise itself (nobody else will).` && |\n| &&
             `  function evSmartVariantInit(oController, args) {` && |\n| &&
             `    const [, svmId, controlId] = args;` && |\n| &&
             `    let tries = 0;` && |\n| &&
             `    const run = () => {` && |\n| &&
             `      const oSVM = ViewSlots.resolveById(svmId);` && |\n| &&
             `      const control = controlId ? ViewSlots.resolveById(controlId) : null;` && |\n| &&
             `      if (!oSVM || (controlId && !control)) {` && |\n| &&
             `        // the view may still be building - wait for both controls to exist` && |\n| &&
             `        if (tries++ < SMART_VARIANT_INIT_TRIES) {` && |\n| &&
             `          setTimeout(run, SMART_VARIANT_INIT_DELAY);` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `        Lib.logError(` && |\n| &&
             `          ``SMART_VARIANT_INIT: '${controlId ? ``${svmId}' / '${controlId}`` : svmId}' not found``,` && |\n| &&
             `        );` && |\n| &&
             `        return;` && |\n| &&
             `      }` && |\n| &&
             `      if (Lib.isDestroyed(oSVM) || typeof oSVM.initialise !== "function") {` && |\n| &&
             `        Lib.logError(` && |\n| &&
             `          ``SMART_VARIANT_INIT: no SmartVariantManagement for id '${svmId}'``,` && |\n| &&
             `        );` && |\n| &&
             `        return;` && |\n| &&
             `      }` && |\n| &&
             `      let target = control;` && |\n| &&
             `      if (!target) {` && |\n| &&
             `        // no control named: fall back to the first one that registered, which` && |\n| &&
             `        // means waiting for that registration (it follows the metadata load)` && |\n| &&
             `        const registered = oSVM.getPersonalizableControls` && |\n| &&
             `          ? oSVM.getPersonalizableControls()` && |\n| &&
             `          : [];` && |\n| &&
             `        if (!registered.length) {` && |\n| &&
             `          if (tries++ < SMART_VARIANT_INIT_TRIES) {` && |\n| &&
             `            setTimeout(run, SMART_VARIANT_INIT_DELAY);` && |\n| &&
             `            return;` && |\n| &&
             `          }` && |\n| &&
             `          Lib.logError(` && |\n| &&
             `            ``SMART_VARIANT_INIT: no personalizable control registered at '${svmId}'``,` && |\n| &&
             `          );` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `        target = ViewSlots.resolveById(registered[0].getControl());` && |\n| &&
             `        if (!target) return;` && |\n| &&
             `      }` && |\n| &&
             `      anchorPersoControl(oSVM, target);` && |\n| &&
             `      ensureInitialised(oSVM, target, 0);` && |\n| &&
             `    };` && |\n| &&
             `` && |\n| &&
             `    run();` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  // ------------------------------------------------------------------` && |\n| &&
             `  // FILTER_BAR_VARIANT_INIT: wire a CLASSIC sap.ui.comp.filterbar.FilterBar` && |\n| &&
             `  // to a SmartVariantManagement. args = [_, svmId, filterBarId].` && |\n| &&
             `  //` && |\n| &&
             `  // A SmartFilterBar registers itself at the variant management (it knows its` && |\n| &&
             `  // fields from the OData metadata), so SMART_VARIANT_INIT above only has to` && |\n| &&
             `  // place the anchor. A classic FilterBar knows nothing about variants: every` && |\n| &&
             `  // list-report controller hand-writes the same three callbacks` && |\n| &&
             `  // (registerFetchData / registerApplyData / registerGetFiltersWithValues),` && |\n| &&
             `  // adds a PersonalizableInfo and marks the variant dirty on each filter` && |\n| &&
             `  // change. That is boilerplate over the bar's own filter items - data, not` && |\n| &&
             `  // app logic - so the framework owns it and the app needs no JavaScript.` && |\n| &&
             `  // ------------------------------------------------------------------` && |\n| &&
             `` && |\n| &&
             `  // marker so a re-sent action cannot stack a second set of callbacks and` && |\n| &&
             `  // change handlers on the same bar (a rebuilt view reuses the ids, but it` && |\n| &&
             `  // builds NEW control instances, which arrive here unmarked)` && |\n| &&
             `  const FILTER_BAR_WIRED = "_z2ui5FilterBarVariantWired";` && |\n| &&
             `` && |\n| &&
             `  function filterItemControl(item) {` && |\n| &&
             `    return item && typeof item.getControl === "function"` && |\n| &&
             `      ? item.getControl()` && |\n| &&
             `      : null;` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  function filterItemValue(item) {` && |\n| &&
             `    const control = filterItemControl(item);` && |\n| &&
             `    return control && typeof control.getValue === "function"` && |\n| &&
             `      ? control.getValue()` && |\n| &&
             `      : "";` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  // what a variant stores, how it is put back, and which filters count as` && |\n| &&
             `  // "assigned" for the bar's own summary text` && |\n| &&
             `  function registerFilterBarCallbacks(oFilterBar) {` && |\n| &&
             `    oFilterBar.registerFetchData(() =>` && |\n| &&
             `      oFilterBar.getAllFilterItems().map((item) => ({` && |\n| &&
             `        groupName: item.getGroupName(),` && |\n| &&
             `        fieldName: item.getName(),` && |\n| &&
             `        fieldData: filterItemValue(item),` && |\n| &&
             `      })),` && |\n| &&
             `    );` && |\n| &&
             `    oFilterBar.registerApplyData((data) => {` && |\n| &&
             `      (data || []).forEach((entry) => {` && |\n| &&
             `        const control = oFilterBar.determineControlByName(` && |\n| &&
             `          entry.fieldName,` && |\n| &&
             `          entry.groupName,` && |\n| &&
             `        );` && |\n| &&
             `        // setValue, not a model write: the two-way binding abap2UI5 put on` && |\n| &&
             `        // the property carries the restored value back to the backend on the` && |\n| &&
             `        // next roundtrip, so selecting a variant needs none of its own` && |\n| &&
             `        if (control && typeof control.setValue === "function") {` && |\n| &&
             `          control.setValue(entry.fieldData);` && |\n| &&
             `        }` && |\n| &&
             `      });` && |\n| &&
             `    });` && |\n| &&
             `    oFilterBar.registerGetFiltersWithValues(() =>` && |\n| &&
             `      oFilterBar` && |\n| &&
             `        .getFilterGroupItems()` && |\n| &&
             `        .filter((item) => String(filterItemValue(item)).length > 0),` && |\n| &&
             `    );` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  // every filter change makes the current variant dirty (the "*" next to the` && |\n| &&
             `  // variant title) and refreshes the bar's assigned-filters summary` && |\n| &&
             `  function attachFilterBarChange(oSVM, oFilterBar) {` && |\n| &&
             `    oFilterBar.getAllFilterItems().forEach((item) => {` && |\n| &&
             `      const control = filterItemControl(item);` && |\n| &&
             `      if (!control || typeof control.attachChange !== "function") return;` && |\n| &&
             `      control.attachChange((oEvent) => {` && |\n| &&
             `        if (typeof oSVM.currentVariantSetModified === "function") {` && |\n| &&
             `          oSVM.currentVariantSetModified(true);` && |\n| &&
             `        }` && |\n| &&
             `        if (typeof oFilterBar.fireFilterChange === "function") {` && |\n| &&
             `          oFilterBar.fireFilterChange(oEvent);` && |\n| &&
             `        }` && |\n| &&
             `      });` && |\n| &&
             `    });` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  // sap.ui.comp is SAPUI5-only, so PersonalizableInfo must never be a hard` && |\n| &&
             `  // dependency of this file (it 404s on OpenUI5 and would kill the component` && |\n| &&
             `  // load). Resolve it at call time: synchronously when the SmartVariant-` && |\n| &&
             `  // Management already pulled it in, asynchronously otherwise.` && |\n| &&
             `  function withPersonalizableInfo(callback) {` && |\n| &&
             `    const name = "sap/ui/comp/smartvariants/PersonalizableInfo";` && |\n| &&
             `    /* ui5lint-disable no-globals --` && |\n| &&
             `       the guard has to read the global sap.ui itself: the point of this` && |\n| &&
             `       function is to load a module that must NOT be a declared dependency` && |\n| &&
             `       (sap.ui.comp is SAPUI5-only and 404s on OpenUI5), so sap.ui.require is` && |\n| &&
             `       the only entry point and there is no injected equivalent to probe. */` && |\n| &&
             `    if (` && |\n| &&
             `      typeof sap === "undefined" ||` && |\n| &&
             `      !sap.ui ||` && |\n| &&
             `      typeof sap.ui.require !== "function"` && |\n| &&
             `    ) {` && |\n| &&
             `      Lib.logError("FILTER_BAR_VARIANT_INIT: sap.ui.require not available");` && |\n| &&
             `      return;` && |\n| &&
             `    }` && |\n| &&
             `    const loaded = sap.ui.require(name);` && |\n| &&
             `    if (loaded) {` && |\n| &&
             `      callback(loaded);` && |\n| &&
             `      return;` && |\n| &&
             `    }` && |\n| &&
             `    sap.ui.require([name], callback, () =>` && |\n| &&
             `      Lib.logError(` && |\n| &&
             `        "FILTER_BAR_VARIANT_INIT: sap.ui.comp.smartvariants not available",` && |\n| &&
             `      ),` && |\n| &&
             `    );` && |\n| &&
             `    /* ui5lint-enable no-globals */` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  function evFilterBarVariantInit(oController, args) {` && |\n| &&
             `    const [, svmId, filterBarId] = args;` && |\n| &&
             `    let tries = 0;` && |\n| &&
             `    const run = () => {` && |\n| &&
             `      const oSVM = ViewSlots.resolveById(svmId);` && |\n| &&
             `      const oFilterBar = ViewSlots.resolveById(filterBarId);` && |\n| &&
             `      if (!oSVM || !oFilterBar) {` && |\n| &&
             `        // the view may still be building - wait for both controls to exist` && |\n| &&
             `        if (tries++ < SMART_VARIANT_INIT_TRIES) {` && |\n| &&
             `          setTimeout(run, SMART_VARIANT_INIT_DELAY);` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `        Lib.logError(` && |\n| &&
             `          ``FILTER_BAR_VARIANT_INIT: '${svmId}' / '${filterBarId}' not found``,` && |\n| &&
             `        );` && |\n| &&
             `        return;` && |\n| &&
             `      }` && |\n| &&
             `      if (` && |\n| &&
             `        Lib.isDestroyed(oSVM) ||` && |\n| &&
             `        typeof oSVM.addPersonalizableControl !== "function"` && |\n| &&
             `      ) {` && |\n| &&
             `        Lib.logError(` && |\n| &&
             `          ``FILTER_BAR_VARIANT_INIT: no SmartVariantManagement for id '${svmId}'``,` && |\n| &&
             `        );` && |\n| &&
             `        return;` && |\n| &&
             `      }` && |\n| &&
             `      if (typeof oFilterBar.registerFetchData !== "function") {` && |\n| &&
             `        Lib.logError(` && |\n| &&
             `          ``FILTER_BAR_VARIANT_INIT: no FilterBar for id '${filterBarId}'``,` && |\n| &&
             `        );` && |\n| &&
             `        return;` && |\n| &&
             `      }` && |\n| &&
             `      if (oFilterBar[FILTER_BAR_WIRED]) return;` && |\n| &&
             `      oFilterBar[FILTER_BAR_WIRED] = true;` && |\n| &&
             `` && |\n| &&
             `      registerFilterBarCallbacks(oFilterBar);` && |\n| &&
             `      attachFilterBarChange(oSVM, oFilterBar);` && |\n| &&
             `      withPersonalizableInfo((PersonalizableInfo) => {` && |\n| &&
             `        oSVM.addPersonalizableControl(` && |\n| &&
             `          new PersonalizableInfo({` && |\n| &&
             `            type: "filterBar",` && |\n| &&
             `            keyName: "persistencyKey",` && |\n| &&
             `            dataSource: "",` && |\n| &&
             `            control: oFilterBar,` && |\n| &&
             `          }),` && |\n| &&
             `        );` && |\n| &&
             `        anchorPersoControl(oSVM, oFilterBar);` && |\n| &&
             `        // the load flow ends in registerApplyData, so the bar is clean again` && |\n| &&
             `        // right after it - drop the "*" the restored values would leave` && |\n| &&
             `        ensureInitialised(oSVM, oFilterBar, 0, () => {` && |\n| &&
             `          if (typeof oSVM.currentVariantSetModified === "function") {` && |\n| &&
             `            oSVM.currentVariantSetModified(false);` && |\n| &&
             `          }` && |\n| &&
             `        });` && |\n| &&
             `      });` && |\n| &&
             `    };` && |\n| &&
             `` && |\n| &&
             `    run();` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  // The events this module owns in the eF dispatch (see` && |\n| &&
             `  // core/FrontendAction.js, which merges the domain modules' handler maps).` && |\n| &&
             `  const handlers = {` && |\n| &&
             `    SMART_VARIANT_INIT: evSmartVariantInit,` && |\n| &&
             `    FILTER_BAR_VARIANT_INIT: evFilterBarVariantInit,` && |\n| &&
             `  };` && |\n| &&
             `` && |\n| &&
             `  return { handlers };` && |\n| &&
             `});` && |\n| &&
             `` && |\n| &&
              ``.

  ENDMETHOD.

ENDCLASS.
