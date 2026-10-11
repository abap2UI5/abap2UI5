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
sap.ui.define(
  ["sap/ui/core/Element", "sap/ui/VersionInfo", "z2ui5/core/Lib"],
  (Element, VersionInfo, Lib) => {
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

    // ------------------------------------------------------------------
    // The libraries a view uses, loaded as PRELOAD BUNDLES before the view
    // is built. manifest.json declares sap.m and sap.ui.core, and those two
    // arrive as one library-preload.js each; every other library a backend
    // view names - sap.ui.table, sap.uxap, sap.f, sap.ui.layout,
    // sap.ui.unified, sap.suite.ui.commons, sap.ui.codeeditor, ... - is
    // resolved by UI5's XMLTemplateProcessor control by control, module by
    // module, and never as its bundle: a view with one sap.ui.table.Table
    // was 37 requests and 308 ms at 40 ms round-trip time, 8 requests and
    // 158 ms once the library had been loaded first. So actions/Slots asks
    // loadViewLibraries( xml ) before every XMLView.create and Fragment.load:
    // the xmlns declarations name the namespaces, and each one is mapped to
    // ITS LIBRARY - the longest library name of the distribution that is a
    // prefix of it (sap.ui.layout.form is a namespace of sap.ui.layout, not
    // a library of its own; sap-ui-version.json lists the libraries, and
    // sap/ui/VersionInfo already fetched it for Component._initVersionInfo,
    // so no request is spent on the list). A namespace under a library that
    // is loaded already, or that is in no library of the distribution (a
    // custom control namespace, a BSP of the customer's), is left to the
    // view's own module loading, as before.
    //
    // sap/ui/core/Lib.load( ) (since 1.118) loads a library asynchronously
    // with its preload; sap.ui.getCore( ).loadLibraries( ) does the same on
    // 1.71, where the module does not exist - the one-id sap.ui.require
    // probe of rule 12. Asynchronous throughout: a script tag per bundle,
    // never eval (rule 13). Never throws, and a library that fails to load
    // only means the view loads the way it always did and reports its own
    // error.
    //
    // What was tried is remembered for the PAGE, not per component: the
    // ui5loader is one per page, a library loaded for one component is
    // loaded for the next, and a page with two z2ui5 components would
    // otherwise ask twice. A roundtrip that re-displays a view therefore
    // costs one Set lookup per namespace and nothing else.
    // ------------------------------------------------------------------

    // A dotted name with at least two segments, nothing a URL would read as
    // a path - what may become <name>/library-preload.js
    const LIBRARY_NAME = /^[A-Za-z_]\w*(?:\.\w+)+$/;

    // the library of every namespace asked so far (null: none of the
    // distribution's), and the load of every library tried so far
    const namespaceLibrary = new Map();
    const libraryLoads = new Map();
    // the names of the distribution's libraries, once asked - null when the
    // version info is not to be had (a bootstrap without sap-ui-version.json)
    let distributionLibraries = null;

    // The namespaces a view declares: every xmlns value that is a dotted
    // name. The frontend's own custom controls (xmlns:z2ui5="z2ui5.cc") are
    // in no library and are left out up front.
    function viewNamespaces(xml) {
      const result = new Set();
      for (const [, , namespace] of String(xml ?? "").matchAll(XMLNS)) {
        if (LIBRARY_NAME.test(namespace) && !namespace.startsWith("z2ui5")) {
          result.add(namespace);
        }
      }
      return [...result];
    }

    /** @returns {Promise<string[] | null>} */
    function loadDistributionLibraries() {
      if (!distributionLibraries) {
        distributionLibraries = Promise.resolve()
          .then(() => VersionInfo?.load?.())
          .then((info) =>
            Array.isArray(info?.libraries)
              ? info.libraries.map((lib) => lib?.name).filter(Boolean)
              : null,
          )
          .catch(() => null);
      }
      return distributionLibraries;
    }

    // The names of the libraries loaded so far: Lib.all( ) from 1.118 on,
    // the core's getLoadedLibraries( ) before.
    function loadedLibraryNames() {
      try {
        const Library = sap.ui.require("sap/ui/core/Lib");
        if (Library?.all) return new Set(Object.keys(Library.all()));
        /* ui5lint-disable no-globals, no-deprecated-api --
         deliberate fallback for UI5 releases without sap/ui/core/Lib
         (added in 1.118); the modern API is used in the branch above. */
        if (sap.ui.getCore) {
          const loaded = sap.ui.getCore().getLoadedLibraries?.();
          if (loaded) return new Set(Object.keys(loaded));
        }
        /* ui5lint-enable no-globals, no-deprecated-api */
      } catch (e) {
        Lib.logError("Env: reading the loaded libraries failed", e);
      }
      return new Set();
    }

    // whether `name` is `library` or lies under it
    function isUnder(name, library) {
      return name === library || name.startsWith(`${library}.`);
    }

    // The library of a namespace: the longest of `libraries` the namespace
    // lies under, null for none. Without a list (no version info) the
    // namespace is taken for a library itself and tried as one.
    function libraryOf(namespace, libraries) {
      if (!libraries) return namespace;
      let best = null;
      for (const library of libraries) {
        if (
          isUnder(namespace, library) &&
          (!best || library.length > best.length)
        ) {
          best = library;
        }
      }
      return best;
    }

    // Load one library with its preload bundle, once per page. Resolves
    // with whether it loaded; never rejects.
    /** @returns {Promise<boolean>} */
    function loadLibrary(name) {
      let load = libraryLoads.get(name);
      if (load) return load;
      load = new Promise((resolve) => {
        try {
          const Library = sap.ui.require("sap/ui/core/Lib");
          if (Library?.load) {
            Library.load({ name }).then(
              () => resolve(true),
              () => resolve(false),
            );
            return;
          }
          /* ui5lint-disable no-globals, no-deprecated-api --
           deliberate fallback for UI5 releases without sap/ui/core/Lib
           (added in 1.118); the modern API is used in the branch above. */
          const core = sap.ui.getCore?.();
          if (core?.loadLibraries) {
            core.loadLibraries([name], { async: true }).then(
              () => resolve(true),
              () => resolve(false),
            );
            return;
          }
          /* ui5lint-enable no-globals, no-deprecated-api */
        } catch (e) {
          Lib.logError(`Env: loading the library ${name} failed`, e);
        }
        resolve(false);
      });
      libraryLoads.set(name, load);
      return load;
    }

    // Load, as preload bundles and in parallel, the libraries a view's XML
    // names that are not loaded yet - see the block comment above. The
    // names given explicitly (`names`, for a caller that knows them) are
    // taken as libraries. Resolves once every load settled; never rejects.
    /** @returns {Promise<void>} */
    async function loadLibraries(names) {
      const wanted = (names || []).filter(
        (name) => LIBRARY_NAME.test(name) && !libraryLoads.get(name),
      );
      if (!wanted.length) return;
      const loaded = loadedLibraryNames();
      await Promise.all(
        wanted
          .filter((name) => ![...loaded].some((lib) => isUnder(name, lib)))
          .map(loadLibrary),
      );
    }

    /** @returns {Promise<void>} */
    async function loadViewLibraries(xml) {
      const namespaces = viewNamespaces(xml).filter(
        (namespace) => !namespaceLibrary.has(namespace),
      );
      if (!namespaces.length) return;
      const libraries = await loadDistributionLibraries();
      const loaded = loadedLibraryNames();
      const names = new Set();
      for (const namespace of namespaces) {
        const library = libraryOf(namespace, libraries);
        namespaceLibrary.set(namespace, library);
        if (!library) continue;
        if ([...loaded].some((lib) => isUnder(library, lib))) continue;
        names.add(library);
      }
      await Promise.all([...names].map(loadLibrary));
    }

    // ------------------------------------------------------------------
    // The global export of the frontend's own classes. UI5 1.x exports every
    // class it creates as a global as well - sap/ui/base/Metadata.createClass
    // writes it to window under its dotted name, and ElementMetadata a
    // control's renderer next to it - so the frontend's classes built a
    // window.z2ui5 on every page it ran on: z2ui5.Component,
    // z2ui5.controller.App and View1, z2ui5.devtools.DeveloperTools, a
    // z2ui5.cc.* per custom control an app used. The global the frontend
    // itself wrote was removed on purpose (#2777); nothing reads these
    // either - every module returns its class, and XML views, controllers
    // and Component.create take it from there. UI5 2.x exports nothing.
    //
    // They are taken off again on a page an EMBEDDED component runs on: that
    // page, and its window, belong to a host. Not on a page of the app's
    // own: there 1.71 still looks a BASE class up by that global name when
    // something extends one of ours (Metadata.applySettings,
    // ObjectPath.get( baseType )) - a launchpad extension project extending
    // z2ui5.Component, a customer control extending a cc/ one - and the
    // extend would fail without it.
    //
    // Every module that defines a class hands it to ownClass right after its
    // extend( ); Component.init of an embedded component calls
    // dropClassGlobals. The classes are defined once per page, whichever
    // component comes first, so both orders end without a global.
    // ------------------------------------------------------------------

    const ownClasses = [];
    let hostPage = false;

    // The namespace objects a host page had under window.z2ui5 before the
    // frontend defined anything - Env loads before every class module, which
    // all depend on it. Emptied of our classes, they stay: they are the
    // host's.
    const hostNamespaces = new WeakSet();
    function collectHostNamespaces(object, depth) {
      if (!object || typeof object !== "object" || depth > 3) return;
      hostNamespaces.add(object);
      for (const key of Object.keys(object)) {
        collectHostNamespaces(object[key], depth + 1);
      }
    }
    /* ui5lint-disable no-project-globals --
     read, never written: what the HOST had under the name before the
     frontend defined anything, so dropClassGlobals leaves it standing. */
    collectHostNamespaces(/** @type {any} */ (window).z2ui5, 0);
    /* ui5lint-enable no-project-globals */

    // Delete window.<name> when it holds `value` - never a value someone
    // else put under the same name - and every namespace object on the way
    // that is empty then and was not the host's.
    function removeGlobal(name, value) {
      if (!name || value === undefined) return;
      const keys = String(name).split(".");
      const leaf = keys.pop();
      const chain = [window];
      for (const key of keys) {
        const next = chain[chain.length - 1][key];
        if (!next || typeof next !== "object") return;
        chain.push(next);
      }
      const holder = chain[chain.length - 1];
      if (holder[leaf] !== value) return;
      delete holder[leaf];
      for (let i = keys.length - 1; i >= 0; i--) {
        const namespace = chain[i + 1];
        if (hostNamespaces.has(namespace) || Object.keys(namespace).length) {
          return;
        }
        delete chain[i][keys[i]];
      }
    }

    function removeClassGlobals(Class) {
      try {
        const metadata = Class.getMetadata();
        removeGlobal(metadata.getName(), Class);
        // a control's renderer, exported next to it (a control class only)
        if (typeof metadata.getRendererName === "function") {
          removeGlobal(metadata.getRendererName(), metadata.getRenderer());
        }
      } catch (e) {
        Lib.logError("Env: removing a class's global export failed", e);
      }
    }

    // A class the frontend defined - see above. Returns it.
    function ownClass(Class) {
      ownClasses.push(Class);
      if (hostPage) removeClassGlobals(Class);
      return Class;
    }

    // The page is a host's: the classes defined so far leave their global,
    // and the ones defined from here on do not keep one.
    function dropClassGlobals() {
      hostPage = true;
      for (const Class of ownClasses) removeClassGlobals(Class);
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
      viewNamespaces,
      loadLibraries,
      loadViewLibraries,
      ownClass,
      dropClassGlobals,
    };
  },
);
