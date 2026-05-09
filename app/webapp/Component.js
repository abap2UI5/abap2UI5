sap.ui.define(
  ['sap/ui/core/UIComponent', 'z2ui5/model/models', 'z2ui5/cc/Server', 'sap/ui/VersionInfo', 'z2ui5/cc/DebugTool'],
  (UIComponent, Models, Server, VersionInfo, DebugTool) => {
    'use strict';

    const _logError = (message, error) => {
      const entry = { message, ts: new Date().toISOString() };
      if (error !== undefined) entry.error = error;
      (z2ui5.errors ??= []).push(entry);
    };

    return UIComponent.extend('z2ui5.Component', {
      metadata: {
        manifest: 'json',
        interfaces: ['sap.ui.core.IAsyncContentCreation'],
      },
      init() {
        if (typeof z2ui5 !== 'undefined') z2ui5.oConfig = {};

        UIComponent.prototype.init.call(this);

        if (typeof z2ui5 === 'undefined') z2ui5 = {};
        if (z2ui5.checkLocal === false) z2ui5 = {};
        z2ui5.oConfig ??= {};
        z2ui5.oDeviceModel = Models.createDeviceModel();
        this.setModel(z2ui5.oDeviceModel, 'device');

        z2ui5.oConfig.ComponentData = this.getComponentData();

        this._initLaunchpad();
        this._initVersionInfo();

        this._boundUnload = this._onUnload.bind(this);
        // pagehide fires on every browser; beforeunload does not on iOS Safari.
        // Feature-detect rather than UA-sniff.
        this._unloadEvent = 'onpagehide' in window ? 'pagehide' : 'beforeunload';
        window.addEventListener(this._unloadEvent, this._boundUnload);

        this._boundKeydown = (zEvent) => {
          if (zEvent.ctrlKey && zEvent.key === 'F12') {
            // ??= alone would not recreate a torn-down dialog control; isDestroyed() check covers that
            if (!z2ui5.debugTool || z2ui5.debugTool.isDestroyed?.()) {
              z2ui5.debugTool = new DebugTool();
            }
            z2ui5.debugTool.toggle();
          }
        };
        document.addEventListener('keydown', this._boundKeydown);

        this._boundPopstate = (event) => {
          // Browser history state should be treated as read-only; drop the navigation flags
          // by shallow-copying the response/PARAMS instead of mutating event.state in place.
          const stateResponse = event?.state?.response;
          if (stateResponse?.PARAMS) {
            const restParams = { ...stateResponse.PARAMS };
            delete restParams.SET_PUSH_STATE;
            delete restParams.SET_APP_STATE_ACTIVE;
            z2ui5.oResponse = { ...stateResponse, PARAMS: restParams };
          }
          if (event?.state?.view) {
            z2ui5.oController?.ViewDestroy();
            z2ui5.oController
              ?.displayView(event.state.view, event.state.model)
              ?.catch((e) => _logError(`popstate: displayView failed`, e));
          }
        };
        window.addEventListener('popstate', this._boundPopstate);

        z2ui5.oRouter = this.getRouter();
        // initialize() loads the route patterns; stop() pauses auto-routing — abap2UI5
        // drives navigation manually via Roundtrip rather than letting UI5 routing dispatch.
        z2ui5.oRouter.initialize();
        z2ui5.oRouter.stop();
      },

      _initLaunchpad() {
        const Container = sap.ui.require('sap/ushell/Container');
        if (!Container) return;
        const launchpad = { Container };
        z2ui5.oLaunchpad = launchpad;
        // Kick off both shell services in parallel; failures stay isolated and don't block each other
        Promise.allSettled([
          Container.getServiceAsync('ShellUIService').then((s) => {
            launchpad.ShellUIService = s;
          }),
          Container.getServiceAsync('CrossApplicationNavigation').then((s) => {
            launchpad.CrossAppNavigator = s;
          }),
        ]).then(([ui, nav]) => {
          if (ui.status === 'rejected') _logError(`Component: ShellUIService init failed`, ui.reason);
          if (nav.status === 'rejected') _logError(`Component: CrossApplicationNavigation init failed`, nav.reason);
        });
        sap.ui.require(
          ['sap/ushell/services/AppConfiguration'],
          (ac) => {
            launchpad.AppConfiguration = ac;
          },
          (e) => _logError(`Component: AppConfiguration init failed`, e),
        );
      },

      async _initVersionInfo() {
        try {
          const { version, buildTimestamp, gav } = (await VersionInfo.load()) ?? {};
          // oConfig may have been torn down between request and response — guard before assignment
          if (!this.isDestroyed() && z2ui5.oConfig) {
            z2ui5.oConfig.UI5VersionInfo = { version, buildTimestamp, gav };
          }
        } catch (e) {
          _logError(`Component: VersionInfo load failed`, e);
        }
      },

      _onUnload() {
        window.removeEventListener(this._unloadEvent, this._boundUnload);
        // destroy() triggers exit() which removes the remaining listeners and ends the session
        this.destroy();
      },

      exit() {
        window.removeEventListener(this._unloadEvent, this._boundUnload);
        document.removeEventListener('keydown', this._boundKeydown);
        window.removeEventListener('popstate', this._boundPopstate);
        // Wrap each destroy individually so one failure does not skip the remaining cleanup
        const safeDestroy = (key) => {
          try {
            z2ui5[key]?.destroy?.();
          } catch (e) {
            _logError(`Component.exit: ${key}.destroy() failed`, e);
          }
        };
        safeDestroy('debugTool');
        safeDestroy('oDeviceModel');
        // Symmetric cleanup so a re-mounted Component does not leak controllers/views/router
        for (const key of [
          'debugTool',
          'oRouter',
          'oController',
          'oControllerNest',
          'oControllerNest2',
          'oControllerPopup',
          'oControllerPopover',
          'oView',
          'oViewNest',
          'oViewNest2',
          'oViewPopup',
          'oViewPopover',
          'oDeviceModel',
        ]) {
          z2ui5[key] = null;
        }
        try {
          Server.endSession();
        } catch (e) {
          _logError(`Component.exit: Server.endSession failed`, e);
        }
        UIComponent.prototype.exit?.call(this);
      },
    });
  },
);
