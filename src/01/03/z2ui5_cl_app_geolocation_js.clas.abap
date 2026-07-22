CLASS z2ui5_cl_app_geolocation_js DEFINITION
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


CLASS z2ui5_cl_app_geolocation_js IMPLEMENTATION.

  METHOD get.

    result = `// Invisible control that reads the device position once after rendering` && |\n| &&
             `// into its bindable properties (longitude, latitude, ...) and fires` && |\n| &&
             `// ``finished`` so the backend can pick the values up.` && |\n| &&
             `sap.ui.define(["sap/ui/core/Control", "z2ui5/core/Lib"], (Control, Lib) => {` && |\n| &&
             `  "use strict";` && |\n| &&
             `` && |\n| &&
             `  const _GEO_PROPS = [` && |\n| &&
             `    "longitude",` && |\n| &&
             `    "latitude",` && |\n| &&
             `    "altitude",` && |\n| &&
             `    "accuracy",` && |\n| &&
             `    "altitudeAccuracy",` && |\n| &&
             `    "speed",` && |\n| &&
             `    "heading",` && |\n| &&
             `  ];` && |\n| &&
             `` && |\n| &&
             `  // Default getCurrentPosition timeout (ms). Shared by the ``timeout`` property` && |\n| &&
             `  // default and the runtime fallback so the two cannot drift apart.` && |\n| &&
             `  const _DEFAULT_TIMEOUT_MS = 5000;` && |\n| &&
             `` && |\n| &&
             `  return Control.extend("z2ui5.cc.Geolocation", {` && |\n| &&
             `    metadata: {` && |\n| &&
             `      properties: {` && |\n| &&
             `        longitude: {` && |\n| &&
             `          type: "string",` && |\n| &&
             `          defaultValue: "",` && |\n| &&
             `        },` && |\n| &&
             `        latitude: {` && |\n| &&
             `          type: "string",` && |\n| &&
             `          defaultValue: "",` && |\n| &&
             `        },` && |\n| &&
             `        altitude: {` && |\n| &&
             `          type: "string",` && |\n| &&
             `          defaultValue: "",` && |\n| &&
             `        },` && |\n| &&
             `        accuracy: {` && |\n| &&
             `          type: "string",` && |\n| &&
             `          defaultValue: "",` && |\n| &&
             `        },` && |\n| &&
             `        altitudeAccuracy: {` && |\n| &&
             `          type: "string",` && |\n| &&
             `          defaultValue: "",` && |\n| &&
             `        },` && |\n| &&
             `        speed: {` && |\n| &&
             `          type: "string",` && |\n| &&
             `          defaultValue: "",` && |\n| &&
             `        },` && |\n| &&
             `        heading: {` && |\n| &&
             `          type: "string",` && |\n| &&
             `          defaultValue: "",` && |\n| &&
             `        },` && |\n| &&
             `        enableHighAccuracy: {` && |\n| &&
             `          type: "boolean",` && |\n| &&
             `          defaultValue: false,` && |\n| &&
             `        },` && |\n| &&
             `        timeout: {` && |\n| &&
             `          type: "string",` && |\n| &&
             `          defaultValue: String(_DEFAULT_TIMEOUT_MS),` && |\n| &&
             `        },` && |\n| &&
             `      },` && |\n| &&
             `      events: {` && |\n| &&
             `        finished: {` && |\n| &&
             `          allowPreventDefault: true,` && |\n| &&
             `          parameters: {},` && |\n| &&
             `        },` && |\n| &&
             `        // Fired when the position could not be read, so a backend can` && |\n| &&
             `        // react. The control never surfaces any UI itself - handling is` && |\n| &&
             `        // delegated entirely to whoever binds this event.` && |\n| &&
             `        error: {` && |\n| &&
             `          parameters: {` && |\n| &&
             `            code: { type: "string" },` && |\n| &&
             `            message: { type: "string" },` && |\n| &&
             `          },` && |\n| &&
             `        },` && |\n| &&
             `      },` && |\n| &&
             `    },` && |\n| &&
             `` && |\n| &&
             `    callbackPosition({ coords }) {` && |\n| &&
             `      // The control could be torn down while the geolocation API was busy.` && |\n| &&
             `      if (Lib.isDestroyed(this)) return;` && |\n| &&
             `      for (const prop of _GEO_PROPS) {` && |\n| &&
             `        this.setProperty(prop, Lib.toText(coords[prop]), true);` && |\n| &&
             `      }` && |\n| &&
             `      this.fireFinished();` && |\n| &&
             `    },` && |\n| &&
             `` && |\n| &&
             `    // Reading the position failed (1 = permission denied, 2 = position` && |\n| &&
             `    // unavailable, 3 = timeout). Log it and fire the ``error`` event so a` && |\n| &&
             `    // backend can handle it; the control never surfaces UI on its own.` && |\n| &&
             `    callbackError(error) {` && |\n| &&
             `      if (Lib.isDestroyed(this)) return;` && |\n| &&
             `      Lib.logError(``Geolocation error (${error.code}): ${error.message}``);` && |\n| &&
             `      this.fireError({` && |\n| &&
             `        code: String(error.code),` && |\n| &&
             `        message: error.message,` && |\n| &&
             `      });` && |\n| &&
             `    },` && |\n| &&
             `` && |\n| &&
             `    init() {` && |\n| &&
             `      this._pendingGeolocate = true;` && |\n| &&
             `    },` && |\n| &&
             `` && |\n| &&
             `    exit() {` && |\n| &&
             `      this._pendingGeolocate = false;` && |\n| &&
             `    },` && |\n| &&
             `` && |\n| &&
             `    onAfterRendering() {` && |\n| &&
             `      if (!this._pendingGeolocate) return;` && |\n| &&
             `      this._pendingGeolocate = false;` && |\n| &&
             `      try {` && |\n| &&
             `        if (!navigator.geolocation) return;` && |\n| &&
             `        navigator.geolocation.getCurrentPosition(` && |\n| &&
             `          this.callbackPosition.bind(this),` && |\n| &&
             `          this.callbackError.bind(this),` && |\n| &&
             `          {` && |\n| &&
             `            enableHighAccuracy: this.getProperty("enableHighAccuracy"),` && |\n| &&
             `            // Guard against an empty or non-numeric property - NaN or 0` && |\n| &&
             `            // would make getCurrentPosition fail immediately.` && |\n| &&
             `            timeout: Number(this.getProperty("timeout")) || _DEFAULT_TIMEOUT_MS,` && |\n| &&
             `          },` && |\n| &&
             `        );` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        Lib.logError(` && |\n| &&
             `          "Geolocation.onAfterRendering: getCurrentPosition failed",` && |\n| &&
             `          e,` && |\n| &&
             `        );` && |\n| &&
             `      }` && |\n| &&
             `    },` && |\n| &&
             `` && |\n| &&
             `    renderer: {` && |\n| &&
             `      apiVersion: 2,` && |\n| &&
             `      render(oRm, oControl) {` && |\n| &&
             `        Lib.renderInvisibleSpan(oRm, oControl);` && |\n| &&
             `      },` && |\n| &&
             `    },` && |\n| &&
             `  });` && |\n| &&
             `});` && |\n| &&
             `` && |\n| &&
              ``.

  ENDMETHOD.

ENDCLASS.
