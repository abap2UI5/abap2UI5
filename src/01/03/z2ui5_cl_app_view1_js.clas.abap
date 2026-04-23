CLASS z2ui5_cl_app_view1_js DEFINITION
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


CLASS z2ui5_cl_app_view1_js IMPLEMENTATION.

  METHOD get.

    result = `sap.ui.define(` && |\n| &&
             `  [` && |\n| &&
             `    'sap/ui/core/mvc/Controller',` && |\n| &&
             `    'sap/ui/core/mvc/XMLView',` && |\n| &&
             `    'sap/ui/model/json/JSONModel',` && |\n| &&
             `    'sap/ui/core/BusyIndicator',` && |\n| &&
             `    'sap/m/MessageBox',` && |\n| &&
             `    'sap/m/MessageToast',` && |\n| &&
             `    'sap/ui/core/Fragment',` && |\n| &&
             `    'sap/m/BusyDialog',` && |\n| &&
             `    'sap/ui/VersionInfo',` && |\n| &&
             `    'z2ui5/cc/Server',` && |\n| &&
             `    'sap/ui/model/odata/v2/ODataModel',` && |\n| &&
             `    'sap/m/library',` && |\n| &&
             `    'sap/ui/core/routing/HashChanger',` && |\n| &&
             `    'sap/ui/util/Storage',` && |\n| &&
             `    'sap/ui/core/Element',` && |\n| &&
             `  ],` && |\n| &&
             `  (` && |\n| &&
             `    Controller,` && |\n| &&
             `    XMLView,` && |\n| &&
             `    JSONModel,` && |\n| &&
             `    BusyIndicator,` && |\n| &&
             `    MessageBox,` && |\n| &&
             `    MessageToast,` && |\n| &&
             `    Fragment,` && |\n| &&
             `    mBusyDialog,` && |\n| &&
             `    VersionInfo,` && |\n| &&
             `    Server,` && |\n| &&
             `    ODataModel,` && |\n| &&
             `    mobileLibrary,` && |\n| &&
             `    HashChanger,` && |\n| &&
             `    Storage,` && |\n| &&
             `    Element,` && |\n| &&
             `  ) => {` && |\n| &&
             `    'use strict';` && |\n| &&
             `` && |\n| &&
             `    const runCallbacks = (arr, ...args) => {` && |\n| &&
             `      for (const fn of arr ?? []) {` && |\n| &&
             `        try {` && |\n| &&
             `          fn?.(...args);` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          _logError(``runCallbacks: callback failed``, e);` && |\n| &&
             `        }` && |\n| &&
             `      }` && |\n| &&
             `    };` && |\n| &&
             `` && |\n| &&
             `    const _msgParser = new DOMParser();` && |\n| &&
             `    const _sanitizeEl = document.createElement('div');` && |\n| &&
             `    const parseMs = (val, def) => (val ? +val : def);` && |\n| &&
             `` && |\n| &&
             `    const _SAFE_PROTOCOLS = new Set(['http:', 'https:']);` && |\n| &&
             `    const _logError = (msg, err) =>` && |\n| &&
             `      (z2ui5.errors ??= []).push({` && |\n| &&
             `        message: msg,` && |\n| &&
             `        ...(err !== undefined && { error: err }),` && |\n| &&
             `        ts: new Date().toISOString(),` && |\n| &&
             `      });` && |\n| &&
             `` && |\n| &&
             `    const isValidRedirectURL = (url) => {` && |\n| &&
             `      if (!url) return false;` && |\n| &&
             `      try {` && |\n| &&
             `        const { origin, protocol } = new URL(url, window.location.origin);` && |\n| &&
             `        if (origin !== window.location.origin) {` && |\n| &&
             `          _logError(``Security: Blocked redirect to different origin: ${url}``);` && |\n| &&
             `          return false;` && |\n| &&
             `        }` && |\n| &&
             `        if (!_SAFE_PROTOCOLS.has(protocol)) {` && |\n| &&
             `          _logError(``Security: Blocked redirect with invalid protocol: ${protocol}``);` && |\n| &&
             `          return false;` && |\n| &&
             `        }` && |\n| &&
             `        return true;` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        _logError(``Security: Invalid URL format: ${url}``, e);` && |\n| &&
             `        return false;` && |\n| &&
             `      }` && |\n| &&
             `    };` && |\n| &&
             `` && |\n| &&
             `    const copyToClipboard = (textToCopy) => {` && |\n| &&
             `      if (!navigator.clipboard?.writeText) {` && |\n| &&
             `        _logError(``Clipboard: writeText API not available``);` && |\n| &&
             `        return;` && |\n| &&
             `      }` && |\n| &&
             `      navigator.clipboard.writeText(textToCopy).catch((err) => _logError(``Clipboard: writeText failed``, err));` && |\n| &&
             `    };` && |\n| &&
             `` && |\n| &&
             `    const sanitizeMessageDetails = (html) => {` && |\n| &&
             `      const doc = _msgParser.parseFromString(html, 'text/html');` && |\n| &&
             `      const items = [...doc.querySelectorAll('li')];` && |\n| &&
             `      if (items.length) {` && |\n| &&
             `        return ``<ul>${items` && |\n| &&
             `          .map((li) => {` && |\n| &&
             `            _sanitizeEl.textContent = li.textContent;` && |\n| &&
             `            return ``<li>${_sanitizeEl.innerHTML}</li>``;` && |\n| &&
             `          })` && |\n| &&
             `          .join('')}</ul>``;` && |\n| &&
             `      }` && |\n| &&
             `      _sanitizeEl.textContent = doc.body.textContent;` && |\n| &&
             `      return _sanitizeEl.innerHTML;` && |\n| &&
             `    };` && |\n| &&
             `` && |\n| &&
             `    const withCrossAppNavigator = (callback) => {` && |\n| &&
             `      const nav = z2ui5.oLaunchpad?.CrossAppNavigator;` && |\n| &&
             `      if (!nav) {` && |\n| &&
             `        _logError(``CrossAppNav: not running inside Launchpad``);` && |\n| &&
             `        return;` && |\n| &&
             `      }` && |\n| &&
             `      try {` && |\n| &&
             `        callback(nav);` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        _logError(``CrossAppNav: callback failed``, e);` && |\n| &&
             `      }` && |\n| &&
             `    };` && |\n| &&
             `` && |\n| &&
             `    const navigateContainer = (lookup, args) => {` && |\n| &&
             `      try {` && |\n| &&
             `        lookup(args[1])?.to(lookup(args[2]));` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        _logError(``navigateContainer: navigation failed``, e);` && |\n| &&
             `      }` && |\n| &&
             `    };` && |\n| &&
             `` && |\n| &&
             `    const _hashChanger = HashChanger.getInstance();` && |\n| &&
             `    const _URLHelper = mobileLibrary.URLHelper;` && |\n| &&
             `` && |\n| &&
             `    const navContainerLookups = {` && |\n| &&
             `      NAV_CONTAINER_TO: (id) => z2ui5.oView?.byId(id),` && |\n| &&
             `      NEST_NAV_CONTAINER_TO: (id) => z2ui5.oViewNest?.byId(id),` && |\n| &&
             `      NEST2_NAV_CONTAINER_TO: (id) => z2ui5.oViewNest2?.byId(id),` && |\n| &&
             `      POPUP_NAV_CONTAINER_TO: (id) => Fragment.byId('popupId', id),` && |\n| &&
             `      POPOVER_NAV_CONTAINER_TO: (id) => Fragment.byId('popoverId', id),` && |\n| &&
             `    };` && |\n| &&
             `` && |\n| &&
             `    const viewLookups = {` && |\n| &&
             `      MAIN: () => z2ui5.oView,` && |\n| &&
             `      NEST: () => z2ui5.oViewNest,` && |\n| &&
             `      NEST2: () => z2ui5.oViewNest2,` && |\n| &&
             `      POPUP: () => z2ui5.oViewPopup,` && |\n| &&
             `      POPOVER: () => z2ui5.oViewPopover,` && |\n| &&
             `    };` && |\n| &&
             `` && |\n| &&
             `    return Controller.extend('z2ui5.controller.View1', {` && |\n| &&
             `      _trackChanges(oModel) {` && |\n| &&
             `        oModel.attachPropertyChange((e) => {` && |\n| &&
             `          const { path: raw, context: c } = e.getParameters();` && |\n| &&
             `          if (!raw) return;` && |\n| &&
             `          const p = c && !raw.startsWith('/') ? ``${c.getPath()}/${raw}`` : raw;` && |\n| &&
             `          if (p.startsWith('/XX/')) (z2ui5.xxChangedPaths ??= new Set()).add(p);` && |\n| &&
             `        });` && |\n| &&
             `        return oModel;` && |\n| &&
             `      },` && |\n| &&
             `      onInit() {` && |\n| &&
             `        z2ui5.oRouter.attachRouteMatched(() => {` && |\n| &&
             `          z2ui5.checkInit = true;` && |\n| &&
             `          Server.Roundtrip();` && |\n| &&
             `        });` && |\n| &&
             `      },` && |\n| &&
             `      onAfterRendering() {` && |\n| &&
             `        if (z2ui5.oResponse) this._processAfterRendering();` && |\n| &&
             `      },` && |\n| &&
             `      async _processAfterRendering() {` && |\n| &&
             `        try {` && |\n| &&
             `          const { PARAMS, ID } = z2ui5.oResponse;` && |\n| &&
             `          if (!PARAMS) return;` && |\n| &&
             `          const { S_POPUP, S_VIEW_NEST, S_VIEW_NEST2, S_POPOVER, SET_APP_STATE_ACTIVE, SET_PUSH_STATE, SET_NAV_BACK } =` && |\n| &&
             `            PARAMS;` && |\n| &&
             `          if (S_POPUP?.CHECK_DESTROY) this.PopupDestroy();` && |\n| &&
             `          if (S_POPOVER?.CHECK_DESTROY) this.PopoverDestroy();` && |\n| &&
             `          if (S_POPUP?.XML) {` && |\n| &&
             `            this.PopupDestroy();` && |\n| &&
             `            await this.displayFragment(S_POPUP.XML, 'oViewPopup');` && |\n| &&
             `          }` && |\n| &&
             `          if (!z2ui5.checkNestAfter && S_VIEW_NEST?.XML) {` && |\n| &&
             `            this.NestViewDestroy();` && |\n| &&
             `            await this.displayNestedView(S_VIEW_NEST.XML, 'oViewNest', 'S_VIEW_NEST', z2ui5.oControllerNest);` && |\n| &&
             `            z2ui5.checkNestAfter = true;` && |\n| &&
             `          }` && |\n| &&
             `          if (!z2ui5.checkNestAfter2 && S_VIEW_NEST2?.XML) {` && |\n| &&
             `            this.NestViewDestroy2();` && |\n| &&
             `            await this.displayNestedView(S_VIEW_NEST2.XML, 'oViewNest2', 'S_VIEW_NEST2', z2ui5.oControllerNest2);` && |\n| &&
             `            z2ui5.checkNestAfter2 = true;` && |\n| &&
             `          }` && |\n| &&
             `          if (S_POPOVER?.XML) await this.displayPopover(S_POPOVER.XML, 'oViewPopover', S_POPOVER.OPEN_BY_ID);` && |\n| &&
             `` && |\n| &&
             `          const oView = z2ui5.oView;` && |\n| &&
             `          const oState = oView` && |\n| &&
             `            ? { view: oView.mProperties.viewContent, model: oView.getModel()?.getData(), response: z2ui5.oResponse }` && |\n| &&
             `            : {};` && |\n| &&
             `          try {` && |\n| &&
             `            if (SET_PUSH_STATE) {` && |\n| &&
             `              const hash = _hashChanger.getHash() || '#';` && |\n| &&
             `              history.pushState(` && |\n| &&
             `                oState,` && |\n| &&
             `                '',` && |\n| &&
             `                ``${window.location.pathname}${window.location.search}${hash}${SET_PUSH_STATE}``,` && |\n| &&
             `              );` && |\n| &&
             `            } else {` && |\n| &&
             `              history.replaceState(oState, '', window.location.href);` && |\n| &&
             `            }` && |\n| &&
             `            _hashChanger.replaceHash(SET_APP_STATE_ACTIVE ? ``z2ui5-xapp-state=${ID ?? ''}`` : '');` && |\n| &&
             `          } catch (e) {` && |\n| &&
             `            _logError(``_processAfterRendering: history update failed``, e);` && |\n| &&
             `          }` && |\n| &&
             `          if (SET_NAV_BACK) history.back();` && |\n| &&
             `` && |\n| &&
             `          runCallbacks(z2ui5.onAfterRendering);` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          _logError(``_processAfterRendering: unexpected error``, e);` && |\n| &&
             `          MessageBox.error(e.toLocaleString(), {` && |\n| &&
             `            title: 'Unexpected Error Occurred - App Terminated',` && |\n| &&
             `            actions: [],` && |\n| &&
             `            onClose: () => new mBusyDialog({ text: 'Please Restart the App' }).open(),` && |\n| &&
             `          });` && |\n| &&
             `        } finally {` && |\n| &&
             `          BusyIndicator.hide();` && |\n| &&
             `          z2ui5.isBusy = false;` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `      _buildDeltaFromPaths(paths, xx) {` && |\n| &&
             `        const delta = {};` && |\n| &&
             `        for (const path of paths) {` && |\n| &&
             `          const [attr, rowIdx, field] = path.slice(4).split('/');` && |\n| &&
             `          if (field !== undefined && rowIdx !== '' && !isNaN(rowIdx)) {` && |\n| &&
             `            if (!delta[attr]?.__delta) delta[attr] = { __delta: {} };` && |\n| &&
             `            const attrDelta = delta[attr].__delta;` && |\n| &&
             `            attrDelta[rowIdx] ??= {};` && |\n| &&
             `            attrDelta[rowIdx][field] = xx[attr]?.[+rowIdx]?.[field];` && |\n| &&
             `          } else {` && |\n| &&
             `            delta[attr] = xx[attr];` && |\n| &&
             `          }` && |\n| &&
             `        }` && |\n| &&
             `        return delta;` && |\n| &&
             `      },` && |\n| &&
             `      _createViewModel() {` && |\n| &&
             `        return this._trackChanges(new JSONModel(z2ui5.oResponse?.OVIEWMODEL));` && |\n| &&
             `      },` && |\n| &&
             `      async displayFragment(xml, viewProp) {` && |\n| &&
             `        const oModel = this._createViewModel();` && |\n| &&
             `        const oFragment = await Fragment.load({` && |\n| &&
             `          definition: xml,` && |\n| &&
             `          controller: z2ui5.oControllerPopup,` && |\n| &&
             `          id: 'popupId',` && |\n| &&
             `        });` && |\n| &&
             `        if (!z2ui5.oApp || z2ui5.oApp.isDestroyed()) {` && |\n| &&
             `          oFragment.destroy();` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `        oFragment.setModel(oModel);` && |\n| &&
             `        oFragment.Fragment = Fragment;` && |\n| &&
             `        z2ui5[viewProp] = oFragment;` && |\n| &&
             `        oFragment.open();` && |\n| &&
             `      },` && |\n| &&
             `      async displayPopover(xml, viewProp, openById) {` && |\n| &&
             `        try {` && |\n| &&
             `          const oModel = this._createViewModel();` && |\n| &&
             `          const oFragment = await Fragment.load({` && |\n| &&
             `            definition: xml,` && |\n| &&
             `            controller: z2ui5.oControllerPopover,` && |\n| &&
             `            id: 'popoverId',` && |\n| &&
             `          });` && |\n| &&
             `          if (!z2ui5.oApp || z2ui5.oApp.isDestroyed()) {` && |\n| &&
             `            oFragment.destroy();` && |\n| &&
             `            return;` && |\n| &&
             `          }` && |\n| &&
             `          oFragment.setModel(oModel);` && |\n| &&
             `          oFragment.Fragment = Fragment;` && |\n| &&
             `          z2ui5[viewProp] = oFragment;` && |\n| &&
             `          const oControl =` && |\n| &&
             `            z2ui5.oView?.byId(openById) ||` && |\n| &&
             `            z2ui5.oViewPopup?.Fragment.byId('popupId', openById) ||` && |\n| &&
             `            z2ui5.oViewNest?.byId(openById) ||` && |\n| &&
             `            z2ui5.oViewNest2?.byId(openById) ||` && |\n| &&
             `            (Element.getElementById?.(openById) ?? sap.ui.getCore?.()?.byId?.(openById));` && |\n| &&
             `          if (!oControl) {` && |\n| &&
             `            _logError(``displayPopover: openBy control '${openById}' not found``);` && |\n| &&
             `            return;` && |\n| &&
             `          }` && |\n| &&
             `          oFragment.openBy(oControl);` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          _logError(``displayPopover: failed``, e);` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `      async displayNestedView(xml, viewProp, viewNestId, controller) {` && |\n| &&
             `        const oModel = this._createViewModel();` && |\n| &&
             `        const oView = await XMLView.create({` && |\n| &&
             `          definition: xml,` && |\n| &&
             `          controller,` && |\n| &&
             `          preprocessors: { xml: { models: { template: oModel } } },` && |\n| &&
             `        });` && |\n| &&
             `        if (!z2ui5.oApp || z2ui5.oApp.isDestroyed()) {` && |\n| &&
             `          oView.destroy();` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `        oView.setModel(oModel);` && |\n| &&
             `        const nestParams = z2ui5.oResponse?.PARAMS?.[viewNestId];` && |\n| &&
             `        if (!nestParams) {` && |\n| &&
             `          _logError(``displayNestedView: missing PARAMS.${viewNestId}``);` && |\n| &&
             `          oView.destroy();` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `        const { ID, METHOD_DESTROY, METHOD_INSERT } = nestParams;` && |\n| &&
             `        const oParent = z2ui5.oView?.byId(ID);` && |\n| &&
             `        if (!oParent) {` && |\n| &&
             `          _logError(``displayNestedView: parent control '${ID}' not found, nested view discarded``);` && |\n| &&
             `          oView.destroy();` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `        try {` && |\n| &&
             `          oParent[METHOD_DESTROY]();` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          _logError(``displayNestedView: parent destroy method failed``, e);` && |\n| &&
             `        }` && |\n| &&
             `        try {` && |\n| &&
             `          oParent[METHOD_INSERT](oView);` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          _logError(``displayNestedView: parent insert method failed``, e);` && |\n| &&
             `          oView.destroy();` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `        z2ui5[viewProp] = oView;` && |\n| &&
             `      },` && |\n| &&
             `      _destroyView(prop, tryClose) {` && |\n| &&
             `        const view = z2ui5[prop];` && |\n| &&
             `        if (!view) return;` && |\n| &&
             `        if (tryClose) {` && |\n| &&
             `          try {` && |\n| &&
             `            view.close?.();` && |\n| &&
             `          } catch (e) {` && |\n| &&
             `            _logError(``_destroyView: view.close() failed for ${prop}``, e);` && |\n| &&
             `          }` && |\n| &&
             `        }` && |\n| &&
             `        try {` && |\n| &&
             `          view.destroy();` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          _logError(``_destroyView: view.destroy() failed for ${prop}``, e);` && |\n| &&
             `        }` && |\n| &&
             `        z2ui5[prop] = null;` && |\n| &&
             `      },` && |\n| &&
             `      PopupDestroy() {` && |\n| &&
             `        this._destroyView('oViewPopup', true);` && |\n| &&
             `      },` && |\n| &&
             `      PopoverDestroy() {` && |\n| &&
             `        this._destroyView('oViewPopover', true);` && |\n| &&
             `      },` && |\n| &&
             `      NestViewDestroy() {` && |\n| &&
             `        this._destroyView('oViewNest');` && |\n| &&
             `      },` && |\n| &&
             `      NestViewDestroy2() {` && |\n| &&
             `        this._destroyView('oViewNest2');` && |\n| &&
             `      },` && |\n| &&
             `      ViewDestroy() {` && |\n| &&
             `        this._destroyView('oView');` && |\n| &&
             `      },` && |\n| &&
             `      eF(...args) {` && |\n| &&
             `        runCallbacks(z2ui5.onBeforeEventFrontend, args);` && |\n| &&
             `` && |\n| &&
             `        const navLookup = navContainerLookups[args[0]];` && |\n| &&
             `        if (navLookup) {` && |\n| &&
             `          navigateContainer(navLookup, args);` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `` && |\n| &&
             `        switch (args[0]) {` && |\n| &&
             `          case 'SET_SIZE_LIMIT': {` && |\n| &&
             `            const target = viewLookups[args[2]]?.();` && |\n| &&
             `            if (target) {` && |\n| &&
             `              const model = target.getModel();` && |\n| &&
             `              if (model) {` && |\n| &&
             `                model.setSizeLimit(+args[1]);` && |\n| &&
             `                model.refresh(true);` && |\n| &&
             `              }` && |\n| &&
             `            }` && |\n| &&
             `            break;` && |\n| &&
             `          }` && |\n| &&
             `          case 'HISTORY_BACK':` && |\n| &&
             `            history.back();` && |\n| &&
             `            break;` && |\n| &&
             `          case 'CLIPBOARD_COPY':` && |\n| &&
             `            copyToClipboard(args[1]);` && |\n| &&
             `            break;` && |\n| &&
             `          case 'CLIPBOARD_APP_STATE':` && |\n| &&
             `            copyToClipboard(``${window.location.href}#/z2ui5-xapp-state=${z2ui5.oResponse?.ID}``);` && |\n| &&
             `            break;` && |\n| &&
             `          case 'SET_ODATA_MODEL': {` && |\n| &&
             `            try {` && |\n| &&
             `              const oModel = new ODataModel({ serviceUrl: args[1], annotationURI: args[3] ?? '' });` && |\n| &&
             `              z2ui5.oView?.setModel(oModel, args[2] || undefined);` && |\n| &&
             `            } catch (e) {` && |\n| &&
             `              _logError(``SET_ODATA_MODEL: failed for '${args[1]}'``, e);` && |\n| &&
             `            }` && |\n| &&
             `            break;` && |\n| &&
             `          }` && |\n| &&
             `          case 'STORE_DATA': {` && |\n| &&
             `            const { TYPE, PREFIX, VALUE, KEY } = args[1];` && |\n| &&
             `            try {` && |\n| &&
             `              const oStorage = new Storage(Storage.Type[TYPE] ?? Storage.Type.session, PREFIX);` && |\n| &&
             `              if (VALUE === '' || VALUE == null) {` && |\n| &&
             `                oStorage.remove(KEY);` && |\n| &&
             `              } else {` && |\n| &&
             `                oStorage.put(KEY, VALUE);` && |\n| &&
             |\n|.
    result = result &&
             `              }` && |\n| &&
             `            } catch (e) {` && |\n| &&
             `              _logError(``STORE_DATA: storage operation failed for key '${KEY}'``, e);` && |\n| &&
             `            }` && |\n| &&
             `            break;` && |\n| &&
             `          }` && |\n| &&
             `          case 'DOWNLOAD_B64_FILE':` && |\n| &&
             `            Object.assign(document.createElement('a'), { href: args[1], download: args[2] }).click();` && |\n| &&
             `            break;` && |\n| &&
             `          case 'CROSS_APP_NAV_TO_PREV_APP':` && |\n| &&
             `            withCrossAppNavigator((nav) => nav.backToPreviousApp());` && |\n| &&
             `            break;` && |\n| &&
             `          case 'CROSS_APP_NAV_TO_EXT':` && |\n| &&
             `            withCrossAppNavigator((nav) => {` && |\n| &&
             `              const hash = nav.hrefForExternal({ target: args[1], params: args[2] }) ?? '';` && |\n| &&
             `              if (args[3] === 'EXT') {` && |\n| &&
             `                _URLHelper.redirect(``${window.location.href.split('#')[0]}${hash}``, true);` && |\n| &&
             `              } else {` && |\n| &&
             `                nav.toExternal({ target: { shellHash: hash } });` && |\n| &&
             `              }` && |\n| &&
             `            });` && |\n| &&
             `            break;` && |\n| &&
             `          case 'LOCATION_RELOAD':` && |\n| &&
             `            if (isValidRedirectURL(args[1])) {` && |\n| &&
             `              window.location.href = args[1];` && |\n| &&
             `            } else {` && |\n| &&
             `              MessageBox.error('Invalid redirect URL. Only relative URLs to the same domain are allowed.');` && |\n| &&
             `            }` && |\n| &&
             `            break;` && |\n| &&
             `          case 'SYSTEM_LOGOUT': {` && |\n| &&
             `            const logoutUrl = args[1] || '/sap/public/bc/icf/logoff';` && |\n| &&
             `            const redirectToLogoff = () => {` && |\n| &&
             `              if (isValidRedirectURL(logoutUrl)) {` && |\n| &&
             `                window.location.href = logoutUrl;` && |\n| &&
             `              } else {` && |\n| &&
             `                MessageBox.error('Invalid logout URL. Only relative URLs to the same domain are allowed.');` && |\n| &&
             `              }` && |\n| &&
             `            };` && |\n| &&
             `            try {` && |\n| &&
             `              if (z2ui5.oLaunchpad?.Container?.logout) {` && |\n| &&
             `                z2ui5.oLaunchpad.Container.logout();` && |\n| &&
             `              } else {` && |\n| &&
             `                redirectToLogoff();` && |\n| &&
             `              }` && |\n| &&
             `            } catch (e) {` && |\n| &&
             `              _logError(``SYSTEM_LOGOUT: ushell logout failed``, e);` && |\n| &&
             `              redirectToLogoff();` && |\n| &&
             `            }` && |\n| &&
             `            break;` && |\n| &&
             `          }` && |\n| &&
             `          case 'OPEN_NEW_TAB':` && |\n| &&
             `            if (isValidRedirectURL(args[1])) {` && |\n| &&
             `              const newWindow = window.open(args[1], '_blank');` && |\n| &&
             `              if (newWindow) newWindow.opener = null;` && |\n| &&
             `            } else {` && |\n| &&
             `              MessageBox.error('Invalid URL. Only relative URLs to the same domain are allowed.');` && |\n| &&
             `            }` && |\n| &&
             `            break;` && |\n| &&
             `          case 'POPUP_CLOSE':` && |\n| &&
             `            this.PopupDestroy();` && |\n| &&
             `            break;` && |\n| &&
             `          case 'POPOVER_CLOSE':` && |\n| &&
             `            this.PopoverDestroy();` && |\n| &&
             `            break;` && |\n| &&
             `          case 'URLHELPER': {` && |\n| &&
             `            const params = args[2];` && |\n| &&
             `            const actions = {` && |\n| &&
             `              REDIRECT: () => _URLHelper.redirect(params.URL, params.NEW_WINDOW),` && |\n| &&
             `              TRIGGER_EMAIL: () =>` && |\n| &&
             `                _URLHelper.triggerEmail(` && |\n| &&
             `                  params.EMAIL,` && |\n| &&
             `                  params.SUBJECT,` && |\n| &&
             `                  params.BODY,` && |\n| &&
             `                  params.CC,` && |\n| &&
             `                  params.BCC,` && |\n| &&
             `                  params.NEW_WINDOW,` && |\n| &&
             `                ),` && |\n| &&
             `              TRIGGER_SMS: () => _URLHelper.triggerSms(params),` && |\n| &&
             `              TRIGGER_TEL: () => _URLHelper.triggerTel(params),` && |\n| &&
             `            };` && |\n| &&
             `            try {` && |\n| &&
             `              actions[args[1]]?.();` && |\n| &&
             `            } catch (e) {` && |\n| &&
             `              _logError(``URLHELPER: '${args[1]}' failed``, e);` && |\n| &&
             `            }` && |\n| &&
             `            break;` && |\n| &&
             `          }` && |\n| &&
             `          case 'IMAGE_EDITOR_POPUP_CLOSE': {` && |\n| &&
             `            let image;` && |\n| &&
             `            try {` && |\n| &&
             `              image = Fragment.byId('popupId', 'imageEditor')?.getImagePngDataURL();` && |\n| &&
             `            } catch (e) {` && |\n| &&
             `              _logError(``IMAGE_EDITOR_POPUP_CLOSE: getImagePngDataURL failed``, e);` && |\n| &&
             `            }` && |\n| &&
             `            this.PopupDestroy();` && |\n| &&
             `            this.eB(['SAVE'], image);` && |\n| &&
             `            break;` && |\n| &&
             `          }` && |\n| &&
             `          case 'Z2UI5':` && |\n| &&
             `            try {` && |\n| &&
             `              z2ui5[args[1]]?.(args.slice(2));` && |\n| &&
             `            } catch (e) {` && |\n| &&
             `              _logError(``Z2UI5: '${args[1]}' failed``, e);` && |\n| &&
             `            }` && |\n| &&
             `            break;` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `      eB(...args) {` && |\n| &&
             `        if (!navigator.onLine) {` && |\n| &&
             `          MessageBox.alert('No internet connection! Please reconnect to the server and try again.');` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `        if (z2ui5.isBusy && !args[0][2]) {` && |\n| &&
             `          const oBusyDialog = new mBusyDialog();` && |\n| &&
             `          oBusyDialog.open();` && |\n| &&
             `          queueMicrotask(() => oBusyDialog.close());` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `        z2ui5.isBusy = true;` && |\n| &&
             `        BusyIndicator.show();` && |\n| &&
             `        z2ui5.oBody = { VIEWNAME: 'MAIN' };` && |\n| &&
             `        let oModel;` && |\n| &&
             `        if (args[0][3] || z2ui5.oController === this) {` && |\n| &&
             `          oModel = z2ui5.oResponse?.PARAMS?.S_VIEW?.SWITCH_DEFAULT_MODEL_PATH` && |\n| &&
             `            ? z2ui5.oView?.getModel('http')` && |\n| &&
             `            : z2ui5.oView?.getModel();` && |\n| &&
             `        } else if (z2ui5.oControllerPopup === this) {` && |\n| &&
             `          oModel = z2ui5.oViewPopup?.getModel();` && |\n| &&
             `        } else if (z2ui5.oControllerPopover === this) {` && |\n| &&
             `          oModel = z2ui5.oViewPopover?.getModel();` && |\n| &&
             `        } else if (z2ui5.oControllerNest === this) {` && |\n| &&
             `          oModel = z2ui5.oViewNest?.getModel();` && |\n| &&
             `          z2ui5.oBody.VIEWNAME = 'NEST';` && |\n| &&
             `        } else if (z2ui5.oControllerNest2 === this) {` && |\n| &&
             `          oModel = z2ui5.oViewNest2?.getModel();` && |\n| &&
             `          z2ui5.oBody.VIEWNAME = 'NEST2';` && |\n| &&
             `        }` && |\n| &&
             `        runCallbacks(z2ui5.onBeforeRoundtrip);` && |\n| &&
             `        if (oModel && z2ui5.xxChangedPaths?.size > 0) {` && |\n| &&
             `          const xx = oModel.getData()?.XX;` && |\n| &&
             `          if (xx) z2ui5.oBody.XX = this._buildDeltaFromPaths(z2ui5.xxChangedPaths, xx);` && |\n| &&
             `        }` && |\n| &&
             `        z2ui5.oBody.ID = z2ui5.oResponse?.ID;` && |\n| &&
             `        z2ui5.oBody.ARGUMENTS = args.map((item, i) =>` && |\n| &&
             `          i > 0 && typeof item === 'object' ? JSON.stringify(item) : item,` && |\n| &&
             `        );` && |\n| &&
             `        z2ui5.oResponseOld = z2ui5.oResponse;` && |\n| &&
             `        Server.Roundtrip();` && |\n| &&
             `        runCallbacks(z2ui5.onAfterRoundtrip);` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      updateModelIfRequired(paramKey, oView) {` && |\n| &&
             `        if (z2ui5.oResponse?.PARAMS?.[paramKey]?.CHECK_UPDATE_MODEL) oView?.setModel(this._createViewModel());` && |\n| &&
             `      },` && |\n| &&
             `      async checkSDKcompatibility(err) {` && |\n| &&
             `        let gav;` && |\n| &&
             `        try {` && |\n| &&
             `          ({ gav } = await VersionInfo.load());` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          _logError('checkSDKcompatibility: VersionInfo.load failed', e);` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `        if (!gav.includes('com.sap.ui5')) {` && |\n| &&
             `          MessageBox.error(``openui5 SDK is loaded, module: ${err?._modules} is not available in openui5``);` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `        MessageBox.error(err.toLocaleString());` && |\n| &&
             `      },` && |\n| &&
             `      showMessage(msgType, params) {` && |\n| &&
             `        if (!params) return;` && |\n| &&
             `        const msg = params[msgType];` && |\n| &&
             `        if (msg?.TEXT === undefined) return;` && |\n| &&
             `        if (msgType === 'S_MSG_TOAST') {` && |\n| &&
             `          MessageToast.show(msg.TEXT, {` && |\n| &&
             `            duration: parseMs(msg.DURATION, 3000),` && |\n| &&
             `            width: msg.WIDTH || '15em',` && |\n| &&
             `            onClose: msg.ONCLOSE ? () => this.eB([msg.ONCLOSE]) : null,` && |\n| &&
             `            autoClose: !!msg.AUTOCLOSE,` && |\n| &&
             `            animationTimingFunction: msg.ANIMATIONTIMINGFUNCTION || 'ease',` && |\n| &&
             `            animationDuration: parseMs(msg.ANIMATIONDURATION, 1000),` && |\n| &&
             `            closeonBrowserNavigation: !!msg.CLOSEONBROWSERNAVIGATION,` && |\n| &&
             `          });` && |\n| &&
             `          if (msg.CLASS)` && |\n| &&
             `            document` && |\n| &&
             `              .querySelector('.sapMMessageToast')` && |\n| &&
             `              ?.classList.add(...msg.CLASS.trim().split(/\s+/).filter(Boolean));` && |\n| &&
             `        } else if (msgType === 'S_MSG_BOX') {` && |\n| &&
             `          const oParams = {` && |\n| &&
             `            styleClass: msg.STYLECLASS || '',` && |\n| &&
             `            title: msg.TITLE || '',` && |\n| &&
             `            onClose: msg.ONCLOSE ? (sAction) => this.eB([msg.ONCLOSE, sAction]) : null,` && |\n| &&
             `            actions: msg.ACTIONS || 'OK',` && |\n| &&
             `            emphasizedAction: msg.EMPHASIZEDACTION || 'OK',` && |\n| &&
             `            initialFocus: msg.INITIALFOCUS || null,` && |\n| &&
             `            textDirection: msg.TEXTDIRECTION || 'Inherit',` && |\n| &&
             `            details: msg.DETAILS ? sanitizeMessageDetails(msg.DETAILS) : '',` && |\n| &&
             `            closeOnNavigation: !!msg.CLOSEONNAVIGATION,` && |\n| &&
             `            ...(msg.ICON && msg.ICON !== 'NONE' && { icon: msg.ICON }),` && |\n| &&
             `          };` && |\n| &&
             `          MessageBox[msg.TYPE]?.(msg.TEXT, oParams);` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `      async displayView(xml, viewModel) {` && |\n| &&
             `        const oViewModel = this._trackChanges(new JSONModel(viewModel));` && |\n| &&
             `        const sView = z2ui5.oResponse?.PARAMS?.S_VIEW;` && |\n| &&
             `        const switchPath = sView?.SWITCH_DEFAULT_MODEL_PATH;` && |\n| &&
             `        const oModel = switchPath` && |\n| &&
             `          ? new ODataModel({` && |\n| &&
             `              serviceUrl: switchPath,` && |\n| &&
             `              annotationURI: sView.SWITCHDEFAULTMODELANNOURI ?? '',` && |\n| &&
             `            })` && |\n| &&
             `          : oViewModel;` && |\n| &&
             `        z2ui5.oView = await XMLView.create({` && |\n| &&
             `          definition: xml,` && |\n| &&
             `          models: oModel,` && |\n| &&
             `          controller: z2ui5.oController,` && |\n| &&
             `          id: 'mainView',` && |\n| &&
             `          preprocessors: { xml: { models: { template: oViewModel } } },` && |\n| &&
             `        });` && |\n| &&
             `        if (!z2ui5.oApp || z2ui5.oApp.isDestroyed()) {` && |\n| &&
             `          z2ui5.oView.destroy();` && |\n| &&
             `          if (switchPath) oModel.destroy();` && |\n| &&
             `          z2ui5.oView = null;` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `        z2ui5.oView.setModel(z2ui5.oDeviceModel, 'device');` && |\n| &&
             `        if (switchPath) z2ui5.oView.setModel(oViewModel, 'http');` && |\n| &&
             `        z2ui5.oApp.removeAllPages();` && |\n| &&
             `        z2ui5.oApp.insertPage(z2ui5.oView);` && |\n| &&
             `      },` && |\n| &&
             `    });` && |\n| &&
             `  },` && |\n| &&
             `);` && |\n| &&
             `` && |\n| &&
              ``.

  ENDMETHOD.

ENDCLASS.
