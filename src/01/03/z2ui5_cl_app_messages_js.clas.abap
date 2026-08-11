* =====================================================================
* GENERATED FILE - DO NOT EDIT (AGENTS.md rule 2)
* Embedded frontend resource, generated from app/webapp/ by
* .github/app2abap/trans2abap.js. Change the source under app/webapp/
* and run 'npm run app2abap' to regenerate; the check_app2abap CI gate
* fails any manual edit here.
* =====================================================================
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

    result = `// Displays a message toast / message box requested by the backend.` && |\n| &&
             `//` && |\n| &&
             `// The options arrive as a plain object already carrying the UI5 option names` && |\n| &&
             `// (duration, my, actions, ...): the backend sends only what the app actually` && |\n| &&
             `// set and normalizes everything it can decide on its own, so there is no` && |\n| &&
             `// mapping layer and no mirrored UI5 default here. What is left are the three` && |\n| &&
             `// things only the client can do - turn an ONCLOSE event name into a callback` && |\n| &&
             `// that round-trips through the controller's eB(), sanitize the message box` && |\n| &&
             `// details, and resolve a control id to the live element dependentOn needs.` && |\n| &&
             `sap.ui.define(` && |\n| &&
             `  [` && |\n| &&
             `    "sap/m/MessageBox",` && |\n| &&
             `    "sap/m/MessageToast",` && |\n| &&
             `    "z2ui5/core/Lib",` && |\n| &&
             `    "z2ui5/core/ViewSlots",` && |\n| &&
             `  ],` && |\n| &&
             `  (MessageBox, MessageToast, Lib, ViewSlots) => {` && |\n| &&
             `    "use strict";` && |\n| &&
             `` && |\n| &&
             `    // ``class`` is not a MessageToast option: a toast carries no id, so the` && |\n| &&
             `    // classes go onto the DOM node of the newest toast (several can be open at` && |\n| &&
             `    // once). The element may not exist right after show(), so retry once on the` && |\n| &&
             `    // next animation frame.` && |\n| &&
             `    function applyToastClass(sClass) {` && |\n| &&
             `      const classes = sClass.trim().split(/\s+/).filter(Boolean);` && |\n| &&
             `      if (!classes.length) return;` && |\n| &&
             `      const apply = () => {` && |\n| &&
             `        const toasts = document.querySelectorAll(".sapMMessageToast");` && |\n| &&
             `        const toastEl = toasts[toasts.length - 1];` && |\n| &&
             `        if (toastEl) toastEl.classList.add(...classes);` && |\n| &&
             `        return Boolean(toastEl);` && |\n| &&
             `      };` && |\n| &&
             `      if (!apply()) requestAnimationFrame(apply);` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function showToast(sText, mOptions, oController) {` && |\n| &&
             `      const o = { ...(mOptions || {}) };` && |\n| &&
             `      const sClass = o.class;` && |\n| &&
             `      delete o.class;` && |\n| &&
             `      if (o.onClose) {` && |\n| &&
             `        const sEvent = o.onClose;` && |\n| &&
             `        o.onClose = () => oController.eB([sEvent]);` && |\n| &&
             `      }` && |\n| &&
             `      MessageToast.show(sText, o);` && |\n| &&
             `      if (sClass) applyToastClass(sClass);` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function showBox(sType, sText, mOptions, oController) {` && |\n| &&
             `      const o = { ...(mOptions || {}) };` && |\n| &&
             `      if (o.onClose) {` && |\n| &&
             `        // the pressed action must ride OUTSIDE the event array: eB treats` && |\n| &&
             `        // args[0] as the event array (name + flags) and Server.roundtrip` && |\n| &&
             `        // shifts the WHOLE array away, so anything placed inside it never` && |\n| &&
             `        // reaches T_EVENT_ARG - the action then has to be the first` && |\n| &&
             `        // positional argument, like evImageEditorPopupClose's eB(["SAVE"], image)` && |\n| &&
             `        const sEvent = o.onClose;` && |\n| &&
             `        o.onClose = (sAction) => oController.eB([sEvent], sAction);` && |\n| &&
             `      }` && |\n| &&
             `      if (o.details) o.details = Lib.sanitizeMessageDetails(o.details);` && |\n| &&
             `      if (o.dependentOn) {` && |\n| &&
             `        // dependentOn (UI5 >= 1.124) ties the message box to an element's` && |\n| &&
             `        // lifecycle - the backend sends the control id, resolved here. A` && |\n| &&
             `        // missing/unresolvable id drops the option instead of passing a` && |\n| &&
             `        // string UI5 would choke on.` && |\n| &&
             `        const oDependentOn = ViewSlots.resolveById(o.dependentOn);` && |\n| &&
             `        if (oDependentOn) o.dependentOn = oDependentOn;` && |\n| &&
             `        else delete o.dependentOn;` && |\n| &&
             `      }` && |\n| &&
             `      // The backend lowercases the type, but an app can still spell one that` && |\n| &&
             `      // is no MessageBox display method at all. Restrict the lookup to` && |\n| &&
             `      // functions (MessageBox also carries enum objects like Action and Icon)` && |\n| &&
             `      // and never drop a requested message box silently: fall back to show().` && |\n| &&
             `      let showFn = MessageBox[sType];` && |\n| &&
             `      if (typeof showFn !== "function") {` && |\n| &&
             `        Lib.logError(` && |\n| &&
             `          ``Messages: unknown message box type '${sType}', shown via show()``,` && |\n| &&
             `        );` && |\n| &&
             `        showFn = MessageBox.show;` && |\n| &&
             `      }` && |\n| &&
             `      showFn(sText, o);` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    return { showToast, showBox };` && |\n| &&
             `  },` && |\n| &&
             `);` && |\n| &&
             `` && |\n| &&
              ``.

  ENDMETHOD.

ENDCLASS.
