
CLASS ltcl_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_uuid_get_c32         FOR TESTING RAISING cx_static_check.
    METHODS test_uuid_get_c22         FOR TESTING RAISING cx_static_check.
    METHODS test_uuid_uniqueness      FOR TESTING RAISING cx_static_check.
    METHODS test_encoding             FOR TESTING RAISING cx_static_check.
    METHODS test_conv_xstring_rtrip   FOR TESTING RAISING cx_static_check.
    METHODS test_conv_base64_rtrip    FOR TESTING RAISING cx_static_check.
    METHODS test_context_get_sy       FOR TESTING RAISING cx_static_check.
    METHODS test_context_check_cloud  FOR TESTING RAISING cx_static_check.
    METHODS test_context_get_user     FOR TESTING RAISING cx_static_check.
    METHODS test_element_text         FOR TESTING RAISING cx_static_check.
    METHODS test_classes_impl_intf    FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_test IMPLEMENTATION.

  METHOD test_uuid_get_c32.

    DATA(lv_uuid) = z2ui5_cl_util_api=>uuid_get_c32( ).
    cl_abap_unit_assert=>assert_not_initial( lv_uuid ).
    cl_abap_unit_assert=>assert_equals( exp = 32
                                        act = strlen( lv_uuid ) ).

  ENDMETHOD.

  METHOD test_uuid_get_c22.

    DATA(lv_uuid) = z2ui5_cl_util_api=>uuid_get_c22( ).
    cl_abap_unit_assert=>assert_not_initial( lv_uuid ).
    cl_abap_unit_assert=>assert_equals( exp = 22
                                        act = strlen( lv_uuid ) ).

  ENDMETHOD.

  METHOD test_uuid_uniqueness.

    DATA(lv_uuid1) = z2ui5_cl_util_api=>uuid_get_c32( ).
    DATA(lv_uuid2) = z2ui5_cl_util_api=>uuid_get_c32( ).

    cl_abap_unit_assert=>assert_differs( exp = lv_uuid2
                                          act = lv_uuid1 ).

    DATA(lv_uuid3) = z2ui5_cl_util_api=>uuid_get_c22( ).
    DATA(lv_uuid4) = z2ui5_cl_util_api=>uuid_get_c22( ).

    cl_abap_unit_assert=>assert_differs( exp = lv_uuid4
                                          act = lv_uuid3 ).

  ENDMETHOD.

  METHOD test_encoding.

    DATA(lv_string)   = `my string`.
    DATA(lv_xstring)  = z2ui5_cl_util_api=>conv_get_xstring_by_string( lv_string ).
    DATA(lv_string2)  = z2ui5_cl_util_api=>conv_encode_x_base64( lv_xstring ).
    DATA(lv_xstring2) = z2ui5_cl_util_api=>conv_decode_x_base64( lv_string2 ).
    DATA(lv_string3)  = z2ui5_cl_util_api=>conv_get_string_by_xstring( lv_xstring2 ).

    cl_abap_unit_assert=>assert_equals( exp = lv_string
                                        act = lv_string3 ).

  ENDMETHOD.

  METHOD test_conv_xstring_rtrip.

    DATA(lv_string) = `Hello World UTF-8`.

    DATA(lv_xstring) = z2ui5_cl_util_api=>conv_get_xstring_by_string( lv_string ).
    cl_abap_unit_assert=>assert_not_initial( lv_xstring ).

    DATA(lv_back) = z2ui5_cl_util_api=>conv_get_string_by_xstring( lv_xstring ).
    cl_abap_unit_assert=>assert_equals( exp = lv_string
                                        act = lv_back ).

  ENDMETHOD.

  METHOD test_conv_base64_rtrip.

    DATA(lv_string) = `Base64 test content`.
    DATA(lv_xstring) = z2ui5_cl_util_api=>conv_get_xstring_by_string( lv_string ).

    DATA(lv_encoded) = z2ui5_cl_util_api=>conv_encode_x_base64( lv_xstring ).
    cl_abap_unit_assert=>assert_not_initial( lv_encoded ).

    DATA(lv_decoded) = z2ui5_cl_util_api=>conv_decode_x_base64( lv_encoded ).
    cl_abap_unit_assert=>assert_equals( exp = lv_xstring
                                        act = lv_decoded ).

    DATA(lv_back) = z2ui5_cl_util_api=>conv_get_string_by_xstring( lv_decoded ).
    cl_abap_unit_assert=>assert_equals( exp = lv_string
                                        act = lv_back ).

  ENDMETHOD.

  METHOD test_context_get_sy.

    DATA(ls_sy) = z2ui5_cl_util_api=>context_get_sy( ).

    cl_abap_unit_assert=>assert_equals( exp = sy-uname
                                        act = ls_sy-uname ).

    cl_abap_unit_assert=>assert_equals( exp = sy-datum
                                        act = ls_sy-datum ).

    cl_abap_unit_assert=>assert_equals( exp = sy-mandt
                                        act = ls_sy-mandt ).

    cl_abap_unit_assert=>assert_not_initial( ls_sy-sysid ).

  ENDMETHOD.

  METHOD test_context_check_cloud.

    DATA(lv_result) = z2ui5_cl_util_api=>context_check_abap_cloud( ).

    cl_abap_unit_assert=>assert_true(
        xsdbool( lv_result = abap_true OR lv_result = abap_false ) ).

  ENDMETHOD.

  METHOD test_context_get_user.

    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.

    cl_abap_unit_assert=>assert_equals( exp = z2ui5_cl_util_api=>context_get_user_tech( )
                                        act = sy-uname ).

    cl_abap_unit_assert=>assert_not_initial( z2ui5_cl_util_api=>context_get_user_tech( ) ).

  ENDMETHOD.

  METHOD test_element_text.

    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.

    DATA(ls_result) = z2ui5_cl_util_api=>rtti_get_data_element_texts( `UNAME` ).
    IF z2ui5_cl_util_api=>context_check_abap_cloud( ) = abap_false.
      cl_abap_unit_assert=>assert_not_initial( ls_result ).
    ENDIF.

  ENDMETHOD.

  METHOD test_classes_impl_intf.

    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.

    DATA(mt_classes) = z2ui5_cl_util_api=>rtti_get_classes_impl_intf( `IF_SERIALIZABLE_OBJECT` ).
    cl_abap_unit_assert=>assert_not_initial( mt_classes ).

  ENDMETHOD.

ENDCLASS.
