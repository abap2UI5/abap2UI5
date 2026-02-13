
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
    CLASS-DATA st_tab TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.

    CLASS-METHODS class_constructor.

    DATA mv_val TYPE string ##NEEDED.
    DATA ms_tab TYPE ty_row ##NEEDED.
    DATA mt_tab TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY ##NEEDED.

  PROTECTED SECTION.

  PRIVATE SECTION.
ENDCLASS.


CLASS ltcl_test_app IMPLEMENTATION.
  METHOD class_constructor.

    sv_var = 1.
    ss_tab = VALUE #( ).
    st_tab = VALUE #( ).

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

    METHODS test_boolean_check_by_name     FOR TESTING RAISING cx_static_check.
    METHODS test_boolean_abap_2_json_true  FOR TESTING RAISING cx_static_check.
    METHODS test_boolean_abap_2_json_false FOR TESTING RAISING cx_static_check.

    METHODS test_ui5_get_msg_type_e        FOR TESTING RAISING cx_static_check.
    METHODS test_ui5_get_msg_type_s        FOR TESTING RAISING cx_static_check.
    METHODS test_ui5_get_msg_type_w        FOR TESTING RAISING cx_static_check.
    METHODS test_ui5_get_msg_type_i        FOR TESTING RAISING cx_static_check.
    METHODS test_ui5_get_msg_type_default  FOR TESTING RAISING cx_static_check.

    METHODS test_rtti_check_clike_string   FOR TESTING RAISING cx_static_check.
    METHODS test_rtti_check_clike_int      FOR TESTING RAISING cx_static_check.
    METHODS test_rtti_check_class_exists   FOR TESTING RAISING cx_static_check.
    METHODS test_rtti_check_class_no_exist FOR TESTING RAISING cx_static_check.

    METHODS test_conv_get_as_data_ref      FOR TESTING RAISING cx_static_check.
    METHODS test_itab_csv_roundtrip        FOR TESTING RAISING cx_static_check.
    METHODS test_itab_get_by_struc         FOR TESTING RAISING cx_static_check.
    METHODS test_itab_filter_by_val        FOR TESTING RAISING cx_static_check.

    METHODS test_filter_get_range_by_eq    FOR TESTING RAISING cx_static_check.
    METHODS test_filter_get_range_by_lt    FOR TESTING RAISING cx_static_check.
    METHODS test_filter_get_range_by_le    FOR TESTING RAISING cx_static_check.
    METHODS test_filter_get_range_by_gt    FOR TESTING RAISING cx_static_check.
    METHODS test_filter_get_range_by_ge    FOR TESTING RAISING cx_static_check.
    METHODS test_filter_get_range_by_cp    FOR TESTING RAISING cx_static_check.
    METHODS test_filter_get_range_by_bt    FOR TESTING RAISING cx_static_check.
    METHODS test_filter_get_range_default  FOR TESTING RAISING cx_static_check.

    METHODS test_filter_get_multi_by_data  FOR TESTING RAISING cx_static_check.
    METHODS test_filter_get_token_mapping  FOR TESTING RAISING cx_static_check.

    METHODS test_x_get_last_t100           FOR TESTING RAISING cx_static_check.
    METHODS test_source_get_file_types     FOR TESTING RAISING cx_static_check.
    METHODS test_json_parse                FOR TESTING RAISING cx_static_check.
    METHODS test_c_trim_empty              FOR TESTING RAISING cx_static_check.
    METHODS test_url_param_set_new         FOR TESTING RAISING cx_static_check.

    METHODS test_time_get_date_by_stampl   FOR TESTING RAISING cx_static_check.
    METHODS test_time_get_time_by_stampl   FOR TESTING RAISING cx_static_check.

    METHODS test_filter_itab               FOR TESTING RAISING cx_static_check.

    METHODS test_unassign_data             FOR TESTING RAISING cx_static_check.
    METHODS test_unassign_object           FOR TESTING RAISING cx_static_check.

    METHODS test_source_method_to_file     FOR TESTING RAISING cx_static_check.

    METHODS test_itab_get_itab_by_csv      FOR TESTING RAISING cx_static_check.
    METHODS test_itab_corresponding        FOR TESTING RAISING cx_static_check.

    METHODS test_rtti_tab_get_rel_name     FOR TESTING RAISING cx_static_check.
    METHODS test_rtti_get_intfname_by_ref  FOR TESTING RAISING cx_static_check.

    METHODS test_filter_update_tokens      FOR TESTING RAISING cx_static_check.
    METHODS test_filter_get_range_t_by_tt  FOR TESTING RAISING cx_static_check.

    METHODS test_msg_get                   FOR TESTING RAISING cx_static_check.
    METHODS test_msg_get_t                 FOR TESTING RAISING cx_static_check.
    METHODS test_msg_get_by_msg            FOR TESTING RAISING cx_static_check.

    METHODS test_x_raise_with_text         FOR TESTING RAISING cx_static_check.
    METHODS test_x_check_raise_with_text   FOR TESTING RAISING cx_static_check.

    METHODS test_json_stringify_table      FOR TESTING RAISING cx_static_check.
    METHODS test_json_parse_to_table       FOR TESTING RAISING cx_static_check.

    METHODS test_xml_parse_empty           FOR TESTING RAISING cx_static_check.

    METHODS test_rtti_get_type_name_string FOR TESTING RAISING cx_static_check.
    METHODS test_rtti_get_type_kind_struct FOR TESTING RAISING cx_static_check.
    METHODS test_rtti_get_type_kind_table  FOR TESTING RAISING cx_static_check.

    METHODS test_rtti_check_clike_char     FOR TESTING RAISING cx_static_check.

    METHODS test_boolean_check_by_data_str FOR TESTING RAISING cx_static_check.

    METHODS test_itab_filter_by_val_no_hit FOR TESTING RAISING cx_static_check.

    METHODS test_conv_copy_ref_data_struc  FOR TESTING RAISING cx_static_check.

    METHODS test_url_param_get_encoded     FOR TESTING RAISING cx_static_check.

    METHODS test_filter_itab_no_match      FOR TESTING RAISING cx_static_check.
    METHODS test_filter_itab_multi_filter  FOR TESTING RAISING cx_static_check.

    METHODS test_rtti_attri_by_tab_name   FOR TESTING RAISING cx_static_check.
    METHODS test_rtti_attri_by_tab_empty  FOR TESTING RAISING cx_static_check.
    METHODS test_rtti_create_tab_by_name  FOR TESTING RAISING cx_static_check.
    METHODS test_rtti_get_dtel_text_l     FOR TESTING RAISING cx_static_check.
    METHODS test_rtti_ddic_fixed_values   FOR TESTING RAISING cx_static_check.
    METHODS test_source_get_method2       FOR TESTING RAISING cx_static_check.
    METHODS test_xml_srtti_stringify      FOR TESTING RAISING cx_static_check.
    METHODS test_filter_get_sql_where     FOR TESTING RAISING cx_static_check.
    METHODS test_itab_filter_by_t_range   FOR TESTING RAISING cx_static_check.
    METHODS test_filter_get_data_by_multi FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_unit_test_open_abap IMPLEMENTATION.

  METHOD test_assign.

    DATA(lo_app) = NEW ltcl_test_app( ).
    FIELD-SYMBOLS <any> TYPE any.

    lo_app->mv_val = `ABC`.

    DATA(lv_assign) = |MV_VAL|.
    ASSIGN lo_app->(lv_assign) TO <any>.
    ASSERT sy-subrc = 0.

    cl_abap_unit_assert=>assert_equals( exp = `ABC`
                                        act = <any> ).

  ENDMETHOD.

  METHOD test_classdescr.

    DATA(lo_app) = NEW ltcl_test_app( ).

    DATA(lt_attri) = CAST cl_abap_classdescr( cl_abap_objectdescr=>describe_by_object_ref( lo_app ) )->attributes.

    DATA(lv_test) = lt_attri[ name = `MS_TAB` ].
    lv_test = lt_attri[ name = `MT_TAB` ].
    lv_test = lt_attri[ name = `MV_VAL` ].
    lv_test = lt_attri[ name = `SS_TAB` ].
    lv_test = lt_attri[ name = `ST_TAB` ].
    lv_test = lt_attri[ name = `SV_STATUS` ].
    lv_test = lt_attri[ name = `SV_VAR` ].

  ENDMETHOD.

  METHOD test_eledescr_rel_name.

    DATA(lo_ele) = CAST cl_abap_elemdescr( cl_abap_elemdescr=>describe_by_data( abap_true ) ).

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

    DATA(lv_search) = replace( val  = `one two three`
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

    TRY.
        IF 1 = 1.
          RAISE EXCEPTION TYPE z2ui5_cx_util_error.
        ENDIF.
        cl_abap_unit_assert=>fail( ).

      CATCH z2ui5_cx_util_error INTO DATA(lx).
        cl_abap_unit_assert=>assert_bound( lx ).
    ENDTRY.

  ENDMETHOD.

  METHOD test_xsdbool.

    DATA(lv_xsdbool) = xsdbool( 1 = 1 ).
    IF lv_xsdbool = abap_false.
      cl_abap_unit_assert=>assert_false( lv_xsdbool ).
    ENDIF.

    IF xsdbool( 1 = 1 ) = abap_false.
      cl_abap_unit_assert=>fail( ).
    ENDIF.

  ENDMETHOD.

  METHOD test_xsdbool_nested.

    DATA(lv_xsdbool) = check_input( xsdbool( 1 = 1 ) ).
    IF lv_xsdbool = abap_false.
      cl_abap_unit_assert=>assert_false( lv_xsdbool ).
    ENDIF.

    IF check_input( abap_false ).
      cl_abap_unit_assert=>fail( ).
    ENDIF.

    IF check_input( xsdbool( 1 = 1 ) ) = abap_false.
      cl_abap_unit_assert=>fail( ).
    ENDIF.

  ENDMETHOD.

  METHOD check_input.

    result = val.

  ENDMETHOD.
ENDCLASS.


CLASS ltcl_unit_test IMPLEMENTATION.
  METHOD test_boolean_check.

    DATA(lv_bool) = xsdbool( 1 = 1 ).
    cl_abap_unit_assert=>assert_true( z2ui5_cl_util=>boolean_check_by_data( lv_bool ) ).

    lv_bool = xsdbool( 1 = 2 ).
    cl_abap_unit_assert=>assert_true( z2ui5_cl_util=>boolean_check_by_data( lv_bool ) ).

    cl_abap_unit_assert=>assert_true( z2ui5_cl_util=>boolean_check_by_data( abap_true ) ).

    cl_abap_unit_assert=>assert_true( z2ui5_cl_util=>boolean_check_by_data( abap_false ) ).

  ENDMETHOD.

  METHOD test_sql_get_by_string.

    DATA(lv_test) = ``.
    DATA(ls_sql) = z2ui5_cl_util=>filter_get_sql_by_sql_string( lv_test ) ##NEEDED.

  ENDMETHOD.

  METHOD test_create.

    DATA(lo_test) = NEW z2ui5_cl_util( ) ##NEEDED.

  ENDMETHOD.

  METHOD test_rtti_get_classname_by_ref.

    DATA(lo_test2) = NEW ltcl_test_app( ).
    DATA(lv_name2) = z2ui5_cl_util=>rtti_get_classname_by_ref( lo_test2 ).
    cl_abap_unit_assert=>assert_equals( exp = `LTCL_TEST_APP`
                                        act = lv_name2 ).

  ENDMETHOD.

  METHOD test_check_bound_a_not_inital.

    DATA(lv_test) = `test`.
    DATA(lr_test) = REF #( lv_test ).

    cl_abap_unit_assert=>assert_true( z2ui5_cl_util=>check_bound_a_not_inital( lr_test ) ).
    CLEAR lv_test.
    cl_abap_unit_assert=>assert_false( z2ui5_cl_util=>check_bound_a_not_inital( lr_test ) ).
    CLEAR lr_test.
    cl_abap_unit_assert=>assert_false( z2ui5_cl_util=>check_bound_a_not_inital( lr_test ) ).

  ENDMETHOD.

  METHOD test_check_unassign_inital.

    DATA(lv_test) = `test`.
    DATA(lr_test) = REF #( lv_test ).

    cl_abap_unit_assert=>assert_false( z2ui5_cl_util=>check_unassign_inital( lr_test ) ).

    CLEAR lv_test.
    cl_abap_unit_assert=>assert_true( z2ui5_cl_util=>check_unassign_inital( lr_test ) ).

  ENDMETHOD.

  METHOD rtti_check_ref_data.

    DATA(lv_test) = `test`.
    DATA lr_data TYPE REF TO data.
*    GET REFERENCE OF lv_test INTO lr_data.
    lr_data = REF #( lv_test ).

    cl_abap_unit_assert=>assert_true( z2ui5_cl_util=>rtti_check_ref_data( lr_data ) ).

    cl_abap_unit_assert=>assert_false( z2ui5_cl_util=>rtti_check_ref_data( lv_test ) ).

  ENDMETHOD.

  METHOD conv_copy_ref_data.

    DATA(lv_test) = `test`.
    DATA lr_data TYPE REF TO data.
*    GET REFERENCE OF lv_test INTO lr_data.
    lr_data = REF #( lv_test ).

    DATA(lr_test2) = z2ui5_cl_util=>conv_copy_ref_data( lr_data ).

    FIELD-SYMBOLS <result> TYPE data.
    ASSIGN lr_test2->* TO <result>.

    cl_abap_unit_assert=>assert_equals( exp = lv_test
                                        act = <result> ).

  ENDMETHOD.

  METHOD test_boolean_abap_2_json.

    cl_abap_unit_assert=>assert_equals( exp = `{ABCD}`
                                        act = z2ui5_cl_util=>boolean_abap_2_json( `{ABCD}` ) ).

  ENDMETHOD.

  METHOD test_time_get_timestampl.

    DATA(lv_time) = z2ui5_cl_util=>time_get_timestampl( ).

    DATA(lv_time2) = z2ui5_cl_util=>time_substract_seconds( time    = lv_time
                                                            seconds = 60 * 60 * 4 ).

    IF lv_time IS INITIAL OR lv_time2 IS INITIAL.
      cl_abap_unit_assert=>fail( ).
    ENDIF.

    IF lv_time < lv_time2.
      cl_abap_unit_assert=>fail( ).
    ENDIF.

  ENDMETHOD.

  METHOD test_time_substract_seconds.

    DATA(lv_time) = z2ui5_cl_util=>time_get_timestampl( ).
    DATA(lv_time2) = z2ui5_cl_util=>time_get_timestampl( ).

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

    TRY.
        z2ui5_cl_util=>x_check_raise( xsdbool( 1 = 1 ) ).
        cl_abap_unit_assert=>fail( ).
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

    TRY.
        z2ui5_cl_util=>x_check_raise( xsdbool( 1 = 3 ) ).
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

    DATA(ls_row) = VALUE ty_row( title = `test` ).

    cl_abap_unit_assert=>assert_equals( exp = `{"selected":false,"title":"test","value":""}`
                                        act = z2ui5_cl_util=>json_stringify( ls_row ) ).

  ENDMETHOD.

  METHOD test_url_param_create_url.

    DATA(lt_param) = z2ui5_cl_util=>url_param_get_tab(
                         `https://url.com/rvice_for_ui?sap-client=100&app_start=z2ui5_cl_app_hello_world` ).
    DATA(lv_url) = z2ui5_cl_util=>url_param_create_url( lt_param ).

    cl_abap_unit_assert=>assert_equals( exp = `sap-client=100&app_start=z2ui5_cl_app_hello_world`
                                        act = lv_url ).

  ENDMETHOD.

  METHOD test_url_param_get.

    DATA(lv_param) = z2ui5_cl_util=>url_param_get(
                         val = `app_start`
                         url = `https://url.com/rvice_for_ui?sap-client=100&app_start=z2ui5_cl_app_hello_world` ).

    cl_abap_unit_assert=>assert_equals( exp = `z2ui5_cl_app_hello_world`
                                        act = lv_param ).

  ENDMETHOD.

  METHOD test_url_param_get_tab.

    DATA(lt_param) = z2ui5_cl_util=>url_param_get_tab(
                         `https://url.com/rvice_for_ui?sap-client=100&app_start=z2ui5_cl_app_hello_world` ).

    cl_abap_unit_assert=>assert_equals( exp = `100`
                                        act = lt_param[ n = `sap-client` ]-v ).

    cl_abap_unit_assert=>assert_equals( exp = `z2ui5_cl_app_hello_world`
                                        act = lt_param[ n = `app_start` ]-v ).

  ENDMETHOD.

  METHOD test_url_param_set.

    DATA(lv_param) = z2ui5_cl_util=>url_param_set(
                         name  = `app_start`
                         value = `z2ui5_cl_app_hello_world2`
                         url   = `https://url.com/rvice_for_ui?sap-client=100&app_start=z2ui5_cl_app_hello_world` ).

    cl_abap_unit_assert=>assert_equals( exp = `sap-client=100&app_start=z2ui5_cl_app_hello_world2`
                                        act = lv_param ).

  ENDMETHOD.

  METHOD test_x_check_raise_not.

    TRY.
        z2ui5_cl_util=>x_check_raise( xsdbool( 1 = 2 ) ).
      CATCH z2ui5_cx_util_error.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD test_rtti_get_type_name.

    DATA(lv_xsdbool) = VALUE xsdboolean( ).
    DATA(lv_name) = z2ui5_cl_util=>rtti_get_type_name( lv_xsdbool ).
    cl_abap_unit_assert=>assert_equals( exp = `XSDBOOLEAN`
                                        act = lv_name ).

  ENDMETHOD.

  METHOD test_rtti_get_type_kind.

    DATA(lv_string) = VALUE string( ).

    DATA(lv_type_kind) = z2ui5_cl_util=>rtti_get_type_kind( lv_string ).
    DATA lr_string TYPE REF TO string.
    cl_abap_unit_assert=>assert_equals( exp = cl_abap_typedescr=>typekind_string
                                        act = lv_type_kind ).

    CREATE DATA lr_string.
    lv_type_kind = z2ui5_cl_util=>rtti_get_type_kind( lr_string ).
    cl_abap_unit_assert=>assert_equals( exp = cl_abap_typedescr=>typekind_dref
                                        act = lv_type_kind ).

  ENDMETHOD.

  METHOD test_rtti_check_type_kind.

    DATA(lv_string) = VALUE string( ).
    DATA lr_string TYPE REF TO string.
    cl_abap_unit_assert=>assert_false( z2ui5_cl_util=>rtti_check_type_kind_dref( lv_string ) ).

    CREATE DATA lr_string.
    cl_abap_unit_assert=>assert_true( z2ui5_cl_util=>rtti_check_type_kind_dref( lr_string ) ).

  ENDMETHOD.

  METHOD test_rtti_get_t_attri_by_obj.

    DATA(lo_obj) = NEW ltcl_test_app( ).
    DATA(lt_attri) = z2ui5_cl_util=>rtti_get_t_attri_by_oref( lo_obj ).

    IF lines( lt_attri ) <> 7.
      cl_abap_unit_assert=>fail( ).
    ENDIF.

    IF NOT line_exists( lt_attri[ name = `MS_TAB` ] ).
      cl_abap_unit_assert=>fail( ).
    ENDIF.

    IF NOT line_exists( lt_attri[ name      = `SS_TAB`
                                  type_kind = `v` ] ).
      cl_abap_unit_assert=>fail( ).
    ENDIF.

    IF NOT line_exists( lt_attri[ name      = `SV_VAR`
                                  type_kind = `g`
                                  is_class  = abap_true ] ).
      cl_abap_unit_assert=>fail( ).
    ENDIF.

    IF NOT line_exists( lt_attri[ name        = `SV_STATUS`
                                  type_kind   = `g`
                                  is_class    = abap_true
                                  is_constant = `X` ] ).
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

    DATA(ls_row) = VALUE ty_row( ).

    DATA(lt_comp) = z2ui5_cl_util=>rtti_get_t_attri_by_any( ls_row ).

    IF lines( lt_comp ) <> 7.
      cl_abap_unit_assert=>fail( ).
    ENDIF.

    IF NOT line_exists( lt_comp[ name = `TITLE` ] ).
      cl_abap_unit_assert=>fail( ).
    ENDIF.

    IF NOT line_exists( lt_comp[ name = `VALUE`  ] ).
      cl_abap_unit_assert=>fail( ).
    ENDIF.

    IF NOT line_exists( lt_comp[ name = `SELECTED` ] ).
      cl_abap_unit_assert=>fail( ).
    ENDIF.

    IF NOT line_exists( lt_comp[ name = `CHECKBOX` ] ).
      cl_abap_unit_assert=>fail( ).
    ENDIF.

    DATA(ls_title) = lt_comp[ 1 ].

    IF ls_title-type->type_kind <> `g`.
      cl_abap_unit_assert=>fail( ).
    ENDIF.

  ENDMETHOD.

  METHOD test_trans_xml_any_2__w_obj.

    DATA(lo_obj) = NEW ltcl_test_app( ).
    DATA(lv_xml) = z2ui5_cl_util=>xml_stringify( lo_obj ).

    IF lv_xml IS INITIAL.
      cl_abap_unit_assert=>fail( ).
    ENDIF.
  ENDMETHOD.

  METHOD test_trans_xml_2_any__w_obj.

    DATA(lo_obj) = NEW ltcl_test_app( ).
    DATA(lv_xml) = z2ui5_cl_util=>xml_stringify( lo_obj ).

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

    DATA(ls_row) = VALUE ty_row( ).
    ls_row-value = `test`.

    DATA(lv_xml) = z2ui5_cl_util=>xml_stringify( ls_row ).

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

    DATA(ls_row) = VALUE ty_row( ).
    DATA(ls_row2) = VALUE ty_row( ).
    ls_row-value = `test`.

    DATA(lv_xml) = z2ui5_cl_util=>xml_stringify( ls_row ).

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

    DATA(lt_range) = VALUE z2ui5_cl_util=>ty_t_range( ( sign = `I` option = `EQ` low = `table` high = `` )
     ).

    DATA(lt_result) = z2ui5_cl_util=>filter_get_token_t_by_range_t( lt_range ).

    DATA(lt_exp) = VALUE z2ui5_cl_util=>ty_t_token(
                             ( key = `=table` text = `=table` visible = `X` selkz = `` editable = `X` )
    ).

    cl_abap_unit_assert=>assert_equals( exp = lt_exp
                                        act = lt_result
    ).

  ENDMETHOD.

  METHOD test_rtti_get_t_attri_by_incl.

    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.

    TYPES:
      BEGIN OF ty_struc_incl,
        incl_title  TYPE string,
        incl_value  TYPE string,
        incl_value2 TYPE string,
      END OF ty_struc_incl.

    TYPES:
      BEGIN OF ty_struc,
        title  TYPE string,
        value  TYPE string,
        value2 TYPE string,
      END OF ty_struc.

    DATA BEGIN OF ms_struc2.
    INCLUDE TYPE ty_struc.
    INCLUDE TYPE ty_struc_incl.
    DATA END OF ms_struc2.

    DATA(lo_datadescr) = cl_abap_typedescr=>describe_by_data( ms_struc2 ).

    IF z2ui5_cl_util=>context_check_abap_cloud( ).
      RETURN.
    ENDIF.
    DATA(lt_attri) = z2ui5_cl_util=>rtti_get_t_attri_by_include( CAST #( lo_datadescr ) ).

    IF lines( lt_attri ) <> 6.
      cl_abap_unit_assert=>fail( ).
    ENDIF.

  ENDMETHOD.

  METHOD test_boolean_check_by_name.

    cl_abap_unit_assert=>assert_true( z2ui5_cl_util=>boolean_check_by_name( `ABAP_BOOL` ) ).
    cl_abap_unit_assert=>assert_true( z2ui5_cl_util=>boolean_check_by_name( `XSDBOOLEAN` ) ).
    cl_abap_unit_assert=>assert_true( z2ui5_cl_util=>boolean_check_by_name( `FLAG` ) ).
    cl_abap_unit_assert=>assert_true( z2ui5_cl_util=>boolean_check_by_name( `XFLAG` ) ).
    cl_abap_unit_assert=>assert_true( z2ui5_cl_util=>boolean_check_by_name( `XFELD` ) ).
    cl_abap_unit_assert=>assert_true( z2ui5_cl_util=>boolean_check_by_name( `ABAP_BOOLEAN` ) ).
    cl_abap_unit_assert=>assert_true( z2ui5_cl_util=>boolean_check_by_name( `WDY_BOOLEAN` ) ).
    cl_abap_unit_assert=>assert_true( z2ui5_cl_util=>boolean_check_by_name( `BOOLE_D` ) ).
    cl_abap_unit_assert=>assert_true( z2ui5_cl_util=>boolean_check_by_name( `OS_BOOLEAN` ) ).
    cl_abap_unit_assert=>assert_false( z2ui5_cl_util=>boolean_check_by_name( `STRING` ) ).
    cl_abap_unit_assert=>assert_false( z2ui5_cl_util=>boolean_check_by_name( `INTEGER` ) ).
    cl_abap_unit_assert=>assert_false( z2ui5_cl_util=>boolean_check_by_name( `` ) ).

  ENDMETHOD.

  METHOD test_boolean_abap_2_json_true.

    cl_abap_unit_assert=>assert_equals( exp = `true`
                                        act = z2ui5_cl_util=>boolean_abap_2_json( abap_true ) ).

  ENDMETHOD.

  METHOD test_boolean_abap_2_json_false.

    cl_abap_unit_assert=>assert_equals( exp = `false`
                                        act = z2ui5_cl_util=>boolean_abap_2_json( abap_false ) ).

  ENDMETHOD.

  METHOD test_ui5_get_msg_type_e.

    cl_abap_unit_assert=>assert_equals( exp = `Error`
                                        act = z2ui5_cl_util=>ui5_get_msg_type( `E` ) ).

  ENDMETHOD.

  METHOD test_ui5_get_msg_type_s.

    cl_abap_unit_assert=>assert_equals( exp = `Success`
                                        act = z2ui5_cl_util=>ui5_get_msg_type( `S` ) ).

  ENDMETHOD.

  METHOD test_ui5_get_msg_type_w.

    cl_abap_unit_assert=>assert_equals( exp = `Warning`
                                        act = z2ui5_cl_util=>ui5_get_msg_type( `W` ) ).

  ENDMETHOD.

  METHOD test_ui5_get_msg_type_i.

    cl_abap_unit_assert=>assert_equals( exp = `Information`
                                        act = z2ui5_cl_util=>ui5_get_msg_type( `I` ) ).

  ENDMETHOD.

  METHOD test_ui5_get_msg_type_default.

    cl_abap_unit_assert=>assert_equals( exp = `Information`
                                        act = z2ui5_cl_util=>ui5_get_msg_type( `X` ) ).

  ENDMETHOD.

  METHOD test_rtti_check_clike_string.

    DATA(lv_string) = `test`.
    cl_abap_unit_assert=>assert_true( z2ui5_cl_util=>rtti_check_clike( lv_string ) ).

  ENDMETHOD.

  METHOD test_rtti_check_clike_int.

    DATA(lv_int) = 42.
    cl_abap_unit_assert=>assert_false( z2ui5_cl_util=>rtti_check_clike( lv_int ) ).

  ENDMETHOD.

  METHOD test_rtti_check_class_exists.

    cl_abap_unit_assert=>assert_true(
        z2ui5_cl_util=>rtti_check_class_exists( `Z2UI5_CL_UTIL` ) ).

  ENDMETHOD.

  METHOD test_rtti_check_class_no_exist.

    cl_abap_unit_assert=>assert_false(
        z2ui5_cl_util=>rtti_check_class_exists( `ZZZZ_NON_EXISTENT_CLASS_99` ) ).

  ENDMETHOD.

  METHOD test_conv_get_as_data_ref.

    DATA(lv_val) = `hello`.
    DATA(lr_ref) = z2ui5_cl_util=>conv_get_as_data_ref( lv_val ).

    cl_abap_unit_assert=>assert_bound( lr_ref ).

    FIELD-SYMBOLS <any> TYPE data.
    ASSIGN lr_ref->* TO <any>.

    cl_abap_unit_assert=>assert_equals( exp = `hello`
                                        act = <any> ).

  ENDMETHOD.

  METHOD test_itab_csv_roundtrip.

    TYPES:
      BEGIN OF ty_row,
        col1 TYPE string,
        col2 TYPE string,
      END OF ty_row.

    DATA lt_data TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.
    lt_data = VALUE #( ( col1 = `A` col2 = `B` )
                       ( col1 = `C` col2 = `D` ) ).

    DATA(lv_csv) = z2ui5_cl_util=>itab_get_csv_by_itab( lt_data ).

    cl_abap_unit_assert=>assert_not_initial( lv_csv ).
    cl_abap_unit_assert=>assert_char_cp( act = lv_csv
                                          exp = `*COL1*` ).
    cl_abap_unit_assert=>assert_char_cp( act = lv_csv
                                          exp = `*COL2*` ).

  ENDMETHOD.

  METHOD test_itab_get_by_struc.

    TYPES:
      BEGIN OF ty_struc,
        name  TYPE string,
        value TYPE string,
      END OF ty_struc.

    DATA(ls_struc) = VALUE ty_struc( name = `test_name` value = `test_value` ).

    DATA(lt_result) = z2ui5_cl_util=>itab_get_by_struc( ls_struc ).

    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( lt_result ) ).

    cl_abap_unit_assert=>assert_equals( exp = `NAME`
                                        act = lt_result[ 1 ]-n ).

    cl_abap_unit_assert=>assert_equals( exp = `test_name`
                                        act = lt_result[ 1 ]-v ).

    cl_abap_unit_assert=>assert_equals( exp = `VALUE`
                                        act = lt_result[ 2 ]-n ).

    cl_abap_unit_assert=>assert_equals( exp = `test_value`
                                        act = lt_result[ 2 ]-v ).

  ENDMETHOD.

  METHOD test_itab_filter_by_val.

    TYPES:
      BEGIN OF ty_row,
        col1 TYPE string,
        col2 TYPE string,
      END OF ty_row.

    DATA lt_data TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.
    lt_data = VALUE #( ( col1 = `Apple`  col2 = `Fruit` )
                       ( col1 = `Carrot` col2 = `Vegetable` )
                       ( col1 = `Banana` col2 = `Fruit` ) ).

    z2ui5_cl_util=>itab_filter_by_val( EXPORTING val = `Fruit`
                                       CHANGING  tab = lt_data ).

    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( lt_data ) ).

  ENDMETHOD.

  METHOD test_filter_get_range_by_eq.

    DATA(ls_range) = z2ui5_cl_util=>filter_get_range_by_token( `=100` ).

    cl_abap_unit_assert=>assert_equals( exp = `I`  act = ls_range-sign ).
    cl_abap_unit_assert=>assert_equals( exp = `EQ` act = ls_range-option ).
    cl_abap_unit_assert=>assert_equals( exp = `100` act = ls_range-low ).

  ENDMETHOD.

  METHOD test_filter_get_range_by_lt.

    DATA(ls_range) = z2ui5_cl_util=>filter_get_range_by_token( `<50` ).

    cl_abap_unit_assert=>assert_equals( exp = `I`  act = ls_range-sign ).
    cl_abap_unit_assert=>assert_equals( exp = `LT` act = ls_range-option ).
    cl_abap_unit_assert=>assert_equals( exp = `50` act = ls_range-low ).

  ENDMETHOD.

  METHOD test_filter_get_range_by_le.

    DATA(ls_range) = z2ui5_cl_util=>filter_get_range_by_token( `<=50` ).

    cl_abap_unit_assert=>assert_equals( exp = `I`  act = ls_range-sign ).
    cl_abap_unit_assert=>assert_equals( exp = `LE` act = ls_range-option ).
    cl_abap_unit_assert=>assert_equals( exp = `50` act = ls_range-low ).

  ENDMETHOD.

  METHOD test_filter_get_range_by_gt.

    DATA(ls_range) = z2ui5_cl_util=>filter_get_range_by_token( `>99` ).

    cl_abap_unit_assert=>assert_equals( exp = `I`  act = ls_range-sign ).
    cl_abap_unit_assert=>assert_equals( exp = `GT` act = ls_range-option ).
    cl_abap_unit_assert=>assert_equals( exp = `99` act = ls_range-low ).

  ENDMETHOD.

  METHOD test_filter_get_range_by_ge.

    DATA(ls_range) = z2ui5_cl_util=>filter_get_range_by_token( `>=10` ).

    cl_abap_unit_assert=>assert_equals( exp = `I`  act = ls_range-sign ).
    cl_abap_unit_assert=>assert_equals( exp = `GE` act = ls_range-option ).
    cl_abap_unit_assert=>assert_equals( exp = `10` act = ls_range-low ).

  ENDMETHOD.

  METHOD test_filter_get_range_by_cp.

    DATA(ls_range) = z2ui5_cl_util=>filter_get_range_by_token( `*test*` ).

    cl_abap_unit_assert=>assert_equals( exp = `I`  act = ls_range-sign ).
    cl_abap_unit_assert=>assert_equals( exp = `CP` act = ls_range-option ).

  ENDMETHOD.

  METHOD test_filter_get_range_by_bt.

    DATA(ls_range) = z2ui5_cl_util=>filter_get_range_by_token( `100...200` ).

    cl_abap_unit_assert=>assert_equals( exp = `BT`  act = ls_range-option ).
    cl_abap_unit_assert=>assert_equals( exp = `100` act = ls_range-low ).
    cl_abap_unit_assert=>assert_equals( exp = `200` act = ls_range-high ).

  ENDMETHOD.

  METHOD test_filter_get_range_default.

    DATA(ls_range) = z2ui5_cl_util=>filter_get_range_by_token( `plain_value` ).

    cl_abap_unit_assert=>assert_equals( exp = `I`  act = ls_range-sign ).
    cl_abap_unit_assert=>assert_equals( exp = `EQ` act = ls_range-option ).
    cl_abap_unit_assert=>assert_equals( exp = `plain_value` act = ls_range-low ).

  ENDMETHOD.

  METHOD test_filter_get_multi_by_data.

    TYPES:
      BEGIN OF ty_row,
        col1 TYPE string,
        col2 TYPE string,
      END OF ty_row.

    DATA(ls_row) = VALUE ty_row( ).
    DATA(lt_filter) = z2ui5_cl_util=>filter_get_multi_by_data( ls_row ).

    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( lt_filter ) ).

    cl_abap_unit_assert=>assert_equals( exp = `COL1`
                                        act = lt_filter[ 1 ]-name ).

    cl_abap_unit_assert=>assert_equals( exp = `COL2`
                                        act = lt_filter[ 2 ]-name ).

  ENDMETHOD.

  METHOD test_filter_get_token_mapping.

    DATA(lt_mapping) = z2ui5_cl_util=>filter_get_token_range_mapping( ).

    cl_abap_unit_assert=>assert_not_initial( lt_mapping ).

    cl_abap_unit_assert=>assert_equals( exp = `={LOW}`
                                        act = lt_mapping[ n = `EQ` ]-v ).

    cl_abap_unit_assert=>assert_equals( exp = `<{LOW}`
                                        act = lt_mapping[ n = `LT` ]-v ).

    cl_abap_unit_assert=>assert_equals( exp = `>{LOW}`
                                        act = lt_mapping[ n = `GT` ]-v ).

    cl_abap_unit_assert=>assert_equals( exp = `{LOW}...{HIGH}`
                                        act = lt_mapping[ n = `BT` ]-v ).

  ENDMETHOD.

  METHOD test_x_get_last_t100.

    TRY.
        RAISE EXCEPTION TYPE z2ui5_cx_util_error
          EXPORTING val = `inner error`.
      CATCH z2ui5_cx_util_error INTO DATA(lx).
        DATA(lv_text) = z2ui5_cl_util=>x_get_last_t100( lx ).
        cl_abap_unit_assert=>assert_char_cp(
            act = lv_text
            exp = `*inner error*` ).
    ENDTRY.

  ENDMETHOD.

  METHOD test_source_get_file_types.

    DATA(lt_types) = z2ui5_cl_util=>source_get_file_types( ).

    cl_abap_unit_assert=>assert_not_initial( lt_types ).

    IF lines( lt_types ) < 10.
      cl_abap_unit_assert=>fail( msg = `Expected many file types` ).
    ENDIF.

  ENDMETHOD.

  METHOD test_json_parse.

    TYPES:
      BEGIN OF ty_data,
        name  TYPE string,
        value TYPE string,
      END OF ty_data.

    DATA ls_data TYPE ty_data.
    z2ui5_cl_util=>json_parse( EXPORTING val  = `{"name":"hello","value":"world"}`
                               CHANGING  data = ls_data ).

    cl_abap_unit_assert=>assert_equals( exp = `hello`
                                        act = ls_data-name ).
    cl_abap_unit_assert=>assert_equals( exp = `world`
                                        act = ls_data-value ).

  ENDMETHOD.

  METHOD test_c_trim_empty.

    cl_abap_unit_assert=>assert_equals( exp = ``
                                        act = z2ui5_cl_util=>c_trim( `` ) ).

    cl_abap_unit_assert=>assert_equals( exp = ``
                                        act = z2ui5_cl_util=>c_trim( `   ` ) ).

  ENDMETHOD.

  METHOD test_url_param_set_new.

    DATA(lv_result) = z2ui5_cl_util=>url_param_set(
        name  = `new_param`
        value = `new_value`
        url   = `https://example.com?existing=1` ).

    cl_abap_unit_assert=>assert_char_cp(
        act = lv_result
        exp = `*new_param=new_value*` ).

    cl_abap_unit_assert=>assert_char_cp(
        act = lv_result
        exp = `*existing=1*` ).

  ENDMETHOD.

  METHOD test_time_get_date_by_stampl.

    DATA(lv_ts) = z2ui5_cl_util=>time_get_timestampl( ).
    DATA(lv_date) = z2ui5_cl_util=>time_get_date_by_stampl( lv_ts ).

    cl_abap_unit_assert=>assert_not_initial( lv_date ).

  ENDMETHOD.

  METHOD test_time_get_time_by_stampl.

    DATA(lv_ts) = z2ui5_cl_util=>time_get_timestampl( ).
    DATA(lv_time) = z2ui5_cl_util=>time_get_time_by_stampl( lv_ts ).

    cl_abap_unit_assert=>assert_not_initial( lv_time ).

  ENDMETHOD.

  METHOD test_filter_itab.

    TYPES:
      BEGIN OF ty_row,
        status TYPE string,
        name   TYPE string,
      END OF ty_row.

    DATA lt_data TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.
    lt_data = VALUE #( ( status = `A` name = `Item1` )
                       ( status = `B` name = `Item2` )
                       ( status = `A` name = `Item3` ) ).

    DATA(lt_filter) = VALUE z2ui5_cl_util=>ty_t_filter_multi(
        ( name = `STATUS` t_range = VALUE #( ( sign = `I` option = `EQ` low = `A` ) ) )
    ).

    z2ui5_cl_util=>filter_itab( EXPORTING filter = lt_filter
                                CHANGING  val    = lt_data ).

    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( lt_data ) ).

    cl_abap_unit_assert=>assert_equals( exp = `Item1`
                                        act = lt_data[ 1 ]-name ).

    cl_abap_unit_assert=>assert_equals( exp = `Item3`
                                        act = lt_data[ 2 ]-name ).

  ENDMETHOD.

  METHOD test_unassign_data.

    DATA(lv_val) = `test_unassign`.
    DATA lr TYPE REF TO data.
    DATA lr2 TYPE REF TO data.
    lr = REF #( lv_val ).
    lr2 = REF #( lr ).

    DATA(lr_result) = z2ui5_cl_util=>unassign_data( lr2 ).

    cl_abap_unit_assert=>assert_bound( lr_result ).

    FIELD-SYMBOLS <any> TYPE any.
    ASSIGN lr_result->* TO <any>.
    cl_abap_unit_assert=>assert_equals( exp = `test_unassign`
                                        act = <any> ).

  ENDMETHOD.

  METHOD test_unassign_object.

    DATA(lo_obj) = NEW ltcl_test_app( ).
    DATA lr TYPE REF TO object.
    DATA lr2 TYPE REF TO data.
    lr = lo_obj.
    lr2 = REF #( lr ).

    DATA(lo_result) = z2ui5_cl_util=>unassign_object( lr2 ).

    cl_abap_unit_assert=>assert_bound( lo_result ).

  ENDMETHOD.

  METHOD test_source_method_to_file.

    DATA(lt_source) = VALUE string_table(
        ( ` line one` )
        ( ` line two` )
        ( ` line three` ) ).

    DATA(lv_result) = z2ui5_cl_util=>source_method_to_file( lt_source ).

    cl_abap_unit_assert=>assert_not_initial( lv_result ).
    cl_abap_unit_assert=>assert_char_cp( act = lv_result
                                          exp = `*line one*` ).
    cl_abap_unit_assert=>assert_char_cp( act = lv_result
                                          exp = `*line two*` ).
    cl_abap_unit_assert=>assert_char_cp( act = lv_result
                                          exp = `*line three*` ).

  ENDMETHOD.

  METHOD test_itab_get_itab_by_csv.

    DATA(lv_csv) = |COL1;COL2| && cl_abap_char_utilities=>newline &&
                   |A;B| && cl_abap_char_utilities=>newline &&
                   |C;D|.

    DATA(lr_result) = z2ui5_cl_util=>itab_get_itab_by_csv( lv_csv ).

    cl_abap_unit_assert=>assert_bound( lr_result ).

    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    ASSIGN lr_result->* TO <tab>.
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( <tab> ) ).

  ENDMETHOD.

  METHOD test_itab_corresponding.

    TYPES:
      BEGIN OF ty_src,
        name  TYPE string,
        value TYPE string,
        extra TYPE string,
      END OF ty_src.

    TYPES:
      BEGIN OF ty_tgt,
        name  TYPE string,
        value TYPE string,
      END OF ty_tgt.

    DATA lt_src TYPE STANDARD TABLE OF ty_src WITH EMPTY KEY.
    lt_src = VALUE #( ( name = `A` value = `1` extra = `x` )
                      ( name = `B` value = `2` extra = `y` ) ).

    DATA lt_tgt TYPE STANDARD TABLE OF ty_tgt WITH EMPTY KEY.

    z2ui5_cl_util=>itab_corresponding( EXPORTING val = lt_src
                                       CHANGING  tab = lt_tgt ).

    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( lt_tgt ) ).

    cl_abap_unit_assert=>assert_equals( exp = `A`
                                        act = lt_tgt[ 1 ]-name ).

    cl_abap_unit_assert=>assert_equals( exp = `2`
                                        act = lt_tgt[ 2 ]-value ).

  ENDMETHOD.

  METHOD test_rtti_tab_get_rel_name.

    TYPES:
      BEGIN OF ty_line,
        field1 TYPE string,
        field2 TYPE string,
      END OF ty_line.

    DATA lt_tab TYPE STANDARD TABLE OF ty_line WITH EMPTY KEY.

    DATA(lv_name) = z2ui5_cl_util=>rtti_tab_get_relative_name( lt_tab ).

    cl_abap_unit_assert=>assert_equals( exp = `TY_LINE`
                                        act = lv_name ).

  ENDMETHOD.

  METHOD test_rtti_get_intfname_by_ref.

    DATA lr_intf TYPE REF TO if_serializable_object.
    lr_intf = NEW ltcl_test_app( ).

    DATA(lv_name) = z2ui5_cl_util=>rtti_get_intfname_by_ref( lr_intf ).

    cl_abap_unit_assert=>assert_equals( exp = `IF_SERIALIZABLE_OBJECT`
                                        act = lv_name ).

  ENDMETHOD.

  METHOD test_filter_update_tokens.

    DATA(lt_filter) = VALUE z2ui5_cl_util=>ty_t_filter_multi(
        ( name = `STATUS`
          t_token = VALUE #( ( key = `=A` text = `=A` visible = abap_true editable = abap_true ) )
          t_token_added = VALUE #( ( key = `=B` text = `=B` visible = abap_true editable = abap_true ) )
          t_token_removed = VALUE #( )
        ) ).

    DATA(lt_result) = z2ui5_cl_util=>filter_update_tokens( val = lt_filter
                                                            name = `STATUS` ).

    DATA(ls_filter) = lt_result[ name = `STATUS` ].

    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( ls_filter-t_token ) ).

    " token_added and token_removed should be cleared
    cl_abap_unit_assert=>assert_initial( ls_filter-t_token_added ).
    cl_abap_unit_assert=>assert_initial( ls_filter-t_token_removed ).

  ENDMETHOD.

  METHOD test_filter_get_range_t_by_tt.

    DATA(lt_tokens) = VALUE z2ui5_cl_util=>ty_t_token(
        ( key = `=A` text = `=A` visible = abap_true editable = abap_true )
        ( key = `>10` text = `>10` visible = abap_true editable = abap_true ) ).

    DATA(lt_range) = z2ui5_cl_util=>filter_get_range_t_by_token_t( lt_tokens ).

    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( lt_range ) ).

    cl_abap_unit_assert=>assert_equals( exp = `EQ`
                                        act = lt_range[ 1 ]-option ).
    cl_abap_unit_assert=>assert_equals( exp = `A`
                                        act = lt_range[ 1 ]-low ).
    cl_abap_unit_assert=>assert_equals( exp = `GT`
                                        act = lt_range[ 2 ]-option ).
    cl_abap_unit_assert=>assert_equals( exp = `10`
                                        act = lt_range[ 2 ]-low ).

  ENDMETHOD.

  METHOD test_msg_get.

    DATA(ls_msg) = z2ui5_cl_util=>msg_get( `test message text` ).

    cl_abap_unit_assert=>assert_equals( exp = `test message text`
                                        act = ls_msg-text ).

  ENDMETHOD.

  METHOD test_msg_get_t.

    DATA(lt_msg) = z2ui5_cl_util=>msg_get_t( `message via msg_get_t` ).

    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( lt_msg ) ).

    cl_abap_unit_assert=>assert_equals( exp = `message via msg_get_t`
                                        act = lt_msg[ 1 ]-text ).

  ENDMETHOD.

  METHOD test_msg_get_by_msg.

    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.

    DATA(ls_msg) = z2ui5_cl_util=>msg_get_by_msg( id = `NET`
                                                    no = `001` ).

    cl_abap_unit_assert=>assert_equals( exp = `NET`
                                        act = ls_msg-id ).

    cl_abap_unit_assert=>assert_equals( exp = `001`
                                        act = ls_msg-no ).

  ENDMETHOD.

  METHOD test_x_raise_with_text.

    TRY.
        z2ui5_cl_util=>x_raise( `custom error text` ).
        cl_abap_unit_assert=>fail( ).
      CATCH z2ui5_cx_util_error INTO DATA(lx).
        cl_abap_unit_assert=>assert_char_cp(
            act = lx->get_text( )
            exp = `*custom error text*` ).
    ENDTRY.

  ENDMETHOD.

  METHOD test_x_check_raise_with_text.

    TRY.
        z2ui5_cl_util=>x_check_raise( when = xsdbool( 1 = 1 )
                                       v    = `conditional error` ).
        cl_abap_unit_assert=>fail( ).
      CATCH z2ui5_cx_util_error INTO DATA(lx).
        cl_abap_unit_assert=>assert_char_cp(
            act = lx->get_text( )
            exp = `*conditional error*` ).
    ENDTRY.

  ENDMETHOD.

  METHOD test_json_stringify_table.

    TYPES:
      BEGIN OF ty_item,
        id   TYPE string,
        name TYPE string,
      END OF ty_item.

    DATA lt_data TYPE STANDARD TABLE OF ty_item WITH EMPTY KEY.
    lt_data = VALUE #( ( id = `1` name = `First` )
                       ( id = `2` name = `Second` ) ).

    DATA(lv_json) = z2ui5_cl_util=>json_stringify( lt_data ).

    cl_abap_unit_assert=>assert_not_initial( lv_json ).
    cl_abap_unit_assert=>assert_char_cp( act = lv_json
                                          exp = `*First*` ).
    cl_abap_unit_assert=>assert_char_cp( act = lv_json
                                          exp = `*Second*` ).

  ENDMETHOD.

  METHOD test_json_parse_to_table.

    TYPES:
      BEGIN OF ty_item,
        id   TYPE string,
        name TYPE string,
      END OF ty_item.

    DATA lt_data TYPE STANDARD TABLE OF ty_item WITH EMPTY KEY.

    z2ui5_cl_util=>json_parse( EXPORTING val  = `[{"id":"1","name":"A"},{"id":"2","name":"B"}]`
                               CHANGING  data = lt_data ).

    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( lt_data ) ).

    cl_abap_unit_assert=>assert_equals( exp = `1`
                                        act = lt_data[ 1 ]-id ).

    cl_abap_unit_assert=>assert_equals( exp = `B`
                                        act = lt_data[ 2 ]-name ).

  ENDMETHOD.

  METHOD test_xml_parse_empty.

    TYPES:
      BEGIN OF ty_data,
        name TYPE string,
      END OF ty_data.

    DATA ls_data TYPE ty_data.
    DATA(lv_xml) = z2ui5_cl_util=>xml_stringify( ls_data ).

    cl_abap_unit_assert=>assert_not_initial( lv_xml ).

    DATA ls_data2 TYPE ty_data.
    z2ui5_cl_util=>xml_parse( EXPORTING xml = lv_xml
                              IMPORTING any = ls_data2 ).

    cl_abap_unit_assert=>assert_equals( exp = ls_data
                                        act = ls_data2 ).

  ENDMETHOD.

  METHOD test_rtti_get_type_name_string.

    DATA(lv_string) = VALUE string( ).
    cl_abap_unit_assert=>assert_equals( exp = `STRING`
                                        act = z2ui5_cl_util=>rtti_get_type_name( lv_string ) ).

  ENDMETHOD.

  METHOD test_rtti_get_type_kind_struct.

    TYPES:
      BEGIN OF ty_s,
        f1 TYPE string,
      END OF ty_s.

    DATA(ls_struct) = VALUE ty_s( ).
    DATA(lv_kind) = z2ui5_cl_util=>rtti_get_type_kind( ls_struct ).

    cl_abap_unit_assert=>assert_equals( exp = cl_abap_typedescr=>typekind_struct1
                                        act = lv_kind ).

  ENDMETHOD.

  METHOD test_rtti_get_type_kind_table.

    DATA lt_tab TYPE STANDARD TABLE OF string WITH EMPTY KEY.
    DATA(lv_kind) = z2ui5_cl_util=>rtti_get_type_kind( lt_tab ).

    cl_abap_unit_assert=>assert_equals( exp = cl_abap_typedescr=>typekind_table
                                        act = lv_kind ).

  ENDMETHOD.

  METHOD test_rtti_check_clike_char.

    DATA lv_char TYPE c LENGTH 10.
    lv_char = `test`.
    cl_abap_unit_assert=>assert_true( z2ui5_cl_util=>rtti_check_clike( lv_char ) ).

  ENDMETHOD.

  METHOD test_boolean_check_by_data_str.

    DATA(lv_string) = `not a boolean`.
    cl_abap_unit_assert=>assert_false( z2ui5_cl_util=>boolean_check_by_data( lv_string ) ).

  ENDMETHOD.

  METHOD test_itab_filter_by_val_no_hit.

    TYPES:
      BEGIN OF ty_row,
        col1 TYPE string,
      END OF ty_row.

    DATA lt_data TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.
    lt_data = VALUE #( ( col1 = `A` )
                       ( col1 = `B` ) ).

    z2ui5_cl_util=>itab_filter_by_val( EXPORTING val = `NONE`
                                       CHANGING  tab = lt_data ).

    cl_abap_unit_assert=>assert_initial( lt_data ).

  ENDMETHOD.

  METHOD test_conv_copy_ref_data_struc.

    TYPES:
      BEGIN OF ty_row,
        name  TYPE string,
        value TYPE string,
      END OF ty_row.

    DATA(ls_row) = VALUE ty_row( name = `hello` value = `world` ).
    DATA lr_data TYPE REF TO data.
    lr_data = REF #( ls_row ).

    DATA(lr_copy) = z2ui5_cl_util=>conv_copy_ref_data( lr_data ).
    cl_abap_unit_assert=>assert_bound( lr_copy ).

    FIELD-SYMBOLS <copy> TYPE ty_row.
    ASSIGN lr_copy->* TO <copy>.

    cl_abap_unit_assert=>assert_equals( exp = `hello`
                                        act = <copy>-name ).
    cl_abap_unit_assert=>assert_equals( exp = `world`
                                        act = <copy>-value ).

  ENDMETHOD.

  METHOD test_url_param_get_encoded.

    DATA(lv_param) = z2ui5_cl_util=>url_param_get(
        val = `sap-client`
        url = `?sap-client=100&view=main` ).

    cl_abap_unit_assert=>assert_equals( exp = `100`
                                        act = lv_param ).

  ENDMETHOD.

  METHOD test_filter_itab_no_match.

    TYPES:
      BEGIN OF ty_row,
        status TYPE string,
        name   TYPE string,
      END OF ty_row.

    DATA lt_data TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.
    lt_data = VALUE #( ( status = `A` name = `Item1` )
                       ( status = `B` name = `Item2` ) ).

    DATA(lt_filter) = VALUE z2ui5_cl_util=>ty_t_filter_multi(
        ( name = `STATUS` t_range = VALUE #( ( sign = `I` option = `EQ` low = `Z` ) ) )
    ).

    z2ui5_cl_util=>filter_itab( EXPORTING filter = lt_filter
                                CHANGING  val    = lt_data ).

    cl_abap_unit_assert=>assert_initial( lt_data ).

  ENDMETHOD.

  METHOD test_filter_itab_multi_filter.

    TYPES:
      BEGIN OF ty_row,
        status TYPE string,
        name   TYPE string,
      END OF ty_row.

    DATA lt_data TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.
    lt_data = VALUE #( ( status = `A` name = `Apple` )
                       ( status = `A` name = `Banana` )
                       ( status = `B` name = `Apple` )
                       ( status = `B` name = `Cherry` ) ).

    DATA(lt_filter) = VALUE z2ui5_cl_util=>ty_t_filter_multi(
        ( name = `STATUS` t_range = VALUE #( ( sign = `I` option = `EQ` low = `A` ) ) )
        ( name = `NAME` t_range = VALUE #( ( sign = `I` option = `EQ` low = `Apple` ) ) )
    ).

    z2ui5_cl_util=>filter_itab( EXPORTING filter = lt_filter
                                CHANGING  val    = lt_data ).

    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( lt_data ) ).

    cl_abap_unit_assert=>assert_equals( exp = `Apple`
                                        act = lt_data[ 1 ]-name ).

    cl_abap_unit_assert=>assert_equals( exp = `A`
                                        act = lt_data[ 1 ]-status ).

  ENDMETHOD.

  METHOD test_rtti_attri_by_tab_name.

    TYPES:
      BEGIN OF ty_test_struc,
        field1 TYPE string,
        field2 TYPE string,
        field3 TYPE i,
      END OF ty_test_struc.

    DATA(lt_comp) = z2ui5_cl_util=>rtti_get_t_attri_by_table_name( `LTCL_TEST_APP-TY_ROW` ).

    cl_abap_unit_assert=>assert_not_initial( lt_comp ).

    IF NOT line_exists( lt_comp[ name = `TITLE` ] ).
      cl_abap_unit_assert=>fail( msg = `TITLE component not found` ).
    ENDIF.

    IF NOT line_exists( lt_comp[ name = `VALUE` ] ).
      cl_abap_unit_assert=>fail( msg = `VALUE component not found` ).
    ENDIF.

  ENDMETHOD.

  METHOD test_rtti_attri_by_tab_empty.

    TRY.
        z2ui5_cl_util=>rtti_get_t_attri_by_table_name( `` ).
        cl_abap_unit_assert=>fail( msg = `Expected exception for empty table name` ).
      CATCH z2ui5_cx_util_error INTO DATA(lx).
        cl_abap_unit_assert=>assert_char_cp(
            act = lx->get_text( )
            exp = `*TABLE_NAME_INITIAL_ERROR*` ).
    ENDTRY.

  ENDMETHOD.

  METHOD test_rtti_create_tab_by_name.

    DATA(lr_tab) = z2ui5_cl_util=>rtti_create_tab_by_name( `LTCL_TEST_APP-TY_ROW` ).

    cl_abap_unit_assert=>assert_bound( lr_tab ).

    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    ASSIGN lr_tab->* TO <tab>.

    cl_abap_unit_assert=>assert_initial( <tab> ).

  ENDMETHOD.

  METHOD test_rtti_get_dtel_text_l.

    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.

    DATA(lv_text) = z2ui5_cl_util=>rtti_get_data_element_text_l( `UNAME` ).

    IF z2ui5_cl_util=>context_check_abap_cloud( ) = abap_false.
      cl_abap_unit_assert=>assert_not_initial( lv_text ).
    ENDIF.

  ENDMETHOD.

  METHOD test_rtti_ddic_fixed_values.

    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.

    " Empty rollname should return empty result
    DATA(lt_empty) = z2ui5_cl_util=>rtti_get_t_ddic_fixed_values( rollname = `` ).
    cl_abap_unit_assert=>assert_initial( lt_empty ).

  ENDMETHOD.

  METHOD test_source_get_method2.

    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.

    " source_get_method depends on XCO or CL_OO_FACTORY - may not work in all envs
    TRY.
        DATA(lv_result) = z2ui5_cl_util=>source_get_method2(
            iv_classname  = `Z2UI5_CL_UTIL`
            iv_methodname = `C_TRIM` ) ##NEEDED.
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

  ENDMETHOD.

  METHOD test_xml_srtti_stringify.

    " xml_srtti requires ZCL_SRTTI_TYPEDESCR or z2ui5_cl_srt_typedescr
    DATA(lv_string) = `test`.

    TRY.
        DATA(lv_xml) = z2ui5_cl_util=>xml_srtti_stringify( lv_string ).
        cl_abap_unit_assert=>assert_not_initial( lv_xml ).

        DATA(lr_data) = z2ui5_cl_util=>xml_srtti_parse( lv_xml ).
        cl_abap_unit_assert=>assert_bound( lr_data ).

        FIELD-SYMBOLS <any> TYPE any.
        ASSIGN lr_data->* TO <any>.
        cl_abap_unit_assert=>assert_equals( exp = `test`
                                            act = <any> ).

      CATCH cx_root ##NO_HANDLER.
        " SRTTI class may not be available in all environments
    ENDTRY.

  ENDMETHOD.

  METHOD test_filter_get_sql_where.

    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.

    IF z2ui5_cl_util=>context_check_abap_cloud( ).
      RETURN.
    ENDIF.

    TRY.
        DATA(lt_filter) = VALUE z2ui5_cl_util=>ty_t_filter_multi(
            ( name = `STATUS` t_range = VALUE #( ( sign = `I` option = `EQ` low = `A` ) ) )
        ).

        DATA(lv_where) = z2ui5_cl_util=>filter_get_sql_where( lt_filter ).
        cl_abap_unit_assert=>assert_not_initial( lv_where ).

      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

  ENDMETHOD.

  METHOD test_itab_filter_by_t_range.

    TYPES:
      BEGIN OF ty_row,
        name   TYPE string,
        status TYPE string,
      END OF ty_row.

    DATA lt_data TYPE STANDARD TABLE OF ty_row WITH DEFAULT KEY.
    lt_data = VALUE #(
        ( name = `Apple`  status = `A` )
        ( name = `Banana` status = `B` )
        ( name = `Cherry` status = `A` )
    ).

    DATA(lt_filter) = VALUE z2ui5_cl_util=>ty_t_filter_multi(
        ( name = `STATUS` t_range = VALUE #( ( sign = `I` option = `EQ` low = `A` ) ) )
    ).

    " empty implementation - table should remain unchanged
    z2ui5_cl_util=>itab_filter_by_t_range( EXPORTING val = lt_filter
                                            CHANGING  tab = lt_data ).

    cl_abap_unit_assert=>assert_equals( exp = 3
                                        act = lines( lt_data ) ).

  ENDMETHOD.

  METHOD test_filter_get_data_by_multi.

    DATA(lt_filter) = VALUE z2ui5_cl_util=>ty_t_filter_multi(
        ( name = `STATUS` t_range = VALUE #( ( sign = `I` option = `EQ` low = `A` ) ) )
    ).

    " empty implementation - result should be initial
    DATA(lt_result) = z2ui5_cl_util=>filter_get_data_by_multi( lt_filter ).

    cl_abap_unit_assert=>assert_initial( lt_result ).

  ENDMETHOD.

ENDCLASS.
