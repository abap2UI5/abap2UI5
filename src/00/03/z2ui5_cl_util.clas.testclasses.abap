
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

  METHOD test_func_get_user_tech.

    IF sy-sysid = `ABC`.
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

    DATA(lt_result) = z2ui5_cl_util=>c_split( val = `one;two;three`
                                               sep = `;` ).

    cl_abap_unit_assert=>assert_equals( exp = 3
                                        act = lines( lt_result ) ).
    cl_abap_unit_assert=>assert_equals( exp = `one`   act = lt_result[ 1 ] ).
    cl_abap_unit_assert=>assert_equals( exp = `two`   act = lt_result[ 2 ] ).
    cl_abap_unit_assert=>assert_equals( exp = `three` act = lt_result[ 3 ] ).

  ENDMETHOD.

  METHOD test_c_split_single.

    DATA(lt_result) = z2ui5_cl_util=>c_split( val = `nosep`
                                               sep = `;` ).

    cl_abap_unit_assert=>assert_equals( exp = 1       act = lines( lt_result ) ).
    cl_abap_unit_assert=>assert_equals( exp = `nosep` act = lt_result[ 1 ] ).

  ENDMETHOD.

  METHOD test_c_join.

    DATA(lt_tab) = VALUE string_table( ( `one` ) ( `two` ) ( `three` ) ).
    DATA(lv_result) = z2ui5_cl_util=>c_join( lt_tab ).

    cl_abap_unit_assert=>assert_equals( exp = `onetwothree`
                                        act = lv_result ).

  ENDMETHOD.

  METHOD test_c_join_with_sep.

    DATA(lt_tab) = VALUE string_table( ( `one` ) ( `two` ) ( `three` ) ).
    DATA(lv_result) = z2ui5_cl_util=>c_join( tab = lt_tab
                                              sep = `-` ).

    cl_abap_unit_assert=>assert_equals( exp = `one-two-three`
                                        act = lv_result ).

  ENDMETHOD.

  METHOD test_c_join_empty.

    DATA(lt_tab) = VALUE string_table( ).
    DATA(lv_result) = z2ui5_cl_util=>c_join( lt_tab ).

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

    DATA(ls_struc) = VALUE ty_s( ).
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

    DATA lt_tab TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.

    DATA(lv_name) = z2ui5_cl_util=>rtti_tab_get_relative_name( lt_tab ).
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

ENDCLASS.


CLASS ltcl_unit_test_filter IMPLEMENTATION.

  METHOD test_range_by_token_eq.

    DATA(ls_range) = z2ui5_cl_util=>filter_get_range_by_token( `=ABC` ).

    cl_abap_unit_assert=>assert_equals( exp = `I`   act = ls_range-sign ).
    cl_abap_unit_assert=>assert_equals( exp = `EQ`  act = ls_range-option ).
    cl_abap_unit_assert=>assert_equals( exp = `ABC` act = ls_range-low ).

  ENDMETHOD.

  METHOD test_range_by_token_lt.

    DATA(ls_range) = z2ui5_cl_util=>filter_get_range_by_token( `<100` ).

    cl_abap_unit_assert=>assert_equals( exp = `I`   act = ls_range-sign ).
    cl_abap_unit_assert=>assert_equals( exp = `LT`  act = ls_range-option ).
    cl_abap_unit_assert=>assert_equals( exp = `100` act = ls_range-low ).

  ENDMETHOD.

  METHOD test_range_by_token_le.

    DATA(ls_range) = z2ui5_cl_util=>filter_get_range_by_token( `<=200` ).

    cl_abap_unit_assert=>assert_equals( exp = `I`   act = ls_range-sign ).
    cl_abap_unit_assert=>assert_equals( exp = `LE`  act = ls_range-option ).
    cl_abap_unit_assert=>assert_equals( exp = `200` act = ls_range-low ).

  ENDMETHOD.

  METHOD test_range_by_token_gt.

    DATA(ls_range) = z2ui5_cl_util=>filter_get_range_by_token( `>50` ).

    cl_abap_unit_assert=>assert_equals( exp = `I`  act = ls_range-sign ).
    cl_abap_unit_assert=>assert_equals( exp = `GT` act = ls_range-option ).
    cl_abap_unit_assert=>assert_equals( exp = `50` act = ls_range-low ).

  ENDMETHOD.

  METHOD test_range_by_token_ge.

    DATA(ls_range) = z2ui5_cl_util=>filter_get_range_by_token( `>=75` ).

    cl_abap_unit_assert=>assert_equals( exp = `I`  act = ls_range-sign ).
    cl_abap_unit_assert=>assert_equals( exp = `GE` act = ls_range-option ).
    cl_abap_unit_assert=>assert_equals( exp = `75` act = ls_range-low ).

  ENDMETHOD.

  METHOD test_range_by_token_cp.

    DATA(ls_range) = z2ui5_cl_util=>filter_get_range_by_token( `*test*` ).

    cl_abap_unit_assert=>assert_equals( exp = `I`    act = ls_range-sign ).
    cl_abap_unit_assert=>assert_equals( exp = `CP`   act = ls_range-option ).
    cl_abap_unit_assert=>assert_equals( exp = `test` act = z2ui5_cl_util=>c_trim( ls_range-low ) ).

  ENDMETHOD.

  METHOD test_range_by_token_bt.

    DATA(ls_range) = z2ui5_cl_util=>filter_get_range_by_token( `100...500` ).

    cl_abap_unit_assert=>assert_equals( exp = `I`   act = ls_range-sign ).
    cl_abap_unit_assert=>assert_equals( exp = `BT`  act = ls_range-option ).
    cl_abap_unit_assert=>assert_equals( exp = `100` act = ls_range-low ).
    cl_abap_unit_assert=>assert_equals( exp = `500` act = ls_range-high ).

  ENDMETHOD.

  METHOD test_range_by_token_plain.

    DATA(ls_range) = z2ui5_cl_util=>filter_get_range_by_token( `hello` ).

    cl_abap_unit_assert=>assert_equals( exp = `I`     act = ls_range-sign ).
    cl_abap_unit_assert=>assert_equals( exp = `EQ`    act = ls_range-option ).
    cl_abap_unit_assert=>assert_equals( exp = `hello` act = ls_range-low ).

  ENDMETHOD.

  METHOD test_token_range_mapping.

    DATA(lt_mapping) = z2ui5_cl_util=>filter_get_token_range_mapping( ).

    cl_abap_unit_assert=>assert_not_initial( lt_mapping ).
    cl_abap_unit_assert=>assert_equals( exp = `={LOW}`
                                        act = lt_mapping[ n = `EQ` ]-v ).
    cl_abap_unit_assert=>assert_equals( exp = `<{LOW}`
                                        act = lt_mapping[ n = `LT` ]-v ).
    cl_abap_unit_assert=>assert_equals( exp = `>{LOW}`
                                        act = lt_mapping[ n = `GT` ]-v ).

  ENDMETHOD.

  METHOD test_range_t_by_token_t.

    DATA(lt_tokens) = VALUE z2ui5_cl_util=>ty_t_token(
      ( key = `=100` text = `=100` visible = abap_true editable = abap_true )
      ( key = `>50`  text = `>50`  visible = abap_true editable = abap_true ) ).

    DATA(lt_range) = z2ui5_cl_util=>filter_get_range_t_by_token_t( lt_tokens ).

    cl_abap_unit_assert=>assert_equals( exp = 2 act = lines( lt_range ) ).
    cl_abap_unit_assert=>assert_equals( exp = `EQ` act = lt_range[ 1 ]-option ).
    cl_abap_unit_assert=>assert_equals( exp = `GT` act = lt_range[ 2 ]-option ).

  ENDMETHOD.

  METHOD test_filter_get_multi.

    TYPES:
      BEGIN OF ty_row,
        name  TYPE string,
        value TYPE string,
      END OF ty_row.

    DATA(ls_row) = VALUE ty_row( ).
    DATA(lt_filter) = z2ui5_cl_util=>filter_get_multi_by_data( ls_row ).

    cl_abap_unit_assert=>assert_equals( exp = 2 act = lines( lt_filter ) ).
    cl_abap_unit_assert=>assert_equals( exp = `NAME`  act = lt_filter[ 1 ]-name ).
    cl_abap_unit_assert=>assert_equals( exp = `VALUE` act = lt_filter[ 2 ]-name ).

  ENDMETHOD.

  METHOD test_filter_get_data.

    DATA(lt_filter) = VALUE z2ui5_cl_util=>ty_t_filter_multi(
      ( name = `F1` t_range = VALUE #( ( sign = `I` option = `EQ` low = `A` ) ) )
      ( name = `F2` )
      ( name = `F3` t_token = VALUE #( ( key = `=B` text = `=B` ) ) ) ).

    DATA(lt_result) = z2ui5_cl_util=>filter_get_data_by_multi( lt_filter ).

    cl_abap_unit_assert=>assert_equals( exp = 2 act = lines( lt_result ) ).

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

ENDCLASS.


CLASS ltcl_unit_test_conversion IMPLEMENTATION.

  METHOD test_json_roundtrip.

    TYPES:
      BEGIN OF ty_data,
        name  TYPE string,
        value TYPE i,
        flag  TYPE abap_bool,
      END OF ty_data.

    DATA(ls_in) = VALUE ty_data( name = `test` value = 42 flag = abap_true ).

    DATA(lv_json) = z2ui5_cl_util=>json_stringify( ls_in ).
    cl_abap_unit_assert=>assert_not_initial( lv_json ).

    DATA ls_out TYPE ty_data.
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

    DATA(lt_in) = VALUE STANDARD TABLE OF ty_row WITH EMPTY KEY(
      ( col1 = `A` col2 = `B` )
      ( col1 = `C` col2 = `D` ) ).

    DATA(lv_csv) = z2ui5_cl_util=>itab_get_csv_by_itab( lt_in ).
    cl_abap_unit_assert=>assert_not_initial( lv_csv ).

    cl_abap_unit_assert=>assert_true(
      xsdbool( lv_csv CS `COL1` ) ).
    cl_abap_unit_assert=>assert_true(
      xsdbool( lv_csv CS `COL2` ) ).

  ENDMETHOD.

  METHOD test_conv_get_as_data_ref.

    DATA(lv_val) = `test_value`.
    DATA(lr_ref) = z2ui5_cl_util=>conv_get_as_data_ref( lv_val ).

    cl_abap_unit_assert=>assert_bound( lr_ref ).

    FIELD-SYMBOLS <any> TYPE any.
    ASSIGN lr_ref->* TO <any>.
    cl_abap_unit_assert=>assert_equals( exp = `test_value`
                                        act = <any> ).

  ENDMETHOD.

  METHOD test_conv_string_to_date.

    DATA(lv_date) = z2ui5_cl_util=>conv_string_to_date( `2024-03-15` ).
    cl_abap_unit_assert=>assert_equals( exp = `20240315`
                                        act = lv_date ).

  ENDMETHOD.

  METHOD test_conv_date_to_string.

    DATA(lv_str) = z2ui5_cl_util=>conv_date_to_string( CONV d( `20240315` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `2024-03-15`
                                        act = lv_str ).

  ENDMETHOD.

  METHOD test_conv_date_roundtrip.

    DATA(lv_original) = `2025-12-31`.
    DATA(lv_date) = z2ui5_cl_util=>conv_string_to_date( lv_original ).
    DATA(lv_back) = z2ui5_cl_util=>conv_date_to_string( lv_date ).

    cl_abap_unit_assert=>assert_equals( exp = lv_original
                                        act = lv_back ).

  ENDMETHOD.

  METHOD test_itab_get_by_struc.

    TYPES:
      BEGIN OF ty_s,
        name  TYPE string,
        value TYPE string,
      END OF ty_s.

    DATA(ls_struc) = VALUE ty_s( name = `test_name` value = `test_value` ).
    DATA(lt_nv) = z2ui5_cl_util=>itab_get_by_struc( ls_struc ).

    cl_abap_unit_assert=>assert_equals( exp = 2 act = lines( lt_nv ) ).
    cl_abap_unit_assert=>assert_equals( exp = `NAME`       act = lt_nv[ 1 ]-n ).
    cl_abap_unit_assert=>assert_equals( exp = `test_name`  act = lt_nv[ 1 ]-v ).
    cl_abap_unit_assert=>assert_equals( exp = `VALUE`      act = lt_nv[ 2 ]-n ).
    cl_abap_unit_assert=>assert_equals( exp = `test_value` act = lt_nv[ 2 ]-v ).

  ENDMETHOD.

  METHOD test_time_add_seconds.

    DATA(lv_time) = z2ui5_cl_util=>time_get_timestampl( ).
    DATA(lv_later) = z2ui5_cl_util=>time_add_seconds( time    = lv_time
                                                       seconds = 3600 ).

    cl_abap_unit_assert=>assert_not_initial( lv_later ).

    IF lv_later <= lv_time.
      cl_abap_unit_assert=>fail( `time_add_seconds should return a later timestamp` ).
    ENDIF.

  ENDMETHOD.

  METHOD test_time_diff_seconds.

    DATA(lv_time) = z2ui5_cl_util=>time_get_timestampl( ).
    DATA(lv_later) = z2ui5_cl_util=>time_add_seconds( time    = lv_time
                                                       seconds = 120 ).

    DATA(lv_diff) = z2ui5_cl_util=>time_diff_seconds( time_from = lv_time
                                                       time_to   = lv_later ).

    cl_abap_unit_assert=>assert_equals( exp = 120
                                        act = lv_diff ).

  ENDMETHOD.

ENDCLASS.
