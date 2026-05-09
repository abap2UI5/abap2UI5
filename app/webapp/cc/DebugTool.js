sap.ui.define(
  ['sap/ui/core/Control', 'sap/ui/core/Fragment', 'sap/ui/model/json/JSONModel'],
  (Control, Fragment, JSONModel) => {
    'use strict';

    const _logError = (message, error) => {
      const entry = { message, ts: new Date().toISOString() };
      if (error !== undefined) entry.error = error;
      (z2ui5.errors ??= []).push(entry);
    };

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
    const _xmlSerializer = typeof XMLSerializer !== 'undefined' ? new XMLSerializer() : null;
    const _domParser = typeof DOMParser !== 'undefined' ? new DOMParser() : null;
    const getXsltProcessor = () => {
      if (typeof XSLTProcessor === 'undefined' || !_domParser) return null;
      if (!_xsltProcessor) {
        const xsltDoc = _domParser.parseFromString(PRETTIFY_XSL, 'application/xml');
        _xsltProcessor = new XSLTProcessor();
        _xsltProcessor.importStylesheet(xsltDoc);
      }
      return _xsltProcessor;
    };

    // prettifyXml does not use 'this' — module-scoped so callers don't need to bind/destructure
    const prettifyXml = (sourceXml) => {
      if (!sourceXml) return '';
      const processor = getXsltProcessor();
      if (!processor || !_domParser || !_xmlSerializer) {
        _logError('DebugTool.prettifyXml: XSLT/XMLSerializer/DOMParser unavailable in this browser');
        return sourceXml;
      }
      try {
        const xmlDoc = _domParser.parseFromString(sourceXml, 'application/xml');
        const resultDoc = processor.transformToDocument(xmlDoc);
        if (!resultDoc) return sourceXml;
        return _xmlSerializer.serializeToString(resultDoc);
      } catch (e) {
        _logError('DebugTool.prettifyXml: XSLT transform failed', e);
        return sourceXml;
      }
    };

    // getViewContent uses the public API when available and falls back to mProperties.viewContent
    // (UI5 internal) for older versions that do not expose a getter
    const getViewContent = (view) => view?.getViewContent?.() ?? view?.mProperties?.viewContent;
    // _xContent is a UI5-internal property holding the raw post-templating XML; there is no
    // public equivalent for the rendered (post-template) view source, so we accept the lookup.
    const getRenderedContent = (view) => view?._xContent?.outerHTML;

    return Control.extend('z2ui5.cc.DebugTool', {
      _buildHandlers(oEvent, oSource, displayEditor) {
        const oView = z2ui5.oView;
        const oResponse = z2ui5.oResponse;
        return {
          CONFIG: () => displayEditor(oEvent, toJson(z2ui5.oConfig), 'json'),
          MODEL: () => displayEditor(oEvent, toJson(oView?.getModel()?.getData()), 'json'),
          VIEW: () => {
            const viewContent = getViewContent(oView) || z2ui5.responseData?.S_FRONT?.PARAMS?.S_VIEW?.XML;
            displayEditor(oEvent, prettifyXml(viewContent), 'xml', prettifyXml(getRenderedContent(oView)));
          },
          PLAIN: () => displayEditor(oEvent, toJson(z2ui5.responseData), 'json'),
          REQUEST: () => displayEditor(oEvent, toJson(z2ui5.oBody), 'json'),
          POPUP: () => displayEditor(oEvent, prettifyXml(oResponse?.PARAMS?.S_POPUP?.XML), 'xml'),
          POPUP_MODEL: () => displayEditor(oEvent, toJson(z2ui5.oViewPopup?.getModel()?.getData()), 'json'),
          POPOVER: () => displayEditor(oEvent, prettifyXml(oResponse?.PARAMS?.S_POPOVER?.XML), 'xml'),
          POPOVER_MODEL: () => displayEditor(oEvent, toJson(z2ui5.oViewPopover?.getModel()?.getData()), 'json'),
          NEST1: () =>
            displayEditor(
              oEvent,
              prettifyXml(getViewContent(z2ui5.oViewNest)),
              'xml',
              prettifyXml(getRenderedContent(z2ui5.oViewNest)),
            ),
          NEST1_MODEL: () => displayEditor(oEvent, toJson(z2ui5.oViewNest?.getModel()?.getData()), 'json'),
          NEST2: () =>
            displayEditor(
              oEvent,
              prettifyXml(getViewContent(z2ui5.oViewNest2)),
              'xml',
              prettifyXml(getRenderedContent(z2ui5.oViewNest2)),
            ),
          NEST2_MODEL: () => displayEditor(oEvent, toJson(z2ui5.oViewNest2?.getModel()?.getData()), 'json'),
          SOURCE: () => {
            const contentControl = oSource.getParent()?.getContent()?.[2]?.getItems()?.[0];
            if (!contentControl) return;
            const appId = encodeURIComponent(z2ui5.responseData?.S_FRONT?.APP ?? '');
            const url = new URL(`/sap/bc/adt/oo/classes/${appId}/source/main`, window.location.origin).href;
            // Use a control-scoped iframe id to avoid collisions with other #test elements
            const iframeId = `${this.getId()}-source-iframe`;
            contentControl.setProperty(
              'content',
              `<iframe id="${iframeId}" src="${url}" height="800px" width="100%"/>`,
            );
            const oModel = oSource.getModel();
            if (!oModel) return;
            Object.assign(oModel.getData(), { editor_visible: false, source_visible: true });
            oModel.refresh();
          },
        };
      },

      onItemSelect(oEvent) {
        const oSource = oEvent.getSource();
        const selItem = oSource.getSelectedKey();
        const displayEditor = (this._displayEditorBound ??= this.displayEditor.bind(this));
        // Rebuild on each click — handlers close over the current oView/oResponse references
        const handlers = this._buildHandlers(oEvent, oSource, displayEditor);
        if (Object.hasOwn(handlers, selItem)) handlers[selItem]();
      },

      displayEditor(oEvent, content, type, xcontent = '') {
        const oModel = oEvent.getSource().getModel();
        // previousValue mirrors value here; onTemplatingPress later toggles between value and xContent
        Object.assign(oModel.getData(), {
          editor_visible: true,
          source_visible: false,
          // Word-boundary detection: only flag actual `xmlns:template=` declarations, avoid
          // false positives like `xmlns:templateData=` or matches inside text/comment nodes
          isTemplating: typeof content === 'string' && /\bxmlns:template\s*=/.test(content),
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
            activeNest1: !!getViewContent(z2ui5.oViewNest),
            activeNest2: !!getViewContent(z2ui5.oViewNest2),
            activePopup: !!z2ui5.oResponse?.PARAMS?.S_POPUP?.XML,
            activePopover: !!z2ui5.oResponse?.PARAMS?.S_POPOVER?.XML,
          };
          const oModel = new JSONModel(oData);
          const { oDialog } = this;
          // .dbg-ltr forces LTR direction inside the dialog (defined in css/style.css)
          oDialog.addStyleClass('dbg-ltr');
          oDialog.setModel(oModel);
          oDialog.open();
        } catch (e) {
          _logError(`DebugTool.show failed`, e);
        } finally {
          this._showPending = false;
        }
      },

      close() {
        if (!this.oDialog) return;
        const { oDialog } = this;
        this.oDialog = null;
        const safeDestroy = () => {
          try {
            oDialog.destroy();
          } catch (e) {
            _logError(`DebugTool.close: oDialog.destroy() failed`, e);
          }
        };
        try {
          // Defer destroy until the close animation has settled to avoid races
          if (typeof oDialog.attachEventOnce === 'function' && typeof oDialog.isOpen === 'function' && oDialog.isOpen()) {
            oDialog.attachEventOnce('afterClose', safeDestroy);
            oDialog.close();
            return;
          }
          oDialog.close();
        } catch (e) {
          _logError(`DebugTool.close: oDialog.close() failed`, e);
        }
        safeDestroy();
      },

      toggle() {
        if (this.oDialog) this.close();
        else this.show();
      },

      renderer: { apiVersion: 2, render() {} },
    });
  },
);
