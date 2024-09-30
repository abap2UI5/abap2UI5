CLASS z2ui5_cl_app__Component_js DEFINITION
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


CLASS z2ui5_cl_app__Component_js IMPLEMENTATION.

  METHOD get.

    result =              `sap.ui.define(["sap/ui/core/UIComponent", "z2ui5/model/models",` && |\n|  &&
             `      "z2ui5/cc/DebugTool","z2ui5/cc/Server", "sap/base/Log","sap/ui/VersionInfo"` && |\n|  &&
             `  ` && |\n|  &&
             `    ], function (UIComponent, models, DebugTool, Server, Log, VersionInfo) {` && |\n|  &&
             `    return UIComponent.extend("z2ui5.Component", {` && |\n|  &&
             `        metadata: {` && |\n|  &&
             `            manifest: "json"` && |\n|  &&
             `        },` && |\n|  &&
             `         init: async function () {` && |\n|  &&
             `` && |\n|  &&
             `            UIComponent.prototype.init.apply(this, arguments);` && |\n|  &&
             `` && |\n|  &&
             `            this.getRouter().initialize();` && |\n|  &&
             `            z2ui5.oRouter = this.getRouter();` && |\n|  &&
             `            this.setModel(models.createDeviceModel(), "device");` && |\n|  &&
             `            this._oLogger = Log.getLogger("abap2UI5");` && |\n|  &&
             `` && |\n|  &&
             `            z2ui5.oConfig = {};` && |\n|  &&
             `            z2ui5.oConfig.ComponentData = this.getComponentData();` && |\n|  &&
             `` && |\n|  &&
             `            try {                                                                                   ` && |\n|  &&
             `                                                                                                    ` && |\n|  &&
             `                                                    ` && |\n|  &&
             `                z2ui5.oLaunchpadService = await this.getService("ShellUIService");                  ` && |\n|  &&
             `                                                                                                    ` && |\n|  &&
             `                                                                                                    ` && |\n|  &&
             `                                                                                                    ` && |\n|  &&
             `                                                         ` && |\n|  &&
             `             } catch (e) {}  ` && |\n|  &&
             `             ` && |\n|  &&
             `            let oVersionInfo = await VersionInfo.load();` && |\n|  &&
             `            z2ui5.oConfig.UI5VersionInfo = {` && |\n|  &&
             `                version : oVersionInfo.version,` && |\n|  &&
             `                buildTimestamp : oVersionInfo.buildTimestamp,` && |\n|  &&
             `                gav : oVersionInfo.gav,` && |\n|  &&
             `            }` && |\n|  &&
             `` && |\n|  &&
             `            if (/iPad|iPhone/.test(navigator.platform)) {` && |\n|  &&
             `                window.addEventListener("__pagehide", this.__pagehide.bind(this));` && |\n|  &&
             `            } else {` && |\n|  &&
             `                window.addEventListener("__beforeunload", this.__beforeunload.bind(this));` && |\n|  &&
             `            }` && |\n|  &&
             `` && |\n|  &&
             `            document.addEventListener("keydown", function (zEvent) {` && |\n|  &&
             `                if (zEvent?.key === "F12") {` && |\n|  &&
             `                    new z2ui5.cc.DebugTool().show();` && |\n|  &&
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
             `` && |\n|  &&
              ``.

  ENDMETHOD.

ENDCLASS.