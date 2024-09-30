sap.ui.define(["sap/ui/core/UIComponent", "z2ui5/model/models",
      "z2ui5/cc/DebugTool","z2ui5/cc/Server", "sap/base/Log","sap/ui/VersionInfo"
  
    ], function (UIComponent, models, DebugTool, Server, Log, VersionInfo) {
    return UIComponent.extend("z2ui5.Component", {
        metadata: {
            manifest: "json"
        },
         init: async function () {

            UIComponent.prototype.init.apply(this, arguments);

            this.getRouter().initialize();
            z2ui5.oRouter = this.getRouter();
            this.setModel(models.createDeviceModel(), "device");
            this._oLogger = Log.getLogger("abap2UI5");

            z2ui5.oConfig = {};
            z2ui5.oConfig.ComponentData = this.getComponentData();

            try {                                                                                                                                                                                                                                           
                z2ui5.oLaunchpadService = await this.getService("ShellUIService");                                                                                                                                                                                                                                                                                                                                                                                       
             } catch (e) {}  
             
            let oVersionInfo = await VersionInfo.load();
            z2ui5.oConfig.UI5VersionInfo = {
                version : oVersionInfo.version,
                buildTimestamp : oVersionInfo.buildTimestamp,
                gav : oVersionInfo.gav,
            }

            if (/iPad|iPhone/.test(navigator.platform)) {
                window.addEventListener("__pagehide", this.__pagehide.bind(this));
            } else {
                window.addEventListener("__beforeunload", this.__beforeunload.bind(this));
            }

            document.addEventListener("keydown", function (zEvent) {
                if (zEvent?.key === "F12") {
                    new z2ui5.cc.DebugTool().show();
                }
            });
        },

        __beforeunload: function () {
            window.removeEventListener("__beforeunload", this.__beforeunload.bind(this));
            this.destroy();
        },
        __pagehide: function () {
            window.removeEventListener("__pagehide", this.__pagehide.bind(this));
            this.destroy();
        },

        exit: function () {
            Server.endSession();
            if (UIComponent.prototype.exit)
                UIComponent.prototype.exit.apply(this, arguments);
        },
    });
});
