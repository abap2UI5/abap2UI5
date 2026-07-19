sap.ui.define(
  [
    "sap/ui/core/Control",
    "sap/ui/core/Fragment",
    "sap/ui/model/json/JSONModel",
    "z2ui5/core/Lib",
    "z2ui5/core/ViewSlots",
    "z2ui5/core/AppState",
    "z2ui5/core/ErrorView",
  ],
  (Control, Fragment, JSONModel, Lib, ViewSlots, AppState, ErrorView) => {
    "use strict";

    // Fragment id under which the developer tools dialog's controls are registered;
    // used to resolve controls by their id instead of by content position.
    const FRAGMENT_ID = "z2ui5DeveloperTools";

    // toJson() pretty-prints with this many spaces per nesting level, so a
    // line's leading-space count divided by it gives that line's JSON depth.
    const INDENT_UNIT = 3;

    // The System tab shows the whole (deeply nested) z2ui5 global; open only
    // the first two levels so it is readable - the rest can be unfolded by
    // hand in the editor.
    const SYSTEM_OPEN_LEVELS = 2;

    // JSON nesting depth of a pretty-printed line, read from its indentation.
    function indentLevel(line, unit) {
      return Math.floor(/^ */.exec(line)[0].length / unit);
    }

    // Fold every foldable block in the ACE edit session that sits at or below
    // `keepLevels` nesting levels, leaving the outer levels open. Uses only the
    // public EditSession folding API (unfold / getFoldWidget /
    // getFoldWidgetRange / addFold), so it works with any CodeEditor build; a
    // block's depth is read from its line indentation. Skipping to the folded
    // block's end row keeps us from descending into (already hidden) children.
    function foldSessionToLevel(session, keepLevels, unit) {
      session.unfold();
      const rowCount = session.getLength();
      for (let row = 0; row < rowCount; row++) {
        if (session.getFoldWidget(row) !== "start") continue;
        if (indentLevel(session.getLine(row) || "", unit) < keepLevels)
          continue;
        const range = session.getFoldWidgetRange(row);
        if (range && range.isMultiLine()) {
          session.addFold("...", range);
          row = range.end.row;
        }
      }
    }

    // Pretty-print any value (object, array, primitive) as indented JSON.
    // `null` is used as a fallback so undefined values still produce output.
    // A replacer drops circular references (the z2ui5 global can hold them,
    // e.g. via ComponentData) so the output stays useful JSON instead of
    // throwing and degrading to a bare "[object Object]".
    function toJson(val) {
      const safe = val === undefined ? null : val;
      const seen = new WeakSet();
      try {
        return JSON.stringify(
          safe,
          (key, value) => {
            if (typeof value === "object" && value !== null) {
              if (seen.has(value)) return "[Circular]";
              seen.add(value);
            }
            return value;
          },
          3,
        );
      } catch {
        // The developer tools must never crash the host app, so degrade to the
        // plain string form if serialization still fails.
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
      // Private member access (developer tools only): XMLView keeps the raw XML
      // string as a pseudo property in mProperties, but does not declare it
      // in its metadata - getProperty("viewContent") therefore throws and
      // would abort the whole tab selection. Read the plain object instead.
      return view?.mProperties?.viewContent;
    }

    function getRenderedContent(view) {
      // Private member access (developer tools only): _xContent holds the view
      // XML after XML templating ran; there is no public equivalent.
      return view?._xContent?.outerHTML;
    }

    // Minimal text dump of the shared error log (the entries Lib.logError
    // pushes to AppState.state.errors): one "<ts>  <message>" line per entry,
    // oldest first. Empty log yields a short placeholder.
    function formatErrorLog() {
      const errors = AppState.state.errors || [];
      if (!errors.length) return "(log is empty)";
      return errors.map((e) => `${e.ts}  ${e.message}`).join("\n");
    }

    // The last fatal error the ErrorView overlay showed (title + full text),
    // so the Error tab reproduces the overlay's content. Empty when the app
    // has not hit a fatal error this session.
    function formatLastError() {
      const err = AppState.state.lastError;
      if (!err) return "(no fatal error captured this session)";
      return err.title ? `${err.title}\n\n${err.text}` : err.text;
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
      // The whole public z2ui5 global facade (oConfig, url, checkLocal,
      // Util, app-registered members, ...). Read directly here on purpose:
      // this is the developer tools inspector, whose job is to surface the live global
      // as-is - functions drop out under JSON.stringify, which is fine.
      // ui5lint-disable-next-line no-project-globals -- see reason above
      SYSTEM: () => window.z2ui5,
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

    return Control.extend("z2ui5.core.DeveloperTools", {
      // Reformat an XML string with indentation. If anything goes wrong the
      // original input is returned unchanged - the developer tools must never
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

      // Called when the user picks an entry in the dropdown of the developer
      // tools dialog - resolve the model + key and render that tab.
      onItemSelect(oEvent) {
        this.renderTab(
          oEvent.getSource().getSelectedKey(),
          oEvent.getSource().getModel(),
        );
      },

      // Render one tab's content into the dialog model. Shared by the user's
      // tab selection (onItemSelect) and show(initialTab), which opens the
      // dialog directly on a given tab (e.g. the error popup's Details jumps
      // to "ERROR"). The content per entry is defined declaratively in
      // jsonSources / xmlSources above.
      renderTab(selItem, oModel) {
        if (jsonSources[selItem]) {
          this.displayEditor(oModel, toJson(jsonSources[selItem]()), "json");
          if (selItem === "SYSTEM") this.foldSystemTab();
          return;
        }

        if (xmlSources[selItem]) {
          const { xml, rendered } = xmlSources[selItem]();
          this.displayEditor(
            oModel,
            this.prettifyXml(xml),
            "xml",
            this.prettifyXml(rendered),
          );
          return;
        }

        if (selItem === "LOG") {
          this.displayEditor(oModel, formatErrorLog(), "text");
          return;
        }

        if (selItem === "ERROR") {
          this.showError(oModel);
          return;
        }

        if (selItem === "SOURCE") this.showAbapSource(oModel);
      },

      // Show the last fatal error (the ErrorView overlay's content). The
      // Retry/Restart/Logout actions live in the dialog footer (always
      // present); refresh hasRetry so the footer's Retry button shows only
      // when this error carried a retry action.
      showError(oModel) {
        this.displayEditor(oModel, formatLastError(), "text");
        const modelData = oModel.getData();
        modelData.hasRetry =
          typeof AppState.state.lastError?.onRetry === "function";
        oModel.refresh();
      },

      // The Error tab's buttons mirror the ErrorView overlay: re-run the
      // captured request, hard-reload, or log out (reusing ErrorView's own
      // logout so the launchpad/fallback logic stays in one place).
      onErrorRetry() {
        const onRetry = AppState.state.lastError?.onRetry;
        // Retrying re-runs the request, so don't bounce back to the error popup.
        this.reopenErrorOnClose = false;
        this.close();
        if (typeof onRetry === "function") onRetry();
      },
      onErrorRestart() {
        window.location.reload();
      },
      onErrorLogout() {
        ErrorView.handleLogout();
      },

      // Collect the content of every developer-tools tab into one plain-text
      // blob so it can be copied elsewhere in one go. XML tabs are
      // pretty-printed, JSON tabs serialized; empty / inactive sections are
      // skipped. Every source is guarded (a throwing one can never blank the
      // whole export) and each section is capped, because the SYSTEM global can
      // serialize to several MB - a value that large blanks a sap.m.TextArea.
      buildExport() {
        // Max characters per section; long ones (mainly SYSTEM) are truncated
        // so the popup's TextArea still renders.
        const MAX_SECTION = 100000;
        const sections = [];
        const push = (title, content) => {
          if (!content) return;
          let body = String(content);
          if (body.length > MAX_SECTION) {
            body = `${body.slice(0, MAX_SECTION)}\n\n... [truncated ${body.length - MAX_SECTION} more characters - open the ${title} tab for the full content]`;
          }
          sections.push(`===== ${title} =====\n${body}`);
        };
        const json = (fn) => {
          try {
            const v = fn();
            return v === undefined || v === null ? "" : toJson(v);
          } catch {
            return "";
          }
        };
        const xml = (fn) => {
          try {
            return this.prettifyXml(fn());
          } catch {
            return "";
          }
        };
        const text = (fn) => {
          try {
            return fn() || "";
          } catch {
            return "";
          }
        };

        if (AppState.state.lastError) push("ERROR", text(formatLastError));
        push("LOG", text(formatErrorLog));
        push(
          "RESPONSE",
          json(() => jsonSources.PLAIN()),
        );
        push(
          "PREVIOUS REQUEST",
          json(() => jsonSources.REQUEST()),
        );
        push(
          "VIEW",
          xml(() => xmlSources.VIEW().xml),
        );
        push(
          "VIEW MODEL",
          json(() => jsonSources.MODEL()),
        );
        if (getResponseXml("S_POPUP")) {
          push(
            "POPUP",
            xml(() => xmlSources.POPUP().xml),
          );
          push(
            "POPUP MODEL",
            json(() => jsonSources.POPUP_MODEL()),
          );
        }
        if (getResponseXml("S_POPOVER")) {
          push(
            "POPOVER",
            xml(() => xmlSources.POPOVER().xml),
          );
          push(
            "POPOVER MODEL",
            json(() => jsonSources.POPOVER_MODEL()),
          );
        }
        if (getViewContent(ViewSlots.getView("NEST"))) {
          push(
            "NEST1",
            xml(() => xmlSources.NEST1().xml),
          );
          push(
            "NEST1 MODEL",
            json(() => jsonSources.NEST1_MODEL()),
          );
        }
        if (getViewContent(ViewSlots.getView("NEST2"))) {
          push(
            "NEST2",
            xml(() => xmlSources.NEST2().xml),
          );
          push(
            "NEST2 MODEL",
            json(() => jsonSources.NEST2_MODEL()),
          );
        }
        // SYSTEM (the whole z2ui5 global) is the largest by far - keep it last
        // so the useful sections come first even after truncation.
        push(
          "SYSTEM",
          json(() => jsonSources.SYSTEM()),
        );

        return sections.join("\n\n") || "(nothing to export)";
      },

      // Show the whole export in a stretched popup with a read-through TextArea
      // (selectable for manual copy) and a one-click "Copy to Clipboard".
      onExport() {
        let text;
        try {
          text = this.buildExport();
        } catch (e) {
          text = `(export failed: ${e?.message || e})`;
        }
        sap.ui.require(
          ["sap/m/Dialog", "sap/m/TextArea", "sap/m/Button"],
          (Dialog, TextArea, Button) => {
            const area = new TextArea({
              editable: true,
              width: "100%",
              rows: 25,
              growing: false,
            });
            // Set the value explicitly (not only via the constructor) so a
            // large payload is applied reliably after the control exists.
            area.setValue(text);
            const dialog = new Dialog({
              title: "abap2UI5 - Developer Tools Export",
              stretch: true,
              content: [area],
              beginButton: new Button({
                text: "Copy to Clipboard",
                type: "Emphasized",
                press: () => {
                  // navigator.clipboard needs a secure (HTTPS) context, which
                  // an on-premise ABAP system often is not. Select the
                  // TextArea and use the classic execCommand("copy") first
                  // (works over plain HTTP), then fall back to the async API.
                  const ta = area.getFocusDomRef();
                  let copied = false;
                  if (ta) {
                    ta.focus();
                    ta.select();
                    ta.setSelectionRange(0, (ta.value || "").length);
                    try {
                      copied = document.execCommand("copy");
                    } catch {
                      copied = false;
                    }
                  }
                  if (!copied && navigator.clipboard?.writeText) {
                    navigator.clipboard.writeText(text).catch(() => {});
                  }
                },
              }),
              endButton: new Button({
                text: "Close",
                press: () => dialog.close(),
              }),
              afterClose: () => dialog.destroy(),
            });
            dialog.addStyleClass("dbg-ltr");
            dialog.open();
          },
        );
      },

      // The CodeEditor's underlying ACE editor, or null if it does not exist
      // yet (created on the CodeEditor's first render) or the build exposes no
      // internal instance.
      getEditorInstance() {
        const ce = Fragment.byId(FRAGMENT_ID, "developerToolsEditor");
        return ce && typeof ce.getInternalEditorInstance === "function"
          ? ce.getInternalEditorInstance()
          : null;
      },

      // Fold the System tab's JSON down to the first SYSTEM_OPEN_LEVELS levels.
      // The ACE editor is created lazily on the CodeEditor's first render, so
      // on the very first open we retry briefly until it exists. Best-effort:
      // any failure leaves the tab fully expanded rather than breaking the
      // developer tools.
      foldSystemTab(triesLeft = 10) {
        let editor = null;
        try {
          editor = this.getEditorInstance();
        } catch (e) {
          Lib.logError("DeveloperTools System fold failed", e);
          return;
        }
        if (editor) {
          try {
            const session = editor.getSession && editor.getSession();
            if (session && typeof session.getFoldWidget === "function") {
              foldSessionToLevel(session, SYSTEM_OPEN_LEVELS, INDENT_UNIT);
            }
          } catch (e) {
            Lib.logError("DeveloperTools System fold failed", e);
          }
          return;
        }
        if (triesLeft > 0) {
          setTimeout(() => this.foldSystemTab(triesLeft - 1), 30);
        }
      },

      // Show the ABAP source of the running app inside an iframe.
      showAbapSource(oModel) {
        const contentControl = Fragment.byId(FRAGMENT_ID, "sourceHtml");
        if (!contentControl) return;

        const sFront = AppState.state.responseData?.S_FRONT;
        const appName = sFront?.APP || "";
        const appId = encodeURIComponent(appName);
        const url = `${window.location.origin}/sap/bc/adt/oo/classes/${appId}/source/main`;
        // setContent (not a bare setProperty) so an already rendered iframe
        // is replaced in the live DOM; a plain property set never reached
        // the DOM once the control had rendered, leaving a stale class
        // on screen after navigating to another app.
        contentControl.setContent(
          `<iframe src="${url}" style="width:100%;height:85vh;border:none;" />`,
        );

        if (!oModel) return;
        const modelData = oModel.getData();
        modelData.editor_visible = false;
        modelData.source_visible = true;
        oModel.refresh();
      },

      // Populates the dialog model so the right editor / source area is shown
      // with the given content. `xcontent` is the rendered DOM variant that
      // can be toggled in via the "Templating" button.
      displayEditor(oModel, content, type, xcontent = "") {
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

      // sap.m.Dialog closes on Escape without routing through onClose; handle
      // it ourselves (reject the default, run our close) so Escape behaves
      // exactly like the Close button - including re-showing the error popup.
      onEscape(oPromise) {
        oPromise.reject();
        this.close();
      },

      // Open the developer tools dialog. `initialTab` (a tab key, e.g. "ERROR") opens
      // it directly on that tab - used by the error popup's Details action;
      // defaults to the response tab.
      async show(initialTab) {
        // Guard against double-clicks while the fragment is still loading.
        if (this._showPending) return;
        this._showPending = true;
        try {
          if (!this.oDialog) {
            await preloadCodeEditor();
            this.oDialog = await Fragment.load({
              name: "z2ui5.core.DeveloperTools",
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

          const selectedTab =
            typeof initialTab === "string" ? initialTab : "PLAIN";
          const value = toJson(AppState.state.responseData);
          const oData = {
            selectedTab: selectedTab,
            type: "json",
            source_visible: false,
            editor_visible: true,
            hasError: Boolean(AppState.state.lastError),
            hasRetry: typeof AppState.state.lastError?.onRetry === "function",
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
          // Render the requested tab's content (the default "PLAIN" already
          // matches the JSON response seeded above, so only re-render when a
          // specific tab was asked for).
          if (initialTab && selectedTab !== "PLAIN") {
            this.renderTab(selectedTab, oModel);
          }
          oDialog.open();
        } catch (e) {
          Lib.logError("DeveloperTools.show failed", e);
        } finally {
          this._showPending = false;
        }
      },

      close() {
        if (!this.oDialog || !this.oDialog.isOpen()) return;
        // When the dialog was opened from the error popup's Details action,
        // closing it (Close or Escape) re-shows that popup so the user never
        // ends up on the dismissed, broken app.
        const reopenError = this.reopenErrorOnClose;
        this.reopenErrorOnClose = false;
        // Keep the dialog (and its fragment controls, e.g. the CodeEditor)
        // and reuse it on the next show(). Destroying and re-loading the
        // fragment each time raced the close animation on older UI5 (1.71):
        // the CodeEditor's fragment-scoped id survived long enough that the
        // reload threw "adding element with duplicate id
        // 'z2ui5DeveloperTools--developerToolsEditor'". The instance is
        // destroyed once in exit() when the control itself goes away.
        this.oDialog.close();
        if (reopenError) ErrorView.reopenErrorDialog();
      },

      // The dialog is not an aggregation of this control, so destroy() alone
      // would leave it (and its fragment controls) alive - clean it up when
      // the control is destroyed (Component.exit). Never re-show the error
      // popup while the app itself is being torn down.
      exit() {
        this.reopenErrorOnClose = false;
        if (this.oDialog) {
          this.oDialog.close();
          this.oDialog.destroy();
          this.oDialog = null;
        }
      },

      toggle() {
        if (this.oDialog && this.oDialog.isOpen()) {
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
