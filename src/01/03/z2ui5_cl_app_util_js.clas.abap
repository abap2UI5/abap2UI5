CLASS z2ui5_cl_app_util_js DEFINITION
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


CLASS z2ui5_cl_app_util_js IMPLEMENTATION.

  METHOD get.

    result = `sap.ui.define([], () => {` && |\n| &&
             `  "use strict";` && |\n| &&
             `` && |\n| &&
             `  // Cap the error log so a long-running session cannot grow it unbounded.` && |\n| &&
             `  const MAX_ERRORS = 100;` && |\n| &&
             `` && |\n| &&
             `  // Append an entry to the global error log. We create the array on first` && |\n| &&
             `  // use and drop the oldest entry once the cap is reached.` && |\n| &&
             `  function logError(message, error) {` && |\n| &&
             `    if (!z2ui5.errors) z2ui5.errors = [];` && |\n| &&
             `    const entry = { message: message, ts: new Date().toISOString() };` && |\n| &&
             `    if (error !== undefined) entry.error = error;` && |\n| &&
             `    z2ui5.errors.push(entry);` && |\n| &&
             `    if (z2ui5.errors.length > MAX_ERRORS) z2ui5.errors.shift();` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  // True when the object supports isDestroyed() and reports destroyed.` && |\n| &&
             `  function isDestroyed(obj) {` && |\n| &&
             `    return !!(obj && obj.isDestroyed && obj.isDestroyed());` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  // True when the object exists and is not destroyed. Used to guard` && |\n| &&
             `  // async continuations (await, FileReader, getUserMedia, ...) against` && |\n| &&
             `  // controls or views that were torn down in the meantime.` && |\n| &&
             `  function isAlive(obj) {` && |\n| &&
             `    return !!obj && !isDestroyed(obj);` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  // Helpers for managing z2ui5 callback arrays (onBeforeRoundtrip,` && |\n| &&
             `  // onAfterRendering, ...). Several custom controls register hooks here in` && |\n| &&
             `  // init() and remove them in exit().` && |\n| &&
             `  function registerCallback(name, fn) {` && |\n| &&
             `    if (!z2ui5[name]) z2ui5[name] = [];` && |\n| &&
             `    z2ui5[name].push(fn);` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  function unregisterCallback(name, fn) {` && |\n| &&
             `    if (!z2ui5[name]) return;` && |\n| &&
             `    z2ui5[name] = z2ui5[name].filter((f) => f !== fn);` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  // Read a File object as a data URL and hand the result to onLoaded.` && |\n| &&
             `  // The callback is skipped when ``owner`` was destroyed while the` && |\n| &&
             `  // FileReader was busy; read errors are logged under ``errorContext``.` && |\n| &&
             `  function readFileAsDataURL(file, owner, onLoaded, errorContext) {` && |\n| &&
             `    const reader = new FileReader();` && |\n| &&
             `    reader.onload = () => {` && |\n| &&
             `      if (isDestroyed(owner)) return;` && |\n| &&
             `      onLoaded(reader.result);` && |\n| &&
             `    };` && |\n| &&
             `    reader.onerror = () =>` && |\n| &&
             `      logError(``${errorContext}: FileReader failed``, reader.error);` && |\n| &&
             `    reader.readAsDataURL(file);` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  // Shared tokenUpdate handling for the multi-input extensions: map the` && |\n| &&
             `  // added/removed UI5 tokens to plain objects and store them in the` && |\n| &&
             `  // control's addedTokens/removedTokens properties.` && |\n| &&
             `  function applyTokenUpdate(control, oEvent) {` && |\n| &&
             `    const mParameters = oEvent.mParameters;` && |\n| &&
             `    const isRemoved = mParameters.type === "removed";` && |\n| &&
             `    const rawList =` && |\n| &&
             `      mParameters[isRemoved ? "removedTokens" : "addedTokens"] || [];` && |\n| &&
             `    const tokens = rawList.map((item) => ({` && |\n| &&
             `      KEY: item.getKey(),` && |\n| &&
             `      TEXT: item.getText(),` && |\n| &&
             `    }));` && |\n| &&
             `    control.setProperty("addedTokens", isRemoved ? [] : tokens);` && |\n| &&
             `    control.setProperty("removedTokens", isRemoved ? tokens : []);` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  return {` && |\n| &&
             `    logError,` && |\n| &&
             `    isDestroyed,` && |\n| &&
             `    isAlive,` && |\n| &&
             `    registerCallback,` && |\n| &&
             `    unregisterCallback,` && |\n| &&
             `    readFileAsDataURL,` && |\n| &&
             `    applyTokenUpdate,` && |\n| &&
             `  };` && |\n| &&
             `});` && |\n| &&
             `` && |\n| &&
              ``.

  ENDMETHOD.

ENDCLASS.
