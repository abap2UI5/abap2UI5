* =====================================================================
* GENERATED FILE - DO NOT EDIT (AGENTS.md rule 2)
* Embedded frontend resource, generated from app/webapp/ by
* .github/app2abap/trans2abap.js. Change the source under app/webapp/
* and run 'npm run app2abap' to regenerate; the check_app2abap CI gate
* fails any manual edit here.
* =====================================================================
CLASS z2ui5_cl_ui5f_launchpd_js DEFINITION
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


CLASS z2ui5_cl_ui5f_launchpd_js IMPLEMENTATION.

  METHOD get.

    result = `sap.ui.define(` && |\n| &&
             `  ["sap/m/library", "z2ui5/core/Lib", "z2ui5/core/AppState"],` && |\n| &&
             `  (mobileLibrary, Lib, AppState) => {` && |\n| &&
             `    "use strict";` && |\n| &&
             `` && |\n| &&
             `    // ------------------------------------------------------------------` && |\n| &&
             `    // Actions against the SAP Fiori Launchpad shell: cross-app navigation` && |\n| &&
             `    // and the shell title. They all resolve the launchpad services captured` && |\n| &&
             `    // at component start (AppState.state.oLaunchpad). The cross-app-nav` && |\n| &&
             `    // handlers no-op with a log line outside the FLP; the title handler is` && |\n| &&
             `    // deliberately silent, because ShellUIService resolves asynchronously` && |\n| &&
             `    // and can legitimately still be unset inside the FLP.` && |\n| &&
             `    // ------------------------------------------------------------------` && |\n| &&
             `` && |\n| &&
             `    const _URLHelper = mobileLibrary.URLHelper;` && |\n| &&
             `` && |\n| &&
             `    // ------------------------------------------------------------------` && |\n| &&
             `    // Launchpad helpers` && |\n| &&
             `    // ------------------------------------------------------------------` && |\n| &&
             `` && |\n| &&
             `    function withCrossAppNavigator(callback) {` && |\n| &&
             `      const nav = AppState.state.oLaunchpad?.CrossAppNavigator;` && |\n| &&
             `      if (!nav) {` && |\n| &&
             `        Lib.logError("CrossAppNav: not running inside Launchpad");` && |\n| &&
             `        return;` && |\n| &&
             `      }` && |\n| &&
             `      try {` && |\n| &&
             `        callback(nav);` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        Lib.logError("CrossAppNav: callback failed", e);` && |\n| &&
             `      }` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function evCrossAppNavToPrevApp() {` && |\n| &&
             `      withCrossAppNavigator((nav) => nav.backToPreviousApp());` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function evCrossAppNavToExt(oController, args) {` && |\n| &&
             `      withCrossAppNavigator((nav) => {` && |\n| &&
             `        const hash =` && |\n| &&
             `          nav.hrefForExternal({ target: args[1], params: args[2] }) || "";` && |\n| &&
             `        if (args[3] === "EXT") {` && |\n| &&
             `          // External redirect: replace the location while keeping the host.` && |\n| &&
             `          // base is the current page (same origin) + a shell-hash fragment,` && |\n| &&
             `          // so this is same-origin by construction; validate anyway to stay` && |\n| &&
             `          // consistent with every other redirect handler in this file.` && |\n| &&
             `          const base = window.location.href.split("#")[0];` && |\n| &&
             `          const url = ``${base}${hash}``;` && |\n| &&
             `          if (!Lib.isValidRedirectURL(url)) {` && |\n| &&
             `            Lib.logError(``CrossAppNav EXT: unsafe redirect URL '${url}'``);` && |\n| &&
             `            return;` && |\n| &&
             `          }` && |\n| &&
             `          _URLHelper.redirect(url, true);` && |\n| &&
             `        } else {` && |\n| &&
             `          nav.toExternal({ target: { shellHash: hash } });` && |\n| &&
             `        }` && |\n| &&
             `      });` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function evSetTitleLaunchpad(oController, args) {` && |\n| &&
             `      const title = Lib.toText(args[1]);` && |\n| &&
             `      try {` && |\n| &&
             `        const shell = AppState.state.oLaunchpad?.ShellUIService;` && |\n| &&
             `        if (shell?.setTitle) {` && |\n| &&
             `          const result = shell.setTitle(title);` && |\n| &&
             `          if (result?.catch) {` && |\n| &&
             `            result.catch((e) =>` && |\n| &&
             `              Lib.logError(` && |\n| &&
             `                "SET_TITLE_LAUNCHPAD: ShellUIService.setTitle failed",` && |\n| &&
             `                e,` && |\n| &&
             `              ),` && |\n| &&
             `            );` && |\n| &&
             `          }` && |\n| &&
             `        }` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        Lib.logError("SET_TITLE_LAUNCHPAD: ShellUIService.setTitle failed", e);` && |\n| &&
             `      }` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // The events this module owns in the eF dispatch (see` && |\n| &&
             `    // core/FrontendAction.js, which merges the domain modules' handler maps).` && |\n| &&
             `    const handlers = {` && |\n| &&
             `      CROSS_APP_NAV_TO_PREV_APP: evCrossAppNavToPrevApp,` && |\n| &&
             `      CROSS_APP_NAV_TO_EXT: evCrossAppNavToExt,` && |\n| &&
             `      SET_TITLE_LAUNCHPAD: evSetTitleLaunchpad,` && |\n| &&
             `    };` && |\n| &&
             `` && |\n| &&
             `    return { handlers };` && |\n| &&
             `  },` && |\n| &&
             `);` && |\n| &&
             `` && |\n| &&
              ``.

  ENDMETHOD.

ENDCLASS.
