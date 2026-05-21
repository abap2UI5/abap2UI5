sap.ui.define(
  ["sap/ui/core/BusyIndicator", "sap/m/MessageBox"],
  (BusyIndicator, MessageBox) => {
    "use strict";

    // Errors longer than this are truncated before being shown to the user,
    // so a stack trace from the backend cannot blow up the error overlay.
    const ERROR_MAX_LENGTH = 50000;
    const _MSG_TYPES = Object.freeze(["S_MSG_TOAST", "S_MSG_BOX"]);

    // Append an entry to the global error log. We create the array on first use.
    function logError(message, error) {
      if (!z2ui5.errors) z2ui5.errors = [];
      z2ui5.errors.push({
        message: message,
        error: error,
        ts: new Date().toISOString(),
      });
    }

    return {
      endSession() {
        if (!z2ui5.contextId) return;
        // Best-effort notify the backend that the session ends. Errors are
        // intentionally swallowed: the browser tab is closing anyway.
        fetch(z2ui5.oConfig.pathname, {
          method: "HEAD",
          keepalive: true,
          headers: {
            "sap-terminate": "session",
            "sap-contextid": z2ui5.contextId,
            "sap-contextid-accept": "header",
          },
        }).catch(() => {});
        delete z2ui5.contextId;
      },

      Roundtrip() {
        z2ui5.checkTimerActive = false;
        z2ui5.checkNestAfter = false;
        z2ui5.checkNestAfter2 = false;

        if (!z2ui5.oBody) z2ui5.oBody = {};
        const oBody = z2ui5.oBody;

        // Pick the first event argument (event name) safely.
        let eventName;
        if (oBody.ARGUMENTS && oBody.ARGUMENTS[0]) {
          eventName = oBody.ARGUMENTS[0][0];
        }

        oBody.S_FRONT = {
          ID: oBody.ID,
          CONFIG: z2ui5.oConfig,
          ORIGIN: window.location.origin,
          PATHNAME: window.location.pathname,
          SEARCH: z2ui5.search || window.location.search,
          VIEW: oBody.VIEWNAME,
          EVENT: eventName,
          HASH: window.location.hash,
        };
        const sFront = oBody.S_FRONT;

        // The first argument was the event name (already stored as EVENT),
        // the remaining entries are the actual event arguments.
        if (oBody.ARGUMENTS) oBody.ARGUMENTS.shift();
        sFront.T_EVENT_ARG = oBody.ARGUMENTS;

        delete oBody.ID;
        delete oBody.VIEWNAME;
        delete oBody.ARGUMENTS;

        // Remove empty / undefined fields so the backend request stays small
        // and these keys are not present in the JSON sent over the wire.
        if (!sFront.T_EVENT_ARG || sFront.T_EVENT_ARG.length === 0) {
          delete sFront.T_EVENT_ARG;
        }
        if (sFront.SEARCH === "") delete sFront.SEARCH;
        if (!oBody.XX) delete oBody.XX;

        this.readHttp();
      },

      async readHttp() {
        // Step 1: send the request.
        let response;
        try {
          response = await fetch(z2ui5.oConfig.pathname, {
            method: "POST",
            headers: {
              "Content-Type": "application/json",
              "sap-contextid-accept": "header",
              "sap-contextid": z2ui5.contextId || "",
            },
            body: JSON.stringify({ value: z2ui5.oBody }),
          });
        } catch (e) {
          this.responseError(`Network error: ${e.message}`);
          return;
        }
        z2ui5.contextId = response.headers.get("sap-contextid");

        // Step 2: if the HTTP status is not 2xx, treat the body as error text.
        if (!response.ok) {
          let text;
          try {
            text = await response.text();
          } catch (e) {
            text = `HTTP ${response.status}: could not read error body`;
          }
          this.responseError(text);
          return;
        }

        // Step 3: parse the JSON body.
        let responseData;
        try {
          responseData = await response.json();
        } catch (e) {
          this.responseError(`Invalid JSON response: ${e.message}`);
          return;
        }
        if (!responseData || !responseData.S_FRONT) {
          this.responseError("Invalid response: missing S_FRONT");
          return;
        }

        // Step 4: hand the parsed response to the success handler.
        z2ui5.responseData = responseData;
        z2ui5.xxChangedPaths = new Set();
        this.responseSuccess({
          ID: responseData.S_FRONT.ID,
          PARAMS: responseData.S_FRONT.PARAMS,
          OVIEWMODEL: responseData.MODEL,
        });
      },

      async responseSuccess(response) {
        const oController = z2ui5.oController;
        try {
          z2ui5.oResponse = response;
          const params = response.PARAMS;
          const sView = params && params.S_VIEW;

          if (sView && sView.CHECK_DESTROY) oController.ViewDestroy();

          // The backend can send small JS snippets to run after the response.
          // Each snippet is either a literal expression or an "eF(...)" call
          // whose arguments are wrapped in single quotes.
          const followUp = params && params.S_FOLLOW_UP_ACTION;
          const customJs = followUp && followUp.CUSTOM_JS;
          if (customJs) {
            queueMicrotask(() => {
              if (oController.isDestroyed && oController.isDestroyed()) return;
              for (const item of customJs) {
                this._runCustomJs(item, oController);
              }
            });
          }

          for (const t of _MSG_TYPES) oController.showMessage(t, params);

          // Full view replacement -> destroy & rebuild, nothing more to do.
          if (sView && sView.XML) {
            oController.ViewDestroy();
            await oController.displayView(sView.XML, response.OVIEWMODEL);
            return;
          }

          // Partial response: refresh whichever existing views the backend
          // sent updates for.
          const updateTargets = [
            ["S_VIEW", z2ui5.oView],
            ["S_VIEW_NEST", z2ui5.oViewNest],
            ["S_VIEW_NEST2", z2ui5.oViewNest2],
            ["S_POPUP", z2ui5.oViewPopup],
            ["S_POPOVER", z2ui5.oViewPopover],
          ];
          for (const [key, view] of updateTargets) {
            oController.updateModelIfRequired(key, view);
          }
          oController._processAfterRendering();
        } catch (e) {
          BusyIndicator.hide();
          z2ui5.isBusy = false;
          logError("responseSuccess: unexpected error", e);
          const msg = e.message || "";
          if (msg.includes("openui5") && msg.includes("script load error")) {
            oController.checkSDKcompatibility(e);
          } else {
            MessageBox.error(e.toLocaleString());
          }
        }
      },

      // Executes a single custom-JS snippet from the backend.
      // Format A:  "alert(123)"           -> runs the expression
      // Format B:  "eF('A','B','C')"      -> calls oController.eF('A','B','C')
      _runCustomJs(item, oController) {
        try {
          const parts = item.split("'");
          // Arguments live at the odd indices between single quotes.
          const args = parts.filter((_, index) => index % 2 === 1);
          if (args.length > 0) {
            oController.eF(...args);
          } else {
            // eslint-disable-next-line no-new-func
            Function("return " + parts[0])();
          }
        } catch (e) {
          logError("customJs: execution failed", e);
        }
      },

      _getOrCreateErrorContainer() {
        const existing = document.getElementById("serverErrorContainer");
        if (existing) return existing;

        const container = document.createElement("div");
        container.id = "serverErrorContainer";
        container.style.cssText = `
          position: fixed;
          top: 50%;
          left: 50%;
          transform: translate(-50%, -50%);
          width: 90%;
          height: 90%;
          background: white;
          border: 2px solid #d32f2f;
          border-radius: 4px;
          box-shadow: 0 4px 6px rgba(0,0,0,0.3);
          z-index: 9999;
          display: flex;
          flex-direction: column;
        `;
        document.body.appendChild(container);
        return container;
      },

      responseError(response) {
        BusyIndicator.hide();
        z2ui5.isBusy = false;

        const full = String(response);
        let errorMessage;
        if (full.length > ERROR_MAX_LENGTH) {
          errorMessage =
            full.slice(0, ERROR_MAX_LENGTH) +
            "\n\n<!-- Content truncated - too long -->";
        } else {
          errorMessage = full;
        }

        const errorContainer = this._getOrCreateErrorContainer();
        errorContainer.textContent = "";

        // Header bar with title and action buttons.
        const headerDiv = document.createElement("div");
        headerDiv.style.cssText =
          "padding: 15px; background: #d32f2f; color: white; display: flex; justify-content: space-between; align-items: center;";

        const h3 = document.createElement("h3");
        h3.textContent = "Server Error - Please Restart The App";
        h3.style.cssText = "margin: 0";
        headerDiv.appendChild(h3);

        const btnStyle =
          "padding: 6px 14px; background: white; color: #d32f2f; border: none; border-radius: 3px; cursor: pointer; font-weight: bold;";

        const actionsDiv = document.createElement("div");
        actionsDiv.style.cssText = "display: flex; gap: 8px;";

        const refreshBtn = document.createElement("button");
        refreshBtn.type = "button";
        refreshBtn.textContent = "Refresh";
        refreshBtn.style.cssText = btnStyle;
        refreshBtn.addEventListener("click", () => window.location.reload());
        actionsDiv.appendChild(refreshBtn);

        const logoutBtn = document.createElement("button");
        logoutBtn.type = "button";
        logoutBtn.textContent = "Logout";
        logoutBtn.style.cssText = btnStyle;
        logoutBtn.addEventListener("click", () => this._handleLogout());
        actionsDiv.appendChild(logoutBtn);

        headerDiv.appendChild(actionsDiv);
        errorContainer.appendChild(headerDiv);

        // The error text itself lives inside a sandboxed iframe so any HTML
        // in the backend response cannot execute or affect the main page.
        const iframe = document.createElement("iframe");
        iframe.id = "errorIframe";
        iframe.style.cssText =
          "width: 100%; height: 100%; border: none; flex: 1;";
        iframe.setAttribute("sandbox", "allow-same-origin");
        errorContainer.appendChild(iframe);

        const contentDocument = iframe.contentDocument;
        if (contentDocument) {
          const pre = contentDocument.createElement("pre");
          pre.style.cssText =
            "margin:0;padding:8px;font-family:monospace;font-size:12px;white-space:pre-wrap;word-break:break-all;";
          pre.textContent = errorMessage;
          const target =
            contentDocument.body || contentDocument.documentElement;
          target.appendChild(pre);
        }
      },

      // Logout via the launchpad if available; otherwise hit the SAP logoff URL.
      _handleLogout() {
        const fallback = () => {
          window.location.href = "/sap/public/bc/icf/logoff";
        };
        try {
          const launchpadLogout =
            z2ui5.oLaunchpad &&
            z2ui5.oLaunchpad.Container &&
            z2ui5.oLaunchpad.Container.logout;
          if (launchpadLogout) {
            z2ui5.oLaunchpad.Container.logout();
          } else {
            fallback();
          }
        } catch (e) {
          fallback();
        }
      },
    };
  },
);
