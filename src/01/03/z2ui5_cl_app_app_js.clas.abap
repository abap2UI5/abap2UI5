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

    result = `// Append an entry to the global error log. We create the array on first use.` && |\n| &&
             `function _logError(message, error) {` && |\n| &&
             `  if (!z2ui5.errors) z2ui5.errors = [];` && |\n| &&
             `  const entry = { message: message, ts: new Date().toISOString() };` && |\n| &&
             `  if (error !== undefined) entry.error = error;` && |\n| &&
             `  z2ui5.errors.push(entry);` && |\n| &&
             `}` && |\n| &&
             `` && |\n| &&
             `// Helpers for managing z2ui5 callback arrays (onBeforeRoundtrip,` && |\n| &&
             `// onAfterRendering, ...). Several custom controls register hooks here in` && |\n| &&
             `// init() and remove them in exit().` && |\n| &&
             `function _registerCallback(name, fn) {` && |\n| &&
             `  if (!z2ui5[name]) z2ui5[name] = [];` && |\n| &&
             `  z2ui5[name].push(fn);` && |\n| &&
             `}` && |\n| &&
             `function _unregisterCallback(name, fn) {` && |\n| &&
             `  if (!z2ui5[name]) return;` && |\n| &&
             `  z2ui5[name] = z2ui5[name].filter((f) => f !== fn);` && |\n| &&
             `}` && |\n| &&
             `` && |\n| &&
             `sap.ui.define(` && |\n| &&
             `  [` && |\n| &&
             `    "sap/ui/core/mvc/Controller",` && |\n| &&
             `    "z2ui5/controller/View1.controller",` && |\n| &&
             `    "z2ui5/cc/Server",` && |\n| &&
             `    "sap/ui/core/routing/HashChanger",` && |\n| &&
             `  ],` && |\n| &&
             `  (BaseController, Controller, Server, HashChanger) => {` && |\n| &&
             `    "use strict";` && |\n| &&
             `    return BaseController.extend("z2ui5.controller.App", {` && |\n| &&
             `      onInit() {` && |\n| &&
             `        const oOwnerComponent = this.getOwnerComponent();` && |\n| &&
             `        z2ui5.oOwnerComponent = oOwnerComponent;` && |\n| &&
             `` && |\n| &&
             `        // Read the backend URI from the manifest, falling back step by step` && |\n| &&
             `        // so a missing entry doesn't blow up.` && |\n| &&
             `        const manifest = oOwnerComponent.getManifest();` && |\n| &&
             `        const sapApp = manifest && manifest["sap.app"];` && |\n| &&
             `        const dataSources = sapApp && sapApp.dataSources;` && |\n| &&
             `        const http = dataSources && dataSources.http;` && |\n| &&
             `        const uri = http && http.uri;` && |\n| &&
             `        z2ui5.oConfig.pathname = z2ui5.checkLocal ? window.location.href : uri;` && |\n| &&
             `` && |\n| &&
             `        // Set up the shared z2ui5 state used by the whole app.` && |\n| &&
             `        z2ui5.oController = new Controller();` && |\n| &&
             `        z2ui5.oApp = this.getView().byId("app");` && |\n| &&
             `        z2ui5.oControllerNest = new Controller();` && |\n| &&
             `        z2ui5.oControllerNest2 = new Controller();` && |\n| &&
             `        z2ui5.oControllerPopup = new Controller();` && |\n| &&
             `        z2ui5.oControllerPopover = new Controller();` && |\n| &&
             `        z2ui5.onBeforeRoundtrip = [];` && |\n| &&
             `        z2ui5.onAfterRendering = [];` && |\n| &&
             `        z2ui5.onBeforeEventFrontend = [];` && |\n| &&
             `        z2ui5.onAfterRoundtrip = [];` && |\n| &&
             `        z2ui5.errors = [];` && |\n| &&
             `        z2ui5.checkNestAfter = false;` && |\n| &&
             `        z2ui5.checkNestAfter2 = false;` && |\n| &&
             `` && |\n| &&
             `        // If the URL already contains a hash, kick off the initial roundtrip` && |\n| &&
             `        // so the backend can restore that state.` && |\n| &&
             `        if (HashChanger.getInstance().getHash()) {` && |\n| &&
             `          z2ui5.checkInit = true;` && |\n| &&
             `          Server.Roundtrip();` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `    });` && |\n| &&
             `  },` && |\n| &&
             `);` && |\n| &&
             `` && |\n| &&
             `sap.ui.define("z2ui5/Timer", ["sap/ui/core/Control"], (Control) => {` && |\n| &&
             `  "use strict";` && |\n| &&
             `` && |\n| &&
             `  return Control.extend("z2ui5.Timer", {` && |\n| &&
             `    metadata: {` && |\n| &&
             `      properties: {` && |\n| &&
             `        delayMS: {` && |\n| &&
             `          type: "int",` && |\n| &&
             `          defaultValue: 0,` && |\n| &&
             `        },` && |\n| &&
             `        checkActive: {` && |\n| &&
             `          type: "boolean",` && |\n| &&
             `          defaultValue: true,` && |\n| &&
             `        },` && |\n| &&
             `        checkRepeat: {` && |\n| &&
             `          type: "boolean",` && |\n| &&
             `          defaultValue: false,` && |\n| &&
             `        },` && |\n| &&
             `      },` && |\n| &&
             `      events: {` && |\n| &&
             `        finished: {` && |\n| &&
             `          allowPreventDefault: true,` && |\n| &&
             `          parameters: {},` && |\n| &&
             `        },` && |\n| &&
             `      },` && |\n| &&
             `    },` && |\n| &&
             `    onAfterRendering() {` && |\n| &&
             `      if (!this._pendingTimer) return;` && |\n| &&
             `      this._pendingTimer = false;` && |\n| &&
             `      this.delayedCall();` && |\n| &&
             `    },` && |\n| &&
             `    exit() {` && |\n| &&
             `      clearTimeout(this._timerId);` && |\n| &&
             `    },` && |\n| &&
             `    delayedCall() {` && |\n| &&
             `      if (!this.getProperty("checkActive")) return;` && |\n| &&
             `      clearTimeout(this._timerId);` && |\n| &&
             `      const repeat = this.getProperty("checkRepeat");` && |\n| &&
             `      const delay = this.getProperty("delayMS");` && |\n| &&
             `      this._timerId = setTimeout(() => {` && |\n| &&
             `        // The control might have been destroyed during the delay.` && |\n| &&
             `        if (this.isDestroyed && this.isDestroyed()) return;` && |\n| &&
             `        if (!repeat) this.setProperty("checkActive", false, true);` && |\n| &&
             `        this.fireFinished();` && |\n| &&
             `        // For repeating timers, queue the next iteration. Re-check destroy` && |\n| &&
             `        // again because fireFinished may have triggered teardown.` && |\n| &&
             `        if (repeat && !(this.isDestroyed && this.isDestroyed())) {` && |\n| &&
             `          this.delayedCall();` && |\n| &&
             `        }` && |\n| &&
             `      }, delay);` && |\n| &&
             `    },` && |\n| &&
             `    renderer: {` && |\n| &&
             `      apiVersion: 2,` && |\n| &&
             `      render(oRm, oControl) {` && |\n| &&
             `        oRm.openStart("span", oControl);` && |\n| &&
             `        oRm.style("display", "none");` && |\n| &&
             `        oRm.openEnd();` && |\n| &&
             `        oRm.close("span");` && |\n| &&
             `        oControl._pendingTimer = oControl.getProperty("checkActive");` && |\n| &&
             `      },` && |\n| &&
             `    },` && |\n| &&
             `  });` && |\n| &&
             `});` && |\n| &&
             `` && |\n| &&
             `sap.ui.define("z2ui5/Focus", ["sap/ui/core/Control"], (Control) => {` && |\n| &&
             `  "use strict";` && |\n| &&
             `  return Control.extend("z2ui5.Focus", {` && |\n| &&
             `    metadata: {` && |\n| &&
             `      properties: {` && |\n| &&
             `        setUpdate: {` && |\n| &&
             `          type: "boolean",` && |\n| &&
             `          defaultValue: true,` && |\n| &&
             `        },` && |\n| &&
             `        focusId: {` && |\n| &&
             `          type: "string",` && |\n| &&
             `        },` && |\n| &&
             `        selectionStart: {` && |\n| &&
             `          type: "string",` && |\n| &&
             `          defaultValue: "0",` && |\n| &&
             `        },` && |\n| &&
             `        selectionEnd: {` && |\n| &&
             `          type: "string",` && |\n| &&
             `          defaultValue: "0",` && |\n| &&
             `        },` && |\n| &&
             `      },` && |\n| &&
             `    },` && |\n| &&
             `    setFocusId(val) {` && |\n| &&
             `      try {` && |\n| &&
             `        this.setProperty("focusId", val);` && |\n| &&
             `        const oElement = z2ui5.oView && z2ui5.oView.byId(val);` && |\n| &&
             `        if (oElement) oElement.applyFocusInfo(oElement.getFocusInfo());` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        _logError("Focus.setFocusId failed", e);` && |\n| &&
             `      }` && |\n| &&
             `    },` && |\n| &&
             `    onAfterRendering() {` && |\n| &&
             `      if (!this._pendingFocus) return;` && |\n| &&
             `      this._pendingFocus = false;` && |\n| &&
             `      const oElement =` && |\n| &&
             `        z2ui5.oView && z2ui5.oView.byId(this.getProperty("focusId"));` && |\n| &&
             `      if (!oElement) return;` && |\n| &&
             `      try {` && |\n| &&
             `        // Merge the additional selection info into the existing focus info,` && |\n| &&
             `        // then apply both at once.` && |\n| &&
             `        const info = oElement.getFocusInfo();` && |\n| &&
             `        info.selectionStart = +this.getProperty("selectionStart");` && |\n| &&
             `        info.selectionEnd = +this.getProperty("selectionEnd");` && |\n| &&
             `        oElement.applyFocusInfo(info);` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        _logError("Focus.onAfterRendering: applyFocusInfo failed", e);` && |\n| &&
             `      }` && |\n| &&
             `    },` && |\n| &&
             `    renderer: {` && |\n| &&
             `      apiVersion: 2,` && |\n| &&
             `      render(oRm, oControl) {` && |\n| &&
             `        oRm.openStart("span", oControl);` && |\n| &&
             `        oRm.style("display", "none");` && |\n| &&
             `        oRm.openEnd();` && |\n| &&
             `        oRm.close("span");` && |\n| &&
             `        if (!oControl.getProperty("setUpdate")) return;` && |\n| &&
             `        oControl.setProperty("setUpdate", false, true);` && |\n| &&
             `        oControl._pendingFocus = true;` && |\n| &&
             `      },` && |\n| &&
             `    },` && |\n| &&
             `  });` && |\n| &&
             `});` && |\n| &&
             `` && |\n| &&
             `sap.ui.define("z2ui5/Title", ["sap/ui/core/Control"], (Control) => {` && |\n| &&
             `  "use strict";` && |\n| &&
             `  return Control.extend("z2ui5.Title", {` && |\n| &&
             `    metadata: {` && |\n| &&
             `      properties: {` && |\n| &&
             `        title: {` && |\n| &&
             `          type: "string",` && |\n| &&
             `        },` && |\n| &&
             `      },` && |\n| &&
             `    },` && |\n| &&
             `    setTitle(val) {` && |\n| &&
             `      this.setProperty("title", val);` && |\n| &&
             `      document.title = val == null ? "" : String(val);` && |\n| &&
             `    },` && |\n| &&
             `    renderer: { apiVersion: 2, render() {} },` && |\n| &&
             `  });` && |\n| &&
             `});` && |\n| &&
             `` && |\n| &&
             `sap.ui.define("z2ui5/LPTitle", ["sap/ui/core/Control"], (Control) => {` && |\n| &&
             `  "use strict";` && |\n| &&
             `  return Control.extend("z2ui5.LPTitle", {` && |\n| &&
             `    metadata: {` && |\n| &&
             `      properties: {` && |\n| &&
             `        title: {` && |\n| &&
             `          type: "string",` && |\n| &&
             `        },` && |\n| &&
             `        ApplicationFullWidth: {` && |\n| &&
             `          type: "boolean",` && |\n| &&
             `        },` && |\n| &&
             `      },` && |\n| &&
             `    },` && |\n| &&
             `    setTitle(val) {` && |\n| &&
             `      this.setProperty("title", val);` && |\n| &&
             `      try {` && |\n| &&
             `        const shell = z2ui5.oLaunchpad && z2ui5.oLaunchpad.ShellUIService;` && |\n| &&
             `        if (!shell || !shell.setTitle) return;` && |\n| &&
             `        const result = shell.setTitle(val);` && |\n| &&
             `        // setTitle may return a Promise; report any async failure.` && |\n| &&
             `        if (result && result.catch) {` && |\n| &&
             `          result.catch((e) =>` && |\n| &&
             `            _logError("LPTitle: Launchpad Service setTitle failed", e),` && |\n| &&
             `          );` && |\n| &&
             `        }` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        _logError("LPTitle: Launchpad Service setTitle failed", e);` && |\n| &&
             `      }` && |\n| &&
             `    },` && |\n| &&
             `` && |\n| &&
             `    setApplicationFullWidth(val) {` && |\n| &&
             `      this.setProperty("ApplicationFullWidth", val);` && |\n| &&
             `      try {` && |\n| &&
             `        const config = z2ui5.oLaunchpad && z2ui5.oLaunchpad.AppConfiguration;` && |\n| &&
             `        if (config && config.setApplicationFullWidth) {` && |\n| &&
             `          config.setApplicationFullWidth(val);` && |\n| &&
             `        }` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        _logError("LPTitle: setApplicationFullWidth failed", e);` && |\n| &&
             `      }` && |\n| &&
             `    },` && |\n| &&
             `` && |\n| &&
             `    renderer: { apiVersion: 2, render() {} },` && |\n| &&
             `  });` && |\n| &&
             `});` && |\n| &&
             `` && |\n| &&
             `sap.ui.define("z2ui5/History", ["sap/ui/core/Control"], (Control) => {` && |\n| &&
             `  "use strict";` && |\n| &&
             `  return Control.extend("z2ui5.History", {` && |\n| &&
             `    metadata: {` && |\n| &&
             `      properties: {` && |\n| &&
             `        search: {` && |\n| &&
             `          type: "string",` && |\n| &&
             `        },` && |\n| &&
             `      },` && |\n| &&
             `    },` && |\n| &&
             `    setSearch(val) {` && |\n| &&
             `      this.setProperty("search", val);` && |\n| &&
             `      try {` && |\n| &&
             `        const search = val == null ? "" : val;` && |\n| &&
             `        history.replaceState(null, "", ``${window.location.pathname}${search}``);` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        _logError("History.setSearch: replaceState failed", e);` && |\n| &&
             `      }` && |\n| &&
             `    },` && |\n| &&
             `    renderer: { apiVersion: 2, render() {} },` && |\n| &&
             `  });` && |\n| &&
             `});` && |\n| &&
             `` && |\n| &&
             `sap.ui.define("z2ui5/Tree", ["sap/ui/core/Control"], (Control) => {` && |\n| &&
             `  "use strict";` && |\n| &&
             `` && |\n| &&
             `  return Control.extend("z2ui5.Tree", {` && |\n| &&
             `    metadata: {` && |\n| &&
             `      properties: {` && |\n| &&
             `        tree_id: {` && |\n| &&
             `          type: "string",` && |\n| &&
             `        },` && |\n| &&
             `      },` && |\n| &&
             `    },` && |\n| &&
             `` && |\n| &&
             `    _getTreeBinding() {` && |\n| &&
             `      if (!z2ui5.oView) return undefined;` && |\n| &&
             `      const treeControl = z2ui5.oView.byId(this.getProperty("tree_id"));` && |\n| &&
             `      if (!treeControl) return undefined;` && |\n| &&
             `      return treeControl.getBinding("items");` && |\n| &&
             `    },` && |\n| &&
             `` && |\n| &&
             `    setBackend() {` && |\n| &&
             `      try {` && |\n| &&
             `        const binding = this._getTreeBinding();` && |\n| &&
             `        z2ui5.treeState = binding ? binding.getCurrentTreeState() : undefined;` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        _logError("Tree.setBackend: failed", e);` && |\n| &&
             `      }` && |\n| &&
             `    },` && |\n| &&
             `` && |\n| &&
             `    init() {` && |\n| &&
             `      this._setBackendBound = this.setBackend.bind(this);` && |\n| &&
             `      _registerCallback("onBeforeRoundtrip", this._setBackendBound);` && |\n| &&
             `    },` && |\n| &&
             `` && |\n| &&
             `    exit() {` && |\n| &&
             `      _unregisterCallback("onBeforeRoundtrip", this._setBackendBound);` && |\n| &&
             `    },` && |\n| &&
             `` && |\n| &&
             `    onAfterRendering() {` && |\n| &&
             `      if (!this._pendingTreeState) return;` && |\n| &&
             `      this._pendingTreeState = false;` && |\n| &&
             `      try {` && |\n| &&
             `        const binding = this._getTreeBinding();` && |\n| &&
             `        if (binding) binding.setTreeState(z2ui5.treeState);` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        _logError("Tree.onAfterRendering: setTreeState failed", e);` && |\n| &&
             `      }` && |\n| &&
             `    },` && |\n| &&
             `` && |\n| &&
             `    renderer: {` && |\n| &&
             `      apiVersion: 2,` && |\n| &&
             `      render(oRm, oControl) {` && |\n| &&
             `        oRm.openStart("span", oControl);` && |\n| &&
             `        oRm.style("display", "none");` && |\n| &&
             `        oRm.openEnd();` && |\n| &&
             `        oRm.close("span");` && |\n| &&
             `        if (!z2ui5.treeState) return;` && |\n| &&
             `        oControl._pendingTreeState = true;` && |\n| &&
             `      },` && |\n| &&
             `    },` && |\n| &&
             `  });` && |\n| &&
             `});` && |\n| &&
             `` && |\n| &&
             `sap.ui.define("z2ui5/Scrolling", ["sap/ui/core/Control"], (Control) => {` && |\n| &&
             `  "use strict";` && |\n| &&
             `` && |\n| &&
             `  return Control.extend("z2ui5.Scrolling", {` && |\n| &&
             `    metadata: {` && |\n| &&
             `      properties: {` && |\n| &&
             `        setUpdate: {` && |\n| &&
             `          type: "boolean",` && |\n| &&
             `          defaultValue: true,` && |\n| &&
             `        },` && |\n| &&
             `        items: {` && |\n| &&
             `          type: "object",` && |\n| &&
             `        },` && |\n| &&
             `      },` && |\n| &&
             `    },` && |\n| &&
             `` && |\n| &&
             `    _getDomInnerElement(id) {` && |\n| &&
             `      const control = z2ui5.oView && z2ui5.oView.byId(id);` && |\n| &&
             `      if (!control) return null;` && |\n| &&
             `      return document.getElementById(``${control.getId()}-inner``);` && |\n| &&
             `    },` && |\n| &&
             `` && |\n| &&
             `    _getScrollTop(item) {` && |\n| &&
             `      try {` && |\n| &&
             `        const control = z2ui5.oView && z2ui5.oView.byId(item.N);` && |\n| &&
             `        // Some controls expose a scroll delegate; prefer it when available.` && |\n| &&
             `        if (control && control.getScrollDelegate) {` && |\n| &&
             `          const delegate = control.getScrollDelegate();` && |\n| &&
             `          if (delegate) return delegate.getScrollTop();` && |\n| &&
             `        }` && |\n| &&
             `        const element = this._getDomInnerElement(item.ID);` && |\n| &&
             `        return element ? element.scrollTop : 0;` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        _logError("Scrolling._getScrollTop: failed", e);` && |\n| &&
             `        return 0;` && |\n| &&
             `      }` && |\n| &&
             `    },` && |\n| &&
             `` && |\n| &&
             `    setBackend() {` && |\n| &&
             `      const items = this.getProperty("items");` && |\n| &&
             `      if (!items) return;` && |\n| &&
             `      try {` && |\n| &&
             `        // Resolve the binding path so we can mark only changed entries` && |\n| &&
             `        // as dirty in xxChangedPaths.` && |\n| &&
             `        const bindingInfo = this.getBindingInfo("items");` && |\n| &&
             `        let bindingPath;` && |\n| &&
             `        if (bindingInfo) {` && |\n| &&
             `          const parts = bindingInfo.parts;` && |\n| &&
             `          if (parts && parts[0]) bindingPath = parts[0].path;` && |\n| &&
             `          if (!bindingPath) bindingPath = bindingInfo.path;` && |\n| &&
             `        }` && |\n| &&
             `        for (const [index, item] of items.entries()) {` && |\n| &&
             `          const scrollTop = this._getScrollTop(item);` && |\n| &&
             `          if (item.V !== scrollTop) {` && |\n| &&
             `            item.V = scrollTop;` && |\n| &&
             |\n|.
    result = result &&
             `            if (bindingPath && z2ui5.xxChangedPaths) {` && |\n| &&
             `              z2ui5.xxChangedPaths.add(``${bindingPath}/${index}/V``);` && |\n| &&
             `            }` && |\n| &&
             `          }` && |\n| &&
             `        }` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        _logError("Scrolling.setBackend: failed", e);` && |\n| &&
             `      }` && |\n| &&
             `    },` && |\n| &&
             `` && |\n| &&
             `    init() {` && |\n| &&
             `      this._setBackendBound = this.setBackend.bind(this);` && |\n| &&
             `      _registerCallback("onBeforeRoundtrip", this._setBackendBound);` && |\n| &&
             `    },` && |\n| &&
             `` && |\n| &&
             `    exit() {` && |\n| &&
             `      _unregisterCallback("onBeforeRoundtrip", this._setBackendBound);` && |\n| &&
             `    },` && |\n| &&
             `` && |\n| &&
             `    _restoreScrollPosition(item) {` && |\n| &&
             `      try {` && |\n| &&
             `        const control = z2ui5.oView && z2ui5.oView.byId(item.N);` && |\n| &&
             `        if (control && control.scrollTo) {` && |\n| &&
             `          control.scrollTo(item.V);` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `        const element = this._getDomInnerElement(item.ID);` && |\n| &&
             `        if (element) element.scrollTop = item.V;` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        _logError("Scrolling._restoreScrollPosition: failed", e);` && |\n| &&
             `      }` && |\n| &&
             `    },` && |\n| &&
             `` && |\n| &&
             `    onAfterRendering() {` && |\n| &&
             `      if (!this._pendingScroll) return;` && |\n| &&
             `      this._pendingScroll = false;` && |\n| &&
             `` && |\n| &&
             `      const items = this.getProperty("items");` && |\n| &&
             `      if (!items) return;` && |\n| &&
             `` && |\n| &&
             `      try {` && |\n| &&
             `        for (const item of items) {` && |\n| &&
             `          const control = z2ui5.oView && z2ui5.oView.byId(item.N);` && |\n| &&
             `          if (!control) continue;` && |\n| &&
             `` && |\n| &&
             `          if (control.getDomRef()) {` && |\n| &&
             `            // The target control is already rendered -> restore immediately.` && |\n| &&
             `            this._restoreScrollPosition(item);` && |\n| &&
             `          } else {` && |\n| &&
             `            // Not rendered yet -> wait until it is, then restore once.` && |\n| &&
             `            const delegate = {` && |\n| &&
             `              onAfterRendering: () => {` && |\n| &&
             `                control.removeEventDelegate(delegate);` && |\n| &&
             `                if (!(this.isDestroyed && this.isDestroyed())) {` && |\n| &&
             `                  this._restoreScrollPosition(item);` && |\n| &&
             `                }` && |\n| &&
             `              },` && |\n| &&
             `            };` && |\n| &&
             `            control.addEventDelegate(delegate);` && |\n| &&
             `          }` && |\n| &&
             `        }` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        _logError("Scrolling.onAfterRendering: failed", e);` && |\n| &&
             `      }` && |\n| &&
             `    },` && |\n| &&
             `` && |\n| &&
             `    renderer: {` && |\n| &&
             `      apiVersion: 2,` && |\n| &&
             `      render(oRm, oControl) {` && |\n| &&
             `        oRm.openStart("span", oControl);` && |\n| &&
             `        oRm.style("display", "none");` && |\n| &&
             `        oRm.openEnd();` && |\n| &&
             `        oRm.close("span");` && |\n| &&
             `` && |\n| &&
             `        if (!oControl.getProperty("setUpdate")) return;` && |\n| &&
             `        oControl.setProperty("setUpdate", false, true);` && |\n| &&
             `        oControl._pendingScroll = true;` && |\n| &&
             `      },` && |\n| &&
             `    },` && |\n| &&
             `  });` && |\n| &&
             `});` && |\n| &&
             `` && |\n| &&
             `sap.ui.define("z2ui5/Info", ["sap/ui/core/Control"], (Control) => {` && |\n| &&
             `  "use strict";` && |\n| &&
             `` && |\n| &&
             `  return Control.extend("z2ui5.Info", {` && |\n| &&
             `    metadata: {` && |\n| &&
             `      properties: {` && |\n| &&
             `        ui5_version: {` && |\n| &&
             `          type: "string",` && |\n| &&
             `        },` && |\n| &&
             `        device_phone: {` && |\n| &&
             `          type: "string",` && |\n| &&
             `        },` && |\n| &&
             `        device_desktop: {` && |\n| &&
             `          type: "string",` && |\n| &&
             `        },` && |\n| &&
             `        device_tablet: {` && |\n| &&
             `          type: "string",` && |\n| &&
             `        },` && |\n| &&
             `        device_combi: {` && |\n| &&
             `          type: "string",` && |\n| &&
             `        },` && |\n| &&
             `        device_height: {` && |\n| &&
             `          type: "string",` && |\n| &&
             `        },` && |\n| &&
             `        device_width: {` && |\n| &&
             `          type: "string",` && |\n| &&
             `        },` && |\n| &&
             `        ui5_theme: {` && |\n| &&
             `          type: "string",` && |\n| &&
             `        },` && |\n| &&
             `        device_os: {` && |\n| &&
             `          type: "string",` && |\n| &&
             `        },` && |\n| &&
             `        device_systemtype: {` && |\n| &&
             `          type: "string",` && |\n| &&
             `        },` && |\n| &&
             `        device_browser: {` && |\n| &&
             `          type: "string",` && |\n| &&
             `        },` && |\n| &&
             `      },` && |\n| &&
             `      events: {` && |\n| &&
             `        finished: {` && |\n| &&
             `          allowPreventDefault: true,` && |\n| &&
             `          parameters: {},` && |\n| &&
             `        },` && |\n| &&
             `      },` && |\n| &&
             `    },` && |\n| &&
             `` && |\n| &&
             `    renderer: {` && |\n| &&
             `      apiVersion: 2,` && |\n| &&
             `      render(_, oControl) {` && |\n| &&
             `        try {` && |\n| &&
             `          // The device model is created by Component.init(); it exposes` && |\n| &&
             `          // system / resize / os / browser info.` && |\n| &&
             `          const deviceModel = z2ui5.oView && z2ui5.oView.getModel("device");` && |\n| &&
             `          const deviceData = deviceModel && deviceModel.getData();` && |\n| &&
             `          if (!deviceData) return;` && |\n| &&
             `` && |\n| &&
             `          const { system, resize, os, browser } = deviceData;` && |\n| &&
             `          const versionInfo = z2ui5.oConfig && z2ui5.oConfig.UI5VersionInfo;` && |\n| &&
             `          const ui5Version = versionInfo ? versionInfo.version : "";` && |\n| &&
             `` && |\n| &&
             `          const props = [` && |\n| &&
             `            ["ui5_version", ui5Version],` && |\n| &&
             `            ["device_phone", system.phone],` && |\n| &&
             `            ["device_desktop", system.desktop],` && |\n| &&
             `            ["device_tablet", system.tablet],` && |\n| &&
             `            ["device_combi", system.combi],` && |\n| &&
             `            ["device_height", resize.height],` && |\n| &&
             `            ["device_width", resize.width],` && |\n| &&
             `            ["device_os", os.name],` && |\n| &&
             `            ["device_browser", browser.name],` && |\n| &&
             `          ];` && |\n| &&
             `          for (const [prop, val] of props) {` && |\n| &&
             `            const safe = val == null ? "" : String(val);` && |\n| &&
             `            oControl.setProperty(prop, safe, true);` && |\n| &&
             `          }` && |\n| &&
             `          oControl.fireFinished();` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          _logError("Info.renderer: failed", e);` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `    },` && |\n| &&
             `  });` && |\n| &&
             `});` && |\n| &&
             `` && |\n| &&
             `sap.ui.define("z2ui5/Geolocation", ["sap/ui/core/Control"], (Control) => {` && |\n| &&
             `  "use strict";` && |\n| &&
             `` && |\n| &&
             `  const _GEO_PROPS = [` && |\n| &&
             `    "longitude",` && |\n| &&
             `    "latitude",` && |\n| &&
             `    "altitude",` && |\n| &&
             `    "accuracy",` && |\n| &&
             `    "altitudeAccuracy",` && |\n| &&
             `    "speed",` && |\n| &&
             `    "heading",` && |\n| &&
             `  ];` && |\n| &&
             `` && |\n| &&
             `  return Control.extend("z2ui5.Geolocation", {` && |\n| &&
             `    metadata: {` && |\n| &&
             `      properties: {` && |\n| &&
             `        longitude: {` && |\n| &&
             `          type: "string",` && |\n| &&
             `          defaultValue: "",` && |\n| &&
             `        },` && |\n| &&
             `        latitude: {` && |\n| &&
             `          type: "string",` && |\n| &&
             `          defaultValue: "",` && |\n| &&
             `        },` && |\n| &&
             `        altitude: {` && |\n| &&
             `          type: "string",` && |\n| &&
             `          defaultValue: "",` && |\n| &&
             `        },` && |\n| &&
             `        accuracy: {` && |\n| &&
             `          type: "string",` && |\n| &&
             `          defaultValue: "",` && |\n| &&
             `        },` && |\n| &&
             `        altitudeAccuracy: {` && |\n| &&
             `          type: "string",` && |\n| &&
             `          defaultValue: "",` && |\n| &&
             `        },` && |\n| &&
             `        speed: {` && |\n| &&
             `          type: "string",` && |\n| &&
             `          defaultValue: "",` && |\n| &&
             `        },` && |\n| &&
             `        heading: {` && |\n| &&
             `          type: "string",` && |\n| &&
             `          defaultValue: "",` && |\n| &&
             `        },` && |\n| &&
             `        enableHighAccuracy: {` && |\n| &&
             `          type: "boolean",` && |\n| &&
             `          defaultValue: false,` && |\n| &&
             `        },` && |\n| &&
             `        timeout: {` && |\n| &&
             `          type: "string",` && |\n| &&
             `          defaultValue: "5000",` && |\n| &&
             `        },` && |\n| &&
             `      },` && |\n| &&
             `      events: {` && |\n| &&
             `        finished: {` && |\n| &&
             `          allowPreventDefault: true,` && |\n| &&
             `          parameters: {},` && |\n| &&
             `        },` && |\n| &&
             `      },` && |\n| &&
             `    },` && |\n| &&
             `` && |\n| &&
             `    callbackPosition({ coords }) {` && |\n| &&
             `      // The control could be torn down while the geolocation API was busy.` && |\n| &&
             `      if (this.isDestroyed && this.isDestroyed()) return;` && |\n| &&
             `      for (const prop of _GEO_PROPS) {` && |\n| &&
             `        const raw = coords[prop];` && |\n| &&
             `        const val = raw == null ? "" : raw.toString();` && |\n| &&
             `        this.setProperty(prop, val, true);` && |\n| &&
             `      }` && |\n| &&
             `      this.fireFinished();` && |\n| &&
             `    },` && |\n| &&
             `` && |\n| &&
             `    init() {` && |\n| &&
             `      this._pendingGeolocate = true;` && |\n| &&
             `    },` && |\n| &&
             `` && |\n| &&
             `    exit() {` && |\n| &&
             `      this._pendingGeolocate = false;` && |\n| &&
             `    },` && |\n| &&
             `` && |\n| &&
             `    onAfterRendering() {` && |\n| &&
             `      if (!this._pendingGeolocate) return;` && |\n| &&
             `      this._pendingGeolocate = false;` && |\n| &&
             `      try {` && |\n| &&
             `        if (!navigator.geolocation) return;` && |\n| &&
             `        navigator.geolocation.getCurrentPosition(` && |\n| &&
             `          this.callbackPosition.bind(this),` && |\n| &&
             `          (error) =>` && |\n| &&
             `            _logError(``Geolocation error (${error.code}): ${error.message}``),` && |\n| &&
             `          {` && |\n| &&
             `            enableHighAccuracy: this.getProperty("enableHighAccuracy"),` && |\n| &&
             `            timeout: +this.getProperty("timeout"),` && |\n| &&
             `          },` && |\n| &&
             `        );` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        _logError("Geolocation.onAfterRendering: getCurrentPosition failed", e);` && |\n| &&
             `      }` && |\n| &&
             `    },` && |\n| &&
             `` && |\n| &&
             `    renderer: {` && |\n| &&
             `      apiVersion: 2,` && |\n| &&
             `      render(oRm, oControl) {` && |\n| &&
             `        oRm.openStart("span", oControl);` && |\n| &&
             `        oRm.style("display", "none");` && |\n| &&
             `        oRm.openEnd();` && |\n| &&
             `        oRm.close("span");` && |\n| &&
             `      },` && |\n| &&
             `    },` && |\n| &&
             `  });` && |\n| &&
             `});` && |\n| &&
             `` && |\n| &&
             `sap.ui.define(` && |\n| &&
             `  "z2ui5/Storage",` && |\n| &&
             `  ["sap/ui/core/Control", "sap/ui/util/Storage"],` && |\n| &&
             `  (Control, Storage) => {` && |\n| &&
             `    "use strict";` && |\n| &&
             `` && |\n| &&
             `    return Control.extend("z2ui5.Storage", {` && |\n| &&
             `      metadata: {` && |\n| &&
             `        properties: {` && |\n| &&
             `          type: {` && |\n| &&
             `            type: "string",` && |\n| &&
             `            defaultValue: "session",` && |\n| &&
             `          },` && |\n| &&
             `          prefix: {` && |\n| &&
             `            type: "string",` && |\n| &&
             `            defaultValue: "",` && |\n| &&
             `          },` && |\n| &&
             `          key: {` && |\n| &&
             `            type: "string",` && |\n| &&
             `            defaultValue: "",` && |\n| &&
             `          },` && |\n| &&
             `          value: {` && |\n| &&
             `            type: "any",` && |\n| &&
             `            defaultValue: "",` && |\n| &&
             `          },` && |\n| &&
             `        },` && |\n| &&
             `        events: {` && |\n| &&
             `          finished: {` && |\n| &&
             `            parameters: {` && |\n| &&
             `              type: {` && |\n| &&
             `                type: "string",` && |\n| &&
             `              },` && |\n| &&
             `              prefix: {` && |\n| &&
             `                type: "string",` && |\n| &&
             `              },` && |\n| &&
             `              key: {` && |\n| &&
             `                type: "string",` && |\n| &&
             `              },` && |\n| &&
             `              value: {` && |\n| &&
             `                type: "any",` && |\n| &&
             `              },` && |\n| &&
             `            },` && |\n| &&
             `          },` && |\n| &&
             `        },` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      renderer: {` && |\n| &&
             `        apiVersion: 2,` && |\n| &&
             `        render(_, oControl) {` && |\n| &&
             `          const type = oControl.getProperty("type");` && |\n| &&
             `          const prefix = oControl.getProperty("prefix");` && |\n| &&
             `          const key = oControl.getProperty("key");` && |\n| &&
             `          const value = oControl.getProperty("value");` && |\n| &&
             `` && |\n| &&
             `          let stored;` && |\n| &&
             `          try {` && |\n| &&
             `            const storageType = Storage.Type[type] || Storage.Type.session;` && |\n| &&
             `            const storage = new Storage(storageType, prefix);` && |\n| &&
             `            const read = storage.get(key);` && |\n| &&
             `            stored = read == null ? "" : read;` && |\n| &&
             `          } catch (e) {` && |\n| &&
             `            _logError(``Storage: read failed for key '${key}'``, e);` && |\n| &&
             `            return;` && |\n| &&
             `          }` && |\n| &&
             `` && |\n| &&
             `          // Only fire "finished" when the stored value differs from the` && |\n| &&
             `          // current property to avoid feedback loops.` && |\n| &&
             `          if (stored !== value) {` && |\n| &&
             `            oControl.setProperty("value", stored, true);` && |\n| &&
             `            oControl.fireFinished({` && |\n| &&
             `              type: type,` && |\n| &&
             `              prefix: prefix,` && |\n| &&
             `              key: key,` && |\n| &&
             `              value: stored,` && |\n| &&
             `            });` && |\n| &&
             `          }` && |\n| &&
             `        },` && |\n| &&
             `      },` && |\n| &&
             `    });` && |\n| &&
             `  },` && |\n| &&
             `);` && |\n| &&
             `` && |\n| &&
             `sap.ui.define(` && |\n| &&
             `  "z2ui5/FileUploader",` && |\n| &&
             `  [` && |\n| &&
             `    "sap/ui/core/Control",` && |\n| &&
             `    "sap/m/Button",` && |\n| &&
             `    "sap/ui/unified/FileUploader",` && |\n| &&
             `    "sap/m/HBox",` && |\n| &&
             `  ],` && |\n| &&
             `  (Control, Button, FileUploader, HBox) => {` && |\n| &&
             `    "use strict";` && |\n| &&
             `` && |\n| &&
             `    return Control.extend("z2ui5.FileUploader", {` && |\n| &&
             `      metadata: {` && |\n| &&
             `        properties: {` && |\n| &&
             `          value: {` && |\n| &&
             `            type: "string",` && |\n| &&
             `            defaultValue: "",` && |\n| &&
             `          },` && |\n| &&
             `          path: {` && |\n| &&
             `            type: "string",` && |\n| &&
             `            defaultValue: "",` && |\n| &&
             `          },` && |\n| &&
             `          tooltip: {` && |\n| &&
             `            type: "string",` && |\n| &&
             `            defaultValue: "",` && |\n| &&
             `          },` && |\n| &&
             `          fileType: {` && |\n| &&
             `            type: "string",` && |\n| &&
             `            defaultValue: "",` && |\n| &&
             `          },` && |\n| &&
             `          placeholder: {` && |\n| &&
             `            type: "string",` && |\n| &&
             `            defaultValue: "",` && |\n| &&
             `          },` && |\n| &&
             `          buttonText: {` && |\n| &&
             `            type: "string",` && |\n| &&
             `            defaultValue: "",` && |\n| &&
             `          },` && |\n| &&
             `          style: {` && |\n| &&
             |\n|.
    result = result &&
             `            type: "string",` && |\n| &&
             `            defaultValue: "",` && |\n| &&
             `          },` && |\n| &&
             `          uploadButtonText: {` && |\n| &&
             `            type: "string",` && |\n| &&
             `            defaultValue: "Upload",` && |\n| &&
             `          },` && |\n| &&
             `          enabled: {` && |\n| &&
             `            type: "boolean",` && |\n| &&
             `            defaultValue: true,` && |\n| &&
             `          },` && |\n| &&
             `          icon: {` && |\n| &&
             `            type: "string",` && |\n| &&
             `            defaultValue: "sap-icon://browse-folder",` && |\n| &&
             `          },` && |\n| &&
             `          iconOnly: {` && |\n| &&
             `            type: "boolean",` && |\n| &&
             `            defaultValue: false,` && |\n| &&
             `          },` && |\n| &&
             `          buttonOnly: {` && |\n| &&
             `            type: "boolean",` && |\n| &&
             `            defaultValue: false,` && |\n| &&
             `          },` && |\n| &&
             `          multiple: {` && |\n| &&
             `            type: "boolean",` && |\n| &&
             `            defaultValue: false,` && |\n| &&
             `          },` && |\n| &&
             `          visible: {` && |\n| &&
             `            type: "boolean",` && |\n| &&
             `            defaultValue: true,` && |\n| &&
             `          },` && |\n| &&
             `          checkDirectUpload: {` && |\n| &&
             `            type: "boolean",` && |\n| &&
             `            defaultValue: false,` && |\n| &&
             `          },` && |\n| &&
             `        },` && |\n| &&
             `` && |\n| &&
             `        events: {` && |\n| &&
             `          upload: {` && |\n| &&
             `            allowPreventDefault: true,` && |\n| &&
             `            parameters: {},` && |\n| &&
             `          },` && |\n| &&
             `        },` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      _readFile(file) {` && |\n| &&
             `        const reader = new FileReader();` && |\n| &&
             `        reader.onload = () => {` && |\n| &&
             `          if (this.isDestroyed && this.isDestroyed()) return;` && |\n| &&
             `          this.setProperty("value", reader.result);` && |\n| &&
             `          this.fireUpload();` && |\n| &&
             `        };` && |\n| &&
             `        reader.onerror = () =>` && |\n| &&
             `          _logError("FileUploader: FileReader failed", reader.error);` && |\n| &&
             `        reader.readAsDataURL(file);` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      exit() {` && |\n| &&
             `        if (this._oHBox) this._oHBox.destroy();` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      renderer: {` && |\n| &&
             `        apiVersion: 2,` && |\n| &&
             `        render(oRm, oControl) {` && |\n| &&
             `          const directUpload = oControl.getProperty("checkDirectUpload");` && |\n| &&
             `          const path = oControl.getProperty("path");` && |\n| &&
             `` && |\n| &&
             `          // Clean up controls from a previous render pass.` && |\n| &&
             `          if (oControl._oHBox) oControl._oHBox.destroy();` && |\n| &&
             `          oControl._oHBox = null;` && |\n| &&
             `          oControl.oUploadButton = null;` && |\n| &&
             `          oControl.oFileUploader = null;` && |\n| &&
             `` && |\n| &&
             `          // Helper: read the first file from a FileUploader instance.` && |\n| &&
             `          const getFirstFile = (uploader) => {` && |\n| &&
             `            const fileUpload = uploader && uploader.oFileUpload;` && |\n| &&
             `            const files = fileUpload && fileUpload.files;` && |\n| &&
             `            return files && files[0];` && |\n| &&
             `          };` && |\n| &&
             `` && |\n| &&
             `          if (!directUpload) {` && |\n| &&
             `            oControl.oUploadButton = new Button({` && |\n| &&
             `              text: oControl.getProperty("uploadButtonText"),` && |\n| &&
             `              enabled: path !== "",` && |\n| &&
             `              press: () => {` && |\n| &&
             `                oControl.setProperty(` && |\n| &&
             `                  "path",` && |\n| &&
             `                  oControl.oFileUploader.getProperty("value"),` && |\n| &&
             `                );` && |\n| &&
             `                const file = getFirstFile(oControl.oFileUploader);` && |\n| &&
             `                if (file) oControl._readFile(file);` && |\n| &&
             `              },` && |\n| &&
             `            });` && |\n| &&
             `          }` && |\n| &&
             `` && |\n| &&
             `          oControl.oFileUploader = new FileUploader({` && |\n| &&
             `            icon: oControl.getProperty("icon"),` && |\n| &&
             `            iconOnly: oControl.getProperty("iconOnly"),` && |\n| &&
             `            buttonOnly: oControl.getProperty("buttonOnly"),` && |\n| &&
             `            buttonText: oControl.getProperty("buttonText"),` && |\n| &&
             `            style: oControl.getProperty("style"),` && |\n| &&
             `            fileType: oControl.getProperty("fileType"),` && |\n| &&
             `            visible: oControl.getProperty("visible"),` && |\n| &&
             `            uploadOnChange: directUpload,` && |\n| &&
             `            multiple: oControl.getProperty("multiple"),` && |\n| &&
             `            enabled: oControl.getProperty("enabled"),` && |\n| &&
             `            value: path,` && |\n| &&
             `            placeholder: oControl.getProperty("placeholder"),` && |\n| &&
             `            change: (oEvent) => {` && |\n| &&
             `              if (directUpload) return;` && |\n| &&
             `              const value = oEvent.getSource().getProperty("value");` && |\n| &&
             `              oControl.setProperty("path", value);` && |\n| &&
             `              if (oControl.oUploadButton) {` && |\n| &&
             `                oControl.oUploadButton.setEnabled(!!value);` && |\n| &&
             `                oControl.oUploadButton.invalidate();` && |\n| &&
             `              }` && |\n| &&
             `            },` && |\n| &&
             `            uploadComplete: (oEvent) => {` && |\n| &&
             `              if (!directUpload) return;` && |\n| &&
             `              const source = oEvent.getSource();` && |\n| &&
             `              oControl.setProperty("path", source.getProperty("value"));` && |\n| &&
             `              const file = getFirstFile(source);` && |\n| &&
             `              if (file) oControl._readFile(file);` && |\n| &&
             `            },` && |\n| &&
             `          });` && |\n| &&
             `` && |\n| &&
             `          oControl._oHBox = new HBox().addItem(oControl.oFileUploader);` && |\n| &&
             `          if (oControl.oUploadButton) {` && |\n| &&
             `            oControl._oHBox.addItem(oControl.oUploadButton);` && |\n| &&
             `          }` && |\n| &&
             `          oRm.renderControl(oControl._oHBox);` && |\n| &&
             `        },` && |\n| &&
             `      },` && |\n| &&
             `    });` && |\n| &&
             `  },` && |\n| &&
             `);` && |\n| &&
             `` && |\n| &&
             `sap.ui.define(` && |\n| &&
             `  "z2ui5/MultiInputExt",` && |\n| &&
             `  ["sap/ui/core/Control", "sap/m/Token"],` && |\n| &&
             `  (Control, Token) => {` && |\n| &&
             `    "use strict";` && |\n| &&
             `` && |\n| &&
             `    return Control.extend("z2ui5.MultiInputExt", {` && |\n| &&
             `      metadata: {` && |\n| &&
             `        properties: {` && |\n| &&
             `          MultiInputId: {` && |\n| &&
             `            type: "string",` && |\n| &&
             `          },` && |\n| &&
             `          MultiInputName: {` && |\n| &&
             `            type: "string",` && |\n| &&
             `          },` && |\n| &&
             `          addedTokens: {` && |\n| &&
             `            type: "object",` && |\n| &&
             `          },` && |\n| &&
             `          checkInit: {` && |\n| &&
             `            type: "boolean",` && |\n| &&
             `            defaultValue: false,` && |\n| &&
             `          },` && |\n| &&
             `          removedTokens: {` && |\n| &&
             `            type: "object",` && |\n| &&
             `          },` && |\n| &&
             `        },` && |\n| &&
             `        events: {` && |\n| &&
             `          change: {` && |\n| &&
             `            allowPreventDefault: true,` && |\n| &&
             `            parameters: {},` && |\n| &&
             `          },` && |\n| &&
             `        },` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      init() {` && |\n| &&
             `        this._setControlBound = this.setControl.bind(this);` && |\n| &&
             `        _registerCallback("onAfterRendering", this._setControlBound);` && |\n| &&
             `      },` && |\n| &&
             `      exit() {` && |\n| &&
             `        _unregisterCallback("onAfterRendering", this._setControlBound);` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      onTokenUpdate(oEvent) {` && |\n| &&
             `        const mParameters = oEvent.mParameters;` && |\n| &&
             `        const isRemoved = mParameters.type === "removed";` && |\n| &&
             `        const rawList =` && |\n| &&
             `          mParameters[isRemoved ? "removedTokens" : "addedTokens"] || [];` && |\n| &&
             `        const tokens = rawList.map((item) => ({` && |\n| &&
             `          KEY: item.getKey(),` && |\n| &&
             `          TEXT: item.getText(),` && |\n| &&
             `        }));` && |\n| &&
             `        this.setProperty("addedTokens", isRemoved ? [] : tokens);` && |\n| &&
             `        this.setProperty("removedTokens", isRemoved ? tokens : []);` && |\n| &&
             `        this.fireChange();` && |\n| &&
             `      },` && |\n| &&
             `      renderer: { apiVersion: 2, render() {} },` && |\n| &&
             `      setControl() {` && |\n| &&
             `        const table =` && |\n| &&
             `          z2ui5.oView && z2ui5.oView.byId(this.getProperty("MultiInputId"));` && |\n| &&
             `        if (!table || this.getProperty("checkInit")) return;` && |\n| &&
             `        this.setProperty("checkInit", true);` && |\n| &&
             `        try {` && |\n| &&
             `          table.attachTokenUpdate(this.onTokenUpdate.bind(this));` && |\n| &&
             `          // Custom validator: turn any free-text entry into a Token where` && |\n| &&
             `          // both key and visible text equal the input string.` && |\n| &&
             `          table.addValidator(({ text }) => new Token({ key: text, text }));` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          _logError("MultiInputExt.setControl: setup failed", e);` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `    });` && |\n| &&
             `  },` && |\n| &&
             `);` && |\n| &&
             `` && |\n| &&
             `sap.ui.define(` && |\n| &&
             `  "z2ui5/SmartMultiInputExt",` && |\n| &&
             `  ["sap/ui/core/Control"],` && |\n| &&
             `  (Control) => {` && |\n| &&
             `    "use strict";` && |\n| &&
             `` && |\n| &&
             `    return Control.extend("z2ui5.SmartMultiInputExt", {` && |\n| &&
             `      metadata: {` && |\n| &&
             `        properties: {` && |\n| &&
             `          multiInputId: {` && |\n| &&
             `            type: "string",` && |\n| &&
             `          },` && |\n| &&
             `          addedTokens: {` && |\n| &&
             `            type: "object",` && |\n| &&
             `          },` && |\n| &&
             `          removedTokens: {` && |\n| &&
             `            type: "object",` && |\n| &&
             `          },` && |\n| &&
             `          rangeData: {` && |\n| &&
             `            type: "object",` && |\n| &&
             `            defaultValue: [],` && |\n| &&
             `          },` && |\n| &&
             `          checkInit: {` && |\n| &&
             `            type: "boolean",` && |\n| &&
             `            defaultValue: false,` && |\n| &&
             `          },` && |\n| &&
             `        },` && |\n| &&
             `        events: {` && |\n| &&
             `          change: {` && |\n| &&
             `            allowPreventDefault: true,` && |\n| &&
             `            parameters: {},` && |\n| &&
             `          },` && |\n| &&
             `        },` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      init() {` && |\n| &&
             `        this._setControlBound = this.setControl.bind(this);` && |\n| &&
             `        this._oInput = null;` && |\n| &&
             `        this._oPendingInnerControlsCreated = null;` && |\n| &&
             `        this._bInnerControlsCreated = false;` && |\n| &&
             `        _registerCallback("onAfterRendering", this._setControlBound);` && |\n| &&
             `      },` && |\n| &&
             `      exit() {` && |\n| &&
             `        _unregisterCallback("onAfterRendering", this._setControlBound);` && |\n| &&
             `        // Resolve any still-pending promise so awaiters don't hang.` && |\n| &&
             `        if (this._oPendingInnerControlsCreated) {` && |\n| &&
             `          this._oPendingInnerControlsCreated(null);` && |\n| &&
             `        }` && |\n| &&
             `        this._oPendingInnerControlsCreated = null;` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      onTokenUpdate(oEvent) {` && |\n| &&
             `        const mParameters = oEvent.mParameters;` && |\n| &&
             `        const isRemoved = mParameters.type === "removed";` && |\n| &&
             `        const rawList =` && |\n| &&
             `          mParameters[isRemoved ? "removedTokens" : "addedTokens"] || [];` && |\n| &&
             `        const mappedTokens = rawList.map((item) => ({` && |\n| &&
             `          KEY: item.getKey(),` && |\n| &&
             `          TEXT: item.getText(),` && |\n| &&
             `        }));` && |\n| &&
             `        this.setProperty("addedTokens", isRemoved ? [] : mappedTokens);` && |\n| &&
             `        this.setProperty("removedTokens", isRemoved ? mappedTokens : []);` && |\n| &&
             `` && |\n| &&
             `        // Mirror each range entry with the visible token text + long key` && |\n| &&
             `        // so the backend has enough info to re-render the input later.` && |\n| &&
             `        const source = oEvent.getSource();` && |\n| &&
             `        const tokens = source.getTokens();` && |\n| &&
             `        const rangeData = source.getRangeData() || [];` && |\n| &&
             `        const enrichedRanges = rangeData.map((oRangeData, index) => {` && |\n| &&
             `          const token = tokens[index];` && |\n| &&
             `          oRangeData.tokenText = token ? token.getText() : "";` && |\n| &&
             `          oRangeData.tokenLongKey = token ? token.data("longKey") : undefined;` && |\n| &&
             `          return oRangeData;` && |\n| &&
             `        });` && |\n| &&
             `        this.setProperty("rangeData", enrichedRanges);` && |\n| &&
             `        this.fireChange();` && |\n| &&
             `      },` && |\n| &&
             `      async setRangeData(aRangeData) {` && |\n| &&
             `        this.setProperty("rangeData", aRangeData);` && |\n| &&
             `        try {` && |\n| &&
             `          const input = await this.inputInitialized();` && |\n| &&
             `          if ((this.isDestroyed && this.isDestroyed()) || !input) return;` && |\n| &&
             `` && |\n| &&
             `          // Convert the ABAP-style uppercase keys to the camelCase property` && |\n| &&
             `          // names the smart multi input expects. "keyField" needs its capital` && |\n| &&
             `          // F preserved.` && |\n| &&
             `          const normalizedRangeData = aRangeData.map((oRangeData) => {` && |\n| &&
             `            const out = {};` && |\n| &&
             `            for (const [key, value] of Object.entries(oRangeData)) {` && |\n| &&
             `              const lower = key.toLowerCase();` && |\n| &&
             `              const finalKey = lower === "keyfield" ? "keyField" : lower;` && |\n| &&
             `              out[finalKey] = value;` && |\n| &&
             `            }` && |\n| &&
             `            return out;` && |\n| &&
             `          });` && |\n| &&
             `          input.setRangeData(normalizedRangeData);` && |\n| &&
             `` && |\n| &&
             `          // We need to set token text explicitly, as setRangeData does no` && |\n| &&
             `          // recalculation.` && |\n| &&
             `          const inputTokens = input.getTokens() || [];` && |\n| &&
             `          for (const [index, token] of inputTokens.entries()) {` && |\n| &&
             `            const rangeItem = aRangeData[index];` && |\n| &&
             `            if (!rangeItem) continue;` && |\n| &&
             `            const { TOKENLONGKEY, TOKENTEXT } = rangeItem;` && |\n| &&
             `            token.data("longKey", TOKENLONGKEY);` && |\n| &&
             `            token.data("range", null);` && |\n| &&
             `            if (TOKENTEXT) token.setText(TOKENTEXT);` && |\n| &&
             `          }` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          _logError("SmartMultiInputExt.setRangeData failed", e);` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `      renderer: { apiVersion: 2, render() {} },` && |\n| &&
             `      setControl() {` && |\n| &&
             `        const input =` && |\n| &&
             `          z2ui5.oView && z2ui5.oView.byId(this.getProperty("multiInputId"));` && |\n| &&
             `        if (!input || this.getProperty("checkInit")) return;` && |\n| &&
             `        this.setProperty("checkInit", true);` && |\n| &&
             `        try {` && |\n| &&
             `          input.attachTokenUpdate(this.onTokenUpdate.bind(this));` && |\n| &&
             `          input.attachInnerControlsCreated(` && |\n| &&
             `            this.onInnerControlsCreated.bind(this),` && |\n| &&
             `          );` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          _logError("SmartMultiInputExt.setControl: setup failed", e);` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `      // Returns a Promise that resolves once the smart multi input's inner` && |\n| &&
             `      // controls exist - they are created lazily on first interaction.` && |\n| &&
             `      inputInitialized() {` && |\n| &&
             `        return new Promise((resolve) => {` && |\n| &&
             `          if (this._bInnerControlsCreated) {` && |\n| &&
             `            resolve(this._oInput);` && |\n| &&
             `          } else {` && |\n| &&
             `            this._oPendingInnerControlsCreated = resolve;` && |\n| &&
             `          }` && |\n| &&
             `        });` && |\n| &&
             `      },` && |\n| &&
             `      onInnerControlsCreated(oEvent) {` && |\n| &&
             `        this._oInput = oEvent.getSource();` && |\n| &&
             `        if (this._oPendingInnerControlsCreated) {` && |\n| &&
             `          this._oPendingInnerControlsCreated(this._oInput);` && |\n| &&
             `        }` && |\n| &&
             `        this._oPendingInnerControlsCreated = null;` && |\n| &&
             `        this._bInnerControlsCreated = true;` && |\n| &&
             `      },` && |\n| &&
             `    });` && |\n| &&
             `  },` && |\n| &&
             `);` && |\n| &&
             `` && |\n| &&
             `sap.ui.define(` && |\n| &&
             `  "z2ui5/CameraPicture",` && |\n| &&
             `  ["sap/ui/core/Control", "sap/m/Dialog", "sap/m/Button", "sap/ui/core/HTML"],` && |\n| &&
             `  (Control, Dialog, Button, HTML) => {` && |\n| &&
             `    "use strict";` && |\n| &&
             `    const _CTX_2D_OPTS = { willReadFrequently: true };` && |\n| &&
             `    const _THUMB_W = 300;` && |\n| &&
             `    return Control.extend("z2ui5.CameraPicture", {` && |\n| &&
             `      metadata: {` && |\n| &&
             `        properties: {` && |\n| &&
             `          id: { type: "string" },` && |\n| &&
             `          value: { type: "string" },` && |\n| &&
             `          thumbnail: { type: "string" },` && |\n| &&
             `          press: { type: "string" },` && |\n| &&
             `          width: { type: "string", defaultValue: "200" },` && |\n| &&
             `          height: { type: "string", defaultValue: "200" },` && |\n| &&
             `          autoplay: { type: "boolean", defaultValue: true },` && |\n| &&
             `          facingMode: { type: "string" },` && |\n| &&
             `          deviceId: { type: "string" },` && |\n| &&
             `        },` && |\n| &&
             `        events: {` && |\n| &&
             `          OnPhoto: {` && |\n| &&
             `            allowPreventDefault: true,` && |\n| &&
             `            parameters: {` && |\n| &&
             `              photo: {` && |\n| &&
             `                type: "string",` && |\n| &&
             `              },` && |\n| &&
             `            },` && |\n| &&
             `          },` && |\n| &&
             `        },` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      capture() {` && |\n| &&
             `        const video = document.getElementById(``${this.getId()}-video``);` && |\n| &&
             `        const canvas = document.getElementById(``${this.getId()}-canvas``);` && |\n| &&
             `        if (!video || !canvas) return;` && |\n| &&
             `` && |\n| &&
             `        const videoWidth = video.videoWidth;` && |\n| &&
             `        const videoHeight = video.videoHeight;` && |\n| &&
             |\n|.
    result = result &&
             `        canvas.width = videoWidth;` && |\n| &&
             `        canvas.height = videoHeight;` && |\n| &&
             `` && |\n| &&
             `        const ctx = canvas.getContext("2d", _CTX_2D_OPTS);` && |\n| &&
             `        if (!ctx) return;` && |\n| &&
             `        ctx.drawImage(video, 0, 0, videoWidth, videoHeight);` && |\n| &&
             `` && |\n| &&
             `        // Full-resolution JPEG (quality 0.85) for the value, plus a small` && |\n| &&
             `        // thumbnail (max width _THUMB_W) at lower quality for previews.` && |\n| &&
             `        let resultb64;` && |\n| &&
             `        try {` && |\n| &&
             `          resultb64 = canvas.toDataURL("image/jpeg", 0.85);` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          _logError("CameraPicture: canvas toDataURL failed", e);` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `` && |\n| &&
             `        const thumbH = videoWidth` && |\n| &&
             `          ? Math.round((videoHeight * _THUMB_W) / videoWidth)` && |\n| &&
             `          : _THUMB_W;` && |\n| &&
             `        const thumbCanvas = document.createElement("canvas");` && |\n| &&
             `        thumbCanvas.width = _THUMB_W;` && |\n| &&
             `        thumbCanvas.height = thumbH;` && |\n| &&
             `        const thumbCtx = thumbCanvas.getContext("2d", _CTX_2D_OPTS);` && |\n| &&
             `        if (thumbCtx) thumbCtx.drawImage(canvas, 0, 0, _THUMB_W, thumbH);` && |\n| &&
             `` && |\n| &&
             `        let thumbB64 = "";` && |\n| &&
             `        try {` && |\n| &&
             `          thumbB64 = thumbCanvas.toDataURL("image/jpeg", 0.7);` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          _logError("CameraPicture: thumb toDataURL failed", e);` && |\n| &&
             `        }` && |\n| &&
             `` && |\n| &&
             `        if (this.isDestroyed && this.isDestroyed()) return;` && |\n| &&
             `        this.setProperty("value", resultb64);` && |\n| &&
             `        this.setProperty("thumbnail", thumbB64);` && |\n| &&
             `        this.fireOnPhoto({ photo: resultb64 });` && |\n| &&
             `        this._stopCamera();` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      _stopCamera() {` && |\n| &&
             `        // Stop every track of the active stream so the OS frees the camera.` && |\n| &&
             `        if (this._stream) {` && |\n| &&
             `          for (const track of this._stream.getTracks()) track.stop();` && |\n| &&
             `        }` && |\n| &&
             `        this._stream = null;` && |\n| &&
             `        const video = document.getElementById(``${this.getId()}-video``);` && |\n| &&
             `        if (video) video.srcObject = null;` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      onPicture() {` && |\n| &&
             `        if (this._oScanDialog && this._oScanDialog.isOpen()) return;` && |\n| &&
             `        if (!this._oScanDialog) {` && |\n| &&
             `          this._oScanDialog = new Dialog({` && |\n| &&
             `            title: "Device Photo Function",` && |\n| &&
             `            contentWidth: "640px",` && |\n| &&
             `            contentHeight: "480px",` && |\n| &&
             `            horizontalScrolling: false,` && |\n| &&
             `            verticalScrolling: false,` && |\n| &&
             `            stretch: true,` && |\n| &&
             `            afterClose: () => this._stopCamera(),` && |\n| &&
             `            content: [` && |\n| &&
             `              new HTML({` && |\n| &&
             `                id: ``${this.getId()}PictureContainer``,` && |\n| &&
             `                content: ``<video style="width:100%;height:100%;object-fit:contain;" autoplay="true" id="${this.getId()}-video">``,` && |\n| &&
             `              }),` && |\n| &&
             `              new Button({` && |\n| &&
             `                text: "Capture",` && |\n| &&
             `                press: () => {` && |\n| &&
             `                  this.capture();` && |\n| &&
             `                  this._oScanDialog.close();` && |\n| &&
             `                },` && |\n| &&
             `              }),` && |\n| &&
             `              new HTML({` && |\n| &&
             `                content: ``<canvas hidden id="${this.getId()}-canvas" style="overflow:auto"></canvas>``,` && |\n| &&
             `              }),` && |\n| &&
             `            ],` && |\n| &&
             `            endButton: new Button({` && |\n| &&
             `              text: "Cancel",` && |\n| &&
             `              press: () => {` && |\n| &&
             `                this._stopCamera();` && |\n| &&
             `                this._oScanDialog.close();` && |\n| &&
             `              },` && |\n| &&
             `            }),` && |\n| &&
             `          });` && |\n| &&
             `        }` && |\n| &&
             `` && |\n| &&
             `        this._oScanDialog.attachEventOnce("afterOpen", async () => {` && |\n| &&
             `          if (this.isDestroyed && this.isDestroyed()) return;` && |\n| &&
             `          const video = document.getElementById(``${this.getId()}-video``);` && |\n| &&
             `          if (!video) {` && |\n| &&
             `            _logError(` && |\n| &&
             `              "CameraPicture: video element not found after dialog open",` && |\n| &&
             `            );` && |\n| &&
             `            return;` && |\n| &&
             `          }` && |\n| &&
             `          const facingMode = this.getProperty("facingMode");` && |\n| &&
             `          const deviceId = this.getProperty("deviceId");` && |\n| &&
             `          const options = {` && |\n| &&
             `            video: { width: { ideal: 1920 }, height: { ideal: 1080 } },` && |\n| &&
             `          };` && |\n| &&
             `          if (deviceId) options.video.deviceId = deviceId;` && |\n| &&
             `          if (facingMode) options.video.facingMode = { exact: facingMode };` && |\n| &&
             `` && |\n| &&
             `          try {` && |\n| &&
             `            const md = navigator.mediaDevices;` && |\n| &&
             `            if (!md || !md.getUserMedia) return;` && |\n| &&
             `            const stream = await md.getUserMedia(options);` && |\n| &&
             `            if (!stream) return;` && |\n| &&
             `            // Guard: the control could have been destroyed during the` && |\n| &&
             `            // getUserMedia await. Release the camera if so.` && |\n| &&
             `            if (this.isDestroyed && this.isDestroyed()) {` && |\n| &&
             `              for (const t of stream.getTracks()) t.stop();` && |\n| &&
             `              return;` && |\n| &&
             `            }` && |\n| &&
             `            this._stream = stream;` && |\n| &&
             `            video.srcObject = stream;` && |\n| &&
             `          } catch (error) {` && |\n| &&
             `            _logError("CameraPicture: getUserMedia failed", error);` && |\n| &&
             `          }` && |\n| &&
             `        });` && |\n| &&
             `        this._oScanDialog.open();` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      exit() {` && |\n| &&
             `        this._stopCamera();` && |\n| &&
             `        if (this._oButton) this._oButton.destroy();` && |\n| &&
             `        if (this._oScanDialog) this._oScanDialog.destroy();` && |\n| &&
             `      },` && |\n| &&
             `      renderer: {` && |\n| &&
             `        apiVersion: 2,` && |\n| &&
             `        render(oRm, oControl) {` && |\n| &&
             `          if (!oControl._oButton) {` && |\n| &&
             `            oControl._oButton = new Button({` && |\n| &&
             `              icon: "sap-icon://camera",` && |\n| &&
             `              text: "Camera",` && |\n| &&
             `              press: oControl.onPicture.bind(oControl),` && |\n| &&
             `            });` && |\n| &&
             `          }` && |\n| &&
             `          oRm.renderControl(oControl._oButton);` && |\n| &&
             `        },` && |\n| &&
             `      },` && |\n| &&
             `    });` && |\n| &&
             `  },` && |\n| &&
             `);` && |\n| &&
             `` && |\n| &&
             `sap.ui.define(` && |\n| &&
             `  "z2ui5/CameraSelector",` && |\n| &&
             `  ["sap/m/ComboBox", "sap/ui/core/Item", "sap/m/ComboBoxRenderer"],` && |\n| &&
             `  (ComboBox, Item, ComboBoxRenderer) => {` && |\n| &&
             `    "use strict";` && |\n| &&
             `    return ComboBox.extend("z2ui5.CameraSelector", {` && |\n| &&
             `      async init() {` && |\n| &&
             `        ComboBox.prototype.init.call(this);` && |\n| &&
             `        try {` && |\n| &&
             `          const md = navigator.mediaDevices;` && |\n| &&
             `          if (!md || !md.enumerateDevices) return;` && |\n| &&
             `          const devices = await md.enumerateDevices();` && |\n| &&
             `          if (!devices) return;` && |\n| &&
             `          for (const device of devices) {` && |\n| &&
             `            // Only video inputs are relevant; also stop adding items when the` && |\n| &&
             `            // ComboBox has been destroyed during the await.` && |\n| &&
             `            if (device.kind !== "videoinput") continue;` && |\n| &&
             `            if (this.isDestroyed && this.isDestroyed()) return;` && |\n| &&
             `            this.addItem(` && |\n| &&
             `              new Item({ key: device.deviceId, text: device.label }),` && |\n| &&
             `            );` && |\n| &&
             `          }` && |\n| &&
             `        } catch (err) {` && |\n| &&
             `          _logError("CameraDeviceList: enumerateDevices failed", err);` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      renderer: ComboBoxRenderer,` && |\n| &&
             `    });` && |\n| &&
             `  },` && |\n| &&
             `);` && |\n| &&
             `` && |\n| &&
             `sap.ui.define("z2ui5/UITableExt", ["sap/ui/core/Control"], (Control) => {` && |\n| &&
             `  "use strict";` && |\n| &&
             `` && |\n| &&
             `  const opSymbols = { EQ: "", NE: "!", LT: "<", LE: "<=", GT: ">", GE: ">=" };` && |\n| &&
             `  const filterDisplayFns = {` && |\n| &&
             `    Contains: (v) => ``*${v ?? ""}*``,` && |\n| &&
             `    StartsWith: (v) => ``^${v ?? ""}``,` && |\n| &&
             `    EndsWith: (v) => ``${v ?? ""}$``,` && |\n| &&
             `  };` && |\n| &&
             `` && |\n| &&
             `  return Control.extend("z2ui5.UITableExt", {` && |\n| &&
             `    metadata: {` && |\n| &&
             `      properties: {` && |\n| &&
             `        tableId: {` && |\n| &&
             `          type: "string",` && |\n| &&
             `        },` && |\n| &&
             `      },` && |\n| &&
             `    },` && |\n| &&
             `` && |\n| &&
             `    init() {` && |\n| &&
             `      this._beforeBound = () => {` && |\n| &&
             `        this.readFilter();` && |\n| &&
             `        this.readSort();` && |\n| &&
             `      };` && |\n| &&
             `      this._afterBound = () => {` && |\n| &&
             `        this.setFilter();` && |\n| &&
             `        this.setSort();` && |\n| &&
             `      };` && |\n| &&
             `      _registerCallback("onBeforeRoundtrip", this._beforeBound);` && |\n| &&
             `      _registerCallback("onAfterRoundtrip", this._afterBound);` && |\n| &&
             `    },` && |\n| &&
             `` && |\n| &&
             `    exit() {` && |\n| &&
             `      _unregisterCallback("onBeforeRoundtrip", this._beforeBound);` && |\n| &&
             `      _unregisterCallback("onAfterRoundtrip", this._afterBound);` && |\n| &&
             `    },` && |\n| &&
             `` && |\n| &&
             `    _getTable() {` && |\n| &&
             `      if (!z2ui5.oView) return undefined;` && |\n| &&
             `      return z2ui5.oView.byId(this.getProperty("tableId"));` && |\n| &&
             `    },` && |\n| &&
             `` && |\n| &&
             `    readFilter() {` && |\n| &&
             `      try {` && |\n| &&
             `        const table = this._getTable();` && |\n| &&
             `        const binding = table && table.getBinding();` && |\n| &&
             `        this.aFilters = binding ? binding.aFilters : undefined;` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        _logError("UITableExt.readFilter failed", e);` && |\n| &&
             `      }` && |\n| &&
             `    },` && |\n| &&
             `` && |\n| &&
             `    _applyWhenRendered(oTable, fn) {` && |\n| &&
             `      if (oTable.getDomRef()) {` && |\n| &&
             `        fn();` && |\n| &&
             `        return;` && |\n| &&
             `      }` && |\n| &&
             `      // Not rendered yet -> run ``fn`` once the next render completes.` && |\n| &&
             `      const delegate = {` && |\n| &&
             `        onAfterRendering: () => {` && |\n| &&
             `          oTable.removeEventDelegate(delegate);` && |\n| &&
             `          if (!(this.isDestroyed && this.isDestroyed())) fn();` && |\n| &&
             `        },` && |\n| &&
             `      };` && |\n| &&
             `      oTable.addEventDelegate(delegate);` && |\n| &&
             `    },` && |\n| &&
             `` && |\n| &&
             `    _applyFilters(oTable, aFilters) {` && |\n| &&
             `      if (!aFilters) return;` && |\n| &&
             `      const binding = oTable.getBinding();` && |\n| &&
             `      if (!binding) return;` && |\n| &&
             `      binding.filter(aFilters);` && |\n| &&
             `      const columns = oTable.getColumns();` && |\n| &&
             `` && |\n| &&
             `      for (const oFilter of aFilters) {` && |\n| &&
             `        // Multi-filter? Pick the inner filter for the column lookup.` && |\n| &&
             `        let sProperty = oFilter.sPath;` && |\n| &&
             `        if (!sProperty && oFilter.aFilters && oFilter.aFilters[0]) {` && |\n| &&
             `          sProperty = oFilter.aFilters[0].sPath;` && |\n| &&
             `        }` && |\n| &&
             `        if (!sProperty) continue;` && |\n| &&
             `` && |\n| &&
             `        const operator = oFilter.sOperator;` && |\n| &&
             `        // Pick the most meaningful value to display in the column header.` && |\n| &&
             `        let vValue = oFilter.oValue1;` && |\n| &&
             `        if (vValue === undefined) vValue = oFilter.oValue2;` && |\n| &&
             `        if (vValue === undefined && oFilter.aFilters && oFilter.aFilters[0]) {` && |\n| &&
             `          vValue = oFilter.aFilters[0].oValue1;` && |\n| &&
             `        }` && |\n| &&
             `` && |\n| &&
             `        // Choose how to format the column header label for this operator.` && |\n| &&
             `        let displayFn;` && |\n| &&
             `        if (operator === "BT") {` && |\n| &&
             `          // "between" displays "from...to".` && |\n| &&
             `          displayFn = (v) => {` && |\n| &&
             `            const from = v == null ? "" : v;` && |\n| &&
             `            const to = oFilter.oValue2 == null ? "" : oFilter.oValue2;` && |\n| &&
             `            return ``${from}...${to}``;` && |\n| &&
             `          };` && |\n| &&
             `        } else if (filterDisplayFns[operator]) {` && |\n| &&
             `          displayFn = filterDisplayFns[operator];` && |\n| &&
             `        } else {` && |\n| &&
             `          // Fallback: optional operator prefix (e.g. "!" for NE) + value.` && |\n| &&
             `          const prefix = opSymbols[operator] || "";` && |\n| &&
             `          displayFn = (v) => ``${prefix}${v == null ? "" : v}``;` && |\n| &&
             `        }` && |\n| &&
             `        const display = displayFn(vValue);` && |\n| &&
             `` && |\n| &&
             `        for (const oCol of columns) {` && |\n| &&
             `          if (` && |\n| &&
             `            oCol.getFilterProperty &&` && |\n| &&
             `            oCol.getFilterProperty() === sProperty` && |\n| &&
             `          ) {` && |\n| &&
             `            oCol.setFilterValue(display);` && |\n| &&
             `            oCol.setFiltered(!!display);` && |\n| &&
             `          }` && |\n| &&
             `        }` && |\n| &&
             `      }` && |\n| &&
             `    },` && |\n| &&
             `` && |\n| &&
             `    _applyToTable(applyFn, errorMsg) {` && |\n| &&
             `      try {` && |\n| &&
             `        const oTable = this._getTable();` && |\n| &&
             `        if (!oTable) return;` && |\n| &&
             `        this._applyWhenRendered(oTable, () => applyFn(oTable));` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        _logError(errorMsg, e);` && |\n| &&
             `      }` && |\n| &&
             `    },` && |\n| &&
             `` && |\n| &&
             `    setFilter() {` && |\n| &&
             `      this._applyToTable(` && |\n| &&
             `        (oTable) => this._applyFilters(oTable, this.aFilters),` && |\n| &&
             `        "UITableExt.setFilter failed",` && |\n| &&
             `      );` && |\n| &&
             `    },` && |\n| &&
             `` && |\n| &&
             `    readSort() {` && |\n| &&
             `      try {` && |\n| &&
             `        const table = this._getTable();` && |\n| &&
             `        const binding = table && table.getBinding();` && |\n| &&
             `        this.aSorters = binding ? binding.aSorters : undefined;` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        _logError("UITableExt.readSort failed", e);` && |\n| &&
             `      }` && |\n| &&
             `    },` && |\n| &&
             `` && |\n| &&
             `    _applySorters(oTable, aSorters) {` && |\n| &&
             `      if (!aSorters) return;` && |\n| &&
             `      const binding = oTable.getBinding();` && |\n| &&
             `      if (!binding) return;` && |\n| &&
             `      binding.sort(aSorters);` && |\n| &&
             `` && |\n| &&
             `      const columns = oTable.getColumns();` && |\n| &&
             `      for (const [idx, srt] of aSorters.entries()) {` && |\n| &&
             `        for (const oCol of columns) {` && |\n| &&
             `          if (oCol.getSortProperty && oCol.getSortProperty() === srt.sPath) {` && |\n| &&
             `            oCol.setSorted(true);` && |\n| &&
             `            oCol.setSortOrder(srt.bDescending ? "Descending" : "Ascending");` && |\n| &&
             `            // setSortIndex is only available on some column variants.` && |\n| &&
             `            if (oCol.setSortIndex) oCol.setSortIndex(idx);` && |\n| &&
             `          }` && |\n| &&
             `        }` && |\n| &&
             `      }` && |\n| &&
             `    },` && |\n| &&
             `` && |\n| &&
             `    setSort() {` && |\n| &&
             `      this._applyToTable(` && |\n| &&
             `        (oTable) => this._applySorters(oTable, this.aSorters),` && |\n| &&
             `        "UITableExt.setSort failed",` && |\n| &&
             `      );` && |\n| &&
             `    },` && |\n| &&
             `    renderer: { apiVersion: 2, render() {} },` && |\n| &&
             `  });` && |\n| &&
             `});` && |\n| &&
             `` && |\n| &&
             `sap.ui.define("z2ui5/Util", [], () => {` && |\n| &&
             `  "use strict";` && |\n| &&
             `` && |\n| &&
             `  // Splits an 8-character ABAP date string "YYYYMMDD" into the [year, month,` && |\n| &&
             `  // day] tuple JavaScript's Date constructor expects. Note: Date months are` && |\n| &&
             `  // 0-based, so we subtract 1 from the month component.` && |\n| &&
             `  function parseDmy(d) {` && |\n| &&
             `    return [+d.slice(0, 4), +d.slice(4, 6) - 1, +d.slice(6, 8)];` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  return {` && |\n| &&
             `    DateCreateObject(s) {` && |\n| &&
             `      return new Date(s);` && |\n| &&
             `    },` && |\n| &&
             `    DateAbapDateToDateObject(d) {` && |\n| &&
             `      return new Date(...parseDmy(d));` && |\n| &&
             `    },` && |\n| &&
             `    // t is an ABAP time string "HHMMSS"; if omitted we default to midnight.` && |\n| &&
             `    DateAbapDateTimeToDateObject(d, t = "000000") {` && |\n| &&
             `      return new Date(` && |\n| &&
             `        ...parseDmy(d),` && |\n| &&
             `        +t.slice(0, 2),` && |\n| &&
             `        +t.slice(2, 4),` && |\n| &&
             `        +t.slice(4, 6),` && |\n| &&
             `      );` && |\n| &&
             `    },` && |\n| &&
             `  };` && |\n| &&
             `});` && |\n| &&
             `sap.ui.require(["z2ui5/Util"], (Util) => (z2ui5.Util = Util));` && |\n| &&
             `` && |\n| &&
             `sap.ui.define("z2ui5/Favicon", ["sap/ui/core/Control"], (Control) => {` && |\n| &&
             `  "use strict";` && |\n| &&
             `  return Control.extend("z2ui5.Favicon", {` && |\n| &&
             `    metadata: {` && |\n| &&
             `      properties: {` && |\n| &&
             `        favicon: {` && |\n| &&
             `          type: "string",` && |\n| &&
             `        },` && |\n| &&
             `      },` && |\n| &&
             `    },` && |\n| &&
             `    setFavicon(val) {` && |\n| &&
             `      this.setProperty("favicon", val);` && |\n| &&
             `      const existing = document.head.querySelector('link[rel="shortcut icon"]');` && |\n| &&
             `      if (existing) {` && |\n| &&
             `        existing.href = val;` && |\n| &&
             `        return;` && |\n| &&
             |\n|.
    result = result &&
             `      }` && |\n| &&
             `      const link = document.createElement("link");` && |\n| &&
             `      link.rel = "shortcut icon";` && |\n| &&
             `      link.href = val;` && |\n| &&
             `      document.head.appendChild(link);` && |\n| &&
             `    },` && |\n| &&
             `    renderer: { apiVersion: 2, render() {} },` && |\n| &&
             `  });` && |\n| &&
             `});` && |\n| &&
             `` && |\n| &&
             `sap.ui.define("z2ui5/Dirty", ["sap/ui/core/Control"], (Control) => {` && |\n| &&
             `  "use strict";` && |\n| &&
             `  return Control.extend("z2ui5.Dirty", {` && |\n| &&
             `    metadata: {` && |\n| &&
             `      properties: {` && |\n| &&
             `        isDirty: {` && |\n| &&
             `          type: "boolean",` && |\n| &&
             `          defaultValue: false,` && |\n| &&
             `        },` && |\n| &&
             `      },` && |\n| &&
             `    },` && |\n| &&
             `    setIsDirty(val) {` && |\n| &&
             `      this.setProperty("isDirty", val);` && |\n| &&
             `` && |\n| &&
             `      // Fallback for non-launchpad scenarios: ask the browser to confirm` && |\n| &&
             `      // before leaving the page when something is unsaved.` && |\n| &&
             `      const fallback = () => {` && |\n| &&
             `        if (val) {` && |\n| &&
             `          window.onbeforeunload = (e) => {` && |\n| &&
             `            e.preventDefault();` && |\n| &&
             `            e.returnValue = "";` && |\n| &&
             `          };` && |\n| &&
             `        } else {` && |\n| &&
             `          window.onbeforeunload = null;` && |\n| &&
             `        }` && |\n| &&
             `      };` && |\n| &&
             `` && |\n| &&
             `      // Use the FLP dirty flag when running inside the Launchpad (SAPUI5` && |\n| &&
             `      // only); otherwise fall back to the browser unload prompt.` && |\n| &&
             `      try {` && |\n| &&
             `        const launchpad = z2ui5.oLaunchpad;` && |\n| &&
             `        const hasFlpDirtyFlag =` && |\n| &&
             `          launchpad &&` && |\n| &&
             `          launchpad.Container &&` && |\n| &&
             `          launchpad.Container.setDirtyFlag &&` && |\n| &&
             `          launchpad.ShellUIService;` && |\n| &&
             `        if (hasFlpDirtyFlag) {` && |\n| &&
             `          launchpad.Container.setDirtyFlag(val);` && |\n| &&
             `        } else {` && |\n| &&
             `          fallback();` && |\n| &&
             `        }` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        _logError("Dirty.setIsDirty: setDirtyFlag failed", e);` && |\n| &&
             `        fallback();` && |\n| &&
             `      }` && |\n| &&
             `    },` && |\n| &&
             `    exit() {` && |\n| &&
             `      window.onbeforeunload = null;` && |\n| &&
             `    },` && |\n| &&
             `    renderer: { apiVersion: 2, render() {} },` && |\n| &&
             `  });` && |\n| &&
             `});` && |\n| &&
             `` && |\n| &&
              ``.

  ENDMETHOD.

ENDCLASS.
