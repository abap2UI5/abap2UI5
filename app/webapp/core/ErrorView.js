// The unified fatal-error overlay. Shown via Server.responseError whenever
// the app reaches an unrecoverable state - a failed roundtrip (network,
// HTTP != 2xx, bad JSON, backend dump) or a client-side failure (invalid
// view XML, post-render crash, missing SDK module). The only way out is a
// restart, hence the Refresh / Logout actions. Built from raw DOM so it
// still works when the UI5 core itself is in a broken state.
sap.ui.define(["z2ui5/core/AppState"], (AppState) => {
  "use strict";

  // Errors longer than this are truncated before being shown to the user,
  // so a stack trace from the backend cannot blow up the error overlay.
  const ERROR_MAX_LENGTH = 50000;

  // The friendly dialog shows only a short preview of the error text (the
  // full text stays on the Developer Tools Error tab); longer previews are cut.
  const PREVIEW_MAX_LENGTH = 500;

  // Remember the last dialog's inputs so the DeveloperTools can re-show the popup
  // after the user closes the developer tools they opened via its Details action.
  let lastDialogTitle = "";
  let lastDialogDetails = "";

  // The currently open friendly error dialog, so a second fatal error (or a
  // reopen from the Developer Tools) never stacks two of them.
  let friendlyDialog = null;

  // Decode the HTML entities that turn up in backend error pages. Non-ASCII
  // replacements go through fromCharCode so this source file stays 7-bit ASCII
  // (it is embedded verbatim into an ABAP class). &amp; is decoded last so an
  // already-encoded entity is not decoded twice.
  function decodeEntities(s) {
    return s
      .replace(/&nbsp;/gi, " ")
      .replace(/&lt;/gi, "<")
      .replace(/&gt;/gi, ">")
      .replace(/&quot;/gi, '"')
      .replace(/&apos;|&#0*39;/gi, "'")
      .replace(/&copy;/gi, String.fromCharCode(169))
      .replace(/&#(\d+);/g, (_, n) => String.fromCharCode(Number(n)))
      .replace(/&#x([0-9a-f]+);/gi, (_, n) =>
        String.fromCharCode(parseInt(n, 16)),
      )
      .replace(/&amp;/gi, "&");
  }

  const cleanText = (s) =>
    decodeEntities(s.replace(/<[^>]+>/g, " "))
      .replace(/\s+/g, " ")
      .trim();

  // Pull just the meaningful message out of a SAP application-server error
  // page: the error header (e.g. "500 Internal Server Error") and the message
  // paragraphs (e.g. "Division by zero"). Everything else - page title, footer,
  // copyright, the client-side clock <script> after "Server time:" - is noise
  // and dropped. Returns "" when the text is not such a page.
  function extractServerError(html) {
    const parts = [];
    const rx = /class="(?:errorTextHeader|detailText)"[^>]*>([\s\S]*?)<\/p>/gi;
    let m;
    while ((m = rx.exec(html))) parts.push(cleanText(m[1]));
    return parts
      .filter(Boolean)
      .filter((t) => !/^server time:/i.test(t))
      .join(" - ");
  }

  // Turn the raw error text into a one-glance preview for the friendly dialog.
  // Backend errors often arrive as a whole HTML page (an ABAP dump rendered as
  // a 500 error page): prefer the structured error message, else fall back to
  // stripping script/style/title and the remaining tags. Rendered as plain
  // MessageBox text, so the stripped markup cannot execute.
  function buildErrorPreview(text) {
    if (!text) return "";
    let preview = text;
    if (/<[a-z][\s\S]*>/i.test(preview)) {
      preview =
        extractServerError(preview) ||
        cleanText(
          preview.replace(/<(script|style|title)[\s\S]*?<\/\1>/gi, " "),
        );
    }
    preview = preview.replace(/\s+/g, " ").trim();
    return preview.length > PREVIEW_MAX_LENGTH
      ? `${preview.slice(0, PREVIEW_MAX_LENGTH)}...`
      : preview;
  }

  function createContainer() {
    // Always start from a fresh element: reusing a previous overlay would
    // keep its keydown focus-trap listener alive and stack a duplicate on
    // every further show() call.
    document.getElementById("serverErrorContainer")?.remove();

    const container = document.createElement("div");
    container.id = "serverErrorContainer";
    container.style.cssText = `
      position: fixed;
      top: 50%;
      left: 50%;
      transform: translate(-50%, -50%);
      width: 90%;
      height: 90%;
      background: white;
      border: 2px solid #d32f2f;
      border-radius: 4px;
      box-shadow: 0 4px 6px rgba(0,0,0,0.3);
      z-index: 9999;
      display: flex;
      flex-direction: column;
    `;
    document.body.appendChild(container);
    return container;
  }

  // Open the DeveloperTools directly on its Error tab so the developer sees the
  // full error text plus the Retry/Refresh/Logout actions. The DeveloperTools is
  // normally created lazily on first Ctrl+F12, so it may not exist yet when
  // the error popup's Details is clicked - create it on demand (requiring the
  // module at runtime avoids a circular dependency, since DeveloperTools imports
  // ErrorView). Without this, Details was a no-op and left a blank screen.
  function openDeveloperTools() {
    try {
      let dbg = AppState.state.developerTools;
      if (!dbg) {
        const DeveloperTools = sap.ui.require("z2ui5/core/DeveloperTools");
        if (DeveloperTools) {
          dbg = new DeveloperTools();
          AppState.state.developerTools = dbg;
        }
      }
      if (dbg) {
        // Closing the DeveloperTools (Close or Escape) should land the user back on
        // the error popup, not on the dismissed, broken app.
        dbg.reopenErrorOnClose = true;
        dbg.show("ERROR");
      }
    } catch {
      // The developer tools itself failed to open - nothing more we can do here;
      // the fatal error is still recorded in AppState.state.lastError.
    }
  }

  // The friendly UI5 error dialog shown first: the extracted error text so the
  // cause is visible at a glance, with a Details action (jump into the
  // DeveloperTools for the full text) and a Restart action (reload). Returns
  // true when it was shown, false when UI5 could not render it so the caller
  // falls back to the raw-DOM overlay. sap.m.Dialog/Button/Text are required
  // lazily so ErrorView never hard-depends on a renderable core.
  //
  // A plain Dialog (not sap.m.MessageBox) is used on purpose: a fatal error
  // leaves the app in a broken state, so the popup must not be dismissable
  // with Escape - MessageBox always closes on Escape and offers no way to
  // suppress it, whereas a Dialog with an escapeHandler that rejects stays
  // open until the user picks an explicit action.
  function showFriendlyDialog(title, details) {
    try {
      const Dialog = sap.ui.require("sap/m/Dialog");
      const Button = sap.ui.require("sap/m/Button");
      const Text = sap.ui.require("sap/m/Text");
      if (!Dialog || !Button || !Text) return false;
      lastDialogTitle = title;
      lastDialogDetails = details;
      // Never stack two error popups (a second fatal error or a reopen).
      if (friendlyDialog) {
        friendlyDialog.destroy();
        friendlyDialog = null;
      }
      // Show only the extracted error text; a short neutral fallback covers
      // the rare case where nothing could be extracted.
      const message = buildErrorPreview(details) || "An error occurred.";
      // Restart is the primary action, so it also gets the initial focus.
      const restartButton = new Button({
        text: "Restart",
        type: "Emphasized",
        press: () => window.location.reload(),
      });
      const dialog = new Dialog({
        title: title || "Application Error",
        type: "Message",
        state: "Error",
        icon: "sap-icon://message-error",
        // Escape must not dismiss the fatal-error popup: rejecting the escape
        // promise keeps it open, so the only ways out are the explicit
        // Details / Restart actions below.
        escapeHandler: (oPromise) => oPromise.reject(),
        content: [new Text({ text: message })],
        beginButton: new Button({
          text: "Details",
          press: () => {
            dialog.close();
            openDeveloperTools();
          },
        }),
        endButton: restartButton,
        initialFocus: restartButton,
        afterClose: () => {
          if (friendlyDialog === dialog) friendlyDialog = null;
          dialog.destroy();
        },
      });
      friendlyDialog = dialog;
      dialog.open();
      return true;
    } catch {
      return false;
    }
  }

  // Re-show the friendly error dialog with the last error's content - used when
  // the user closes the DeveloperTools they opened via the popup's Details action so
  // they land back on the error popup. No-op if UI5 cannot render it.
  function reopenErrorDialog() {
    return showFriendlyDialog(lastDialogTitle, lastDialogDetails);
  }

  // Logout via the launchpad if available; otherwise hit the SAP logoff URL.
  function handleLogout() {
    const fallback = () => {
      window.location.href = "/sap/public/bc/icf/logoff";
    };
    try {
      if (AppState.state.oLaunchpad?.Container?.logout) {
        AppState.state.oLaunchpad.Container.logout();
      } else {
        fallback();
      }
    } catch {
      fallback();
    }
  }

  // `response` may be a string or an Error object; `title` overrides the
  // default header text; `options.onRetry` adds a Retry action that removes
  // the overlay and re-runs the failed request (offered by Server.readHttp
  // for network/timeout failures, where the request may never have reached
  // the server and app state is still intact).
  function show(response, title, options = {}) {
    const full = response?.stack ? String(response.stack) : String(response);
    // Rendered via textContent, so the truncation marker is plain text (an
    // HTML comment would show up literally).
    const errorMessage =
      full.length > ERROR_MAX_LENGTH
        ? `${full.slice(0, ERROR_MAX_LENGTH)}\n\n[... truncated after ${ERROR_MAX_LENGTH} characters]`
        : full;

    // Record the fatal error so the Developer Tools Error tab can re-show it
    // (title, text and the same Retry action) after the overlay is gone.
    AppState.state.lastError = {
      title: title || "Application Error - Please Restart The App",
      text: errorMessage,
      onRetry: typeof options.onRetry === "function" ? options.onRetry : null,
    };

    // Prefer a friendly UI5 dialog ("an unexpected error occurred" + Details
    // / Restart). Only when UI5 cannot render it (broken core, missing
    // module) do we fall back to the raw-DOM overlay below.
    if (showFriendlyDialog(title, errorMessage)) return;

    const errorContainer = createContainer();

    // Announce the overlay to assistive technology: without a dialog role
    // and focus move, a screen-reader user is never told the app crashed.
    errorContainer.setAttribute("role", "alertdialog");
    errorContainer.setAttribute("aria-modal", "true");
    errorContainer.setAttribute("aria-labelledby", "serverErrorTitle");

    // Header bar with title and action buttons.
    const headerDiv = document.createElement("div");
    headerDiv.style.cssText =
      "padding: 15px; background: #d32f2f; color: white; display: flex; justify-content: space-between; align-items: center;";

    const h3 = document.createElement("h3");
    h3.id = "serverErrorTitle";
    h3.textContent = title || "Application Error - Please Restart The App";
    h3.style.cssText = "margin: 0";
    headerDiv.appendChild(h3);

    const btnStyle =
      "padding: 6px 14px; background: white; color: #d32f2f; border: none; border-radius: 3px; cursor: pointer; font-weight: bold;";

    const actionsDiv = document.createElement("div");
    actionsDiv.style.cssText = "display: flex; gap: 8px;";

    if (typeof options.onRetry === "function") {
      const retryBtn = document.createElement("button");
      retryBtn.type = "button";
      retryBtn.textContent = "Retry";
      retryBtn.style.cssText = btnStyle;
      retryBtn.addEventListener("click", () => {
        errorContainer.remove();
        options.onRetry();
      });
      actionsDiv.appendChild(retryBtn);
    }

    const refreshBtn = document.createElement("button");
    refreshBtn.type = "button";
    refreshBtn.textContent = "Refresh";
    refreshBtn.style.cssText = btnStyle;
    refreshBtn.addEventListener("click", () => window.location.reload());
    actionsDiv.appendChild(refreshBtn);

    const logoutBtn = document.createElement("button");
    logoutBtn.type = "button";
    logoutBtn.textContent = "Logout";
    logoutBtn.style.cssText = btnStyle;
    logoutBtn.addEventListener("click", () => handleLogout());
    actionsDiv.appendChild(logoutBtn);

    headerDiv.appendChild(actionsDiv);
    errorContainer.appendChild(headerDiv);

    // Keep keyboard focus inside the overlay: Tab cycles through the action
    // buttons instead of escaping into the broken page behind it.
    errorContainer.addEventListener("keydown", (event) => {
      if (event.key !== "Tab") return;
      const buttons = actionsDiv.querySelectorAll("button");
      const first = buttons[0];
      const last = buttons[buttons.length - 1];
      if (event.shiftKey && document.activeElement === first) {
        event.preventDefault();
        last.focus();
      } else if (!event.shiftKey && document.activeElement === last) {
        event.preventDefault();
        first.focus();
      }
    });

    // The error text itself lives inside a sandboxed iframe so any HTML
    // in the backend response cannot execute or affect the main page.
    const iframe = document.createElement("iframe");
    iframe.id = "errorIframe";
    iframe.style.cssText = "width: 100%; height: 100%; border: none; flex: 1;";
    iframe.setAttribute("sandbox", "allow-same-origin");
    errorContainer.appendChild(iframe);

    const preStyle =
      "margin:0;padding:8px;font-family:monospace;font-size:12px;white-space:pre-wrap;word-break:break-all;";
    const contentDocument = iframe.contentDocument;
    if (contentDocument) {
      const pre = contentDocument.createElement("pre");
      pre.style.cssText = preStyle;
      pre.textContent = errorMessage;
      const target = contentDocument.body || contentDocument.documentElement;
      target.appendChild(pre);
    } else {
      // The sandboxed iframe document was not reachable (sandbox/timing
      // edge). Never leave the fatal overlay empty: fall back to a plain
      // <pre> in the container. textContent does not parse HTML, so the
      // untrusted backend message still cannot execute.
      const pre = document.createElement("pre");
      pre.style.cssText = preStyle;
      pre.textContent = errorMessage;
      errorContainer.appendChild(pre);
    }

    // Move focus into the dialog so keyboard and screen-reader users land on
    // the primary action instead of the broken page behind the overlay.
    const firstButton = actionsDiv.querySelector("button");
    if (firstButton) firstButton.focus();
  }

  return { show, handleLogout, reopenErrorDialog };
});
