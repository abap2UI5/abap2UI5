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
             `        if (typeof z2ui5.oConfig === 'undefined') z2ui5.oConfig = {};` && |\n| &&
             `        z2ui5.oDeviceModel = Models.createDeviceModel();` && |\n| &&
             `        this.setModel(z2ui5.oDeviceModel, 'device');` && |\n| &&
             `` && |\n| &&
             `        z2ui5.oConfig.ComponentData = this.getComponentData();` && |\n| &&
             `` && |\n| &&
             `        this._initLaunchpad();` && |\n| &&
             `        this._initVersionInfo();` && |\n| &&
             `` && |\n| &&
             `        this._boundUnload = this._onUnload.bind(this);` && |\n| &&
             `        this._unloadEvent = /iPad|iPhone/.test(navigator.userAgent) ? 'pagehide' : 'beforeunload';` && |\n| &&
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
             `          delete event?.state?.response?.PARAMS?.SET_PUSH_STATE;` && |\n| &&
             `          delete event?.state?.response?.PARAMS?.SET_APP_STATE_ACTIVE;` && |\n| &&
             `          if (event?.state?.view) {` && |\n| &&
             `            z2ui5.oController?.ViewDestroy();` && |\n| &&
             `            z2ui5.oResponse = event.state.response;` && |\n| &&
             `            z2ui5.oController?.displayView(event.state.view, event.state.model)?.catch((e) =>` && |\n| &&
             `              (z2ui5.errors ??= []).push({` && |\n| &&
             `                message: ``popstate: displayView failed``,` && |\n| &&
             `                error: e,` && |\n| &&
             `                ts: new Date().toISOString(),` && |\n| &&
             `              }),` && |\n| &&
             `            );` && |\n| &&
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
             `        const logErr = (message, error) =>` && |\n| &&
             `          (z2ui5.errors ??= []).push({ message, error, ts: new Date().toISOString() });` && |\n| &&
             `        const Container = sap.ui.require('sap/ushell/Container');` && |\n| &&
             `        if (!Container) return;` && |\n| &&
             `        const launchpad = { Container };` && |\n| &&
             `        this._launchpad = launchpad;` && |\n| &&
             `        z2ui5.oLaunchpad = launchpad;` && |\n| &&
             `        // Guard async writes: a slow-resolving service must not populate the` && |\n| &&
             `        // launchpad object after the component has been destroyed (e.g. user` && |\n| &&
             `        // closes the app before the FLP services finish loading).` && |\n| &&
             `        const setIfAlive = (key, value) => {` && |\n| &&
             `          if (!this.isDestroyed?.() && this._launchpad === launchpad) launchpad[key] = value;` && |\n| &&
             `        };` && |\n| &&
             `        Container.getServiceAsync('ShellUIService')` && |\n| &&
             `          .then((s) => setIfAlive('ShellUIService', s))` && |\n| &&
             `          .catch((e) => logErr(``Component: ShellUIService init failed``, e));` && |\n| &&
             `        Container.getServiceAsync('CrossApplicationNavigation')` && |\n| &&
             `          .then((s) => setIfAlive('CrossAppNavigator', s))` && |\n| &&
             `          .catch((e) => logErr(``Component: CrossApplicationNavigation init failed``, e));` && |\n| &&
             `        sap.ui.require(` && |\n| &&
             `          ['sap/ushell/services/AppConfiguration'],` && |\n| &&
             `          (ac) => setIfAlive('AppConfiguration', ac),` && |\n| &&
             `          (e) => logErr(``Component: AppConfiguration init failed``, e),` && |\n| &&
             `        );` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      async _initVersionInfo() {` && |\n| &&
             `        try {` && |\n| &&
             `          const { version, buildTimestamp, gav } = await VersionInfo.load();` && |\n| &&
             `          if (!this.isDestroyed?.()) z2ui5.oConfig.UI5VersionInfo = { version, buildTimestamp, gav };` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          (z2ui5.errors ??= []).push({` && |\n| &&
             `            message: ``Component: VersionInfo load failed``,` && |\n| &&
             `            error: e,` && |\n| &&
             `            ts: new Date().toISOString(),` && |\n| &&
             `          });` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      _onUnload() {` && |\n| &&
             `        window.removeEventListener(this._unloadEvent, this._boundUnload);` && |\n| &&
             `        this.destroy();` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      exit() {` && |\n| &&
             `        window.removeEventListener(this._unloadEvent, this._boundUnload);` && |\n| &&
             `        document.removeEventListener('keydown', this._boundKeydown);` && |\n| &&
             `        window.removeEventListener('popstate', this._boundPopstate);` && |\n| &&
             `        Server.endSession();` && |\n| &&
             `        // Robust launchpad teardown: clear the FLP dirty flag so it does not` && |\n| &&
             `        // carry over into the next app, and detach the shared launchpad` && |\n| &&
             `        // object so a subsequent re-launch starts from a clean state and any` && |\n| &&
             `        // still-pending init Promises become no-ops.` && |\n| &&
             `        try {` && |\n| &&
             `          this._launchpad?.Container?.setDirtyFlag?.(false);` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          (z2ui5.errors ??= []).push({` && |\n| &&
             `            message: ``Component: clearing FLP dirty flag failed``,` && |\n| &&
             `            error: e,` && |\n| &&
             `            ts: new Date().toISOString(),` && |\n| &&
             `          });` && |\n| &&
             `        }` && |\n| &&
             `        if (z2ui5.oLaunchpad === this._launchpad) z2ui5.oLaunchpad = null;` && |\n| &&
             `        this._launchpad = null;` && |\n| &&
             `        UIComponent.prototype.exit?.call(this);` && |\n| &&
             `      },` && |\n| &&
             `    });` && |\n| &&
             `  },` && |\n| &&
             `);` && |\n| &&
             `` && |\n| &&
              ``.

  ENDMETHOD.

ENDCLASS.
