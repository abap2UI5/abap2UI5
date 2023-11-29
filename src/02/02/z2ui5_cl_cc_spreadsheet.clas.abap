class Z2UI5_CL_CC_SPREADSHEET definition
  public
  final
  create public .

public section.

  methods LOAD_CC
    importing
      !COLUMNCONFIG type CLIKE
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods CONSTRUCTOR
    importing
      !VIEW type ref to Z2UI5_CL_XML_VIEW .
  methods CONTROL
    importing
      !TABLEID type CLIKE
      !TYPE type CLIKE optional
      !TEXT type CLIKE optional
      !ICON type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  class-methods GET_JS
    importing
      !I_COLUMNCONFIG type CLIKE
    returning
      value(R_JS) type STRING .
  PROTECTED SECTION.
      DATA mo_view TYPE REF TO z2ui5_cl_xml_view.
  PRIVATE SECTION.

ENDCLASS.



CLASS Z2UI5_CL_CC_SPREADSHEET IMPLEMENTATION.


  METHOD CONSTRUCTOR.

    ME->MO_VIEW = VIEW.

  ENDMETHOD.


  METHOD control.

    result = mo_view.
    mo_view->_generic( name   = `ExportSpreadsheet`
              ns     = `z2ui5`
              t_prop = VALUE #( ( n = `tableId`  v = tableid )
                                ( n = `text`     v = text )
                                ( n = `icon`     v = icon )
                                ( n = `type`     v = type )
              ) ).

  ENDMETHOD.


  METHOD get_js.

    r_js  = ` jQuery.sap.declare("z2ui5.ExportSpreadsheet");` && |\n| &&
                     |\n| &&
                     `        sap.ui.require([` && |\n| &&
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


  METHOD load_cc.

    DATA js TYPE string.


    js = get_js( columnconfig ).

*    result = mo_view->_cc_plain_xml( `<html:script>` && js && `</html:script>` ).
    result = mo_view->_generic( ns = `html` name = `script` )->_cc_plain_xml( js ).
  ENDMETHOD.
ENDCLASS.
