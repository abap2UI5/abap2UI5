sap.ui.define(["sap/ui/core/mvc/Controller"], (Controller) => {
  "use strict";

  const NEEDS =
    "abap2UI5 could not start: this app needs @abap2ui5/embed-control " +
    "newer than 0.1.1 and abap2UI5 newer than 1.146.0 - both know the " +
    "second name of the frontend, z2ui5.embed.frontend, which this app " +
    "needs because it is the component z2ui5 itself";

  // The control shows nothing when the app cannot start - the endpoint
  // refused, the frontend not loaded (no abap2UI5 on the system, or one
  // older than 1.146.0), the component failed. Say so instead of a blank
  // page.
  return Controller.extend("abap2ui5.frontend.controller.Main", {
    // This page is the control and nothing else, so the URL hash is the
    // app's: hash routing, set_push_state / hash_replace, browser Back and
    // Forward between routed apps (the control's ownsHash). Set here, before
    // the first rendering starts the app.
    //
    // A control without the property is 0.1.1, which knows no second name
    // either: it would create the frontend as z2ui5 - this component again
    // (Component.js stops that). Nothing starts then, and the page says
    // what is missing. Goes into the view as ownsHash="true" once the
    // control's release that has it is in package-lock.json.
    onInit() {
      const container = this.byId("app");
      if (typeof container.setOwnsHash !== "function") {
        this._model().setProperty("/app", "");
        this._model().setProperty("/error", NEEDS);
        return;
      }
      container.setOwnsHash(true);
    },

    onComponentCreated() {
      if (this._model().getProperty("/error") !== NEEDS) {
        this._model().setProperty("/error", "");
      }
    },

    onComponentFailed(event) {
      const reason = event.getParameter("reason");
      this._model().setProperty(
        "/error",
        `abap2UI5 could not start: ${(reason && reason.message) || reason}`,
      );
    },

    _model() {
      return this.getOwnerComponent().getModel("start");
    },
  });
});
