sap.ui.define(
  ["z2ui5/core/Lib", "z2ui5/core/ViewSlots", "z2ui5/core/AppState"],
  (Lib, ViewSlots, AppState) => {
    "use strict";

    // ------------------------------------------------------------------
    // KEYBOARD_SHORTCUT: bind a key combination to a NAMED BACKEND EVENT -
    // the declarative equivalent of a sap.ui.core.CommandExecution shortcut
    // (which needs a controller method and therefore has no place in a
    // controller-less app). The backend registers "combo -> event" pairs as
    // data; the document listener below is installed once and always reads
    // the CURRENT registry, so an app switch (which resets AppState) starts
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
      return SHORTCUT_ALIASES[t] ?? t;
    }

    // "Ctrl+Shift+S" / "shift + CTRL + s" -> "ctrl+shift+s". Returns an empty
    // string when no actual key (only modifiers) is named.
    function normalizeShortcut(combo) {
      const parts = String(combo ?? "")
        .split("+")
        .map(shortcutToken)
        .filter((p) => p !== "");
      const mods = SHORTCUT_MODIFIERS.filter((m) => parts.includes(m));
      const keys = parts.filter((p) => !SHORTCUT_MODIFIERS.includes(p));
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
    function scopeControlOpen(id) {
      const c = ViewSlots.resolveById(id);
      if (!c) return false;
      if (typeof c.isOpen === "function") return !!c.isOpen();
      return typeof c.getVisible === "function"
        ? c.getVisible() !== false
        : true;
    }

    function shortcutEntry(combo) {
      const scopes = AppState.state.shortcuts[combo];
      if (!scopes) return undefined;
      for (const key of Object.keys(scopes)) {
        if (key === SHORTCUT_GLOBAL || SHORTCUT_SLOTS.includes(key)) continue;
        if (scopeControlOpen(key)) return scopes[key];
      }
      for (const key of SHORTCUT_SLOTS) {
        if (scopes[key] && ViewSlots.getView(key)) return scopes[key];
      }
      return scopes[SHORTCUT_GLOBAL];
    }

    let shortcutListener = null;

    function installShortcutListener() {
      if (shortcutListener || typeof document === "undefined") return;
      shortcutListener = (oEvent) => {
        try {
          const entry = shortcutEntry(shortcutFromEvent(oEvent));
          if (!entry) return;
          // the browser's own default for the combo (Ctrl+S saves the page,
          // Ctrl+D bookmarks it) must not fire alongside the app command
          oEvent.preventDefault();
          entry.controller.eB([entry.event]);
        } catch (e) {
          Lib.logError("KEYBOARD_SHORTCUT: dispatch failed", e);
        }
      };
      document.addEventListener("keydown", shortcutListener);
    }

    // args: [_, combo, eventName, scope] - an empty event name unregisters the
    // combo IN THAT SCOPE; scope is a view slot key (cs_view-popover/popup/...)
    // and defaults to the unscoped, always-eligible registration
    function evKeyboardShortcut(oController, args) {
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
      const scope = SHORTCUT_SLOTS.includes(raw.toUpperCase())
        ? raw.toUpperCase()
        : raw;
      const shortcuts = AppState.state.shortcuts;
      const scopes = shortcuts[combo] ?? (shortcuts[combo] = {});
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
      installShortcutListener();
    }

    // ------------------------------------------------------------------
    // KEYBOARD_SET_MODE: the HTML `inputmode` of an input - inputmode="none"
    // is what keeps the soft keyboard down on a scanner device.
    //
    // The mode is a property of the CONTROL, but `inputmode` is an attribute
    // of the DOM element UI5 throws away and rebuilds on every re-render, so
    // setting it once is not enough. It is remembered per control here and
    // re-applied after each rendering.
    // ------------------------------------------------------------------

    // control -> { mode }, the mode the delegate installed on that control
    // applies; a WeakMap so a destroyed control (a full view rebuild destroys
    // them all) takes its entry with it
    const inputModes = new WeakMap();

    function applyInputMode(oElement, mode) {
      const dom = oElement.getDomRef();
      if (!dom) return;
      const input = dom.matches("input, textarea")
        ? dom
        : dom.querySelector("input, textarea");
      if (!input) return;
      input.setAttribute("inputmode", mode);
    }

    function evKeyboardSetMode(oController, args) {
      try {
        // resolveById, not byId("MAIN"): the scan field may sit in a popup,
        // a popover or a nested view - same resolution SET_FOCUS uses
        const oElement = ViewSlots.resolveById(args[1]);
        if (!oElement) return;
        const mode = args[2] || "text";
        const entry = inputModes.get(oElement);
        if (entry) {
          // one delegate per control: re-issuing the action only changes the
          // mode the delegate already installed applies
          entry.mode = mode;
        } else {
          const state = { mode };
          inputModes.set(oElement, state);
          const apply = () => applyInputMode(oElement, state.mode);
          oElement.addEventDelegate({
            onAfterRendering: apply,
            // And again while the field is TAKING the focus: a SET_FOCUS from
            // the same roundtrip runs from its own onAfterRendering delegate,
            // and delegates fire in registration order - an app that sets the
            // focus before the mode (the documented order) would focus an
            // input that still carries no inputmode. A browser that decides
            // about its on-screen keyboard when the focus lands - a Windows
            // terminal does - has shown the keyboard by then, and a later
            // attribute change no longer takes it back. focusin fires while
            // that focus is still being processed, so this makes the mode
            // independent of the order the two actions arrive in.
            onfocusin: apply,
          });
        }
        // An app that re-issues the mode next to a FULL re-render (the usual
        // shape: view_display, then set focus and input mode) reaches here
        // BEFORE UI5 rendered the freshly built control - getDomRef( ) is
        // null then and only the delegate above can land the attribute.
        // Applying here as well covers the already-rendered control, i.e.
        // the view_model_update path, in the same roundtrip.
        applyInputMode(oElement, mode);
      } catch (e) {
        Lib.logError(
          `KEYBOARD_SET_MODE: setAttribute failed for '${args[1]}'`,
          e,
        );
      }
    }

    // The events this module owns in the eF dispatch (see
    // core/FrontendAction.js, which merges the domain modules' handler maps).
    const handlers = {
      KEYBOARD_SHORTCUT: evKeyboardShortcut,
      KEYBOARD_SET_MODE: evKeyboardSetMode,
    };

    return { handlers };
  },
);
