// The UI5-release compatibility layer of the z2ui5 frontend: every API
// that differs between UI5 1.71 - the oldest release abap2UI5 supports -
// and the current one is reached through a function here, never directly.
// Each function prefers the modern module and falls back to the legacy
// global (sap.ui.getCore(), the Configuration, the MessageManager) only
// when the modern one is absent, so the deprecated calls - and their
// ui5lint suppressions - are confined to this one file.
//
// A module newer than 1.71 is never a sap.ui.define dependency here (it
// 404s on 1.71 and takes the whole component down - see
// .github/scripts/frontend-module-gate.mjs); it is probed with a
// synchronous, single-id sap.ui.require at the point of use instead.
//
// When the 1.71 floor is raised, this file is where the fallbacks go.
sap.ui.define(["sap/ui/core/Element", "z2ui5/core/Lib"], (Element, Lib) => {
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
      Lib.logError("Env: reading theme failed", e);
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
      Lib.logError("Env: reading locale failed", e);
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

  // True on UI5 1.71 to 1.82, where Fragment.load processes the fragment's
  // XML synchronously: a control from a library not loaded yet is fetched
  // by synchronous XHR and executed with eval, which a CSP without
  // 'unsafe-eval' - the framework default - refuses. From 1.84 on the
  // processing is async and the ui5loader loads the library itself. An
  // unreadable version means "modern" (see hasMessagingModule).
  function fragmentLoadsSync() {
    /* ui5lint-disable no-globals --
       sap.ui.version is the only way to read the running UI5 version. */
    const rawVersion = String(sap.ui.version || "");
    /* ui5lint-enable no-globals */
    const [major, minor] = rawVersion.split(".").map(Number);
    if (!Number.isFinite(major) || !Number.isFinite(minor)) return false;
    return major === 1 && minor < 84;
  }

  // The control modules a fragment's XML instantiates: every element whose
  // local name starts upper-case, resolved against the xmlns declarations
  // (<t:Table> with xmlns:t="sap.ui.table" is sap/ui/table/Table) - the
  // same mapping UI5's XMLTemplateProcessor applies. FragmentDefinition is
  // a marker, not a class. Lower-case elements are aggregations.
  const XMLNS = /\bxmlns(?::([\w.-]+))?\s*=\s*["']([\w.]+)["']/g;
  const ELEMENT = /<(?:([\w.-]+):)?([A-Z]\w*)[\s/>]/g;
  function fragmentControlModules(xml) {
    const text = String(xml ?? "");
    const namespaces = new Map();
    for (const [, prefix, namespace] of text.matchAll(XMLNS)) {
      namespaces.set(prefix ?? "", namespace);
    }
    const result = new Set();
    for (const [, prefix, name] of text.matchAll(ELEMENT)) {
      const namespace = namespaces.get(prefix ?? "");
      if (!namespace || name === "FragmentDefinition") continue;
      result.add(`${namespace.replace(/\./g, "/")}/${name}`);
    }
    return [...result];
  }

  // Load, asynchronously, every control module a fragment instantiates
  // before Fragment.load runs - so that on 1.71 to 1.82 its synchronous
  // XML processing finds them loaded instead of fetching and eval'ing them
  // one by one (see fragmentLoadsSync). A library counting as loaded is no
  // guarantee: sap.m pulls sap.ui.layout in WITHOUT its preload bundle.
  // An async require is a script tag, never eval, and brings the module's
  // own dependencies along. A no-op on every later release. Never throws:
  // a module that fails to load only means the fragment loads the way it
  // always did, and reports its own error.
  /** @returns {Promise<void>} */
  function preloadFragmentModules(xml) {
    if (!fragmentLoadsSync()) return Promise.resolve();
    const modules = fragmentControlModules(xml);
    if (!modules.length) return Promise.resolve();
    return new Promise((resolve) => {
      sap.ui.require(
        modules,
        () => resolve(),
        (e) => {
          Lib.logError("Env: preloading the fragment's controls failed", e);
          resolve();
        },
      );
    });
  }

  // The CONTROL filters of a list binding - the ones a sap.ui.table column
  // filter row applies (Column.filter( ) uses FilterType.Control on 1.71
  // and 1.120 alike). ListBinding.getFilters(sFilterType) arrived in 1.96;
  // older releases only expose the private aFilters member, which IS that
  // array. "Application" would answer the app's own binding filters
  // instead, usually none - and the user's column filter was then gone
  // after a view rebuild on every release with getFilters while 1.71 kept
  // it (cc/UITableExt, the one caller). Undefined without a binding.
  function controlFilters(binding) {
    if (!binding) return undefined;
    if (typeof binding.getFilters === "function") {
      return binding.getFilters("Control");
    }
    return binding.aFilters;
  }

  return {
    getElementById,
    getMessaging,
    controlFilters,
    getThemingModule,
    getTheme,
    getLocale,
    hasMessagingModule,
    fragmentLoadsSync,
    fragmentControlModules,
    preloadFragmentModules,
  };
});
