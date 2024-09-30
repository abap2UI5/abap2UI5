sap.ui.define([
	"./flpSandbox",
	"sap/ui/fl/FakeLrepConnectorLocalStorage",
	"sap/m/MessageBox"
], function (flpSandbox, FakeLrepConnectorLocalStorage, MessageBox) {
	"use strict";

	flpSandbox.init().then(function () {
		FakeLrepConnectorLocalStorage.enableFakeConnector();
	}, function (oError) {
		MessageBox.error(oError.message);
	});
});