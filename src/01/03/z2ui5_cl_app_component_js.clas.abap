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

    result =              `sap.ui.define(["sap/ui/core/UIComponent", "z2ui5/model/models", "z2ui5/cc/Server", "sap/ui/VersionInfo", "z2ui5/cc/DebugTool"` && |\n|  &&
             `], function (UIComponent, Models, Server, VersionInfo, DebugTool) {` && |\n|  &&
             `    return UIComponent.extend("z2ui5.Component", {` && |\n|  &&
             `        metadata: {` && |\n|  &&
             `            manifest: "json",` && |\n|  &&
             `            interfaces: [` && |\n|  &&
             `                "sap.ui.core.IAsyncContentCreation"` && |\n|  &&
             `            ]` && |\n|  &&
             `        },` && |\n|  &&
             `        async init() {` && |\n|  &&
             `            UIComponent.prototype.init.apply(this, arguments);` && |\n|  &&
             `` && |\n|  &&
             `            if (typeof z2ui5 == 'undefined') {` && |\n|  &&
             `                z2ui5 = {};` && |\n|  &&
             `            }` && |\n|  &&
             `            if (z2ui5?.checkLocal == false) {` && |\n|  &&
             `            z2ui5 = {};` && |\n|  &&
             `            }` && |\n|  &&
             `` && |\n|  &&
             `            z2ui5.oRouter = this.getRouter();` && |\n|  &&
             `            z2ui5.oRouter.initialize();` && |\n|  &&
             `            z2ui5.oRouter.stop();` && |\n|  &&
             `` && |\n|  &&
             `            z2ui5.oDeviceModel = Models.createDeviceModel();` && |\n|  &&
             `            this.setModel(z2ui5.oDeviceModel, "device");` && |\n|  &&
             `` && |\n|  &&
             `            z2ui5.oConfig = {};` && |\n|  &&
             `            z2ui5.oConfig.ComponentData = this.getComponentData();` && |\n|  &&
             `` && |\n|  &&
             `            try {` && |\n|  &&
             `                z2ui5.oLaunchpadService = await this.getService("ShellUIService");` && |\n|  &&
             `            } catch (e) { }` && |\n|  &&
             `` && |\n|  &&
             `            let oVersionInfo = await VersionInfo.load();` && |\n|  &&
             `            z2ui5.oConfig.UI5VersionInfo = {` && |\n|  &&
             `                version: oVersionInfo.version,` && |\n|  &&
             `                buildTimestamp: oVersionInfo.buildTimestamp,` && |\n|  &&
             `                gav: oVersionInfo.gav,` && |\n|  &&
             `            }` && |\n|  &&
             `` && |\n|  &&
             `            if (/iPad|iPhone/.test(navigator.platform)) {` && |\n|  &&
             `                window.addEventListener("__pagehide", this.__pagehide.bind(this));` && |\n|  &&
             `            } else {` && |\n|  &&
             `                window.addEventListener("__beforeunload", this.__beforeunload.bind(this));` && |\n|  &&
             `            }` && |\n|  &&
             `` && |\n|  &&
             `            document.addEventListener("keydown", function (zEvent) {` && |\n|  &&
             `                if (zEvent?.ctrlKey && zEvent?.key === "F12") {` && |\n|  &&
             `                    if (!z2ui5.debugTool) {` && |\n|  &&
             `                        z2ui5.debugTool = new DebugTool();` && |\n|  &&
             `                    }` && |\n|  &&
             `                    z2ui5.debugTool.toggle();` && |\n|  &&
             `                }` && |\n|  &&
             `            });` && |\n|  &&
             `` && |\n|  &&
             `            window.addEventListener("popstate", (event) => {` && |\n|  &&
             `                delete event?.state?.response?.PARAMS?.SET_PUSH_STATE;` && |\n|  &&
             `                delete event?.state?.response?.PARAMS?.SET_APP_STATE_ACTIVE;` && |\n|  &&
             `                if (event?.state?.view) {` && |\n|  &&
             `                    z2ui5.oController.ViewDestroy();` && |\n|  &&
             `                    z2ui5.oResponse = event.state.response;` && |\n|  &&
             `                    z2ui5.oController.displayView(event.state.view, event.state.model);` && |\n|  &&
             `                }` && |\n|  &&
             `            });` && |\n|  &&
             `        },` && |\n|  &&
             `` && |\n|  &&
             `        __beforeunload: function () {` && |\n|  &&
             `            window.removeEventListener("__beforeunload", this.__beforeunload.bind(this));` && |\n|  &&
             `            this.destroy();` && |\n|  &&
             `        },` && |\n|  &&
             `        __pagehide: function () {` && |\n|  &&
             `            window.removeEventListener("__pagehide", this.__pagehide.bind(this));` && |\n|  &&
             `            this.destroy();` && |\n|  &&
             `        },` && |\n|  &&
             `` && |\n|  &&
             `        exit: function () {` && |\n|  &&
             `            Server.endSession();` && |\n|  &&
             `            if (UIComponent.prototype.exit)` && |\n|  &&
             `                UIComponent.prototype.exit.apply(this, arguments);` && |\n|  &&
             `        },` && |\n|  &&
             `    });` && |\n|  &&
             `});` && |\n|  &&
              ``.

  ENDMETHOD.

ENDCLASS.
