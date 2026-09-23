sap.ui.define(
  [
    "z2ui5/core/actions/ControlCall",
    "z2ui5/core/actions/BindingCall",
    "z2ui5/core/actions/Browser",
    "z2ui5/core/actions/Launchpad",
    "z2ui5/core/actions/Variants",
    "z2ui5/core/actions/Shortcuts",
    "z2ui5/core/actions/ViewOps",
    "z2ui5/core/Lib",
  ],
  (
    ControlCall,
    BindingCall,
    Browser,
    Launchpad,
    Variants,
    Shortcuts,
    ViewOps,
    Lib,
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
    // controller state (eB, ...) receive the calling controller as first
    // argument - and through it the component's context (oController.ctx,
    // core/Context.js), which is where every handler reads the state.
    // ------------------------------------------------------------------
    // Object.create(null) rather than {}: args[0] is an action name off the
    // wire, and on a plain object handlers["valueOf"] resolves to a function
    // from Object.prototype and gets CALLED as a handler. Same reasoning as
    // the whitelists in core/actions/ControlCall.js.
    const handlers = Object.assign(
      Object.create(null),
      ControlCall.handlers,
      BindingCall.handlers,
      Browser.handlers,
      Launchpad.handlers,
      Variants.handlers,
      Shortcuts.handlers,
      ViewOps.handlers,
    );

    // Entry point called by View1.controller's eF(). Hands the handler's
    // result back: a handler that loads something on first use returns a
    // promise, and the custom-action runner awaits it so the actions queued
    // behind it in the same response see its work done.
    function execute(oController, args) {
      // runCallbacks isolates each hook in its own try/catch, so a throwing
      // before-event hook cannot escape here.
      Lib.runCallbacks(oController?.ctx?.state.onBeforeEventFrontend, args);

      try {
        const handler = handlers[args[0]];
        if (handler) {
          return handler(oController, args);
        } else {
          // a typo in follow_up_action( ) or a wire an older frontend does
          // not know used to say nothing anywhere, while the SYSTEM phase
          // below reports its unknown action
          Lib.logError(`FrontendAction: unknown action '${args[0]}'`);
        }
      } catch (e) {
        // Backstop: individual handlers already guard themselves, but a
        // malformed payload must never let an error escape into the caller.
        Lib.logError(`FrontendAction: handler '${args[0]}' failed`, e);
      }
      return undefined;
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
      Lib.runCallbacks(oController?.ctx?.state.onBeforeEventFrontend, args);
      const handler = handlers[args[0]];
      if (!handler) {
        Lib.logError(`FrontendAction: unknown system action '${args[0]}'`);
        return undefined;
      }
      return handler(oController, args, ctx);
    }

    // Run one SYSTEM action from the response's T_SYSTEM list. A system
    // action is always framework-generated and arrives as a real JSON array
    // (the backend embeds it into the response - handler actions_serialize);
    // the string form stays accepted so a skewed backend keeps working.
    // There are no legacy formats here, and errors propagate: a failing
    // view display has to reach _processAfterRendering, which turns it
    // into the fatal overlay instead of leaving the app half-built.
    function runSystem(item, oController, ctx) {
      let args = item;
      if (typeof item === "string") {
        try {
          args = JSON.parse(item);
        } catch {
          args = null;
        }
      }
      if (!Array.isArray(args)) {
        Lib.logError(`FrontendAction: '${item}' is no system action payload`);
        return undefined;
      }
      return executeSystem(oController, args, ctx);
    }

    // Run one APP follow-up action from the response's T_CUSTOM list: a
    // JSON array ["EVENT", ...args], embedded into the response by the
    // backend (handler actions_serialize). Pure data, dispatched via
    // oController.eF( ) - no code is parsed or evaluated here. The
    // stringified form stays accepted so a skewed backend keeps working.
    // Anything else is not run.
    function runCustom(item, oController) {
      try {
        let args = item;
        if (typeof item === "string") {
          try {
            args = JSON.parse(item);
          } catch {
            args = null;
          }
        }
        if (Array.isArray(args)) {
          return oController.eF(...args);
        }
      } catch (e) {
        Lib.logError("customJs: execution failed", e);
      }
      return undefined;
    }

    return { execute, executeSystem, runSystem, runCustom };
  },
);
