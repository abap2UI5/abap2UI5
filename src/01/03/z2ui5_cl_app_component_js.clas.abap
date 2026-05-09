CLASS z2ui5_cl_app_component_js DEFINITION
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


CLASS z2ui5_cl_app_component_js IMPLEMENTATION.

  METHOD get.

    result = `// Shared utility module — registered first so that consumers (Server, DebugTool,` && |\n| &&
             `// View1.controller, App.controller) can declare 'z2ui5/cc/Util' as an AMD dependency.` && |\n| &&
             `// Component.js is the entry point, so this define block is parsed before any other` && |\n| &&
             `// abap2UI5 module is fetched, which guarantees the registry is populated in time.` && |\n| &&
             `sap.ui.define('z2ui5/cc/Util', [], () => {` && |\n| &&
             `  'use strict';` && |\n| &&
             `` && |\n| &&
             `  const ERRORS_CAP = 200;` && |\n| &&
             `` && |\n| &&
             `  const logError = (message, error) => {` && |\n| &&
             `    const entry = { message, ts: new Date().toISOString() };` && |\n| &&
             `    if (error !== undefined) entry.error = error;` && |\n| &&
             `    // Defensive: re-create z2ui5.errors if it has been clobbered with a non-array` && |\n| &&
             `    if (!Array.isArray(z2ui5.errors)) z2ui5.errors = [];` && |\n| &&
             `    const arr = z2ui5.errors;` && |\n| &&
             `    arr.push(entry);` && |\n| &&
             `    // Single splice trims any overflow in one shot (cap the rolling log)` && |\n| &&
             `    if (arr.length > ERRORS_CAP) arr.splice(0, arr.length - ERRORS_CAP);` && |\n| &&
             `  };` && |\n| &&
             `` && |\n| &&
             `  // Push a callback onto one of the z2ui5.onXxx arrays, recreating the array if the` && |\n| &&
             `  // global has been clobbered with a non-array (??= alone would not detect that).` && |\n| &&
             `  const registerCallback = (key, fn) => {` && |\n| &&
             `    if (!Array.isArray(z2ui5[key])) z2ui5[key] = [];` && |\n| &&
             `    z2ui5[key].push(fn);` && |\n| &&
             `  };` && |\n| &&
             `` && |\n| &&
             `  // Remove a callback without crashing if the array has been clobbered` && |\n| &&
             `  const unregisterCallback = (key, fn) => {` && |\n| &&
             `    z2ui5[key] = Array.isArray(z2ui5[key]) ? z2ui5[key].filter((cb) => cb !== fn) : [];` && |\n| &&
             `  };` && |\n| &&
             `` && |\n| &&
             `  // Run each callback in ``arr`` with ``args``, swallowing per-callback errors so a single` && |\n| &&
             `  // bad callback does not break the iteration over the rest.` && |\n| &&
             `  const runCallbacks = (arr, ...args) => {` && |\n| &&
             `    if (!Array.isArray(arr)) return;` && |\n| &&
             `    for (const fn of arr) {` && |\n| &&
             `      try {` && |\n| &&
             `        fn?.(...args);` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        logError(``runCallbacks: callback failed``, e);` && |\n| &&
             `      }` && |\n| &&
             `    }` && |\n| &&
             `  };` && |\n| &&
             `` && |\n| &&
             `  // Public getViewContent() became available in newer UI5 versions; fall back to the` && |\n| &&
             `  // internal mProperties.viewContent for older versions` && |\n| &&
             `  const getViewContent = (view) => view?.getViewContent?.() ?? view?.mProperties?.viewContent;` && |\n| &&
             `` && |\n| &&
             `  return {` && |\n| &&
             `    ERRORS_CAP,` && |\n| &&
             `    logError,` && |\n| &&
             `    registerCallback,` && |\n| &&
             `    unregisterCallback,` && |\n| &&
             `    runCallbacks,` && |\n| &&
             `    getViewContent,` && |\n| &&
             `  };` && |\n| &&
             `});` && |\n| &&
             `` && |\n| &&
             `sap.ui.define(` && |\n| &&
             `  ['sap/ui/core/UIComponent', 'z2ui5/model/models', 'z2ui5/cc/Server', 'sap/ui/VersionInfo', 'z2ui5/cc/DebugTool', 'z2ui5/cc/Util'],` && |\n| &&
             `  (UIComponent, Models, Server, VersionInfo, DebugTool, Util) => {` && |\n| &&
             `    'use strict';` && |\n| &&
             `` && |\n| &&
             `    const { logError: _logError } = Util;` && |\n| &&
             `` && |\n| &&
             `    return UIComponent.extend('z2ui5.Component', {` && |\n| &&
             `      metadata: {` && |\n| &&
             `        manifest: 'json',` && |\n| &&
             `        interfaces: ['sap.ui.core.IAsyncContentCreation'],` && |\n| &&
             `      },` && |\n| &&
             `      init() {` && |\n| &&
             `        if (typeof z2ui5 !== 'undefined') z2ui5.oConfig = {};` && |\n| &&
             `` && |\n| &&
             `        UIComponent.prototype.init.call(this);` && |\n| &&
             `` && |\n| &&
             `        if (typeof z2ui5 === 'undefined') z2ui5 = {};` && |\n| &&
             `        if (z2ui5.checkLocal === false) z2ui5 = {};` && |\n| &&
             `        z2ui5.oConfig ??= {};` && |\n| &&
             `        z2ui5.oDeviceModel = Models.createDeviceModel();` && |\n| &&
             `        this.setModel(z2ui5.oDeviceModel, 'device');` && |\n| &&
             `` && |\n| &&
             `        z2ui5.oConfig.ComponentData = this.getComponentData();` && |\n| &&
             `` && |\n| &&
             `        this._initLaunchpad();` && |\n| &&
             `        this._initVersionInfo();` && |\n| &&
             `` && |\n| &&
             `        this._boundUnload = this._onUnload.bind(this);` && |\n| &&
             `        // pagehide fires on every browser; beforeunload does not on iOS Safari.` && |\n| &&
             `        // Feature-detect rather than UA-sniff.` && |\n| &&
             `        this._unloadEvent = 'onpagehide' in window ? 'pagehide' : 'beforeunload';` && |\n| &&
             `        window.addEventListener(this._unloadEvent, this._boundUnload);` && |\n| &&
             `` && |\n| &&
             `        this._boundKeydown = (zEvent) => {` && |\n| &&
             `          if (zEvent.ctrlKey && zEvent.key === 'F12') {` && |\n| &&
             `            // ??= alone would not recreate a torn-down dialog control; isDestroyed() check covers that` && |\n| &&
             `            if (!z2ui5.debugTool || z2ui5.debugTool.isDestroyed?.()) {` && |\n| &&
             `              z2ui5.debugTool = new DebugTool();` && |\n| &&
             `            }` && |\n| &&
             `            z2ui5.debugTool.toggle();` && |\n| &&
             `          }` && |\n| &&
             `        };` && |\n| &&
             `        document.addEventListener('keydown', this._boundKeydown);` && |\n| &&
             `` && |\n| &&
             `        this._boundPopstate = (event) => {` && |\n| &&
             `          // Browser history state should be treated as read-only; drop the navigation flags` && |\n| &&
             `          // by shallow-copying the response/PARAMS instead of mutating event.state in place.` && |\n| &&
             `          const stateResponse = event?.state?.response;` && |\n| &&
             `          if (stateResponse?.PARAMS) {` && |\n| &&
             `            const restParams = { ...stateResponse.PARAMS };` && |\n| &&
             `            delete restParams.SET_PUSH_STATE;` && |\n| &&
             `            delete restParams.SET_APP_STATE_ACTIVE;` && |\n| &&
             `            z2ui5.oResponse = { ...stateResponse, PARAMS: restParams };` && |\n| &&
             `          }` && |\n| &&
             `          if (event?.state?.view) {` && |\n| &&
             `            z2ui5.oController?.ViewDestroy();` && |\n| &&
             `            z2ui5.oController` && |\n| &&
             `              ?.displayView(event.state.view, event.state.model)` && |\n| &&
             `              ?.catch((e) => _logError(``popstate: displayView failed``, e));` && |\n| &&
             `          }` && |\n| &&
             `        };` && |\n| &&
             `        window.addEventListener('popstate', this._boundPopstate);` && |\n| &&
             `` && |\n| &&
             `        z2ui5.oRouter = this.getRouter();` && |\n| &&
             `        // initialize() loads the route patterns; stop() pauses auto-routing — abap2UI5` && |\n| &&
             `        // drives navigation manually via Roundtrip rather than letting UI5 routing dispatch.` && |\n| &&
             `        z2ui5.oRouter.initialize();` && |\n| &&
             `        z2ui5.oRouter.stop();` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      _initLaunchpad() {` && |\n| &&
             `        const Container = sap.ui.require('sap/ushell/Container');` && |\n| &&
             `        if (!Container) return;` && |\n| &&
             `        const launchpad = { Container };` && |\n| &&
             `        z2ui5.oLaunchpad = launchpad;` && |\n| &&
             `        // Kick off both shell services in parallel; failures stay isolated and don't block each other` && |\n| &&
             `        Promise.allSettled([` && |\n| &&
             `          Container.getServiceAsync('ShellUIService').then((s) => {` && |\n| &&
             `            launchpad.ShellUIService = s;` && |\n| &&
             `          }),` && |\n| &&
             `          Container.getServiceAsync('CrossApplicationNavigation').then((s) => {` && |\n| &&
             `            launchpad.CrossAppNavigator = s;` && |\n| &&
             `          }),` && |\n| &&
             `        ]).then(([ui, nav]) => {` && |\n| &&
             `          if (ui.status === 'rejected') _logError(``Component: ShellUIService init failed``, ui.reason);` && |\n| &&
             `          if (nav.status === 'rejected') _logError(``Component: CrossApplicationNavigation init failed``, nav.reason);` && |\n| &&
             `        });` && |\n| &&
             `        sap.ui.require(` && |\n| &&
             `          ['sap/ushell/services/AppConfiguration'],` && |\n| &&
             `          (ac) => {` && |\n| &&
             `            launchpad.AppConfiguration = ac;` && |\n| &&
             `          },` && |\n| &&
             `          (e) => _logError(``Component: AppConfiguration init failed``, e),` && |\n| &&
             `        );` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      async _initVersionInfo() {` && |\n| &&
             `        try {` && |\n| &&
             `          const { version, buildTimestamp, gav } = (await VersionInfo.load()) ?? {};` && |\n| &&
             `          // oConfig may have been torn down between request and response — guard before assignment` && |\n| &&
             `          if (!this.isDestroyed() && z2ui5.oConfig) {` && |\n| &&
             `            z2ui5.oConfig.UI5VersionInfo = { version, buildTimestamp, gav };` && |\n| &&
             `          }` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          _logError(``Component: VersionInfo load failed``, e);` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      _onUnload() {` && |\n| &&
             `        window.removeEventListener(this._unloadEvent, this._boundUnload);` && |\n| &&
             `        // destroy() triggers exit() which removes the remaining listeners and ends the session` && |\n| &&
             `        this.destroy();` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      exit() {` && |\n| &&
             `        window.removeEventListener(this._unloadEvent, this._boundUnload);` && |\n| &&
             `        document.removeEventListener('keydown', this._boundKeydown);` && |\n| &&
             `        window.removeEventListener('popstate', this._boundPopstate);` && |\n| &&
             `        // Wrap each destroy individually so one failure does not skip the remaining cleanup` && |\n| &&
             `        const safeDestroy = (key) => {` && |\n| &&
             `          try {` && |\n| &&
             `            z2ui5[key]?.destroy?.();` && |\n| &&
             `          } catch (e) {` && |\n| &&
             `            _logError(``Component.exit: ${key}.destroy() failed``, e);` && |\n| &&
             `          }` && |\n| &&
             `        };` && |\n| &&
             `        safeDestroy('debugTool');` && |\n| &&
             `        safeDestroy('oDeviceModel');` && |\n| &&
             `        // Symmetric cleanup so a re-mounted Component does not leak controllers/views/router` && |\n| &&
             `        for (const key of [` && |\n| &&
             `          'debugTool',` && |\n| &&
             `          'oRouter',` && |\n| &&
             `          'oController',` && |\n| &&
             `          'oControllerNest',` && |\n| &&
             `          'oControllerNest2',` && |\n| &&
             `          'oControllerPopup',` && |\n| &&
             `          'oControllerPopover',` && |\n| &&
             `          'oView',` && |\n| &&
             `          'oViewNest',` && |\n| &&
             `          'oViewNest2',` && |\n| &&
             `          'oViewPopup',` && |\n| &&
             `          'oViewPopover',` && |\n| &&
             `          'oDeviceModel',` && |\n| &&
             `        ]) {` && |\n| &&
             `          z2ui5[key] = null;` && |\n| &&
             `        }` && |\n| &&
             `        try {` && |\n| &&
             `          Server.endSession();` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          _logError(``Component.exit: Server.endSession failed``, e);` && |\n| &&
             `        }` && |\n| &&
             `        UIComponent.prototype.exit?.call(this);` && |\n| &&
             `      },` && |\n| &&
             `    });` && |\n| &&
             `  },` && |\n| &&
             `);` && |\n| &&
             `` && |\n| &&
              ``.

  ENDMETHOD.

ENDCLASS.
