sap.ui.define(
  [
    "sap/m/MessageBox",
    "sap/m/library",
    "sap/ui/util/Storage",
    "z2ui5/core/Router",
    "z2ui5/core/Lib",
    "z2ui5/core/AppState",
  ],
  (MessageBox, mobileLibrary, Storage, Router, Lib, AppState) => {
    "use strict";

    // ------------------------------------------------------------------
    // Actions against the BROWSER rather than a UI5 control: history and
    // URL, clipboard, downloads, storage, page title/favicon, logout,
    // audio. Everything URL-shaped is validated here - these are the
    // handlers that can navigate away or hand data out of the app.
    // ------------------------------------------------------------------

    const _URLHelper = mobileLibrary.URLHelper;

    // ------------------------------------------------------------------
    // Individual event handlers - one per entry in the dispatch table at
    // the bottom. Uniform signature (oController, args) so the dispatch
    // stays trivial; handlers that don't need the controller ignore it.
    // ------------------------------------------------------------------

    function evClipboardCopy(oController, args) {
      Lib.copyToClipboard(args[1]);
    }

    function evClipboardAppState() {
      // Guard against a missing response so the copied link never carries
      // the literal "undefined" as its state id.
      const id = AppState.state.oResponse?.ID || "";
      // Router.hrefFor drops the current app hash (e.g. an active app-state)
      // so the link carries only the fresh state id, but KEEPS the FLP shell
      // hash - without it the recipient lands on the launchpad home page
      // instead of this app.
      Lib.copyToClipboard(Router.hrefFor(`/z2ui5-xapp-state=${id}`));
    }

    function evDownloadB64File(oController, args) {
      if (!Lib.isSafeDownloadURL(args[1])) {
        Lib.logError("DOWNLOAD_B64_FILE: blocked unsafe URL");
        return;
      }
      // A data: URL carrying active HTML combined with an attacker-chosen
      // .html/.hta filename is a known drive-by vector; block executable data:
      // MIME types outright (real downloads are octet-stream, images, pdf, ...).
      if (
        /^data:(text\/html|application\/xhtml|text\/xml|image\/svg)/i.test(
          args[1],
        )
      ) {
        Lib.logError("DOWNLOAD_B64_FILE: blocked active data: MIME type");
        return;
      }
      const a = document.createElement("a");
      a.href = args[1];
      // Fall back to an empty download attribute when the backend omits the
      // filename, so the anchor never carries the literal "undefined". Strip
      // path separators and control characters so the filename cannot escape
      // the download directory or carry a misleading name.
      // eslint-disable-next-line no-control-regex -- control chars are matched on purpose here
      a.download = String(args[2] || "").replace(/[\\/:*?"<>|\x00-\x1f]/g, "_");
      // Firefox only triggers a programmatic download click when the anchor
      // is part of the document, so attach it briefly and remove it again.
      document.body.appendChild(a);
      a.click();
      document.body.removeChild(a);
    }

    function evStoreData(oController, args) {
      // Guard against a missing payload so the try below logs a
      // STORE_DATA-specific error instead of a generic dispatch failure.
      const { TYPE, PREFIX, VALUE, KEY } = args[1] ?? {};
      try {
        const storageType = Storage.Type[TYPE] || Storage.Type.session;
        const oStorage = new Storage(storageType, PREFIX);
        if (VALUE === "" || VALUE == null) {
          oStorage.remove(KEY);
        } else {
          oStorage.put(KEY, VALUE);
        }
      } catch (e) {
        Lib.logError(
          `STORE_DATA: storage operation failed for key '${KEY}'`,
          e,
        );
      }
    }

    function evLocationReload(oController, args) {
      if (Lib.isValidRedirectURL(args[1])) {
        window.location.href = args[1];
      } else {
        MessageBox.error(
          "Invalid redirect URL. Only relative URLs to the same domain are allowed.",
        );
      }
    }

    // SYSTEM_LOGOUT: prefer the launchpad logout when running inside the
    // FLP; otherwise terminate a possible stateful BSP session first and
    // then navigate to the logout URL.
    function evSystemLogout(oController, args) {
      const logoutUrl = args[1] || "/sap/public/bc/icf/logoff";
      try {
        const container = AppState.state.oLaunchpad?.Container;
        // No explicit logout URL was passed (args is just the event name):
        // inside the launchpad, prefer its own logout over the BSP/ICF
        // redirect below.
        if (container?.logout && args.length <= 1) {
          container.logout();
          return;
        }
      } catch (e) {
        Lib.logError("SYSTEM_LOGOUT: ushell logout failed", e);
      }
      logoutViaBspTerminate(logoutUrl);
    }

    // When abap2UI5 is hosted as a BSP application,
    // /sap/public/bc/icf/logoff alone does not terminate the stateful
    // BSP context (sap-contextid stays bound to /sap/bc/bsp/sap/<app>/).
    // Hit the BSP path with ?sap-sessioncmd=logoff first so the BSP
    // runtime calls server->session->terminate( ), then go to the ICF
    // logoff to also drop the SSO2 ticket. Outside a BSP path this goes
    // straight to the logout URL.
    function logoutViaBspTerminate(logoutUrl) {
      const path = window.location.pathname;
      if (!path.startsWith("/sap/bc/bsp/")) {
        redirectToLogout(logoutUrl);
        return;
      }

      // location.pathname never contains a query string, so "?" always starts
      // the sap-sessioncmd parameter
      const bspKill = `${path}?sap-sessioncmd=logoff`;
      let done = false;
      let frame;
      const finish = () => {
        if (done) return;
        done = true;
        // Remove the hidden BSP-kill iframe. On a successful logout the page
        // navigates away and unload cleans up anyway; but if redirectToLogout
        // blocks an invalid URL (MessageBox, no navigation) the iframe would
        // otherwise leak - and accumulate over repeated logout attempts.
        if (frame) {
          try {
            frame.remove();
          } catch {
            /* already detached */
          }
          frame = null;
        }
        redirectToLogout(logoutUrl);
      };
      try {
        frame = document.createElement("iframe");
        frame.style.display = "none";
        frame.src = bspKill;
        frame.addEventListener("load", finish);
        document.body.appendChild(frame);
      } catch (e) {
        Lib.logError("SYSTEM_LOGOUT: BSP terminate iframe failed", e);
        finish();
        return;
      }
      // Safety net: never wait longer than 1.5s for the BSP terminate.
      setTimeout(finish, 1500);
    }

    function redirectToLogout(logoutUrl) {
      if (Lib.isValidRedirectURL(logoutUrl)) {
        window.location.href = logoutUrl;
      } else {
        MessageBox.error(
          "Invalid logout URL. Only relative URLs to the same domain are allowed.",
        );
      }
    }

    function evOpenNewTab(oController, args) {
      if (!Lib.isValidRedirectURL(args[1])) {
        MessageBox.error(
          "Invalid URL. Only relative URLs to the same domain are allowed.",
        );
        return;
      }
      const newWindow = window.open(args[1], "_blank");
      // Clear opener to prevent the new tab from accessing window.opener.
      if (newWindow) newWindow.opener = null;
    }

    function evUrlHelper(oController, args) {
      const params = args[2] ?? {};
      // mailto:/sms:/tel: targets are handed to URLHelper as-is; a CR/LF in a
      // recipient/subject can inject extra headers in some mail clients.
      // Reject CR/LF in the string params up front.
      const hasCrLf = (v) => typeof v === "string" && /[\r\n]/.test(v);
      if (Object.values(params).some(hasCrLf)) {
        Lib.logError("URLHELPER: blocked CR/LF in parameters");
        return;
      }
      const actions = {
        REDIRECT: () => {
          if (!Lib.isSafeRedirectProtocol(params.URL)) {
            MessageBox.error(
              "Invalid redirect URL. Only http/https protocols are allowed.",
            );
            return;
          }
          _URLHelper.redirect(params.URL, params.NEW_WINDOW);
        },
        TRIGGER_EMAIL: () =>
          _URLHelper.triggerEmail(
            params.EMAIL,
            params.SUBJECT,
            params.BODY,
            params.CC,
            params.BCC,
            params.NEW_WINDOW,
          ),
        TRIGGER_SMS: () =>
          _URLHelper.triggerSms(params.TEL, params.TEXT, params.NEW_WINDOW),
        TRIGGER_TEL: () => _URLHelper.triggerTel(params.TEL),
      };
      try {
        const fn = actions[args[1]];
        if (fn) fn();
      } catch (e) {
        Lib.logError(`URLHELPER: '${args[1]}' failed`, e);
      }
    }

    function evSetTitle(oController, args) {
      const title = Lib.toText(args[1]);
      try {
        document.title = title;
      } catch (e) {
        Lib.logError("SET_TITLE: setting document.title failed", e);
      }
    }

    function evSetFavicon(oController, args) {
      const href = Lib.toText(args[1]);
      // the one URL-consuming action that had no validator - no current
      // browser executes javascript: in a <link rel=icon>, but consistency
      // is what keeps the NEXT copy-paste of this shape safe
      if (!Lib.isSafeDownloadURL(href)) {
        Lib.logError(`SET_FAVICON: refused unsafe URL "${href}"`);
        return;
      }
      try {
        // Reuse the icon link the page already has instead of appending a
        // second one - which of two competing <link rel="icon"> elements the
        // browser honours is up to it, and an app that switches its icon
        // would otherwise leave one behind per change. `~=` matches one entry
        // of the whitespace-separated rel list, so a page declaring the
        // legacy rel="shortcut icon" is found too.
        const existing = document.head.querySelector('link[rel~="icon"]');
        if (existing) {
          existing.href = href;
          return;
        }
        const link = document.createElement("link");
        link.rel = "icon";
        link.href = href;
        document.head.appendChild(link);
      } catch (e) {
        Lib.logError("SET_FAVICON: setting the favicon failed", e);
      }
    }

    function evPlayAudio(oController, args) {
      // Only http(s)/data:/blob: sources are meaningful for Audio; validating
      // the protocol keeps this consistent with the other URL-consuming
      // actions and blocks odd schemes early.
      if (!Lib.isSafeDownloadURL(args[1])) {
        Lib.logError("PLAY_AUDIO: blocked unsafe audio URL");
        return;
      }
      try {
        const playing = new Audio(args[1]).play();
        // play() returns a Promise; a rejection (e.g. blocked by the
        // browser's autoplay policy) is not caught by the surrounding
        // try/catch and would surface as an unhandled rejection.
        if (playing?.catch) {
          playing.catch((e) =>
            Lib.logError(`PLAY_AUDIO: failed for '${args[1]}'`, e),
          );
        }
      } catch (e) {
        Lib.logError(`PLAY_AUDIO: failed for '${args[1]}'`, e);
      }
    }

    // The events this module owns in the eF dispatch (see
    // core/FrontendAction.js, which merges the domain modules' handler maps).
    const handlers = {
      CLIPBOARD_COPY: evClipboardCopy,
      CLIPBOARD_APP_STATE: evClipboardAppState,
      DOWNLOAD_B64_FILE: evDownloadB64File,
      STORE_DATA: evStoreData,
      LOCATION_RELOAD: evLocationReload,
      SYSTEM_LOGOUT: evSystemLogout,
      OPEN_NEW_TAB: evOpenNewTab,
      URLHELPER: evUrlHelper,
      SET_TITLE: evSetTitle,
      SET_FAVICON: evSetFavicon,
      PLAY_AUDIO: evPlayAudio,
    };

    return { handlers };
  },
);
