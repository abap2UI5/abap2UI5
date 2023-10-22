CLASS z2ui5_cl_fw_cc_bwipjs DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    DATA mo_view TYPE REF TO z2ui5_cl_xml_view.

    TYPES:
      BEGIN OF ty_s_barcode,
        sym  TYPE string,
        desc TYPE string,
        text TYPE string,
        opts TYPE string,
      END OF ty_s_barcode.
    TYPES ty_t_barcode TYPE STANDARD TABLE OF ty_s_barcode WITH EMPTY KEY.

    CONSTANTS cv_src TYPE string VALUE `https://cdnjs.cloudflare.com/ajax/libs/bwip-js/4.1.1/bwip-js-min.js`.

    METHODS get_js
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS get_t_barcode_types
      RETURNING
        VALUE(result) TYPE ty_t_barcode.

  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.



CLASS z2ui5_cl_fw_cc_bwipjs IMPLEMENTATION.

  METHOD get_js.

    result = mo_view->_cc_plain_xml( `<html:script>` && cv_src && `</html:script>` ).

  ENDMETHOD.

  METHOD get_t_barcode_types.

    result = VALUE #(
      ( sym = 'ean5' desc = 'EAN-5' text = '90200' opts = 'includetext guardwhitespace' )
      ( sym = 'ean2' desc = 'EAN-2' text = '05'    opts = 'includetext guardwhitespace' )
    ).

  ENDMETHOD.

ENDCLASS.
