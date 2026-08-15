// The developer tools dialog.
//
// Only the dialog: which group is selected, which sub-view inside it,
// and getting the right string into the editor. What a tab IS lives in
// devtools/Tabs.js, the report in devtools/Report.js, the ABAP class in
// devtools/AbapSource.js, and the lifecycle (Ctrl+F12, auto open,
// teardown) in devtools/DevTools.js.
//
// The structure this renders is five groups, not twenty-two flat tabs:
//
//   Overview     which app, which roundtrip, is anything broken
//   Problems     Error / Log
//   Roundtrips   History / Request / Response / Actions / the two diffs
//   View & Data  slot x aspect, plus the picked control
//   System       Environment / Registry / ABAP Source
//
// The tab KEYS underneath are unchanged, because they are a
// compatibility surface: "?z2ui5-devtools=HISTORY" and the remembered
// last tab in sessionStorage both store them.
sap.ui.define(
  [
    "sap/ui/core/Control",
    "sap/ui/core/Fragment",
    "sap/ui/model/json/JSONModel",
    "z2ui5/core/Lib",
    "z2ui5/core/AppState",
    "z2ui5/core/ErrorView",
    "z2ui5/devtools/AbapSource",
    "z2ui5/devtools/Console",
    "z2ui5/devtools/Inspect",
    "z2ui5/devtools/LiveEdit",
    "z2ui5/devtools/Picker",
    "z2ui5/devtools/Recorder",
    "z2ui5/devtools/Report",
    "z2ui5/devtools/Tabs",
  ],
  (
    Control,
    Fragment,
    JSONModel,
    Lib,
    AppState,
    ErrorView,
    AbapSource,
    Console,
    Inspect,
    LiveEdit,
    Picker,
    Recorder,
    Report,
    Tabs,
  ) => {
    "use strict";

    // Fragment id under which the developer tools dialog's controls are
    // registered; used to resolve controls by their id instead of by
    // content position.
    const FRAGMENT_ID = "z2ui5DeveloperTools";

    // The sub-view the tools were last on. Reopening where you were
    // working is what makes them usable across a debugging session -
    // landing on the same place every time means re-navigating after
    // every close. In sessionStorage, so it survives a reload too.
    const LAST_TAB_KEY = "z2ui5.devtools.lastTab";

    // Where the tools open when nothing else is known. Used to be the raw
    // response JSON, which answers no question anybody arrives with.
    const DEFAULT_TAB = "OVERVIEW";

    // How long a one-line result (Apply, Report a Bug) stays under the
    // action bar before it clears itself.
    const STATUS_MS = 6000;

    function readLastTab() {
      try {
        return window.sessionStorage?.getItem(LAST_TAB_KEY) || "";
      } catch {
        return "";
      }
    }

    function writeLastTab(tabKey) {
      try {
        window.sessionStorage?.setItem(LAST_TAB_KEY, tabKey);
      } catch {
        // storage unavailable - the memory is then per dialog instance
      }
    }

    // The sub-view to open on. A remembered or requested key that no
    // longer resolves - stored by an older version, a typo in the URL
    // parameter, or a popup that has since closed - falls back to its
    // group's first available view, and only then to the default.
    function resolveTab(tabKey) {
      if (Tabs.isEnabled(Tabs.get(tabKey))) return tabKey;
      if (Tabs.isKnown(tabKey)) {
        const sibling = Tabs.firstTabOf(Tabs.groupOf(tabKey));
        if (sibling) return sibling;
      }
      return DEFAULT_TAB;
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

    const DeveloperTools = Control.extend("z2ui5.devtools.DeveloperTools", {
      // ----------------------------------------------------------------
      // Navigation
      // ----------------------------------------------------------------

      // The single place a sub-view becomes the shown one. Every entry
      // point routes through here: the group tabs, the two selectors,
      // show(initialTab), the pick that returns, the payload toggle.
      renderTab(tabKey, oModel) {
        const key = resolveTab(tabKey);
        const tab = Tabs.get(key);
        const data = oModel.getData();

        data.selectedTab = key;
        data.selectedGroup = tab.group;
        // Leaving the search result behind is what picking any view
        // means - the result is not a place you can navigate within.
        data.searchResult = false;
        writeLastTab(key);

        // The two selectors of View & Data. The slot list is rebuilt on
        // every selection because a popup opens and closes underneath
        // the tools while they are open.
        const slots = Tabs.enabledSlots().map((slot) => ({
          key: slot.key,
          text: slot.label,
        }));
        data.slots = slots;
        data.selectedSlot = tab.slot || data.selectedSlot || "MAIN";
        // The picked control is in this group but is not about a slot,
        // so it hides the slot selector rather than pointing it at an
        // unrelated slot.
        data.showSlotBar = Boolean(tab.slot) && slots.length > 1;

        const views = (
          tab.slot ? Tabs.aspectsOfSlot(tab.slot) : Tabs.enabledTabs(tab.group)
        ).map((entry) => ({ key: entry.key, text: entry.label }));
        // In View & Data the picked control is reachable from every
        // slot's aspect bar - it belongs to the group, not to a slot.
        if (tab.group === "VIEWDATA" && tab.slot) {
          const pick = Tabs.get("PICK");
          views.push({ key: pick.key, text: pick.label });
        }
        data.views = views;
        data.showViewBar = views.length > 1;

        // Group flags drive the action bar. Plain booleans, never an
        // expression binding in the fragment (AGENTS.md rule 13).
        data.isOverview = tab.group === "OVERVIEW";
        data.isRoundtrips = tab.group === "ROUNDTRIPS";
        data.isViewData = tab.group === "VIEWDATA";
        data.isErrorView = key === "ERROR";
        data.isSourceView = key === "SOURCE";
        data.hasRetry =
          key === "ERROR" &&
          typeof AppState.state.lastError?.onRetry === "function";
        data.recordPayloads = Recorder.isRecordingPayloads();
        data.openOnError = Console.isAlertOnError();

        if (tab.kind === "source") {
          this.showAbapSource(oModel);
          return;
        }

        this.displayEditor(
          oModel,
          Tabs.render(key),
          tab.kind,
          Tabs.renderTemplated(key),
        );
        // A view tab is editable: its XML can be rendered back into the
        // slot without a roundtrip (devtools/LiveEdit.js).
        data.canApply = LiveEdit.canApply(key);
        oModel.refresh();
      },

      onGroupSelect(oEvent) {
        const oModel = oEvent.getSource().getModel();
        const groupKey = oEvent.getSource().getSelectedKey();
        this.renderTab(Tabs.firstTabOf(groupKey) || DEFAULT_TAB, oModel);
      },

      onViewSelect(oEvent) {
        const oSource = oEvent.getSource();
        this.renderTab(oSource.getSelectedKey(), oSource.getModel());
      },

      // Switching the slot keeps the aspect where that is possible -
      // going from Main/Bindings to a popup should land on the popup's
      // bindings, not throw the user back to its XML. Tabs.tabFor falls
      // back when the new slot has no such aspect.
      onSlotSelect(oEvent) {
        const oSource = oEvent.getSource();
        const oModel = oSource.getModel();
        const aspect = Tabs.get(oModel.getData().selectedTab)?.aspect;
        this.renderTab(Tabs.tabFor(oSource.getSelectedKey(), aspect), oModel);
      },

      // ----------------------------------------------------------------
      // Search
      // ----------------------------------------------------------------

      onSearch(oEvent) {
        const oSource = oEvent.getSource();
        const oModel = oSource.getModel();
        const data = oModel.getData();
        data.searchTerm = oSource.getValue();
        this.displayEditor(oModel, Tabs.search(data.searchTerm), "text");
        // Set after displayEditor, which clears the per-view flags.
        data.searchResult = true;
        data.canApply = false;
        oModel.refresh();
      },

      // ----------------------------------------------------------------
      // Content
      // ----------------------------------------------------------------

      // Populates the dialog model so the right editor / source area is
      // shown with the given content. `xcontent` is the post-templating
      // variant that the "After Templating" toggle switches to.
      displayEditor(oModel, content, type, xcontent = "") {
        const data = oModel.getData();
        data.editor_visible = true;
        data.source_visible = false;
        // Only the view tabs re-enable this (see renderTab) - every other
        // view shows content that has no slot to be applied to.
        data.canApply = false;
        data.isTemplating = Boolean(content?.includes("xmlns:template"));
        // the toggle always starts on the original source for this view
        data.templatingSource = false;
        data.value = content;
        data.previousValue = content;
        data.xContent = xcontent;
        data.type = type;
        oModel.refresh();
      },

      onTemplatingPress(oEvent) {
        const oSource = oEvent.getSource();
        const oModel = oSource.getModel();
        const data = oModel.getData();
        // Toggle between the original (previousValue) and the rendered
        // DOM (xContent) representation.
        data.value = oSource.getPressed() ? data.xContent : data.previousValue;
        oModel.refresh();
      },

      // Show the ABAP source of the running app inside an iframe.
      showAbapSource(oModel) {
        const contentControl = Fragment.byId(FRAGMENT_ID, "sourceHtml");
        // setContent (not a bare setProperty) so an already rendered
        // iframe is replaced in the live DOM; a plain property set never
        // reached the DOM once the control had rendered, leaving a stale
        // class on screen after navigating to another app.
        contentControl?.setContent(AbapSource.iframeHtml());

        // Warm the source cache in the background so the ADT button can
        // deep-link at the current event's line. Opening this view is the
        // moment a developer is heading for the source, and the fetch must
        // not block the switch - failures are swallowed by fetchSource.
        AbapSource.fetchSource();

        if (!oModel) return;
        const data = oModel.getData();
        data.editor_visible = false;
        data.source_visible = true;
        oModel.refresh();
      },

      onOpenAbapInAdt() {
        AbapSource.openInAdt();
      },

      // ----------------------------------------------------------------
      // Actions
      // ----------------------------------------------------------------

      // A one-line result under the action bar. The dialog is modal, so a
      // MessageToast behind it would be invisible.
      showStatus(oModel, text) {
        const data = oModel.getData();
        data.statusText = text;
        data.hasStatusText = Boolean(text);
        oModel.refresh();
        if (!text) return;
        clearTimeout(this._statusTimer);
        this._statusTimer = setTimeout(() => {
          if (Lib.isDestroyed(this)) return;
          data.statusText = "";
          data.hasStatusText = false;
          oModel.refresh();
        }, STATUS_MS);
      },

      // The most common reason these tools are opened: the whole session
      // state as a GitHub issue body, on the clipboard, in one press.
      async onReportBug(oEvent) {
        const oModel = oEvent.getSource().getModel();
        const source = await AbapSource.fetchSource();
        if (Lib.isDestroyed(this)) return;
        this.showStatus(oModel, Report.copyMarkdown(source));
      },

      async onExport() {
        Report.openDialog(AbapSource.appName(), await AbapSource.fetchSource());
      },

      // Put what is shown on the clipboard. A CodeEditor has no select-all
      // affordance of its own, so copying a report used to mean dragging
      // across thousands of lines - or going through Export, which builds
      // everything rather than the one view being looked at.
      onCopyTab(oEvent) {
        const oSource = oEvent.getSource();
        Lib.copyToClipboard(oSource.getModel().getData().value || "");
        // Confirm on the button itself and put the label back - the dialog
        // is modal, so a toast behind it would be invisible.
        const original = oSource.getText();
        oSource.setText("Copied");
        setTimeout(() => {
          if (!Lib.isDestroyed(oSource)) oSource.setText(original);
        }, 1500);
      },

      // The Error view's actions mirror the ErrorView overlay: re-run the
      // captured request, hard-reload, or log out (reusing ErrorView's own
      // logout so the launchpad/fallback logic stays in one place).
      onErrorRetry() {
        const onRetry = AppState.state.lastError?.onRetry;
        // Retrying re-runs the request, so don't bounce back to the error
        // popup.
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

      // Tier 2 of the recorder: keeping request/response bodies is the
      // expensive half of the history, so it is opt-in and switched here.
      // Switching it OFF also drops what was already retained, so a
      // developer can free the memory again without reloading the app.
      // The current view is re-rendered because both diff views and the
      // history report the flag's state.
      onToggleRecordPayloads(oEvent) {
        const oSource = oEvent.getSource();
        Recorder.setRecordingPayloads(oSource.getPressed());
        const oModel = oSource.getModel();
        this.renderTab(oModel.getData().selectedTab, oModel);
      },

      // Pop the tools open on the Log as soon as anything logs at error
      // level. Off by default - a modal dialog jumping up is the last
      // thing a productive user needs - but in a test system it is the
      // difference between noticing a broken roundtrip and not. The
      // setting lives in devtools/Console.js, which is where the errors
      // are and which both this dialog and the lifecycle facade can reach
      // without importing each other.
      onToggleOpenOnError(oEvent) {
        const oSource = oEvent.getSource();
        Console.setAlertOnError(oSource.getPressed());
        const oModel = oSource.getModel();
        oModel.getData().openOnError = Console.isAlertOnError();
        oModel.refresh();
      },

      // Pick a control on the screen and report what feeds it. The dialog
      // has to get out of the way first (it is modal and covers the app),
      // so it closes for the duration of the pick and reopens on the
      // picked-control view with the result. Escape cancels and reopens
      // on the view the user came from.
      onPickControl() {
        const previousTab = this.oDialog?.getModel()?.getData()?.selectedTab;
        this.reopenErrorOnClose = false;
        this.close();
        Picker.start((report) => {
          if (Lib.isDestroyed(this)) return;
          this.show(report ? "PICK" : previousTab);
        });
      },

      // Render the edited XML back into its view slot. Local preview only
      // - LiveEdit's result message says so, and it is shown under the
      // action bar so the developer knows it landed.
      async onApplyXml(oEvent) {
        const oModel = oEvent.getSource().getModel();
        const data = oModel.getData();
        if (LiveEdit.isBusy()) {
          this.showStatus(oModel, "A roundtrip is running - try again.");
          return;
        }
        const result = await LiveEdit.apply(data.selectedTab, data.value);
        if (Lib.isDestroyed(this)) return;
        this.showStatus(oModel, result);
      },

      // Put the backend's original XML back into the editor. Does not
      // re-render - press Apply for that.
      onResetXml(oEvent) {
        const oModel = oEvent.getSource().getModel();
        const data = oModel.getData();
        const xml = Tabs.render(data.selectedTab);
        data.value = xml;
        data.previousValue = xml;
        oModel.refresh();
        this.showStatus(oModel, "");
      },

      // The help used to be a tab of its own, which put a page of prose
      // in the same row as the twenty tabs that show live state. It is
      // reached from the info icon in the footer now and opens in its own
      // dialog, so it does not take the current view away.
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

      // ----------------------------------------------------------------
      // Lifecycle
      // ----------------------------------------------------------------

      onClose() {
        this.close();
      },

      // sap.m.Dialog closes on Escape without routing through onClose;
      // handle it ourselves (reject the default, run our close) so Escape
      // behaves exactly like the Close button - including re-showing the
      // error popup.
      onEscape(oPromise) {
        oPromise.reject();
        this.close();
      },

      // Open the developer tools dialog. `initialTab` (a tab key, e.g.
      // "ERROR") opens it directly on that view - used by the error
      // popup's Details action; defaults to where the developer left off.
      async show(initialTab) {
        // Guard against double-clicks while the fragment is still loading.
        if (this._showPending) return;
        this._showPending = true;
        try {
          if (!this.oDialog) {
            await preloadCodeEditor();
            this.oDialog = await Fragment.load({
              name: "z2ui5.devtools.DeveloperTools",
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

          // A caller-named view wins (the error popup's Details jumps to
          // ERROR); otherwise reopen where the developer left off.
          const requested =
            typeof initialTab === "string" && initialTab
              ? initialTab
              : readLastTab();

          const appName = AbapSource.appName();
          const oModel = new JSONModel({
            // The dialog title always names the app the tools are looking
            // at - every view below shows that app's data, and after a
            // navigation the previous app's name is the first thing that
            // would mislead. Assembled here rather than as an expression
            // binding in the fragment (AGENTS.md rule 13).
            title: appName
              ? `abap2UI5 - Developer Tools - ${appName}`
              : "abap2UI5 - Developer Tools",
            selectedGroup: Tabs.DEFAULT_GROUP,
            selectedTab: DEFAULT_TAB,
            selectedSlot: "MAIN",
            searchTerm: "",
            searchResult: false,
            slots: [],
            views: [],
            showSlotBar: false,
            showViewBar: false,
            isOverview: true,
            isRoundtrips: false,
            isViewData: false,
            isErrorView: false,
            isSourceView: false,
            hasRetry: false,
            canApply: false,
            isTemplating: false,
            templatingSource: false,
            statusText: "",
            hasStatusText: false,
            // The count badge on the Problems tab: the reason to look
            // there at all, visible without opening it.
            problemCount: this.problemCount(),
            recordPayloads: Recorder.isRecordingPayloads(),
            openOnError: Console.isAlertOnError(),
            type: "text",
            value: "",
            previousValue: "",
            xContent: "",
            source_visible: false,
            editor_visible: true,
          });

          const oDialog = this.oDialog;
          oDialog.setModel(oModel);
          this.renderTab(requested, oModel);
          oDialog.open();
        } catch (e) {
          Lib.logError("DeveloperTools.show failed", e);
        } finally {
          this._showPending = false;
        }
      },

      // What the Problems tab badge shows: a fatal error counts, and so
      // does anything the log captured at error level. "" hides the badge
      // - IconTabFilter renders a "0" otherwise, which reads as a problem
      // in itself.
      problemCount() {
        const errors = (AppState.state.errors || []).length;
        const total = errors + (AppState.state.lastError ? 1 : 0);
        return total ? String(total) : "";
      },

      close() {
        if (!this.oDialog || !this.oDialog.isOpen()) return;
        // When the dialog was opened from the error popup's Details
        // action, closing it (Close or Escape) re-shows that popup so the
        // user never ends up on the dismissed, broken app.
        const reopenError = this.reopenErrorOnClose;
        this.reopenErrorOnClose = false;
        // Keep the dialog (and its fragment controls, e.g. the
        // CodeEditor) and reuse it on the next show(). Destroying and
        // re-loading the fragment each time raced the close animation on
        // older UI5 (1.71): the CodeEditor's fragment-scoped id survived
        // long enough that the reload threw "adding element with
        // duplicate id 'z2ui5DeveloperTools--developerToolsEditor'". The
        // instance is destroyed once in exit() when the control itself
        // goes away.
        this.oDialog.close();
        if (reopenError) ErrorView.reopenErrorDialog();
      },

      // The dialog is not an aggregation of this control, so destroy()
      // alone would leave it (and its fragment controls) alive - clean it
      // up when the control is destroyed (Component.exit). Never re-show
      // the error popup while the app itself is being torn down.
      exit() {
        this.reopenErrorOnClose = false;
        clearTimeout(this._statusTimer);
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

      // The control itself renders nothing - it just provides the dialog
      // API.
      renderer: { apiVersion: 2, render() {} },
    });

    // The lifecycle around this control - creation, the Ctrl+F12
    // shortcut, auto open and teardown - belongs to
    // devtools/DevTools.js, which is the single entry point the framework
    // calls. This module is only the dialog.
    return DeveloperTools;
  },
);
