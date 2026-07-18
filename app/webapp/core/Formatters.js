sap.ui.define(["z2ui5/core/Lib"], (Lib) => {
  "use strict";

  // ------------------------------------------------------------------
  // App-supplied client-side formatter functions.
  //
  // The backend registers named formatters via
  // client->register_formatter( name js ) - they travel in the response as
  // PARAMS.T_FORMATTER ([{NAME, JS}]) and are compiled here BEFORE any view
  // of the same response is created, so XML binding strings can reference
  // them like the framework's own z2ui5.Util:
  //
  //   state="{ parts: [...], formatter: 'z2ui5.fmt.weightState' }"
  //
  // `fmt` is published as the z2ui5.fmt global by Component.js. Each JS
  // source is a single function expression, compiled once per name+source
  // and cached; re-registering the same source is a no-op, a new source
  // replaces the entry. Compiling uses the Function constructor, so a CSP
  // without 'unsafe-eval' rejects it - the entry is skipped with a logged
  // error and the binding falls back to its unformatted value.
  // ------------------------------------------------------------------

  const fmt = {};
  const sources = {};

  function register(name, js) {
    if (!name || !js || sources[name] === js) return;
    try {
      // eslint-disable-next-line no-new-func
      const fn = Function(`"use strict"; return (${js});`)();
      if (typeof fn !== "function") {
        throw new TypeError("source is not a function expression");
      }
      fmt[name] = fn;
      sources[name] = js;
    } catch (e) {
      Lib.logError(`registerFormatter: '${name}' rejected`, e);
    }
  }

  // items: the raw PARAMS.T_FORMATTER array of a response (or undefined).
  function registerAll(items) {
    for (const item of items || []) register(item.NAME, item.JS);
  }

  return { fmt, register, registerAll };
});
