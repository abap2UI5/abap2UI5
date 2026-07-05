CLASS z2ui5_cl_app_messages_js DEFINITION
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


CLASS z2ui5_cl_app_messages_js IMPLEMENTATION.

  METHOD get.

    result = `// Displays the message toast / message box that a backend response` && |\n| &&
             `// requested via the S_MSG_TOAST / S_MSG_BOX entries in PARAMS. The` && |\n| &&
             `// calling controller is only needed for the optional ONCLOSE follow-up` && |\n| &&
             `// events, which trigger a backend roundtrip through its eB().` && |\n| &&
             `sap.ui.define(` && |\n| &&
             `  ["sap/m/MessageBox", "sap/m/MessageToast", "z2ui5/core/Lib"],` && |\n| &&
             `  (MessageBox, MessageToast, Lib) => {` && |\n| &&
             `    "use strict";` && |\n| &&
             `` && |\n| &&
             `    // Parse a value as integer milliseconds, falling back to ``fallback``` && |\n| &&
             `    // when the input is empty / undefined / not a finite number (so a stray` && |\n| &&
             `    // non-numeric value never reaches MessageToast as NaN).` && |\n| &&
             `    function parseMs(val, fallback) {` && |\n| &&
             `      const parsed = Number(val);` && |\n| &&
             `      return val && Number.isFinite(parsed) ? parsed : fallback;` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function showToast(msg, oController) {` && |\n| &&
             `      MessageToast.show(msg.TEXT, {` && |\n| &&
             `        duration: parseMs(msg.DURATION, 3000),` && |\n| &&
             `        width: msg.WIDTH || "15em",` && |\n| &&
             `        onClose: msg.ONCLOSE ? () => oController.eB([msg.ONCLOSE]) : null,` && |\n| &&
             `        autoClose: Boolean(msg.AUTOCLOSE),` && |\n| &&
             `        animationTimingFunction: msg.ANIMATIONTIMINGFUNCTION || "ease",` && |\n| &&
             `        animationDuration: parseMs(msg.ANIMATIONDURATION, 1000),` && |\n| &&
             `        closeOnBrowserNavigation: Boolean(msg.CLOSEONBROWSERNAVIGATION),` && |\n| &&
             `      });` && |\n| &&
             `      if (msg.CLASS) {` && |\n| &&
             `        const classes = msg.CLASS.trim().split(/\s+/).filter(Boolean);` && |\n| &&
             `        // Pick the newest toast (several can be open at once). The` && |\n| &&
             `        // element may not be in the DOM yet right after show(), so` && |\n| &&
             `        // retry once on the next animation frame.` && |\n| &&
             `        const applyClass = () => {` && |\n| &&
             `          const toasts = document.querySelectorAll(".sapMMessageToast");` && |\n| &&
             `          const toastEl = toasts[toasts.length - 1];` && |\n| &&
             `          if (toastEl) toastEl.classList.add(...classes);` && |\n| &&
             `          return Boolean(toastEl);` && |\n| &&
             `        };` && |\n| &&
             `        if (!applyClass()) requestAnimationFrame(applyClass);` && |\n| &&
             `      }` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function showBox(msg, oController) {` && |\n| &&
             `      const oParams = {` && |\n| &&
             `        styleClass: msg.STYLECLASS || "",` && |\n| &&
             `        title: msg.TITLE || "",` && |\n| &&
             `        onClose: msg.ONCLOSE` && |\n| &&
             `          ? (sAction) => oController.eB([msg.ONCLOSE, sAction])` && |\n| &&
             `          : null,` && |\n| &&
             `        actions: msg.ACTIONS || "OK",` && |\n| &&
             `        emphasizedAction: msg.EMPHASIZEDACTION || "OK",` && |\n| &&
             `        initialFocus: msg.INITIALFOCUS || null,` && |\n| &&
             `        textDirection: msg.TEXTDIRECTION || "Inherit",` && |\n| &&
             `        details: msg.DETAILS ? Lib.sanitizeMessageDetails(msg.DETAILS) : "",` && |\n| &&
             `        closeOnNavigation: Boolean(msg.CLOSEONNAVIGATION),` && |\n| &&
             `      };` && |\n| &&
             `      if (msg.ICON && msg.ICON !== "NONE") oParams.icon = msg.ICON;` && |\n| &&
             `      // MessageBox display methods are lowercase (show, error, warning,` && |\n| &&
             `      // ...), but the type can arrive capitalized - the ABAP message` && |\n| &&
             `      // formatter sends e.g. "Error" for multi-message boxes - or as a` && |\n| &&
             `      // typo from an app. Restrict the lookup to functions (MessageBox` && |\n| &&
             `      // also carries enum objects like Action and Icon) and never drop a` && |\n| &&
             `      // requested message box silently: fall back to a plain show().` && |\n| &&
             `      let showFn = MessageBox[msg.TYPE];` && |\n| &&
             `      if (typeof showFn !== "function") {` && |\n| &&
             `        showFn = MessageBox[String(msg.TYPE).toLowerCase()];` && |\n| &&
             `      }` && |\n| &&
             `      if (typeof showFn !== "function") {` && |\n| &&
             `        Lib.logError(` && |\n| &&
             `          ``Messages: unknown message box type '${msg.TYPE}', shown via show()``,` && |\n| &&
             `        );` && |\n| &&
             `        showFn = MessageBox.show;` && |\n| &&
             `      }` && |\n| &&
             `      showFn(msg.TEXT, oParams);` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // Display the message of type ``msgType`` ("S_MSG_TOAST" / "S_MSG_BOX")` && |\n| &&
             `    // when the response params carry one.` && |\n| &&
             `    function show(msgType, params, oController) {` && |\n| &&
             `      if (!params) return;` && |\n| &&
             `      const msg = params[msgType];` && |\n| &&
             `      if (!msg || msg.TEXT === undefined) return;` && |\n| &&
             `` && |\n| &&
             `      if (msgType === "S_MSG_TOAST") {` && |\n| &&
             `        showToast(msg, oController);` && |\n| &&
             `      } else if (msgType === "S_MSG_BOX") {` && |\n| &&
             `        showBox(msg, oController);` && |\n| &&
             `      }` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    return { show };` && |\n| &&
             `  },` && |\n| &&
             `);` && |\n| &&
             `` && |\n| &&
              ``.

  ENDMETHOD.

ENDCLASS.
