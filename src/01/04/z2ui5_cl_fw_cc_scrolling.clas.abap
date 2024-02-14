CLASS z2ui5_cl_fw_cc_scrolling DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      BEGIN OF ty_s_item,
        id       TYPE string,
        scrollto TYPE string,
      END OF ty_s_item.
    TYPES ty_t_item TYPE STANDARD TABLE OF ty_s_item WITH EMPTY KEY ##NEEDED.

    CLASS-METHODS get_js
      RETURNING
        VALUE(result) TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_fw_cc_scrolling IMPLEMENTATION.


  METHOD get_js.

    result = `sap.ui.define("z2ui5/Scrolling", [` && |\n| &&
             `  "sap/ui/core/Control",` && |\n| &&
             `], (Control) => {` && |\n| &&
             `  "use strict";` && |\n| &&
             |\n| &&
             `  return Control.extend("z2ui5.Scrolling", {` && |\n| &&
             `      metadata: {` && |\n| &&
             `          properties: {` && |\n| &&
             `              setUpdate: { type: "boolean" , defaultValue: true},` && |\n| &&
             `              items: { type: "Array" },` && |\n| &&
             `          }` && |\n| &&
             `      },` && |\n| &&
             |\n| &&
             `      setBackend() {  ` && |\n| &&
               `   if (this.mProperties.items){ this.mProperties.items.forEach(item => {` && |\n| &&
                           `                        try {` && |\n| &&
                           `                            item.SCROLLTO = sap.z2ui5.oView.byId(item.ID).getScrollDelegate().getScrollTop();` && |\n| &&
                           `                        } catch (e) {` && |\n| &&
                           `                            try {` && |\n| &&
                           `                                var ele = '#' + sap.z2ui5.oView.byId(item.ID).getId() + '-inner';` && |\n| &&
                           `                                item.SCROLLTO = $(ele).scrollTop();` && |\n| &&
                           `                            } catch (e) { }` && |\n| &&
                           `                        }` && |\n| &&
                           `                    });` && |\n| &&
             `  } },` && |\n| &&
             `      init() {    sap.z2ui5.onBeforeRoundtrip.push( this.setBackend.bind(this) );   },` && |\n| &&
             `      renderer(oRm, oControl) {` && |\n| &&
             |\n| &&
             `       ` && |\n| &&
             `            if (!oControl.getProperty("setUpdate")){ return; }` && |\n| &&
             |\n| &&
             `            oControl.setProperty("setUpdate", false);` && |\n| &&
             `          var items = oControl.getProperty("items");` && |\n| &&
             `          if(!items){return;};` && |\n| &&
             |\n| &&
             `            setTimeout( (oControl) => { ` && |\n| &&
             `              var items = oControl.getProperty("items");  ` && |\n| &&
             `              items.forEach(item => {` && |\n| &&
             `                  try {` && |\n| &&
             `                      sap.z2ui5.oView.byId(item.ID).scrollTo(item.SCROLLTO);` && |\n| &&
             `                  } catch {` && |\n| &&
             `                      try {` && |\n| &&
             `                          var ele = '#' + sap.z2ui5.oView.byId(item.ID).getId() + '-inner';` && |\n| &&
             `                          $(ele).scrollTop(item.SCROLLTO);` && |\n| &&
             `                      } catch { setTimeout( function( item ) { sap.z2ui5.oView.byId(item.ID).scrollTo(item.SCROLLTO); } , 1 , item);}` && |\n| &&
             `                  }` && |\n| &&
             `              }      ` && |\n| &&
             `              );` && |\n| &&
             |\n| &&
             `            } , 50 , oControl );` && |\n| &&
             `      }` && |\n| &&
             `  });` && |\n| &&
             `});`.
  ENDMETHOD.

ENDCLASS.
