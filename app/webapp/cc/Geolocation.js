// Invisible control that reads the device position once after rendering
// into its bindable properties (longitude, latitude, ...) and fires
// `finished` so the backend can pick the values up.
sap.ui.define(["sap/ui/core/Control", "z2ui5/core/Lib"], (Control, Lib) => {
  "use strict";

  const _GEO_PROPS = [
    "longitude",
    "latitude",
    "altitude",
    "accuracy",
    "altitudeAccuracy",
    "speed",
    "heading",
  ];

  return Control.extend("z2ui5.cc.Geolocation", {
    metadata: {
      properties: {
        longitude: {
          type: "string",
          defaultValue: "",
        },
        latitude: {
          type: "string",
          defaultValue: "",
        },
        altitude: {
          type: "string",
          defaultValue: "",
        },
        accuracy: {
          type: "string",
          defaultValue: "",
        },
        altitudeAccuracy: {
          type: "string",
          defaultValue: "",
        },
        speed: {
          type: "string",
          defaultValue: "",
        },
        heading: {
          type: "string",
          defaultValue: "",
        },
        enableHighAccuracy: {
          type: "boolean",
          defaultValue: false,
        },
        timeout: {
          type: "string",
          defaultValue: "5000",
        },
      },
      events: {
        finished: {
          allowPreventDefault: true,
          parameters: {},
        },
      },
    },

    callbackPosition({ coords }) {
      // The control could be torn down while the geolocation API was busy.
      if (Lib.isDestroyed(this)) return;
      for (const prop of _GEO_PROPS) {
        this.setProperty(prop, Lib.toText(coords[prop]), true);
      }
      this.fireFinished();
    },

    init() {
      this._pendingGeolocate = true;
    },

    exit() {
      this._pendingGeolocate = false;
    },

    onAfterRendering() {
      if (!this._pendingGeolocate) return;
      this._pendingGeolocate = false;
      try {
        if (!navigator.geolocation) return;
        navigator.geolocation.getCurrentPosition(
          this.callbackPosition.bind(this),
          (error) =>
            Lib.logError(`Geolocation error (${error.code}): ${error.message}`),
          {
            enableHighAccuracy: this.getProperty("enableHighAccuracy"),
            // Guard against an empty or non-numeric property - NaN or 0
            // would make getCurrentPosition fail immediately.
            timeout: Number(this.getProperty("timeout")) || 5000,
          },
        );
      } catch (e) {
        Lib.logError(
          "Geolocation.onAfterRendering: getCurrentPosition failed",
          e,
        );
      }
    },

    renderer: {
      apiVersion: 2,
      render(oRm, oControl) {
        oRm.openStart("span", oControl);
        oRm.style("display", "none");
        oRm.openEnd();
        oRm.close("span");
      },
    },
  });
});
