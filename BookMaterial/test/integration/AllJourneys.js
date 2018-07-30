jQuery.sap.require("sap.ui.qunit.qunit-css");
jQuery.sap.require("sap.ui.thirdparty.qunit");
jQuery.sap.require("sap.ui.qunit.qunit-junit");
QUnit.config.autostart = false;

sap.ui.require([
		"sap/ui/test/Opa5",
		"comitedgst/test/integration/pages/Common",
		"sap/ui/test/opaQunit",
		"comitedgst/test/integration/pages/Worklist",
		"comitedgst/test/integration/pages/Object",
		"comitedgst/test/integration/pages/NotFound",
		"comitedgst/test/integration/pages/Browser",
		"comitedgst/test/integration/pages/App"
	], function (Opa5, Common) {
	"use strict";
	Opa5.extendConfig({
		arrangements: new Common(),
		viewNamespace: "comitedgst.view."
	});

	sap.ui.require([
		"comitedgst/test/integration/WorklistJourney",
		"comitedgst/test/integration/ObjectJourney",
		"comitedgst/test/integration/NavigationJourney",
		"comitedgst/test/integration/NotFoundJourney",
		"comitedgst/test/integration/FLPIntegrationJourney"
	], function () {
		QUnit.start();
	});
});