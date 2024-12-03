sap.ui.define(["sap/ui/core/UIComponent", "z2ui5/model/models","z2ui5/cc/Server", "sap/ui/VersionInfo", "z2ui5/cc/DebugTool"
    ], function (UIComponent, Models, Server, VersionInfo, DebugTool) {
    return UIComponent.extend("z2ui5.Component", {
        metadata: {
            manifest: "json"
        },
         init: async function () {

            UIComponent.prototype.init.apply(this, arguments);

            if (typeof z2ui5 == 'undefined'){
              z2ui5 = {};
            }
            this.getRouter().initialize();
            z2ui5.oRouter = this.getRouter();
            z2ui5.oDeviceModel = Models.createDeviceModel();
            this.setModel(z2ui5.oDeviceModel, "device");

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
                if (zEvent?.ctrlKey && zEvent?.key === "F12") {
                   if (!z2ui5.debugTool){
                     z2ui5.debugTool = new DebugTool();
                     z2ui5.debugTool.show();
                   } else { 
                     z2ui5.debugTool.close();
                     z2ui5.debugTool = null; 
                   } 
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
