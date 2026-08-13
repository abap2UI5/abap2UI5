// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");

// Tests the location cadence of Server.roundtrip: ORIGIN/PATHNAME/SEARCH are
// session-constant, so the backend stores them with the draft
// (z2ui5_cl_ui5_handler=>session_merge) and event roundtrips omit them. They
// still travel with every app-start-shaped request (no draft id) - the
// backend parses ?app_start= from SEARCH only there, and a route restore
// (Back/Forward) is exactly such a request. HASH carries the live routing
// state and goes out every time.

function loadServer() {
  const bodies = [];
  // the cadence latch lives in core/Session.js - load the real module (a
  // fresh instance per test, so each test starts with an unsent location)
  const { module: Session } = loadModule("core/Session.js", {
    deps: {
      "sap/ui/Device": {
        system: {},
        browser: {},
        os: {},
        support: {},
        orientation: {},
        resize: {},
      },
      "z2ui5/core/Lib": { deriveSystemType: () => "" },
    },
    sandbox: {
      window: {
        location: {
          origin: "https://host",
          pathname: "/sap/bc/z2ui5",
          search: "?app_start=Z_MY_APP",
        },
      },
    },
  });
  const { module: Server } = loadModule("core/Server.js", {
    deps: {
      "z2ui5/core/Session": Session,
      "z2ui5/core/ScrollFocus": {
        getFocusInfo: () => undefined,
        getScrollInfo: () => undefined,
      },
      "z2ui5/core/Lib": {},
      "z2ui5/core/AppState": {
        state: {},
        getGlobal: () => undefined,
      },
    },
    sandbox: {
      window: {
        location: {
          origin: "https://host",
          pathname: "/sap/bc/z2ui5",
          search: "?app_start=Z_MY_APP",
          hash: "#/route",
        },
      },
    },
  });
  // capture what roundtrip hands to the HTTP layer instead of fetching
  Server.readHttp = (oBody) => bodies.push(oBody);
  return { Server, bodies };
}

test("the first roundtrip carries the location, an event roundtrip omits it", () => {
  const { Server, bodies } = loadServer();

  Server.roundtrip({});
  Server.roundtrip({ ID: "DRAFT1" });

  expect(bodies[0].S_FRONT.ORIGIN).toBe("https://host");
  expect(bodies[0].S_FRONT.PATHNAME).toBe("/sap/bc/z2ui5");
  expect(bodies[0].S_FRONT.SEARCH).toBe("?app_start=Z_MY_APP");
  expect(bodies[1].S_FRONT.ORIGIN).toBeUndefined();
  expect(bodies[1].S_FRONT.PATHNAME).toBeUndefined();
  expect(bodies[1].S_FRONT.SEARCH).toBeUndefined();
  // the hash stays live on every request
  expect(bodies[0].S_FRONT.HASH).toBe("#/route");
  expect(bodies[1].S_FRONT.HASH).toBe("#/route");
});

test("an app-start-shaped request re-sends the location (route restore)", () => {
  const { Server, bodies } = loadServer();

  Server.roundtrip({ ID: "DRAFT1" });
  // Back/Forward restore: empty body, no draft id - the backend takes the
  // first-start path and needs SEARCH/HASH to resolve the target
  Server.roundtrip({});

  expect(bodies[0].S_FRONT.ORIGIN).toBe("https://host");
  expect(bodies[1].S_FRONT.ORIGIN).toBe("https://host");
  expect(bodies[1].S_FRONT.SEARCH).toBe("?app_start=Z_MY_APP");
});
