CLASS ltcl_error DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS raise            FOR TESTING.
    METHODS raise_w_location FOR TESTING.
    METHODS raise_w_node     FOR TESTING.
    METHODS set_location     FOR TESTING.

ENDCLASS.


CLASS ltcl_error IMPLEMENTATION.
  METHOD raise.

    DATA lx     TYPE REF TO z2ui5_cx_ajson_error.
    DATA lv_msg TYPE string.

    lv_msg = repeat( val = 'a'
                     occ = 50 ) && repeat( val = 'b'
                                           occ = 50 ) && |123|.

    TRY.
        z2ui5_cx_ajson_error=>raise( lv_msg ).
        cl_abap_unit_assert=>fail( ).
      CATCH z2ui5_cx_ajson_error INTO lx.
        cl_abap_unit_assert=>assert_equals( exp = lv_msg
                                            act = lx->get_text( ) ).
    ENDTRY.

  ENDMETHOD.

  METHOD raise_w_location.

    DATA lx TYPE REF TO z2ui5_cx_ajson_error.

    TRY.
        z2ui5_cx_ajson_error=>raise( iv_msg      = 'a'
                                     iv_location = 'b' ).
        cl_abap_unit_assert=>fail( ).
      CATCH z2ui5_cx_ajson_error INTO lx.
        cl_abap_unit_assert=>assert_equals( exp = 'a @b'
                                            act = lx->get_text( ) ).
    ENDTRY.

  ENDMETHOD.

  METHOD raise_w_node.

    DATA lx      TYPE REF TO z2ui5_cx_ajson_error.
    DATA ls_node TYPE z2ui5_if_ajson_types=>ty_node.

    ls_node-path = '/x/'.
    ls_node-name = 'y'.

    TRY.
        z2ui5_cx_ajson_error=>raise( iv_msg  = 'a'
                                     is_node = ls_node ).
        cl_abap_unit_assert=>fail( ).
      CATCH z2ui5_cx_ajson_error INTO lx.
        cl_abap_unit_assert=>assert_equals( exp = 'a @/x/y'
                                            act = lx->get_text( ) ).
    ENDTRY.

  ENDMETHOD.

  METHOD set_location.

    DATA lx TYPE REF TO z2ui5_cx_ajson_error.

    TRY.
        z2ui5_cx_ajson_error=>raise( iv_msg      = 'a'
                                     iv_location = 'b' ).
        cl_abap_unit_assert=>fail( ).
      CATCH z2ui5_cx_ajson_error INTO lx.
        cl_abap_unit_assert=>assert_equals( exp = lx->location
                                            act = 'b' ).
        lx->set_location( 'c' ).
        cl_abap_unit_assert=>assert_equals( exp = lx->location
                                            act = 'c' ).
        cl_abap_unit_assert=>assert_equals( exp = 'a @c'
                                            act = lx->get_text( ) ).
    ENDTRY.

    TRY.
        z2ui5_cx_ajson_error=>raise( iv_msg = 'a' ).
        cl_abap_unit_assert=>fail( ).
      CATCH z2ui5_cx_ajson_error INTO lx.
        cl_abap_unit_assert=>assert_equals( exp = lx->location
                                            act = '' ).
        lx->set_location( 'c' ).
        cl_abap_unit_assert=>assert_equals( exp = lx->location
                                            act = 'c' ).
        cl_abap_unit_assert=>assert_equals( exp = 'a @c'
                                            act = lx->get_text( ) ).
    ENDTRY.

  ENDMETHOD.
ENDCLASS.
