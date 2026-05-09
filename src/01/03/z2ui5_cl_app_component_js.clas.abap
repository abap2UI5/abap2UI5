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
             `        z2ui5.oLaunchpad = launchpad;` && |\n| &&
             `        Container.getServiceAsync('ShellUIService')` && |\n| &&
             `          .then((s) => {` && |\n| &&
             `            launchpad.ShellUIService = s;` && |\n| &&
             `          })` && |\n| &&
             `          .catch((e) => logErr(``Component: ShellUIService init failed``, e));` && |\n| &&
             `        Container.getServiceAsync('CrossApplicationNavigation')` && |\n| &&
             `          .then((s) => {` && |\n| &&
             `            launchpad.CrossAppNavigator = s;` && |\n| &&
             `          })` && |\n| &&
             `          .catch((e) => logErr(``Component: CrossApplicationNavigation init failed``, e));` && |\n| &&
             `        sap.ui.require(` && |\n| &&
             `          ['sap/ushell/services/AppConfiguration'],` && |\n| &&
             `          (ac) => {` && |\n| &&
             `            launchpad.AppConfiguration = ac;` && |\n| &&
             `          },` && |\n| &&
             `          (e) => logErr(``Component: AppConfiguration init failed``, e),` && |\n| &&
             `        );` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      async _initVersionInfo() {` && |\n| &&
             `        try {` && |\n| &&
             `          const { version, buildTimestamp, gav } = await VersionInfo.load();` && |\n| &&
             `          if (!this.isDestroyed()) z2ui5.oConfig.UI5VersionInfo = { version, buildTimestamp, gav };` && |\n| &&
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
             `        UIComponent.prototype.exit.call(this);` && |\n| &&
             `      },` && |\n| &&
             `    });` && |\n| &&
             `  },` && |\n| &&
             `);` && |\n| &&
             `` && |\n| &&
              ``.

  ENDMETHOD.

ENDCLASS.
