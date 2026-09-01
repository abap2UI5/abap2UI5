// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");
const { loadLib } = require("./loadLibModule");

// Tests the handlers of core/actions/Launchpad.js - the actions against the
// SAP Fiori Launchpad shell. The launchpad services are injected at component
// start via AppState.state.oLaunchpad, so a spec can hand in a stub navigator
// and shell service and pin:
//   CROSS_APP_NAV_TO_PREV_APP  the backToPreviousApp forward, and the no-op
//                              with a log line outside the FLP
//   CROSS_APP_NAV_TO_EXT       hrefForExternal composition, the toExternal
//                              shell-hash navigation, and the EXT redirect
//                              through the REAL Lib.isValidRedirectURL guard
//   SET_TITLE_LAUNCHPAD        setTitle via ShellUIService, the deliberately
//                              silent absence (the service resolves async and
//                              can legitimately still be unset inside the FLP),
//                              and a rejecting setTitle caught into the log
function load({ oLaunchpad, href = "http://localhost:3000/sap/z2ui5" } = {}) {
  // The real Lib: its sandbox origin (http://localhost:3000, loadLibModule)
  // anchors the same-origin check of the EXT redirect.
  const { Lib, sandbox: libSandbox } = loadLib();

  const redirects = [];

  const { module: Launchpad } = loadModule("core/actions/Launchpad.js", {
    deps: {
      "sap/m/library": {
        URLHelper: {
          redirect: (...a) => redirects.push(a),
        },
      },
      "z2ui5/core/Lib": Lib,
      "z2ui5/core/AppState": { state: { oLaunchpad } },
    },
    sandbox: {
      window: { location: { href } },
    },
  });

  return {
    handlers: Launchpad.handlers,
    redirects,
    errors: () => (libSandbox.z2ui5.errors || []).map((e) => e.message),
  };
}

test.describe("CROSS_APP_NAV_TO_PREV_APP", () => {
  test("forwards to the navigator's backToPreviousApp", () => {
    const calls = [];
    const { handlers, errors } = load({
      oLaunchpad: {
        CrossAppNavigator: { backToPreviousApp: () => calls.push(1) },
      },
    });

    handlers.CROSS_APP_NAV_TO_PREV_APP({}, ["CROSS_APP_NAV_TO_PREV_APP"]);

    expect(calls).toEqual([1]);
    expect(errors()).toEqual([]);
  });

  test("outside the FLP it no-ops with a log line, never throws", () => {
    const { handlers, errors } = load();

    handlers.CROSS_APP_NAV_TO_PREV_APP({}, ["CROSS_APP_NAV_TO_PREV_APP"]);

    expect(errors()).toContain("CrossAppNav: not running inside Launchpad");
  });
});

test.describe("CROSS_APP_NAV_TO_EXT", () => {
  test("navigates via toExternal with the hrefForExternal shell hash", () => {
    const hrefArgs = [];
    const toExternalArgs = [];
    const { handlers, redirects, errors } = load({
      oLaunchpad: {
        CrossAppNavigator: {
          hrefForExternal: (o) => {
            hrefArgs.push(o);
            return "#Other-app?p=1";
          },
          toExternal: (o) => toExternalArgs.push(o),
        },
      },
    });

    handlers.CROSS_APP_NAV_TO_EXT({}, [
      "CROSS_APP_NAV_TO_EXT",
      { semanticObject: "Other", action: "app" },
      { p: "1" },
    ]);

    // target and params travel into hrefForExternal exactly as sent
    expect(hrefArgs).toEqual([
      {
        target: { semanticObject: "Other", action: "app" },
        params: { p: "1" },
      },
    ]);
    // the composed hash goes to the shell as a shellHash target
    expect(toExternalArgs).toEqual([
      { target: { shellHash: "#Other-app?p=1" } },
    ]);
    expect(redirects).toEqual([]);
    expect(errors()).toEqual([]);
  });

  test("EXT mode replaces the location, keeping the host before the hash", () => {
    const { handlers, redirects, errors } = load({
      href: "http://localhost:3000/sap/z2ui5#Old-app",
      oLaunchpad: {
        CrossAppNavigator: {
          hrefForExternal: () => "#Other-app",
          toExternal: () => {
            throw new Error("EXT must not go through toExternal");
          },
        },
      },
    });

    handlers.CROSS_APP_NAV_TO_EXT({}, [
      "CROSS_APP_NAV_TO_EXT",
      "Other-app",
      undefined,
      "EXT",
    ]);

    // base is the page without its old hash; true = no history entry
    expect(redirects).toEqual([["http://localhost:3000/sap/z2ui5#Other-app", true]]);
    expect(errors()).toEqual([]);
  });

  test("EXT mode refuses a URL the real Lib validator rejects", () => {
    // the base is same-origin by construction in the browser; the guard
    // still runs, so a foreign page context cannot smuggle a redirect out
    const { handlers, redirects, errors } = load({
      href: "https://evil.example/page",
      oLaunchpad: {
        CrossAppNavigator: {
          hrefForExternal: () => "#Other-app",
          toExternal: () => {},
        },
      },
    });

    handlers.CROSS_APP_NAV_TO_EXT({}, [
      "CROSS_APP_NAV_TO_EXT",
      "Other-app",
      undefined,
      "EXT",
    ]);

    expect(redirects).toEqual([]);
    expect(errors()).toContain(
      "CrossAppNav EXT: unsafe redirect URL 'https://evil.example/page#Other-app'",
    );
  });

  test("a navigator that throws is caught into the log, never up", () => {
    const { handlers, errors } = load({
      oLaunchpad: {
        CrossAppNavigator: {
          hrefForExternal: () => {
            throw new Error("boom");
          },
        },
      },
    });

    handlers.CROSS_APP_NAV_TO_EXT({}, ["CROSS_APP_NAV_TO_EXT", "X-y"]);

    expect(errors()).toContain("CrossAppNav: callback failed");
  });

  test("outside the FLP it no-ops with a log line", () => {
    const { handlers, redirects, errors } = load();

    handlers.CROSS_APP_NAV_TO_EXT({}, ["CROSS_APP_NAV_TO_EXT", "X-y"]);

    expect(redirects).toEqual([]);
    expect(errors()).toContain("CrossAppNav: not running inside Launchpad");
  });
});

test.describe("SET_TITLE_LAUNCHPAD", () => {
  test("hands the title text to ShellUIService.setTitle", () => {
    const titles = [];
    const { handlers, errors } = load({
      oLaunchpad: {
        ShellUIService: { setTitle: (t) => titles.push(t) },
      },
    });

    handlers.SET_TITLE_LAUNCHPAD({}, ["SET_TITLE_LAUNCHPAD", "My App"]);

    expect(titles).toEqual(["My App"]);
    expect(errors()).toEqual([]);
  });

  test("a missing shell service is a SILENT no-op", () => {
    // deliberate asymmetry to the cross-app-nav handlers: ShellUIService
    // resolves asynchronously and can legitimately still be unset inside
    // the FLP, so absence is not an error worth logging
    const { handlers, errors } = load();

    handlers.SET_TITLE_LAUNCHPAD({}, ["SET_TITLE_LAUNCHPAD", "My App"]);

    expect(errors()).toEqual([]);
  });

  test("a rejecting setTitle lands in the error log, not as an unhandled rejection", async () => {
    const { handlers, errors } = load({
      oLaunchpad: {
        ShellUIService: {
          setTitle: () => Promise.reject(new Error("shell says no")),
        },
      },
    });

    handlers.SET_TITLE_LAUNCHPAD({}, ["SET_TITLE_LAUNCHPAD", "My App"]);
    // the rejection is delivered asynchronously
    await new Promise((resolve) => setTimeout(resolve, 0));

    expect(errors()).toContain(
      "SET_TITLE_LAUNCHPAD: ShellUIService.setTitle failed",
    );
  });
});
