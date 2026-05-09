CLASS z2ui5_cl_app_server_js DEFINITION
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


CLASS z2ui5_cl_app_server_js IMPLEMENTATION.

  METHOD get.

    result = `sap.ui.define(` && |\n| &&
             `  ['sap/ui/core/BusyIndicator', 'sap/m/MessageBox', 'z2ui5/cc/Util'],` && |\n| &&
             `  (BusyIndicator, MessageBox, Util) => {` && |\n| &&
             `  'use strict';` && |\n| &&
             `` && |\n| &&
             `  const {` && |\n| &&
             `    logError: _logError,` && |\n| &&
             `    escapeHtml,` && |\n| &&
             `    ERROR_MAX_LENGTH,` && |\n| &&
             `    DEFAULT_FETCH_TIMEOUT_MS,` && |\n| &&
             `    DEFAULT_LOGOUT_URL,` && |\n| &&
             `  } = Util;` && |\n| &&
             `` && |\n| &&
             `  // Apps can override the timeout by setting z2ui5.oConfig.fetchTimeoutMs before Roundtrip` && |\n| &&
             `  const _fetchTimeoutMs = () => {` && |\n| &&
             `    const v = z2ui5.oConfig?.fetchTimeoutMs;` && |\n| &&
             `    return Number.isFinite(v) && v > 0 ? v : DEFAULT_FETCH_TIMEOUT_MS;` && |\n| &&
             `  };` && |\n| &&
             `  const SAP_CONTEXTID_ACCEPT_HEADER = 'sap-contextid-accept';` && |\n| &&
             `  const SAP_CONTEXTID_ACCEPT_VALUE = 'header';` && |\n| &&
             `  const SAP_CONTEXTID_HEADER = 'sap-contextid';` && |\n| &&
             `  const _MSG_TYPES = ['S_MSG_TOAST', 'S_MSG_BOX'];` && |\n| &&
             `` && |\n| &&
             `  const resolveLogoutUrl = () => z2ui5.oConfig?.logoutUrl || DEFAULT_LOGOUT_URL;` && |\n| &&
             `` && |\n| &&
             `  return {` && |\n| &&
             `    endSession() {` && |\n| &&
             `      if (!z2ui5.contextId) return;` && |\n| &&
             `      const pathname = z2ui5.oConfig?.pathname;` && |\n| &&
             `      if (!pathname) {` && |\n| &&
             `        delete z2ui5.contextId;` && |\n| &&
             `        return;` && |\n| &&
             `      }` && |\n| &&
             `      // SAP convention: HEAD with sap-terminate header releases the stateful session.` && |\n| &&
             `      // Some reverse proxies may strip HEAD bodies — we rely on headers only.` && |\n| &&
             `      fetch(pathname, {` && |\n| &&
             `        method: 'HEAD',` && |\n| &&
             `        keepalive: true,` && |\n| &&
             `        headers: {` && |\n| &&
             `          'sap-terminate': 'session',` && |\n| &&
             `          [SAP_CONTEXTID_HEADER]: z2ui5.contextId,` && |\n| &&
             `          [SAP_CONTEXTID_ACCEPT_HEADER]: SAP_CONTEXTID_ACCEPT_VALUE,` && |\n| &&
             `        },` && |\n| &&
             `      }).catch(() => {});` && |\n| &&
             `      delete z2ui5.contextId;` && |\n| &&
             `    },` && |\n| &&
             `    Roundtrip() {` && |\n| &&
             `      // Direct assignments avoid one Object.assign call per roundtrip` && |\n| &&
             `      z2ui5.checkNestAfter = false;` && |\n| &&
             `      z2ui5.checkNestAfter2 = false;` && |\n| &&
             `      const oBody = (z2ui5.oBody ??= {});` && |\n| &&
             `      const args = oBody.ARGUMENTS ?? [];` && |\n| &&
             `      oBody.S_FRONT = {` && |\n| &&
             `        ID: oBody.ID,` && |\n| &&
             `        CONFIG: z2ui5.oConfig,` && |\n| &&
             `        ORIGIN: window.location.origin,` && |\n| &&
             `        PATHNAME: window.location.pathname,` && |\n| &&
             `        SEARCH: z2ui5.search || window.location.search,` && |\n| &&
             `        VIEW: oBody.VIEWNAME,` && |\n| &&
             `        EVENT: args[0]?.[0],` && |\n| &&
             `        HASH: window.location.hash,` && |\n| &&
             `      };` && |\n| &&
             `      const sFront = oBody.S_FRONT;` && |\n| &&
             `      const tEventArg = args.slice(1);` && |\n| &&
             `      if (tEventArg.length) sFront.T_EVENT_ARG = tEventArg;` && |\n| &&
             `      if (sFront.T_STARTUP_PARAMETERS === undefined) delete sFront.T_STARTUP_PARAMETERS;` && |\n| &&
             `      if (sFront.SEARCH === '') delete sFront.SEARCH;` && |\n| &&
             `      // Strip the source fields now that they have been promoted into S_FRONT` && |\n| &&
             `      delete oBody.ID;` && |\n| &&
             `      delete oBody.VIEWNAME;` && |\n| &&
             `      delete oBody.ARGUMENTS;` && |\n| &&
             `      if (!oBody.XX) delete oBody.XX;` && |\n| &&
             `      this.readHttp();` && |\n| &&
             `    },` && |\n| &&
             `` && |\n| &&
             `    async readHttp() {` && |\n| &&
             `      const pathname = z2ui5.oConfig?.pathname;` && |\n| &&
             `      if (!pathname) {` && |\n| &&
             `        this.responseError(``Request aborted: z2ui5.oConfig.pathname is missing``);` && |\n| &&
             `        return;` && |\n| &&
             `      }` && |\n| &&
             `      let body;` && |\n| &&
             `      try {` && |\n| &&
             `        body = JSON.stringify({ value: z2ui5.oBody });` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        // Most likely a circular reference (e.g. UI5 control accidentally landed in the model)` && |\n| &&
             `        this.responseError(``Request serialisation failed: ${e.message}``);` && |\n| &&
             `        return;` && |\n| &&
             `      }` && |\n| &&
             `      let response;` && |\n| &&
             `      const fetchOpts = {` && |\n| &&
             `        method: 'POST',` && |\n| &&
             `        headers: {` && |\n| &&
             `          'Content-Type': 'application/json',` && |\n| &&
             `          // CSRF: the abap2UI5 ICF handler relies on cookie-based session auth.` && |\n| &&
             `          // Apps requiring an x-csrf-token can inject it via z2ui5.oConfig before Roundtrip().` && |\n| &&
             `          [SAP_CONTEXTID_ACCEPT_HEADER]: SAP_CONTEXTID_ACCEPT_VALUE,` && |\n| &&
             `          [SAP_CONTEXTID_HEADER]: z2ui5.contextId ?? '',` && |\n| &&
             `        },` && |\n| &&
             `        body,` && |\n| &&
             `      };` && |\n| &&
             `      // AbortSignal.timeout is ES2022; older browsers fall back to no client-side timeout` && |\n| &&
             `      const timeoutMs = _fetchTimeoutMs();` && |\n| &&
             `      if (typeof AbortSignal !== 'undefined' && typeof AbortSignal.timeout === 'function') {` && |\n| &&
             `        fetchOpts.signal = AbortSignal.timeout(timeoutMs);` && |\n| &&
             `      }` && |\n| &&
             `      try {` && |\n| &&
             `        response = await fetch(pathname, fetchOpts);` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        // AbortError (or TimeoutError on newer browsers) means the timeout fired` && |\n| &&
             `        const isTimeout = e?.name === 'TimeoutError' || e?.name === 'AbortError';` && |\n| &&
             `        const prefix = isTimeout` && |\n| &&
             `          ? ``Request timed out after ${Math.round(timeoutMs / 1000)}s``` && |\n| &&
             `          : 'Network error';` && |\n| &&
             `        this.responseError(``${prefix}: ${e.message}``);` && |\n| &&
             `        return;` && |\n| &&
             `      }` && |\n| &&
             `      // HTTP header lookup is case-insensitive per spec; only update when present so a` && |\n| &&
             `      // missing header does not blow away the existing context id` && |\n| &&
             `      const newCtx = response.headers.get(SAP_CONTEXTID_HEADER);` && |\n| &&
             `      if (newCtx) z2ui5.contextId = newCtx;` && |\n| &&
             `      if (!response.ok) {` && |\n| &&
             `        let text;` && |\n| &&
             `        try {` && |\n| &&
             `          text = await response.text();` && |\n| &&
             `        } catch {` && |\n| &&
             `          text = ``HTTP ${response.status}: could not read error body``;` && |\n| &&
             `        }` && |\n| &&
             `        this.responseError(text);` && |\n| &&
             `        return;` && |\n| &&
             `      }` && |\n| &&
             `      let responseData;` && |\n| &&
             `      try {` && |\n| &&
             `        responseData = await response.json();` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        this.responseError(``Invalid JSON response: ${e.message}``);` && |\n| &&
             `        return;` && |\n| &&
             `      }` && |\n| &&
             `      if (!responseData?.S_FRONT) {` && |\n| &&
             `        this.responseError(``Invalid response: missing S_FRONT``);` && |\n| &&
             `        return;` && |\n| &&
             `      }` && |\n| &&
             `      z2ui5.responseData = responseData;` && |\n| &&
             `      z2ui5.xxChangedPaths = new Set();` && |\n| &&
             `      const {` && |\n| &&
             `        S_FRONT: { ID, PARAMS },` && |\n| &&
             `        MODEL,` && |\n| &&
             `      } = responseData;` && |\n| &&
             `      this.responseSuccess({ ID, PARAMS, OVIEWMODEL: MODEL });` && |\n| &&
             `    },` && |\n| &&
             `    async responseSuccess(response) {` && |\n| &&
             `      const { oController } = z2ui5;` && |\n| &&
             `      // Bail early if the controller has been torn down between request and response —` && |\n| &&
             `      // every subsequent call (ViewDestroy, eF, showMessage, displayView) assumes it exists` && |\n| &&
             `      if (!oController) {` && |\n| &&
             `        BusyIndicator.hide();` && |\n| &&
             `        z2ui5.isBusy = false;` && |\n| &&
             `        _logError('responseSuccess: z2ui5.oController is missing — response discarded');` && |\n| &&
             `        return;` && |\n| &&
             `      }` && |\n| &&
             `      try {` && |\n| &&
             `        z2ui5.oResponse = response;` && |\n| &&
             `        const params = response.PARAMS;` && |\n| &&
             `        const sView = params?.S_VIEW;` && |\n| &&
             `        if (sView?.CHECK_DESTROY) oController.ViewDestroy();` && |\n| &&
             `        const customJs = params?.S_FOLLOW_UP_ACTION?.CUSTOM_JS;` && |\n| &&
             `        if (Array.isArray(customJs) && customJs.length) {` && |\n| &&
             `          queueMicrotask(() => {` && |\n| &&
             `            for (const item of customJs) {` && |\n| &&
             `              if (oController.isDestroyed?.()) return;` && |\n| &&
             `              if (typeof item !== 'string') {` && |\n| &&
             `                _logError(``customJs: item is not a string``, item);` && |\n| &&
             `                continue;` && |\n| &&
             `              }` && |\n| &&
             `              try {` && |\n| &&
             `                // Format: text'arg1'text'arg2'... — odd-indexed slices are the eF arguments` && |\n| &&
             `                const mParams = item.split("'");` && |\n| &&
             `                const mParamsEF = mParams.filter((_, index) => index % 2);` && |\n| &&
             `                if (mParamsEF.length) oController.eF(...mParamsEF);` && |\n| &&
             `                // Controlled eval of backend-provided JS expression` && |\n| &&
             `                else new Function('return ' + mParams[0])();` && |\n| &&
             `              } catch (e) {` && |\n| &&
             `                _logError(``customJs: execution failed``, e);` && |\n| &&
             `              }` && |\n| &&
             `            }` && |\n| &&
             `          });` && |\n| &&
             `        }` && |\n| &&
             `        for (const t of _MSG_TYPES) oController.showMessage(t, params);` && |\n| &&
             `        if (sView?.XML) {` && |\n| &&
             `          oController.ViewDestroy();` && |\n| &&
             `          await oController.displayView(sView.XML, response.OVIEWMODEL);` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `        for (const [key, view] of [` && |\n| &&
             `          ['S_VIEW', z2ui5.oView],` && |\n| &&
             `          ['S_VIEW_NEST', z2ui5.oViewNest],` && |\n| &&
             `          ['S_VIEW_NEST2', z2ui5.oViewNest2],` && |\n| &&
             `          ['S_POPUP', z2ui5.oViewPopup],` && |\n| &&
             `          ['S_POPOVER', z2ui5.oViewPopover],` && |\n| &&
             `        ])` && |\n| &&
             `          oController.updateModelIfRequired(key, view);` && |\n| &&
             `        oController._processAfterRendering();` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        BusyIndicator.hide();` && |\n| &&
             `        z2ui5.isBusy = false;` && |\n| &&
             `        _logError(``responseSuccess: unexpected error``, e);` && |\n| &&
             `        const msg = e.message ?? '';` && |\n| &&
             `        if (msg.includes('openui5') && msg.includes('script load error')) {` && |\n| &&
             `          oController.checkSDKcompatibility(e);` && |\n| &&
             `        } else {` && |\n| &&
             `          MessageBox.error(e.message ?? String(e));` && |\n| &&
             `        }` && |\n| &&
             `      }` && |\n| &&
             `    },` && |\n| &&
             `    _getOrCreateErrorContainer() {` && |\n| &&
             `      const existing = document.getElementById('serverErrorContainer');` && |\n| &&
             `      if (existing) return existing;` && |\n| &&
             `      const container = Object.assign(document.createElement('div'), {` && |\n| &&
             `        id: 'serverErrorContainer',` && |\n| &&
             `        className: 'z2ui5-error-overlay',` && |\n| &&
             `      });` && |\n| &&
             `      // document.body can be momentarily null during pagehide; fall back to documentElement` && |\n| &&
             `      (document.body ?? document.documentElement).appendChild(container);` && |\n| &&
             `      return container;` && |\n| &&
             `    },` && |\n| &&
             `    responseError(response) {` && |\n| &&
             `      BusyIndicator.hide();` && |\n| &&
             `      z2ui5.isBusy = false;` && |\n| &&
             `` && |\n| &&
             `      const full = String(response);` && |\n| &&
             `      const errorMessage =` && |\n| &&
             `        full.length > ERROR_MAX_LENGTH` && |\n| &&
             `          ? ``${full.slice(0, ERROR_MAX_LENGTH)}\n\n<!-- Content truncated - too long -->``` && |\n| &&
             `          : full;` && |\n| &&
             `` && |\n| &&
             `      const errorContainer = this._getOrCreateErrorContainer();` && |\n| &&
             `      errorContainer.replaceChildren();` && |\n| &&
             `` && |\n| &&
             `      const headerDiv = Object.assign(document.createElement('div'), { className: 'z2ui5-error-overlay__header' });` && |\n| &&
             `      const h3 = Object.assign(document.createElement('h3'), {` && |\n| &&
             `        textContent: 'Server Error - Please Restart The App',` && |\n| &&
             `        className: 'z2ui5-error-overlay__title',` && |\n| &&
             `      });` && |\n| &&
             `      headerDiv.appendChild(h3);` && |\n| &&
             `` && |\n| &&
             `      const actionsDiv = Object.assign(document.createElement('div'), { className: 'z2ui5-error-overlay__actions' });` && |\n| &&
             `` && |\n| &&
             `      const refreshBtn = Object.assign(document.createElement('button'), {` && |\n| &&
             `        type: 'button',` && |\n| &&
             `        textContent: 'Refresh',` && |\n| &&
             `        className: 'z2ui5-error-overlay__btn',` && |\n| &&
             `      });` && |\n| &&
             `      refreshBtn.setAttribute('aria-label', 'Refresh page');` && |\n| &&
             `      refreshBtn.addEventListener('click', () => window.location.reload());` && |\n| &&
             `      actionsDiv.appendChild(refreshBtn);` && |\n| &&
             `` && |\n| &&
             `      const logoutBtn = Object.assign(document.createElement('button'), {` && |\n| &&
             `        type: 'button',` && |\n| &&
             `        textContent: 'Logout',` && |\n| &&
             `        className: 'z2ui5-error-overlay__btn',` && |\n| &&
             `      });` && |\n| &&
             `      logoutBtn.setAttribute('aria-label', 'Logout from server');` && |\n| &&
             `      logoutBtn.addEventListener('click', () => {` && |\n| &&
             `        const redirectToLogoff = () => {` && |\n| &&
             `          window.location.href = resolveLogoutUrl();` && |\n| &&
             `        };` && |\n| &&
             `        try {` && |\n| &&
             `          if (z2ui5.oLaunchpad?.Container?.logout) {` && |\n| &&
             `            z2ui5.oLaunchpad.Container.logout();` && |\n| &&
             `          } else {` && |\n| &&
             `            redirectToLogoff();` && |\n| &&
             `          }` && |\n| &&
             `        } catch {` && |\n| &&
             `          redirectToLogoff();` && |\n| &&
             `        }` && |\n| &&
             `      });` && |\n| &&
             `      actionsDiv.appendChild(logoutBtn);` && |\n| &&
             `` && |\n| &&
             `      headerDiv.appendChild(actionsDiv);` && |\n| &&
             `      errorContainer.appendChild(headerDiv);` && |\n| &&
             `` && |\n| &&
             `      const iframe = Object.assign(document.createElement('iframe'), {` && |\n| &&
             `        id: 'errorIframe',` && |\n| &&
             `        className: 'z2ui5-error-overlay__iframe',` && |\n| &&
             `        title: 'Server error details',` && |\n| &&
             `      });` && |\n| &&
             `      // sandbox="" gives the iframe an opaque origin and blocks scripts/forms/popups.` && |\n| &&
             `      // srcdoc renders escaped, static <pre> content — no contentDocument access from parent needed.` && |\n| &&
             `      iframe.setAttribute('sandbox', '');` && |\n| &&
             `      try {` && |\n| &&
             `        iframe.srcdoc = ``<style>html,body{margin:0;padding:0}pre{margin:0;padding:8px;font-family:monospace;font-size:12px;white-space:pre-wrap;word-break:break-all}</style><pre>${escapeHtml(` && |\n| &&
             `          errorMessage,` && |\n| &&
             `        )}</pre>``;` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        _logError(``responseError: srcdoc assignment failed``, e);` && |\n| &&
             `      }` && |\n| &&
             `      errorContainer.appendChild(iframe);` && |\n| &&
             `` && |\n| &&
             `      // basic focus context for keyboard users; focus() can throw inside detached/closing windows` && |\n| &&
             `      try {` && |\n| &&
             `        refreshBtn.focus();` && |\n| &&
             `      } catch {` && |\n| &&
             `        /* focus is best-effort */` && |\n| &&
             `      }` && |\n| &&
             `    },` && |\n| &&
             `  };` && |\n| &&
             `});` && |\n| &&
             `` && |\n| &&
              ``.

  ENDMETHOD.

ENDCLASS.
