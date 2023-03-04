CLASS z2ui5_lcl_unit_test DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    METHODS:
      first_test FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS z2ui5_lcl_unit_test IMPLEMENTATION.

  METHOD first_test.

    z2ui5_cl_http_handler=>client = VALUE #(
      t_header = VALUE #( ( name = `~path` value = `/sap/bc/http/sap/zz99test` ) ) ).

    DATA(lv_index_html) = z2ui5_cl_http_handler=>main_index_html( ).

    IF lv_index_html IS INITIAL.
      cl_abap_unit_assert=>fail( 'No index.html' ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.
