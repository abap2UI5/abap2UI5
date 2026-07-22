// Displays the message toast / message box that a backend response
// requested via the S_MSG_TOAST / S_MSG_BOX entries in PARAMS. The
// calling controller is only needed for the optional ONCLOSE follow-up
// events, which trigger a backend roundtrip through its eB().
sap.ui.define(
  [
    "sap/m/MessageBox",
    "sap/m/MessageToast",
    "sap/ui/core/Popup",
    "z2ui5/core/Lib",
    "z2ui5/core/ViewSlots",
  ],
  (MessageBox, MessageToast, Popup, Lib, ViewSlots) => {
    "use strict";

    // Parse a value as integer milliseconds, falling back to `fallback`
    // when the input is empty / undefined / not a finite number (so a stray
    // non-numeric value never reaches MessageToast as NaN).
    function parseMs(val, fallback) {
      const parsed = Number(val);
      return val && Number.isFinite(parsed) ? parsed : fallback;
    }

    // Resolve a dock position ("center bottom", "begin top", ...) to the
    // sap.ui.core.Popup.Dock value of the running UI5 version. Older UI5
    // keeps the jQuery-style "center bottom" spelling, newer UI5 switched
    // the enum to "CenterBottom" (and rejects the old form in MessageToast's
    // dock validation with a console error). Looking the position up by its
    // PascalCase key returns whichever spelling this version expects, so the
    // value validates on both. Unknown values are passed through unchanged.
    function toDockValue(pos) {
      if (!pos) return pos;
      const key = pos
        .trim()
        .split(/\s+/)
        .map((w) => w.charAt(0).toUpperCase() + w.slice(1).toLowerCase())
        .join("");
      return Popup.Dock[key] || pos;
    }

    function showToast(msg, oController) {
      // autoClose and closeOnBrowserNavigation are always sent (the public
      // API message_toast_display defaults both to abap_true), so Boolean()
      // is meaningful here - it never silently defeats UI5's own true default
      // the way it would for an omitted field. Same rationale as showBox's
      // closeOnNavigation below.
      const mOptions = {
        duration: parseMs(msg.DURATION, 3000),
        width: msg.WIDTH || "15em",
        onClose: msg.ONCLOSE ? () => oController.eB([msg.ONCLOSE]) : null,
        autoClose: Boolean(msg.AUTOCLOSE),
        animationTimingFunction: msg.ANIMATIONTIMINGFUNCTION || "ease",
        animationDuration: parseMs(msg.ANIMATIONDURATION, 1000),
        closeOnBrowserNavigation: Boolean(msg.CLOSEONBROWSERNAVIGATION),
      };
      // Only forward the position options the app actually set. sap.m.MessageToast
      // owns a default position AND a default vertical lift, but applies that lift
      // ONLY when none of my/at/of/offset is passed (its hasDefaultPosition check).
      // Passing any of them - even a value equal to UI5's own default - suppresses
      // the lift, so a bare toast would sit lower than a native MessageToast.show().
      // Omitting them lets UI5 own the defaults, so we never mirror (and drift from)
      // its internal values.
      if (msg.MY) mOptions.my = toDockValue(msg.MY);
      if (msg.AT) mOptions.at = toDockValue(msg.AT);
      if (msg.OF) mOptions.of = msg.OF;
      if (msg.OFFSET) mOptions.offset = msg.OFFSET;
      if (msg.COLLISION) mOptions.collision = msg.COLLISION;
      MessageToast.show(msg.TEXT, mOptions);
      if (msg.CLASS) {
        const classes = msg.CLASS.trim().split(/\s+/).filter(Boolean);
        // Pick the newest toast (several can be open at once). The
        // element may not be in the DOM yet right after show(), so
        // retry once on the next animation frame.
        const applyClass = () => {
          const toasts = document.querySelectorAll(".sapMMessageToast");
          const toastEl = toasts[toasts.length - 1];
          if (toastEl) toastEl.classList.add(...classes);
          return Boolean(toastEl);
        };
        if (!applyClass()) requestAnimationFrame(applyClass);
      }
    }

    function showBox(msg, oController) {
      // closeOnNavigation is always sent (ABAP DEFAULT abap_true, = UI5's own
      // default), so it is always meaningful to pass.
      const oParams = {
        closeOnNavigation: Boolean(msg.CLOSEONNAVIGATION),
      };
      // Only forward the options the app actually set. Each MessageBox method
      // (confirm, error, warning, success, ...) has its OWN sensible defaults -
      // e.g. confirm's [OK, CANCEL] or error's [CLOSE] action set, and the
      // emphasized action derived from them. Forcing actions/emphasizedAction
      // (or title/styleClass/textDirection/...) to a fixed value would override
      // those; omitting them lets UI5 apply its per-method defaults.
      if (msg.TITLE) oParams.title = msg.TITLE;
      if (msg.STYLECLASS) oParams.styleClass = msg.STYLECLASS;
      if (msg.ONCLOSE) {
        oParams.onClose = (sAction) => oController.eB([msg.ONCLOSE, sAction]);
      }
      if (msg.ACTIONS) oParams.actions = msg.ACTIONS;
      if (msg.EMPHASIZEDACTION) oParams.emphasizedAction = msg.EMPHASIZEDACTION;
      if (msg.INITIALFOCUS) oParams.initialFocus = msg.INITIALFOCUS;
      if (msg.TEXTDIRECTION) oParams.textDirection = msg.TEXTDIRECTION;
      if (msg.DETAILS)
        oParams.details = Lib.sanitizeMessageDetails(msg.DETAILS);
      if (msg.ICON && msg.ICON !== "NONE") oParams.icon = msg.ICON;
      if (msg.CONTENTWIDTH) oParams.contentWidth = msg.CONTENTWIDTH;
      // dependentOn (UI5 >= 1.124) adds the message box to an element's
      // lifecycle - the backend sends the control id, resolved to the element
      // here. A missing/unresolvable id drops the option silently.
      const oDependentOn = ViewSlots.resolveById(msg.DEPENDENTON);
      if (oDependentOn) oParams.dependentOn = oDependentOn;
      // MessageBox display methods are lowercase (show, error, warning,
      // ...), but the type can arrive capitalized - the ABAP message
      // formatter sends e.g. "Error" for multi-message boxes - or as a
      // typo from an app. Restrict the lookup to functions (MessageBox
      // also carries enum objects like Action and Icon) and never drop a
      // requested message box silently: fall back to a plain show().
      let showFn = MessageBox[msg.TYPE];
      if (typeof showFn !== "function") {
        showFn = MessageBox[String(msg.TYPE).toLowerCase()];
      }
      if (typeof showFn !== "function") {
        Lib.logError(
          `Messages: unknown message box type '${msg.TYPE}', shown via show()`,
        );
        showFn = MessageBox.show;
      }
      showFn(msg.TEXT, oParams);
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
