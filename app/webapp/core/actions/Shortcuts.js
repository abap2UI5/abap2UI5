sap.ui.define(["z2ui5/core/Lib", "z2ui5/core/ViewSlots"], (Lib, ViewSlots) => {
  "use strict";

  // ------------------------------------------------------------------
  // KEYBOARD_SHORTCUT: bind a key combination to a NAMED BACKEND EVENT -
  // the declarative equivalent of a sap.ui.core.CommandExecution shortcut
  // (which needs a controller method and therefore has no place in a
  // controller-less app). The backend registers "combo -> event" pairs as
  // data; the document listener below is installed once per context
  // (`ctx.shortcuts.listener`) and always reads the CURRENT registry of
  // that context, so an app switch (which empties the registry) starts
  // from an empty set without touching the listener.
  // ------------------------------------------------------------------

  // in the order they are emitted into a normalized combo, so registration
  // and keydown produce the same string for any spelling
  const SHORTCUT_MODIFIERS = ["ctrl", "shift", "alt", "meta"];

  // spellings apps/UI5 use for the same modifier or key
  const SHORTCUT_ALIASES = {
    control: "ctrl",
    cmd: "meta",
    command: "meta",
    option: "alt",
    esc: "escape",
    del: "delete",
    ins: "insert",
    return: "enter",
    space: " ",
  };

  function shortcutToken(part) {
    const t = part.trim().toLowerCase();
    // own property only - `constructor` off the wire would otherwise
    // resolve to Object.prototype's and become the token
    return Object.prototype.hasOwnProperty.call(SHORTCUT_ALIASES, t)
      ? SHORTCUT_ALIASES[t]
      : t;
  }

  // "Ctrl+Shift+S" / "shift + CTRL + s" -> "ctrl+shift+s". Returns an empty
  // string when no actual key (only modifiers) is named.
  //
  // The "+" key itself is spelled "Ctrl++": the separator is the key, so
  // split( ) yields two EMPTY tokens at the end, and dropping empties read
  // the combo as modifiers only. That trailing PAIR is the key - a single
  // trailing empty token ("Ctrl+") still names none. It is what a keydown
  // for "+" normalizes to as well (shortcutFromEvent joins with "+").
  function normalizeShortcut(combo) {
    const tokens = String(combo ?? "").split("+");
    const plusKey =
      tokens.length >= 2 &&
      tokens[tokens.length - 1].trim() === "" &&
      tokens[tokens.length - 2].trim() === "";
    const parts = tokens.map(shortcutToken).filter((p) => p !== "");
    const mods = SHORTCUT_MODIFIERS.filter((m) => parts.includes(m));
    const keys = parts.filter((p) => !SHORTCUT_MODIFIERS.includes(p));
    if (plusKey) keys.push("+");
    if (keys.length === 0) return "";
    return [...mods, keys[keys.length - 1]].join("+");
  }

  // the same normalized form for an actual keydown event
  function shortcutFromEvent(oEvent) {
    const key = String(oEvent.key ?? "").toLowerCase();
    // a bare modifier press is not a shortcut
    if (key === "" || SHORTCUT_MODIFIERS.includes(shortcutToken(key)))
      return "";
    const mods = [];
    if (oEvent.ctrlKey) mods.push("ctrl");
    if (oEvent.shiftKey) mods.push("shift");
    if (oEvent.altKey) mods.push("alt");
    if (oEvent.metaKey) mods.push("meta");
    return [...mods, key].join("+");
  }

  // A shortcut may be SCOPED, which is how UI5's own CommandExecution
  // behaves: one in a Popover's dependents shadows the page-level one for
  // the same command while that popover is open. A scope is either
  //
  //   a VIEW SLOT   - POPOVER/POPUP/NEST2/NEST/MAIN, open when the framework
  //                   has that slot showing (popover_display, popup_display,
  //                   a nested view)
  //   a CONTROL ID  - any control DECLARED IN THE VIEW that can be open or
  //                   closed: a sap.m.Popover/Dialog in `dependents` opened
  //                   with control_by_id openBy, which is the shape the demo
  //                   kit's Commands sample actually uses. It never enters a
  //                   framework slot, so the slot form alone would never fire.
  //
  // Dispatch prefers a CONTROL scope (the more specific statement) over a
  // slot scope, then takes the innermost open slot, then the unscoped entry.
  const SHORTCUT_SLOTS = ["POPOVER", "POPUP", "NEST2", "NEST", "MAIN"];

  const SHORTCUT_GLOBAL = ""; // the unscoped registration

  // A control scope counts while the control is OPEN - isOpen() for the
  // popup-like controls this is for, visibility otherwise.
  function scopeControlOpen(ctx, id) {
    const c = ViewSlots.resolveById(ctx, id);
    if (!c) return false;
    if (typeof c.isOpen === "function") return !!c.isOpen();
    return typeof c.getVisible === "function" ? c.getVisible() !== false : true;
  }

  function shortcutEntry(ctx, combo) {
    // own entries only - see the registration for why a prototype name
    // must not be looked up on the registry object
    const shortcuts = ctx.state.shortcuts;
    if (!Object.prototype.hasOwnProperty.call(shortcuts, combo)) {
      return undefined;
    }
    const scopes = shortcuts[combo];
    for (const key of Object.keys(scopes)) {
      if (key === SHORTCUT_GLOBAL || SHORTCUT_SLOTS.includes(key)) continue;
      if (scopeControlOpen(ctx, key)) return scopes[key];
    }
    for (const key of SHORTCUT_SLOTS) {
      if (scopes[key] && ViewSlots.getView(ctx, key)) return scopes[key];
    }
    return scopes[SHORTCUT_GLOBAL];
  }

  function installShortcutListener(ctx) {
    if (ctx.shortcuts.listener || typeof document === "undefined") return;
    const listener = (oEvent) => {
      try {
        const entry = shortcutEntry(ctx, shortcutFromEvent(oEvent));
        if (!entry) return;
        // a registration whose controller died with its view (an app
        // switch clears the registry, an in-app teardown does not) must
        // not dispatch into a destroyed controller - same guard as
        // ViewOps.evStartTimer
        if (!Lib.isControllerAlive(entry.controller)) return;
        // the browser's own default for the combo (Ctrl+S saves the page,
        // Ctrl+D bookmarks it) must not fire alongside the app command
        oEvent.preventDefault();
        entry.controller.eB([entry.event]);
      } catch (e) {
        Lib.logError("KEYBOARD_SHORTCUT: dispatch failed", e);
      }
    };
    ctx.shortcuts.listener = listener;
    document.addEventListener("keydown", listener);
  }

  // Take the listener off `document` on the component teardown, the way
  // every other module that installs one does (Component.exit, Router.exit,
  // devtools/Picker, devtools/Console). It used to be MODULE state and
  // outlived the component that installed it - on an FLP re-launch the
  // page stays alive, so the dead listener kept running shortcutFromEvent
  // plus a registry lookup on every keystroke of whatever came next, for
  // the rest of the session. The REGISTRY needs no such treatment: it is
  // app-scoped, cleared on an app switch (View1._processAfterRendering)
  // and rebuilt with the context. Installing again is the next
  // evKeyboardShortcut( )'s job, as on a fresh page: the field going back
  // to null is what lets it.
  function reset(ctx) {
    const listener = ctx?.shortcuts?.listener;
    if (!listener || typeof document === "undefined") return;
    document.removeEventListener("keydown", listener);
    ctx.shortcuts.listener = null;
  }

  // args: [_, combo, eventName, scope] - an empty event name unregisters the
  // combo IN THAT SCOPE; scope is a view slot key (cs_view-popover/popup/...)
  // or a control id (see the scope section above) and defaults to the
  // unscoped, always-eligible registration
  function evKeyboardShortcut(oController, args) {
    const ctx = oController?.ctx;
    if (!ctx) {
      Lib.logError("KEYBOARD_SHORTCUT: no context to register in");
      return;
    }
    const combo = normalizeShortcut(args[1]);
    if (!combo) {
      Lib.logError(
        `KEYBOARD_SHORTCUT: '${args[1]}' names no key to bind (modifiers only?)`,
      );
      return;
    }
    // a slot key is matched case-insensitively; anything else is taken as a
    // control id and keeps its case, because that is how it must resolve
    const raw = String(args[3] ?? "");
    const upper = raw.toUpperCase();
    const scope = SHORTCUT_SLOTS.includes(upper) ? upper : raw;
    const shortcuts = ctx.state.shortcuts;
    // a combo that spells a property Object.prototype carries - `__proto__`,
    // `constructor` - is no key combination. The registry itself is
    // prototype-less since 2026-09-23 (AppState.createState), so such a
    // write no longer reaches Object.prototype; the check stays for the
    // log line, which is the only way an app learns its wire was wrong.
    if (combo in Object.prototype) {
      Lib.logError(`KEYBOARD_SHORTCUT: '${args[1]}' is not a key combination`);
      return;
    }
    // the scope map is keyed by a control id off the wire, so it is
    // prototype-less for the same reason as the registry around it
    const scopes = shortcuts[combo] ?? (shortcuts[combo] = Object.create(null));
    if (!args[2]) {
      delete scopes[scope];
      // a combo with no registration left must not keep an empty entry:
      // shortcutEntry would still find it and fall through to undefined,
      // but preventDefault has already been decided by then
      if (Object.keys(scopes).length === 0) delete shortcuts[combo];
      return;
    }
    // re-registering a combo in the same scope replaces it, so the backend
    // can rebind a shortcut without unregistering it first
    scopes[scope] = { event: args[2], controller: oController };
    installShortcutListener(ctx);
  }

  // The events this module owns in the eF dispatch (see
  // core/FrontendAction.js, which merges the domain modules' handler maps).
  const handlers = {
    KEYBOARD_SHORTCUT: evKeyboardShortcut,
  };

  // the two pure halves of the registry are exported for the unit specs
  // (node/tests/shortcuts.spec.js); the listener reads them from here
  return { handlers, reset, normalizeShortcut, shortcutFromEvent };
});
