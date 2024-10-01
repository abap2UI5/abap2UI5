sap.ui.define(["sap/ui/core/mvc/Controller",
  "z2ui5/controller/View1.controller",
], function (BaseController, Controller) {
  return BaseController.extend("z2ui5.controller.App", {

    onInit: async function () {

      z2ui5.oConfig.pathname = this.getView().getModel().sServiceUrl;
      if (z2ui5?.checkLocal == true ) { 
          z2ui5.oConfig.pathname = window.location.href; 
      };
      
      z2ui5.oController = new Controller();
      z2ui5.oController.setApp(this.getView().byId("app"));

      z2ui5.oControllerNest = new Controller();
      z2ui5.oControllerNest2 = new Controller();
      z2ui5.oControllerPopup = new Controller();
      z2ui5.oControllerPopover = new Controller();

      z2ui5.onBeforeRoundtrip = [];
      z2ui5.onAfterRendering = [];
      z2ui5.onBeforeEventFrontend = [];
      z2ui5.onAfterRoundtrip = [];

      z2ui5.checkNestAfter = false;

    }
  });
});


sap.ui.define("z2ui5/Timer", ["sap/ui/core/Control"], (Control) => {
  "use strict";

  return Control.extend("z2ui5.Timer", {
    metadata: {
      properties: {
        delayMS: {
          type: "string",
          defaultValue: ""
        },
        checkActive: {
          type: "boolean",
          defaultValue: true
        },
        checkRepeat: {
          type: "boolean",
          defaultValue: false
        },
      },
      events: {
        "finished": {
          allowPreventDefault: true,
          parameters: {},
        }
      }
    },
    onAfterRendering() { },
    delayedCall(oControl) {

      if (oControl.getProperty("checkActive") == false) {
        return;
      }
      setTimeout((oControl) => {
        oControl.setProperty("checkActive", false)
        oControl.fireFinished();
        if (oControl.getProperty("checkRepeat")) {
          oControl.delayedCall(oControl);
        }
      }
        , parseInt(oControl.getProperty("delayMS")), oControl);
    },
    renderer(oRm, oControl) {
      oControl.delayedCall(oControl);
    }
  });
}
);

sap.ui.define("z2ui5/Focus", ["sap/ui/core/Control",], (Control) => {
  "use strict";
  return Control.extend("z2ui5.Focus", {
    metadata: {
      properties: {
        setUpdate: {
          type: "boolean",
          defaultValue: true
        },
        focusId: {
          type: "string"
        },
        selectionStart: {
          type: "string",
          defaultValue: "0"
        },
        selectionEnd: {
          type: "string",
          defaultValue: "0"
        },
      }
    },
    init() { },
    setFocusId(val) {
      try {
        this.setProperty("focusId", val);
        var oElement = z2ui5.oView.byId(val);
        var oFocus = oElement.getFocusInfo();
        oElement.applyFocusInfo(oFocus);
      } catch (e) { }
    },
    renderer(oRm, oControl) {
      if (!oControl.getProperty("setUpdate")) {
        return;
      }
      oControl.setProperty("setUpdate", false);
      setTimeout((oControl) => {
        var oElement = z2ui5.oView.byId(oControl.getProperty("focusId"));
        var oFocus = oElement.getFocusInfo();
        oFocus.selectionStart = parseInt(oControl.getProperty("selectionStart"));
        oFocus.selectionEnd = parseInt(oControl.getProperty("selectionEnd"));
        oElement.applyFocusInfo(oFocus);
      }
        , 100, oControl);
    }
  });
}
);

sap.ui.define("z2ui5/Title", ["sap/ui/core/Control"], (Control) => {
  "use strict";
  return Control.extend("z2ui5.Title", {
    metadata: {
      properties: {
        title: {
          type: "string"
        },
      }
    },
    setTitle(val) {
      this.setProperty("title", val);
      document.title = val;
    },
    renderer(oRm, oControl) { }
  });
}
);
sap.ui.define("z2ui5/LPTitle", ["sap/ui/core/Control"], (Control) => {
  "use strict";
  return Control.extend("z2ui5.LPTitle", {
    metadata: {
      properties: {
        title: {
          type: "string"
        },
      }
    },
    setTitle(val) {
      try {
        this.setProperty("title", val);
        z2ui5.oLaunchpadService.setTitle(val);
      } catch (e) {
        console.error("Launchpad Service to set Title not found");
      }
    },
    renderer(oRm, oControl) { }
  });
}
);
sap.ui.define("z2ui5/History", ["sap/ui/core/Control"], (Control) => {
  "use strict";
  return Control.extend("z2ui5.History", {
    metadata: {
      properties: {
        search: {
          type: "string"
        },
      }
    },
    setSearch(val) {
      this.setProperty("search", val);
      history.replaceState(null, null, window.location.pathname + val);
    },
    renderer(oRm, oControl) { }
  });
}
);
sap.ui.define("z2ui5/Scrolling", ["sap/ui/core/Control"], (Control) => {
  "use strict";

  return Control.extend("z2ui5.Scrolling", {
    metadata: {
      properties: {
        setUpdate: {
          type: "boolean",
          defaultValue: true
        },
        items: {
          type: "Array"
        }
      }
    },

    setBackend() {
      const items = this.getProperty("items");

      if (items) {
        items.forEach(item => {
          try {
            const scrollDelegate = z2ui5.oView.byId(item.ID).getScrollDelegate();
            item.SCROLLTO = scrollDelegate ? scrollDelegate.getScrollTop() : 0;
          } catch {
            try {
              const element = document.getElementById(`${z2ui5.oView.byId(item.ID).getId()}-inner`);
              item.SCROLLTO = element ? element.scrollTop : 0;
            } catch {}
          }
        });
      }
    },

    init() {
      z2ui5.onBeforeRoundtrip.push(this.setBackend.bind(this));
    },

    renderer(oRm, oControl) {
      if (!oControl.getProperty("setUpdate")) return;

      oControl.setProperty("setUpdate", false);
      const items = oControl.getProperty("items");
      if (!items) return;

      setTimeout(() => {
        items.forEach(item => {
          try {
            z2ui5.oView.byId(item.ID).scrollTo(item.SCROLLTO);
          } catch {
            try {
              const element = document.getElementById(`${z2ui5.oView.byId(item.ID).getId()}-inner`);
              if (element) element.scrollTop = item.SCROLLTO;
            } catch {
              setTimeout(() => {
                z2ui5.oView.byId(item.ID).scrollTo(item.SCROLLTO);
              }, 1);
            }
          }
        });
      }, 100);
    }
  });
});



sap.ui.define("z2ui5/Info", ["sap/ui/core/Control", "sap/ui/VersionInfo", "sap/ui/Device"], (Control, VersionInfo, Device) => {
  "use strict";

  return Control.extend("z2ui5.Info", {
    metadata: {
      properties: {
        ui5_version: {
          type: "string"
        },
        device_phone: {
          type: "string"
        },
        device_desktop: {
          type: "string"
        },
        device_tablet: {
          type: "string"
        },
        device_combi: {
          type: "string"
        },
        device_height: {
          type: "string"
        },
        device_width: {
          type: "string"
        },
        ui5_theme: {
          type: "string"
        },
        device_os: {
          type: "string"
        },
        device_systemtype: {
          type: "string"
        },
        device_browser: {
          type: "string"
        },
      },
      events: {
        "finished": {
          allowPreventDefault: true,
          parameters: {},
        }
      }
    },

    init() { },

    onAfterRendering() {
    },

    async renderer(oRm, oControl) {

      debugger;
      let oDevice = z2ui5.oView.getModel("device").oData;
      oControl.setProperty("device_phone", oDevice.system.phone);
      oControl.setProperty("device_desktop", oDevice.system.desktop);
      oControl.setProperty("device_tablet", oDevice.system.tablet);
      oControl.setProperty("device_combi", oDevice.system.combi);
      oControl.setProperty("device_height", oDevice.resize.height);
      oControl.setProperty("device_width", oDevice.resize.width);
      oControl.setProperty("device_os", oDevice.os.name);
      oControl.setProperty("device_browser", oDevice.browser.name);
       oControl.fireFinished();

    }
  });
}
);

sap.ui.define("z2ui5/Geolocation", ["sap/ui/core/Control"], (Control) => {
  "use strict";

  return Control.extend("z2ui5.Geolocation", {
    metadata: {
      properties: {
        longitude: {
          type: "string",
          defaultValue: ""
        },
        latitude: {
          type: "string",
          defaultValue: ""
        },
        altitude: {
          type: "string",
          defaultValue: ""
        },
        accuracy: {
          type: "string",
          defaultValue: ""
        },
        altitudeAccuracy: {
          type: "string",
          defaultValue: ""
        },
        speed: {
          type: "string",
          defaultValue: false
        },
        heading: {
          type: "string",
          defaultValue: false
        },
        enableHighAccuracy: {
          type: "boolean",
          defaultValue: false
        },
        timeout: {
          type: "string",
          defaultValue: "5000"
        }
      },
      events: {
        "finished": {
          allowPreventDefault: true,
          parameters: {},
        }
      }
    },

    callbackPosition(position) {

      var test = position.coords.longitude
      this.setProperty("longitude", position.coords.longitude, true);
      this.setProperty("latitude", position.coords.latitude, true);
      this.setProperty("altitude", position.coords.altitude, true);
      this.setProperty("accuracy", position.coords.accuracy, true);
      this.setProperty("altitudeAccuracy", position.coords.altitudeAccuracy, true);
      this.setProperty("speed", position.coords.speed, true);
      this.setProperty("heading", position.coords.heading, true);
      this.fireFinished();
      //this.getParent().getParent().getModel().refresh();

    },

    async init() {

      navigator.geolocation.getCurrentPosition(this.callbackPosition.bind(this));
      //navigator.geolocation.watchPosition(this.callbackPosition.bind(this));

    },

    exit() {//clearWatch
    },

    onAfterRendering() {
    },

    renderer(oRm, oControl) {
    }
  });
}
);

sap.ui.define("z2ui5/FileUploader", ["sap/ui/core/Control", "sap/m/Button", "sap/ui/unified/FileUploader", "sap/m/HBox"], function (Control, Button, FileUploader, HBox) {
  "use strict";

  return Control.extend("z2ui5.FileUploader", {

    metadata: {
      properties: {
        value: {
          type: "string",
          defaultValue: ""
        },
        path: {
          type: "string",
          defaultValue: ""
        },
        tooltip: {
          type: "string",
          defaultValue: ""
        },
        fileType: {
          type: "string",
          defaultValue: ""
        },
        placeholder: {
          type: "string",
          defaultValue: ""
        },
        buttonText: {
          type: "string",
          defaultValue: ""
        },
        style: {
          type: "string",
          defaultValue: ""
        },
        uploadButtonText: {
          type: "string",
          defaultValue: "Upload"
        },
        enabled: {
          type: "boolean",
          defaultValue: true
        },
        icon: {
          type: "string",
          defaultValue: "sap-icon://browse-folder"
        },
        iconOnly: {
          type: "boolean",
          defaultValue: false
        },
        buttonOnly: {
          type: "boolean",
          defaultValue: false
        },
        multiple: {
          type: "boolean",
          defaultValue: false
        },
        visible: {
          type: "boolean",
          defaultValue: true
        },
        checkDirectUpload: {
          type: "boolean",
          defaultValue: false
        }
      },

      aggregations: {},
      events: {
        "upload": {
          allowPreventDefault: true,
          parameters: {}
        }
      },
      renderer: null
    },

    renderer: function (oRm, oControl) {

      if (!oControl.getProperty("checkDirectUpload")) {
        oControl.oUploadButton = new Button({
          text: oControl.getProperty("uploadButtonText"),
          enabled: oControl.getProperty("path") !== "",
          press: function (oEvent) {

            this.setProperty("path", this.oFileUploader.getProperty("value"));

            var file = z2ui5.oUpload.oFileUpload.files[0];
            var reader = new FileReader();

            reader.onload = function (evt) {
              var vContent = evt.currentTarget.result;
              this.setProperty("value", vContent);
              this.fireUpload();
              //this.getView().byId('picture' ).getDomRef().src = vContent;
            }
              .bind(this)

            reader.readAsDataURL(file);
          }
            .bind(oControl)
        });
      }

      oControl.oFileUploader = new FileUploader({
        icon: oControl.getProperty("icon"),
        iconOnly: oControl.getProperty("iconOnly"),
        buttonOnly: oControl.getProperty("buttonOnly"),
        buttonText: oControl.getProperty("buttonText"),
        style: oControl.getProperty("style"),
        fileType: oControl.getProperty("fileType"),
        visible: oControl.getProperty("visible"),
        uploadOnChange: true,
        enabled: oControl.getProperty("enabled"),
        value: oControl.getProperty("path"),
        placeholder: oControl.getProperty("placeholder"),
        change: function (oEvent) {
          if (oControl.getProperty("checkDirectUpload")) {
            return;
          }

          var value = oEvent.getSource().getProperty("value");
          this.setProperty("path", value);
          if (value) {
            this.oUploadButton.setEnabled();
          } else {
            this.oUploadButton.setEnabled(false);
          }
          this.oUploadButton.rerender();
          z2ui5.oUpload = oEvent.oSource;
        }
          .bind(oControl),
        uploadComplete: function (oEvent) {
          if (!oControl.getProperty("checkDirectUpload")) {
            return;
          }

          var value = oEvent.getSource().getProperty("value");
          this.setProperty("path", value);

          var file = oEvent.oSource.oFileUpload.files[0];
          var reader = new FileReader();

          reader.onload = function (evt) {
            var vContent = evt.currentTarget.result;
            this.setProperty("value", vContent);
            this.fireUpload();
          }
            .bind(this)

          reader.readAsDataURL(file);
        }
          .bind(oControl)
      });

      var hbox = new HBox();
      hbox.addItem(oControl.oFileUploader);
      hbox.addItem(oControl.oUploadButton);
      oRm.renderControl(hbox);
    }
  });
});

sap.ui.define("z2ui5/MultiInputExt", ["sap/ui/core/Control", "sap/m/Token", "sap/ui/core/Core", "sap/ui/core/Element"], (Control, Token, Core, Element) => {
  "use strict";

  return Control.extend("z2ui5.MultiInputExt", {
    metadata: {
      properties: {
        MultiInputId: {
          type: "String"
        },
        MultiInputName: {
          type: "String"
        },
        addedTokens: {
          type: "Array"
        },
        checkInit: {
          type: "Boolean",
          defaultValue: false
        },
        removedTokens: {
          type: "Array"
        }
      },
      events: {
        "change": {
          allowPreventDefault: true,
          parameters: {}
        }
      },
    },

    init() {
      z2ui5.onAfterRendering.push(this.setControl.bind(this));
    },

    onTokenUpdate(oEvent) {
      this.setProperty("addedTokens", []);
      this.setProperty("removedTokens", []);

      if (oEvent.mParameters.type == "removed") {
        let removedTokens = [];
        oEvent.mParameters.removedTokens.forEach((item) => {
          removedTokens.push({
            KEY: item.getKey(),
            TEXT: item.getText()
          });
        }
        );
        this.setProperty("removedTokens", removedTokens);
      } else {
        let addedTokens = [];
        oEvent.mParameters.addedTokens.forEach((item) => {
          addedTokens.push({
            KEY: item.getKey(),
            TEXT: item.getText()
          });
        }
        );
        this.setProperty("addedTokens", addedTokens);
      }
      this.fireChange();
    },
    renderer(oRm, oControl) {
      z2ui5.onAfterRendering.push(this.setControl.bind(oControl));
    },
    setControl() {
      let table = z2ui5.oView.byId(this.getProperty("MultiInputId"));
      if (!table) {
        try {
          table = Core.byId(Element.getElementsByName(this.getProperty("MultiInputName"))[0].id.replace('-inner', ''));
        } catch (e) {
          return;
        }
      }
      if (!table) {
        return;
      }
      if (this.getProperty("checkInit") == true) {
        return;
      }
      this.setProperty("checkInit", true);
      table.attachTokenUpdate(this.onTokenUpdate.bind(this));
      var fnValidator = function (args) {
        var text = args.text;
        return new Token({
          key: text,
          text: text
        });
      };
      table.addValidator(fnValidator);
    },
    renderer(oRM, oControl) { }
  });
}
);

sap.ui.define("z2ui5/UITableExt", ["sap/ui/core/Control"], (Control) => {
  "use strict";

  return Control.extend("z2ui5.UITableExt", {
    metadata: {
      properties: {
        tableId: {
          type: "String"
        }
      }
    },

    init() {
      z2ui5.onBeforeRoundtrip.push(this.readFilter.bind(this));
      z2ui5.onAfterRoundtrip.push(this.setFilter.bind(this));
    },

    readFilter() {
      try {
        let id = this.getProperty("tableId");
        let oTable = z2ui5.oView.byId(id);
        this.aFilters = oTable.getBinding().aFilters;
      } catch (e) { }
      ;
    },

    setFilter() {
      try {
        setTimeout((aFilters) => {
          let id = this.getProperty("tableId");
          let oTable = z2ui5.oView.byId(id);
          oTable.getBinding().filter(aFilters);
        }
          , 100, this.aFilters);
      } catch (e) { }
      ;
    },

    renderer(oRM, oControl) { }
  });
}
);

sap.ui.define("z2ui5/Util", [], () => {
  "use strict";
  return {
    DateCreateObject: (s) => new Date(s),
    DateAbapTimestampToDate: (sTimestamp) => new sap.gantt.misc.Format.abapTimestampToDate(sTimestamp),
    DateAbapDateToDateObject: (d) => new Date(d.slice(0, 4), parseInt(d.slice(4, 6)) - 1, d.slice(6, 8)),
    DateAbapDateTimeToDateObject: (d, t = '000000') => new Date(d.slice(0, 4), parseInt(d.slice(4, 6)) - 1, d.slice(6, 8), t.slice(0, 2), t.slice(2, 4), t.slice(4, 6)),
  };
}
);
sap.ui.require(["z2ui5/Util"], (Util) => {
  z2ui5.Util = Util;
}
);

sap.ui.define("z2ui5/Favicon", ["sap/ui/core/Control"], (Control) => {
  "use strict";
  return Control.extend("z2ui5.Favicon", {
    metadata: {
      properties: {
        favicon: {
          type: "string"
        },
      }
    },
    setFavicon(val) {
      this.setProperty("favicon", val);
      let headTitle = document.querySelector('head');
      let setFavicon = document.createElement('link');
      setFavicon.setAttribute('rel', 'shortcut icon');
      setFavicon.setAttribute('href', val);
      headTitle.appendChild(setFavicon);
    },
    renderer(oRm, oControl) { }
  });
}
);

sap.ui.define("z2ui5/Dirty", ["sap/ui/core/Control", "sap/ushell/Container"], (Control, Container) => {
  "use strict";
  return Control.extend("z2ui5.Dirty", {
    metadata: {
      properties: {
        isDirty: {
          type: "string"
        },
      }
    },
    setIsDirty(val) {
      if (Container) {
        Container.setDirtyFlag(val);
      } else {
        window.onbeforeunload = function (e) {
          if (val) {
            e.preventDefault();
          }
        }
      }
    },
    renderer(oRm, oControl) { }
  });
}
);