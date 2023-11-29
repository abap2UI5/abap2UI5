CLASS z2ui5_cl_cc_bwipjs DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      BEGIN OF ty_s_barcode,
        sym  TYPE string,
        desc TYPE string,
        text TYPE string,
        opts TYPE string,
      END OF ty_s_barcode.
    TYPES ty_t_barcode TYPE STANDARD TABLE OF ty_s_barcode WITH EMPTY KEY.

    CONSTANTS cv_src TYPE string VALUE `https://cdnjs.cloudflare.com/ajax/libs/bwip-js/4.1.1/bwip-js-min.js`.

    METHODS load_lib
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    class-METHODS get_t_barcode_types
      RETURNING
        VALUE(result) TYPE ty_t_barcode.

    CLASS-METHODS get_js
      RETURNING
        VALUE(r_js) TYPE string.

    METHODS load_cc
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS constructor
      IMPORTING
        view TYPE REF TO z2ui5_cl_xml_view.

    METHODS control
      IMPORTING
        bcid          TYPE clike OPTIONAL
        text          TYPE clike OPTIONAL
        scale         TYPE clike OPTIONAL
        height        TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

  PROTECTED SECTION.
    DATA mo_view TYPE REF TO z2ui5_cl_xml_view.

  PRIVATE SECTION.

ENDCLASS.



CLASS z2ui5_cl_cc_bwipjs IMPLEMENTATION.

  METHOD constructor.

    me->mo_view = view.

  ENDMETHOD.

  METHOD load_lib.

    result = mo_view->_cc_plain_xml( `<html:script type="text/javascript" src="` && cv_src && `" />` ).

  ENDMETHOD.

  METHOD get_t_barcode_types.

    result = VALUE #(
      ( sym = 'ean5'    desc = 'EAN-5'     text = '90200'                   opts = 'includetext guardwhitespace' )
      ( sym = 'ean2'    desc = 'EAN-2'     text = '05'                      opts = 'includetext guardwhitespace' )
      ( sym = 'ean13'   desc = 'EAN-13'    text = '9520123456788'           opts = 'includetext guardwhitespace' )
      ( sym = 'upca'    desc = 'UPC-A'     text = '012345000058'            opts = 'includetext' )
      ( sym = 'isbn'    desc = 'ISBN'      text = '978-1-56581-231-4 90000' opts = 'includetext guardwhitespace' )
      ( sym = 'qrcode'  desc = 'QR Code'   text = 'http://goo.gl/0bis'      opts = 'eclevel=M' )
    ).

  ENDMETHOD.

  METHOD load_cc.

    data(js) = get_js( ).
    result = mo_view->_generic( ns = `html` name = `script` )->_cc_plain_xml( js ).

  ENDMETHOD.

  METHOD control.

    result = mo_view.
    mo_view->_generic( name   = `bwipjs`
              ns     = `z2ui5`
              t_prop = VALUE #( ( n = `bcid`   v = bcid )
                                ( n = `text`   v = text )
                                ( n = `scale`  v = scale )
                                ( n = `height` v = height )
              ) ).

  ENDMETHOD.


  METHOD get_js.

    r_js  = `debugger;  jQuery.sap.declare("z2ui5.bwipjs");` && |\n| &&
                     |\n| &&
                     `        sap.ui.require([` && |\n| &&
                     `            "sap/ui/core/Control",` && |\n| &&
                     `        ], function (Control) {` && |\n| &&
                     `            "use strict";` && |\n| &&
                     |\n| &&
                     `            return Control.extend("z2ui5.bwipjs", {` && |\n| &&
                     |\n| &&
                     `                metadata: {` && |\n| &&
                     `                    properties: {` && |\n| &&
                     `                        bcid: {` && |\n| &&
                     `                            type: "string",` && |\n| &&
                     `                            defaultValue: ""` && |\n| &&
                     `                        },` && |\n| &&
                     `                        text: {` && |\n| &&
                     `                            type: "string",` && |\n| &&
                     `                            defaultValue: ""` && |\n| &&
                     `                        },` && |\n| &&
                     `                        scale: {` && |\n| &&
                     `                            type: "string",` && |\n| &&
                     `                            defaultValue: ""` && |\n| &&
                     `                        },` && |\n| &&
                     `                        height: {` && |\n| &&
                     `                            type: "string",` && |\n| &&
                     `                            defaultValue: ""` && |\n| &&
                     `                        },` && |\n| &&
                     `                        includetext: {` && |\n| &&
                     `                            type: "string",` && |\n| &&
                     `                            defaultValue: ""` && |\n| &&
                     `                        },` && |\n| &&
                     `                        textalign: {` && |\n| &&
                     `                            type: "string",` && |\n| &&
                     `                            defaultValue: ""` && |\n| &&
                     `                        }` && |\n| &&
                     `                    },` && |\n| &&
                     |\n| &&
                     |\n| &&
                     `                    aggregations: {` && |\n| &&
                     `                    },` && |\n| &&
                     `                    events: {` && |\n| &&
                     `                        "upload": {` && |\n| &&
                     `                            allowPreventDefault: true,` && |\n| &&
                     `                            parameters: {}` && |\n| &&
                     `                        }` && |\n| &&
                     `                    },` && |\n| &&
                     `                    renderer: null` && |\n| &&
                     `                },` && |\n| &&
                     |\n| &&
                     `   onAfterRendering() {  ` &&
                     ` let canvas = bwipjs.toCanvas('mycanvas', {` && |\n|  &&
                     `            bcid:        this.getProperty("bcid"),       // Barcode type` && |\n|  &&
                     `            text:        this.getProperty("text"),    // Text to encode` && |\n|  &&
                     `            scale:       this.getProperty("scale"),               // 3x scaling factor` && |\n|  &&
                     `            height:      this.getProperty("height"),               // Bar height, in millimeters` && |\n|  &&
                     `            includetext: true,            // Show human-readable text` && |\n|  &&
                     `            textxalign:  'center',        // Always good to set this` && |\n|  &&
                     `        });` && |\n|  &&
                     `  },` && |\n| &&
                     `                renderer: function (oRm, oControl) {` && |\n| &&
` debugger;  oRm.write( "&lt;canvas id='mycanvas' /&gt;");` && |\n| && |\n|  &&
                     `    // The return value is the canvas element` && |\n|  &&
                     `                }` && |\n| &&
                     `            });` && |\n| &&
                     `        });`.

  ENDMETHOD.

ENDCLASS.
