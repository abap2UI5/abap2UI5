sap.ui.define(
  [
    "sap/ui/core/Control",
    "sap/ui/core/Fragment",
    "sap/ui/model/json/JSONModel",
  ],
  (Control, Fragment, JSONModel) => {
    "use strict";

    // Append an entry to the global error log. We create the array on first use.
    function logError(message, error) {
      if (!z2ui5.errors) z2ui5.errors = [];
      z2ui5.errors.push({
        message: message,
        error: error,
        ts: new Date().toISOString(),
      });
    }

    // Pretty-print any value (object, array, primitive) as indented JSON.
    // `null` is used as a fallback so undefined values still produce output.
    function toJson(val) {
      const safe = val === undefined ? null : val;
      return JSON.stringify(safe, null, 3);
    }

    // XSL stylesheet used by prettifyXml to reindent any XML string.
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

    // The XSLT processor and (de)serializers are expensive to construct, so
    // we keep them as module-level singletons.
    const _xmlSerializer = new XMLSerializer();
    const _domParser = new DOMParser();
    let _xsltProcessor = null;

    function getXsltProcessor() {
      if (_xsltProcessor) return _xsltProcessor;
      const xsltDoc = _domParser.parseFromString(
        PRETTIFY_XSL,
        "application/xml",
      );
      _xsltProcessor = new XSLTProcessor();
      _xsltProcessor.importStylesheet(xsltDoc);
      return _xsltProcessor;
    }

    return Control.extend("z2ui5.cc.DebugTool", {
      // Reformat an XML string with indentation. If anything goes wrong the
      // original input is returned unchanged - the debug tool must never
      // crash the host app.
      prettifyXml(sourceXml) {
        if (!sourceXml) return "";
        try {
          const xmlDoc = _domParser.parseFromString(
            sourceXml,
            "application/xml",
          );
          const resultDoc = getXsltProcessor().transformToDocument(xmlDoc);
          if (!resultDoc) return sourceXml;
          const resultXml = _xmlSerializer.serializeToString(resultDoc);
          // The serializer escapes < and > inside text nodes; undo this so
          // the output is browseable XML again.
          return resultXml.replace(/&gt;|&lt;/g, (m) =>
            m === "&gt;" ? ">" : "<",
          );
        } catch (e) {
          return sourceXml;
        }
      },

      // Called when the user picks an entry in the dropdown of the debug
      // dialog. Each case shows a different piece of internal state.
      onItemSelect(oEvent) {
        const oSource = oEvent.getSource();
        const selItem = oSource.getSelectedKey();
        const oView = z2ui5.oView;
        const oResponse = z2ui5.oResponse;

        // Cache a bound version of displayEditor so we don't recreate the
        // bound function on every call.
        if (!this._displayEditorBound) {
          this._displayEditorBound = this.displayEditor.bind(this);
        }
        const displayEditor = this._displayEditorBound;
        const prettifyXml = this.prettifyXml;

        switch (selItem) {
          case "CONFIG":
            displayEditor(oEvent, toJson(z2ui5.oConfig), "json");
            break;

          case "MODEL": {
            const data =
              oView && oView.getModel() && oView.getModel().getData();
            displayEditor(oEvent, toJson(data), "json");
            break;
          }

          case "VIEW": {
            // Prefer the actual viewContent string; fall back to the XML
            // that arrived in the last server response.
            const viewContent =
              (oView && oView.mProperties && oView.mProperties.viewContent) ||
              (z2ui5.responseData &&
                z2ui5.responseData.S_FRONT &&
                z2ui5.responseData.S_FRONT.PARAMS &&
                z2ui5.responseData.S_FRONT.PARAMS.S_VIEW &&
                z2ui5.responseData.S_FRONT.PARAMS.S_VIEW.XML);
            const rendered =
              oView && oView._xContent && oView._xContent.outerHTML;
            displayEditor(
              oEvent,
              prettifyXml(viewContent),
              "xml",
              prettifyXml(rendered),
            );
            break;
          }

          case "PLAIN":
            displayEditor(oEvent, toJson(z2ui5.responseData), "json");
            break;

          case "REQUEST":
            displayEditor(oEvent, toJson(z2ui5.oBody), "json");
            break;

          case "POPUP": {
            const xml =
              oResponse &&
              oResponse.PARAMS &&
              oResponse.PARAMS.S_POPUP &&
              oResponse.PARAMS.S_POPUP.XML;
            displayEditor(oEvent, prettifyXml(xml), "xml");
            break;
          }

          case "POPUP_MODEL": {
            const data =
              z2ui5.oViewPopup &&
              z2ui5.oViewPopup.getModel() &&
              z2ui5.oViewPopup.getModel().getData();
            displayEditor(oEvent, toJson(data), "json");
            break;
          }

          case "POPOVER": {
            const xml =
              oResponse &&
              oResponse.PARAMS &&
              oResponse.PARAMS.S_POPOVER &&
              oResponse.PARAMS.S_POPOVER.XML;
            displayEditor(oEvent, prettifyXml(xml), "xml");
            break;
          }

          case "POPOVER_MODEL": {
            const data =
              z2ui5.oViewPopover &&
              z2ui5.oViewPopover.getModel() &&
              z2ui5.oViewPopover.getModel().getData();
            displayEditor(oEvent, toJson(data), "json");
            break;
          }

          case "NEST1": {
            const nest = z2ui5.oViewNest;
            const xml =
              nest && nest.mProperties && nest.mProperties.viewContent;
            const rendered = nest && nest._xContent && nest._xContent.outerHTML;
            displayEditor(
              oEvent,
              prettifyXml(xml),
              "xml",
              prettifyXml(rendered),
            );
            break;
          }

          case "NEST1_MODEL": {
            const data =
              z2ui5.oViewNest &&
              z2ui5.oViewNest.getModel() &&
              z2ui5.oViewNest.getModel().getData();
            displayEditor(oEvent, toJson(data), "json");
            break;
          }

          case "NEST2": {
            const nest = z2ui5.oViewNest2;
            const xml =
              nest && nest.mProperties && nest.mProperties.viewContent;
            const rendered = nest && nest._xContent && nest._xContent.outerHTML;
            displayEditor(
              oEvent,
              prettifyXml(xml),
              "xml",
              prettifyXml(rendered),
            );
            break;
          }

          case "NEST2_MODEL": {
            const data =
              z2ui5.oViewNest2 &&
              z2ui5.oViewNest2.getModel() &&
              z2ui5.oViewNest2.getModel().getData();
            displayEditor(oEvent, toJson(data), "json");
            break;
          }

          case "SOURCE": {
            // Show the ABAP source of the running app inside an iframe.
            const parent = oSource.getParent();
            const content = parent && parent.getContent && parent.getContent();
            const contentControl =
              content &&
              content[2] &&
              content[2].getItems &&
              content[2].getItems()[0];
            if (!contentControl) break;

            const appName =
              (z2ui5.responseData &&
                z2ui5.responseData.S_FRONT &&
                z2ui5.responseData.S_FRONT.APP) ||
              "";
            const appId = encodeURIComponent(appName);
            const url = `${window.location.origin}/sap/bc/adt/oo/classes/${appId}/source/main`;
            contentControl.setProperty(
              "content",
              `<iframe id="test" src="${url}" height="800px" width="1200px" />`,
            );

            const oModel = oSource.getModel();
            if (!oModel) break;
            const modelData = oModel.getData();
            modelData.editor_visible = false;
            modelData.source_visible = true;
            oModel.refresh();
            break;
          }
        }
      },

      // Populates the dialog model so the right editor / source area is shown
      // with the given content. `xcontent` is the rendered DOM variant that
      // can be toggled in via the "Templating" button.
      displayEditor(oEvent, content, type, xcontent = "") {
        const oModel = oEvent.getSource().getModel();
        const modelData = oModel.getData();
        modelData.editor_visible = true;
        modelData.source_visible = false;
        modelData.isTemplating = !!(
          content && content.includes("xmlns:template")
        );
        modelData.value = content;
        modelData.previousValue = content;
        modelData.xContent = xcontent;
        modelData.type = type;
        oModel.refresh();
      },

      onTemplatingPress(oEvent) {
        const oSource = oEvent.getSource();
        const oModel = oSource.getModel();
        const modelData = oModel.getData();
        // Toggle between the original (previousValue) and the rendered DOM
        // (xContent) representation.
        if (oSource.getPressed()) {
          modelData.value = modelData.xContent;
        } else {
          modelData.value = modelData.previousValue;
        }
        oModel.refresh();
      },

      onClose() {
        this.close();
      },

      async show() {
        // Guard against double-clicks while the fragment is still loading.
        if (this._showPending) return;
        this._showPending = true;
        try {
          if (!this.oDialog) {
            this.oDialog = await Fragment.load({
              name: "z2ui5.cc.DebugTool",
              controller: this,
            });
          }
          // If the user closed the app while the fragment was loading we
          // must throw the freshly created dialog away.
          if (this.isDestroyed && this.isDestroyed()) {
            if (this.oDialog) this.oDialog.destroy();
            this.oDialog = null;
            return;
          }

          const value = toJson(z2ui5.responseData);
          const oData = {
            type: "json",
            source_visible: false,
            editor_visible: true,
            value: value,
            xContent: "",
            previousValue: value,
            isTemplating: false,
            templatingSource: false,
            activeNest1: !!(
              z2ui5.oViewNest &&
              z2ui5.oViewNest.mProperties &&
              z2ui5.oViewNest.mProperties.viewContent
            ),
            activeNest2: !!(
              z2ui5.oViewNest2 &&
              z2ui5.oViewNest2.mProperties &&
              z2ui5.oViewNest2.mProperties.viewContent
            ),
            activePopup: !!(
              z2ui5.oResponse &&
              z2ui5.oResponse.PARAMS &&
              z2ui5.oResponse.PARAMS.S_POPUP &&
              z2ui5.oResponse.PARAMS.S_POPUP.XML
            ),
            activePopover: !!(
              z2ui5.oResponse &&
              z2ui5.oResponse.PARAMS &&
              z2ui5.oResponse.PARAMS.S_POPOVER &&
              z2ui5.oResponse.PARAMS.S_POPOVER.XML
            ),
          };

          const oModel = new JSONModel(oData);
          const oDialog = this.oDialog;
          oDialog.addStyleClass("dbg-ltr");
          oDialog.setModel(oModel);
          oDialog.open();
        } catch (e) {
          logError("DebugTool.show failed", e);
        } finally {
          this._showPending = false;
        }
      },

      close() {
        if (!this.oDialog) return;
        const oDialog = this.oDialog;
        this.oDialog = null;
        oDialog.close();
        oDialog.destroy();
      },

      toggle() {
        if (this.oDialog) {
          this.close();
        } else {
          this.show();
        }
      },

      // The control itself renders nothing - it just provides the dialog API.
      renderer: { apiVersion: 2, render() {} },
    });
  },
);
