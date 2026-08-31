// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");

// Tests core/Router.js - the hash router (UI5 Router style). Three areas:
//
//  1. splitHash / hrefFor: the FLP shell hash vs. the app hash. Inside the
//     launchpad the browser hash is "#<SemanticObject>-<action>&/<app hash>";
//     the shell owns the part before "&/" and only what follows belongs to the
//     running app. Every read and every URL the router builds has to respect
//     that, or the launchpad loses the tile the user is on.
//  2. parse / patternFor: the route "app/{class}/{state}" - KEEP routes carry
//     the app state as a draft id, FRESH routes carry the class only.
//  3. onHashChanged (read side) and sync (write side): which history entry a
//     roundtrip touches, and when a hash change triggers a restore.

const CALLER = "Z2UI5_CL_CALLER";
const CALLEE = "Z2UI5_CL_CALLEE";
const FLP_SHELL = "Z2UI5App-display";

function loadRouter({ state: stateOverrides = {}, hash = "", href } = {}) {
  // records every hash write plus the echo guard (currentDraftId) in place at
  // that moment - onHashChanged compares against it
  const writes = [];
  let current = hash;
  const hashChanger = {
    getHash: () => current,
    setHash: (h) => {
      writes.push({ op: "set", hash: h, guard: state.currentDraftId });
      current = h;
    },
    replaceHash: (h) => {
      writes.push({ op: "replace", hash: h, guard: state.currentDraftId });
      current = h;
    },
    attachEvent: () => {},
    detachEvent: () => {},
    init: () => {},
  };
  const state = {
    navRouting: true,
    navMode: "KEEP",
    currentApp: CALLER,
    currentDraftId: "D1",
    navFromHash: false,
    ...stateOverrides,
  };
  const pushes = [];
  const errors = [];
  const location = {
    href: href || "https://host/sap/z2ui5",
    hash: href && href.includes("#") ? `#${href.split("#")[1]}` : "",
    pathname: "/sap/z2ui5",
    search: "",
  };
  const { module: Router } = loadModule("core/Router.js", {
    deps: {
      "sap/ui/core/routing/HashChanger": { getInstance: () => hashChanger },
      "z2ui5/core/AppState": { state },
      "z2ui5/core/Lib": {
        logError: (msg, e) => errors.push({ msg, e }),
        isDestroyed: (o) => !!(o && o.destroyed),
      },
    },
    sandbox: {
      window: { location },
      history: { pushState: (a, b, url) => pushes.push(url) },
    },
  });
  return {
    Router,
    state,
    writes,
    pushes,
    errors,
    setHash: (h) => {
      current = h;
    },
  };
}

// ---------------------------------------------------------------------------
// 1. FLP shell hash vs. app hash
// ---------------------------------------------------------------------------

test("splitHash separates the FLP shell hash from the app hash", () => {
  const { Router } = loadRouter();
  expect(Router.splitHash(`#${FLP_SHELL}&/app/${CALLER}/D1`)).toEqual({
    shell: FLP_SHELL,
    app: `/app/${CALLER}/D1`,
  });
  // shell hash with its own parameters
  expect(Router.splitHash(`#${FLP_SHELL}?a=b&c=d&/app/${CALLER}`)).toEqual({
    shell: `${FLP_SHELL}?a=b&c=d`,
    app: `/app/${CALLER}`,
  });
  // standalone - no shell hash at all, with and without the leading "#"
  expect(Router.splitHash(`#/app/${CALLER}/D1`)).toEqual({
    shell: "",
    app: `/app/${CALLER}/D1`,
  });
  expect(Router.splitHash(`/app/${CALLER}/D1`)).toEqual({
    shell: "",
    app: `/app/${CALLER}/D1`,
  });
  expect(Router.splitHash("")).toEqual({ shell: "", app: "" });
  // a bare FLP shell hash carries no app hash
  expect(Router.splitHash(`#${FLP_SHELL}`)).toEqual({
    shell: "",
    app: FLP_SHELL,
  });
});

test("an app hash containing '&/' is never split", () => {
  // the split must key off the leading "/" of an app hash, not off the first
  // "&/" - an app-owned query parameter may legitimately contain one
  const { Router } = loadRouter();
  expect(Router.splitHash(`#/app/${CALLER}/D1?next=&/x`)).toEqual({
    shell: "",
    app: `/app/${CALLER}/D1?next=&/x`,
  });
});

test("routes are parsed the same with or without a shell hash", () => {
  const { Router } = loadRouter();
  for (const prefix of ["#", `#${FLP_SHELL}&`, ""]) {
    expect(Router.parse(`${prefix}/app/${CALLER}/D1`)).toEqual({
      app: CALLER,
      draft: "D1",
    });
  }
  expect(Router.parse(`#${FLP_SHELL}&/app/${CALLER}`)).toEqual({
    app: CALLER,
    draft: "",
  });
});

test("hrefFor keeps the FLP shell hash, so a copied link reopens the tile", () => {
  const flp = loadRouter({ href: `https://host/flp#${FLP_SHELL}&/app/X/D1` });
  expect(flp.Router.hrefFor("/z2ui5-xapp-state=ABC")).toBe(
    `https://host/flp#${FLP_SHELL}&/z2ui5-xapp-state=ABC`,
  );
  const standalone = loadRouter({ href: "https://host/sap/z2ui5#/app/X/D1" });
  expect(standalone.Router.hrefFor("/z2ui5-xapp-state=ABC")).toBe(
    "https://host/sap/z2ui5#/z2ui5-xapp-state=ABC",
  );
});

// ---------------------------------------------------------------------------
// 2. Route patterns
// ---------------------------------------------------------------------------

test("patternFor / appOf / draftOf round-trip", () => {
  const { Router } = loadRouter();
  expect(Router.patternFor("Z2UI5_CL_X", "DRAFT9")).toBe(
    "/app/Z2UI5_CL_X/DRAFT9",
  );
  expect(Router.patternFor("Z2UI5_CL_X")).toBe("/app/Z2UI5_CL_X"); // no draft
  expect(Router.appOf("/app/Z2UI5_CL_X/DRAFT9")).toBe("Z2UI5_CL_X");
  expect(Router.draftOf("/app/Z2UI5_CL_X/DRAFT9")).toBe("DRAFT9");
  expect(Router.draftOf("#/app/Z2UI5_CL_X/DRAFT9")).toBe("DRAFT9");
  expect(Router.draftOf("/app/Z2UI5_CL_X")).toBe(""); // class only
});

test("non-app hashes parse to no route", () => {
  const { Router } = loadRouter();
  expect(Router.parse("")).toBe(null);
  expect(Router.appOf("/head/pos/42")).toBe("");
  expect(Router.draftOf("#/z2ui5-xapp-state=abc")).toBe("");
  expect(Router.parse(`#${FLP_SHELL}`)).toBe(null); // bare launchpad hash
});

// ---------------------------------------------------------------------------
// 3a. Read side - onHashChanged
// ---------------------------------------------------------------------------

test("a different draft (state) triggers a restore and marks it browser-initiated", () => {
  const { Router, state } = loadRouter();
  let restores = 0;
  Router.init(() => restores++);
  Router.onHashChanged(`/app/${CALLEE}/D2`);
  expect(restores).toBe(1);
  // so the render skips the hash rewrite (keeps the forward history entries)
  expect(state.navFromHash).toBe(true);
});

test("a Back press inside the FLP restores just like standalone", () => {
  // the shell's hashChanged hands over the app hash; a full hash must work too
  const { Router } = loadRouter();
  let restores = 0;
  Router.init(() => restores++);
  Router.onHashChanged(`#${FLP_SHELL}&/app/${CALLEE}/D2`);
  expect(restores).toBe(1);
});

test("the echo of the current draft is ignored (no loop)", () => {
  const { Router } = loadRouter({
    state: { currentApp: CALLEE, currentDraftId: "D2" },
  });
  let restores = 0;
  Router.init(() => restores++);
  Router.onHashChanged(`/app/${CALLEE}/D2`);
  expect(restores).toBe(0);
});

test("same class but a different draft still restores (state changed)", () => {
  const { Router } = loadRouter({
    state: { currentApp: CALLEE, currentDraftId: "D2" },
  });
  let restores = 0;
  Router.init(() => restores++);
  Router.onHashChanged(`/app/${CALLEE}/D9`);
  expect(restores).toBe(1);
});

test("FRESH mode: a draft-less route to a different class restarts it", () => {
  const { Router, state } = loadRouter({
    state: { currentApp: CALLER, currentDraftId: null },
  });
  let restores = 0;
  Router.init(() => restores++);
  Router.onHashChanged(`/app/${CALLER}`); // same class, no draft -> echo
  expect(restores).toBe(0);
  Router.onHashChanged(`/app/${CALLEE}`); // different class, no draft
  expect(restores).toBe(1);
  expect(state.navFromHash).toBe(true);
});

test("a non-app hash and disabled routing are both ignored", () => {
  const { Router } = loadRouter();
  let restores = 0;
  Router.init(() => restores++);
  Router.onHashChanged("/head/pos/42");
  expect(restores).toBe(0);

  const off = loadRouter({ state: { navRouting: false } });
  let offRestores = 0;
  off.Router.init(() => offRestores++);
  off.Router.onHashChanged(`/app/${CALLEE}/D2`);
  expect(offRestores).toBe(0);
});

// ---------------------------------------------------------------------------
// 3b. Write side - sync
// ---------------------------------------------------------------------------

// Writes reach the HashChanger WITHOUT the route's leading slash: standalone,
// hasher (prependHash "/") adds exactly one of its own - handing it a
// slash-prefixed route put "#//app/X" into the URL, which the frontend never
// saw (reads come back trimmed) but which hid the route from the backend's
// raw window.location.hash parser: every Back/Forward/reload fell back to
// the "?app_start=" boot query and restarted the boot app instead of
// restoring the routed one (forward navigation appeared to do nothing).

// the response of the roundtrip that ran client->nav_app_call
function navCallParams() {
  return {
    checkNavAppCall: true,
    navAppCallPrevApp: CALLER,
    navAppCallPrevId: "D2",
  };
}

test("a plain roundtrip replaces the current entry with the newest draft", () => {
  const { Router, state, writes } = loadRouter();
  state.oResponse = { APP: CALLER };

  Router.sync({ id: "D2" });

  expect(writes).toEqual([
    { op: "replace", hash: `app/${CALLER}/D2`, guard: "D2" },
  ]);
});

test("a nav_app_call repoints the caller's entry, then pushes the called app", () => {
  const { Router, state, writes, setHash } = loadRouter();
  setHash(`/app/${CALLER}/D1`); // the entry the browser is standing on
  state.oResponse = { APP: CALLEE };

  Router.sync({ ...navCallParams(), id: "D9" });

  expect(writes).toEqual([
    // the caller's entry now points at the draft that carries the user's
    // client-side changes ...
    { op: "replace", hash: `app/${CALLER}/D2`, guard: "D2" },
    // ... and the called app gets a NEW entry, so Back returns to it
    { op: "set", hash: `app/${CALLEE}/D9`, guard: "D9" },
  ]);
  // the state ends up on the called app (the repoint must not leak)
  expect(state.currentApp).toBe(CALLEE);
  expect(state.currentDraftId).toBe("D9");
});

test("the repoint is skipped when the caller's entry is already current", () => {
  const { Router, state, writes, setHash } = loadRouter();
  setHash(`/app/${CALLER}/D2`);
  state.oResponse = { APP: CALLEE };

  Router.sync({ ...navCallParams(), id: "D9" });

  expect(writes).toEqual([
    { op: "set", hash: `app/${CALLEE}/D9`, guard: "D9" },
  ]);
});

test("a nav_app_call without the caller info only pushes (older backend)", () => {
  const { Router, state, writes } = loadRouter();
  state.oResponse = { APP: CALLEE };

  Router.sync({ checkNavAppCall: true, id: "D9" });

  expect(writes).toEqual([
    { op: "set", hash: `app/${CALLEE}/D9`, guard: "D9" },
  ]);
});

test("FRESH mode routes by class only and never repoints", () => {
  const { Router, state, writes } = loadRouter({
    state: { navMode: "FRESH", currentDraftId: null },
  });
  state.oResponse = { APP: CALLEE };

  Router.sync({ ...navCallParams(), id: "D9" });

  expect(writes).toEqual([{ op: "set", hash: `app/${CALLEE}`, guard: null }]);
});

test("a render caused by browser Back/Forward writes no hash at all", () => {
  const { Router, state, writes } = loadRouter({
    state: { navFromHash: true },
  });
  state.oResponse = { APP: CALLER };

  Router.sync({ id: "D2" });

  expect(writes).toEqual([]);
  expect(state.navFromHash).toBe(false);
});

test("the routing mode arrives with every response and switches modes live", () => {
  const { Router, state, writes } = loadRouter({
    state: { navRouting: false, navMode: null },
  });
  state.oResponse = { APP: CALLER };

  Router.sync({ setNavRouting: "KEEP", id: "D2" });
  expect(state.navRouting).toBe(true);
  expect(state.navMode).toBe("KEEP");
  expect(writes).toEqual([
    { op: "replace", hash: `app/${CALLER}/D2`, guard: "D2" },
  ]);

  // DEFAULT turns routing off again and hands the hash back to the app
  Router.sync({ setNavRouting: "DEFAULT", id: "D3" });
  expect(state.navRouting).toBe(false);
  expect(state.navMode).toBe(null);
});

test("set_push_state keeps the FLP shell hash in the pushed URL", () => {
  const flp = loadRouter({
    state: { navRouting: false },
    href: `https://host/flp#${FLP_SHELL}&/app/X/D1`,
  });
  flp.Router.sync({ setPushState: "?pos=42", id: "D2" });
  expect(flp.pushes).toEqual([
    `/sap/z2ui5#${FLP_SHELL}&/app/X/D1?pos=42`,
  ]);

  const standalone = loadRouter({
    state: { navRouting: false },
    href: "https://host/sap/z2ui5#/app/X/D1",
  });
  standalone.Router.sync({ setPushState: "?pos=42", id: "D2" });
  expect(standalone.pushes).toEqual(["/sap/z2ui5#/app/X/D1?pos=42"]);
});

test("set_push_state in KEEP mode pushes the route through the HashChanger", () => {
  // history.pushState writes the URL bar but not hasher's cached hash: the
  // next browser Back landed exactly on the cached value, hasher read "no
  // change", and the restore roundtrip never fired - the one Back the push
  // exists for. In KEEP mode the suffix therefore rides behind the CURRENT
  // draft's route, pushed via setHash so hasher's cache follows; the entry
  // below keeps the pre-event draft (the updateAppRoute skip) and is what
  // Back restores. Nothing goes through history.pushState, and sync still
  // stops before the trailing replaceHash("") cleanup that would wipe the
  // pushed hash.
  const { Router, state, writes, pushes } = loadRouter({
    state: { navRouting: true, navMode: "KEEP", currentApp: CALLER },
    hash: `app/${CALLER}/D1`,
    href: `https://host/sap/z2ui5#/app/${CALLER}/D1`,
  });
  state.oResponse = { APP: CALLER };
  Router.sync({ setPushState: "/Page2", id: "D2" });
  expect(pushes).toEqual([]);
  expect(writes).toEqual([
    { op: "set", hash: `app/${CALLER}/D2/Page2`, guard: "D2" },
  ]);
  // the entry below the push still names D1, so its echo must not be
  // swallowed: a D1 route differs from the current draft and restores
  expect(Router.draftOf(`#/app/${CALLER}/D1`)).toBe("D1");
  expect(state.currentDraftId).toBe("D2");
});

test("set_push_state in FRESH mode keeps the legacy history push", () => {
  // a suffix behind a draft-less route would PARSE as a draft id, so FRESH
  // stays on history.pushState - Back is inert there by design (a FRESH
  // route restarts the app on every entry anyway), and the trailing
  // replaceHash("") cleanup stays skipped
  const { Router, state, writes, pushes } = loadRouter({
    state: {
      navRouting: true,
      navMode: "FRESH",
      currentApp: CALLER,
      currentDraftId: null,
    },
    hash: `app/${CALLER}`,
    href: `https://host/sap/z2ui5#/app/${CALLER}`,
  });
  state.oResponse = { APP: CALLER };
  Router.sync({ setPushState: "?pos=42", id: "D2" });
  expect(pushes).toEqual([`/sap/z2ui5#/app/${CALLER}?pos=42`]);
  expect(writes.filter((w) => w.hash === "")).toEqual([]);
});

// ---------------------------------------------------------------------------
// App-owned hash routing (HASH_LISTENER, routing off)
// ---------------------------------------------------------------------------

test("a registered hash listener turns set_push_state into a HashChanger push", () => {
  // history.pushState bypasses hasher's cache, so the next browser Back
  // landed exactly on the cached value and hasher read "no change" - the
  // registered event never fired. With a listener the value is the whole
  // app hash, pushed through setHash so the cache follows. The registration
  // arrives as a nav OPTION (setHashEvent) so the very response that
  // registers is already covered.
  const { Router, state, writes, pushes } = loadRouter({
    state: { navRouting: false },
  });
  Router.sync({ setHashEvent: "HASH_CHANGED", id: "D1" });
  Router.sync({ setPushState: "/Page2", id: "D2" });
  expect(pushes).toEqual([]);
  expect(writes).toEqual([{ op: "set", hash: "Page2", guard: "D1" }]);
  expect(state.hashEvent).toBe("HASH_CHANGED");
  expect(state.appHash).toBe("/Page2");
});

test("the listener fires on a foreign hash change and swallows its own echo", () => {
  const { Router, state } = loadRouter({ state: { navRouting: false } });
  const fired = [];
  state.oController = { eB: (a) => fired.push(a) };
  Router.sync({ setHashEvent: "HASH_CHANGED", id: "D1" });
  Router.sync({ setPushState: "/Page2", id: "D2" });
  // the echo of our own write - both spellings hasher hands back
  Router.onHashChanged("Page2");
  Router.onHashChanged("/Page2");
  expect(fired).toEqual([]);
  // browser Back to the entry without the hash
  Router.onHashChanged("");
  expect(fired).toEqual([["HASH_CHANGED"]]);
  expect(state.appHash).toBe("");
  // browser Forward to the pushed entry again
  Router.onHashChanged("/Page2");
  expect(fired).toEqual([["HASH_CHANGED"], ["HASH_CHANGED"]]);
});

test("a hash listener keeps the per-response cleanup off the hash", () => {
  // with the app's value in hasher's cache, the trailing replaceHash("")
  // would count as a change and wipe the hash on the NEXT unrelated
  // roundtrip - sync must leave a listener-owned hash alone. The same
  // response registering the listener is already covered (applyHashEvent
  // runs before the cleanup), which is what a boot on a deep link needs.
  const { Router, writes, pushes } = loadRouter({
    state: { navRouting: false },
  });
  Router.sync({ setHashEvent: "HASH_CHANGED", id: "D1" });
  Router.sync({ id: "D2" });
  expect(writes).toEqual([]);
  expect(pushes).toEqual([]);
});

test("a deep-link boot adopts the hash it was opened on", () => {
  // opening ?app_start=...#/Page2 cold: the first response registers the
  // listener, applyHashEvent adopts the live hash as the known value - no
  // dispatch for the boot hash itself, and the cleanup leaves it alone
  const { Router, state, writes } = loadRouter({
    state: { navRouting: false },
    href: "https://host/sap/z2ui5#/Page2",
  });
  const fired = [];
  state.oController = { eB: (a) => fired.push(a) };
  Router.sync({ setHashEvent: "HASH_CHANGED", id: "D1" });
  Router.onHashChanged("/Page2");
  expect(fired).toEqual([]);
  expect(writes).toEqual([]);
});

test("a blank setHashEvent unregisters, a destroyed controller stays silent", () => {
  const { Router, state } = loadRouter({ state: { navRouting: false } });
  const fired = [];
  state.oController = { eB: (a) => fired.push(a), destroyed: false };
  Router.sync({ setHashEvent: "HASH_CHANGED", id: "D1" });
  // the controller died with its view mid-rebuild
  state.oController.destroyed = true;
  Router.onHashChanged("/Page2");
  expect(fired).toEqual([]);
  // a single space is the unregister encoding (empty means "no change")
  state.oController.destroyed = false;
  Router.sync({ setHashEvent: " ", id: "D2" });
  expect(state.hashEvent).toBe(null);
  Router.onHashChanged("/other");
  expect(fired).toEqual([]);
});

test("the app-state hash reaches the HashChanger slash-less too", () => {
  // hasher prepends the one canonical "/" - the live URL becomes
  // "#/z2ui5-xapp-state=ABC", exactly the format the copy link writes
  const { Router, writes } = loadRouter({ state: { navRouting: false } });
  Router.sync({ setAppStateActive: true, id: "ABC" });
  expect(writes).toEqual([
    { op: "replace", hash: "z2ui5-xapp-state=ABC", guard: "D1" },
  ]);
});

test("navTo strips every leading slash before writing", () => {
  // regression: with the slash left in, hasher turned "/app/X" into
  // "#//app/X" and the backend route parser no longer matched it
  const { Router, writes } = loadRouter();
  Router.navTo(`/app/${CALLEE}/D9`);
  Router.navTo(`//app/${CALLEE}`, true);
  expect(writes).toEqual([
    { op: "set", hash: `app/${CALLEE}/D9`, guard: "D1" },
    { op: "replace", hash: `app/${CALLEE}`, guard: "D1" },
  ]);
});

test("routes with stacked leading slashes still parse (old history entries)", () => {
  // "#//app/X" URLs written before navTo stripped its slash live on in
  // bookmarks and history entries - Back/Forward hands them to the router
  const { Router } = loadRouter();
  expect(Router.parse(`#//app/${CALLEE}/D9`)).toEqual({
    app: CALLEE,
    draft: "D9",
  });
  expect(Router.appOf(`//app/${CALLEE}`)).toBe(CALLEE);
});

// The option names are a contract with the backend: z2ui5_cl_ui5_act_front=>
// nav_serialize writes exactly these keys into the ROUTER/sync call.
// A rename on either side silently disables routing - the router would read
// undefined everywhere and simply do nothing - so pin the set here.
test("reads exactly the option names the backend writes", () => {
  const src = require("fs").readFileSync(
    require("path").join(__dirname, "..", "..", "app", "webapp", "core", "Router.js"),
    "utf8",
  );
  const read = [...src.matchAll(/mOptions\.([a-zA-Z]+)/g)].map((m) => m[1]);
  expect([...new Set(read)].sort()).toEqual([
    "checkNavAppCall",
    "id",
    "navAppCallPrevApp",
    "navAppCallPrevId",
    "setAppStateActive",
    "setHashEvent",
    "setNavRouting",
    "setPushState",
  ]);
});
