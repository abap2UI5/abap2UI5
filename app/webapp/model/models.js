sap.ui.define(
  ["sap/ui/model/json/JSONModel", "sap/ui/Device"],
  (JSONModel, Device) => {
    "use strict";

    // The range set every {device>/media/range} binding reads. "Std" is UI5's
    // own predefined set (Phone < 600px, Tablet < 1024px, Desktop above), the
    // same thresholds the demo kit's media models use.
    const RANGE_SET = "Std";

    return {
      // Creates a read-only JSON model that exposes the current device info
      // (phone / tablet / desktop, orientation, ...) to the views.
      //
      // The model wraps the LIVE sap.ui.Device object, which mutates itself
      // on resize and rotation - but a JSONModel only notifies its bindings
      // when something tells it to, so without the handlers below a
      // {device>/resize/width} binding renders the width at load time and
      // never moves again. The handlers cost nothing at rest (Device fires
      // them only on a real change) and keep every device binding live
      // without a roundtrip, which is the point of having the model at all.
      createDeviceModel() {
        const oModel = new JSONModel(Device);
        oModel.setDefaultBindingMode("OneWay");

        Device.media.initRangeSet(RANGE_SET);

        const refresh = () => {
          // Device.media exposes methods only - there is no property a binding
          // could address - so the current range NAME is published onto the
          // model itself. It is the value a live breakpoint branch wants:
          // class="{= ${device>/media/range} === 'Phone' ? 'a' : 'b' }".
          const oRange = Device.media.getCurrentRange(RANGE_SET);
          oModel.setProperty("/media/range", oRange ? oRange.name : "");
          oModel.refresh(true);
        };

        Device.resize.attachHandler(refresh);
        Device.orientation.attachHandler(refresh);
        Device.media.attachHandler(refresh, null, RANGE_SET);
        refresh(); // seed /media/range before the first render

        return oModel;
      },
    };
  },
);
