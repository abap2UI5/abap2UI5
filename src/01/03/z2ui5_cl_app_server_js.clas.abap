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

    result = `sap.ui.define(['sap/ui/core/BusyIndicator', 'sap/m/MessageBox'], (BusyIndicator, MessageBox) => {` && |\n| &&
             `  'use strict';` && |\n| &&
             `` && |\n| &&
             `  const ERROR_MAX_LENGTH = 50000;` && |\n| &&
             `  const FETCH_TIMEOUT_MS = 600000;` && |\n| &&
             `  const DEFAULT_LOGOUT_URL = '/sap/public/bc/icf/logoff';` && |\n| &&
             `  const _MSG_TYPES = ['S_MSG_TOAST', 'S_MSG_BOX'];` && |\n| &&
             `` && |\n| &&
             `  const _logError = (message, error) => {` && |\n| &&
             `    const entry = { message, ts: new Date().toISOString() };` && |\n| &&
             `    if (error !== undefined) entry.error = error;` && |\n| &&
             `    (z2ui5.errors ??= []).push(entry);` && |\n| &&
             `  };` && |\n| &&
             `` && |\n| &&
             `  const escapeHtml = (str) =>` && |\n| &&
             `    String(str).replace(` && |\n| &&
             `      /[&<>"']/g,` && |\n| &&
             `      (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' })[c],` && |\n| &&
             `    );` && |\n| &&
             `` && |\n| &&
             `  const resolveLogoutUrl = () => z2ui5.oConfig?.logoutUrl || DEFAULT_LOGOUT_URL;` && |\n| &&
             `` && |\n| &&
             `  return {` && |\n| &&
             `    endSession() {` && |\n| &&
             `      if (!z2ui5.contextId) return;` && |\n| &&
             `      // SAP convention: HEAD with sap-terminate header releases the stateful session.` && |\n| &&
             `      // Some reverse proxies may strip HEAD bodies — we rely on headers only.` && |\n| &&
             `      fetch(z2ui5.oConfig.pathname, {` && |\n| &&
             `        method: 'HEAD',` && |\n| &&
             `        keepalive: true,` && |\n| &&
             `        headers: {` && |\n| &&
             `          'sap-terminate': 'session',` && |\n| &&
             `          'sap-contextid': z2ui5.contextId,` && |\n| &&
             `          'sap-contextid-accept': 'header',` && |\n| &&
             `        },` && |\n| &&
             `      }).catch(() => {});` && |\n| &&
             `      delete z2ui5.contextId;` && |\n| &&
             `    },` && |\n| &&
             `    Roundtrip() {` && |\n| &&
             `      Object.assign(z2ui5, { checkNestAfter: false, checkNestAfter2: false });` && |\n| &&
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
             `      let response;` && |\n| &&
             `      const fetchOpts = {` && |\n| &&
             `        method: 'POST',` && |\n| &&
             `        headers: {` && |\n| &&
             `          'Content-Type': 'application/json',` && |\n| &&
             `          // CSRF: the abap2UI5 ICF handler relies on cookie-based session auth.` && |\n| &&
             `          // Apps requiring an x-csrf-token can inject it via z2ui5.oConfig before Roundtrip().` && |\n| &&
             `          'sap-contextid-accept': 'header',` && |\n| &&
             `          'sap-contextid': z2ui5.contextId ?? '',` && |\n| &&
             `        },` && |\n| &&
             `        body: JSON.stringify({ value: z2ui5.oBody }),` && |\n| &&
             `      };` && |\n| &&
             `      // AbortSignal.timeout is ES2022; older browsers fall back to no client-side timeout` && |\n| &&
             `      if (typeof AbortSignal !== 'undefined' && typeof AbortSignal.timeout === 'function') {` && |\n| &&
             `        fetchOpts.signal = AbortSignal.timeout(FETCH_TIMEOUT_MS);` && |\n| &&
             `      }` && |\n| &&
             `      try {` && |\n| &&
             `        response = await fetch(z2ui5.oConfig.pathname, fetchOpts);` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        this.responseError(``Network error: ${e.message}``);` && |\n| &&
             `        return;` && |\n| &&
             `      }` && |\n| &&
             `      // HTTP header lookup is case-insensitive per spec; only update when present so a` && |\n| &&
             `      // missing header does not blow away the existing context id` && |\n| &&
             `      const newCtx = response.headers.get('sap-contextid');` && |\n| &&
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
             `      try {` && |\n| &&
             `        z2ui5.oResponse = response;` && |\n| &&
             `        const params = response.PARAMS;` && |\n| &&
             `        const sView = params?.S_VIEW;` && |\n| &&
             `        if (sView?.CHECK_DESTROY) oController.ViewDestroy();` && |\n| &&
             `        const customJs = params?.S_FOLLOW_UP_ACTION?.CUSTOM_JS;` && |\n| &&
             `        if (customJs) {` && |\n| &&
             `          queueMicrotask(() => {` && |\n| &&
             `            for (const item of customJs) {` && |\n| &&
             `              if (oController.isDestroyed?.()) return;` && |\n| &&
             `              try {` && |\n| &&
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
             `      document.body.appendChild(container);` && |\n| &&
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
             `      iframe.srcdoc = ``<style>html,body{margin:0;padding:0}pre{margin:0;padding:8px;font-family:monospace;font-size:12px;white-space:pre-wrap;word-break:break-all}</style><pre>${escapeHtml(` && |\n| &&
             `        errorMessage,` && |\n| &&
             `      )}</pre>``;` && |\n| &&
             `      errorContainer.appendChild(iframe);` && |\n| &&
             `` && |\n| &&
             `      // basic focus context for keyboard users; not a full focus trap` && |\n| &&
             `      refreshBtn.focus();` && |\n| &&
             `    },` && |\n| &&
             `  };` && |\n| &&
             `});` && |\n| &&
             `` && |\n| &&
              ``.

  ENDMETHOD.

ENDCLASS.
