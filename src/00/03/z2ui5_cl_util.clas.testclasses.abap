
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


CLASS ltcl_unit_test_abap_api DEFINITION FINAL
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


CLASS ltcl_unit_test_abap_api IMPLEMENTATION.
  METHOD test_assign.

    DATA(lo_app) = NEW ltcl_test_app( ).
    FIELD-SYMBOLS <any> TYPE any.

    lo_app->mv_val = `ABC`.

    DATA(lv_assign) = |LO_APP->MV_VAL|.
    ASSIGN (lv_assign) TO <any>.
    ASSERT sy-subrc = 0.

    cl_abap_unit_assert=>assert_equals( exp = `ABC`
                                        act = <any> ).

  ENDMETHOD.

  METHOD test_classdescr.

    DATA(lo_app) = NEW ltcl_test_app( ).

    DATA(lt_attri) = CAST cl_abap_classdescr( cl_abap_objectdescr=>describe_by_object_ref( lo_app ) )->attributes.

    " TODO: variable is assigned but never used (ABAP cleaner)
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

    DATA(lv_search) = replace( val  = `one two three`
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

    DATA(lo_test) = NEW z2ui5_cl_util( ).
    DATA(lv_name) = z2ui5_cl_util=>rtti_get_classname_by_ref( lo_test ).
    cl_abap_unit_assert=>assert_equals( exp = `Z2UI5_CL_UTIL`
                                        act = lv_name ).

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
    GET REFERENCE OF lv_test INTO lr_data.

    cl_abap_unit_assert=>assert_true( z2ui5_cl_util=>rtti_check_ref_data( lr_data ) ).

    cl_abap_unit_assert=>assert_false( z2ui5_cl_util=>rtti_check_ref_data( lv_test ) ).

  ENDMETHOD.

  METHOD conv_copy_ref_data.

    DATA(lv_test) = `test`.
    DATA lr_data TYPE REF TO data.
    GET REFERENCE OF lv_test INTO lr_data.

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

    TRY.
        z2ui5_cl_util=>x_check_raise( xsdbool( 1 = 1 ) ).
        cl_abap_unit_assert=>fail( ).
      CATCH cx_root.
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

    DATA(lt_range) = VALUE z2ui5_cl_util=>ty_t_range( ( sign = 'I' option = 'EQ' low = `table` high = `` )
     ).

    DATA(lt_result) = z2ui5_cl_util=>filter_get_token_t_by_range_t( lt_range ).

    DATA(lt_exp) = VALUE z2ui5_cl_util=>ty_t_token(
                             ( key = `=table` text = `=table` visible = 'X' selkz = '' editable = 'X' )
    ).

    cl_abap_unit_assert=>assert_equals( exp = lt_exp
                                        act = lt_result
    ).

  ENDMETHOD.

  METHOD test_rtti_get_t_attri_by_incl.

    IF sy-sysid = 'ABC'.
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
    DATA(lt_attri) = z2ui5_cl_util=>rtti_get_t_attri_by_include( CAST #( lo_datadescr ) ).

    IF lines( lt_attri ) <> 6.
      cl_abap_unit_assert=>fail( ).
    ENDIF.

  ENDMETHOD.
ENDCLASS.

CLASS ltcl_unit_test_msg_mapper DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS test_bal            FOR TESTING RAISING cx_static_check.
    METHODS test_cx            FOR TESTING RAISING cx_static_check.
    METHODS test_bapiret       FOR TESTING RAISING cx_static_check.
    METHODS test_bapirettab       FOR TESTING RAISING cx_static_check.
    METHODS test_sy       FOR TESTING RAISING cx_static_check.


ENDCLASS.

CLASS ltcl_unit_test_msg_mapper IMPLEMENTATION.

  METHOD test_sy.

    IF sy-sysid = 'ABC'.
      RETURN.
    ENDIF.

    MESSAGE ID 'NET' TYPE 'I' NUMBER '001' INTO DATA(lv_dummy).
    DATA(lt_result) = lcl_msp_mapper=>msg_get( sy ).

   cl_abap_unit_assert=>assert_equals( exp = `NET`
                                        act = lt_result[ 1 ]-id ).

    cl_abap_unit_assert=>assert_equals( exp = `001`
                                    act = lt_result[ 1 ]-no ).

    cl_abap_unit_assert=>assert_equals( exp = `I`
                                        act = lt_result[ 1 ]-type ).

  ENDMETHOD.

  METHOD test_bapiret.

    IF sy-sysid = 'ABC'.
      RETURN.
    ENDIF.

    DATA(lt_msg) = VALUE bapirettab(
      ( type = 'E' id = 'MSG1' number = '001' message = 'An empty Report field causes an empty XML Message to be sent' )
     ).

    DATA(lt_result) = lcl_msp_mapper=>msg_get( lt_msg[ 1 ] ).

    cl_abap_unit_assert=>assert_equals( exp = `MSG1`
                                        act = lt_result[ 1 ]-id ).

    cl_abap_unit_assert=>assert_equals( exp = `001`
                                    act = lt_result[ 1 ]-no ).

    cl_abap_unit_assert=>assert_equals( exp = `E`
                                        act = lt_result[ 1 ]-type ).

  ENDMETHOD.

  METHOD test_bapirettab.

    IF sy-sysid = 'ABC'.
      RETURN.
    ENDIF.

    DATA(lt_msg) = VALUE bapirettab(
      ( type = 'E' id = 'MSG1' number = '001' message = 'An empty Report field causes an empty XML Message to be sent' )
      ( type = 'I' id = 'MSG2' number = '002' message = 'Product already in use' ) ).

    DATA(lt_result) = lcl_msp_mapper=>msg_get( lt_msg ).

   cl_abap_unit_assert=>assert_equals( exp = `MSG1`
                                        act = lt_result[ 1 ]-id ).

    cl_abap_unit_assert=>assert_equals( exp = `001`
                                    act = lt_result[ 1 ]-no ).

    cl_abap_unit_assert=>assert_equals( exp = `E`
                                        act = lt_result[ 1 ]-type ).

  ENDMETHOD.

  METHOD test_cx.

    TRY.
        DATA(lv_val) = 1 / 0.
      CATCH cx_root INTO DATA(lx).
        DATA(lt_result) = lcl_msp_mapper=>msg_get( lx ).
    ENDTRY.

    cl_abap_unit_assert=>assert_equals( exp = `E`
                                        act = lt_result[ 1 ]-type ).


  ENDMETHOD.

  method test_bal.

  TYPES: BEGIN OF ty_log_entry,
         msgnumber   TYPE n LENGTH 6,      " Application Log: Internal Message Serial Number
         msgty       TYPE c LENGTH 1,      " Message Type
         msgid       TYPE c LENGTH 20,     " Message Class
         msgno       TYPE n LENGTH 3,      " Message Number
         msgv1       TYPE c LENGTH 50,     " Message Variable
         msgv2       TYPE c LENGTH 50,     " Message Variable
         msgv3       TYPE c LENGTH 50,     " Message Variable
         msgv4       TYPE c LENGTH 50,     " Message Variable
         msgv1_src   TYPE c LENGTH 15,     " Origin of a Message Variable
         msgv2_src   TYPE c LENGTH 15,     " Origin of a Message Variable
         msgv3_src   TYPE c LENGTH 15,     " Origin of a Message Variable
         msgv4_src   TYPE c LENGTH 15,     " Origin of a Message Variable
         detlevel    TYPE c LENGTH 1,      " Level of Detail
         probclass   TYPE c LENGTH 1,      " Problem Class
         alsort      TYPE c LENGTH 3,      " Sort Criterion/Grouping
         time_stmp   TYPE p LENGTH 8 DECIMALS 7, " Message Time Stamp
         msg_count   TYPE i,               " Cumulated Message Count
         context     TYPE c LENGTH 255,    " Context (Generic Placeholder)
         params      TYPE c LENGTH 255,    " Parameters (Generic Placeholder)
         msg_txt     TYPE string,          " Message Text
       END OF ty_log_entry.

  endmethod.

ENDCLASS.
