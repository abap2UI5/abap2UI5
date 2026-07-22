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
             `  [` && |\n| &&
             `    "sap/m/MessageBox",` && |\n| &&
             `    "sap/m/MessageToast",` && |\n| &&
             `    "sap/ui/core/Popup",` && |\n| &&
             `    "z2ui5/core/Lib",` && |\n| &&
             `    "z2ui5/core/ViewSlots",` && |\n| &&
             `  ],` && |\n| &&
             `  (MessageBox, MessageToast, Popup, Lib, ViewSlots) => {` && |\n| &&
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
             `    // Resolve a dock position ("center bottom", "begin top", ...) to the` && |\n| &&
             `    // sap.ui.core.Popup.Dock value of the running UI5 version. Older UI5` && |\n| &&
             `    // keeps the jQuery-style "center bottom" spelling, newer UI5 switched` && |\n| &&
             `    // the enum to "CenterBottom" (and rejects the old form in MessageToast's` && |\n| &&
             `    // dock validation with a console error). Looking the position up by its` && |\n| &&
             `    // PascalCase key returns whichever spelling this version expects, so the` && |\n| &&
             `    // value validates on both. Unknown values are passed through unchanged.` && |\n| &&
             `    function toDockValue(pos) {` && |\n| &&
             `      if (!pos) return pos;` && |\n| &&
             `      const key = pos` && |\n| &&
             `        .trim()` && |\n| &&
             `        .split(/\s+/)` && |\n| &&
             `        .map((w) => w.charAt(0).toUpperCase() + w.slice(1).toLowerCase())` && |\n| &&
             `        .join("");` && |\n| &&
             `      return Popup.Dock[key] || pos;` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function showToast(msg, oController) {` && |\n| &&
             `      // autoClose and closeOnBrowserNavigation are always sent (the public` && |\n| &&
             `      // API message_toast_display defaults both to abap_true), so Boolean()` && |\n| &&
             `      // is meaningful here - it never silently defeats UI5's own true default` && |\n| &&
             `      // the way it would for an omitted field. Same rationale as showBox's` && |\n| &&
             `      // closeOnNavigation below.` && |\n| &&
             `      const mOptions = {` && |\n| &&
             `        duration: parseMs(msg.DURATION, 3000),` && |\n| &&
             `        width: msg.WIDTH || "15em",` && |\n| &&
             `        onClose: msg.ONCLOSE ? () => oController.eB([msg.ONCLOSE]) : null,` && |\n| &&
             `        autoClose: Boolean(msg.AUTOCLOSE),` && |\n| &&
             `        animationTimingFunction: msg.ANIMATIONTIMINGFUNCTION || "ease",` && |\n| &&
             `        animationDuration: parseMs(msg.ANIMATIONDURATION, 1000),` && |\n| &&
             `        closeOnBrowserNavigation: Boolean(msg.CLOSEONBROWSERNAVIGATION),` && |\n| &&
             `      };` && |\n| &&
             `      // Only forward the position options the app actually set. sap.m.MessageToast` && |\n| &&
             `      // owns a default position AND a default vertical lift, but applies that lift` && |\n| &&
             `      // ONLY when none of my/at/of/offset is passed (its hasDefaultPosition check).` && |\n| &&
             `      // Passing any of them - even a value equal to UI5's own default - suppresses` && |\n| &&
             `      // the lift, so a bare toast would sit lower than a native MessageToast.show().` && |\n| &&
             `      // Omitting them lets UI5 own the defaults, so we never mirror (and drift from)` && |\n| &&
             `      // its internal values.` && |\n| &&
             `      if (msg.MY) mOptions.my = toDockValue(msg.MY);` && |\n| &&
             `      if (msg.AT) mOptions.at = toDockValue(msg.AT);` && |\n| &&
             `      if (msg.OF) mOptions.of = msg.OF;` && |\n| &&
             `      if (msg.OFFSET) mOptions.offset = msg.OFFSET;` && |\n| &&
             `      if (msg.COLLISION) mOptions.collision = msg.COLLISION;` && |\n| &&
             `      MessageToast.show(msg.TEXT, mOptions);` && |\n| &&
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
             `      // closeOnNavigation is always sent (ABAP DEFAULT abap_true, = UI5's own` && |\n| &&
             `      // default), so it is always meaningful to pass.` && |\n| &&
             `      const oParams = {` && |\n| &&
             `        closeOnNavigation: Boolean(msg.CLOSEONNAVIGATION),` && |\n| &&
             `      };` && |\n| &&
             `      // Only forward the options the app actually set. Each MessageBox method` && |\n| &&
             `      // (confirm, error, warning, success, ...) has its OWN sensible defaults -` && |\n| &&
             `      // e.g. confirm's [OK, CANCEL] or error's [CLOSE] action set, and the` && |\n| &&
             `      // emphasized action derived from them. Forcing actions/emphasizedAction` && |\n| &&
             `      // (or title/styleClass/textDirection/...) to a fixed value would override` && |\n| &&
             `      // those; omitting them lets UI5 apply its per-method defaults.` && |\n| &&
             `      if (msg.TITLE) oParams.title = msg.TITLE;` && |\n| &&
             `      if (msg.STYLECLASS) oParams.styleClass = msg.STYLECLASS;` && |\n| &&
             `      if (msg.ONCLOSE) {` && |\n| &&
             `        oParams.onClose = (sAction) => oController.eB([msg.ONCLOSE, sAction]);` && |\n| &&
             `      }` && |\n| &&
             `      if (msg.ACTIONS) oParams.actions = msg.ACTIONS;` && |\n| &&
             `      if (msg.EMPHASIZEDACTION) oParams.emphasizedAction = msg.EMPHASIZEDACTION;` && |\n| &&
             `      if (msg.INITIALFOCUS) oParams.initialFocus = msg.INITIALFOCUS;` && |\n| &&
             `      if (msg.TEXTDIRECTION) oParams.textDirection = msg.TEXTDIRECTION;` && |\n| &&
             `      if (msg.DETAILS)` && |\n| &&
             `        oParams.details = Lib.sanitizeMessageDetails(msg.DETAILS);` && |\n| &&
             `      if (msg.ICON && msg.ICON !== "NONE") oParams.icon = msg.ICON;` && |\n| &&
             `      if (msg.CONTENTWIDTH) oParams.contentWidth = msg.CONTENTWIDTH;` && |\n| &&
             `      // dependentOn (UI5 >= 1.124) adds the message box to an element's` && |\n| &&
             `      // lifecycle - the backend sends the control id, resolved to the element` && |\n| &&
             `      // here. A missing/unresolvable id drops the option silently.` && |\n| &&
             `      const oDependentOn = ViewSlots.resolveById(msg.DEPENDENTON);` && |\n| &&
             `      if (oDependentOn) oParams.dependentOn = oDependentOn;` && |\n| &&
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
