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

    CONSTANTS cv_src TYPE string VALUE `https://cdnjs.cloudflare.com/ajax/libs/bwip-js/4.1.1/bwip-js-min.js` ##NEEDED.

    CLASS-METHODS get_t_barcode_types
      RETURNING
        VALUE(result) TYPE ty_t_barcode.

    CLASS-METHODS get_js_lib_local
      RETURNING VALUE(result) TYPE string.

    CLASS-METHODS get_js
      RETURNING
        VALUE(r_js) TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS Z2UI5_CL_CC_BWIPJS IMPLEMENTATION.


  METHOD get_js.

    r_js  = `    sap.ui.define("z2ui5/bwipjs", [` && |\n| &&
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
                     `  init() {` && |\n| &&
                     |\n| &&
                     |\n| &&
                     `      },` &&
                     `   onAfterRendering() {  ` &&
                      `     if(window.bwipjs == undefined) {  const loadScript = (FILE_URL, async = true, type = "text/javascript") => {` && |\n| &&
                     `              return new Promise((resolve, reject) => {` && |\n| &&
                     `                  try {` && |\n| &&
                     `                      const scriptEle = document.createElement("script");` && |\n| &&
                     `                      scriptEle.type = type;` && |\n| &&
                     `                      scriptEle.async = async;` && |\n| &&
                     `                      scriptEle.src =FILE_URL;` && |\n| &&
                     `                      scriptEle.addEventListener("load", (ev) => {` && |\n| &&
                     `                          resolve({ status: true });` && |\n| &&
                     `                      });` && |\n| &&
                     `                      scriptEle.addEventListener("error", (ev) => {` && |\n| &&
                     `                          reject({` && |\n| &&
                     `                              status: false,` && |\n| &&
                     `                              message: ``Failed to load the script ${FILE_URL}``` && |\n| &&
                     `                          });` && |\n| &&
                     `                      });` && |\n| &&
                     `                      document.body.appendChild(scriptEle);` && |\n| &&
                     `                  } catch (error) {` && |\n| &&
                     `                      reject(error);` && |\n| &&
                     `                  }` && |\n| &&
                     `              });` && |\n| &&
                     `          };` && |\n| &&
                     `          ` && |\n| &&
                     `          this.BusyDialog = new sap.m.BusyDialog( { title : "Loading bwip-js", text : "... now loading the data from a far away server" });` && |\n| &&
                     `          this.BusyDialog.open();` && |\n| &&
                     `          loadScript("https://cdnjs.cloudflare.com/ajax/libs/bwip-js/4.1.1/bwip-js-min.js")` && |\n| &&
                     `              .then( data  => {` && |\n| &&
                     `                  this.BusyDialog.close();` && |\n| &&
                       ` let canvas = bwipjs.toCanvas('mycanvas', {` && |\n| &&
                     `            bcid:        this.getProperty("bcid"),       // Barcode type` && |\n| &&
                     `            text:        this.getProperty("text"),    // Text to encode` && |\n| &&
                     `            scale:       this.getProperty("scale"),               // 3x scaling factor` && |\n| &&
                     `            height:      this.getProperty("height"),               // Bar height, in millimeters` && |\n| &&
                     `            includetext: true,            // Show human-readable text` && |\n| &&
                     `            textxalign:  'center',        // Always good to set this` && |\n| &&
                     `              })` && |\n| &&
                     `              .catch( err => {` && |\n| &&
                     `                  new sap.m.MessageBox.error('Error on load bwip-js library: ' + err);` && |\n| &&
                     `                  this.BusyDialog.close();` && |\n| &&
                     `              }); } ) } else {` && |\n| &&
                     ` let canvas = bwipjs.toCanvas('mycanvas', {` && |\n| &&
                     `            bcid:        this.getProperty("bcid"),       // Barcode type` && |\n| &&
                     `            text:        this.getProperty("text"),    // Text to encode` && |\n| &&
                     `            scale:       this.getProperty("scale"),               // 3x scaling factor` && |\n| &&
                     `            height:      this.getProperty("height"),               // Bar height, in millimeters` && |\n| &&
                     `            includetext: true,            // Show human-readable text` && |\n| &&
                     `            textxalign:  'center',        // Always good to set this` && |\n| &&
                     `        }); }` && |\n| &&
                     `  },` && |\n| &&
                     `                renderer: function (oRm, oControl) {` && |\n| &&
                     `                    oRm.write( "&lt;canvas id='mycanvas' /&gt;");` && |\n| && |\n| &&
                     `    // The return value is the canvas element` && |\n| &&
                     `                }` && |\n| &&
                     `            });` && |\n| &&
                     `        });`.

  ENDMETHOD.


  METHOD get_js_lib_local.

    result = ``.

  ENDMETHOD.


  METHOD get_t_barcode_types.

    result = VALUE #(
      ( sym = 'ean5'    desc = 'EAN-5'     text = '90200'                   opts = 'includetext guardwhitespace' )
      ( sym = 'ean2'    desc = 'EAN-2'     text = '05'                      opts = 'includetext guardwhitespace' )
      ( sym = 'ean13'   desc = 'EAN-13'    text = '9520123456788'           opts = 'includetext guardwhitespace' )
      ( sym = 'upca'    desc = 'UPC-A'     text = '012345000058'            opts = 'includetext' )
      ( sym = 'isbn'    desc = 'ISBN'      text = '978-1-56581-231-4 90000' opts = 'includetext guardwhitespace' )
      ( sym = 'qrcode'  desc = 'QR Code'   text = 'http://goo.gl/0bis'      opts = 'eclevel=M' ) ).

  ENDMETHOD.
ENDCLASS.
