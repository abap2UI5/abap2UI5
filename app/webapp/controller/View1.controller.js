sap.ui.define(
  [
    'sap/ui/core/mvc/Controller',
    'sap/ui/core/mvc/XMLView',
    'sap/ui/model/json/JSONModel',
    'sap/ui/core/BusyIndicator',
    'sap/m/MessageBox',
    'sap/m/MessageToast',
    'sap/ui/core/Fragment',
    'sap/m/BusyDialog',
    'sap/ui/VersionInfo',
    'z2ui5/cc/Server',
    'sap/ui/model/odata/v2/ODataModel',
    'sap/m/library',
    'sap/ui/core/routing/HashChanger',
    'sap/ui/util/Storage',
    'sap/ui/core/Element',
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
  ) => {
    'use strict';

    const runCallbacks = (arr, ...args) => {
      // Guard: someone may have clobbered the global with a non-iterable
      if (!Array.isArray(arr)) return;
      for (const fn of arr) {
        try {
          fn?.(...args);
        } catch (e) {
          _logError(`runCallbacks: callback failed`, e);
        }
      }
    };

    const _msgParser = new DOMParser();
    const _sanitizeEl = document.createElement('div');
    // ?? semantics: an explicit 0 from the backend should pass through (e.g. duration=0 to disable),
    // not be replaced by the default
    const parseMs = (val, def) => {
      if (val === undefined || val === null || val === '') return def;
      const n = +val;
      return Number.isFinite(n) ? n : def;
    };

    // length of the "/XX/" prefix on two-way binding paths
    const _XX_PATH_PREFIX_LEN = 4;
    const _TOAST_DEFAULT_WIDTH = '15em';
    const _TOAST_DEFAULT_DURATION_MS = 3000;
    const _TOAST_DEFAULT_ANIM_MS = 1000;
    const _ERRORS_CAP = 200;
    // Safety net: if a Dialog.afterClose never fires (stuck), still destroy after this many ms
    const _DESTROY_SAFETY_NET_MS = 1000;

    // Public getViewContent() became available in newer UI5 versions; fall back to the internal
    // mProperties.viewContent for older versions
    const _getViewContent = (view) => view?.getViewContent?.() ?? view?.mProperties?.viewContent;

    // Whitelist of MessageBox functions we accept from the backend — guards against
    // prototype-pollution (e.g. msg.TYPE === '__proto__') and unintended dispatch.
    const _MSG_BOX_TYPES = new Set(['error', 'success', 'warning', 'information', 'show', 'alert', 'confirm']);

    const _SAFE_PROTOCOLS = new Set(['http:', 'https:']);
    const _logError = (msg, err) => {
      // Defensive: if z2ui5.errors got clobbered with a non-array, reset it
      if (!Array.isArray(z2ui5.errors)) z2ui5.errors = [];
      const arr = z2ui5.errors;
      arr.push({
        message: msg,
        ...(err !== undefined && { error: err }),
        ts: new Date().toISOString(),
      });
      // Single splice trims any overflow in one shot (cap the rolling log)
      if (arr.length > _ERRORS_CAP) arr.splice(0, arr.length - _ERRORS_CAP);
    };

    const isValidRedirectURL = (url) => {
      if (!url) return false;
      try {
        const { origin, protocol } = new URL(url, window.location.origin);
        if (origin !== window.location.origin) {
          _logError(`Security: Blocked redirect to different origin: ${url}`);
          return false;
        }
        if (!_SAFE_PROTOCOLS.has(protocol)) {
          _logError(`Security: Blocked redirect with invalid protocol: ${protocol}`);
          return false;
        }
        return true;
      } catch (e) {
        _logError(`Security: Invalid URL format: ${url}`, e);
        return false;
      }
    };

    const _legacyClipboardCopy = (text) => {
      // Fallback for non-HTTPS contexts and older browsers without navigator.clipboard
      const ta = document.createElement('textarea');
      ta.value = text;
      ta.setAttribute('readonly', '');
      ta.style.cssText = 'position:fixed;top:-1000px;left:-1000px;opacity:0;';
      (document.body ?? document.documentElement).appendChild(ta);
      ta.select();
      try {
        // execCommand returns false if the copy was rejected (e.g. user gesture missing)
        const ok = document.execCommand('copy');
        if (!ok) _logError(`Clipboard: legacy execCommand returned false`);
      } catch (e) {
        _logError(`Clipboard: legacy execCommand failed`, e);
      } finally {
        ta.remove();
      }
    };

    const copyToClipboard = (textToCopy) => {
      if (navigator.clipboard?.writeText) {
        navigator.clipboard
          .writeText(textToCopy)
          .catch((err) => {
            _logError(`Clipboard: writeText failed, falling back to execCommand`, err);
            _legacyClipboardCopy(textToCopy);
          });
        return;
      }
      _legacyClipboardCopy(textToCopy);
    };

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

    const withCrossAppNavigator = (callback) => {
      const nav = z2ui5.oLaunchpad?.CrossAppNavigator;
      if (!nav) {
        _logError(`CrossAppNav: not running inside Launchpad`);
        return;
      }
      try {
        callback(nav);
      } catch (e) {
        _logError(`CrossAppNav: callback failed`, e);
      }
    };

    const navigateContainer = (lookup, args) => {
      try {
        lookup(args[1])?.to(lookup(args[2]));
      } catch (e) {
        _logError(`navigateContainer: navigation failed`, e);
      }
    };

    const _hashChanger = HashChanger.getInstance();
    const _URLHelper = mobileLibrary.URLHelper;

    // URLHelper actions table — module-level so we don't reallocate per call
    const _URL_HELPER_ACTIONS = {
      REDIRECT: (params) => _URLHelper.redirect(params.URL, params.NEW_WINDOW),
      TRIGGER_EMAIL: (params) =>
        _URLHelper.triggerEmail(params.EMAIL, params.SUBJECT, params.BODY, params.CC, params.BCC, params.NEW_WINDOW),
      TRIGGER_SMS: (params) => _URLHelper.triggerSms(params),
      TRIGGER_TEL: (params) => _URLHelper.triggerTel(params),
    };

    const navContainerLookups = {
      NAV_CONTAINER_TO: (id) => z2ui5.oView?.byId(id),
      NEST_NAV_CONTAINER_TO: (id) => z2ui5.oViewNest?.byId(id),
      NEST2_NAV_CONTAINER_TO: (id) => z2ui5.oViewNest2?.byId(id),
      POPUP_NAV_CONTAINER_TO: (id) => Fragment.byId('popupId', id),
      POPOVER_NAV_CONTAINER_TO: (id) => Fragment.byId('popoverId', id),
    };

    // Look up a control across all active views by ID (used by openBy and the Z2UI5 frontend action).
    // Uses the imported Fragment module directly instead of the per-instance Fragment property
    // pinned by displayFragment/displayPopover.
    const _findControlById = (id) =>
      z2ui5.oView?.byId(id) ||
      (z2ui5.oViewPopup && Fragment.byId('popupId', id)) ||
      (z2ui5.oViewPopover && Fragment.byId('popoverId', id)) ||
      z2ui5.oViewNest?.byId(id) ||
      z2ui5.oViewNest2?.byId(id) ||
      Element.getElementById?.(id) ||
      // sap.ui.getCore() is removed in ui5-legacy-free; chain with optional access for compatibility
      sap.ui.getCore?.()?.byId?.(id);

    const viewLookups = {
      MAIN: () => z2ui5.oView,
      NEST: () => z2ui5.oViewNest,
      NEST2: () => z2ui5.oViewNest2,
      POPUP: () => z2ui5.oViewPopup,
      POPOVER: () => z2ui5.oViewPopover,
    };

    const paramToViewKey = {
      S_VIEW: 'MAIN',
      S_VIEW_NEST: 'NEST',
      S_VIEW_NEST2: 'NEST2',
      S_POPUP: 'POPUP',
      S_POPOVER: 'POPOVER',
    };

    const applyStoredSizeLimit = (viewKey, oModel) => {
      const limit = z2ui5.viewSizeLimits?.[viewKey];
      if (limit !== undefined && oModel) oModel.setSizeLimit(limit);
    };

    return Controller.extend('z2ui5.controller.View1', {
      _trackChanges(oModel) {
        oModel.attachPropertyChange((e) => {
          const { path: raw, context: c } = e.getParameters();
          if (!raw) return;
          const p = c && !raw.startsWith('/') ? `${c.getPath()}/${raw}` : raw;
          if (p.startsWith('/XX/')) (z2ui5.xxChangedPaths ??= new Set()).add(p);
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
        if (z2ui5.oResponse) this._processAfterRendering();
      },
      async _processAfterRendering() {
        try {
          const { PARAMS, ID } = z2ui5.oResponse;
          if (!PARAMS) return;
          const { S_POPUP, S_VIEW_NEST, S_VIEW_NEST2, S_POPOVER, SET_APP_STATE_ACTIVE, SET_PUSH_STATE, SET_NAV_BACK } =
            PARAMS;
          // CHECK_DESTROY without a follow-up XML closes the popup; if XML is also present
          // the displayFragment branch destroys the existing popup before creating the new one,
          // so a separate CHECK_DESTROY here would be redundant double-destroy.
          if (S_POPUP?.CHECK_DESTROY && !S_POPUP?.XML) this.PopupDestroy();
          if (S_POPOVER?.CHECK_DESTROY && !S_POPOVER?.XML) this.PopoverDestroy();
          if (S_POPUP?.XML) {
            this.PopupDestroy();
            await this.displayFragment(S_POPUP.XML, 'oViewPopup');
          }
          if (!z2ui5.checkNestAfter && S_VIEW_NEST?.XML) {
            this.NestViewDestroy();
            await this.displayNestedView(S_VIEW_NEST.XML, 'oViewNest', 'S_VIEW_NEST', z2ui5.oControllerNest);
            z2ui5.checkNestAfter = true;
          }
          if (!z2ui5.checkNestAfter2 && S_VIEW_NEST2?.XML) {
            this.NestViewDestroy2();
            await this.displayNestedView(S_VIEW_NEST2.XML, 'oViewNest2', 'S_VIEW_NEST2', z2ui5.oControllerNest2);
            z2ui5.checkNestAfter2 = true;
          }
          if (S_POPOVER?.XML) await this.displayPopover(S_POPOVER.XML, 'oViewPopover', S_POPOVER.OPEN_BY_ID);

          const oView = z2ui5.oView;
          const oState = oView
            ? { view: _getViewContent(oView), model: oView.getModel()?.getData(), response: z2ui5.oResponse }
            : {};
          try {
            if (SET_PUSH_STATE) {
              const hash = _hashChanger.getHash() || '#';
              // Avoid emitting `##` if SET_PUSH_STATE already starts with a hash
              const tail = SET_PUSH_STATE.startsWith('#') && hash === '#' ? SET_PUSH_STATE : `${hash}${SET_PUSH_STATE}`;
              this._safeHistoryWrite(
                'pushState',
                oState,
                `${window.location.pathname}${window.location.search}${tail}`,
              );
            } else {
              this._safeHistoryWrite('replaceState', oState, window.location.href);
            }
            _hashChanger.replaceHash(SET_APP_STATE_ACTIVE ? `z2ui5-xapp-state=${ID ?? ''}` : '');
          } catch (e) {
            _logError(`_processAfterRendering: history update failed`, e);
          }
          if (SET_NAV_BACK && history.length > 1) history.back();

          runCallbacks(z2ui5.onAfterRendering);
        } catch (e) {
          _logError(`_processAfterRendering: unexpected error`, e);
          // i18n: title key "appTerminated.title", body key "appTerminated.body"
          MessageBox.error(e.message ?? String(e), {
            title: 'Unexpected Error Occurred - App Terminated',
            actions: [],
            onClose: () => new mBusyDialog({ text: 'Please Restart the App' }).open(),
          });
        } finally {
          BusyIndicator.hide();
          z2ui5.isBusy = false;
        }
      },
      _buildDeltaFromPaths(paths, xx) {
        const delta = {};
        for (const path of paths) {
          const [attr, rowIdx, field] = path.slice(_XX_PATH_PREFIX_LEN).split('/');
          if (field !== undefined && rowIdx !== '' && Number.isFinite(+rowIdx)) {
            if (!delta[attr]?.__delta) delta[attr] = { __delta: {} };
            const attrDelta = delta[attr].__delta;
            attrDelta[rowIdx] ??= {};
            attrDelta[rowIdx][field] = xx[attr]?.[+rowIdx]?.[field];
          } else {
            delta[attr] = xx[attr];
          }
        }
        return delta;
      },
      // Try a full pushState/replaceState; if the browser rejects the state object
      // (~640 kB quota in some browsers) progressively shrink the state until it fits,
      // and finally fall back to a null state if even the view alone is too large.
      _safeHistoryWrite(method, state, url) {
        try {
          history[method](state, '', url);
          return;
        } catch (e) {
          _logError(`_safeHistoryWrite: ${method} oversized state — retrying without model`, e);
        }
        // First retry: drop the model (typically the largest payload)
        try {
          const tier1 = state ? { view: state.view, response: state.response } : {};
          history[method](tier1, '', url);
          return;
        } catch (e) {
          _logError(`_safeHistoryWrite: ${method} still oversized — retrying with view only`, e);
        }
        // Second retry: keep only the view XML so popstate can still restore the page
        try {
          const tier2 = state ? { view: state.view } : {};
          history[method](tier2, '', url);
          return;
        } catch (e) {
          _logError(`_safeHistoryWrite: ${method} failed even with view-only state`, e);
        }
        // Last resort: null state — popstate handler will treat it as a no-op
        try {
          history[method](null, '', url);
        } catch (e) {
          _logError(`_safeHistoryWrite: ${method} failed with null state`, e);
        }
      },
      _createViewModel() {
        return this._trackChanges(new JSONModel(z2ui5.oResponse?.OVIEWMODEL));
      },
      async displayFragment(xml, viewProp) {
        const oModel = this._createViewModel();
        applyStoredSizeLimit('POPUP', oModel);
        let oFragment;
        try {
          oFragment = await Fragment.load({
            definition: xml,
            controller: z2ui5.oControllerPopup,
            id: 'popupId',
          });
        } catch (e) {
          oModel.destroy?.();
          _logError(`displayFragment: Fragment.load failed`, e);
          return;
        }
        if (!z2ui5.oApp || z2ui5.oApp.isDestroyed()) {
          oFragment.destroy();
          oModel.destroy?.();
          return;
        }
        oFragment.setModel(oModel);
        // .Fragment is pinned for legacy app-side lookups; new code should import Fragment directly
        oFragment.Fragment = Fragment;
        z2ui5[viewProp] = oFragment;
        oFragment.open();
      },
      async displayPopover(xml, viewProp, openById) {
        const oModel = this._createViewModel();
        applyStoredSizeLimit('POPOVER', oModel);
        let oFragment;
        try {
          oFragment = await Fragment.load({
            definition: xml,
            controller: z2ui5.oControllerPopover,
            id: 'popoverId',
          });
        } catch (e) {
          oModel.destroy?.();
          _logError(`displayPopover: Fragment.load failed`, e);
          return;
        }
        try {
          if (!z2ui5.oApp || z2ui5.oApp.isDestroyed()) {
            oFragment.destroy();
            oModel.destroy?.();
            return;
          }
          oFragment.setModel(oModel);
          // .Fragment pinned for legacy app-side lookups; new code should import Fragment directly
          oFragment.Fragment = Fragment;
          z2ui5[viewProp] = oFragment;
          const oControl = _findControlById(openById);
          if (!oControl) {
            _logError(`displayPopover: openBy control '${openById}' not found`);
            // Fragment + model are unowned at this point — release them instead of leaking
            z2ui5[viewProp] = null;
            oFragment.destroy();
            oModel.destroy?.();
            return;
          }
          oFragment.openBy(oControl);
        } catch (e) {
          _logError(`displayPopover: failed`, e);
        }
      },
      async displayNestedView(xml, viewProp, viewNestId, controller) {
        const oModel = this._createViewModel();
        applyStoredSizeLimit(paramToViewKey[viewNestId], oModel);
        let oView;
        try {
          oView = await XMLView.create({
            definition: xml,
            controller,
            preprocessors: { xml: { models: { template: oModel } } },
          });
        } catch (e) {
          oModel.destroy?.();
          throw e;
        }
        const abort = (reason, err) => {
          if (reason) _logError(reason, err);
          oView.destroy();
          oModel.destroy?.();
        };
        if (!z2ui5.oApp || z2ui5.oApp.isDestroyed()) {
          abort();
          return;
        }
        oView.setModel(oModel);
        const nestParams = z2ui5.oResponse?.PARAMS?.[viewNestId];
        if (!nestParams) {
          abort(`displayNestedView: missing PARAMS.${viewNestId}`);
          return;
        }
        const { ID, METHOD_DESTROY, METHOD_INSERT } = nestParams;
        const oParent = z2ui5.oView?.byId(ID);
        if (!oParent) {
          abort(`displayNestedView: parent control '${ID}' not found, nested view discarded`);
          return;
        }
        // typeof guards: METHOD_DESTROY/INSERT come from the backend; tolerate missing/non-function values
        if (typeof oParent[METHOD_DESTROY] === 'function') {
          try {
            oParent[METHOD_DESTROY]();
          } catch (e) {
            _logError(`displayNestedView: parent destroy method '${METHOD_DESTROY}' failed`, e);
          }
        } else {
          _logError(`displayNestedView: parent has no method '${METHOD_DESTROY}'`);
        }
        if (typeof oParent[METHOD_INSERT] !== 'function') {
          abort(`displayNestedView: parent has no method '${METHOD_INSERT}'`);
          return;
        }
        try {
          oParent[METHOD_INSERT](oView);
        } catch (e) {
          abort(`displayNestedView: parent insert method '${METHOD_INSERT}' failed`, e);
          return;
        }
        z2ui5[viewProp] = oView;
      },
      _destroyView(prop, tryClose) {
        const view = z2ui5[prop];
        if (!view) return;
        z2ui5[prop] = null;
        let destroyed = false;
        let safetyTimer = null;
        const closeAndDestroy = () => {
          if (destroyed) return;
          destroyed = true;
          if (safetyTimer !== null) clearTimeout(safetyTimer);
          try {
            view.destroy();
          } catch (e) {
            _logError(`_destroyView: view.destroy() failed for ${prop}`, e);
          }
        };
        if (tryClose) {
          try {
            const ret = view.close?.();
            // Defer destroy until the close animation has settled. If close() returned a
            // thenable we wait for it; otherwise an afterClose handler covers Dialog/Popover.
            if (ret && typeof ret.then === 'function') {
              ret.then(closeAndDestroy, closeAndDestroy);
              return;
            }
            if (typeof view.attachEventOnce === 'function' && typeof view.isOpen === 'function' && view.isOpen()) {
              view.attachEventOnce('afterClose', closeAndDestroy);
              // Safety net: if afterClose never fires (e.g. dialog stuck), still destroy.
              // The timer is cleared in closeAndDestroy so we don't keep an orphan callback.
              safetyTimer = setTimeout(closeAndDestroy, _DESTROY_SAFETY_NET_MS);
              return;
            }
          } catch (e) {
            _logError(`_destroyView: view.close() failed for ${prop}`, e);
          }
        }
        closeAndDestroy();
      },
      PopupDestroy() {
        this._destroyView('oViewPopup', true);
      },
      PopoverDestroy() {
        this._destroyView('oViewPopover', true);
      },
      NestViewDestroy() {
        this._destroyView('oViewNest');
      },
      NestViewDestroy2() {
        this._destroyView('oViewNest2');
      },
      ViewDestroy() {
        this._destroyView('oView');
      },
      eF(...args) {
        runCallbacks(z2ui5.onBeforeEventFrontend, args);

        // Object.hasOwn guard prevents prototype lookups (e.g. args[0] === 'constructor')
        const navLookup =
          typeof args[0] === 'string' && Object.hasOwn(navContainerLookups, args[0]) ? navContainerLookups[args[0]] : null;
        if (navLookup) {
          navigateContainer(navLookup, args);
          return;
        }

        switch (args[0]) {
          case 'SET_SIZE_LIMIT': {
            const hasLimit = args[2] !== undefined && args[2] !== '';
            const viewKey = hasLimit ? args[2] : args[1];
            const limit = hasLimit ? Number(args[1]) : NaN;
            // Object.hasOwn guard prevents prototype access (viewKey === '__proto__' etc.)
            const model =
              typeof viewKey === 'string' && Object.hasOwn(viewLookups, viewKey)
                ? viewLookups[viewKey]()?.getModel()
                : undefined;
            if (Number.isFinite(limit) && limit > 0) {
              (z2ui5.viewSizeLimits ??= {})[viewKey] = limit;
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
            break;
          }
          case 'HISTORY_BACK':
            // Only navigate back when there is actually an entry to go back to
            if (history.length > 1) history.back();
            break;
          case 'CLIPBOARD_COPY':
            copyToClipboard(args[1]);
            break;
          case 'CLIPBOARD_APP_STATE': {
            // Strip any existing hash before appending — avoids producing a malformed URL with two `#`
            const baseUrl = window.location.href.split('#')[0];
            copyToClipboard(`${baseUrl}#/z2ui5-xapp-state=${z2ui5.oResponse?.ID ?? ''}`);
            break;
          }
          case 'SET_ODATA_MODEL': {
            try {
              const modelName = args[2] || undefined;
              // Destroy a previously bound ODataModel under the same name to release sockets/handlers
              const previous = z2ui5.oView?.getModel(modelName);
              const oModel = new ODataModel({ serviceUrl: args[1], annotationURI: args[3] ?? '' });
              z2ui5.oView?.setModel(oModel, modelName);
              if (previous && previous !== oModel && typeof previous.destroy === 'function') previous.destroy();
            } catch (e) {
              _logError(`SET_ODATA_MODEL: failed for '${args[1]}'`, e);
            }
            break;
          }
          case 'STORE_DATA': {
            const { TYPE, PREFIX, VALUE, KEY } = args[1];
            try {
              const StorageTypes = Storage?.Type ?? {};
              // Object.hasOwn guard prevents prototype lookups (TYPE === '__proto__')
              const resolvedType =
                typeof TYPE === 'string' && Object.hasOwn(StorageTypes, TYPE)
                  ? StorageTypes[TYPE]
                  : StorageTypes.session;
              const oStorage = new Storage(resolvedType, PREFIX);
              if (VALUE === '' || VALUE == null) {
                oStorage.remove(KEY);
              } else {
                oStorage.put(KEY, VALUE);
              }
            } catch (e) {
              _logError(`STORE_DATA: storage operation failed for key '${KEY}'`, e);
            }
            break;
          }
          case 'DOWNLOAD_B64_FILE': {
            // Firefox ignores click() on a detached anchor; attach briefly to the body
            const a = Object.assign(document.createElement('a'), { href: args[1], download: args[2] });
            document.body.appendChild(a);
            a.click();
            a.remove();
            break;
          }
          case 'CROSS_APP_NAV_TO_PREV_APP':
            withCrossAppNavigator((nav) => nav.backToPreviousApp());
            break;
          case 'CROSS_APP_NAV_TO_EXT':
            withCrossAppNavigator((nav) => {
              const hash = nav.hrefForExternal({ target: args[1], params: args[2] }) ?? '';
              if (args[3] === 'EXT') {
                _URLHelper.redirect(`${window.location.href.split('#')[0]}${hash}`, true);
              } else {
                nav.toExternal({ target: { shellHash: hash } });
              }
            });
            break;
          case 'LOCATION_RELOAD':
            if (isValidRedirectURL(args[1])) {
              window.location.href = args[1];
            } else {
              MessageBox.error('Invalid redirect URL. Only relative URLs to the same domain are allowed.');
            }
            break;
          case 'SYSTEM_LOGOUT': {
            const logoutUrl = args[1] || '/sap/public/bc/icf/logoff';
            const redirectToLogoff = () => {
              if (isValidRedirectURL(logoutUrl)) {
                window.location.href = logoutUrl;
              } else {
                MessageBox.error('Invalid logout URL. Only relative URLs to the same domain are allowed.');
              }
            };
            try {
              if (z2ui5.oLaunchpad?.Container?.logout) {
                z2ui5.oLaunchpad.Container.logout();
              } else {
                redirectToLogoff();
              }
            } catch (e) {
              _logError(`SYSTEM_LOGOUT: ushell logout failed`, e);
              redirectToLogoff();
            }
            break;
          }
          case 'OPEN_NEW_TAB':
            if (isValidRedirectURL(args[1])) {
              // noopener,noreferrer prevents the new tab from accessing window.opener and from
              // sending a Referer header (modern best practice; supersedes manual `opener = null`)
              window.open(args[1], '_blank', 'noopener,noreferrer');
            } else {
              MessageBox.error('Invalid URL. Only relative URLs to the same domain are allowed.');
            }
            break;
          case 'POPUP_CLOSE':
            this.PopupDestroy();
            break;
          case 'POPOVER_CLOSE':
            this.PopoverDestroy();
            break;
          case 'URLHELPER': {
            try {
              _URL_HELPER_ACTIONS[args[1]]?.(args[2]);
            } catch (e) {
              _logError(`URLHELPER: '${args[1]}' failed`, e);
            }
            break;
          }
          case 'IMAGE_EDITOR_POPUP_CLOSE': {
            let image;
            try {
              image = Fragment.byId('popupId', 'imageEditor')?.getImagePngDataURL();
            } catch (e) {
              _logError(`IMAGE_EDITOR_POPUP_CLOSE: getImagePngDataURL failed`, e);
            }
            this.PopupDestroy();
            // Skip the SAVE roundtrip if we couldn't extract the image — sending undefined
            // would silently overwrite the backend image with null
            if (image !== undefined) this.eB(['SAVE'], image);
            break;
          }
          case 'Z2UI5':
            try {
              const fnName = args[1];
              // Restrict to own callable properties to block prototype-pollution paths like
              // '__proto__', 'constructor', 'hasOwnProperty', etc.
              if (typeof fnName !== 'string' || !Object.hasOwn(z2ui5, fnName) || typeof z2ui5[fnName] !== 'function') {
                _logError(`Z2UI5: '${fnName}' is not a callable own property of z2ui5`);
                break;
              }
              z2ui5[fnName](args.slice(2));
            } catch (e) {
              _logError(`Z2UI5: '${args[1]}' failed`, e);
            }
            break;
        }
      },
      eB(...args) {
        if (!navigator.onLine) {
          MessageBox.alert('No internet connection! Please reconnect to the server and try again.');
          return;
        }
        // args[0] is the event-name array — args[0][2] is the "force during busy" flag,
        // args[0][3] forces the main controller path
        if (z2ui5.isBusy && !args[0]?.[2]) {
          const oBusyDialog = new mBusyDialog();
          oBusyDialog.open();
          queueMicrotask(() => oBusyDialog.close());
          return;
        }
        z2ui5.isBusy = true;
        BusyIndicator.show();
        z2ui5.oBody = { VIEWNAME: 'MAIN' };
        let oModel = null;
        if (args[0]?.[3] || z2ui5.oController === this) {
          oModel = z2ui5.oResponse?.PARAMS?.S_VIEW?.SWITCH_DEFAULT_MODEL_PATH
            ? z2ui5.oView?.getModel('http')
            : z2ui5.oView?.getModel();
        } else if (z2ui5.oControllerPopup === this) {
          oModel = z2ui5.oViewPopup?.getModel();
        } else if (z2ui5.oControllerPopover === this) {
          oModel = z2ui5.oViewPopover?.getModel();
        } else if (z2ui5.oControllerNest === this) {
          oModel = z2ui5.oViewNest?.getModel();
          z2ui5.oBody.VIEWNAME = 'NEST';
        } else if (z2ui5.oControllerNest2 === this) {
          oModel = z2ui5.oViewNest2?.getModel();
          z2ui5.oBody.VIEWNAME = 'NEST2';
        }
        runCallbacks(z2ui5.onBeforeRoundtrip);
        if (oModel && z2ui5.xxChangedPaths?.size > 0) {
          const xx = oModel.getData()?.XX;
          if (xx) z2ui5.oBody.XX = this._buildDeltaFromPaths(z2ui5.xxChangedPaths, xx);
        }
        z2ui5.oBody.ID = z2ui5.oResponse?.ID;
        // Index 0 is the event-name array; later indices are user-supplied payloads.
        // Stringify objects/arrays to keep JSON sane; preserve null and primitives untouched.
        z2ui5.oBody.ARGUMENTS = args.map((item, i) => {
          if (i === 0 || item === null || typeof item !== 'object') return item;
          try {
            return JSON.stringify(item);
          } catch (e) {
            _logError(`eB: failed to stringify argument ${i}`, e);
            return null;
          }
        });
        z2ui5.oResponseOld = z2ui5.oResponse;
        Server.Roundtrip();
        runCallbacks(z2ui5.onAfterRoundtrip);
      },

      updateModelIfRequired(paramKey, oView) {
        if (!z2ui5.oResponse?.PARAMS?.[paramKey]?.CHECK_UPDATE_MODEL) return;
        const oModel = this._createViewModel();
        applyStoredSizeLimit(paramToViewKey[paramKey], oModel);
        if (oView) {
          oView.setModel(oModel);
        } else {
          // No target view to bind to — release the model instead of leaking it
          oModel.destroy?.();
        }
      },
      async checkSDKcompatibility(err) {
        let gav;
        try {
          ({ gav } = (await VersionInfo.load()) ?? {});
        } catch (e) {
          _logError('checkSDKcompatibility: VersionInfo.load failed', e);
          return;
        }
        // gav can be missing for some openui5 builds — fall back to a plain message
        if (typeof gav === 'string' && !gav.includes('com.sap.ui5')) {
          MessageBox.error(`openui5 SDK is loaded, module: ${err?._modules} is not available in openui5`);
          return;
        }
        MessageBox.error(err?.message ?? String(err));
      },
      showMessage(msgType, params) {
        if (!params) return;
        const msg = params[msgType];
        // Skip when the backend sends no usable text (undefined or null)
        if (msg?.TEXT == null) return;
        if (msgType === 'S_MSG_TOAST') {
          MessageToast.show(msg.TEXT, {
            duration: parseMs(msg.DURATION, _TOAST_DEFAULT_DURATION_MS),
            width: msg.WIDTH || _TOAST_DEFAULT_WIDTH,
            onClose: msg.ONCLOSE ? () => this.eB([msg.ONCLOSE]) : null,
            autoClose: !!msg.AUTOCLOSE,
            animationTimingFunction: msg.ANIMATIONTIMINGFUNCTION || 'ease',
            animationDuration: parseMs(msg.ANIMATIONDURATION, _TOAST_DEFAULT_ANIM_MS),
            closeonBrowserNavigation: !!msg.CLOSEONBROWSERNAVIGATION,
          });
          if (typeof msg.CLASS === 'string' && msg.CLASS) {
            // Pick the most recently appended toast — querySelectorAll returns them in DOM order.
            // classList.add throws on invalid token names; protect the rest of the flow.
            try {
              const toasts = document.querySelectorAll('.sapMMessageToast');
              const toast = toasts[toasts.length - 1];
              toast?.classList.add(...msg.CLASS.trim().split(/\s+/).filter(Boolean));
            } catch (e) {
              _logError(`showMessage: invalid toast CLASS '${msg.CLASS}'`, e);
            }
          }
        } else if (msgType === 'S_MSG_BOX') {
          const oParams = {
            styleClass: msg.STYLECLASS || '',
            title: msg.TITLE || '',
            onClose: msg.ONCLOSE ? (sAction) => this.eB([msg.ONCLOSE, sAction]) : null,
            actions: msg.ACTIONS || 'OK',
            emphasizedAction: msg.EMPHASIZEDACTION || 'OK',
            initialFocus: msg.INITIALFOCUS || null,
            textDirection: msg.TEXTDIRECTION || 'Inherit',
            details: msg.DETAILS ? sanitizeMessageDetails(msg.DETAILS) : '',
            closeOnNavigation: !!msg.CLOSEONNAVIGATION,
            ...(msg.ICON && msg.ICON !== 'NONE' && { icon: msg.ICON }),
          };
          // Whitelist guard: prevents prototype-pollution dispatch (e.g. msg.TYPE === '__proto__')
          if (typeof msg.TYPE === 'string' && _MSG_BOX_TYPES.has(msg.TYPE) && typeof MessageBox[msg.TYPE] === 'function') {
            MessageBox[msg.TYPE](msg.TEXT, oParams);
          } else {
            _logError(`showMessage: unsupported MessageBox type '${msg.TYPE}'`);
          }
        }
      },
      async displayView(xml, viewModel) {
        const oViewModel = this._trackChanges(new JSONModel(viewModel));
        const sView = z2ui5.oResponse?.PARAMS?.S_VIEW;
        const switchPath = sView?.SWITCH_DEFAULT_MODEL_PATH;
        const oModel = switchPath
          ? new ODataModel({
              serviceUrl: switchPath,
              annotationURI: sView.SWITCHDEFAULTMODELANNOURI ?? '',
            })
          : oViewModel;
        applyStoredSizeLimit('MAIN', oModel);
        let oView;
        try {
          oView = await XMLView.create({
            definition: xml,
            models: oModel,
            controller: z2ui5.oController,
            id: 'mainView',
            preprocessors: { xml: { models: { template: oViewModel } } },
          });
        } catch (e) {
          // If XMLView.create rejects, both models leak — destroy them explicitly
          if (switchPath) {
            oModel.destroy?.();
            oViewModel.destroy?.();
          } else {
            oViewModel.destroy?.();
          }
          throw e;
        }
        if (!z2ui5.oApp || z2ui5.oApp.isDestroyed()) {
          oView.destroy();
          if (switchPath) {
            oModel.destroy?.();
            oViewModel.destroy?.();
          }
          z2ui5.oView = null;
          return;
        }
        z2ui5.oView = oView;
        oView.setModel(z2ui5.oDeviceModel, 'device');
        if (switchPath) oView.setModel(oViewModel, 'http');
        z2ui5.oApp.removeAllPages();
        z2ui5.oApp.insertPage(oView);
      },
    });
  },
);
