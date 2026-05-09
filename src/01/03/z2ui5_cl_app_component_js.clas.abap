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

    result = `sap.ui.define(` && |\n| &&
             `  ['sap/ui/core/UIComponent', 'z2ui5/model/models', 'z2ui5/cc/Server', 'sap/ui/VersionInfo', 'z2ui5/cc/DebugTool'],` && |\n| &&
             `  (UIComponent, Models, Server, VersionInfo, DebugTool) => {` && |\n| &&
             `    'use strict';` && |\n| &&
             `` && |\n| &&
             `    const _logError = (message, error) => {` && |\n| &&
             `      const entry = { message, ts: new Date().toISOString() };` && |\n| &&
             `      if (error !== undefined) entry.error = error;` && |\n| &&
             `      (z2ui5.errors ??= []).push(entry);` && |\n| &&
             `    };` && |\n| &&
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
             `            z2ui5.debugTool ??= new DebugTool();` && |\n| &&
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
             `            const {` && |\n| &&
             `              SET_PUSH_STATE: _0,` && |\n| &&
             `              SET_APP_STATE_ACTIVE: _1,` && |\n| &&
             `              ...restParams` && |\n| &&
             `            } = stateResponse.PARAMS;` && |\n| &&
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
             `        z2ui5.oRouter.initialize();` && |\n| &&
             `        z2ui5.oRouter.stop();` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      _initLaunchpad() {` && |\n| &&
             `        const Container = sap.ui.require('sap/ushell/Container');` && |\n| &&
             `        if (!Container) return;` && |\n| &&
             `        const launchpad = { Container };` && |\n| &&
             `        z2ui5.oLaunchpad = launchpad;` && |\n| &&
             `        Container.getServiceAsync('ShellUIService')` && |\n| &&
             `          .then((s) => {` && |\n| &&
             `            launchpad.ShellUIService = s;` && |\n| &&
             `          })` && |\n| &&
             `          .catch((e) => _logError(``Component: ShellUIService init failed``, e));` && |\n| &&
             `        Container.getServiceAsync('CrossApplicationNavigation')` && |\n| &&
             `          .then((s) => {` && |\n| &&
             `            launchpad.CrossAppNavigator = s;` && |\n| &&
             `          })` && |\n| &&
             `          .catch((e) => _logError(``Component: CrossApplicationNavigation init failed``, e));` && |\n| &&
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
             `          const { version, buildTimestamp, gav } = await VersionInfo.load();` && |\n| &&
             `          if (!this.isDestroyed()) z2ui5.oConfig.UI5VersionInfo = { version, buildTimestamp, gav };` && |\n| &&
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
             `        z2ui5.debugTool?.destroy?.();` && |\n| &&
             `        // Symmetric cleanup so a re-mounted Component does not leak controllers/views` && |\n| &&
             `        for (const key of [` && |\n| &&
             `          'debugTool',` && |\n| &&
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
             `        ]) {` && |\n| &&
             `          z2ui5[key] = null;` && |\n| &&
             `        }` && |\n| &&
             `        Server.endSession();` && |\n| &&
             `        UIComponent.prototype.exit?.call(this);` && |\n| &&
             `      },` && |\n| &&
             `    });` && |\n| &&
             `  },` && |\n| &&
             `);` && |\n| &&
             `` && |\n| &&
              ``.

  ENDMETHOD.

ENDCLASS.
