// Displays a message toast / message box requested by the backend.
//
// The options arrive as a plain object already carrying the UI5 option names
// (duration, my, actions, ...): the backend sends only what the app actually
// set and normalizes everything it can decide on its own, so there is no
// mapping layer and no mirrored UI5 default here. What is left are the three
// things only the client can do - turn an ONCLOSE event name into a callback
// that round-trips through the controller's eB(), sanitize the message box
// details, and resolve a control id to the live element dependentOn needs.
sap.ui.define(
  [
    "sap/m/MessageBox",
    "sap/m/MessageToast",
    "z2ui5/core/Lib",
    "z2ui5/core/ViewSlots",
  ],
  (MessageBox, MessageToast, Lib, ViewSlots) => {
    "use strict";

    // `class` is not a MessageToast option: a toast carries no id, so the
    // classes go onto the DOM node of the newest toast (several can be open at
    // once). The element may not exist right after show(), so retry once on the
    // next animation frame.
    function applyToastClass(sClass) {
      const classes = sClass.trim().split(/\s+/).filter(Boolean);
      if (!classes.length) return;
      const apply = () => {
        const toasts = document.querySelectorAll(".sapMMessageToast");
        const toastEl = toasts[toasts.length - 1];
        if (toastEl) toastEl.classList.add(...classes);
        return Boolean(toastEl);
      };
      if (!apply()) requestAnimationFrame(apply);
    }

    function showToast(sText, mOptions, oController) {
      const o = { ...(mOptions || {}) };
      const sClass = o.class;
      delete o.class;
      if (o.onClose) {
        const sEvent = o.onClose;
        o.onClose = () => oController.eB([sEvent]);
      }
      MessageToast.show(sText, o);
      if (sClass) applyToastClass(sClass);
    }

    function showBox(sType, sText, mOptions, oController) {
      const o = { ...(mOptions || {}) };
      if (o.onClose) {
        // the pressed action must ride OUTSIDE the event array: eB treats
        // args[0] as the event array (name + flags) and Server.roundtrip
        // shifts the WHOLE array away, so anything placed inside it never
        // reaches T_EVENT_ARG - the action then has to be the first
        // positional argument, like evImageEditorPopupClose's eB(["SAVE"], image)
        const sEvent = o.onClose;
        o.onClose = (sAction) => oController.eB([sEvent], sAction);
      }
      if (o.details) o.details = Lib.sanitizeMessageDetails(o.details);
      if (o.dependentOn) {
        // dependentOn (UI5 >= 1.124) ties the message box to an element's
        // lifecycle - the backend sends the control id, resolved here. A
        // missing/unresolvable id drops the option instead of passing a
        // string UI5 would choke on.
        const oDependentOn = ViewSlots.resolveById(o.dependentOn);
        if (oDependentOn) o.dependentOn = oDependentOn;
        else delete o.dependentOn;
      }
      // The backend lowercases the type, but an app can still spell one that
      // is no MessageBox display method at all. Restrict the lookup to
      // functions (MessageBox also carries enum objects like Action and Icon)
      // and never drop a requested message box silently: fall back to show().
      let showFn = MessageBox[sType];
      if (typeof showFn !== "function") {
        Lib.logError(
          `Messages: unknown message box type '${sType}', shown via show()`,
        );
        showFn = MessageBox.show;
      }
      showFn(sText, o);
    }

    return { showToast, showBox };
  },
);
