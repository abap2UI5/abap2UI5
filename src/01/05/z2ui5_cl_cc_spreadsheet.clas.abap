CLASS z2ui5_cl_cc_spreadsheet DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES z2ui5_if_ajson_filter.
    CLASS-METHODS get_js
      IMPORTING
        !i_columnconfig TYPE clike OPTIONAL
      RETURNING
        VALUE(r_js)     TYPE string .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS Z2UI5_CL_CC_SPREADSHEET IMPLEMENTATION.


  METHOD get_js.
    DATA lv_column_config TYPE string.
    lv_column_config = i_columnconfig.
    IF lv_column_config IS INITIAL.
      lv_column_config = `''`.
    ENDIF.

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
                     `                        tooltip: {` && |\n| &&
                     `                            type: "string",` && |\n| &&
                     `                            defaultValue: ""` && |\n| &&
                     `                        },` && |\n| &&
                     `                        columnconfig: { ` && |\n| &&
                     `                            type: "Array" ` && |\n| &&
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
                     `                setColumnconfig: function(oConfig) { ` && |\n| &&
*                     `                  oConfig = JSON.parse(oConfig);` && |\n| &&
                     `                  this.setProperty("columnconfig", oConfig, true );` && |\n| &&
                     `                },` && |\n| &&
                     |\n| &&
                     `                renderer: function (oRm, oControl) {` && |\n| &&
                     `                    var checkVersion = sap.ui.getVersionInfo().gav.includes('com.sap.ui5') ? true : false;` && |\n| &&
                     |\n| &&
                     `                    oControl.oExportButton = new Button({` && |\n| &&
                     `                        text: oControl.getProperty("text"),` && |\n| &&
                     `                        icon: oControl.getProperty("icon"), ` && |\n| &&
                     `                        type: oControl.getProperty("type"), ` && |\n| &&
                     `                        enabled: checkVersion,` && |\n| &&
                     `                        tooltip: !checkVersion ? 'Not Available on OpenUI5 SDK' : oControl.getProperty("tooltip") , ` && |\n| &&
                     `                        press: function (oEvent) { ` && |\n| &&
                     |\n| &&
                     `                             var aCols = oControl.getProperty("columnconfig");` && |\n| &&
                     `                             if( !aCols ) { aCols = ` && lv_column_config  && `; }` && |\n| &&
                     |\n| &&
                     `                             var oBinding, oSettings, oSheet, vTableId, vViewPrefix,vPrefixTableId;` && |\n| &&
                     `                             vTableId = oControl.getProperty("tableId")` && |\n| &&
                     `                             vPrefixTableId = sap.z2ui5.oView.createId( vTableId );` && |\n| &&
                     `                             var oTable;` && |\n| &&
                     `                             if (!oTable) { oTable = sap.z2ui5.oView.byId(vTableId); };` && |\n| &&
                     `                             if (!oTable) { oTable = sap.z2ui5.oViewNest.byId(vTableId); };` && |\n| &&
                     `                             if (!oTable) { oTable = sap.z2ui5.oViewNest2.byId(vTableId); };` && |\n| &&
                     `                             if (!oTable) { oTable = sap.z2ui5.oViewPopup.Fragment.byId('popupId',vTableId); };` && |\n| &&
                     `                             if (!oTable) { oTable = sap.z2ui5.oViewPopover.byId(vTableId); };` && |\n| &&
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


  METHOD z2ui5_if_ajson_filter~keep_node.

    rv_keep = abap_true.

    CASE iv_visit.

      WHEN  z2ui5_if_ajson_filter=>visit_type-open.

        IF is_node-children = 0.
          rv_keep = abap_false.
        ENDIF.

      WHEN  z2ui5_if_ajson_filter=>visit_type-value.

        CASE is_node-type.
          WHEN z2ui5_if_ajson_types=>node_type-boolean.
            IF is_node-value = `false`.
              rv_keep = abap_false.
            ENDIF.
          WHEN z2ui5_if_ajson_types=>node_type-number.
            IF is_node-value = `0` OR is_node-value = `0.00`.
              rv_keep = abap_false.
            ENDIF.
          WHEN z2ui5_if_ajson_types=>node_type-string.
            IF is_node-value = ``.
              rv_keep = abap_false.
            ENDIF.
        ENDCASE.

      WHEN  z2ui5_if_ajson_filter=>visit_type-close.

        IF is_node-children = 0.
          rv_keep = abap_false.
        ENDIF.

    ENDCASE.

  ENDMETHOD.
ENDCLASS.
