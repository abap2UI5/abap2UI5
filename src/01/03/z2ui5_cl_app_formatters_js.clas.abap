CLASS z2ui5_cl_app_formatters_js DEFINITION
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


CLASS z2ui5_cl_app_formatters_js IMPLEMENTATION.

  METHOD get.

    result = `sap.ui.define(["z2ui5/core/Lib"], (Lib) => {` && |\n| &&
             `  "use strict";` && |\n| &&
             `` && |\n| &&
             `  // ------------------------------------------------------------------` && |\n| &&
             `  // App-supplied client-side formatter functions.` && |\n| &&
             `  //` && |\n| &&
             `  // The backend registers named formatters via` && |\n| &&
             `  // client->register_formatter( name js ) - they travel in the response as` && |\n| &&
             `  // PARAMS.T_FORMATTER ([{NAME, JS}]) and are compiled here BEFORE any view` && |\n| &&
             `  // of the same response is created, so XML binding strings can reference` && |\n| &&
             `  // them like the framework's own z2ui5.Util:` && |\n| &&
             `  //` && |\n| &&
             `  //   state="{ parts: [...], formatter: 'z2ui5.fmt.weightState' }"` && |\n| &&
             `  //` && |\n| &&
             `  // ``fmt`` is published as the z2ui5.fmt global by Component.js. Each JS` && |\n| &&
             `  // source is a single function expression, compiled once per name+source` && |\n| &&
             `  // and cached; re-registering the same source is a no-op, a new source` && |\n| &&
             `  // replaces the entry. Compiling uses the Function constructor, so a CSP` && |\n| &&
             `  // without 'unsafe-eval' rejects it - the entry is skipped with a logged` && |\n| &&
             `  // error and the binding falls back to its unformatted value.` && |\n| &&
             `  // ------------------------------------------------------------------` && |\n| &&
             `` && |\n| &&
             `  const fmt = {};` && |\n| &&
             `  const sources = {};` && |\n| &&
             `` && |\n| &&
             `  function register(name, js) {` && |\n| &&
             `    if (!name || !js || sources[name] === js) return;` && |\n| &&
             `    try {` && |\n| &&
             `      // eslint-disable-next-line no-new-func` && |\n| &&
             `      const fn = Function(``"use strict"; return (${js});``)();` && |\n| &&
             `      if (typeof fn !== "function") {` && |\n| &&
             `        throw new TypeError("source is not a function expression");` && |\n| &&
             `      }` && |\n| &&
             `      fmt[name] = fn;` && |\n| &&
             `      sources[name] = js;` && |\n| &&
             `    } catch (e) {` && |\n| &&
             `      Lib.logError(``registerFormatter: '${name}' rejected``, e);` && |\n| &&
             `    }` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  // items: the raw PARAMS.T_FORMATTER array of a response (or undefined).` && |\n| &&
             `  function registerAll(items) {` && |\n| &&
             `    for (const item of items || []) register(item.NAME, item.JS);` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  return { fmt, register, registerAll };` && |\n| &&
             `});` && |\n| &&
             `` && |\n| &&
              ``.

  ENDMETHOD.

ENDCLASS.
