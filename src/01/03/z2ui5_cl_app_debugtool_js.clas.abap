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
             `    "z2ui5/core/Lib",` && |\n| &&
             `    "z2ui5/core/ViewSlots",` && |\n| &&
             `    "z2ui5/core/AppState",` && |\n| &&
             `  ],` && |\n| &&
             `  (Control, Fragment, JSONModel, Lib, ViewSlots, AppState) => {` && |\n| &&
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
             `      try {` && |\n| &&
             `        return JSON.stringify(safe, null, 3);` && |\n| &&
             `      } catch {` && |\n| &&
             `        // e.g. circular references in ComponentData - the debug tool must` && |\n| &&
             `        // never crash the host app, so degrade to the plain string form.` && |\n| &&
             `        return String(safe);` && |\n| &&
             `      }` && |\n| &&
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
             `    // Helpers to pull the various pieces of state shown in the dialog.` && |\n| &&
             `    function getModelJson(view) {` && |\n| &&
             `      const model = view?.getModel();` && |\n| &&
             `      return model?.getData();` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function getViewContent(view) {` && |\n| &&
             `      // Private member access (debug tool only): XMLView keeps the raw XML` && |\n| &&
             `      // string as a pseudo property in mProperties, but does not declare it` && |\n| &&
             `      // in its metadata - getProperty("viewContent") therefore throws and` && |\n| &&
             `      // would abort the whole tab selection. Read the plain object instead.` && |\n| &&
             `      return view?.mProperties?.viewContent;` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function getRenderedContent(view) {` && |\n| &&
             `      // Private member access (debug tool only): _xContent holds the view` && |\n| &&
             `      // XML after XML templating ran; there is no public equivalent.` && |\n| &&
             `      return view?._xContent?.outerHTML;` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function getResponseXml(key) {` && |\n| &&
             `      const params = AppState.state.oResponse?.PARAMS;` && |\n| &&
             `      const slot = params?.[key];` && |\n| &&
             `      return slot?.XML;` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // Preload the sap.ui.codeeditor modules used by the fragment. On older` && |\n| &&
             `    // UI5 releases (e.g. 1.71) Fragment.load still processes the XML with` && |\n| &&
             `    // the sync strategy, so an unloaded CodeEditor would be fetched via` && |\n| &&
             `    // synchronous XHR and executed with eval - which a Content-Security-` && |\n| &&
             `    // Policy without 'unsafe-eval' blocks. Requiring the modules` && |\n| &&
             `    // asynchronously up front makes the sync lookup a cache hit.` && |\n| &&
             `    function preloadCodeEditor() {` && |\n| &&
             `      return new Promise((resolve) => {` && |\n| &&
             `        sap.ui.require(` && |\n| &&
             `          ["sap/ui/codeeditor/library", "sap/ui/codeeditor/CodeEditor"],` && |\n| &&
             `          () => resolve(),` && |\n| &&
             `          // On failure continue anyway and let Fragment.load surface the` && |\n| &&
             `          // real error.` && |\n| &&
             `          () => resolve(),` && |\n| &&
             `        );` && |\n| &&
             `      });` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // What each dropdown entry shows: either a JSON source or an XML source` && |\n| &&
             `    // (the latter optionally with the rendered DOM for the templating` && |\n| &&
             `    // toggle). The "SOURCE" entry is handled separately in onItemSelect.` && |\n| &&
             `    const jsonSources = {` && |\n| &&
             `      CONFIG: () => AppState.getGlobal("oConfig"),` && |\n| &&
             `      MODEL: () => getModelJson(ViewSlots.getView("MAIN")),` && |\n| &&
             `      PLAIN: () => AppState.state.responseData,` && |\n| &&
             `      REQUEST: () => AppState.state.oBody,` && |\n| &&
             `      POPUP_MODEL: () => getModelJson(ViewSlots.getView("POPUP")),` && |\n| &&
             `      POPOVER_MODEL: () => getModelJson(ViewSlots.getView("POPOVER")),` && |\n| &&
             `      NEST1_MODEL: () => getModelJson(ViewSlots.getView("NEST")),` && |\n| &&
             `      NEST2_MODEL: () => getModelJson(ViewSlots.getView("NEST2")),` && |\n| &&
             `    };` && |\n| &&
             `` && |\n| &&
             `    const xmlSources = {` && |\n| &&
             `      // Prefer the actual viewContent string; fall back to the XML that` && |\n| &&
             `      // arrived in the last server response.` && |\n| &&
             `      VIEW: () => ({` && |\n| &&
             `        xml:` && |\n| &&
             `          getViewContent(ViewSlots.getView("MAIN")) || getResponseXml("S_VIEW"),` && |\n| &&
             `        rendered: getRenderedContent(ViewSlots.getView("MAIN")),` && |\n| &&
             `      }),` && |\n| &&
             `      POPUP: () => ({ xml: getResponseXml("S_POPUP") }),` && |\n| &&
             `      POPOVER: () => ({ xml: getResponseXml("S_POPOVER") }),` && |\n| &&
             `      NEST1: () => ({` && |\n| &&
             `        xml: getViewContent(ViewSlots.getView("NEST")),` && |\n| &&
             `        rendered: getRenderedContent(ViewSlots.getView("NEST")),` && |\n| &&
             `      }),` && |\n| &&
             `      NEST2: () => ({` && |\n| &&
             `        xml: getViewContent(ViewSlots.getView("NEST2")),` && |\n| &&
             `        rendered: getRenderedContent(ViewSlots.getView("NEST2")),` && |\n| &&
             `      }),` && |\n| &&
             `    };` && |\n| &&
             `` && |\n| &&
             `    return Control.extend("z2ui5.core.DebugTool", {` && |\n| &&
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
             `          return resultXml.replace(/&gt;|&lt;/g, (match) =>` && |\n| &&
             `            match === "&gt;" ? ">" : "<",` && |\n| &&
             `          );` && |\n| &&
             `        } catch {` && |\n| &&
             `          return sourceXml;` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      // Called when the user picks an entry in the dropdown of the debug` && |\n| &&
             `      // dialog. The content shown per entry is defined declaratively in` && |\n| &&
             `      // jsonSources / xmlSources above.` && |\n| &&
             `      onItemSelect(oEvent) {` && |\n| &&
             `        const selItem = oEvent.getSource().getSelectedKey();` && |\n| &&
             `` && |\n| &&
             `        if (jsonSources[selItem]) {` && |\n| &&
             `          this.displayEditor(oEvent, toJson(jsonSources[selItem]()), "json");` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `` && |\n| &&
             `        if (xmlSources[selItem]) {` && |\n| &&
             `          const { xml, rendered } = xmlSources[selItem]();` && |\n| &&
             `          this.displayEditor(` && |\n| &&
             `            oEvent,` && |\n| &&
             `            this.prettifyXml(xml),` && |\n| &&
             `            "xml",` && |\n| &&
             `            this.prettifyXml(rendered),` && |\n| &&
             `          );` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `` && |\n| &&
             `        if (selItem === "SOURCE") this.showAbapSource(oEvent);` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      // Show the ABAP source of the running app inside an iframe.` && |\n| &&
             `      showAbapSource(oEvent) {` && |\n| &&
             `        const contentControl = Fragment.byId(FRAGMENT_ID, "sourceHtml");` && |\n| &&
             `        if (!contentControl) return;` && |\n| &&
             `` && |\n| &&
             `        const sFront = AppState.state.responseData?.S_FRONT;` && |\n| &&
             `        const appName = sFront?.APP || "";` && |\n| &&
             `        const appId = encodeURIComponent(appName);` && |\n| &&
             `        const url = ``${window.location.origin}/sap/bc/adt/oo/classes/${appId}/source/main``;` && |\n| &&
             `        contentControl.setProperty(` && |\n| &&
             `          "content",` && |\n| &&
             `          ``<iframe id="test" src="${url}" height="800px" width="1200px" />``,` && |\n| &&
             `        );` && |\n| &&
             `` && |\n| &&
             `        const oModel = oEvent.getSource().getModel();` && |\n| &&
             `        if (!oModel) return;` && |\n| &&
             `        const modelData = oModel.getData();` && |\n| &&
             `        modelData.editor_visible = false;` && |\n| &&
             `        modelData.source_visible = true;` && |\n| &&
             `        oModel.refresh();` && |\n| &&
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
             `        modelData.isTemplating = Boolean(content?.includes("xmlns:template"));` && |\n| &&
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
             `        modelData.value = oSource.getPressed()` && |\n| &&
             `          ? modelData.xContent` && |\n| &&
             `          : modelData.previousValue;` && |\n| &&
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
             `            await preloadCodeEditor();` && |\n| &&
             `            this.oDialog = await Fragment.load({` && |\n| &&
             `              name: "z2ui5.core.DebugTool",` && |\n| &&
             `              controller: this,` && |\n| &&
             `              id: FRAGMENT_ID,` && |\n| &&
             `            });` && |\n| &&
             `          }` && |\n| &&
             `          // If the user closed the app while the fragment was loading we` && |\n| &&
             `          // must throw the freshly created dialog away.` && |\n| &&
             `          if (Lib.isDestroyed(this)) {` && |\n| &&
             `            if (this.oDialog) this.oDialog.destroy();` && |\n| &&
             `            this.oDialog = null;` && |\n| &&
             `            return;` && |\n| &&
             `          }` && |\n| &&
             `` && |\n| &&
             `          const value = toJson(AppState.state.responseData);` && |\n| &&
             `          const oData = {` && |\n| &&
             `            type: "json",` && |\n| &&
             `            source_visible: false,` && |\n| &&
             `            editor_visible: true,` && |\n| &&
             `            value: value,` && |\n| &&
             `            xContent: "",` && |\n| &&
             `            previousValue: value,` && |\n| &&
             `            isTemplating: false,` && |\n| &&
             `            templatingSource: false,` && |\n| &&
             `            activeNest1: Boolean(getViewContent(ViewSlots.getView("NEST"))),` && |\n| &&
             `            activeNest2: Boolean(getViewContent(ViewSlots.getView("NEST2"))),` && |\n| &&
             `            activePopup: Boolean(getResponseXml("S_POPUP")),` && |\n| &&
             `            activePopover: Boolean(getResponseXml("S_POPOVER")),` && |\n| &&
             `          };` && |\n| &&
             `` && |\n| &&
             `          const oModel = new JSONModel(oData);` && |\n| &&
             `          const oDialog = this.oDialog;` && |\n| &&
             `          oDialog.addStyleClass("dbg-ltr");` && |\n| &&
             `          oDialog.setModel(oModel);` && |\n| &&
             `          oDialog.open();` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          Lib.logError("DebugTool.show failed", e);` && |\n| &&
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
             `      // The dialog is not an aggregation of this control, so destroy() alone` && |\n| &&
             `      // would leave it (and its fragment controls) alive - clean it up when` && |\n| &&
             `      // the control is destroyed (Component.exit).` && |\n| &&
             `      exit() {` && |\n| &&
             `        this.close();` && |\n| &&
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
