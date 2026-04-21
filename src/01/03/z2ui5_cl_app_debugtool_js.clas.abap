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
             `  ['sap/ui/core/Control', 'sap/ui/core/Fragment', 'sap/ui/model/json/JSONModel'],` && |\n| &&
             `  (Control, Fragment, JSONModel) => {` && |\n| &&
             `    'use strict';` && |\n| &&
             `` && |\n| &&
             `    const toJson = (val) => JSON.stringify(val ?? null, null, 3);` && |\n| &&
             `` && |\n| &&
             `    const PRETTIFY_XSL = ``<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform">` && |\n| &&
             `        <xsl:strip-space elements="*" />` && |\n| &&
             `        <xsl:template match="para[content-style][not(text())]">` && |\n| &&
             `          <xsl:value-of select="normalize-space(.)" />` && |\n| &&
             `        </xsl:template>` && |\n| &&
             `        <xsl:template match="node()|@*">` && |\n| &&
             `          <xsl:copy>` && |\n| &&
             `            <xsl:apply-templates select="node()|@*" />` && |\n| &&
             `          </xsl:copy>` && |\n| &&
             `        </xsl:template>` && |\n| &&
             `        <xsl:output indent="yes" />` && |\n| &&
             `      </xsl:stylesheet>``;` && |\n| &&
             `` && |\n| &&
             `    let _xsltProcessor = null;` && |\n| &&
             `    const _xmlSerializer = new XMLSerializer();` && |\n| &&
             `    const _domParser = new DOMParser();` && |\n| &&
             `    function getXsltProcessor() {` && |\n| &&
             `      if (!_xsltProcessor) {` && |\n| &&
             `        const xsltDoc = _domParser.parseFromString(PRETTIFY_XSL, 'application/xml');` && |\n| &&
             `        _xsltProcessor = new XSLTProcessor();` && |\n| &&
             `        _xsltProcessor.importStylesheet(xsltDoc);` && |\n| &&
             `      }` && |\n| &&
             `      return _xsltProcessor;` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    return Control.extend('z2ui5.cc.DebugTool', {` && |\n| &&
             `      prettifyXml(sourceXml) {` && |\n| &&
             `        if (!sourceXml) return '';` && |\n| &&
             `        try {` && |\n| &&
             `          const xmlDoc = _domParser.parseFromString(sourceXml, 'application/xml');` && |\n| &&
             `          const resultDoc = getXsltProcessor().transformToDocument(xmlDoc);` && |\n| &&
             `          if (!resultDoc) return sourceXml;` && |\n| &&
             `          const resultXml = _xmlSerializer.serializeToString(resultDoc);` && |\n| &&
             `          return resultXml.replace(/&gt;|&lt;/g, (m) => (m === '&gt;' ? '>' : '<'));` && |\n| &&
             `        } catch {` && |\n| &&
             `          return sourceXml;` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      onItemSelect(oEvent) {` && |\n| &&
             `        const oSource = oEvent.getSource();` && |\n| &&
             `        const selItem = oSource.getSelectedKey();` && |\n| &&
             `        const oView = z2ui5.oView;` && |\n| &&
             `        const oResponse = z2ui5.oResponse;` && |\n| &&
             `        const displayEditor = (this._displayEditorBound ??= this.displayEditor.bind(this));` && |\n| &&
             `        const { prettifyXml } = this;` && |\n| &&
             `` && |\n| &&
             `        switch (selItem) {` && |\n| &&
             `          case 'CONFIG':` && |\n| &&
             `            displayEditor(oEvent, toJson(z2ui5.oConfig), 'json');` && |\n| &&
             `            break;` && |\n| &&
             `          case 'MODEL':` && |\n| &&
             `            displayEditor(oEvent, toJson(oView?.getModel()?.getData()), 'json');` && |\n| &&
             `            break;` && |\n| &&
             `          case 'VIEW': {` && |\n| &&
             `            const viewContent = oView?.mProperties?.viewContent || z2ui5.responseData?.S_FRONT?.PARAMS?.S_VIEW?.XML;` && |\n| &&
             `            displayEditor(oEvent, prettifyXml(viewContent), 'xml', prettifyXml(oView?._xContent?.outerHTML));` && |\n| &&
             `            break;` && |\n| &&
             `          }` && |\n| &&
             `          case 'PLAIN':` && |\n| &&
             `            displayEditor(oEvent, toJson(z2ui5.responseData), 'json');` && |\n| &&
             `            break;` && |\n| &&
             `          case 'REQUEST':` && |\n| &&
             `            displayEditor(oEvent, toJson(z2ui5.oBody), 'json');` && |\n| &&
             `            break;` && |\n| &&
             `          case 'POPUP':` && |\n| &&
             `            displayEditor(oEvent, prettifyXml(oResponse?.PARAMS?.S_POPUP?.XML), 'xml');` && |\n| &&
             `            break;` && |\n| &&
             `          case 'POPUP_MODEL':` && |\n| &&
             `            displayEditor(oEvent, toJson(z2ui5.oViewPopup?.getModel()?.getData()), 'json');` && |\n| &&
             `            break;` && |\n| &&
             `          case 'POPOVER':` && |\n| &&
             `            displayEditor(oEvent, prettifyXml(oResponse?.PARAMS?.S_POPOVER?.XML), 'xml');` && |\n| &&
             `            break;` && |\n| &&
             `          case 'POPOVER_MODEL':` && |\n| &&
             `            displayEditor(oEvent, toJson(z2ui5.oViewPopover?.getModel()?.getData()), 'json');` && |\n| &&
             `            break;` && |\n| &&
             `          case 'NEST1':` && |\n| &&
             `            displayEditor(` && |\n| &&
             `              oEvent,` && |\n| &&
             `              prettifyXml(z2ui5.oViewNest?.mProperties?.viewContent),` && |\n| &&
             `              'xml',` && |\n| &&
             `              prettifyXml(z2ui5.oViewNest?._xContent?.outerHTML),` && |\n| &&
             `            );` && |\n| &&
             `            break;` && |\n| &&
             `          case 'NEST1_MODEL':` && |\n| &&
             `            displayEditor(oEvent, toJson(z2ui5.oViewNest?.getModel()?.getData()), 'json');` && |\n| &&
             `            break;` && |\n| &&
             `          case 'NEST2':` && |\n| &&
             `            displayEditor(` && |\n| &&
             `              oEvent,` && |\n| &&
             `              prettifyXml(z2ui5.oViewNest2?.mProperties?.viewContent),` && |\n| &&
             `              'xml',` && |\n| &&
             `              prettifyXml(z2ui5.oViewNest2?._xContent?.outerHTML),` && |\n| &&
             `            );` && |\n| &&
             `            break;` && |\n| &&
             `          case 'NEST2_MODEL':` && |\n| &&
             `            displayEditor(oEvent, toJson(z2ui5.oViewNest2?.getModel()?.getData()), 'json');` && |\n| &&
             `            break;` && |\n| &&
             `          case 'SOURCE': {` && |\n| &&
             `            const contentControl = oSource.getParent()?.getContent()?.[2]?.getItems()?.[0];` && |\n| &&
             `            if (!contentControl) break;` && |\n| &&
             `            const appId = encodeURIComponent(z2ui5.responseData?.S_FRONT?.APP ?? '');` && |\n| &&
             `            const url = ``${window.location.origin}/sap/bc/adt/oo/classes/${appId}/source/main``;` && |\n| &&
             `            contentControl.setProperty('content', ``<iframe id="test" src="${url}" height="800px" width="1200px" />``);` && |\n| &&
             `            const oModel = oSource.getModel();` && |\n| &&
             `            if (!oModel) break;` && |\n| &&
             `            Object.assign(oModel.getData(), { editor_visible: false, source_visible: true });` && |\n| &&
             `            oModel.refresh();` && |\n| &&
             `            break;` && |\n| &&
             `          }` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      displayEditor(oEvent, content, type, xcontent = '') {` && |\n| &&
             `        const oModel = oEvent.getSource().getModel();` && |\n| &&
             `        Object.assign(oModel.getData(), {` && |\n| &&
             `          editor_visible: true,` && |\n| &&
             `          source_visible: false,` && |\n| &&
             `          isTemplating: content?.includes('xmlns:template') ?? false,` && |\n| &&
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
             `          if (this.bIsDestroyed) {` && |\n| &&
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
             `            activeNest1: !!z2ui5.oViewNest?.mProperties?.viewContent,` && |\n| &&
             `            activeNest2: !!z2ui5.oViewNest2?.mProperties?.viewContent,` && |\n| &&
             `            activePopup: !!z2ui5.oResponse?.PARAMS?.S_POPUP?.XML,` && |\n| &&
             `            activePopover: !!z2ui5.oResponse?.PARAMS?.S_POPOVER?.XML,` && |\n| &&
             `          };` && |\n| &&
             `          const oModel = new JSONModel(oData);` && |\n| &&
             `          const { oDialog } = this;` && |\n| &&
             `          oDialog.addStyleClass('dbg-ltr');` && |\n| &&
             `          oDialog.setModel(oModel);` && |\n| &&
             `          oDialog.open();` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          (z2ui5.errors ??= []).push({ message: ``DebugTool.show failed``, error: e, ts: new Date().toISOString() });` && |\n| &&
             `        } finally {` && |\n| &&
             `          this._showPending = false;` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      close() {` && |\n| &&
             `        if (!this.oDialog) return;` && |\n| &&
             `        const { oDialog } = this;` && |\n| &&
             `        this.oDialog = null;` && |\n| &&
             `        oDialog.close();` && |\n| &&
             `        oDialog.destroy();` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      toggle() {` && |\n| &&
             `        if (this.oDialog) this.close();` && |\n| &&
             `        else this.show();` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      renderer() {},` && |\n| &&
             `    });` && |\n| &&
             `  },` && |\n| &&
             `);` && |\n| &&
             `` && |\n| &&
              ``.

  ENDMETHOD.

ENDCLASS.
