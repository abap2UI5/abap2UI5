CLASS z2ui5_cl_cc_title DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS constructor
      IMPORTING
        view TYPE REF TO z2ui5_cl_xml_view optional.

    METHODS control
      IMPORTING
        title         TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    CLASS-METHODS get_js
      RETURNING
        VALUE(result) TYPE string.

  PROTECTED SECTION.
    DATA mo_view TYPE REF TO z2ui5_cl_xml_view.

  PRIVATE SECTION.
ENDCLASS.



CLASS Z2UI5_CL_CC_TITLE IMPLEMENTATION.


  METHOD constructor.

    me->mo_view = view.

  ENDMETHOD.


  METHOD control.

    result = mo_view.
    mo_view->_generic( name   = `Title`
              ns     = `z2ui5`
              t_prop = VALUE #( ( n = `title`  v = title ) ) ).

  ENDMETHOD.


  METHOD get_js.

    result = `jQuery.sap.declare("z2ui5.Title");` && |\n|  &&
             `sap.ui.require(["sap/ui/core/Control"], (Control)=>{` && |\n|  &&
             `        "use strict";` && |\n|  &&
             `        return Control.extend("z2ui5.Title", {` && |\n|  &&
             `            metadata: {` && |\n|  &&
             `                properties: {` && |\n|  &&
             `                    title: {` && |\n|  &&
             `                        type: "string"` && |\n|  &&
             `                    },` && |\n|  &&
             `                }` && |\n|  &&
             `            },` && |\n|  &&
             `            setTitle(val) {` && |\n|  &&
             `                this.setProperty("title", val);` && |\n|  &&
             `                document.title = val;` && |\n|  &&
             `            },` && |\n|  &&
             `            renderer(oRm, oControl) {}` && |\n|  &&
             `        });` && |\n|  &&
             `  });`.

  ENDMETHOD.

ENDCLASS.
