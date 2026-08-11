sap.ui.define(["sap/ui/Device", "z2ui5/core/Lib"], (Device, Lib) => {
  "use strict";

  // ------------------------------------------------------------------
  // The session block of the request: what the backend only needs ONCE
  // per page load (the UI5 build, the static device profile, the
  // launchpad's ComponentData) plus the two device fields that stay live.
  // The backend stores the full block with the draft
  // (z2ui5_cl_core_handler=>session_merge), so every later roundtrip
  // sends only the live fields - a few hundred bytes off every event.
  // ------------------------------------------------------------------

  // SYSTEM / BROWSER / OS / SUPPORT are fixed for the lifetime of the
  // session, so resolve them once and reuse the cached block.
  let deviceStatic;
  function getDeviceStatic() {
    if (!deviceStatic) {
      deviceStatic = {
        SYSTEM: Lib.deriveSystemType(Device.system),
        BROWSER: {
          NAME: Device.browser.name || "",
          VERSION: String(Device.browser.version || ""),
        },
        OS: {
          NAME: Device.os.name || "",
          VERSION: String(Device.os.version || ""),
        },
        SUPPORT: {
          TOUCH: Device.support.touch || false,
          POINTER: Device.support.pointer || false,
          RETINA: Device.support.retina || false,
        },
      };
    }
    return deviceStatic;
  }

  function getDeviceLive() {
    return {
      ORIENTATION: Device.orientation.portrait ? "portrait" : "landscape",
      RESIZE: {
        WIDTH: Device.resize.width || window.innerWidth,
        HEIGHT: Device.resize.height || window.innerHeight,
      },
    };
  }

  // Sent until it has gone out COMPLETE, not just once: the version info
  // is loaded asynchronously during component init, so the first roundtrip
  // can fire before it exists. Repeating it costs the same bytes it used
  // to cost every time, and stops as soon as there is something to store.
  //
  // A page load always starts by sending it again, which is what makes a
  // draft reopened on a different device pick up THAT device instead of
  // the one that created it.
  let sessionConfigSent = false;

  function config(oConfig) {
    // orientation and resize are the two device fields that are NOT
    // session-constant - a window is resized and a phone rotated while
    // the app runs - so they travel every time and the backend merges
    // them over the block it stored.
    const live = getDeviceLive();
    if (sessionConfigSent) return { S_DEVICE: live };
    if (oConfig?.S_UI5) sessionConfigSent = true;
    return {
      S_UI5: oConfig?.S_UI5,
      ComponentData: oConfig?.ComponentData,
      S_DEVICE: { ...getDeviceStatic(), ...live },
    };
  }

  // The page location (origin, pathname, query) is session-constant like
  // the block above, but travels on its own cadence: with every app-start-
  // shaped request (no draft id - the backend parses ?app_start= from
  // SEARCH only there, and a route restore via Back/Forward is exactly
  // such a request) and on the page load's first roundtrip, so the backend
  // can store it with the draft (z2ui5_cl_core_handler=>session_merge).
  // Event roundtrips omit it. The hash is NOT part of this: it carries the
  // live routing state and stays a per-request field (Server.roundtrip).
  let locationSent = false;

  function location(draftId, search) {
    if (draftId && locationSent) return null;
    locationSent = true;
    return {
      ORIGIN: window.location.origin,
      PATHNAME: window.location.pathname,
      SEARCH: search || window.location.search,
    };
  }

  return { config, location };
});
