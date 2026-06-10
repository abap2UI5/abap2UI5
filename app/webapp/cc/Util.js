sap.ui.define([], () => {
  "use strict";

  // Cap the error log so a long-running session cannot grow it unbounded.
  const MAX_ERRORS = 100;

  // Append an entry to the global error log. We create the array on first
  // use and drop the oldest entry once the cap is reached.
  function logError(message, error) {
    if (!z2ui5.errors) z2ui5.errors = [];
    const entry = { message: message, ts: new Date().toISOString() };
    if (error !== undefined) entry.error = error;
    z2ui5.errors.push(entry);
    if (z2ui5.errors.length > MAX_ERRORS) z2ui5.errors.shift();
  }

  // True when the object supports isDestroyed() and reports destroyed.
  function isDestroyed(obj) {
    return !!(obj && obj.isDestroyed && obj.isDestroyed());
  }

  // True when the object exists and is not destroyed. Used to guard
  // async continuations (await, FileReader, getUserMedia, ...) against
  // controls or views that were torn down in the meantime.
  function isAlive(obj) {
    return !!obj && !isDestroyed(obj);
  }

  // Helpers for managing z2ui5 callback arrays (onBeforeRoundtrip,
  // onAfterRendering, ...). Several custom controls register hooks here in
  // init() and remove them in exit().
  function registerCallback(name, fn) {
    if (!z2ui5[name]) z2ui5[name] = [];
    z2ui5[name].push(fn);
  }

  function unregisterCallback(name, fn) {
    if (!z2ui5[name]) return;
    z2ui5[name] = z2ui5[name].filter((f) => f !== fn);
  }

  // Read a File object as a data URL and hand the result to onLoaded.
  // The callback is skipped when `owner` was destroyed while the
  // FileReader was busy; read errors are logged under `errorContext`.
  function readFileAsDataURL(file, owner, onLoaded, errorContext) {
    const reader = new FileReader();
    reader.onload = () => {
      if (isDestroyed(owner)) return;
      onLoaded(reader.result);
    };
    reader.onerror = () =>
      logError(`${errorContext}: FileReader failed`, reader.error);
    reader.readAsDataURL(file);
  }

  // Shared tokenUpdate handling for the multi-input extensions: map the
  // added/removed UI5 tokens to plain objects and store them in the
  // control's addedTokens/removedTokens properties.
  function applyTokenUpdate(control, oEvent) {
    const mParameters = oEvent.mParameters;
    const isRemoved = mParameters.type === "removed";
    const rawList =
      mParameters[isRemoved ? "removedTokens" : "addedTokens"] || [];
    const tokens = rawList.map((item) => ({
      KEY: item.getKey(),
      TEXT: item.getText(),
    }));
    control.setProperty("addedTokens", isRemoved ? [] : tokens);
    control.setProperty("removedTokens", isRemoved ? tokens : []);
  }

  return {
    logError,
    isDestroyed,
    isAlive,
    registerCallback,
    unregisterCallback,
    readFileAsDataURL,
    applyTokenUpdate,
  };
});
