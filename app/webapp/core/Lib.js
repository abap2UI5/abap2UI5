// Shared helper module of the z2ui5 frontend. core/AppState.js owns the
// shared frontend state and documents the complete field inventory
// (public contract vs. internal fields, plus their defaults); the helpers
// here reach it via AppState.state instead of the z2ui5 global.
//
// Shared rendering pattern of the custom controls (Timer.js, Focus.js,
// Scrolling.js, ...): the renderer only *marks* work by setting a
// `_pending*` flag on the control instance, and onAfterRendering() consumes
// the flag and performs the actual DOM work (focus, scrolling, timers, tree
// state). Renderers must stay cheap and free of visible side effects
// (rendering API v2); deferring to onAfterRendering also guarantees the
// control's DOM exists.
//
// Nothing hash/route related belongs here: core/Router.js is the one module
// that knows how a URL hash is split between the FLP shell and the running
// app, and the only one that writes it. Two modules read the raw hash
// without splitting it (core/Server.js ships it as S_FRONT.HASH,
// core/actions/Launchpad.js takes the part before the "#" as a base URL);
// everything else asks the Router.
sap.ui.define(
  ["z2ui5/core/AppState", "sap/ui/core/Element"],
  (AppState, Element) => {
    "use strict";

    // Resolve a control id to its sap.ui.core.Element via the global registry.
    // Element.getElementById arrived in UI5 1.119; older bootstraps fall back
    // to the deprecated sap.ui.getCore().byId. Returns null when the id is
    // empty or does not resolve, so callers can treat "not found" uniformly.
    function getElementById(sId) {
      if (!sId) return null;
      if (Element.getElementById) return Element.getElementById(sId) || null;
      /* ui5lint-disable no-globals, no-deprecated-api --
       deliberate fallback for UI5 releases without Element.getElementById
       (added in 1.119); the modern API is used in the branch above. */
      if (sap.ui.getCore) {
        const core = sap.ui.getCore();
        if (core?.byId) return core.byId(sId) || null;
      }
      /* ui5lint-enable no-globals, no-deprecated-api */
      return null;
    }

    // Resolve the central UI5 messaging facade version-independently.
    // sap/ui/core/Messaging arrived in 1.118 and is the only API left in
    // UI5 2.x; older releases expose the same interface (getMessageModel,
    // registerObject, unregisterObject) via the MessageManager singleton.
    // Returns null when neither is available (bare test bootstraps).
    // Memoised once resolved - both facades are singletons, and every slot
    // attach and every slot teardown asks for it (a MAIN rebuild is five
    // teardowns and a build), so the loader lookup ran ~6x per roundtrip.
    // Only a truthy answer is kept: before Component.init's warm-load
    // resolves, the module may legitimately not be there yet.
    let messagingFacade = null;
    function getMessaging() {
      if (messagingFacade) return messagingFacade;
      const Messaging = sap.ui.require("sap/ui/core/Messaging");
      if (Messaging) {
        messagingFacade = Messaging;
        return Messaging;
      }
      /* ui5lint-disable no-globals, no-deprecated-api --
       deliberate fallback for UI5 releases without sap/ui/core/Messaging
       (added in 1.118); the modern API is used in the branch above. */
      if (sap.ui.getCore) {
        const core = sap.ui.getCore();
        if (core?.getMessageManager) {
          messagingFacade = core.getMessageManager();
          return messagingFacade;
        }
      }
      /* ui5lint-enable no-globals, no-deprecated-api */
      return null;
    }

    // Probe for the sap/ui/core/Theming module (since 1.118) - the ONLY way
    // it may be reached (rule 12: a hard sap.ui.define dependency 404s on
    // 1.71 and kills the whole component load). On modern UI5 the core has
    // it loaded so the probing require finds it; on older releases it
    // returns null and the caller falls back or reports "not available".
    function getThemingModule() {
      return sap.ui.require("sap/ui/core/Theming") || null;
    }

    // The running theme, version-independently. sap/ui/core/Theming is the
    // only API left in UI5 2.x; older releases expose the theme through the
    // Configuration singleton. Returns "" when neither answers (bare test
    // bootstraps) - never throws, so a diagnostic caller cannot be the
    // thing that breaks.
    function getTheme() {
      try {
        const Theming = getThemingModule();
        if (Theming?.getTheme) return Theming.getTheme();
        /* ui5lint-disable no-globals, no-deprecated-api --
         deliberate fallback for UI5 releases without sap/ui/core/Theming
         (added in 1.118); the modern API is used in the branch above. */
        if (sap.ui.getCore) {
          const config = sap.ui.getCore().getConfiguration?.();
          if (config?.getTheme) return config.getTheme();
        }
        /* ui5lint-enable no-globals, no-deprecated-api */
      } catch (e) {
        logError("Lib: reading theme failed", e);
      }
      return "";
    }

    // Language and text direction, version-independently - the same probe
    // for sap/base/i18n/Localization (since 1.118, the only API left in
    // UI5 2.x); older releases expose both through the Configuration.
    function getLocale() {
      try {
        const Localization = sap.ui.require("sap/base/i18n/Localization");
        if (Localization?.getLanguage) {
          return {
            language: Localization.getLanguage(),
            rtl: Boolean(Localization.getRTL?.()),
          };
        }
        /* ui5lint-disable no-globals, no-deprecated-api --
         deliberate fallback for UI5 releases without
         sap/base/i18n/Localization (added in 1.118); the modern API is used
         in the branch above. */
        if (sap.ui.getCore) {
          const config = sap.ui.getCore().getConfiguration?.();
          if (config?.getLanguage) {
            return {
              language: config.getLanguage(),
              rtl: Boolean(config.getRTL?.()),
            };
          }
        }
        /* ui5lint-enable no-globals, no-deprecated-api */
      } catch (e) {
        logError("Lib: reading locale failed", e);
      }
      return { language: "", rtl: false };
    }

    // True when the running UI5 ships the sap/ui/core/Messaging module (added
    // in 1.118). Callers use it to skip warm-loading that module on older
    // releases (e.g. 1.71) where an async require would 404 and make the
    // ui5loader retry noisily via synchronous XHR. getMessaging()'s
    // MessageManager fallback covers those releases instead.
    //
    // An UNREADABLE version means "modern", never "old": the legacy-free
    // (UI5 2.x) build no longer ships the sap.ui.version global, so probing
    // it there yields undefined on a 1.142 runtime. Answering "false" for
    // that case is doubly wrong - legacy-free is the one runtime where
    // sap/ui/core/Messaging is the ONLY messaging API, because the
    // sap.ui.getCore().getMessageManager() fallback in getMessaging() is
    // gone too. The warm-load in Component.init would then be skipped and
    // getMessaging() would return null for good: no message> model, no
    // handleValidation. Only a version we can read AND that is older than
    // 1.118 may switch the warm-load off.
    function hasMessagingModule() {
      /* ui5lint-disable no-globals --
       sap.ui.version is the only way to read the running UI5 version; there
       is no injected/module equivalent. Absent on the legacy-free build. */
      const rawVersion = String(sap.ui.version || "");
      /* ui5lint-enable no-globals */
      const [major, minor] = rawVersion.split(".").map(Number);
      if (!Number.isFinite(major) || !Number.isFinite(minor)) return true;
      return major > 1 || (major === 1 && minor >= 118);
    }

    // Cap the error log so a long-running session cannot grow it unbounded.
    const MAX_ERRORS = 100;

    // Append an entry to the shared error log and drop the oldest entry once
    // the cap is reached. In the app the array always exists (AppState
    // default); the guard keeps the helper usable standalone, e.g. in the
    // Node specs that load this module with a bare AppState stub.
    function logError(message, error) {
      const state = AppState.state;
      if (!state.errors) state.errors = [];
      const entry = { message, ts: new Date().toISOString() };
      if (error !== undefined) entry.error = error;
      state.errors.push(entry);
      if (state.errors.length > MAX_ERRORS) state.errors.shift();
    }

    // True while `oController` is one of the slot controllers the CURRENT
    // app state owns. This is the liveness test for a View1 controller,
    // and isDestroyed( ) below is NOT: sap.ui.core.mvc.Controller is no
    // ManagedObject - it has neither isDestroyed() nor bIsDestroyed on any
    // release (checked on 1.71 and 1.144) - and the five controllers are
    // created once per component (App.controller) and never destroyed, so
    // isDestroyed( controller ) answered "alive" for a torn-down app and
    // every guard on it was dead code: variant poll chains kept resolving
    // the NEXT app's controls after an FLP teardown. What does end a
    // controller's life is Component.exit -> AppState.reset( ): the state
    // is rebuilt with the slot fields null and the next launch registers a
    // fresh set. Membership in the current state is the test, so it holds
    // across every release and needs no flag on the controller.
    const CONTROLLER_FIELDS = [
      "oController",
      "oControllerNest",
      "oControllerNest2",
      "oControllerPopup",
      "oControllerPopover",
    ];
    function isControllerAlive(oController) {
      if (!oController) return false;
      const state = AppState.state;
      return CONTROLLER_FIELDS.some((field) => state[field] === oController);
    }

    // True when the object supports isDestroyed() and reports destroyed.
    // For a CONTROL (a ManagedObject). A controller is asked with
    // isControllerAlive( ) above - see there for why this one cannot tell.
    function isDestroyed(obj) {
      if (!obj) return false;
      // ManagedObject#isDestroyed( ) is @since 1.93 - on the 1.71 floor the
      // method is absent and the guard would read "alive" for a destroyed
      // control, so fall back to the flag every release carries
      if (typeof obj.isDestroyed === "function") return obj.isDestroyed();
      return Boolean(obj.bIsDestroyed);
    }

    // A companion control (MultiInputExt, UploadSetExt, ...) resolves its
    // target after EVERY render - the onAfterRendering hook it registers in
    // init() fires once per roundtrip - but may attach its handlers only
    // once, or every roundtrip would add another listener. Returns true
    // exactly once: the first render at which `target` actually resolved.
    // The claim is recorded in the control's own `checkInit` property (set
    // without invalidating, these controls render nothing).
    function claimOnce(owner, target) {
      if (!target || owner.getProperty("checkInit")) return false;
      owner.setProperty("checkInit", true, true);
      return true;
    }

    // True when the object exists and is not destroyed. Used to guard
    // async continuations (await, FileReader, getUserMedia, ...) against
    // controls or views that were torn down in the meantime.
    function isAlive(obj) {
      return Boolean(obj) && !isDestroyed(obj);
    }

    // Helpers for managing the shared callback arrays (onBeforeRoundtrip,
    // onAfterRendering, ...). Several custom controls register hooks here in
    // init() and remove them in exit(). The arrays always exist in the app
    // (AppState defaults); the guard keeps the helper standalone-safe.
    function registerCallback(name, fn) {
      const state = AppState.state;
      if (!state[name]) state[name] = [];
      state[name].push(fn);
    }

    function unregisterCallback(name, fn) {
      const state = AppState.state;
      if (!state[name]) return;
      state[name] = state[name].filter((f) => f !== fn);
    }

    // Read a File object as a data URL and hand the result to onLoaded.
    // The callback is skipped when `owner` was destroyed while the
    // FileReader was busy; read errors are logged under `errorContext` and
    // reported to `onFailed` (readFilesInTurn's way of stepping over a file
    // that cannot be read - see there).
    function readFileAsDataURL(file, owner, onLoaded, errorContext, onFailed) {
      const reader = new FileReader();
      reader.onload = () => {
        if (isDestroyed(owner)) return;
        onLoaded(reader.result);
      };
      reader.onerror = () => {
        logError(`${errorContext}: FileReader failed`, reader.error);
        if (onFailed && !isDestroyed(owner)) onFailed();
      };
      reader.readAsDataURL(file);
    }

    // Read a set of picked files ONE AT A TIME, the next only once the
    // roundtrip the previous one started has landed. Both file controls
    // (cc/FileUploader, cc/UploadSetExt) carry ONE file in their bindable
    // properties and fire ONE event per file, so a multi-select that read
    // every file at once overwrote the properties before the busy guard
    // (View1.eB) had let the second event through - three files picked, one
    // arrived. They had a copy of this queue each, and the copies drifted.
    //
    // `onFile(file, result)` is all a control keeps: it writes its properties
    // and fires its event, and the queue takes it from there. A FAILED read
    // steps to the next file instead of stalling the queue - a single
    // NotReadableError used to leave `_reading` true forever, and every file
    // picked afterwards was queued and never read until the view was rebuilt.
    // The chain also ends when `owner` is destroyed, so a torn-down control
    // stops reading.
    function readFilesInTurn(owner, errorContext, onFile) {
      const queue = [];
      let reading = false;
      let cancelWait = null;

      const readNext = () => {
        const file = queue.shift();
        if (!file || isDestroyed(owner)) {
          reading = false;
          return;
        }
        reading = true;
        const step = () => {
          cancelWait = afterRoundtrip(owner, () => {
            cancelWait = null;
            readNext();
          });
        };
        readFileAsDataURL(
          file,
          owner,
          (result) => {
            onFile(file, result);
            step();
          },
          errorContext,
          // the reader failed on THIS file - the rest of the selection is
          // still readable, and nothing started a roundtrip to wait for
          readNext,
        );
      };

      return {
        add(files) {
          for (const file of files) queue.push(file);
          if (!reading) readNext();
        },
        // for the control's exit( ): drop what is left and stop waiting
        cancel() {
          queue.length = 0;
          reading = false;
          if (cancelWait) {
            cancelWait();
            cancelWait = null;
          }
        },
      };
    }

    // Cancel every pending backend timer (evStartTimer's single slot, and
    // whatever an app armed through it). A new roundtrip overrides them:
    // a timer that already fired removed itself before calling eB, so this
    // only cancels the ones still waiting. It lives here because every path
    // that starts a roundtrip owes it - View1.eB had the loop written out
    // and Server.restoreFromRoute, the Back/Forward restore, had nothing at
    // all, so a poll armed by the app one screen back kept ticking into the
    // restored one.
    function cancelPendingTimers() {
      const timers = AppState.state.timers;
      if (!timers) return;
      for (const key in timers) {
        clearTimeout(timers[key]);
        delete timers[key];
      }
    }

    // Shared tokenUpdate handling for the multi-input extensions: map the
    // added/removed UI5 tokens to plain objects and store them in the
    // control's addedTokens/removedTokens properties.
    function applyTokenUpdate(control, oEvent) {
      const isRemoved = oEvent.getParameter("type") === "removed";
      const rawList =
        oEvent.getParameter(isRemoved ? "removedTokens" : "addedTokens") || [];
      const tokens = rawList.map((item) => ({
        KEY: item.getKey(),
        TEXT: item.getText(),
      }));
      control.setProperty("addedTokens", isRemoved ? [] : tokens);
      control.setProperty("removedTokens", isRemoved ? tokens : []);
    }

    // Run every callback in `callbacks` (the shared callback arrays above),
    // swallowing individual failures so one bad callback cannot break the
    // whole event sequence.
    // Runs `fn` once the roundtrip a control just started has landed - right
    // away when it started none (state.isBusy is set synchronously by
    // View1.eB, so the answer is known the moment the event was fired). A
    // control that reports several files/values one roundtrip each hands
    // the next one over from here; firing them back to back lost every one
    // but the first on the busy guard. The one-shot hook takes itself off
    // the onAfterRendering list again; `owner` destroyed meanwhile ends it.
    // Returns a function that cancels the wait (for the owner's exit).
    function afterRoundtrip(owner, fn) {
      if (!AppState.state.isBusy) {
        fn();
        return () => {};
      }
      const once = () => {
        unregisterCallback("onAfterRendering", once);
        if (isDestroyed(owner)) return;
        fn();
      };
      registerCallback("onAfterRendering", once);
      return () => unregisterCallback("onAfterRendering", once);
    }

    function runCallbacks(callbacks, ...args) {
      if (!callbacks) return;
      for (const fn of callbacks) {
        if (!fn) continue;
        try {
          fn(...args);
        } catch (e) {
          logError("runCallbacks: callback failed", e);
        }
      }
    }

    // Runs `fn` once `control` has a DOM reference: immediately when it is
    // already rendered, otherwise once after its next rendering. The call
    // is skipped when `owner` was destroyed in the meantime.
    //
    // `owner` is a CONTROL: the guard is isDestroyed( ), which cannot answer
    // for a View1 CONTROLLER (no ManagedObject - see isControllerAlive). A
    // caller whose owner is a controller therefore has to ask
    // isControllerAlive( ) in `fn` itself; core/actions/ControlCall.js
    // (whenAnchorRendered) and core/actions/ViewOps.js (SET_FOCUS) both do.
    function whenRendered(control, owner, fn) {
      if (control.getDomRef()) {
        // Same owner-liveness guard as the deferred branch below: a caller
        // resuming from an async continuation may reach here after its owner
        // was torn down while the target control is still rendered.
        if (!isDestroyed(owner)) fn();
        return;
      }
      const delegate = {
        onAfterRendering: () => {
          control.removeEventDelegate(delegate);
          if (!isDestroyed(owner)) fn();
        },
      };
      control.addEventDelegate(delegate);
    }

    // Join a control's own text with its ancestors' texts, outermost first
    // ("Create New Site > Official Store"), the `while (oItem instanceof
    // MenuItem)` loop UI5 samples write in a controller. A control-tree walk
    // cannot be expressed as a binding path, which is why it lives here and is
    // reachable from an event argument via the controller's textPath().
    //
    // The walk climbs getParent() and BREAKS at the first ancestor that has no
    // getText - it does not skip that ancestor and keep climbing. So the result
    // is a breadcrumb only while every level in between is text-bearing, and
    // whether that holds is a question about the control, not about this
    // function. It notably does NOT hold for sap.m.Menu any more: since UI5
    // 1.136 a Menu forwards its items aggregation into an internal
    // sap.m.MenuWrapper (Menu.js, forwarding idSuffix "-menuWrapper"), the
    // wrapper declares no text property and no getText, and it sits between
    // every item and its parent item - so the walk stops after one hop and
    // returns the leaf text alone. UI5's own sample loop breaks on the same
    // wrapper, so that is upstream behaviour rather than a difference, but do
    // not promise a menu breadcrumb on the strength of this helper.
    function getTextPath(control, separator) {
      const texts = [];
      let node = control;
      // the control tree is finite, but never loop forever on a cyclic or
      // self-referencing parent
      for (let i = 0; node && i < 100; i++) {
        if (typeof node.getText !== "function") break;
        const text = node.getText();
        if (text) texts.unshift(text);
        node = typeof node.getParent === "function" ? node.getParent() : null;
      }
      return texts.join(separator || " > ");
    }

    // Copy text to the clipboard, preferring the async clipboard API with a
    // fallback to the legacy textarea + execCommand approach.
    // Async clipboard API FIRST, execCommand fallback second - the inverse
    // of core/ErrorView.js, deliberately: Lib serves ordinary app features
    // on pages that are usually secure origins, where the async API is the
    // reliable one. ErrorView prefers execCommand because it must also work
    // on the insecure on-prem HTTP origins where navigator.clipboard does
    // not exist - and a fatal-error overlay is exactly where that matters.
    function copyToClipboard(textToCopy) {
      if (navigator.clipboard?.writeText) {
        navigator.clipboard.writeText(textToCopy).catch((err) => {
          logError("Clipboard: writeText failed, falling back", err);
          copyToClipboardFallback(textToCopy);
        });
        return;
      }
      copyToClipboardFallback(textToCopy);
    }

    function copyToClipboardFallback(textToCopy) {
      const textarea = document.createElement("textarea");
      textarea.value = textToCopy;
      textarea.setAttribute("readonly", "");
      textarea.style.position = "fixed";
      textarea.style.top = "-1000px";
      textarea.style.opacity = "0";
      document.body.appendChild(textarea);
      textarea.select();
      try {
        if (!document.execCommand("copy")) {
          logError("Clipboard: execCommand('copy') returned false");
        }
      } catch (err) {
        logError("Clipboard: execCommand('copy') threw", err);
      } finally {
        document.body.removeChild(textarea);
      }
    }

    // ------------------------------------------------------------------
    // Pure helpers - free of UI5 dependencies so the Node specs under
    // node/tests/ can load this module with a stubbed sap.ui.define and
    // test the real implementation instead of a copy.
    // ------------------------------------------------------------------

    const SAFE_PROTOCOLS = ["http:", "https:"];

    // Normalizes any value for display: null and undefined become the empty
    // string, everything else its string representation.
    function toText(val) {
      return val == null ? "" : String(val);
    }

    // True for a DOM element that carries a text caret.
    function isTextInput(el) {
      return (
        Boolean(el) && (el.tagName === "INPUT" || el.tagName === "TEXTAREA")
      );
    }

    // The caret of a text field as { start, end }, or null when the element
    // is no text field or carries no selection. Input types without a text
    // selection (number, date, ...) throw or return null on selectionStart -
    // reporting that as 0 would later snap the cursor to the far left, so
    // "no caret" has to stay distinguishable from "caret at 0".
    function readCaret(el) {
      if (!isTextInput(el)) return null;
      try {
        const start = el.selectionStart;
        const end = el.selectionEnd;
        if (start == null || end == null) return null;
        return { start, end };
      } catch {
        return null;
      }
    }

    // Collapse a UI5 Device `system` flag object into a single label. The
    // order matters - phone/tablet/combi are mutually exclusive with the
    // desktop fallback. Shared by core/Session.js (request payload) and
    // the Info control so both report the same value.
    function deriveSystemType(system) {
      if (!system) return "desktop";
      if (system.phone) return "phone";
      if (system.tablet) return "tablet";
      if (system.combi) return "combi";
      return "desktop";
    }

    // Shared first step of the URL validators below: resolve the URL against
    // the current origin, log and return null when it is empty or malformed.
    function parseUrl(url) {
      if (!url) return null;
      try {
        return new URL(url, window.location.origin);
      } catch (e) {
        logError(`Security: Invalid URL format: ${url}`, e);
        return null;
      }
    }

    function hasSafeProtocol(parsed) {
      if (SAFE_PROTOCOLS.includes(parsed.protocol)) return true;
      logError(
        `Security: Blocked redirect with invalid protocol: ${parsed.protocol}`,
      );
      return false;
    }

    // Returns true only if the URL is on the same origin and uses http/https.
    function isValidRedirectURL(url) {
      const parsed = parseUrl(url);
      if (!parsed) return false;
      if (parsed.origin !== window.location.origin) {
        logError(`Security: Blocked redirect to different origin: ${url}`);
        return false;
      }
      return hasSafeProtocol(parsed);
    }

    // Returns true if the URL uses a safe (http/https) protocol. Unlike
    // isValidRedirectURL this allows cross-origin targets, so it fits
    // outbound redirects to external sites while still blocking dangerous
    // schemes such as javascript:, data: or vbscript:.
    function isSafeRedirectProtocol(url) {
      const parsed = parseUrl(url);
      return parsed !== null && hasSafeProtocol(parsed);
    }

    // Returns true for URLs that are safe as download targets: data: and
    // blob: (generated content) plus http(s). Blocks javascript: and other
    // active schemes, consistent with the redirect validators above.
    function isSafeDownloadURL(url) {
      const parsed = parseUrl(url);
      return (
        parsed !== null &&
        (parsed.protocol === "data:" ||
          parsed.protocol === "blob:" ||
          SAFE_PROTOCOLS.includes(parsed.protocol))
      );
    }

    // A usable stateful session id ("sap-contextid"). We must never put a
    // missing value on the wire: an empty or - via string coercion of a
    // JS `undefined` - the literal "undefined" makes the SAP Web Dispatcher /
    // ICM log "invalid w3c session id" / "HttpExtractSID: SID wrong len: 9"
    // on every roundtrip. Only forward a real, non-empty id.
    function isValidContextId(id) {
      return typeof id === "string" && id !== "" && id !== "undefined";
    }

    // Parse the path segments behind the attribute into (row, field) steps.
    // Returns null when the segments do not follow the alternating
    // <numeric row>/<field name> shape - the caller then ships the whole
    // attribute. A non-numeric segment after a field (a struct member, e.g.
    // attr/3/S_ADR/CITY) marks the field as leaf: the whole current value at
    // row/field is shipped, which always covers the deeper edit too.
    function parseDeltaSteps(segs) {
      const steps = [];
      let i = 0;
      while (i < segs.length) {
        const row = segs[i];
        if (row === "" || Number.isNaN(Number(row))) return null;
        const field = segs[i + 1];
        if (
          field === undefined ||
          field === "" ||
          !Number.isNaN(Number(field))
        ) {
          return null;
        }
        i += 2;
        if (i >= segs.length || Number.isNaN(Number(segs[i]))) {
          steps.push({ row, field, leaf: true });
          return steps;
        }
        // a numeric segment follows -> field is a nested table, walk deeper
        steps.push({ row, field, leaf: false });
      }
      return null;
    }

    // Build the delta object sent to the backend. `paths` is the set of
    // model paths that the user edited; `model` is the full view model data.
    // Table edits become (recursively nested) __delta structures, so a cell
    // edit in a nested/tree table ships only the changed cell instead of
    // the whole outer table.
    function buildDeltaFromPaths(paths, modelData) {
      const delta = {};
      for (const path of paths) {
        // path looks like "/<attr>" or "/<attr>/<row>/<field>" with
        // arbitrarily deep <row>/<subtable> repetitions for nested tables
        const parts = path.slice(1).split("/");
        const attr = parts[0];
        const steps = parseDeltaSteps(parts.slice(1));
        if (!steps) {
          // Scalar or unrecognized shape -> ship the whole attribute. The
          // full value always wins over any queued delta: both read the
          // same current model data, so it is a superset of every delta.
          delta[attr] = modelData[attr];
          continue;
        }
        // A full attribute queued by another path already carries every
        // cell (both read the same current model data) - never downgrade
        // it to a partial delta, regardless of Set iteration order.
        if (attr in delta && !delta[attr]?.__delta) continue;
        if (!delta[attr]?.__delta) delta[attr] = { __delta: {} };
        let node = delta[attr];
        let model = modelData[attr];
        for (const { row, field, leaf } of steps) {
          const rows = node.__delta;
          if (!rows[row]) rows[row] = {};
          const rowDelta = rows[row];
          model = model?.[Number(row)]?.[field];
          if (leaf) {
            // The leaf value (cell, struct or whole sub-table) replaces any
            // nested delta queued for the same field - it reads the same
            // current model data and therefore carries those edits too.
            rowDelta[field] = model;
            break;
          }
          // Nested table step - a whole sub-value queued by another path
          // already covers this deeper edit.
          if (field in rowDelta && !rowDelta[field]?.__delta) break;
          if (!rowDelta[field]?.__delta) rowDelta[field] = { __delta: {} };
          node = rowDelta[field];
        }
      }
      return delta;
    }

    // Turns an HTML "details" snippet from the backend into safe HTML.
    //
    // Safe by RECONSTRUCTION, not by removal: nothing of the parsed document
    // is passed through: every text node is escaped through a DOM property
    // and every element is re-emitted only if its tag is on this whitelist,
    // without a single attribute. An element that is not on it contributes
    // its children and nothing else, so a `<script>`/`<img onerror=...>`
    // cannot survive in any shape.
    //
    // The whitelist is the intersection of what the backend produces
    // (z2ui5_cl_ui5_util_context=>ui5_data_box_format) and what
    // sap.m.FormattedText keeps when it renders the result.
    const MSG_DETAIL_TAGS = new Set(["UL", "OL", "LI", "STRONG", "EM", "P"]);

    // ... and these are dropped WITH their content - see sanitizeMessageNodes
    const MSG_DROP_TAGS = new Set(["SCRIPT", "STYLE", "TEMPLATE"]);

    // The DOM helpers are created lazily so loading this module does not
    // require a DOM (the Node specs never call this function).
    let _msgParser = null;
    let _sanitizeEl = null;

    function escapeMessageText(text) {
      _sanitizeEl.textContent = text;
      return _sanitizeEl.innerHTML;
    }

    // Walks the children of one node. Recursion is what keeps a NESTED list
    // nested: the previous version collected the top-level <li>s and took
    // each one's textContent, which folded a whole subtree - a table inside a
    // structure inside a row - into one run-on line. That was invisible for
    // as long as the details sat behind the "Show details" link and became
    // the whole content of the box when they stopped.
    function sanitizeMessageNodes(node) {
      let out = "";
      for (const child of node.childNodes) {
        if (child.nodeType === 3) {
          out += escapeMessageText(child.nodeValue);
        } else if (child.nodeType === 1) {
          const tag = child.tagName.toUpperCase();
          if (MSG_DROP_TAGS.has(tag)) {
            // what these carry is code, not text: dropping the ELEMENT the
            // way an unknown tag is dropped would keep its body and print
            // `alert(1)`. Where the parser puts them differs (a leading
            // <script> lands in <head>, one inside a <li> does not), so the
            // rule sits here rather than depending on that.
            continue;
          }
          if (tag === "BR") {
            out += "<br>";
          } else if (MSG_DETAIL_TAGS.has(tag)) {
            const name = tag.toLowerCase();
            out += `<${name}>${sanitizeMessageNodes(child)}</${name}>`;
          } else {
            // not on the whitelist: the tag goes, what it wrapped stays
            out += sanitizeMessageNodes(child);
          }
        }
      }
      return out;
    }

    function sanitizeMessageDetails(html) {
      if (!_msgParser) {
        _msgParser = new DOMParser();
        _sanitizeEl = document.createElement("div");
      }
      const doc = _msgParser.parseFromString(html, "text/html");
      return sanitizeMessageNodes(doc.body);
    }

    // The MAIN view and its two nested views (NEST, NEST2) share ONE JSON
    // model: the nested views are inserted into the MAIN control tree and
    // inherit its default model through UI5 model propagation instead of each
    // creating their own. Popup and popover are opened standalone (outside the
    // MAIN tree) and keep their own model.
    const ROOT_MODEL_SLOTS = ["MAIN", "NEST", "NEST2"];

    function isRootModelSlot(slotKey) {
      return ROOT_MODEL_SLOTS.includes(slotKey);
    }

    // Effective JSONModel size limit for a slot. Because the root slots share a
    // single model, a per-view limit collapses onto it - the largest requested
    // limit across MAIN/NEST/NEST2 wins. Popup/popover keep their own limit.
    // Returns undefined when nothing is stored, so callers keep the UI5 default.
    function effectiveSizeLimit(viewSizeLimits, slotKey) {
      if (!isRootModelSlot(slotKey)) return viewSizeLimits[slotKey];
      let max;
      for (const key of ROOT_MODEL_SLOTS) {
        const limit = viewSizeLimits[key];
        if (limit !== undefined && (max === undefined || limit > max)) {
          max = limit;
        }
      }
      return max;
    }

    // Render the invisible <span> placeholder shared by every marker custom
    // control (Focus, Timer, Scrolling, Tree, Info, Geolocation, Storage): the
    // real work happens in onAfterRendering (see the module header), so the
    // renderer only needs a cheap hidden DOM anchor. apiVersion-2 renderer.
    function renderInvisibleSpan(oRm, oControl) {
      oRm.openStart("span", oControl);
      oRm.style("display", "none");
      oRm.openEnd();
      oRm.close("span");
    }

    // The renderer of a companion control that renders NOTHING (not even a
    // placeholder span - it lives outside the visible tree entirely). One
    // shared spec instead of the same literal in every cc/ module; UI5 copies
    // the spec into the control's own renderer class, so sharing is safe.
    const EMPTY_RENDERER = { apiVersion: 2, render() {} };

    // The init/exit pair every companion control repeats: register the bound
    // hook method as a shared-state callback and hand back the unregister.
    //   init() { this._unhook = Lib.hookCallback(this, "onAfterRendering", "setControl"); }
    //   exit() { this._unhook(); }
    function hookCallback(owner, callbackName, method) {
      const bound = owner[method].bind(owner);
      registerCallback(callbackName, bound);
      return () => unregisterCallback(callbackName, bound);
    }

    // Event arguments are whatever the UI5 expression grammar produced for
    // them. Most are strings or numbers, but a UI5 event parameter is quite
    // often a CONTROL or an ARRAY OF CONTROLS -
    // ViewSettingsDialog.confirm/filterItems, Menu.itemSelected/item,
    // SinglePlanningCalendar.selectedDatesChange with its DateRange list. Those
    // could not travel before: JSON.stringify walks a ManagedObject through its
    // parent/aggregation graph and throws on the circular reference, so the
    // whole roundtrip body failed to serialize. The expression grammar has no
    // loop or lambda either, so an app could not project the array itself and
    // was left parsing a display string (the localized `filterString`) instead.
    //
    // Marshal them into plain data here: one object per control carrying its
    // control id plus the values of its metadata PROPERTIES. Which properties
    // exist is asked of the control's own metadata - nothing is interpreted,
    // renamed or decided, so this stays the thin-executor contract. The
    // backend receives it as the JSON string every object argument becomes in
    // T_EVENT_ARG and parses it with ajson.
    //
    // Anything that is not a control is handed through untouched, so this is
    // purely additive for every wire that works today.
    const MAX_ARG_DEPTH = 4;

    function isManagedObject(value) {
      return (
        value !== null &&
        typeof value === "object" &&
        typeof value.isA === "function" &&
        value.isA("sap.ui.base.ManagedObject")
      );
    }

    /* A Date property carries a CALENDAR DAY the user picked in their own
     * timezone, not a point on the timeline - UI5 fills DateRange.startDate,
     * CalendarAppointment.startDate, DatePicker.dateValue and friends with
     * LOCAL midnight of that day. JSON.stringify would take it through
     * Date.prototype.toJSON -> toISOString(), which is UTC, so east of
     * Greenwich the date part came out as the PREVIOUS day - a wrong day
     * delivered with no error anywhere.
     *
     * Serialize the local parts instead, as an ISO local timestamp with no Z.
     * That is the shape the framework already uses in the INBOUND direction
     * (model/formatter.js builds a Date from local parts precisely so a
     * date-only string does not shift), and an app reads the first ten
     * characters as the day. Sending the instant plus an offset would also be
     * recoverable, but it makes every consumer do arithmetic to recover a
     * value that was never more than a calendar day.
     *
     * An INVALID Date is left alone deliberately: UI5 produces one for an
     * empty optional date, and it must not become the string "Invalid Date" -
     * the existing path yields null, which is what the curated formatter's
     * DateCreateObject returns for a falsy input. */
    function projectValue(value) {
      // toString rather than `instanceof Date`: instanceof compares against
      // ONE realm's constructor, so a Date that crossed a realm boundary (an
      // iframe, or the vm sandbox the unit tests load this module in) is not
      // recognized and silently keeps the UTC serialization this exists to
      // avoid. The tag is realm-independent.
      if (
        Object.prototype.toString.call(value) === "[object Date]" &&
        !isNaN(value)
      ) {
        const p = (n, w = 2) => String(n).padStart(w, "0");
        return (
          `${p(value.getFullYear(), 4)}-${p(value.getMonth() + 1)}-${p(value.getDate())}` +
          `T${p(value.getHours())}:${p(value.getMinutes())}:${p(value.getSeconds())}`
        );
      }
      return value;
    }

    function projectControl(control) {
      const result = { ID: control.getId() };
      const properties = control.getMetadata().getAllProperties();
      for (const name in properties) {
        try {
          const value = control.getProperty(name);
          if (value !== undefined) result[name] = projectValue(value);
        } catch {
          // a property whose getter throws is simply not reported - the
          // remaining ones still have to reach the backend
        }
      }
      return result;
    }

    function normalizeEventArg(value, depth) {
      const level = depth || 0;
      if (level > MAX_ARG_DEPTH) return value;
      if (isManagedObject(value)) return projectControl(value);
      if (Array.isArray(value)) {
        return value.map((entry) => normalizeEventArg(entry, level + 1));
      }
      return value;
    }

    // Always returns a fresh top-level array: Server.roundtrip shifts
    // oBody.ARGUMENTS, which must not reach the caller's own rest-parameter
    // array.
    function normalizeEventArgs(args) {
      return args.map((arg) => normalizeEventArg(arg, 0));
    }

    return {
      logError,
      isDestroyed,
      isControllerAlive,
      afterRoundtrip,
      isAlive,
      claimOnce,
      isTextInput,
      readCaret,
      registerCallback,
      unregisterCallback,
      readFileAsDataURL,
      readFilesInTurn,
      cancelPendingTimers,
      applyTokenUpdate,
      runCallbacks,
      whenRendered,
      getTextPath,
      copyToClipboard,
      toText,
      deriveSystemType,
      isValidRedirectURL,
      isSafeRedirectProtocol,
      isSafeDownloadURL,
      isValidContextId,
      buildDeltaFromPaths,
      sanitizeMessageDetails,
      getElementById,
      getMessaging,
      hasMessagingModule,
      getThemingModule,
      getTheme,
      getLocale,
      isRootModelSlot,
      effectiveSizeLimit,
      renderInvisibleSpan,
      EMPTY_RENDERER,
      hookCallback,
      normalizeEventArgs,
    };
  },
);
