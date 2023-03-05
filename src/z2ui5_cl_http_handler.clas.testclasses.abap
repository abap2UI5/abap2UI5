CLASS z2ui5_lcl_unit_test DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    METHODS
      first_test FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS z2ui5_lcl_unit_test IMPLEMENTATION.

  METHOD first_test.

    DATA temp139 LIKE z2ui5_cl_http_handler=>client.
    CLEAR temp139.
    DATA temp20 TYPE z2ui5_cl_http_handler=>ty_t_name_value.
    CLEAR temp20.
    DATA temp21 LIKE LINE OF temp20.
    temp21-name = `~path`.
    temp21-value = `/sap/bc/http/sap/zz99test`.
    APPEND temp21 TO temp20.
    temp139-t_header = temp20.
    z2ui5_cl_http_handler=>client = temp139.

    DATA lv_index_html TYPE string.
    lv_index_html = z2ui5_cl_http_handler=>main_index_html( ).

    IF lv_index_html IS INITIAL.
      cl_abap_unit_assert=>fail( 'No index.html' ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.
