sap.ui.define(["sap/ui/Device", "z2ui5/core/Lib"], (Device, Lib) => {
  "use strict";

  // ------------------------------------------------------------------
  // The session block of the request: what the backend only needs ONCE
  // per page load (the UI5 build, the static device profile, the
  // launchpad's ComponentData) plus the two device fields that stay live.
  // The backend stores the full block with the draft
  // (z2ui5_cl_ui5_handler=>session_merge), so every later roundtrip
  // sends only the live fields - a few hundred bytes off every event.
  //
  // The send latches are per component: they live on `ctx.session`
  // (core/Context.js), so two instances on a page each tell the backend
  // about the browser once. Only the static device profile is cached at
  // module level - it describes the browser, not the instance.
  // ------------------------------------------------------------------

  // SYSTEM / BROWSER / OS / SUPPORT are fixed for the lifetime of the
  // page, so resolve them once and reuse the cached block.
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

  // The latches of `ctx.session`:
  //   configSent   the static blocks - the device profile and the
  //                launchpad's ComponentData - have gone out. A page load
  //                always starts by sending them again, which is what
  //                makes a draft reopened on a different device pick up
  //                THAT device instead of the one that created it.
  //   ui5Sent      the UI5 version info has gone out. It is a latch of its
  //                own because the info is loaded asynchronously during
  //                component init (Component._initVersionInfo) and the
  //                first roundtrip fires before it exists - on purpose, the
  //                first paint does not wait for a network fetch. Until
  //                2026-10 the whole block counted as unsent while S_UI5
  //                was missing, so the second roundtrip of EVERY page load
  //                repeated the device profile and the ComponentData. Now
  //                the version info travels alone, on the first roundtrip
  //                that finds it loaded (the backend merges it into the
  //                stored block, z2ui5_cl_ui5_handler=>session_merge), and
  //                a page whose fetch failed sends nothing for it.
  //   liveSent     the last-sent live device values. Orientation and
  //                resize are the two device fields that are NOT
  //                session-constant - but they change on a rotation or
  //                window resize, not per click, so they only travel when
  //                they differ from what was last sent. The backend stores
  //                every arrived value with the draft and treats an absent
  //                field as "unchanged".
  //   pending      what the request being BUILT carries. The latches only
  //                advance in confirmSent( ), once that request won its
  //                stale guard (Server.readHttp) - a request may be aborted
  //                or superseded, and a latch advanced at build time would
  //                mark a value as known to the backend that never arrived
  //                there. Same protocol as the model delta's changed-paths
  //                clear. The token is PER REQUEST (takePending hands it to
  //                the roundtrip that carries the block): a retried request
  //                re-sends its own old body, so it must confirm what IT
  //                carried - not whatever was built last.
  //   locationSent the page location has gone out - see location( )

  // `draftId` mirrors location's cadence: an app-start-shaped request (no
  // draft id - page load, Back/Forward route restore, launchpad start)
  // always re-sends the WHOLE block. Such a request may start a FRESH app
  // whose backend session record is empty and has no draft to inherit
  // from - without the block it would stay empty for good, since event
  // roundtrips only send changes.
  function config(ctx, oConfig, draftId) {
    const latches = ctx.session;
    const live = getDeviceLive();
    const liveKey = JSON.stringify(live);
    const ui5 = oConfig?.S_UI5;
    if (latches.configSent && draftId) {
      // the version info alone, once it is there and not yet sent; the
      // live device fields only when they changed
      const sendUi5 = Boolean(ui5) && !latches.ui5Sent;
      const sendLive = liveKey !== latches.liveSent;
      if (!sendUi5 && !sendLive) {
        latches.pending = null;
        return {};
      }
      latches.pending = {
        ...(sendUi5 && { ui5: true }),
        ...(sendLive && { live: liveKey }),
      };
      return {
        ...(sendUi5 && { S_UI5: ui5 }),
        ...(sendLive && { S_DEVICE: live }),
      };
    }
    latches.pending = { config: true, ui5: Boolean(ui5), live: liveKey };
    return {
      S_UI5: ui5,
      ComponentData: oConfig?.ComponentData,
      S_DEVICE: { ...getDeviceStatic(), ...live },
    };
  }

  // Claim the just-built block's confirmation token for the request that
  // carries it.
  function takePending(ctx) {
    const p = ctx.session.pending;
    ctx.session.pending = null;
    return p;
  }

  // The carrying request won - what IT carried is now known to the backend.
  // Each latch advances only for the value THIS token actually carried: a
  // token built by location( ) alone has no `live`, and overwriting the live
  // key with undefined would re-send the device block for no reason.
  function confirmSent(ctx, p) {
    if (!p) return;
    const latches = ctx.session;
    if (p.config) latches.configSent = true;
    if (p.ui5) latches.ui5Sent = true;
    if (p.live !== undefined) latches.liveSent = p.live;
    if (p.location) latches.locationSent = true;
  }

  // The page location (origin, pathname, query) is session-constant like
  // the block above, but travels on its own cadence: with every app-start-
  // shaped request (no draft id - the backend parses ?app_start= from
  // SEARCH only there, and a route restore via Back/Forward is exactly
  // such a request) and on the page load's first roundtrip, so the backend
  // can store it with the draft (z2ui5_cl_ui5_handler=>session_merge).
  // Event roundtrips omit it. The hash is NOT part of this: it carries the
  // live routing state and stays a per-request field (Server.roundtrip).
  //
  // The latch is confirm-gated like the ones above, and for the same reason:
  // an app started FROM a draft id sends the location on a request that
  // already carries that id, and if that request is aborted or superseded a
  // build-time latch would leave the backend without an origin for good -
  // every later event roundtrip omits it.
  function location(ctx, draftId) {
    const latches = ctx.session;
    if (draftId && latches.locationSent) return null;
    // rides in the same per-request token as the session block, which
    // config( ) has already built (or cleared) by the time we get here
    latches.pending = { ...latches.pending, location: true };
    return {
      ORIGIN: window.location.origin,
      PATHNAME: window.location.pathname,
      SEARCH: window.location.search,
    };
  }

  // Back to page-load state (Component.exit): the context is torn down
  // with the component, but a host that keeps a context object around
  // must not find the old send state in it. deviceStatic stays: the
  // browser did not change.
  function reset(ctx) {
    const latches = ctx.session;
    latches.configSent = false;
    latches.ui5Sent = false;
    latches.liveSent = "";
    latches.pending = null;
    latches.locationSent = false;
  }

  return { config, takePending, confirmSent, location, reset };
});
