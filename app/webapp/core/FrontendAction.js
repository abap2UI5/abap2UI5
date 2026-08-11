sap.ui.define(
  [
    "z2ui5/core/actions/ControlCall",
    "z2ui5/core/actions/Browser",
    "z2ui5/core/actions/Launchpad",
    "z2ui5/core/actions/Variants",
    "z2ui5/core/actions/Shortcuts",
    "z2ui5/core/actions/ViewOps",
    "z2ui5/core/actions/LegacyCustomJs",
    "z2ui5/core/Lib",
    "z2ui5/core/AppState",
  ],
  (
    ControlCall,
    Browser,
    Launchpad,
    Variants,
    Shortcuts,
    ViewOps,
    LegacyCustomJs,
    Lib,
    AppState,
  ) => {
    "use strict";

    // ------------------------------------------------------------------
    // Frontend action dispatch: the handlers behind the controller's eF()
    // entry point and behind every backend follow-up action. eF itself
    // stays on View1.controller (its name is part of the protocol -
    // backend-generated view XML binds events to eB/eF); the behavior
    // lives in the domain modules under core/actions/, one handler map
    // per domain, merged here into the one dispatch table. Handlers share
    // the uniform signature (oController, args); ones that need to reach
    // controller state (slotAction, eB, ...) receive the calling
    // controller as first argument.
    // ------------------------------------------------------------------
    const handlers = Object.assign(
      {},
      ControlCall.handlers,
      Browser.handlers,
      Launchpad.handlers,
      Variants.handlers,
      Shortcuts.handlers,
      ViewOps.handlers,
    );

    // Entry point called by View1.controller's eF().
    function execute(oController, args) {
      // runCallbacks isolates each hook in its own try/catch, so a throwing
      // before-event hook cannot escape here.
      Lib.runCallbacks(AppState.state.onBeforeEventFrontend, args);

      try {
        const handler = handlers[args[0]];
        if (handler) handler(oController, args);
      } catch (e) {
        // Backstop: individual handlers already guard themselves, but a
        // malformed payload must never let an error escape into the caller.
        Lib.logError(`FrontendAction: handler '${args[0]}' failed`, e);
      }
    }

    // Entry point for the SYSTEM phase. Two differences to execute( ), both
    // deliberate: the result is RETURNED so an async view display can be
    // awaited before the next action runs, and errors are NOT swallowed - a
    // malformed-XML load has always propagated to _processAfterRendering and
    // surfaced the fatal "App Terminated" overlay rather than leaving the app
    // half-built behind a log line.
    //
    // `ctx` is the action context: today it carries `seq`, the stamp of the
    // request the processed response belongs to, which the VIEW_SLOTS
    // display path needs to discard builds a newer request superseded. It is
    // threaded through the dispatch as an argument - never parked on shared
    // state, where a parallel response's phase would overwrite it.
    function executeSystem(oController, args, ctx) {
      Lib.runCallbacks(AppState.state.onBeforeEventFrontend, args);
      const handler = handlers[args[0]];
      if (!handler) {
        Lib.logError(`FrontendAction: unknown system action '${args[0]}'`);
        return undefined;
      }
      return handler(oController, args, ctx);
    }

    // Run one SYSTEM action from the response's T_SYSTEM list. A system
    // action is always framework-generated and arrives as a real JSON array
    // (the backend embeds it into the response - handler actions_embed);
    // the string form stays accepted so a skewed backend keeps working.
    // There are no legacy formats here, and errors propagate: a failing
    // view display has to reach _processAfterRendering, which turns it
    // into the fatal overlay instead of leaving the app half-built.
    function runSystem(item, oController, ctx) {
      let args = item;
      if (!Array.isArray(args)) {
        try {
          args = JSON.parse(item);
        } catch (e) {
          Lib.logError(`systemJs: '${item}' is no action payload`, e);
          return undefined;
        }
      }
      if (!Array.isArray(args)) {
        Lib.logError(`systemJs: '${item}' is no action payload`);
        return undefined;
      }
      return executeSystem(oController, args, ctx);
    }

    // Run one APP follow-up action / custom-JS snippet from the response's
    // T_CUSTOM list.
    // Format A:  a real JSON array ["EVENT", ...args] - the structured form
    //            every framework follow-up action travels in (embedded into
    //            the response by the backend - handler actions_embed). Pure
    //            data, dispatched via oController.eF( ) - no code is parsed
    //            or evaluated on this path. The stringified form stays
    //            accepted so a skewed backend keeps working.
    // Formats B/C: legacy app-authored snippets (raw strings the backend
    //            passes through untouched) - see actions/LegacyCustomJs.
    function runCustom(item, oController) {
      try {
        if (Array.isArray(item)) {
          oController.eF(...item);
          return;
        }
        const snippet = item.trim();
        if (snippet.startsWith("[")) {
          // JSON array -> structured follow-up action. A raw-JS expression
          // that merely starts with "[" is no JSON array, so it fails the
          // parse and falls through to the legacy formats.
          try {
            const args = JSON.parse(snippet);
            if (Array.isArray(args)) {
              oController.eF(...args);
              return;
            }
          } catch {
            // not JSON - keep going with the legacy formats
          }
        }
        LegacyCustomJs.run(item, oController);
      } catch (e) {
        Lib.logError("customJs: execution failed", e);
      }
    }

    return { execute, executeSystem, runSystem, runCustom };
  },
);
