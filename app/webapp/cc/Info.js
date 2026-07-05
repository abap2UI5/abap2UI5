sap.ui.define(
  ["sap/ui/core/Control", "z2ui5/core/Lib", "z2ui5/core/ViewSlots"],
  (Control, Lib, ViewSlots) => {
    "use strict";

    // Invisible control that reports the UI5 version/theme and the device
    // info (system type, screen size, OS, browser) back to the backend via
    // its bindable properties, then fires `finished`.
    return Control.extend("z2ui5.cc.Info", {
      metadata: {
        properties: {
          ui5_version: {
            type: "string",
          },
          device_phone: {
            type: "string",
          },
          device_desktop: {
            type: "string",
          },
          device_tablet: {
            type: "string",
          },
          device_combi: {
            type: "string",
          },
          device_height: {
            type: "string",
          },
          device_width: {
            type: "string",
          },
          ui5_theme: {
            type: "string",
          },
          ui5_gav: {
            type: "string",
          },
          device_os: {
            type: "string",
          },
          device_systemtype: {
            type: "string",
          },
          device_browser: {
            type: "string",
          },
        },
        events: {
          finished: {
            allowPreventDefault: true,
            parameters: {},
          },
        },
      },

      // Follows the shared rendering pattern (see core/Lib.js): the renderer
      // only marks the work, onAfterRendering reads the device info and
      // fires the event.
      onAfterRendering() {
        if (!this._pendingInfo) return;
        this._pendingInfo = false;
        try {
          // The device model is created by Component.init(); it exposes
          // system / resize / os / browser info.
          const deviceModel = ViewSlots.getView("MAIN")?.getModel("device");
          const deviceData = deviceModel?.getData();
          if (!deviceData) return;

          const { system, resize, os, browser } = deviceData;
          // Filled by Component._initVersionInfo (async, may not have
          // resolved yet on the very first render).
          const ui5Info = z2ui5.oConfig?.S_UI5;
          const ui5Version = ui5Info?.VERSION || "";

          // Single system-type label, same derivation as Server._getDeviceInfo.
          const systemType = Lib.deriveSystemType(system);

          const props = [
            ["ui5_version", ui5Version],
            ["device_phone", system.phone],
            ["device_desktop", system.desktop],
            ["device_tablet", system.tablet],
            ["device_combi", system.combi],
            ["device_height", resize.height],
            ["device_width", resize.width],
            ["ui5_theme", ui5Info?.THEME || ""],
            ["ui5_gav", ui5Info?.GAV || ""],
            ["device_systemtype", systemType],
            ["device_os", os.name],
            ["device_browser", browser.name],
          ];
          for (const [prop, val] of props) {
            this.setProperty(prop, Lib.toText(val), true);
          }
          this.fireFinished();
        } catch (e) {
          Lib.logError("Info.onAfterRendering: failed", e);
        }
      },

      renderer: {
        apiVersion: 2,
        render(oRm, oControl) {
          oRm.openStart("span", oControl);
          oRm.style("display", "none");
          oRm.openEnd();
          oRm.close("span");
          oControl._pendingInfo = true;
        },
      },
    });
  },
);
