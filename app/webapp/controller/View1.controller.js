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
      for (const fn of arr ?? []) {
        try {
          fn?.(...args);
        } catch (e) {
          _logError(`runCallbacks: callback failed`, e);
        }
      }
    };

    const _msgParser = new DOMParser();
    const _sanitizeEl = document.createElement('div');
    const parseMs = (val, def) => (val ? +val : def);

    const _SAFE_PROTOCOLS = new Set(['http:', 'https:']);
    const _logError = (msg, err) =>
      (z2ui5.errors ??= []).push({
        message: msg,
        ...(err !== undefined && { error: err }),
        ts: new Date().toISOString(),
      });

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

    const copyToClipboard = (textToCopy) => {
      if (!navigator.clipboard?.writeText) {
        _logError(`Clipboard: writeText API not available`);
        return;
      }
      navigator.clipboard.writeText(textToCopy).catch((err) => _logError(`Clipboard: writeText failed`, err));
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

    const navContainerLookups = {
      NAV_CONTAINER_TO: (id) => z2ui5.oView?.byId(id),
      NEST_NAV_CONTAINER_TO: (id) => z2ui5.oViewNest?.byId(id),
      NEST2_NAV_CONTAINER_TO: (id) => z2ui5.oViewNest2?.byId(id),
      POPUP_NAV_CONTAINER_TO: (id) => Fragment.byId('popupId', id),
      POPOVER_NAV_CONTAINER_TO: (id) => Fragment.byId('popoverId', id),
    };

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
          if (S_POPUP?.CHECK_DESTROY) this.PopupDestroy();
          if (S_POPOVER?.CHECK_DESTROY) this.PopoverDestroy();
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
            ? { view: oView.mProperties.viewContent, model: oView.getModel()?.getData(), response: z2ui5.oResponse }
            : {};
          try {
            if (SET_PUSH_STATE) {
              const hash = _hashChanger.getHash() || '#';
              history.pushState(
                oState,
                '',
                `${window.location.pathname}${window.location.search}${hash}${SET_PUSH_STATE}`,
              );
            } else {
              history.replaceState(oState, '', window.location.href);
            }
            _hashChanger.replaceHash(SET_APP_STATE_ACTIVE ? `z2ui5-xapp-state=${ID ?? ''}` : '');
          } catch (e) {
            _logError(`_processAfterRendering: history update failed`, e);
          }
          if (SET_NAV_BACK) history.back();

          runCallbacks(z2ui5.onAfterRendering);
        } catch (e) {
          _logError(`_processAfterRendering: unexpected error`, e);
          MessageBox.error(e.toLocaleString(), {
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
          const [attr, rowIdx, field] = path.slice(4).split('/');
          if (field !== undefined && rowIdx !== '' && !isNaN(rowIdx)) {
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
      _createViewModel() {
        return this._trackChanges(new JSONModel(z2ui5.oResponse?.OVIEWMODEL));
      },
      async displayFragment(xml, viewProp) {
        const oModel = this._createViewModel();
        applyStoredSizeLimit('POPUP', oModel);
        const oFragment = await Fragment.load({
          definition: xml,
          controller: z2ui5.oControllerPopup,
          id: 'popupId',
        });
        if (!z2ui5.oApp || z2ui5.oApp.isDestroyed()) {
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
          applyStoredSizeLimit('POPOVER', oModel);
          const oFragment = await Fragment.load({
            definition: xml,
            controller: z2ui5.oControllerPopover,
            id: 'popoverId',
          });
          if (!z2ui5.oApp || z2ui5.oApp.isDestroyed()) {
            oFragment.destroy();
            return;
          }
          oFragment.setModel(oModel);
          oFragment.Fragment = Fragment;
          z2ui5[viewProp] = oFragment;
          const oControl =
            z2ui5.oView?.byId(openById) ||
            z2ui5.oViewPopup?.Fragment.byId('popupId', openById) ||
            z2ui5.oViewNest?.byId(openById) ||
            z2ui5.oViewNest2?.byId(openById) ||
            (Element.getElementById?.(openById) ?? sap.ui.getCore?.()?.byId?.(openById));
          if (!oControl) {
            _logError(`displayPopover: openBy control '${openById}' not found`);
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
        const oView = await XMLView.create({
          definition: xml,
          controller,
          preprocessors: { xml: { models: { template: oModel } } },
        });
        if (!z2ui5.oApp || z2ui5.oApp.isDestroyed()) {
          oView.destroy();
          return;
        }
        oView.setModel(oModel);
        const nestParams = z2ui5.oResponse?.PARAMS?.[viewNestId];
        if (!nestParams) {
          _logError(`displayNestedView: missing PARAMS.${viewNestId}`);
          oView.destroy();
          return;
        }
        const { ID, METHOD_DESTROY, METHOD_INSERT } = nestParams;
        const oParent = z2ui5.oView?.byId(ID);
        if (!oParent) {
          _logError(`displayNestedView: parent control '${ID}' not found, nested view discarded`);
          oView.destroy();
          return;
        }
        try {
          oParent[METHOD_DESTROY]();
        } catch (e) {
          _logError(`displayNestedView: parent destroy method failed`, e);
        }
        try {
          oParent[METHOD_INSERT](oView);
        } catch (e) {
          _logError(`displayNestedView: parent insert method failed`, e);
          oView.destroy();
          return;
        }
        z2ui5[viewProp] = oView;
      },
      _destroyView(prop, tryClose) {
        const view = z2ui5[prop];
        if (!view) return;
        if (tryClose) {
          try {
            view.close?.();
          } catch (e) {
            _logError(`_destroyView: view.close() failed for ${prop}`, e);
          }
        }
        try {
          view.destroy();
        } catch (e) {
          _logError(`_destroyView: view.destroy() failed for ${prop}`, e);
        }
        z2ui5[prop] = null;
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

        const navLookup = navContainerLookups[args[0]];
        if (navLookup) {
          navigateContainer(navLookup, args);
          return;
        }

        switch (args[0]) {
          case 'SET_SIZE_LIMIT': {
            const hasLimit = args[2] !== undefined && args[2] !== '';
            const viewKey = hasLimit ? args[2] : args[1];
            const limit = hasLimit ? Number(args[1]) : NaN;
            const model = viewLookups[viewKey]?.()?.getModel();
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
            history.back();
            break;
          case 'CLIPBOARD_COPY':
            copyToClipboard(args[1]);
            break;
          case 'CLIPBOARD_APP_STATE':
            copyToClipboard(`${window.location.href}#/z2ui5-xapp-state=${z2ui5.oResponse?.ID}`);
            break;
          case 'SET_ODATA_MODEL': {
            try {
              const oModel = new ODataModel({ serviceUrl: args[1], annotationURI: args[3] ?? '' });
              z2ui5.oView?.setModel(oModel, args[2] || undefined);
            } catch (e) {
              _logError(`SET_ODATA_MODEL: failed for '${args[1]}'`, e);
            }
            break;
          }
          case 'STORE_DATA': {
            const { TYPE, PREFIX, VALUE, KEY } = args[1];
            try {
              const oStorage = new Storage(Storage.Type[TYPE] ?? Storage.Type.session, PREFIX);
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
          case 'DOWNLOAD_B64_FILE':
            Object.assign(document.createElement('a'), { href: args[1], download: args[2] }).click();
            break;
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
              const newWindow = window.open(args[1], '_blank');
              if (newWindow) newWindow.opener = null;
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
              actions[args[1]]?.();
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
            this.eB(['SAVE'], image);
            break;
          }
          case 'Z2UI5':
            try {
              z2ui5[args[1]]?.(args.slice(2));
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
        if (z2ui5.isBusy && !args[0][2]) {
          const oBusyDialog = new mBusyDialog();
          oBusyDialog.open();
          queueMicrotask(() => oBusyDialog.close());
          return;
        }
        z2ui5.isBusy = true;
        BusyIndicator.show();
        z2ui5.oBody = { VIEWNAME: 'MAIN' };
        let oModel;
        if (args[0][3] || z2ui5.oController === this) {
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
        z2ui5.oBody.ARGUMENTS = args.map((item, i) =>
          i > 0 && typeof item === 'object' ? JSON.stringify(item) : item,
        );
        z2ui5.oResponseOld = z2ui5.oResponse;
        Server.Roundtrip();
        runCallbacks(z2ui5.onAfterRoundtrip);
      },

      updateModelIfRequired(paramKey, oView) {
        if (!z2ui5.oResponse?.PARAMS?.[paramKey]?.CHECK_UPDATE_MODEL) return;
        const oModel = this._createViewModel();
        applyStoredSizeLimit(paramToViewKey[paramKey], oModel);
        oView?.setModel(oModel);
      },
      async checkSDKcompatibility(err) {
        let gav;
        try {
          ({ gav } = await VersionInfo.load());
        } catch (e) {
          _logError('checkSDKcompatibility: VersionInfo.load failed', e);
          return;
        }
        if (!gav.includes('com.sap.ui5')) {
          MessageBox.error(`openui5 SDK is loaded, module: ${err?._modules} is not available in openui5`);
          return;
        }
        MessageBox.error(err.toLocaleString());
      },
      showMessage(msgType, params) {
        if (!params) return;
        const msg = params[msgType];
        if (msg?.TEXT === undefined) return;
        if (msgType === 'S_MSG_TOAST') {
          MessageToast.show(msg.TEXT, {
            duration: parseMs(msg.DURATION, 3000),
            width: msg.WIDTH || '15em',
            onClose: msg.ONCLOSE ? () => this.eB([msg.ONCLOSE]) : null,
            autoClose: !!msg.AUTOCLOSE,
            animationTimingFunction: msg.ANIMATIONTIMINGFUNCTION || 'ease',
            animationDuration: parseMs(msg.ANIMATIONDURATION, 1000),
            closeonBrowserNavigation: !!msg.CLOSEONBROWSERNAVIGATION,
          });
          if (msg.CLASS)
            document
              .querySelector('.sapMMessageToast')
              ?.classList.add(...msg.CLASS.trim().split(/\s+/).filter(Boolean));
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
          MessageBox[msg.TYPE]?.(msg.TEXT, oParams);
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
        z2ui5.oView = await XMLView.create({
          definition: xml,
          models: oModel,
          controller: z2ui5.oController,
          id: 'mainView',
          preprocessors: { xml: { models: { template: oViewModel } } },
        });
        if (!z2ui5.oApp || z2ui5.oApp.isDestroyed()) {
          z2ui5.oView.destroy();
          if (switchPath) oModel.destroy();
          z2ui5.oView = null;
          return;
        }
        z2ui5.oView.setModel(z2ui5.oDeviceModel, 'device');
        if (switchPath) z2ui5.oView.setModel(oViewModel, 'http');
        z2ui5.oApp.removeAllPages();
        z2ui5.oApp.insertPage(z2ui5.oView);
      },
    });
  },
);
