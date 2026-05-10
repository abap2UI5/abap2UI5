CLASS z2ui5_cl_app_component_js DEFINITION
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


CLASS z2ui5_cl_app_component_js IMPLEMENTATION.

  METHOD get.

    result = `// Shared utility module — registered first so that consumers (Server, DebugTool,` && |\n| &&
             `// View1.controller, App.controller) can declare 'z2ui5/cc/Util' as an AMD dependency.` && |\n| &&
             `// Component.js is the entry point, so this define block is parsed before any other` && |\n| &&
             `// abap2UI5 module is fetched, which guarantees the registry is populated in time.` && |\n| &&
             `sap.ui.define(` && |\n| &&
             `  'z2ui5/cc/Util',` && |\n| &&
             `  ['sap/ui/core/Fragment', 'sap/ui/core/Element'],` && |\n| &&
             `  (Fragment, Element) => {` && |\n| &&
             `    'use strict';` && |\n| &&
             `` && |\n| &&
             `    const ERRORS_CAP = 200;` && |\n| &&
             `    const ERROR_MAX_LENGTH = 50000;` && |\n| &&
             `    const DEFAULT_FETCH_TIMEOUT_MS = 600000;` && |\n| &&
             `    const DEFAULT_LOGOUT_URL = '/sap/public/bc/icf/logoff';` && |\n| &&
             `    const TOAST_DEFAULT_WIDTH = '15em';` && |\n| &&
             `    const TOAST_DEFAULT_DURATION_MS = 3000;` && |\n| &&
             `    const TOAST_DEFAULT_ANIM_MS = 1000;` && |\n| &&
             `    const XX_PATH_PREFIX_LEN = 4;` && |\n| &&
             `` && |\n| &&
             `    const logError = (message, error) => {` && |\n| &&
             `      const entry = { message, ts: new Date().toISOString() };` && |\n| &&
             `      if (error !== undefined) entry.error = error;` && |\n| &&
             `      if (!Array.isArray(z2ui5.errors)) z2ui5.errors = [];` && |\n| &&
             `      const arr = z2ui5.errors;` && |\n| &&
             `      arr.push(entry);` && |\n| &&
             `      if (arr.length > ERRORS_CAP) arr.splice(0, arr.length - ERRORS_CAP);` && |\n| &&
             `    };` && |\n| &&
             `` && |\n| &&
             `    const registerCallback = (key, fn) => {` && |\n| &&
             `      if (!Array.isArray(z2ui5[key])) z2ui5[key] = [];` && |\n| &&
             `      z2ui5[key].push(fn);` && |\n| &&
             `    };` && |\n| &&
             `` && |\n| &&
             `    const unregisterCallback = (key, fn) => {` && |\n| &&
             `      z2ui5[key] = Array.isArray(z2ui5[key]) ? z2ui5[key].filter((cb) => cb !== fn) : [];` && |\n| &&
             `    };` && |\n| &&
             `` && |\n| &&
             `    const runCallbacks = (arr, ...args) => {` && |\n| &&
             `      if (!Array.isArray(arr)) return;` && |\n| &&
             `      for (const fn of arr) {` && |\n| &&
             `        try {` && |\n| &&
             `          fn?.(...args);` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          logError(``runCallbacks: callback failed``, e);` && |\n| &&
             `        }` && |\n| &&
             `      }` && |\n| &&
             `    };` && |\n| &&
             `` && |\n| &&
             `    // explicit 0 from backend must pass through (e.g. duration=0 disables auto-close)` && |\n| &&
             `    const parseMs = (val, def) => {` && |\n| &&
             `      if (val === undefined || val === null || val === '') return def;` && |\n| &&
             `      const n = +val;` && |\n| &&
             `      return Number.isFinite(n) ? n : def;` && |\n| &&
             `    };` && |\n| &&
             `` && |\n| &&
             `    const toJson = (val) => JSON.stringify(val ?? null, null, 3);` && |\n| &&
             `` && |\n| &&
             `    const _ESCAPE_MAP = { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' };` && |\n| &&
             `    const _ESCAPE_RE = /[&<>"']/g;` && |\n| &&
             `    const escapeHtml = (str) => String(str).replace(_ESCAPE_RE, (c) => _ESCAPE_MAP[c]);` && |\n| &&
             `` && |\n| &&
             `    const _SAFE_PROTOCOLS = new Set(['http:', 'https:']);` && |\n| &&
             `    const isValidRedirectURL = (url) => {` && |\n| &&
             `      if (!url) return false;` && |\n| &&
             `      try {` && |\n| &&
             `        const { origin, protocol } = new URL(url, window.location.origin);` && |\n| &&
             `        if (origin !== window.location.origin) {` && |\n| &&
             `          logError(``Security: Blocked redirect to different origin: ${url}``);` && |\n| &&
             `          return false;` && |\n| &&
             `        }` && |\n| &&
             `        if (!_SAFE_PROTOCOLS.has(protocol)) {` && |\n| &&
             `          logError(``Security: Blocked redirect with invalid protocol: ${protocol}``);` && |\n| &&
             `          return false;` && |\n| &&
             `        }` && |\n| &&
             `        return true;` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        logError(``Security: Invalid URL format: ${url}``, e);` && |\n| &&
             `        return false;` && |\n| &&
             `      }` && |\n| &&
             `    };` && |\n| &&
             `` && |\n| &&
             `    const _legacyClipboardCopy = (text) => {` && |\n| &&
             `      const ta = document.createElement('textarea');` && |\n| &&
             `      ta.value = text;` && |\n| &&
             `      ta.setAttribute('readonly', '');` && |\n| &&
             `      ta.style.cssText = 'position:fixed;top:-1000px;left:-1000px;opacity:0;';` && |\n| &&
             `      (document.body ?? document.documentElement).appendChild(ta);` && |\n| &&
             `      ta.select();` && |\n| &&
             `      try {` && |\n| &&
             `        if (!document.execCommand('copy')) logError(``Clipboard: legacy execCommand returned false``);` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        logError(``Clipboard: legacy execCommand failed``, e);` && |\n| &&
             `      } finally {` && |\n| &&
             `        ta.remove();` && |\n| &&
             `      }` && |\n| &&
             `    };` && |\n| &&
             `` && |\n| &&
             `    const copyToClipboard = (textToCopy) => {` && |\n| &&
             `      if (navigator.clipboard?.writeText) {` && |\n| &&
             `        navigator.clipboard.writeText(textToCopy).catch((err) => {` && |\n| &&
             `          logError(``Clipboard: writeText failed, falling back to execCommand``, err);` && |\n| &&
             `          _legacyClipboardCopy(textToCopy);` && |\n| &&
             `        });` && |\n| &&
             `        return;` && |\n| &&
             `      }` && |\n| &&
             `      _legacyClipboardCopy(textToCopy);` && |\n| &&
             `    };` && |\n| &&
             `` && |\n| &&
             `    const _msgParser = new DOMParser();` && |\n| &&
             `    const _sanitizeEl = document.createElement('div');` && |\n| &&
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
             `    // public getViewContent() since newer UI5; fall back to internal mProperties for older` && |\n| &&
             `    const getViewContent = (view) => view?.getViewContent?.() ?? view?.mProperties?.viewContent;` && |\n| &&
             `    // _xContent is UI5-internal — no public equivalent for the post-template view source` && |\n| &&
             `    const getRenderedContent = (view) => view?._xContent?.outerHTML;` && |\n| &&
             `` && |\n| &&
             `    const findControlById = (id) =>` && |\n| &&
             `      z2ui5.oView?.byId(id) ||` && |\n| &&
             `      (z2ui5.oViewPopup && Fragment.byId('popupId', id)) ||` && |\n| &&
             `      (z2ui5.oViewPopover && Fragment.byId('popoverId', id)) ||` && |\n| &&
             `      z2ui5.oViewNest?.byId(id) ||` && |\n| &&
             `      z2ui5.oViewNest2?.byId(id) ||` && |\n| &&
             `      Element.getElementById?.(id) ||` && |\n| &&
             `      // sap.ui.getCore() is removed in ui5-legacy-free` && |\n| &&
             `      sap.ui.getCore?.()?.byId?.(id);` && |\n| &&
             `` && |\n| &&
             `    const PRETTIFY_XSL = ``<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform">` && |\n| &&
             `        <xsl:strip-space elements="*" />` && |\n| &&
             `        <xsl:template match="para[content-style][not(text())]">` && |\n| &&
             `          <xsl:value-of select="normalize-space(.)" />` && |\n| &&
             `        </xsl:template>` && |\n| &&
             `        <xsl:template match="node()|@*">` && |\n| &&
             `          <xsl:copy>` && |\n| &&
             `            <xsl:apply-templates select="node()|@*" />` && |\n| &&
             `          </xsl:copy>` && |\n| &&
             `        </xsl:template>` && |\n| &&
             `        <xsl:output indent="yes" />` && |\n| &&
             `      </xsl:stylesheet>``;` && |\n| &&
             `    let _xsltProcessor = null;` && |\n| &&
             `    const _xmlSerializer = typeof XMLSerializer !== 'undefined' ? new XMLSerializer() : null;` && |\n| &&
             `    const _domParser = typeof DOMParser !== 'undefined' ? new DOMParser() : null;` && |\n| &&
             `    const _getXsltProcessor = () => {` && |\n| &&
             `      if (typeof XSLTProcessor === 'undefined' || !_domParser) return null;` && |\n| &&
             `      if (!_xsltProcessor) {` && |\n| &&
             `        const xsltDoc = _domParser.parseFromString(PRETTIFY_XSL, 'application/xml');` && |\n| &&
             `        _xsltProcessor = new XSLTProcessor();` && |\n| &&
             `        _xsltProcessor.importStylesheet(xsltDoc);` && |\n| &&
             `      }` && |\n| &&
             `      return _xsltProcessor;` && |\n| &&
             `    };` && |\n| &&
             `    const prettifyXml = (sourceXml) => {` && |\n| &&
             `      if (!sourceXml) return '';` && |\n| &&
             `      const processor = _getXsltProcessor();` && |\n| &&
             `      if (!processor || !_domParser || !_xmlSerializer) {` && |\n| &&
             `        logError('Util.prettifyXml: XSLT/XMLSerializer/DOMParser unavailable in this browser');` && |\n| &&
             `        return sourceXml;` && |\n| &&
             `      }` && |\n| &&
             `      try {` && |\n| &&
             `        const xmlDoc = _domParser.parseFromString(sourceXml, 'application/xml');` && |\n| &&
             `        const resultDoc = processor.transformToDocument(xmlDoc);` && |\n| &&
             `        if (!resultDoc) return sourceXml;` && |\n| &&
             `        return _xmlSerializer.serializeToString(resultDoc);` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        logError('Util.prettifyXml: XSLT transform failed', e);` && |\n| &&
             `        return sourceXml;` && |\n| &&
             `      }` && |\n| &&
             `    };` && |\n| &&
             `` && |\n| &&
             `    return {` && |\n| &&
             `      ERRORS_CAP,` && |\n| &&
             `      ERROR_MAX_LENGTH,` && |\n| &&
             `      DEFAULT_FETCH_TIMEOUT_MS,` && |\n| &&
             `      DEFAULT_LOGOUT_URL,` && |\n| &&
             `      TOAST_DEFAULT_WIDTH,` && |\n| &&
             `      TOAST_DEFAULT_DURATION_MS,` && |\n| &&
             `      TOAST_DEFAULT_ANIM_MS,` && |\n| &&
             `      XX_PATH_PREFIX_LEN,` && |\n| &&
             `      logError,` && |\n| &&
             `      registerCallback,` && |\n| &&
             `      unregisterCallback,` && |\n| &&
             `      runCallbacks,` && |\n| &&
             `      parseMs,` && |\n| &&
             `      toJson,` && |\n| &&
             `      escapeHtml,` && |\n| &&
             `      isValidRedirectURL,` && |\n| &&
             `      copyToClipboard,` && |\n| &&
             `      sanitizeMessageDetails,` && |\n| &&
             `      getViewContent,` && |\n| &&
             `      getRenderedContent,` && |\n| &&
             `      findControlById,` && |\n| &&
             `      prettifyXml,` && |\n| &&
             `    };` && |\n| &&
             `  },` && |\n| &&
             `);` && |\n| &&
             `` && |\n| &&
             `sap.ui.define(` && |\n| &&
             `  ['sap/ui/core/UIComponent', 'z2ui5/model/models', 'z2ui5/cc/Server', 'sap/ui/VersionInfo', 'z2ui5/cc/DebugTool', 'z2ui5/cc/Util'],` && |\n| &&
             `  (UIComponent, Models, Server, VersionInfo, DebugTool, Util) => {` && |\n| &&
             `    'use strict';` && |\n| &&
             `` && |\n| &&
             `    const { logError: _logError } = Util;` && |\n| &&
             `` && |\n| &&
             `    return UIComponent.extend('z2ui5.Component', {` && |\n| &&
             `      metadata: {` && |\n| &&
             `        manifest: 'json',` && |\n| &&
             `        interfaces: ['sap.ui.core.IAsyncContentCreation'],` && |\n| &&
             `      },` && |\n| &&
             `      init() {` && |\n| &&
             `        if (typeof z2ui5 !== 'undefined') z2ui5.oConfig = {};` && |\n| &&
             `` && |\n| &&
             `        UIComponent.prototype.init.call(this);` && |\n| &&
             `` && |\n| &&
             `        if (typeof z2ui5 === 'undefined') z2ui5 = {};` && |\n| &&
             `        if (z2ui5.checkLocal === false) z2ui5 = {};` && |\n| &&
             `        z2ui5.oConfig ??= {};` && |\n| &&
             `        z2ui5.oDeviceModel = Models.createDeviceModel();` && |\n| &&
             `        this.setModel(z2ui5.oDeviceModel, 'device');` && |\n| &&
             `` && |\n| &&
             `        z2ui5.oConfig.ComponentData = this.getComponentData();` && |\n| &&
             `` && |\n| &&
             `        this._initLaunchpad();` && |\n| &&
             `        this._initVersionInfo();` && |\n| &&
             `` && |\n| &&
             `        this._boundUnload = this._onUnload.bind(this);` && |\n| &&
             `        // pagehide fires on every browser; beforeunload does not on iOS Safari.` && |\n| &&
             `        // Feature-detect rather than UA-sniff.` && |\n| &&
             `        this._unloadEvent = 'onpagehide' in window ? 'pagehide' : 'beforeunload';` && |\n| &&
             `        window.addEventListener(this._unloadEvent, this._boundUnload);` && |\n| &&
             `` && |\n| &&
             `        this._boundKeydown = (zEvent) => {` && |\n| &&
             `          if (zEvent.ctrlKey && zEvent.key === 'F12') {` && |\n| &&
             `            // ??= alone would not recreate a torn-down dialog control; isDestroyed() check covers that` && |\n| &&
             `            if (!z2ui5.debugTool || z2ui5.debugTool.isDestroyed?.()) {` && |\n| &&
             `              z2ui5.debugTool = new DebugTool();` && |\n| &&
             `            }` && |\n| &&
             `            z2ui5.debugTool.toggle();` && |\n| &&
             `          }` && |\n| &&
             `        };` && |\n| &&
             `        document.addEventListener('keydown', this._boundKeydown);` && |\n| &&
             `` && |\n| &&
             `        this._boundPopstate = (event) => {` && |\n| &&
             `          // Browser history state should be treated as read-only; drop the navigation flags` && |\n| &&
             `          // by shallow-copying the response/PARAMS instead of mutating event.state in place.` && |\n| &&
             `          const stateResponse = event?.state?.response;` && |\n| &&
             `          if (stateResponse?.PARAMS) {` && |\n| &&
             `            const restParams = { ...stateResponse.PARAMS };` && |\n| &&
             `            delete restParams.SET_PUSH_STATE;` && |\n| &&
             `            delete restParams.SET_APP_STATE_ACTIVE;` && |\n| &&
             `            z2ui5.oResponse = { ...stateResponse, PARAMS: restParams };` && |\n| &&
             `          }` && |\n| &&
             `          if (event?.state?.view) {` && |\n| &&
             `            z2ui5.oController?.ViewDestroy();` && |\n| &&
             `            z2ui5.oController` && |\n| &&
             `              ?.displayView(event.state.view, event.state.model)` && |\n| &&
             `              ?.catch((e) => _logError(``popstate: displayView failed``, e));` && |\n| &&
             `          }` && |\n| &&
             `        };` && |\n| &&
             `        window.addEventListener('popstate', this._boundPopstate);` && |\n| &&
             `` && |\n| &&
             `        z2ui5.oRouter = this.getRouter();` && |\n| &&
             `        // initialize() loads the route patterns; stop() pauses auto-routing — abap2UI5` && |\n| &&
             `        // drives navigation manually via Roundtrip rather than letting UI5 routing dispatch.` && |\n| &&
             `        z2ui5.oRouter.initialize();` && |\n| &&
             `        z2ui5.oRouter.stop();` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      _initLaunchpad() {` && |\n| &&
             `        const Container = sap.ui.require('sap/ushell/Container');` && |\n| &&
             `        if (!Container) return;` && |\n| &&
             `        const launchpad = { Container };` && |\n| &&
             `        z2ui5.oLaunchpad = launchpad;` && |\n| &&
             `        Container.getServiceAsync('ShellUIService')` && |\n| &&
             `          .then((s) => { launchpad.ShellUIService = s; })` && |\n| &&
             `          .catch((e) => _logError(``Component: ShellUIService init failed``, e));` && |\n| &&
             `        Container.getServiceAsync('CrossApplicationNavigation')` && |\n| &&
             `          .then((s) => { launchpad.CrossAppNavigator = s; })` && |\n| &&
             `          .catch((e) => _logError(``Component: CrossApplicationNavigation init failed``, e));` && |\n| &&
             `        sap.ui.require(` && |\n| &&
             `          ['sap/ushell/services/AppConfiguration'],` && |\n| &&
             `          (ac) => { launchpad.AppConfiguration = ac; },` && |\n| &&
             `          (e) => _logError(``Component: AppConfiguration init failed``, e),` && |\n| &&
             `        );` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      async _initVersionInfo() {` && |\n| &&
             `        try {` && |\n| &&
             `          const { version, buildTimestamp, gav } = (await VersionInfo.load()) ?? {};` && |\n| &&
             `          // oConfig may have been torn down between request and response — guard before assignment` && |\n| &&
             `          if (!this.isDestroyed() && z2ui5.oConfig) {` && |\n| &&
             `            z2ui5.oConfig.UI5VersionInfo = { version, buildTimestamp, gav };` && |\n| &&
             `          }` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          _logError(``Component: VersionInfo load failed``, e);` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      _onUnload() {` && |\n| &&
             `        window.removeEventListener(this._unloadEvent, this._boundUnload);` && |\n| &&
             `        // destroy() triggers exit() which removes the remaining listeners and ends the session` && |\n| &&
             `        this.destroy();` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      exit() {` && |\n| &&
             `        window.removeEventListener(this._unloadEvent, this._boundUnload);` && |\n| &&
             `        document.removeEventListener('keydown', this._boundKeydown);` && |\n| &&
             `        window.removeEventListener('popstate', this._boundPopstate);` && |\n| &&
             `        // Wrap each destroy individually so one failure does not skip the remaining cleanup` && |\n| &&
             `        const safeDestroy = (key) => {` && |\n| &&
             `          try {` && |\n| &&
             `            z2ui5[key]?.destroy?.();` && |\n| &&
             `          } catch (e) {` && |\n| &&
             `            _logError(``Component.exit: ${key}.destroy() failed``, e);` && |\n| &&
             `          }` && |\n| &&
             `        };` && |\n| &&
             `        safeDestroy('debugTool');` && |\n| &&
             `        safeDestroy('oDeviceModel');` && |\n| &&
             `        // Symmetric cleanup so a re-mounted Component does not leak controllers/views/router` && |\n| &&
             `        for (const key of [` && |\n| &&
             `          'debugTool',` && |\n| &&
             `          'oRouter',` && |\n| &&
             `          'oController',` && |\n| &&
             `          'oControllerNest',` && |\n| &&
             `          'oControllerNest2',` && |\n| &&
             `          'oControllerPopup',` && |\n| &&
             `          'oControllerPopover',` && |\n| &&
             `          'oView',` && |\n| &&
             `          'oViewNest',` && |\n| &&
             `          'oViewNest2',` && |\n| &&
             `          'oViewPopup',` && |\n| &&
             `          'oViewPopover',` && |\n| &&
             `          'oDeviceModel',` && |\n| &&
             `        ]) {` && |\n| &&
             `          z2ui5[key] = null;` && |\n| &&
             `        }` && |\n| &&
             `        try {` && |\n| &&
             `          Server.endSession();` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          _logError(``Component.exit: Server.endSession failed``, e);` && |\n| &&
             `        }` && |\n| &&
             `        UIComponent.prototype.exit?.call(this);` && |\n| &&
             `      },` && |\n| &&
             `    });` && |\n| &&
             `  },` && |\n| &&
             `);` && |\n| &&
             `` && |\n| &&
              ``.

  ENDMETHOD.

ENDCLASS.
