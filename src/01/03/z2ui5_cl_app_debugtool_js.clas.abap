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
             `    "z2ui5/core/ErrorView",` && |\n| &&
             `  ],` && |\n| &&
             `  (Control, Fragment, JSONModel, Lib, ViewSlots, AppState, ErrorView) => {` && |\n| &&
             `    "use strict";` && |\n| &&
             `` && |\n| &&
             `    // Fragment id under which the debug dialog's controls are registered;` && |\n| &&
             `    // used to resolve controls by their id instead of by content position.` && |\n| &&
             `    const FRAGMENT_ID = "z2ui5DebugTool";` && |\n| &&
             `` && |\n| &&
             `    // toJson() pretty-prints with this many spaces per nesting level, so a` && |\n| &&
             `    // line's leading-space count divided by it gives that line's JSON depth.` && |\n| &&
             `    const INDENT_UNIT = 3;` && |\n| &&
             `` && |\n| &&
             `    // The System tab shows the whole (deeply nested) z2ui5 global; open only` && |\n| &&
             `    // the first two levels so it is readable - the rest can be unfolded by` && |\n| &&
             `    // hand in the editor.` && |\n| &&
             `    const SYSTEM_OPEN_LEVELS = 2;` && |\n| &&
             `` && |\n| &&
             `    // JSON nesting depth of a pretty-printed line, read from its indentation.` && |\n| &&
             `    function indentLevel(line, unit) {` && |\n| &&
             `      return Math.floor(/^ */.exec(line)[0].length / unit);` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // Fold every foldable block in the ACE edit session that sits at or below` && |\n| &&
             `    // ``keepLevels`` nesting levels, leaving the outer levels open. Uses only the` && |\n| &&
             `    // public EditSession folding API (unfold / getFoldWidget /` && |\n| &&
             `    // getFoldWidgetRange / addFold), so it works with any CodeEditor build; a` && |\n| &&
             `    // block's depth is read from its line indentation. Skipping to the folded` && |\n| &&
             `    // block's end row keeps us from descending into (already hidden) children.` && |\n| &&
             `    function foldSessionToLevel(session, keepLevels, unit) {` && |\n| &&
             `      session.unfold();` && |\n| &&
             `      const rowCount = session.getLength();` && |\n| &&
             `      for (let row = 0; row < rowCount; row++) {` && |\n| &&
             `        if (session.getFoldWidget(row) !== "start") continue;` && |\n| &&
             `        if (indentLevel(session.getLine(row) || "", unit) < keepLevels)` && |\n| &&
             `          continue;` && |\n| &&
             `        const range = session.getFoldWidgetRange(row);` && |\n| &&
             `        if (range && range.isMultiLine()) {` && |\n| &&
             `          session.addFold("...", range);` && |\n| &&
             `          row = range.end.row;` && |\n| &&
             `        }` && |\n| &&
             `      }` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // Pretty-print any value (object, array, primitive) as indented JSON.` && |\n| &&
             `    // ``null`` is used as a fallback so undefined values still produce output.` && |\n| &&
             `    // A replacer drops circular references (the z2ui5 global can hold them,` && |\n| &&
             `    // e.g. via ComponentData) so the output stays useful JSON instead of` && |\n| &&
             `    // throwing and degrading to a bare "[object Object]".` && |\n| &&
             `    function toJson(val) {` && |\n| &&
             `      const safe = val === undefined ? null : val;` && |\n| &&
             `      const seen = new WeakSet();` && |\n| &&
             `      try {` && |\n| &&
             `        return JSON.stringify(` && |\n| &&
             `          safe,` && |\n| &&
             `          (key, value) => {` && |\n| &&
             `            if (typeof value === "object" && value !== null) {` && |\n| &&
             `              if (seen.has(value)) return "[Circular]";` && |\n| &&
             `              seen.add(value);` && |\n| &&
             `            }` && |\n| &&
             `            return value;` && |\n| &&
             `          },` && |\n| &&
             `          3,` && |\n| &&
             `        );` && |\n| &&
             `      } catch {` && |\n| &&
             `        // The debug tool must never crash the host app, so degrade to the` && |\n| &&
             `        // plain string form if serialization still fails.` && |\n| &&
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
             `    // Minimal text dump of the shared error log (the entries Lib.logError` && |\n| &&
             `    // pushes to AppState.state.errors): one "<ts>  <message>" line per entry,` && |\n| &&
             `    // oldest first. Empty log yields a short placeholder.` && |\n| &&
             `    function formatErrorLog() {` && |\n| &&
             `      const errors = AppState.state.errors || [];` && |\n| &&
             `      if (!errors.length) return "(log is empty)";` && |\n| &&
             `      return errors.map((e) => ``${e.ts}  ${e.message}``).join("\n");` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // The last fatal error the ErrorView overlay showed (title + full text),` && |\n| &&
             `    // so the Error tab reproduces the overlay's content. Empty when the app` && |\n| &&
             `    // has not hit a fatal error this session.` && |\n| &&
             `    function formatLastError() {` && |\n| &&
             `      const err = AppState.state.lastError;` && |\n| &&
             `      if (!err) return "(no fatal error captured this session)";` && |\n| &&
             `      return err.title ? ``${err.title}\n\n${err.text}`` : err.text;` && |\n| &&
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
             `      // The whole public z2ui5 global facade (oConfig, url, checkLocal,` && |\n| &&
             `      // Util, app-registered members, ...). Read directly here on purpose:` && |\n| &&
             `      // this is the debug inspector, whose job is to surface the live global` && |\n| &&
             `      // as-is - functions drop out under JSON.stringify, which is fine.` && |\n| &&
             `      // ui5lint-disable-next-line no-project-globals -- see reason above` && |\n| &&
             `      SYSTEM: () => window.z2ui5,` && |\n| &&
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
             `      // dialog - resolve the model + key and render that tab.` && |\n| &&
             `      onItemSelect(oEvent) {` && |\n| &&
             `        this.renderTab(` && |\n| &&
             `          oEvent.getSource().getSelectedKey(),` && |\n| &&
             `          oEvent.getSource().getModel(),` && |\n| &&
             `        );` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      // Render one tab's content into the dialog model. Shared by the user's` && |\n| &&
             `      // tab selection (onItemSelect) and show(initialTab), which opens the` && |\n| &&
             `      // dialog directly on a given tab (e.g. the error popup's Details jumps` && |\n| &&
             `      // to "ERROR"). The content per entry is defined declaratively in` && |\n| &&
             `      // jsonSources / xmlSources above.` && |\n| &&
             `      renderTab(selItem, oModel) {` && |\n| &&
             `        if (jsonSources[selItem]) {` && |\n| &&
             `          this.displayEditor(oModel, toJson(jsonSources[selItem]()), "json");` && |\n| &&
             `          if (selItem === "SYSTEM") this.foldSystemTab();` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `` && |\n| &&
             `        if (xmlSources[selItem]) {` && |\n| &&
             `          const { xml, rendered } = xmlSources[selItem]();` && |\n| &&
             `          this.displayEditor(` && |\n| &&
             `            oModel,` && |\n| &&
             `            this.prettifyXml(xml),` && |\n| &&
             `            "xml",` && |\n| &&
             `            this.prettifyXml(rendered),` && |\n| &&
             `          );` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `` && |\n| &&
             `        if (selItem === "LOG") {` && |\n| &&
             `          this.displayEditor(oModel, formatErrorLog(), "text");` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `` && |\n| &&
             `        if (selItem === "ERROR") {` && |\n| &&
             `          this.showError(oModel);` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `` && |\n| &&
             `        if (selItem === "SOURCE") this.showAbapSource(oModel);` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      // Show the last fatal error (the ErrorView overlay's content). The` && |\n| &&
             `      // Retry/Restart/Logout actions live in the dialog footer (always` && |\n| &&
             `      // present); refresh hasRetry so the footer's Retry button shows only` && |\n| &&
             `      // when this error carried a retry action.` && |\n| &&
             `      showError(oModel) {` && |\n| &&
             `        this.displayEditor(oModel, formatLastError(), "text");` && |\n| &&
             `        const modelData = oModel.getData();` && |\n| &&
             `        modelData.hasRetry =` && |\n| &&
             `          typeof AppState.state.lastError?.onRetry === "function";` && |\n| &&
             `        oModel.refresh();` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      // The Error tab's buttons mirror the ErrorView overlay: re-run the` && |\n| &&
             `      // captured request, hard-reload, or log out (reusing ErrorView's own` && |\n| &&
             `      // logout so the launchpad/fallback logic stays in one place).` && |\n| &&
             `      onErrorRetry() {` && |\n| &&
             `        const onRetry = AppState.state.lastError?.onRetry;` && |\n| &&
             `        // Retrying re-runs the request, so don't bounce back to the error popup.` && |\n| &&
             `        this.reopenErrorOnClose = false;` && |\n| &&
             `        this.close();` && |\n| &&
             `        if (typeof onRetry === "function") onRetry();` && |\n| &&
             `      },` && |\n| &&
             `      onErrorRestart() {` && |\n| &&
             `        window.location.reload();` && |\n| &&
             `      },` && |\n| &&
             `      onErrorLogout() {` && |\n| &&
             `        ErrorView.handleLogout();` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      // The CodeEditor's underlying ACE editor, or null if it does not exist` && |\n| &&
             `      // yet (created on the CodeEditor's first render) or the build exposes no` && |\n| &&
             `      // internal instance.` && |\n| &&
             `      getEditorInstance() {` && |\n| &&
             `        const ce = Fragment.byId(FRAGMENT_ID, "debugEditor");` && |\n| &&
             `        return ce && typeof ce.getInternalEditorInstance === "function"` && |\n| &&
             `          ? ce.getInternalEditorInstance()` && |\n| &&
             `          : null;` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      // Fold the System tab's JSON down to the first SYSTEM_OPEN_LEVELS levels.` && |\n| &&
             `      // The ACE editor is created lazily on the CodeEditor's first render, so` && |\n| &&
             `      // on the very first open we retry briefly until it exists. Best-effort:` && |\n| &&
             `      // any failure leaves the tab fully expanded rather than breaking the` && |\n| &&
             `      // debug tool.` && |\n| &&
             `      foldSystemTab(triesLeft = 10) {` && |\n| &&
             `        let editor = null;` && |\n| &&
             `        try {` && |\n| &&
             `          editor = this.getEditorInstance();` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          Lib.logError("DebugTool System fold failed", e);` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `        if (editor) {` && |\n| &&
             `          try {` && |\n| &&
             `            const session = editor.getSession && editor.getSession();` && |\n| &&
             `            if (session && typeof session.getFoldWidget === "function") {` && |\n| &&
             `              foldSessionToLevel(session, SYSTEM_OPEN_LEVELS, INDENT_UNIT);` && |\n| &&
             `            }` && |\n| &&
             `          } catch (e) {` && |\n| &&
             `            Lib.logError("DebugTool System fold failed", e);` && |\n| &&
             `          }` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `        if (triesLeft > 0) {` && |\n| &&
             `          setTimeout(() => this.foldSystemTab(triesLeft - 1), 30);` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      // Show the ABAP source of the running app inside an iframe.` && |\n| &&
             `      showAbapSource(oModel) {` && |\n| &&
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
             `      displayEditor(oModel, content, type, xcontent = "") {` && |\n| &&
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
             `` && |\n|.
    result = result &&
             `      // sap.m.Dialog closes on Escape without routing through onClose; handle` && |\n| &&
             `      // it ourselves (reject the default, run our close) so Escape behaves` && |\n| &&
             `      // exactly like the Close button - including re-showing the error popup.` && |\n| &&
             `      onEscape(oPromise) {` && |\n| &&
             `        oPromise.reject();` && |\n| &&
             `        this.close();` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      // Open the debug dialog. ``initialTab`` (a tab key, e.g. "ERROR") opens` && |\n| &&
             `      // it directly on that tab - used by the error popup's Details action;` && |\n| &&
             `      // defaults to the response tab.` && |\n| &&
             `      async show(initialTab) {` && |\n| &&
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
             `          const selectedTab =` && |\n| &&
             `            typeof initialTab === "string" ? initialTab : "PLAIN";` && |\n| &&
             `          const value = toJson(AppState.state.responseData);` && |\n| &&
             `          const oData = {` && |\n| &&
             `            selectedTab: selectedTab,` && |\n| &&
             `            type: "json",` && |\n| &&
             `            source_visible: false,` && |\n| &&
             `            editor_visible: true,` && |\n| &&
             `            hasError: Boolean(AppState.state.lastError),` && |\n| &&
             `            hasRetry: typeof AppState.state.lastError?.onRetry === "function",` && |\n| &&
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
             `          // Render the requested tab's content (the default "PLAIN" already` && |\n| &&
             `          // matches the JSON response seeded above, so only re-render when a` && |\n| &&
             `          // specific tab was asked for).` && |\n| &&
             `          if (initialTab && selectedTab !== "PLAIN") {` && |\n| &&
             `            this.renderTab(selectedTab, oModel);` && |\n| &&
             `          }` && |\n| &&
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
             `        // When the dialog was opened from the error popup's Details action,` && |\n| &&
             `        // closing it (Close or Escape) re-shows that popup so the user never` && |\n| &&
             `        // ends up on the dismissed, broken app.` && |\n| &&
             `        const reopenError = this.reopenErrorOnClose;` && |\n| &&
             `        this.reopenErrorOnClose = false;` && |\n| &&
             `        oDialog.close();` && |\n| &&
             `        oDialog.destroy();` && |\n| &&
             `        if (reopenError) ErrorView.reopenErrorDialog();` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      // The dialog is not an aggregation of this control, so destroy() alone` && |\n| &&
             `      // would leave it (and its fragment controls) alive - clean it up when` && |\n| &&
             `      // the control is destroyed (Component.exit). Never re-show the error` && |\n| &&
             `      // popup while the app itself is being torn down.` && |\n| &&
             `      exit() {` && |\n| &&
             `        this.reopenErrorOnClose = false;` && |\n| &&
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
