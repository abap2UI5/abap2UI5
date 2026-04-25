sap.ui.define(
  ['sap/ui/core/Control', 'sap/ui/core/Fragment', 'sap/ui/model/json/JSONModel'],
  (Control, Fragment, JSONModel) => {
    'use strict';

    const toJson = (val) => JSON.stringify(val ?? null, null, 3);

    const PRETTIFY_XSL = `<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
        <xsl:strip-space elements="*" />
        <xsl:template match="para[content-style][not(text())]">
          <xsl:value-of select="normalize-space(.)" />
        </xsl:template>
        <xsl:template match="node()|@*">
          <xsl:copy>
            <xsl:apply-templates select="node()|@*" />
          </xsl:copy>
        </xsl:template>
        <xsl:output indent="yes" />
      </xsl:stylesheet>`;

    let _xsltProcessor = null;
    const _xmlSerializer = new XMLSerializer();
    const _domParser = new DOMParser();
    const getXsltProcessor = () => {
      if (!_xsltProcessor) {
        const xsltDoc = _domParser.parseFromString(PRETTIFY_XSL, 'application/xml');
        _xsltProcessor = new XSLTProcessor();
        _xsltProcessor.importStylesheet(xsltDoc);
      }
      return _xsltProcessor;
    };

    return Control.extend('z2ui5.cc.DebugTool', {
      prettifyXml(sourceXml) {
        if (!sourceXml) return '';
        try {
          const xmlDoc = _domParser.parseFromString(sourceXml, 'application/xml');
          const resultDoc = getXsltProcessor().transformToDocument(xmlDoc);
          if (!resultDoc) return sourceXml;
          const resultXml = _xmlSerializer.serializeToString(resultDoc);
          return resultXml.replace(/&gt;|&lt;/g, (m) => (m === '&gt;' ? '>' : '<'));
        } catch {
          return sourceXml;
        }
      },

      onItemSelect(oEvent) {
        const oSource = oEvent.getSource();
        const selItem = oSource.getSelectedKey();
        const oView = z2ui5.oView;
        const oResponse = z2ui5.oResponse;
        const displayEditor = (this._displayEditorBound ??= this.displayEditor.bind(this));
        const { prettifyXml } = this;

        switch (selItem) {
          case 'CONFIG':
            displayEditor(oEvent, toJson(z2ui5.oConfig), 'json');
            break;
          case 'MODEL':
            displayEditor(oEvent, toJson(oView?.getModel()?.getData()), 'json');
            break;
          case 'VIEW': {
            const viewContent = oView?.mProperties?.viewContent || z2ui5.responseData?.S_FRONT?.PARAMS?.S_VIEW?.XML;
            displayEditor(oEvent, prettifyXml(viewContent), 'xml', prettifyXml(oView?._xContent?.outerHTML));
            break;
          }
          case 'PLAIN':
            displayEditor(oEvent, toJson(z2ui5.responseData), 'json');
            break;
          case 'REQUEST':
            displayEditor(oEvent, toJson(z2ui5.oBody), 'json');
            break;
          case 'POPUP':
            displayEditor(oEvent, prettifyXml(oResponse?.PARAMS?.S_POPUP?.XML), 'xml');
            break;
          case 'POPUP_MODEL':
            displayEditor(oEvent, toJson(z2ui5.oViewPopup?.getModel()?.getData()), 'json');
            break;
          case 'POPOVER':
            displayEditor(oEvent, prettifyXml(oResponse?.PARAMS?.S_POPOVER?.XML), 'xml');
            break;
          case 'POPOVER_MODEL':
            displayEditor(oEvent, toJson(z2ui5.oViewPopover?.getModel()?.getData()), 'json');
            break;
          case 'NEST1':
            displayEditor(
              oEvent,
              prettifyXml(z2ui5.oViewNest?.mProperties?.viewContent),
              'xml',
              prettifyXml(z2ui5.oViewNest?._xContent?.outerHTML),
            );
            break;
          case 'NEST1_MODEL':
            displayEditor(oEvent, toJson(z2ui5.oViewNest?.getModel()?.getData()), 'json');
            break;
          case 'NEST2':
            displayEditor(
              oEvent,
              prettifyXml(z2ui5.oViewNest2?.mProperties?.viewContent),
              'xml',
              prettifyXml(z2ui5.oViewNest2?._xContent?.outerHTML),
            );
            break;
          case 'NEST2_MODEL':
            displayEditor(oEvent, toJson(z2ui5.oViewNest2?.getModel()?.getData()), 'json');
            break;
          case 'SOURCE': {
            const contentControl = oSource.getParent()?.getContent()?.[2]?.getItems()?.[0];
            if (!contentControl) break;
            const appId = encodeURIComponent(z2ui5.responseData?.S_FRONT?.APP ?? '');
            const url = `${window.location.origin}/sap/bc/adt/oo/classes/${appId}/source/main`;
            contentControl.setProperty('content', `<iframe id="test" src="${url}" height="800px" width="1200px" />`);
            const oModel = oSource.getModel();
            if (!oModel) break;
            Object.assign(oModel.getData(), { editor_visible: false, source_visible: true });
            oModel.refresh();
            break;
          }
        }
      },

      displayEditor(oEvent, content, type, xcontent = '') {
        const oModel = oEvent.getSource().getModel();
        Object.assign(oModel.getData(), {
          editor_visible: true,
          source_visible: false,
          isTemplating: content?.includes('xmlns:template') ?? false,
          value: content,
          previousValue: content,
          xContent: xcontent,
          type,
        });
        oModel.refresh();
      },

      onTemplatingPress(oEvent) {
        const oSource = oEvent.getSource();
        const oModel = oSource.getModel();
        const modelData = oModel.getData();
        modelData.value = oSource.getPressed() ? modelData.xContent : modelData.previousValue;
        oModel.refresh();
      },

      onClose() {
        this.close();
      },

      async show() {
        if (this._showPending) return;
        this._showPending = true;
        try {
          if (!this.oDialog) {
            this.oDialog = await Fragment.load({
              name: 'z2ui5.cc.DebugTool',
              controller: this,
            });
          }
          if (this.isDestroyed()) {
            this.oDialog?.destroy();
            this.oDialog = null;
            return;
          }
          const value = toJson(z2ui5.responseData);
          const oData = {
            type: 'json',
            source_visible: false,
            editor_visible: true,
            value,
            xContent: '',
            previousValue: value,
            isTemplating: false,
            templatingSource: false,
            activeNest1: !!z2ui5.oViewNest?.mProperties?.viewContent,
            activeNest2: !!z2ui5.oViewNest2?.mProperties?.viewContent,
            activePopup: !!z2ui5.oResponse?.PARAMS?.S_POPUP?.XML,
            activePopover: !!z2ui5.oResponse?.PARAMS?.S_POPOVER?.XML,
          };
          const oModel = new JSONModel(oData);
          const { oDialog } = this;
          oDialog.addStyleClass('dbg-ltr');
          oDialog.setModel(oModel);
          oDialog.open();
        } catch (e) {
          (z2ui5.errors ??= []).push({ message: `DebugTool.show failed`, error: e, ts: new Date().toISOString() });
        } finally {
          this._showPending = false;
        }
      },

      close() {
        if (!this.oDialog) return;
        const { oDialog } = this;
        this.oDialog = null;
        oDialog.close();
        oDialog.destroy();
      },

      toggle() {
        if (this.oDialog) this.close();
        else this.show();
      },

      renderer: { apiVersion: 2, render() {} },
    });
  },
);
