// The place of the root control in the shell view (App.view.xml). An
// XMLView renders what its XML declared, not what is added to its content
// later, and the root's class is only known at run time: a sap.m.App on a
// page of the app's own, a sap.m.NavContainer for an embedded component
// (App.controller.js, createRoot). The slot is declared in the XML and
// renders the one control it is given, filling the view: the root's 100%
// height needs a parent with a height.
sap.ui.define(["sap/ui/core/Control", "z2ui5/core/Env"], (Control, Env) => {
  "use strict";
  const RootSlot = Control.extend("z2ui5.core.RootSlot", {
    metadata: {
      aggregations: {
        root: { type: "sap.ui.core.Control", multiple: false },
      },
      defaultAggregation: "root",
    },
    renderer: {
      apiVersion: 2,
      render(rm, oSlot) {
        rm.openStart("div", oSlot);
        rm.style("width", "100%");
        rm.style("height", "100%");
        rm.openEnd();
        const oRoot = oSlot.getAggregation("root");
        if (oRoot) rm.renderControl(oRoot);
        rm.close("div");
      },
    },
  });
  return Env.ownClass(RootSlot);
});
