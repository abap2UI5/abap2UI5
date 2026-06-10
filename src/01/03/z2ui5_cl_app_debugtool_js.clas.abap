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
             `  [` && |\n| &&
             `    "sap/ui/core/Control",` && |\n| &&
             `    "sap/ui/core/Fragment",` && |\n| &&
             `    "sap/ui/model/json/JSONModel",` && |\n| &&
             `    "z2ui5/cc/Util",` && |\n| &&
             `  ],` && |\n| &&
             `  (Control, Fragment, JSONModel, Util) => {` && |\n| &&
             `    "use strict";` && |\n| &&
             `` && |\n| &&
             `    // Fragment id under which the debug dialog's controls are registered;` && |\n| &&
             `    // used to resolve controls by their id instead of by content position.` && |\n| &&
             `    const FRAGMENT_ID = "z2ui5DebugTool";` && |\n| &&
             `` && |\n| &&
             `    // Pretty-print any value (object, array, primitive) as indented JSON.` && |\n| &&
             `    // ``null`` is used as a fallback so undefined values still produce output.` && |\n| &&
             `    function toJson(val) {` && |\n| &&
             `      const safe = val === undefined ? null : val;` && |\n| &&
             `      return JSON.stringify(safe, null, 3);` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // XSL stylesheet used by prettifyXml to reindent any XML string.` && |\n| &&
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
             `    // The XSLT processor and (de)serializers are expensive to construct, so` && |\n| &&
             `    // we keep them as module-level singletons.` && |\n| &&
             `    const _xmlSerializer = new XMLSerializer();` && |\n| &&
             `    const _domParser = new DOMParser();` && |\n| &&
             `    let _xsltProcessor = null;` && |\n| &&
             `` && |\n| &&
             `    function getXsltProcessor() {` && |\n| &&
             `      if (_xsltProcessor) return _xsltProcessor;` && |\n| &&
             `      const xsltDoc = _domParser.parseFromString(` && |\n| &&
             `        PRETTIFY_XSL,` && |\n| &&
             `        "application/xml",` && |\n| &&
             `      );` && |\n| &&
             `      _xsltProcessor = new XSLTProcessor();` && |\n| &&
             `      _xsltProcessor.importStylesheet(xsltDoc);` && |\n| &&
             `      return _xsltProcessor;` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    return Control.extend("z2ui5.cc.DebugTool", {` && |\n| &&
             `      // Reformat an XML string with indentation. If anything goes wrong the` && |\n| &&
             `      // original input is returned unchanged - the debug tool must never` && |\n| &&
             `      // crash the host app.` && |\n| &&
             `      prettifyXml(sourceXml) {` && |\n| &&
             `        if (!sourceXml) return "";` && |\n| &&
             `        try {` && |\n| &&
             `          const xmlDoc = _domParser.parseFromString(` && |\n| &&
             `            sourceXml,` && |\n| &&
             `            "application/xml",` && |\n| &&
             `          );` && |\n| &&
             `          const resultDoc = getXsltProcessor().transformToDocument(xmlDoc);` && |\n| &&
             `          if (!resultDoc) return sourceXml;` && |\n| &&
             `          const resultXml = _xmlSerializer.serializeToString(resultDoc);` && |\n| &&
             `          // The serializer escapes < and > inside text nodes; undo this so` && |\n| &&
             `          // the output is browseable XML again.` && |\n| &&
             `          return resultXml.replace(/&gt;|&lt;/g, (m) =>` && |\n| &&
             `            m === "&gt;" ? ">" : "<",` && |\n| &&
             `          );` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          return sourceXml;` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      // Called when the user picks an entry in the dropdown of the debug` && |\n| &&
             `      // dialog. Each case shows a different piece of internal state.` && |\n| &&
             `      onItemSelect(oEvent) {` && |\n| &&
             `        const oSource = oEvent.getSource();` && |\n| &&
             `        const selItem = oSource.getSelectedKey();` && |\n| &&
             `        const oView = z2ui5.oView;` && |\n| &&
             `        const oResponse = z2ui5.oResponse;` && |\n| &&
             `` && |\n| &&
             `        // Cache a bound version of displayEditor so we don't recreate the` && |\n| &&
             `        // bound function on every call.` && |\n| &&
             `        if (!this._displayEditorBound) {` && |\n| &&
             `          this._displayEditorBound = this.displayEditor.bind(this);` && |\n| &&
             `        }` && |\n| &&
             `        const displayEditor = this._displayEditorBound;` && |\n| &&
             `        const prettifyXml = this.prettifyXml;` && |\n| &&
             `` && |\n| &&
             `        switch (selItem) {` && |\n| &&
             `          case "CONFIG":` && |\n| &&
             `            displayEditor(oEvent, toJson(z2ui5.oConfig), "json");` && |\n| &&
             `            break;` && |\n| &&
             `` && |\n| &&
             `          case "MODEL": {` && |\n| &&
             `            const data =` && |\n| &&
             `              oView && oView.getModel() && oView.getModel().getData();` && |\n| &&
             `            displayEditor(oEvent, toJson(data), "json");` && |\n| &&
             `            break;` && |\n| &&
             `          }` && |\n| &&
             `` && |\n| &&
             `          case "VIEW": {` && |\n| &&
             `            // Prefer the actual viewContent string; fall back to the XML` && |\n| &&
             `            // that arrived in the last server response.` && |\n| &&
             `            const viewContent =` && |\n| &&
             `              (oView && oView.mProperties && oView.mProperties.viewContent) ||` && |\n| &&
             `              (z2ui5.responseData &&` && |\n| &&
             `                z2ui5.responseData.S_FRONT &&` && |\n| &&
             `                z2ui5.responseData.S_FRONT.PARAMS &&` && |\n| &&
             `                z2ui5.responseData.S_FRONT.PARAMS.S_VIEW &&` && |\n| &&
             `                z2ui5.responseData.S_FRONT.PARAMS.S_VIEW.XML);` && |\n| &&
             `            const rendered =` && |\n| &&
             `              oView && oView._xContent && oView._xContent.outerHTML;` && |\n| &&
             `            displayEditor(` && |\n| &&
             `              oEvent,` && |\n| &&
             `              prettifyXml(viewContent),` && |\n| &&
             `              "xml",` && |\n| &&
             `              prettifyXml(rendered),` && |\n| &&
             `            );` && |\n| &&
             `            break;` && |\n| &&
             `          }` && |\n| &&
             `` && |\n| &&
             `          case "PLAIN":` && |\n| &&
             `            displayEditor(oEvent, toJson(z2ui5.responseData), "json");` && |\n| &&
             `            break;` && |\n| &&
             `` && |\n| &&
             `          case "REQUEST":` && |\n| &&
             `            displayEditor(oEvent, toJson(z2ui5.oBody), "json");` && |\n| &&
             `            break;` && |\n| &&
             `` && |\n| &&
             `          case "POPUP": {` && |\n| &&
             `            const xml =` && |\n| &&
             `              oResponse &&` && |\n| &&
             `              oResponse.PARAMS &&` && |\n| &&
             `              oResponse.PARAMS.S_POPUP &&` && |\n| &&
             `              oResponse.PARAMS.S_POPUP.XML;` && |\n| &&
             `            displayEditor(oEvent, prettifyXml(xml), "xml");` && |\n| &&
             `            break;` && |\n| &&
             `          }` && |\n| &&
             `` && |\n| &&
             `          case "POPUP_MODEL": {` && |\n| &&
             `            const data =` && |\n| &&
             `              z2ui5.oViewPopup &&` && |\n| &&
             `              z2ui5.oViewPopup.getModel() &&` && |\n| &&
             `              z2ui5.oViewPopup.getModel().getData();` && |\n| &&
             `            displayEditor(oEvent, toJson(data), "json");` && |\n| &&
             `            break;` && |\n| &&
             `          }` && |\n| &&
             `` && |\n| &&
             `          case "POPOVER": {` && |\n| &&
             `            const xml =` && |\n| &&
             `              oResponse &&` && |\n| &&
             `              oResponse.PARAMS &&` && |\n| &&
             `              oResponse.PARAMS.S_POPOVER &&` && |\n| &&
             `              oResponse.PARAMS.S_POPOVER.XML;` && |\n| &&
             `            displayEditor(oEvent, prettifyXml(xml), "xml");` && |\n| &&
             `            break;` && |\n| &&
             `          }` && |\n| &&
             `` && |\n| &&
             `          case "POPOVER_MODEL": {` && |\n| &&
             `            const data =` && |\n| &&
             `              z2ui5.oViewPopover &&` && |\n| &&
             `              z2ui5.oViewPopover.getModel() &&` && |\n| &&
             `              z2ui5.oViewPopover.getModel().getData();` && |\n| &&
             `            displayEditor(oEvent, toJson(data), "json");` && |\n| &&
             `            break;` && |\n| &&
             `          }` && |\n| &&
             `` && |\n| &&
             `          case "NEST1": {` && |\n| &&
             `            const nest = z2ui5.oViewNest;` && |\n| &&
             `            const xml =` && |\n| &&
             `              nest && nest.mProperties && nest.mProperties.viewContent;` && |\n| &&
             `            const rendered = nest && nest._xContent && nest._xContent.outerHTML;` && |\n| &&
             `            displayEditor(` && |\n| &&
             `              oEvent,` && |\n| &&
             `              prettifyXml(xml),` && |\n| &&
             `              "xml",` && |\n| &&
             `              prettifyXml(rendered),` && |\n| &&
             `            );` && |\n| &&
             `            break;` && |\n| &&
             `          }` && |\n| &&
             `` && |\n| &&
             `          case "NEST1_MODEL": {` && |\n| &&
             `            const data =` && |\n| &&
             `              z2ui5.oViewNest &&` && |\n| &&
             `              z2ui5.oViewNest.getModel() &&` && |\n| &&
             `              z2ui5.oViewNest.getModel().getData();` && |\n| &&
             `            displayEditor(oEvent, toJson(data), "json");` && |\n| &&
             `            break;` && |\n| &&
             `          }` && |\n| &&
             `` && |\n| &&
             `          case "NEST2": {` && |\n| &&
             `            const nest = z2ui5.oViewNest2;` && |\n| &&
             `            const xml =` && |\n| &&
             `              nest && nest.mProperties && nest.mProperties.viewContent;` && |\n| &&
             `            const rendered = nest && nest._xContent && nest._xContent.outerHTML;` && |\n| &&
             `            displayEditor(` && |\n| &&
             `              oEvent,` && |\n| &&
             `              prettifyXml(xml),` && |\n| &&
             `              "xml",` && |\n| &&
             `              prettifyXml(rendered),` && |\n| &&
             `            );` && |\n| &&
             `            break;` && |\n| &&
             `          }` && |\n| &&
             `` && |\n| &&
             `          case "NEST2_MODEL": {` && |\n| &&
             `            const data =` && |\n| &&
             `              z2ui5.oViewNest2 &&` && |\n| &&
             `              z2ui5.oViewNest2.getModel() &&` && |\n| &&
             `              z2ui5.oViewNest2.getModel().getData();` && |\n| &&
             `            displayEditor(oEvent, toJson(data), "json");` && |\n| &&
             `            break;` && |\n| &&
             `          }` && |\n| &&
             `` && |\n| &&
             `          case "SOURCE": {` && |\n| &&
             `            // Show the ABAP source of the running app inside an iframe.` && |\n| &&
             `            const contentControl = Fragment.byId(FRAGMENT_ID, "sourceHtml");` && |\n| &&
             `            if (!contentControl) break;` && |\n| &&
             `` && |\n| &&
             `            const appName =` && |\n| &&
             `              (z2ui5.responseData &&` && |\n| &&
             `                z2ui5.responseData.S_FRONT &&` && |\n| &&
             `                z2ui5.responseData.S_FRONT.APP) ||` && |\n| &&
             `              "";` && |\n| &&
             `            const appId = encodeURIComponent(appName);` && |\n| &&
             `            const url = ``${window.location.origin}/sap/bc/adt/oo/classes/${appId}/source/main``;` && |\n| &&
             `            contentControl.setProperty(` && |\n| &&
             `              "content",` && |\n| &&
             `              ``<iframe id="test" src="${url}" height="800px" width="1200px" />``,` && |\n| &&
             `            );` && |\n| &&
             `` && |\n| &&
             `            const oModel = oSource.getModel();` && |\n| &&
             `            if (!oModel) break;` && |\n| &&
             `            const modelData = oModel.getData();` && |\n| &&
             `            modelData.editor_visible = false;` && |\n| &&
             `            modelData.source_visible = true;` && |\n| &&
             `            oModel.refresh();` && |\n| &&
             `            break;` && |\n| &&
             `          }` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      // Populates the dialog model so the right editor / source area is shown` && |\n| &&
             `      // with the given content. ``xcontent`` is the rendered DOM variant that` && |\n| &&
             `      // can be toggled in via the "Templating" button.` && |\n| &&
             `      displayEditor(oEvent, content, type, xcontent = "") {` && |\n| &&
             `        const oModel = oEvent.getSource().getModel();` && |\n| &&
             `        const modelData = oModel.getData();` && |\n| &&
             `        modelData.editor_visible = true;` && |\n| &&
             `        modelData.source_visible = false;` && |\n| &&
             `        modelData.isTemplating = !!(` && |\n| &&
             `          content && content.includes("xmlns:template")` && |\n| &&
             `        );` && |\n| &&
             `        modelData.value = content;` && |\n| &&
             `        modelData.previousValue = content;` && |\n| &&
             `        modelData.xContent = xcontent;` && |\n| &&
             `        modelData.type = type;` && |\n| &&
             `        oModel.refresh();` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      onTemplatingPress(oEvent) {` && |\n| &&
             `        const oSource = oEvent.getSource();` && |\n| &&
             `        const oModel = oSource.getModel();` && |\n| &&
             `        const modelData = oModel.getData();` && |\n| &&
             `        // Toggle between the original (previousValue) and the rendered DOM` && |\n| &&
             `        // (xContent) representation.` && |\n| &&
             `        if (oSource.getPressed()) {` && |\n| &&
             `          modelData.value = modelData.xContent;` && |\n| &&
             `        } else {` && |\n| &&
             `          modelData.value = modelData.previousValue;` && |\n| &&
             `        }` && |\n| &&
             `        oModel.refresh();` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      onClose() {` && |\n| &&
             `        this.close();` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      async show() {` && |\n| &&
             `        // Guard against double-clicks while the fragment is still loading.` && |\n| &&
             `        if (this._showPending) return;` && |\n| &&
             `        this._showPending = true;` && |\n| &&
             `        try {` && |\n| &&
             `          if (!this.oDialog) {` && |\n| &&
             `            this.oDialog = await Fragment.load({` && |\n| &&
             `              name: "z2ui5.cc.DebugTool",` && |\n| &&
             `              controller: this,` && |\n| &&
             `              id: FRAGMENT_ID,` && |\n| &&
             `            });` && |\n| &&
             `          }` && |\n| &&
             `          // If the user closed the app while the fragment was loading we` && |\n| &&
             `          // must throw the freshly created dialog away.` && |\n| &&
             `          if (Util.isDestroyed(this)) {` && |\n| &&
             `            if (this.oDialog) this.oDialog.destroy();` && |\n| &&
             `            this.oDialog = null;` && |\n| &&
             `            return;` && |\n| &&
             `          }` && |\n| &&
             `` && |\n| &&
             `          const value = toJson(z2ui5.responseData);` && |\n| &&
             `          const oData = {` && |\n| &&
             `            type: "json",` && |\n| &&
             `            source_visible: false,` && |\n| &&
             `            editor_visible: true,` && |\n| &&
             `            value: value,` && |\n| &&
             `            xContent: "",` && |\n| &&
             `            previousValue: value,` && |\n| &&
             `            isTemplating: false,` && |\n| &&
             `            templatingSource: false,` && |\n| &&
             `            activeNest1: !!(` && |\n| &&
             `              z2ui5.oViewNest &&` && |\n| &&
             `              z2ui5.oViewNest.mProperties &&` && |\n| &&
             `              z2ui5.oViewNest.mProperties.viewContent` && |\n| &&
             `            ),` && |\n| &&
             `            activeNest2: !!(` && |\n| &&
             `              z2ui5.oViewNest2 &&` && |\n| &&
             `              z2ui5.oViewNest2.mProperties &&` && |\n| &&
             `              z2ui5.oViewNest2.mProperties.viewContent` && |\n| &&
             `            ),` && |\n| &&
             `            activePopup: !!(` && |\n| &&
             `              z2ui5.oResponse &&` && |\n| &&
             `              z2ui5.oResponse.PARAMS &&` && |\n| &&
             `              z2ui5.oResponse.PARAMS.S_POPUP &&` && |\n| &&
             `              z2ui5.oResponse.PARAMS.S_POPUP.XML` && |\n| &&
             `            ),` && |\n| &&
             `            activePopover: !!(` && |\n| &&
             `              z2ui5.oResponse &&` && |\n| &&
             `              z2ui5.oResponse.PARAMS &&` && |\n| &&
             `              z2ui5.oResponse.PARAMS.S_POPOVER &&` && |\n| &&
             `              z2ui5.oResponse.PARAMS.S_POPOVER.XML` && |\n| &&
             `            ),` && |\n| &&
             `          };` && |\n| &&
             `` && |\n| &&
             `          const oModel = new JSONModel(oData);` && |\n| &&
             `          const oDialog = this.oDialog;` && |\n| &&
             `          oDialog.addStyleClass("dbg-ltr");` && |\n| &&
             `          oDialog.setModel(oModel);` && |\n| &&
             `          oDialog.open();` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          Util.logError("DebugTool.show failed", e);` && |\n| &&
             `        } finally {` && |\n| &&
             `          this._showPending = false;` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      close() {` && |\n| &&
             `        if (!this.oDialog) return;` && |\n| &&
             `        const oDialog = this.oDialog;` && |\n| &&
             `        this.oDialog = null;` && |\n| &&
             `        oDialog.close();` && |\n| &&
             `        oDialog.destroy();` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      toggle() {` && |\n| &&
             `        if (this.oDialog) {` && |\n| &&
             `          this.close();` && |\n| &&
             `        } else {` && |\n| &&
             `          this.show();` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      // The control itself renders nothing - it just provides the dialog API.` && |\n| &&
             `      renderer: { apiVersion: 2, render() {} },` && |\n| &&
             `    });` && |\n| &&
             `  },` && |\n| &&
             `);` && |\n| &&
             `` && |\n| &&
              ``.

  ENDMETHOD.

ENDCLASS.
