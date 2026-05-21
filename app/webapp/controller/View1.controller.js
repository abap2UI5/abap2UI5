sap.ui.define(
  [
    "sap/ui/core/mvc/Controller",
    "sap/ui/core/mvc/XMLView",
    "sap/ui/model/json/JSONModel",
    "sap/ui/core/BusyIndicator",
    "sap/m/MessageBox",
    "sap/m/MessageToast",
    "sap/ui/core/Fragment",
    "sap/m/BusyDialog",
    "sap/ui/VersionInfo",
    "z2ui5/cc/Server",
    "sap/ui/model/odata/v2/ODataModel",
    "sap/m/library",
    "sap/ui/core/routing/HashChanger",
    "sap/ui/util/Storage",
    "sap/ui/core/Element",
    "sap/ui/core/Rendering",
  ],
  (
    Controller,
    XMLView,
    JSONModel,
    BusyIndicator,
    MessageBox,
    MessageToast,
    Fragment,
    mBusyDialog,
    VersionInfo,
    Server,
    ODataModel,
    mobileLibrary,
    HashChanger,
    Storage,
    Element,
    Rendering,
  ) => {
    "use strict";

    // ------------------------------------------------------------------
    // Small utility helpers (module-private)
    // ------------------------------------------------------------------

    // Append an entry to the global error log. We create the array on first use.
    function logError(message, error) {
      if (!z2ui5.errors) z2ui5.errors = [];
      const entry = { message: message, ts: new Date().toISOString() };
      if (error !== undefined) entry.error = error;
      z2ui5.errors.push(entry);
    }

    // Run every callback in `arr`, swallowing individual failures so one bad
    // callback cannot break the whole event sequence.
    function runCallbacks(arr, ...args) {
      if (!arr) return;
      for (const fn of arr) {
        if (!fn) continue;
        try {
          fn(...args);
        } catch (e) {
          logError("runCallbacks: callback failed", e);
        }
      }
    }

    // Parse a value as integer milliseconds, falling back to `def` when the
    // input is empty / undefined.
    function parseMs(val, def) {
      return val ? +val : def;
    }

    // DOM helpers reused across calls; kept as module-level singletons.
    const _msgParser = new DOMParser();
    const _sanitizeEl = document.createElement("div");
    const _hashChanger = HashChanger.getInstance();
    const _URLHelper = mobileLibrary.URLHelper;
    const _SAFE_PROTOCOLS = new Set(["http:", "https:"]);

    // ------------------------------------------------------------------
    // Security helpers
    // ------------------------------------------------------------------

    // Returns true only if the URL is on the same origin and uses http/https.
    function isValidRedirectURL(url) {
      if (!url) return false;
      try {
        const parsed = new URL(url, window.location.origin);
        if (parsed.origin !== window.location.origin) {
          logError(`Security: Blocked redirect to different origin: ${url}`);
          return false;
        }
        if (!_SAFE_PROTOCOLS.has(parsed.protocol)) {
          logError(
            `Security: Blocked redirect with invalid protocol: ${parsed.protocol}`,
          );
          return false;
        }
        return true;
      } catch (e) {
        logError(`Security: Invalid URL format: ${url}`, e);
        return false;
      }
    }

    function copyToClipboard(textToCopy) {
      if (!navigator.clipboard || !navigator.clipboard.writeText) {
        logError("Clipboard: writeText API not available");
        return;
      }
      navigator.clipboard
        .writeText(textToCopy)
        .catch((err) => logError("Clipboard: writeText failed", err));
    }

    // Turns an HTML "details" snippet from the backend into safe HTML.
    // Bullet lists are preserved; everything else is reduced to plain text.
    function sanitizeMessageDetails(html) {
      const doc = _msgParser.parseFromString(html, "text/html");
      const items = Array.from(doc.querySelectorAll("li"));
      if (items.length > 0) {
        const safeItems = items.map((li) => {
          _sanitizeEl.textContent = li.textContent;
          return `<li>${_sanitizeEl.innerHTML}</li>`;
        });
        return `<ul>${safeItems.join("")}</ul>`;
      }
      _sanitizeEl.textContent = doc.body.textContent;
      return _sanitizeEl.innerHTML;
    }

    // ------------------------------------------------------------------
    // Launchpad / NavContainer helpers
    // ------------------------------------------------------------------

    function withCrossAppNavigator(callback) {
      const nav = z2ui5.oLaunchpad && z2ui5.oLaunchpad.CrossAppNavigator;
      if (!nav) {
        logError("CrossAppNav: not running inside Launchpad");
        return;
      }
      try {
        callback(nav);
      } catch (e) {
        logError("CrossAppNav: callback failed", e);
      }
    }

    function navigateContainer(lookup, args) {
      try {
        const container = lookup(args[1]);
        if (container) container.to(lookup(args[2]));
      } catch (e) {
        logError("navigateContainer: navigation failed", e);
      }
    }

    // Lookup tables mapping event names / param keys to the right view.
    const navContainerLookups = {
      NAV_CONTAINER_TO: (id) => z2ui5.oView && z2ui5.oView.byId(id),
      NEST_NAV_CONTAINER_TO: (id) =>
        z2ui5.oViewNest && z2ui5.oViewNest.byId(id),
      NEST2_NAV_CONTAINER_TO: (id) =>
        z2ui5.oViewNest2 && z2ui5.oViewNest2.byId(id),
      POPUP_NAV_CONTAINER_TO: (id) => Fragment.byId("popupId", id),
      POPOVER_NAV_CONTAINER_TO: (id) => Fragment.byId("popoverId", id),
    };

    const viewLookups = {
      MAIN: () => z2ui5.oView,
      NEST: () => z2ui5.oViewNest,
      NEST2: () => z2ui5.oViewNest2,
      POPUP: () => z2ui5.oViewPopup,
      POPOVER: () => z2ui5.oViewPopover,
    };

    const paramToViewKey = {
      S_VIEW: "MAIN",
      S_VIEW_NEST: "NEST",
      S_VIEW_NEST2: "NEST2",
      S_POPUP: "POPUP",
      S_POPOVER: "POPOVER",
    };

    function applyStoredSizeLimit(viewKey, oModel) {
      if (!oModel || !z2ui5.viewSizeLimits) return;
      const limit = z2ui5.viewSizeLimits[viewKey];
      if (limit !== undefined) oModel.setSizeLimit(limit);
    }

    return Controller.extend("z2ui5.controller.View1", {
      // ------------------------------------------------------------------
      // Model change tracking - remembers which /XX/ paths the user edited
      // so the next roundtrip only ships the delta.
      // ------------------------------------------------------------------
      _trackChanges(oModel) {
        oModel.attachPropertyChange((e) => {
          const params = e.getParameters();
          const raw = params.path;
          const ctx = params.context;
          if (!raw) return;
          // Resolve relative paths against the binding context.
          let p;
          if (ctx && !raw.startsWith("/")) {
            p = `${ctx.getPath()}/${raw}`;
          } else {
            p = raw;
          }
          if (p.startsWith("/XX/")) {
            if (!z2ui5.xxChangedPaths) z2ui5.xxChangedPaths = new Set();
            z2ui5.xxChangedPaths.add(p);
          }
        });
        return oModel;
      },

      onInit() {
        z2ui5.oRouter.attachRouteMatched(() => {
          z2ui5.checkInit = true;
          Server.Roundtrip();
        });
      },

      onAfterRendering() {
        if (z2ui5.oResponse && !z2ui5.oResponse._processed) {
          this._processAfterRendering();
        }
      },

      // Runs once after each roundtrip's view has been rendered. Handles
      // popups, nested views, popovers and browser-history updates.
      async _processAfterRendering() {
        try {
          const oResponse = z2ui5.oResponse;
          if (oResponse._processed) return;
          oResponse._processed = true;

          const PARAMS = oResponse.PARAMS;
          const ID = oResponse.ID;
          if (!PARAMS) return;

          const S_POPUP = PARAMS.S_POPUP;
          const S_VIEW_NEST = PARAMS.S_VIEW_NEST;
          const S_VIEW_NEST2 = PARAMS.S_VIEW_NEST2;
          const S_POPOVER = PARAMS.S_POPOVER;
          const SET_APP_STATE_ACTIVE = PARAMS.SET_APP_STATE_ACTIVE;
          const SET_PUSH_STATE = PARAMS.SET_PUSH_STATE;
          const SET_NAV_BACK = PARAMS.SET_NAV_BACK;

          if (S_POPUP && S_POPUP.CHECK_DESTROY) this.PopupDestroy();
          if (S_POPOVER && S_POPOVER.CHECK_DESTROY) this.PopoverDestroy();

          if (S_POPUP && S_POPUP.XML) {
            this.PopupDestroy();
            await this.displayFragment(S_POPUP.XML, "oViewPopup");
          }

          if (!z2ui5.checkNestAfter && S_VIEW_NEST && S_VIEW_NEST.XML) {
            this.NestViewDestroy();
            await this.displayNestedView(
              S_VIEW_NEST.XML,
              "oViewNest",
              "S_VIEW_NEST",
              z2ui5.oControllerNest,
            );
            z2ui5.checkNestAfter = true;
          }

          if (!z2ui5.checkNestAfter2 && S_VIEW_NEST2 && S_VIEW_NEST2.XML) {
            this.NestViewDestroy2();
            await this.displayNestedView(
              S_VIEW_NEST2.XML,
              "oViewNest2",
              "S_VIEW_NEST2",
              z2ui5.oControllerNest2,
            );
            z2ui5.checkNestAfter2 = true;
          }

          if (S_POPOVER && S_POPOVER.XML) {
            this.PopoverDestroy();
            await this.displayPopover(
              S_POPOVER.XML,
              "oViewPopover",
              S_POPOVER.OPEN_BY_ID,
            );
          }

          // Build the state object stored in history.state, so a future
          // popstate can restore the current view without a backend hit.
          const oView = z2ui5.oView;
          let oState = {};
          if (oView) {
            const model = oView.getModel();
            oState = {
              view: oView.mProperties.viewContent,
              model: model ? model.getData() : undefined,
              response: z2ui5.oResponse,
            };
          }

          try {
            if (SET_PUSH_STATE) {
              const hash = _hashChanger.getHash();
              const newUrl = `${window.location.pathname}${window.location.search}#${hash}${SET_PUSH_STATE}`;
              history.pushState(oState, "", newUrl);
            } else {
              history.replaceState(oState, "", window.location.href);
            }
            const newHash = SET_APP_STATE_ACTIVE
              ? `z2ui5-xapp-state=${ID || ""}`
              : "";
            _hashChanger.replaceHash(newHash);
          } catch (e) {
            logError("_processAfterRendering: history update failed", e);
          }

          if (SET_NAV_BACK) history.back();

          runCallbacks(z2ui5.onAfterRendering);
        } catch (e) {
          logError("_processAfterRendering: unexpected error", e);
          MessageBox.error(e.toLocaleString(), {
            title: "Unexpected Error Occurred - App Terminated",
            actions: [],
            onClose: () =>
              new mBusyDialog({ text: "Please Restart the App" }).open(),
          });
        } finally {
          BusyIndicator.hide();
          z2ui5.isBusy = false;
        }
      },

      // Build the delta object sent to the backend. `paths` is the set of
      // /XX/... paths that the user edited; `xx` is the full XX model data.
      _buildDeltaFromPaths(paths, xx) {
        const delta = {};
        for (const path of paths) {
          // path looks like "/XX/<attr>" or "/XX/<attr>/<row>/<field>"
          const [attr, rowIdx, field] = path.slice(4).split("/");
          const isRowField =
            field !== undefined && rowIdx !== "" && !isNaN(rowIdx);
          if (isRowField) {
            // Table cell change -> ship only the changed cell.
            if (!delta[attr] || !delta[attr].__delta) {
              delta[attr] = { __delta: {} };
            }
            const attrDelta = delta[attr].__delta;
            if (!attrDelta[rowIdx]) attrDelta[rowIdx] = {};
            const row = xx[attr] && xx[attr][+rowIdx];
            attrDelta[rowIdx][field] = row ? row[field] : undefined;
          } else {
            // Scalar change -> ship the whole attribute.
            delta[attr] = xx[attr];
          }
        }
        return delta;
      },

      _createViewModel() {
        const data = z2ui5.oResponse && z2ui5.oResponse.OVIEWMODEL;
        return this._trackChanges(new JSONModel(data));
      },

      // ------------------------------------------------------------------
      // Display: popups, popovers, nested views, main view
      // ------------------------------------------------------------------

      async displayFragment(xml, viewProp) {
        const oModel = this._createViewModel();
        applyStoredSizeLimit("POPUP", oModel);
        const oFragment = await Fragment.load({
          definition: xml,
          controller: z2ui5.oControllerPopup,
          id: "popupId",
        });
        // The app might have been torn down while the fragment loaded.
        const appAlive =
          z2ui5.oApp && (!z2ui5.oApp.isDestroyed || !z2ui5.oApp.isDestroyed());
        if (!appAlive) {
          oFragment.destroy();
          return;
        }
        oFragment.setModel(oModel);
        oFragment.Fragment = Fragment;
        z2ui5[viewProp] = oFragment;
        oFragment.open();
      },

      async displayPopover(xml, viewProp, openById) {
        try {
          const oModel = this._createViewModel();
          applyStoredSizeLimit("POPOVER", oModel);
          const oFragment = await Fragment.load({
            definition: xml,
            controller: z2ui5.oControllerPopover,
            id: "popoverId",
          });
          const appAlive =
            z2ui5.oApp &&
            (!z2ui5.oApp.isDestroyed || !z2ui5.oApp.isDestroyed());
          if (!appAlive) {
            oFragment.destroy();
            return;
          }
          oFragment.setModel(oModel);
          oFragment.Fragment = Fragment;

          // Find the control to attach the popover to. We search the main
          // view first, then any open popup / nested views, then the global
          // UI5 control registry as a last resort.
          let oControl = z2ui5.oView && z2ui5.oView.byId(openById);
          if (!oControl && z2ui5.oViewPopup && z2ui5.oViewPopup.Fragment) {
            oControl = z2ui5.oViewPopup.Fragment.byId("popupId", openById);
          }
          if (!oControl && z2ui5.oViewNest) {
            oControl = z2ui5.oViewNest.byId(openById);
          }
          if (!oControl && z2ui5.oViewNest2) {
            oControl = z2ui5.oViewNest2.byId(openById);
          }
          if (!oControl) {
            if (Element.getElementById) {
              oControl = Element.getElementById(openById);
            } else if (sap.ui.getCore) {
              const core = sap.ui.getCore();
              if (core && core.byId) oControl = core.byId(openById);
            }
          }

          if (!oControl) {
            logError(`displayPopover: openBy control '${openById}' not found`);
            oFragment.destroy();
            return;
          }
          z2ui5[viewProp] = oFragment;
          oFragment.openBy(oControl);
        } catch (e) {
          logError("displayPopover: failed", e);
        }
      },

      async displayNestedView(xml, viewProp, viewNestId, controller) {
        const oModel = this._createViewModel();
        applyStoredSizeLimit(paramToViewKey[viewNestId], oModel);
        const oView = await XMLView.create({
          definition: xml,
          controller: controller,
          preprocessors: { xml: { models: { template: oModel } } },
        });

        const appAlive =
          z2ui5.oApp && (!z2ui5.oApp.isDestroyed || !z2ui5.oApp.isDestroyed());
        if (!appAlive) {
          oView.destroy();
          return;
        }
        oView.setModel(oModel);

        const nestParams =
          z2ui5.oResponse &&
          z2ui5.oResponse.PARAMS &&
          z2ui5.oResponse.PARAMS[viewNestId];
        if (!nestParams) {
          logError(`displayNestedView: missing PARAMS.${viewNestId}`);
          oView.destroy();
          return;
        }
        const { ID, METHOD_DESTROY, METHOD_INSERT } = nestParams;

        const oParent = z2ui5.oView && z2ui5.oView.byId(ID);
        if (!oParent) {
          logError(
            `displayNestedView: parent control '${ID}' not found, nested view discarded`,
          );
          oView.destroy();
          return;
        }

        try {
          oParent[METHOD_DESTROY]();
        } catch (e) {
          logError("displayNestedView: parent destroy method failed", e);
        }
        try {
          oParent[METHOD_INSERT](oView);
        } catch (e) {
          logError("displayNestedView: parent insert method failed", e);
          oView.destroy();
          return;
        }
        z2ui5[viewProp] = oView;
      },

      // Shared destroy logic: close (if dialog/popover) and destroy the view,
      // then clear the slot on z2ui5.
      _destroyView(prop, tryClose) {
        const view = z2ui5[prop];
        if (!view) return;
        if (tryClose) {
          try {
            if (view.close) view.close();
          } catch (e) {
            logError(`_destroyView: view.close() failed for ${prop}`, e);
          }
        }
        try {
          view.destroy();
        } catch (e) {
          logError(`_destroyView: view.destroy() failed for ${prop}`, e);
        }
        z2ui5[prop] = null;
      },

      PopupDestroy() {
        this._destroyView("oViewPopup", true);
      },
      PopoverDestroy() {
        this._destroyView("oViewPopover", true);
      },
      NestViewDestroy() {
        this._destroyView("oViewNest");
      },
      NestViewDestroy2() {
        this._destroyView("oViewNest2");
      },
      ViewDestroy() {
        this._destroyView("oView");
      },

      // ------------------------------------------------------------------
      // eF: handle frontend-only events triggered by the backend response.
      // ------------------------------------------------------------------
      eF(...args) {
        runCallbacks(z2ui5.onBeforeEventFrontend, args);

        // NavContainer navigation is dispatched via lookup table.
        const navLookup = navContainerLookups[args[0]];
        if (navLookup) {
          navigateContainer(navLookup, args);
          return;
        }

        switch (args[0]) {
          case "SET_SIZE_LIMIT":
            this._evSetSizeLimit(args);
            break;
          case "HISTORY_BACK":
            history.back();
            break;
          case "CLIPBOARD_COPY":
            copyToClipboard(args[1]);
            break;
          case "CLIPBOARD_APP_STATE": {
            const id = z2ui5.oResponse && z2ui5.oResponse.ID;
            copyToClipboard(`${window.location.href}#/z2ui5-xapp-state=${id}`);
            break;
          }
          case "SET_ODATA_MODEL":
            this._evSetODataModel(args);
            break;
          case "STORE_DATA":
            this._evStoreData(args);
            break;
          case "DOWNLOAD_B64_FILE": {
            const a = document.createElement("a");
            a.href = args[1];
            a.download = args[2];
            a.click();
            break;
          }
          case "CROSS_APP_NAV_TO_PREV_APP":
            withCrossAppNavigator((nav) => nav.backToPreviousApp());
            break;
          case "CROSS_APP_NAV_TO_EXT":
            this._evCrossAppNavToExt(args);
            break;
          case "LOCATION_RELOAD":
            this._evLocationReload(args);
            break;
          case "SYSTEM_LOGOUT":
            this._evSystemLogout(args);
            break;
          case "OPEN_NEW_TAB":
            this._evOpenNewTab(args);
            break;
          case "POPUP_CLOSE":
            this.PopupDestroy();
            break;
          case "POPOVER_CLOSE":
            this.PopoverDestroy();
            break;
          case "URLHELPER":
            this._evUrlHelper(args);
            break;
          case "IMAGE_EDITOR_POPUP_CLOSE":
            this._evImageEditorPopupClose();
            break;
          case "SET_TITLE":
            this._evSetTitle(args);
            break;
          case "SET_FOCUS":
            this._evSetFocus(args);
            break;
          case "SET_FOCUS_CELL":
            this._evSetCellFocus(args);
            break;
          case "KEYBOARD_KEEP_OPEN":
            this._evFocusActiveInput();
            break;
          case "START_TIMER":
            this._evStartTimer(args);
            break;
          case "KEYBOARD_SET_MODE":
            this._evSetInputMode(args);
            break;
          case "Z2UI5":
            this._evZ2ui5Custom(args);
            break;
        }
      },

      // ------------------------------------------------------------------
      // Individual event handlers - one per case in eF(). Splitting them out
      // keeps eF() short and makes each behavior easy to find.
      // ------------------------------------------------------------------

      _evSetSizeLimit(args) {
        // Two call shapes:
        //   ["SET_SIZE_LIMIT", "<limit>", "<viewKey>"]   -> set the limit
        //   ["SET_SIZE_LIMIT", "<viewKey>"]              -> reset the limit
        const hasLimit = args[2] !== undefined && args[2] !== "";
        const viewKey = hasLimit ? args[2] : args[1];
        const limit = hasLimit ? Number(args[1]) : NaN;
        const view = viewLookups[viewKey] && viewLookups[viewKey]();
        const model = view && view.getModel();

        if (Number.isFinite(limit) && limit > 0) {
          if (!z2ui5.viewSizeLimits) z2ui5.viewSizeLimits = {};
          z2ui5.viewSizeLimits[viewKey] = limit;
          if (model) {
            model.setSizeLimit(limit);
            model.refresh(true);
          }
        } else {
          if (z2ui5.viewSizeLimits) delete z2ui5.viewSizeLimits[viewKey];
          if (model) {
            model.setSizeLimit(100);
            model.refresh(true);
          }
        }
      },

      _evSetODataModel(args) {
        try {
          const oModel = new ODataModel({
            serviceUrl: args[1],
            annotationURI: args[3] || "",
          });
          if (z2ui5.oView) z2ui5.oView.setModel(oModel, args[2] || undefined);
        } catch (e) {
          logError(`SET_ODATA_MODEL: failed for '${args[1]}'`, e);
        }
      },

      _evStoreData(args) {
        const { TYPE, PREFIX, VALUE, KEY } = args[1];
        try {
          const storageType = Storage.Type[TYPE] || Storage.Type.session;
          const oStorage = new Storage(storageType, PREFIX);
          if (VALUE === "" || VALUE == null) {
            oStorage.remove(KEY);
          } else {
            oStorage.put(KEY, VALUE);
          }
        } catch (e) {
          logError(`STORE_DATA: storage operation failed for key '${KEY}'`, e);
        }
      },

      _evCrossAppNavToExt(args) {
        withCrossAppNavigator((nav) => {
          const hash =
            nav.hrefForExternal({ target: args[1], params: args[2] }) || "";
          if (args[3] === "EXT") {
            // External redirect: replace the location while keeping the host.
            const base = window.location.href.split("#")[0];
            _URLHelper.redirect(`${base}${hash}`, true);
          } else {
            nav.toExternal({ target: { shellHash: hash } });
          }
        });
      },

      _evLocationReload(args) {
        if (isValidRedirectURL(args[1])) {
          window.location.href = args[1];
        } else {
          MessageBox.error(
            "Invalid redirect URL. Only relative URLs to the same domain are allowed.",
          );
        }
      },

      _evSystemLogout(args) {
        const logoutUrl = args[1] || "/sap/public/bc/icf/logoff";
        const goToLogoutUrl = () => {
          if (isValidRedirectURL(logoutUrl)) {
            window.location.href = logoutUrl;
          } else {
            MessageBox.error(
              "Invalid logout URL. Only relative URLs to the same domain are allowed.",
            );
          }
        };
        // When abap2UI5 is hosted as a BSP application,
        // /sap/public/bc/icf/logoff alone does not terminate the stateful
        // BSP context (sap-contextid stays bound to /sap/bc/bsp/sap/<app>/).
        // Hit the BSP path with ?sap-sessioncmd=logoff first so the BSP
        // runtime calls server->session->terminate( ), then go to the ICF
        // logoff to also drop the SSO2 ticket.
        const redirectToLogoff = () => {
          const path = window.location.pathname;
          if (path.indexOf("/sap/bc/bsp/") !== 0) {
            goToLogoutUrl();
            return;
          }
          const sep = path.indexOf("?") >= 0 ? "&" : "?";
          const bspKill = path + sep + "sap-sessioncmd=logoff";
          let done = false;
          const finish = () => {
            if (done) return;
            done = true;
            goToLogoutUrl();
          };
          try {
            const f = document.createElement("iframe");
            f.style.display = "none";
            f.src = bspKill;
            f.addEventListener("load", finish);
            document.body.appendChild(f);
          } catch (e) {
            finish();
            return;
          }
          // Safety net: never wait longer than 1.5s for the BSP terminate.
          setTimeout(finish, 1500);
        };
        try {
          const launchpadLogout =
            z2ui5.oLaunchpad &&
            z2ui5.oLaunchpad.Container &&
            z2ui5.oLaunchpad.Container.logout;
          if (launchpadLogout) {
            z2ui5.oLaunchpad.Container.logout();
          } else {
            redirectToLogoff();
          }
        } catch (e) {
          logError("SYSTEM_LOGOUT: ushell logout failed", e);
          redirectToLogoff();
        }
      },

      _evOpenNewTab(args) {
        if (!isValidRedirectURL(args[1])) {
          MessageBox.error(
            "Invalid URL. Only relative URLs to the same domain are allowed.",
          );
          return;
        }
        const newWindow = window.open(args[1], "_blank");
        // Clear opener to prevent the new tab from accessing window.opener.
        if (newWindow) newWindow.opener = null;
      },

      _evUrlHelper(args) {
        const params = args[2];
        const actions = {
          REDIRECT: () => _URLHelper.redirect(params.URL, params.NEW_WINDOW),
          TRIGGER_EMAIL: () =>
            _URLHelper.triggerEmail(
              params.EMAIL,
              params.SUBJECT,
              params.BODY,
              params.CC,
              params.BCC,
              params.NEW_WINDOW,
            ),
          TRIGGER_SMS: () => _URLHelper.triggerSms(params),
          TRIGGER_TEL: () => _URLHelper.triggerTel(params),
        };
        try {
          const fn = actions[args[1]];
          if (fn) fn();
        } catch (e) {
          logError(`URLHELPER: '${args[1]}' failed`, e);
        }
      },

      _evImageEditorPopupClose() {
        let image;
        try {
          const editor = Fragment.byId("popupId", "imageEditor");
          if (editor) image = editor.getImagePngDataURL();
        } catch (e) {
          logError("IMAGE_EDITOR_POPUP_CLOSE: getImagePngDataURL failed", e);
        }
        this.PopupDestroy();
        this.eB(["SAVE"], image);
      },

      _evStartTimer(args) {
        const eventName = args[1];
        const delay = +args[2] || 0;
        if (!z2ui5.timers) z2ui5.timers = {};
        clearTimeout(z2ui5.timers[eventName]);
        z2ui5.timers[eventName] = setTimeout(() => {
          delete z2ui5.timers[eventName];
          this.eB([eventName]);
        }, delay);
      },

      _evSetInputMode(args) {
        try {
          const oElement = z2ui5.oView && z2ui5.oView.byId(args[1]);
          if (!oElement) return;
          const dom = oElement.getDomRef();
          if (!dom) return;
          const input = dom.matches("input, textarea")
            ? dom
            : dom.querySelector("input, textarea");
          if (!input) return;
          input.setAttribute("inputmode", args[2] || "text");
        } catch (e) {
          logError(
            `KEYBOARD_SET_MODE: setAttribute failed for '${args[1]}'`,
            e,
          );
        }
      },

      _evSetFocus(args) {
        try {
          const oElement = z2ui5.oView && z2ui5.oView.byId(args[1]);
          if (!oElement) return;
          const info = oElement.getFocusInfo();
          if (args[2] != null && args[2] !== "") info.selectionStart = +args[2];
          if (args[3] != null && args[3] !== "") info.selectionEnd = +args[3];
          oElement.applyFocusInfo(info);
        } catch (e) {
          logError(`SET_FOCUS: failed for '${args[1]}'`, e);
        }
      },

      _evSetCellFocus(args) {
        try {
          // args[1] = column view-relative ID, args[2] = row index (0-based)
          const oColumn = z2ui5.oView && z2ui5.oView.byId(args[1]);
          if (!oColumn) return;
          const oTable = oColumn.getParent();
          if (!oTable) return;
          const colIdx = oTable.indexOfColumn(oColumn);
          const rows = oTable.getItems ? oTable.getItems() : oTable.getRows();
          const oRow = rows[+args[2]];
          if (!oRow) return;
          const oCell = oRow.getCells()[colIdx];
          if (!oCell) return;
          oCell.applyFocusInfo(oCell.getFocusInfo());
        } catch (e) {
          logError(`SET_FOCUS_CELL: failed for column '${args[1]}'`, e);
        }
      },

      _evFocusActiveInput() {
        const onAfterRendering = () => {
          Rendering.detachAfterRendering(onAfterRendering);
          try {
            const el = document.activeElement;
            if (!el) return;
            const input = el.matches("input, textarea")
              ? el
              : el.querySelector("input, textarea");
            if (!input) return;
            input.focus();
            input.select();
          } catch (e) {
            logError("FOCUS_ACTIVE_INPUT: failed", e);
          }
        };
        Rendering.attachAfterRendering(onAfterRendering);
      },

      _evSetTitle(args) {
        const title = args[1] == null ? "" : String(args[1]);
        try {
          const shell = z2ui5.oLaunchpad && z2ui5.oLaunchpad.ShellUIService;
          if (shell && shell.setTitle) {
            const result = shell.setTitle(title);
            if (result && result.catch) {
              result.catch((e) =>
                logError("SET_TITLE: ShellUIService.setTitle failed", e),
              );
            }
          } else {
            document.title = title;
          }
        } catch (e) {
          logError("SET_TITLE: ShellUIService.setTitle failed", e);
        }
      },

      _evZ2ui5Custom(args) {
        try {
          const fn = z2ui5[args[1]];
          if (fn) fn(args.slice(2));
        } catch (e) {
          logError(`Z2UI5: '${args[1]}' failed`, e);
        }
      },

      // ------------------------------------------------------------------
      // eB: trigger a backend roundtrip with arguments.
      // ------------------------------------------------------------------
      eB(...args) {
        if (!navigator.onLine) {
          MessageBox.alert(
            "No internet connection! Please reconnect to the server and try again.",
          );
          return;
        }

        // If a roundtrip is already in flight, briefly show a BusyDialog so
        // the user gets visual feedback instead of a silent click. args[0][2]
        // is the "ignore busy" flag set by certain background events.
        if (z2ui5.isBusy && !args[0][2]) {
          const oBusyDialog = new mBusyDialog();
          oBusyDialog.attachEventOnce("afterClose", () =>
            oBusyDialog.destroy(),
          );
          oBusyDialog.open();
          queueMicrotask(() => oBusyDialog.close());
          return;
        }

        z2ui5.isBusy = true;
        BusyIndicator.show();
        z2ui5.oBody = { VIEWNAME: "MAIN" };

        // Decide which view's model holds the data we need to send back. The
        // mapping is: main app controller -> main view, popup controller ->
        // popup view, etc.
        const oModel = this._pickModelForRoundtrip(args);

        runCallbacks(z2ui5.onBeforeRoundtrip);

        // If the user edited /XX/ paths, send only the delta to keep the
        // payload small.
        if (oModel && z2ui5.xxChangedPaths && z2ui5.xxChangedPaths.size > 0) {
          const data = oModel.getData();
          const xx = data && data.XX;
          if (xx) {
            z2ui5.oBody.XX = this._buildDeltaFromPaths(
              z2ui5.xxChangedPaths,
              xx,
            );
          }
        }

        z2ui5.oBody.ID = z2ui5.oResponse && z2ui5.oResponse.ID;
        // Object arguments are stringified for transport; the event name in
        // args[0] is left as-is.
        z2ui5.oBody.ARGUMENTS = args.map((item, i) => {
          if (i > 0 && typeof item === "object") return JSON.stringify(item);
          return item;
        });

        z2ui5.oResponseOld = z2ui5.oResponse;
        Server.Roundtrip();
        runCallbacks(z2ui5.onAfterRoundtrip);
      },

      _pickModelForRoundtrip(args) {
        // The 4th positional flag in args[0] forces use of the main view's
        // model even when called from a popup/popover controller.
        if (args[0][3] || z2ui5.oController === this) {
          const sView =
            z2ui5.oResponse && z2ui5.oResponse.PARAMS
              ? z2ui5.oResponse.PARAMS.S_VIEW
              : null;
          if (sView && sView.SWITCH_DEFAULT_MODEL_PATH) {
            return z2ui5.oView && z2ui5.oView.getModel("http");
          }
          return z2ui5.oView && z2ui5.oView.getModel();
        }
        if (z2ui5.oControllerPopup === this) {
          return z2ui5.oViewPopup && z2ui5.oViewPopup.getModel();
        }
        if (z2ui5.oControllerPopover === this) {
          return z2ui5.oViewPopover && z2ui5.oViewPopover.getModel();
        }
        if (z2ui5.oControllerNest === this) {
          z2ui5.oBody.VIEWNAME = "NEST";
          return z2ui5.oViewNest && z2ui5.oViewNest.getModel();
        }
        if (z2ui5.oControllerNest2 === this) {
          z2ui5.oBody.VIEWNAME = "NEST2";
          return z2ui5.oViewNest2 && z2ui5.oViewNest2.getModel();
        }
        return undefined;
      },

      // Re-bind a model to one of the views when the response signals an
      // update is required for that particular slot.
      updateModelIfRequired(paramKey, oView) {
        const params = z2ui5.oResponse && z2ui5.oResponse.PARAMS;
        const slot = params && params[paramKey];
        if (!slot || !slot.CHECK_UPDATE_MODEL) return;

        const oModel = this._createViewModel();
        applyStoredSizeLimit(paramToViewKey[paramKey], oModel);
        if (oView) oView.setModel(oModel);
      },

      async checkSDKcompatibility(err) {
        let gav;
        try {
          const info = await VersionInfo.load();
          gav = info.gav;
        } catch (e) {
          logError("checkSDKcompatibility: VersionInfo.load failed", e);
          return;
        }
        if (!gav || !gav.includes("com.sap.ui5")) {
          // openui5 doesn't ship some sap.com modules - tell the user which
          // module is missing so they know to switch to SAPUI5.
          const missingModule = err && err._modules;
          MessageBox.error(
            `openui5 SDK is loaded, module: ${missingModule} is not available in openui5`,
          );
          return;
        }
        MessageBox.error(err.toLocaleString());
      },

      // Display a toast or message box. Triggered for S_MSG_TOAST and
      // S_MSG_BOX entries in the server response.
      showMessage(msgType, params) {
        if (!params) return;
        const msg = params[msgType];
        if (!msg || msg.TEXT === undefined) return;

        if (msgType === "S_MSG_TOAST") {
          MessageToast.show(msg.TEXT, {
            duration: parseMs(msg.DURATION, 3000),
            width: msg.WIDTH || "15em",
            onClose: msg.ONCLOSE ? () => this.eB([msg.ONCLOSE]) : null,
            autoClose: !!msg.AUTOCLOSE,
            animationTimingFunction: msg.ANIMATIONTIMINGFUNCTION || "ease",
            animationDuration: parseMs(msg.ANIMATIONDURATION, 1000),
            closeonBrowserNavigation: !!msg.CLOSEONBROWSERNAVIGATION,
          });
          if (msg.CLASS) {
            const toastEl = document.querySelector(".sapMMessageToast");
            if (toastEl) {
              const classes = msg.CLASS.trim().split(/\s+/).filter(Boolean);
              toastEl.classList.add(...classes);
            }
          }
          return;
        }

        if (msgType === "S_MSG_BOX") {
          const oParams = {
            styleClass: msg.STYLECLASS || "",
            title: msg.TITLE || "",
            onClose: msg.ONCLOSE
              ? (sAction) => this.eB([msg.ONCLOSE, sAction])
              : null,
            actions: msg.ACTIONS || "OK",
            emphasizedAction: msg.EMPHASIZEDACTION || "OK",
            initialFocus: msg.INITIALFOCUS || null,
            textDirection: msg.TEXTDIRECTION || "Inherit",
            details: msg.DETAILS ? sanitizeMessageDetails(msg.DETAILS) : "",
            closeOnNavigation: !!msg.CLOSEONNAVIGATION,
          };
          if (msg.ICON && msg.ICON !== "NONE") oParams.icon = msg.ICON;
          const showFn = MessageBox[msg.TYPE];
          if (showFn) showFn(msg.TEXT, oParams);
        }
      },

      // Replace the main app view with the XML coming from the backend.
      async displayView(xml, viewModel) {
        const oViewModel = this._trackChanges(new JSONModel(viewModel));

        const sView =
          z2ui5.oResponse && z2ui5.oResponse.PARAMS
            ? z2ui5.oResponse.PARAMS.S_VIEW
            : null;
        const switchPath = sView && sView.SWITCH_DEFAULT_MODEL_PATH;

        // When the app wants OData as the default model, build it here and
        // keep the JSON model as the named "http" model.
        let oModel;
        if (switchPath) {
          oModel = new ODataModel({
            serviceUrl: switchPath,
            annotationURI: sView.SWITCHDEFAULTMODELANNOURI || "",
          });
        } else {
          oModel = oViewModel;
        }
        applyStoredSizeLimit("MAIN", oModel);

        z2ui5.oView = await XMLView.create({
          definition: xml,
          models: oModel,
          controller: z2ui5.oController,
          id: "mainView",
          preprocessors: { xml: { models: { template: oViewModel } } },
        });

        // Guard against the app being destroyed during the await above.
        const appAlive =
          z2ui5.oApp && (!z2ui5.oApp.isDestroyed || !z2ui5.oApp.isDestroyed());
        if (!appAlive) {
          z2ui5.oView.destroy();
          if (switchPath) oModel.destroy();
          z2ui5.oView = null;
          return;
        }

        z2ui5.oView.setModel(z2ui5.oDeviceModel, "device");
        if (switchPath) z2ui5.oView.setModel(oViewModel, "http");
        z2ui5.oApp.removeAllPages();
        z2ui5.oApp.insertPage(z2ui5.oView);
      },
    });
  },
);
