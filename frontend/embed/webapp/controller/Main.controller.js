sap.ui.define(["sap/ui/core/mvc/Controller"], (Controller) => {
  "use strict";

  // The control shows nothing when the app cannot start - the endpoint
  // refused, the frontend not loaded (no abap2UI5 on the system, or one
  // older than 1.147.0, which does not know the second name of the
  // frontend, z2ui5.embed.frontend, that this app needs because it is the
  // component z2ui5 itself), the component failed. Say so instead of a
  // blank page.
  //
  // This page is the control and nothing else, so the page is the app's:
  // the URL hash (hash routing, set_push_state / hash_replace, browser
  // Back and Forward between routed apps), the title, the favicon, the
  // busy indicator and the "leave page?" prompt - the control's ownsPage,
  // set in the view (@abap2ui5/embed-control 0.3.0 and later have it;
  // the pin in package.json holds the control to that).
  return Controller.extend("abap2ui5.frontend.controller.Main", {
    onComponentCreated() {
      this._model().setProperty("/error", "");
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
