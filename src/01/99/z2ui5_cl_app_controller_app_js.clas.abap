CLASS z2ui5_cl_app_controller_App_js DEFINITION
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


CLASS z2ui5_cl_app_controller_App_js IMPLEMENTATION.

  METHOD get.

    result =              `sap.ui.define(["sap/ui/core/mvc/Controller",` && |\n|  &&
             `  "z2ui5/controller/View1.controller",` && |\n|  &&
             `], function (BaseController, Controller) {` && |\n|  &&
             `  return BaseController.extend("z2ui5.controller.App", {` && |\n|  &&
             `` && |\n|  &&
             `    onInit: async function () {` && |\n|  &&
             `` && |\n|  &&
             `      z2ui5.oConfig.pathname = this.getView().getModel().sServiceUrl;` && |\n|  &&
             `      if (z2ui5.oConfig.pathname == '_LOCAL_') { ` && |\n|  &&
             `          z2ui5.oConfig.pathname = window.location.href; ` && |\n|  &&
             `      };` && |\n|  &&
             `      ` && |\n|  &&
             `      z2ui5.oController = new Controller();` && |\n|  &&
             `      z2ui5.oController.setApp(this.getView().byId("app"));` && |\n|  &&
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
             `            const scrollDelegate = z2ui5.oView.byId(item.ID).getScrollDelegate();` && |\n|  &&
             `            item.SCROLLTO = scrollDelegate ? scrollDelegate.getScrollTop() : 0;` && |\n|  &&
             `          } catch {` && |\n|  &&
             `            try {` && |\n|  &&
             `              const element = document.getElementById(``${z2ui5.oView.byId(item.ID).getId()}-inner``);` && |\n|  &&
             `              item.SCROLLTO = element ? element.scrollTop : 0;` && |\n|  &&
             `            } catch {}` && |\n|  &&
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
             `            z2ui5.oView.byId(item.ID).scrollTo(item.SCROLLTO);` && |\n|  &&
             `          } catch {` && |\n|  &&
             `            try {` && |\n|  &&
             `              const element = document.getElementById(``${z2ui5.oView.byId(item.ID).getId()}-inner``);` && |\n|  &&
             `              if (element) element.scrollTop = item.SCROLLTO;` && |\n|  &&
             `            } catch {` && |\n|  &&
             `              setTimeout(() => {` && |\n|  &&
             `                z2ui5.oView.byId(item.ID).scrollTo(item.SCROLLTO);` && |\n|  &&
             `              }, 1);` && |\n|  &&
             `            }` && |\n|  &&
             `          }` && |\n|  &&
             `        });` && |\n|  &&
             `      }, 100);` && |\n|  &&
             `    }` && |\n|  &&
             `  });` && |\n|  &&
             `});` && |\n|  &&
             `` && |\n|  &&
             `` && |\n|  &&
             `` && |\n|  &&
             `sap.ui.define("z2ui5/Info", ["sap/ui/core/Control", "sap/ui/VersionInfo", "sap/ui/Device"], (Control` && |\n|  &&
             `, VersionInfo, Device) => {` && |\n|  &&
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
             `    async renderer(oRm, oControl) {` && |\n|  &&
             `` && |\n|  &&
             `      debugger;` && |\n|  &&
             `      let oDevice = z2ui5.oView.getModel("device").oData;` && |\n|  &&
             `      oControl.setProperty("device_phone", oDevice.system.phone);` && |\n|  &&
             `      oControl.setProperty("device_desktop", oDevice.system.desktop);` && |\n|  &&
             `      oControl.setProperty("device_tablet", oDevice.system.tablet);` && |\n|  &&
             `      oControl.setProperty("device_combi", oDevice.system.combi);` && |\n|  &&
             `      oControl.setProperty("device_height", oDevice.resize.height);` && |\n|  &&
             `      oControl.setProperty("device_width", oDevice.resize.width);` && |\n|  &&
             `      oControl.setProperty("device_os", oDevice.os.name);` && |\n|  &&
             `      oControl.setProperty("device_browser", oDevice.browser.name);` && |\n|  &&
             `       oControl.fireFinished();` && |\n|  &&
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
             `      var test = position.coords.longitude` && |\n|  &&
             `      this.setProperty("longitude", position.coords.longitude, true);` && |\n|  &&
             `      this.setProperty("latitude", position.coords.latitude, true);` && |\n|  &&
             `      this.setProperty("altitude", position.coords.altitude, true);` && |\n|  &&
             `      this.setProperty("accuracy", position.coords.accuracy, true);` && |\n|  &&
             `      this.setProperty("altitudeAccuracy", position.coords.altitudeAccuracy, true);` && |\n|  &&
             `      this.setProperty("speed", position.coords.speed, true);` && |\n|  &&
             `      this.setProperty("heading", position.coords.heading, true);` && |\n|  &&
             `      this.fireFinished();` && |\n|  &&
             `      //this.getParent().getParent().getModel().refresh();` && |\n|  &&
             `` && |\n|  &&
             `    },` && |\n|  &&
             `` && |\n|  &&
             `    async init() {` && |\n|  &&
             `` && |\n|  &&
             `      navigator.geolocation.getCurrentPosition(this.callbackPosition.bind(this));` && |\n|  &&
             `      //navigator.geolocation.watchPosition(this.callbackPosition.bind(this));` && |\n|  &&
             `` && |\n|  &&
             `    },` && |\n|  &&
             `` && |\n|  &&
             `    exit() {//clearWatch` && |\n|  &&
             `    },` && |\n|  &&
             `` && |\n|  &&
             `    onAfterRendering() {` && |\n|  &&
             `    },` && |\n|  &&
             `` && |\n|  &&
             `    renderer(oRm, oControl) {` && |\n|  &&
             `    }` && |\n|  &&
             `  });` && |\n|  &&
             `}` && |\n|  &&
             `);` && |\n|  &&
             `` && |\n|  &&
             `sap.ui.define("z2ui5/FileUploader", ["sap/ui/core/Control", "sap/m/Button", "sap/ui/unified/FileUplo` && |\n|  &&
             `ader", "sap/m/HBox"], function (Control, Button, FileUploader, HBox) {` && |\n|  &&
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
             `        uploadOnChange: true,` && |\n|  &&
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
             `sap.ui.define("z2ui5/MultiInputExt", ["sap/ui/core/Control", "sap/m/Token", "sap/ui/core/Core", "sap` && |\n|  &&
             `/ui/core/Element"], (Control, Token, Core, Element) => {` && |\n|  &&
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
             `          //  table = sap.ui.getCore().byId(document.getElementsByName(this.getProperty("MultiInputN` && |\n|  &&
             `ame"))[0].id.replace('-inner', ''));` && |\n|  &&
             `          table = Core.byId(Element.getElementsByName(this.getProperty("MultiInputName"))[0].id.repl` && |\n|  &&
             `ace('-inner', ''));` && |\n|  &&
             `` && |\n|  &&
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
             `    DateAbapTimestampToDate: (sTimestamp) => new sap.gantt.misc.Format.abapTimestampToDate(sTimestam` && |\n|  &&
             `p),` && |\n|  &&
             `    DateAbapDateToDateObject: (d) => new Date(d.slice(0, 4), parseInt(d.slice(4, 6)) - 1, d.slice(6,` && |\n|  &&
             ` 8)),` && |\n|  &&
             `    DateAbapDateTimeToDateObject: (d, t = '000000') => new Date(d.slice(0, 4), parseInt(d.slice(4, 6` && |\n|  &&
             `)) - 1, d.slice(6, 8), t.slice(0, 2), t.slice(2, 4), t.slice(4, 6)),` && |\n|  &&
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
             `sap.ui.define("z2ui5/Dirty", ["sap/ui/core/Control", "sap/ushell/Container"], (Control, Container) =` && |\n|  &&
             `> {` && |\n|  &&
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