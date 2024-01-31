CLASS z2ui5_cl_cc_spreadsheet DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CLASS-METHODS get_js
      IMPORTING
      !i_columnconfig TYPE clike
      RETURNING
      VALUE(r_js) TYPE string .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS Z2UI5_CL_CC_SPREADSHEET IMPLEMENTATION.


  METHOD get_js.

    r_js  = `        sap.ui.define("z2ui5/ExportSpreadsheet" , [` && |\n| &&
                     `            "sap/ui/core/Control",` && |\n| &&
                     `            "sap/m/Button",` && |\n| &&
                     `            "sap/ui/export/Spreadsheet"` && |\n| &&
                     `        ], function (Control, Button, Spreadsheet) {` && |\n| &&
                     `            "use strict";` && |\n| &&
                     |\n| &&
                     `            return Control.extend("z2ui5.ExportSpreadsheet", {` && |\n| &&
                     |\n| &&
                     `                metadata: {` && |\n| &&
                     `                    properties: {` && |\n| &&
                     `                        tableId: {` && |\n| &&
                     `                            type: "string",` && |\n| &&
                     `                            defaultValue: ""` && |\n| &&
                     `                        },` && |\n| &&
                     `                        type: {` && |\n| &&
                     `                            type: "string",` && |\n| &&
                     `                            defaultValue: ""` && |\n| &&
                     `                        },` && |\n| &&
                     `                        icon: {` && |\n| &&
                     `                            type: "string",` && |\n| &&
                     `                            defaultValue: ""` && |\n| &&
                     `                        },` && |\n| &&
                     `                        text: {` && |\n| &&
                     `                            type: "string",` && |\n| &&
                     `                            defaultValue: ""` && |\n| &&
                     `                        }` && |\n| &&
                     `                    },` && |\n| &&
                     |\n| &&
                     |\n| &&
                     `                    aggregations: {` && |\n| &&
                     `                    },` && |\n| &&
                     `                    events: { },` && |\n| &&
                     `                    renderer: null` && |\n| &&
                     `                },` && |\n| &&
                     |\n| &&
                     `                renderer: function (oRm, oControl) {` && |\n| &&
                     |\n| &&
                     `                    oControl.oExportButton = new Button({` && |\n| &&
                     `                        text: oControl.getProperty("text"),` && |\n| &&
                     `                        icon: oControl.getProperty("icon"), ` && |\n| &&
                     `                        type: oControl.getProperty("type"), ` && |\n| &&
                     `                        press: function (oEvent) { ` && |\n| &&
                     |\n| &&
                     `                             var aCols =` && i_columnconfig  && `;` && |\n| &&
                     |\n| &&
                     `                             var oBinding, oSettings, oSheet, oTable, vTableId, vViewPrefix,vPrefixTableId;` && |\n| &&
                     `                             vTableId = oControl.getProperty("tableId")` && |\n| &&
                     `                          //   vViewPrefix = sap.z2ui5.oView.sId;` && |\n| &&
                     `                           //  vPrefixTableId = vViewPrefix + "--" + vTableId;` && |\n| &&
                     `                             vPrefixTableId = sap.z2ui5.oView.createId( vTableId );` && |\n| &&
                     `                             oTable = sap.ui.getCore().byId(vPrefixTableId);` && |\n| &&
                     `                             oBinding = oTable.getBinding("rows");` && |\n| &&
                     `                             if (oBinding == null) {` && |\n| &&
                     `                               oBinding = oTable.getBinding("items");` && |\n| &&
                     `                             };` && |\n| &&
                     `                             oSettings = {` && |\n| &&
                     `                               workbook: { columns: aCols },` && |\n| &&
                     `                               dataSource: oBinding` && |\n| &&
                     `                             };` && |\n| &&
                     `                             oSheet = new Spreadsheet(oSettings);` && |\n| &&
                     `                             oSheet.build()` && |\n| &&
                     `                               .then(function() {` && |\n| &&
                     `                               }).finally(function() {` && |\n| &&
                     `                                 oSheet.destroy();` && |\n| &&
                     `                               });` && |\n| &&
                     `                         }.bind(oControl)` && |\n| &&
                     `                  });` && |\n| &&
                     |\n| &&
                     `                    oRm.renderControl(oControl.oExportButton);` && |\n| &&
                     `                }` && |\n| &&
                     `            });` && |\n| &&
                     `        });`.

  ENDMETHOD.
ENDCLASS.
