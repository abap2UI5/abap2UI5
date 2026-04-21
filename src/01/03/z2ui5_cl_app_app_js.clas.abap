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

    result = `function _logError(msg, err) {` && |\n| &&
             `  (z2ui5.errors ??= []).push({ message: msg, ...(err !== undefined && { error: err }), ts: new Date().toISOString() });` && |\n| &&
             `}` && |\n| &&
             `` && |\n| &&
             `sap.ui.define(` && |\n| &&
             `  [` && |\n| &&
             `    'sap/ui/core/mvc/Controller',` && |\n| &&
             `    'z2ui5/controller/View1.controller',` && |\n| &&
             `    'z2ui5/cc/Server',` && |\n| &&
             `    'sap/ui/core/routing/HashChanger',` && |\n| &&
             `  ],` && |\n| &&
             `  (BaseController, Controller, Server, HashChanger) => {` && |\n| &&
             `    'use strict';` && |\n| &&
             `    return BaseController.extend('z2ui5.controller.App', {` && |\n| &&
             `      onInit() {` && |\n| &&
             `        const oOwnerComponent = this.getOwnerComponent();` && |\n| &&
             `        z2ui5.oOwnerComponent = oOwnerComponent;` && |\n| &&
             `        z2ui5.oConfig.pathname = z2ui5.checkLocal` && |\n| &&
             `          ? window.location.href` && |\n| &&
             `          : oOwnerComponent.getManifest()['sap.app'].dataSources.http.uri;` && |\n| &&
             `` && |\n| &&
             `        Object.assign(z2ui5, {` && |\n| &&
             `          oController: new Controller(),` && |\n| &&
             `          oApp: this.getView().byId('app'),` && |\n| &&
             `          oControllerNest: new Controller(),` && |\n| &&
             `          oControllerNest2: new Controller(),` && |\n| &&
             `          oControllerPopup: new Controller(),` && |\n| &&
             `          oControllerPopover: new Controller(),` && |\n| &&
             `          onBeforeRoundtrip: [],` && |\n| &&
             `          onAfterRendering: [],` && |\n| &&
             `          onBeforeEventFrontend: [],` && |\n| &&
             `          onAfterRoundtrip: [],` && |\n| &&
             `          errors: [],` && |\n| &&
             `          checkNestAfter: false,` && |\n| &&
             `          checkNestAfter2: false,` && |\n| &&
             `        });` && |\n| &&
             `` && |\n| &&
             `        if (HashChanger.getInstance().getHash()) {` && |\n| &&
             `          z2ui5.checkInit = true;` && |\n| &&
             `          Server.Roundtrip();` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `    });` && |\n| &&
             `  },` && |\n| &&
             `);` && |\n| &&
             `` && |\n| &&
             `sap.ui.define('z2ui5/Timer', ['sap/ui/core/Control'], (Control) => {` && |\n| &&
             `  'use strict';` && |\n| &&
             `` && |\n| &&
             `  return Control.extend('z2ui5.Timer', {` && |\n| &&
             `    metadata: {` && |\n| &&
             `      properties: {` && |\n| &&
             `        delayMS: {` && |\n| &&
             `          type: 'int',` && |\n| &&
             `          defaultValue: 0,` && |\n| &&
             `        },` && |\n| &&
             `        checkActive: {` && |\n| &&
             `          type: 'boolean',` && |\n| &&
             `          defaultValue: true,` && |\n| &&
             `        },` && |\n| &&
             `        checkRepeat: {` && |\n| &&
             `          type: 'boolean',` && |\n| &&
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
             `      if (!this.getProperty('checkActive')) return;` && |\n| &&
             `      clearTimeout(this._timerId);` && |\n| &&
             `      this._timerId = setTimeout(() => {` && |\n| &&
             `        if (this.bIsDestroyed) return;` && |\n| &&
             `        if (!this.getProperty('checkRepeat')) this.setProperty('checkActive', false, true);` && |\n| &&
             `        this.fireFinished();` && |\n| &&
             `        if (this.getProperty('checkRepeat') && !this.bIsDestroyed) this.delayedCall();` && |\n| &&
             `      }, this.getProperty('delayMS'));` && |\n| &&
             `    },` && |\n| &&
             `    renderer(oRm, oControl) {` && |\n| &&
             `      oRm.openStart('span', oControl);` && |\n| &&
             `      oRm.addStyle('display', 'none');` && |\n| &&
             `      oRm.openEnd();` && |\n| &&
             `      oRm.close('span');` && |\n| &&
             `      oControl._pendingTimer = oControl.getProperty('checkActive');` && |\n| &&
             `    },` && |\n| &&
             `  });` && |\n| &&
             `});` && |\n| &&
             `` && |\n| &&
             `sap.ui.define('z2ui5/Focus', ['sap/ui/core/Control'], (Control) => {` && |\n| &&
             `  'use strict';` && |\n| &&
             `  return Control.extend('z2ui5.Focus', {` && |\n| &&
             `    metadata: {` && |\n| &&
             `      properties: {` && |\n| &&
             `        setUpdate: {` && |\n| &&
             `          type: 'boolean',` && |\n| &&
             `          defaultValue: true,` && |\n| &&
             `        },` && |\n| &&
             `        focusId: {` && |\n| &&
             `          type: 'string',` && |\n| &&
             `        },` && |\n| &&
             `        selectionStart: {` && |\n| &&
             `          type: 'string',` && |\n| &&
             `          defaultValue: '0',` && |\n| &&
             `        },` && |\n| &&
             `        selectionEnd: {` && |\n| &&
             `          type: 'string',` && |\n| &&
             `          defaultValue: '0',` && |\n| &&
             `        },` && |\n| &&
             `      },` && |\n| &&
             `    },` && |\n| &&
             `    setFocusId(val) {` && |\n| &&
             `      try {` && |\n| &&
             `        this.setProperty('focusId', val);` && |\n| &&
             `        const oElement = z2ui5.oView?.byId(val);` && |\n| &&
             `        if (oElement) oElement.applyFocusInfo(oElement.getFocusInfo());` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        _logError(``Focus.setFocusId failed``, e);` && |\n| &&
             `      }` && |\n| &&
             `    },` && |\n| &&
             `    onAfterRendering() {` && |\n| &&
             `      if (!this._pendingFocus) return;` && |\n| &&
             `      this._pendingFocus = false;` && |\n| &&
             `      const oElement = z2ui5.oView?.byId(this.getProperty('focusId'));` && |\n| &&
             `      if (!oElement) return;` && |\n| &&
             `      try {` && |\n| &&
             `        oElement.applyFocusInfo(` && |\n| &&
             `          Object.assign(oElement.getFocusInfo(), {` && |\n| &&
             `            selectionStart: +this.getProperty('selectionStart'),` && |\n| &&
             `            selectionEnd: +this.getProperty('selectionEnd'),` && |\n| &&
             `          }),` && |\n| &&
             `        );` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        _logError(``Focus.onAfterRendering: applyFocusInfo failed``, e);` && |\n| &&
             `      }` && |\n| &&
             `    },` && |\n| &&
             `    renderer(oRm, oControl) {` && |\n| &&
             `      oRm.openStart('span', oControl);` && |\n| &&
             `      oRm.addStyle('display', 'none');` && |\n| &&
             `      oRm.openEnd();` && |\n| &&
             `      oRm.close('span');` && |\n| &&
             `      if (!oControl.getProperty('setUpdate')) return;` && |\n| &&
             `      oControl.setProperty('setUpdate', false, true);` && |\n| &&
             `      oControl._pendingFocus = true;` && |\n| &&
             `    },` && |\n| &&
             `  });` && |\n| &&
             `});` && |\n| &&
             `` && |\n| &&
             `sap.ui.define('z2ui5/Title', ['sap/ui/core/Control'], (Control) => {` && |\n| &&
             `  'use strict';` && |\n| &&
             `  return Control.extend('z2ui5.Title', {` && |\n| &&
             `    metadata: {` && |\n| &&
             `      properties: {` && |\n| &&
             `        title: {` && |\n| &&
             `          type: 'string',` && |\n| &&
             `        },` && |\n| &&
             `      },` && |\n| &&
             `    },` && |\n| &&
             `    setTitle(val) {` && |\n| &&
             `      this.setProperty('title', val);` && |\n| &&
             `      document.title = String(val ?? '');` && |\n| &&
             `    },` && |\n| &&
             `    renderer() {},` && |\n| &&
             `  });` && |\n| &&
             `});` && |\n| &&
             `` && |\n| &&
             `sap.ui.define('z2ui5/LPTitle', ['sap/ui/core/Control'], (Control) => {` && |\n| &&
             `  'use strict';` && |\n| &&
             `  return Control.extend('z2ui5.LPTitle', {` && |\n| &&
             `    metadata: {` && |\n| &&
             `      properties: {` && |\n| &&
             `        title: {` && |\n| &&
             `          type: 'string',` && |\n| &&
             `        },` && |\n| &&
             `        ApplicationFullWidth: {` && |\n| &&
             `          type: 'boolean',` && |\n| &&
             `        },` && |\n| &&
             `      },` && |\n| &&
             `    },` && |\n| &&
             `    setTitle(val) {` && |\n| &&
             `      this.setProperty('title', val);` && |\n| &&
             `      try {` && |\n| &&
             `        z2ui5.oLaunchpadService` && |\n| &&
             `          ?.setTitle(val)` && |\n| &&
             `          ?.catch((e) => _logError(``LPTitle: Launchpad Service setTitle failed``, e));` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        _logError(``LPTitle: Launchpad Service setTitle failed``, e);` && |\n| &&
             `      }` && |\n| &&
             `    },` && |\n| &&
             `` && |\n| &&
             `    setApplicationFullWidth(val) {` && |\n| &&
             `      this.setProperty('ApplicationFullWidth', val);` && |\n| &&
             `      sap.ui.require(` && |\n| &&
             `        ['sap/ushell/services/AppConfiguration'],` && |\n| &&
             `        (AppConfiguration) => {` && |\n| &&
             `          if (this.bIsDestroyed) return;` && |\n| &&
             `          try {` && |\n| &&
             `            AppConfiguration.setApplicationFullWidth(val);` && |\n| &&
             `          } catch (e) {` && |\n| &&
             `            _logError(``LPTitle: setApplicationFullWidth failed``, e);` && |\n| &&
             `          }` && |\n| &&
             `        },` && |\n| &&
             `        () => _logError(``LPTitle: sap/ushell/services/AppConfiguration not available``),` && |\n| &&
             `      );` && |\n| &&
             `    },` && |\n| &&
             `` && |\n| &&
             `    renderer() {},` && |\n| &&
             `  });` && |\n| &&
             `});` && |\n| &&
             `` && |\n| &&
             `sap.ui.define('z2ui5/History', ['sap/ui/core/Control'], (Control) => {` && |\n| &&
             `  'use strict';` && |\n| &&
             `  return Control.extend('z2ui5.History', {` && |\n| &&
             `    metadata: {` && |\n| &&
             `      properties: {` && |\n| &&
             `        search: {` && |\n| &&
             `          type: 'string',` && |\n| &&
             `        },` && |\n| &&
             `      },` && |\n| &&
             `    },` && |\n| &&
             `    setSearch(val) {` && |\n| &&
             `      this.setProperty('search', val);` && |\n| &&
             `      try {` && |\n| &&
             `        history.replaceState(null, '', ``${window.location.pathname}${val ?? ''}``);` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        _logError(``History.setSearch: replaceState failed``, e);` && |\n| &&
             `      }` && |\n| &&
             `    },` && |\n| &&
             `    renderer() {},` && |\n| &&
             `  });` && |\n| &&
             `});` && |\n| &&
             `` && |\n| &&
             `sap.ui.define('z2ui5/Tree', ['sap/ui/core/Control'], (Control) => {` && |\n| &&
             `  'use strict';` && |\n| &&
             `` && |\n| &&
             `  return Control.extend('z2ui5.Tree', {` && |\n| &&
             `    metadata: {` && |\n| &&
             `      properties: {` && |\n| &&
             `        tree_id: {` && |\n| &&
             `          type: 'string',` && |\n| &&
             `        },` && |\n| &&
             `      },` && |\n| &&
             `    },` && |\n| &&
             `` && |\n| &&
             `    _getTreeBinding() {` && |\n| &&
             `      return z2ui5.oView?.byId(this.getProperty('tree_id'))?.getBinding('items');` && |\n| &&
             `    },` && |\n| &&
             `` && |\n| &&
             `    setBackend() {` && |\n| &&
             `      try {` && |\n| &&
             `        z2ui5.treeState = this._getTreeBinding()?.getCurrentTreeState();` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        _logError(``Tree.setBackend: failed``, e);` && |\n| &&
             `      }` && |\n| &&
             `    },` && |\n| &&
             `` && |\n| &&
             `    init() {` && |\n| &&
             `      this._setBackendBound = this.setBackend.bind(this);` && |\n| &&
             `      (z2ui5.onBeforeRoundtrip ??= []).push(this._setBackendBound);` && |\n| &&
             `    },` && |\n| &&
             `` && |\n| &&
             `    exit() {` && |\n| &&
             `      z2ui5.onBeforeRoundtrip = (z2ui5.onBeforeRoundtrip ?? []).filter((fn) => fn !== this._setBackendBound);` && |\n| &&
             `    },` && |\n| &&
             `` && |\n| &&
             `    onAfterRendering() {` && |\n| &&
             `      if (!this._pendingTreeState) return;` && |\n| &&
             `      this._pendingTreeState = false;` && |\n| &&
             `      try {` && |\n| &&
             `        this._getTreeBinding()?.setTreeState(z2ui5.treeState);` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        _logError(``Tree.onAfterRendering: setTreeState failed``, e);` && |\n| &&
             `      }` && |\n| &&
             `    },` && |\n| &&
             `` && |\n| &&
             `    renderer(oRm, oControl) {` && |\n| &&
             `      oRm.openStart('span', oControl);` && |\n| &&
             `      oRm.addStyle('display', 'none');` && |\n| &&
             `      oRm.openEnd();` && |\n| &&
             `      oRm.close('span');` && |\n| &&
             `      if (!z2ui5.treeState) return;` && |\n| &&
             `      oControl._pendingTreeState = true;` && |\n| &&
             `    },` && |\n| &&
             `  });` && |\n| &&
             `});` && |\n| &&
             `` && |\n| &&
             `sap.ui.define('z2ui5/Scrolling', ['sap/ui/core/Control'], (Control) => {` && |\n| &&
             `  'use strict';` && |\n| &&
             `` && |\n| &&
             `  return Control.extend('z2ui5.Scrolling', {` && |\n| &&
             `    metadata: {` && |\n| &&
             `      properties: {` && |\n| &&
             `        setUpdate: {` && |\n| &&
             `          type: 'boolean',` && |\n| &&
             `          defaultValue: true,` && |\n| &&
             `        },` && |\n| &&
             `        items: {` && |\n| &&
             `          type: 'object',` && |\n| &&
             `        },` && |\n| &&
             `      },` && |\n| &&
             `    },` && |\n| &&
             `` && |\n| &&
             `    _getDomInnerElement(id) {` && |\n| &&
             `      const control = z2ui5.oView?.byId(id);` && |\n| &&
             `      return control && document.getElementById(``${control.getId()}-inner``);` && |\n| &&
             `    },` && |\n| &&
             `` && |\n| &&
             `    _getScrollTop(item) {` && |\n| &&
             `      try {` && |\n| &&
             `        const control = z2ui5.oView?.byId(item.N);` && |\n| &&
             `        const scrollDelegate = control?.getScrollDelegate?.();` && |\n| &&
             `        if (scrollDelegate) return scrollDelegate.getScrollTop();` && |\n| &&
             `        const element = this._getDomInnerElement(item.ID);` && |\n| &&
             `        return element?.scrollTop ?? 0;` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        _logError(``Scrolling._getScrollTop: failed``, e);` && |\n| &&
             `        return 0;` && |\n| &&
             `      }` && |\n| &&
             `    },` && |\n| &&
             `` && |\n| &&
             `    setBackend() {` && |\n| &&
             `      const items = this.getProperty('items');` && |\n| &&
             `      if (!items) return;` && |\n| &&
             `      try {` && |\n| &&
             `        const bindingInfo = this.getBindingInfo('items');` && |\n| &&
             `        const bindingPath = bindingInfo?.parts?.[0]?.path ?? bindingInfo?.path;` && |\n| &&
             `        for (const [index, item] of items.entries()) {` && |\n| &&
             `          const scrollTop = this._getScrollTop(item);` && |\n| &&
             `          if (item.V !== scrollTop) {` && |\n| &&
             `            item.V = scrollTop;` && |\n| &&
             `            if (bindingPath) z2ui5.xxChangedPaths?.add(``${bindingPath}/${index}/V``);` && |\n| &&
             `          }` && |\n| &&
             `        }` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        _logError(``Scrolling.setBackend: failed``, e);` && |\n| &&
             `      }` && |\n| &&
             `    },` && |\n| &&
             `` && |\n| &&
             `    init() {` && |\n| &&
             `      this._setBackendBound = this.setBackend.bind(this);` && |\n| &&
             `      (z2ui5.onBeforeRoundtrip ??= []).push(this._setBackendBound);` && |\n| &&
             `    },` && |\n| &&
             `` && |\n| &&
             `    exit() {` && |\n| &&
             `      z2ui5.onBeforeRoundtrip = (z2ui5.onBeforeRoundtrip ?? []).filter((fn) => fn !== this._setBackendBound);` && |\n| &&
             `    },` && |\n| &&
             `` && |\n| &&
             `    _restoreScrollPosition(item) {` && |\n| &&
             `      try {` && |\n| &&
             `        const control = z2ui5.oView?.byId(item.N);` && |\n| &&
             `        if (control?.scrollTo) {` && |\n| &&
             `          control.scrollTo(item.V);` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `        const element = this._getDomInnerElement(item.ID);` && |\n| &&
             `        if (element) element.scrollTop = item.V;` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        _logError(``Scrolling._restoreScrollPosition: failed``, e);` && |\n| &&
             `      }` && |\n| &&
             `    },` && |\n| &&
             `` && |\n| &&
             `    onAfterRendering() {` && |\n| &&
             `      if (!this._pendingScroll) return;` && |\n| &&
             `      this._pendingScroll = false;` && |\n| &&
             `` && |\n| &&
             `      const items = this.getProperty('items');` && |\n| &&
             `      if (!items) return;` && |\n| &&
             `` && |\n| &&
             `      try {` && |\n| &&
             `        for (const item of items) {` && |\n| &&
             `          const control = z2ui5.oView?.byId(item.N);` && |\n| &&
             `          if (control?.getDomRef()) {` && |\n| &&
             `            this._restoreScrollPosition(item);` && |\n| &&
             `          } else if (control) {` && |\n| &&
             `            const delegate = {` && |\n| &&
             `              onAfterRendering: () => {` && |\n| &&
             `                control.removeEventDelegate(delegate);` && |\n| &&
             `                if (!this.bIsDestroyed) this._restoreScrollPosition(item);` && |\n| &&
             `              },` && |\n| &&
             `            };` && |\n| &&
             `            control.addEventDelegate(delegate);` && |\n| &&
             `          }` && |\n| &&
             `        }` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        _logError(``Scrolling.onAfterRendering: failed``, e);` && |\n| &&
             `      }` && |\n| &&
             `    },` && |\n| &&
             `` && |\n| &&
             `    renderer(oRm, oControl) {` && |\n| &&
             |\n|.
    result = result &&
             `      oRm.openStart('span', oControl);` && |\n| &&
             `      oRm.addStyle('display', 'none');` && |\n| &&
             `      oRm.openEnd();` && |\n| &&
             `      oRm.close('span');` && |\n| &&
             `` && |\n| &&
             `      if (!oControl.getProperty('setUpdate')) return;` && |\n| &&
             `      oControl.setProperty('setUpdate', false, true);` && |\n| &&
             `      oControl._pendingScroll = true;` && |\n| &&
             `    },` && |\n| &&
             `  });` && |\n| &&
             `});` && |\n| &&
             `` && |\n| &&
             `sap.ui.define('z2ui5/Info', ['sap/ui/core/Control'], (Control) => {` && |\n| &&
             `  'use strict';` && |\n| &&
             `` && |\n| &&
             `  return Control.extend('z2ui5.Info', {` && |\n| &&
             `    metadata: {` && |\n| &&
             `      properties: {` && |\n| &&
             `        ui5_version: {` && |\n| &&
             `          type: 'string',` && |\n| &&
             `        },` && |\n| &&
             `        device_phone: {` && |\n| &&
             `          type: 'string',` && |\n| &&
             `        },` && |\n| &&
             `        device_desktop: {` && |\n| &&
             `          type: 'string',` && |\n| &&
             `        },` && |\n| &&
             `        device_tablet: {` && |\n| &&
             `          type: 'string',` && |\n| &&
             `        },` && |\n| &&
             `        device_combi: {` && |\n| &&
             `          type: 'string',` && |\n| &&
             `        },` && |\n| &&
             `        device_height: {` && |\n| &&
             `          type: 'string',` && |\n| &&
             `        },` && |\n| &&
             `        device_width: {` && |\n| &&
             `          type: 'string',` && |\n| &&
             `        },` && |\n| &&
             `        ui5_theme: {` && |\n| &&
             `          type: 'string',` && |\n| &&
             `        },` && |\n| &&
             `        device_os: {` && |\n| &&
             `          type: 'string',` && |\n| &&
             `        },` && |\n| &&
             `        device_systemtype: {` && |\n| &&
             `          type: 'string',` && |\n| &&
             `        },` && |\n| &&
             `        device_browser: {` && |\n| &&
             `          type: 'string',` && |\n| &&
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
             `    renderer(_, oControl) {` && |\n| &&
             `      try {` && |\n| &&
             `        const deviceData = z2ui5.oView?.getModel('device')?.getData();` && |\n| &&
             `        if (!deviceData) return;` && |\n| &&
             `        const { system, resize, os, browser } = deviceData;` && |\n| &&
             `        for (const [prop, val] of [` && |\n| &&
             `          ['ui5_version', z2ui5.oConfig?.UI5VersionInfo?.version],` && |\n| &&
             `          ['device_phone', system.phone],` && |\n| &&
             `          ['device_desktop', system.desktop],` && |\n| &&
             `          ['device_tablet', system.tablet],` && |\n| &&
             `          ['device_combi', system.combi],` && |\n| &&
             `          ['device_height', resize.height],` && |\n| &&
             `          ['device_width', resize.width],` && |\n| &&
             `          ['device_os', os.name],` && |\n| &&
             `          ['device_browser', browser.name],` && |\n| &&
             `        ])` && |\n| &&
             `          oControl.setProperty(prop, String(val ?? ''), true);` && |\n| &&
             `        oControl.fireFinished();` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        _logError(``Info.renderer: failed``, e);` && |\n| &&
             `      }` && |\n| &&
             `    },` && |\n| &&
             `  });` && |\n| &&
             `});` && |\n| &&
             `` && |\n| &&
             `sap.ui.define('z2ui5/Geolocation', ['sap/ui/core/Control'], (Control) => {` && |\n| &&
             `  'use strict';` && |\n| &&
             `` && |\n| &&
             `  const _GEO_PROPS = ['longitude', 'latitude', 'altitude', 'accuracy', 'altitudeAccuracy', 'speed', 'heading'];` && |\n| &&
             `` && |\n| &&
             `  return Control.extend('z2ui5.Geolocation', {` && |\n| &&
             `    metadata: {` && |\n| &&
             `      properties: {` && |\n| &&
             `        longitude: {` && |\n| &&
             `          type: 'string',` && |\n| &&
             `          defaultValue: '',` && |\n| &&
             `        },` && |\n| &&
             `        latitude: {` && |\n| &&
             `          type: 'string',` && |\n| &&
             `          defaultValue: '',` && |\n| &&
             `        },` && |\n| &&
             `        altitude: {` && |\n| &&
             `          type: 'string',` && |\n| &&
             `          defaultValue: '',` && |\n| &&
             `        },` && |\n| &&
             `        accuracy: {` && |\n| &&
             `          type: 'string',` && |\n| &&
             `          defaultValue: '',` && |\n| &&
             `        },` && |\n| &&
             `        altitudeAccuracy: {` && |\n| &&
             `          type: 'string',` && |\n| &&
             `          defaultValue: '',` && |\n| &&
             `        },` && |\n| &&
             `        speed: {` && |\n| &&
             `          type: 'string',` && |\n| &&
             `          defaultValue: '',` && |\n| &&
             `        },` && |\n| &&
             `        heading: {` && |\n| &&
             `          type: 'string',` && |\n| &&
             `          defaultValue: '',` && |\n| &&
             `        },` && |\n| &&
             `        enableHighAccuracy: {` && |\n| &&
             `          type: 'boolean',` && |\n| &&
             `          defaultValue: false,` && |\n| &&
             `        },` && |\n| &&
             `        timeout: {` && |\n| &&
             `          type: 'string',` && |\n| &&
             `          defaultValue: '5000',` && |\n| &&
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
             `      if (this.bIsDestroyed) return;` && |\n| &&
             `      for (const prop of _GEO_PROPS) this.setProperty(prop, coords[prop]?.toString() ?? '', true);` && |\n| &&
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
             `        navigator.geolocation?.getCurrentPosition(` && |\n| &&
             `          this.callbackPosition.bind(this),` && |\n| &&
             `          (error) => _logError(``Geolocation error (${error.code}): ${error.message}``),` && |\n| &&
             `          {` && |\n| &&
             `            enableHighAccuracy: this.getProperty('enableHighAccuracy'),` && |\n| &&
             `            timeout: +this.getProperty('timeout'),` && |\n| &&
             `          },` && |\n| &&
             `        );` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        _logError(``Geolocation.onAfterRendering: getCurrentPosition failed``, e);` && |\n| &&
             `      }` && |\n| &&
             `    },` && |\n| &&
             `` && |\n| &&
             `    renderer(oRm, oControl) {` && |\n| &&
             `      oRm.openStart('span', oControl);` && |\n| &&
             `      oRm.addStyle('display', 'none');` && |\n| &&
             `      oRm.openEnd();` && |\n| &&
             `      oRm.close('span');` && |\n| &&
             `    },` && |\n| &&
             `  });` && |\n| &&
             `});` && |\n| &&
             `` && |\n| &&
             `sap.ui.define('z2ui5/Storage', ['sap/ui/core/Control', 'sap/ui/util/Storage'], (Control, Storage) => {` && |\n| &&
             `  'use strict';` && |\n| &&
             `` && |\n| &&
             `  return Control.extend('z2ui5.Storage', {` && |\n| &&
             `    metadata: {` && |\n| &&
             `      properties: {` && |\n| &&
             `        type: {` && |\n| &&
             `          type: 'string',` && |\n| &&
             `          defaultValue: 'session',` && |\n| &&
             `        },` && |\n| &&
             `        prefix: {` && |\n| &&
             `          type: 'string',` && |\n| &&
             `          defaultValue: '',` && |\n| &&
             `        },` && |\n| &&
             `        key: {` && |\n| &&
             `          type: 'string',` && |\n| &&
             `          defaultValue: '',` && |\n| &&
             `        },` && |\n| &&
             `        value: {` && |\n| &&
             `          type: 'any',` && |\n| &&
             `          defaultValue: '',` && |\n| &&
             `        },` && |\n| &&
             `      },` && |\n| &&
             `      events: {` && |\n| &&
             `        finished: {` && |\n| &&
             `          parameters: {` && |\n| &&
             `            type: {` && |\n| &&
             `              type: 'string',` && |\n| &&
             `            },` && |\n| &&
             `            prefix: {` && |\n| &&
             `              type: 'string',` && |\n| &&
             `            },` && |\n| &&
             `            key: {` && |\n| &&
             `              type: 'string',` && |\n| &&
             `            },` && |\n| &&
             `            value: {` && |\n| &&
             `              type: 'any',` && |\n| &&
             `            },` && |\n| &&
             `          },` && |\n| &&
             `        },` && |\n| &&
             `      },` && |\n| &&
             `    },` && |\n| &&
             `` && |\n| &&
             `    renderer(_, oControl) {` && |\n| &&
             `      const type = oControl.getProperty('type');` && |\n| &&
             `      const prefix = oControl.getProperty('prefix');` && |\n| &&
             `      const key = oControl.getProperty('key');` && |\n| &&
             `      const value = oControl.getProperty('value');` && |\n| &&
             `      let stored;` && |\n| &&
             `      try {` && |\n| &&
             `        stored = new Storage(Storage.Type[type] ?? Storage.Type.session, prefix).get(key) ?? '';` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        _logError(``Storage: read failed for key '${key}'``, e);` && |\n| &&
             `        return;` && |\n| &&
             `      }` && |\n| &&
             `      if (stored !== value) {` && |\n| &&
             `        oControl.setProperty('value', stored, true);` && |\n| &&
             `        oControl.fireFinished({ type, prefix, key, value: stored });` && |\n| &&
             `      }` && |\n| &&
             `    },` && |\n| &&
             `  });` && |\n| &&
             `});` && |\n| &&
             `` && |\n| &&
             `sap.ui.define(` && |\n| &&
             `  'z2ui5/FileUploader',` && |\n| &&
             `  ['sap/ui/core/Control', 'sap/m/Button', 'sap/ui/unified/FileUploader', 'sap/m/HBox'],` && |\n| &&
             `  (Control, Button, FileUploader, HBox) => {` && |\n| &&
             `    'use strict';` && |\n| &&
             `` && |\n| &&
             `    return Control.extend('z2ui5.FileUploader', {` && |\n| &&
             `      metadata: {` && |\n| &&
             `        properties: {` && |\n| &&
             `          value: {` && |\n| &&
             `            type: 'string',` && |\n| &&
             `            defaultValue: '',` && |\n| &&
             `          },` && |\n| &&
             `          path: {` && |\n| &&
             `            type: 'string',` && |\n| &&
             `            defaultValue: '',` && |\n| &&
             `          },` && |\n| &&
             `          tooltip: {` && |\n| &&
             `            type: 'string',` && |\n| &&
             `            defaultValue: '',` && |\n| &&
             `          },` && |\n| &&
             `          fileType: {` && |\n| &&
             `            type: 'string',` && |\n| &&
             `            defaultValue: '',` && |\n| &&
             `          },` && |\n| &&
             `          placeholder: {` && |\n| &&
             `            type: 'string',` && |\n| &&
             `            defaultValue: '',` && |\n| &&
             `          },` && |\n| &&
             `          buttonText: {` && |\n| &&
             `            type: 'string',` && |\n| &&
             `            defaultValue: '',` && |\n| &&
             `          },` && |\n| &&
             `          style: {` && |\n| &&
             `            type: 'string',` && |\n| &&
             `            defaultValue: '',` && |\n| &&
             `          },` && |\n| &&
             `          uploadButtonText: {` && |\n| &&
             `            type: 'string',` && |\n| &&
             `            defaultValue: 'Upload',` && |\n| &&
             `          },` && |\n| &&
             `          enabled: {` && |\n| &&
             `            type: 'boolean',` && |\n| &&
             `            defaultValue: true,` && |\n| &&
             `          },` && |\n| &&
             `          icon: {` && |\n| &&
             `            type: 'string',` && |\n| &&
             `            defaultValue: 'sap-icon://browse-folder',` && |\n| &&
             `          },` && |\n| &&
             `          iconOnly: {` && |\n| &&
             `            type: 'boolean',` && |\n| &&
             `            defaultValue: false,` && |\n| &&
             `          },` && |\n| &&
             `          buttonOnly: {` && |\n| &&
             `            type: 'boolean',` && |\n| &&
             `            defaultValue: false,` && |\n| &&
             `          },` && |\n| &&
             `          multiple: {` && |\n| &&
             `            type: 'boolean',` && |\n| &&
             `            defaultValue: false,` && |\n| &&
             `          },` && |\n| &&
             `          visible: {` && |\n| &&
             `            type: 'boolean',` && |\n| &&
             `            defaultValue: true,` && |\n| &&
             `          },` && |\n| &&
             `          checkDirectUpload: {` && |\n| &&
             `            type: 'boolean',` && |\n| &&
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
             `          if (this.bIsDestroyed) return;` && |\n| &&
             `          this.setProperty('value', reader.result);` && |\n| &&
             `          this.fireUpload();` && |\n| &&
             `        };` && |\n| &&
             `        reader.onerror = () => _logError(``FileUploader: FileReader failed``, reader.error);` && |\n| &&
             `        reader.readAsDataURL(file);` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      exit() {` && |\n| &&
             `        this._oHBox?.destroy();` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      renderer(oRm, oControl) {` && |\n| &&
             `        const directUpload = oControl.getProperty('checkDirectUpload');` && |\n| &&
             `        const path = oControl.getProperty('path');` && |\n| &&
             `        oControl._oHBox?.destroy();` && |\n| &&
             `        oControl._oHBox = null;` && |\n| &&
             `        oControl.oUploadButton = null;` && |\n| &&
             `        oControl.oFileUploader = null;` && |\n| &&
             `        if (!directUpload) {` && |\n| &&
             `          oControl.oUploadButton = new Button({` && |\n| &&
             `            text: oControl.getProperty('uploadButtonText'),` && |\n| &&
             `            enabled: path !== '',` && |\n| &&
             `            press: () => {` && |\n| &&
             `              oControl.setProperty('path', oControl.oFileUploader.getProperty('value'));` && |\n| &&
             `              const file = oControl.oFileUploader?.oFileUpload?.files?.[0];` && |\n| &&
             `              if (file) oControl._readFile(file);` && |\n| &&
             `            },` && |\n| &&
             `          });` && |\n| &&
             `        }` && |\n| &&
             `` && |\n| &&
             `        oControl.oFileUploader = new FileUploader({` && |\n| &&
             `          icon: oControl.getProperty('icon'),` && |\n| &&
             `          iconOnly: oControl.getProperty('iconOnly'),` && |\n| &&
             `          buttonOnly: oControl.getProperty('buttonOnly'),` && |\n| &&
             `          buttonText: oControl.getProperty('buttonText'),` && |\n| &&
             `          style: oControl.getProperty('style'),` && |\n| &&
             `          fileType: oControl.getProperty('fileType'),` && |\n| &&
             `          visible: oControl.getProperty('visible'),` && |\n| &&
             `          uploadOnChange: directUpload,` && |\n| &&
             `          multiple: oControl.getProperty('multiple'),` && |\n| &&
             `          enabled: oControl.getProperty('enabled'),` && |\n| &&
             `          value: path,` && |\n| &&
             `          placeholder: oControl.getProperty('placeholder'),` && |\n| &&
             `          change: (oEvent) => {` && |\n| &&
             `            if (directUpload) return;` && |\n| &&
             `            const value = oEvent.getSource().getProperty('value');` && |\n| &&
             `            oControl.setProperty('path', value);` && |\n| &&
             `            oControl.oUploadButton?.setEnabled(!!value);` && |\n| &&
             `            oControl.oUploadButton?.rerender();` && |\n| &&
             `          },` && |\n| &&
             `          uploadComplete: (oEvent) => {` && |\n| &&
             `            if (!directUpload) return;` && |\n| &&
             `            const value = oEvent.getSource().getProperty('value');` && |\n| &&
             `            oControl.setProperty('path', value);` && |\n| &&
             `            const file = oEvent.getSource().oFileUpload?.files?.[0];` && |\n| &&
             `            if (file) oControl._readFile(file);` && |\n| &&
             `          },` && |\n| &&
             `        });` && |\n| &&
             `` && |\n| &&
             `        oControl._oHBox = new HBox().addItem(oControl.oFileUploader);` && |\n| &&
             `        if (oControl.oUploadButton) oControl._oHBox.addItem(oControl.oUploadButton);` && |\n| &&
             `        oRm.renderControl(oControl._oHBox);` && |\n| &&
             `      },` && |\n| &&
             `    });` && |\n| &&
             `  },` && |\n| &&
             `);` && |\n| &&
             `` && |\n| &&
             `sap.ui.define('z2ui5/MultiInputExt', ['sap/ui/core/Control', 'sap/m/Token'], (Control, Token) => {` && |\n| &&
             `  'use strict';` && |\n| &&
             `` && |\n| &&
             `  return Control.extend('z2ui5.MultiInputExt', {` && |\n| &&
             `    metadata: {` && |\n| &&
             `      properties: {` && |\n| &&
             `        MultiInputId: {` && |\n| &&
             `          type: 'string',` && |\n| &&
             `        },` && |\n| &&
             |\n|.
    result = result &&
             `        MultiInputName: {` && |\n| &&
             `          type: 'string',` && |\n| &&
             `        },` && |\n| &&
             `        addedTokens: {` && |\n| &&
             `          type: 'object',` && |\n| &&
             `        },` && |\n| &&
             `        checkInit: {` && |\n| &&
             `          type: 'boolean',` && |\n| &&
             `          defaultValue: false,` && |\n| &&
             `        },` && |\n| &&
             `        removedTokens: {` && |\n| &&
             `          type: 'object',` && |\n| &&
             `        },` && |\n| &&
             `      },` && |\n| &&
             `      events: {` && |\n| &&
             `        change: {` && |\n| &&
             `          allowPreventDefault: true,` && |\n| &&
             `          parameters: {},` && |\n| &&
             `        },` && |\n| &&
             `      },` && |\n| &&
             `    },` && |\n| &&
             `` && |\n| &&
             `    init() {` && |\n| &&
             `      this._setControlBound = this.setControl.bind(this);` && |\n| &&
             `      (z2ui5.onAfterRendering ??= []).push(this._setControlBound);` && |\n| &&
             `    },` && |\n| &&
             `    exit() {` && |\n| &&
             `      z2ui5.onAfterRendering = (z2ui5.onAfterRendering ?? []).filter((fn) => fn !== this._setControlBound);` && |\n| &&
             `    },` && |\n| &&
             `` && |\n| &&
             `    onTokenUpdate(oEvent) {` && |\n| &&
             `      const { mParameters } = oEvent;` && |\n| &&
             `      const isRemoved = mParameters.type === 'removed';` && |\n| &&
             `      const tokens = (mParameters[isRemoved ? 'removedTokens' : 'addedTokens'] ?? []).map((item) => ({` && |\n| &&
             `        KEY: item.getKey(),` && |\n| &&
             `        TEXT: item.getText(),` && |\n| &&
             `      }));` && |\n| &&
             `      this.setProperty('addedTokens', isRemoved ? [] : tokens);` && |\n| &&
             `      this.setProperty('removedTokens', isRemoved ? tokens : []);` && |\n| &&
             `      this.fireChange();` && |\n| &&
             `    },` && |\n| &&
             `    renderer() {},` && |\n| &&
             `    setControl() {` && |\n| &&
             `      const table = z2ui5.oView?.byId(this.getProperty('MultiInputId'));` && |\n| &&
             `      if (!table || this.getProperty('checkInit')) return;` && |\n| &&
             `      this.setProperty('checkInit', true);` && |\n| &&
             `      try {` && |\n| &&
             `        table.attachTokenUpdate(this.onTokenUpdate.bind(this));` && |\n| &&
             `        table.addValidator(({ text }) => new Token({ key: text, text }));` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        _logError(``MultiInputExt.setControl: setup failed``, e);` && |\n| &&
             `      }` && |\n| &&
             `    },` && |\n| &&
             `  });` && |\n| &&
             `});` && |\n| &&
             `` && |\n| &&
             `sap.ui.define('z2ui5/SmartMultiInputExt', ['sap/ui/core/Control'], (Control) => {` && |\n| &&
             `  'use strict';` && |\n| &&
             `` && |\n| &&
             `  return Control.extend('z2ui5.SmartMultiInputExt', {` && |\n| &&
             `    metadata: {` && |\n| &&
             `      properties: {` && |\n| &&
             `        multiInputId: {` && |\n| &&
             `          type: 'string',` && |\n| &&
             `        },` && |\n| &&
             `        addedTokens: {` && |\n| &&
             `          type: 'object',` && |\n| &&
             `        },` && |\n| &&
             `        removedTokens: {` && |\n| &&
             `          type: 'object',` && |\n| &&
             `        },` && |\n| &&
             `        rangeData: {` && |\n| &&
             `          type: 'object',` && |\n| &&
             `          defaultValue: [],` && |\n| &&
             `        },` && |\n| &&
             `        checkInit: {` && |\n| &&
             `          type: 'boolean',` && |\n| &&
             `          defaultValue: false,` && |\n| &&
             `        },` && |\n| &&
             `      },` && |\n| &&
             `      events: {` && |\n| &&
             `        change: {` && |\n| &&
             `          allowPreventDefault: true,` && |\n| &&
             `          parameters: {},` && |\n| &&
             `        },` && |\n| &&
             `      },` && |\n| &&
             `    },` && |\n| &&
             `` && |\n| &&
             `    init() {` && |\n| &&
             `      this._setControlBound = this.setControl.bind(this);` && |\n| &&
             `      this._oInput = null;` && |\n| &&
             `      this._oPendingInnerControlsCreated = null;` && |\n| &&
             `      this._bInnerControlsCreated = false;` && |\n| &&
             `      (z2ui5.onAfterRendering ??= []).push(this._setControlBound);` && |\n| &&
             `    },` && |\n| &&
             `    exit() {` && |\n| &&
             `      z2ui5.onAfterRendering = (z2ui5.onAfterRendering ?? []).filter((fn) => fn !== this._setControlBound);` && |\n| &&
             `      this._oPendingInnerControlsCreated?.(null);` && |\n| &&
             `      this._oPendingInnerControlsCreated = null;` && |\n| &&
             `    },` && |\n| &&
             `` && |\n| &&
             `    onTokenUpdate(oEvent) {` && |\n| &&
             `      const { mParameters } = oEvent;` && |\n| &&
             `      const isRemoved = mParameters.type === 'removed';` && |\n| &&
             `      const mappedTokens = (mParameters[isRemoved ? 'removedTokens' : 'addedTokens'] ?? []).map((item) => ({` && |\n| &&
             `        KEY: item.getKey(),` && |\n| &&
             `        TEXT: item.getText(),` && |\n| &&
             `      }));` && |\n| &&
             `      this.setProperty('addedTokens', isRemoved ? [] : mappedTokens);` && |\n| &&
             `      this.setProperty('removedTokens', isRemoved ? mappedTokens : []);` && |\n| &&
             `      const source = oEvent.getSource();` && |\n| &&
             `      const tokens = source.getTokens();` && |\n| &&
             `      this.setProperty(` && |\n| &&
             `        'rangeData',` && |\n| &&
             `        (source.getRangeData() ?? []).map((oRangeData, index) => {` && |\n| &&
             `          const token = tokens[index];` && |\n| &&
             `          return Object.assign(oRangeData, { tokenText: token?.getText() ?? '', tokenLongKey: token?.data('longKey') });` && |\n| &&
             `        }),` && |\n| &&
             `      );` && |\n| &&
             `      this.fireChange();` && |\n| &&
             `    },` && |\n| &&
             `    async setRangeData(aRangeData) {` && |\n| &&
             `      this.setProperty('rangeData', aRangeData);` && |\n| &&
             `      try {` && |\n| &&
             `        const input = await this.inputInitialized();` && |\n| &&
             `        if (this.bIsDestroyed || !input) return;` && |\n| &&
             `        input.setRangeData(` && |\n| &&
             `          aRangeData.map((oRangeData) =>` && |\n| &&
             `            Object.fromEntries(` && |\n| &&
             `              Object.entries(oRangeData).map(([key, value]) => {` && |\n| &&
             `                const k = key.toLowerCase();` && |\n| &&
             `                return [k === 'keyfield' ? 'keyField' : k, value];` && |\n| &&
             `              }),` && |\n| &&
             `            ),` && |\n| &&
             `          ),` && |\n| &&
             `        );` && |\n| &&
             `        //we need to set token text explicitly, as setRangeData does no recalculation` && |\n| &&
             `        for (const [index, token] of (input.getTokens() ?? []).entries()) {` && |\n| &&
             `          const rangeItem = aRangeData[index];` && |\n| &&
             `          if (!rangeItem) continue;` && |\n| &&
             `          const { TOKENLONGKEY, TOKENTEXT } = rangeItem;` && |\n| &&
             `          token.data('longKey', TOKENLONGKEY);` && |\n| &&
             `          token.data('range', null);` && |\n| &&
             `          if (TOKENTEXT) token.setText(TOKENTEXT);` && |\n| &&
             `        }` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        _logError('SmartMultiInputExt.setRangeData failed', e);` && |\n| &&
             `      }` && |\n| &&
             `    },` && |\n| &&
             `    renderer() {},` && |\n| &&
             `    setControl() {` && |\n| &&
             `      const input = z2ui5.oView?.byId(this.getProperty('multiInputId'));` && |\n| &&
             `      if (!input || this.getProperty('checkInit')) return;` && |\n| &&
             `      this.setProperty('checkInit', true);` && |\n| &&
             `      try {` && |\n| &&
             `        input.attachTokenUpdate(this.onTokenUpdate.bind(this));` && |\n| &&
             `        input.attachInnerControlsCreated(this.onInnerControlsCreated.bind(this));` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        _logError(``SmartMultiInputExt.setControl: setup failed``, e);` && |\n| &&
             `      }` && |\n| &&
             `    },` && |\n| &&
             `    inputInitialized() {` && |\n| &&
             `      return new Promise((resolve) => {` && |\n| &&
             `        if (this._bInnerControlsCreated) resolve(this._oInput);` && |\n| &&
             `        else this._oPendingInnerControlsCreated = resolve;` && |\n| &&
             `      });` && |\n| &&
             `    },` && |\n| &&
             `    onInnerControlsCreated(oEvent) {` && |\n| &&
             `      this._oInput = oEvent.getSource();` && |\n| &&
             `      this._oPendingInnerControlsCreated?.(this._oInput);` && |\n| &&
             `      this._oPendingInnerControlsCreated = null;` && |\n| &&
             `      this._bInnerControlsCreated = true;` && |\n| &&
             `    },` && |\n| &&
             `  });` && |\n| &&
             `});` && |\n| &&
             `` && |\n| &&
             `sap.ui.define(` && |\n| &&
             `  'z2ui5/CameraPicture',` && |\n| &&
             `  ['sap/ui/core/Control', 'sap/m/Dialog', 'sap/m/Button', 'sap/ui/core/HTML'],` && |\n| &&
             `  (Control, Dialog, Button, HTML) => {` && |\n| &&
             `    'use strict';` && |\n| &&
             `    const _CTX_2D_OPTS = { willReadFrequently: true };` && |\n| &&
             `    const _THUMB_W = 300;` && |\n| &&
             `    return Control.extend('z2ui5.CameraPicture', {` && |\n| &&
             `      metadata: {` && |\n| &&
             `        properties: {` && |\n| &&
             `          id: { type: 'string' },` && |\n| &&
             `          value: { type: 'string' },` && |\n| &&
             `          thumbnail: { type: 'string' },` && |\n| &&
             `          press: { type: 'string' },` && |\n| &&
             `          width: { type: 'string', defaultValue: '200' },` && |\n| &&
             `          height: { type: 'string', defaultValue: '200' },` && |\n| &&
             `          autoplay: { type: 'boolean', defaultValue: true },` && |\n| &&
             `          facingMode: { type: 'string' },` && |\n| &&
             `          deviceId: { type: 'string' },` && |\n| &&
             `        },` && |\n| &&
             `        events: {` && |\n| &&
             `          OnPhoto: {` && |\n| &&
             `            allowPreventDefault: true,` && |\n| &&
             `            parameters: {` && |\n| &&
             `              photo: {` && |\n| &&
             `                type: 'string',` && |\n| &&
             `              },` && |\n| &&
             `            },` && |\n| &&
             `          },` && |\n| &&
             `        },` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      capture() {` && |\n| &&
             `        const video = document.getElementById('zvideo');` && |\n| &&
             `        const canvas = document.getElementById('zcanvas');` && |\n| &&
             `        if (!video || !canvas) return;` && |\n| &&
             `        const { videoWidth, videoHeight } = video;` && |\n| &&
             `        Object.assign(canvas, { width: videoWidth, height: videoHeight });` && |\n| &&
             `        const ctx = canvas.getContext('2d', _CTX_2D_OPTS);` && |\n| &&
             `        if (!ctx) return;` && |\n| &&
             `        ctx.drawImage(video, 0, 0, videoWidth, videoHeight);` && |\n| &&
             `        let resultb64;` && |\n| &&
             `        try {` && |\n| &&
             `          resultb64 = canvas.toDataURL('image/jpeg', 0.85);` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          _logError(``CameraPicture: canvas toDataURL failed``, e);` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `        const thumbH = videoWidth ? Math.round((videoHeight * _THUMB_W) / videoWidth) : _THUMB_W;` && |\n| &&
             `        const thumbCanvas = Object.assign(document.createElement('canvas'), { width: _THUMB_W, height: thumbH });` && |\n| &&
             `        thumbCanvas.getContext('2d', _CTX_2D_OPTS)?.drawImage(canvas, 0, 0, _THUMB_W, thumbH);` && |\n| &&
             `        let thumbB64 = '';` && |\n| &&
             `        try {` && |\n| &&
             `          thumbB64 = thumbCanvas.toDataURL('image/jpeg', 0.7);` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          _logError(``CameraPicture: thumb toDataURL failed``, e);` && |\n| &&
             `        }` && |\n| &&
             `        if (this.bIsDestroyed) return;` && |\n| &&
             `        this.setProperty('value', resultb64);` && |\n| &&
             `        this.setProperty('thumbnail', thumbB64);` && |\n| &&
             `        this.fireOnPhoto({ photo: resultb64 });` && |\n| &&
             `        this._stopCamera();` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      _stopCamera() {` && |\n| &&
             `        for (const track of this._stream?.getTracks() ?? []) track.stop();` && |\n| &&
             `        this._stream = null;` && |\n| &&
             `        const video = document.getElementById('zvideo');` && |\n| &&
             `        if (video) video.srcObject = null;` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      onPicture() {` && |\n| &&
             `        if (this._oScanDialog?.isOpen()) return;` && |\n| &&
             `        if (!this._oScanDialog) {` && |\n| &&
             `          this._oScanDialog = new Dialog({` && |\n| &&
             `            title: 'Device Photo Function',` && |\n| &&
             `            contentWidth: '640px',` && |\n| &&
             `            contentHeight: '480px',` && |\n| &&
             `            horizontalScrolling: false,` && |\n| &&
             `            verticalScrolling: false,` && |\n| &&
             `            stretch: true,` && |\n| &&
             `            content: [` && |\n| &&
             `              new HTML({` && |\n| &&
             `                id: ``${this.getId()}PictureContainer``,` && |\n| &&
             `                content: '<video style="width:100%;height:100%;object-fit:contain;" autoplay="true" id="zvideo">',` && |\n| &&
             `              }),` && |\n| &&
             `              new Button({` && |\n| &&
             `                text: 'Capture',` && |\n| &&
             `                press: () => {` && |\n| &&
             `                  this.capture();` && |\n| &&
             `                  this._oScanDialog.close();` && |\n| &&
             `                },` && |\n| &&
             `              }),` && |\n| &&
             `              new HTML({` && |\n| &&
             `                content: '<canvas hidden id="zcanvas" style="overflow:auto"></canvas>',` && |\n| &&
             `              }),` && |\n| &&
             `            ],` && |\n| &&
             `            endButton: new Button({` && |\n| &&
             `              text: 'Cancel',` && |\n| &&
             `              press: () => {` && |\n| &&
             `                this._stopCamera();` && |\n| &&
             `                this._oScanDialog.close();` && |\n| &&
             `              },` && |\n| &&
             `            }),` && |\n| &&
             `          });` && |\n| &&
             `        }` && |\n| &&
             `` && |\n| &&
             `        this._oScanDialog.attachEventOnce('afterOpen', async () => {` && |\n| &&
             `          if (this.bIsDestroyed) return;` && |\n| &&
             `          const video = document.getElementById('zvideo');` && |\n| &&
             `          if (!video) {` && |\n| &&
             `            _logError(``CameraPicture: video element not found after dialog open``);` && |\n| &&
             `            return;` && |\n| &&
             `          }` && |\n| &&
             `          const facingMode = this.getProperty('facingMode');` && |\n| &&
             `          const deviceId = this.getProperty('deviceId');` && |\n| &&
             `          const options = { video: { width: { ideal: 1920 }, height: { ideal: 1080 } } };` && |\n| &&
             `          if (deviceId) options.video.deviceId = deviceId;` && |\n| &&
             `          if (facingMode) options.video.facingMode = { exact: facingMode };` && |\n| &&
             `          try {` && |\n| &&
             `            const stream = await navigator.mediaDevices?.getUserMedia?.(options);` && |\n| &&
             `            if (!stream) return;` && |\n| &&
             `            if (this.bIsDestroyed) {` && |\n| &&
             `              for (const t of stream.getTracks()) t.stop();` && |\n| &&
             `              return;` && |\n| &&
             `            }` && |\n| &&
             `            this._stream = video.srcObject = stream;` && |\n| &&
             `          } catch (error) {` && |\n| &&
             `            _logError(``CameraPicture: getUserMedia failed``, error);` && |\n| &&
             `          }` && |\n| &&
             `        });` && |\n| &&
             `        this._oScanDialog.open();` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      exit() {` && |\n| &&
             `        this._stopCamera();` && |\n| &&
             `        this._oButton?.destroy();` && |\n| &&
             `        this._oScanDialog?.destroy();` && |\n| &&
             `      },` && |\n| &&
             `      renderer(oRm, oControl) {` && |\n| &&
             `        oControl._oButton ??= new Button({` && |\n| &&
             `          icon: 'sap-icon://camera',` && |\n| &&
             `          text: 'Camera',` && |\n| &&
             `          press: oControl.onPicture.bind(oControl),` && |\n| &&
             `        });` && |\n| &&
             `        oRm.renderControl(oControl._oButton);` && |\n| &&
             `      },` && |\n| &&
             `    });` && |\n| &&
             `  },` && |\n| &&
             `);` && |\n| &&
             `` && |\n| &&
             `sap.ui.define(` && |\n| &&
             `  'z2ui5/CameraSelector',` && |\n| &&
             `  ['sap/m/ComboBox', 'sap/ui/core/Item', 'sap/m/ComboBoxRenderer'],` && |\n| &&
             `  (ComboBox, Item, ComboBoxRenderer) => {` && |\n| &&
             `    'use strict';` && |\n| &&
             `    return ComboBox.extend('z2ui5.CameraSelector', {` && |\n| &&
             `      async init() {` && |\n| &&
             `        ComboBox.prototype.init.call(this);` && |\n| &&
             `        try {` && |\n| &&
             `          const devices = await navigator.mediaDevices?.enumerateDevices();` && |\n| &&
             `          if (!devices) return;` && |\n| &&
             `          for (const device of devices) {` && |\n| &&
             `            if (device.kind === 'videoinput' && !this.bIsDestroyed)` && |\n| &&
             `              this.addItem(new Item({ key: device.deviceId, text: device.label }));` && |\n| &&
             `          }` && |\n| &&
             `        } catch (err) {` && |\n| &&
             `          _logError(``CameraDeviceList: enumerateDevices failed``, err);` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      renderer: ComboBoxRenderer,` && |\n| &&
             `    });` && |\n| &&
             `  },` && |\n| &&
             `);` && |\n| &&
             `` && |\n| &&
             `sap.ui.define('z2ui5/UITableExt', ['sap/ui/core/Control'], (Control) => {` && |\n| &&
             `  'use strict';` && |\n| &&
             `` && |\n| &&
             `  const opSymbols = { EQ: '', NE: '!', LT: '<', LE: '<=', GT: '>', GE: '>=' };` && |\n| &&
             `  const filterDisplayFns = {` && |\n| &&
             `    Contains: (v) => ``*${v ?? ''}*``,` && |\n| &&
             `    StartsWith: (v) => ``^${v ?? ''}``,` && |\n| &&
             `    EndsWith: (v) => ``${v ?? ''}$``,` && |\n| &&
             `  };` && |\n| &&
             `` && |\n| &&
             `  return Control.extend('z2ui5.UITableExt', {` && |\n| &&
             `    metadata: {` && |\n| &&
             `      properties: {` && |\n| &&
             `        tableId: {` && |\n| &&
             `          type: 'string',` && |\n| &&
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
             `      (z2ui5.onBeforeRoundtrip ??= []).push(this._beforeBound);` && |\n| &&
             `      (z2ui5.onAfterRoundtrip ??= []).push(this._afterBound);` && |\n| &&
             `    },` && |\n| &&
             `` && |\n| &&
             `    exit() {` && |\n| &&
             `      z2ui5.onBeforeRoundtrip = (z2ui5.onBeforeRoundtrip ?? []).filter((fn) => fn !== this._beforeBound);` && |\n| &&
             `      z2ui5.onAfterRoundtrip = (z2ui5.onAfterRoundtrip ?? []).filter((fn) => fn !== this._afterBound);` && |\n| &&
             `    },` && |\n| &&
             `` && |\n| &&
             `    _getTable() {` && |\n| &&
             `      return z2ui5.oView?.byId(this.getProperty('tableId'));` && |\n| &&
             `    },` && |\n| &&
             `` && |\n| &&
             `    readFilter() {` && |\n| &&
             `      try {` && |\n| &&
             `        this.aFilters = this._getTable()?.getBinding()?.aFilters;` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        _logError(``UITableExt.readFilter failed``, e);` && |\n| &&
             `      }` && |\n| &&
             `    },` && |\n| &&
             |\n|.
    result = result &&
             `` && |\n| &&
             `    _applyWhenRendered(oTable, fn) {` && |\n| &&
             `      if (oTable.getDomRef()) {` && |\n| &&
             `        fn();` && |\n| &&
             `        return;` && |\n| &&
             `      }` && |\n| &&
             `      const delegate = {` && |\n| &&
             `        onAfterRendering: () => {` && |\n| &&
             `          oTable.removeEventDelegate(delegate);` && |\n| &&
             `          if (!this.bIsDestroyed) fn();` && |\n| &&
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
             `        const sProperty = oFilter.sPath || oFilter.aFilters?.[0]?.sPath;` && |\n| &&
             `        if (!sProperty) continue;` && |\n| &&
             `` && |\n| &&
             `        const operator = oFilter.sOperator;` && |\n| &&
             `        const vValue = oFilter.oValue1 ?? oFilter.oValue2 ?? oFilter.aFilters?.[0]?.oValue1;` && |\n| &&
             `        const displayFn =` && |\n| &&
             `          operator === 'BT'` && |\n| &&
             `            ? (v) => ``${v ?? ''}...${oFilter.oValue2 ?? ''}``` && |\n| &&
             `            : (filterDisplayFns[operator] ?? ((v) => ``${opSymbols[operator] || ''}${v ?? ''}``));` && |\n| &&
             `        const display = displayFn(vValue);` && |\n| &&
             `` && |\n| &&
             `        for (const oCol of columns) {` && |\n| &&
             `          if (oCol.getFilterProperty?.() === sProperty) {` && |\n| &&
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
             `      this._applyToTable((oTable) => this._applyFilters(oTable, this.aFilters), ``UITableExt.setFilter failed``);` && |\n| &&
             `    },` && |\n| &&
             `` && |\n| &&
             `    readSort() {` && |\n| &&
             `      try {` && |\n| &&
             `        this.aSorters = this._getTable()?.getBinding()?.aSorters;` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        _logError(``UITableExt.readSort failed``, e);` && |\n| &&
             `      }` && |\n| &&
             `    },` && |\n| &&
             `` && |\n| &&
             `    _applySorters(oTable, aSorters) {` && |\n| &&
             `      if (!aSorters) return;` && |\n| &&
             `      const binding = oTable.getBinding();` && |\n| &&
             `      if (!binding) return;` && |\n| &&
             `      binding.sort(aSorters);` && |\n| &&
             `      const columns = oTable.getColumns();` && |\n| &&
             `      for (const [idx, srt] of aSorters.entries()) {` && |\n| &&
             `        for (const oCol of columns) {` && |\n| &&
             `          if (oCol.getSortProperty?.() === srt.sPath) {` && |\n| &&
             `            oCol.setSorted(true);` && |\n| &&
             `            oCol.setSortOrder(srt.bDescending ? 'Descending' : 'Ascending');` && |\n| &&
             `            oCol.setSortIndex?.(idx);` && |\n| &&
             `          }` && |\n| &&
             `        }` && |\n| &&
             `      }` && |\n| &&
             `    },` && |\n| &&
             `` && |\n| &&
             `    setSort() {` && |\n| &&
             `      this._applyToTable((oTable) => this._applySorters(oTable, this.aSorters), ``UITableExt.setSort failed``);` && |\n| &&
             `    },` && |\n| &&
             `    renderer() {},` && |\n| &&
             `  });` && |\n| &&
             `});` && |\n| &&
             `` && |\n| &&
             `sap.ui.define('z2ui5/Util', [], () => {` && |\n| &&
             `  'use strict';` && |\n| &&
             `  const parseDmy = (d) => [+d.slice(0, 4), +d.slice(4, 6) - 1, +d.slice(6, 8)];` && |\n| &&
             `  return {` && |\n| &&
             `    DateCreateObject: (s) => new Date(s),` && |\n| &&
             `    DateAbapDateToDateObject: (d) => new Date(...parseDmy(d)),` && |\n| &&
             `    DateAbapDateTimeToDateObject: (d, t = '000000') =>` && |\n| &&
             `      new Date(...parseDmy(d), +t.slice(0, 2), +t.slice(2, 4), +t.slice(4, 6)),` && |\n| &&
             `  };` && |\n| &&
             `});` && |\n| &&
             `sap.ui.require(['z2ui5/Util'], (Util) => (z2ui5.Util = Util));` && |\n| &&
             `` && |\n| &&
             `sap.ui.define('z2ui5/Favicon', ['sap/ui/core/Control'], (Control) => {` && |\n| &&
             `  'use strict';` && |\n| &&
             `  return Control.extend('z2ui5.Favicon', {` && |\n| &&
             `    metadata: {` && |\n| &&
             `      properties: {` && |\n| &&
             `        favicon: {` && |\n| &&
             `          type: 'string',` && |\n| &&
             `        },` && |\n| &&
             `      },` && |\n| &&
             `    },` && |\n| &&
             `    setFavicon(val) {` && |\n| &&
             `      this.setProperty('favicon', val);` && |\n| &&
             `      const existing = document.head.querySelector('link[rel="shortcut icon"]');` && |\n| &&
             `      if (existing) {` && |\n| &&
             `        existing.href = val;` && |\n| &&
             `      } else {` && |\n| &&
             `        document.head.appendChild(Object.assign(document.createElement('link'), { rel: 'shortcut icon', href: val }));` && |\n| &&
             `      }` && |\n| &&
             `    },` && |\n| &&
             `    renderer() {},` && |\n| &&
             `  });` && |\n| &&
             `});` && |\n| &&
             `` && |\n| &&
             `sap.ui.define('z2ui5/Dirty', ['sap/ui/core/Control'], (Control) => {` && |\n| &&
             `  'use strict';` && |\n| &&
             `  return Control.extend('z2ui5.Dirty', {` && |\n| &&
             `    metadata: {` && |\n| &&
             `      properties: {` && |\n| &&
             `        isDirty: {` && |\n| &&
             `          type: 'boolean',` && |\n| &&
             `          defaultValue: false,` && |\n| &&
             `        },` && |\n| &&
             `      },` && |\n| &&
             `    },` && |\n| &&
             `    setIsDirty(val) {` && |\n| &&
             `      this.setProperty('isDirty', val);` && |\n| &&
             `      const fallback = () => {` && |\n| &&
             `        window.onbeforeunload = val` && |\n| &&
             `          ? (e) => {` && |\n| &&
             `              e.preventDefault();` && |\n| &&
             `              e.returnValue = '';` && |\n| &&
             `            }` && |\n| &&
             `          : null;` && |\n| &&
             `      };` && |\n| &&
             `` && |\n| &&
             `      // use FLP dirty flag (SAPUI5 only) when in Launchpad, else fall back to browser unload` && |\n| &&
             `      sap.ui.require(` && |\n| &&
             `        ['sap/ushell/Container'],` && |\n| &&
             `        (Container) => {` && |\n| &&
             `          if (this.bIsDestroyed) return;` && |\n| &&
             `          try {` && |\n| &&
             `            if (Container && z2ui5.oLaunchpadService) Container.setDirtyFlag(val);` && |\n| &&
             `            else fallback();` && |\n| &&
             `          } catch (e) {` && |\n| &&
             `            _logError(``Dirty.setIsDirty: setDirtyFlag failed``, e);` && |\n| &&
             `            fallback();` && |\n| &&
             `          }` && |\n| &&
             `        },` && |\n| &&
             `        fallback,` && |\n| &&
             `      );` && |\n| &&
             `    },` && |\n| &&
             `    exit() {` && |\n| &&
             `      window.onbeforeunload = null;` && |\n| &&
             `    },` && |\n| &&
             `    renderer() {},` && |\n| &&
             `  });` && |\n| &&
             `});` && |\n| &&
             `` && |\n| &&
              ``.

  ENDMETHOD.

ENDCLASS.
