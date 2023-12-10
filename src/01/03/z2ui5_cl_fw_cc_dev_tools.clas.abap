CLASS z2ui5_cl_fw_cc_dev_tools DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CLASS-METHODS get_js
      RETURNING
        VALUE(result) TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS Z2UI5_CL_FW_CC_DEV_TOOLS IMPLEMENTATION.

  METHOD get_js.

    result = `jQuery.sap.declare("z2ui5.DevTools");` && |\n|  &&
             `sap.ui.require([` && |\n|  &&
             `    "sap/ui/core/Control"` && |\n|  &&
             `], (Control) => {` && |\n|  &&
             `    "use strict";` && |\n|  &&
             |\n|  &&
             `    return Control.extend("z2ui5.DevTools", {` && |\n|  &&
             `        metadata: {` && |\n|  &&
             `            properties: {` && |\n|  &&
             `                checkLoggingActive: {` && |\n|  &&
             `                    type: "boolean",` && |\n|  &&
             `                    defaultValue: ""` && |\n|  &&
             `                }` && |\n|  &&
             `            },` && |\n|  &&
             `            events: {` && |\n|  &&
             `                "finished": {` && |\n|  &&
             `                    allowPreventDefault: true,` && |\n|  &&
             `                    parameters: {},` && |\n|  &&
             `                }` && |\n|  &&
             `            }` && |\n|  &&
             `        },` && |\n|  &&
             |\n|  &&
             `        displayLog(){` && |\n|  &&
             |\n|  &&
             `            sap.m.MessageToast.show( 'test');` && |\n|  &&
             `        },` && |\n|  &&
             |\n|  &&
             `        activateLogging(checkActive) {` && |\n|  &&
             `            if (!checkActive){` && |\n|  &&
             `                return;` && |\n|  &&
             `            }` && |\n|  &&
             `            sap.z2ui5.onBeforeRoundtrip.push( () => {` && |\n|  &&
             `                console.log('Request Object:');` && |\n|  &&
             `                console.log(sap.z2ui5.oBody);` && |\n|  &&
             `            });` && |\n|  &&
             |\n|  &&
             `            sap.z2ui5.onAfterRoundtrip.push( () => {` && |\n|  &&
             `       ` && |\n|  &&
             `                console.log('Response Object:', sap.z2ui5.oResponse);` && |\n|  &&
             |\n|  &&
             `                // Destructure for easier access` && |\n|  &&
             `                const { S_VIEW, S_POPUP, S_POPOVER, S_VIEW_NEST, S_VIEW_NEST2 } = sap.z2ui5.oResponse.PARAMS;` && |\n|  &&
             `    ` && |\n|  &&
             `                // Helper function to log XML` && |\n|  &&
             `                const logXML = (label, xml) => {` && |\n|  &&
             `                    if (xml !== '') {` && |\n|  &&
             `                        console.log(``${label}:``, xml);` && |\n|  &&
             `                    }` && |\n|  &&
             `                };` && |\n|  &&
             `    ` && |\n|  &&
             `                // Log different XML responses` && |\n|  &&
             `                logXML('UI5-XML-View', S_VIEW.XML);` && |\n|  &&
             `                logXML('UI5-XML-Popup', S_POPUP.XML);` && |\n|  &&
             `                logXML('UI5-XML-Popover', S_POPOVER.XML);` && |\n|  &&
             `                logXML('UI5-XML-Nest', S_VIEW_NEST.XML);` && |\n|  &&
             `                logXML('UI5-XML-Nest2', S_VIEW_NEST2.XML);` && |\n|  &&
             |\n|  &&
             `            });` && |\n|  &&
             |\n|  &&
             `        },` && |\n|  &&
             |\n|  &&
             `        async init() {` && |\n|  &&
             `        },` && |\n|  &&
             |\n|  &&
             `        exit() {` && |\n|  &&
             `        },` && |\n|  &&
             |\n|  &&
             `        onAfterRendering() {` && |\n|  &&
             `        },` && |\n|  &&
             |\n|  &&
             `        renderer(oRm, oControl) {` && |\n|  &&
             `        }` && |\n|  &&
             `    });` && |\n|  &&
             `  ` && |\n|  &&
             `});`.

  ENDMETHOD.

ENDCLASS.
