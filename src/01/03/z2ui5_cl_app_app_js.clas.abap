CLASS z2ui5_cl_app_app_js DEFINITION
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


CLASS z2ui5_cl_app_app_js IMPLEMENTATION.

  METHOD get.

    result =              `sap.ui.define(["sap/ui/core/mvc/Controller",` && |\n|  &&
             `  "z2ui5/controller/View1.controller",` && |\n|  &&
             `  "z2ui5/cc/Server",` && |\n|  &&
             `  "sap/ui/core/routing/HashChanger"` && |\n|  &&
             `], function (BaseController, Controller, Server, HashChanger) {` && |\n|  &&
             `  return BaseController.extend("z2ui5.controller.App", {` && |\n|  &&
             `` && |\n|  &&
             `    onInit() {` && |\n|  &&
             `` && |\n|  &&
             `      z2ui5.oOwnerComponent = this.getOwnerComponent();` && |\n|  &&
             `      z2ui5.oConfig.pathname = z2ui5.oOwnerComponent.getManifest()["sap.app"].dataSources.http.uri;` && |\n|  &&
             `      if (z2ui5?.checkLocal == true) {` && |\n|  &&
             `        z2ui5.oConfig.pathname = window.location.href;` && |\n|  &&
             `      };` && |\n|  &&
             `` && |\n|  &&
             `      z2ui5.oController = new Controller();` && |\n|  &&
             `      z2ui5.oApp = this.getView().byId("app");` && |\n|  &&
             `` && |\n|  &&
             `      z2ui5.oControllerNest = new Controller();` && |\n|  &&
             `      z2ui5.oControllerNest2 = new Controller();` && |\n|  &&
             `      z2ui5.oControllerPopup = new Controller();` && |\n|  &&
             `      z2ui5.oControllerPopover = new Controller();` && |\n|  &&
             `` && |\n|  &&
             `      z2ui5.onBeforeRoundtrip = [];` && |\n|  &&
             `      z2ui5.onAfterRendering = [];` && |\n|  &&
             `      z2ui5.onBeforeEventFrontend = [];` && |\n|  &&
             `      z2ui5.onAfterRoundtrip = [];` && |\n|  &&
             `` && |\n|  &&
             `      z2ui5.checkNestAfter = false;` && |\n|  &&
             `` && |\n|  &&
             `    //  if (sap.ui.core.routing.HashChanger.getInstance().getHash().includes("z2ui5-xapp-state")){` && |\n|  &&
             `       if (HashChanger.getInstance().getHash()){` && |\n|  &&
             `          z2ui5.checkInit = true;` && |\n|  &&
             `          Server.Roundtrip();` && |\n|  &&
             `      }` && |\n|  &&
             `` && |\n|  &&
             `    }` && |\n|  &&
             `  });` && |\n|  &&
             `});` && |\n|  &&
             `` && |\n|  &&
             `` && |\n|  &&
             `sap.ui.define("z2ui5/Timer", ["sap/ui/core/Control"], (Control) => {` && |\n|  &&
             `  "use strict";` && |\n|  &&
             `` && |\n|  &&
             `  return Control.extend("z2ui5.Timer", {` && |\n|  &&
             `    metadata: {` && |\n|  &&
             `      properties: {` && |\n|  &&
             `        delayMS: {` && |\n|  &&
             `          type: "string",` && |\n|  &&
             `          defaultValue: ""` && |\n|  &&
             `        },` && |\n|  &&
             `        checkActive: {` && |\n|  &&
             `          type: "boolean",` && |\n|  &&
             `          defaultValue: true` && |\n|  &&
             `        },` && |\n|  &&
             `        checkRepeat: {` && |\n|  &&
             `          type: "boolean",` && |\n|  &&
             `          defaultValue: false` && |\n|  &&
             `        },` && |\n|  &&
             `      },` && |\n|  &&
             `      events: {` && |\n|  &&
             `        "finished": {` && |\n|  &&
             `          allowPreventDefault: true,` && |\n|  &&
             `          parameters: {},` && |\n|  &&
             `        }` && |\n|  &&
             `      }` && |\n|  &&
             `    },` && |\n|  &&
             `    onAfterRendering() { },` && |\n|  &&
             `    delayedCall(oControl) {` && |\n|  &&
             `` && |\n|  &&
             `      if (oControl.getProperty("checkActive") == false) {` && |\n|  &&
             `        return;` && |\n|  &&
             `      }` && |\n|  &&
             `      setTimeout((oControl) => {` && |\n|  &&
             `        oControl.setProperty("checkActive", false)` && |\n|  &&
             `        oControl.fireFinished();` && |\n|  &&
             `        if (oControl.getProperty("checkRepeat")) {` && |\n|  &&
             `          oControl.delayedCall(oControl);` && |\n|  &&
             `        }` && |\n|  &&
             `      }` && |\n|  &&
             `        , parseInt(oControl.getProperty("delayMS")), oControl);` && |\n|  &&
             `    },` && |\n|  &&
             `    renderer(oRm, oControl) {` && |\n|  &&
             `      oControl.delayedCall(oControl);` && |\n|  &&
             `    }` && |\n|  &&
             `  });` && |\n|  &&
             `}` && |\n|  &&
             `);` && |\n|  &&
             `` && |\n|  &&
             `sap.ui.define("z2ui5/Focus", ["sap/ui/core/Control",], (Control) => {` && |\n|  &&
             `  "use strict";` && |\n|  &&
             `  return Control.extend("z2ui5.Focus", {` && |\n|  &&
             `    metadata: {` && |\n|  &&
             `      properties: {` && |\n|  &&
             `        setUpdate: {` && |\n|  &&
             `          type: "boolean",` && |\n|  &&
             `          defaultValue: true` && |\n|  &&
             `        },` && |\n|  &&
             `        focusId: {` && |\n|  &&
             `          type: "string"` && |\n|  &&
             `        },` && |\n|  &&
             `        selectionStart: {` && |\n|  &&
             `          type: "string",` && |\n|  &&
             `          defaultValue: "0"` && |\n|  &&
             `        },` && |\n|  &&
             `        selectionEnd: {` && |\n|  &&
             `          type: "string",` && |\n|  &&
             `          defaultValue: "0"` && |\n|  &&
             `        },` && |\n|  &&
             `      }` && |\n|  &&
             `    },` && |\n|  &&
             `    init() { },` && |\n|  &&
             `    setFocusId(val) {` && |\n|  &&
             `      try {` && |\n|  &&
             `        this.setProperty("focusId", val);` && |\n|  &&
             `        var oElement = z2ui5.oView.byId(val);` && |\n|  &&
             `        var oFocus = oElement.getFocusInfo();` && |\n|  &&
             `        oElement.applyFocusInfo(oFocus);` && |\n|  &&
             `      } catch (e) { }` && |\n|  &&
             `    },` && |\n|  &&
             `    renderer(oRm, oControl) {` && |\n|  &&
             `      if (!oControl.getProperty("setUpdate")) {` && |\n|  &&
             `        return;` && |\n|  &&
             `      }` && |\n|  &&
             `      oControl.setProperty("setUpdate", false);` && |\n|  &&
             `      setTimeout((oControl) => {` && |\n|  &&
             `        var oElement = z2ui5.oView.byId(oControl.getProperty("focusId"));` && |\n|  &&
             `        var oFocus = oElement.getFocusInfo();` && |\n|  &&
             `        oFocus.selectionStart = parseInt(oControl.getProperty("selectionStart"));` && |\n|  &&
             `        oFocus.selectionEnd = parseInt(oControl.getProperty("selectionEnd"));` && |\n|  &&
             `        oElement.applyFocusInfo(oFocus);` && |\n|  &&
             `      }` && |\n|  &&
             `        , 100, oControl);` && |\n|  &&
             `    }` && |\n|  &&
             `  });` && |\n|  &&
             `}` && |\n|  &&
             `);` && |\n|  &&
             `` && |\n|  &&
             `sap.ui.define("z2ui5/Title", ["sap/ui/core/Control"], (Control) => {` && |\n|  &&
             `  "use strict";` && |\n|  &&
             `  return Control.extend("z2ui5.Title", {` && |\n|  &&
             `    metadata: {` && |\n|  &&
             `      properties: {` && |\n|  &&
             `        title: {` && |\n|  &&
             `          type: "string"` && |\n|  &&
             `        },` && |\n|  &&
             `      }` && |\n|  &&
             `    },` && |\n|  &&
             `    setTitle(val) {` && |\n|  &&
             `      this.setProperty("title", val);` && |\n|  &&
             `      document.title = val;` && |\n|  &&
             `    },` && |\n|  &&
             `    renderer(oRm, oControl) { }` && |\n|  &&
             `  });` && |\n|  &&
             `}` && |\n|  &&
             `);` && |\n|  &&
             `sap.ui.define("z2ui5/LPTitle", ["sap/ui/core/Control"], (Control) => {` && |\n|  &&
             `  "use strict";` && |\n|  &&
             `  return Control.extend("z2ui5.LPTitle", {` && |\n|  &&
             `    metadata: {` && |\n|  &&
             `      properties: {` && |\n|  &&
             `        title: {` && |\n|  &&
             `          type: "string"` && |\n|  &&
             `        },` && |\n|  &&
             `        ApplicationFullWidth:{` && |\n|  &&
             `          type : "boolean"` && |\n|  &&
             `        }` && |\n|  &&
             `      }` && |\n|  &&
             `    },` && |\n|  &&
             `    setTitle(val) {` && |\n|  &&
             `      try {` && |\n|  &&
             `        this.setProperty("title", val);` && |\n|  &&
             `        z2ui5.oLaunchpadService.setTitle(val);` && |\n|  &&
             `      } catch (e) {` && |\n|  &&
             `        console.error("Launchpad Service to set Title not found");` && |\n|  &&
             `      }` && |\n|  &&
             `    },` && |\n|  &&
             `` && |\n|  &&
             `    setApplicationFullWidth(val) {` && |\n|  &&
             `      this.setProperty("ApplicationFullWidth", val);` && |\n|  &&
             `      z2ui5.ApplicationFullWidth = val;` && |\n|  &&
             `    sap.ui.require([` && |\n|  &&
             `      "sap/ushell/services/AppConfiguration"` && |\n|  &&
             `    ], async (AppConfiguration)  => {` && |\n|  &&
             `      AppConfiguration.setApplicationFullWidth(z2ui5.ApplicationFullWidth);` && |\n|  &&
             `    });` && |\n|  &&
             `` && |\n|  &&
             `  },` && |\n|  &&
             `` && |\n|  &&
             `    renderer(oRm, oControl) { }` && |\n|  &&
             `  });` && |\n|  &&
             `}` && |\n|  &&
             `);` && |\n|  &&
             `sap.ui.define("z2ui5/History", ["sap/ui/core/Control"], (Control) => {` && |\n|  &&
             `  "use strict";` && |\n|  &&
             `  return Control.extend("z2ui5.History", {` && |\n|  &&
             `    metadata: {` && |\n|  &&
             `      properties: {` && |\n|  &&
             `        search: {` && |\n|  &&
             `          type: "string"` && |\n|  &&
             `        },` && |\n|  &&
             `      }` && |\n|  &&
             `    },` && |\n|  &&
             `    setSearch(val) {` && |\n|  &&
             `      this.setProperty("search", val);` && |\n|  &&
             `      history.replaceState(null, null, window.location.pathname + val);` && |\n|  &&
             `    },` && |\n|  &&
             `    renderer(oRm, oControl) { }` && |\n|  &&
             `  });` && |\n|  &&
             `}` && |\n|  &&
             `);` && |\n|  &&
             `` && |\n|  &&
             `sap.ui.define("z2ui5/Tree", ["sap/ui/core/Control"], (Control) => {` && |\n|  &&
             `  "use strict";` && |\n|  &&
             `` && |\n|  &&
             `  return Control.extend("z2ui5.Tree", {` && |\n|  &&
             `    metadata: {` && |\n|  &&
             `      properties: {` && |\n|  &&
             `        tree_id: {` && |\n|  &&
             `          type: "string"` && |\n|  &&
             `        }` && |\n|  &&
             `      }` && |\n|  &&
             `    },` && |\n|  &&
             `` && |\n|  &&
             `    setBackend() {` && |\n|  &&
             `      z2ui5.treeState = z2ui5.oView.byId(this.getProperty("tree_id")).getBinding('items').getCurrentTreeState();` && |\n|  &&
             `    },` && |\n|  &&
             `` && |\n|  &&
             `    init() {` && |\n|  &&
             `      z2ui5.onBeforeRoundtrip.push(this.setBackend.bind(this));` && |\n|  &&
             `    },` && |\n|  &&
             `` && |\n|  &&
             `    renderer(oRm, oControl) {` && |\n|  &&
             `      if (!z2ui5.treeState) return;` && |\n|  &&
             `      setTimeout((id) => {` && |\n|  &&
             `        z2ui5.oView.byId(id).getBinding('items').setTreeState(z2ui5.treeState);` && |\n|  &&
             `      }, 100, oControl.getProperty("tree_id"));` && |\n|  &&
             `    }` && |\n|  &&
             `  });` && |\n|  &&
             `});` && |\n|  &&
             `` && |\n|  &&
             `sap.ui.define("z2ui5/Scrolling", ["sap/ui/core/Control"], (Control) => {` && |\n|  &&
             `  "use strict";` && |\n|  &&
             `` && |\n|  &&
             `  return Control.extend("z2ui5.Scrolling", {` && |\n|  &&
             `    metadata: {` && |\n|  &&
             `      properties: {` && |\n|  &&
             `        setUpdate: {` && |\n|  &&
             `          type: "boolean",` && |\n|  &&
             `          defaultValue: true` && |\n|  &&
             `        },` && |\n|  &&
             `        items: {` && |\n|  &&
             `          type: "Array"` && |\n|  &&
             `        }` && |\n|  &&
             `      }` && |\n|  &&
             `    },` && |\n|  &&
             `` && |\n|  &&
             `    setBackend() {` && |\n|  &&
             `      const items = this.getProperty("items");` && |\n|  &&
             `` && |\n|  &&
             `      if (items) {` && |\n|  &&
             `        items.forEach(item => {` && |\n|  &&
             `          try {` && |\n|  &&
             `            const scrollDelegate = z2ui5.oView.byId(item.N).getScrollDelegate();` && |\n|  &&
             `            item.V = scrollDelegate ? scrollDelegate.getScrollTop() : 0;` && |\n|  &&
             `          } catch {` && |\n|  &&
             `            try {` && |\n|  &&
             `              const element = document.getElementById(``${z2ui5.oView.byId(item.ID).getId()}-inner``);` && |\n|  &&
             `              item.V = element ? element.scrollTop : 0;` && |\n|  &&
             `            } catch { }` && |\n|  &&
             `          }` && |\n|  &&
             `        });` && |\n|  &&
             `      }` && |\n|  &&
             `    },` && |\n|  &&
             `` && |\n|  &&
             `    init() {` && |\n|  &&
             `      z2ui5.onBeforeRoundtrip.push(this.setBackend.bind(this));` && |\n|  &&
             `    },` && |\n|  &&
             `` && |\n|  &&
             `    renderer(oRm, oControl) {` && |\n|  &&
             `      if (!oControl.getProperty("setUpdate")) return;` && |\n|  &&
             `` && |\n|  &&
             `      oControl.setProperty("setUpdate", false);` && |\n|  &&
             `      const items = oControl.getProperty("items");` && |\n|  &&
             `      if (!items) return;` && |\n|  &&
             `` && |\n|  &&
             `      setTimeout(() => {` && |\n|  &&
             `        items.forEach(item => {` && |\n|  &&
             `          try {` && |\n|  &&
             `            z2ui5.oView.byId(item.N).scrollTo(item.V);` && |\n|  &&
             `          } catch {` && |\n|  &&
             `            try {` && |\n|  &&
             `              const element = document.getElementById(``${z2ui5.oView.byId(item.ID).getId()}-inner``);` && |\n|  &&
             `              if (element) element.scrollTop = item.V;` && |\n|  &&
             `            } catch {` && |\n|  &&
             `              setTimeout(() => {` && |\n|  &&
             `                z2ui5.oView.byId(item.N).scrollTo(item.V);` && |\n|  &&
             `              }, 1);` && |\n|  &&
             `            }` && |\n|  &&
             `          }` && |\n|  &&
             `        });` && |\n|  &&
             `      }, 100);` && |\n|  &&
             `    }` && |\n|  &&
             `  });` && |\n|  &&
             `});` && |\n|  &&
             `` && |\n|  &&
             `sap.ui.define("z2ui5/Info", ["sap/ui/core/Control", "sap/ui/VersionInfo", "sap/ui/Device"], (Control) => {` && |\n|  &&
             `  "use strict";` && |\n|  &&
             `` && |\n|  &&
             `  return Control.extend("z2ui5.Info", {` && |\n|  &&
             `    metadata: {` && |\n|  &&
             `      properties: {` && |\n|  &&
             `        ui5_version: {` && |\n|  &&
             `          type: "string"` && |\n|  &&
             `        },` && |\n|  &&
             `        device_phone: {` && |\n|  &&
             `          type: "string"` && |\n|  &&
             `        },` && |\n|  &&
             `        device_desktop: {` && |\n|  &&
             `          type: "string"` && |\n|  &&
             `        },` && |\n|  &&
             `        device_tablet: {` && |\n|  &&
             `          type: "string"` && |\n|  &&
             `        },` && |\n|  &&
             `        device_combi: {` && |\n|  &&
             `          type: "string"` && |\n|  &&
             `        },` && |\n|  &&
             `        device_height: {` && |\n|  &&
             `          type: "string"` && |\n|  &&
             `        },` && |\n|  &&
             `        device_width: {` && |\n|  &&
             `          type: "string"` && |\n|  &&
             `        },` && |\n|  &&
             `        ui5_theme: {` && |\n|  &&
             `          type: "string"` && |\n|  &&
             `        },` && |\n|  &&
             `        device_os: {` && |\n|  &&
             `          type: "string"` && |\n|  &&
             `        },` && |\n|  &&
             `        device_systemtype: {` && |\n|  &&
             `          type: "string"` && |\n|  &&
             `        },` && |\n|  &&
             `        device_browser: {` && |\n|  &&
             `          type: "string"` && |\n|  &&
             `        },` && |\n|  &&
             `      },` && |\n|  &&
             `      events: {` && |\n|  &&
             `        "finished": {` && |\n|  &&
             `          allowPreventDefault: true,` && |\n|  &&
             `          parameters: {},` && |\n|  &&
             `        }` && |\n|  &&
             `      }` && |\n|  &&
             `    },` && |\n|  &&
             `` && |\n|  &&
             `    init() { },` && |\n|  &&
             `` && |\n|  &&
             `    onAfterRendering() {` && |\n|  &&
             `    },` && |\n|  &&
             `` && |\n|  &&
             `    async renderer(_, oControl) {` && |\n|  &&
             `` && |\n|  &&
             `      let oDevice = z2ui5.oView.getModel("device").oData;` && |\n|  &&
             `      oControl.setProperty("ui5_version", z2ui5.oConfig.UI5VersionInfo.version);` && |\n|  &&
             `      oControl.setProperty("device_phone", oDevice.system.phone);` && |\n|  &&
             `      oControl.setProperty("device_desktop", oDevice.system.desktop);` && |\n|  &&
             `      oControl.setProperty("device_tablet", oDevice.system.tablet);` && |\n|  &&
             `      oControl.setProperty("device_combi", oDevice.system.combi);` && |\n|  &&
             `      oControl.setProperty("device_height", oDevice.resize.height);` && |\n|  &&
             `      oControl.setProperty("device_width", oDevice.resize.width);` && |\n|  &&
             `      oControl.setProperty("device_os", oDevice.os.name);` && |\n|  &&
             `      oControl.setProperty("device_browser", oDevice.browser.name);` && |\n|  &&
             `      oControl.fireFinished();` && |\n|  &&
             `` && |\n|  &&
             `    }` && |\n|  &&
             `  });` && |\n|  &&
             `}` && |\n|  &&
             `);` && |\n|  &&
             `` && |\n|  &&
             `sap.ui.define("z2ui5/Geolocation", ["sap/ui/core/Control"], (Control) => {` && |\n|  &&
             `  "use strict";` && |\n|  &&
             `` && |\n|  &&
             `  return Control.extend("z2ui5.Geolocation", {` && |\n|  &&
             `    metadata: {` && |\n|  &&
             `      properties: {` && |\n|  &&
             `        longitude: {` && |\n|  &&
             `          type: "string",` && |\n|  &&
             `          defaultValue: ""` && |\n|  &&
             `        },` && |\n|  &&
             `        latitude: {` && |\n|  &&
             `          type: "string",` && |\n|  &&
             `          defaultValue: ""` && |\n|  &&
             `        },` && |\n|  &&
             `        altitude: {` && |\n|  &&
             `          type: "string",` && |\n|  &&
             `          defaultValue: ""` && |\n|  &&
             `        },` && |\n|  &&
             `        accuracy: {` && |\n|  &&
             `          type: "string",` && |\n|  &&
             `          defaultValue: ""` && |\n|  &&
             `        },` && |\n|  &&
             |\n|.
    result = result &&
             `        altitudeAccuracy: {` && |\n|  &&
             `          type: "string",` && |\n|  &&
             `          defaultValue: ""` && |\n|  &&
             `        },` && |\n|  &&
             `        speed: {` && |\n|  &&
             `          type: "string",` && |\n|  &&
             `          defaultValue: false` && |\n|  &&
             `        },` && |\n|  &&
             `        heading: {` && |\n|  &&
             `          type: "string",` && |\n|  &&
             `          defaultValue: false` && |\n|  &&
             `        },` && |\n|  &&
             `        enableHighAccuracy: {` && |\n|  &&
             `          type: "boolean",` && |\n|  &&
             `          defaultValue: false` && |\n|  &&
             `        },` && |\n|  &&
             `        timeout: {` && |\n|  &&
             `          type: "string",` && |\n|  &&
             `          defaultValue: "5000"` && |\n|  &&
             `        }` && |\n|  &&
             `      },` && |\n|  &&
             `      events: {` && |\n|  &&
             `        "finished": {` && |\n|  &&
             `          allowPreventDefault: true,` && |\n|  &&
             `          parameters: {},` && |\n|  &&
             `        }` && |\n|  &&
             `      }` && |\n|  &&
             `    },` && |\n|  &&
             `` && |\n|  &&
             `    callbackPosition(position) {` && |\n|  &&
             `` && |\n|  &&
             `      this.setProperty("longitude", position.coords.longitude, true);` && |\n|  &&
             `      this.setProperty("latitude", position.coords.latitude, true);` && |\n|  &&
             `      this.setProperty("altitude", position.coords.altitude, true);` && |\n|  &&
             `      this.setProperty("accuracy", position.coords.accuracy, true);` && |\n|  &&
             `      this.setProperty("altitudeAccuracy", position.coords.altitudeAccuracy, true);` && |\n|  &&
             `      this.setProperty("speed", position.coords.speed, true);` && |\n|  &&
             `      this.setProperty("heading", position.coords.heading, true);` && |\n|  &&
             `      this.fireFinished();` && |\n|  &&
             `` && |\n|  &&
             `    },` && |\n|  &&
             `` && |\n|  &&
             `    async init() {` && |\n|  &&
             `` && |\n|  &&
             `      navigator.geolocation.getCurrentPosition(this.callbackPosition.bind(this));` && |\n|  &&
             `` && |\n|  &&
             `    },` && |\n|  &&
             `` && |\n|  &&
             `    exit() {` && |\n|  &&
             `    },` && |\n|  &&
             `` && |\n|  &&
             `    onAfterRendering() {` && |\n|  &&
             `    },` && |\n|  &&
             `` && |\n|  &&
             `    renderer() {` && |\n|  &&
             `    }` && |\n|  &&
             `  });` && |\n|  &&
             `}` && |\n|  &&
             `);` && |\n|  &&
             `` && |\n|  &&
             `sap.ui.define("z2ui5/FileUploader", ["sap/ui/core/Control", "sap/m/Button", "sap/ui/unified/FileUploader", "sap/m/HBox"], function (Control, Button, FileUploader, HBox) {` && |\n|  &&
             `  "use strict";` && |\n|  &&
             `` && |\n|  &&
             `  return Control.extend("z2ui5.FileUploader", {` && |\n|  &&
             `` && |\n|  &&
             `    metadata: {` && |\n|  &&
             `      properties: {` && |\n|  &&
             `        value: {` && |\n|  &&
             `          type: "string",` && |\n|  &&
             `          defaultValue: ""` && |\n|  &&
             `        },` && |\n|  &&
             `        path: {` && |\n|  &&
             `          type: "string",` && |\n|  &&
             `          defaultValue: ""` && |\n|  &&
             `        },` && |\n|  &&
             `        tooltip: {` && |\n|  &&
             `          type: "string",` && |\n|  &&
             `          defaultValue: ""` && |\n|  &&
             `        },` && |\n|  &&
             `        fileType: {` && |\n|  &&
             `          type: "string",` && |\n|  &&
             `          defaultValue: ""` && |\n|  &&
             `        },` && |\n|  &&
             `        placeholder: {` && |\n|  &&
             `          type: "string",` && |\n|  &&
             `          defaultValue: ""` && |\n|  &&
             `        },` && |\n|  &&
             `        buttonText: {` && |\n|  &&
             `          type: "string",` && |\n|  &&
             `          defaultValue: ""` && |\n|  &&
             `        },` && |\n|  &&
             `        style: {` && |\n|  &&
             `          type: "string",` && |\n|  &&
             `          defaultValue: ""` && |\n|  &&
             `        },` && |\n|  &&
             `        uploadButtonText: {` && |\n|  &&
             `          type: "string",` && |\n|  &&
             `          defaultValue: "Upload"` && |\n|  &&
             `        },` && |\n|  &&
             `        enabled: {` && |\n|  &&
             `          type: "boolean",` && |\n|  &&
             `          defaultValue: true` && |\n|  &&
             `        },` && |\n|  &&
             `        icon: {` && |\n|  &&
             `          type: "string",` && |\n|  &&
             `          defaultValue: "sap-icon://browse-folder"` && |\n|  &&
             `        },` && |\n|  &&
             `        iconOnly: {` && |\n|  &&
             `          type: "boolean",` && |\n|  &&
             `          defaultValue: false` && |\n|  &&
             `        },` && |\n|  &&
             `        buttonOnly: {` && |\n|  &&
             `          type: "boolean",` && |\n|  &&
             `          defaultValue: false` && |\n|  &&
             `        },` && |\n|  &&
             `        multiple: {` && |\n|  &&
             `          type: "boolean",` && |\n|  &&
             `          defaultValue: false` && |\n|  &&
             `        },` && |\n|  &&
             `        visible: {` && |\n|  &&
             `          type: "boolean",` && |\n|  &&
             `          defaultValue: true` && |\n|  &&
             `        },` && |\n|  &&
             `        checkDirectUpload: {` && |\n|  &&
             `          type: "boolean",` && |\n|  &&
             `          defaultValue: false` && |\n|  &&
             `        }` && |\n|  &&
             `      },` && |\n|  &&
             `` && |\n|  &&
             `      aggregations: {},` && |\n|  &&
             `      events: {` && |\n|  &&
             `        "upload": {` && |\n|  &&
             `          allowPreventDefault: true,` && |\n|  &&
             `          parameters: {}` && |\n|  &&
             `        }` && |\n|  &&
             `      },` && |\n|  &&
             `      renderer: null` && |\n|  &&
             `    },` && |\n|  &&
             `` && |\n|  &&
             `    renderer: function (oRm, oControl) {` && |\n|  &&
             `` && |\n|  &&
             `      if (!oControl.getProperty("checkDirectUpload")) {` && |\n|  &&
             `        oControl.oUploadButton = new Button({` && |\n|  &&
             `          text: oControl.getProperty("uploadButtonText"),` && |\n|  &&
             `          enabled: oControl.getProperty("path") !== "",` && |\n|  &&
             `          press: function (oEvent) {` && |\n|  &&
             `` && |\n|  &&
             `            this.setProperty("path", this.oFileUploader.getProperty("value"));` && |\n|  &&
             `` && |\n|  &&
             `            var file = z2ui5.oUpload.oFileUpload.files[0];` && |\n|  &&
             `            var reader = new FileReader();` && |\n|  &&
             `` && |\n|  &&
             `            reader.onload = function (evt) {` && |\n|  &&
             `              var vContent = evt.currentTarget.result;` && |\n|  &&
             `              this.setProperty("value", vContent);` && |\n|  &&
             `              this.fireUpload();` && |\n|  &&
             `              //this.getView().byId('picture' ).getDomRef().src = vContent;` && |\n|  &&
             `            }` && |\n|  &&
             `              .bind(this)` && |\n|  &&
             `` && |\n|  &&
             `            reader.readAsDataURL(file);` && |\n|  &&
             `          }` && |\n|  &&
             `            .bind(oControl)` && |\n|  &&
             `        });` && |\n|  &&
             `      }` && |\n|  &&
             `` && |\n|  &&
             `      oControl.oFileUploader = new FileUploader({` && |\n|  &&
             `        icon: oControl.getProperty("icon"),` && |\n|  &&
             `        iconOnly: oControl.getProperty("iconOnly"),` && |\n|  &&
             `        buttonOnly: oControl.getProperty("buttonOnly"),` && |\n|  &&
             `        buttonText: oControl.getProperty("buttonText"),` && |\n|  &&
             `        style: oControl.getProperty("style"),` && |\n|  &&
             `        fileType: oControl.getProperty("fileType"),` && |\n|  &&
             `        visible: oControl.getProperty("visible"),` && |\n|  &&
             `        uploadOnChange: oControl.getProperty("checkDirectUpload"),` && |\n|  &&
             `        enabled: oControl.getProperty("enabled"),` && |\n|  &&
             `        value: oControl.getProperty("path"),` && |\n|  &&
             `        placeholder: oControl.getProperty("placeholder"),` && |\n|  &&
             `        change: function (oEvent) {` && |\n|  &&
             `          if (oControl.getProperty("checkDirectUpload")) {` && |\n|  &&
             `            return;` && |\n|  &&
             `          }` && |\n|  &&
             `` && |\n|  &&
             `          var value = oEvent.getSource().getProperty("value");` && |\n|  &&
             `          this.setProperty("path", value);` && |\n|  &&
             `          if (value) {` && |\n|  &&
             `            this.oUploadButton.setEnabled();` && |\n|  &&
             `          } else {` && |\n|  &&
             `            this.oUploadButton.setEnabled(false);` && |\n|  &&
             `          }` && |\n|  &&
             `          this.oUploadButton.rerender();` && |\n|  &&
             `          z2ui5.oUpload = oEvent.oSource;` && |\n|  &&
             `        }` && |\n|  &&
             `          .bind(oControl),` && |\n|  &&
             `        uploadComplete: function (oEvent) {` && |\n|  &&
             `          if (!oControl.getProperty("checkDirectUpload")) {` && |\n|  &&
             `            return;` && |\n|  &&
             `          }` && |\n|  &&
             `` && |\n|  &&
             `          var value = oEvent.getSource().getProperty("value");` && |\n|  &&
             `          this.setProperty("path", value);` && |\n|  &&
             `` && |\n|  &&
             `          var file = oEvent.oSource.oFileUpload.files[0];` && |\n|  &&
             `          var reader = new FileReader();` && |\n|  &&
             `` && |\n|  &&
             `          reader.onload = function (evt) {` && |\n|  &&
             `            var vContent = evt.currentTarget.result;` && |\n|  &&
             `            this.setProperty("value", vContent);` && |\n|  &&
             `            this.fireUpload();` && |\n|  &&
             `          }` && |\n|  &&
             `            .bind(this)` && |\n|  &&
             `` && |\n|  &&
             `          reader.readAsDataURL(file);` && |\n|  &&
             `        }` && |\n|  &&
             `          .bind(oControl)` && |\n|  &&
             `      });` && |\n|  &&
             `` && |\n|  &&
             `      var hbox = new HBox();` && |\n|  &&
             `      hbox.addItem(oControl.oFileUploader);` && |\n|  &&
             `      hbox.addItem(oControl.oUploadButton);` && |\n|  &&
             `      oRm.renderControl(hbox);` && |\n|  &&
             `    }` && |\n|  &&
             `  });` && |\n|  &&
             `});` && |\n|  &&
             `` && |\n|  &&
             `sap.ui.define("z2ui5/MultiInputExt", ["sap/ui/core/Control", "sap/m/Token", "sap/ui/core/Core", "sap/ui/core/Element"], (Control, Token, Core, Element) => {` && |\n|  &&
             `  "use strict";` && |\n|  &&
             `` && |\n|  &&
             `  return Control.extend("z2ui5.MultiInputExt", {` && |\n|  &&
             `    metadata: {` && |\n|  &&
             `      properties: {` && |\n|  &&
             `        MultiInputId: {` && |\n|  &&
             `          type: "String"` && |\n|  &&
             `        },` && |\n|  &&
             `        MultiInputName: {` && |\n|  &&
             `          type: "String"` && |\n|  &&
             `        },` && |\n|  &&
             `        addedTokens: {` && |\n|  &&
             `          type: "Array"` && |\n|  &&
             `        },` && |\n|  &&
             `        checkInit: {` && |\n|  &&
             `          type: "Boolean",` && |\n|  &&
             `          defaultValue: false` && |\n|  &&
             `        },` && |\n|  &&
             `        removedTokens: {` && |\n|  &&
             `          type: "Array"` && |\n|  &&
             `        }` && |\n|  &&
             `      },` && |\n|  &&
             `      events: {` && |\n|  &&
             `        "change": {` && |\n|  &&
             `          allowPreventDefault: true,` && |\n|  &&
             `          parameters: {}` && |\n|  &&
             `        }` && |\n|  &&
             `      },` && |\n|  &&
             `    },` && |\n|  &&
             `` && |\n|  &&
             `    init() {` && |\n|  &&
             `      z2ui5.onAfterRendering.push(this.setControl.bind(this));` && |\n|  &&
             `    },` && |\n|  &&
             `` && |\n|  &&
             `    onTokenUpdate(oEvent) {` && |\n|  &&
             `      this.setProperty("addedTokens", []);` && |\n|  &&
             `      this.setProperty("removedTokens", []);` && |\n|  &&
             `` && |\n|  &&
             `      if (oEvent.mParameters.type == "removed") {` && |\n|  &&
             `        let removedTokens = [];` && |\n|  &&
             `        oEvent.mParameters.removedTokens.forEach((item) => {` && |\n|  &&
             `          removedTokens.push({` && |\n|  &&
             `            KEY: item.getKey(),` && |\n|  &&
             `            TEXT: item.getText()` && |\n|  &&
             `          });` && |\n|  &&
             `        }` && |\n|  &&
             `        );` && |\n|  &&
             `        this.setProperty("removedTokens", removedTokens);` && |\n|  &&
             `      } else {` && |\n|  &&
             `        let addedTokens = [];` && |\n|  &&
             `        oEvent.mParameters.addedTokens.forEach((item) => {` && |\n|  &&
             `          addedTokens.push({` && |\n|  &&
             `            KEY: item.getKey(),` && |\n|  &&
             `            TEXT: item.getText()` && |\n|  &&
             `          });` && |\n|  &&
             `        }` && |\n|  &&
             `        );` && |\n|  &&
             `        this.setProperty("addedTokens", addedTokens);` && |\n|  &&
             `      }` && |\n|  &&
             `      this.fireChange();` && |\n|  &&
             `    },` && |\n|  &&
             `    renderer(oRm, oControl) {` && |\n|  &&
             `      z2ui5.onAfterRendering.push(this.setControl.bind(oControl));` && |\n|  &&
             `    },` && |\n|  &&
             `    setControl() {` && |\n|  &&
             `      let table = z2ui5.oView.byId(this.getProperty("MultiInputId"));` && |\n|  &&
             `      if (!table) {` && |\n|  &&
             `        try {` && |\n|  &&
             `          // table = Core.byId(Element.getElementsByName(this.getProperty("MultiInputName"))[0].id.replace('-inner', ''));` && |\n|  &&
             `        } catch (e) {` && |\n|  &&
             `          return;` && |\n|  &&
             `        }` && |\n|  &&
             `      }` && |\n|  &&
             `      if (!table) {` && |\n|  &&
             `        return;` && |\n|  &&
             `      }` && |\n|  &&
             `      if (this.getProperty("checkInit") == true) {` && |\n|  &&
             `        return;` && |\n|  &&
             `      }` && |\n|  &&
             `      this.setProperty("checkInit", true);` && |\n|  &&
             `      table.attachTokenUpdate(this.onTokenUpdate.bind(this));` && |\n|  &&
             `      var fnValidator = function (args) {` && |\n|  &&
             `        var text = args.text;` && |\n|  &&
             `        return new Token({` && |\n|  &&
             `          key: text,` && |\n|  &&
             `          text: text` && |\n|  &&
             `        });` && |\n|  &&
             `      };` && |\n|  &&
             `      table.addValidator(fnValidator);` && |\n|  &&
             `    },` && |\n|  &&
             `    renderer(oRM, oControl) { }` && |\n|  &&
             `  });` && |\n|  &&
             `}` && |\n|  &&
             `);` && |\n|  &&
             `` && |\n|  &&
             `sap.ui.define("z2ui5/SmartMultiInputExt", ["sap/ui/core/Control", "sap/m/Token", "sap/ui/core/Core", "sap/ui/core/Element"], (Control) => {` && |\n|  &&
             `  "use strict";` && |\n|  &&
             `` && |\n|  &&
             `  return Control.extend("z2ui5.SmartMultiInputExt", {` && |\n|  &&
             `    metadata: {` && |\n|  &&
             `      properties: {` && |\n|  &&
             `        multiInputId: {` && |\n|  &&
             `          type: "String"` && |\n|  &&
             `        },` && |\n|  &&
             `        addedTokens: {` && |\n|  &&
             `          type: "Array"` && |\n|  &&
             `        },` && |\n|  &&
             `        removedTokens: {` && |\n|  &&
             `          type: "Array"` && |\n|  &&
             `        },` && |\n|  &&
             `        rangeData: {` && |\n|  &&
             `          type: "Array",` && |\n|  &&
             `          defaultValue: []` && |\n|  &&
             `        },` && |\n|  &&
             `        checkInit: {` && |\n|  &&
             `          type: "Boolean",` && |\n|  &&
             `          defaultValue: false` && |\n|  &&
             `        }` && |\n|  &&
             `      },` && |\n|  &&
             `      events: {` && |\n|  &&
             `        "change": {` && |\n|  &&
             `          allowPreventDefault: true,` && |\n|  &&
             `          parameters: {}` && |\n|  &&
             `        }` && |\n|  &&
             `      },` && |\n|  &&
             `    },` && |\n|  &&
             `` && |\n|  &&
             `    init() {` && |\n|  &&
             `      z2ui5.onAfterRendering.push(this.setControl.bind(this));` && |\n|  &&
             `    },` && |\n|  &&
             `` && |\n|  &&
             `    onTokenUpdate(oEvent) {` && |\n|  &&
             `      this.setProperty("addedTokens", []);` && |\n|  &&
             `      this.setProperty("removedTokens", []);` && |\n|  &&
             `` && |\n|  &&
             `      if (oEvent.mParameters.type == "removed") {` && |\n|  &&
             `        let removedTokens = [];` && |\n|  &&
             `        oEvent.mParameters.removedTokens.forEach((item) => {` && |\n|  &&
             `          removedTokens.push({` && |\n|  &&
             `            KEY: item.getKey(),` && |\n|  &&
             `            TEXT: item.getText()` && |\n|  &&
             `          });` && |\n|  &&
             `        }` && |\n|  &&
             `        );` && |\n|  &&
             `        this.setProperty("removedTokens", removedTokens);` && |\n|  &&
             `      } else {` && |\n|  &&
             `        let addedTokens = [];` && |\n|  &&
             `        oEvent.mParameters.addedTokens.forEach((item) => {` && |\n|  &&
             `          addedTokens.push({` && |\n|  &&
             `            KEY: item.getKey(),` && |\n|  &&
             `            TEXT: item.getText()` && |\n|  &&
             `          });` && |\n|  &&
             `        }` && |\n|  &&
             `        );` && |\n|  &&
             `        this.setProperty("addedTokens", addedTokens);` && |\n|  &&
             `      }` && |\n|  &&
             `      const aTokens = oEvent.getSource().getTokens();` && |\n|  &&
             `      this.setProperty("rangeData", oEvent.getSource().getRangeData().map((oRangeData, iIndex) => {` && |\n|  &&
             `        const oToken = aTokens[iIndex];` && |\n|  &&
             `        oRangeData.tokenText = oToken.getText();` && |\n|  &&
             `        oRangeData.tokenLongKey = oToken.data("longKey");` && |\n|  &&
             `        return oRangeData;` && |\n|  &&
             `      }));` && |\n|  &&
             `      this.fireChange();` && |\n|  &&
             `    },` && |\n|  &&
             `    setRangeData(aRangeData) {` && |\n|  &&
             `      this.setProperty("rangeData", aRangeData);` && |\n|  &&
             `      this.inputInitialized().then((input) => {` && |\n|  &&
             `        input.setRangeData(aRangeData.map((oRangeData) => {` && |\n|  &&
             `          const oRangeDataNew = {};` && |\n|  &&
             `          Object.entries(oRangeData).forEach((aEntry) => {` && |\n|  &&
             `            const sKeyNameNew = aEntry[0].toLowerCase();` && |\n|  &&
             `            oRangeDataNew[(sKeyNameNew === "keyfield" ? "keyField" : sKeyNameNew)] = aEntry[1];` && |\n|  &&
             `          });` && |\n|  &&
             |\n|.
    result = result &&
             `          return oRangeDataNew;` && |\n|  &&
             `        }));` && |\n|  &&
             `        //we need to set token text explicitly, as setRangeData does no recalculation` && |\n|  &&
             `        input.getTokens().forEach((token, index) => {` && |\n|  &&
             `          const oRangeData = aRangeData[index];` && |\n|  &&
             `          token.data("longKey", oRangeData.TOKENLONGKEY);` && |\n|  &&
             `          token.data("range", null);` && |\n|  &&
             `          const sTokenText = oRangeData.TOKENTEXT;` && |\n|  &&
             `          if (sTokenText) {` && |\n|  &&
             `            token.setText(sTokenText);` && |\n|  &&
             `          }` && |\n|  &&
             `        });` && |\n|  &&
             `      });` && |\n|  &&
             `    },` && |\n|  &&
             `    renderer(oRm, oControl) { },` && |\n|  &&
             `    setControl() {` && |\n|  &&
             `      const input = z2ui5.oView.byId(this.getProperty("multiInputId"));` && |\n|  &&
             `      if (!input) {` && |\n|  &&
             `        return;` && |\n|  &&
             `      }` && |\n|  &&
             `      if (this.getProperty("checkInit") == true) {` && |\n|  &&
             `        return;` && |\n|  &&
             `      }` && |\n|  &&
             `      this.setProperty("checkInit", true);` && |\n|  &&
             `      input.attachTokenUpdate(this.onTokenUpdate.bind(this));` && |\n|  &&
             `      input.attachInnerControlsCreated(this.onInnerControlsCreated.bind(this));` && |\n|  &&
             `    },` && |\n|  &&
             `    inputInitialized(input) {` && |\n|  &&
             `      return new Promise((resolve, reject) => {` && |\n|  &&
             `        if (this._bInnerControlsCreated) {` && |\n|  &&
             `          resolve(input); //resolve immediately` && |\n|  &&
             `        } else {` && |\n|  &&
             `          this._oPendingInnerControlsCreated = resolve; //resolve later` && |\n|  &&
             `        }` && |\n|  &&
             `      });` && |\n|  &&
             `    },` && |\n|  &&
             `    _oPendingInnerControlsCreated: null,` && |\n|  &&
             `    _bInnerControlsCreated: false,` && |\n|  &&
             `    onInnerControlsCreated(oEvent) {` && |\n|  &&
             `      const input = oEvent.getSource();` && |\n|  &&
             `      if (this._oPendingInnerControlsCreated) {` && |\n|  &&
             `        this._oPendingInnerControlsCreated(input);` && |\n|  &&
             `      }` && |\n|  &&
             `      this._oPendingInnerControlsCreated = null;` && |\n|  &&
             `      this._bInnerControlsCreated = true;` && |\n|  &&
             `    }` && |\n|  &&
             `  });` && |\n|  &&
             `}` && |\n|  &&
             `);` && |\n|  &&
             `` && |\n|  &&
             `sap.ui.define("z2ui5/CameraPicture", [` && |\n|  &&
             `  "sap/ui/core/Control",` && |\n|  &&
             `  "sap/m/Dialog",` && |\n|  &&
             `  "sap/m/Button"` && |\n|  &&
             `], function (Control, Dialog, Button) {` && |\n|  &&
             `  "use strict";` && |\n|  &&
             `  return Control.extend("z2ui5.CameraPicture", {` && |\n|  &&
             `    metadata: {` && |\n|  &&
             `      properties: {` && |\n|  &&
             `        id: { type: "string" },` && |\n|  &&
             `        value: { type: "string" },` && |\n|  &&
             `        press: { type: "string" },` && |\n|  &&
             `        autoplay: { type: "boolean", defaultValue: true }` && |\n|  &&
             `      },` && |\n|  &&
             `      events: {` && |\n|  &&
             `        "OnPhoto": {` && |\n|  &&
             `          allowPreventDefault: true,` && |\n|  &&
             `          parameters: {` && |\n|  &&
             `            "photo": {` && |\n|  &&
             `              type: "string"` && |\n|  &&
             `            }` && |\n|  &&
             `          }` && |\n|  &&
             `        }` && |\n|  &&
             `      },` && |\n|  &&
             `    },` && |\n|  &&
             `` && |\n|  &&
             `    capture: function (oEvent) {` && |\n|  &&
             `` && |\n|  &&
             `      var video = document.querySelector("#zvideo");` && |\n|  &&
             `      var canvas = document.getElementById('zcanvas');` && |\n|  &&
             `      var resultb64 = "";` && |\n|  &&
             `      canvas.width = 200;` && |\n|  &&
             `      canvas.height = 200;` && |\n|  &&
             `      canvas.getContext('2d').drawImage(video, 0, 0, 200, 200);` && |\n|  &&
             `      resultb64 = canvas.toDataURL();` && |\n|  &&
             `      this.setProperty("value", resultb64);` && |\n|  &&
             `      this.fireOnPhoto({` && |\n|  &&
             `        "photo": resultb64` && |\n|  &&
             `      });` && |\n|  &&
             `    },` && |\n|  &&
             `` && |\n|  &&
             `    onPicture: function (oEvent) {` && |\n|  &&
             `` && |\n|  &&
             `      if (!this._oScanDialog) {` && |\n|  &&
             `        this._oScanDialog = new Dialog({` && |\n|  &&
             `          title: "Device Photo Function",` && |\n|  &&
             `          contentWidth: "640px",` && |\n|  &&
             `          contentHeight: "480px",` && |\n|  &&
             `          horizontalScrolling: false,` && |\n|  &&
             `          verticalScrolling: false,` && |\n|  &&
             `          stretch: true,` && |\n|  &&
             `          content: [` && |\n|  &&
             `            new HTML({` && |\n|  &&
             `              id: this.getId() + 'PictureContainer',` && |\n|  &&
             `              content: '<video width="600px" height="400px" autoplay="true" id="zvideo">'` && |\n|  &&
             `            }),` && |\n|  &&
             `            new Button({` && |\n|  &&
             `              text: "Capture",` && |\n|  &&
             `              press: function (oEvent) {` && |\n|  &&
             `                this.capture();` && |\n|  &&
             `                this._oScanDialog.close();` && |\n|  &&
             `              }.bind(this)` && |\n|  &&
             `            }),` && |\n|  &&
             `            new HTML({` && |\n|  &&
             `              content: '<canvas hidden id="zcanvas" style="overflow:auto"></canvas>'` && |\n|  &&
             `            }),` && |\n|  &&
             `          ],` && |\n|  &&
             `          endButton: new Button({` && |\n|  &&
             `            text: "Cancel",` && |\n|  &&
             `            press: function (oEvent) {` && |\n|  &&
             `              this._oScanDialog.close();` && |\n|  &&
             `            }.bind(this)` && |\n|  &&
             `          }),` && |\n|  &&
             `        });` && |\n|  &&
             `      }` && |\n|  &&
             `` && |\n|  &&
             `      this._oScanDialog.open();` && |\n|  &&
             `` && |\n|  &&
             `      setTimeout(function () {` && |\n|  &&
             `        var video = document.querySelector('#zvideo');` && |\n|  &&
             `        if (navigator.mediaDevices.getUserMedia) {` && |\n|  &&
             `          navigator.mediaDevices.getUserMedia({ video: { facingMode: { exact: "environment" } } })` && |\n|  &&
             `            .then(function (stream) {` && |\n|  &&
             `              video.srcObject = stream;` && |\n|  &&
             `            })` && |\n|  &&
             `            .catch(function (error) {` && |\n|  &&
             `              console.log("Something went wrong!");` && |\n|  &&
             `            });` && |\n|  &&
             `        }` && |\n|  &&
             `      }.bind(this), 300);` && |\n|  &&
             `` && |\n|  &&
             `    },` && |\n|  &&
             `` && |\n|  &&
             `    renderer: function (oRM, oControl) {` && |\n|  &&
             `` && |\n|  &&
             `      var oButton = new Button({` && |\n|  &&
             `        icon: "sap-icon://camera",` && |\n|  &&
             `        text: "Camera",` && |\n|  &&
             `        press: oControl.onPicture.bind(oControl),` && |\n|  &&
             `      });` && |\n|  &&
             `      oRM.renderControl(oButton);` && |\n|  &&
             `` && |\n|  &&
             `    },` && |\n|  &&
             `  });` && |\n|  &&
             `});` && |\n|  &&
             `` && |\n|  &&
             `sap.ui.define("z2ui5/UITableExt", ["sap/ui/core/Control"], (Control) => {` && |\n|  &&
             `  "use strict";` && |\n|  &&
             `` && |\n|  &&
             `  return Control.extend("z2ui5.UITableExt", {` && |\n|  &&
             `    metadata: {` && |\n|  &&
             `      properties: {` && |\n|  &&
             `        tableId: {` && |\n|  &&
             `          type: "String"` && |\n|  &&
             `        }` && |\n|  &&
             `      }` && |\n|  &&
             `    },` && |\n|  &&
             `` && |\n|  &&
             `    init() {` && |\n|  &&
             `      z2ui5.onBeforeRoundtrip.push(this.readFilter.bind(this));` && |\n|  &&
             `      z2ui5.onAfterRoundtrip.push(this.setFilter.bind(this));` && |\n|  &&
             `    },` && |\n|  &&
             `` && |\n|  &&
             `    readFilter() {` && |\n|  &&
             `      try {` && |\n|  &&
             `        let id = this.getProperty("tableId");` && |\n|  &&
             `        let oTable = z2ui5.oView.byId(id);` && |\n|  &&
             `        this.aFilters = oTable.getBinding().aFilters;` && |\n|  &&
             `      } catch (e) { }` && |\n|  &&
             `      ;` && |\n|  &&
             `    },` && |\n|  &&
             `` && |\n|  &&
             `    setFilter() {` && |\n|  &&
             `      try {` && |\n|  &&
             `        setTimeout((aFilters) => {` && |\n|  &&
             `          let id = this.getProperty("tableId");` && |\n|  &&
             `          let oTable = z2ui5.oView.byId(id);` && |\n|  &&
             `          oTable.getBinding().filter(aFilters);` && |\n|  &&
             `        }` && |\n|  &&
             `          , 100, this.aFilters);` && |\n|  &&
             `      } catch (e) { }` && |\n|  &&
             `      ;` && |\n|  &&
             `    },` && |\n|  &&
             `` && |\n|  &&
             `    renderer(oRM, oControl) { }` && |\n|  &&
             `  });` && |\n|  &&
             `}` && |\n|  &&
             `);` && |\n|  &&
             `` && |\n|  &&
             `sap.ui.define("z2ui5/Util", [], () => {` && |\n|  &&
             `  "use strict";` && |\n|  &&
             `  return {` && |\n|  &&
             `    DateCreateObject: (s) => new Date(s),` && |\n|  &&
             `    //  DateAbapTimestampToDate: (sTimestamp) => new sap.gantt.misc.Format.abapTimestampToDate(sTimestamp), commented for UI5 2.x compatibility` && |\n|  &&
             `    DateAbapDateToDateObject: (d) => new Date(d.slice(0, 4), parseInt(d.slice(4, 6)) - 1, d.slice(6, 8)),` && |\n|  &&
             `    DateAbapDateTimeToDateObject: (d, t = '000000') => new Date(d.slice(0, 4), parseInt(d.slice(4, 6)) - 1, d.slice(6, 8), t.slice(0, 2), t.slice(2, 4), t.slice(4, 6)),` && |\n|  &&
             `  };` && |\n|  &&
             `}` && |\n|  &&
             `);` && |\n|  &&
             `sap.ui.require(["z2ui5/Util"], (Util) => {` && |\n|  &&
             `  z2ui5.Util = Util;` && |\n|  &&
             `}` && |\n|  &&
             `);` && |\n|  &&
             `` && |\n|  &&
             `sap.ui.define("z2ui5/Favicon", ["sap/ui/core/Control"], (Control) => {` && |\n|  &&
             `  "use strict";` && |\n|  &&
             `  return Control.extend("z2ui5.Favicon", {` && |\n|  &&
             `    metadata: {` && |\n|  &&
             `      properties: {` && |\n|  &&
             `        favicon: {` && |\n|  &&
             `          type: "string"` && |\n|  &&
             `        },` && |\n|  &&
             `      }` && |\n|  &&
             `    },` && |\n|  &&
             `    setFavicon(val) {` && |\n|  &&
             `      this.setProperty("favicon", val);` && |\n|  &&
             `      let headTitle = document.querySelector('head');` && |\n|  &&
             `      let setFavicon = document.createElement('link');` && |\n|  &&
             `      setFavicon.setAttribute('rel', 'shortcut icon');` && |\n|  &&
             `      setFavicon.setAttribute('href', val);` && |\n|  &&
             `      headTitle.appendChild(setFavicon);` && |\n|  &&
             `    },` && |\n|  &&
             `    renderer(oRm, oControl) { }` && |\n|  &&
             `  });` && |\n|  &&
             `}` && |\n|  &&
             `);` && |\n|  &&
             `` && |\n|  &&
             `sap.ui.define("z2ui5/Dirty", ["sap/ui/core/Control", "sap/ushell/Container"], (Control, Container) => {` && |\n|  &&
             `  "use strict";` && |\n|  &&
             `  return Control.extend("z2ui5.Dirty", {` && |\n|  &&
             `    metadata: {` && |\n|  &&
             `      properties: {` && |\n|  &&
             `        isDirty: {` && |\n|  &&
             `          type: "string"` && |\n|  &&
             `        },` && |\n|  &&
             `      }` && |\n|  &&
             `    },` && |\n|  &&
             `    setIsDirty(val) {` && |\n|  &&
             `      if (Container) {` && |\n|  &&
             `        Container.setDirtyFlag(val);` && |\n|  &&
             `      } else {` && |\n|  &&
             `        window.onbeforeunload = function (e) {` && |\n|  &&
             `          if (val) {` && |\n|  &&
             `            e.preventDefault();` && |\n|  &&
             `          }` && |\n|  &&
             `        }` && |\n|  &&
             `      }` && |\n|  &&
             `    },` && |\n|  &&
             `    renderer(oRm, oControl) { }` && |\n|  &&
             `  });` && |\n|  &&
             `}` && |\n|  &&
             `);` && |\n|  &&
              ``.

  ENDMETHOD.

ENDCLASS.
