sap.ui.define(['sap/ui/core/BusyIndicator', 'sap/m/MessageBox'], (BusyIndicator, MessageBox) => {
  'use strict';

  const ERROR_MAX_LENGTH = 50000;
  const FETCH_TIMEOUT_MS = 600000;
  const DEFAULT_LOGOUT_URL = '/sap/public/bc/icf/logoff';
  const SAP_CONTEXTID_ACCEPT_HEADER = 'sap-contextid-accept';
  const SAP_CONTEXTID_ACCEPT_VALUE = 'header';
  const SAP_CONTEXTID_HEADER = 'sap-contextid';
  const _MSG_TYPES = ['S_MSG_TOAST', 'S_MSG_BOX'];
  const _ERRORS_CAP = 200;

  const _logError = (message, error) => {
    const entry = { message, ts: new Date().toISOString() };
    if (error !== undefined) entry.error = error;
    // Defensive: if z2ui5.errors got clobbered with a non-array, reset it
    if (!Array.isArray(z2ui5.errors)) z2ui5.errors = [];
    const arr = z2ui5.errors;
    arr.push(entry);
    // Single splice trims any overflow in one shot (O(n) shift loop replaced)
    if (arr.length > _ERRORS_CAP) arr.splice(0, arr.length - _ERRORS_CAP);
  };

  // Hoisted lookup table avoids re-allocating the object on every escape call
  const _ESCAPE_MAP = { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' };
  const _ESCAPE_RE = /[&<>"']/g;
  const escapeHtml = (str) => String(str).replace(_ESCAPE_RE, (c) => _ESCAPE_MAP[c]);

  const resolveLogoutUrl = () => z2ui5.oConfig?.logoutUrl || DEFAULT_LOGOUT_URL;

  return {
    endSession() {
      if (!z2ui5.contextId) return;
      const pathname = z2ui5.oConfig?.pathname;
      if (!pathname) {
        delete z2ui5.contextId;
        return;
      }
      // SAP convention: HEAD with sap-terminate header releases the stateful session.
      // Some reverse proxies may strip HEAD bodies — we rely on headers only.
      fetch(pathname, {
        method: 'HEAD',
        keepalive: true,
        headers: {
          'sap-terminate': 'session',
          [SAP_CONTEXTID_HEADER]: z2ui5.contextId,
          [SAP_CONTEXTID_ACCEPT_HEADER]: SAP_CONTEXTID_ACCEPT_VALUE,
        },
      }).catch(() => {});
      delete z2ui5.contextId;
    },
    Roundtrip() {
      // Direct assignments avoid one Object.assign call per roundtrip
      z2ui5.checkNestAfter = false;
      z2ui5.checkNestAfter2 = false;
      const oBody = (z2ui5.oBody ??= {});
      const args = oBody.ARGUMENTS ?? [];
      oBody.S_FRONT = {
        ID: oBody.ID,
        CONFIG: z2ui5.oConfig,
        ORIGIN: window.location.origin,
        PATHNAME: window.location.pathname,
        SEARCH: z2ui5.search || window.location.search,
        VIEW: oBody.VIEWNAME,
        EVENT: args[0]?.[0],
        HASH: window.location.hash,
      };
      const sFront = oBody.S_FRONT;
      const tEventArg = args.slice(1);
      if (tEventArg.length) sFront.T_EVENT_ARG = tEventArg;
      if (sFront.T_STARTUP_PARAMETERS === undefined) delete sFront.T_STARTUP_PARAMETERS;
      if (sFront.SEARCH === '') delete sFront.SEARCH;
      // Strip the source fields now that they have been promoted into S_FRONT
      delete oBody.ID;
      delete oBody.VIEWNAME;
      delete oBody.ARGUMENTS;
      if (!oBody.XX) delete oBody.XX;
      this.readHttp();
    },

    async readHttp() {
      const pathname = z2ui5.oConfig?.pathname;
      if (!pathname) {
        this.responseError(`Request aborted: z2ui5.oConfig.pathname is missing`);
        return;
      }
      let body;
      try {
        body = JSON.stringify({ value: z2ui5.oBody });
      } catch (e) {
        // Most likely a circular reference (e.g. UI5 control accidentally landed in the model)
        this.responseError(`Request serialisation failed: ${e.message}`);
        return;
      }
      let response;
      const fetchOpts = {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          // CSRF: the abap2UI5 ICF handler relies on cookie-based session auth.
          // Apps requiring an x-csrf-token can inject it via z2ui5.oConfig before Roundtrip().
          [SAP_CONTEXTID_ACCEPT_HEADER]: SAP_CONTEXTID_ACCEPT_VALUE,
          [SAP_CONTEXTID_HEADER]: z2ui5.contextId ?? '',
        },
        body,
      };
      // AbortSignal.timeout is ES2022; older browsers fall back to no client-side timeout
      if (typeof AbortSignal !== 'undefined' && typeof AbortSignal.timeout === 'function') {
        fetchOpts.signal = AbortSignal.timeout(FETCH_TIMEOUT_MS);
      }
      try {
        response = await fetch(pathname, fetchOpts);
      } catch (e) {
        // AbortError (or TimeoutError on newer browsers) means the timeout fired
        const isTimeout = e?.name === 'TimeoutError' || e?.name === 'AbortError';
        const prefix = isTimeout
          ? `Request timed out after ${Math.round(FETCH_TIMEOUT_MS / 1000)}s`
          : 'Network error';
        this.responseError(`${prefix}: ${e.message}`);
        return;
      }
      // HTTP header lookup is case-insensitive per spec; only update when present so a
      // missing header does not blow away the existing context id
      const newCtx = response.headers.get(SAP_CONTEXTID_HEADER);
      if (newCtx) z2ui5.contextId = newCtx;
      if (!response.ok) {
        let text;
        try {
          text = await response.text();
        } catch {
          text = `HTTP ${response.status}: could not read error body`;
        }
        this.responseError(text);
        return;
      }
      let responseData;
      try {
        responseData = await response.json();
      } catch (e) {
        this.responseError(`Invalid JSON response: ${e.message}`);
        return;
      }
      if (!responseData?.S_FRONT) {
        this.responseError(`Invalid response: missing S_FRONT`);
        return;
      }
      z2ui5.responseData = responseData;
      z2ui5.xxChangedPaths = new Set();
      const {
        S_FRONT: { ID, PARAMS },
        MODEL,
      } = responseData;
      this.responseSuccess({ ID, PARAMS, OVIEWMODEL: MODEL });
    },
    async responseSuccess(response) {
      const { oController } = z2ui5;
      // Bail early if the controller has been torn down between request and response —
      // every subsequent call (ViewDestroy, eF, showMessage, displayView) assumes it exists
      if (!oController) {
        BusyIndicator.hide();
        z2ui5.isBusy = false;
        _logError('responseSuccess: z2ui5.oController is missing — response discarded');
        return;
      }
      try {
        z2ui5.oResponse = response;
        const params = response.PARAMS;
        const sView = params?.S_VIEW;
        if (sView?.CHECK_DESTROY) oController.ViewDestroy();
        const customJs = params?.S_FOLLOW_UP_ACTION?.CUSTOM_JS;
        if (Array.isArray(customJs) && customJs.length) {
          queueMicrotask(() => {
            for (const item of customJs) {
              if (oController.isDestroyed?.()) return;
              if (typeof item !== 'string') {
                _logError(`customJs: item is not a string`, item);
                continue;
              }
              try {
                // Format: text'arg1'text'arg2'... — odd-indexed slices are the eF arguments
                const mParams = item.split("'");
                const mParamsEF = mParams.filter((_, index) => index % 2);
                if (mParamsEF.length) oController.eF(...mParamsEF);
                // Controlled eval of backend-provided JS expression
                else new Function('return ' + mParams[0])();
              } catch (e) {
                _logError(`customJs: execution failed`, e);
              }
            }
          });
        }
        for (const t of _MSG_TYPES) oController.showMessage(t, params);
        if (sView?.XML) {
          oController.ViewDestroy();
          await oController.displayView(sView.XML, response.OVIEWMODEL);
          return;
        }
        for (const [key, view] of [
          ['S_VIEW', z2ui5.oView],
          ['S_VIEW_NEST', z2ui5.oViewNest],
          ['S_VIEW_NEST2', z2ui5.oViewNest2],
          ['S_POPUP', z2ui5.oViewPopup],
          ['S_POPOVER', z2ui5.oViewPopover],
        ])
          oController.updateModelIfRequired(key, view);
        oController._processAfterRendering();
      } catch (e) {
        BusyIndicator.hide();
        z2ui5.isBusy = false;
        _logError(`responseSuccess: unexpected error`, e);
        const msg = e.message ?? '';
        if (msg.includes('openui5') && msg.includes('script load error')) {
          oController.checkSDKcompatibility(e);
        } else {
          MessageBox.error(e.message ?? String(e));
        }
      }
    },
    _getOrCreateErrorContainer() {
      const existing = document.getElementById('serverErrorContainer');
      if (existing) return existing;
      const container = Object.assign(document.createElement('div'), {
        id: 'serverErrorContainer',
        className: 'z2ui5-error-overlay',
      });
      // document.body can be momentarily null during pagehide; fall back to documentElement
      (document.body ?? document.documentElement).appendChild(container);
      return container;
    },
    responseError(response) {
      BusyIndicator.hide();
      z2ui5.isBusy = false;

      const full = String(response);
      const errorMessage =
        full.length > ERROR_MAX_LENGTH
          ? `${full.slice(0, ERROR_MAX_LENGTH)}\n\n<!-- Content truncated - too long -->`
          : full;

      const errorContainer = this._getOrCreateErrorContainer();
      errorContainer.replaceChildren();

      const headerDiv = Object.assign(document.createElement('div'), { className: 'z2ui5-error-overlay__header' });
      const h3 = Object.assign(document.createElement('h3'), {
        textContent: 'Server Error - Please Restart The App',
        className: 'z2ui5-error-overlay__title',
      });
      headerDiv.appendChild(h3);

      const actionsDiv = Object.assign(document.createElement('div'), { className: 'z2ui5-error-overlay__actions' });

      const refreshBtn = Object.assign(document.createElement('button'), {
        type: 'button',
        textContent: 'Refresh',
        className: 'z2ui5-error-overlay__btn',
      });
      refreshBtn.setAttribute('aria-label', 'Refresh page');
      refreshBtn.addEventListener('click', () => window.location.reload());
      actionsDiv.appendChild(refreshBtn);

      const logoutBtn = Object.assign(document.createElement('button'), {
        type: 'button',
        textContent: 'Logout',
        className: 'z2ui5-error-overlay__btn',
      });
      logoutBtn.setAttribute('aria-label', 'Logout from server');
      logoutBtn.addEventListener('click', () => {
        const redirectToLogoff = () => {
          window.location.href = resolveLogoutUrl();
        };
        try {
          if (z2ui5.oLaunchpad?.Container?.logout) {
            z2ui5.oLaunchpad.Container.logout();
          } else {
            redirectToLogoff();
          }
        } catch {
          redirectToLogoff();
        }
      });
      actionsDiv.appendChild(logoutBtn);

      headerDiv.appendChild(actionsDiv);
      errorContainer.appendChild(headerDiv);

      const iframe = Object.assign(document.createElement('iframe'), {
        id: 'errorIframe',
        className: 'z2ui5-error-overlay__iframe',
        title: 'Server error details',
      });
      // sandbox="" gives the iframe an opaque origin and blocks scripts/forms/popups.
      // srcdoc renders escaped, static <pre> content — no contentDocument access from parent needed.
      iframe.setAttribute('sandbox', '');
      try {
        iframe.srcdoc = `<style>html,body{margin:0;padding:0}pre{margin:0;padding:8px;font-family:monospace;font-size:12px;white-space:pre-wrap;word-break:break-all}</style><pre>${escapeHtml(
          errorMessage,
        )}</pre>`;
      } catch (e) {
        _logError(`responseError: srcdoc assignment failed`, e);
      }
      errorContainer.appendChild(iframe);

      // basic focus context for keyboard users; focus() can throw inside detached/closing windows
      try {
        refreshBtn.focus();
      } catch {
        /* focus is best-effort */
      }
    },
  };
});
