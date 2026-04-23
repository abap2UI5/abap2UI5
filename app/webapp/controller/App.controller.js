const _logError = (msg, err) => {
  (z2ui5.errors ??= []).push({ message: msg, ...(err !== undefined && { error: err }), ts: new Date().toISOString() });
};

sap.ui.define(
  [
    'sap/ui/core/mvc/Controller',
    'z2ui5/controller/View1.controller',
    'z2ui5/cc/Server',
    'sap/ui/core/routing/HashChanger',
  ],
  (BaseController, Controller, Server, HashChanger) => {
    'use strict';
    return BaseController.extend('z2ui5.controller.App', {
      onInit() {
        const oOwnerComponent = this.getOwnerComponent();
        z2ui5.oOwnerComponent = oOwnerComponent;
        const uri = oOwnerComponent.getManifest()?.['sap.app']?.dataSources?.http?.uri;
        z2ui5.oConfig.pathname = z2ui5.checkLocal ? window.location.href : uri;

        Object.assign(z2ui5, {
          oController: new Controller(),
          oApp: this.getView().byId('app'),
          oControllerNest: new Controller(),
          oControllerNest2: new Controller(),
          oControllerPopup: new Controller(),
          oControllerPopover: new Controller(),
          onBeforeRoundtrip: [],
          onAfterRendering: [],
          onBeforeEventFrontend: [],
          onAfterRoundtrip: [],
          errors: [],
          checkNestAfter: false,
          checkNestAfter2: false,
        });

        if (HashChanger.getInstance().getHash()) {
          z2ui5.checkInit = true;
          Server.Roundtrip();
        }
      },
    });
  },
);

sap.ui.define('z2ui5/Timer', ['sap/ui/core/Control'], (Control) => {
  'use strict';

  return Control.extend('z2ui5.Timer', {
    metadata: {
      properties: {
        delayMS: {
          type: 'int',
          defaultValue: 0,
        },
        checkActive: {
          type: 'boolean',
          defaultValue: true,
        },
        checkRepeat: {
          type: 'boolean',
          defaultValue: false,
        },
      },
      events: {
        finished: {
          allowPreventDefault: true,
          parameters: {},
        },
      },
    },
    onAfterRendering() {
      if (!this._pendingTimer) return;
      this._pendingTimer = false;
      this.delayedCall();
    },
    exit() {
      clearTimeout(this._timerId);
    },
    delayedCall() {
      if (!this.getProperty('checkActive')) return;
      clearTimeout(this._timerId);
      this._timerId = setTimeout(() => {
        if (this.isDestroyed()) return;
        if (!this.getProperty('checkRepeat')) this.setProperty('checkActive', false, true);
        this.fireFinished();
        if (this.getProperty('checkRepeat') && !this.isDestroyed()) this.delayedCall();
      }, this.getProperty('delayMS'));
    },
    renderer(oRm, oControl) {
      oRm.openStart('span', oControl);
      oRm.addStyle('display', 'none');
      oRm.openEnd();
      oRm.close('span');
      oControl._pendingTimer = oControl.getProperty('checkActive');
    },
  });
});

sap.ui.define('z2ui5/Focus', ['sap/ui/core/Control'], (Control) => {
  'use strict';
  return Control.extend('z2ui5.Focus', {
    metadata: {
      properties: {
        setUpdate: {
          type: 'boolean',
          defaultValue: true,
        },
        focusId: {
          type: 'string',
        },
        selectionStart: {
          type: 'string',
          defaultValue: '0',
        },
        selectionEnd: {
          type: 'string',
          defaultValue: '0',
        },
      },
    },
    setFocusId(val) {
      try {
        this.setProperty('focusId', val);
        const oElement = z2ui5.oView?.byId(val);
        if (oElement) oElement.applyFocusInfo(oElement.getFocusInfo());
      } catch (e) {
        _logError(`Focus.setFocusId failed`, e);
      }
    },
    onAfterRendering() {
      if (!this._pendingFocus) return;
      this._pendingFocus = false;
      const oElement = z2ui5.oView?.byId(this.getProperty('focusId'));
      if (!oElement) return;
      try {
        oElement.applyFocusInfo(
          Object.assign(oElement.getFocusInfo(), {
            selectionStart: +this.getProperty('selectionStart'),
            selectionEnd: +this.getProperty('selectionEnd'),
          }),
        );
      } catch (e) {
        _logError(`Focus.onAfterRendering: applyFocusInfo failed`, e);
      }
    },
    renderer(oRm, oControl) {
      oRm.openStart('span', oControl);
      oRm.addStyle('display', 'none');
      oRm.openEnd();
      oRm.close('span');
      if (!oControl.getProperty('setUpdate')) return;
      oControl.setProperty('setUpdate', false, true);
      oControl._pendingFocus = true;
    },
  });
});

sap.ui.define('z2ui5/Title', ['sap/ui/core/Control'], (Control) => {
  'use strict';
  return Control.extend('z2ui5.Title', {
    metadata: {
      properties: {
        title: {
          type: 'string',
        },
      },
    },
    setTitle(val) {
      this.setProperty('title', val);
      document.title = String(val ?? '');
    },
    renderer() {},
  });
});

sap.ui.define('z2ui5/LPTitle', ['sap/ui/core/Control'], (Control) => {
  'use strict';
  return Control.extend('z2ui5.LPTitle', {
    metadata: {
      properties: {
        title: {
          type: 'string',
        },
        ApplicationFullWidth: {
          type: 'boolean',
        },
      },
    },
    setTitle(val) {
      this.setProperty('title', val);
      try {
        z2ui5.oLaunchpad?.ShellUIService?.setTitle(val)?.catch((e) =>
          _logError(`LPTitle: Launchpad Service setTitle failed`, e),
        );
      } catch (e) {
        _logError(`LPTitle: Launchpad Service setTitle failed`, e);
      }
    },

    setApplicationFullWidth(val) {
      this.setProperty('ApplicationFullWidth', val);
      try {
        z2ui5.oLaunchpad?.AppConfiguration?.setApplicationFullWidth(val);
      } catch (e) {
        _logError(`LPTitle: setApplicationFullWidth failed`, e);
      }
    },

    renderer() {},
  });
});

sap.ui.define('z2ui5/History', ['sap/ui/core/Control'], (Control) => {
  'use strict';
  return Control.extend('z2ui5.History', {
    metadata: {
      properties: {
        search: {
          type: 'string',
        },
      },
    },
    setSearch(val) {
      this.setProperty('search', val);
      try {
        history.replaceState(null, '', `${window.location.pathname}${val ?? ''}`);
      } catch (e) {
        _logError(`History.setSearch: replaceState failed`, e);
      }
    },
    renderer() {},
  });
});

sap.ui.define('z2ui5/Tree', ['sap/ui/core/Control'], (Control) => {
  'use strict';

  return Control.extend('z2ui5.Tree', {
    metadata: {
      properties: {
        tree_id: {
          type: 'string',
        },
      },
    },

    _getTreeBinding() {
      return z2ui5.oView?.byId(this.getProperty('tree_id'))?.getBinding('items');
    },

    setBackend() {
      try {
        z2ui5.treeState = this._getTreeBinding()?.getCurrentTreeState();
      } catch (e) {
        _logError(`Tree.setBackend: failed`, e);
      }
    },

    init() {
      this._setBackendBound = this.setBackend.bind(this);
      (z2ui5.onBeforeRoundtrip ??= []).push(this._setBackendBound);
    },

    exit() {
      z2ui5.onBeforeRoundtrip = (z2ui5.onBeforeRoundtrip ?? []).filter((fn) => fn !== this._setBackendBound);
    },

    onAfterRendering() {
      if (!this._pendingTreeState) return;
      this._pendingTreeState = false;
      try {
        this._getTreeBinding()?.setTreeState(z2ui5.treeState);
      } catch (e) {
        _logError(`Tree.onAfterRendering: setTreeState failed`, e);
      }
    },

    renderer(oRm, oControl) {
      oRm.openStart('span', oControl);
      oRm.addStyle('display', 'none');
      oRm.openEnd();
      oRm.close('span');
      if (!z2ui5.treeState) return;
      oControl._pendingTreeState = true;
    },
  });
});

sap.ui.define('z2ui5/Scrolling', ['sap/ui/core/Control'], (Control) => {
  'use strict';

  return Control.extend('z2ui5.Scrolling', {
    metadata: {
      properties: {
        setUpdate: {
          type: 'boolean',
          defaultValue: true,
        },
        items: {
          type: 'object',
        },
      },
    },

    _getDomInnerElement(id) {
      const control = z2ui5.oView?.byId(id);
      return control && document.getElementById(`${control.getId()}-inner`);
    },

    _getScrollTop(item) {
      try {
        const control = z2ui5.oView?.byId(item.N);
        const scrollDelegate = control?.getScrollDelegate?.();
        if (scrollDelegate) return scrollDelegate.getScrollTop();
        const element = this._getDomInnerElement(item.ID);
        return element?.scrollTop ?? 0;
      } catch (e) {
        _logError(`Scrolling._getScrollTop: failed`, e);
        return 0;
      }
    },

    setBackend() {
      const items = this.getProperty('items');
      if (!items) return;
      try {
        const bindingInfo = this.getBindingInfo('items');
        const bindingPath = bindingInfo?.parts?.[0]?.path ?? bindingInfo?.path;
        for (const [index, item] of items.entries()) {
          const scrollTop = this._getScrollTop(item);
          if (item.V !== scrollTop) {
            item.V = scrollTop;
            if (bindingPath) z2ui5.xxChangedPaths?.add(`${bindingPath}/${index}/V`);
          }
        }
      } catch (e) {
        _logError(`Scrolling.setBackend: failed`, e);
      }
    },

    init() {
      this._setBackendBound = this.setBackend.bind(this);
      (z2ui5.onBeforeRoundtrip ??= []).push(this._setBackendBound);
    },

    exit() {
      z2ui5.onBeforeRoundtrip = (z2ui5.onBeforeRoundtrip ?? []).filter((fn) => fn !== this._setBackendBound);
    },

    _restoreScrollPosition(item) {
      try {
        const control = z2ui5.oView?.byId(item.N);
        if (control?.scrollTo) {
          control.scrollTo(item.V);
          return;
        }
        const element = this._getDomInnerElement(item.ID);
        if (element) element.scrollTop = item.V;
      } catch (e) {
        _logError(`Scrolling._restoreScrollPosition: failed`, e);
      }
    },

    onAfterRendering() {
      if (!this._pendingScroll) return;
      this._pendingScroll = false;

      const items = this.getProperty('items');
      if (!items) return;

      try {
        for (const item of items) {
          const control = z2ui5.oView?.byId(item.N);
          if (control?.getDomRef()) {
            this._restoreScrollPosition(item);
          } else if (control) {
            const delegate = {
              onAfterRendering: () => {
                control.removeEventDelegate(delegate);
                if (!this.isDestroyed()) this._restoreScrollPosition(item);
              },
            };
            control.addEventDelegate(delegate);
          }
        }
      } catch (e) {
        _logError(`Scrolling.onAfterRendering: failed`, e);
      }
    },

    renderer(oRm, oControl) {
      oRm.openStart('span', oControl);
      oRm.addStyle('display', 'none');
      oRm.openEnd();
      oRm.close('span');

      if (!oControl.getProperty('setUpdate')) return;
      oControl.setProperty('setUpdate', false, true);
      oControl._pendingScroll = true;
    },
  });
});

sap.ui.define('z2ui5/Info', ['sap/ui/core/Control'], (Control) => {
  'use strict';

  return Control.extend('z2ui5.Info', {
    metadata: {
      properties: {
        ui5_version: {
          type: 'string',
        },
        device_phone: {
          type: 'string',
        },
        device_desktop: {
          type: 'string',
        },
        device_tablet: {
          type: 'string',
        },
        device_combi: {
          type: 'string',
        },
        device_height: {
          type: 'string',
        },
        device_width: {
          type: 'string',
        },
        ui5_theme: {
          type: 'string',
        },
        device_os: {
          type: 'string',
        },
        device_systemtype: {
          type: 'string',
        },
        device_browser: {
          type: 'string',
        },
      },
      events: {
        finished: {
          allowPreventDefault: true,
          parameters: {},
        },
      },
    },

    renderer(_, oControl) {
      try {
        const deviceData = z2ui5.oView?.getModel('device')?.getData();
        if (!deviceData) return;
        const { system, resize, os, browser } = deviceData;
        for (const [prop, val] of [
          ['ui5_version', z2ui5.oConfig?.UI5VersionInfo?.version],
          ['device_phone', system.phone],
          ['device_desktop', system.desktop],
          ['device_tablet', system.tablet],
          ['device_combi', system.combi],
          ['device_height', resize.height],
          ['device_width', resize.width],
          ['device_os', os.name],
          ['device_browser', browser.name],
        ])
          oControl.setProperty(prop, String(val ?? ''), true);
        oControl.fireFinished();
      } catch (e) {
        _logError(`Info.renderer: failed`, e);
      }
    },
  });
});

sap.ui.define('z2ui5/Geolocation', ['sap/ui/core/Control'], (Control) => {
  'use strict';

  const _GEO_PROPS = ['longitude', 'latitude', 'altitude', 'accuracy', 'altitudeAccuracy', 'speed', 'heading'];

  return Control.extend('z2ui5.Geolocation', {
    metadata: {
      properties: {
        longitude: {
          type: 'string',
          defaultValue: '',
        },
        latitude: {
          type: 'string',
          defaultValue: '',
        },
        altitude: {
          type: 'string',
          defaultValue: '',
        },
        accuracy: {
          type: 'string',
          defaultValue: '',
        },
        altitudeAccuracy: {
          type: 'string',
          defaultValue: '',
        },
        speed: {
          type: 'string',
          defaultValue: '',
        },
        heading: {
          type: 'string',
          defaultValue: '',
        },
        enableHighAccuracy: {
          type: 'boolean',
          defaultValue: false,
        },
        timeout: {
          type: 'string',
          defaultValue: '5000',
        },
      },
      events: {
        finished: {
          allowPreventDefault: true,
          parameters: {},
        },
      },
    },

    callbackPosition({ coords }) {
      if (this.isDestroyed()) return;
      for (const prop of _GEO_PROPS) this.setProperty(prop, coords[prop]?.toString() ?? '', true);
      this.fireFinished();
    },

    init() {
      this._pendingGeolocate = true;
    },

    exit() {
      this._pendingGeolocate = false;
    },

    onAfterRendering() {
      if (!this._pendingGeolocate) return;
      this._pendingGeolocate = false;
      try {
        navigator.geolocation?.getCurrentPosition(
          this.callbackPosition.bind(this),
          (error) => _logError(`Geolocation error (${error.code}): ${error.message}`),
          {
            enableHighAccuracy: this.getProperty('enableHighAccuracy'),
            timeout: +this.getProperty('timeout'),
          },
        );
      } catch (e) {
        _logError(`Geolocation.onAfterRendering: getCurrentPosition failed`, e);
      }
    },

    renderer(oRm, oControl) {
      oRm.openStart('span', oControl);
      oRm.addStyle('display', 'none');
      oRm.openEnd();
      oRm.close('span');
    },
  });
});

sap.ui.define('z2ui5/Storage', ['sap/ui/core/Control', 'sap/ui/util/Storage'], (Control, Storage) => {
  'use strict';

  return Control.extend('z2ui5.Storage', {
    metadata: {
      properties: {
        type: {
          type: 'string',
          defaultValue: 'session',
        },
        prefix: {
          type: 'string',
          defaultValue: '',
        },
        key: {
          type: 'string',
          defaultValue: '',
        },
        value: {
          type: 'any',
          defaultValue: '',
        },
      },
      events: {
        finished: {
          parameters: {
            type: {
              type: 'string',
            },
            prefix: {
              type: 'string',
            },
            key: {
              type: 'string',
            },
            value: {
              type: 'any',
            },
          },
        },
      },
    },

    renderer(_, oControl) {
      const type = oControl.getProperty('type');
      const prefix = oControl.getProperty('prefix');
      const key = oControl.getProperty('key');
      const value = oControl.getProperty('value');
      let stored;
      try {
        stored = new Storage(Storage.Type[type] ?? Storage.Type.session, prefix).get(key) ?? '';
      } catch (e) {
        _logError(`Storage: read failed for key '${key}'`, e);
        return;
      }
      if (stored !== value) {
        oControl.setProperty('value', stored, true);
        oControl.fireFinished({ type, prefix, key, value: stored });
      }
    },
  });
});

sap.ui.define(
  'z2ui5/FileUploader',
  ['sap/ui/core/Control', 'sap/m/Button', 'sap/ui/unified/FileUploader', 'sap/m/HBox'],
  (Control, Button, FileUploader, HBox) => {
    'use strict';

    return Control.extend('z2ui5.FileUploader', {
      metadata: {
        properties: {
          value: {
            type: 'string',
            defaultValue: '',
          },
          path: {
            type: 'string',
            defaultValue: '',
          },
          tooltip: {
            type: 'string',
            defaultValue: '',
          },
          fileType: {
            type: 'string',
            defaultValue: '',
          },
          placeholder: {
            type: 'string',
            defaultValue: '',
          },
          buttonText: {
            type: 'string',
            defaultValue: '',
          },
          style: {
            type: 'string',
            defaultValue: '',
          },
          uploadButtonText: {
            type: 'string',
            defaultValue: 'Upload',
          },
          enabled: {
            type: 'boolean',
            defaultValue: true,
          },
          icon: {
            type: 'string',
            defaultValue: 'sap-icon://browse-folder',
          },
          iconOnly: {
            type: 'boolean',
            defaultValue: false,
          },
          buttonOnly: {
            type: 'boolean',
            defaultValue: false,
          },
          multiple: {
            type: 'boolean',
            defaultValue: false,
          },
          visible: {
            type: 'boolean',
            defaultValue: true,
          },
          checkDirectUpload: {
            type: 'boolean',
            defaultValue: false,
          },
        },

        events: {
          upload: {
            allowPreventDefault: true,
            parameters: {},
          },
        },
      },

      _readFile(file) {
        const reader = new FileReader();
        reader.onload = () => {
          if (this.isDestroyed()) return;
          this.setProperty('value', reader.result);
          this.fireUpload();
        };
        reader.onerror = () => _logError(`FileUploader: FileReader failed`, reader.error);
        reader.readAsDataURL(file);
      },

      exit() {
        this._oHBox?.destroy();
      },

      renderer(oRm, oControl) {
        const directUpload = oControl.getProperty('checkDirectUpload');
        const path = oControl.getProperty('path');
        oControl._oHBox?.destroy();
        oControl._oHBox = null;
        oControl.oUploadButton = null;
        oControl.oFileUploader = null;
        if (!directUpload) {
          oControl.oUploadButton = new Button({
            text: oControl.getProperty('uploadButtonText'),
            enabled: path !== '',
            press: () => {
              oControl.setProperty('path', oControl.oFileUploader.getProperty('value'));
              const file = oControl.oFileUploader?.oFileUpload?.files?.[0];
              if (file) oControl._readFile(file);
            },
          });
        }

        oControl.oFileUploader = new FileUploader({
          icon: oControl.getProperty('icon'),
          iconOnly: oControl.getProperty('iconOnly'),
          buttonOnly: oControl.getProperty('buttonOnly'),
          buttonText: oControl.getProperty('buttonText'),
          style: oControl.getProperty('style'),
          fileType: oControl.getProperty('fileType'),
          visible: oControl.getProperty('visible'),
          uploadOnChange: directUpload,
          multiple: oControl.getProperty('multiple'),
          enabled: oControl.getProperty('enabled'),
          value: path,
          placeholder: oControl.getProperty('placeholder'),
          change: (oEvent) => {
            if (directUpload) return;
            const value = oEvent.getSource().getProperty('value');
            oControl.setProperty('path', value);
            oControl.oUploadButton?.setEnabled(!!value);
            oControl.oUploadButton?.rerender();
          },
          uploadComplete: (oEvent) => {
            if (!directUpload) return;
            const value = oEvent.getSource().getProperty('value');
            oControl.setProperty('path', value);
            const file = oEvent.getSource().oFileUpload?.files?.[0];
            if (file) oControl._readFile(file);
          },
        });

        oControl._oHBox = new HBox().addItem(oControl.oFileUploader);
        if (oControl.oUploadButton) oControl._oHBox.addItem(oControl.oUploadButton);
        oRm.renderControl(oControl._oHBox);
      },
    });
  },
);

sap.ui.define('z2ui5/MultiInputExt', ['sap/ui/core/Control', 'sap/m/Token'], (Control, Token) => {
  'use strict';

  return Control.extend('z2ui5.MultiInputExt', {
    metadata: {
      properties: {
        MultiInputId: {
          type: 'string',
        },
        MultiInputName: {
          type: 'string',
        },
        addedTokens: {
          type: 'object',
        },
        checkInit: {
          type: 'boolean',
          defaultValue: false,
        },
        removedTokens: {
          type: 'object',
        },
      },
      events: {
        change: {
          allowPreventDefault: true,
          parameters: {},
        },
      },
    },

    init() {
      this._setControlBound = this.setControl.bind(this);
      (z2ui5.onAfterRendering ??= []).push(this._setControlBound);
    },
    exit() {
      z2ui5.onAfterRendering = (z2ui5.onAfterRendering ?? []).filter((fn) => fn !== this._setControlBound);
    },

    onTokenUpdate(oEvent) {
      const { mParameters } = oEvent;
      const isRemoved = mParameters.type === 'removed';
      const tokens = (mParameters[isRemoved ? 'removedTokens' : 'addedTokens'] ?? []).map((item) => ({
        KEY: item.getKey(),
        TEXT: item.getText(),
      }));
      this.setProperty('addedTokens', isRemoved ? [] : tokens);
      this.setProperty('removedTokens', isRemoved ? tokens : []);
      this.fireChange();
    },
    renderer() {},
    setControl() {
      const table = z2ui5.oView?.byId(this.getProperty('MultiInputId'));
      if (!table || this.getProperty('checkInit')) return;
      this.setProperty('checkInit', true);
      try {
        table.attachTokenUpdate(this.onTokenUpdate.bind(this));
        table.addValidator(({ text }) => new Token({ key: text, text }));
      } catch (e) {
        _logError(`MultiInputExt.setControl: setup failed`, e);
      }
    },
  });
});

sap.ui.define('z2ui5/SmartMultiInputExt', ['sap/ui/core/Control'], (Control) => {
  'use strict';

  return Control.extend('z2ui5.SmartMultiInputExt', {
    metadata: {
      properties: {
        multiInputId: {
          type: 'string',
        },
        addedTokens: {
          type: 'object',
        },
        removedTokens: {
          type: 'object',
        },
        rangeData: {
          type: 'object',
          defaultValue: [],
        },
        checkInit: {
          type: 'boolean',
          defaultValue: false,
        },
      },
      events: {
        change: {
          allowPreventDefault: true,
          parameters: {},
        },
      },
    },

    init() {
      this._setControlBound = this.setControl.bind(this);
      this._oInput = null;
      this._oPendingInnerControlsCreated = null;
      this._bInnerControlsCreated = false;
      (z2ui5.onAfterRendering ??= []).push(this._setControlBound);
    },
    exit() {
      z2ui5.onAfterRendering = (z2ui5.onAfterRendering ?? []).filter((fn) => fn !== this._setControlBound);
      this._oPendingInnerControlsCreated?.(null);
      this._oPendingInnerControlsCreated = null;
    },

    onTokenUpdate(oEvent) {
      const { mParameters } = oEvent;
      const isRemoved = mParameters.type === 'removed';
      const mappedTokens = (mParameters[isRemoved ? 'removedTokens' : 'addedTokens'] ?? []).map((item) => ({
        KEY: item.getKey(),
        TEXT: item.getText(),
      }));
      this.setProperty('addedTokens', isRemoved ? [] : mappedTokens);
      this.setProperty('removedTokens', isRemoved ? mappedTokens : []);
      const source = oEvent.getSource();
      const tokens = source.getTokens();
      this.setProperty(
        'rangeData',
        (source.getRangeData() ?? []).map((oRangeData, index) => {
          const token = tokens[index];
          return Object.assign(oRangeData, { tokenText: token?.getText() ?? '', tokenLongKey: token?.data('longKey') });
        }),
      );
      this.fireChange();
    },
    async setRangeData(aRangeData) {
      this.setProperty('rangeData', aRangeData);
      try {
        const input = await this.inputInitialized();
        if (this.isDestroyed() || !input) return;
        input.setRangeData(
          aRangeData.map((oRangeData) =>
            Object.fromEntries(
              Object.entries(oRangeData).map(([key, value]) => {
                const k = key.toLowerCase();
                return [k === 'keyfield' ? 'keyField' : k, value];
              }),
            ),
          ),
        );
        //we need to set token text explicitly, as setRangeData does no recalculation
        for (const [index, token] of (input.getTokens() ?? []).entries()) {
          const rangeItem = aRangeData[index];
          if (!rangeItem) continue;
          const { TOKENLONGKEY, TOKENTEXT } = rangeItem;
          token.data('longKey', TOKENLONGKEY);
          token.data('range', null);
          if (TOKENTEXT) token.setText(TOKENTEXT);
        }
      } catch (e) {
        _logError('SmartMultiInputExt.setRangeData failed', e);
      }
    },
    renderer() {},
    setControl() {
      const input = z2ui5.oView?.byId(this.getProperty('multiInputId'));
      if (!input || this.getProperty('checkInit')) return;
      this.setProperty('checkInit', true);
      try {
        input.attachTokenUpdate(this.onTokenUpdate.bind(this));
        input.attachInnerControlsCreated(this.onInnerControlsCreated.bind(this));
      } catch (e) {
        _logError(`SmartMultiInputExt.setControl: setup failed`, e);
      }
    },
    inputInitialized() {
      return new Promise((resolve) => {
        if (this._bInnerControlsCreated) resolve(this._oInput);
        else this._oPendingInnerControlsCreated = resolve;
      });
    },
    onInnerControlsCreated(oEvent) {
      this._oInput = oEvent.getSource();
      this._oPendingInnerControlsCreated?.(this._oInput);
      this._oPendingInnerControlsCreated = null;
      this._bInnerControlsCreated = true;
    },
  });
});

sap.ui.define(
  'z2ui5/CameraPicture',
  ['sap/ui/core/Control', 'sap/m/Dialog', 'sap/m/Button', 'sap/ui/core/HTML'],
  (Control, Dialog, Button, HTML) => {
    'use strict';
    const _CTX_2D_OPTS = { willReadFrequently: true };
    const _THUMB_W = 300;
    return Control.extend('z2ui5.CameraPicture', {
      metadata: {
        properties: {
          id: { type: 'string' },
          value: { type: 'string' },
          thumbnail: { type: 'string' },
          press: { type: 'string' },
          width: { type: 'string', defaultValue: '200' },
          height: { type: 'string', defaultValue: '200' },
          autoplay: { type: 'boolean', defaultValue: true },
          facingMode: { type: 'string' },
          deviceId: { type: 'string' },
        },
        events: {
          OnPhoto: {
            allowPreventDefault: true,
            parameters: {
              photo: {
                type: 'string',
              },
            },
          },
        },
      },

      capture() {
        const video = document.getElementById(`${this.getId()}-video`);
        const canvas = document.getElementById(`${this.getId()}-canvas`);
        if (!video || !canvas) return;
        const { videoWidth, videoHeight } = video;
        Object.assign(canvas, { width: videoWidth, height: videoHeight });
        const ctx = canvas.getContext('2d', _CTX_2D_OPTS);
        if (!ctx) return;
        ctx.drawImage(video, 0, 0, videoWidth, videoHeight);
        let resultb64;
        try {
          resultb64 = canvas.toDataURL('image/jpeg', 0.85);
        } catch (e) {
          _logError(`CameraPicture: canvas toDataURL failed`, e);
          return;
        }
        const thumbH = videoWidth ? Math.round((videoHeight * _THUMB_W) / videoWidth) : _THUMB_W;
        const thumbCanvas = Object.assign(document.createElement('canvas'), { width: _THUMB_W, height: thumbH });
        thumbCanvas.getContext('2d', _CTX_2D_OPTS)?.drawImage(canvas, 0, 0, _THUMB_W, thumbH);
        let thumbB64 = '';
        try {
          thumbB64 = thumbCanvas.toDataURL('image/jpeg', 0.7);
        } catch (e) {
          _logError(`CameraPicture: thumb toDataURL failed`, e);
        }
        if (this.isDestroyed()) return;
        this.setProperty('value', resultb64);
        this.setProperty('thumbnail', thumbB64);
        this.fireOnPhoto({ photo: resultb64 });
        this._stopCamera();
      },

      _stopCamera() {
        for (const track of this._stream?.getTracks() ?? []) track.stop();
        this._stream = null;
        const video = document.getElementById(`${this.getId()}-video`);
        if (video) video.srcObject = null;
      },

      onPicture() {
        if (this._oScanDialog?.isOpen()) return;
        if (!this._oScanDialog) {
          this._oScanDialog = new Dialog({
            title: 'Device Photo Function',
            contentWidth: '640px',
            contentHeight: '480px',
            horizontalScrolling: false,
            verticalScrolling: false,
            stretch: true,
            content: [
              new HTML({
                id: `${this.getId()}PictureContainer`,
                content: `<video style="width:100%;height:100%;object-fit:contain;" autoplay="true" id="${this.getId()}-video">`,
              }),
              new Button({
                text: 'Capture',
                press: () => {
                  this.capture();
                  this._oScanDialog.close();
                },
              }),
              new HTML({
                content: `<canvas hidden id="${this.getId()}-canvas" style="overflow:auto"></canvas>`,
              }),
            ],
            endButton: new Button({
              text: 'Cancel',
              press: () => {
                this._stopCamera();
                this._oScanDialog.close();
              },
            }),
          });
        }

        this._oScanDialog.attachEventOnce('afterOpen', async () => {
          if (this.isDestroyed()) return;
          const video = document.getElementById(`${this.getId()}-video`);
          if (!video) {
            _logError(`CameraPicture: video element not found after dialog open`);
            return;
          }
          const facingMode = this.getProperty('facingMode');
          const deviceId = this.getProperty('deviceId');
          const options = { video: { width: { ideal: 1920 }, height: { ideal: 1080 } } };
          if (deviceId) options.video.deviceId = deviceId;
          if (facingMode) options.video.facingMode = { exact: facingMode };
          try {
            const stream = await navigator.mediaDevices?.getUserMedia?.(options);
            if (!stream) return;
            if (this.isDestroyed()) {
              for (const t of stream.getTracks()) t.stop();
              return;
            }
            this._stream = video.srcObject = stream;
          } catch (error) {
            _logError(`CameraPicture: getUserMedia failed`, error);
          }
        });
        this._oScanDialog.open();
      },

      exit() {
        this._stopCamera();
        this._oButton?.destroy();
        this._oScanDialog?.destroy();
      },
      renderer(oRm, oControl) {
        oControl._oButton ??= new Button({
          icon: 'sap-icon://camera',
          text: 'Camera',
          press: oControl.onPicture.bind(oControl),
        });
        oRm.renderControl(oControl._oButton);
      },
    });
  },
);

sap.ui.define(
  'z2ui5/CameraSelector',
  ['sap/m/ComboBox', 'sap/ui/core/Item', 'sap/m/ComboBoxRenderer'],
  (ComboBox, Item, ComboBoxRenderer) => {
    'use strict';
    return ComboBox.extend('z2ui5.CameraSelector', {
      async init() {
        ComboBox.prototype.init.call(this);
        try {
          const devices = await navigator.mediaDevices?.enumerateDevices();
          if (!devices) return;
          for (const device of devices) {
            if (device.kind === 'videoinput' && !this.isDestroyed())
              this.addItem(new Item({ key: device.deviceId, text: device.label }));
          }
        } catch (err) {
          _logError(`CameraDeviceList: enumerateDevices failed`, err);
        }
      },

      renderer: ComboBoxRenderer,
    });
  },
);

sap.ui.define('z2ui5/UITableExt', ['sap/ui/core/Control'], (Control) => {
  'use strict';

  const opSymbols = { EQ: '', NE: '!', LT: '<', LE: '<=', GT: '>', GE: '>=' };
  const filterDisplayFns = {
    Contains: (v) => `*${v ?? ''}*`,
    StartsWith: (v) => `^${v ?? ''}`,
    EndsWith: (v) => `${v ?? ''}$`,
  };

  return Control.extend('z2ui5.UITableExt', {
    metadata: {
      properties: {
        tableId: {
          type: 'string',
        },
      },
    },

    init() {
      this._beforeBound = () => {
        this.readFilter();
        this.readSort();
      };
      this._afterBound = () => {
        this.setFilter();
        this.setSort();
      };
      (z2ui5.onBeforeRoundtrip ??= []).push(this._beforeBound);
      (z2ui5.onAfterRoundtrip ??= []).push(this._afterBound);
    },

    exit() {
      z2ui5.onBeforeRoundtrip = (z2ui5.onBeforeRoundtrip ?? []).filter((fn) => fn !== this._beforeBound);
      z2ui5.onAfterRoundtrip = (z2ui5.onAfterRoundtrip ?? []).filter((fn) => fn !== this._afterBound);
    },

    _getTable() {
      return z2ui5.oView?.byId(this.getProperty('tableId'));
    },

    readFilter() {
      try {
        this.aFilters = this._getTable()?.getBinding()?.aFilters;
      } catch (e) {
        _logError(`UITableExt.readFilter failed`, e);
      }
    },

    _applyWhenRendered(oTable, fn) {
      if (oTable.getDomRef()) {
        fn();
        return;
      }
      const delegate = {
        onAfterRendering: () => {
          oTable.removeEventDelegate(delegate);
          if (!this.isDestroyed()) fn();
        },
      };
      oTable.addEventDelegate(delegate);
    },

    _applyFilters(oTable, aFilters) {
      if (!aFilters) return;
      const binding = oTable.getBinding();
      if (!binding) return;
      binding.filter(aFilters);
      const columns = oTable.getColumns();

      for (const oFilter of aFilters) {
        const sProperty = oFilter.sPath || oFilter.aFilters?.[0]?.sPath;
        if (!sProperty) continue;

        const operator = oFilter.sOperator;
        const vValue = oFilter.oValue1 ?? oFilter.oValue2 ?? oFilter.aFilters?.[0]?.oValue1;
        const displayFn =
          operator === 'BT'
            ? (v) => `${v ?? ''}...${oFilter.oValue2 ?? ''}`
            : (filterDisplayFns[operator] ?? ((v) => `${opSymbols[operator] || ''}${v ?? ''}`));
        const display = displayFn(vValue);

        for (const oCol of columns) {
          if (oCol.getFilterProperty?.() === sProperty) {
            oCol.setFilterValue(display);
            oCol.setFiltered(!!display);
          }
        }
      }
    },

    _applyToTable(applyFn, errorMsg) {
      try {
        const oTable = this._getTable();
        if (!oTable) return;
        this._applyWhenRendered(oTable, () => applyFn(oTable));
      } catch (e) {
        _logError(errorMsg, e);
      }
    },

    setFilter() {
      this._applyToTable((oTable) => this._applyFilters(oTable, this.aFilters), `UITableExt.setFilter failed`);
    },

    readSort() {
      try {
        this.aSorters = this._getTable()?.getBinding()?.aSorters;
      } catch (e) {
        _logError(`UITableExt.readSort failed`, e);
      }
    },

    _applySorters(oTable, aSorters) {
      if (!aSorters) return;
      const binding = oTable.getBinding();
      if (!binding) return;
      binding.sort(aSorters);
      const columns = oTable.getColumns();
      for (const [idx, srt] of aSorters.entries()) {
        for (const oCol of columns) {
          if (oCol.getSortProperty?.() === srt.sPath) {
            oCol.setSorted(true);
            oCol.setSortOrder(srt.bDescending ? 'Descending' : 'Ascending');
            oCol.setSortIndex?.(idx);
          }
        }
      }
    },

    setSort() {
      this._applyToTable((oTable) => this._applySorters(oTable, this.aSorters), `UITableExt.setSort failed`);
    },
    renderer() {},
  });
});

sap.ui.define('z2ui5/Util', [], () => {
  'use strict';
  const parseDmy = (d) => [+d.slice(0, 4), +d.slice(4, 6) - 1, +d.slice(6, 8)];
  return {
    DateCreateObject: (s) => new Date(s),
    DateAbapDateToDateObject: (d) => new Date(...parseDmy(d)),
    DateAbapDateTimeToDateObject: (d, t = '000000') =>
      new Date(...parseDmy(d), +t.slice(0, 2), +t.slice(2, 4), +t.slice(4, 6)),
  };
});
sap.ui.require(['z2ui5/Util'], (Util) => (z2ui5.Util = Util));

sap.ui.define('z2ui5/Favicon', ['sap/ui/core/Control'], (Control) => {
  'use strict';
  return Control.extend('z2ui5.Favicon', {
    metadata: {
      properties: {
        favicon: {
          type: 'string',
        },
      },
    },
    setFavicon(val) {
      this.setProperty('favicon', val);
      const existing = document.head.querySelector('link[rel="shortcut icon"]');
      if (existing) {
        existing.href = val;
      } else {
        document.head.appendChild(Object.assign(document.createElement('link'), { rel: 'shortcut icon', href: val }));
      }
    },
    renderer() {},
  });
});

sap.ui.define('z2ui5/Dirty', ['sap/ui/core/Control'], (Control) => {
  'use strict';
  return Control.extend('z2ui5.Dirty', {
    metadata: {
      properties: {
        isDirty: {
          type: 'boolean',
          defaultValue: false,
        },
      },
    },
    setIsDirty(val) {
      this.setProperty('isDirty', val);
      const fallback = () => {
        window.onbeforeunload = val
          ? (e) => {
              e.preventDefault();
              e.returnValue = '';
            }
          : null;
      };

      // use FLP dirty flag (SAPUI5 only) when in Launchpad, else fall back to browser unload
      try {
        if (z2ui5.oLaunchpad?.Container?.setDirtyFlag && z2ui5.oLaunchpad?.ShellUIService) {
          z2ui5.oLaunchpad.Container.setDirtyFlag(val);
        } else {
          fallback();
        }
      } catch (e) {
        _logError(`Dirty.setIsDirty: setDirtyFlag failed`, e);
        fallback();
      }
    },
    exit() {
      window.onbeforeunload = null;
    },
    renderer() {},
  });
});
