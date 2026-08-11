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
    function executeSystem(oController, args) {
      Lib.runCallbacks(AppState.state.onBeforeEventFrontend, args);
      const handler = handlers[args[0]];
      if (!handler) {
        Lib.logError(`FrontendAction: unknown system action '${args[0]}'`);
        return undefined;
      }
      return handler(oController, args);
    }

    // Run one SYSTEM action from the response's T_SYSTEM list. A system
    // action is always framework-generated and therefore always a JSON
    // array - there are no legacy formats here - and errors propagate: a
    // failing view display has to reach _processAfterRendering, which turns
    // it into the fatal overlay instead of leaving the app half-built.
    function runSystem(item, oController) {
      let args;
      try {
        args = JSON.parse(item);
      } catch (e) {
        Lib.logError(`systemJs: '${item}' is no action payload`, e);
        return undefined;
      }
      if (!Array.isArray(args)) {
        Lib.logError(`systemJs: '${item}' is no action payload`);
        return undefined;
      }
      return executeSystem(oController, args);
    }

    // Run one APP follow-up action / custom-JS snippet from the response's
    // T_CUSTOM list.
    // Format A:  a JSON array ["EVENT", ...args] - the structured form the
    //            backend (z2ui5_cl_core_srv_event=>get_event_client_json)
    //            emits for every framework follow-up action. Pure data,
    //            serialized and escaped entirely in ABAP; dispatched via
    //            oController.eF( ) after a single JSON.parse - no code is
    //            parsed or evaluated on this path.
    // Formats B/C: legacy app-authored snippets - see actions/LegacyCustomJs.
    function runCustom(item, oController) {
      try {
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
