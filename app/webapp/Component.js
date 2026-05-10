// Shared utility module — registered first so that consumers (Server, DebugTool,
// View1.controller, App.controller) can declare 'z2ui5/cc/Util' as an AMD dependency.
// Component.js is the entry point, so this define block is parsed before any other
// abap2UI5 module is fetched, which guarantees the registry is populated in time.
sap.ui.define(
  'z2ui5/cc/Util',
  ['sap/ui/core/Fragment', 'sap/ui/core/Element'],
  (Fragment, Element) => {
    'use strict';

    const ERRORS_CAP = 200;
    const ERROR_MAX_LENGTH = 50000;
    const DEFAULT_FETCH_TIMEOUT_MS = 600000;
    const DEFAULT_LOGOUT_URL = '/sap/public/bc/icf/logoff';
    const TOAST_DEFAULT_WIDTH = '15em';
    const TOAST_DEFAULT_DURATION_MS = 3000;
    const TOAST_DEFAULT_ANIM_MS = 1000;
    const XX_PATH_PREFIX_LEN = 4;

    const logError = (message, error) => {
      const entry = { message, ts: new Date().toISOString() };
      if (error !== undefined) entry.error = error;
      if (!Array.isArray(z2ui5.errors)) z2ui5.errors = [];
      const arr = z2ui5.errors;
      arr.push(entry);
      if (arr.length > ERRORS_CAP) arr.splice(0, arr.length - ERRORS_CAP);
    };

    const registerCallback = (key, fn) => {
      if (!Array.isArray(z2ui5[key])) z2ui5[key] = [];
      z2ui5[key].push(fn);
    };

    const unregisterCallback = (key, fn) => {
      z2ui5[key] = Array.isArray(z2ui5[key]) ? z2ui5[key].filter((cb) => cb !== fn) : [];
    };

    const runCallbacks = (arr, ...args) => {
      if (!Array.isArray(arr)) return;
      for (const fn of arr) {
        try {
          fn?.(...args);
        } catch (e) {
          logError(`runCallbacks: callback failed`, e);
        }
      }
    };

    // explicit 0 from backend must pass through (e.g. duration=0 disables auto-close)
    const parseMs = (val, def) => {
      if (val === undefined || val === null || val === '') return def;
      const n = +val;
      return Number.isFinite(n) ? n : def;
    };

    const toJson = (val) => JSON.stringify(val ?? null, null, 3);

    const _ESCAPE_MAP = { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' };
    const _ESCAPE_RE = /[&<>"']/g;
    const escapeHtml = (str) => String(str).replace(_ESCAPE_RE, (c) => _ESCAPE_MAP[c]);

    const _SAFE_PROTOCOLS = new Set(['http:', 'https:']);
    const isValidRedirectURL = (url) => {
      if (!url) return false;
      try {
        const { origin, protocol } = new URL(url, window.location.origin);
        if (origin !== window.location.origin) {
          logError(`Security: Blocked redirect to different origin: ${url}`);
          return false;
        }
        if (!_SAFE_PROTOCOLS.has(protocol)) {
          logError(`Security: Blocked redirect with invalid protocol: ${protocol}`);
          return false;
        }
        return true;
      } catch (e) {
        logError(`Security: Invalid URL format: ${url}`, e);
        return false;
      }
    };

    const _legacyClipboardCopy = (text) => {
      const ta = document.createElement('textarea');
      ta.value = text;
      ta.setAttribute('readonly', '');
      ta.style.cssText = 'position:fixed;top:-1000px;left:-1000px;opacity:0;';
      (document.body ?? document.documentElement).appendChild(ta);
      ta.select();
      try {
        if (!document.execCommand('copy')) logError(`Clipboard: legacy execCommand returned false`);
      } catch (e) {
        logError(`Clipboard: legacy execCommand failed`, e);
      } finally {
        ta.remove();
      }
    };

    const copyToClipboard = (textToCopy) => {
      if (navigator.clipboard?.writeText) {
        navigator.clipboard.writeText(textToCopy).catch((err) => {
          logError(`Clipboard: writeText failed, falling back to execCommand`, err);
          _legacyClipboardCopy(textToCopy);
        });
        return;
      }
      _legacyClipboardCopy(textToCopy);
    };

    const _msgParser = new DOMParser();
    const _sanitizeEl = document.createElement('div');
    const sanitizeMessageDetails = (html) => {
      const doc = _msgParser.parseFromString(html, 'text/html');
      const items = [...doc.querySelectorAll('li')];
      if (items.length) {
        return `<ul>${items
          .map((li) => {
            _sanitizeEl.textContent = li.textContent;
            return `<li>${_sanitizeEl.innerHTML}</li>`;
          })
          .join('')}</ul>`;
      }
      _sanitizeEl.textContent = doc.body.textContent;
      return _sanitizeEl.innerHTML;
    };

    // public getViewContent() since newer UI5; fall back to internal mProperties for older
    const getViewContent = (view) => view?.getViewContent?.() ?? view?.mProperties?.viewContent;
    // _xContent is UI5-internal — no public equivalent for the post-template view source
    const getRenderedContent = (view) => view?._xContent?.outerHTML;

    const findControlById = (id) =>
      z2ui5.oView?.byId(id) ||
      (z2ui5.oViewPopup && Fragment.byId('popupId', id)) ||
      (z2ui5.oViewPopover && Fragment.byId('popoverId', id)) ||
      z2ui5.oViewNest?.byId(id) ||
      z2ui5.oViewNest2?.byId(id) ||
      Element.getElementById?.(id) ||
      // sap.ui.getCore() is removed in ui5-legacy-free
      sap.ui.getCore?.()?.byId?.(id);

    const PRETTIFY_XSL = `<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
        <xsl:strip-space elements="*" />
        <xsl:template match="para[content-style][not(text())]">
          <xsl:value-of select="normalize-space(.)" />
        </xsl:template>
        <xsl:template match="node()|@*">
          <xsl:copy>
            <xsl:apply-templates select="node()|@*" />
          </xsl:copy>
        </xsl:template>
        <xsl:output indent="yes" />
      </xsl:stylesheet>`;
    let _xsltProcessor = null;
    const _xmlSerializer = typeof XMLSerializer !== 'undefined' ? new XMLSerializer() : null;
    const _domParser = typeof DOMParser !== 'undefined' ? new DOMParser() : null;
    const _getXsltProcessor = () => {
      if (typeof XSLTProcessor === 'undefined' || !_domParser) return null;
      if (!_xsltProcessor) {
        const xsltDoc = _domParser.parseFromString(PRETTIFY_XSL, 'application/xml');
        _xsltProcessor = new XSLTProcessor();
        _xsltProcessor.importStylesheet(xsltDoc);
      }
      return _xsltProcessor;
    };
    const prettifyXml = (sourceXml) => {
      if (!sourceXml) return '';
      const processor = _getXsltProcessor();
      if (!processor || !_domParser || !_xmlSerializer) {
        logError('Util.prettifyXml: XSLT/XMLSerializer/DOMParser unavailable in this browser');
        return sourceXml;
      }
      try {
        const xmlDoc = _domParser.parseFromString(sourceXml, 'application/xml');
        const resultDoc = processor.transformToDocument(xmlDoc);
        if (!resultDoc) return sourceXml;
        return _xmlSerializer.serializeToString(resultDoc);
      } catch (e) {
        logError('Util.prettifyXml: XSLT transform failed', e);
        return sourceXml;
      }
    };

    return {
      ERRORS_CAP,
      ERROR_MAX_LENGTH,
      DEFAULT_FETCH_TIMEOUT_MS,
      DEFAULT_LOGOUT_URL,
      TOAST_DEFAULT_WIDTH,
      TOAST_DEFAULT_DURATION_MS,
      TOAST_DEFAULT_ANIM_MS,
      XX_PATH_PREFIX_LEN,
      logError,
      registerCallback,
      unregisterCallback,
      runCallbacks,
      parseMs,
      toJson,
      escapeHtml,
      isValidRedirectURL,
      copyToClipboard,
      sanitizeMessageDetails,
      getViewContent,
      getRenderedContent,
      findControlById,
      prettifyXml,
    };
  },
);

sap.ui.define(
  ['sap/ui/core/UIComponent', 'z2ui5/model/models', 'z2ui5/cc/Server', 'sap/ui/VersionInfo', 'z2ui5/cc/DebugTool', 'z2ui5/cc/Util'],
  (UIComponent, Models, Server, VersionInfo, DebugTool, Util) => {
    'use strict';

    const { logError: _logError } = Util;

    return UIComponent.extend('z2ui5.Component', {
      metadata: {
        manifest: 'json',
        interfaces: ['sap.ui.core.IAsyncContentCreation'],
      },
      init() {
        if (typeof z2ui5 !== 'undefined') z2ui5.oConfig = {};

        UIComponent.prototype.init.call(this);

        if (typeof z2ui5 === 'undefined') z2ui5 = {};
        if (z2ui5.checkLocal === false) z2ui5 = {};
        z2ui5.oConfig ??= {};
        z2ui5.oDeviceModel = Models.createDeviceModel();
        this.setModel(z2ui5.oDeviceModel, 'device');

        z2ui5.oConfig.ComponentData = this.getComponentData();

        this._initLaunchpad();
        this._initVersionInfo();

        this._boundUnload = this._onUnload.bind(this);
        // pagehide fires on every browser; beforeunload does not on iOS Safari.
        // Feature-detect rather than UA-sniff.
        this._unloadEvent = 'onpagehide' in window ? 'pagehide' : 'beforeunload';
        window.addEventListener(this._unloadEvent, this._boundUnload);

        this._boundKeydown = (zEvent) => {
          if (zEvent.ctrlKey && zEvent.key === 'F12') {
            // ??= alone would not recreate a torn-down dialog control; isDestroyed() check covers that
            if (!z2ui5.debugTool || z2ui5.debugTool.isDestroyed?.()) {
              z2ui5.debugTool = new DebugTool();
            }
            z2ui5.debugTool.toggle();
          }
        };
        document.addEventListener('keydown', this._boundKeydown);

        this._boundPopstate = (event) => {
          // Browser history state should be treated as read-only; drop the navigation flags
          // by shallow-copying the response/PARAMS instead of mutating event.state in place.
          const stateResponse = event?.state?.response;
          if (stateResponse?.PARAMS) {
            const restParams = { ...stateResponse.PARAMS };
            delete restParams.SET_PUSH_STATE;
            delete restParams.SET_APP_STATE_ACTIVE;
            z2ui5.oResponse = { ...stateResponse, PARAMS: restParams };
          }
          if (event?.state?.view) {
            z2ui5.oController?.ViewDestroy();
            z2ui5.oController
              ?.displayView(event.state.view, event.state.model)
              ?.catch((e) => _logError(`popstate: displayView failed`, e));
          }
        };
        window.addEventListener('popstate', this._boundPopstate);

        z2ui5.oRouter = this.getRouter();
        // initialize() loads the route patterns; stop() pauses auto-routing — abap2UI5
        // drives navigation manually via Roundtrip rather than letting UI5 routing dispatch.
        z2ui5.oRouter.initialize();
        z2ui5.oRouter.stop();
      },

      _initLaunchpad() {
        const Container = sap.ui.require('sap/ushell/Container');
        if (!Container) return;
        const launchpad = { Container };
        z2ui5.oLaunchpad = launchpad;
        Container.getServiceAsync('ShellUIService')
          .then((s) => { launchpad.ShellUIService = s; })
          .catch((e) => _logError(`Component: ShellUIService init failed`, e));
        Container.getServiceAsync('CrossApplicationNavigation')
          .then((s) => { launchpad.CrossAppNavigator = s; })
          .catch((e) => _logError(`Component: CrossApplicationNavigation init failed`, e));
        sap.ui.require(
          ['sap/ushell/services/AppConfiguration'],
          (ac) => { launchpad.AppConfiguration = ac; },
          (e) => _logError(`Component: AppConfiguration init failed`, e),
        );
      },

      async _initVersionInfo() {
        try {
          const { version, buildTimestamp, gav } = (await VersionInfo.load()) ?? {};
          // oConfig may have been torn down between request and response — guard before assignment
          if (!this.isDestroyed() && z2ui5.oConfig) {
            z2ui5.oConfig.UI5VersionInfo = { version, buildTimestamp, gav };
          }
        } catch (e) {
          _logError(`Component: VersionInfo load failed`, e);
        }
      },

      _onUnload() {
        window.removeEventListener(this._unloadEvent, this._boundUnload);
        // destroy() triggers exit() which removes the remaining listeners and ends the session
        this.destroy();
      },

      exit() {
        window.removeEventListener(this._unloadEvent, this._boundUnload);
        document.removeEventListener('keydown', this._boundKeydown);
        window.removeEventListener('popstate', this._boundPopstate);
        // Wrap each destroy individually so one failure does not skip the remaining cleanup
        const safeDestroy = (key) => {
          try {
            z2ui5[key]?.destroy?.();
          } catch (e) {
            _logError(`Component.exit: ${key}.destroy() failed`, e);
          }
        };
        safeDestroy('debugTool');
        safeDestroy('oDeviceModel');
        // Symmetric cleanup so a re-mounted Component does not leak controllers/views/router
        for (const key of [
          'debugTool',
          'oRouter',
          'oController',
          'oControllerNest',
          'oControllerNest2',
          'oControllerPopup',
          'oControllerPopover',
          'oView',
          'oViewNest',
          'oViewNest2',
          'oViewPopup',
          'oViewPopover',
          'oDeviceModel',
        ]) {
          z2ui5[key] = null;
        }
        try {
          Server.endSession();
        } catch (e) {
          _logError(`Component.exit: Server.endSession failed`, e);
        }
        UIComponent.prototype.exit?.call(this);
      },
    });
  },
);
