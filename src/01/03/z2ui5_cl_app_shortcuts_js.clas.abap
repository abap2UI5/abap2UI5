* =====================================================================
* GENERATED FILE - DO NOT EDIT (AGENTS.md rule 2)
* Embedded frontend resource, generated from app/webapp/ by
* .github/app2abap/trans2abap.js. Change the source under app/webapp/
* and run 'npm run app2abap' to regenerate; the check_app2abap CI gate
* fails any manual edit here.
* =====================================================================
CLASS z2ui5_cl_app_shortcuts_js DEFINITION
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


CLASS z2ui5_cl_app_shortcuts_js IMPLEMENTATION.

  METHOD get.

    result = `sap.ui.define(` && |\n| &&
             `  ["z2ui5/core/Lib", "z2ui5/core/ViewSlots", "z2ui5/core/AppState"],` && |\n| &&
             `  (Lib, ViewSlots, AppState) => {` && |\n| &&
             `    "use strict";` && |\n| &&
             `` && |\n| &&
             `    // ------------------------------------------------------------------` && |\n| &&
             `    // KEYBOARD_SHORTCUT: bind a key combination to a NAMED BACKEND EVENT -` && |\n| &&
             `    // the declarative equivalent of a sap.ui.core.CommandExecution shortcut` && |\n| &&
             `    // (which needs a controller method and therefore has no place in a` && |\n| &&
             `    // controller-less app). The backend registers "combo -> event" pairs as` && |\n| &&
             `    // data; the document listener below is installed once and always reads` && |\n| &&
             `    // the CURRENT registry, so an app switch (which resets AppState) starts` && |\n| &&
             `    // from an empty set without touching the listener.` && |\n| &&
             `    // ------------------------------------------------------------------` && |\n| &&
             `` && |\n| &&
             `    // in the order they are emitted into a normalized combo, so registration` && |\n| &&
             `    // and keydown produce the same string for any spelling` && |\n| &&
             `    const SHORTCUT_MODIFIERS = ["ctrl", "shift", "alt", "meta"];` && |\n| &&
             `` && |\n| &&
             `    // spellings apps/UI5 use for the same modifier or key` && |\n| &&
             `    const SHORTCUT_ALIASES = {` && |\n| &&
             `      control: "ctrl",` && |\n| &&
             `      cmd: "meta",` && |\n| &&
             `      command: "meta",` && |\n| &&
             `      option: "alt",` && |\n| &&
             `      esc: "escape",` && |\n| &&
             `      del: "delete",` && |\n| &&
             `      ins: "insert",` && |\n| &&
             `      return: "enter",` && |\n| &&
             `      space: " ",` && |\n| &&
             `    };` && |\n| &&
             `` && |\n| &&
             `    function shortcutToken(part) {` && |\n| &&
             `      const t = part.trim().toLowerCase();` && |\n| &&
             `      return SHORTCUT_ALIASES[t] ?? t;` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // "Ctrl+Shift+S" / "shift + CTRL + s" -> "ctrl+shift+s". Returns an empty` && |\n| &&
             `    // string when no actual key (only modifiers) is named.` && |\n| &&
             `    function normalizeShortcut(combo) {` && |\n| &&
             `      const parts = String(combo ?? "")` && |\n| &&
             `        .split("+")` && |\n| &&
             `        .map(shortcutToken)` && |\n| &&
             `        .filter((p) => p !== "");` && |\n| &&
             `      const mods = SHORTCUT_MODIFIERS.filter((m) => parts.includes(m));` && |\n| &&
             `      const keys = parts.filter((p) => !SHORTCUT_MODIFIERS.includes(p));` && |\n| &&
             `      if (keys.length === 0) return "";` && |\n| &&
             `      return [...mods, keys[keys.length - 1]].join("+");` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // the same normalized form for an actual keydown event` && |\n| &&
             `    function shortcutFromEvent(oEvent) {` && |\n| &&
             `      const key = String(oEvent.key ?? "").toLowerCase();` && |\n| &&
             `      // a bare modifier press is not a shortcut` && |\n| &&
             `      if (key === "" || SHORTCUT_MODIFIERS.includes(shortcutToken(key)))` && |\n| &&
             `        return "";` && |\n| &&
             `      const mods = [];` && |\n| &&
             `      if (oEvent.ctrlKey) mods.push("ctrl");` && |\n| &&
             `      if (oEvent.shiftKey) mods.push("shift");` && |\n| &&
             `      if (oEvent.altKey) mods.push("alt");` && |\n| &&
             `      if (oEvent.metaKey) mods.push("meta");` && |\n| &&
             `      return [...mods, key].join("+");` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // A shortcut may be SCOPED, which is how UI5's own CommandExecution` && |\n| &&
             `    // behaves: one in a Popover's dependents shadows the page-level one for` && |\n| &&
             `    // the same command while that popover is open. A scope is either` && |\n| &&
             `    //` && |\n| &&
             `    //   a VIEW SLOT   - POPOVER/POPUP/NEST2/NEST/MAIN, open when the framework` && |\n| &&
             `    //                   has that slot showing (popover_display, popup_display,` && |\n| &&
             `    //                   a nested view)` && |\n| &&
             `    //   a CONTROL ID  - any control DECLARED IN THE VIEW that can be open or` && |\n| &&
             `    //                   closed: a sap.m.Popover/Dialog in ``dependents`` opened` && |\n| &&
             `    //                   with control_by_id openBy, which is the shape the demo` && |\n| &&
             `    //                   kit's Commands sample actually uses. It never enters a` && |\n| &&
             `    //                   framework slot, so the slot form alone would never fire.` && |\n| &&
             `    //` && |\n| &&
             `    // Dispatch prefers a CONTROL scope (the more specific statement) over a` && |\n| &&
             `    // slot scope, then takes the innermost open slot, then the unscoped entry.` && |\n| &&
             `    const SHORTCUT_SLOTS = ["POPOVER", "POPUP", "NEST2", "NEST", "MAIN"];` && |\n| &&
             `` && |\n| &&
             `    const SHORTCUT_GLOBAL = ""; // the unscoped registration` && |\n| &&
             `` && |\n| &&
             `    // A control scope counts while the control is OPEN - isOpen() for the` && |\n| &&
             `    // popup-like controls this is for, visibility otherwise.` && |\n| &&
             `    function scopeControlOpen(id) {` && |\n| &&
             `      const c = ViewSlots.resolveById(id);` && |\n| &&
             `      if (!c) return false;` && |\n| &&
             `      if (typeof c.isOpen === "function") return !!c.isOpen();` && |\n| &&
             `      return typeof c.getVisible === "function"` && |\n| &&
             `        ? c.getVisible() !== false` && |\n| &&
             `        : true;` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function shortcutEntry(combo) {` && |\n| &&
             `      const scopes = AppState.state.shortcuts[combo];` && |\n| &&
             `      if (!scopes) return undefined;` && |\n| &&
             `      for (const key of Object.keys(scopes)) {` && |\n| &&
             `        if (key === SHORTCUT_GLOBAL || SHORTCUT_SLOTS.includes(key)) continue;` && |\n| &&
             `        if (scopeControlOpen(key)) return scopes[key];` && |\n| &&
             `      }` && |\n| &&
             `      for (const key of SHORTCUT_SLOTS) {` && |\n| &&
             `        if (scopes[key] && ViewSlots.getView(key)) return scopes[key];` && |\n| &&
             `      }` && |\n| &&
             `      return scopes[SHORTCUT_GLOBAL];` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    let shortcutListener = null;` && |\n| &&
             `` && |\n| &&
             `    function installShortcutListener() {` && |\n| &&
             `      if (shortcutListener || typeof document === "undefined") return;` && |\n| &&
             `      shortcutListener = (oEvent) => {` && |\n| &&
             `        try {` && |\n| &&
             `          const entry = shortcutEntry(shortcutFromEvent(oEvent));` && |\n| &&
             `          if (!entry) return;` && |\n| &&
             `          // the browser's own default for the combo (Ctrl+S saves the page,` && |\n| &&
             `          // Ctrl+D bookmarks it) must not fire alongside the app command` && |\n| &&
             `          oEvent.preventDefault();` && |\n| &&
             `          entry.controller.eB([entry.event]);` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          Lib.logError("KEYBOARD_SHORTCUT: dispatch failed", e);` && |\n| &&
             `        }` && |\n| &&
             `      };` && |\n| &&
             `      document.addEventListener("keydown", shortcutListener);` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // args: [_, combo, eventName, scope] - an empty event name unregisters the` && |\n| &&
             `    // combo IN THAT SCOPE; scope is a view slot key (cs_view-popover/popup/...)` && |\n| &&
             `    // and defaults to the unscoped, always-eligible registration` && |\n| &&
             `    function evKeyboardShortcut(oController, args) {` && |\n| &&
             `      const combo = normalizeShortcut(args[1]);` && |\n| &&
             `      if (!combo) {` && |\n| &&
             `        Lib.logError(` && |\n| &&
             `          ``KEYBOARD_SHORTCUT: '${args[1]}' names no key to bind (modifiers only?)``,` && |\n| &&
             `        );` && |\n| &&
             `        return;` && |\n| &&
             `      }` && |\n| &&
             `      // a slot key is matched case-insensitively; anything else is taken as a` && |\n| &&
             `      // control id and keeps its case, because that is how it must resolve` && |\n| &&
             `      const raw = String(args[3] ?? "");` && |\n| &&
             `      const scope = SHORTCUT_SLOTS.includes(raw.toUpperCase())` && |\n| &&
             `        ? raw.toUpperCase()` && |\n| &&
             `        : raw;` && |\n| &&
             `      const shortcuts = AppState.state.shortcuts;` && |\n| &&
             `      const scopes = shortcuts[combo] ?? (shortcuts[combo] = {});` && |\n| &&
             `      if (!args[2]) {` && |\n| &&
             `        delete scopes[scope];` && |\n| &&
             `        // a combo with no registration left must not keep an empty entry:` && |\n| &&
             `        // shortcutEntry would still find it and fall through to undefined,` && |\n| &&
             `        // but preventDefault has already been decided by then` && |\n| &&
             `        if (Object.keys(scopes).length === 0) delete shortcuts[combo];` && |\n| &&
             `        return;` && |\n| &&
             `      }` && |\n| &&
             `      // re-registering a combo in the same scope replaces it, so the backend` && |\n| &&
             `      // can rebind a shortcut without unregistering it first` && |\n| &&
             `      scopes[scope] = { event: args[2], controller: oController };` && |\n| &&
             `      installShortcutListener();` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function evSetInputMode(oController, args) {` && |\n| &&
             `      try {` && |\n| &&
             `        const oElement = ViewSlots.byId("MAIN", args[1]);` && |\n| &&
             `        if (!oElement) return;` && |\n| &&
             `        const dom = oElement.getDomRef();` && |\n| &&
             `        if (!dom) return;` && |\n| &&
             `        const input = dom.matches("input, textarea")` && |\n| &&
             `          ? dom` && |\n| &&
             `          : dom.querySelector("input, textarea");` && |\n| &&
             `        if (!input) return;` && |\n| &&
             `        input.setAttribute("inputmode", args[2] || "text");` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        Lib.logError(` && |\n| &&
             `          ``KEYBOARD_SET_MODE: setAttribute failed for '${args[1]}'``,` && |\n| &&
             `          e,` && |\n| &&
             `        );` && |\n| &&
             `      }` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // The events this module owns in the eF dispatch (see` && |\n| &&
             `    // core/FrontendAction.js, which merges the domain modules' handler maps).` && |\n| &&
             `    const handlers = {` && |\n| &&
             `      KEYBOARD_SHORTCUT: evKeyboardShortcut,` && |\n| &&
             `      KEYBOARD_SET_MODE: evSetInputMode,` && |\n| &&
             `    };` && |\n| &&
             `` && |\n| &&
             `    return { handlers };` && |\n| &&
             `  },` && |\n| &&
             `);` && |\n| &&
             `` && |\n| &&
              ``.

  ENDMETHOD.

ENDCLASS.
