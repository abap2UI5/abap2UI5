
CLASS ltcl_test_app DEFINITION FOR TESTING.

  PUBLIC SECTION.

    INTERFACES if_serializable_object.

    TYPES:
      BEGIN OF ty_row,
        title    TYPE string,
        value    TYPE string,
        descr    TYPE string,
        icon     TYPE string,
        info     TYPE string,
        selected TYPE abap_bool,
        checkbox TYPE abap_bool,
      END OF ty_row.

    CONSTANTS sv_status TYPE string VALUE `test` ##NEEDED.

    CLASS-DATA sv_var TYPE string.
    CLASS-DATA ss_tab TYPE ty_row.
    CLASS-DATA st_tab TYPE STANDARD TABLE OF ty_row WITH DEFAULT KEY.

    CLASS-METHODS class_constructor.

    DATA mv_val TYPE string ##NEEDED.
    DATA ms_tab TYPE ty_row ##NEEDED.
    TYPES temp1_f9908b1ee3 TYPE STANDARD TABLE OF ty_row WITH DEFAULT KEY.
DATA mt_tab TYPE temp1_f9908b1ee3 ##NEEDED.

  PROTECTED SECTION.

  PRIVATE SECTION.
ENDCLASS.


CLASS ltcl_test_app IMPLEMENTATION.
  METHOD class_constructor.
    DATA temp1 TYPE ltcl_test_app=>ty_row.
    DATA temp2 LIKE st_tab.

    sv_var = 1.
    
    CLEAR temp1.
    ss_tab = temp1.
    
    CLEAR temp2.
    st_tab = temp2.

  ENDMETHOD.
ENDCLASS.


CLASS ltcl_unit_test_open_abap DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS check_input
      IMPORTING
        val           TYPE data
      RETURNING
        VALUE(result) TYPE abap_bool.

    METHODS test_assign            FOR TESTING RAISING cx_static_check.
    METHODS test_eledescr_rel_name FOR TESTING RAISING cx_static_check.
    METHODS test_classdescr        FOR TESTING RAISING cx_static_check.
    METHODS test_substring_after   FOR TESTING RAISING cx_static_check.
    METHODS test_substring_before  FOR TESTING RAISING cx_static_check.
    METHODS test_string_shift      FOR TESTING RAISING cx_static_check.
    METHODS test_string_replace    FOR TESTING RAISING cx_static_check.
    METHODS test_raise_error       FOR TESTING RAISING cx_static_check.
    METHODS test_xsdbool           FOR TESTING RAISING cx_static_check.
    METHODS test_xsdbool_nested    FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_unit_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION MEDIUM.

  PRIVATE SECTION.

    METHODS test_create                    FOR TESTING RAISING cx_static_check.

    METHODS test_boolean_abap_2_json       FOR TESTING RAISING cx_static_check.
    METHODS test_boolean_check             FOR TESTING RAISING cx_static_check.

    METHODS test_c_trim                    FOR TESTING RAISING cx_static_check.
    METHODS test_c_trim_lower              FOR TESTING RAISING cx_static_check.
    METHODS test_c_trim_upper              FOR TESTING RAISING cx_static_check.
    METHODS test_c_trim_horizontal_tab     FOR TESTING RAISING cx_static_check.

    METHODS test_time_get_timestampl       FOR TESTING RAISING cx_static_check.
    METHODS test_time_substract_seconds    FOR TESTING RAISING cx_static_check.
    METHODS test_func_get_user_tech        FOR TESTING RAISING cx_static_check.

    METHODS test_rtti_get_t_attri_by_incl  FOR TESTING RAISING cx_static_check.
    METHODS test_rtti_get_classname_by_ref FOR TESTING RAISING cx_static_check.
    METHODS test_rtti_get_type_name        FOR TESTING RAISING cx_static_check.
    METHODS test_rtti_get_type_kind        FOR TESTING RAISING cx_static_check.
    METHODS test_rtti_check_type_kind      FOR TESTING RAISING cx_static_check.
    METHODS test_rtti_get_t_attri_by_obj   FOR TESTING RAISING cx_static_check.
    METHODS test_rtti_get_t_comp_by_struc  FOR TESTING RAISING cx_static_check.

    METHODS test_trans_json_any_2__w_struc FOR TESTING RAISING cx_static_check.
    METHODS test_trans_xml_any_2__w_obj    FOR TESTING RAISING cx_static_check.
    METHODS test_trans_xml_any_2__w_data   FOR TESTING RAISING cx_static_check.
    METHODS test_trans_xml_2_any__w_obj    FOR TESTING RAISING cx_static_check.
    METHODS test_trans_xml_2_any__w_data   FOR TESTING RAISING cx_static_check.

    METHODS test_url_param_create_url      FOR TESTING RAISING cx_static_check.
    METHODS test_url_param_get             FOR TESTING RAISING cx_static_check.
    METHODS test_url_param_get_tab         FOR TESTING RAISING cx_static_check.
    METHODS test_url_param_set             FOR TESTING RAISING cx_static_check.

    METHODS test_x_check_raise             FOR TESTING RAISING cx_static_check.
    METHODS test_x_check_raise_not         FOR TESTING RAISING cx_static_check.
    METHODS test_x_raise                   FOR TESTING RAISING cx_static_check.
    METHODS test_check_unassign_inital     FOR TESTING RAISING cx_static_check.
    METHODS conv_copy_ref_data             FOR TESTING RAISING cx_static_check.
    METHODS rtti_check_ref_data            FOR TESTING RAISING cx_static_check.
    METHODS test_check_bound_a_not_inital  FOR TESTING RAISING cx_static_check.
    METHODS test_sql_get_by_string         FOR TESTING RAISING cx_static_check.
    METHODS test_get_token_t_by_r_t        FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_unit_test_open_abap IMPLEMENTATION.

  METHOD test_assign.

    DATA lo_app TYPE REF TO ltcl_test_app.
    FIELD-SYMBOLS <any> TYPE any.
    DATA lv_assign TYPE string.
    CREATE OBJECT lo_app TYPE ltcl_test_app.
    

    lo_app->mv_val = `ABC`.

    
    lv_assign = |MV_VAL|.
    ASSIGN lo_app->(lv_assign) TO <any>.
    ASSERT sy-subrc = 0.

    cl_abap_unit_assert=>assert_equals( exp = `ABC`
                                        act = <any> ).

  ENDMETHOD.

  METHOD test_classdescr.

    DATA lo_app TYPE REF TO ltcl_test_app.
    DATA temp3 TYPE REF TO cl_abap_classdescr.
    DATA lt_attri LIKE temp3->attributes.
    DATA lv_test LIKE LINE OF lt_attri.
    DATA temp1 LIKE LINE OF lt_attri.
    DATA temp2 LIKE sy-tabix.
    DATA temp4 LIKE LINE OF lt_attri.
    DATA temp5 LIKE sy-tabix.
    DATA temp6 LIKE LINE OF lt_attri.
    DATA temp7 LIKE sy-tabix.
    DATA temp8 LIKE LINE OF lt_attri.
    DATA temp9 LIKE sy-tabix.
    DATA temp10 LIKE LINE OF lt_attri.
    DATA temp11 LIKE sy-tabix.
    DATA temp12 LIKE LINE OF lt_attri.
    DATA temp13 LIKE sy-tabix.
    DATA temp14 LIKE LINE OF lt_attri.
    DATA temp15 LIKE sy-tabix.
    CREATE OBJECT lo_app TYPE ltcl_test_app.

    
    temp3 ?= cl_abap_objectdescr=>describe_by_object_ref( lo_app ).
    
    lt_attri = temp3->attributes.

    " TODO: variable is assigned but never used (ABAP cleaner)
    
    
    
    temp2 = sy-tabix.
    READ TABLE lt_attri WITH KEY name = `MS_TAB` INTO temp1.
    sy-tabix = temp2.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    lv_test = temp1.
    
    
    temp5 = sy-tabix.
    READ TABLE lt_attri WITH KEY name = `MT_TAB` INTO temp4.
    sy-tabix = temp5.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    lv_test = temp4.
    
    
    temp7 = sy-tabix.
    READ TABLE lt_attri WITH KEY name = `MV_VAL` INTO temp6.
    sy-tabix = temp7.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    lv_test = temp6.
    
    
    temp9 = sy-tabix.
    READ TABLE lt_attri WITH KEY name = `SS_TAB` INTO temp8.
    sy-tabix = temp9.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    lv_test = temp8.
    
    
    temp11 = sy-tabix.
    READ TABLE lt_attri WITH KEY name = `ST_TAB` INTO temp10.
    sy-tabix = temp11.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    lv_test = temp10.
    
    
    temp13 = sy-tabix.
    READ TABLE lt_attri WITH KEY name = `SV_STATUS` INTO temp12.
    sy-tabix = temp13.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    lv_test = temp12.
    
    
    temp15 = sy-tabix.
    READ TABLE lt_attri WITH KEY name = `SV_VAR` INTO temp14.
    sy-tabix = temp15.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    lv_test = temp14.

  ENDMETHOD.

  METHOD test_eledescr_rel_name.

    DATA temp16 TYPE REF TO cl_abap_elemdescr.
    DATA lo_ele LIKE temp16.
    temp16 ?= cl_abap_elemdescr=>describe_by_data( abap_true ).
    
    lo_ele = temp16.

    cl_abap_unit_assert=>assert_equals( exp = `ABAP_BOOL`
                                        act = lo_ele->get_relative_name( ) ).

  ENDMETHOD.

  METHOD test_substring_after.

    cl_abap_unit_assert=>assert_equals( exp = ` string`
                                        act = substring_after( val = 'this is a string'
                                                               sub = 'a' ) ).

  ENDMETHOD.

  METHOD test_substring_before.

    cl_abap_unit_assert=>assert_equals( exp = `this is `
                                        act = substring_before( val = 'this is a string'
                                                                sub = 'a' ) ).

  ENDMETHOD.

  METHOD test_string_shift.

    cl_abap_unit_assert=>assert_equals( exp = `string`
                                        act = shift_left( shift_right( val = `   string   `
                                                                       sub = ` ` ) ) ).

  ENDMETHOD.

  METHOD test_string_replace.

    DATA lv_search TYPE string.
    lv_search = replace( val  = `one two three`
                               sub  = `two`
                               with = 'ABC'
                               occ  = 0 ) ##NEEDED.

    cl_abap_unit_assert=>assert_equals( exp = `one ABC three`
                                        act = replace( val  = `one two three`
                                                       sub  = `two`
                                                       with = 'ABC'
                                                       occ  = 0 ) ).

  ENDMETHOD.

  METHOD test_raise_error.
        DATA lx TYPE REF TO z2ui5_cx_util_error.

    TRY.
        IF 1 = 1.
          RAISE EXCEPTION TYPE z2ui5_cx_util_error.
        ENDIF.
        cl_abap_unit_assert=>fail( ).

        
      CATCH z2ui5_cx_util_error INTO lx.
        cl_abap_unit_assert=>assert_bound( lx ).
    ENDTRY.

  ENDMETHOD.

  METHOD test_xsdbool.

    DATA lv_xsdbool TYPE abap_bool.
    DATA temp1 TYPE xsdboolean.
    DATA temp2 TYPE xsdboolean.
    temp1 = boolc( 1 = 1 ).
    lv_xsdbool = temp1.
    IF lv_xsdbool = abap_false.
      cl_abap_unit_assert=>assert_false( lv_xsdbool ).
    ENDIF.

    
    temp2 = boolc( 1 = 1 ).
    IF temp2 = abap_false.
      cl_abap_unit_assert=>fail( ).
    ENDIF.

  ENDMETHOD.

  METHOD test_xsdbool_nested.

    DATA lv_xsdbool TYPE abap_bool.
    DATA temp3 TYPE xsdboolean.
    DATA temp4 TYPE xsdboolean.
    temp3 = boolc( 1 = 1 ).
    lv_xsdbool = check_input( temp3 ).
    IF lv_xsdbool = abap_false.
      cl_abap_unit_assert=>assert_false( lv_xsdbool ).
    ENDIF.

    IF check_input( abap_false ) IS NOT INITIAL.
      cl_abap_unit_assert=>fail( ).
    ENDIF.

    
    temp4 = boolc( 1 = 1 ).
    IF check_input( temp4 ) = abap_false.
      cl_abap_unit_assert=>fail( ).
    ENDIF.

  ENDMETHOD.

  METHOD check_input.

    result = val.

  ENDMETHOD.
ENDCLASS.


CLASS ltcl_unit_test IMPLEMENTATION.
  METHOD test_boolean_check.

    DATA lv_bool TYPE abap_bool.
    DATA temp5 TYPE xsdboolean.
    DATA temp6 TYPE xsdboolean.
    temp5 = boolc( 1 = 1 ).
    lv_bool = temp5.
    cl_abap_unit_assert=>assert_true( z2ui5_cl_util=>boolean_check_by_data( lv_bool ) ).

    
    temp6 = boolc( 1 = 2 ).
    lv_bool = temp6.
    cl_abap_unit_assert=>assert_true( z2ui5_cl_util=>boolean_check_by_data( lv_bool ) ).

    cl_abap_unit_assert=>assert_true( z2ui5_cl_util=>boolean_check_by_data( abap_true ) ).

    cl_abap_unit_assert=>assert_true( z2ui5_cl_util=>boolean_check_by_data( abap_false ) ).

  ENDMETHOD.

  METHOD test_sql_get_by_string.

    DATA lv_test TYPE string.
    DATA ls_sql TYPE z2ui5_cl_util=>ty_s_sql.
    lv_test = ``.
    
    ls_sql = z2ui5_cl_util=>filter_get_sql_by_sql_string( lv_test ) ##NEEDED.

  ENDMETHOD.

  METHOD test_create.

    DATA lo_test TYPE REF TO z2ui5_cl_util.
    CREATE OBJECT lo_test TYPE z2ui5_cl_util.

  ENDMETHOD.

  METHOD test_rtti_get_classname_by_ref.

    DATA lo_test2 TYPE REF TO ltcl_test_app.
    DATA lv_name2 TYPE string.
    CREATE OBJECT lo_test2 TYPE ltcl_test_app.
    
    lv_name2 = z2ui5_cl_util=>rtti_get_classname_by_ref( lo_test2 ).
    cl_abap_unit_assert=>assert_equals( exp = `LTCL_TEST_APP`
                                        act = lv_name2 ).

  ENDMETHOD.

  METHOD test_check_bound_a_not_inital.

    DATA lv_test TYPE string.
    DATA lr_test LIKE REF TO lv_test.
    lv_test = `test`.
    
    GET REFERENCE OF lv_test INTO lr_test.

    cl_abap_unit_assert=>assert_true( z2ui5_cl_util=>check_bound_a_not_inital( lr_test ) ).
    CLEAR lv_test.
    cl_abap_unit_assert=>assert_false( z2ui5_cl_util=>check_bound_a_not_inital( lr_test ) ).
    CLEAR lr_test.
    cl_abap_unit_assert=>assert_false( z2ui5_cl_util=>check_bound_a_not_inital( lr_test ) ).

  ENDMETHOD.

  METHOD test_check_unassign_inital.

    DATA lv_test TYPE string.
    DATA lr_test LIKE REF TO lv_test.
    lv_test = `test`.
    
    GET REFERENCE OF lv_test INTO lr_test.

    cl_abap_unit_assert=>assert_false( z2ui5_cl_util=>check_unassign_inital( lr_test ) ).

    CLEAR lv_test.
    cl_abap_unit_assert=>assert_true( z2ui5_cl_util=>check_unassign_inital( lr_test ) ).

  ENDMETHOD.

  METHOD rtti_check_ref_data.

    DATA lv_test TYPE string.
    DATA lr_data TYPE REF TO data.
    lv_test = `test`.
    
*    GET REFERENCE OF lv_test INTO lr_data.
    GET REFERENCE OF lv_test INTO lr_data.

    cl_abap_unit_assert=>assert_true( z2ui5_cl_util=>rtti_check_ref_data( lr_data ) ).

    cl_abap_unit_assert=>assert_false( z2ui5_cl_util=>rtti_check_ref_data( lv_test ) ).

  ENDMETHOD.

  METHOD conv_copy_ref_data.

    DATA lv_test TYPE string.
    DATA lr_data TYPE REF TO data.
    DATA lr_test2 TYPE REF TO data.
    FIELD-SYMBOLS <result> TYPE data.
    lv_test = `test`.
    
*    GET REFERENCE OF lv_test INTO lr_data.
    GET REFERENCE OF lv_test INTO lr_data.

    
    lr_test2 = z2ui5_cl_util=>conv_copy_ref_data( lr_data ).

    
    ASSIGN lr_test2->* TO <result>.

    cl_abap_unit_assert=>assert_equals( exp = lv_test
                                        act = <result> ).

  ENDMETHOD.

  METHOD test_boolean_abap_2_json.

    cl_abap_unit_assert=>assert_equals( exp = `{ABCD}`
                                        act = z2ui5_cl_util=>boolean_abap_2_json( `{ABCD}` ) ).

  ENDMETHOD.

  METHOD test_time_get_timestampl.

    DATA lv_time TYPE timestampl.
    DATA lv_time2 TYPE timestampl.
    lv_time = z2ui5_cl_util=>time_get_timestampl( ).

    
    lv_time2 = z2ui5_cl_util=>time_substract_seconds( time    = lv_time
                                                            seconds = 60 * 60 * 4 ).

    IF lv_time IS INITIAL OR lv_time2 IS INITIAL.
      cl_abap_unit_assert=>fail( ).
    ENDIF.

    IF lv_time < lv_time2.
      cl_abap_unit_assert=>fail( ).
    ENDIF.

  ENDMETHOD.

  METHOD test_time_substract_seconds.

    DATA lv_time TYPE timestampl.
    DATA lv_time2 TYPE timestampl.
    lv_time = z2ui5_cl_util=>time_get_timestampl( ).
    
    lv_time2 = z2ui5_cl_util=>time_get_timestampl( ).

    IF lv_time IS INITIAL OR lv_time2 IS INITIAL.
      cl_abap_unit_assert=>fail( ).
    ENDIF.

    IF lv_time2 < lv_time.
      cl_abap_unit_assert=>fail( ).
    ENDIF.

  ENDMETHOD.

  METHOD test_c_trim.

    cl_abap_unit_assert=>assert_equals( exp = `JsadfHHs`
                                        act = z2ui5_cl_util=>c_trim( ` JsadfHHs  ` ) ).

  ENDMETHOD.

  METHOD test_c_trim_lower.

    cl_abap_unit_assert=>assert_equals( exp = `jsadfhhs`
                                        act = z2ui5_cl_util=>c_trim_lower( ` JsadfHHs  ` ) ).

  ENDMETHOD.

  METHOD test_c_trim_upper.

    cl_abap_unit_assert=>assert_equals( exp = `JSADFHHS`
                                        act = z2ui5_cl_util=>c_trim_upper( ` JsadfHHs  ` ) ).

  ENDMETHOD.

  METHOD test_func_get_user_tech.

    IF sy-sysid = 'ABC'.
      RETURN.
    ENDIF.

    cl_abap_unit_assert=>assert_equals( exp = z2ui5_cl_util=>context_get_user_tech( )
                                        act = sy-uname ).

    cl_abap_unit_assert=>assert_not_initial( z2ui5_cl_util=>context_get_user_tech( ) ).

  ENDMETHOD.

  METHOD test_x_raise.

    TRY.
        z2ui5_cl_util=>x_raise( ).
        cl_abap_unit_assert=>fail( ).
      CATCH cx_root.
    ENDTRY.

  ENDMETHOD.

  METHOD test_x_check_raise.
        DATA temp7 TYPE xsdboolean.
        DATA temp8 TYPE xsdboolean.

    TRY.
        
        temp7 = boolc( 1 = 1 ).
        z2ui5_cl_util=>x_check_raise( temp7 ).
        cl_abap_unit_assert=>fail( ).
      CATCH cx_root.
    ENDTRY.

    TRY.
        
        temp8 = boolc( 1 = 3 ).
        z2ui5_cl_util=>x_check_raise( temp8 ).
      CATCH cx_root.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.

  ENDMETHOD.

  METHOD test_trans_json_any_2__w_struc.

    TYPES:
      BEGIN OF ty_row,
        title    TYPE string,
        value    TYPE string,
        selected TYPE abap_bool,
      END OF ty_row.

    DATA temp17 TYPE ty_row.
    DATA ls_row LIKE temp17.
    CLEAR temp17.
    temp17-title = `test`.
    
    ls_row = temp17.

    cl_abap_unit_assert=>assert_equals( exp = `{"selected":false,"title":"test","value":""}`
                                        act = z2ui5_cl_util=>json_stringify( ls_row ) ).

  ENDMETHOD.

  METHOD test_url_param_create_url.

    DATA lt_param TYPE z2ui5_cl_util=>ty_t_name_value.
    DATA lv_url TYPE string.
    lt_param = z2ui5_cl_util=>url_param_get_tab(
                         `https://url.com/rvice_for_ui?sap-client=100&app_start=z2ui5_cl_app_hello_world` ).
    
    lv_url = z2ui5_cl_util=>url_param_create_url( lt_param ).

    cl_abap_unit_assert=>assert_equals( exp = `sap-client=100&app_start=z2ui5_cl_app_hello_world`
                                        act = lv_url ).

  ENDMETHOD.

  METHOD test_url_param_get.

    DATA lv_param TYPE string.
    lv_param = z2ui5_cl_util=>url_param_get(
                         val = `app_start`
                         url = `https://url.com/rvice_for_ui?sap-client=100&app_start=z2ui5_cl_app_hello_world` ).

    cl_abap_unit_assert=>assert_equals( exp = `z2ui5_cl_app_hello_world`
                                        act = lv_param ).

  ENDMETHOD.

  METHOD test_url_param_get_tab.

    DATA lt_param TYPE z2ui5_cl_util=>ty_t_name_value.
    DATA temp18 LIKE LINE OF lt_param.
    DATA temp19 LIKE sy-tabix.
    DATA temp20 LIKE LINE OF lt_param.
    DATA temp21 LIKE sy-tabix.
    lt_param = z2ui5_cl_util=>url_param_get_tab(
                         `https://url.com/rvice_for_ui?sap-client=100&app_start=z2ui5_cl_app_hello_world` ).

    
    
    temp19 = sy-tabix.
    READ TABLE lt_param WITH KEY n = `sap-client` INTO temp18.
    sy-tabix = temp19.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `100`
                                        act = temp18-v ).

    
    
    temp21 = sy-tabix.
    READ TABLE lt_param WITH KEY n = `app_start` INTO temp20.
    sy-tabix = temp21.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `z2ui5_cl_app_hello_world`
                                        act = temp20-v ).

  ENDMETHOD.

  METHOD test_url_param_set.

    DATA lv_param TYPE string.
    lv_param = z2ui5_cl_util=>url_param_set(
                         name  = `app_start`
                         value = `z2ui5_cl_app_hello_world2`
                         url   = `https://url.com/rvice_for_ui?sap-client=100&app_start=z2ui5_cl_app_hello_world` ).

    cl_abap_unit_assert=>assert_equals( exp = `sap-client=100&app_start=z2ui5_cl_app_hello_world2`
                                        act = lv_param ).

  ENDMETHOD.

  METHOD test_x_check_raise_not.
        DATA temp9 TYPE xsdboolean.

    TRY.
        
        temp9 = boolc( 1 = 2 ).
        z2ui5_cl_util=>x_check_raise( temp9 ).
      CATCH z2ui5_cx_util_error.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD test_rtti_get_type_name.

    DATA temp22 TYPE xsdboolean.
    DATA lv_xsdbool LIKE temp22.
    DATA lv_name TYPE string.
    CLEAR temp22.
    
    lv_xsdbool = temp22.
    
    lv_name = z2ui5_cl_util=>rtti_get_type_name( lv_xsdbool ).
    cl_abap_unit_assert=>assert_equals( exp = `XSDBOOLEAN`
                                        act = lv_name ).

  ENDMETHOD.

  METHOD test_rtti_get_type_kind.

    DATA temp23 TYPE string.
    DATA lv_string LIKE temp23.
    DATA lv_type_kind TYPE string.
    DATA lr_string TYPE REF TO string.
    CLEAR temp23.
    
    lv_string = temp23.

    
    lv_type_kind = z2ui5_cl_util=>rtti_get_type_kind( lv_string ).
    
    cl_abap_unit_assert=>assert_equals( exp = cl_abap_typedescr=>typekind_string
                                        act = lv_type_kind ).

    CREATE DATA lr_string.
    lv_type_kind = z2ui5_cl_util=>rtti_get_type_kind( lr_string ).
    cl_abap_unit_assert=>assert_equals( exp = cl_abap_typedescr=>typekind_dref
                                        act = lv_type_kind ).

  ENDMETHOD.

  METHOD test_rtti_check_type_kind.

    DATA temp24 TYPE string.
    DATA lv_string LIKE temp24.
    DATA lr_string TYPE REF TO string.
    CLEAR temp24.
    
    lv_string = temp24.
    
    cl_abap_unit_assert=>assert_false( z2ui5_cl_util=>rtti_check_type_kind_dref( lv_string ) ).

    CREATE DATA lr_string.
    cl_abap_unit_assert=>assert_true( z2ui5_cl_util=>rtti_check_type_kind_dref( lr_string ) ).

  ENDMETHOD.

  METHOD test_rtti_get_t_attri_by_obj.

    DATA lo_obj TYPE REF TO ltcl_test_app.
    DATA lt_attri TYPE abap_attrdescr_tab.
    DATA temp25 LIKE sy-subrc.
    DATA temp26 LIKE sy-subrc.
    DATA temp27 LIKE sy-subrc.
    DATA temp28 LIKE sy-subrc.
    CREATE OBJECT lo_obj TYPE ltcl_test_app.
    
    lt_attri = z2ui5_cl_util=>rtti_get_t_attri_by_oref( lo_obj ).

    IF lines( lt_attri ) <> 7.
      cl_abap_unit_assert=>fail( ).
    ENDIF.

    
    READ TABLE lt_attri WITH KEY name = `MS_TAB` TRANSPORTING NO FIELDS.
    temp25 = sy-subrc.
    IF NOT temp25 = 0.
      cl_abap_unit_assert=>fail( ).
    ENDIF.

    
    READ TABLE lt_attri WITH KEY name = `SS_TAB` type_kind = `v` TRANSPORTING NO FIELDS.
    temp26 = sy-subrc.
    IF NOT temp26 = 0.
      cl_abap_unit_assert=>fail( ).
    ENDIF.

    
    READ TABLE lt_attri WITH KEY name = `SV_VAR` type_kind = `g` is_class = abap_true TRANSPORTING NO FIELDS.
    temp27 = sy-subrc.
    IF NOT temp27 = 0.
      cl_abap_unit_assert=>fail( ).
    ENDIF.

    
    READ TABLE lt_attri WITH KEY name = `SV_STATUS` type_kind = `g` is_class = abap_true is_constant = `X` TRANSPORTING NO FIELDS.
    temp28 = sy-subrc.
    IF NOT temp28 = 0.
      cl_abap_unit_assert=>fail( ).
    ENDIF.

  ENDMETHOD.

  METHOD test_rtti_get_t_comp_by_struc.

    TYPES:
      BEGIN OF ty_row,
        title    TYPE string,
        value    TYPE string,
        descr    TYPE string,
        icon     TYPE string,
        info     TYPE string,
        selected TYPE abap_bool,
        checkbox TYPE abap_bool,
      END OF ty_row.

    DATA temp29 TYPE ty_row.
    DATA ls_row LIKE temp29.
    DATA lt_comp TYPE abap_component_tab.
    DATA temp30 LIKE sy-subrc.
    DATA temp31 LIKE sy-subrc.
    DATA temp32 LIKE sy-subrc.
    DATA temp33 LIKE sy-subrc.
    DATA ls_title LIKE LINE OF lt_comp.
    DATA temp3 LIKE LINE OF lt_comp.
    DATA temp4 LIKE sy-tabix.
    CLEAR temp29.
    
    ls_row = temp29.

    
    lt_comp = z2ui5_cl_util=>rtti_get_t_attri_by_any( ls_row ).

    IF lines( lt_comp ) <> 7.
      cl_abap_unit_assert=>fail( ).
    ENDIF.

    
    READ TABLE lt_comp WITH KEY name = `TITLE` TRANSPORTING NO FIELDS.
    temp30 = sy-subrc.
    IF NOT temp30 = 0.
      cl_abap_unit_assert=>fail( ).
    ENDIF.

    
    READ TABLE lt_comp WITH KEY name = `VALUE` TRANSPORTING NO FIELDS.
    temp31 = sy-subrc.
    IF NOT temp31 = 0.
      cl_abap_unit_assert=>fail( ).
    ENDIF.

    
    READ TABLE lt_comp WITH KEY name = `SELECTED` TRANSPORTING NO FIELDS.
    temp32 = sy-subrc.
    IF NOT temp32 = 0.
      cl_abap_unit_assert=>fail( ).
    ENDIF.

    
    READ TABLE lt_comp WITH KEY name = `CHECKBOX` TRANSPORTING NO FIELDS.
    temp33 = sy-subrc.
    IF NOT temp33 = 0.
      cl_abap_unit_assert=>fail( ).
    ENDIF.

    
    
    
    temp4 = sy-tabix.
    READ TABLE lt_comp INDEX 1 INTO temp3.
    sy-tabix = temp4.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    ls_title = temp3.

    IF ls_title-type->type_kind <> `g`.
      cl_abap_unit_assert=>fail( ).
    ENDIF.

  ENDMETHOD.

  METHOD test_trans_xml_any_2__w_obj.

    DATA lo_obj TYPE REF TO ltcl_test_app.
    DATA lv_xml TYPE string.
    CREATE OBJECT lo_obj TYPE ltcl_test_app.
    
    lv_xml = z2ui5_cl_util=>xml_stringify( lo_obj ).

    IF lv_xml IS INITIAL.
      cl_abap_unit_assert=>fail( ).
    ENDIF.
  ENDMETHOD.

  METHOD test_trans_xml_2_any__w_obj.

    DATA lo_obj TYPE REF TO ltcl_test_app.
    DATA lv_xml TYPE string.
    CREATE OBJECT lo_obj TYPE ltcl_test_app.
    
    lv_xml = z2ui5_cl_util=>xml_stringify( lo_obj ).

    CLEAR lo_obj.
    z2ui5_cl_util=>xml_parse( EXPORTING xml = lv_xml
                              IMPORTING any = lo_obj ).

    IF lo_obj IS NOT BOUND.
      cl_abap_unit_assert=>fail( ).
    ENDIF.

  ENDMETHOD.

  METHOD test_trans_xml_any_2__w_data.

    TYPES:
      BEGIN OF ty_row,
        title    TYPE string,
        value    TYPE string,
        descr    TYPE string,
        icon     TYPE string,
        info     TYPE string,
        selected TYPE abap_bool,
        checkbox TYPE abap_bool,
      END OF ty_row.

    DATA temp34 TYPE ty_row.
    DATA ls_row LIKE temp34.
    DATA lv_xml TYPE string.
    CLEAR temp34.
    
    ls_row = temp34.
    ls_row-value = `test`.

    
    lv_xml = z2ui5_cl_util=>xml_stringify( ls_row ).

    IF lv_xml IS INITIAL.
      cl_abap_unit_assert=>fail( ).
    ENDIF.

  ENDMETHOD.

  METHOD test_trans_xml_2_any__w_data.

    TYPES:
      BEGIN OF ty_row,
        title    TYPE string,
        value    TYPE string,
        descr    TYPE string,
        icon     TYPE string,
        info     TYPE string,
        selected TYPE abap_bool,
        checkbox TYPE abap_bool,
      END OF ty_row.

    DATA temp35 TYPE ty_row.
    DATA ls_row LIKE temp35.
    DATA temp36 TYPE ty_row.
    DATA ls_row2 LIKE temp36.
    DATA lv_xml TYPE string.
    CLEAR temp35.
    
    ls_row = temp35.
    
    CLEAR temp36.
    
    ls_row2 = temp36.
    ls_row-value = `test`.

    
    lv_xml = z2ui5_cl_util=>xml_stringify( ls_row ).

    z2ui5_cl_util=>xml_parse( EXPORTING xml = lv_xml
                              IMPORTING any = ls_row2 ).

    cl_abap_unit_assert=>assert_equals( exp = ls_row2
                                        act = ls_row ).

  ENDMETHOD.

  METHOD test_c_trim_horizontal_tab.

    IF z2ui5_cl_util=>c_trim( |{ cl_abap_char_utilities=>horizontal_tab }|
                                && |JsadfHHs|
                                && |{ cl_abap_char_utilities=>horizontal_tab }| ) <> `JsadfHHs`.
      cl_abap_unit_assert=>fail( ).

    ENDIF.

  ENDMETHOD.

  METHOD test_get_token_t_by_r_t.

    DATA temp37 TYPE z2ui5_cl_util=>ty_t_range.
    DATA temp38 LIKE LINE OF temp37.
    DATA lt_range LIKE temp37.
    DATA lt_result TYPE z2ui5_cl_util=>ty_t_token.
    DATA temp39 TYPE z2ui5_cl_util=>ty_t_token.
    DATA temp40 LIKE LINE OF temp39.
    DATA lt_exp LIKE temp39.
    CLEAR temp37.
    
    temp38-sign = 'I'.
    temp38-option = 'EQ'.
    temp38-low = `table`.
    temp38-high = ``.
    INSERT temp38 INTO TABLE temp37.
    
    lt_range = temp37.

    
    lt_result = z2ui5_cl_util=>filter_get_token_t_by_range_t( lt_range ).

    
    CLEAR temp39.
    
    temp40-key = `=table`.
    temp40-text = `=table`.
    temp40-visible = 'X'.
    temp40-selkz = ''.
    temp40-editable = 'X'.
    INSERT temp40 INTO TABLE temp39.
    
    lt_exp = temp39.

    cl_abap_unit_assert=>assert_equals( exp = lt_exp
                                        act = lt_result
    ).

  ENDMETHOD.

  METHOD test_rtti_get_t_attri_by_incl.
TYPES BEGIN OF ty_struc_incl.
TYPES incl_title TYPE string.
TYPES incl_value TYPE string.
TYPES incl_value2 TYPE string.
TYPES END OF ty_struc_incl.
TYPES BEGIN OF ty_struc.
TYPES title TYPE string.
TYPES value TYPE string.
TYPES value2 TYPE string.
TYPES END OF ty_struc.
DATA BEGIN OF ms_struc2.INCLUDE TYPE ty_struc.INCLUDE TYPE ty_struc_incl.DATA END OF ms_struc2.
    DATA lo_datadescr TYPE REF TO cl_abap_typedescr.
    DATA temp41 TYPE REF TO cl_abap_datadescr.
    DATA lt_attri TYPE abap_component_tab.

    IF sy-sysid = 'ABC'.
      RETURN.
    ENDIF.

    

    

    

    
    lo_datadescr = cl_abap_typedescr=>describe_by_data( ms_struc2 ).

    IF z2ui5_cl_util=>context_check_abap_cloud( ) IS NOT INITIAL.
      RETURN.
    ENDIF.
    
    temp41 ?= lo_datadescr.
    
    lt_attri = z2ui5_cl_util=>rtti_get_t_attri_by_include( temp41 ).

    IF lines( lt_attri ) <> 6.
      cl_abap_unit_assert=>fail( ).
    ENDIF.

  ENDMETHOD.
ENDCLASS.
