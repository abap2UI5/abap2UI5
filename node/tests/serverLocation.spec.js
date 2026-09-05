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
  const cancels = [];
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
      // restoreFromRoute hands the timer cancel to the shared helper - the
      // stub only records that it was asked (Lib's own spec proves it clears)
      "z2ui5/core/Lib": {
        cancelPendingTimers: () => cancels.push("cancelPendingTimers"),
      },
      "sap/ui/core/BusyIndicator": { show: () => {}, hide: () => {} },
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
  // Capture what roundtrip hands to the HTTP layer instead of fetching. The
  // real readHttp confirms the request's token once the response wins its
  // stale guard - do the same here, so the latches advance exactly as they do
  // in the browser. `drop` simulates a request that never got there.
  let drop = false;
  Server.readHttp = (oBody, token) => {
    bodies.push(oBody);
    if (!drop) Session.confirmSent(token);
  };
  const dropNext = (v = true) => {
    drop = v;
  };
  return { Server, bodies, dropNext, cancels };
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

test("a dropped request does not latch the location - the next one re-sends it", () => {
  const { Server, bodies, dropNext } = loadServer();

  // an app started FROM a draft id: the location travels on a request that
  // already carries that id, so the app-start-shaped re-send does not apply
  dropNext();
  Server.roundtrip({ ID: "DRAFT1" });
  dropNext(false);
  Server.roundtrip({ ID: "DRAFT1" });

  expect(bodies[0].S_FRONT.ORIGIN).toBe("https://host");
  // the first request never reached the backend, so the second still carries it
  expect(bodies[1].S_FRONT.ORIGIN).toBe("https://host");
  expect(bodies[1].S_FRONT.PATHNAME).toBe("/sap/bc/z2ui5");

  Server.roundtrip({ ID: "DRAFT1" });
  expect(bodies[2].S_FRONT.ORIGIN).toBeUndefined();
});

// A restore is a new roundtrip, so the timers armed by the screen being left
// go with it - the same cancel View1.eB does before its own dispatch. This
// path had none, so a poll armed one Back ago kept ticking its old event into
// the app the restore had just brought up.
test("the Back/Forward restore cancels the timers of the screen it leaves", () => {
  const { Server, bodies, cancels } = loadServer();

  Server.restoreFromRoute();

  expect(cancels).toEqual(["cancelPendingTimers"]);
  // and it is still the app-start-shaped request the backend resolves the
  // route from
  expect(bodies).toHaveLength(1);
  expect(bodies[0].ID).toBeUndefined();
});
