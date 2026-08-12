* =====================================================================
* GENERATED FILE - DO NOT EDIT (AGENTS.md rule 2)
* Embedded frontend resource, generated from app/webapp/ by
* .github/app2abap/trans2abap.js. Change the source under app/webapp/
* and run 'npm run app2abap' to regenerate; the check_app2abap CI gate
* fails any manual edit here.
* =====================================================================
CLASS z2ui5_cl_app_session_js DEFINITION
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


CLASS z2ui5_cl_app_session_js IMPLEMENTATION.

  METHOD get.

    result = `sap.ui.define(["sap/ui/Device", "z2ui5/core/Lib"], (Device, Lib) => {` && |\n| &&
             `  "use strict";` && |\n| &&
             `` && |\n| &&
             `  // ------------------------------------------------------------------` && |\n| &&
             `  // The session block of the request: what the backend only needs ONCE` && |\n| &&
             `  // per page load (the UI5 build, the static device profile, the` && |\n| &&
             `  // launchpad's ComponentData) plus the two device fields that stay live.` && |\n| &&
             `  // The backend stores the full block with the draft` && |\n| &&
             `  // (z2ui5_cl_core_handler=>session_merge), so every later roundtrip` && |\n| &&
             `  // sends only the live fields - a few hundred bytes off every event.` && |\n| &&
             `  // ------------------------------------------------------------------` && |\n| &&
             `` && |\n| &&
             `  // SYSTEM / BROWSER / OS / SUPPORT are fixed for the lifetime of the` && |\n| &&
             `  // session, so resolve them once and reuse the cached block.` && |\n| &&
             `  let deviceStatic;` && |\n| &&
             `  function getDeviceStatic() {` && |\n| &&
             `    if (!deviceStatic) {` && |\n| &&
             `      deviceStatic = {` && |\n| &&
             `        SYSTEM: Lib.deriveSystemType(Device.system),` && |\n| &&
             `        BROWSER: {` && |\n| &&
             `          NAME: Device.browser.name || "",` && |\n| &&
             `          VERSION: String(Device.browser.version || ""),` && |\n| &&
             `        },` && |\n| &&
             `        OS: {` && |\n| &&
             `          NAME: Device.os.name || "",` && |\n| &&
             `          VERSION: String(Device.os.version || ""),` && |\n| &&
             `        },` && |\n| &&
             `        SUPPORT: {` && |\n| &&
             `          TOUCH: Device.support.touch || false,` && |\n| &&
             `          POINTER: Device.support.pointer || false,` && |\n| &&
             `          RETINA: Device.support.retina || false,` && |\n| &&
             `        },` && |\n| &&
             `      };` && |\n| &&
             `    }` && |\n| &&
             `    return deviceStatic;` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  function getDeviceLive() {` && |\n| &&
             `    return {` && |\n| &&
             `      ORIENTATION: Device.orientation.portrait ? "portrait" : "landscape",` && |\n| &&
             `      RESIZE: {` && |\n| &&
             `        WIDTH: Device.resize.width || window.innerWidth,` && |\n| &&
             `        HEIGHT: Device.resize.height || window.innerHeight,` && |\n| &&
             `      },` && |\n| &&
             `    };` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  // Sent until it has gone out COMPLETE, not just once: the version info` && |\n| &&
             `  // is loaded asynchronously during component init, so the first roundtrip` && |\n| &&
             `  // can fire before it exists. Repeating it costs the same bytes it used` && |\n| &&
             `  // to cost every time, and stops as soon as there is something to store.` && |\n| &&
             `  //` && |\n| &&
             `  // A page load always starts by sending it again, which is what makes a` && |\n| &&
             `  // draft reopened on a different device pick up THAT device instead of` && |\n| &&
             `  // the one that created it.` && |\n| &&
             `  let sessionConfigSent = false;` && |\n| &&
             `` && |\n| &&
             `  // The last-sent live device values. Orientation and resize are the two` && |\n| &&
             `  // device fields that are NOT session-constant - but they change on a` && |\n| &&
             `  // rotation or window resize, not per click, so they only travel when` && |\n| &&
             `  // they differ from what was last sent. The backend stores every arrived` && |\n| &&
             `  // value with the draft and treats an absent field as "unchanged".` && |\n| &&
             `  let liveSent = "";` && |\n| &&
             `` && |\n| &&
             `  function config(oConfig) {` && |\n| &&
             `    const live = getDeviceLive();` && |\n| &&
             `    const liveKey = JSON.stringify(live);` && |\n| &&
             `    if (sessionConfigSent) {` && |\n| &&
             `      if (liveKey === liveSent) return {};` && |\n| &&
             `      liveSent = liveKey;` && |\n| &&
             `      return { S_DEVICE: live };` && |\n| &&
             `    }` && |\n| &&
             `    if (oConfig?.S_UI5) {` && |\n| &&
             `      sessionConfigSent = true;` && |\n| &&
             `      liveSent = liveKey;` && |\n| &&
             `    }` && |\n| &&
             `    return {` && |\n| &&
             `      S_UI5: oConfig?.S_UI5,` && |\n| &&
             `      ComponentData: oConfig?.ComponentData,` && |\n| &&
             `      S_DEVICE: { ...getDeviceStatic(), ...live },` && |\n| &&
             `    };` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  // The page location (origin, pathname, query) is session-constant like` && |\n| &&
             `  // the block above, but travels on its own cadence: with every app-start-` && |\n| &&
             `  // shaped request (no draft id - the backend parses ?app_start= from` && |\n| &&
             `  // SEARCH only there, and a route restore via Back/Forward is exactly` && |\n| &&
             `  // such a request) and on the page load's first roundtrip, so the backend` && |\n| &&
             `  // can store it with the draft (z2ui5_cl_core_handler=>session_merge).` && |\n| &&
             `  // Event roundtrips omit it. The hash is NOT part of this: it carries the` && |\n| &&
             `  // live routing state and stays a per-request field (Server.roundtrip).` && |\n| &&
             `  let locationSent = false;` && |\n| &&
             `` && |\n| &&
             `  function location(draftId, search) {` && |\n| &&
             `    if (draftId && locationSent) return null;` && |\n| &&
             `    locationSent = true;` && |\n| &&
             `    return {` && |\n| &&
             `      ORIGIN: window.location.origin,` && |\n| &&
             `      PATHNAME: window.location.pathname,` && |\n| &&
             `      SEARCH: search || window.location.search,` && |\n| &&
             `    };` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  return { config, location };` && |\n| &&
             `});` && |\n| &&
             `` && |\n| &&
              ``.

  ENDMETHOD.

ENDCLASS.
