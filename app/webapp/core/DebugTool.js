sap.ui.define(
  [
    "sap/ui/core/Control",
    "sap/ui/core/Fragment",
    "sap/ui/model/json/JSONModel",
    "z2ui5/core/Lib",
    "z2ui5/core/ViewSlots",
    "z2ui5/core/AppState",
  ],
  (Control, Fragment, JSONModel, Lib, ViewSlots, AppState) => {
    "use strict";

    // Fragment id under which the debug dialog's controls are registered;
    // used to resolve controls by their id instead of by content position.
    const FRAGMENT_ID = "z2ui5DebugTool";

    // Pretty-print any value (object, array, primitive) as indented JSON.
    // `null` is used as a fallback so undefined values still produce output.
    function toJson(val) {
      const safe = val === undefined ? null : val;
      try {
        return JSON.stringify(safe, null, 3);
      } catch {
        // e.g. circular references in ComponentData - the debug tool must
        // never crash the host app, so degrade to the plain string form.
        return String(safe);
      }
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

    // Helpers to pull the various pieces of state shown in the dialog.
    function getModelJson(view) {
      const model = view?.getModel();
      return model?.getData();
    }

    function getViewContent(view) {
      return view?.getProperty("viewContent");
    }

    function getRenderedContent(view) {
      // Private member access (debug tool only): _xContent holds the view
      // XML after XML templating ran; there is no public equivalent.
      return view?._xContent?.outerHTML;
    }

    function getResponseXml(key) {
      const params = AppState.state.oResponse?.PARAMS;
      const slot = params?.[key];
      return slot?.XML;
    }

    // Preload the sap.ui.codeeditor modules used by the fragment. On older
    // UI5 releases (e.g. 1.71) Fragment.load still processes the XML with
    // the sync strategy, so an unloaded CodeEditor would be fetched via
    // synchronous XHR and executed with eval - which a Content-Security-
    // Policy without 'unsafe-eval' blocks. Requiring the modules
    // asynchronously up front makes the sync lookup a cache hit.
    function preloadCodeEditor() {
      return new Promise((resolve) => {
        sap.ui.require(
          ["sap/ui/codeeditor/library", "sap/ui/codeeditor/CodeEditor"],
          () => resolve(),
          // On failure continue anyway and let Fragment.load surface the
          // real error.
          () => resolve(),
        );
      });
    }

    // What each dropdown entry shows: either a JSON source or an XML source
    // (the latter optionally with the rendered DOM for the templating
    // toggle). The "SOURCE" entry is handled separately in onItemSelect.
    const jsonSources = {
      CONFIG: () => AppState.getGlobal("oConfig"),
      MODEL: () => getModelJson(ViewSlots.getView("MAIN")),
      PLAIN: () => AppState.state.responseData,
      REQUEST: () => AppState.state.oBody,
      POPUP_MODEL: () => getModelJson(ViewSlots.getView("POPUP")),
      POPOVER_MODEL: () => getModelJson(ViewSlots.getView("POPOVER")),
      NEST1_MODEL: () => getModelJson(ViewSlots.getView("NEST")),
      NEST2_MODEL: () => getModelJson(ViewSlots.getView("NEST2")),
    };

    const xmlSources = {
      // Prefer the actual viewContent string; fall back to the XML that
      // arrived in the last server response.
      VIEW: () => ({
        xml:
          getViewContent(ViewSlots.getView("MAIN")) || getResponseXml("S_VIEW"),
        rendered: getRenderedContent(ViewSlots.getView("MAIN")),
      }),
      POPUP: () => ({ xml: getResponseXml("S_POPUP") }),
      POPOVER: () => ({ xml: getResponseXml("S_POPOVER") }),
      NEST1: () => ({
        xml: getViewContent(ViewSlots.getView("NEST")),
        rendered: getRenderedContent(ViewSlots.getView("NEST")),
      }),
      NEST2: () => ({
        xml: getViewContent(ViewSlots.getView("NEST2")),
        rendered: getRenderedContent(ViewSlots.getView("NEST2")),
      }),
    };

    return Control.extend("z2ui5.core.DebugTool", {
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
          return resultXml.replace(/&gt;|&lt;/g, (match) =>
            match === "&gt;" ? ">" : "<",
          );
        } catch {
          return sourceXml;
        }
      },

      // Called when the user picks an entry in the dropdown of the debug
      // dialog. The content shown per entry is defined declaratively in
      // jsonSources / xmlSources above.
      onItemSelect(oEvent) {
        const selItem = oEvent.getSource().getSelectedKey();

        if (jsonSources[selItem]) {
          this.displayEditor(oEvent, toJson(jsonSources[selItem]()), "json");
          return;
        }

        if (xmlSources[selItem]) {
          const { xml, rendered } = xmlSources[selItem]();
          this.displayEditor(
            oEvent,
            this.prettifyXml(xml),
            "xml",
            this.prettifyXml(rendered),
          );
          return;
        }

        if (selItem === "SOURCE") this.showAbapSource(oEvent);
      },

      // Show the ABAP source of the running app inside an iframe.
      showAbapSource(oEvent) {
        const contentControl = Fragment.byId(FRAGMENT_ID, "sourceHtml");
        if (!contentControl) return;

        const sFront = AppState.state.responseData?.S_FRONT;
        const appName = sFront?.APP || "";
        const appId = encodeURIComponent(appName);
        const url = `${window.location.origin}/sap/bc/adt/oo/classes/${appId}/source/main`;
        contentControl.setProperty(
          "content",
          `<iframe id="test" src="${url}" height="800px" width="1200px" />`,
        );

        const oModel = oEvent.getSource().getModel();
        if (!oModel) return;
        const modelData = oModel.getData();
        modelData.editor_visible = false;
        modelData.source_visible = true;
        oModel.refresh();
      },

      // Populates the dialog model so the right editor / source area is shown
      // with the given content. `xcontent` is the rendered DOM variant that
      // can be toggled in via the "Templating" button.
      displayEditor(oEvent, content, type, xcontent = "") {
        const oModel = oEvent.getSource().getModel();
        const modelData = oModel.getData();
        modelData.editor_visible = true;
        modelData.source_visible = false;
        modelData.isTemplating = Boolean(content?.includes("xmlns:template"));
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
        modelData.value = oSource.getPressed()
          ? modelData.xContent
          : modelData.previousValue;
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
            await preloadCodeEditor();
            this.oDialog = await Fragment.load({
              name: "z2ui5.core.DebugTool",
              controller: this,
              id: FRAGMENT_ID,
            });
          }
          // If the user closed the app while the fragment was loading we
          // must throw the freshly created dialog away.
          if (Lib.isDestroyed(this)) {
            if (this.oDialog) this.oDialog.destroy();
            this.oDialog = null;
            return;
          }

          const value = toJson(AppState.state.responseData);
          const oData = {
            type: "json",
            source_visible: false,
            editor_visible: true,
            value: value,
            xContent: "",
            previousValue: value,
            isTemplating: false,
            templatingSource: false,
            activeNest1: Boolean(getViewContent(ViewSlots.getView("NEST"))),
            activeNest2: Boolean(getViewContent(ViewSlots.getView("NEST2"))),
            activePopup: Boolean(getResponseXml("S_POPUP")),
            activePopover: Boolean(getResponseXml("S_POPOVER")),
          };

          const oModel = new JSONModel(oData);
          const oDialog = this.oDialog;
          oDialog.addStyleClass("dbg-ltr");
          oDialog.setModel(oModel);
          oDialog.open();
        } catch (e) {
          Lib.logError("DebugTool.show failed", e);
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

      // The dialog is not an aggregation of this control, so destroy() alone
      // would leave it (and its fragment controls) alive - clean it up when
      // the control is destroyed (Component.exit).
      exit() {
        this.close();
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
