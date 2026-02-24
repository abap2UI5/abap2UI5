sap.ui.define(["sap/ui/core/mvc/Controller",
  "z2ui5/controller/View1.controller",
  "z2ui5/cc/Server",
  "sap/ui/core/routing/HashChanger"
], function (BaseController, Controller, Server, HashChanger) {
  return BaseController.extend("z2ui5.controller.App", {

    onInit() {

      z2ui5.oOwnerComponent = this.getOwnerComponent();
      z2ui5.oConfig.pathname = z2ui5.oOwnerComponent.getManifest()["sap.app"].dataSources.http.uri;
      if (z2ui5?.checkLocal == true) {
        z2ui5.oConfig.pathname = window.location.href;
      };

      z2ui5.oController = new Controller();
      z2ui5.oApp = this.getView().byId("app");

      z2ui5.oControllerNest = new Controller();
      z2ui5.oControllerNest2 = new Controller();
      z2ui5.oControllerPopup = new Controller();
      z2ui5.oControllerPopover = new Controller();

      z2ui5.onBeforeRoundtrip = [];
      z2ui5.onAfterRendering = [];
      z2ui5.onBeforeEventFrontend = [];
      z2ui5.onAfterRoundtrip = [];

      z2ui5.checkNestAfter = false;

    //  if (sap.ui.core.routing.HashChanger.getInstance().getHash().includes("z2ui5-xapp-state")){
       if (HashChanger.getInstance().getHash()){
          z2ui5.checkInit = true;
          Server.Roundtrip();
      }

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
    onAfterRendering() {
      if (!this._pendingFocus) return;
      this._pendingFocus = false;
      var oElement = z2ui5.oView.byId(this.getProperty("focusId"));
      if (!oElement) return;
      var oFocus = oElement.getFocusInfo();
      oFocus.selectionStart = parseInt(this.getProperty("selectionStart"));
      oFocus.selectionEnd = parseInt(this.getProperty("selectionEnd"));
      oElement.applyFocusInfo(oFocus);
    },
    renderer(oRm, oControl) {
      oRm.openStart("span", oControl);
      oRm.addStyle("display", "none");
      oRm.openEnd();
      oRm.close("span");
      if (!oControl.getProperty("setUpdate")) return;
      oControl.setProperty("setUpdate", false);
      oControl._pendingFocus = true;
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
        ApplicationFullWidth:{
          type : "boolean"
        }
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

    setApplicationFullWidth(val) {
      this.setProperty("ApplicationFullWidth", val);
      z2ui5.ApplicationFullWidth = val;
    sap.ui.require([
      "sap/ushell/services/AppConfiguration"
    ], async (AppConfiguration)  => {
      AppConfiguration.setApplicationFullWidth(z2ui5.ApplicationFullWidth);
    });

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

sap.ui.define("z2ui5/Tree", ["sap/ui/core/Control"], (Control) => {
  "use strict";

  return Control.extend("z2ui5.Tree", {
    metadata: {
      properties: {
        tree_id: {
          type: "string"
        }
      }
    },

    setBackend() {
      z2ui5.treeState = z2ui5.oView.byId(this.getProperty("tree_id")).getBinding('items').getCurrentTreeState();
    },

    init() {
      z2ui5.onBeforeRoundtrip.push(this.setBackend.bind(this));
    },

    onAfterRendering() {
      if (!this._pendingTreeState) return;
      this._pendingTreeState = false;
      const id = this.getProperty("tree_id");
      z2ui5.oView.byId(id).getBinding('items').setTreeState(z2ui5.treeState);
    },

    renderer(oRm, oControl) {
      oRm.openStart("span", oControl);
      oRm.addStyle("display", "none");
      oRm.openEnd();
      oRm.close("span");
      if (!z2ui5.treeState) return;
      oControl._pendingTreeState = true;
    }
  });
});

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
          type: "object"
        }
      }
    },

    setBackend() {
      const items = this.getProperty("items");
      if (!items) return;

      const bindingInfo = this.getBindingInfo("items");
      const bindingPath = bindingInfo?.parts?.[0]?.path || bindingInfo?.path;

      items.forEach((item, index) => {
        let scrollTop = 0;
        try {
          const scrollDelegate = z2ui5.oView.byId(item.N).getScrollDelegate();
          scrollTop = scrollDelegate ? scrollDelegate.getScrollTop() : 0;
        } catch {
          try {
            const element = document.getElementById(`${z2ui5.oView.byId(item.ID).getId()}-inner`);
            scrollTop = element ? element.scrollTop : 0;
          } catch { }
        }
        if (item.V !== scrollTop) {
          item.V = scrollTop;
          if (bindingPath && z2ui5.xxChangedPaths) {
            z2ui5.xxChangedPaths.add(`${bindingPath}/${index}/V`);
          }
        }
      });
    },

    init() {
      z2ui5.onBeforeRoundtrip.push(this.setBackend.bind(this));
    },

    _restoreScrollPosition(item) {
      try {
        z2ui5.oView.byId(item.N).scrollTo(item.V);
      } catch {
        try {
          const element = document.getElementById(`${z2ui5.oView.byId(item.ID).getId()}-inner`);
          if (element) element.scrollTop = item.V;
        } catch { }
      }
    },

    onAfterRendering() {
      if (!this._pendingScroll) return;
      this._pendingScroll = false;

      const items = this.getProperty("items");
      if (!items) return;

      items.forEach(item => {
        const control = z2ui5.oView.byId(item.N);
        if (control?.getDomRef()) {
          this._restoreScrollPosition(item);
        } else if (control) {
          const delegate = {
            onAfterRendering: () => {
              this._restoreScrollPosition(item);
              control.removeEventDelegate(delegate);
            }
          };
          control.addEventDelegate(delegate);
        }
      });
    },

    renderer(oRm, oControl) {
      oRm.openStart("span", oControl);
      oRm.addStyle("display", "none");
      oRm.openEnd();
      oRm.close("span");

      if (!oControl.getProperty("setUpdate")) return;
      oControl.setProperty("setUpdate", false, true);
      oControl._pendingScroll = true;
    }
  });
});

sap.ui.define("z2ui5/Info", ["sap/ui/core/Control", "sap/ui/VersionInfo", "sap/ui/Device"], (Control) => {
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

    async renderer(_, oControl) {

      let oDevice = z2ui5.oView.getModel("device").oData;
      oControl.setProperty("ui5_version", z2ui5.oConfig.UI5VersionInfo.version);
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

      this.setProperty("longitude", position.coords.longitude, true);
      this.setProperty("latitude", position.coords.latitude, true);
      this.setProperty("altitude", position.coords.altitude, true);
      this.setProperty("accuracy", position.coords.accuracy, true);
      this.setProperty("altitudeAccuracy", position.coords.altitudeAccuracy, true);
      this.setProperty("speed", position.coords.speed, true);
      this.setProperty("heading", position.coords.heading, true);
      this.fireFinished();

    },

    async init() {

      navigator.geolocation.getCurrentPosition(this.callbackPosition.bind(this));

    },

    exit() {
    },

    onAfterRendering() {
    },

    renderer() {
    }
  });
}
);

sap.ui.define("z2ui5/Storage", ["sap/ui/core/Control", "sap/ui/util/Storage"], (Control, Storage) => {
  "use strict";

  return Control.extend("z2ui5.Storage", {
    metadata: {
      properties: {
        type: {
          type: "string",
          defaultValue: "session"
        },
        prefix: {
          type: "string",
          defaultValue: ""
        },
        key: {
          type: "string",
          defaultValue: ""
        },
        value: {
          type: "any",
          defaultValue: ""
        }
      },
      events: {
        "finished": {
          parameters: {
            type: {
              type: "string",
            },
            prefix: {
              type: "string",
            },
            key: {
              type: "string",
            },
            value: {
              type: "any",
            }
          }
        }
      }
    },

    async renderer(_, oControl) {
      let storageType = oControl.getProperty("type");
      let storageKeyPrefix = oControl.getProperty("prefix");
      let storageKey  = oControl.getProperty("key");
      let storageValue = oControl.getProperty("value");
      let oStorage = new Storage(storageType, storageKeyPrefix);
      let storedValue = oStorage.get(storageKey);
      if (storedValue == null) {
        storedValue = "";
      }
      if (storedValue !== storageValue) {
         oControl.setProperty("value", storedValue);
         oControl.fireFinished({
           "type": storageType,
           "prefix": storageKeyPrefix,
           "key": storageKey,
           "value": storedValue
         });
       }
    },
    onAfterRendering() { },
    init() { }
  });
});

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
        uploadOnChange: oControl.getProperty("checkDirectUpload"),
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
          type: "string"
        },
        MultiInputName: {
          type: "string"
        },
        addedTokens: {
          type: "object"
        },
        checkInit: {
          type: "boolean",
          defaultValue: false
        },
        removedTokens: {
          type: "object"
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
      z2ui5.onAfterRendering.push(oControl.setControl.bind(oControl));
    },
    setControl() {
      let table = z2ui5.oView.byId(this.getProperty("MultiInputId"));
      if (!table) {
        try {
          // table = Core.byId(Element.getElementsByName(this.getProperty("MultiInputName"))[0].id.replace('-inner', ''));
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
    }
  });
}
);

sap.ui.define("z2ui5/SmartMultiInputExt", ["sap/ui/core/Control", "sap/m/Token", "sap/ui/core/Core", "sap/ui/core/Element"], (Control) => {
  "use strict";

  return Control.extend("z2ui5.SmartMultiInputExt", {
    metadata: {
      properties: {
        multiInputId: {
          type: "string"
        },
        addedTokens: {
          type: "object"
        },
        removedTokens: {
          type: "object"
        },
        rangeData: {
          type: "object",
          defaultValue: []
        },
        checkInit: {
          type: "boolean",
          defaultValue: false
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
      const aTokens = oEvent.getSource().getTokens();
      this.setProperty("rangeData", oEvent.getSource().getRangeData().map((oRangeData, iIndex) => {
        const oToken = aTokens[iIndex];
        oRangeData.tokenText = oToken.getText();
        oRangeData.tokenLongKey = oToken.data("longKey");
        return oRangeData;
      }));
      this.fireChange();
    },
    setRangeData(aRangeData) {
      this.setProperty("rangeData", aRangeData);
      this.inputInitialized().then((input) => {
        input.setRangeData(aRangeData.map((oRangeData) => {
          const oRangeDataNew = {};
          Object.entries(oRangeData).forEach((aEntry) => {
            const sKeyNameNew = aEntry[0].toLowerCase();
            oRangeDataNew[(sKeyNameNew === "keyfield" ? "keyField" : sKeyNameNew)] = aEntry[1];
          });
          return oRangeDataNew;
        }));
        //we need to set token text explicitly, as setRangeData does no recalculation
        input.getTokens().forEach((token, index) => {
          const oRangeData = aRangeData[index];
          token.data("longKey", oRangeData.TOKENLONGKEY);
          token.data("range", null);
          const sTokenText = oRangeData.TOKENTEXT;
          if (sTokenText) {
            token.setText(sTokenText);
          }
        });
      });
    },
    renderer(oRm, oControl) { },
    setControl() {
      const input = z2ui5.oView.byId(this.getProperty("multiInputId"));
      if (!input) {
        return;
      }
      if (this.getProperty("checkInit") == true) {
        return;
      }
      this.setProperty("checkInit", true);
      input.attachTokenUpdate(this.onTokenUpdate.bind(this));
      input.attachInnerControlsCreated(this.onInnerControlsCreated.bind(this));
    },
    inputInitialized(input) {
      return new Promise((resolve, reject) => {
        if (this._bInnerControlsCreated) {
          resolve(input); //resolve immediately
        } else {
          this._oPendingInnerControlsCreated = resolve; //resolve later
        }
      });
    },
    _oPendingInnerControlsCreated: null,
    _bInnerControlsCreated: false,
    onInnerControlsCreated(oEvent) {
      const input = oEvent.getSource();
      if (this._oPendingInnerControlsCreated) {
        this._oPendingInnerControlsCreated(input);
      }
      this._oPendingInnerControlsCreated = null;
      this._bInnerControlsCreated = true;
    }
  });
}
);

sap.ui.define("z2ui5/CameraPicture", [
  "sap/ui/core/Control",
  "sap/m/Dialog",
  "sap/m/Button",
  "sap/ui/core/HTML"
], function (Control, Dialog, Button, HTML) {
  "use strict";
  return Control.extend("z2ui5.CameraPicture", {
    metadata: {
      properties: {
        id: { type: "string" },
        value: { type: "string" },
        press: { type: "string" },
        width: { type: "string" , defaultValue: 200 },
        height: { type: "string" , defaultValue: 200 },
        autoplay: { type: "boolean", defaultValue: true },
        facingMode: { type: "string" },
        deviceId: { type: "string" }
      },
      events: {
        "OnPhoto": {
          allowPreventDefault: true,
          parameters: {
            "photo": {
              type: "string"
            }
          }
        }
      },
    },

    capture: function (oEvent) {

      var video = document.querySelector("#zvideo");
      var canvas = document.getElementById('zcanvas');
      var resultb64 = "";
      canvas.width = parseInt( this.getProperty("width") );
      canvas.height = parseInt( this.getProperty("height") );
      canvas.getContext('2d').drawImage(video, 0, 0, canvas.width, canvas.height);
      resultb64 = canvas.toDataURL();
      this.setProperty("value", resultb64);
      this.fireOnPhoto({
        "photo": resultb64
      });
    },

    onPicture: function (oEvent) {

      if (!this._oScanDialog) {
        this._oScanDialog = new Dialog({
          title: "Device Photo Function",
          contentWidth: "640px",
          contentHeight: "480px",
          horizontalScrolling: false,
          verticalScrolling: false,
          stretch: true,
          content: [
            new HTML({
              id: this.getId() + 'PictureContainer',
              content: '<video width="' + this.getProperty("width") + 'px" height="' + this.getProperty("height")  + 'px" autoplay="true" id="zvideo">'
            }),
            new Button({
              text: "Capture",
              press: function (oEvent) {
                this.capture();
                this._oScanDialog.close();
              }.bind(this)
            }),
            new HTML({
              content: '<canvas hidden id="zcanvas" style="overflow:auto"></canvas>'
            }),
          ],
          endButton: new Button({
            text: "Cancel",
            press: function (oEvent) {
              this._oScanDialog.close();
            }.bind(this)
          }),
        });
      }

      this._oScanDialog.attachEventOnce("afterOpen", function () {
        var video = document.querySelector('#zvideo');
        if (navigator.mediaDevices.getUserMedia) {
          const facingMode = this.getProperty("facingMode");
          const deviceId = this.getProperty("deviceId");

          let options = { video: {} };
          if (deviceId) {
            options.video.deviceId = deviceId;
          }
          if (facingMode) {
            options.video.facingMode = { exact: facingMode };
          }

          navigator.mediaDevices.getUserMedia(options)
            .then(function (stream) {
              video.srcObject = stream;
            })
            .catch(function (error) {
              console.log("Something went wrong! " + error);
            });
        }
      }.bind(this));
      this._oScanDialog.open();

    },

    renderer: function (oRM, oControl) {

      var oButton = new Button({
        icon: "sap-icon://camera",
        text: "Camera",
        press: oControl.onPicture.bind(oControl),
      });
      oRM.renderControl(oButton);

    },
  });
});


sap.ui.define("z2ui5/CameraSelector", [
  "sap/m/ComboBox",
  "sap/ui/core/Item",
  "sap/m/ComboBoxRenderer"
], function (ComboBox, Item, ComboBoxRenderer) {
  "use strict";
  return ComboBox.extend("z2ui5.CameraSelector", {

    init: function () {

      ComboBox.prototype.init.apply(this, arguments);

      navigator.mediaDevices
        .enumerateDevices()
        .then((devices) => {
          devices.forEach((device) => {
            if (device.kind === "videoinput") {
              this.addItem(new Item({
                key: device.deviceId,
                text: device.label
              }));
            }
          });
        })
        .catch((err) => {
          console.error(`${err.name}: ${err.message}`);
        });

    },

    renderer: ComboBoxRenderer
  });
});


sap.ui.define("z2ui5/UITableExt", ["sap/ui/core/Control"], (Control) => {
  "use strict";

  return Control.extend("z2ui5.UITableExt", {
    metadata: {
      properties: {
        tableId: {
          type: "string"
        },
      },
    },

    init() {
      z2ui5.onBeforeRoundtrip.push(this.readFilter.bind(this));
      z2ui5.onBeforeRoundtrip.push(this.readSort.bind(this));
      z2ui5.onAfterRoundtrip.push(this.setFilter.bind(this));
      z2ui5.onAfterRoundtrip.push(this.setSort.bind(this));
    },

    readFilter() {
      try {
        let id = this.getProperty("tableId");
        let oTable = z2ui5.oView.byId(id);
        this.aFilters = oTable.getBinding().aFilters;
      } catch (e) { }
      ;
    },

    _applyFilters(oTable, aFilters) {
      oTable.getBinding().filter(aFilters);
      var opSymbols = {
  EQ: "",
  NE: "!",
  LT: "<",
  LE: "<=",
  GT: ">",
  GE: ">=",
  BT: "...",
  Contains: "*",
  StartsWith: "^",
  EndsWith: "$"
};

aFilters.forEach(function(oFilter) {
  var sProperty = oFilter.sPath || oFilter.aFilters?.[0]?.sPath;
  if (!sProperty) return;

  oTable.getColumns().forEach(function(oCol) {
    if (oCol.getFilterProperty && oCol.getFilterProperty() === sProperty) {
      var operator = oFilter.sOperator;
      var vValue = oFilter.oValue1 !== undefined ? oFilter.oValue1 : oFilter.oValue2;

      if (vValue === undefined && oFilter.aFilters && oFilter.aFilters[0].oValue1 !== undefined) {
        vValue = oFilter.aFilters[0].oValue1;
      }

      var display;
      if (operator === "BT") {
        var vValue2 = oFilter.oValue2 !== undefined ? oFilter.oValue2 : "";
        display = (vValue != null ? vValue : "") + opSymbols["BT"] + (vValue2 != null ? vValue2 : "");
      } else if (operator === "Contains") {
        display = "*" + (vValue != null ? vValue : "") + "*";
      } else if (operator === "StartsWith") {
        display = "^" + (vValue != null ? vValue : "");
      } else if (operator === "EndsWith") {
        display = (vValue != null ? vValue : "") + "$";
      } else {
        display = (opSymbols[operator] || "") + (vValue != null ? vValue : "");
      }

      oCol.setFilterValue(display);
      oCol.setFiltered(!!display);
    }
  });
});
    },

    setFilter() {
      try {
        const aFilters = this.aFilters;
        let oTable = z2ui5.oView.byId(this.getProperty("tableId"));
        if (!oTable) return;
        if (oTable.getDomRef()) {
          this._applyFilters(oTable, aFilters);
        } else {
          const delegate = {
            onAfterRendering: () => {
              oTable.removeEventDelegate(delegate);
              this._applyFilters(oTable, aFilters);
            }
          };
          oTable.addEventDelegate(delegate);
        }
      } catch (e) { }
      ;
    },
readSort() {
  try {
    let id = this.getProperty("tableId");
    let oTable = z2ui5.oView.byId(id);
    this.aSorters = oTable.getBinding().aSorters;
  } catch (e) {}
},

_applySorters(oTable, aSorters) {
  oTable.getBinding().sort(aSorters);
  aSorters.forEach(function(srt, idx) {
    oTable.getColumns().forEach(function(oCol) {
      if (oCol.getSortProperty && oCol.getSortProperty() === srt.sPath) {
        oCol.setSorted(true);
        oCol.setSortOrder(srt.bDescending ? "Descending" : "Ascending");
        if (oCol.setSortIndex) oCol.setSortIndex(idx);
      }
    });
  });
},

setSort() {
  try {
    const aSorters = this.aSorters;
    let oTable = z2ui5.oView.byId(this.getProperty("tableId"));
    if (!oTable) return;
    if (oTable.getDomRef()) {
      this._applySorters(oTable, aSorters);
    } else {
      const delegate = {
        onAfterRendering: () => {
          oTable.removeEventDelegate(delegate);
          this._applySorters(oTable, aSorters);
        }
      };
      oTable.addEventDelegate(delegate);
    }
  } catch (e) {}
},
    renderer(oRM, oControl) { }
  });
}
);

sap.ui.define("z2ui5/Util", [], () => {
  "use strict";
  return {
    DateCreateObject: (s) => new Date(s),
    //  DateAbapTimestampToDate: (sTimestamp) => new sap.gantt.misc.Format.abapTimestampToDate(sTimestamp), commented for UI5 2.x compatibility
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

sap.ui.define("z2ui5/Dirty", ["sap/ui/core/Control"], (Control) => {
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
      
      const fallback = () => {
        window.onbeforeunload = function (e) {
          if (val) {
            e.preventDefault();
          }
        }
      }

      // Container can be loaded (only available in SAPUI5, not in OpenUI5) and we are in Fiori Launchpad?
      //   Yes: We can use the containers ability to prevent data loss
      //   No: We fallback to window.onbeforeunload event
      sap.ui.require([ "sap/ushell/Container" ], async (Container) => {
        
        if (Container && z2ui5.oLaunchpadService) {          
          Container.setDirtyFlag(val);
        } else {
          fallback();
        }
        
      }, fallback);
      
    },
    renderer(oRm, oControl) { }
  });
}
);
