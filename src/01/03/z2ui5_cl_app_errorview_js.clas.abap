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
             `sap.ui.define([], () => {` && |\n| &&
             `  "use strict";` && |\n| &&
             `` && |\n| &&
             `  // Errors longer than this are truncated before being shown to the user,` && |\n| &&
             `  // so a stack trace from the backend cannot blow up the error overlay.` && |\n| &&
             `  const ERROR_MAX_LENGTH = 50000;` && |\n| &&
             `` && |\n| &&
             `  function getOrCreateContainer() {` && |\n| &&
             `    const existing = document.getElementById("serverErrorContainer");` && |\n| &&
             `    if (existing) return existing;` && |\n| &&
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
             `  // Logout via the launchpad if available; otherwise hit the SAP logoff URL.` && |\n| &&
             `  function handleLogout() {` && |\n| &&
             `    const fallback = () => {` && |\n| &&
             `      window.location.href = "/sap/public/bc/icf/logoff";` && |\n| &&
             `    };` && |\n| &&
             `    try {` && |\n| &&
             `      if (z2ui5.oLaunchpad?.Container?.logout) {` && |\n| &&
             `        z2ui5.oLaunchpad.Container.logout();` && |\n| &&
             `      } else {` && |\n| &&
             `        fallback();` && |\n| &&
             `      }` && |\n| &&
             `    } catch (e) {` && |\n| &&
             `      fallback();` && |\n| &&
             `    }` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  // ``response`` may be a string or an Error object; ``title`` overrides the` && |\n| &&
             `  // default header text.` && |\n| &&
             `  function show(response, title) {` && |\n| &&
             `    const full = response?.stack ? String(response.stack) : String(response);` && |\n| &&
             `    let errorMessage;` && |\n| &&
             `    if (full.length > ERROR_MAX_LENGTH) {` && |\n| &&
             `      // Rendered via textContent, so use plain text (an HTML comment would` && |\n| &&
             `      // show up literally).` && |\n| &&
             `      errorMessage =` && |\n| &&
             `        full.slice(0, ERROR_MAX_LENGTH) +` && |\n| &&
             `        ``\n\n[... truncated after ${ERROR_MAX_LENGTH} characters]``;` && |\n| &&
             `    } else {` && |\n| &&
             `      errorMessage = full;` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    const errorContainer = getOrCreateContainer();` && |\n| &&
             `    errorContainer.textContent = "";` && |\n| &&
             `` && |\n| &&
             `    // Header bar with title and action buttons.` && |\n| &&
             `    const headerDiv = document.createElement("div");` && |\n| &&
             `    headerDiv.style.cssText =` && |\n| &&
             `      "padding: 15px; background: #d32f2f; color: white; display: flex; justify-content: space-between; align-items: center;";` && |\n| &&
             `` && |\n| &&
             `    const h3 = document.createElement("h3");` && |\n| &&
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
             `  }` && |\n| &&
             `` && |\n| &&
             `  return { show };` && |\n| &&
             `});` && |\n| &&
             `` && |\n| &&
              ``.

  ENDMETHOD.

ENDCLASS.
