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

    result = `sap.ui.define(["sap/ui/core/UIComponent", "z2ui5/model/models", "z2ui5/cc/Server", "sap/ui/VersionInfo", "z2ui5/cc/DebugTool"` && |\n| &&
             `], function (UIComponent, Models, Server, VersionInfo, DebugTool) {` && |\n| &&
             `    "use strict";` && |\n| &&
             `    return UIComponent.extend("z2ui5.Component", {` && |\n| &&
             `        metadata: {` && |\n| &&
             `            manifest: "json",` && |\n| &&
             `            interfaces: [` && |\n| &&
             `                "sap.ui.core.IAsyncContentCreation"` && |\n| &&
             `            ]` && |\n| &&
             `        },` && |\n| &&
             `        init() {` && |\n| &&
             `` && |\n| &&
             `            if (typeof z2ui5 !== 'undefined') {` && |\n| &&
             `                z2ui5.oConfig = {};` && |\n| &&
             `            }` && |\n| &&
             `` && |\n| &&
             `            UIComponent.prototype.init.apply(this, arguments);` && |\n| &&
             `` && |\n| &&
             `            if (typeof z2ui5 === 'undefined') {` && |\n| &&
             `                z2ui5 = {};` && |\n| &&
             `            }` && |\n| &&
             `            if (z2ui5?.checkLocal === false) {` && |\n| &&
             `                z2ui5 = {};` && |\n| &&
             `            }` && |\n| &&
             `` && |\n| &&
             `            if (typeof z2ui5.oConfig === 'undefined') {` && |\n| &&
             `                z2ui5.oConfig = {};` && |\n| &&
             `            }` && |\n| &&
             `            z2ui5.oDeviceModel = Models.createDeviceModel();` && |\n| &&
             `            this.setModel(z2ui5.oDeviceModel, "device");` && |\n| &&
             `` && |\n| &&
             `            z2ui5.oConfig.ComponentData = this.getComponentData();` && |\n| &&
             `` && |\n| &&
             `            (async () => {` && |\n| &&
             `            try {` && |\n| &&
             `                if (sap.ui.require("sap/ushell/Container")) {` && |\n| &&
             `                    z2ui5.oLaunchpadService = await this.getService("ShellUIService");` && |\n| &&
             `                }` && |\n| &&
             `            } catch (e) { }` && |\n| &&
             `` && |\n| &&
             `            let oVersionInfo = await VersionInfo.load();` && |\n| &&
             `            z2ui5.oConfig.UI5VersionInfo = {` && |\n| &&
             `                version: oVersionInfo.version,` && |\n| &&
             `                buildTimestamp: oVersionInfo.buildTimestamp,` && |\n| &&
             `                gav: oVersionInfo.gav,` && |\n| &&
             `            }` && |\n| &&
             `            })();` && |\n| &&
             `` && |\n| &&
             `            this._boundUnload = this._onUnload.bind(this);` && |\n| &&
             `            this._unloadEvent = /iPad|iPhone/.test(navigator.platform) ? "pagehide" : "beforeunload";` && |\n| &&
             `            window.addEventListener(this._unloadEvent, this._boundUnload);` && |\n| &&
             `` && |\n| &&
             `            this._boundKeydown = function (zEvent) {` && |\n| &&
             `                if (zEvent?.ctrlKey && zEvent?.key === "F12") {` && |\n| &&
             `                    if (!z2ui5.debugTool) {` && |\n| &&
             `                        z2ui5.debugTool = new DebugTool();` && |\n| &&
             `                    }` && |\n| &&
             `                    z2ui5.debugTool.toggle();` && |\n| &&
             `                }` && |\n| &&
             `            };` && |\n| &&
             `            document.addEventListener("keydown", this._boundKeydown);` && |\n| &&
             `` && |\n| &&
             `            this._boundPopstate = (event) => {` && |\n| &&
             `                delete event?.state?.response?.PARAMS?.SET_PUSH_STATE;` && |\n| &&
             `                delete event?.state?.response?.PARAMS?.SET_APP_STATE_ACTIVE;` && |\n| &&
             `                if (event?.state?.view) {` && |\n| &&
             `                    z2ui5.oController.ViewDestroy();` && |\n| &&
             `                    z2ui5.oResponse = event.state.response;` && |\n| &&
             `                    z2ui5.oController.displayView(event.state.view, event.state.model);` && |\n| &&
             `                }` && |\n| &&
             `            };` && |\n| &&
             `            window.addEventListener("popstate", this._boundPopstate);` && |\n| &&
             `` && |\n| &&
             `            z2ui5.oRouter = this.getRouter();` && |\n| &&
             `            z2ui5.oRouter.initialize();` && |\n| &&
             `            z2ui5.oRouter.stop();` && |\n| &&
             `` && |\n| &&
             `        },` && |\n| &&
             `` && |\n| &&
             `        _onUnload: function () {` && |\n| &&
             `            window.removeEventListener(this._unloadEvent, this._boundUnload);` && |\n| &&
             `            this.destroy();` && |\n| &&
             `        },` && |\n| &&
             `` && |\n| &&
             `        exit: function () {` && |\n| &&
             `            document.removeEventListener("keydown", this._boundKeydown);` && |\n| &&
             `            window.removeEventListener("popstate", this._boundPopstate);` && |\n| &&
             `            Server.endSession();` && |\n| &&
             `            if (UIComponent.prototype.exit)` && |\n| &&
             `                UIComponent.prototype.exit.apply(this, arguments);` && |\n| &&
             `        },` && |\n| &&
             `    });` && |\n| &&
             `});` && |\n| &&
             `` && |\n| &&
              ``.

  ENDMETHOD.

ENDCLASS.
