CLASS ltcl_test DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    METHODS test_func_get_uuid_32 FOR TESTING RAISING cx_static_check.
    METHODS test_func_get_uuid_22 FOR TESTING RAISING cx_static_check.
    METHODS test_encoding         FOR TESTING RAISING cx_static_check.
    METHODS test_element_text     FOR TESTING RAISING cx_static_check.
    METHODS test_classes_impl_intf  FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_test IMPLEMENTATION.

  METHOD test_func_get_uuid_32.

    DATA(lv_uuid) = z2ui5_cl_util_stmpncfctn=>uuid_get_c32( ).
    cl_abap_unit_assert=>assert_not_initial( lv_uuid ).
    cl_abap_unit_assert=>assert_equals(
        act = 32
        exp = strlen( lv_uuid ) ).

  ENDMETHOD.

  METHOD test_func_get_uuid_22.

    DATA(lv_uuid) = z2ui5_cl_util_stmpncfctn=>uuid_get_c22( ).
    cl_abap_unit_assert=>assert_not_initial( lv_uuid ).
    cl_abap_unit_assert=>assert_equals(
        act = 22
        exp = strlen( lv_uuid ) ).

  ENDMETHOD.

  METHOD test_encoding.

    DATA(lv_string)   = `my string`.
    DATA(lv_xstring)  = z2ui5_cl_util_stmpncfctn=>conv_get_xstring_by_string( lv_string ).
    DATA(lv_string2)  = z2ui5_cl_util_stmpncfctn=>conv_encode_x_base64( lv_xstring ).
    DATA(lv_xstring2) = z2ui5_cl_util_stmpncfctn=>conv_decode_x_base64( lv_string2 ).
    DATA(lv_string3)  = z2ui5_cl_util_stmpncfctn=>conv_get_string_by_xstring( lv_xstring2 ).

    cl_abap_unit_assert=>assert_equals(
        act = lv_string3
        exp = lv_string ).

  ENDMETHOD.

  METHOD test_element_text.

    IF sy-sysid = 'ABC'.
      RETURN.
    ENDIF.

    DATA(ls_result) = z2ui5_cl_util_stmpncfctn=>rtti_get_data_element_texts( `UNAME` ).
    cl_abap_unit_assert=>assert_not_initial( ls_result ).

  ENDMETHOD.

  METHOD test_classes_impl_intf.

    IF sy-sysid = 'ABC'.
      RETURN.
    ENDIF.

    DATA(mt_classes) = z2ui5_cl_util_stmpncfctn=>rtti_get_classes_impl_intf( `IF_SERIALIZABLE_OBJECT`  ).
    cl_abap_unit_assert=>assert_not_initial( mt_classes ).

  ENDMETHOD.

ENDCLASS.
