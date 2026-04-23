sap.ui.define(
  ['sap/ui/core/UIComponent', 'z2ui5/model/models', 'z2ui5/cc/Server', 'sap/ui/VersionInfo', 'z2ui5/cc/DebugTool'],
  (UIComponent, Models, Server, VersionInfo, DebugTool) => {
    'use strict';
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
        if (typeof z2ui5.oConfig === 'undefined') z2ui5.oConfig = {};
        z2ui5.oDeviceModel = Models.createDeviceModel();
        this.setModel(z2ui5.oDeviceModel, 'device');

        z2ui5.oConfig.ComponentData = this.getComponentData();

        this._initAsync();

        this._boundUnload = this._onUnload.bind(this);
        this._unloadEvent = /iPad|iPhone/.test(navigator.userAgent) ? 'pagehide' : 'beforeunload';
        window.addEventListener(this._unloadEvent, this._boundUnload);

        this._boundKeydown = (zEvent) => {
          if (zEvent.ctrlKey && zEvent.key === 'F12') {
            z2ui5.debugTool ??= new DebugTool();
            z2ui5.debugTool.toggle();
          }
        };
        document.addEventListener('keydown', this._boundKeydown);

        this._boundPopstate = (event) => {
          delete event?.state?.response?.PARAMS?.SET_PUSH_STATE;
          delete event?.state?.response?.PARAMS?.SET_APP_STATE_ACTIVE;
          if (event?.state?.view) {
            z2ui5.oController?.ViewDestroy();
            z2ui5.oResponse = event.state.response;
            z2ui5.oController?.displayView(event.state.view, event.state.model)?.catch((e) =>
              (z2ui5.errors ??= []).push({
                message: `popstate: displayView failed`,
                error: e,
                ts: new Date().toISOString(),
              }),
            );
          }
        };
        window.addEventListener('popstate', this._boundPopstate);

        z2ui5.oRouter = this.getRouter();
        z2ui5.oRouter.initialize();
        z2ui5.oRouter.stop();
      },

      async _initAsync() {
        const logLaunchpadError = (message, error) =>
          (z2ui5.errors ??= []).push({ message, error, ts: new Date().toISOString() });
        try {
          const Container = sap.ui.require('sap/ushell/Container');
          if (Container) {
            const launchpad = { Container };
            try {
              launchpad.ShellUIService = await this.getService('ShellUIService');
            } catch (e) {
              logLaunchpadError(`Component: ShellUIService init failed`, e);
            }
            try {
              launchpad.CrossAppNavigator = Container.getService('CrossApplicationNavigation');
            } catch (e) {
              logLaunchpadError(`Component: CrossApplicationNavigation init failed`, e);
            }
            try {
              launchpad.AppConfiguration = await new Promise((resolve, reject) =>
                sap.ui.require(['sap/ushell/services/AppConfiguration'], resolve, reject),
              );
            } catch (e) {
              logLaunchpadError(`Component: AppConfiguration init failed`, e);
            }
            if (!this.isDestroyed()) z2ui5.oLaunchpad = launchpad;
          }
        } catch (e) {
          logLaunchpadError(`Component: Launchpad init failed`, e);
        }

        try {
          const { version, buildTimestamp, gav } = await VersionInfo.load();
          if (!this.isDestroyed()) z2ui5.oConfig.UI5VersionInfo = { version, buildTimestamp, gav };
        } catch (e) {
          (z2ui5.errors ??= []).push({
            message: `Component: VersionInfo load failed`,
            error: e,
            ts: new Date().toISOString(),
          });
        }
      },

      _onUnload() {
        window.removeEventListener(this._unloadEvent, this._boundUnload);
        this.destroy();
      },

      exit() {
        window.removeEventListener(this._unloadEvent, this._boundUnload);
        document.removeEventListener('keydown', this._boundKeydown);
        window.removeEventListener('popstate', this._boundPopstate);
        Server.endSession();
        UIComponent.prototype.exit.call(this);
      },
    });
  },
);
