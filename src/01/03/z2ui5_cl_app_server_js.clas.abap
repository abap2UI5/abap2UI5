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
             `  const _MSG_TYPES = ['S_MSG_TOAST', 'S_MSG_BOX'];` && |\n| &&
             `` && |\n| &&
             `  return {` && |\n| &&
             `    endSession() {` && |\n| &&
             `      if (z2ui5.contextId) {` && |\n| &&
             `        fetch(z2ui5.oConfig.pathname, {` && |\n| &&
             `          method: 'HEAD',` && |\n| &&
             `          keepalive: true,` && |\n| &&
             `          headers: {` && |\n| &&
             `            'sap-terminate': 'session',` && |\n| &&
             `            'sap-contextid': z2ui5.contextId,` && |\n| &&
             `            'sap-contextid-accept': 'header',` && |\n| &&
             `          },` && |\n| &&
             `        }).catch(() => {});` && |\n| &&
             `        delete z2ui5.contextId;` && |\n| &&
             `      }` && |\n| &&
             `    },` && |\n| &&
             `    Roundtrip() {` && |\n| &&
             `      z2ui5.checkTimerActive = z2ui5.checkNestAfter = z2ui5.checkNestAfter2 = false;` && |\n| &&
             `      const oBody = (z2ui5.oBody ??= {});` && |\n| &&
             `      oBody.S_FRONT = {` && |\n| &&
             `        ID: oBody.ID,` && |\n| &&
             `        CONFIG: z2ui5.oConfig,` && |\n| &&
             `        ORIGIN: window.location.origin,` && |\n| &&
             `        PATHNAME: window.location.pathname,` && |\n| &&
             `        SEARCH: z2ui5.search || window.location.search,` && |\n| &&
             `        VIEW: oBody.VIEWNAME,` && |\n| &&
             `        EVENT: oBody.ARGUMENTS?.[0]?.[0],` && |\n| &&
             `        HASH: window.location.hash,` && |\n| &&
             `      };` && |\n| &&
             `      const sFront = oBody.S_FRONT;` && |\n| &&
             `      oBody.ARGUMENTS?.shift();` && |\n| &&
             `      sFront.T_EVENT_ARG = oBody.ARGUMENTS;` && |\n| &&
             `      delete oBody.ID;` && |\n| &&
             `      delete oBody.VIEWNAME;` && |\n| &&
             `      delete oBody.ARGUMENTS;` && |\n| &&
             `      if (!sFront.T_EVENT_ARG?.length) delete sFront.T_EVENT_ARG;` && |\n| &&
             `      if (sFront.T_STARTUP_PARAMETERS === undefined) delete sFront.T_STARTUP_PARAMETERS;` && |\n| &&
             `      if (sFront.SEARCH === '') delete sFront.SEARCH;` && |\n| &&
             `      if (!oBody.XX) delete oBody.XX;` && |\n| &&
             `      this.readHttp();` && |\n| &&
             `    },` && |\n| &&
             `` && |\n| &&
             `    async readHttp() {` && |\n| &&
             `      let response;` && |\n| &&
             `      try {` && |\n| &&
             `        response = await fetch(z2ui5.oConfig.pathname, {` && |\n| &&
             `          method: 'POST',` && |\n| &&
             `          headers: {` && |\n| &&
             `            'Content-Type': 'application/json',` && |\n| &&
             `            'sap-contextid-accept': 'header',` && |\n| &&
             `            'sap-contextid': z2ui5.contextId ?? '',` && |\n| &&
             `          },` && |\n| &&
             `          body: JSON.stringify({ value: z2ui5.oBody }),` && |\n| &&
             `        });` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        this.responseError(``Network error: ${e.message}``);` && |\n| &&
             `        return;` && |\n| &&
             `      }` && |\n| &&
             `      z2ui5.contextId = response.headers.get('sap-contextid');` && |\n| &&
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
             `            if (oController.isDestroyed?.()) return;` && |\n| &&
             `            for (const item of customJs) {` && |\n| &&
             `              try {` && |\n| &&
             `                const mParams = item.split("'");` && |\n| &&
             `                const mParamsEF = mParams.filter((_, index) => index % 2);` && |\n| &&
             `                if (mParamsEF.length) oController.eF(...mParamsEF);` && |\n| &&
             `                else Function('return ' + mParams[0])();` && |\n| &&
             `              } catch (e) {` && |\n| &&
             `                (z2ui5.errors ??= []).push({` && |\n| &&
             `                  message: ``customJs: execution failed``,` && |\n| &&
             `                  error: e,` && |\n| &&
             `                  ts: new Date().toISOString(),` && |\n| &&
             `                });` && |\n| &&
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
             `        (z2ui5.errors ??= []).push({` && |\n| &&
             `          message: ``responseSuccess: unexpected error``,` && |\n| &&
             `          error: e,` && |\n| &&
             `          ts: new Date().toISOString(),` && |\n| &&
             `        });` && |\n| &&
             `        const msg = e.message ?? '';` && |\n| &&
             `        if (msg.includes('openui5') && msg.includes('script load error')) {` && |\n| &&
             `          oController.checkSDKcompatibility(e);` && |\n| &&
             `        } else {` && |\n| &&
             `          MessageBox.error(e.toLocaleString());` && |\n| &&
             `        }` && |\n| &&
             `      }` && |\n| &&
             `    },` && |\n| &&
             `    _getOrCreateErrorContainer() {` && |\n| &&
             `      const existing = document.getElementById('serverErrorContainer');` && |\n| &&
             `      if (existing) return existing;` && |\n| &&
             `      const container = Object.assign(document.createElement('div'), { id: 'serverErrorContainer' });` && |\n| &&
             `      container.style.cssText = ``` && |\n| &&
             `          position: fixed;` && |\n| &&
             `          top: 50%;` && |\n| &&
             `          left: 50%;` && |\n| &&
             `          transform: translate(-50%, -50%);` && |\n| &&
             `          width: 90%;` && |\n| &&
             `          height: 90%;` && |\n| &&
             `          background: white;` && |\n| &&
             `          border: 2px solid #d32f2f;` && |\n| &&
             `          border-radius: 4px;` && |\n| &&
             `          box-shadow: 0 4px 6px rgba(0,0,0,0.3);` && |\n| &&
             `          z-index: 9999;` && |\n| &&
             `          display: flex;` && |\n| &&
             `          flex-direction: column;` && |\n| &&
             `        ``;` && |\n| &&
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
             `      errorContainer.textContent = '';` && |\n| &&
             `` && |\n| &&
             `      const headerDiv = document.createElement('div');` && |\n| &&
             `      headerDiv.style.cssText =` && |\n| &&
             `        'padding: 15px; background: #d32f2f; color: white; display: flex; justify-content: space-between; align-items: center;';` && |\n| &&
             `      const h3 = Object.assign(document.createElement('h3'), { textContent: 'Server Error - Please Restart The App' });` && |\n| &&
             `      h3.style.cssText = 'margin: 0';` && |\n| &&
             `      headerDiv.appendChild(h3);` && |\n| &&
             `` && |\n| &&
             `      const btnStyle =` && |\n| &&
             `        'padding: 6px 14px; background: white; color: #d32f2f; border: none; border-radius: 3px; cursor: pointer; font-weight: bold;';` && |\n| &&
             `` && |\n| &&
             `      const actionsDiv = document.createElement('div');` && |\n| &&
             `      actionsDiv.style.cssText = 'display: flex; gap: 8px;';` && |\n| &&
             `` && |\n| &&
             `      const refreshBtn = Object.assign(document.createElement('button'), { type: 'button', textContent: 'Refresh' });` && |\n| &&
             `      refreshBtn.style.cssText = btnStyle;` && |\n| &&
             `      refreshBtn.addEventListener('click', () => window.location.reload());` && |\n| &&
             `      actionsDiv.appendChild(refreshBtn);` && |\n| &&
             `` && |\n| &&
             `      const logoutBtn = Object.assign(document.createElement('button'), { type: 'button', textContent: 'Logout' });` && |\n| &&
             `      logoutBtn.style.cssText = btnStyle;` && |\n| &&
             `      logoutBtn.addEventListener('click', () => {` && |\n| &&
             `        try {` && |\n| &&
             `          const container = sap.ushell?.Container;` && |\n| &&
             `          if (container?.logout) {` && |\n| &&
             `            container.logout();` && |\n| &&
             `            return;` && |\n| &&
             `          }` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          // fall through to redirect` && |\n| &&
             `        }` && |\n| &&
             `        window.location.href = '/sap/public/bc/icf/logoff';` && |\n| &&
             `      });` && |\n| &&
             `      actionsDiv.appendChild(logoutBtn);` && |\n| &&
             `` && |\n| &&
             `      headerDiv.appendChild(actionsDiv);` && |\n| &&
             `` && |\n| &&
             `      errorContainer.appendChild(headerDiv);` && |\n| &&
             `` && |\n| &&
             `      const iframe = Object.assign(document.createElement('iframe'), { id: 'errorIframe' });` && |\n| &&
             `      iframe.style.cssText = 'width: 100%; height: 100%; border: none; flex: 1;';` && |\n| &&
             `      iframe.setAttribute('sandbox', 'allow-same-origin');` && |\n| &&
             `      errorContainer.appendChild(iframe);` && |\n| &&
             `` && |\n| &&
             `      const { contentDocument } = iframe;` && |\n| &&
             `      if (contentDocument) {` && |\n| &&
             `        const pre = contentDocument.createElement('pre');` && |\n| &&
             `        pre.style.cssText =` && |\n| &&
             `          'margin:0;padding:8px;font-family:monospace;font-size:12px;white-space:pre-wrap;word-break:break-all;';` && |\n| &&
             `        pre.textContent = errorMessage;` && |\n| &&
             `        (contentDocument.body || contentDocument.documentElement).appendChild(pre);` && |\n| &&
             `      }` && |\n| &&
             `    },` && |\n| &&
             `  };` && |\n| &&
             `});` && |\n| &&
             `` && |\n| &&
              ``.

  ENDMETHOD.

ENDCLASS.
