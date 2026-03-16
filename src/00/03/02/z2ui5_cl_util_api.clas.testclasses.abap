
CLASS ltcl_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS test_uuid_get_c32              FOR TESTING RAISING cx_static_check.
    METHODS test_uuid_get_c22              FOR TESTING RAISING cx_static_check.
    METHODS test_context_check_abap_cloud  FOR TESTING RAISING cx_static_check.
    METHODS test_context_get_user_tech     FOR TESTING RAISING cx_static_check.
    METHODS test_context_get_sy            FOR TESTING RAISING cx_static_check.
    METHODS test_context_get_tenant        FOR TESTING RAISING cx_static_check.
    METHODS test_context_get_callstack     FOR TESTING RAISING cx_static_check.
    METHODS test_conv_get_xstring_by_str   FOR TESTING RAISING cx_static_check.
    METHODS test_conv_get_string_by_xstr   FOR TESTING RAISING cx_static_check.
    METHODS test_conv_encode_x_base64      FOR TESTING RAISING cx_static_check.
    METHODS test_conv_decode_x_base64      FOR TESTING RAISING cx_static_check.
    METHODS test_encoding_roundtrip        FOR TESTING RAISING cx_static_check.
    METHODS test_conv_get_xlsx_by_itab     FOR TESTING RAISING cx_static_check.
    METHODS test_conv_get_itab_by_xlsx     FOR TESTING RAISING cx_static_check.
    METHODS test_rtti_get_data_elem_texts  FOR TESTING RAISING cx_static_check.
    METHODS test_rtti_get_classes_impl     FOR TESTING RAISING cx_static_check.
    METHODS test_rtti_get_t_fixvalues      FOR TESTING RAISING cx_static_check.
    METHODS test_rtti_get_table_desrc      FOR TESTING RAISING cx_static_check.
    METHODS test_source_get_method         FOR TESTING RAISING cx_static_check.
    METHODS test_bal_read                  FOR TESTING RAISING cx_static_check.
    METHODS test_bal_save                  FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_test IMPLEMENTATION.

  METHOD test_uuid_get_c32.

    DATA lv_uuid TYPE string.
    lv_uuid = z2ui5_cl_util_api=>uuid_get_c32( ).
    cl_abap_unit_assert=>assert_not_initial( lv_uuid ).
    cl_abap_unit_assert=>assert_equals( exp = 32
                                        act = strlen( lv_uuid ) ).

  ENDMETHOD.

  METHOD test_uuid_get_c22.

    DATA lv_uuid TYPE string.
    lv_uuid = z2ui5_cl_util_api=>uuid_get_c22( ).
    cl_abap_unit_assert=>assert_not_initial( lv_uuid ).
    cl_abap_unit_assert=>assert_equals( exp = 22
                                        act = strlen( lv_uuid ) ).

  ENDMETHOD.

  METHOD test_context_check_abap_cloud.

    DATA lv_result TYPE abap_bool.
    DATA temp1 TYPE xsdboolean.
    lv_result = z2ui5_cl_util_api=>context_check_abap_cloud( ).
    
    temp1 = boolc( lv_result = abap_true OR lv_result = abap_false ).
    cl_abap_unit_assert=>assert_true(
      temp1 ).

  ENDMETHOD.

  METHOD test_context_get_user_tech.

    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.

    cl_abap_unit_assert=>assert_equals( exp = z2ui5_cl_util_api=>context_get_user_tech( )
                                        act = sy-uname ).

    cl_abap_unit_assert=>assert_not_initial( z2ui5_cl_util_api=>context_get_user_tech( ) ).

  ENDMETHOD.

  METHOD test_context_get_sy.
    DATA ls_sy TYPE z2ui5_cl_util_api=>ty_syst.

    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.

    
    ls_sy = z2ui5_cl_util_api=>context_get_sy( ).
    cl_abap_unit_assert=>assert_not_initial( ls_sy-datum ).
    cl_abap_unit_assert=>assert_not_initial( ls_sy-uname ).
    cl_abap_unit_assert=>assert_equals( exp = sy-datum
                                        act = ls_sy-datum ).

  ENDMETHOD.

  METHOD test_context_get_tenant.

    DATA lv_tenant TYPE string.
    lv_tenant = z2ui5_cl_util_api=>context_get_tenant( ) ##NEEDED.

  ENDMETHOD.

  METHOD test_context_get_callstack.
    DATA lt_stack TYPE z2ui5_cl_util_api=>ty_t_stack.

    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.

    
    lt_stack = z2ui5_cl_util_api=>context_get_callstack( ) ##NEEDED.

  ENDMETHOD.

  METHOD test_conv_get_xstring_by_str.

    DATA lv_xstring TYPE xstring.
    lv_xstring = z2ui5_cl_util_api=>conv_get_xstring_by_string( `test` ).
    cl_abap_unit_assert=>assert_not_initial( lv_xstring ).

  ENDMETHOD.

  METHOD test_conv_get_string_by_xstr.

    DATA lv_xstring TYPE xstring.
    DATA lv_string TYPE string.
    lv_xstring = z2ui5_cl_util_api=>conv_get_xstring_by_string( `hello` ).
    
    lv_string = z2ui5_cl_util_api=>conv_get_string_by_xstring( lv_xstring ).
    cl_abap_unit_assert=>assert_equals( exp = `hello`
                                        act = lv_string ).

  ENDMETHOD.

  METHOD test_conv_encode_x_base64.

    DATA lv_xstring TYPE xstring.
    DATA lv_base64 TYPE string.
    lv_xstring = z2ui5_cl_util_api=>conv_get_xstring_by_string( `base64 test` ).
    
    lv_base64 = z2ui5_cl_util_api=>conv_encode_x_base64( lv_xstring ).
    cl_abap_unit_assert=>assert_not_initial( lv_base64 ).

  ENDMETHOD.

  METHOD test_conv_decode_x_base64.

    DATA lv_xstring TYPE xstring.
    DATA lv_base64 TYPE string.
    DATA lv_decoded TYPE xstring.
    lv_xstring = z2ui5_cl_util_api=>conv_get_xstring_by_string( `decode test` ).
    
    lv_base64 = z2ui5_cl_util_api=>conv_encode_x_base64( lv_xstring ).
    
    lv_decoded = z2ui5_cl_util_api=>conv_decode_x_base64( lv_base64 ).
    cl_abap_unit_assert=>assert_equals( exp = lv_xstring
                                        act = lv_decoded ).

  ENDMETHOD.

  METHOD test_encoding_roundtrip.

    DATA lv_string TYPE string.
    DATA lv_xstring TYPE xstring.
    DATA lv_string2 TYPE string.
    DATA lv_xstring2 TYPE xstring.
    DATA lv_string3 TYPE string.
    lv_string   = `my string`.
    
    lv_xstring  = z2ui5_cl_util_api=>conv_get_xstring_by_string( lv_string ).
    
    lv_string2  = z2ui5_cl_util_api=>conv_encode_x_base64( lv_xstring ).
    
    lv_xstring2 = z2ui5_cl_util_api=>conv_decode_x_base64( lv_string2 ).
    
    lv_string3  = z2ui5_cl_util_api=>conv_get_string_by_xstring( lv_xstring2 ).

    cl_abap_unit_assert=>assert_equals( exp = lv_string
                                        act = lv_string3 ).

  ENDMETHOD.

  METHOD test_conv_get_xlsx_by_itab.

    TYPES:
      BEGIN OF ty_row,
        col1 TYPE string,
        col2 TYPE string,
      END OF ty_row.

    TYPES temp3 TYPE STANDARD TABLE OF ty_row WITH DEFAULT KEY.
DATA lt_tab TYPE temp3.
    DATA temp1 LIKE lt_tab.
    DATA temp2 LIKE LINE OF temp1.
    DATA lv_result TYPE xstring.
    CLEAR temp1.
    
    temp2-col1 = `A`.
    temp2-col2 = `B`.
    INSERT temp2 INTO TABLE temp1.
    lt_tab = temp1.

    
    lv_result = z2ui5_cl_util_api=>conv_get_xlsx_by_itab( lt_tab ) ##NEEDED.

  ENDMETHOD.

  METHOD test_conv_get_itab_by_xlsx.

    DATA lv_xstring TYPE xstring.
    DATA lr_result TYPE REF TO data.

    z2ui5_cl_util_api=>conv_get_itab_by_xlsx( EXPORTING val    = lv_xstring
                                              IMPORTING result = lr_result ) ##NEEDED.

  ENDMETHOD.

  METHOD test_rtti_get_data_elem_texts.
    DATA ls_result TYPE z2ui5_cl_util_api=>ty_s_data_element_text.

    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.

    
    ls_result = z2ui5_cl_util_api=>rtti_get_data_element_texts( `UNAME` ).
    IF z2ui5_cl_util_api=>context_check_abap_cloud( ) = abap_false.
      cl_abap_unit_assert=>assert_not_initial( ls_result ).
    ENDIF.

  ENDMETHOD.

  METHOD test_rtti_get_classes_impl.
    DATA mt_classes TYPE z2ui5_cl_util_api=>ty_t_classes.

    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.

    
    mt_classes = z2ui5_cl_util_api=>rtti_get_classes_impl_intf( `IF_SERIALIZABLE_OBJECT` ).
    cl_abap_unit_assert=>assert_not_initial( mt_classes ).

  ENDMETHOD.

  METHOD test_rtti_get_t_fixvalues.
    DATA temp3 TYPE REF TO cl_abap_elemdescr.
    DATA lo_elem LIKE temp3.
    DATA lt_result TYPE z2ui5_cl_util_api=>ty_t_fix_val.

    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.

    IF z2ui5_cl_util_api=>context_check_abap_cloud( ) IS NOT INITIAL.
      RETURN.
    ENDIF.

    
    temp3 ?= cl_abap_elemdescr=>describe_by_name( `ABAP_BOOL` ).
    
    lo_elem = temp3.

    
    lt_result = z2ui5_cl_util_api=>rtti_get_t_fixvalues( elemdescr = lo_elem
                                                                langu     = sy-langu ) ##NEEDED.

  ENDMETHOD.

  METHOD test_rtti_get_table_desrc.
    DATA lv_result TYPE string.

    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.

    IF z2ui5_cl_util_api=>context_check_abap_cloud( ) IS NOT INITIAL.
      RETURN.
    ENDIF.

    
    lv_result = z2ui5_cl_util_api=>rtti_get_table_desrc( tabname = `T100` ).
    cl_abap_unit_assert=>assert_not_initial( lv_result ).

  ENDMETHOD.

  METHOD test_source_get_method.
    DATA lt_source TYPE string_table.

    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.

    
    lt_source = z2ui5_cl_util_api=>source_get_method(
      iv_classname  = `Z2UI5_CL_UTIL_API`
      iv_methodname = `UUID_GET_C32` ) ##NEEDED.

  ENDMETHOD.

  METHOD test_bal_read.
    DATA lt_msg TYPE z2ui5_cl_util=>ty_t_msg.
    DATA lt_result TYPE z2ui5_cl_util=>ty_t_msg.

    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.

    
    
    lt_result = z2ui5_cl_util_api=>bal_read( object    = `TEST`
                                                    subobject = `TEST`
                                                    id        = `TEST` ) ##NEEDED.

  ENDMETHOD.

  METHOD test_bal_save.
    DATA lt_log TYPE z2ui5_cl_util=>ty_t_msg.

    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.

    
    z2ui5_cl_util_api=>bal_save( object    = `TEST`
                                  subobject = `TEST`
                                  id        = `TEST`
                                  t_log     = lt_log ).

  ENDMETHOD.

ENDCLASS.
