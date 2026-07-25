CLASS z2ui5_cl_app_errorview_js DEFINITION
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


CLASS z2ui5_cl_app_errorview_js IMPLEMENTATION.

  METHOD get.

    result = `// The unified fatal-error overlay. Shown via Server.responseError whenever` && |\n| &&
             `// the app reaches an unrecoverable state - a failed roundtrip (network,` && |\n| &&
             `// HTTP != 2xx, bad JSON, backend dump) or a client-side failure (invalid` && |\n| &&
             `// view XML, post-render crash, missing SDK module). The only way out is a` && |\n| &&
             `// restart, hence the Refresh / Logout actions. Built from raw DOM so it` && |\n| &&
             `// still works when the UI5 core itself is in a broken state.` && |\n| &&
             `sap.ui.define(["z2ui5/core/AppState"], (AppState) => {` && |\n| &&
             `  "use strict";` && |\n| &&
             `` && |\n| &&
             `  // Errors longer than this are truncated before being shown to the user,` && |\n| &&
             `  // so a stack trace from the backend cannot blow up the error overlay.` && |\n| &&
             `  const ERROR_MAX_LENGTH = 50000;` && |\n| &&
             `` && |\n| &&
             `  // The friendly dialog shows only a short preview of the error text (the` && |\n| &&
             `  // full text stays on the Developer Tools Error tab); longer previews are cut.` && |\n| &&
             `  const PREVIEW_MAX_LENGTH = 500;` && |\n| &&
             `` && |\n| &&
             `  // Remember the last dialog's inputs so the DeveloperTools can re-show the popup` && |\n| &&
             `  // after the user closes the developer tools they opened via its Details action.` && |\n| &&
             `  let lastDialogTitle = "";` && |\n| &&
             `  let lastDialogDetails = "";` && |\n| &&
             `` && |\n| &&
             `  // The currently open friendly error dialog, so a second fatal error (or a` && |\n| &&
             `  // reopen from the Developer Tools) never stacks two of them.` && |\n| &&
             `  let friendlyDialog = null;` && |\n| &&
             `` && |\n| &&
             `  // Decode the HTML entities that turn up in backend error pages. Non-ASCII` && |\n| &&
             `  // replacements go through fromCharCode so this source file stays 7-bit ASCII` && |\n| &&
             `  // (it is embedded verbatim into an ABAP class). &amp; is decoded last so an` && |\n| &&
             `  // already-encoded entity is not decoded twice.` && |\n| &&
             `  function decodeEntities(s) {` && |\n| &&
             `    return s` && |\n| &&
             `      .replace(/&nbsp;/gi, " ")` && |\n| &&
             `      .replace(/&lt;/gi, "<")` && |\n| &&
             `      .replace(/&gt;/gi, ">")` && |\n| &&
             `      .replace(/&quot;/gi, '"')` && |\n| &&
             `      .replace(/&apos;|&#0*39;/gi, "'")` && |\n| &&
             `      .replace(/&copy;/gi, String.fromCharCode(169))` && |\n| &&
             `      .replace(/&#(\d+);/g, (_, n) => String.fromCharCode(Number(n)))` && |\n| &&
             `      .replace(/&#x([0-9a-f]+);/gi, (_, n) =>` && |\n| &&
             `        String.fromCharCode(parseInt(n, 16)),` && |\n| &&
             `      )` && |\n| &&
             `      .replace(/&amp;/gi, "&");` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  const cleanText = (s) =>` && |\n| &&
             `    decodeEntities(s.replace(/<[^>]+>/g, " "))` && |\n| &&
             `      .replace(/\s+/g, " ")` && |\n| &&
             `      .trim();` && |\n| &&
             `` && |\n| &&
             `  // Pull just the meaningful message out of a SAP application-server error` && |\n| &&
             `  // page: the error header (e.g. "500 Internal Server Error") and the message` && |\n| &&
             `  // paragraphs (e.g. "Division by zero"). Everything else - page title, footer,` && |\n| &&
             `  // copyright, the client-side clock <script> after "Server time:" - is noise` && |\n| &&
             `  // and dropped. Returns "" when the text is not such a page.` && |\n| &&
             `  function extractServerError(html) {` && |\n| &&
             `    const parts = [];` && |\n| &&
             `    const rx = /class="(?:errorTextHeader|detailText)"[^>]*>([\s\S]*?)<\/p>/gi;` && |\n| &&
             `    let m;` && |\n| &&
             `    while ((m = rx.exec(html))) parts.push(cleanText(m[1]));` && |\n| &&
             `    return parts` && |\n| &&
             `      .filter(Boolean)` && |\n| &&
             `      .filter((t) => !/^server time:/i.test(t))` && |\n| &&
             `      .join(" - ");` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  // Turn the raw error text into a one-glance preview for the friendly dialog.` && |\n| &&
             `  // Backend errors often arrive as a whole HTML page (an ABAP dump rendered as` && |\n| &&
             `  // a 500 error page): prefer the structured error message, else fall back to` && |\n| &&
             `  // stripping script/style/title and the remaining tags. Rendered as plain` && |\n| &&
             `  // MessageBox text, so the stripped markup cannot execute.` && |\n| &&
             `  function buildErrorPreview(text) {` && |\n| &&
             `    if (!text) return "";` && |\n| &&
             `    let preview = text;` && |\n| &&
             `    if (/<[a-z][\s\S]*>/i.test(preview)) {` && |\n| &&
             `      preview =` && |\n| &&
             `        extractServerError(preview) ||` && |\n| &&
             `        cleanText(` && |\n| &&
             `          preview.replace(/<(script|style|title)[\s\S]*?<\/\1>/gi, " "),` && |\n| &&
             `        );` && |\n| &&
             `    }` && |\n| &&
             `    preview = preview.replace(/\s+/g, " ").trim();` && |\n| &&
             `    return preview.length > PREVIEW_MAX_LENGTH` && |\n| &&
             `      ? ``${preview.slice(0, PREVIEW_MAX_LENGTH)}...``` && |\n| &&
             `      : preview;` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  // Copy text to the clipboard, working both in a secure (HTTPS) context and` && |\n| &&
             `  // over plain HTTP - the latter is common for on-premise ABAP systems, where` && |\n| &&
             `  // the async navigator.clipboard API is unavailable. A hidden <textarea> plus` && |\n| &&
             `  // the classic execCommand("copy") works everywhere, so try it first and only` && |\n| &&
             `  // fall back to the async API when it did not copy. Returns nothing - copying` && |\n| &&
             `  // is best-effort and must never throw out of a fatal-error dialog.` && |\n| &&
             `  function copyToClipboard(text) {` && |\n| &&
             `    const value = String(text == null ? "" : text);` && |\n| &&
             `    let copied;` && |\n| &&
             `    const textarea = document.createElement("textarea");` && |\n| &&
             `    textarea.value = value;` && |\n| &&
             `    // Keep it out of view and out of the layout flow while it is selected.` && |\n| &&
             `    textarea.style.cssText =` && |\n| &&
             `      "position:fixed;top:-9999px;left:-9999px;opacity:0;";` && |\n| &&
             `    textarea.setAttribute("readonly", "");` && |\n| &&
             `    document.body.appendChild(textarea);` && |\n| &&
             `    try {` && |\n| &&
             `      textarea.focus();` && |\n| &&
             `      textarea.select();` && |\n| &&
             `      textarea.setSelectionRange(0, value.length);` && |\n| &&
             `      copied = document.execCommand("copy");` && |\n| &&
             `    } catch {` && |\n| &&
             `      copied = false;` && |\n| &&
             `    }` && |\n| &&
             `    textarea.remove();` && |\n| &&
             `    if (!copied && navigator.clipboard?.writeText) {` && |\n| &&
             `      navigator.clipboard.writeText(value).catch(() => {});` && |\n| &&
             `    }` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  function createContainer() {` && |\n| &&
             `    // Always start from a fresh element: reusing a previous overlay would` && |\n| &&
             `    // keep its keydown focus-trap listener alive and stack a duplicate on` && |\n| &&
             `    // every further show() call.` && |\n| &&
             `    document.getElementById("serverErrorContainer")?.remove();` && |\n| &&
             `` && |\n| &&
             `    const container = document.createElement("div");` && |\n| &&
             `    container.id = "serverErrorContainer";` && |\n| &&
             `    container.style.cssText = ``` && |\n| &&
             `      position: fixed;` && |\n| &&
             `      top: 50%;` && |\n| &&
             `      left: 50%;` && |\n| &&
             `      transform: translate(-50%, -50%);` && |\n| &&
             `      width: 90%;` && |\n| &&
             `      height: 90%;` && |\n| &&
             `      background: white;` && |\n| &&
             `      border: 2px solid #d32f2f;` && |\n| &&
             `      border-radius: 4px;` && |\n| &&
             `      box-shadow: 0 4px 6px rgba(0,0,0,0.3);` && |\n| &&
             `      z-index: 9999;` && |\n| &&
             `      display: flex;` && |\n| &&
             `      flex-direction: column;` && |\n| &&
             `    ``;` && |\n| &&
             `    document.body.appendChild(container);` && |\n| &&
             `    return container;` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  // Open the DeveloperTools directly on its Error tab so the developer sees the` && |\n| &&
             `  // full error text plus the Retry/Refresh/Logout actions. The DeveloperTools is` && |\n| &&
             `  // normally created lazily on first Ctrl+F12, so it may not exist yet when` && |\n| &&
             `  // the error popup's Details is clicked - create it on demand (requiring the` && |\n| &&
             `  // module at runtime avoids a circular dependency, since DeveloperTools imports` && |\n| &&
             `  // ErrorView). Without this, Details was a no-op and left a blank screen.` && |\n| &&
             `  function openDeveloperTools() {` && |\n| &&
             `    try {` && |\n| &&
             `      let dbg = AppState.state.developerTools;` && |\n| &&
             `      if (!dbg) {` && |\n| &&
             `        const DeveloperTools = sap.ui.require("z2ui5/core/DeveloperTools");` && |\n| &&
             `        if (DeveloperTools) {` && |\n| &&
             `          dbg = new DeveloperTools();` && |\n| &&
             `          AppState.state.developerTools = dbg;` && |\n| &&
             `        }` && |\n| &&
             `      }` && |\n| &&
             `      if (dbg) {` && |\n| &&
             `        // Closing the DeveloperTools (Close or Escape) should land the user back on` && |\n| &&
             `        // the error popup, not on the dismissed, broken app.` && |\n| &&
             `        dbg.reopenErrorOnClose = true;` && |\n| &&
             `        dbg.show("ERROR");` && |\n| &&
             `      }` && |\n| &&
             `    } catch {` && |\n| &&
             `      // The developer tools itself failed to open - nothing more we can do here;` && |\n| &&
             `      // the fatal error is still recorded in AppState.state.lastError.` && |\n| &&
             `    }` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  // The friendly UI5 error dialog shown first: the extracted error text so the` && |\n| &&
             `  // cause is visible at a glance, with a Details action (jump into the` && |\n| &&
             `  // DeveloperTools for the full text) and a Restart action (reload). Returns` && |\n| &&
             `  // true when it was shown, false when UI5 could not render it so the caller` && |\n| &&
             `  // falls back to the raw-DOM overlay. sap.m.Dialog/Button/Text are required` && |\n| &&
             `  // lazily so ErrorView never hard-depends on a renderable core.` && |\n| &&
             `  //` && |\n| &&
             `  // A plain Dialog (not sap.m.MessageBox) is used on purpose: a fatal error` && |\n| &&
             `  // leaves the app in a broken state, so the popup must not be dismissable` && |\n| &&
             `  // with Escape - MessageBox always closes on Escape and offers no way to` && |\n| &&
             `  // suppress it, whereas a Dialog with an escapeHandler that rejects stays` && |\n| &&
             `  // open until the user picks an explicit action.` && |\n| &&
             `  function showFriendlyDialog(title, details) {` && |\n| &&
             `    try {` && |\n| &&
             `      const Dialog = sap.ui.require("sap/m/Dialog");` && |\n| &&
             `      const Button = sap.ui.require("sap/m/Button");` && |\n| &&
             `      const Text = sap.ui.require("sap/m/Text");` && |\n| &&
             `      if (!Dialog || !Button || !Text) return false;` && |\n| &&
             `      lastDialogTitle = title;` && |\n| &&
             `      lastDialogDetails = details;` && |\n| &&
             `      // Never stack two error popups (a second fatal error or a reopen).` && |\n| &&
             `      if (friendlyDialog) {` && |\n| &&
             `        friendlyDialog.destroy();` && |\n| &&
             `        friendlyDialog = null;` && |\n| &&
             `      }` && |\n| &&
             `      // Show only the extracted error text; a short neutral fallback covers` && |\n| &&
             `      // the rare case where nothing could be extracted.` && |\n| &&
             `      const message = buildErrorPreview(details) || "An error occurred.";` && |\n| &&
             `      // Restart is the primary action, so it also gets the initial focus.` && |\n| &&
             `      const restartButton = new Button({` && |\n| &&
             `        text: "Restart",` && |\n| &&
             `        type: "Emphasized",` && |\n| &&
             `        press: () => window.location.reload(),` && |\n| &&
             `      });` && |\n| &&
             `      // Copy the full error text (not just the shown preview) to the clipboard` && |\n| &&
             `      // so the user can paste it into a ticket or chat. Briefly flip the label` && |\n| &&
             `      // to "Copied" as feedback, then restore it (guarding against a dialog` && |\n| &&
             `      // that was closed in the meantime).` && |\n| &&
             `      const copyButton = new Button({` && |\n| &&
             `        text: "Copy",` && |\n| &&
             `        press: () => {` && |\n| &&
             `          copyToClipboard(details);` && |\n| &&
             `          copyButton.setText("Copied");` && |\n| &&
             `          setTimeout(() => {` && |\n| &&
             `            if (!copyButton.bIsDestroyed) copyButton.setText("Copy");` && |\n| &&
             `          }, 1500);` && |\n| &&
             `        },` && |\n| &&
             `      });` && |\n| &&
             `      // sap.m.Dialog does not allow more than one begin/end button, so use the` && |\n| &&
             `      // ``buttons`` aggregation to line up Details / Copy / Restart in the footer.` && |\n| &&
             `      const dialog = new Dialog({` && |\n| &&
             `        title: title || "Application Error",` && |\n| &&
             `        type: "Message",` && |\n| &&
             `        state: "Error",` && |\n| &&
             `        icon: "sap-icon://message-error",` && |\n| &&
             `        // Escape must not dismiss the fatal-error popup: rejecting the escape` && |\n| &&
             `        // promise keeps it open, so the only ways out are the explicit` && |\n| &&
             `        // Details / Copy / Restart actions below.` && |\n| &&
             `        escapeHandler: (oPromise) => oPromise.reject(),` && |\n| &&
             `        content: [new Text({ text: message })],` && |\n| &&
             `        buttons: [` && |\n| &&
             `          new Button({` && |\n| &&
             `            text: "Details",` && |\n| &&
             `            press: () => {` && |\n| &&
             `              dialog.close();` && |\n| &&
             `              openDeveloperTools();` && |\n| &&
             `            },` && |\n| &&
             `          }),` && |\n| &&
             `          copyButton,` && |\n| &&
             `          restartButton,` && |\n| &&
             `        ],` && |\n| &&
             `        initialFocus: restartButton,` && |\n| &&
             `        afterClose: () => {` && |\n| &&
             `          if (friendlyDialog === dialog) friendlyDialog = null;` && |\n| &&
             `          dialog.destroy();` && |\n| &&
             `        },` && |\n| &&
             `      });` && |\n| &&
             `      friendlyDialog = dialog;` && |\n| &&
             `      dialog.open();` && |\n| &&
             `      return true;` && |\n| &&
             `    } catch {` && |\n| &&
             `      return false;` && |\n| &&
             `    }` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  // Re-show the friendly error dialog with the last error's content - used when` && |\n| &&
             `  // the user closes the DeveloperTools they opened via the popup's Details action so` && |\n| &&
             `  // they land back on the error popup. No-op if UI5 cannot render it.` && |\n| &&
             `  function reopenErrorDialog() {` && |\n| &&
             `    return showFriendlyDialog(lastDialogTitle, lastDialogDetails);` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  // Logout via the launchpad if available; otherwise hit the SAP logoff URL.` && |\n| &&
             `  function handleLogout() {` && |\n| &&
             `    const fallback = () => {` && |\n| &&
             `      window.location.href = "/sap/public/bc/icf/logoff";` && |\n| &&
             `    };` && |\n| &&
             `    try {` && |\n| &&
             `      if (AppState.state.oLaunchpad?.Container?.logout) {` && |\n| &&
             `        AppState.state.oLaunchpad.Container.logout();` && |\n| &&
             `      } else {` && |\n| &&
             `        fallback();` && |\n| &&
             `      }` && |\n| &&
             `    } catch {` && |\n| &&
             `      fallback();` && |\n| &&
             `    }` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  // showFriendlyDialog only succeeds when sap.m.Dialog/Button/Text are already` && |\n| &&
             `  // loaded, because it resolves them with the synchronous sap.ui.require (which` && |\n| &&
             `  // returns undefined for a not-yet-loaded module). This kicks off the async` && |\n| &&
             `  // require for those three controls and retries the friendly popup once they` && |\n| &&
             `  // arrive, so a fatal error raised before any Dialog was used - most notably a` && |\n| &&
             `  // popover fragment that fails to render on the first roundtrip - still lands` && |\n| &&
             `  // in the friendly UI5 popup instead of the raw-DOM overlay. Returns true when` && |\n| &&
             `  // the async load was started (the caller must then NOT also show the raw` && |\n| &&
             `  // overlay); false when async loading is unavailable, so the caller falls back` && |\n| &&
             `  // right away. If the modules cannot be loaded (broken core) or still cannot` && |\n| &&
             `  // render, the errback / retry paths show the raw overlay so the error is` && |\n| &&
             `  // never swallowed.` && |\n| &&
             `  function loadFriendlyDialogAsync(title, details, options) {` && |\n| &&
             `    try {` && |\n| &&
             `      const require = sap?.ui?.require;` && |\n| &&
             `      if (typeof require !== "function") return false;` && |\n| &&
             `      require(["sap/m/Dialog", "sap/m/Button", "sap/m/Text"], () => {` && |\n| &&
             `        if (!showFriendlyDialog(title, details)) {` && |\n| &&
             `          showRawOverlay(title, details, options);` && |\n| &&
             `        }` && |\n| &&
             `      }, () => showRawOverlay(title, details, options));` && |\n| &&
             `      return true;` && |\n| &&
             `    } catch {` && |\n| &&
             `      return false;` && |\n| &&
             `    }` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  // ``response`` may be a string or an Error object; ``title`` overrides the` && |\n| &&
             `  // default header text; ``options.onRetry`` adds a Retry action that removes` && |\n| &&
             `  // the overlay and re-runs the failed request (offered by Server.readHttp` && |\n| &&
             `  // for network/timeout failures, where the request may never have reached` && |\n| &&
             `  // the server and app state is still intact).` && |\n| &&
             `  function show(response, title, options = {}) {` && |\n| &&
             `    const full = response?.stack ? String(response.stack) : String(response);` && |\n| &&
             `    // Rendered via textContent, so the truncation marker is plain text (an` && |\n| &&
             `    // HTML comment would show up literally).` && |\n| &&
             `    const errorMessage =` && |\n| &&
             `      full.length > ERROR_MAX_LENGTH` && |\n| &&
             `        ? ``${full.slice(0, ERROR_MAX_LENGTH)}\n\n[... truncated after ${ERROR_MAX_LENGTH} characters]``` && |\n| &&
             `        : full;` && |\n| &&
             `` && |\n| &&
             `    // Record the fatal error so the Developer Tools Error tab can re-show it` && |\n| &&
             `    // (title, text and the same Retry action) after the overlay is gone.` && |\n| &&
             `    AppState.state.lastError = {` && |\n| &&
             `      title: title || "Application Error - Please Restart The App",` && |\n| &&
             `      text: errorMessage,` && |\n| &&
             `      onRetry: typeof options.onRetry === "function" ? options.onRetry : null,` && |\n| &&
             `    };` && |\n| &&
             `` && |\n| &&
             `    // Prefer a friendly UI5 dialog (the error text + Details / Restart).` && |\n| &&
             `    if (showFriendlyDialog(title, errorMessage)) return;` && |\n| &&
             `` && |\n| &&
             `    // Its modules were not loaded yet: load them asynchronously and retry, so` && |\n| &&
             `    // the error still lands in the friendly popup first (see` && |\n| &&
             `    // loadFriendlyDialogAsync). Only when async loading is unavailable do we` && |\n| &&
             `    // fall through to the raw-DOM overlay immediately.` && |\n| &&
             `    if (loadFriendlyDialogAsync(title, errorMessage, options)) return;` && |\n| &&
             `` && |\n| &&
             `    showRawOverlay(title, errorMessage, options);` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  // The raw-DOM fatal overlay - the last-resort error display, built without` && |\n| &&
             `  // UI5 so it still works when the core cannot render the friendly dialog.` && |\n| &&
             `  function showRawOverlay(title, errorMessage, options = {}) {` && |\n| &&
             `    const errorContainer = createContainer();` && |\n| &&
             `` && |\n| &&
             `    // Announce the overlay to assistive technology: without a dialog role` && |\n| &&
             `    // and focus move, a screen-reader user is never told the app crashed.` && |\n| &&
             `    errorContainer.setAttribute("role", "alertdialog");` && |\n| &&
             `    errorContainer.setAttribute("aria-modal", "true");` && |\n| &&
             `    errorContainer.setAttribute("aria-labelledby", "serverErrorTitle");` && |\n| &&
             `` && |\n| &&
             `    // Header bar with title and action buttons.` && |\n| &&
             `    const headerDiv = document.createElement("div");` && |\n| &&
             `    headerDiv.style.cssText =` && |\n| &&
             `      "padding: 15px; background: #d32f2f; color: white; display: flex; justify-content: space-between; align-items: center;";` && |\n| &&
             `` && |\n| &&
             `    const h3 = document.createElement("h3");` && |\n| &&
             `    h3.id = "serverErrorTitle";` && |\n| &&
             `    h3.textContent = title || "Application Error - Please Restart The App";` && |\n| &&
             `    h3.style.cssText = "margin: 0";` && |\n| &&
             `    headerDiv.appendChild(h3);` && |\n| &&
             `` && |\n| &&
             `    const btnStyle =` && |\n| &&
             `      "padding: 6px 14px; background: white; color: #d32f2f; border: none; border-radius: 3px; cursor: pointer; font-weight: bold;";` && |\n| &&
             `` && |\n| &&
             `    const actionsDiv = document.createElement("div");` && |\n| &&
             `    actionsDiv.style.cssText = "display: flex; gap: 8px;";` && |\n| &&
             `` && |\n| &&
             `    if (typeof options.onRetry === "function") {` && |\n| &&
             `      const retryBtn = document.createElement("button");` && |\n| &&
             `      retryBtn.type = "button";` && |\n| &&
             `      retryBtn.textContent = "Retry";` && |\n| &&
             `      retryBtn.style.cssText = btnStyle;` && |\n| &&
             `      retryBtn.addEventListener("click", () => {` && |\n| &&
             `        errorContainer.remove();` && |\n| &&
             `        options.onRetry();` && |\n| &&
             `      });` && |\n| &&
             `      actionsDiv.appendChild(retryBtn);` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    const refreshBtn = document.createElement("button");` && |\n| &&
             `    refreshBtn.type = "button";` && |\n| &&
             `    refreshBtn.textContent = "Refresh";` && |\n| &&
             `    refreshBtn.style.cssText = btnStyle;` && |\n| &&
             `    refreshBtn.addEventListener("click", () => window.location.reload());` && |\n| &&
             `    actionsDiv.appendChild(refreshBtn);` && |\n| &&
             `` && |\n| &&
             `    const logoutBtn = document.createElement("button");` && |\n| &&
             `    logoutBtn.type = "button";` && |\n| &&
             `    logoutBtn.textContent = "Logout";` && |\n| &&
             `    logoutBtn.style.cssText = btnStyle;` && |\n| &&
             `    logoutBtn.addEventListener("click", () => handleLogout());` && |\n| &&
             `    actionsDiv.appendChild(logoutBtn);` && |\n| &&
             `` && |\n| &&
             `    headerDiv.appendChild(actionsDiv);` && |\n| &&
             `    errorContainer.appendChild(headerDiv);` && |\n| &&
             `` && |\n| &&
             `    // Keep keyboard focus inside the overlay: Tab cycles through the action` && |\n| &&
             `    // buttons instead of escaping into the broken page behind it. The button` && |\n|.
    result = result &&
             `    // set is complete here (all appended above), so resolve first/last once` && |\n| &&
             `    // rather than re-querying the DOM on every Tab press.` && |\n| &&
             `    const trapButtons = actionsDiv.querySelectorAll("button");` && |\n| &&
             `    const firstTrap = trapButtons[0];` && |\n| &&
             `    const lastTrap = trapButtons[trapButtons.length - 1];` && |\n| &&
             `    errorContainer.addEventListener("keydown", (event) => {` && |\n| &&
             `      if (event.key !== "Tab") return;` && |\n| &&
             `      if (event.shiftKey && document.activeElement === firstTrap) {` && |\n| &&
             `        event.preventDefault();` && |\n| &&
             `        lastTrap.focus();` && |\n| &&
             `      } else if (!event.shiftKey && document.activeElement === lastTrap) {` && |\n| &&
             `        event.preventDefault();` && |\n| &&
             `        firstTrap.focus();` && |\n| &&
             `      }` && |\n| &&
             `    });` && |\n| &&
             `` && |\n| &&
             `    // The error text itself lives inside a sandboxed iframe so any HTML` && |\n| &&
             `    // in the backend response cannot execute or affect the main page.` && |\n| &&
             `    const iframe = document.createElement("iframe");` && |\n| &&
             `    iframe.id = "errorIframe";` && |\n| &&
             `    iframe.style.cssText = "width: 100%; height: 100%; border: none; flex: 1;";` && |\n| &&
             `    iframe.setAttribute("sandbox", "allow-same-origin");` && |\n| &&
             `    errorContainer.appendChild(iframe);` && |\n| &&
             `` && |\n| &&
             `    const preStyle =` && |\n| &&
             `      "margin:0;padding:8px;font-family:monospace;font-size:12px;white-space:pre-wrap;word-break:break-all;";` && |\n| &&
             `    const contentDocument = iframe.contentDocument;` && |\n| &&
             `    if (contentDocument) {` && |\n| &&
             `      const pre = contentDocument.createElement("pre");` && |\n| &&
             `      pre.style.cssText = preStyle;` && |\n| &&
             `      pre.textContent = errorMessage;` && |\n| &&
             `      const target = contentDocument.body || contentDocument.documentElement;` && |\n| &&
             `      target.appendChild(pre);` && |\n| &&
             `    } else {` && |\n| &&
             `      // The sandboxed iframe document was not reachable (sandbox/timing` && |\n| &&
             `      // edge). Never leave the fatal overlay empty: fall back to a plain` && |\n| &&
             `      // <pre> in the container. textContent does not parse HTML, so the` && |\n| &&
             `      // untrusted backend message still cannot execute.` && |\n| &&
             `      const pre = document.createElement("pre");` && |\n| &&
             `      pre.style.cssText = preStyle;` && |\n| &&
             `      pre.textContent = errorMessage;` && |\n| &&
             `      errorContainer.appendChild(pre);` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // Move focus into the dialog so keyboard and screen-reader users land on` && |\n| &&
             `    // the primary action instead of the broken page behind the overlay.` && |\n| &&
             `    const firstButton = actionsDiv.querySelector("button");` && |\n| &&
             `    if (firstButton) firstButton.focus();` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  return { show, handleLogout, reopenErrorDialog };` && |\n| &&
             `});` && |\n| &&
             `` && |\n| &&
              ``.

  ENDMETHOD.

ENDCLASS.
