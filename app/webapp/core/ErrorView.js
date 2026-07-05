// The unified fatal-error overlay. Shown via Server.responseError whenever
// the app reaches an unrecoverable state - a failed roundtrip (network,
// HTTP != 2xx, bad JSON, backend dump) or a client-side failure (invalid
// view XML, post-render crash, missing SDK module). The only way out is a
// restart, hence the Refresh / Logout actions. Built from raw DOM so it
// still works when the UI5 core itself is in a broken state.
sap.ui.define([], () => {
  "use strict";

  // Errors longer than this are truncated before being shown to the user,
  // so a stack trace from the backend cannot blow up the error overlay.
  const ERROR_MAX_LENGTH = 50000;

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

  // Logout via the launchpad if available; otherwise hit the SAP logoff URL.
  function handleLogout() {
    const fallback = () => {
      window.location.href = "/sap/public/bc/icf/logoff";
    };
    try {
      if (z2ui5.oLaunchpad?.Container?.logout) {
        z2ui5.oLaunchpad.Container.logout();
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

  return { show };
});
