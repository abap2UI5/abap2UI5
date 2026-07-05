CLASS z2ui5_cl_app_info_js DEFINITION
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


CLASS z2ui5_cl_app_info_js IMPLEMENTATION.

  METHOD get.

    result = `sap.ui.define(` && |\n| &&
             `  ["sap/ui/core/Control", "z2ui5/core/Lib", "z2ui5/core/ViewSlots"],` && |\n| &&
             `  (Control, Lib, ViewSlots) => {` && |\n| &&
             `    "use strict";` && |\n| &&
             `` && |\n| &&
             `    // Invisible control that reports the UI5 version/theme and the device` && |\n| &&
             `    // info (system type, screen size, OS, browser) back to the backend via` && |\n| &&
             `    // its bindable properties, then fires ``finished``.` && |\n| &&
             `    return Control.extend("z2ui5.cc.Info", {` && |\n| &&
             `      metadata: {` && |\n| &&
             `        properties: {` && |\n| &&
             `          ui5_version: {` && |\n| &&
             `            type: "string",` && |\n| &&
             `          },` && |\n| &&
             `          device_phone: {` && |\n| &&
             `            type: "string",` && |\n| &&
             `          },` && |\n| &&
             `          device_desktop: {` && |\n| &&
             `            type: "string",` && |\n| &&
             `          },` && |\n| &&
             `          device_tablet: {` && |\n| &&
             `            type: "string",` && |\n| &&
             `          },` && |\n| &&
             `          device_combi: {` && |\n| &&
             `            type: "string",` && |\n| &&
             `          },` && |\n| &&
             `          device_height: {` && |\n| &&
             `            type: "string",` && |\n| &&
             `          },` && |\n| &&
             `          device_width: {` && |\n| &&
             `            type: "string",` && |\n| &&
             `          },` && |\n| &&
             `          ui5_theme: {` && |\n| &&
             `            type: "string",` && |\n| &&
             `          },` && |\n| &&
             `          ui5_gav: {` && |\n| &&
             `            type: "string",` && |\n| &&
             `          },` && |\n| &&
             `          device_os: {` && |\n| &&
             `            type: "string",` && |\n| &&
             `          },` && |\n| &&
             `          device_systemtype: {` && |\n| &&
             `            type: "string",` && |\n| &&
             `          },` && |\n| &&
             `          device_browser: {` && |\n| &&
             `            type: "string",` && |\n| &&
             `          },` && |\n| &&
             `        },` && |\n| &&
             `        events: {` && |\n| &&
             `          finished: {` && |\n| &&
             `            allowPreventDefault: true,` && |\n| &&
             `            parameters: {},` && |\n| &&
             `          },` && |\n| &&
             `        },` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      // Follows the shared rendering pattern (see core/Lib.js): the renderer` && |\n| &&
             `      // only marks the work, onAfterRendering reads the device info and` && |\n| &&
             `      // fires the event.` && |\n| &&
             `      onAfterRendering() {` && |\n| &&
             `        if (!this._pendingInfo) return;` && |\n| &&
             `        this._pendingInfo = false;` && |\n| &&
             `        try {` && |\n| &&
             `          // The device model is created by Component.init(); it exposes` && |\n| &&
             `          // system / resize / os / browser info.` && |\n| &&
             `          const deviceModel = ViewSlots.getView("MAIN")?.getModel("device");` && |\n| &&
             `          const deviceData = deviceModel?.getData();` && |\n| &&
             `          if (!deviceData) return;` && |\n| &&
             `` && |\n| &&
             `          const { system, resize, os, browser } = deviceData;` && |\n| &&
             `          // Filled by Component._initVersionInfo (async, may not have` && |\n| &&
             `          // resolved yet on the very first render).` && |\n| &&
             `          const ui5Info = z2ui5.oConfig?.S_UI5;` && |\n| &&
             `          const ui5Version = ui5Info?.VERSION || "";` && |\n| &&
             `` && |\n| &&
             `          // Single system-type label, same derivation as Server._getDeviceInfo.` && |\n| &&
             `          const systemType = Lib.deriveSystemType(system);` && |\n| &&
             `` && |\n| &&
             `          const props = [` && |\n| &&
             `            ["ui5_version", ui5Version],` && |\n| &&
             `            ["device_phone", system.phone],` && |\n| &&
             `            ["device_desktop", system.desktop],` && |\n| &&
             `            ["device_tablet", system.tablet],` && |\n| &&
             `            ["device_combi", system.combi],` && |\n| &&
             `            ["device_height", resize.height],` && |\n| &&
             `            ["device_width", resize.width],` && |\n| &&
             `            ["ui5_theme", ui5Info?.THEME || ""],` && |\n| &&
             `            ["ui5_gav", ui5Info?.GAV || ""],` && |\n| &&
             `            ["device_systemtype", systemType],` && |\n| &&
             `            ["device_os", os.name],` && |\n| &&
             `            ["device_browser", browser.name],` && |\n| &&
             `          ];` && |\n| &&
             `          for (const [prop, val] of props) {` && |\n| &&
             `            this.setProperty(prop, Lib.toText(val), true);` && |\n| &&
             `          }` && |\n| &&
             `          this.fireFinished();` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          Lib.logError("Info.onAfterRendering: failed", e);` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      renderer: {` && |\n| &&
             `        apiVersion: 2,` && |\n| &&
             `        render(oRm, oControl) {` && |\n| &&
             `          oRm.openStart("span", oControl);` && |\n| &&
             `          oRm.style("display", "none");` && |\n| &&
             `          oRm.openEnd();` && |\n| &&
             `          oRm.close("span");` && |\n| &&
             `          oControl._pendingInfo = true;` && |\n| &&
             `        },` && |\n| &&
             `      },` && |\n| &&
             `    });` && |\n| &&
             `  },` && |\n| &&
             `);` && |\n| &&
             `` && |\n| &&
              ``.

  ENDMETHOD.

ENDCLASS.
