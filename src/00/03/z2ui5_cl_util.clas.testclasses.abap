
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
    METHODS test_time_subtract_seconds    FOR TESTING RAISING cx_static_check.
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
    METHODS test_check_unassign_initial     FOR TESTING RAISING cx_static_check.
    METHODS conv_copy_ref_data             FOR TESTING RAISING cx_static_check.
    METHODS rtti_check_ref_data            FOR TESTING RAISING cx_static_check.
    METHODS test_check_bound_a_not_initial  FOR TESTING RAISING cx_static_check.
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
                                        act = substring_after( val = `this is a string`
                                                               sub = `a` ) ).

  ENDMETHOD.

  METHOD test_substring_before.

    cl_abap_unit_assert=>assert_equals( exp = `this is `
                                        act = substring_before( val = `this is a string`
                                                                sub = `a` ) ).

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
                               with = `ABC`
                               occ  = 0 ) ##NEEDED.

    cl_abap_unit_assert=>assert_equals( exp = `one ABC three`
                                        act = replace( val  = `one two three`
                                                       sub  = `two`
                                                       with = `ABC`
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

  METHOD test_check_bound_a_not_initial.

    DATA lv_test TYPE string.
    DATA lr_test LIKE REF TO lv_test.
    lv_test = `test`.

    GET REFERENCE OF lv_test INTO lr_test.

    cl_abap_unit_assert=>assert_true( z2ui5_cl_util=>check_bound_a_not_initial( lr_test ) ).
    CLEAR lv_test.
    cl_abap_unit_assert=>assert_false( z2ui5_cl_util=>check_bound_a_not_initial( lr_test ) ).
    CLEAR lr_test.
    cl_abap_unit_assert=>assert_false( z2ui5_cl_util=>check_bound_a_not_initial( lr_test ) ).

  ENDMETHOD.

  METHOD test_check_unassign_initial.

    DATA lv_test TYPE string.
    DATA lr_test LIKE REF TO lv_test.
    lv_test = `test`.

    GET REFERENCE OF lv_test INTO lr_test.

    cl_abap_unit_assert=>assert_false( z2ui5_cl_util=>check_unassign_initial( lr_test ) ).

    CLEAR lv_test.
    cl_abap_unit_assert=>assert_true( z2ui5_cl_util=>check_unassign_initial( lr_test ) ).

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


    lv_time2 = z2ui5_cl_util=>time_subtract_seconds( time    = lv_time
                                                            seconds = 60 * 60 * 4 ).

    IF lv_time IS INITIAL OR lv_time2 IS INITIAL.
      cl_abap_unit_assert=>fail( ).
    ENDIF.

    IF lv_time < lv_time2.
      cl_abap_unit_assert=>fail( ).
    ENDIF.

  ENDMETHOD.

  METHOD test_time_subtract_seconds.

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

  METHOD test_x_raise.

    TRY.
        z2ui5_cl_util=>x_raise( ).
        cl_abap_unit_assert=>fail( ).
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

  ENDMETHOD.

  METHOD test_x_check_raise.
        DATA temp7 TYPE xsdboolean.
        DATA temp8 TYPE xsdboolean.

    TRY.

        temp7 = boolc( 1 = 1 ).
        z2ui5_cl_util=>x_check_raise( temp7 ).
        cl_abap_unit_assert=>fail( ).
      CATCH cx_root ##NO_HANDLER.
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

    temp38-sign = `I`.
    temp38-option = `EQ`.
    temp38-low = `table`.
    temp38-high = ``.
    INSERT temp38 INTO TABLE temp37.

    lt_range = temp37.


    lt_result = z2ui5_cl_util=>filter_get_token_t_by_range_t( lt_range ).


    CLEAR temp39.

    temp40-key = `=table`.
    temp40-text = `=table`.
    temp40-visible = `X`.
    temp40-selkz = ``.
    temp40-editable = `X`.
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

    IF sy-sysid = `ABC`.
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


CLASS ltcl_unit_test_strings DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS test_c_contains_found       FOR TESTING RAISING cx_static_check.
    METHODS test_c_contains_not_found   FOR TESTING RAISING cx_static_check.
    METHODS test_c_starts_with_true     FOR TESTING RAISING cx_static_check.
    METHODS test_c_starts_with_false    FOR TESTING RAISING cx_static_check.
    METHODS test_c_starts_with_longer   FOR TESTING RAISING cx_static_check.
    METHODS test_c_ends_with_true       FOR TESTING RAISING cx_static_check.
    METHODS test_c_ends_with_false      FOR TESTING RAISING cx_static_check.
    METHODS test_c_ends_with_longer     FOR TESTING RAISING cx_static_check.
    METHODS test_c_split                FOR TESTING RAISING cx_static_check.
    METHODS test_c_split_single         FOR TESTING RAISING cx_static_check.
    METHODS test_c_join                 FOR TESTING RAISING cx_static_check.
    METHODS test_c_join_with_sep        FOR TESTING RAISING cx_static_check.
    METHODS test_c_join_empty           FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_unit_test_strings IMPLEMENTATION.

  METHOD test_c_contains_found.

    cl_abap_unit_assert=>assert_true(
      z2ui5_cl_util=>c_contains( val = `Hello World`
                                  sub = `World` ) ).

  ENDMETHOD.

  METHOD test_c_contains_not_found.

    cl_abap_unit_assert=>assert_false(
      z2ui5_cl_util=>c_contains( val = `Hello World`
                                  sub = `xyz` ) ).

  ENDMETHOD.

  METHOD test_c_starts_with_true.

    cl_abap_unit_assert=>assert_true(
      z2ui5_cl_util=>c_starts_with( val    = `Hello World`
                                     prefix = `Hello` ) ).

  ENDMETHOD.

  METHOD test_c_starts_with_false.

    cl_abap_unit_assert=>assert_false(
      z2ui5_cl_util=>c_starts_with( val    = `Hello World`
                                     prefix = `World` ) ).

  ENDMETHOD.

  METHOD test_c_starts_with_longer.

    cl_abap_unit_assert=>assert_false(
      z2ui5_cl_util=>c_starts_with( val    = `Hi`
                                     prefix = `Hello World` ) ).

  ENDMETHOD.

  METHOD test_c_ends_with_true.

    cl_abap_unit_assert=>assert_true(
      z2ui5_cl_util=>c_ends_with( val    = `Hello World`
                                   suffix = `World` ) ).

  ENDMETHOD.

  METHOD test_c_ends_with_false.

    cl_abap_unit_assert=>assert_false(
      z2ui5_cl_util=>c_ends_with( val    = `Hello World`
                                   suffix = `Hello` ) ).

  ENDMETHOD.

  METHOD test_c_ends_with_longer.

    cl_abap_unit_assert=>assert_false(
      z2ui5_cl_util=>c_ends_with( val    = `Hi`
                                   suffix = `Hello World` ) ).

  ENDMETHOD.

  METHOD test_c_split.

    DATA lt_result TYPE string_table.
    DATA temp42 LIKE LINE OF lt_result.
    DATA temp43 LIKE sy-tabix.
    DATA temp44 LIKE LINE OF lt_result.
    DATA temp45 LIKE sy-tabix.
    DATA temp46 LIKE LINE OF lt_result.
    DATA temp47 LIKE sy-tabix.
    lt_result = z2ui5_cl_util=>c_split( val = `one;two;three`
                                               sep = `;` ).

    cl_abap_unit_assert=>assert_equals( exp = 3
                                        act = lines( lt_result ) ).


    temp43 = sy-tabix.
    READ TABLE lt_result INDEX 1 INTO temp42.
    sy-tabix = temp43.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `one`   act = temp42 ).


    temp45 = sy-tabix.
    READ TABLE lt_result INDEX 2 INTO temp44.
    sy-tabix = temp45.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `two`   act = temp44 ).


    temp47 = sy-tabix.
    READ TABLE lt_result INDEX 3 INTO temp46.
    sy-tabix = temp47.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `three` act = temp46 ).

  ENDMETHOD.

  METHOD test_c_split_single.

    DATA lt_result TYPE string_table.
    DATA temp48 LIKE LINE OF lt_result.
    DATA temp49 LIKE sy-tabix.
    lt_result = z2ui5_cl_util=>c_split( val = `nosep`
                                               sep = `;` ).

    cl_abap_unit_assert=>assert_equals( exp = 1       act = lines( lt_result ) ).


    temp49 = sy-tabix.
    READ TABLE lt_result INDEX 1 INTO temp48.
    sy-tabix = temp49.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `nosep` act = temp48 ).

  ENDMETHOD.

  METHOD test_c_join.

    DATA temp50 TYPE string_table.
    DATA lt_tab LIKE temp50.
    DATA lv_result TYPE string.
    CLEAR temp50.
    INSERT `one` INTO TABLE temp50.
    INSERT `two` INTO TABLE temp50.
    INSERT `three` INTO TABLE temp50.

    lt_tab = temp50.

    lv_result = z2ui5_cl_util=>c_join( lt_tab ).

    cl_abap_unit_assert=>assert_equals( exp = `onetwothree`
                                        act = lv_result ).

  ENDMETHOD.

  METHOD test_c_join_with_sep.

    DATA temp52 TYPE string_table.
    DATA lt_tab LIKE temp52.
    DATA lv_result TYPE string.
    CLEAR temp52.
    INSERT `one` INTO TABLE temp52.
    INSERT `two` INTO TABLE temp52.
    INSERT `three` INTO TABLE temp52.

    lt_tab = temp52.

    lv_result = z2ui5_cl_util=>c_join( tab = lt_tab
                                              sep = `-` ).

    cl_abap_unit_assert=>assert_equals( exp = `one-two-three`
                                        act = lv_result ).

  ENDMETHOD.

  METHOD test_c_join_empty.

    DATA temp54 TYPE string_table.
    DATA lt_tab LIKE temp54.
    DATA lv_result TYPE string.
    CLEAR temp54.

    lt_tab = temp54.

    lv_result = z2ui5_cl_util=>c_join( lt_tab ).

    cl_abap_unit_assert=>assert_initial( lv_result ).

  ENDMETHOD.

ENDCLASS.


CLASS ltcl_unit_test_rtti DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS test_rtti_check_table_true    FOR TESTING RAISING cx_static_check.
    METHODS test_rtti_check_table_false   FOR TESTING RAISING cx_static_check.
    METHODS test_rtti_check_struc_true    FOR TESTING RAISING cx_static_check.
    METHODS test_rtti_check_struc_false   FOR TESTING RAISING cx_static_check.
    METHODS test_rtti_check_numeric_int   FOR TESTING RAISING cx_static_check.
    METHODS test_rtti_check_numeric_str   FOR TESTING RAISING cx_static_check.
    METHODS test_rtti_check_clike_str     FOR TESTING RAISING cx_static_check.
    METHODS test_rtti_check_clike_int     FOR TESTING RAISING cx_static_check.
    METHODS test_rtti_check_class_exists  FOR TESTING RAISING cx_static_check.
    METHODS test_rtti_check_class_no      FOR TESTING RAISING cx_static_check.
    METHODS test_rtti_tab_rel_name        FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_unit_test_rtti IMPLEMENTATION.

  METHOD test_rtti_check_table_true.

    DATA lt_tab TYPE string_table.
    cl_abap_unit_assert=>assert_true( z2ui5_cl_util=>rtti_check_table( lt_tab ) ).

  ENDMETHOD.

  METHOD test_rtti_check_table_false.

    DATA lv_string TYPE string.
    cl_abap_unit_assert=>assert_false( z2ui5_cl_util=>rtti_check_table( lv_string ) ).

  ENDMETHOD.

  METHOD test_rtti_check_struc_true.

    TYPES:
      BEGIN OF ty_s,
        a TYPE string,
        b TYPE i,
      END OF ty_s.

    DATA temp55 TYPE ty_s.
    DATA ls_struc LIKE temp55.
    CLEAR temp55.

    ls_struc = temp55.
    cl_abap_unit_assert=>assert_true( z2ui5_cl_util=>rtti_check_structure( ls_struc ) ).

  ENDMETHOD.

  METHOD test_rtti_check_struc_false.

    DATA lv_string TYPE string.
    cl_abap_unit_assert=>assert_false( z2ui5_cl_util=>rtti_check_structure( lv_string ) ).

  ENDMETHOD.

  METHOD test_rtti_check_numeric_int.

    DATA lv_int TYPE i.
    cl_abap_unit_assert=>assert_true( z2ui5_cl_util=>rtti_check_numeric( lv_int ) ).

  ENDMETHOD.

  METHOD test_rtti_check_numeric_str.

    DATA lv_string TYPE string.
    cl_abap_unit_assert=>assert_false( z2ui5_cl_util=>rtti_check_numeric( lv_string ) ).

  ENDMETHOD.

  METHOD test_rtti_check_clike_str.

    DATA lv_string TYPE string.
    cl_abap_unit_assert=>assert_true( z2ui5_cl_util=>rtti_check_clike( lv_string ) ).

  ENDMETHOD.

  METHOD test_rtti_check_clike_int.

    DATA lv_int TYPE i.
    cl_abap_unit_assert=>assert_false( z2ui5_cl_util=>rtti_check_clike( lv_int ) ).

  ENDMETHOD.

  METHOD test_rtti_check_class_exists.

    cl_abap_unit_assert=>assert_true(
      z2ui5_cl_util=>rtti_check_class_exists( `Z2UI5_CL_UTIL` ) ).

  ENDMETHOD.

  METHOD test_rtti_check_class_no.

    cl_abap_unit_assert=>assert_false(
      z2ui5_cl_util=>rtti_check_class_exists( `Z2UI5_CL_DOES_NOT_EXIST_XYZ` ) ).

  ENDMETHOD.

  METHOD test_rtti_tab_rel_name.

    TYPES:
      BEGIN OF ty_row,
        title TYPE string,
        value TYPE string,
      END OF ty_row.

    TYPES temp2 TYPE STANDARD TABLE OF ty_row WITH DEFAULT KEY.
DATA lt_tab TYPE temp2.

    DATA lv_name TYPE string.
    lv_name = z2ui5_cl_util=>rtti_tab_get_relative_name( lt_tab ).
    cl_abap_unit_assert=>assert_equals( exp = `TY_ROW`
                                        act = lv_name ).

  ENDMETHOD.

ENDCLASS.


CLASS ltcl_unit_test_boolean DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS test_bool_check_name_true    FOR TESTING RAISING cx_static_check.
    METHODS test_bool_check_name_false   FOR TESTING RAISING cx_static_check.
    METHODS test_bool_abap2json_true     FOR TESTING RAISING cx_static_check.
    METHODS test_bool_abap2json_false    FOR TESTING RAISING cx_static_check.
    METHODS test_bool_abap2json_nonbool  FOR TESTING RAISING cx_static_check.
    METHODS test_ui5_msg_type_error      FOR TESTING RAISING cx_static_check.
    METHODS test_ui5_msg_type_success    FOR TESTING RAISING cx_static_check.
    METHODS test_ui5_msg_type_warning    FOR TESTING RAISING cx_static_check.
    METHODS test_ui5_msg_type_info       FOR TESTING RAISING cx_static_check.
    METHODS test_ui5_msg_type_other      FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_unit_test_boolean IMPLEMENTATION.

  METHOD test_bool_check_name_true.

    cl_abap_unit_assert=>assert_true( z2ui5_cl_util=>boolean_check_by_name( `ABAP_BOOL` ) ).
    cl_abap_unit_assert=>assert_true( z2ui5_cl_util=>boolean_check_by_name( `XSDBOOLEAN` ) ).
    cl_abap_unit_assert=>assert_true( z2ui5_cl_util=>boolean_check_by_name( `FLAG` ) ).
    cl_abap_unit_assert=>assert_true( z2ui5_cl_util=>boolean_check_by_name( `XFLAG` ) ).
    cl_abap_unit_assert=>assert_true( z2ui5_cl_util=>boolean_check_by_name( `XFELD` ) ).
    cl_abap_unit_assert=>assert_true( z2ui5_cl_util=>boolean_check_by_name( `ABAP_BOOLEAN` ) ).
    cl_abap_unit_assert=>assert_true( z2ui5_cl_util=>boolean_check_by_name( `WDY_BOOLEAN` ) ).
    cl_abap_unit_assert=>assert_true( z2ui5_cl_util=>boolean_check_by_name( `BOOLE_D` ) ).
    cl_abap_unit_assert=>assert_true( z2ui5_cl_util=>boolean_check_by_name( `OS_BOOLEAN` ) ).

  ENDMETHOD.

  METHOD test_bool_check_name_false.

    cl_abap_unit_assert=>assert_false( z2ui5_cl_util=>boolean_check_by_name( `STRING` ) ).
    cl_abap_unit_assert=>assert_false( z2ui5_cl_util=>boolean_check_by_name( `INT4` ) ).
    cl_abap_unit_assert=>assert_false( z2ui5_cl_util=>boolean_check_by_name( `` ) ).

  ENDMETHOD.

  METHOD test_bool_abap2json_true.

    cl_abap_unit_assert=>assert_equals( exp = `true`
                                        act = z2ui5_cl_util=>boolean_abap_2_json( abap_true ) ).

  ENDMETHOD.

  METHOD test_bool_abap2json_false.

    cl_abap_unit_assert=>assert_equals( exp = `false`
                                        act = z2ui5_cl_util=>boolean_abap_2_json( abap_false ) ).

  ENDMETHOD.

  METHOD test_bool_abap2json_nonbool.

    cl_abap_unit_assert=>assert_equals( exp = `some_value`
                                        act = z2ui5_cl_util=>boolean_abap_2_json( `some_value` ) ).

  ENDMETHOD.

  METHOD test_ui5_msg_type_error.

    cl_abap_unit_assert=>assert_equals( exp = `Error`
                                        act = z2ui5_cl_util=>ui5_get_msg_type( `E` ) ).

  ENDMETHOD.

  METHOD test_ui5_msg_type_success.

    cl_abap_unit_assert=>assert_equals( exp = `Success`
                                        act = z2ui5_cl_util=>ui5_get_msg_type( `S` ) ).

  ENDMETHOD.

  METHOD test_ui5_msg_type_warning.

    cl_abap_unit_assert=>assert_equals( exp = `Warning`
                                        act = z2ui5_cl_util=>ui5_get_msg_type( `W` ) ).

  ENDMETHOD.

  METHOD test_ui5_msg_type_info.

    cl_abap_unit_assert=>assert_equals( exp = `Information`
                                        act = z2ui5_cl_util=>ui5_get_msg_type( `I` ) ).

  ENDMETHOD.

  METHOD test_ui5_msg_type_other.

    cl_abap_unit_assert=>assert_equals( exp = `Information`
                                        act = z2ui5_cl_util=>ui5_get_msg_type( `X` ) ).

  ENDMETHOD.

ENDCLASS.


CLASS ltcl_unit_test_filter DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS test_range_by_token_eq      FOR TESTING RAISING cx_static_check.
    METHODS test_range_by_token_lt      FOR TESTING RAISING cx_static_check.
    METHODS test_range_by_token_le      FOR TESTING RAISING cx_static_check.
    METHODS test_range_by_token_gt      FOR TESTING RAISING cx_static_check.
    METHODS test_range_by_token_ge      FOR TESTING RAISING cx_static_check.
    METHODS test_range_by_token_cp      FOR TESTING RAISING cx_static_check.
    METHODS test_range_by_token_bt      FOR TESTING RAISING cx_static_check.
    METHODS test_range_by_token_plain   FOR TESTING RAISING cx_static_check.
    METHODS test_token_range_mapping    FOR TESTING RAISING cx_static_check.
    METHODS test_range_t_by_token_t     FOR TESTING RAISING cx_static_check.
    METHODS test_filter_get_multi       FOR TESTING RAISING cx_static_check.
    METHODS test_filter_get_data        FOR TESTING RAISING cx_static_check.

    METHODS test_sql_where_eq           FOR TESTING RAISING cx_static_check.
    METHODS test_sql_where_ne           FOR TESTING RAISING cx_static_check.
    METHODS test_sql_where_lt           FOR TESTING RAISING cx_static_check.
    METHODS test_sql_where_le           FOR TESTING RAISING cx_static_check.
    METHODS test_sql_where_gt           FOR TESTING RAISING cx_static_check.
    METHODS test_sql_where_ge           FOR TESTING RAISING cx_static_check.
    METHODS test_sql_where_cp           FOR TESTING RAISING cx_static_check.
    METHODS test_sql_where_np           FOR TESTING RAISING cx_static_check.
    METHODS test_sql_where_bt           FOR TESTING RAISING cx_static_check.
    METHODS test_sql_where_nb           FOR TESTING RAISING cx_static_check.
    METHODS test_sql_where_excl_sign    FOR TESTING RAISING cx_static_check.
    METHODS test_sql_where_quote_esc    FOR TESTING RAISING cx_static_check.
    METHODS test_sql_where_or           FOR TESTING RAISING cx_static_check.
    METHODS test_sql_where_and          FOR TESTING RAISING cx_static_check.
    METHODS test_sql_where_empty        FOR TESTING RAISING cx_static_check.
    METHODS test_sql_where_skip_empty   FOR TESTING RAISING cx_static_check.

    METHODS test_multi_by_where_eq      FOR TESTING RAISING cx_static_check.
    METHODS test_multi_by_where_ops     FOR TESTING RAISING cx_static_check.
    METHODS test_multi_by_where_bt      FOR TESTING RAISING cx_static_check.
    METHODS test_multi_by_where_like    FOR TESTING RAISING cx_static_check.
    METHODS test_multi_by_where_combo   FOR TESTING RAISING cx_static_check.
    METHODS test_multi_by_where_empty   FOR TESTING RAISING cx_static_check.
    METHODS test_multi_by_where_quote   FOR TESTING RAISING cx_static_check.

    METHODS test_sql_roundtrip          FOR TESTING RAISING cx_static_check.
    METHODS test_sql_string_with_where  FOR TESTING RAISING cx_static_check.
    METHODS test_sql_string_tab_only    FOR TESTING RAISING cx_static_check.
    METHODS test_sql_string_no_fields   FOR TESTING RAISING cx_static_check.

    METHODS test_filter_itab            FOR TESTING RAISING cx_static_check.
    METHODS test_update_tokens          FOR TESTING RAISING cx_static_check.
    METHODS test_update_tokens_remove   FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_unit_test_filter IMPLEMENTATION.

  METHOD test_range_by_token_eq.

    DATA ls_range TYPE z2ui5_cl_util=>ty_s_range.
    ls_range = z2ui5_cl_util=>filter_get_range_by_token( `=ABC` ).

    cl_abap_unit_assert=>assert_equals( exp = `I`   act = ls_range-sign ).
    cl_abap_unit_assert=>assert_equals( exp = `EQ`  act = ls_range-option ).
    cl_abap_unit_assert=>assert_equals( exp = `ABC` act = ls_range-low ).

  ENDMETHOD.

  METHOD test_range_by_token_lt.

    DATA ls_range TYPE z2ui5_cl_util=>ty_s_range.
    ls_range = z2ui5_cl_util=>filter_get_range_by_token( `<100` ).

    cl_abap_unit_assert=>assert_equals( exp = `I`   act = ls_range-sign ).
    cl_abap_unit_assert=>assert_equals( exp = `LT`  act = ls_range-option ).
    cl_abap_unit_assert=>assert_equals( exp = `100` act = ls_range-low ).

  ENDMETHOD.

  METHOD test_range_by_token_le.

    DATA ls_range TYPE z2ui5_cl_util=>ty_s_range.
    ls_range = z2ui5_cl_util=>filter_get_range_by_token( `<=200` ).

    cl_abap_unit_assert=>assert_equals( exp = `I`   act = ls_range-sign ).
    cl_abap_unit_assert=>assert_equals( exp = `LE`  act = ls_range-option ).
    cl_abap_unit_assert=>assert_equals( exp = `200` act = ls_range-low ).

  ENDMETHOD.

  METHOD test_range_by_token_gt.

    DATA ls_range TYPE z2ui5_cl_util=>ty_s_range.
    ls_range = z2ui5_cl_util=>filter_get_range_by_token( `>50` ).

    cl_abap_unit_assert=>assert_equals( exp = `I`  act = ls_range-sign ).
    cl_abap_unit_assert=>assert_equals( exp = `GT` act = ls_range-option ).
    cl_abap_unit_assert=>assert_equals( exp = `50` act = ls_range-low ).

  ENDMETHOD.

  METHOD test_range_by_token_ge.

    DATA ls_range TYPE z2ui5_cl_util=>ty_s_range.
    ls_range = z2ui5_cl_util=>filter_get_range_by_token( `>=75` ).

    cl_abap_unit_assert=>assert_equals( exp = `I`  act = ls_range-sign ).
    cl_abap_unit_assert=>assert_equals( exp = `GE` act = ls_range-option ).
    cl_abap_unit_assert=>assert_equals( exp = `75` act = ls_range-low ).

  ENDMETHOD.

  METHOD test_range_by_token_cp.

    DATA ls_range TYPE z2ui5_cl_util=>ty_s_range.
    ls_range = z2ui5_cl_util=>filter_get_range_by_token( `*test*` ).

    cl_abap_unit_assert=>assert_equals( exp = `I`    act = ls_range-sign ).
    cl_abap_unit_assert=>assert_equals( exp = `CP`   act = ls_range-option ).
    cl_abap_unit_assert=>assert_equals( exp = `test` act = z2ui5_cl_util=>c_trim( ls_range-low ) ).

  ENDMETHOD.

  METHOD test_range_by_token_bt.

    DATA ls_range TYPE z2ui5_cl_util=>ty_s_range.
    ls_range = z2ui5_cl_util=>filter_get_range_by_token( `100...500` ).

    cl_abap_unit_assert=>assert_equals( exp = `I`   act = ls_range-sign ).
    cl_abap_unit_assert=>assert_equals( exp = `BT`  act = ls_range-option ).
    cl_abap_unit_assert=>assert_equals( exp = `100` act = ls_range-low ).
    cl_abap_unit_assert=>assert_equals( exp = `500` act = ls_range-high ).

  ENDMETHOD.

  METHOD test_range_by_token_plain.

    DATA ls_range TYPE z2ui5_cl_util=>ty_s_range.
    ls_range = z2ui5_cl_util=>filter_get_range_by_token( `hello` ).

    cl_abap_unit_assert=>assert_equals( exp = `I`     act = ls_range-sign ).
    cl_abap_unit_assert=>assert_equals( exp = `EQ`    act = ls_range-option ).
    cl_abap_unit_assert=>assert_equals( exp = `hello` act = ls_range-low ).

  ENDMETHOD.

  METHOD test_token_range_mapping.

    DATA lt_mapping TYPE z2ui5_cl_util=>ty_t_name_value.
    DATA temp56 LIKE LINE OF lt_mapping.
    DATA temp57 LIKE sy-tabix.
    DATA temp58 LIKE LINE OF lt_mapping.
    DATA temp59 LIKE sy-tabix.
    DATA temp60 LIKE LINE OF lt_mapping.
    DATA temp61 LIKE sy-tabix.
    lt_mapping = z2ui5_cl_util=>filter_get_token_range_mapping( ).

    cl_abap_unit_assert=>assert_not_initial( lt_mapping ).


    temp57 = sy-tabix.
    READ TABLE lt_mapping WITH KEY n = `EQ` INTO temp56.
    sy-tabix = temp57.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `={LOW}`
                                        act = temp56-v ).


    temp59 = sy-tabix.
    READ TABLE lt_mapping WITH KEY n = `LT` INTO temp58.
    sy-tabix = temp59.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `<{LOW}`
                                        act = temp58-v ).


    temp61 = sy-tabix.
    READ TABLE lt_mapping WITH KEY n = `GT` INTO temp60.
    sy-tabix = temp61.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `>{LOW}`
                                        act = temp60-v ).

  ENDMETHOD.

  METHOD test_range_t_by_token_t.

    DATA temp62 TYPE z2ui5_cl_util=>ty_t_token.
    DATA temp63 LIKE LINE OF temp62.
    DATA lt_tokens LIKE temp62.
    DATA lt_range TYPE z2ui5_cl_util=>ty_t_range.
    DATA temp64 LIKE LINE OF lt_range.
    DATA temp65 LIKE sy-tabix.
    DATA temp66 LIKE LINE OF lt_range.
    DATA temp67 LIKE sy-tabix.
    CLEAR temp62.

    temp63-key = `=100`.
    temp63-text = `=100`.
    temp63-visible = abap_true.
    temp63-editable = abap_true.
    INSERT temp63 INTO TABLE temp62.
    temp63-key = `>50`.
    temp63-text = `>50`.
    temp63-visible = abap_true.
    temp63-editable = abap_true.
    INSERT temp63 INTO TABLE temp62.

    lt_tokens = temp62.


    lt_range = z2ui5_cl_util=>filter_get_range_t_by_token_t( lt_tokens ).

    cl_abap_unit_assert=>assert_equals( exp = 2 act = lines( lt_range ) ).


    temp65 = sy-tabix.
    READ TABLE lt_range INDEX 1 INTO temp64.
    sy-tabix = temp65.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `EQ` act = temp64-option ).


    temp67 = sy-tabix.
    READ TABLE lt_range INDEX 2 INTO temp66.
    sy-tabix = temp67.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `GT` act = temp66-option ).

  ENDMETHOD.

  METHOD test_filter_get_multi.

    TYPES:
      BEGIN OF ty_row,
        name  TYPE string,
        value TYPE string,
      END OF ty_row.

    DATA temp68 TYPE ty_row.
    DATA ls_row LIKE temp68.
    DATA lt_filter TYPE z2ui5_cl_util=>ty_t_filter_multi.
    DATA temp69 LIKE LINE OF lt_filter.
    DATA temp70 LIKE sy-tabix.
    DATA temp71 LIKE LINE OF lt_filter.
    DATA temp72 LIKE sy-tabix.
    CLEAR temp68.

    ls_row = temp68.

    lt_filter = z2ui5_cl_util=>filter_get_multi_by_data( ls_row ).

    cl_abap_unit_assert=>assert_equals( exp = 2 act = lines( lt_filter ) ).


    temp70 = sy-tabix.
    READ TABLE lt_filter INDEX 1 INTO temp69.
    sy-tabix = temp70.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `NAME`  act = temp69-name ).


    temp72 = sy-tabix.
    READ TABLE lt_filter INDEX 2 INTO temp71.
    sy-tabix = temp72.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `VALUE` act = temp71-name ).

  ENDMETHOD.

  METHOD test_filter_get_data.

    DATA lt_filter TYPE z2ui5_cl_util=>ty_t_filter_multi.
    DATA ls_filter TYPE z2ui5_cl_util=>ty_s_filter_multi.
    DATA temp73 TYPE z2ui5_cl_util=>ty_t_range.
    DATA temp74 LIKE LINE OF temp73.
    DATA temp75 TYPE z2ui5_cl_util=>ty_t_token.
    DATA temp76 LIKE LINE OF temp75.
    DATA lt_result TYPE z2ui5_cl_util=>ty_t_filter_multi.

    ls_filter-name = `F1`.

    CLEAR temp73.

    temp74-sign = `I`.
    temp74-option = `EQ`.
    temp74-low = `A`.
    INSERT temp74 INTO TABLE temp73.
    ls_filter-t_range = temp73.
    INSERT ls_filter INTO TABLE lt_filter.

    CLEAR ls_filter.
    ls_filter-name = `F2`.
    INSERT ls_filter INTO TABLE lt_filter.

    CLEAR ls_filter.
    ls_filter-name = `F3`.

    CLEAR temp75.

    temp76-key = `=B`.
    temp76-text = `=B`.
    INSERT temp76 INTO TABLE temp75.
    ls_filter-t_token = temp75.
    INSERT ls_filter INTO TABLE lt_filter.


    lt_result = z2ui5_cl_util=>filter_get_data_by_multi( lt_filter ).

    cl_abap_unit_assert=>assert_equals( exp = 2 act = lines( lt_result ) ).

  ENDMETHOD.

  METHOD test_sql_where_eq.

    DATA temp77 TYPE z2ui5_cl_util=>ty_t_filter_multi.
    DATA temp78 LIKE LINE OF temp77.
    DATA temp5 TYPE z2ui5_cl_util=>ty_t_range.
    DATA temp6 LIKE LINE OF temp5.
    DATA lt_filter LIKE temp77.
    CLEAR temp77.

    temp78-name = `F1`.

    CLEAR temp5.

    temp6-sign = `I`.
    temp6-option = `EQ`.
    temp6-low = `A`.
    INSERT temp6 INTO TABLE temp5.
    temp78-t_range = temp5.
    INSERT temp78 INTO TABLE temp77.

    lt_filter = temp77.

    cl_abap_unit_assert=>assert_equals(
      exp = `( F1 = 'A' )`
      act = z2ui5_cl_util=>filter_get_sql_where( lt_filter ) ).

  ENDMETHOD.

  METHOD test_sql_where_ne.

    DATA temp79 TYPE z2ui5_cl_util=>ty_t_filter_multi.
    DATA temp80 LIKE LINE OF temp79.
    DATA temp7 TYPE z2ui5_cl_util=>ty_t_range.
    DATA temp8 LIKE LINE OF temp7.
    DATA lt_filter LIKE temp79.
    CLEAR temp79.

    temp80-name = `F1`.

    CLEAR temp7.

    temp8-sign = `I`.
    temp8-option = `NE`.
    temp8-low = `A`.
    INSERT temp8 INTO TABLE temp7.
    temp80-t_range = temp7.
    INSERT temp80 INTO TABLE temp79.

    lt_filter = temp79.

    cl_abap_unit_assert=>assert_equals(
      exp = `( F1 <> 'A' )`
      act = z2ui5_cl_util=>filter_get_sql_where( lt_filter ) ).

  ENDMETHOD.

  METHOD test_sql_where_lt.

    DATA temp81 TYPE z2ui5_cl_util=>ty_t_filter_multi.
    DATA temp82 LIKE LINE OF temp81.
    DATA temp9 TYPE z2ui5_cl_util=>ty_t_range.
    DATA temp10 LIKE LINE OF temp9.
    DATA lt_filter LIKE temp81.
    CLEAR temp81.

    temp82-name = `F1`.

    CLEAR temp9.

    temp10-sign = `I`.
    temp10-option = `LT`.
    temp10-low = `100`.
    INSERT temp10 INTO TABLE temp9.
    temp82-t_range = temp9.
    INSERT temp82 INTO TABLE temp81.

    lt_filter = temp81.

    cl_abap_unit_assert=>assert_equals(
      exp = `( F1 < '100' )`
      act = z2ui5_cl_util=>filter_get_sql_where( lt_filter ) ).

  ENDMETHOD.

  METHOD test_sql_where_le.

    DATA temp83 TYPE z2ui5_cl_util=>ty_t_filter_multi.
    DATA temp84 LIKE LINE OF temp83.
    DATA temp11 TYPE z2ui5_cl_util=>ty_t_range.
    DATA temp12 LIKE LINE OF temp11.
    DATA lt_filter LIKE temp83.
    CLEAR temp83.

    temp84-name = `F1`.

    CLEAR temp11.

    temp12-sign = `I`.
    temp12-option = `LE`.
    temp12-low = `100`.
    INSERT temp12 INTO TABLE temp11.
    temp84-t_range = temp11.
    INSERT temp84 INTO TABLE temp83.

    lt_filter = temp83.

    cl_abap_unit_assert=>assert_equals(
      exp = `( F1 <= '100' )`
      act = z2ui5_cl_util=>filter_get_sql_where( lt_filter ) ).

  ENDMETHOD.

  METHOD test_sql_where_gt.

    DATA temp85 TYPE z2ui5_cl_util=>ty_t_filter_multi.
    DATA temp86 LIKE LINE OF temp85.
    DATA temp13 TYPE z2ui5_cl_util=>ty_t_range.
    DATA temp14 LIKE LINE OF temp13.
    DATA lt_filter LIKE temp85.
    CLEAR temp85.

    temp86-name = `F1`.

    CLEAR temp13.

    temp14-sign = `I`.
    temp14-option = `GT`.
    temp14-low = `100`.
    INSERT temp14 INTO TABLE temp13.
    temp86-t_range = temp13.
    INSERT temp86 INTO TABLE temp85.

    lt_filter = temp85.

    cl_abap_unit_assert=>assert_equals(
      exp = `( F1 > '100' )`
      act = z2ui5_cl_util=>filter_get_sql_where( lt_filter ) ).

  ENDMETHOD.

  METHOD test_sql_where_ge.

    DATA temp87 TYPE z2ui5_cl_util=>ty_t_filter_multi.
    DATA temp88 LIKE LINE OF temp87.
    DATA temp15 TYPE z2ui5_cl_util=>ty_t_range.
    DATA temp16 LIKE LINE OF temp15.
    DATA lt_filter LIKE temp87.
    CLEAR temp87.

    temp88-name = `F1`.

    CLEAR temp15.

    temp16-sign = `I`.
    temp16-option = `GE`.
    temp16-low = `100`.
    INSERT temp16 INTO TABLE temp15.
    temp88-t_range = temp15.
    INSERT temp88 INTO TABLE temp87.

    lt_filter = temp87.

    cl_abap_unit_assert=>assert_equals(
      exp = `( F1 >= '100' )`
      act = z2ui5_cl_util=>filter_get_sql_where( lt_filter ) ).

  ENDMETHOD.

  METHOD test_sql_where_cp.

    DATA temp89 TYPE z2ui5_cl_util=>ty_t_filter_multi.
    DATA temp90 LIKE LINE OF temp89.
    DATA temp17 TYPE z2ui5_cl_util=>ty_t_range.
    DATA temp18 LIKE LINE OF temp17.
    DATA lt_filter LIKE temp89.
    CLEAR temp89.

    temp90-name = `F1`.

    CLEAR temp17.

    temp18-sign = `I`.
    temp18-option = `CP`.
    temp18-low = `te*st+`.
    INSERT temp18 INTO TABLE temp17.
    temp90-t_range = temp17.
    INSERT temp90 INTO TABLE temp89.

    lt_filter = temp89.

    cl_abap_unit_assert=>assert_equals(
      exp = `( F1 LIKE 'te%st_' )`
      act = z2ui5_cl_util=>filter_get_sql_where( lt_filter ) ).

  ENDMETHOD.

  METHOD test_sql_where_np.

    DATA temp91 TYPE z2ui5_cl_util=>ty_t_filter_multi.
    DATA temp92 LIKE LINE OF temp91.
    DATA temp19 TYPE z2ui5_cl_util=>ty_t_range.
    DATA temp20 LIKE LINE OF temp19.
    DATA lt_filter LIKE temp91.
    CLEAR temp91.

    temp92-name = `F1`.

    CLEAR temp19.

    temp20-sign = `I`.
    temp20-option = `NP`.
    temp20-low = `*x*`.
    INSERT temp20 INTO TABLE temp19.
    temp92-t_range = temp19.
    INSERT temp92 INTO TABLE temp91.

    lt_filter = temp91.

    cl_abap_unit_assert=>assert_equals(
      exp = `( F1 NOT LIKE '%x%' )`
      act = z2ui5_cl_util=>filter_get_sql_where( lt_filter ) ).

  ENDMETHOD.

  METHOD test_sql_where_bt.

    DATA temp93 TYPE z2ui5_cl_util=>ty_t_filter_multi.
    DATA temp94 LIKE LINE OF temp93.
    DATA temp21 TYPE z2ui5_cl_util=>ty_t_range.
    DATA temp22 LIKE LINE OF temp21.
    DATA lt_filter LIKE temp93.
    CLEAR temp93.

    temp94-name = `F1`.

    CLEAR temp21.

    temp22-sign = `I`.
    temp22-option = `BT`.
    temp22-low = `100`.
    temp22-high = `500`.
    INSERT temp22 INTO TABLE temp21.
    temp94-t_range = temp21.
    INSERT temp94 INTO TABLE temp93.

    lt_filter = temp93.

    cl_abap_unit_assert=>assert_equals(
      exp = `( F1 BETWEEN '100' AND '500' )`
      act = z2ui5_cl_util=>filter_get_sql_where( lt_filter ) ).

  ENDMETHOD.

  METHOD test_sql_where_nb.

    DATA temp95 TYPE z2ui5_cl_util=>ty_t_filter_multi.
    DATA temp96 LIKE LINE OF temp95.
    DATA temp23 TYPE z2ui5_cl_util=>ty_t_range.
    DATA temp24 LIKE LINE OF temp23.
    DATA lt_filter LIKE temp95.
    CLEAR temp95.

    temp96-name = `F1`.

    CLEAR temp23.

    temp24-sign = `I`.
    temp24-option = `NB`.
    temp24-low = `100`.
    temp24-high = `500`.
    INSERT temp24 INTO TABLE temp23.
    temp96-t_range = temp23.
    INSERT temp96 INTO TABLE temp95.

    lt_filter = temp95.

    cl_abap_unit_assert=>assert_equals(
      exp = `( F1 NOT BETWEEN '100' AND '500' )`
      act = z2ui5_cl_util=>filter_get_sql_where( lt_filter ) ).

  ENDMETHOD.

  METHOD test_sql_where_excl_sign.

    DATA temp97 TYPE z2ui5_cl_util=>ty_t_filter_multi.
    DATA temp98 LIKE LINE OF temp97.
    DATA temp25 TYPE z2ui5_cl_util=>ty_t_range.
    DATA temp26 LIKE LINE OF temp25.
    DATA lt_filter LIKE temp97.
    CLEAR temp97.

    temp98-name = `F1`.

    CLEAR temp25.

    temp26-sign = `E`.
    temp26-option = `EQ`.
    temp26-low = `A`.
    INSERT temp26 INTO TABLE temp25.
    temp98-t_range = temp25.
    INSERT temp98 INTO TABLE temp97.

    lt_filter = temp97.

    cl_abap_unit_assert=>assert_equals(
      exp = `( F1 <> 'A' )`
      act = z2ui5_cl_util=>filter_get_sql_where( lt_filter ) ).

  ENDMETHOD.

  METHOD test_sql_where_quote_esc.

    DATA temp99 TYPE z2ui5_cl_util=>ty_t_filter_multi.
    DATA temp100 LIKE LINE OF temp99.
    DATA temp27 TYPE z2ui5_cl_util=>ty_t_range.
    DATA temp28 LIKE LINE OF temp27.
    DATA lt_filter LIKE temp99.
    CLEAR temp99.

    temp100-name = `NAME`.

    CLEAR temp27.

    temp28-sign = `I`.
    temp28-option = `EQ`.
    temp28-low = `O'Brien`.
    INSERT temp28 INTO TABLE temp27.
    temp100-t_range = temp27.
    INSERT temp100 INTO TABLE temp99.

    lt_filter = temp99.

    cl_abap_unit_assert=>assert_equals(
      exp = `( NAME = 'O''Brien' )`
      act = z2ui5_cl_util=>filter_get_sql_where( lt_filter ) ).

  ENDMETHOD.

  METHOD test_sql_where_or.

    DATA temp101 TYPE z2ui5_cl_util=>ty_t_filter_multi.
    DATA temp102 LIKE LINE OF temp101.
    DATA temp29 TYPE z2ui5_cl_util=>ty_t_range.
    DATA temp30 LIKE LINE OF temp29.
    DATA lt_filter LIKE temp101.
    CLEAR temp101.

    temp102-name = `F1`.

    CLEAR temp29.

    temp30-sign = `I`.
    temp30-option = `EQ`.
    temp30-low = `A`.
    INSERT temp30 INTO TABLE temp29.
    temp30-sign = `I`.
    temp30-option = `EQ`.
    temp30-low = `B`.
    INSERT temp30 INTO TABLE temp29.
    temp102-t_range = temp29.
    INSERT temp102 INTO TABLE temp101.

    lt_filter = temp101.

    cl_abap_unit_assert=>assert_equals(
      exp = `( F1 = 'A' OR F1 = 'B' )`
      act = z2ui5_cl_util=>filter_get_sql_where( lt_filter ) ).

  ENDMETHOD.

  METHOD test_sql_where_and.

    DATA temp103 TYPE z2ui5_cl_util=>ty_t_filter_multi.
    DATA temp104 LIKE LINE OF temp103.
    DATA temp31 TYPE z2ui5_cl_util=>ty_t_range.
    DATA temp32 LIKE LINE OF temp31.
    DATA temp33 TYPE z2ui5_cl_util=>ty_t_range.
    DATA temp34 LIKE LINE OF temp33.
    DATA lt_filter LIKE temp103.
    CLEAR temp103.

    temp104-name = `F1`.

    CLEAR temp31.

    temp32-sign = `I`.
    temp32-option = `EQ`.
    temp32-low = `A`.
    INSERT temp32 INTO TABLE temp31.
    temp104-t_range = temp31.
    INSERT temp104 INTO TABLE temp103.
    temp104-name = `F2`.

    CLEAR temp33.

    temp34-sign = `I`.
    temp34-option = `EQ`.
    temp34-low = `B`.
    INSERT temp34 INTO TABLE temp33.
    temp104-t_range = temp33.
    INSERT temp104 INTO TABLE temp103.

    lt_filter = temp103.

    cl_abap_unit_assert=>assert_equals(
      exp = `( F1 = 'A' ) AND ( F2 = 'B' )`
      act = z2ui5_cl_util=>filter_get_sql_where( lt_filter ) ).

  ENDMETHOD.

  METHOD test_sql_where_empty.

    DATA lt_filter TYPE z2ui5_cl_util=>ty_t_filter_multi.

    cl_abap_unit_assert=>assert_initial(
      z2ui5_cl_util=>filter_get_sql_where( lt_filter ) ).

  ENDMETHOD.

  METHOD test_sql_where_skip_empty.

    DATA temp105 TYPE z2ui5_cl_util=>ty_t_filter_multi.
    DATA temp106 LIKE LINE OF temp105.
    DATA temp35 TYPE z2ui5_cl_util=>ty_t_range.
    DATA temp36 LIKE LINE OF temp35.
    DATA lt_filter LIKE temp105.
    CLEAR temp105.

    temp106-name = `F1`.
    INSERT temp106 INTO TABLE temp105.
    temp106-name = `F2`.

    CLEAR temp35.

    temp36-sign = `I`.
    temp36-option = `EQ`.
    temp36-low = `B`.
    INSERT temp36 INTO TABLE temp35.
    temp106-t_range = temp35.
    INSERT temp106 INTO TABLE temp105.

    lt_filter = temp105.

    cl_abap_unit_assert=>assert_equals(
      exp = `( F2 = 'B' )`
      act = z2ui5_cl_util=>filter_get_sql_where( lt_filter ) ).

  ENDMETHOD.

  METHOD test_multi_by_where_eq.

    DATA lt_filter TYPE z2ui5_cl_util=>ty_t_filter_multi.
    DATA temp107 LIKE LINE OF lt_filter.
    DATA temp108 LIKE sy-tabix.
    DATA temp109 LIKE LINE OF lt_filter.
    DATA temp110 LIKE sy-tabix.
    DATA temp111 LIKE LINE OF lt_filter.
    DATA temp112 LIKE sy-tabix.
    DATA temp37 LIKE LINE OF temp111-t_range.
    DATA temp38 LIKE sy-tabix.
    DATA temp113 LIKE LINE OF lt_filter.
    DATA temp114 LIKE sy-tabix.
    DATA temp39 LIKE LINE OF temp113-t_range.
    DATA temp40 LIKE sy-tabix.
    DATA temp115 LIKE LINE OF lt_filter.
    DATA temp116 LIKE sy-tabix.
    DATA temp41 LIKE LINE OF temp115-t_range.
    DATA temp42 LIKE sy-tabix.
    lt_filter = z2ui5_cl_util=>filter_get_multi_by_sql_where(
                        `( F1 = 'A' )` ).

    cl_abap_unit_assert=>assert_equals( exp = 1 act = lines( lt_filter ) ).


    temp108 = sy-tabix.
    READ TABLE lt_filter INDEX 1 INTO temp107.
    sy-tabix = temp108.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `F1` act = temp107-name ).


    temp110 = sy-tabix.
    READ TABLE lt_filter INDEX 1 INTO temp109.
    sy-tabix = temp110.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = 1 act = lines( temp109-t_range ) ).


    temp112 = sy-tabix.
    READ TABLE lt_filter INDEX 1 INTO temp111.
    sy-tabix = temp112.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.


    temp38 = sy-tabix.
    READ TABLE temp111-t_range INDEX 1 INTO temp37.
    sy-tabix = temp38.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `EQ` act = temp37-option ).


    temp114 = sy-tabix.
    READ TABLE lt_filter INDEX 1 INTO temp113.
    sy-tabix = temp114.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.


    temp40 = sy-tabix.
    READ TABLE temp113-t_range INDEX 1 INTO temp39.
    sy-tabix = temp40.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `A`  act = temp39-low ).


    temp116 = sy-tabix.
    READ TABLE lt_filter INDEX 1 INTO temp115.
    sy-tabix = temp116.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.


    temp42 = sy-tabix.
    READ TABLE temp115-t_range INDEX 1 INTO temp41.
    sy-tabix = temp42.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `I`  act = temp41-sign ).

  ENDMETHOD.

  METHOD test_multi_by_where_ops.

    DATA lt_filter TYPE z2ui5_cl_util=>ty_t_filter_multi.
    DATA temp117 LIKE LINE OF lt_filter.
    DATA temp118 LIKE sy-tabix.
    DATA temp119 LIKE LINE OF lt_filter.
    DATA temp120 LIKE sy-tabix.
    DATA temp43 LIKE LINE OF temp119-t_range.
    DATA temp44 LIKE sy-tabix.
    DATA temp121 LIKE LINE OF lt_filter.
    DATA temp122 LIKE sy-tabix.
    DATA temp45 LIKE LINE OF temp121-t_range.
    DATA temp46 LIKE sy-tabix.
    DATA temp123 LIKE LINE OF lt_filter.
    DATA temp124 LIKE sy-tabix.
    DATA temp47 LIKE LINE OF temp123-t_range.
    DATA temp48 LIKE sy-tabix.
    DATA temp125 LIKE LINE OF lt_filter.
    DATA temp126 LIKE sy-tabix.
    DATA temp49 LIKE LINE OF temp125-t_range.
    DATA temp50 LIKE sy-tabix.
    DATA temp127 LIKE LINE OF lt_filter.
    DATA temp128 LIKE sy-tabix.
    DATA temp51 LIKE LINE OF temp127-t_range.
    DATA temp52 LIKE sy-tabix.
    lt_filter = z2ui5_cl_util=>filter_get_multi_by_sql_where(
                        `( F1 <> 'A' OR F1 < 'B' OR F1 <= 'C' OR F1 > 'D' OR F1 >= 'E' )` ).

    cl_abap_unit_assert=>assert_equals( exp = 1 act = lines( lt_filter ) ).


    temp118 = sy-tabix.
    READ TABLE lt_filter INDEX 1 INTO temp117.
    sy-tabix = temp118.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = 5 act = lines( temp117-t_range ) ).


    temp120 = sy-tabix.
    READ TABLE lt_filter INDEX 1 INTO temp119.
    sy-tabix = temp120.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.


    temp44 = sy-tabix.
    READ TABLE temp119-t_range INDEX 1 INTO temp43.
    sy-tabix = temp44.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `NE` act = temp43-option ).


    temp122 = sy-tabix.
    READ TABLE lt_filter INDEX 1 INTO temp121.
    sy-tabix = temp122.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.


    temp46 = sy-tabix.
    READ TABLE temp121-t_range INDEX 2 INTO temp45.
    sy-tabix = temp46.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `LT` act = temp45-option ).


    temp124 = sy-tabix.
    READ TABLE lt_filter INDEX 1 INTO temp123.
    sy-tabix = temp124.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.


    temp48 = sy-tabix.
    READ TABLE temp123-t_range INDEX 3 INTO temp47.
    sy-tabix = temp48.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `LE` act = temp47-option ).


    temp126 = sy-tabix.
    READ TABLE lt_filter INDEX 1 INTO temp125.
    sy-tabix = temp126.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.


    temp50 = sy-tabix.
    READ TABLE temp125-t_range INDEX 4 INTO temp49.
    sy-tabix = temp50.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `GT` act = temp49-option ).


    temp128 = sy-tabix.
    READ TABLE lt_filter INDEX 1 INTO temp127.
    sy-tabix = temp128.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.


    temp52 = sy-tabix.
    READ TABLE temp127-t_range INDEX 5 INTO temp51.
    sy-tabix = temp52.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `GE` act = temp51-option ).

  ENDMETHOD.

  METHOD test_multi_by_where_bt.

    DATA lt_filter TYPE z2ui5_cl_util=>ty_t_filter_multi.
    DATA temp129 LIKE LINE OF lt_filter.
    DATA temp130 LIKE sy-tabix.
    DATA temp131 LIKE LINE OF lt_filter.
    DATA temp132 LIKE sy-tabix.
    DATA temp53 LIKE LINE OF temp131-t_range.
    DATA temp54 LIKE sy-tabix.
    DATA temp133 LIKE LINE OF lt_filter.
    DATA temp134 LIKE sy-tabix.
    DATA temp55 LIKE LINE OF temp133-t_range.
    DATA temp56 LIKE sy-tabix.
    DATA temp135 LIKE LINE OF lt_filter.
    DATA temp136 LIKE sy-tabix.
    DATA temp57 LIKE LINE OF temp135-t_range.
    DATA temp58 LIKE sy-tabix.
    DATA temp137 LIKE LINE OF lt_filter.
    DATA temp138 LIKE sy-tabix.
    DATA temp59 LIKE LINE OF temp137-t_range.
    DATA temp60 LIKE sy-tabix.
    DATA temp139 LIKE LINE OF lt_filter.
    DATA temp140 LIKE sy-tabix.
    DATA temp61 LIKE LINE OF temp139-t_range.
    DATA temp62 LIKE sy-tabix.
    DATA temp141 LIKE LINE OF lt_filter.
    DATA temp142 LIKE sy-tabix.
    DATA temp63 LIKE LINE OF temp141-t_range.
    DATA temp64 LIKE sy-tabix.
    lt_filter = z2ui5_cl_util=>filter_get_multi_by_sql_where(
                        `( F1 BETWEEN '100' AND '500' OR F1 NOT BETWEEN '700' AND '900' )` ).

    cl_abap_unit_assert=>assert_equals( exp = 1 act = lines( lt_filter ) ).


    temp130 = sy-tabix.
    READ TABLE lt_filter INDEX 1 INTO temp129.
    sy-tabix = temp130.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = 2 act = lines( temp129-t_range ) ).


    temp132 = sy-tabix.
    READ TABLE lt_filter INDEX 1 INTO temp131.
    sy-tabix = temp132.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.


    temp54 = sy-tabix.
    READ TABLE temp131-t_range INDEX 1 INTO temp53.
    sy-tabix = temp54.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `BT`  act = temp53-option ).


    temp134 = sy-tabix.
    READ TABLE lt_filter INDEX 1 INTO temp133.
    sy-tabix = temp134.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.


    temp56 = sy-tabix.
    READ TABLE temp133-t_range INDEX 1 INTO temp55.
    sy-tabix = temp56.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `100` act = temp55-low ).


    temp136 = sy-tabix.
    READ TABLE lt_filter INDEX 1 INTO temp135.
    sy-tabix = temp136.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.


    temp58 = sy-tabix.
    READ TABLE temp135-t_range INDEX 1 INTO temp57.
    sy-tabix = temp58.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `500` act = temp57-high ).


    temp138 = sy-tabix.
    READ TABLE lt_filter INDEX 1 INTO temp137.
    sy-tabix = temp138.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.


    temp60 = sy-tabix.
    READ TABLE temp137-t_range INDEX 2 INTO temp59.
    sy-tabix = temp60.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `NB`  act = temp59-option ).


    temp140 = sy-tabix.
    READ TABLE lt_filter INDEX 1 INTO temp139.
    sy-tabix = temp140.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.


    temp62 = sy-tabix.
    READ TABLE temp139-t_range INDEX 2 INTO temp61.
    sy-tabix = temp62.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `700` act = temp61-low ).


    temp142 = sy-tabix.
    READ TABLE lt_filter INDEX 1 INTO temp141.
    sy-tabix = temp142.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.


    temp64 = sy-tabix.
    READ TABLE temp141-t_range INDEX 2 INTO temp63.
    sy-tabix = temp64.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `900` act = temp63-high ).

  ENDMETHOD.

  METHOD test_multi_by_where_like.

    DATA lt_filter TYPE z2ui5_cl_util=>ty_t_filter_multi.
    DATA temp143 LIKE LINE OF lt_filter.
    DATA temp144 LIKE sy-tabix.
    DATA temp145 LIKE LINE OF lt_filter.
    DATA temp146 LIKE sy-tabix.
    DATA temp65 LIKE LINE OF temp145-t_range.
    DATA temp66 LIKE sy-tabix.
    DATA temp147 LIKE LINE OF lt_filter.
    DATA temp148 LIKE sy-tabix.
    DATA temp67 LIKE LINE OF temp147-t_range.
    DATA temp68 LIKE sy-tabix.
    DATA temp149 LIKE LINE OF lt_filter.
    DATA temp150 LIKE sy-tabix.
    DATA temp69 LIKE LINE OF temp149-t_range.
    DATA temp70 LIKE sy-tabix.
    DATA temp151 LIKE LINE OF lt_filter.
    DATA temp152 LIKE sy-tabix.
    DATA temp71 LIKE LINE OF temp151-t_range.
    DATA temp72 LIKE sy-tabix.
    lt_filter = z2ui5_cl_util=>filter_get_multi_by_sql_where(
                        `( F1 LIKE 'te%st_' OR F1 NOT LIKE '%bad%' )` ).

    cl_abap_unit_assert=>assert_equals( exp = 1 act = lines( lt_filter ) ).


    temp144 = sy-tabix.
    READ TABLE lt_filter INDEX 1 INTO temp143.
    sy-tabix = temp144.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = 2 act = lines( temp143-t_range ) ).


    temp146 = sy-tabix.
    READ TABLE lt_filter INDEX 1 INTO temp145.
    sy-tabix = temp146.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.


    temp66 = sy-tabix.
    READ TABLE temp145-t_range INDEX 1 INTO temp65.
    sy-tabix = temp66.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `CP`     act = temp65-option ).


    temp148 = sy-tabix.
    READ TABLE lt_filter INDEX 1 INTO temp147.
    sy-tabix = temp148.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.


    temp68 = sy-tabix.
    READ TABLE temp147-t_range INDEX 1 INTO temp67.
    sy-tabix = temp68.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `te*st+` act = temp67-low ).


    temp150 = sy-tabix.
    READ TABLE lt_filter INDEX 1 INTO temp149.
    sy-tabix = temp150.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.


    temp70 = sy-tabix.
    READ TABLE temp149-t_range INDEX 2 INTO temp69.
    sy-tabix = temp70.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `NP`     act = temp69-option ).


    temp152 = sy-tabix.
    READ TABLE lt_filter INDEX 1 INTO temp151.
    sy-tabix = temp152.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.


    temp72 = sy-tabix.
    READ TABLE temp151-t_range INDEX 2 INTO temp71.
    sy-tabix = temp72.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `*bad*`  act = temp71-low ).

  ENDMETHOD.

  METHOD test_multi_by_where_combo.

    DATA lt_filter TYPE z2ui5_cl_util=>ty_t_filter_multi.
    DATA temp153 LIKE LINE OF lt_filter.
    DATA temp154 LIKE sy-tabix.
    DATA temp155 LIKE LINE OF lt_filter.
    DATA temp156 LIKE sy-tabix.
    DATA temp157 LIKE LINE OF lt_filter.
    DATA temp158 LIKE sy-tabix.
    DATA temp159 LIKE LINE OF lt_filter.
    DATA temp160 LIKE sy-tabix.
    lt_filter = z2ui5_cl_util=>filter_get_multi_by_sql_where(
                        `( F1 = 'A' OR F1 = 'B' ) AND ( F2 = 'X' )` ).

    cl_abap_unit_assert=>assert_equals( exp = 2 act = lines( lt_filter ) ).


    temp154 = sy-tabix.
    READ TABLE lt_filter INDEX 1 INTO temp153.
    sy-tabix = temp154.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `F1` act = temp153-name ).


    temp156 = sy-tabix.
    READ TABLE lt_filter INDEX 1 INTO temp155.
    sy-tabix = temp156.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = 2 act = lines( temp155-t_range ) ).


    temp158 = sy-tabix.
    READ TABLE lt_filter INDEX 2 INTO temp157.
    sy-tabix = temp158.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `F2` act = temp157-name ).


    temp160 = sy-tabix.
    READ TABLE lt_filter INDEX 2 INTO temp159.
    sy-tabix = temp160.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = 1 act = lines( temp159-t_range ) ).

  ENDMETHOD.

  METHOD test_multi_by_where_empty.

    DATA lt_filter TYPE z2ui5_cl_util=>ty_t_filter_multi.
    lt_filter = z2ui5_cl_util=>filter_get_multi_by_sql_where( `` ).
    cl_abap_unit_assert=>assert_initial( lt_filter ).

  ENDMETHOD.

  METHOD test_multi_by_where_quote.

    DATA lt_filter TYPE z2ui5_cl_util=>ty_t_filter_multi.
    DATA temp161 LIKE LINE OF lt_filter.
    DATA temp162 LIKE sy-tabix.
    DATA temp73 LIKE LINE OF temp161-t_range.
    DATA temp74 LIKE sy-tabix.
    lt_filter = z2ui5_cl_util=>filter_get_multi_by_sql_where(
                        `( NAME = 'O''Brien' )` ).

    cl_abap_unit_assert=>assert_equals( exp = 1 act = lines( lt_filter ) ).


    temp162 = sy-tabix.
    READ TABLE lt_filter INDEX 1 INTO temp161.
    sy-tabix = temp162.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.


    temp74 = sy-tabix.
    READ TABLE temp161-t_range INDEX 1 INTO temp73.
    sy-tabix = temp74.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `O'Brien`
                                        act = temp73-low ).

  ENDMETHOD.

  METHOD test_sql_roundtrip.

    DATA temp163 TYPE z2ui5_cl_util=>ty_t_filter_multi.
    DATA temp164 LIKE LINE OF temp163.
    DATA temp75 TYPE z2ui5_cl_util=>ty_t_range.
    DATA temp76 LIKE LINE OF temp75.
    DATA temp77 TYPE z2ui5_cl_util=>ty_t_range.
    DATA temp78 LIKE LINE OF temp77.
    DATA lt_filter LIKE temp163.
    DATA lv_where TYPE string.
    DATA lt_parsed TYPE z2ui5_cl_util=>ty_t_filter_multi.
    DATA temp165 LIKE LINE OF lt_filter.
    DATA temp166 LIKE sy-tabix.
    DATA temp79 LIKE LINE OF lt_parsed.
    DATA temp80 LIKE sy-tabix.
    DATA temp167 LIKE LINE OF lt_filter.
    DATA temp168 LIKE sy-tabix.
    DATA temp81 LIKE LINE OF lt_parsed.
    DATA temp82 LIKE sy-tabix.
    DATA temp169 LIKE LINE OF lt_filter.
    DATA temp170 LIKE sy-tabix.
    DATA temp83 LIKE LINE OF lt_parsed.
    DATA temp84 LIKE sy-tabix.
    DATA temp171 LIKE LINE OF lt_filter.
    DATA temp172 LIKE sy-tabix.
    DATA temp85 LIKE LINE OF lt_parsed.
    DATA temp86 LIKE sy-tabix.
    CLEAR temp163.

    temp164-name = `CARRID`.

    CLEAR temp75.

    temp76-sign = `I`.
    temp76-option = `EQ`.
    temp76-low = `LH`.
    INSERT temp76 INTO TABLE temp75.
    temp76-sign = `I`.
    temp76-option = `EQ`.
    temp76-low = `AA`.
    INSERT temp76 INTO TABLE temp75.
    temp164-t_range = temp75.
    INSERT temp164 INTO TABLE temp163.
    temp164-name = `CONNID`.

    CLEAR temp77.

    temp78-sign = `I`.
    temp78-option = `BT`.
    temp78-low = `100`.
    temp78-high = `500`.
    INSERT temp78 INTO TABLE temp77.
    temp164-t_range = temp77.
    INSERT temp164 INTO TABLE temp163.

    lt_filter = temp163.


    lv_where = z2ui5_cl_util=>filter_get_sql_where( lt_filter ).

    lt_parsed = z2ui5_cl_util=>filter_get_multi_by_sql_where( lv_where ).

    cl_abap_unit_assert=>assert_equals( exp = 2 act = lines( lt_parsed ) ).


    temp166 = sy-tabix.
    READ TABLE lt_filter INDEX 1 INTO temp165.
    sy-tabix = temp166.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.


    temp80 = sy-tabix.
    READ TABLE lt_parsed INDEX 1 INTO temp79.
    sy-tabix = temp80.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = temp165-name act = temp79-name ).


    temp168 = sy-tabix.
    READ TABLE lt_filter INDEX 1 INTO temp167.
    sy-tabix = temp168.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.


    temp82 = sy-tabix.
    READ TABLE lt_parsed INDEX 1 INTO temp81.
    sy-tabix = temp82.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = temp167-t_range act = temp81-t_range ).


    temp170 = sy-tabix.
    READ TABLE lt_filter INDEX 2 INTO temp169.
    sy-tabix = temp170.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.


    temp84 = sy-tabix.
    READ TABLE lt_parsed INDEX 2 INTO temp83.
    sy-tabix = temp84.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = temp169-name act = temp83-name ).


    temp172 = sy-tabix.
    READ TABLE lt_filter INDEX 2 INTO temp171.
    sy-tabix = temp172.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.


    temp86 = sy-tabix.
    READ TABLE lt_parsed INDEX 2 INTO temp85.
    sy-tabix = temp86.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = temp171-t_range act = temp85-t_range ).

  ENDMETHOD.

  METHOD test_sql_string_with_where.

    DATA ls_sql TYPE z2ui5_cl_util=>ty_s_sql.
    DATA temp173 LIKE LINE OF ls_sql-t_filter.
    DATA temp174 LIKE sy-tabix.
    DATA temp175 LIKE LINE OF ls_sql-t_filter.
    DATA temp176 LIKE sy-tabix.
    DATA temp87 LIKE LINE OF temp175-t_range.
    DATA temp88 LIKE sy-tabix.
    ls_sql = z2ui5_cl_util=>filter_get_sql_by_sql_string(
                     `SELECT FROM scarr FIELDS carrid, carrname WHERE carrid = 'LH'` ).

    cl_abap_unit_assert=>assert_equals( exp = `SCARR` act = ls_sql-tabname ).
    cl_abap_unit_assert=>assert_equals( exp = `carrid = 'LH'` act = ls_sql-where ).
    cl_abap_unit_assert=>assert_equals( exp = 1 act = lines( ls_sql-t_filter ) ).


    temp174 = sy-tabix.
    READ TABLE ls_sql-t_filter INDEX 1 INTO temp173.
    sy-tabix = temp174.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `carrid` act = temp173-name ).


    temp176 = sy-tabix.
    READ TABLE ls_sql-t_filter INDEX 1 INTO temp175.
    sy-tabix = temp176.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.


    temp88 = sy-tabix.
    READ TABLE temp175-t_range INDEX 1 INTO temp87.
    sy-tabix = temp88.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `LH` act = temp87-low ).

  ENDMETHOD.

  METHOD test_sql_string_tab_only.

    DATA ls_sql TYPE z2ui5_cl_util=>ty_s_sql.
    ls_sql = z2ui5_cl_util=>filter_get_sql_by_sql_string(
                     `SELECT FROM scarr FIELDS carrid` ).

    cl_abap_unit_assert=>assert_equals( exp = `SCARR` act = ls_sql-tabname ).
    cl_abap_unit_assert=>assert_initial( ls_sql-where ).
    cl_abap_unit_assert=>assert_initial( ls_sql-t_filter ).

  ENDMETHOD.

  METHOD test_sql_string_no_fields.

    DATA ls_sql TYPE z2ui5_cl_util=>ty_s_sql.
    ls_sql = z2ui5_cl_util=>filter_get_sql_by_sql_string(
                     `SELECT FROM scarr WHERE carrid = 'LH'` ).

    cl_abap_unit_assert=>assert_equals( exp = `SCARR` act = ls_sql-tabname ).
    cl_abap_unit_assert=>assert_equals( exp = `carrid = 'LH'` act = ls_sql-where ).

  ENDMETHOD.

  METHOD test_filter_itab.

    TYPES:
      BEGIN OF ty_row,
        name  TYPE string,
        value TYPE string,
      END OF ty_row.

    TYPES temp3 TYPE STANDARD TABLE OF ty_row WITH DEFAULT KEY.
DATA lt_data TYPE temp3.

    DATA temp177 TYPE ty_row.
    DATA temp178 TYPE ty_row.
    DATA temp179 TYPE ty_row.
    DATA temp180 TYPE z2ui5_cl_util=>ty_t_filter_multi.
    DATA temp181 LIKE LINE OF temp180.
    DATA temp89 TYPE z2ui5_cl_util=>ty_t_range.
    DATA temp90 LIKE LINE OF temp89.
    DATA lt_filter LIKE temp180.
    DATA temp182 LIKE LINE OF lt_data.
    DATA temp183 LIKE sy-tabix.
    DATA temp184 LIKE LINE OF lt_data.
    DATA temp185 LIKE sy-tabix.
    CLEAR temp177.
    temp177-name = `alpha`.
    temp177-value = `low`.
    INSERT temp177 INTO TABLE lt_data.

    CLEAR temp178.
    temp178-name = `beta`.
    temp178-value = `mid`.
    INSERT temp178 INTO TABLE lt_data.

    CLEAR temp179.
    temp179-name = `gamma`.
    temp179-value = `top`.
    INSERT temp179 INTO TABLE lt_data.


    CLEAR temp180.

    temp181-name = `VALUE`.

    CLEAR temp89.

    temp90-sign = `I`.
    temp90-option = `EQ`.
    temp90-low = `mid`.
    INSERT temp90 INTO TABLE temp89.
    temp90-sign = `I`.
    temp90-option = `EQ`.
    temp90-low = `top`.
    INSERT temp90 INTO TABLE temp89.
    temp181-t_range = temp89.
    INSERT temp181 INTO TABLE temp180.

    lt_filter = temp180.

    z2ui5_cl_util=>filter_itab( EXPORTING filter = lt_filter
                                CHANGING  val    = lt_data ).

    cl_abap_unit_assert=>assert_equals( exp = 2 act = lines( lt_data ) ).


    temp183 = sy-tabix.
    READ TABLE lt_data INDEX 1 INTO temp182.
    sy-tabix = temp183.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `beta` act = temp182-name ).


    temp185 = sy-tabix.
    READ TABLE lt_data INDEX 2 INTO temp184.
    sy-tabix = temp185.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `gamma` act = temp184-name ).

  ENDMETHOD.

  METHOD test_update_tokens.

    DATA temp186 TYPE z2ui5_cl_util=>ty_t_filter_multi.
    DATA temp187 LIKE LINE OF temp186.
    DATA temp91 TYPE z2ui5_cl_util=>ty_t_token.
    DATA temp92 LIKE LINE OF temp91.
    DATA lt_filter LIKE temp186.
    DATA lt_result TYPE z2ui5_cl_util=>ty_t_filter_multi.
    DATA temp188 LIKE LINE OF lt_result.
    DATA temp189 LIKE sy-tabix.
    DATA temp190 LIKE LINE OF lt_result.
    DATA temp191 LIKE sy-tabix.
    DATA temp93 LIKE LINE OF temp190-t_token.
    DATA temp94 LIKE sy-tabix.
    DATA temp192 LIKE LINE OF lt_result.
    DATA temp193 LIKE sy-tabix.
    DATA temp194 LIKE LINE OF lt_result.
    DATA temp195 LIKE sy-tabix.
    DATA temp196 LIKE LINE OF lt_result.
    DATA temp197 LIKE sy-tabix.
    DATA temp198 LIKE LINE OF lt_result.
    DATA temp199 LIKE sy-tabix.
    DATA temp95 LIKE LINE OF temp198-t_range.
    DATA temp96 LIKE sy-tabix.
    DATA temp200 LIKE LINE OF lt_result.
    DATA temp201 LIKE sy-tabix.
    DATA temp97 LIKE LINE OF temp200-t_range.
    DATA temp98 LIKE sy-tabix.
    CLEAR temp186.

    temp187-name = `F1`.

    CLEAR temp91.

    temp92-key = `=A`.
    temp92-text = `=A`.
    INSERT temp92 INTO TABLE temp91.
    temp187-t_token_added = temp91.
    INSERT temp187 INTO TABLE temp186.

    lt_filter = temp186.


    lt_result = z2ui5_cl_util=>filter_update_tokens( val  = lt_filter
                                                           name = `F1` ).



    temp189 = sy-tabix.
    READ TABLE lt_result INDEX 1 INTO temp188.
    sy-tabix = temp189.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = 1 act = lines( temp188-t_token ) ).


    temp191 = sy-tabix.
    READ TABLE lt_result INDEX 1 INTO temp190.
    sy-tabix = temp191.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.


    temp94 = sy-tabix.
    READ TABLE temp190-t_token INDEX 1 INTO temp93.
    sy-tabix = temp94.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `=A` act = temp93-text ).


    temp193 = sy-tabix.
    READ TABLE lt_result INDEX 1 INTO temp192.
    sy-tabix = temp193.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_initial( temp192-t_token_added ).


    temp195 = sy-tabix.
    READ TABLE lt_result INDEX 1 INTO temp194.
    sy-tabix = temp195.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_initial( temp194-t_token_removed ).


    temp197 = sy-tabix.
    READ TABLE lt_result INDEX 1 INTO temp196.
    sy-tabix = temp197.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = 1 act = lines( temp196-t_range ) ).


    temp199 = sy-tabix.
    READ TABLE lt_result INDEX 1 INTO temp198.
    sy-tabix = temp199.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.


    temp96 = sy-tabix.
    READ TABLE temp198-t_range INDEX 1 INTO temp95.
    sy-tabix = temp96.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `EQ` act = temp95-option ).


    temp201 = sy-tabix.
    READ TABLE lt_result INDEX 1 INTO temp200.
    sy-tabix = temp201.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.


    temp98 = sy-tabix.
    READ TABLE temp200-t_range INDEX 1 INTO temp97.
    sy-tabix = temp98.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `A`  act = temp97-low ).

  ENDMETHOD.

  METHOD test_update_tokens_remove.

    DATA temp202 TYPE z2ui5_cl_util=>ty_t_filter_multi.
    DATA temp203 LIKE LINE OF temp202.
    DATA temp99 TYPE z2ui5_cl_util=>ty_t_token.
    DATA temp100 LIKE LINE OF temp99.
    DATA temp101 TYPE z2ui5_cl_util=>ty_t_token.
    DATA temp102 LIKE LINE OF temp101.
    DATA lt_filter LIKE temp202.
    DATA lt_result TYPE z2ui5_cl_util=>ty_t_filter_multi.
    DATA temp204 LIKE LINE OF lt_result.
    DATA temp205 LIKE sy-tabix.
    DATA temp206 LIKE LINE OF lt_result.
    DATA temp207 LIKE sy-tabix.
    DATA temp103 LIKE LINE OF temp206-t_token.
    DATA temp104 LIKE sy-tabix.
    DATA temp208 LIKE LINE OF lt_result.
    DATA temp209 LIKE sy-tabix.
    DATA temp210 LIKE LINE OF lt_result.
    DATA temp211 LIKE sy-tabix.
    DATA temp105 LIKE LINE OF temp210-t_range.
    DATA temp106 LIKE sy-tabix.
    CLEAR temp202.

    temp203-name = `F1`.

    CLEAR temp99.

    temp100-key = `=A`.
    temp100-text = `=A`.
    INSERT temp100 INTO TABLE temp99.
    temp100-key = `=B`.
    temp100-text = `=B`.
    INSERT temp100 INTO TABLE temp99.
    temp203-t_token = temp99.

    CLEAR temp101.

    temp102-key = `=A`.
    temp102-text = `=A`.
    INSERT temp102 INTO TABLE temp101.
    temp203-t_token_removed = temp101.
    INSERT temp203 INTO TABLE temp202.

    lt_filter = temp202.


    lt_result = z2ui5_cl_util=>filter_update_tokens( val  = lt_filter
                                                           name = `F1` ).



    temp205 = sy-tabix.
    READ TABLE lt_result INDEX 1 INTO temp204.
    sy-tabix = temp205.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = 1 act = lines( temp204-t_token ) ).


    temp207 = sy-tabix.
    READ TABLE lt_result INDEX 1 INTO temp206.
    sy-tabix = temp207.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.


    temp104 = sy-tabix.
    READ TABLE temp206-t_token INDEX 1 INTO temp103.
    sy-tabix = temp104.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `=B` act = temp103-text ).


    temp209 = sy-tabix.
    READ TABLE lt_result INDEX 1 INTO temp208.
    sy-tabix = temp209.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = 1 act = lines( temp208-t_range ) ).


    temp211 = sy-tabix.
    READ TABLE lt_result INDEX 1 INTO temp210.
    sy-tabix = temp211.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.


    temp106 = sy-tabix.
    READ TABLE temp210-t_range INDEX 1 INTO temp105.
    sy-tabix = temp106.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `B` act = temp105-low ).

  ENDMETHOD.

ENDCLASS.


CLASS ltcl_unit_test_conversion DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS test_json_roundtrip          FOR TESTING RAISING cx_static_check.
    METHODS test_csv_roundtrip           FOR TESTING RAISING cx_static_check.
    METHODS test_conv_get_as_data_ref    FOR TESTING RAISING cx_static_check.
    METHODS test_conv_string_to_date     FOR TESTING RAISING cx_static_check.
    METHODS test_conv_date_to_string     FOR TESTING RAISING cx_static_check.
    METHODS test_conv_date_roundtrip     FOR TESTING RAISING cx_static_check.
    METHODS test_itab_get_by_struc       FOR TESTING RAISING cx_static_check.
    METHODS test_time_add_seconds        FOR TESTING RAISING cx_static_check.
    METHODS test_time_diff_seconds       FOR TESTING RAISING cx_static_check.
    METHODS test_cal_weekday             FOR TESTING RAISING cx_static_check.
    METHODS test_cal_workdays            FOR TESTING RAISING cx_static_check.
    METHODS test_zip_pack                FOR TESTING RAISING cx_static_check.
    METHODS test_zip_unpack              FOR TESTING RAISING cx_static_check.
    METHODS test_lock_get_dequeue        FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_unit_test_conversion IMPLEMENTATION.

  METHOD test_json_roundtrip.

    TYPES:
      BEGIN OF ty_data,
        name  TYPE string,
        value TYPE i,
        flag  TYPE abap_bool,
      END OF ty_data.

    DATA temp212 TYPE ty_data.
    DATA ls_in LIKE temp212.
    DATA lv_json TYPE string.
    DATA ls_out TYPE ty_data.
    CLEAR temp212.
    temp212-name = `test`.
    temp212-value = 42.
    temp212-flag = abap_true.

    ls_in = temp212.


    lv_json = z2ui5_cl_util=>json_stringify( ls_in ).
    cl_abap_unit_assert=>assert_not_initial( lv_json ).


    z2ui5_cl_util=>json_parse( EXPORTING val = lv_json
                                CHANGING data = ls_out ).

    cl_abap_unit_assert=>assert_equals( exp = `test` act = ls_out-name ).
    cl_abap_unit_assert=>assert_equals( exp = 42     act = ls_out-value ).
    cl_abap_unit_assert=>assert_true( ls_out-flag ).

  ENDMETHOD.

  METHOD test_csv_roundtrip.

    TYPES:
      BEGIN OF ty_row,
        col1 TYPE string,
        col2 TYPE string,
      END OF ty_row.

    TYPES temp4 TYPE STANDARD TABLE OF ty_row WITH DEFAULT KEY.
DATA lt_in TYPE temp4.
    DATA temp213 LIKE lt_in.
    DATA temp214 LIKE LINE OF temp213.
    DATA lv_csv TYPE string.
    DATA temp10 TYPE xsdboolean.
    DATA temp11 TYPE xsdboolean.
    CLEAR temp213.

    temp214-col1 = `A`.
    temp214-col2 = `B`.
    INSERT temp214 INTO TABLE temp213.
    temp214-col1 = `C`.
    temp214-col2 = `D`.
    INSERT temp214 INTO TABLE temp213.
    lt_in = temp213.


    lv_csv = z2ui5_cl_util=>itab_get_csv_by_itab( lt_in ).
    cl_abap_unit_assert=>assert_not_initial( lv_csv ).


    temp10 = boolc( lv_csv CS `COL1` ).
    cl_abap_unit_assert=>assert_true(
      temp10 ).

    temp11 = boolc( lv_csv CS `COL2` ).
    cl_abap_unit_assert=>assert_true(
      temp11 ).

  ENDMETHOD.

  METHOD test_conv_get_as_data_ref.

    DATA lv_val TYPE string.
    DATA lr_ref TYPE REF TO data.
    FIELD-SYMBOLS <any> TYPE any.
    lv_val = `test_value`.

    lr_ref = z2ui5_cl_util=>conv_get_as_data_ref( lv_val ).

    cl_abap_unit_assert=>assert_bound( lr_ref ).


    ASSIGN lr_ref->* TO <any>.
    cl_abap_unit_assert=>assert_equals( exp = `test_value`
                                        act = <any> ).

  ENDMETHOD.

  METHOD test_conv_string_to_date.

    DATA lv_date TYPE d.
    lv_date = z2ui5_cl_util=>conv_string_to_date( `2024-03-15` ).
    cl_abap_unit_assert=>assert_equals( exp = `20240315`
                                        act = lv_date ).

  ENDMETHOD.

  METHOD test_conv_date_to_string.

    DATA temp215 TYPE d.
    DATA lv_str TYPE string.
    temp215 = `20240315`.

    lv_str = z2ui5_cl_util=>conv_date_to_string( temp215 ).
    cl_abap_unit_assert=>assert_equals( exp = `2024-03-15`
                                        act = lv_str ).

  ENDMETHOD.

  METHOD test_conv_date_roundtrip.

    DATA lv_original TYPE string.
    DATA lv_date TYPE d.
    DATA lv_back TYPE string.
    lv_original = `2025-12-31`.

    lv_date = z2ui5_cl_util=>conv_string_to_date( lv_original ).

    lv_back = z2ui5_cl_util=>conv_date_to_string( lv_date ).

    cl_abap_unit_assert=>assert_equals( exp = lv_original
                                        act = lv_back ).

  ENDMETHOD.

  METHOD test_itab_get_by_struc.

    TYPES:
      BEGIN OF ty_s,
        name  TYPE string,
        value TYPE string,
      END OF ty_s.

    DATA temp216 TYPE ty_s.
    DATA ls_struc LIKE temp216.
    DATA lt_nv TYPE z2ui5_cl_util=>ty_t_name_value.
    DATA temp217 LIKE LINE OF lt_nv.
    DATA temp218 LIKE sy-tabix.
    DATA temp219 LIKE LINE OF lt_nv.
    DATA temp220 LIKE sy-tabix.
    DATA temp221 LIKE LINE OF lt_nv.
    DATA temp222 LIKE sy-tabix.
    DATA temp223 LIKE LINE OF lt_nv.
    DATA temp224 LIKE sy-tabix.
    CLEAR temp216.
    temp216-name = `test_name`.
    temp216-value = `test_value`.

    ls_struc = temp216.

    lt_nv = z2ui5_cl_util=>itab_get_by_struc( ls_struc ).

    cl_abap_unit_assert=>assert_equals( exp = 2 act = lines( lt_nv ) ).


    temp218 = sy-tabix.
    READ TABLE lt_nv INDEX 1 INTO temp217.
    sy-tabix = temp218.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `NAME`       act = temp217-n ).


    temp220 = sy-tabix.
    READ TABLE lt_nv INDEX 1 INTO temp219.
    sy-tabix = temp220.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `test_name`  act = temp219-v ).


    temp222 = sy-tabix.
    READ TABLE lt_nv INDEX 2 INTO temp221.
    sy-tabix = temp222.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `VALUE`      act = temp221-n ).


    temp224 = sy-tabix.
    READ TABLE lt_nv INDEX 2 INTO temp223.
    sy-tabix = temp224.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `test_value` act = temp223-v ).

  ENDMETHOD.

  METHOD test_time_add_seconds.

    DATA lv_time TYPE timestampl.
    DATA lv_later TYPE timestampl.
    lv_time = z2ui5_cl_util=>time_get_timestampl( ).

    lv_later = z2ui5_cl_util=>time_add_seconds( time    = lv_time
                                                       seconds = 3600 ).

    cl_abap_unit_assert=>assert_not_initial( lv_later ).

    IF lv_later <= lv_time.
      cl_abap_unit_assert=>fail( `time_add_seconds should return a later timestamp` ).
    ENDIF.

  ENDMETHOD.

  METHOD test_time_diff_seconds.

    DATA lv_time TYPE timestampl.
    DATA lv_later TYPE timestampl.
    DATA lv_diff TYPE i.
    lv_time = z2ui5_cl_util=>time_get_timestampl( ).

    lv_later = z2ui5_cl_util=>time_add_seconds( time    = lv_time
                                                       seconds = 120 ).


    lv_diff = z2ui5_cl_util=>time_diff_seconds( time_from = lv_time
                                                       time_to   = lv_later ).

    cl_abap_unit_assert=>assert_equals( exp = 120
                                        act = lv_diff ).

  ENDMETHOD.

  METHOD test_cal_weekday.

    " 2024-01-01 was a Monday, 2024-01-07 a Sunday
    DATA temp225 TYPE d.
    DATA temp226 TYPE d.
    DATA temp227 TYPE d.
    DATA temp228 TYPE d.
    temp225 = `20240101`.
    cl_abap_unit_assert=>assert_equals(
        exp = 1
        act = z2ui5_cl_util=>cal_get_weekday( temp225 ) ).

    temp226 = `20240101`.
    cl_abap_unit_assert=>assert_false(
        z2ui5_cl_util=>cal_is_weekend( temp226 ) ).


    temp227 = `20240107`.
    cl_abap_unit_assert=>assert_equals(
        exp = 7
        act = z2ui5_cl_util=>cal_get_weekday( temp227 ) ).

    temp228 = `20240107`.
    cl_abap_unit_assert=>assert_true(
        z2ui5_cl_util=>cal_is_weekend( temp228 ) ).

  ENDMETHOD.

  METHOD test_cal_workdays.

    " Friday 2024-03-15 + 1 workday skips the weekend -> Monday 2024-03-18
    DATA temp229 TYPE d.
    DATA temp107 TYPE d.
    DATA temp230 TYPE d.
    DATA temp108 TYPE d.
    temp229 = `20240318`.

    temp107 = `20240315`.
    cl_abap_unit_assert=>assert_equals(
        exp = temp229
        act = z2ui5_cl_util=>cal_add_workdays( date = temp107
                                               days = 1 ) ).

    " Monday 2024-01-01 to Monday 2024-01-08 -> 5 workdays

    temp230 = `20240101`.

    temp108 = `20240108`.
    cl_abap_unit_assert=>assert_equals(
        exp = 5
        act = z2ui5_cl_util=>cal_count_workdays( date_from = temp230
                                                 date_to   = temp108 ) ).

  ENDMETHOD.

  METHOD test_zip_pack.

    " Skip when the runtime (e.g. the transpiler) does not provide CL_ABAP_ZIP
    DATA lo_probe TYPE REF TO object.
    DATA temp231 TYPE z2ui5_cl_util=>ty_t_zip_file.
    DATA temp232 LIKE LINE OF temp231.
    DATA temp109 TYPE xstring.
    DATA temp110 TYPE xstring.
    DATA lt_in LIKE temp231.
    DATA lv_archive TYPE xstring.
    TRY.
        CREATE OBJECT lo_probe TYPE ('CL_ABAP_ZIP').
      CATCH cx_root.
        RETURN.
    ENDTRY.


    CLEAR temp231.

    temp232-name = `hello.txt`.

    temp109 = `48656C6C6F`.
    temp232-content = temp109.
    INSERT temp232 INTO TABLE temp231.
    temp232-name = `world.txt`.

    temp110 = `576F726C64`.
    temp232-content = temp110.
    INSERT temp232 INTO TABLE temp231.

    lt_in = temp231.


    lv_archive = z2ui5_cl_util=>zip_pack( lt_in ).
    cl_abap_unit_assert=>assert_not_initial( lv_archive ).

  ENDMETHOD.

  METHOD test_zip_unpack.

    " Note: this full round-trip relies on CL_ABAP_ZIP=>LOAD, which the
    " open-abap transpiler runtime does not implement - the method is therefore
    " listed in the transpiler skip list (node/setup/abap_transpile.json).
    DATA temp233 TYPE z2ui5_cl_util=>ty_t_zip_file.
    DATA temp234 LIKE LINE OF temp233.
    DATA temp111 TYPE xstring.
    DATA temp112 TYPE xstring.
    DATA lt_in LIKE temp233.
    DATA lv_archive TYPE xstring.
    DATA lt_out TYPE z2ui5_cl_util=>ty_t_zip_file.
    DATA ls_in LIKE LINE OF lt_in.
      DATA temp235 TYPE z2ui5_cl_util=>ty_s_zip_file.
      DATA temp236 TYPE z2ui5_cl_util=>ty_s_zip_file.
      DATA ls_out LIKE temp235.
    CLEAR temp233.

    temp234-name = `hello.txt`.

    temp111 = `48656C6C6F`.
    temp234-content = temp111.
    INSERT temp234 INTO TABLE temp233.
    temp234-name = `world.txt`.

    temp112 = `576F726C64`.
    temp234-content = temp112.
    INSERT temp234 INTO TABLE temp233.

    lt_in = temp233.


    lv_archive = z2ui5_cl_util=>zip_pack( lt_in ).

    lt_out = z2ui5_cl_util=>zip_unpack( lv_archive ).

    cl_abap_unit_assert=>assert_equals( exp = 2 act = lines( lt_out ) ).


    LOOP AT lt_in INTO ls_in.

      CLEAR temp235.

      READ TABLE lt_out INTO temp236 WITH KEY name = ls_in-name.
      IF sy-subrc = 0.
        temp235 = temp236.
      ENDIF.

      ls_out = temp235.
      cl_abap_unit_assert=>assert_equals( exp = ls_in-content
                                          act = ls_out-content ).
    ENDLOOP.

  ENDMETHOD.

  METHOD test_lock_get_dequeue.

    DATA lv_result TYPE string.

    lv_result = z2ui5_cl_util=>lock_get_dequeue_by_enqueue( `ENQUEUE_EVVBAKE` ).
    cl_abap_unit_assert=>assert_equals( exp = `DEQUEUE_EVVBAKE`
                                        act = lv_result ).

    lv_result = z2ui5_cl_util=>lock_get_dequeue_by_enqueue( `enqueue_evvbake` ).
    cl_abap_unit_assert=>assert_equals( exp = `DEQUEUE_EVVBAKE`
                                        act = lv_result ).

    lv_result = z2ui5_cl_util=>lock_get_dequeue_by_enqueue( `DEQUEUE_EVVBAKE` ).
    cl_abap_unit_assert=>assert_equals( exp = `DEQUEUE_EVVBAKE`
                                        act = lv_result ).

  ENDMETHOD.

ENDCLASS.
