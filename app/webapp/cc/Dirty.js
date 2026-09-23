// Invisible control that marks the session as having unsaved changes:
// inside the Launchpad via the FLP dirty flag, standalone via the
// browser's "leave page?" confirmation prompt (a beforeunload listener).
sap.ui.define(
  ["sap/ui/core/Control", "z2ui5/core/Lib", "z2ui5/core/Context"],
  (Control, Lib, Context) => {
    "use strict";

    // Every live Dirty instance that is currently dirty. The FLP dirty flag
    // and the browser's onbeforeunload are single global slots, so the guard
    // must reflect whether ANY instance is dirty - one instance clearing its
    // own flag (or being destroyed) must not wipe another instance's unsaved
    // guard (e.g. a main-view form plus a form in a dialog). PAGE-WIDE on
    // purpose, across every component on the page (core/Context.js lists
    // the prompt among what stays page-wide): the two slots it feeds are.
    // Which component an instance belongs to is what reset( ) asks.
    const dirtyControls = new Set();

    // one handler for the page, not a new closure per dirty transition
    const promptOnUnload = (e) => {
      e.preventDefault();
      e.returnValue = "";
    };

    // Added and removed as a LISTENER, never assigned to
    // window.onbeforeunload: the assignment overwrote whatever a host page
    // (or anything else on it) had installed there, and clearing it to
    // null took the host's handler down with ours. One listener per page
    // whatever the number of instances - the flag is what keeps a second
    // add (a no-op for the same function, but not free) and a stray
    // remove off the event target.
    let promptInstalled = false;

    function syncUnloadPrompt(anyDirty) {
      if (anyDirty === promptInstalled) return;
      if (anyDirty) {
        window.addEventListener("beforeunload", promptOnUnload);
      } else {
        window.removeEventListener("beforeunload", promptOnUnload);
      }
      promptInstalled = anyDirty;
    }

    const Dirty = Control.extend("z2ui5.cc.Dirty", {
      metadata: {
        properties: {
          isDirty: {
            type: "boolean",
            defaultValue: false,
          },
        },
      },
      setIsDirty(val) {
        // Empty renderer -> suppress the no-op invalidation; the effect below
        // (applying the dirty state) is what actually matters.
        this.setProperty("isDirty", val, true);
        if (val) {
          dirtyControls.add(this);
        } else {
          dirtyControls.delete(this);
        }
        this._applyDirtyState();
      },

      // Apply the AGGREGATE dirty state (any instance dirty) to whichever
      // mechanism is active: the FLP dirty flag inside the Launchpad (SAPUI5
      // only), else the browser unload prompt. The launchpad record is the
      // one of this instance's component; an instance in no component
      // (Context.of answers null) knows of no launchpad and takes the
      // browser prompt - the standalone behaviour, nothing to log.
      _applyDirtyState() {
        applyDirtyState(Context.of(this)?.state.oLaunchpad);
      },
      exit() {
        dirtyControls.delete(this);
        this._applyDirtyState();
      },
      renderer: Lib.EMPTY_RENDERER,
    });

    // The aggregate applied through `launchpad` (the oLaunchpad record of
    // whichever context asked - the FLP container is a page singleton, so
    // any one that has it does).
    function applyDirtyState(launchpad) {
      const anyDirty = dirtyControls.size > 0;
      try {
        const hasFlpDirtyFlag =
          launchpad?.Container?.setDirtyFlag && launchpad.ShellUIService;
        if (hasFlpDirtyFlag) {
          launchpad.Container.setDirtyFlag(anyDirty);
          // the branch is decided PER CALL, and ShellUIService arrives
          // asynchronously (Component._initLaunchpad): a setIsDirty(true)
          // before it resolved took the else branch and set the unload
          // prompt - clear it here, or the FLP user keeps answering a
          // "leave page?" dialog for a dirty state that is long gone
          syncUnloadPrompt(false);
        } else {
          syncUnloadPrompt(anyDirty);
        }
      } catch (e) {
        Lib.logError("Dirty._applyDirtyState: setDirtyFlag failed", e);
        syncUnloadPrompt(anyDirty);
      }
    }

    // Component teardown (Component.exit, before Context.destroy). The set
    // above is MODULE state - it has to be, because the two mechanisms it
    // feeds are single global slots - and an instance only leaves it
    // through its own exit( ). The POPUP and POPOVER slots are not
    // destroyed on the way out, so a Dirty control inside a dialog never
    // runs one: its entry survived the component and kept
    // window.onbeforeunload installed, and the next app (an FLP re-launch
    // keeps the page alive) asked "leave page?" for unsaved changes that
    // belonged to an app that no longer exists. Drops ONLY the instances of
    // `ctx` (Context.of answers it while the component still exists): a
    // second component on the page keeps its own marks, and the prompt and
    // the FLP flag are re-synced from what remains. The flag is written
    // through the launchpad of `ctx` - the one that set it - or, without
    // one, through that of a remaining instance.
    Dirty.reset = function reset(ctx) {
      for (const inst of dirtyControls) {
        if (Context.of(inst) === ctx) dirtyControls.delete(inst);
      }
      let launchpad = ctx?.state?.oLaunchpad;
      for (const inst of dirtyControls) {
        if (launchpad) break;
        launchpad = Context.of(inst)?.state.oLaunchpad;
      }
      applyDirtyState(launchpad);
    };

    return Dirty;
  },
);
