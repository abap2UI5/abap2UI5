sap.ui.define([
    "sap/ui/model/json/JSONModel",
    "sap/ui/Device",
    "sap/ui/util/Storage"
], 
function (JSONModel, Device, Storage) {
    "use strict";

    return {
        /**
         * Provides runtime info for the device the UI5 app is running on as JSONModel
         */
        createDeviceModel: function () {
            var oModel = new JSONModel(Device);
            oModel.setDefaultBindingMode("OneWay");
            return oModel;
        },
        createStorageModel: function () {
            var oModel = new JSONModel(Storage);
            oModel.setDefaultBindingMode("TwoWay");
            return oModel;
        }        
    };

});
