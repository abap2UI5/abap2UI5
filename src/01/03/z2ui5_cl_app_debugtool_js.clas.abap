CLASS z2ui5_cl_app_debugtool_js DEFINITION
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


CLASS z2ui5_cl_app_debugtool_js IMPLEMENTATION.

  METHOD get.

    result = `sap.ui.define(` && |\n| &&
             `  ['sap/ui/core/Control', 'sap/ui/core/Fragment', 'sap/ui/model/json/JSONModel', 'z2ui5/cc/Util'],` && |\n| &&
             `  (Control, Fragment, JSONModel, Util) => {` && |\n| &&
             `    'use strict';` && |\n| &&
             `` && |\n| &&
             `    // toJson, prettifyXml, getViewContent, getRenderedContent come from z2ui5/cc/Util` && |\n| &&
             `    const { logError: _logError, hasOwn, toJson, prettifyXml, getViewContent, getRenderedContent } = Util;` && |\n| &&
             `` && |\n| &&
             `    return Control.extend('z2ui5.cc.DebugTool', {` && |\n| &&
             `      _buildHandlers(oEvent, oSource, displayEditor) {` && |\n| &&
             `        const oView = z2ui5.oView;` && |\n| &&
             `        const oResponse = z2ui5.oResponse;` && |\n| &&
             `        return {` && |\n| &&
             `          CONFIG: () => displayEditor(oEvent, toJson(z2ui5.oConfig), 'json'),` && |\n| &&
             `          MODEL: () => displayEditor(oEvent, toJson(oView?.getModel()?.getData()), 'json'),` && |\n| &&
             `          VIEW: () => {` && |\n| &&
             `            const viewContent = getViewContent(oView) || z2ui5.responseData?.S_FRONT?.PARAMS?.S_VIEW?.XML;` && |\n| &&
             `            displayEditor(oEvent, prettifyXml(viewContent), 'xml', prettifyXml(getRenderedContent(oView)));` && |\n| &&
             `          },` && |\n| &&
             `          PLAIN: () => displayEditor(oEvent, toJson(z2ui5.responseData), 'json'),` && |\n| &&
             `          REQUEST: () => displayEditor(oEvent, toJson(z2ui5.oBody), 'json'),` && |\n| &&
             `          POPUP: () => displayEditor(oEvent, prettifyXml(oResponse?.PARAMS?.S_POPUP?.XML), 'xml'),` && |\n| &&
             `          POPUP_MODEL: () => displayEditor(oEvent, toJson(z2ui5.oViewPopup?.getModel()?.getData()), 'json'),` && |\n| &&
             `          POPOVER: () => displayEditor(oEvent, prettifyXml(oResponse?.PARAMS?.S_POPOVER?.XML), 'xml'),` && |\n| &&
             `          POPOVER_MODEL: () => displayEditor(oEvent, toJson(z2ui5.oViewPopover?.getModel()?.getData()), 'json'),` && |\n| &&
             `          NEST1: () =>` && |\n| &&
             `            displayEditor(` && |\n| &&
             `              oEvent,` && |\n| &&
             `              prettifyXml(getViewContent(z2ui5.oViewNest)),` && |\n| &&
             `              'xml',` && |\n| &&
             `              prettifyXml(getRenderedContent(z2ui5.oViewNest)),` && |\n| &&
             `            ),` && |\n| &&
             `          NEST1_MODEL: () => displayEditor(oEvent, toJson(z2ui5.oViewNest?.getModel()?.getData()), 'json'),` && |\n| &&
             `          NEST2: () =>` && |\n| &&
             `            displayEditor(` && |\n| &&
             `              oEvent,` && |\n| &&
             `              prettifyXml(getViewContent(z2ui5.oViewNest2)),` && |\n| &&
             `              'xml',` && |\n| &&
             `              prettifyXml(getRenderedContent(z2ui5.oViewNest2)),` && |\n| &&
             `            ),` && |\n| &&
             `          NEST2_MODEL: () => displayEditor(oEvent, toJson(z2ui5.oViewNest2?.getModel()?.getData()), 'json'),` && |\n| &&
             `          SOURCE: () => {` && |\n| &&
             `            const contentControl = oSource.getParent()?.getContent()?.[2]?.getItems()?.[0];` && |\n| &&
             `            if (!contentControl) return;` && |\n| &&
             `            const appId = encodeURIComponent(z2ui5.responseData?.S_FRONT?.APP ?? '');` && |\n| &&
             `            const url = new URL(``/sap/bc/adt/oo/classes/${appId}/source/main``, window.location.origin).href;` && |\n| &&
             `            // Use a control-scoped iframe id to avoid collisions with other #test elements` && |\n| &&
             `            const iframeId = ``${this.getId()}-source-iframe``;` && |\n| &&
             `            contentControl.setProperty(` && |\n| &&
             `              'content',` && |\n| &&
             `              ``<iframe id="${iframeId}" src="${url}" height="800px" width="100%"/>``,` && |\n| &&
             `            );` && |\n| &&
             `            const oModel = oSource.getModel();` && |\n| &&
             `            if (!oModel) return;` && |\n| &&
             `            Object.assign(oModel.getData(), { editor_visible: false, source_visible: true });` && |\n| &&
             `            oModel.refresh();` && |\n| &&
             `          },` && |\n| &&
             `        };` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      onItemSelect(oEvent) {` && |\n| &&
             `        const oSource = oEvent.getSource();` && |\n| &&
             `        const selItem = oSource.getSelectedKey();` && |\n| &&
             `        const displayEditor = (this._displayEditorBound ??= this.displayEditor.bind(this));` && |\n| &&
             `        // Rebuild on each click — handlers close over the current oView/oResponse references` && |\n| &&
             `        const handlers = this._buildHandlers(oEvent, oSource, displayEditor);` && |\n| &&
             `        if (hasOwn(handlers, selItem)) handlers[selItem]();` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      displayEditor(oEvent, content, type, xcontent = '') {` && |\n| &&
             `        const oModel = oEvent.getSource().getModel();` && |\n| &&
             `        // previousValue mirrors value here; onTemplatingPress later toggles between value and xContent` && |\n| &&
             `        Object.assign(oModel.getData(), {` && |\n| &&
             `          editor_visible: true,` && |\n| &&
             `          source_visible: false,` && |\n| &&
             `          // Word-boundary detection: only flag actual ``xmlns:template=`` declarations, avoid` && |\n| &&
             `          // false positives like ``xmlns:templateData=`` or matches inside text/comment nodes` && |\n| &&
             `          isTemplating: typeof content === 'string' && /\bxmlns:template\s*=/.test(content),` && |\n| &&
             `          value: content,` && |\n| &&
             `          previousValue: content,` && |\n| &&
             `          xContent: xcontent,` && |\n| &&
             `          type,` && |\n| &&
             `        });` && |\n| &&
             `        oModel.refresh();` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      onTemplatingPress(oEvent) {` && |\n| &&
             `        const oSource = oEvent.getSource();` && |\n| &&
             `        const oModel = oSource.getModel();` && |\n| &&
             `        const modelData = oModel.getData();` && |\n| &&
             `        modelData.value = oSource.getPressed() ? modelData.xContent : modelData.previousValue;` && |\n| &&
             `        oModel.refresh();` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      onClose() {` && |\n| &&
             `        this.close();` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      async show() {` && |\n| &&
             `        if (this._showPending) return;` && |\n| &&
             `        this._showPending = true;` && |\n| &&
             `        try {` && |\n| &&
             `          if (!this.oDialog) {` && |\n| &&
             `            this.oDialog = await Fragment.load({` && |\n| &&
             `              name: 'z2ui5.cc.DebugTool',` && |\n| &&
             `              controller: this,` && |\n| &&
             `            });` && |\n| &&
             `          }` && |\n| &&
             `          if (this.isDestroyed()) {` && |\n| &&
             `            this.oDialog?.destroy();` && |\n| &&
             `            this.oDialog = null;` && |\n| &&
             `            return;` && |\n| &&
             `          }` && |\n| &&
             `          const value = toJson(z2ui5.responseData);` && |\n| &&
             `          const oData = {` && |\n| &&
             `            type: 'json',` && |\n| &&
             `            source_visible: false,` && |\n| &&
             `            editor_visible: true,` && |\n| &&
             `            value,` && |\n| &&
             `            xContent: '',` && |\n| &&
             `            previousValue: value,` && |\n| &&
             `            isTemplating: false,` && |\n| &&
             `            templatingSource: false,` && |\n| &&
             `            activeNest1: !!getViewContent(z2ui5.oViewNest),` && |\n| &&
             `            activeNest2: !!getViewContent(z2ui5.oViewNest2),` && |\n| &&
             `            activePopup: !!z2ui5.oResponse?.PARAMS?.S_POPUP?.XML,` && |\n| &&
             `            activePopover: !!z2ui5.oResponse?.PARAMS?.S_POPOVER?.XML,` && |\n| &&
             `          };` && |\n| &&
             `          const oModel = new JSONModel(oData);` && |\n| &&
             `          const { oDialog } = this;` && |\n| &&
             `          oDialog.setModel(oModel);` && |\n| &&
             `          oDialog.open();` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          _logError(``DebugTool.show failed``, e);` && |\n| &&
             `        } finally {` && |\n| &&
             `          this._showPending = false;` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      close() {` && |\n| &&
             `        if (!this.oDialog) return;` && |\n| &&
             `        const { oDialog } = this;` && |\n| &&
             `        this.oDialog = null;` && |\n| &&
             `        try {` && |\n| &&
             `          oDialog.close();` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          _logError(``DebugTool.close: oDialog.close() failed``, e);` && |\n| &&
             `        }` && |\n| &&
             `        try {` && |\n| &&
             `          oDialog.destroy();` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          _logError(``DebugTool.close: oDialog.destroy() failed``, e);` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      toggle() {` && |\n| &&
             `        if (this.oDialog) this.close();` && |\n| &&
             `        else this.show();` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      renderer: { apiVersion: 2, render() {} },` && |\n| &&
             `    });` && |\n| &&
             `  },` && |\n| &&
             `);` && |\n| &&
             `` && |\n| &&
              ``.

  ENDMETHOD.

ENDCLASS.
