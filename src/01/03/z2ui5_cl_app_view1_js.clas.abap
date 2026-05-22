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
             `    "sap/ui/core/mvc/Controller",` && |\n| &&
             `    "sap/ui/core/mvc/XMLView",` && |\n| &&
             `    "sap/ui/model/json/JSONModel",` && |\n| &&
             `    "sap/ui/core/BusyIndicator",` && |\n| &&
             `    "sap/m/MessageBox",` && |\n| &&
             `    "sap/m/MessageToast",` && |\n| &&
             `    "sap/ui/core/Fragment",` && |\n| &&
             `    "sap/m/BusyDialog",` && |\n| &&
             `    "sap/ui/VersionInfo",` && |\n| &&
             `    "z2ui5/cc/Server",` && |\n| &&
             `    "sap/ui/model/odata/v2/ODataModel",` && |\n| &&
             `    "sap/m/library",` && |\n| &&
             `    "sap/ui/core/routing/HashChanger",` && |\n| &&
             `    "sap/ui/util/Storage",` && |\n| &&
             `    "sap/ui/core/Element",` && |\n| &&
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
             `    "use strict";` && |\n| &&
             `` && |\n| &&
             `    // ------------------------------------------------------------------` && |\n| &&
             `    // Small utility helpers (module-private)` && |\n| &&
             `    // ------------------------------------------------------------------` && |\n| &&
             `` && |\n| &&
             `    // Append an entry to the global error log. We create the array on first use.` && |\n| &&
             `    function logError(message, error) {` && |\n| &&
             `      if (!z2ui5.errors) z2ui5.errors = [];` && |\n| &&
             `      const entry = { message: message, ts: new Date().toISOString() };` && |\n| &&
             `      if (error !== undefined) entry.error = error;` && |\n| &&
             `      z2ui5.errors.push(entry);` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // Run every callback in ``arr``, swallowing individual failures so one bad` && |\n| &&
             `    // callback cannot break the whole event sequence.` && |\n| &&
             `    function runCallbacks(arr, ...args) {` && |\n| &&
             `      if (!arr) return;` && |\n| &&
             `      for (const fn of arr) {` && |\n| &&
             `        if (!fn) continue;` && |\n| &&
             `        try {` && |\n| &&
             `          fn(...args);` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          logError("runCallbacks: callback failed", e);` && |\n| &&
             `        }` && |\n| &&
             `      }` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // Parse a value as integer milliseconds, falling back to ``def`` when the` && |\n| &&
             `    // input is empty / undefined.` && |\n| &&
             `    function parseMs(val, def) {` && |\n| &&
             `      return val ? +val : def;` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // DOM helpers reused across calls; kept as module-level singletons.` && |\n| &&
             `    const _msgParser = new DOMParser();` && |\n| &&
             `    const _sanitizeEl = document.createElement("div");` && |\n| &&
             `    const _hashChanger = HashChanger.getInstance();` && |\n| &&
             `    const _URLHelper = mobileLibrary.URLHelper;` && |\n| &&
             `    const _SAFE_PROTOCOLS = new Set(["http:", "https:"]);` && |\n| &&
             `` && |\n| &&
             `    // ------------------------------------------------------------------` && |\n| &&
             `    // Security helpers` && |\n| &&
             `    // ------------------------------------------------------------------` && |\n| &&
             `` && |\n| &&
             `    // Returns true only if the URL is on the same origin and uses http/https.` && |\n| &&
             `    function isValidRedirectURL(url) {` && |\n| &&
             `      if (!url) return false;` && |\n| &&
             `      try {` && |\n| &&
             `        const parsed = new URL(url, window.location.origin);` && |\n| &&
             `        if (parsed.origin !== window.location.origin) {` && |\n| &&
             `          logError(``Security: Blocked redirect to different origin: ${url}``);` && |\n| &&
             `          return false;` && |\n| &&
             `        }` && |\n| &&
             `        if (!_SAFE_PROTOCOLS.has(parsed.protocol)) {` && |\n| &&
             `          logError(` && |\n| &&
             `            ``Security: Blocked redirect with invalid protocol: ${parsed.protocol}``,` && |\n| &&
             `          );` && |\n| &&
             `          return false;` && |\n| &&
             `        }` && |\n| &&
             `        return true;` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        logError(``Security: Invalid URL format: ${url}``, e);` && |\n| &&
             `        return false;` && |\n| &&
             `      }` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function copyToClipboard(textToCopy) {` && |\n| &&
             `      if (navigator.clipboard && navigator.clipboard.writeText) {` && |\n| &&
             `        navigator.clipboard.writeText(textToCopy).catch((err) => {` && |\n| &&
             `          logError("Clipboard: writeText failed, falling back", err);` && |\n| &&
             `          copyToClipboardFallback(textToCopy);` && |\n| &&
             `        });` && |\n| &&
             `        return;` && |\n| &&
             `      }` && |\n| &&
             `      copyToClipboardFallback(textToCopy);` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function copyToClipboardFallback(textToCopy) {` && |\n| &&
             `      const textarea = document.createElement("textarea");` && |\n| &&
             `      textarea.value = textToCopy;` && |\n| &&
             `      textarea.setAttribute("readonly", "");` && |\n| &&
             `      textarea.style.position = "fixed";` && |\n| &&
             `      textarea.style.top = "-1000px";` && |\n| &&
             `      textarea.style.opacity = "0";` && |\n| &&
             `      document.body.appendChild(textarea);` && |\n| &&
             `      textarea.select();` && |\n| &&
             `      try {` && |\n| &&
             `        if (!document.execCommand("copy")) {` && |\n| &&
             `          logError("Clipboard: execCommand('copy') returned false");` && |\n| &&
             `        }` && |\n| &&
             `      } catch (err) {` && |\n| &&
             `        logError("Clipboard: execCommand('copy') threw", err);` && |\n| &&
             `      } finally {` && |\n| &&
             `        document.body.removeChild(textarea);` && |\n| &&
             `      }` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // Turns an HTML "details" snippet from the backend into safe HTML.` && |\n| &&
             `    // Bullet lists are preserved; everything else is reduced to plain text.` && |\n| &&
             `    function sanitizeMessageDetails(html) {` && |\n| &&
             `      const doc = _msgParser.parseFromString(html, "text/html");` && |\n| &&
             `      const items = Array.from(doc.querySelectorAll("li"));` && |\n| &&
             `      if (items.length > 0) {` && |\n| &&
             `        const safeItems = items.map((li) => {` && |\n| &&
             `          _sanitizeEl.textContent = li.textContent;` && |\n| &&
             `          return ``<li>${_sanitizeEl.innerHTML}</li>``;` && |\n| &&
             `        });` && |\n| &&
             `        return ``<ul>${safeItems.join("")}</ul>``;` && |\n| &&
             `      }` && |\n| &&
             `      _sanitizeEl.textContent = doc.body.textContent;` && |\n| &&
             `      return _sanitizeEl.innerHTML;` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // ------------------------------------------------------------------` && |\n| &&
             `    // Launchpad / NavContainer helpers` && |\n| &&
             `    // ------------------------------------------------------------------` && |\n| &&
             `` && |\n| &&
             `    function withCrossAppNavigator(callback) {` && |\n| &&
             `      const nav = z2ui5.oLaunchpad && z2ui5.oLaunchpad.CrossAppNavigator;` && |\n| &&
             `      if (!nav) {` && |\n| &&
             `        logError("CrossAppNav: not running inside Launchpad");` && |\n| &&
             `        return;` && |\n| &&
             `      }` && |\n| &&
             `      try {` && |\n| &&
             `        callback(nav);` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        logError("CrossAppNav: callback failed", e);` && |\n| &&
             `      }` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function navigateContainer(lookup, args) {` && |\n| &&
             `      try {` && |\n| &&
             `        const container = lookup(args[1]);` && |\n| &&
             `        if (container) container.to(lookup(args[2]));` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        logError("navigateContainer: navigation failed", e);` && |\n| &&
             `      }` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // Lookup tables mapping event names / param keys to the right view.` && |\n| &&
             `    const navContainerLookups = {` && |\n| &&
             `      NAV_CONTAINER_TO: (id) => z2ui5.oView && z2ui5.oView.byId(id),` && |\n| &&
             `      NEST_NAV_CONTAINER_TO: (id) =>` && |\n| &&
             `        z2ui5.oViewNest && z2ui5.oViewNest.byId(id),` && |\n| &&
             `      NEST2_NAV_CONTAINER_TO: (id) =>` && |\n| &&
             `        z2ui5.oViewNest2 && z2ui5.oViewNest2.byId(id),` && |\n| &&
             `      POPUP_NAV_CONTAINER_TO: (id) => Fragment.byId("popupId", id),` && |\n| &&
             `      POPOVER_NAV_CONTAINER_TO: (id) => Fragment.byId("popoverId", id),` && |\n| &&
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
             `    const paramToViewKey = {` && |\n| &&
             `      S_VIEW: "MAIN",` && |\n| &&
             `      S_VIEW_NEST: "NEST",` && |\n| &&
             `      S_VIEW_NEST2: "NEST2",` && |\n| &&
             `      S_POPUP: "POPUP",` && |\n| &&
             `      S_POPOVER: "POPOVER",` && |\n| &&
             `    };` && |\n| &&
             `` && |\n| &&
             `    function applyStoredSizeLimit(viewKey, oModel) {` && |\n| &&
             `      if (!oModel || !z2ui5.viewSizeLimits) return;` && |\n| &&
             `      const limit = z2ui5.viewSizeLimits[viewKey];` && |\n| &&
             `      if (limit !== undefined) oModel.setSizeLimit(limit);` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    return Controller.extend("z2ui5.controller.View1", {` && |\n| &&
             `      // ------------------------------------------------------------------` && |\n| &&
             `      // Model change tracking - remembers which /XX/ paths the user edited` && |\n| &&
             `      // so the next roundtrip only ships the delta.` && |\n| &&
             `      // ------------------------------------------------------------------` && |\n| &&
             `      _trackChanges(oModel) {` && |\n| &&
             `        oModel.attachPropertyChange((e) => {` && |\n| &&
             `          const params = e.getParameters();` && |\n| &&
             `          const raw = params.path;` && |\n| &&
             `          const ctx = params.context;` && |\n| &&
             `          if (!raw) return;` && |\n| &&
             `          // Resolve relative paths against the binding context.` && |\n| &&
             `          let p;` && |\n| &&
             `          if (ctx && !raw.startsWith("/")) {` && |\n| &&
             `            p = ``${ctx.getPath()}/${raw}``;` && |\n| &&
             `          } else {` && |\n| &&
             `            p = raw;` && |\n| &&
             `          }` && |\n| &&
             `          if (p.startsWith("/XX/")) {` && |\n| &&
             `            if (!z2ui5.xxChangedPaths) z2ui5.xxChangedPaths = new Set();` && |\n| &&
             `            z2ui5.xxChangedPaths.add(p);` && |\n| &&
             `          }` && |\n| &&
             `        });` && |\n| &&
             `        return oModel;` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      onInit() {` && |\n| &&
             `        z2ui5.oRouter.attachRouteMatched(() => {` && |\n| &&
             `          z2ui5.checkInit = true;` && |\n| &&
             `          Server.Roundtrip();` && |\n| &&
             `        });` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      onAfterRendering() {` && |\n| &&
             `        if (z2ui5.oResponse && !z2ui5.oResponse._processed) {` && |\n| &&
             `          this._processAfterRendering();` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      // Runs once after each roundtrip's view has been rendered. Handles` && |\n| &&
             `      // popups, nested views, popovers and browser-history updates.` && |\n| &&
             `      async _processAfterRendering() {` && |\n| &&
             `        try {` && |\n| &&
             `          const oResponse = z2ui5.oResponse;` && |\n| &&
             `          if (oResponse._processed) return;` && |\n| &&
             `          oResponse._processed = true;` && |\n| &&
             `` && |\n| &&
             `          const PARAMS = oResponse.PARAMS;` && |\n| &&
             `          const ID = oResponse.ID;` && |\n| &&
             `          if (!PARAMS) return;` && |\n| &&
             `` && |\n| &&
             `          const S_POPUP = PARAMS.S_POPUP;` && |\n| &&
             `          const S_VIEW_NEST = PARAMS.S_VIEW_NEST;` && |\n| &&
             `          const S_VIEW_NEST2 = PARAMS.S_VIEW_NEST2;` && |\n| &&
             `          const S_POPOVER = PARAMS.S_POPOVER;` && |\n| &&
             `          const SET_APP_STATE_ACTIVE = PARAMS.SET_APP_STATE_ACTIVE;` && |\n| &&
             `          const SET_PUSH_STATE = PARAMS.SET_PUSH_STATE;` && |\n| &&
             `          const SET_NAV_BACK = PARAMS.SET_NAV_BACK;` && |\n| &&
             `` && |\n| &&
             `          if (S_POPUP && S_POPUP.CHECK_DESTROY) this.PopupDestroy();` && |\n| &&
             `          if (S_POPOVER && S_POPOVER.CHECK_DESTROY) this.PopoverDestroy();` && |\n| &&
             `` && |\n| &&
             `          if (S_POPUP && S_POPUP.XML) {` && |\n| &&
             `            this.PopupDestroy();` && |\n| &&
             `            await this.displayFragment(S_POPUP.XML, "oViewPopup");` && |\n| &&
             `          }` && |\n| &&
             `` && |\n| &&
             `          if (!z2ui5.checkNestAfter && S_VIEW_NEST && S_VIEW_NEST.XML) {` && |\n| &&
             `            this.NestViewDestroy();` && |\n| &&
             `            await this.displayNestedView(` && |\n| &&
             `              S_VIEW_NEST.XML,` && |\n| &&
             `              "oViewNest",` && |\n| &&
             `              "S_VIEW_NEST",` && |\n| &&
             `              z2ui5.oControllerNest,` && |\n| &&
             `            );` && |\n| &&
             `            z2ui5.checkNestAfter = true;` && |\n| &&
             `          }` && |\n| &&
             `` && |\n| &&
             `          if (!z2ui5.checkNestAfter2 && S_VIEW_NEST2 && S_VIEW_NEST2.XML) {` && |\n| &&
             `            this.NestViewDestroy2();` && |\n| &&
             `            await this.displayNestedView(` && |\n| &&
             `              S_VIEW_NEST2.XML,` && |\n| &&
             `              "oViewNest2",` && |\n| &&
             `              "S_VIEW_NEST2",` && |\n| &&
             `              z2ui5.oControllerNest2,` && |\n| &&
             `            );` && |\n| &&
             `            z2ui5.checkNestAfter2 = true;` && |\n| &&
             `          }` && |\n| &&
             `` && |\n| &&
             `          if (S_POPOVER && S_POPOVER.XML) {` && |\n| &&
             `            this.PopoverDestroy();` && |\n| &&
             `            await this.displayPopover(` && |\n| &&
             `              S_POPOVER.XML,` && |\n| &&
             `              "oViewPopover",` && |\n| &&
             `              S_POPOVER.OPEN_BY_ID,` && |\n| &&
             `            );` && |\n| &&
             `          }` && |\n| &&
             `` && |\n| &&
             `          // Build the state object stored in history.state, so a future` && |\n| &&
             `          // popstate can restore the current view without a backend hit.` && |\n| &&
             `          const oView = z2ui5.oView;` && |\n| &&
             `          let oState = {};` && |\n| &&
             `          if (oView) {` && |\n| &&
             `            const model = oView.getModel();` && |\n| &&
             `            oState = {` && |\n| &&
             `              view: oView.mProperties.viewContent,` && |\n| &&
             `              model: model ? model.getData() : undefined,` && |\n| &&
             `              response: z2ui5.oResponse,` && |\n| &&
             `            };` && |\n| &&
             `          }` && |\n| &&
             `` && |\n| &&
             `          try {` && |\n| &&
             `            if (SET_PUSH_STATE) {` && |\n| &&
             `              const hash = _hashChanger.getHash();` && |\n| &&
             `              const newUrl = ``${window.location.pathname}${window.location.search}#${hash}${SET_PUSH_STATE}``;` && |\n| &&
             `              history.pushState(oState, "", newUrl);` && |\n| &&
             `            } else {` && |\n| &&
             `              history.replaceState(oState, "", window.location.href);` && |\n| &&
             `            }` && |\n| &&
             `            const newHash = SET_APP_STATE_ACTIVE` && |\n| &&
             `              ? ``z2ui5-xapp-state=${ID || ""}``` && |\n| &&
             `              : "";` && |\n| &&
             `            _hashChanger.replaceHash(newHash);` && |\n| &&
             `          } catch (e) {` && |\n| &&
             `            logError("_processAfterRendering: history update failed", e);` && |\n| &&
             `          }` && |\n| &&
             `` && |\n| &&
             `          if (SET_NAV_BACK) history.back();` && |\n| &&
             `` && |\n| &&
             `          runCallbacks(z2ui5.onAfterRendering);` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          logError("_processAfterRendering: unexpected error", e);` && |\n| &&
             `          MessageBox.error(e.toLocaleString(), {` && |\n| &&
             `            title: "Unexpected Error Occurred - App Terminated",` && |\n| &&
             `            actions: [],` && |\n| &&
             `            onClose: () =>` && |\n| &&
             `              new mBusyDialog({ text: "Please Restart the App" }).open(),` && |\n| &&
             `          });` && |\n| &&
             `        } finally {` && |\n| &&
             `          BusyIndicator.hide();` && |\n| &&
             `          z2ui5.isBusy = false;` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      // Build the delta object sent to the backend. ``paths`` is the set of` && |\n| &&
             `      // /XX/... paths that the user edited; ``xx`` is the full XX model data.` && |\n| &&
             `      _buildDeltaFromPaths(paths, xx) {` && |\n| &&
             `        const delta = {};` && |\n| &&
             `        for (const path of paths) {` && |\n| &&
             `          // path looks like "/XX/<attr>" or "/XX/<attr>/<row>/<field>"` && |\n| &&
             `          const [attr, rowIdx, field] = path.slice(4).split("/");` && |\n| &&
             `          const isRowField =` && |\n| &&
             `            field !== undefined && rowIdx !== "" && !isNaN(rowIdx);` && |\n| &&
             `          if (isRowField) {` && |\n| &&
             `            // Table cell change -> ship only the changed cell.` && |\n| &&
             `            if (!delta[attr] || !delta[attr].__delta) {` && |\n| &&
             `              delta[attr] = { __delta: {} };` && |\n| &&
             `            }` && |\n| &&
             `            const attrDelta = delta[attr].__delta;` && |\n| &&
             `            if (!attrDelta[rowIdx]) attrDelta[rowIdx] = {};` && |\n| &&
             `            const row = xx[attr] && xx[attr][+rowIdx];` && |\n| &&
             `            attrDelta[rowIdx][field] = row ? row[field] : undefined;` && |\n| &&
             `          } else {` && |\n| &&
             `            // Scalar change -> ship the whole attribute.` && |\n| &&
             `            delta[attr] = xx[attr];` && |\n| &&
             `          }` && |\n| &&
             `        }` && |\n| &&
             `        return delta;` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      _createViewModel() {` && |\n| &&
             `        const data = z2ui5.oResponse && z2ui5.oResponse.OVIEWMODEL;` && |\n| &&
             `        return this._trackChanges(new JSONModel(data));` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      // ------------------------------------------------------------------` && |\n| &&
             `      // Display: popups, popovers, nested views, main view` && |\n| &&
             `      // ------------------------------------------------------------------` && |\n| &&
             `` && |\n| &&
             `      async displayFragment(xml, viewProp) {` && |\n| &&
             `        const oModel = this._createViewModel();` && |\n| &&
             `        applyStoredSizeLimit("POPUP", oModel);` && |\n| &&
             `        const oFragment = await Fragment.load({` && |\n| &&
             `          definition: xml,` && |\n| &&
             `          controller: z2ui5.oControllerPopup,` && |\n| &&
             `          id: "popupId",` && |\n| &&
             `        });` && |\n| &&
             `        // The app might have been torn down while the fragment loaded.` && |\n| &&
             `        const appAlive =` && |\n| &&
             `          z2ui5.oApp && (!z2ui5.oApp.isDestroyed || !z2ui5.oApp.isDestroyed());` && |\n| &&
             `        if (!appAlive) {` && |\n| &&
             `          oFragment.destroy();` && |\n| &&
             |\n|.
    result = result &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `        oFragment.setModel(oModel);` && |\n| &&
             `        oFragment.Fragment = Fragment;` && |\n| &&
             `        z2ui5[viewProp] = oFragment;` && |\n| &&
             `        oFragment.open();` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      async displayPopover(xml, viewProp, openById) {` && |\n| &&
             `        try {` && |\n| &&
             `          const oModel = this._createViewModel();` && |\n| &&
             `          applyStoredSizeLimit("POPOVER", oModel);` && |\n| &&
             `          const oFragment = await Fragment.load({` && |\n| &&
             `            definition: xml,` && |\n| &&
             `            controller: z2ui5.oControllerPopover,` && |\n| &&
             `            id: "popoverId",` && |\n| &&
             `          });` && |\n| &&
             `          const appAlive =` && |\n| &&
             `            z2ui5.oApp &&` && |\n| &&
             `            (!z2ui5.oApp.isDestroyed || !z2ui5.oApp.isDestroyed());` && |\n| &&
             `          if (!appAlive) {` && |\n| &&
             `            oFragment.destroy();` && |\n| &&
             `            return;` && |\n| &&
             `          }` && |\n| &&
             `          oFragment.setModel(oModel);` && |\n| &&
             `          oFragment.Fragment = Fragment;` && |\n| &&
             `` && |\n| &&
             `          // Find the control to attach the popover to. We search the main` && |\n| &&
             `          // view first, then any open popup / nested views, then the global` && |\n| &&
             `          // UI5 control registry as a last resort.` && |\n| &&
             `          let oControl = z2ui5.oView && z2ui5.oView.byId(openById);` && |\n| &&
             `          if (!oControl && z2ui5.oViewPopup && z2ui5.oViewPopup.Fragment) {` && |\n| &&
             `            oControl = z2ui5.oViewPopup.Fragment.byId("popupId", openById);` && |\n| &&
             `          }` && |\n| &&
             `          if (!oControl && z2ui5.oViewNest) {` && |\n| &&
             `            oControl = z2ui5.oViewNest.byId(openById);` && |\n| &&
             `          }` && |\n| &&
             `          if (!oControl && z2ui5.oViewNest2) {` && |\n| &&
             `            oControl = z2ui5.oViewNest2.byId(openById);` && |\n| &&
             `          }` && |\n| &&
             `          if (!oControl) {` && |\n| &&
             `            if (Element.getElementById) {` && |\n| &&
             `              oControl = Element.getElementById(openById);` && |\n| &&
             `            } else if (sap.ui.getCore) {` && |\n| &&
             `              const core = sap.ui.getCore();` && |\n| &&
             `              if (core && core.byId) oControl = core.byId(openById);` && |\n| &&
             `            }` && |\n| &&
             `          }` && |\n| &&
             `` && |\n| &&
             `          if (!oControl) {` && |\n| &&
             `            logError(``displayPopover: openBy control '${openById}' not found``);` && |\n| &&
             `            oFragment.destroy();` && |\n| &&
             `            return;` && |\n| &&
             `          }` && |\n| &&
             `          z2ui5[viewProp] = oFragment;` && |\n| &&
             `          oFragment.openBy(oControl);` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          logError("displayPopover: failed", e);` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      async displayNestedView(xml, viewProp, viewNestId, controller) {` && |\n| &&
             `        const oModel = this._createViewModel();` && |\n| &&
             `        applyStoredSizeLimit(paramToViewKey[viewNestId], oModel);` && |\n| &&
             `        const oView = await XMLView.create({` && |\n| &&
             `          definition: xml,` && |\n| &&
             `          controller: controller,` && |\n| &&
             `          preprocessors: { xml: { models: { template: oModel } } },` && |\n| &&
             `        });` && |\n| &&
             `` && |\n| &&
             `        const appAlive =` && |\n| &&
             `          z2ui5.oApp && (!z2ui5.oApp.isDestroyed || !z2ui5.oApp.isDestroyed());` && |\n| &&
             `        if (!appAlive) {` && |\n| &&
             `          oView.destroy();` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `        oView.setModel(oModel);` && |\n| &&
             `` && |\n| &&
             `        const nestParams =` && |\n| &&
             `          z2ui5.oResponse &&` && |\n| &&
             `          z2ui5.oResponse.PARAMS &&` && |\n| &&
             `          z2ui5.oResponse.PARAMS[viewNestId];` && |\n| &&
             `        if (!nestParams) {` && |\n| &&
             `          logError(``displayNestedView: missing PARAMS.${viewNestId}``);` && |\n| &&
             `          oView.destroy();` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `        const { ID, METHOD_DESTROY, METHOD_INSERT } = nestParams;` && |\n| &&
             `` && |\n| &&
             `        const oParent = z2ui5.oView && z2ui5.oView.byId(ID);` && |\n| &&
             `        if (!oParent) {` && |\n| &&
             `          logError(` && |\n| &&
             `            ``displayNestedView: parent control '${ID}' not found, nested view discarded``,` && |\n| &&
             `          );` && |\n| &&
             `          oView.destroy();` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `` && |\n| &&
             `        try {` && |\n| &&
             `          oParent[METHOD_DESTROY]();` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          logError("displayNestedView: parent destroy method failed", e);` && |\n| &&
             `        }` && |\n| &&
             `        try {` && |\n| &&
             `          oParent[METHOD_INSERT](oView);` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          logError("displayNestedView: parent insert method failed", e);` && |\n| &&
             `          oView.destroy();` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `        z2ui5[viewProp] = oView;` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      // Shared destroy logic: close (if dialog/popover) and destroy the view,` && |\n| &&
             `      // then clear the slot on z2ui5.` && |\n| &&
             `      _destroyView(prop, tryClose) {` && |\n| &&
             `        const view = z2ui5[prop];` && |\n| &&
             `        if (!view) return;` && |\n| &&
             `        if (tryClose) {` && |\n| &&
             `          try {` && |\n| &&
             `            if (view.close) view.close();` && |\n| &&
             `          } catch (e) {` && |\n| &&
             `            logError(``_destroyView: view.close() failed for ${prop}``, e);` && |\n| &&
             `          }` && |\n| &&
             `        }` && |\n| &&
             `        try {` && |\n| &&
             `          view.destroy();` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          logError(``_destroyView: view.destroy() failed for ${prop}``, e);` && |\n| &&
             `        }` && |\n| &&
             `        z2ui5[prop] = null;` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      PopupDestroy() {` && |\n| &&
             `        this._destroyView("oViewPopup", true);` && |\n| &&
             `      },` && |\n| &&
             `      PopoverDestroy() {` && |\n| &&
             `        this._destroyView("oViewPopover", true);` && |\n| &&
             `      },` && |\n| &&
             `      NestViewDestroy() {` && |\n| &&
             `        this._destroyView("oViewNest");` && |\n| &&
             `      },` && |\n| &&
             `      NestViewDestroy2() {` && |\n| &&
             `        this._destroyView("oViewNest2");` && |\n| &&
             `      },` && |\n| &&
             `      ViewDestroy() {` && |\n| &&
             `        this._destroyView("oView");` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      // ------------------------------------------------------------------` && |\n| &&
             `      // eF: handle frontend-only events triggered by the backend response.` && |\n| &&
             `      // ------------------------------------------------------------------` && |\n| &&
             `      eF(...args) {` && |\n| &&
             `        runCallbacks(z2ui5.onBeforeEventFrontend, args);` && |\n| &&
             `` && |\n| &&
             `        // NavContainer navigation is dispatched via lookup table.` && |\n| &&
             `        const navLookup = navContainerLookups[args[0]];` && |\n| &&
             `        if (navLookup) {` && |\n| &&
             `          navigateContainer(navLookup, args);` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `` && |\n| &&
             `        switch (args[0]) {` && |\n| &&
             `          case "SET_SIZE_LIMIT":` && |\n| &&
             `            this._evSetSizeLimit(args);` && |\n| &&
             `            break;` && |\n| &&
             `          case "HISTORY_BACK":` && |\n| &&
             `            history.back();` && |\n| &&
             `            break;` && |\n| &&
             `          case "CLIPBOARD_COPY":` && |\n| &&
             `            copyToClipboard(args[1]);` && |\n| &&
             `            break;` && |\n| &&
             `          case "CLIPBOARD_APP_STATE": {` && |\n| &&
             `            const id = z2ui5.oResponse && z2ui5.oResponse.ID;` && |\n| &&
             `            copyToClipboard(``${window.location.href}#/z2ui5-xapp-state=${id}``);` && |\n| &&
             `            break;` && |\n| &&
             `          }` && |\n| &&
             `          case "SET_ODATA_MODEL":` && |\n| &&
             `            this._evSetODataModel(args);` && |\n| &&
             `            break;` && |\n| &&
             `          case "STORE_DATA":` && |\n| &&
             `            this._evStoreData(args);` && |\n| &&
             `            break;` && |\n| &&
             `          case "DOWNLOAD_B64_FILE": {` && |\n| &&
             `            const a = document.createElement("a");` && |\n| &&
             `            a.href = args[1];` && |\n| &&
             `            a.download = args[2];` && |\n| &&
             `            a.click();` && |\n| &&
             `            break;` && |\n| &&
             `          }` && |\n| &&
             `          case "CROSS_APP_NAV_TO_PREV_APP":` && |\n| &&
             `            withCrossAppNavigator((nav) => nav.backToPreviousApp());` && |\n| &&
             `            break;` && |\n| &&
             `          case "CROSS_APP_NAV_TO_EXT":` && |\n| &&
             `            this._evCrossAppNavToExt(args);` && |\n| &&
             `            break;` && |\n| &&
             `          case "LOCATION_RELOAD":` && |\n| &&
             `            this._evLocationReload(args);` && |\n| &&
             `            break;` && |\n| &&
             `          case "SYSTEM_LOGOUT":` && |\n| &&
             `            this._evSystemLogout(args);` && |\n| &&
             `            break;` && |\n| &&
             `          case "OPEN_NEW_TAB":` && |\n| &&
             `            this._evOpenNewTab(args);` && |\n| &&
             `            break;` && |\n| &&
             `          case "POPUP_CLOSE":` && |\n| &&
             `            this.PopupDestroy();` && |\n| &&
             `            break;` && |\n| &&
             `          case "POPOVER_CLOSE":` && |\n| &&
             `            this.PopoverDestroy();` && |\n| &&
             `            break;` && |\n| &&
             `          case "URLHELPER":` && |\n| &&
             `            this._evUrlHelper(args);` && |\n| &&
             `            break;` && |\n| &&
             `          case "IMAGE_EDITOR_POPUP_CLOSE":` && |\n| &&
             `            this._evImageEditorPopupClose();` && |\n| &&
             `            break;` && |\n| &&
             `          case "SET_TITLE":` && |\n| &&
             `            this._evSetTitle(args);` && |\n| &&
             `            break;` && |\n| &&
             `          case "SET_FOCUS":` && |\n| &&
             `            this._evSetFocus(args);` && |\n| &&
             `            break;` && |\n| &&
             `          case "SCROLL_TO":` && |\n| &&
             `            this._evScrollTo(args);` && |\n| &&
             `            break;` && |\n| &&
             `          case "SCROLL_INTO_VIEW":` && |\n| &&
             `            this._evScrollIntoView(args);` && |\n| &&
             `            break;` && |\n| &&
             `          case "START_TIMER":` && |\n| &&
             `            this._evStartTimer(args);` && |\n| &&
             `            break;` && |\n| &&
             `          case "KEYBOARD_SET_MODE":` && |\n| &&
             `            this._evSetInputMode(args);` && |\n| &&
             `            break;` && |\n| &&
             `          case "Z2UI5":` && |\n| &&
             `            this._evZ2ui5Custom(args);` && |\n| &&
             `            break;` && |\n| &&
             `          case "WIZARD_SET_NEXT_STEP":` && |\n| &&
             `            this._evWizardSetNextStep(args);` && |\n| &&
             `            break;` && |\n| &&
             `          case "PLAY_AUDIO":` && |\n| &&
             `            this._evPlayAudio(args);` && |\n| &&
             `            break;` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      // ------------------------------------------------------------------` && |\n| &&
             `      // Individual event handlers - one per case in eF(). Splitting them out` && |\n| &&
             `      // keeps eF() short and makes each behavior easy to find.` && |\n| &&
             `      // ------------------------------------------------------------------` && |\n| &&
             `` && |\n| &&
             `      _evSetSizeLimit(args) {` && |\n| &&
             `        // Two call shapes:` && |\n| &&
             `        //   ["SET_SIZE_LIMIT", "<limit>", "<viewKey>"]   -> set the limit` && |\n| &&
             `        //   ["SET_SIZE_LIMIT", "<viewKey>"]              -> reset the limit` && |\n| &&
             `        const hasLimit = args[2] !== undefined && args[2] !== "";` && |\n| &&
             `        const viewKey = hasLimit ? args[2] : args[1];` && |\n| &&
             `        const limit = hasLimit ? Number(args[1]) : NaN;` && |\n| &&
             `        const view = viewLookups[viewKey] && viewLookups[viewKey]();` && |\n| &&
             `        const model = view && view.getModel();` && |\n| &&
             `` && |\n| &&
             `        if (Number.isFinite(limit) && limit > 0) {` && |\n| &&
             `          if (!z2ui5.viewSizeLimits) z2ui5.viewSizeLimits = {};` && |\n| &&
             `          z2ui5.viewSizeLimits[viewKey] = limit;` && |\n| &&
             `          if (model) {` && |\n| &&
             `            model.setSizeLimit(limit);` && |\n| &&
             `            model.refresh(true);` && |\n| &&
             `          }` && |\n| &&
             `        } else {` && |\n| &&
             `          if (z2ui5.viewSizeLimits) delete z2ui5.viewSizeLimits[viewKey];` && |\n| &&
             `          if (model) {` && |\n| &&
             `            model.setSizeLimit(100);` && |\n| &&
             `            model.refresh(true);` && |\n| &&
             `          }` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      _evSetODataModel(args) {` && |\n| &&
             `        try {` && |\n| &&
             `          const oModel = new ODataModel({` && |\n| &&
             `            serviceUrl: args[1],` && |\n| &&
             `            annotationURI: args[3] || "",` && |\n| &&
             `          });` && |\n| &&
             `          if (z2ui5.oView) z2ui5.oView.setModel(oModel, args[2] || undefined);` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          logError(``SET_ODATA_MODEL: failed for '${args[1]}'``, e);` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      _evStoreData(args) {` && |\n| &&
             `        const { TYPE, PREFIX, VALUE, KEY } = args[1];` && |\n| &&
             `        try {` && |\n| &&
             `          const storageType = Storage.Type[TYPE] || Storage.Type.session;` && |\n| &&
             `          const oStorage = new Storage(storageType, PREFIX);` && |\n| &&
             `          if (VALUE === "" || VALUE == null) {` && |\n| &&
             `            oStorage.remove(KEY);` && |\n| &&
             `          } else {` && |\n| &&
             `            oStorage.put(KEY, VALUE);` && |\n| &&
             `          }` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          logError(``STORE_DATA: storage operation failed for key '${KEY}'``, e);` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      _evCrossAppNavToExt(args) {` && |\n| &&
             `        withCrossAppNavigator((nav) => {` && |\n| &&
             `          const hash =` && |\n| &&
             `            nav.hrefForExternal({ target: args[1], params: args[2] }) || "";` && |\n| &&
             `          if (args[3] === "EXT") {` && |\n| &&
             `            // External redirect: replace the location while keeping the host.` && |\n| &&
             `            const base = window.location.href.split("#")[0];` && |\n| &&
             `            _URLHelper.redirect(``${base}${hash}``, true);` && |\n| &&
             `          } else {` && |\n| &&
             `            nav.toExternal({ target: { shellHash: hash } });` && |\n| &&
             `          }` && |\n| &&
             `        });` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      _evLocationReload(args) {` && |\n| &&
             `        if (isValidRedirectURL(args[1])) {` && |\n| &&
             `          window.location.href = args[1];` && |\n| &&
             `        } else {` && |\n| &&
             `          MessageBox.error(` && |\n| &&
             `            "Invalid redirect URL. Only relative URLs to the same domain are allowed.",` && |\n| &&
             `          );` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      _evSystemLogout(args) {` && |\n| &&
             `        const logoutUrl = args[1] || "/sap/public/bc/icf/logoff";` && |\n| &&
             `        const goToLogoutUrl = () => {` && |\n| &&
             `          if (isValidRedirectURL(logoutUrl)) {` && |\n| &&
             `            window.location.href = logoutUrl;` && |\n| &&
             `          } else {` && |\n| &&
             `            MessageBox.error(` && |\n| &&
             `              "Invalid logout URL. Only relative URLs to the same domain are allowed.",` && |\n| &&
             `            );` && |\n| &&
             `          }` && |\n| &&
             `        };` && |\n| &&
             `        // When abap2UI5 is hosted as a BSP application,` && |\n| &&
             `        // /sap/public/bc/icf/logoff alone does not terminate the stateful` && |\n| &&
             `        // BSP context (sap-contextid stays bound to /sap/bc/bsp/sap/<app>/).` && |\n| &&
             `        // Hit the BSP path with ?sap-sessioncmd=logoff first so the BSP` && |\n| &&
             `        // runtime calls server->session->terminate( ), then go to the ICF` && |\n| &&
             `        // logoff to also drop the SSO2 ticket.` && |\n| &&
             `        const redirectToLogoff = () => {` && |\n| &&
             `          const path = window.location.pathname;` && |\n| &&
             `          if (path.indexOf("/sap/bc/bsp/") !== 0) {` && |\n| &&
             `            goToLogoutUrl();` && |\n| &&
             `            return;` && |\n| &&
             `          }` && |\n| &&
             `          const sep = path.indexOf("?") >= 0 ? "&" : "?";` && |\n| &&
             `          const bspKill = path + sep + "sap-sessioncmd=logoff";` && |\n| &&
             `          let done = false;` && |\n| &&
             `          const finish = () => {` && |\n| &&
             `            if (done) return;` && |\n| &&
             `            done = true;` && |\n| &&
             `            goToLogoutUrl();` && |\n| &&
             `          };` && |\n| &&
             `          try {` && |\n| &&
             `            const f = document.createElement("iframe");` && |\n| &&
             `            f.style.display = "none";` && |\n| &&
             `            f.src = bspKill;` && |\n| &&
             `            f.addEventListener("load", finish);` && |\n| &&
             `            document.body.appendChild(f);` && |\n| &&
             `          } catch (e) {` && |\n| &&
             `            finish();` && |\n| &&
             `            return;` && |\n| &&
             `          }` && |\n| &&
             `          // Safety net: never wait longer than 1.5s for the BSP terminate.` && |\n| &&
             `          setTimeout(finish, 1500);` && |\n| &&
             `        };` && |\n| &&
             `        try {` && |\n| &&
             `          const launchpadLogout =` && |\n| &&
             `            z2ui5.oLaunchpad &&` && |\n| &&
             `            z2ui5.oLaunchpad.Container &&` && |\n| &&
             `            z2ui5.oLaunchpad.Container.logout;` && |\n| &&
             `          if (launchpadLogout) {` && |\n| &&
             `            z2ui5.oLaunchpad.Container.logout();` && |\n| &&
             `          } else {` && |\n| &&
             `            redirectToLogoff();` && |\n| &&
             `          }` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          logError("SYSTEM_LOGOUT: ushell logout failed", e);` && |\n| &&
             `          redirectToLogoff();` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      _evOpenNewTab(args) {` && |\n| &&
             `        if (!isValidRedirectURL(args[1])) {` && |\n| &&
             `          MessageBox.error(` && |\n| &&
             `            "Invalid URL. Only relative URLs to the same domain are allowed.",` && |\n| &&
             `          );` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `        const newWindow = window.open(args[1], "_blank");` && |\n| &&
             `        // Clear opener to prevent the new tab from accessing window.opener.` && |\n| &&
             `        if (newWindow) newWindow.opener = null;` && |\n| &&
             `      },` && |\n| &&
             |\n|.
    result = result &&
             `` && |\n| &&
             `      _evUrlHelper(args) {` && |\n| &&
             `        const params = args[2];` && |\n| &&
             `        const actions = {` && |\n| &&
             `          REDIRECT: () => _URLHelper.redirect(params.URL, params.NEW_WINDOW),` && |\n| &&
             `          TRIGGER_EMAIL: () =>` && |\n| &&
             `            _URLHelper.triggerEmail(` && |\n| &&
             `              params.EMAIL,` && |\n| &&
             `              params.SUBJECT,` && |\n| &&
             `              params.BODY,` && |\n| &&
             `              params.CC,` && |\n| &&
             `              params.BCC,` && |\n| &&
             `              params.NEW_WINDOW,` && |\n| &&
             `            ),` && |\n| &&
             `          TRIGGER_SMS: () => _URLHelper.triggerSms(params),` && |\n| &&
             `          TRIGGER_TEL: () => _URLHelper.triggerTel(params),` && |\n| &&
             `        };` && |\n| &&
             `        try {` && |\n| &&
             `          const fn = actions[args[1]];` && |\n| &&
             `          if (fn) fn();` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          logError(``URLHELPER: '${args[1]}' failed``, e);` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      _evImageEditorPopupClose() {` && |\n| &&
             `        let image;` && |\n| &&
             `        try {` && |\n| &&
             `          const editor = Fragment.byId("popupId", "imageEditor");` && |\n| &&
             `          if (editor) image = editor.getImagePngDataURL();` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          logError("IMAGE_EDITOR_POPUP_CLOSE: getImagePngDataURL failed", e);` && |\n| &&
             `        }` && |\n| &&
             `        this.PopupDestroy();` && |\n| &&
             `        this.eB(["SAVE"], image);` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      _evStartTimer(args) {` && |\n| &&
             `        const timerKey = args[0];` && |\n| &&
             `        const callbackEvent = args[1];` && |\n| &&
             `        const delay = +args[2] || 0;` && |\n| &&
             `        if (!z2ui5.timers) z2ui5.timers = {};` && |\n| &&
             `        clearTimeout(z2ui5.timers[timerKey]);` && |\n| &&
             `        z2ui5.timers[timerKey] = setTimeout(() => {` && |\n| &&
             `          delete z2ui5.timers[timerKey];` && |\n| &&
             `          this.eB([callbackEvent]);` && |\n| &&
             `        }, delay);` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      _evSetInputMode(args) {` && |\n| &&
             `        try {` && |\n| &&
             `          const oElement = z2ui5.oView && z2ui5.oView.byId(args[1]);` && |\n| &&
             `          if (!oElement) return;` && |\n| &&
             `          const dom = oElement.getDomRef();` && |\n| &&
             `          if (!dom) return;` && |\n| &&
             `          const input = dom.matches("input, textarea")` && |\n| &&
             `            ? dom` && |\n| &&
             `            : dom.querySelector("input, textarea");` && |\n| &&
             `          if (!input) return;` && |\n| &&
             `          input.setAttribute("inputmode", args[2] || "text");` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          logError(` && |\n| &&
             `            ``KEYBOARD_SET_MODE: setAttribute failed for '${args[1]}'``,` && |\n| &&
             `            e,` && |\n| &&
             `          );` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      _evSetFocus(args) {` && |\n| &&
             `        try {` && |\n| &&
             `          const oElement = z2ui5.oView && z2ui5.oView.byId(args[1]);` && |\n| &&
             `          if (!oElement) return;` && |\n| &&
             `          const info = oElement.getFocusInfo();` && |\n| &&
             `          if (args[2] != null && args[2] !== "") info.selectionStart = +args[2];` && |\n| &&
             `          if (args[3] != null && args[3] !== "") info.selectionEnd = +args[3];` && |\n| &&
             `          oElement.applyFocusInfo(info);` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          logError(``SET_FOCUS: failed for '${args[1]}'``, e);` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      _evScrollTo(args) {` && |\n| &&
             `        // args[1] = control id` && |\n| &&
             `        // args[2] = scrollTop  (Y, vertical, px)` && |\n| &&
             `        // args[3] = scrollLeft (X, horizontal, px) - optional, default 0` && |\n| &&
             `        // args[4] = behavior - "auto" (default) | "smooth" | "instant"` && |\n| &&
             `        // When behavior is "smooth" the modern Element.scrollTo({...,` && |\n| &&
             `        // behavior}) API is used. Otherwise the Scrolling custom control's` && |\n| &&
             `        // restoration logic is mirrored (delegate.scrollTo / scrollTop on` && |\n| &&
             `        // the -inner DOM element).` && |\n| &&
             `        try {` && |\n| &&
             `          const oElement = z2ui5.oView && z2ui5.oView.byId(args[1]);` && |\n| &&
             `          if (!oElement) return;` && |\n| &&
             `          const y = +args[2] || 0;` && |\n| &&
             `          const x = +args[3] || 0;` && |\n| &&
             `          const behavior = args[4] || "auto";` && |\n| &&
             `` && |\n| &&
             `          if (behavior === "smooth" || behavior === "instant") {` && |\n| &&
             `            const dom =` && |\n| &&
             `              document.getElementById(``${oElement.getId()}-inner``) ||` && |\n| &&
             `              oElement.getDomRef();` && |\n| &&
             `            if (dom && dom.scrollTo) {` && |\n| &&
             `              dom.scrollTo({ top: y, left: x, behavior });` && |\n| &&
             `              return;` && |\n| &&
             `            }` && |\n| &&
             `          }` && |\n| &&
             `` && |\n| &&
             `          let handledByDelegate = false;` && |\n| &&
             `          try {` && |\n| &&
             `            const d =` && |\n| &&
             `              oElement.getScrollDelegate && oElement.getScrollDelegate();` && |\n| &&
             `            if (d && d.scrollTo) {` && |\n| &&
             `              // Hammer.js / iScroll delegate: scrollTo(x, y, time)` && |\n| &&
             `              d.scrollTo(x, y, 0);` && |\n| &&
             `              handledByDelegate = true;` && |\n| &&
             `            }` && |\n| &&
             `          } catch (e) {` && |\n| &&
             `            // fall through` && |\n| &&
             `          }` && |\n| &&
             `          if (!handledByDelegate && oElement.scrollTo) {` && |\n| &&
             `            // sap.m.Page.scrollTo(y, time) - vertical only` && |\n| &&
             `            oElement.scrollTo(y);` && |\n| &&
             `            handledByDelegate = true;` && |\n| &&
             `          }` && |\n| &&
             `          const dom = document.getElementById(``${oElement.getId()}-inner``);` && |\n| &&
             `          if (dom) {` && |\n| &&
             `            if (!handledByDelegate) dom.scrollTop = y;` && |\n| &&
             `            dom.scrollLeft = x;` && |\n| &&
             `          }` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          logError(``SCROLL_TO: failed for '${args[1]}'``, e);` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      _evScrollIntoView(args) {` && |\n| &&
             `        // args[1] = control id` && |\n| &&
             `        // args[2] = behavior - "smooth" (default) | "auto" | "instant"` && |\n| &&
             `        // args[3] = block    - "start"  (default) | "center" | "end" | "nearest"` && |\n| &&
             `        // args[4] = inline   - "nearest" (default)| "start"  | "center" | "end"` && |\n| &&
             `        // Modern declarative scroll: bring a control into the viewport,` && |\n| &&
             `        // regardless of where the surrounding scroll container currently is.` && |\n| &&
             `        try {` && |\n| &&
             `          const oElement = z2ui5.oView && z2ui5.oView.byId(args[1]);` && |\n| &&
             `          if (!oElement) return;` && |\n| &&
             `          const dom = oElement.getDomRef();` && |\n| &&
             `          if (!dom || !dom.scrollIntoView) return;` && |\n| &&
             `          dom.scrollIntoView({` && |\n| &&
             `            behavior: args[2] || "smooth",` && |\n| &&
             `            block: args[3] || "start",` && |\n| &&
             `            inline: args[4] || "nearest",` && |\n| &&
             `          });` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          logError(``SCROLL_INTO_VIEW: failed for '${args[1]}'``, e);` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      _evSetTitle(args) {` && |\n| &&
             `        const title = args[1] == null ? "" : String(args[1]);` && |\n| &&
             `        try {` && |\n| &&
             `          const shell = z2ui5.oLaunchpad && z2ui5.oLaunchpad.ShellUIService;` && |\n| &&
             `          if (shell && shell.setTitle) {` && |\n| &&
             `            const result = shell.setTitle(title);` && |\n| &&
             `            if (result && result.catch) {` && |\n| &&
             `              result.catch((e) =>` && |\n| &&
             `                logError("SET_TITLE: ShellUIService.setTitle failed", e),` && |\n| &&
             `              );` && |\n| &&
             `            }` && |\n| &&
             `          } else {` && |\n| &&
             `            document.title = title;` && |\n| &&
             `          }` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          logError("SET_TITLE: ShellUIService.setTitle failed", e);` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      _evZ2ui5Custom(args) {` && |\n| &&
             `        try {` && |\n| &&
             `          const fn = z2ui5[args[1]];` && |\n| &&
             `          if (fn) fn(args.slice(2));` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          logError(``Z2UI5: '${args[1]}' failed``, e);` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      _evWizardSetNextStep(args) {` && |\n| &&
             `        try {` && |\n| &&
             `          const wiz = z2ui5.oView && z2ui5.oView.byId(args[1]);` && |\n| &&
             `          const step = z2ui5.oView && z2ui5.oView.byId(args[2]);` && |\n| &&
             `          const nextStep = z2ui5.oView && z2ui5.oView.byId(args[3]);` && |\n| &&
             `          if (wiz && step) wiz.discardProgress(step);` && |\n| &&
             `          if (step && nextStep) step.setNextStep(nextStep);` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          logError(``WIZARD_SET_NEXT_STEP: failed for wizard '${args[1]}'``, e);` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      _evPlayAudio(args) {` && |\n| &&
             `        try {` && |\n| &&
             `          new Audio(args[1]).play();` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          logError(``PLAY_AUDIO: failed for '${args[1]}'``, e);` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      // ------------------------------------------------------------------` && |\n| &&
             `      // eB: trigger a backend roundtrip with arguments.` && |\n| &&
             `      // ------------------------------------------------------------------` && |\n| &&
             `      eB(...args) {` && |\n| &&
             `        if (!navigator.onLine) {` && |\n| &&
             `          MessageBox.alert(` && |\n| &&
             `            "No internet connection! Please reconnect to the server and try again.",` && |\n| &&
             `          );` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `` && |\n| &&
             `        // If a roundtrip is already in flight, briefly show a BusyDialog so` && |\n| &&
             `        // the user gets visual feedback instead of a silent click. args[0][2]` && |\n| &&
             `        // is the "ignore busy" flag set by certain background events.` && |\n| &&
             `        if (z2ui5.isBusy && !args[0][2]) {` && |\n| &&
             `          const oBusyDialog = new mBusyDialog();` && |\n| &&
             `          oBusyDialog.attachEventOnce("afterClose", () =>` && |\n| &&
             `            oBusyDialog.destroy(),` && |\n| &&
             `          );` && |\n| &&
             `          oBusyDialog.open();` && |\n| &&
             `          queueMicrotask(() => oBusyDialog.close());` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `` && |\n| &&
             `        z2ui5.isBusy = true;` && |\n| &&
             `        BusyIndicator.show();` && |\n| &&
             `        z2ui5.oBody = { VIEWNAME: "MAIN" };` && |\n| &&
             `` && |\n| &&
             `        // Decide which view's model holds the data we need to send back. The` && |\n| &&
             `        // mapping is: main app controller -> main view, popup controller ->` && |\n| &&
             `        // popup view, etc.` && |\n| &&
             `        const oModel = this._pickModelForRoundtrip(args);` && |\n| &&
             `` && |\n| &&
             `        runCallbacks(z2ui5.onBeforeRoundtrip);` && |\n| &&
             `` && |\n| &&
             `        // If the user edited /XX/ paths, send only the delta to keep the` && |\n| &&
             `        // payload small.` && |\n| &&
             `        if (oModel && z2ui5.xxChangedPaths && z2ui5.xxChangedPaths.size > 0) {` && |\n| &&
             `          const data = oModel.getData();` && |\n| &&
             `          const xx = data && data.XX;` && |\n| &&
             `          if (xx) {` && |\n| &&
             `            z2ui5.oBody.XX = this._buildDeltaFromPaths(` && |\n| &&
             `              z2ui5.xxChangedPaths,` && |\n| &&
             `              xx,` && |\n| &&
             `            );` && |\n| &&
             `          }` && |\n| &&
             `        }` && |\n| &&
             `` && |\n| &&
             `        z2ui5.oBody.ID = z2ui5.oResponse && z2ui5.oResponse.ID;` && |\n| &&
             `        // Object arguments are stringified for transport; the event name in` && |\n| &&
             `        // args[0] is left as-is.` && |\n| &&
             `        z2ui5.oBody.ARGUMENTS = args.map((item, i) => {` && |\n| &&
             `          if (i > 0 && typeof item === "object") return JSON.stringify(item);` && |\n| &&
             `          return item;` && |\n| &&
             `        });` && |\n| &&
             `` && |\n| &&
             `        z2ui5.oResponseOld = z2ui5.oResponse;` && |\n| &&
             `        Server.Roundtrip();` && |\n| &&
             `        runCallbacks(z2ui5.onAfterRoundtrip);` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      _pickModelForRoundtrip(args) {` && |\n| &&
             `        // The 4th positional flag in args[0] forces use of the main view's` && |\n| &&
             `        // model even when called from a popup/popover controller.` && |\n| &&
             `        if (args[0][3] || z2ui5.oController === this) {` && |\n| &&
             `          const sView =` && |\n| &&
             `            z2ui5.oResponse && z2ui5.oResponse.PARAMS` && |\n| &&
             `              ? z2ui5.oResponse.PARAMS.S_VIEW` && |\n| &&
             `              : null;` && |\n| &&
             `          if (sView && sView.SWITCH_DEFAULT_MODEL_PATH) {` && |\n| &&
             `            return z2ui5.oView && z2ui5.oView.getModel("http");` && |\n| &&
             `          }` && |\n| &&
             `          return z2ui5.oView && z2ui5.oView.getModel();` && |\n| &&
             `        }` && |\n| &&
             `        if (z2ui5.oControllerPopup === this) {` && |\n| &&
             `          return z2ui5.oViewPopup && z2ui5.oViewPopup.getModel();` && |\n| &&
             `        }` && |\n| &&
             `        if (z2ui5.oControllerPopover === this) {` && |\n| &&
             `          return z2ui5.oViewPopover && z2ui5.oViewPopover.getModel();` && |\n| &&
             `        }` && |\n| &&
             `        if (z2ui5.oControllerNest === this) {` && |\n| &&
             `          z2ui5.oBody.VIEWNAME = "NEST";` && |\n| &&
             `          return z2ui5.oViewNest && z2ui5.oViewNest.getModel();` && |\n| &&
             `        }` && |\n| &&
             `        if (z2ui5.oControllerNest2 === this) {` && |\n| &&
             `          z2ui5.oBody.VIEWNAME = "NEST2";` && |\n| &&
             `          return z2ui5.oViewNest2 && z2ui5.oViewNest2.getModel();` && |\n| &&
             `        }` && |\n| &&
             `        return undefined;` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      // Re-bind a model to one of the views when the response signals an` && |\n| &&
             `      // update is required for that particular slot.` && |\n| &&
             `      updateModelIfRequired(paramKey, oView) {` && |\n| &&
             `        const params = z2ui5.oResponse && z2ui5.oResponse.PARAMS;` && |\n| &&
             `        const slot = params && params[paramKey];` && |\n| &&
             `        if (!slot || !slot.CHECK_UPDATE_MODEL) return;` && |\n| &&
             `` && |\n| &&
             `        const oModel = this._createViewModel();` && |\n| &&
             `        applyStoredSizeLimit(paramToViewKey[paramKey], oModel);` && |\n| &&
             `        if (oView) oView.setModel(oModel);` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      async checkSDKcompatibility(err) {` && |\n| &&
             `        let gav;` && |\n| &&
             `        try {` && |\n| &&
             `          const info = await VersionInfo.load();` && |\n| &&
             `          gav = info.gav;` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          logError("checkSDKcompatibility: VersionInfo.load failed", e);` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `        if (!gav || !gav.includes("com.sap.ui5")) {` && |\n| &&
             `          // openui5 doesn't ship some sap.com modules - tell the user which` && |\n| &&
             `          // module is missing so they know to switch to SAPUI5.` && |\n| &&
             `          const missingModule = err && err._modules;` && |\n| &&
             `          MessageBox.error(` && |\n| &&
             `            ``openui5 SDK is loaded, module: ${missingModule} is not available in openui5``,` && |\n| &&
             `          );` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `        MessageBox.error(err.toLocaleString());` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      // Display a toast or message box. Triggered for S_MSG_TOAST and` && |\n| &&
             `      // S_MSG_BOX entries in the server response.` && |\n| &&
             `      showMessage(msgType, params) {` && |\n| &&
             `        if (!params) return;` && |\n| &&
             `        const msg = params[msgType];` && |\n| &&
             `        if (!msg || msg.TEXT === undefined) return;` && |\n| &&
             `` && |\n| &&
             `        if (msgType === "S_MSG_TOAST") {` && |\n| &&
             `          MessageToast.show(msg.TEXT, {` && |\n| &&
             `            duration: parseMs(msg.DURATION, 3000),` && |\n| &&
             `            width: msg.WIDTH || "15em",` && |\n| &&
             `            onClose: msg.ONCLOSE ? () => this.eB([msg.ONCLOSE]) : null,` && |\n| &&
             `            autoClose: !!msg.AUTOCLOSE,` && |\n| &&
             `            animationTimingFunction: msg.ANIMATIONTIMINGFUNCTION || "ease",` && |\n| &&
             `            animationDuration: parseMs(msg.ANIMATIONDURATION, 1000),` && |\n| &&
             `            closeonBrowserNavigation: !!msg.CLOSEONBROWSERNAVIGATION,` && |\n| &&
             `          });` && |\n| &&
             `          if (msg.CLASS) {` && |\n| &&
             `            const toastEl = document.querySelector(".sapMMessageToast");` && |\n| &&
             `            if (toastEl) {` && |\n| &&
             `              const classes = msg.CLASS.trim().split(/\s+/).filter(Boolean);` && |\n| &&
             `              toastEl.classList.add(...classes);` && |\n| &&
             `            }` && |\n| &&
             `          }` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `` && |\n| &&
             `        if (msgType === "S_MSG_BOX") {` && |\n| &&
             `          const oParams = {` && |\n| &&
             `            styleClass: msg.STYLECLASS || "",` && |\n| &&
             `            title: msg.TITLE || "",` && |\n| &&
             `            onClose: msg.ONCLOSE` && |\n| &&
             `              ? (sAction) => this.eB([msg.ONCLOSE, sAction])` && |\n| &&
             `              : null,` && |\n| &&
             `            actions: msg.ACTIONS || "OK",` && |\n| &&
             `            emphasizedAction: msg.EMPHASIZEDACTION || "OK",` && |\n| &&
             `            initialFocus: msg.INITIALFOCUS || null,` && |\n| &&
             `            textDirection: msg.TEXTDIRECTION || "Inherit",` && |\n| &&
             `            details: msg.DETAILS ? sanitizeMessageDetails(msg.DETAILS) : "",` && |\n| &&
             `            closeOnNavigation: !!msg.CLOSEONNAVIGATION,` && |\n| &&
             `          };` && |\n| &&
             `          if (msg.ICON && msg.ICON !== "NONE") oParams.icon = msg.ICON;` && |\n| &&
             `          const showFn = MessageBox[msg.TYPE];` && |\n| &&
             `          if (showFn) showFn(msg.TEXT, oParams);` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      // Replace the main app view with the XML coming from the backend.` && |\n| &&
             `      async displayView(xml, viewModel) {` && |\n| &&
             `        const oViewModel = this._trackChanges(new JSONModel(viewModel));` && |\n| &&
             `` && |\n| &&
             `        const sView =` && |\n| &&
             `          z2ui5.oResponse && z2ui5.oResponse.PARAMS` && |\n| &&
             `            ? z2ui5.oResponse.PARAMS.S_VIEW` && |\n| &&
             `            : null;` && |\n| &&
             `        const switchPath = sView && sView.SWITCH_DEFAULT_MODEL_PATH;` && |\n| &&
             `` && |\n| &&
             `        // When the app wants OData as the default model, build it here and` && |\n| &&
             `        // keep the JSON model as the named "http" model.` && |\n| &&
             `        let oModel;` && |\n| &&
             `        if (switchPath) {` && |\n| &&
             `          oModel = new ODataModel({` && |\n| &&
             `            serviceUrl: switchPath,` && |\n| &&
             `            annotationURI: sView.SWITCHDEFAULTMODELANNOURI || "",` && |\n| &&
             `          });` && |\n| &&
             `        } else {` && |\n| &&
             `          oModel = oViewModel;` && |\n| &&
             `        }` && |\n| &&
             `        applyStoredSizeLimit("MAIN", oModel);` && |\n| &&
             `` && |\n| &&
             `        z2ui5.oView = await XMLView.create({` && |\n| &&
             `          definition: xml,` && |\n| &&
             |\n|.
    result = result &&
             `          models: oModel,` && |\n| &&
             `          controller: z2ui5.oController,` && |\n| &&
             `          id: "mainView",` && |\n| &&
             `          preprocessors: { xml: { models: { template: oViewModel } } },` && |\n| &&
             `        });` && |\n| &&
             `` && |\n| &&
             `        // Guard against the app being destroyed during the await above.` && |\n| &&
             `        const appAlive =` && |\n| &&
             `          z2ui5.oApp && (!z2ui5.oApp.isDestroyed || !z2ui5.oApp.isDestroyed());` && |\n| &&
             `        if (!appAlive) {` && |\n| &&
             `          z2ui5.oView.destroy();` && |\n| &&
             `          if (switchPath) oModel.destroy();` && |\n| &&
             `          z2ui5.oView = null;` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `` && |\n| &&
             `        z2ui5.oView.setModel(z2ui5.oDeviceModel, "device");` && |\n| &&
             `        if (switchPath) z2ui5.oView.setModel(oViewModel, "http");` && |\n| &&
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
