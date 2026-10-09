// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");
const { loadLib, withSpecController } = require("./loadLibModule");

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
  // the handlers read the launchpad services off the calling controller's
  // context; the spec's one context carries them
  const { Lib, state: libState, ctx } = loadLib({ state: { oLaunchpad } });

  const redirects = [];

  const { module: Launchpad } = loadModule("core/actions/Launchpad.js", {
    deps: {
      "sap/m/library": {
        URLHelper: {
          redirect: (...a) => redirects.push(a),
        },
      },
      "z2ui5/core/Lib": Lib,
      // the params of a handler-queued action arrive as a MODEL PATH and
      // are read from the TRACKED framework model, as STORE_DATA reads its
      // payload (browserActions spec)
      "z2ui5/core/ViewSlots": {
        trackedModel: (owner) => owner?.__tracked,
      },
    },
    sandbox: {
      window: { location: { href } },
    },
  });

  return {
    handlers: withSpecController(Launchpad.handlers, ctx).handlers,
    redirects,
    errors: () => (libState.errors || []).map((e) => e.message),
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

  // The handover form samples-stack documents is
  //   t_arg = ( `{ semanticObject: ... }` ) ( `$` && client->_bind( nav_params ) )
  // Wired in a VIEW, UI5 evaluates `${/NAV_PARAMS}` when the view is built
  // and the handler receives the structure. Queued from a HANDLER the action
  // is data (T_CUSTOM) and the very same argument arrives as the literal
  // string - which went into hrefForExternal as `params`, so the receiving
  // app started without its startup parameters and nothing said why.
  function navigator() {
    const hrefArgs = [];
    const toExternalArgs = [];
    return {
      hrefArgs,
      toExternalArgs,
      CrossAppNavigator: {
        hrefForExternal: (o) => {
          hrefArgs.push(o);
          return "#Other-app";
        },
        toExternal: (o) => toExternalArgs.push(o),
      },
    };
  }

  function viewWithModel(data) {
    const model = { getProperty: (path) => data[path] };
    const view = { __tracked: model };
    return { getView: () => view };
  }

  for (const spelling of ["${/NAV_PARAMS}", "{/NAV_PARAMS}", "/NAV_PARAMS"]) {
    test(`params given as the model path '${spelling}' are read from the model`, () => {
      const nav = navigator();
      const { handlers, errors } = load({ oLaunchpad: nav });

      handlers.CROSS_APP_NAV_TO_EXT(
        viewWithModel({ "/NAV_PARAMS": { PRODUCT: "P1", QUANTITY: "3" } }),
        [
          "CROSS_APP_NAV_TO_EXT",
          { semanticObject: "Other", action: "app" },
          spelling,
        ],
      );

      expect(nav.hrefArgs).toEqual([
        {
          target: { semanticObject: "Other", action: "app" },
          params: { PRODUCT: "P1", QUANTITY: "3" },
        },
      ]);
      expect(nav.toExternalArgs).toHaveLength(1);
      expect(errors()).toEqual([]);
    });
  }

  test("a model path with nothing bound is reported and does not navigate", () => {
    const nav = navigator();
    const { handlers, errors } = load({ oLaunchpad: nav });

    handlers.CROSS_APP_NAV_TO_EXT(viewWithModel({}), [
      "CROSS_APP_NAV_TO_EXT",
      { semanticObject: "Other", action: "app" },
      "${/NAV_PARAMS}",
    ]);

    expect(nav.hrefArgs).toEqual([]);
    expect(nav.toExternalArgs).toEqual([]);
    expect(errors()).toContain(
      "CROSS_APP_NAV_TO_EXT: nothing bound at the model path '/NAV_PARAMS' (params)",
    );
  });

  // The target is read like the params: a bound { semanticObject, action }
  // structure works from a view wire and, as a model path, from a handler.
  for (const spelling of ["{/S_TARGET}", "/S_TARGET"]) {
    test(`a target given as the model path '${spelling}' is read from the model`, () => {
      const nav = navigator();
      const { handlers, errors } = load({ oLaunchpad: nav });

      handlers.CROSS_APP_NAV_TO_EXT(
        viewWithModel({
          "/S_TARGET": { semanticObject: "Other", action: "app" },
        }),
        ["CROSS_APP_NAV_TO_EXT", spelling],
      );

      expect(nav.hrefArgs).toEqual([
        {
          target: { semanticObject: "Other", action: "app" },
          params: undefined,
        },
      ]);
      expect(nav.toExternalArgs).toHaveLength(1);
      expect(errors()).toEqual([]);
    });
  }

  // samples-stack wires the target as the JS object literal
  // `{ semanticObject: "...", action: "display" }`, which UI5 evaluates on a
  // view wire. Queued from a handler it is no JSON, arrived as the STRING,
  // and the shell navigated to a hash composed from nothing.
  test("an object-literal target queued from a handler is refused with the JSON hint", () => {
    const nav = navigator();
    const { handlers, redirects, errors } = load({ oLaunchpad: nav });

    handlers.CROSS_APP_NAV_TO_EXT(viewWithModel({}), [
      "CROSS_APP_NAV_TO_EXT",
      '{ semanticObject: "Z2UI5_CL_LP_SAMPLE_04",  action: "display" }',
      "",
      "EXT",
    ]);

    expect(nav.hrefArgs).toEqual([]);
    expect(nav.toExternalArgs).toEqual([]);
    expect(redirects).toEqual([]);
    expect(errors().some((m) => m.includes("spell it as JSON"))).toBe(true);
  });

  test("a target path with nothing bound is reported and does not navigate", () => {
    const nav = navigator();
    const { handlers, errors } = load({ oLaunchpad: nav });

    handlers.CROSS_APP_NAV_TO_EXT(viewWithModel({}), [
      "CROSS_APP_NAV_TO_EXT",
      "{/S_TARGET}",
    ]);

    expect(nav.hrefArgs).toEqual([]);
    expect(errors()).toContain(
      "CROSS_APP_NAV_TO_EXT: nothing bound at the model path '/S_TARGET' (target)",
    );
  });

  test("the empty params placeholder in front of EXT means no params", () => {
    const nav = navigator();
    const { handlers, redirects, errors } = load({ oLaunchpad: nav });

    handlers.CROSS_APP_NAV_TO_EXT({}, [
      "CROSS_APP_NAV_TO_EXT",
      { semanticObject: "Other", action: "app" },
      "",
      "EXT",
    ]);

    expect(nav.hrefArgs).toEqual([
      { target: { semanticObject: "Other", action: "app" }, params: undefined },
    ]);
    expect(redirects).toHaveLength(1);
    expect(errors()).toEqual([]);
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
