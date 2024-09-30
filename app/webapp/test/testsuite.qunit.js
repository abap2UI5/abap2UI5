/* global window, parent, location */

// eslint-disable-next-line fiori-custom/sap-no-global-define
window.suite = function() {
	"use strict";

	// eslint-disable-next-line
	var oSuite = new parent.jsUnitTestSuite(),
		sContextPath = location.pathname.substring(0, location.pathname.lastIndexOf("/") + 1);

	oSuite.addTestPage(sContextPath + "unit/unitTests.qunit.html");
	oSuite.addTestPage(sContextPath + "integration/opaTests.qunit.html");

	return oSuite;
};