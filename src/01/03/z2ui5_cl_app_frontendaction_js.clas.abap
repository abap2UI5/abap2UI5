* =====================================================================
* GENERATED FILE - DO NOT EDIT (AGENTS.md rule 2)
* Embedded frontend resource, generated from app/webapp/ by
* .github/app2abap/trans2abap.js. Change the source under app/webapp/
* and run 'npm run app2abap' to regenerate; the check_app2abap CI gate
* fails any manual edit here.
* =====================================================================
CLASS z2ui5_cl_app_frontendaction_js DEFINITION
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


CLASS z2ui5_cl_app_frontendaction_js IMPLEMENTATION.

  METHOD get.

    result = `sap.ui.define(` && |\n| &&
             `  [` && |\n| &&
             `    "z2ui5/core/actions/ControlCall",` && |\n| &&
             `    "z2ui5/core/actions/Browser",` && |\n| &&
             `    "z2ui5/core/actions/Launchpad",` && |\n| &&
             `    "z2ui5/core/actions/Variants",` && |\n| &&
             `    "z2ui5/core/actions/Shortcuts",` && |\n| &&
             `    "z2ui5/core/actions/ViewOps",` && |\n| &&
             `    "z2ui5/core/actions/LegacyCustomJs",` && |\n| &&
             `    "z2ui5/core/Lib",` && |\n| &&
             `    "z2ui5/core/AppState",` && |\n| &&
             `  ],` && |\n| &&
             `  (` && |\n| &&
             `    ControlCall,` && |\n| &&
             `    Browser,` && |\n| &&
             `    Launchpad,` && |\n| &&
             `    Variants,` && |\n| &&
             `    Shortcuts,` && |\n| &&
             `    ViewOps,` && |\n| &&
             `    LegacyCustomJs,` && |\n| &&
             `    Lib,` && |\n| &&
             `    AppState,` && |\n| &&
             `  ) => {` && |\n| &&
             `    "use strict";` && |\n| &&
             `` && |\n| &&
             `    // ------------------------------------------------------------------` && |\n| &&
             `    // Frontend action dispatch: the handlers behind the controller's eF()` && |\n| &&
             `    // entry point and behind every backend follow-up action. eF itself` && |\n| &&
             `    // stays on View1.controller (its name is part of the protocol -` && |\n| &&
             `    // backend-generated view XML binds events to eB/eF); the behavior` && |\n| &&
             `    // lives in the domain modules under core/actions/, one handler map` && |\n| &&
             `    // per domain, merged here into the one dispatch table. Handlers share` && |\n| &&
             `    // the uniform signature (oController, args); ones that need to reach` && |\n| &&
             `    // controller state (slotAction, eB, ...) receive the calling` && |\n| &&
             `    // controller as first argument.` && |\n| &&
             `    // ------------------------------------------------------------------` && |\n| &&
             `    const handlers = Object.assign(` && |\n| &&
             `      {},` && |\n| &&
             `      ControlCall.handlers,` && |\n| &&
             `      Browser.handlers,` && |\n| &&
             `      Launchpad.handlers,` && |\n| &&
             `      Variants.handlers,` && |\n| &&
             `      Shortcuts.handlers,` && |\n| &&
             `      ViewOps.handlers,` && |\n| &&
             `    );` && |\n| &&
             `` && |\n| &&
             `    // Entry point called by View1.controller's eF().` && |\n| &&
             `    function execute(oController, args) {` && |\n| &&
             `      // runCallbacks isolates each hook in its own try/catch, so a throwing` && |\n| &&
             `      // before-event hook cannot escape here.` && |\n| &&
             `      Lib.runCallbacks(AppState.state.onBeforeEventFrontend, args);` && |\n| &&
             `` && |\n| &&
             `      try {` && |\n| &&
             `        const handler = handlers[args[0]];` && |\n| &&
             `        if (handler) handler(oController, args);` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        // Backstop: individual handlers already guard themselves, but a` && |\n| &&
             `        // malformed payload must never let an error escape into the caller.` && |\n| &&
             `        Lib.logError(``FrontendAction: handler '${args[0]}' failed``, e);` && |\n| &&
             `      }` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // Entry point for the SYSTEM phase. Two differences to execute( ), both` && |\n| &&
             `    // deliberate: the result is RETURNED so an async view display can be` && |\n| &&
             `    // awaited before the next action runs, and errors are NOT swallowed - a` && |\n| &&
             `    // malformed-XML load has always propagated to _processAfterRendering and` && |\n| &&
             `    // surfaced the fatal "App Terminated" overlay rather than leaving the app` && |\n| &&
             `    // half-built behind a log line.` && |\n| &&
             `    //` && |\n| &&
             `    // ``ctx`` is the action context: today it carries ``seq``, the stamp of the` && |\n| &&
             `    // request the processed response belongs to, which the VIEW_SLOTS` && |\n| &&
             `    // display path needs to discard builds a newer request superseded. It is` && |\n| &&
             `    // threaded through the dispatch as an argument - never parked on shared` && |\n| &&
             `    // state, where a parallel response's phase would overwrite it.` && |\n| &&
             `    function executeSystem(oController, args, ctx) {` && |\n| &&
             `      Lib.runCallbacks(AppState.state.onBeforeEventFrontend, args);` && |\n| &&
             `      const handler = handlers[args[0]];` && |\n| &&
             `      if (!handler) {` && |\n| &&
             `        Lib.logError(``FrontendAction: unknown system action '${args[0]}'``);` && |\n| &&
             `        return undefined;` && |\n| &&
             `      }` && |\n| &&
             `      return handler(oController, args, ctx);` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // Run one SYSTEM action from the response's T_SYSTEM list. A system` && |\n| &&
             `    // action is always framework-generated and arrives as a real JSON array` && |\n| &&
             `    // (the backend embeds it into the response - handler actions_embed);` && |\n| &&
             `    // the string form stays accepted so a skewed backend keeps working.` && |\n| &&
             `    // There are no legacy formats here, and errors propagate: a failing` && |\n| &&
             `    // view display has to reach _processAfterRendering, which turns it` && |\n| &&
             `    // into the fatal overlay instead of leaving the app half-built.` && |\n| &&
             `    function runSystem(item, oController, ctx) {` && |\n| &&
             `      let args = item;` && |\n| &&
             `      if (!Array.isArray(args)) {` && |\n| &&
             `        try {` && |\n| &&
             `          args = JSON.parse(item);` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          Lib.logError(``systemJs: '${item}' is no action payload``, e);` && |\n| &&
             `          return undefined;` && |\n| &&
             `        }` && |\n| &&
             `      }` && |\n| &&
             `      if (!Array.isArray(args)) {` && |\n| &&
             `        Lib.logError(``systemJs: '${item}' is no action payload``);` && |\n| &&
             `        return undefined;` && |\n| &&
             `      }` && |\n| &&
             `      return executeSystem(oController, args, ctx);` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // Run one APP follow-up action / custom-JS snippet from the response's` && |\n| &&
             `    // T_CUSTOM list.` && |\n| &&
             `    // Format A:  a real JSON array ["EVENT", ...args] - the structured form` && |\n| &&
             `    //            every framework follow-up action travels in (embedded into` && |\n| &&
             `    //            the response by the backend - handler actions_embed). Pure` && |\n| &&
             `    //            data, dispatched via oController.eF( ) - no code is parsed` && |\n| &&
             `    //            or evaluated on this path. The stringified form stays` && |\n| &&
             `    //            accepted so a skewed backend keeps working.` && |\n| &&
             `    // Formats B/C: legacy app-authored snippets (raw strings the backend` && |\n| &&
             `    //            passes through untouched) - see actions/LegacyCustomJs.` && |\n| &&
             `    function runCustom(item, oController) {` && |\n| &&
             `      try {` && |\n| &&
             `        if (Array.isArray(item)) {` && |\n| &&
             `          oController.eF(...item);` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `        const snippet = item.trim();` && |\n| &&
             `        if (snippet.startsWith("[")) {` && |\n| &&
             `          // JSON array -> structured follow-up action. A raw-JS expression` && |\n| &&
             `          // that merely starts with "[" is no JSON array, so it fails the` && |\n| &&
             `          // parse and falls through to the legacy formats.` && |\n| &&
             `          try {` && |\n| &&
             `            const args = JSON.parse(snippet);` && |\n| &&
             `            if (Array.isArray(args)) {` && |\n| &&
             `              oController.eF(...args);` && |\n| &&
             `              return;` && |\n| &&
             `            }` && |\n| &&
             `          } catch {` && |\n| &&
             `            // not JSON - keep going with the legacy formats` && |\n| &&
             `          }` && |\n| &&
             `        }` && |\n| &&
             `        LegacyCustomJs.run(item, oController);` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        Lib.logError("customJs: execution failed", e);` && |\n| &&
             `      }` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    return { execute, executeSystem, runSystem, runCustom };` && |\n| &&
             `  },` && |\n| &&
             `);` && |\n| &&
             `` && |\n| &&
              ``.

  ENDMETHOD.

ENDCLASS.
