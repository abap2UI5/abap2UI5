// Append an entry to the global error log. We create the array on first use.
function _logError(message, error) {
  if (!z2ui5.errors) z2ui5.errors = [];
  const entry = { message: message, ts: new Date().toISOString() };
  if (error !== undefined) entry.error = error;
  z2ui5.errors.push(entry);
}

// Helpers for managing z2ui5 callback arrays (onBeforeRoundtrip,
// onAfterRendering, ...). Several custom controls register hooks here in
// init() and remove them in exit().
function _registerCallback(name, fn) {
  if (!z2ui5[name]) z2ui5[name] = [];
  z2ui5[name].push(fn);
}
function _unregisterCallback(name, fn) {
  if (!z2ui5[name]) return;
  z2ui5[name] = z2ui5[name].filter((f) => f !== fn);
}

sap.ui.define(
  [
    "sap/ui/core/mvc/Controller",
    "z2ui5/controller/View1.controller",
    "z2ui5/cc/Server",
    "sap/ui/core/routing/HashChanger",
  ],
  (BaseController, Controller, Server, HashChanger) => {
    "use strict";
    return BaseController.extend("z2ui5.controller.App", {
      onInit() {
        const oOwnerComponent = this.getOwnerComponent();
        z2ui5.oOwnerComponent = oOwnerComponent;

        // Read the backend URI from the manifest, falling back step by step
        // so a missing entry doesn't blow up.
        const manifest = oOwnerComponent.getManifest();
        const sapApp = manifest && manifest["sap.app"];
        const dataSources = sapApp && sapApp.dataSources;
        const http = dataSources && dataSources.http;
        const uri = http && http.uri;
        z2ui5.oConfig.pathname = z2ui5.checkLocal ? window.location.href : uri;

        // Set up the shared z2ui5 state used by the whole app.
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
        z2ui5.errors = [];
        z2ui5.checkNestAfter = false;
        z2ui5.checkNestAfter2 = false;

        // If the URL already contains a hash, kick off the initial roundtrip
        // so the backend can restore that state.
        if (HashChanger.getInstance().getHash()) {
          z2ui5.checkInit = true;
          Server.Roundtrip();
        }
      },
    });
  },
);

sap.ui.define("z2ui5/Timer", ["sap/ui/core/Control"], (Control) => {
  "use strict";

  return Control.extend("z2ui5.Timer", {
    metadata: {
      properties: {
        delayMS: {
          type: "int",
          defaultValue: 0,
        },
        checkActive: {
          type: "boolean",
          defaultValue: true,
        },
        checkRepeat: {
          type: "boolean",
          defaultValue: false,
        },
      },
      events: {
        finished: {
          allowPreventDefault: true,
          parameters: {},
        },
      },
    },
    onAfterRendering() {
      if (!this._pendingTimer) return;
      this._pendingTimer = false;
      this.delayedCall();
    },
    exit() {
      clearTimeout(this._timerId);
    },
    delayedCall() {
      if (!this.getProperty("checkActive")) return;
      clearTimeout(this._timerId);
      const repeat = this.getProperty("checkRepeat");
      const delay = this.getProperty("delayMS");
      this._timerId = setTimeout(() => {
        // The control might have been destroyed during the delay.
        if (this.isDestroyed && this.isDestroyed()) return;
        if (!repeat) this.setProperty("checkActive", false, true);
        this.fireFinished();
        // For repeating timers, queue the next iteration. Re-check destroy
        // again because fireFinished may have triggered teardown.
        if (repeat && !(this.isDestroyed && this.isDestroyed())) {
          this.delayedCall();
        }
      }, delay);
    },
    renderer: {
      apiVersion: 2,
      render(oRm, oControl) {
        oRm.openStart("span", oControl);
        oRm.style("display", "none");
        oRm.openEnd();
        oRm.close("span");
        oControl._pendingTimer = oControl.getProperty("checkActive");
      },
    },
  });
});

sap.ui.define("z2ui5/Focus", ["sap/ui/core/Control"], (Control) => {
  "use strict";
  return Control.extend("z2ui5.Focus", {
    metadata: {
      properties: {
        setUpdate: {
          type: "boolean",
          defaultValue: true,
        },
        focusId: {
          type: "string",
        },
        selectionStart: {
          type: "string",
          defaultValue: "0",
        },
        selectionEnd: {
          type: "string",
          defaultValue: "0",
        },
      },
    },
    setFocusId(val) {
      try {
        this.setProperty("focusId", val);
        const oElement = z2ui5.oView && z2ui5.oView.byId(val);
        if (oElement) oElement.applyFocusInfo(oElement.getFocusInfo());
      } catch (e) {
        _logError("Focus.setFocusId failed", e);
      }
    },
    onAfterRendering() {
      if (!this._pendingFocus) return;
      this._pendingFocus = false;
      const oElement =
        z2ui5.oView && z2ui5.oView.byId(this.getProperty("focusId"));
      if (!oElement) return;
      try {
        // Merge the additional selection info into the existing focus info,
        // then apply both at once.
        const info = oElement.getFocusInfo();
        info.selectionStart = +this.getProperty("selectionStart");
        info.selectionEnd = +this.getProperty("selectionEnd");
        oElement.applyFocusInfo(info);
      } catch (e) {
        _logError("Focus.onAfterRendering: applyFocusInfo failed", e);
      }
    },
    renderer: {
      apiVersion: 2,
      render(oRm, oControl) {
        oRm.openStart("span", oControl);
        oRm.style("display", "none");
        oRm.openEnd();
        oRm.close("span");
        if (!oControl.getProperty("setUpdate")) return;
        oControl.setProperty("setUpdate", false, true);
        oControl._pendingFocus = true;
      },
    },
  });
});

sap.ui.define("z2ui5/Title", ["sap/ui/core/Control"], (Control) => {
  "use strict";
  return Control.extend("z2ui5.Title", {
    metadata: {
      properties: {
        title: {
          type: "string",
        },
      },
    },
    setTitle(val) {
      this.setProperty("title", val);
      document.title = val == null ? "" : String(val);
    },
    renderer: { apiVersion: 2, render() {} },
  });
});

sap.ui.define("z2ui5/LPTitle", ["sap/ui/core/Control"], (Control) => {
  "use strict";
  return Control.extend("z2ui5.LPTitle", {
    metadata: {
      properties: {
        title: {
          type: "string",
        },
        ApplicationFullWidth: {
          type: "boolean",
        },
      },
    },
    setTitle(val) {
      this.setProperty("title", val);
      try {
        const shell = z2ui5.oLaunchpad && z2ui5.oLaunchpad.ShellUIService;
        if (!shell || !shell.setTitle) return;
        const result = shell.setTitle(val);
        // setTitle may return a Promise; report any async failure.
        if (result && result.catch) {
          result.catch((e) =>
            _logError("LPTitle: Launchpad Service setTitle failed", e),
          );
        }
      } catch (e) {
        _logError("LPTitle: Launchpad Service setTitle failed", e);
      }
    },

    setApplicationFullWidth(val) {
      this.setProperty("ApplicationFullWidth", val);
      try {
        const config = z2ui5.oLaunchpad && z2ui5.oLaunchpad.AppConfiguration;
        if (config && config.setApplicationFullWidth) {
          config.setApplicationFullWidth(val);
        }
      } catch (e) {
        _logError("LPTitle: setApplicationFullWidth failed", e);
      }
    },

    renderer: { apiVersion: 2, render() {} },
  });
});

sap.ui.define("z2ui5/History", ["sap/ui/core/Control"], (Control) => {
  "use strict";
  return Control.extend("z2ui5.History", {
    metadata: {
      properties: {
        search: {
          type: "string",
        },
      },
    },
    setSearch(val) {
      this.setProperty("search", val);
      try {
        const search = val == null ? "" : val;
        history.replaceState(null, "", `${window.location.pathname}${search}`);
      } catch (e) {
        _logError("History.setSearch: replaceState failed", e);
      }
    },
    renderer: { apiVersion: 2, render() {} },
  });
});

sap.ui.define("z2ui5/Tree", ["sap/ui/core/Control"], (Control) => {
  "use strict";

  return Control.extend("z2ui5.Tree", {
    metadata: {
      properties: {
        tree_id: {
          type: "string",
        },
      },
    },

    _getTreeBinding() {
      if (!z2ui5.oView) return undefined;
      const treeControl = z2ui5.oView.byId(this.getProperty("tree_id"));
      if (!treeControl) return undefined;
      return treeControl.getBinding("items");
    },

    setBackend() {
      try {
        const binding = this._getTreeBinding();
        z2ui5.treeState = binding ? binding.getCurrentTreeState() : undefined;
      } catch (e) {
        _logError("Tree.setBackend: failed", e);
      }
    },

    init() {
      this._setBackendBound = this.setBackend.bind(this);
      _registerCallback("onBeforeRoundtrip", this._setBackendBound);
    },

    exit() {
      _unregisterCallback("onBeforeRoundtrip", this._setBackendBound);
    },

    onAfterRendering() {
      if (!this._pendingTreeState) return;
      this._pendingTreeState = false;
      try {
        const binding = this._getTreeBinding();
        if (binding) binding.setTreeState(z2ui5.treeState);
      } catch (e) {
        _logError("Tree.onAfterRendering: setTreeState failed", e);
      }
    },

    renderer: {
      apiVersion: 2,
      render(oRm, oControl) {
        oRm.openStart("span", oControl);
        oRm.style("display", "none");
        oRm.openEnd();
        oRm.close("span");
        if (!z2ui5.treeState) return;
        oControl._pendingTreeState = true;
      },
    },
  });
});

sap.ui.define("z2ui5/Scrolling", ["sap/ui/core/Control"], (Control) => {
  "use strict";

  return Control.extend("z2ui5.Scrolling", {
    metadata: {
      properties: {
        setUpdate: {
          type: "boolean",
          defaultValue: true,
        },
        items: {
          type: "object",
        },
      },
    },

    _getDomInnerElement(id) {
      const control = z2ui5.oView && z2ui5.oView.byId(id);
      if (!control) return null;
      return document.getElementById(`${control.getId()}-inner`);
    },

    _getScrollTop(item) {
      try {
        const control = z2ui5.oView && z2ui5.oView.byId(item.N);
        // Some controls expose a scroll delegate; prefer it when available.
        if (control && control.getScrollDelegate) {
          const delegate = control.getScrollDelegate();
          if (delegate) return delegate.getScrollTop();
        }
        const element = this._getDomInnerElement(item.ID);
        return element ? element.scrollTop : 0;
      } catch (e) {
        _logError("Scrolling._getScrollTop: failed", e);
        return 0;
      }
    },

    setBackend() {
      const items = this.getProperty("items");
      if (!items) return;
      try {
        // Resolve the binding path so we can mark only changed entries
        // as dirty in xxChangedPaths.
        const bindingInfo = this.getBindingInfo("items");
        let bindingPath;
        if (bindingInfo) {
          const parts = bindingInfo.parts;
          if (parts && parts[0]) bindingPath = parts[0].path;
          if (!bindingPath) bindingPath = bindingInfo.path;
        }
        for (const [index, item] of items.entries()) {
          const scrollTop = this._getScrollTop(item);
          if (item.V !== scrollTop) {
            item.V = scrollTop;
            if (bindingPath && z2ui5.xxChangedPaths) {
              z2ui5.xxChangedPaths.add(`${bindingPath}/${index}/V`);
            }
          }
        }
      } catch (e) {
        _logError("Scrolling.setBackend: failed", e);
      }
    },

    init() {
      this._setBackendBound = this.setBackend.bind(this);
      _registerCallback("onBeforeRoundtrip", this._setBackendBound);
    },

    exit() {
      _unregisterCallback("onBeforeRoundtrip", this._setBackendBound);
    },

    _restoreScrollPosition(item) {
      try {
        const control = z2ui5.oView && z2ui5.oView.byId(item.N);
        if (control && control.scrollTo) {
          control.scrollTo(item.V);
          return;
        }
        const element = this._getDomInnerElement(item.ID);
        if (element) element.scrollTop = item.V;
      } catch (e) {
        _logError("Scrolling._restoreScrollPosition: failed", e);
      }
    },

    onAfterRendering() {
      if (!this._pendingScroll) return;
      this._pendingScroll = false;

      const items = this.getProperty("items");
      if (!items) return;

      try {
        for (const item of items) {
          const control = z2ui5.oView && z2ui5.oView.byId(item.N);
          if (!control) continue;

          if (control.getDomRef()) {
            // The target control is already rendered -> restore immediately.
            this._restoreScrollPosition(item);
          } else {
            // Not rendered yet -> wait until it is, then restore once.
            const delegate = {
              onAfterRendering: () => {
                control.removeEventDelegate(delegate);
                if (!(this.isDestroyed && this.isDestroyed())) {
                  this._restoreScrollPosition(item);
                }
              },
            };
            control.addEventDelegate(delegate);
          }
        }
      } catch (e) {
        _logError("Scrolling.onAfterRendering: failed", e);
      }
    },

    renderer: {
      apiVersion: 2,
      render(oRm, oControl) {
        oRm.openStart("span", oControl);
        oRm.style("display", "none");
        oRm.openEnd();
        oRm.close("span");

        if (!oControl.getProperty("setUpdate")) return;
        oControl.setProperty("setUpdate", false, true);
        oControl._pendingScroll = true;
      },
    },
  });
});

sap.ui.define("z2ui5/Info", ["sap/ui/core/Control"], (Control) => {
  "use strict";

  return Control.extend("z2ui5.Info", {
    metadata: {
      properties: {
        ui5_version: {
          type: "string",
        },
        device_phone: {
          type: "string",
        },
        device_desktop: {
          type: "string",
        },
        device_tablet: {
          type: "string",
        },
        device_combi: {
          type: "string",
        },
        device_height: {
          type: "string",
        },
        device_width: {
          type: "string",
        },
        ui5_theme: {
          type: "string",
        },
        device_os: {
          type: "string",
        },
        device_systemtype: {
          type: "string",
        },
        device_browser: {
          type: "string",
        },
      },
      events: {
        finished: {
          allowPreventDefault: true,
          parameters: {},
        },
      },
    },

    renderer: {
      apiVersion: 2,
      render(_, oControl) {
        try {
          // The device model is created by Component.init(); it exposes
          // system / resize / os / browser info.
          const deviceModel = z2ui5.oView && z2ui5.oView.getModel("device");
          const deviceData = deviceModel && deviceModel.getData();
          if (!deviceData) return;

          const { system, resize, os, browser } = deviceData;
          const versionInfo = z2ui5.oConfig && z2ui5.oConfig.UI5VersionInfo;
          const ui5Version = versionInfo ? versionInfo.version : "";

          const props = [
            ["ui5_version", ui5Version],
            ["device_phone", system.phone],
            ["device_desktop", system.desktop],
            ["device_tablet", system.tablet],
            ["device_combi", system.combi],
            ["device_height", resize.height],
            ["device_width", resize.width],
            ["device_os", os.name],
            ["device_browser", browser.name],
          ];
          for (const [prop, val] of props) {
            const safe = val == null ? "" : String(val);
            oControl.setProperty(prop, safe, true);
          }
          oControl.fireFinished();
        } catch (e) {
          _logError("Info.renderer: failed", e);
        }
      },
    },
  });
});

sap.ui.define("z2ui5/Geolocation", ["sap/ui/core/Control"], (Control) => {
  "use strict";

  const _GEO_PROPS = [
    "longitude",
    "latitude",
    "altitude",
    "accuracy",
    "altitudeAccuracy",
    "speed",
    "heading",
  ];

  return Control.extend("z2ui5.Geolocation", {
    metadata: {
      properties: {
        longitude: {
          type: "string",
          defaultValue: "",
        },
        latitude: {
          type: "string",
          defaultValue: "",
        },
        altitude: {
          type: "string",
          defaultValue: "",
        },
        accuracy: {
          type: "string",
          defaultValue: "",
        },
        altitudeAccuracy: {
          type: "string",
          defaultValue: "",
        },
        speed: {
          type: "string",
          defaultValue: "",
        },
        heading: {
          type: "string",
          defaultValue: "",
        },
        enableHighAccuracy: {
          type: "boolean",
          defaultValue: false,
        },
        timeout: {
          type: "string",
          defaultValue: "5000",
        },
      },
      events: {
        finished: {
          allowPreventDefault: true,
          parameters: {},
        },
      },
    },

    callbackPosition({ coords }) {
      // The control could be torn down while the geolocation API was busy.
      if (this.isDestroyed && this.isDestroyed()) return;
      for (const prop of _GEO_PROPS) {
        const raw = coords[prop];
        const val = raw == null ? "" : raw.toString();
        this.setProperty(prop, val, true);
      }
      this.fireFinished();
    },

    init() {
      this._pendingGeolocate = true;
    },

    exit() {
      this._pendingGeolocate = false;
    },

    onAfterRendering() {
      if (!this._pendingGeolocate) return;
      this._pendingGeolocate = false;
      try {
        if (!navigator.geolocation) return;
        navigator.geolocation.getCurrentPosition(
          this.callbackPosition.bind(this),
          (error) =>
            _logError(`Geolocation error (${error.code}): ${error.message}`),
          {
            enableHighAccuracy: this.getProperty("enableHighAccuracy"),
            timeout: +this.getProperty("timeout"),
          },
        );
      } catch (e) {
        _logError("Geolocation.onAfterRendering: getCurrentPosition failed", e);
      }
    },

    renderer: {
      apiVersion: 2,
      render(oRm, oControl) {
        oRm.openStart("span", oControl);
        oRm.style("display", "none");
        oRm.openEnd();
        oRm.close("span");
      },
    },
  });
});

sap.ui.define(
  "z2ui5/Storage",
  ["sap/ui/core/Control", "sap/ui/util/Storage"],
  (Control, Storage) => {
    "use strict";

    return Control.extend("z2ui5.Storage", {
      metadata: {
        properties: {
          type: {
            type: "string",
            defaultValue: "session",
          },
          prefix: {
            type: "string",
            defaultValue: "",
          },
          key: {
            type: "string",
            defaultValue: "",
          },
          value: {
            type: "any",
            defaultValue: "",
          },
        },
        events: {
          finished: {
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
              },
            },
          },
        },
      },

      renderer: {
        apiVersion: 2,
        render(_, oControl) {
          const type = oControl.getProperty("type");
          const prefix = oControl.getProperty("prefix");
          const key = oControl.getProperty("key");
          const value = oControl.getProperty("value");

          let stored;
          try {
            const storageType = Storage.Type[type] || Storage.Type.session;
            const storage = new Storage(storageType, prefix);
            const read = storage.get(key);
            stored = read == null ? "" : read;
          } catch (e) {
            _logError(`Storage: read failed for key '${key}'`, e);
            return;
          }

          // Only fire "finished" when the stored value differs from the
          // current property to avoid feedback loops.
          if (stored !== value) {
            oControl.setProperty("value", stored, true);
            oControl.fireFinished({
              type: type,
              prefix: prefix,
              key: key,
              value: stored,
            });
          }
        },
      },
    });
  },
);

sap.ui.define(
  "z2ui5/FileUploader",
  [
    "sap/ui/core/Control",
    "sap/m/Button",
    "sap/ui/unified/FileUploader",
    "sap/m/HBox",
  ],
  (Control, Button, FileUploader, HBox) => {
    "use strict";

    return Control.extend("z2ui5.FileUploader", {
      metadata: {
        properties: {
          value: {
            type: "string",
            defaultValue: "",
          },
          path: {
            type: "string",
            defaultValue: "",
          },
          tooltip: {
            type: "string",
            defaultValue: "",
          },
          fileType: {
            type: "string",
            defaultValue: "",
          },
          placeholder: {
            type: "string",
            defaultValue: "",
          },
          buttonText: {
            type: "string",
            defaultValue: "",
          },
          style: {
            type: "string",
            defaultValue: "",
          },
          uploadButtonText: {
            type: "string",
            defaultValue: "Upload",
          },
          enabled: {
            type: "boolean",
            defaultValue: true,
          },
          icon: {
            type: "string",
            defaultValue: "sap-icon://browse-folder",
          },
          iconOnly: {
            type: "boolean",
            defaultValue: false,
          },
          buttonOnly: {
            type: "boolean",
            defaultValue: false,
          },
          multiple: {
            type: "boolean",
            defaultValue: false,
          },
          visible: {
            type: "boolean",
            defaultValue: true,
          },
          checkDirectUpload: {
            type: "boolean",
            defaultValue: false,
          },
        },

        events: {
          upload: {
            allowPreventDefault: true,
            parameters: {},
          },
        },
      },

      _readFile(file) {
        const reader = new FileReader();
        reader.onload = () => {
          if (this.isDestroyed && this.isDestroyed()) return;
          this.setProperty("value", reader.result);
          this.fireUpload();
        };
        reader.onerror = () =>
          _logError("FileUploader: FileReader failed", reader.error);
        reader.readAsDataURL(file);
      },

      exit() {
        if (this._oHBox) this._oHBox.destroy();
      },

      renderer: {
        apiVersion: 2,
        render(oRm, oControl) {
          const directUpload = oControl.getProperty("checkDirectUpload");
          const path = oControl.getProperty("path");

          // Clean up controls from a previous render pass.
          if (oControl._oHBox) oControl._oHBox.destroy();
          oControl._oHBox = null;
          oControl.oUploadButton = null;
          oControl.oFileUploader = null;

          // Helper: read the first file from a FileUploader instance.
          const getFirstFile = (uploader) => {
            const fileUpload = uploader && uploader.oFileUpload;
            const files = fileUpload && fileUpload.files;
            return files && files[0];
          };

          if (!directUpload) {
            oControl.oUploadButton = new Button({
              text: oControl.getProperty("uploadButtonText"),
              enabled: path !== "",
              press: () => {
                oControl.setProperty(
                  "path",
                  oControl.oFileUploader.getProperty("value"),
                );
                const file = getFirstFile(oControl.oFileUploader);
                if (file) oControl._readFile(file);
              },
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
            uploadOnChange: directUpload,
            multiple: oControl.getProperty("multiple"),
            enabled: oControl.getProperty("enabled"),
            value: path,
            placeholder: oControl.getProperty("placeholder"),
            change: (oEvent) => {
              if (directUpload) return;
              const value = oEvent.getSource().getProperty("value");
              oControl.setProperty("path", value);
              if (oControl.oUploadButton) {
                oControl.oUploadButton.setEnabled(!!value);
                oControl.oUploadButton.invalidate();
              }
            },
            uploadComplete: (oEvent) => {
              if (!directUpload) return;
              const source = oEvent.getSource();
              oControl.setProperty("path", source.getProperty("value"));
              const file = getFirstFile(source);
              if (file) oControl._readFile(file);
            },
          });

          oControl._oHBox = new HBox().addItem(oControl.oFileUploader);
          if (oControl.oUploadButton) {
            oControl._oHBox.addItem(oControl.oUploadButton);
          }
          oRm.renderControl(oControl._oHBox);
        },
      },
    });
  },
);

sap.ui.define(
  "z2ui5/MultiInputExt",
  ["sap/ui/core/Control", "sap/m/Token"],
  (Control, Token) => {
    "use strict";

    return Control.extend("z2ui5.MultiInputExt", {
      metadata: {
        properties: {
          MultiInputId: {
            type: "string",
          },
          MultiInputName: {
            type: "string",
          },
          addedTokens: {
            type: "object",
          },
          checkInit: {
            type: "boolean",
            defaultValue: false,
          },
          removedTokens: {
            type: "object",
          },
        },
        events: {
          change: {
            allowPreventDefault: true,
            parameters: {},
          },
        },
      },

      init() {
        this._setControlBound = this.setControl.bind(this);
        _registerCallback("onAfterRendering", this._setControlBound);
      },
      exit() {
        _unregisterCallback("onAfterRendering", this._setControlBound);
      },

      onTokenUpdate(oEvent) {
        const mParameters = oEvent.mParameters;
        const isRemoved = mParameters.type === "removed";
        const rawList =
          mParameters[isRemoved ? "removedTokens" : "addedTokens"] || [];
        const tokens = rawList.map((item) => ({
          KEY: item.getKey(),
          TEXT: item.getText(),
        }));
        this.setProperty("addedTokens", isRemoved ? [] : tokens);
        this.setProperty("removedTokens", isRemoved ? tokens : []);
        this.fireChange();
      },
      renderer: { apiVersion: 2, render() {} },
      setControl() {
        const table =
          z2ui5.oView && z2ui5.oView.byId(this.getProperty("MultiInputId"));
        if (!table || this.getProperty("checkInit")) return;
        this.setProperty("checkInit", true);
        try {
          table.attachTokenUpdate(this.onTokenUpdate.bind(this));
          // Custom validator: turn any free-text entry into a Token where
          // both key and visible text equal the input string.
          table.addValidator(({ text }) => new Token({ key: text, text }));
        } catch (e) {
          _logError("MultiInputExt.setControl: setup failed", e);
        }
      },
    });
  },
);

sap.ui.define("z2ui5/UploadSetExt", ["sap/ui/core/Control"], (Control) => {
  "use strict";

  return Control.extend("z2ui5.UploadSetExt", {
    metadata: {
      properties: {
        uploadSetId: {
          type: "string",
        },
        fileData: {
          type: "string",
          defaultValue: "",
        },
        fileName: {
          type: "string",
          defaultValue: "",
        },
        mediaType: {
          type: "string",
          defaultValue: "",
        },
        fileSize: {
          type: "string",
          defaultValue: "",
        },
        removedFileName: {
          type: "string",
          defaultValue: "",
        },
        checkInit: {
          type: "boolean",
          defaultValue: false,
        },
      },
      events: {
        change: {
          allowPreventDefault: true,
          parameters: {},
        },
        remove: {
          allowPreventDefault: true,
          parameters: {},
        },
      },
    },

    init() {
      this._setControlBound = this.setControl.bind(this);
      _registerCallback("onAfterRendering", this._setControlBound);
    },
    exit() {
      _unregisterCallback("onAfterRendering", this._setControlBound);
    },

    _readFile(file) {
      const reader = new FileReader();
      reader.onload = () => {
        if (this.isDestroyed && this.isDestroyed()) return;
        this.setProperty("fileData", reader.result);
        this.setProperty("fileName", file.name);
        this.setProperty("mediaType", file.type);
        this.setProperty("fileSize", String(file.size));
        this.fireChange();
      };
      reader.onerror = () =>
        _logError("UploadSetExt: FileReader failed", reader.error);
      reader.readAsDataURL(file);
    },

    onItemAdded(oEvent) {
      const item = oEvent.getParameter("item");
      const file = item && item.getFileObject ? item.getFileObject() : null;
      if (file) this._readFile(file);
    },

    onItemRemoved(oEvent) {
      const item = oEvent.getParameter("item");
      const name = item && item.getFileName ? item.getFileName() : "";
      this.setProperty("removedFileName", name);
      this.fireRemove();
    },

    renderer: { apiVersion: 2, render() {} },
    setControl() {
      const uploadSet =
        z2ui5.oView && z2ui5.oView.byId(this.getProperty("uploadSetId"));
      if (!uploadSet || this.getProperty("checkInit")) return;
      this.setProperty("checkInit", true);
      try {
        uploadSet.attachAfterItemAdded(this.onItemAdded.bind(this));
        uploadSet.attachAfterItemRemoved(this.onItemRemoved.bind(this));
      } catch (e) {
        _logError("UploadSetExt.setControl: setup failed", e);
      }
    },
  });
});

sap.ui.define(
  "z2ui5/SmartMultiInputExt",
  ["sap/ui/core/Control"],
  (Control) => {
    "use strict";

    return Control.extend("z2ui5.SmartMultiInputExt", {
      metadata: {
        properties: {
          multiInputId: {
            type: "string",
          },
          addedTokens: {
            type: "object",
          },
          removedTokens: {
            type: "object",
          },
          rangeData: {
            type: "object",
            defaultValue: [],
          },
          checkInit: {
            type: "boolean",
            defaultValue: false,
          },
        },
        events: {
          change: {
            allowPreventDefault: true,
            parameters: {},
          },
        },
      },

      init() {
        this._setControlBound = this.setControl.bind(this);
        this._oInput = null;
        this._oPendingInnerControlsCreated = null;
        this._bInnerControlsCreated = false;
        _registerCallback("onAfterRendering", this._setControlBound);
      },
      exit() {
        _unregisterCallback("onAfterRendering", this._setControlBound);
        // Resolve any still-pending promise so awaiters don't hang.
        if (this._oPendingInnerControlsCreated) {
          this._oPendingInnerControlsCreated(null);
        }
        this._oPendingInnerControlsCreated = null;
      },

      onTokenUpdate(oEvent) {
        const mParameters = oEvent.mParameters;
        const isRemoved = mParameters.type === "removed";
        const rawList =
          mParameters[isRemoved ? "removedTokens" : "addedTokens"] || [];
        const mappedTokens = rawList.map((item) => ({
          KEY: item.getKey(),
          TEXT: item.getText(),
        }));
        this.setProperty("addedTokens", isRemoved ? [] : mappedTokens);
        this.setProperty("removedTokens", isRemoved ? mappedTokens : []);

        // Mirror each range entry with the visible token text + long key
        // so the backend has enough info to re-render the input later.
        const source = oEvent.getSource();
        const tokens = source.getTokens();
        const rangeData = source.getRangeData() || [];
        const enrichedRanges = rangeData.map((oRangeData, index) => {
          const token = tokens[index];
          oRangeData.tokenText = token ? token.getText() : "";
          oRangeData.tokenLongKey = token ? token.data("longKey") : undefined;
          return oRangeData;
        });
        this.setProperty("rangeData", enrichedRanges);
        this.fireChange();
      },
      async setRangeData(aRangeData) {
        this.setProperty("rangeData", aRangeData);
        try {
          const input = await this.inputInitialized();
          if ((this.isDestroyed && this.isDestroyed()) || !input) return;

          // Convert the ABAP-style uppercase keys to the camelCase property
          // names the smart multi input expects. "keyField" needs its capital
          // F preserved.
          const normalizedRangeData = aRangeData.map((oRangeData) => {
            const out = {};
            for (const [key, value] of Object.entries(oRangeData)) {
              const lower = key.toLowerCase();
              const finalKey = lower === "keyfield" ? "keyField" : lower;
              out[finalKey] = value;
            }
            return out;
          });
          input.setRangeData(normalizedRangeData);

          // We need to set token text explicitly, as setRangeData does no
          // recalculation.
          const inputTokens = input.getTokens() || [];
          for (const [index, token] of inputTokens.entries()) {
            const rangeItem = aRangeData[index];
            if (!rangeItem) continue;
            const { TOKENLONGKEY, TOKENTEXT } = rangeItem;
            token.data("longKey", TOKENLONGKEY);
            token.data("range", null);
            if (TOKENTEXT) token.setText(TOKENTEXT);
          }
        } catch (e) {
          _logError("SmartMultiInputExt.setRangeData failed", e);
        }
      },
      renderer: { apiVersion: 2, render() {} },
      setControl() {
        const input =
          z2ui5.oView && z2ui5.oView.byId(this.getProperty("multiInputId"));
        if (!input || this.getProperty("checkInit")) return;
        this.setProperty("checkInit", true);
        try {
          input.attachTokenUpdate(this.onTokenUpdate.bind(this));
          input.attachInnerControlsCreated(
            this.onInnerControlsCreated.bind(this),
          );
        } catch (e) {
          _logError("SmartMultiInputExt.setControl: setup failed", e);
        }
      },
      // Returns a Promise that resolves once the smart multi input's inner
      // controls exist - they are created lazily on first interaction.
      inputInitialized() {
        return new Promise((resolve) => {
          if (this._bInnerControlsCreated) {
            resolve(this._oInput);
          } else {
            this._oPendingInnerControlsCreated = resolve;
          }
        });
      },
      onInnerControlsCreated(oEvent) {
        this._oInput = oEvent.getSource();
        if (this._oPendingInnerControlsCreated) {
          this._oPendingInnerControlsCreated(this._oInput);
        }
        this._oPendingInnerControlsCreated = null;
        this._bInnerControlsCreated = true;
      },
    });
  },
);

sap.ui.define(
  "z2ui5/CameraPicture",
  ["sap/ui/core/Control", "sap/m/Dialog", "sap/m/Button", "sap/ui/core/HTML"],
  (Control, Dialog, Button, HTML) => {
    "use strict";
    const _CTX_2D_OPTS = { willReadFrequently: true };
    const _THUMB_W = 300;
    return Control.extend("z2ui5.CameraPicture", {
      metadata: {
        properties: {
          id: { type: "string" },
          value: { type: "string" },
          thumbnail: { type: "string" },
          press: { type: "string" },
          width: { type: "string", defaultValue: "200" },
          height: { type: "string", defaultValue: "200" },
          autoplay: { type: "boolean", defaultValue: true },
          facingMode: { type: "string" },
          deviceId: { type: "string" },
        },
        events: {
          OnPhoto: {
            allowPreventDefault: true,
            parameters: {
              photo: {
                type: "string",
              },
            },
          },
        },
      },

      capture() {
        const video = document.getElementById(`${this.getId()}-video`);
        const canvas = document.getElementById(`${this.getId()}-canvas`);
        if (!video || !canvas) return;

        const videoWidth = video.videoWidth;
        const videoHeight = video.videoHeight;
        canvas.width = videoWidth;
        canvas.height = videoHeight;

        const ctx = canvas.getContext("2d", _CTX_2D_OPTS);
        if (!ctx) return;
        ctx.drawImage(video, 0, 0, videoWidth, videoHeight);

        // Full-resolution JPEG (quality 0.85) for the value, plus a small
        // thumbnail (max width _THUMB_W) at lower quality for previews.
        let resultb64;
        try {
          resultb64 = canvas.toDataURL("image/jpeg", 0.85);
        } catch (e) {
          _logError("CameraPicture: canvas toDataURL failed", e);
          return;
        }

        const thumbH = videoWidth
          ? Math.round((videoHeight * _THUMB_W) / videoWidth)
          : _THUMB_W;
        const thumbCanvas = document.createElement("canvas");
        thumbCanvas.width = _THUMB_W;
        thumbCanvas.height = thumbH;
        const thumbCtx = thumbCanvas.getContext("2d", _CTX_2D_OPTS);
        if (thumbCtx) thumbCtx.drawImage(canvas, 0, 0, _THUMB_W, thumbH);

        let thumbB64 = "";
        try {
          thumbB64 = thumbCanvas.toDataURL("image/jpeg", 0.7);
        } catch (e) {
          _logError("CameraPicture: thumb toDataURL failed", e);
        }

        if (this.isDestroyed && this.isDestroyed()) return;
        this.setProperty("value", resultb64);
        this.setProperty("thumbnail", thumbB64);
        this.fireOnPhoto({ photo: resultb64 });
        this._stopCamera();
      },

      _stopCamera() {
        // Stop every track of the active stream so the OS frees the camera.
        if (this._stream) {
          for (const track of this._stream.getTracks()) track.stop();
        }
        this._stream = null;
        const video = document.getElementById(`${this.getId()}-video`);
        if (video) video.srcObject = null;
      },

      onPicture() {
        if (this._oScanDialog && this._oScanDialog.isOpen()) return;
        if (!this._oScanDialog) {
          this._oScanDialog = new Dialog({
            title: "Device Photo Function",
            contentWidth: "640px",
            contentHeight: "480px",
            horizontalScrolling: false,
            verticalScrolling: false,
            stretch: true,
            afterClose: () => this._stopCamera(),
            content: [
              new HTML({
                id: `${this.getId()}PictureContainer`,
                content: `<video style="width:100%;height:100%;object-fit:contain;" autoplay="true" id="${this.getId()}-video">`,
              }),
              new Button({
                text: "Capture",
                press: () => {
                  this.capture();
                  this._oScanDialog.close();
                },
              }),
              new HTML({
                content: `<canvas hidden id="${this.getId()}-canvas" style="overflow:auto"></canvas>`,
              }),
            ],
            endButton: new Button({
              text: "Cancel",
              press: () => {
                this._stopCamera();
                this._oScanDialog.close();
              },
            }),
          });
        }

        this._oScanDialog.attachEventOnce("afterOpen", async () => {
          if (this.isDestroyed && this.isDestroyed()) return;
          const video = document.getElementById(`${this.getId()}-video`);
          if (!video) {
            _logError(
              "CameraPicture: video element not found after dialog open",
            );
            return;
          }
          const facingMode = this.getProperty("facingMode");
          const deviceId = this.getProperty("deviceId");
          const options = {
            video: { width: { ideal: 1920 }, height: { ideal: 1080 } },
          };
          if (deviceId) options.video.deviceId = deviceId;
          if (facingMode) options.video.facingMode = { exact: facingMode };

          try {
            const md = navigator.mediaDevices;
            if (!md || !md.getUserMedia) return;
            const stream = await md.getUserMedia(options);
            if (!stream) return;
            // Guard: the control could have been destroyed during the
            // getUserMedia await. Release the camera if so.
            if (this.isDestroyed && this.isDestroyed()) {
              for (const t of stream.getTracks()) t.stop();
              return;
            }
            this._stream = stream;
            video.srcObject = stream;
          } catch (error) {
            _logError("CameraPicture: getUserMedia failed", error);
          }
        });
        this._oScanDialog.open();
      },

      exit() {
        this._stopCamera();
        if (this._oButton) this._oButton.destroy();
        if (this._oScanDialog) this._oScanDialog.destroy();
      },
      renderer: {
        apiVersion: 2,
        render(oRm, oControl) {
          if (!oControl._oButton) {
            oControl._oButton = new Button({
              icon: "sap-icon://camera",
              text: "Camera",
              press: oControl.onPicture.bind(oControl),
            });
          }
          oRm.renderControl(oControl._oButton);
        },
      },
    });
  },
);

sap.ui.define(
  "z2ui5/CameraSelector",
  ["sap/m/ComboBox", "sap/ui/core/Item", "sap/m/ComboBoxRenderer"],
  (ComboBox, Item, ComboBoxRenderer) => {
    "use strict";
    return ComboBox.extend("z2ui5.CameraSelector", {
      async init() {
        ComboBox.prototype.init.call(this);
        try {
          const md = navigator.mediaDevices;
          if (!md || !md.enumerateDevices) return;
          const devices = await md.enumerateDevices();
          if (!devices) return;
          for (const device of devices) {
            // Only video inputs are relevant; also stop adding items when the
            // ComboBox has been destroyed during the await.
            if (device.kind !== "videoinput") continue;
            if (this.isDestroyed && this.isDestroyed()) return;
            this.addItem(
              new Item({ key: device.deviceId, text: device.label }),
            );
          }
        } catch (err) {
          _logError("CameraDeviceList: enumerateDevices failed", err);
        }
      },

      renderer: ComboBoxRenderer,
    });
  },
);

sap.ui.define("z2ui5/UITableExt", ["sap/ui/core/Control"], (Control) => {
  "use strict";

  const opSymbols = { EQ: "", NE: "!", LT: "<", LE: "<=", GT: ">", GE: ">=" };
  const filterDisplayFns = {
    Contains: (v) => `*${v ?? ""}*`,
    StartsWith: (v) => `^${v ?? ""}`,
    EndsWith: (v) => `${v ?? ""}$`,
  };

  return Control.extend("z2ui5.UITableExt", {
    metadata: {
      properties: {
        tableId: {
          type: "string",
        },
      },
    },

    init() {
      this._beforeBound = () => {
        this.readFilter();
        this.readSort();
      };
      this._afterBound = () => {
        this.setFilter();
        this.setSort();
      };
      _registerCallback("onBeforeRoundtrip", this._beforeBound);
      _registerCallback("onAfterRoundtrip", this._afterBound);
    },

    exit() {
      _unregisterCallback("onBeforeRoundtrip", this._beforeBound);
      _unregisterCallback("onAfterRoundtrip", this._afterBound);
    },

    _getTable() {
      if (!z2ui5.oView) return undefined;
      return z2ui5.oView.byId(this.getProperty("tableId"));
    },

    readFilter() {
      try {
        const table = this._getTable();
        const binding = table && table.getBinding();
        this.aFilters = binding ? binding.aFilters : undefined;
      } catch (e) {
        _logError("UITableExt.readFilter failed", e);
      }
    },

    _applyWhenRendered(oTable, fn) {
      if (oTable.getDomRef()) {
        fn();
        return;
      }
      // Not rendered yet -> run `fn` once the next render completes.
      const delegate = {
        onAfterRendering: () => {
          oTable.removeEventDelegate(delegate);
          if (!(this.isDestroyed && this.isDestroyed())) fn();
        },
      };
      oTable.addEventDelegate(delegate);
    },

    _applyFilters(oTable, aFilters) {
      if (!aFilters) return;
      const binding = oTable.getBinding();
      if (!binding) return;
      binding.filter(aFilters);
      const columns = oTable.getColumns();

      for (const oFilter of aFilters) {
        // Multi-filter? Pick the inner filter for the column lookup.
        let sProperty = oFilter.sPath;
        if (!sProperty && oFilter.aFilters && oFilter.aFilters[0]) {
          sProperty = oFilter.aFilters[0].sPath;
        }
        if (!sProperty) continue;

        const operator = oFilter.sOperator;
        // Pick the most meaningful value to display in the column header.
        let vValue = oFilter.oValue1;
        if (vValue === undefined) vValue = oFilter.oValue2;
        if (vValue === undefined && oFilter.aFilters && oFilter.aFilters[0]) {
          vValue = oFilter.aFilters[0].oValue1;
        }

        // Choose how to format the column header label for this operator.
        let displayFn;
        if (operator === "BT") {
          // "between" displays "from...to".
          displayFn = (v) => {
            const from = v == null ? "" : v;
            const to = oFilter.oValue2 == null ? "" : oFilter.oValue2;
            return `${from}...${to}`;
          };
        } else if (filterDisplayFns[operator]) {
          displayFn = filterDisplayFns[operator];
        } else {
          // Fallback: optional operator prefix (e.g. "!" for NE) + value.
          const prefix = opSymbols[operator] || "";
          displayFn = (v) => `${prefix}${v == null ? "" : v}`;
        }
        const display = displayFn(vValue);

        for (const oCol of columns) {
          if (
            oCol.getFilterProperty &&
            oCol.getFilterProperty() === sProperty
          ) {
            oCol.setFilterValue(display);
            oCol.setFiltered(!!display);
          }
        }
      }
    },

    _applyToTable(applyFn, errorMsg) {
      try {
        const oTable = this._getTable();
        if (!oTable) return;
        this._applyWhenRendered(oTable, () => applyFn(oTable));
      } catch (e) {
        _logError(errorMsg, e);
      }
    },

    setFilter() {
      this._applyToTable(
        (oTable) => this._applyFilters(oTable, this.aFilters),
        "UITableExt.setFilter failed",
      );
    },

    readSort() {
      try {
        const table = this._getTable();
        const binding = table && table.getBinding();
        this.aSorters = binding ? binding.aSorters : undefined;
      } catch (e) {
        _logError("UITableExt.readSort failed", e);
      }
    },

    _applySorters(oTable, aSorters) {
      if (!aSorters) return;
      const binding = oTable.getBinding();
      if (!binding) return;
      binding.sort(aSorters);

      const columns = oTable.getColumns();
      for (const [idx, srt] of aSorters.entries()) {
        for (const oCol of columns) {
          if (oCol.getSortProperty && oCol.getSortProperty() === srt.sPath) {
            oCol.setSorted(true);
            oCol.setSortOrder(srt.bDescending ? "Descending" : "Ascending");
            // setSortIndex is only available on some column variants.
            if (oCol.setSortIndex) oCol.setSortIndex(idx);
          }
        }
      }
    },

    setSort() {
      this._applyToTable(
        (oTable) => this._applySorters(oTable, this.aSorters),
        "UITableExt.setSort failed",
      );
    },
    renderer: { apiVersion: 2, render() {} },
  });
});

sap.ui.define("z2ui5/Util", [], () => {
  "use strict";

  // Splits an 8-character ABAP date string "YYYYMMDD" into the [year, month,
  // day] tuple JavaScript's Date constructor expects. Note: Date months are
  // 0-based, so we subtract 1 from the month component.
  function parseDmy(d) {
    return [+d.slice(0, 4), +d.slice(4, 6) - 1, +d.slice(6, 8)];
  }

  return {
    DateCreateObject(s) {
      return new Date(s);
    },
    DateAbapDateToDateObject(d) {
      return new Date(...parseDmy(d));
    },
    // t is an ABAP time string "HHMMSS"; if omitted we default to midnight.
    DateAbapDateTimeToDateObject(d, t = "000000") {
      return new Date(
        ...parseDmy(d),
        +t.slice(0, 2),
        +t.slice(2, 4),
        +t.slice(4, 6),
      );
    },
  };
});
sap.ui.require(["z2ui5/Util"], (Util) => (z2ui5.Util = Util));

sap.ui.define("z2ui5/Favicon", ["sap/ui/core/Control"], (Control) => {
  "use strict";
  return Control.extend("z2ui5.Favicon", {
    metadata: {
      properties: {
        favicon: {
          type: "string",
        },
      },
    },
    setFavicon(val) {
      this.setProperty("favicon", val);
      const existing = document.head.querySelector('link[rel="shortcut icon"]');
      if (existing) {
        existing.href = val;
        return;
      }
      const link = document.createElement("link");
      link.rel = "shortcut icon";
      link.href = val;
      document.head.appendChild(link);
    },
    renderer: { apiVersion: 2, render() {} },
  });
});

sap.ui.define("z2ui5/Dirty", ["sap/ui/core/Control"], (Control) => {
  "use strict";
  return Control.extend("z2ui5.Dirty", {
    metadata: {
      properties: {
        isDirty: {
          type: "boolean",
          defaultValue: false,
        },
      },
    },
    setIsDirty(val) {
      this.setProperty("isDirty", val);

      // Fallback for non-launchpad scenarios: ask the browser to confirm
      // before leaving the page when something is unsaved.
      const fallback = () => {
        if (val) {
          window.onbeforeunload = (e) => {
            e.preventDefault();
            e.returnValue = "";
          };
        } else {
          window.onbeforeunload = null;
        }
      };

      // Use the FLP dirty flag when running inside the Launchpad (SAPUI5
      // only); otherwise fall back to the browser unload prompt.
      try {
        const launchpad = z2ui5.oLaunchpad;
        const hasFlpDirtyFlag =
          launchpad &&
          launchpad.Container &&
          launchpad.Container.setDirtyFlag &&
          launchpad.ShellUIService;
        if (hasFlpDirtyFlag) {
          launchpad.Container.setDirtyFlag(val);
        } else {
          fallback();
        }
      } catch (e) {
        _logError("Dirty.setIsDirty: setDirtyFlag failed", e);
        fallback();
      }
    },
    exit() {
      window.onbeforeunload = null;
    },
    renderer: { apiVersion: 2, render() {} },
  });
});
