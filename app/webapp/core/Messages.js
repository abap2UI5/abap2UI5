// Displays the message toast / message box that a backend response
// requested via the S_MSG_TOAST / S_MSG_BOX entries in PARAMS. The
// calling controller is only needed for the optional ONCLOSE follow-up
// events, which trigger a backend roundtrip through its eB().
sap.ui.define(
  ["sap/m/MessageBox", "sap/m/MessageToast", "z2ui5/core/Lib"],
  (MessageBox, MessageToast, Lib) => {
    "use strict";

    // Parse a value as integer milliseconds, falling back to `def` when the
    // input is empty / undefined / not a finite number (so a stray
    // non-numeric value never reaches MessageToast as NaN).
    function parseMs(val, def) {
      const n = +val;
      return val && Number.isFinite(n) ? n : def;
    }

    function showToast(msg, oController) {
      MessageToast.show(msg.TEXT, {
        duration: parseMs(msg.DURATION, 3000),
        width: msg.WIDTH || "15em",
        onClose: msg.ONCLOSE ? () => oController.eB([msg.ONCLOSE]) : null,
        autoClose: !!msg.AUTOCLOSE,
        animationTimingFunction: msg.ANIMATIONTIMINGFUNCTION || "ease",
        animationDuration: parseMs(msg.ANIMATIONDURATION, 1000),
        closeOnBrowserNavigation: !!msg.CLOSEONBROWSERNAVIGATION,
      });
      if (msg.CLASS) {
        const classes = msg.CLASS.trim().split(/\s+/).filter(Boolean);
        // Pick the newest toast (several can be open at once). The
        // element may not be in the DOM yet right after show(), so
        // retry once on the next animation frame.
        const applyClass = () => {
          const toasts = document.querySelectorAll(".sapMMessageToast");
          const toastEl = toasts[toasts.length - 1];
          if (toastEl) toastEl.classList.add(...classes);
          return !!toastEl;
        };
        if (!applyClass()) requestAnimationFrame(applyClass);
      }
    }

    function showBox(msg, oController) {
      const oParams = {
        styleClass: msg.STYLECLASS || "",
        title: msg.TITLE || "",
        onClose: msg.ONCLOSE
          ? (sAction) => oController.eB([msg.ONCLOSE, sAction])
          : null,
        actions: msg.ACTIONS || "OK",
        emphasizedAction: msg.EMPHASIZEDACTION || "OK",
        initialFocus: msg.INITIALFOCUS || null,
        textDirection: msg.TEXTDIRECTION || "Inherit",
        details: msg.DETAILS ? Lib.sanitizeMessageDetails(msg.DETAILS) : "",
        closeOnNavigation: !!msg.CLOSEONNAVIGATION,
      };
      if (msg.ICON && msg.ICON !== "NONE") oParams.icon = msg.ICON;
      const showFn = MessageBox[msg.TYPE];
      if (showFn) showFn(msg.TEXT, oParams);
    }

    // Display the message of type `msgType` ("S_MSG_TOAST" / "S_MSG_BOX")
    // when the response params carry one.
    function show(msgType, params, oController) {
      if (!params) return;
      const msg = params[msgType];
      if (!msg || msg.TEXT === undefined) return;

      if (msgType === "S_MSG_TOAST") {
        showToast(msg, oController);
      } else if (msgType === "S_MSG_BOX") {
        showBox(msg, oController);
      }
    }

    return { show };
  },
);
