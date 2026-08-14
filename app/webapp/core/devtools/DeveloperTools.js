sap.ui.define(
  [
    "sap/ui/core/Control",
    "sap/ui/core/Fragment",
    "sap/ui/model/json/JSONModel",
    "z2ui5/core/Lib",
    "z2ui5/core/ViewSlots",
    "z2ui5/core/AppState",
    "z2ui5/core/ErrorView",
    "z2ui5/core/devtools/Console",
    "z2ui5/core/devtools/Recorder",
    "z2ui5/core/devtools/Inspect",
    "z2ui5/core/devtools/Picker",
    "z2ui5/core/devtools/LiveEdit",
  ],
  (
    Control,
    Fragment,
    JSONModel,
    Lib,
    ViewSlots,
    AppState,
    ErrorView,
    Console,
    Recorder,
    Inspect,
    Picker,
    LiveEdit,
  ) => {
    "use strict";

    // Fragment id under which the developer tools dialog's controls are registered;
    // used to resolve controls by their id instead of by content position.
    const FRAGMENT_ID = "z2ui5DeveloperTools";

    // toJson() pretty-prints with this many spaces per nesting level.
    const INDENT_UNIT = 3;

    // Hits reported per tab by searchAllTabs. A term that matches a whole
    // model would otherwise bury the tabs that matched it once.
    const MAX_HITS_PER_TAB = 20;

    // The tab the tools were last on. Reopening on the tab you were
    // working in is what makes them usable across a debugging session -
    // landing on the response JSON every time means re-navigating after
    // every close. In sessionStorage, so it survives a reload too.
    const LAST_TAB_KEY = "z2ui5.devtools.lastTab";

    // The tab opened when nothing else is known.
    const DEFAULT_TAB = "PLAIN";

    function readLastTab() {
      try {
        return window.sessionStorage?.getItem(LAST_TAB_KEY) || "";
      } catch {
        return "";
      }
    }

    // The tabs that are not table-driven have their own branch in
    // renderTab, so they have to be listed for the validity check. Keep
    // this in step with those branches - a tab missing here is silently
    // rejected as "unknown" and reopens on the default instead.
    const STANDALONE_TABS = [
      "HISTORY",
      "DIFF",
      "SEARCH",
      "PICK",
      "ERROR",
      "SOURCE",
    ];

    function isKnownTab(tabKey) {
      if (!tabKey) return false;
      if (STANDALONE_TABS.includes(tabKey)) return true;
      return Boolean(
        jsonSources[tabKey] || xmlSources[tabKey] || textSources[tabKey],
      );
    }

    function writeLastTab(tabKey) {
      try {
        window.sessionStorage?.setItem(LAST_TAB_KEY, tabKey);
      } catch {
        // storage unavailable - the memory is then per dialog instance
      }
    }

    // Pretty-print any value (object, array, primitive) as indented JSON.
    // `null` is used as a fallback so undefined values still produce output.
    // A replacer drops circular references (the z2ui5 global can hold them,
    // e.g. via ComponentData) so the output stays useful JSON instead of
    // throwing and degrading to a bare "[object Object]".
    function toJson(val) {
      const safe = val === undefined ? null : val;
      // Track the ANCESTOR chain, not every object ever visited: a plain
      // WeakSet of all seen objects would mislabel a value referenced twice in
      // sibling branches (common in the live z2ui5 global) as "[Circular]".
      // `this` inside the replacer is the object the key belongs to, so we can
      // unwind the stack back to it before testing containment.
      const ancestors = [];
      try {
        return JSON.stringify(
          safe,
          function (key, value) {
            if (typeof value === "object" && value !== null) {
              while (
                ancestors.length > 0 &&
                ancestors[ancestors.length - 1] !== this
              ) {
                ancestors.pop();
              }
              if (ancestors.includes(value)) return "[Circular]";
              ancestors.push(value);
            }
            return value;
          },
          INDENT_UNIT,
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

    // A model tab is only worth opening when the slot's model carries DATA -
    // an app without bound attributes serves an empty object, and a greyed
    // tab says "nothing here" more clearly than rendering {}.
    function hasModelData(oView) {
      const data = getModelJson(oView);
      return Boolean(data) && Object.keys(data).length > 0;
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

    // The last fatal error the ErrorView overlay showed (title + full text),
    // so the Error tab reproduces the overlay's content. Empty when the app
    // has not hit a fatal error this session.
    function formatLastError() {
      const err = AppState.state.lastError;
      if (!err) return "(no fatal error captured this session)";
      return err.title ? `${err.title}\n\n${err.text}` : err.text;
    }

    // The view XML a slot currently holds: the live view's own viewContent
    // when UI5 kept it, else the source ViewSlots recorded when the slot was
    // filled (a fragment or a `definition`-built view keeps none).
    //
    // Read from the SLOT, never from the last response: a slot lives and dies
    // by ViewSlots.setView/destroy, and both ways of tearing one down end up
    // there - the backend's ["VIEW_SLOTS","destroy",...] action and the
    // roundtrip-free frontend close (cs_event-popup_close / popover_close,
    // which the backend formats as that very same action). Scraping the last
    // response's display action instead made the frontend close look like a
    // popup that was still open: no roundtrip happens, so the response that
    // opened it stayed the current one.
    function getSlotXml(slotKey) {
      return (
        getViewContent(ViewSlots.getView(slotKey)) ||
        ViewSlots.getViewXml(slotKey)
      );
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

    // What each tab shows: either a JSON source or an XML source
    // (the latter optionally with the rendered DOM for the templating
    // toggle). The "SOURCE" entry is handled separately in onItemSelect.
    const jsonSources = {
      MODEL: () => getModelJson(ViewSlots.getView("MAIN")),
      PLAIN: () => AppState.state.responseData,
      REQUEST: () => AppState.state.oBody,
      POPUP_MODEL: () => getModelJson(ViewSlots.getView("POPUP")),
      POPOVER_MODEL: () => getModelJson(ViewSlots.getView("POPOVER")),
      // no NEST/NEST2 model sources: the nested views inherit the MAIN
      // view's model by UI5 propagation - it would be the same data as
      // MODEL, shown twice
    };

    // Tabs whose content is a plain-text report built by one of the
    // devtools inspectors. Kept as a table for the same reason
    // jsonSources / xmlSources are: adding a tab is one entry plus one
    // IconTabFilter, never a new branch in renderTab.
    const textSources = {
      // The framework error log, the console capture and the backend
      // messages used to be three tabs; Inspect.formatLog merges them into
      // one timeline (see there).
      LOG: () => Inspect.formatLog(),
      VIEWDIFF: () => Recorder.formatViewDiff(),
      ENV: () => Inspect.formatEnvironment(),
      REGISTRY: () => Inspect.formatRegistry(),
      ACTIONS: () => Inspect.formatActions(),
      BINDINGS: () => Inspect.formatBindings(),
    };

    const xmlSources = {
      VIEW: () => ({
        xml: getSlotXml("MAIN"),
        rendered: getRenderedContent(ViewSlots.getView("MAIN")),
      }),
      POPUP: () => ({ xml: getSlotXml("POPUP") }),
      POPOVER: () => ({ xml: getSlotXml("POPOVER") }),
      NEST1: () => ({
        xml: getSlotXml("NEST"),
        rendered: getRenderedContent(ViewSlots.getView("NEST")),
      }),
      NEST2: () => ({
        xml: getSlotXml("NEST2"),
        rendered: getRenderedContent(ViewSlots.getView("NEST2")),
      }),
    };

    const DeveloperTools = Control.extend(
      "z2ui5.core.devtools.DeveloperTools",
      {
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

        // Search every tab at once and report which of them contain the term.
        // With more than twenty tabs, "where does CUSTOMER appear?" is a
        // question the dialog could not answer at all - the developer had to
        // open each tab and use the editor's own find.
        //
        // Sources are evaluated the same way the tabs render them, each
        // guarded: one throwing source may not blank the whole result.
        searchAllTabs(term) {
          const needle = String(term || "").toLowerCase();
          if (!needle) return "(enter a search term)";
          const sections = [];
          let totalHits = 0;

          const scan = (tabKey, produce) => {
            let text;
            try {
              text = produce();
            } catch {
              return;
            }
            if (text === undefined || text === null || text === "") return;
            const lines = String(text).split("\n");
            const hits = [];
            for (let i = 0; i < lines.length; i += 1) {
              if (!lines[i].toLowerCase().includes(needle)) continue;
              hits.push(`    ${String(i + 1).padStart(5)}: ${lines[i].trim()}`);
              if (hits.length >= MAX_HITS_PER_TAB) break;
            }
            if (!hits.length) return;
            totalHits += hits.length;
            sections.push(
              `  [${tabKey}]  ${hits.length}${hits.length >= MAX_HITS_PER_TAB ? "+" : ""} hit(s)`,
            );
            sections.push(...hits);
            sections.push("");
          };

          for (const key of Object.keys(jsonSources)) {
            scan(key, () => toJson(jsonSources[key]()));
          }
          for (const key of Object.keys(xmlSources)) {
            scan(key, () => this.prettifyXml(xmlSources[key]().xml));
          }
          for (const key of Object.keys(textSources)) {
            scan(key, () => textSources[key]());
          }
          scan("ERROR", formatLastError);
          scan("HISTORY", () => Recorder.formatHistory());

          const head = [
            `Search for "${term}" across every tab`,
            "",
            totalHits
              ? `${totalHits} hit(s) - the tab key is in brackets.`
              : "(no hit in any tab)",
            "",
          ];
          return head.concat(sections).join("\n");
        },

        onSearch(oEvent) {
          const oSource = oEvent.getSource();
          const oModel = oSource.getModel();
          const modelData = oModel.getData();
          modelData.searchTerm = oSource.getValue();
          modelData.selectedTab = "SEARCH";
          this.displayEditor(
            oModel,
            this.searchAllTabs(modelData.searchTerm),
            "text",
          );
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
          // The controls that belong to ONE tab live in the content area
          // rather than the footer, so they appear with their tab instead
          // of sitting there greyed out on the other twenty.
          const flags = oModel.getData();
          flags.isPickTab = selItem === "PICK";
          flags.isHistoryTab = selItem === "HISTORY";
          flags.isSearchTab = selItem === "SEARCH";
          writeLastTab(selItem);

          if (jsonSources[selItem]) {
            this.displayEditor(oModel, toJson(jsonSources[selItem]()), "json");
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
            // A view tab is editable: its XML can be rendered back into the
            // slot without a roundtrip (core/devtools/LiveEdit.js), so the
            // Apply / Reset footer buttons appear for exactly these tabs.
            const modelData = oModel.getData();
            modelData.canApply = LiveEdit.canApply(selItem);
            oModel.refresh();
            return;
          }

          // The roundtrip history and the model diff are owned end to end by
          // core/devtools/Recorder.js - this dialog only renders the text it
          // hands over.
          if (selItem === "HISTORY") {
            this.displayEditor(oModel, Recorder.formatHistory(), "text");
            return;
          }

          if (selItem === "DIFF") {
            this.displayEditor(oModel, Recorder.formatModelDiff(), "text");
            return;
          }

          // The read-only inspectors live in core/devtools/Inspect.js; the
          // dialog only decides which one to show. The picked-control report
          // is the one entry that is not derived from live state - it is the
          // result of the last pick and therefore held on the control.
          if (textSources[selItem]) {
            this.displayEditor(oModel, textSources[selItem](), "text");
            return;
          }

          if (selItem === "SEARCH") {
            this.displayEditor(
              oModel,
              this.searchAllTabs(oModel.getData().searchTerm),
              "text",
            );
            return;
          }

          if (selItem === "PICK") {
            this.displayEditor(
              oModel,
              this.pickedControlReport ||
                'No control picked yet - press "Pick Control" in the footer,' +
                  " then click any control in the app.",
              "text",
            );
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
        // whole export) and each section is capped - a value that large blanks
        // a sap.m.TextArea.
        // `abapSource` is the running app's ABAP class source, fetched
        // asynchronously by onExport (empty when it could not be retrieved).
        buildExport(abapSource) {
          // Max characters per section; long ones are truncated so the
          // popup's TextArea still renders.
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

          // First section on purpose: versions, UI5 distribution, launchpad
          // and device are what a reader of a shared report needs before
          // anything else, and asking for them is the standard first reply
          // to a bug report.
          push(
            "ENVIRONMENT",
            text(() => Inspect.formatEnvironment()),
          );
          if (AppState.state.lastError) push("ERROR", text(formatLastError));
          push(
            "LOG",
            text(() => Inspect.formatLog()),
          );
          // The roundtrip history is the timeline an error happened on, so it
          // travels with the export - it is the context a reader of a shared
          // bug report otherwise has to ask for.
          push(
            "ROUNDTRIP HISTORY",
            text(() => Recorder.formatHistory()),
          );
          if (Recorder.isRecordingPayloads()) {
            push(
              "MODEL DIFF",
              text(() => Recorder.formatModelDiff()),
            );
          }
          // The running app's ABAP class source (fetched by onExport). Placed
          // high up because it is usually the most useful context when sharing
          // an error - a reader can see the class that produced it.
          push("ABAP SOURCE", abapSource);
          push(
            "ACTIONS",
            text(() => Inspect.formatActions()),
          );
          push(
            "REGISTRY",
            text(() => Inspect.formatRegistry()),
          );
          push(
            "BINDINGS",
            text(() => Inspect.formatBindings()),
          );
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
          // one gate for both slots and both close paths: the slot holds an
          // XML for exactly as long as it is filled
          if (getSlotXml("POPUP")) {
            push(
              "POPUP",
              xml(() => xmlSources.POPUP().xml),
            );
            push(
              "POPUP MODEL",
              json(() => jsonSources.POPUP_MODEL()),
            );
          }
          if (getSlotXml("POPOVER")) {
            push(
              "POPOVER",
              xml(() => xmlSources.POPOVER().xml),
            );
            push(
              "POPOVER MODEL",
              json(() => jsonSources.POPOVER_MODEL()),
            );
          }
          // the nested views carry no model tab of their own - they inherit
          // the MAIN view's model by propagation, so only the XML is shown
          if (getSlotXml("NEST")) {
            push(
              "NEST1",
              xml(() => xmlSources.NEST1().xml),
            );
          }
          if (getSlotXml("NEST2")) {
            push(
              "NEST2",
              xml(() => xmlSources.NEST2().xml),
            );
          }
          return sections.join("\n\n") || "(nothing to export)";
        },

        // The same content as buildExport, but as a GitHub-ready issue body:
        // each section becomes a collapsed <details> block so a long report
        // stays readable in a comment, and the code fences keep XML and JSON
        // from being eaten by the markdown renderer. Pasting a report into an
        // issue is the last step of most bug reports, and doing it by hand
        // means either an unreadable wall of text or manual reformatting.
        buildMarkdown(abapSource) {
          const plain = this.buildExport(abapSource);
          const blocks = plain.split(/^===== (.+) =====$/m);
          // split() yields [preamble, title, body, title, body, ...]
          const out = ["## abap2UI5 - Developer Tools export", ""];
          for (let i = 1; i < blocks.length; i += 2) {
            const title = blocks[i];
            const body = (blocks[i + 1] || "").trim();
            if (!body) continue;
            // The environment block is what a reader needs first, so it is
            // the one section that is not collapsed.
            const open = title === "ENVIRONMENT" ? " open" : "";
            const fence = title.includes("SOURCE") ? "abap" : "text";
            out.push(`<details${open}>`);
            out.push(`<summary>${title}</summary>`);
            out.push("");
            out.push(`\`\`\`${fence}`);
            out.push(body);
            out.push("```");
            out.push("");
            out.push("</details>");
            out.push("");
          }
          return out.join("\n");
        },

        // Fetch the running app's ABAP class source via the ADT REST endpoint,
        // so the export can include the class that produced the current state.
        // Returns the raw source text, or "" when the class name is unknown or
        // the request fails (the endpoint needs an authenticated, ADT-enabled
        // session, which is not always available - the export must still work
        // without it). Never throws: the export must succeed regardless.
        async fetchAbapSource() {
          const url = this.getAbapSourceUrl();
          if (!url) return "";
          const appName = this.getAppName();
          // Cached per app class: the Source Code tab warms it, and the ADT
          // jump reads it to find the line of the current event. A second
          // fetch of the same class would be a wasted request on every open.
          if (this._abapSourceCache?.app === appName) {
            return this._abapSourceCache.source;
          }
          let source = "";
          try {
            const response = await fetch(url, {
              headers: { Accept: "text/plain" },
              credentials: "same-origin",
            });
            if (response.ok) source = await response.text();
          } catch {
            source = "";
          }
          this._abapSourceCache = { app: appName, source };
          return source;
        },

        // Show the whole export in a stretched popup with a read-through TextArea
        // (selectable for manual copy) and a one-click "Copy to Clipboard". The
        // ABAP class source is fetched first (asynchronously) so it can be part
        // of the exported / copied blob.
        async onExport() {
          let text;
          try {
            const abapSource = await this.fetchAbapSource();
            // kept for the Markdown button, which rebuilds from the same
            // content instead of fetching the class source a second time
            this._lastExportSource = abapSource;
            text = this.buildExport(abapSource);
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
                // The `buttons` aggregation, not beginButton/endButton: UI5
                // ignores those two as soon as `buttons` is filled, and the
                // download actions below make this a four-button footer.
                buttons: [
                  new Button({
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
                  // Two files, because they answer different questions: the
                  // report is what a human reads, the history JSON is what
                  // makes a bug reproducible (it carries the recorded
                  // request/response bodies when payload recording was on).
                  new Button({
                    text: "Copy as Markdown",
                    press: () => {
                      try {
                        Lib.copyToClipboard(
                          this.buildMarkdown(this._lastExportSource),
                        );
                      } catch (e) {
                        Lib.logError(
                          "DeveloperTools: markdown export failed",
                          e,
                        );
                      }
                    },
                  }),
                  new Button({
                    text: "Download Report",
                    press: () =>
                      this.downloadText(this.exportFileName("txt"), text),
                  }),
                  new Button({
                    text: "Download History (JSON)",
                    press: () =>
                      this.downloadText(
                        this.exportFileName("json"),
                        Recorder.exportJson(),
                        "application/json",
                      ),
                  }),
                  new Button({
                    text: "Close",
                    press: () => dialog.close(),
                  }),
                ],
                afterClose: () => dialog.destroy(),
              });
              dialog.open();
            },
          );
        },

        // The class name of the running app, as the backend reported it in the
        // last response. Empty before the first response arrived.
        getAppName() {
          return AppState.state.responseData?.S_FRONT?.APP || "";
        },

        // The ADT REST endpoint that renders the running app's ABAP class
        // source. Empty when the app class name is unknown (no response yet).
        getAbapSourceUrl() {
          const appName = this.getAppName();
          if (!appName) return "";
          const appId = encodeURIComponent(appName);
          return `${window.location.origin}/sap/bc/adt/oo/classes/${appId}/source/main`;
        },

        // Open the ABAP class source as a top-level document in a new browser
        // tab. The ADT REST endpoint renders it with syntax highlighting and its
        // own "Open in ABAP Development Tools" link; opening it top-level is what
        // lets that link's adt:// navigation reach the desktop ADT. From inside
        // the inline iframe below the jump never worked - browsers suppress a
        // custom-scheme navigation started in a subframe, and some systems block
        // framing the ADT endpoint entirely (X-Frame-Options), so the preview is
        // just blank there. noopener keeps the new tab from reaching back into
        // window.opener.
        // The ADT url, deep-linked at the handler of the event the last
        // roundtrip carried when that is possible: the ADT source endpoint
        // honours a "#start=<line>,<col>" anchor, and the event name is a
        // literal in the class that handles it. Needs the source in the cache
        // (the Source Code tab warms it); without it, or when the name is not
        // found, the plain class url is returned - the jump is a shortcut,
        // never a precondition.
        getAbapAdtUrl() {
          const url = this.getAbapSourceUrl();
          if (!url) return "";
          const event = AppState.state.oBody?.S_FRONT?.EVENT;
          const cache = this._abapSourceCache;
          if (!event || cache?.app !== this.getAppName() || !cache?.source) {
            return url;
          }
          const lineNumber = Inspect.findEventLine(cache.source, event);
          return lineNumber ? `${url}#start=${lineNumber},1` : url;
        },

        onOpenAbapInAdt() {
          // Stays synchronous: a window.open after an await is treated as an
          // unrequested popup and blocked.
          const url = this.getAbapAdtUrl();
          if (!url) return;
          window.open(url, "_blank", "noopener,noreferrer");
        },

        // Hand a generated text file to the browser. Used by the export
        // dialog: a copy to the clipboard is fine for a short report, but a
        // full export with payloads belongs in a file that can be attached
        // to an issue.
        downloadText(fileName, content, mimeType) {
          try {
            const blob = new Blob([content], {
              type: `${mimeType || "text/plain"};charset=utf-8`,
            });
            const url = URL.createObjectURL(blob);
            const anchor = document.createElement("a");
            anchor.href = url;
            anchor.download = fileName;
            document.body.appendChild(anchor);
            anchor.click();
            document.body.removeChild(anchor);
            // Release the object url once the download has been handed over.
            setTimeout(() => URL.revokeObjectURL(url), 0);
          } catch (e) {
            Lib.logError("DeveloperTools: download failed", e);
          }
        },

        // Stable, sortable file name stem for the generated downloads.
        exportFileName(extension) {
          const stamp = new Date().toISOString().replace(/[:.]/g, "-");
          const app = this.getAppName() || "abap2ui5";
          return `${app}_${stamp}.${extension}`;
        },

        // Show the ABAP source of the running app inside an iframe.
        showAbapSource(oModel) {
          const contentControl = Fragment.byId(FRAGMENT_ID, "sourceHtml");
          if (!contentControl) return;

          const url = this.getAbapSourceUrl();
          // setContent (not a bare setProperty) so an already rendered iframe
          // is replaced in the live DOM; a plain property set never reached
          // the DOM once the control had rendered, leaving a stale class
          // on screen after navigating to another app.
          contentControl.setContent(
            url
              ? `<iframe src="${url}" style="width:100%;height:85vh;border:none;" />`
              : "",
          );

          // Warm the source cache in the background so the ADT button can
          // deep-link at the current event's line (getAbapAdtUrl). Opening
          // this tab is the moment a developer is heading for the source, and
          // the fetch must not block the tab switch - failures are swallowed
          // by fetchAbapSource itself.
          this.fetchAbapSource();

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
          // Only the view tabs re-enable this (see renderTab) - every other
          // tab shows content that has no slot to be applied to.
          modelData.canApply = false;
          modelData.isTemplating = Boolean(content?.includes("xmlns:template"));
          // the toggle always starts on the original source for this tab
          modelData.templatingSource = false;
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

        // Tier 2 of the recorder: keeping request/response bodies is the
        // expensive half of the history, so it is opt-in and switched here.
        // Switching it OFF also drops what was already retained, so a
        // developer can free the memory again without reloading the app.
        // The current tab is re-rendered because both recorder tabs report
        // the flag's state.
        onToggleRecordPayloads(oEvent) {
          const oSource = oEvent.getSource();
          Recorder.setRecordingPayloads(oSource.getPressed());
          const oModel = oSource.getModel();
          const modelData = oModel.getData();
          modelData.recordPayloads = Recorder.isRecordingPayloads();
          oModel.refresh();
          this.renderTab(modelData.selectedTab, oModel);
        },

        // Pick a control on the screen and report what feeds it. The dialog
        // has to get out of the way first (it is modal and covers the app),
        // so it closes for the duration of the pick and reopens on the
        // picked-control tab with the result. Escape cancels and reopens on
        // the tab the user came from.
        onPickControl() {
          const previousTab = this.oDialog?.getModel()?.getData()?.selectedTab;
          this.reopenErrorOnClose = false;
          this.close();
          Picker.start((report) => {
            if (Lib.isDestroyed(this)) return;
            if (report) this.pickedControlReport = report;
            this.show(report ? "PICK" : previousTab);
          });
        },

        // Render the edited XML back into its view slot. Local preview only -
        // LiveEdit's result message says so, and it is shown in place of the
        // editor content's usual silence so the developer knows it landed.
        async onApplyXml(oEvent) {
          const oModel = oEvent.getSource().getModel();
          const modelData = oModel.getData();
          if (LiveEdit.isBusy()) {
            this.showApplyResult(oModel, "A roundtrip is running - try again.");
            return;
          }
          const result = await LiveEdit.apply(
            modelData.selectedTab,
            modelData.value,
          );
          if (Lib.isDestroyed(this)) return;
          this.showApplyResult(oModel, result);
        },

        // Put the backend's original XML back into the editor. Does not
        // re-render - press Apply for that.
        onResetXml(oEvent) {
          const oModel = oEvent.getSource().getModel();
          const modelData = oModel.getData();
          const xml = this.prettifyXml(
            LiveEdit.originalXml(modelData.selectedTab),
          );
          modelData.value = xml;
          modelData.previousValue = xml;
          modelData.applyResult = "";
          oModel.refresh();
        },

        showApplyResult(oModel, text) {
          const modelData = oModel.getData();
          modelData.applyResult = text;
          oModel.refresh();
        },

        // Put the current tab's content on the clipboard. A CodeEditor has no
        // select-all affordance of its own, so copying a report used to mean
        // dragging across thousands of lines - or going through Export, which
        // builds everything rather than the one tab being looked at.
        onCopyTab(oEvent) {
          const oSource = oEvent.getSource();
          const modelData = oSource.getModel().getData();
          Lib.copyToClipboard(modelData.value || "");
          // Confirm on the button itself and put the label back - the dialog
          // is modal, so a toast behind it would be invisible.
          const original = oSource.getText();
          oSource.setText("Copied");
          setTimeout(() => {
            if (!Lib.isDestroyed(oSource)) oSource.setText(original);
          }, 1500);
        },

        // Pop the tools open on the Console tab as soon as anything logs at
        // error level. Off by default - a modal dialog jumping up is the
        // last thing a productive user needs - but in a test system it is
        // the difference between noticing a broken roundtrip and not. The
        // setting lives in core/devtools/Console.js, which is where the
        // errors are and which both this dialog and the lifecycle facade
        // can reach without importing each other.
        onToggleOpenOnError(oEvent) {
          const oSource = oEvent.getSource();
          Console.setAlertOnError(oSource.getPressed());
          const oModel = oSource.getModel();
          oModel.getData().openOnError = Console.isAlertOnError();
          oModel.refresh();
        },

        // The help used to be a tab of its own, which put a page of prose
        // in the same row as the twenty tabs that show live state. It is
        // reached from the info icon in the footer now and opens in its
        // own dialog, so it does not take the current tab away.
        onShowHelp() {
          sap.ui.require(
            ["sap/m/Dialog", "sap/m/TextArea", "sap/m/Button"],
            (Dialog, TextArea, Button) => {
              const area = new TextArea({
                editable: false,
                width: "100%",
                rows: 25,
                growing: false,
              });
              area.setValue(Inspect.formatHelp());
              const dialog = new Dialog({
                title: "abap2UI5 - Developer Tools Help",
                stretch: true,
                content: [area],
                buttons: [
                  new Button({
                    text: "Close",
                    type: "Emphasized",
                    press: () => dialog.close(),
                  }),
                ],
                afterClose: () => dialog.destroy(),
              });
              dialog.open();
            },
          );
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
                name: "z2ui5.core.devtools.DeveloperTools",
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

            // A caller-named tab wins (the error popup's Details jumps to
            // ERROR); otherwise reopen where the developer left off. The
            // remembered key is validated: a tab that no longer exists -
            // one stored by an older version, or a typo in the URL
            // parameter - would otherwise select nothing at all.
            const remembered = readLastTab();
            const selectedTab =
              typeof initialTab === "string" && initialTab
                ? initialTab
                : isKnownTab(remembered)
                  ? remembered
                  : DEFAULT_TAB;
            const value = toJson(AppState.state.responseData);
            const oData = {
              selectedTab: selectedTab,
              // the dialog title always names the app the tools are looking at -
              // every tab below shows that app's data, and after a navigation
              // the previous app's name is the first thing that would mislead
              appName: this.getAppName(),
              type: "json",
              source_visible: false,
              editor_visible: true,
              hasError: Boolean(AppState.state.lastError),
              // Tier 2 opt-in of the roundtrip recorder; drives both the
              // footer toggle and what the two recorder tabs report.
              recordPayloads: Recorder.isRecordingPayloads(),
              // Set per tab by renderTab: only the view tabs can be applied
              // back into their slot (core/devtools/LiveEdit.js).
              canApply: false,
              applyResult: "",
              // set per tab by renderTab - the controls that belong to one
              // tab live in the content area, not in the footer
              isPickTab: false,
              isHistoryTab: false,
              isSearchTab: false,
              hasRetry: typeof AppState.state.lastError?.onRetry === "function",
              value: value,
              xContent: "",
              previousValue: value,
              isTemplating: false,
              templatingSource: false,
              activeNest1: Boolean(getSlotXml("NEST")),
              activeNest2: Boolean(getSlotXml("NEST2")),
              // Filled for as long as the slot is - the tabs appear with the
              // popup/popover and go with it, whether the backend tore it down
              // or the app closed it in the browser without a roundtrip.
              activePopup: Boolean(getSlotXml("POPUP")),
              activePopover: Boolean(getSlotXml("POPOVER")),
              // the model tabs grey out when the slot's model holds no data
              hasViewModel: hasModelData(ViewSlots.getView("MAIN")),
              hasPopupModel: hasModelData(ViewSlots.getView("POPUP")),
              hasPopoverModel: hasModelData(ViewSlots.getView("POPOVER")),
            };

            writeLastTab(selectedTab);
            const oModel = new JSONModel(oData);
            const oDialog = this.oDialog;
            oDialog.setModel(oModel);
            // Render the requested tab's content (the default "PLAIN" already
            // matches the JSON response seeded above, so only re-render when a
            // specific tab was asked for).
            if (selectedTab !== "PLAIN") {
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
      },
    );

    // The lifecycle around this control - creation, the Ctrl+F12
    // shortcut, auto open and teardown - belongs to
    // core/devtools/DevTools.js, which is the single entry point the
    // framework calls. This module is only the dialog.
    return DeveloperTools;
  },
);
