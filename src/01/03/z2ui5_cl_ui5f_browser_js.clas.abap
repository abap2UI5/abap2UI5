* =====================================================================
* GENERATED FILE - DO NOT EDIT (AGENTS.md rule 2)
* Embedded frontend resource, generated from app/webapp/ by
* .github/app2abap/trans2abap.js. Change the source under app/webapp/
* and run 'npm run app2abap' to regenerate; the check_app2abap CI gate
* fails any manual edit here.
* =====================================================================
CLASS z2ui5_cl_ui5f_browser_js DEFINITION
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


CLASS z2ui5_cl_ui5f_browser_js IMPLEMENTATION.

  METHOD get.

    result = `sap.ui.define(` && |\n| &&
             `  [` && |\n| &&
             `    "sap/m/MessageBox",` && |\n| &&
             `    "sap/m/library",` && |\n| &&
             `    "sap/ui/util/Storage",` && |\n| &&
             `    "z2ui5/core/Router",` && |\n| &&
             `    "z2ui5/core/Lib",` && |\n| &&
             `    "z2ui5/core/AppState",` && |\n| &&
             `  ],` && |\n| &&
             `  (MessageBox, mobileLibrary, Storage, Router, Lib, AppState) => {` && |\n| &&
             `    "use strict";` && |\n| &&
             `` && |\n| &&
             `    // ------------------------------------------------------------------` && |\n| &&
             `    // Actions against the BROWSER rather than a UI5 control: history and` && |\n| &&
             `    // URL, clipboard, downloads, storage, page title/favicon, logout,` && |\n| &&
             `    // audio. Everything URL-shaped is validated here - these are the` && |\n| &&
             `    // handlers that can navigate away or hand data out of the app.` && |\n| &&
             `    // ------------------------------------------------------------------` && |\n| &&
             `` && |\n| &&
             `    const _URLHelper = mobileLibrary.URLHelper;` && |\n| &&
             `` && |\n| &&
             `    // ------------------------------------------------------------------` && |\n| &&
             `    // Individual event handlers - one per entry in the dispatch table at` && |\n| &&
             `    // the bottom. Uniform signature (oController, args) so the dispatch` && |\n| &&
             `    // stays trivial; handlers that don't need the controller ignore it.` && |\n| &&
             `    // ------------------------------------------------------------------` && |\n| &&
             `` && |\n| &&
             `    function evClipboardCopy(oController, args) {` && |\n| &&
             `      Lib.copyToClipboard(args[1]);` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function evClipboardAppState() {` && |\n| &&
             `      // Guard against a missing response so the copied link never carries` && |\n| &&
             `      // the literal "undefined" as its state id.` && |\n| &&
             `      const id = AppState.state.oResponse?.ID || "";` && |\n| &&
             `      // Router.hrefFor drops the current app hash (e.g. an active app-state)` && |\n| &&
             `      // so the link carries only the fresh state id, but KEEPS the FLP shell` && |\n| &&
             `      // hash - without it the recipient lands on the launchpad home page` && |\n| &&
             `      // instead of this app.` && |\n| &&
             `      Lib.copyToClipboard(Router.hrefFor(``/z2ui5-xapp-state=${id}``));` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function evDownloadB64File(oController, args) {` && |\n| &&
             `      if (!Lib.isSafeDownloadURL(args[1])) {` && |\n| &&
             `        Lib.logError("DOWNLOAD_B64_FILE: blocked unsafe URL");` && |\n| &&
             `        return;` && |\n| &&
             `      }` && |\n| &&
             `      // A data: URL carrying active HTML combined with an attacker-chosen` && |\n| &&
             `      // .html/.hta filename is a known drive-by vector; block executable data:` && |\n| &&
             `      // MIME types outright (real downloads are octet-stream, images, pdf, ...).` && |\n| &&
             `      if (` && |\n| &&
             `        /^data:(text\/html|application\/xhtml|text\/xml|image\/svg)/i.test(` && |\n| &&
             `          args[1],` && |\n| &&
             `        )` && |\n| &&
             `      ) {` && |\n| &&
             `        Lib.logError("DOWNLOAD_B64_FILE: blocked active data: MIME type");` && |\n| &&
             `        return;` && |\n| &&
             `      }` && |\n| &&
             `      const a = document.createElement("a");` && |\n| &&
             `      a.href = args[1];` && |\n| &&
             `      // Fall back to an empty download attribute when the backend omits the` && |\n| &&
             `      // filename, so the anchor never carries the literal "undefined". Strip` && |\n| &&
             `      // path separators and control characters so the filename cannot escape` && |\n| &&
             `      // the download directory or carry a misleading name.` && |\n| &&
             `      // eslint-disable-next-line no-control-regex -- control chars are matched on purpose here` && |\n| &&
             `      a.download = String(args[2] || "").replace(/[\\/:*?"<>|\x00-\x1f]/g, "_");` && |\n| &&
             `      // Firefox only triggers a programmatic download click when the anchor` && |\n| &&
             `      // is part of the document, so attach it briefly and remove it again.` && |\n| &&
             `      document.body.appendChild(a);` && |\n| &&
             `      a.click();` && |\n| &&
             `      document.body.removeChild(a);` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function evStoreData(oController, args) {` && |\n| &&
             `      // Guard against a missing payload so the try below logs a` && |\n| &&
             `      // STORE_DATA-specific error instead of a generic dispatch failure.` && |\n| &&
             `      const { TYPE, PREFIX, VALUE, KEY } = args[1] ?? {};` && |\n| &&
             `      try {` && |\n| &&
             `        const storageType = Storage.Type[TYPE] || Storage.Type.session;` && |\n| &&
             `        const oStorage = new Storage(storageType, PREFIX);` && |\n| &&
             `        if (VALUE === "" || VALUE == null) {` && |\n| &&
             `          oStorage.remove(KEY);` && |\n| &&
             `        } else {` && |\n| &&
             `          oStorage.put(KEY, VALUE);` && |\n| &&
             `        }` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        Lib.logError(` && |\n| &&
             `          ``STORE_DATA: storage operation failed for key '${KEY}'``,` && |\n| &&
             `          e,` && |\n| &&
             `        );` && |\n| &&
             `      }` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function evLocationReload(oController, args) {` && |\n| &&
             `      if (Lib.isValidRedirectURL(args[1])) {` && |\n| &&
             `        window.location.href = args[1];` && |\n| &&
             `      } else {` && |\n| &&
             `        MessageBox.error(` && |\n| &&
             `          "Invalid redirect URL. Only relative URLs to the same domain are allowed.",` && |\n| &&
             `        );` && |\n| &&
             `      }` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // SYSTEM_LOGOUT: prefer the launchpad logout when running inside the` && |\n| &&
             `    // FLP; otherwise terminate a possible stateful BSP session first and` && |\n| &&
             `    // then navigate to the logout URL.` && |\n| &&
             `    function evSystemLogout(oController, args) {` && |\n| &&
             `      const logoutUrl = args[1] || "/sap/public/bc/icf/logoff";` && |\n| &&
             `      try {` && |\n| &&
             `        const container = AppState.state.oLaunchpad?.Container;` && |\n| &&
             `        // No explicit logout URL was passed (args is just the event name):` && |\n| &&
             `        // inside the launchpad, prefer its own logout over the BSP/ICF` && |\n| &&
             `        // redirect below.` && |\n| &&
             `        if (container?.logout && args.length <= 1) {` && |\n| &&
             `          container.logout();` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        Lib.logError("SYSTEM_LOGOUT: ushell logout failed", e);` && |\n| &&
             `      }` && |\n| &&
             `      logoutViaBspTerminate(logoutUrl);` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // When abap2UI5 is hosted as a BSP application,` && |\n| &&
             `    // /sap/public/bc/icf/logoff alone does not terminate the stateful` && |\n| &&
             `    // BSP context (sap-contextid stays bound to /sap/bc/bsp/sap/<app>/).` && |\n| &&
             `    // Hit the BSP path with ?sap-sessioncmd=logoff first so the BSP` && |\n| &&
             `    // runtime calls server->session->terminate( ), then go to the ICF` && |\n| &&
             `    // logoff to also drop the SSO2 ticket. Outside a BSP path this goes` && |\n| &&
             `    // straight to the logout URL.` && |\n| &&
             `    function logoutViaBspTerminate(logoutUrl) {` && |\n| &&
             `      const path = window.location.pathname;` && |\n| &&
             `      if (!path.startsWith("/sap/bc/bsp/")) {` && |\n| &&
             `        redirectToLogout(logoutUrl);` && |\n| &&
             `        return;` && |\n| &&
             `      }` && |\n| &&
             `` && |\n| &&
             `      // location.pathname never contains a query string, so "?" always starts` && |\n| &&
             `      // the sap-sessioncmd parameter` && |\n| &&
             `      const bspKill = ``${path}?sap-sessioncmd=logoff``;` && |\n| &&
             `      let done = false;` && |\n| &&
             `      let frame;` && |\n| &&
             `      const finish = () => {` && |\n| &&
             `        if (done) return;` && |\n| &&
             `        done = true;` && |\n| &&
             `        // Remove the hidden BSP-kill iframe. On a successful logout the page` && |\n| &&
             `        // navigates away and unload cleans up anyway; but if redirectToLogout` && |\n| &&
             `        // blocks an invalid URL (MessageBox, no navigation) the iframe would` && |\n| &&
             `        // otherwise leak - and accumulate over repeated logout attempts.` && |\n| &&
             `        if (frame) {` && |\n| &&
             `          try {` && |\n| &&
             `            frame.remove();` && |\n| &&
             `          } catch {` && |\n| &&
             `            /* already detached */` && |\n| &&
             `          }` && |\n| &&
             `          frame = null;` && |\n| &&
             `        }` && |\n| &&
             `        redirectToLogout(logoutUrl);` && |\n| &&
             `      };` && |\n| &&
             `      try {` && |\n| &&
             `        frame = document.createElement("iframe");` && |\n| &&
             `        frame.style.display = "none";` && |\n| &&
             `        frame.src = bspKill;` && |\n| &&
             `        frame.addEventListener("load", finish);` && |\n| &&
             `        document.body.appendChild(frame);` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        Lib.logError("SYSTEM_LOGOUT: BSP terminate iframe failed", e);` && |\n| &&
             `        finish();` && |\n| &&
             `        return;` && |\n| &&
             `      }` && |\n| &&
             `      // Safety net: never wait longer than 1.5s for the BSP terminate.` && |\n| &&
             `      setTimeout(finish, 1500);` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function redirectToLogout(logoutUrl) {` && |\n| &&
             `      if (Lib.isValidRedirectURL(logoutUrl)) {` && |\n| &&
             `        window.location.href = logoutUrl;` && |\n| &&
             `      } else {` && |\n| &&
             `        MessageBox.error(` && |\n| &&
             `          "Invalid logout URL. Only relative URLs to the same domain are allowed.",` && |\n| &&
             `        );` && |\n| &&
             `      }` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function evOpenNewTab(oController, args) {` && |\n| &&
             `      if (!Lib.isValidRedirectURL(args[1])) {` && |\n| &&
             `        MessageBox.error(` && |\n| &&
             `          "Invalid URL. Only relative URLs to the same domain are allowed.",` && |\n| &&
             `        );` && |\n| &&
             `        return;` && |\n| &&
             `      }` && |\n| &&
             `      const newWindow = window.open(args[1], "_blank");` && |\n| &&
             `      // Clear opener to prevent the new tab from accessing window.opener.` && |\n| &&
             `      if (newWindow) newWindow.opener = null;` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function evUrlHelper(oController, args) {` && |\n| &&
             `      const params = args[2] ?? {};` && |\n| &&
             `      // mailto:/sms:/tel: targets are handed to URLHelper as-is; a CR/LF in a` && |\n| &&
             `      // recipient/subject can inject extra headers in some mail clients.` && |\n| &&
             `      // Reject CR/LF in the string params up front.` && |\n| &&
             `      const hasCrLf = (v) => typeof v === "string" && /[\r\n]/.test(v);` && |\n| &&
             `      if (Object.values(params).some(hasCrLf)) {` && |\n| &&
             `        Lib.logError("URLHELPER: blocked CR/LF in parameters");` && |\n| &&
             `        return;` && |\n| &&
             `      }` && |\n| &&
             `      const actions = {` && |\n| &&
             `        REDIRECT: () => {` && |\n| &&
             `          if (!Lib.isSafeRedirectProtocol(params.URL)) {` && |\n| &&
             `            MessageBox.error(` && |\n| &&
             `              "Invalid redirect URL. Only http/https protocols are allowed.",` && |\n| &&
             `            );` && |\n| &&
             `            return;` && |\n| &&
             `          }` && |\n| &&
             `          _URLHelper.redirect(params.URL, params.NEW_WINDOW);` && |\n| &&
             `        },` && |\n| &&
             `        TRIGGER_EMAIL: () =>` && |\n| &&
             `          _URLHelper.triggerEmail(` && |\n| &&
             `            params.EMAIL,` && |\n| &&
             `            params.SUBJECT,` && |\n| &&
             `            params.BODY,` && |\n| &&
             `            params.CC,` && |\n| &&
             `            params.BCC,` && |\n| &&
             `            params.NEW_WINDOW,` && |\n| &&
             `          ),` && |\n| &&
             `        TRIGGER_SMS: () =>` && |\n| &&
             `          _URLHelper.triggerSms(params.TEL, params.TEXT, params.NEW_WINDOW),` && |\n| &&
             `        TRIGGER_TEL: () => _URLHelper.triggerTel(params.TEL),` && |\n| &&
             `      };` && |\n| &&
             `      try {` && |\n| &&
             `        const fn = actions[args[1]];` && |\n| &&
             `        if (fn) fn();` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        Lib.logError(``URLHELPER: '${args[1]}' failed``, e);` && |\n| &&
             `      }` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function evSetTitle(oController, args) {` && |\n| &&
             `      const title = Lib.toText(args[1]);` && |\n| &&
             `      try {` && |\n| &&
             `        document.title = title;` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        Lib.logError("SET_TITLE: setting document.title failed", e);` && |\n| &&
             `      }` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function evSetFavicon(oController, args) {` && |\n| &&
             `      const href = Lib.toText(args[1]);` && |\n| &&
             `      try {` && |\n| &&
             `        // Reuse the icon link the page already has instead of appending a` && |\n| &&
             `        // second one - which of two competing <link rel="icon"> elements the` && |\n| &&
             `        // browser honours is up to it, and an app that switches its icon` && |\n| &&
             `        // would otherwise leave one behind per change. ``~=`` matches one entry` && |\n| &&
             `        // of the whitespace-separated rel list, so a page declaring the` && |\n| &&
             `        // legacy rel="shortcut icon" is found too.` && |\n| &&
             `        const existing = document.head.querySelector('link[rel~="icon"]');` && |\n| &&
             `        if (existing) {` && |\n| &&
             `          existing.href = href;` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `        const link = document.createElement("link");` && |\n| &&
             `        link.rel = "icon";` && |\n| &&
             `        link.href = href;` && |\n| &&
             `        document.head.appendChild(link);` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        Lib.logError("SET_FAVICON: setting the favicon failed", e);` && |\n| &&
             `      }` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function evPlayAudio(oController, args) {` && |\n| &&
             `      // Only http(s)/data:/blob: sources are meaningful for Audio; validating` && |\n| &&
             `      // the protocol keeps this consistent with the other URL-consuming` && |\n| &&
             `      // actions and blocks odd schemes early.` && |\n| &&
             `      if (!Lib.isSafeDownloadURL(args[1])) {` && |\n| &&
             `        Lib.logError("PLAY_AUDIO: blocked unsafe audio URL");` && |\n| &&
             `        return;` && |\n| &&
             `      }` && |\n| &&
             `      try {` && |\n| &&
             `        const playing = new Audio(args[1]).play();` && |\n| &&
             `        // play() returns a Promise; a rejection (e.g. blocked by the` && |\n| &&
             `        // browser's autoplay policy) is not caught by the surrounding` && |\n| &&
             `        // try/catch and would surface as an unhandled rejection.` && |\n| &&
             `        if (playing?.catch) {` && |\n| &&
             `          playing.catch((e) =>` && |\n| &&
             `            Lib.logError(``PLAY_AUDIO: failed for '${args[1]}'``, e),` && |\n| &&
             `          );` && |\n| &&
             `        }` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        Lib.logError(``PLAY_AUDIO: failed for '${args[1]}'``, e);` && |\n| &&
             `      }` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // The events this module owns in the eF dispatch (see` && |\n| &&
             `    // core/FrontendAction.js, which merges the domain modules' handler maps).` && |\n| &&
             `    const handlers = {` && |\n| &&
             `      CLIPBOARD_COPY: evClipboardCopy,` && |\n| &&
             `      CLIPBOARD_APP_STATE: evClipboardAppState,` && |\n| &&
             `      DOWNLOAD_B64_FILE: evDownloadB64File,` && |\n| &&
             `      STORE_DATA: evStoreData,` && |\n| &&
             `      LOCATION_RELOAD: evLocationReload,` && |\n| &&
             `      SYSTEM_LOGOUT: evSystemLogout,` && |\n| &&
             `      OPEN_NEW_TAB: evOpenNewTab,` && |\n| &&
             `      URLHELPER: evUrlHelper,` && |\n| &&
             `      SET_TITLE: evSetTitle,` && |\n| &&
             `      SET_FAVICON: evSetFavicon,` && |\n| &&
             `      PLAY_AUDIO: evPlayAudio,` && |\n| &&
             `    };` && |\n| &&
             `` && |\n| &&
             `    return { handlers };` && |\n| &&
             `  },` && |\n| &&
             `);` && |\n| &&
             `` && |\n| &&
              ``.

  ENDMETHOD.

ENDCLASS.
