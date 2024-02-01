CLASS z2ui5_cl_cc_camera_picture DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CLASS-METHODS get_js
      RETURNING
        VALUE(r_js) TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS Z2UI5_CL_CC_CAMERA_PICTURE IMPLEMENTATION.


  METHOD get_js.

    r_js  = ` sap.ui.define("z2ui5/CameraPicture" , [` && |\n| &&
            `    "sap/ui/core/Control"` && |\n| &&
            `], function (Control) {` && |\n| &&
            `    "use strict";` && |\n| &&
            `    return Control.extend("z2ui5.CameraPicture", {` && |\n| &&
            `        metadata: {` && |\n| &&
            `            properties: {` && |\n| &&
            `                id: { type: "string" },` && |\n| &&
            `                value: { type: "string" },` && |\n| &&
            `                press: { type: "string" },` && |\n| &&
            `                autoplay: { type: "boolean", defaultValue: true }` && |\n| &&
            `            },` && |\n| &&
            `            events: {` && |\n| &&
            `                "OnPhoto": {` && |\n| &&
            `                    allowPreventDefault: true,` && |\n| &&
            `                    parameters: {` && |\n| &&
            `                        "photo": {` && |\n| &&
            `                            type: "string"` && |\n| &&
            `                        }` && |\n| &&
            `                    }` && |\n| &&
            `                }` && |\n| &&
            `            },` && |\n| &&
            `        },` && |\n| &&
            |\n| &&
            `        capture: function (oEvent) {` && |\n| &&
            |\n| &&
            `            var video = document.querySelector("#zvideo");` && |\n| &&
            `            var canvas = document.getElementById('zcanvas');` && |\n| &&
            `            var resultb64 = "";` && |\n| &&
            `            canvas.width = 200;` && |\n| &&
            `            canvas.height = 200;` && |\n| &&
            `            canvas.getContext('2d').drawImage(video, 0, 0, 200, 200);` && |\n| &&
            `            resultb64 = canvas.toDataURL();` && |\n| &&
            `            this.setProperty("value", resultb64);` && |\n| &&
            `            this.fireOnPhoto({` && |\n| &&
            `                "photo": resultb64` && |\n| &&
            `            });` && |\n| &&
            `        },` && |\n| &&
            |\n| &&
            `        onPicture: function (oEvent) {` && |\n| &&
            |\n| &&
            `            if (!this._oScanDialog) {` && |\n| &&
            `                this._oScanDialog = new sap.m.Dialog({` && |\n| &&
            `                    title: "Device Photo Function",` && |\n| &&
            `                    contentWidth: "640px",` && |\n| &&
            `                    contentHeight: "480px",` && |\n| &&
            `                    horizontalScrolling: false,` && |\n| &&
            `                    verticalScrolling: false,` && |\n| &&
            `                    stretchOnPhone: true,` && |\n| &&
            `                    content: [` && |\n| &&
            `                        new sap.ui.core.HTML({` && |\n| &&
            `                            id: this.getId() + 'PictureContainer',` && |\n| &&
            `                            content: '&lt;video width="600px" height="400px" autoplay="true" id="zvideo"&gt;'` && |\n| &&
            `                        }),` && |\n| &&
            `                        new sap.m.Button({` && |\n| &&
            `                            text: "Capture",` && |\n| &&
            `                            press: function (oEvent) {` && |\n| &&
            `                                this.capture();` && |\n| &&
            `                                this._oScanDialog.close();` && |\n| &&
            `                            }.bind(this)` && |\n| &&
            `                        }),` && |\n| &&
            `                        new sap.ui.core.HTML({` && |\n| &&
            `                            content: '&lt;canvas hidden id="zcanvas" style="overflow:auto"&gt;&lt;/canvas&gt;'` && |\n| &&
            `                        }),` && |\n| &&
            `                    ],` && |\n| &&
            `                    endButton: new sap.m.Button({` && |\n| &&
            `                        text: "Cancel",` && |\n| &&
            `                        press: function (oEvent) {` && |\n| &&
            `                            this._oScanDialog.close();` && |\n| &&
            `                        }.bind(this)` && |\n| &&
            `                    }),` && |\n| &&
            `                });` && |\n| &&
            `            }` && |\n| &&
            |\n| &&
            `            this._oScanDialog.open();` && |\n| &&
            |\n| &&
            `            setTimeout(function () {` && |\n| &&
            `                var video = document.querySelector('#zvideo');` && |\n| &&
            `                if (navigator.mediaDevices.getUserMedia) {` && |\n| &&
            `                   navigator.mediaDevices.getUserMedia({video: { facingMode: { exact: "environment" } } })` && |\n| &&
            `                        .then(function (stream) {` && |\n| &&
            `                            video.srcObject = stream;` && |\n| &&
            `                        })` && |\n| &&
            `                        .catch(function (error) {` && |\n| &&
            `                            console.log("Something went wrong!");` && |\n| &&
            `                        });` && |\n| &&
            `                }` && |\n| &&
            `            }.bind(this), 300);` && |\n| &&
            |\n| &&
            `        },` && |\n| &&
            |\n| &&
            `        renderer: function (oRM, oControl) {` && |\n| &&
            |\n| &&
            `            var oButton = new sap.m.Button({` && |\n| &&
            `                icon: "sap-icon://camera",` && |\n| &&
            `                text: "Camera",` && |\n| &&
            `                press: oControl.onPicture.bind(oControl),` && |\n| &&
            `            });` && |\n| &&
            `            oRM.renderControl(oButton);` && |\n| &&
            |\n| &&
            `        },` && |\n| &&
            `    });` && |\n| &&
            `});`.

  ENDMETHOD.
ENDCLASS.
