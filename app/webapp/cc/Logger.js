sap.ui.define([], () => {
  "use strict";

  // Append an entry to the global error log. We create the array on first use.
  // `error` is only added when defined, so the log never contains a stray
  // `error: undefined` field.
  function logError(message, error) {
    if (typeof z2ui5 === "undefined") return;
    if (!z2ui5.errors) z2ui5.errors = [];
    const entry = { message: message, ts: new Date().toISOString() };
    if (error !== undefined) entry.error = error;
    z2ui5.errors.push(entry);
  }

  return { logError: logError };
});
