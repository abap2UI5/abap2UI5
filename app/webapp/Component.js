sap.ui.define(["sap/ui/core/UIComponent", "z2ui5/model/models", "z2ui5/cc/Server", "sap/ui/VersionInfo", "z2ui5/cc/DebugTool"
], function (UIComponent, Models, Server, VersionInfo, DebugTool) {
    return UIComponent.extend("z2ui5.Component", {
        metadata: {
            manifest: "json",
            interfaces: [
                "sap.ui.core.IAsyncContentCreation"
            ]
        },
        init() {

            if (typeof z2ui5 !== 'undefined') {
                z2ui5.oConfig = {};
            }

            UIComponent.prototype.init.apply(this, arguments);

            if (typeof z2ui5 == 'undefined') {
                z2ui5 = {};
            }
            if (z2ui5?.checkLocal == false) {
                z2ui5 = {};
            }

            if (typeof z2ui5.oConfig == 'undefined') {
                z2ui5.oConfig = {};
            }
            z2ui5.oDeviceModel = Models.createDeviceModel();
            this.setModel(z2ui5.oDeviceModel, "device");

            z2ui5.oConfig.ComponentData = this.getComponentData();

            (async () => {
            try {
                z2ui5.oLaunchpadService = await this.getService("ShellUIService");
            } catch (e) { }

            let oVersionInfo = await VersionInfo.load();
            z2ui5.oConfig.UI5VersionInfo = {
                version: oVersionInfo.version,
                buildTimestamp: oVersionInfo.buildTimestamp,
                gav: oVersionInfo.gav,
            }
            })();

            this._boundUnload = this._onUnload.bind(this);
            if (/iPad|iPhone/.test(navigator.platform)) {
                window.addEventListener("pagehide", this._boundUnload);
            } else {
                window.addEventListener("beforeunload", this._boundUnload);
            }

            document.addEventListener("keydown", function (zEvent) {
                if (zEvent?.ctrlKey && zEvent?.key === "F12") {
                    if (!z2ui5.debugTool) {
                        z2ui5.debugTool = new DebugTool();
                    }
                    z2ui5.debugTool.toggle();
                }
            });

            window.addEventListener("popstate", (event) => {
                delete event?.state?.response?.PARAMS?.SET_PUSH_STATE;
                delete event?.state?.response?.PARAMS?.SET_APP_STATE_ACTIVE;
                if (event?.state?.view) {
                    z2ui5.oController.ViewDestroy();
                    z2ui5.oResponse = event.state.response;
                    z2ui5.oController.displayView(event.state.view, event.state.model);
                }
            });

            z2ui5.oRouter = this.getRouter();
            z2ui5.oRouter.initialize();
            z2ui5.oRouter.stop();

        },

        _onUnload: function () {
            if (/iPad|iPhone/.test(navigator.platform)) {
                window.removeEventListener("pagehide", this._boundUnload);
            } else {
                window.removeEventListener("beforeunload", this._boundUnload);
            }
            this.destroy();
        },

        exit: function () {
            Server.endSession();
            if (UIComponent.prototype.exit)
                UIComponent.prototype.exit.apply(this, arguments);
        },
    });
});
