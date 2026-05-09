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
             `    'z2ui5/cc/Util',` && |\n| &&
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
             `    Util,` && |\n| &&
             `  ) => {` && |\n| &&
             `    'use strict';` && |\n| &&
             `` && |\n| &&
             `    const { logError: _logError, runCallbacks, getViewContent: _getViewContent } = Util;` && |\n| &&
             `` && |\n| &&
             `    const _msgParser = new DOMParser();` && |\n| &&
             `    const _sanitizeEl = document.createElement('div');` && |\n| &&
             `    // ?? semantics: an explicit 0 from the backend should pass through (e.g. duration=0 to disable),` && |\n| &&
             `    // not be replaced by the default` && |\n| &&
             `    const parseMs = (val, def) => {` && |\n| &&
             `      if (val === undefined || val === null || val === '') return def;` && |\n| &&
             `      const n = +val;` && |\n| &&
             `      return Number.isFinite(n) ? n : def;` && |\n| &&
             `    };` && |\n| &&
             `` && |\n| &&
             `    // length of the "/XX/" prefix on two-way binding paths` && |\n| &&
             `    const _XX_PATH_PREFIX_LEN = 4;` && |\n| &&
             `    const _TOAST_DEFAULT_WIDTH = '15em';` && |\n| &&
             `    const _TOAST_DEFAULT_DURATION_MS = 3000;` && |\n| &&
             `    const _TOAST_DEFAULT_ANIM_MS = 1000;` && |\n| &&
             `    // Safety net: if a Dialog.afterClose never fires (stuck), still destroy after this many ms` && |\n| &&
             `    const _DESTROY_SAFETY_NET_MS = 1000;` && |\n| &&
             `` && |\n| &&
             `    // Whitelist of MessageBox functions we accept from the backend — guards against` && |\n| &&
             `    // prototype-pollution (e.g. msg.TYPE === '__proto__') and unintended dispatch.` && |\n| &&
             `    const _MSG_BOX_TYPES = new Set(['error', 'success', 'warning', 'information', 'show', 'alert', 'confirm']);` && |\n| &&
             `` && |\n| &&
             `    const _SAFE_PROTOCOLS = new Set(['http:', 'https:']);` && |\n| &&
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
             `    const _legacyClipboardCopy = (text) => {` && |\n| &&
             `      // Fallback for non-HTTPS contexts and older browsers without navigator.clipboard` && |\n| &&
             `      const ta = document.createElement('textarea');` && |\n| &&
             `      ta.value = text;` && |\n| &&
             `      ta.setAttribute('readonly', '');` && |\n| &&
             `      ta.style.cssText = 'position:fixed;top:-1000px;left:-1000px;opacity:0;';` && |\n| &&
             `      (document.body ?? document.documentElement).appendChild(ta);` && |\n| &&
             `      ta.select();` && |\n| &&
             `      try {` && |\n| &&
             `        // execCommand returns false if the copy was rejected (e.g. user gesture missing)` && |\n| &&
             `        const ok = document.execCommand('copy');` && |\n| &&
             `        if (!ok) _logError(``Clipboard: legacy execCommand returned false``);` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        _logError(``Clipboard: legacy execCommand failed``, e);` && |\n| &&
             `      } finally {` && |\n| &&
             `        ta.remove();` && |\n| &&
             `      }` && |\n| &&
             `    };` && |\n| &&
             `` && |\n| &&
             `    const copyToClipboard = (textToCopy) => {` && |\n| &&
             `      if (navigator.clipboard?.writeText) {` && |\n| &&
             `        navigator.clipboard` && |\n| &&
             `          .writeText(textToCopy)` && |\n| &&
             `          .catch((err) => {` && |\n| &&
             `            _logError(``Clipboard: writeText failed, falling back to execCommand``, err);` && |\n| &&
             `            _legacyClipboardCopy(textToCopy);` && |\n| &&
             `          });` && |\n| &&
             `        return;` && |\n| &&
             `      }` && |\n| &&
             `      _legacyClipboardCopy(textToCopy);` && |\n| &&
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
             `    // URLHelper actions table — module-level so we don't reallocate per call` && |\n| &&
             `    const _URL_HELPER_ACTIONS = {` && |\n| &&
             `      REDIRECT: (params) => _URLHelper.redirect(params.URL, params.NEW_WINDOW),` && |\n| &&
             `      TRIGGER_EMAIL: (params) =>` && |\n| &&
             `        _URLHelper.triggerEmail(params.EMAIL, params.SUBJECT, params.BODY, params.CC, params.BCC, params.NEW_WINDOW),` && |\n| &&
             `      TRIGGER_SMS: (params) => _URLHelper.triggerSms(params),` && |\n| &&
             `      TRIGGER_TEL: (params) => _URLHelper.triggerTel(params),` && |\n| &&
             `    };` && |\n| &&
             `` && |\n| &&
             `    const navContainerLookups = {` && |\n| &&
             `      NAV_CONTAINER_TO: (id) => z2ui5.oView?.byId(id),` && |\n| &&
             `      NEST_NAV_CONTAINER_TO: (id) => z2ui5.oViewNest?.byId(id),` && |\n| &&
             `      NEST2_NAV_CONTAINER_TO: (id) => z2ui5.oViewNest2?.byId(id),` && |\n| &&
             `      POPUP_NAV_CONTAINER_TO: (id) => Fragment.byId('popupId', id),` && |\n| &&
             `      POPOVER_NAV_CONTAINER_TO: (id) => Fragment.byId('popoverId', id),` && |\n| &&
             `    };` && |\n| &&
             `` && |\n| &&
             `    // Look up a control across all active views by ID (used by openBy and the Z2UI5 frontend action).` && |\n| &&
             `    // Uses the imported Fragment module directly instead of the per-instance Fragment property` && |\n| &&
             `    // pinned by displayFragment/displayPopover.` && |\n| &&
             `    const _findControlById = (id) =>` && |\n| &&
             `      z2ui5.oView?.byId(id) ||` && |\n| &&
             `      (z2ui5.oViewPopup && Fragment.byId('popupId', id)) ||` && |\n| &&
             `      (z2ui5.oViewPopover && Fragment.byId('popoverId', id)) ||` && |\n| &&
             `      z2ui5.oViewNest?.byId(id) ||` && |\n| &&
             `      z2ui5.oViewNest2?.byId(id) ||` && |\n| &&
             `      Element.getElementById?.(id) ||` && |\n| &&
             `      // sap.ui.getCore() is removed in ui5-legacy-free; chain with optional access for compatibility` && |\n| &&
             `      sap.ui.getCore?.()?.byId?.(id);` && |\n| &&
             `` && |\n| &&
             `    const viewLookups = {` && |\n| &&
             `      MAIN: () => z2ui5.oView,` && |\n| &&
             `      NEST: () => z2ui5.oViewNest,` && |\n| &&
             `      NEST2: () => z2ui5.oViewNest2,` && |\n| &&
             `      POPUP: () => z2ui5.oViewPopup,` && |\n| &&
             `      POPOVER: () => z2ui5.oViewPopover,` && |\n| &&
             `    };` && |\n| &&
             `` && |\n| &&
             `    const paramToViewKey = {` && |\n| &&
             `      S_VIEW: 'MAIN',` && |\n| &&
             `      S_VIEW_NEST: 'NEST',` && |\n| &&
             `      S_VIEW_NEST2: 'NEST2',` && |\n| &&
             `      S_POPUP: 'POPUP',` && |\n| &&
             `      S_POPOVER: 'POPOVER',` && |\n| &&
             `    };` && |\n| &&
             `` && |\n| &&
             `    const applyStoredSizeLimit = (viewKey, oModel) => {` && |\n| &&
             `      const limit = z2ui5.viewSizeLimits?.[viewKey];` && |\n| &&
             `      if (limit !== undefined && oModel) oModel.setSizeLimit(limit);` && |\n| &&
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
             `          // CHECK_DESTROY without a follow-up XML closes the popup; if XML is also present` && |\n| &&
             `          // the displayFragment branch destroys the existing popup before creating the new one,` && |\n| &&
             `          // so a separate CHECK_DESTROY here would be redundant double-destroy.` && |\n| &&
             `          if (S_POPUP?.CHECK_DESTROY && !S_POPUP?.XML) this.PopupDestroy();` && |\n| &&
             `          if (S_POPOVER?.CHECK_DESTROY && !S_POPOVER?.XML) this.PopoverDestroy();` && |\n| &&
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
             `            ? { view: _getViewContent(oView), model: oView.getModel()?.getData(), response: z2ui5.oResponse }` && |\n| &&
             `            : {};` && |\n| &&
             `          try {` && |\n| &&
             `            if (SET_PUSH_STATE) {` && |\n| &&
             `              const hash = _hashChanger.getHash() || '#';` && |\n| &&
             `              // Avoid emitting ``##`` if SET_PUSH_STATE already starts with a hash` && |\n| &&
             `              const tail = SET_PUSH_STATE.startsWith('#') && hash === '#' ? SET_PUSH_STATE : ``${hash}${SET_PUSH_STATE}``;` && |\n| &&
             `              this._safeHistoryWrite(` && |\n| &&
             `                'pushState',` && |\n| &&
             `                oState,` && |\n| &&
             `                ``${window.location.pathname}${window.location.search}${tail}``,` && |\n| &&
             `              );` && |\n| &&
             `            } else {` && |\n| &&
             `              this._safeHistoryWrite('replaceState', oState, window.location.href);` && |\n| &&
             `            }` && |\n| &&
             `            _hashChanger.replaceHash(SET_APP_STATE_ACTIVE ? ``z2ui5-xapp-state=${ID ?? ''}`` : '');` && |\n| &&
             `          } catch (e) {` && |\n| &&
             `            _logError(``_processAfterRendering: history update failed``, e);` && |\n| &&
             `          }` && |\n| &&
             `          if (SET_NAV_BACK && history.length > 1) history.back();` && |\n| &&
             `` && |\n| &&
             `          runCallbacks(z2ui5.onAfterRendering);` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          _logError(``_processAfterRendering: unexpected error``, e);` && |\n| &&
             `          // i18n: title key "appTerminated.title", body key "appTerminated.body"` && |\n| &&
             `          MessageBox.error(e.message ?? String(e), {` && |\n| &&
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
             `          const [attr, rowIdx, field] = path.slice(_XX_PATH_PREFIX_LEN).split('/');` && |\n| &&
             `          if (field !== undefined && rowIdx !== '' && Number.isFinite(+rowIdx)) {` && |\n| &&
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
             `      // Try a full pushState/replaceState; if the browser rejects the state object` && |\n| &&
             `      // (~640 kB quota in some browsers) progressively shrink the state until it fits,` && |\n| &&
             `      // and finally fall back to a null state if even the view alone is too large.` && |\n| &&
             `      _safeHistoryWrite(method, state, url) {` && |\n| &&
             `        try {` && |\n| &&
             `          history[method](state, '', url);` && |\n| &&
             `          return;` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          _logError(``_safeHistoryWrite: ${method} oversized state — retrying without model``, e);` && |\n| &&
             `        }` && |\n| &&
             `        // First retry: drop the model (typically the largest payload)` && |\n| &&
             `        try {` && |\n| &&
             `          const tier1 = state ? { view: state.view, response: state.response } : {};` && |\n| &&
             `          history[method](tier1, '', url);` && |\n| &&
             `          return;` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          _logError(``_safeHistoryWrite: ${method} still oversized — retrying with view only``, e);` && |\n| &&
             `        }` && |\n| &&
             `        // Second retry: keep only the view XML so popstate can still restore the page` && |\n| &&
             `        try {` && |\n| &&
             `          const tier2 = state ? { view: state.view } : {};` && |\n| &&
             `          history[method](tier2, '', url);` && |\n| &&
             `          return;` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          _logError(``_safeHistoryWrite: ${method} failed even with view-only state``, e);` && |\n| &&
             `        }` && |\n| &&
             `        // Last resort: null state — popstate handler will treat it as a no-op` && |\n| &&
             `        try {` && |\n| &&
             `          history[method](null, '', url);` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          _logError(``_safeHistoryWrite: ${method} failed with null state``, e);` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `      _createViewModel() {` && |\n| &&
             `        return this._trackChanges(new JSONModel(z2ui5.oResponse?.OVIEWMODEL));` && |\n| &&
             `      },` && |\n| &&
             `      async displayFragment(xml, viewProp) {` && |\n| &&
             `        const oModel = this._createViewModel();` && |\n| &&
             `        applyStoredSizeLimit('POPUP', oModel);` && |\n| &&
             `        let oFragment;` && |\n| &&
             `        try {` && |\n| &&
             `          oFragment = await Fragment.load({` && |\n| &&
             `            definition: xml,` && |\n| &&
             `            controller: z2ui5.oControllerPopup,` && |\n| &&
             `            id: 'popupId',` && |\n| &&
             `          });` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          oModel.destroy?.();` && |\n| &&
             `          _logError(``displayFragment: Fragment.load failed``, e);` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `        if (!z2ui5.oApp || z2ui5.oApp.isDestroyed()) {` && |\n| &&
             `          oFragment.destroy();` && |\n| &&
             `          oModel.destroy?.();` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `        oFragment.setModel(oModel);` && |\n| &&
             `        // .Fragment is pinned for legacy app-side lookups; new code should import Fragment directly` && |\n| &&
             `        oFragment.Fragment = Fragment;` && |\n| &&
             `        z2ui5[viewProp] = oFragment;` && |\n| &&
             `        oFragment.open();` && |\n| &&
             `      },` && |\n| &&
             `      async displayPopover(xml, viewProp, openById) {` && |\n| &&
             `        const oModel = this._createViewModel();` && |\n| &&
             `        applyStoredSizeLimit('POPOVER', oModel);` && |\n| &&
             `        let oFragment;` && |\n| &&
             `        try {` && |\n| &&
             `          oFragment = await Fragment.load({` && |\n| &&
             `            definition: xml,` && |\n| &&
             `            controller: z2ui5.oControllerPopover,` && |\n| &&
             `            id: 'popoverId',` && |\n| &&
             `          });` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          oModel.destroy?.();` && |\n| &&
             `          _logError(``displayPopover: Fragment.load failed``, e);` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `        try {` && |\n| &&
             `          if (!z2ui5.oApp || z2ui5.oApp.isDestroyed()) {` && |\n| &&
             `            oFragment.destroy();` && |\n| &&
             `            oModel.destroy?.();` && |\n| &&
             `            return;` && |\n| &&
             `          }` && |\n| &&
             `          oFragment.setModel(oModel);` && |\n| &&
             `          // .Fragment pinned for legacy app-side lookups; new code should import Fragment directly` && |\n| &&
             `          oFragment.Fragment = Fragment;` && |\n| &&
             `          z2ui5[viewProp] = oFragment;` && |\n| &&
             `          const oControl = _findControlById(openById);` && |\n| &&
             `          if (!oControl) {` && |\n| &&
             `            _logError(``displayPopover: openBy control '${openById}' not found``);` && |\n| &&
             `            // Fragment + model are unowned at this point — release them instead of leaking` && |\n| &&
             `            z2ui5[viewProp] = null;` && |\n| &&
             `            oFragment.destroy();` && |\n| &&
             `            oModel.destroy?.();` && |\n| &&
             `            return;` && |\n| &&
             `          }` && |\n| &&
             |\n|.
    result = result &&
             `          oFragment.openBy(oControl);` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          _logError(``displayPopover: failed``, e);` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `      async displayNestedView(xml, viewProp, viewNestId, controller) {` && |\n| &&
             `        const oModel = this._createViewModel();` && |\n| &&
             `        applyStoredSizeLimit(paramToViewKey[viewNestId], oModel);` && |\n| &&
             `        let oView;` && |\n| &&
             `        try {` && |\n| &&
             `          oView = await XMLView.create({` && |\n| &&
             `            definition: xml,` && |\n| &&
             `            controller,` && |\n| &&
             `            preprocessors: { xml: { models: { template: oModel } } },` && |\n| &&
             `          });` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          oModel.destroy?.();` && |\n| &&
             `          throw e;` && |\n| &&
             `        }` && |\n| &&
             `        const abort = (reason, err) => {` && |\n| &&
             `          if (reason) _logError(reason, err);` && |\n| &&
             `          oView.destroy();` && |\n| &&
             `          oModel.destroy?.();` && |\n| &&
             `        };` && |\n| &&
             `        if (!z2ui5.oApp || z2ui5.oApp.isDestroyed()) {` && |\n| &&
             `          abort();` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `        oView.setModel(oModel);` && |\n| &&
             `        const nestParams = z2ui5.oResponse?.PARAMS?.[viewNestId];` && |\n| &&
             `        if (!nestParams) {` && |\n| &&
             `          abort(``displayNestedView: missing PARAMS.${viewNestId}``);` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `        const { ID, METHOD_DESTROY, METHOD_INSERT } = nestParams;` && |\n| &&
             `        const oParent = z2ui5.oView?.byId(ID);` && |\n| &&
             `        if (!oParent) {` && |\n| &&
             `          abort(``displayNestedView: parent control '${ID}' not found, nested view discarded``);` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `        // typeof guards: METHOD_DESTROY/INSERT come from the backend; tolerate missing/non-function values` && |\n| &&
             `        if (typeof oParent[METHOD_DESTROY] === 'function') {` && |\n| &&
             `          try {` && |\n| &&
             `            oParent[METHOD_DESTROY]();` && |\n| &&
             `          } catch (e) {` && |\n| &&
             `            _logError(``displayNestedView: parent destroy method '${METHOD_DESTROY}' failed``, e);` && |\n| &&
             `          }` && |\n| &&
             `        } else {` && |\n| &&
             `          _logError(``displayNestedView: parent has no method '${METHOD_DESTROY}'``);` && |\n| &&
             `        }` && |\n| &&
             `        if (typeof oParent[METHOD_INSERT] !== 'function') {` && |\n| &&
             `          abort(``displayNestedView: parent has no method '${METHOD_INSERT}'``);` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `        try {` && |\n| &&
             `          oParent[METHOD_INSERT](oView);` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          abort(``displayNestedView: parent insert method '${METHOD_INSERT}' failed``, e);` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `        z2ui5[viewProp] = oView;` && |\n| &&
             `      },` && |\n| &&
             `      _destroyView(prop, tryClose) {` && |\n| &&
             `        const view = z2ui5[prop];` && |\n| &&
             `        if (!view) return;` && |\n| &&
             `        z2ui5[prop] = null;` && |\n| &&
             `        let destroyed = false;` && |\n| &&
             `        let safetyTimer = null;` && |\n| &&
             `        const closeAndDestroy = () => {` && |\n| &&
             `          if (destroyed) return;` && |\n| &&
             `          destroyed = true;` && |\n| &&
             `          if (safetyTimer !== null) clearTimeout(safetyTimer);` && |\n| &&
             `          try {` && |\n| &&
             `            view.destroy();` && |\n| &&
             `          } catch (e) {` && |\n| &&
             `            _logError(``_destroyView: view.destroy() failed for ${prop}``, e);` && |\n| &&
             `          }` && |\n| &&
             `        };` && |\n| &&
             `        if (tryClose) {` && |\n| &&
             `          try {` && |\n| &&
             `            const ret = view.close?.();` && |\n| &&
             `            // Defer destroy until the close animation has settled. If close() returned a` && |\n| &&
             `            // thenable we wait for it; otherwise an afterClose handler covers Dialog/Popover.` && |\n| &&
             `            if (ret && typeof ret.then === 'function') {` && |\n| &&
             `              ret.then(closeAndDestroy, closeAndDestroy);` && |\n| &&
             `              return;` && |\n| &&
             `            }` && |\n| &&
             `            if (typeof view.attachEventOnce === 'function' && typeof view.isOpen === 'function' && view.isOpen()) {` && |\n| &&
             `              view.attachEventOnce('afterClose', closeAndDestroy);` && |\n| &&
             `              // Safety net: if afterClose never fires (e.g. dialog stuck), still destroy.` && |\n| &&
             `              // The timer is cleared in closeAndDestroy so we don't keep an orphan callback.` && |\n| &&
             `              safetyTimer = setTimeout(closeAndDestroy, _DESTROY_SAFETY_NET_MS);` && |\n| &&
             `              return;` && |\n| &&
             `            }` && |\n| &&
             `          } catch (e) {` && |\n| &&
             `            _logError(``_destroyView: view.close() failed for ${prop}``, e);` && |\n| &&
             `          }` && |\n| &&
             `        }` && |\n| &&
             `        closeAndDestroy();` && |\n| &&
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
             `        // Object.hasOwn guard prevents prototype lookups (e.g. args[0] === 'constructor')` && |\n| &&
             `        const navLookup =` && |\n| &&
             `          typeof args[0] === 'string' && Object.hasOwn(navContainerLookups, args[0]) ? navContainerLookups[args[0]] : null;` && |\n| &&
             `        if (navLookup) {` && |\n| &&
             `          navigateContainer(navLookup, args);` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `` && |\n| &&
             `        switch (args[0]) {` && |\n| &&
             `          case 'SET_SIZE_LIMIT': {` && |\n| &&
             `            const hasLimit = args[2] !== undefined && args[2] !== '';` && |\n| &&
             `            const viewKey = hasLimit ? args[2] : args[1];` && |\n| &&
             `            const limit = hasLimit ? Number(args[1]) : NaN;` && |\n| &&
             `            // Object.hasOwn guard prevents prototype access (viewKey === '__proto__' etc.)` && |\n| &&
             `            const model =` && |\n| &&
             `              typeof viewKey === 'string' && Object.hasOwn(viewLookups, viewKey)` && |\n| &&
             `                ? viewLookups[viewKey]()?.getModel()` && |\n| &&
             `                : undefined;` && |\n| &&
             `            if (Number.isFinite(limit) && limit > 0) {` && |\n| &&
             `              (z2ui5.viewSizeLimits ??= {})[viewKey] = limit;` && |\n| &&
             `              if (model) {` && |\n| &&
             `                model.setSizeLimit(limit);` && |\n| &&
             `                model.refresh(true);` && |\n| &&
             `              }` && |\n| &&
             `            } else {` && |\n| &&
             `              if (z2ui5.viewSizeLimits) delete z2ui5.viewSizeLimits[viewKey];` && |\n| &&
             `              if (model) {` && |\n| &&
             `                model.setSizeLimit(100);` && |\n| &&
             `                model.refresh(true);` && |\n| &&
             `              }` && |\n| &&
             `            }` && |\n| &&
             `            break;` && |\n| &&
             `          }` && |\n| &&
             `          case 'HISTORY_BACK':` && |\n| &&
             `            // Only navigate back when there is actually an entry to go back to` && |\n| &&
             `            if (history.length > 1) history.back();` && |\n| &&
             `            break;` && |\n| &&
             `          case 'CLIPBOARD_COPY':` && |\n| &&
             `            copyToClipboard(args[1]);` && |\n| &&
             `            break;` && |\n| &&
             `          case 'CLIPBOARD_APP_STATE': {` && |\n| &&
             `            // Strip any existing hash before appending — avoids producing a malformed URL with two ``#``` && |\n| &&
             `            const baseUrl = window.location.href.split('#')[0];` && |\n| &&
             `            copyToClipboard(``${baseUrl}#/z2ui5-xapp-state=${z2ui5.oResponse?.ID ?? ''}``);` && |\n| &&
             `            break;` && |\n| &&
             `          }` && |\n| &&
             `          case 'SET_ODATA_MODEL': {` && |\n| &&
             `            try {` && |\n| &&
             `              const modelName = args[2] || undefined;` && |\n| &&
             `              // Destroy a previously bound ODataModel under the same name to release sockets/handlers` && |\n| &&
             `              const previous = z2ui5.oView?.getModel(modelName);` && |\n| &&
             `              const oModel = new ODataModel({ serviceUrl: args[1], annotationURI: args[3] ?? '' });` && |\n| &&
             `              z2ui5.oView?.setModel(oModel, modelName);` && |\n| &&
             `              if (previous && previous !== oModel && typeof previous.destroy === 'function') previous.destroy();` && |\n| &&
             `            } catch (e) {` && |\n| &&
             `              _logError(``SET_ODATA_MODEL: failed for '${args[1]}'``, e);` && |\n| &&
             `            }` && |\n| &&
             `            break;` && |\n| &&
             `          }` && |\n| &&
             `          case 'STORE_DATA': {` && |\n| &&
             `            const { TYPE, PREFIX, VALUE, KEY } = args[1];` && |\n| &&
             `            try {` && |\n| &&
             `              const StorageTypes = Storage?.Type ?? {};` && |\n| &&
             `              // Object.hasOwn guard prevents prototype lookups (TYPE === '__proto__')` && |\n| &&
             `              const resolvedType =` && |\n| &&
             `                typeof TYPE === 'string' && Object.hasOwn(StorageTypes, TYPE)` && |\n| &&
             `                  ? StorageTypes[TYPE]` && |\n| &&
             `                  : StorageTypes.session;` && |\n| &&
             `              const oStorage = new Storage(resolvedType, PREFIX);` && |\n| &&
             `              if (VALUE === '' || VALUE == null) {` && |\n| &&
             `                oStorage.remove(KEY);` && |\n| &&
             `              } else {` && |\n| &&
             `                oStorage.put(KEY, VALUE);` && |\n| &&
             `              }` && |\n| &&
             `            } catch (e) {` && |\n| &&
             `              _logError(``STORE_DATA: storage operation failed for key '${KEY}'``, e);` && |\n| &&
             `            }` && |\n| &&
             `            break;` && |\n| &&
             `          }` && |\n| &&
             `          case 'DOWNLOAD_B64_FILE': {` && |\n| &&
             `            // Firefox ignores click() on a detached anchor; attach briefly to the body` && |\n| &&
             `            const a = Object.assign(document.createElement('a'), { href: args[1], download: args[2] });` && |\n| &&
             `            document.body.appendChild(a);` && |\n| &&
             `            a.click();` && |\n| &&
             `            a.remove();` && |\n| &&
             `            break;` && |\n| &&
             `          }` && |\n| &&
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
             `              // noopener,noreferrer prevents the new tab from accessing window.opener and from` && |\n| &&
             `              // sending a Referer header (modern best practice; supersedes manual ``opener = null``)` && |\n| &&
             `              window.open(args[1], '_blank', 'noopener,noreferrer');` && |\n| &&
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
             `            try {` && |\n| &&
             `              _URL_HELPER_ACTIONS[args[1]]?.(args[2]);` && |\n| &&
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
             `            // Skip the SAVE roundtrip if we couldn't extract the image — sending undefined` && |\n| &&
             `            // would silently overwrite the backend image with null` && |\n| &&
             `            if (image !== undefined) this.eB(['SAVE'], image);` && |\n| &&
             `            break;` && |\n| &&
             `          }` && |\n| &&
             `          case 'Z2UI5':` && |\n| &&
             `            try {` && |\n| &&
             `              const fnName = args[1];` && |\n| &&
             `              // Restrict to own callable properties to block prototype-pollution paths like` && |\n| &&
             `              // '__proto__', 'constructor', 'hasOwnProperty', etc.` && |\n| &&
             `              if (typeof fnName !== 'string' || !Object.hasOwn(z2ui5, fnName) || typeof z2ui5[fnName] !== 'function') {` && |\n| &&
             `                _logError(``Z2UI5: '${fnName}' is not a callable own property of z2ui5``);` && |\n| &&
             `                break;` && |\n| &&
             `              }` && |\n| &&
             `              z2ui5[fnName](args.slice(2));` && |\n| &&
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
             `        // args[0] is the event-name array — args[0][2] is the "force during busy" flag,` && |\n| &&
             `        // args[0][3] forces the main controller path` && |\n| &&
             `        if (z2ui5.isBusy && !args[0]?.[2]) {` && |\n| &&
             `          const oBusyDialog = new mBusyDialog();` && |\n| &&
             `          oBusyDialog.open();` && |\n| &&
             `          queueMicrotask(() => oBusyDialog.close());` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `        z2ui5.isBusy = true;` && |\n| &&
             `        BusyIndicator.show();` && |\n| &&
             `        z2ui5.oBody = { VIEWNAME: 'MAIN' };` && |\n| &&
             `        let oModel = null;` && |\n| &&
             `        if (args[0]?.[3] || z2ui5.oController === this) {` && |\n| &&
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
             `        // Index 0 is the event-name array; later indices are user-supplied payloads.` && |\n| &&
             `        // Stringify objects/arrays to keep JSON sane; preserve null and primitives untouched.` && |\n| &&
             `        z2ui5.oBody.ARGUMENTS = args.map((item, i) => {` && |\n| &&
             `          if (i === 0 || item === null || typeof item !== 'object') return item;` && |\n| &&
             `          try {` && |\n| &&
             `            return JSON.stringify(item);` && |\n| &&
             `          } catch (e) {` && |\n| &&
             `            _logError(``eB: failed to stringify argument ${i}``, e);` && |\n| &&
             `            return null;` && |\n| &&
             `          }` && |\n| &&
             `        });` && |\n| &&
             `        z2ui5.oResponseOld = z2ui5.oResponse;` && |\n| &&
             `        Server.Roundtrip();` && |\n| &&
             `        runCallbacks(z2ui5.onAfterRoundtrip);` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      updateModelIfRequired(paramKey, oView) {` && |\n| &&
             `        if (!z2ui5.oResponse?.PARAMS?.[paramKey]?.CHECK_UPDATE_MODEL) return;` && |\n| &&
             `        const oModel = this._createViewModel();` && |\n| &&
             `        applyStoredSizeLimit(paramToViewKey[paramKey], oModel);` && |\n| &&
             `        if (oView) {` && |\n| &&
             `          oView.setModel(oModel);` && |\n| &&
             `        } else {` && |\n| &&
             `          // No target view to bind to — release the model instead of leaking it` && |\n| &&
             `          oModel.destroy?.();` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `      async checkSDKcompatibility(err) {` && |\n| &&
             `        let gav;` && |\n| &&
             `        try {` && |\n| &&
             `          ({ gav } = (await VersionInfo.load()) ?? {});` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          _logError('checkSDKcompatibility: VersionInfo.load failed', e);` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `        // gav can be missing for some openui5 builds — fall back to a plain message` && |\n| &&
             `        if (typeof gav === 'string' && !gav.includes('com.sap.ui5')) {` && |\n| &&
             `          MessageBox.error(``openui5 SDK is loaded, module: ${err?._modules} is not available in openui5``);` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `        MessageBox.error(err?.message ?? String(err));` && |\n| &&
             `      },` && |\n| &&
             `      showMessage(msgType, params) {` && |\n| &&
             `        if (!params) return;` && |\n| &&
             `        const msg = params[msgType];` && |\n| &&
             `        // Skip when the backend sends no usable text (undefined or null)` && |\n| &&
             `        if (msg?.TEXT == null) return;` && |\n| &&
             `        if (msgType === 'S_MSG_TOAST') {` && |\n| &&
             `          MessageToast.show(msg.TEXT, {` && |\n| &&
             `            duration: parseMs(msg.DURATION, _TOAST_DEFAULT_DURATION_MS),` && |\n| &&
             `            width: msg.WIDTH || _TOAST_DEFAULT_WIDTH,` && |\n| &&
             `            onClose: msg.ONCLOSE ? () => this.eB([msg.ONCLOSE]) : null,` && |\n| &&
             `            autoClose: !!msg.AUTOCLOSE,` && |\n| &&
             `            animationTimingFunction: msg.ANIMATIONTIMINGFUNCTION || 'ease',` && |\n| &&
             `            animationDuration: parseMs(msg.ANIMATIONDURATION, _TOAST_DEFAULT_ANIM_MS),` && |\n| &&
             `            closeonBrowserNavigation: !!msg.CLOSEONBROWSERNAVIGATION,` && |\n| &&
             `          });` && |\n| &&
             `          if (typeof msg.CLASS === 'string' && msg.CLASS) {` && |\n| &&
             `            // Pick the most recently appended toast — querySelectorAll returns them in DOM order.` && |\n| &&
             `            // classList.add throws on invalid token names; protect the rest of the flow.` && |\n| &&
             `            try {` && |\n| &&
             `              const toasts = document.querySelectorAll('.sapMMessageToast');` && |\n| &&
             `              const toast = toasts[toasts.length - 1];` && |\n| &&
             `              toast?.classList.add(...msg.CLASS.trim().split(/\s+/).filter(Boolean));` && |\n| &&
             |\n|.
    result = result &&
             `            } catch (e) {` && |\n| &&
             `              _logError(``showMessage: invalid toast CLASS '${msg.CLASS}'``, e);` && |\n| &&
             `            }` && |\n| &&
             `          }` && |\n| &&
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
             `          // Whitelist guard: prevents prototype-pollution dispatch (e.g. msg.TYPE === '__proto__')` && |\n| &&
             `          if (typeof msg.TYPE === 'string' && _MSG_BOX_TYPES.has(msg.TYPE) && typeof MessageBox[msg.TYPE] === 'function') {` && |\n| &&
             `            MessageBox[msg.TYPE](msg.TEXT, oParams);` && |\n| &&
             `          } else {` && |\n| &&
             `            _logError(``showMessage: unsupported MessageBox type '${msg.TYPE}'``);` && |\n| &&
             `          }` && |\n| &&
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
             `        applyStoredSizeLimit('MAIN', oModel);` && |\n| &&
             `        let oView;` && |\n| &&
             `        try {` && |\n| &&
             `          oView = await XMLView.create({` && |\n| &&
             `            definition: xml,` && |\n| &&
             `            models: oModel,` && |\n| &&
             `            controller: z2ui5.oController,` && |\n| &&
             `            id: 'mainView',` && |\n| &&
             `            preprocessors: { xml: { models: { template: oViewModel } } },` && |\n| &&
             `          });` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          // If XMLView.create rejects, both models leak — destroy them explicitly` && |\n| &&
             `          if (switchPath) {` && |\n| &&
             `            oModel.destroy?.();` && |\n| &&
             `            oViewModel.destroy?.();` && |\n| &&
             `          } else {` && |\n| &&
             `            oViewModel.destroy?.();` && |\n| &&
             `          }` && |\n| &&
             `          throw e;` && |\n| &&
             `        }` && |\n| &&
             `        if (!z2ui5.oApp || z2ui5.oApp.isDestroyed()) {` && |\n| &&
             `          oView.destroy();` && |\n| &&
             `          if (switchPath) {` && |\n| &&
             `            oModel.destroy?.();` && |\n| &&
             `            oViewModel.destroy?.();` && |\n| &&
             `          }` && |\n| &&
             `          z2ui5.oView = null;` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `        z2ui5.oView = oView;` && |\n| &&
             `        oView.setModel(z2ui5.oDeviceModel, 'device');` && |\n| &&
             `        if (switchPath) oView.setModel(oViewModel, 'http');` && |\n| &&
             `        z2ui5.oApp.removeAllPages();` && |\n| &&
             `        z2ui5.oApp.insertPage(oView);` && |\n| &&
             `      },` && |\n| &&
             `    });` && |\n| &&
             `  },` && |\n| &&
             `);` && |\n| &&
             `` && |\n| &&
              ``.

  ENDMETHOD.

ENDCLASS.
