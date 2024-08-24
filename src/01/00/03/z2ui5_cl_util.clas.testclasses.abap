CLASS ltcl_test DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    METHODS  test_db_handle FOR TESTING RAISING cx_static_check.
    METHODS  test_db_handle_read_id FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_test IMPLEMENTATION.

  METHOD test_db_handle.

    IF sy-sysid = 'ABC'.
      RETURN.
    ENDIF.

    TYPES:
      BEGIN OF ty_row,
        title    TYPE string,
        value    TYPE string,
        selected TYPE abap_bool,
      END OF ty_row.

    DATA(ls_row) = VALUE ty_row(
        title    = `test`
        value    = `val`
        selected = abap_true ).
    DATA(ls_row_result) = VALUE ty_row( ).

    DATA(lv_id) = z2ui5_cl_util=>db_save(
        uname   = `name`
        handle  = `handle1`
        handle2 = `handle2`
        handle3 = `handle3`
        data    = ls_row ).

    z2ui5_cl_util=>db_load_by_id(
      EXPORTING
        id     = lv_id
      IMPORTING
        result = ls_row_result ).

    cl_abap_unit_assert=>assert_equals(
        act = ls_row_result
        exp = ls_row ).

    CLEAR ls_row_result.
    z2ui5_cl_util=>db_load_by_handle(
      EXPORTING
        uname   = `name`
        handle  = `handle1`
        handle2 = `handle2`
        handle3 = `handle3`
      IMPORTING
        result  = ls_row_result ).

    cl_abap_unit_assert=>assert_equals(
       act = ls_row_result
       exp = ls_row ).

  ENDMETHOD.

  METHOD test_db_handle_read_id.

    IF sy-sysid = 'ABC'.
      RETURN.
    ENDIF.

    TYPES:
      BEGIN OF ty_row,
        title    TYPE string,
        value    TYPE string,
        selected TYPE abap_bool,
      END OF ty_row.

    DATA(ls_row) = VALUE ty_row(
        title    = `test`
        value    = `val`
        selected = abap_true ).

    DATA(lv_id) = z2ui5_cl_util=>db_save(
        uname   = `name`
        handle  = `handle1`
        handle2 = `handle2`
        handle3 = `handle3`
        data    = ls_row ).

    cl_abap_unit_assert=>assert_not_initial( lv_id ).

    DATA(lv_id2) = z2ui5_cl_util=>db_save(
        uname   = `name`
        handle  = `handle1`
        handle2 = `handle2`
        handle3 = `handle3`
        data    = ls_row ).

    cl_abap_unit_assert=>assert_equals(
        act = lv_id
        exp = lv_id2 ).

  ENDMETHOD.

ENDCLASS.

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

CLASS ltcl_unit_test_abap_api DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.

    METHODS check_input
      IMPORTING
        val           TYPE data
      RETURNING
        VALUE(result) TYPE abap_bool.

    METHODS test_assign             FOR TESTING RAISING cx_static_check.
    METHODS test_eledescr_rel_name  FOR TESTING RAISING cx_static_check.
    METHODS test_classdescr         FOR TESTING RAISING cx_static_check.
    METHODS test_substring_after    FOR TESTING RAISING cx_static_check.
    METHODS test_substring_before   FOR TESTING RAISING cx_static_check.
    METHODS test_string_shift       FOR TESTING RAISING cx_static_check.
    METHODS test_string_replace     FOR TESTING RAISING cx_static_check.
    METHODS test_raise_error        FOR TESTING RAISING cx_static_check.
    METHODS test_xsdbool            FOR TESTING RAISING cx_static_check.
    METHODS test_xsdbool_nested     FOR TESTING RAISING cx_static_check.

ENDCLASS.

CLASS ltcl_unit_test DEFINITION FINAL FOR TESTING
  DURATION MEDIUM
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.

    METHODS test_create               FOR TESTING RAISING cx_static_check.

    METHODS test_boolean_abap_2_json  FOR TESTING RAISING cx_static_check.
    METHODS test_boolean_check        FOR TESTING RAISING cx_static_check.

    METHODS test_c_trim                 FOR TESTING RAISING cx_static_check.
    METHODS test_c_trim_lower           FOR TESTING RAISING cx_static_check.
    METHODS test_c_trim_upper           FOR TESTING RAISING cx_static_check.
    METHODS test_c_trim_horizontal_tab  FOR TESTING RAISING cx_static_check.

    METHODS test_time_get_timestampl       FOR TESTING RAISING cx_static_check.
    METHODS test_time_substract_seconds    FOR TESTING RAISING cx_static_check.
    METHODS test_func_get_user_tech        FOR TESTING RAISING cx_static_check.


    METHODS test_rtti_get_t_attri_by_incl FOR TESTING RAISING cx_static_check.
    METHODS test_rtti_get_classname_by_ref FOR TESTING RAISING cx_static_check.
    METHODS test_rtti_get_type_name        FOR TESTING RAISING cx_static_check.
    METHODS test_rtti_get_type_kind        FOR TESTING RAISING cx_static_check.
    METHODS test_rtti_check_type_kind      FOR TESTING RAISING cx_static_check.
    METHODS test_rtti_get_t_attri_by_obj   FOR TESTING RAISING cx_static_check.
    METHODS test_rtti_get_t_comp_by_struc  FOR TESTING RAISING cx_static_check.

    METHODS test_trans_json_any_2__w_struc  FOR TESTING RAISING cx_static_check.
    METHODS test_trans_xml_any_2__w_obj  FOR TESTING RAISING cx_static_check.
    METHODS test_trans_xml_any_2__w_data FOR TESTING RAISING cx_static_check.
    METHODS test_trans_xml_2_any__w_obj  FOR TESTING RAISING cx_static_check.
    METHODS test_trans_xml_2_any__w_data FOR TESTING RAISING cx_static_check.

    METHODS test_url_param_create_url FOR TESTING RAISING cx_static_check.
    METHODS test_url_param_get        FOR TESTING RAISING cx_static_check.
    METHODS test_url_param_get_tab    FOR TESTING RAISING cx_static_check.
    METHODS test_url_param_set        FOR TESTING RAISING cx_static_check.

    METHODS test_x_check_raise        FOR TESTING RAISING cx_static_check.
    METHODS test_x_check_raise_not    FOR TESTING RAISING cx_static_check.
    METHODS test_x_raise              FOR TESTING RAISING cx_static_check.
    METHODS test_check_unassign_inital FOR TESTING RAISING cx_static_check.
    METHODS conv_copy_ref_data FOR TESTING RAISING cx_static_check.
    METHODS rtti_check_ref_data FOR TESTING RAISING cx_static_check.
    METHODS test_check_bound_a_not_inital FOR TESTING RAISING cx_static_check.
    METHODS test_sql_get_by_string FOR TESTING RAISING cx_static_check.

ENDCLASS.

CLASS ltcl_unit_test_abap_api IMPLEMENTATION.


  METHOD test_assign.

    DATA(lo_app) = NEW ltcl_test_app( ).
    FIELD-SYMBOLS <any> TYPE any.

    lo_app->mv_val = `ABC`.

    DATA(lv_assign) = `LO_APP->` && 'MV_VAL'.
    ASSIGN (lv_assign) TO <any>.
    ASSERT sy-subrc = 0.

    cl_abap_unit_assert=>assert_equals(
        act = <any>
        exp = `ABC` ).

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

    cl_abap_unit_assert=>assert_equals(
      act = lo_ele->get_relative_name( )
      exp = `ABAP_BOOL` ).

  ENDMETHOD.

  METHOD test_substring_after.

    cl_abap_unit_assert=>assert_equals(
      act = substring_after( val = 'this is a string' sub = 'a' )
      exp = ` string` ).

  ENDMETHOD.

  METHOD test_substring_before.

    cl_abap_unit_assert=>assert_equals(
      act = substring_before( val = 'this is a string' sub = 'a' )
      exp = `this is ` ).

  ENDMETHOD.

  METHOD test_string_shift.

    cl_abap_unit_assert=>assert_equals(
      act = shift_left( shift_right( val = `   string   ` sub = ` ` ) )
      exp = `string` ).

  ENDMETHOD.

  METHOD test_string_replace.

    DATA(lv_search) = replace( val  = `one two three`
                               sub  = `two`
                               with = 'ABC'
                               occ  = 0 ) ##NEEDED.

    cl_abap_unit_assert=>assert_equals(
      act = replace( val  = `one two three` sub  = `two` with = 'ABC' occ  = 0 )
      exp = `one ABC three` ).

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
      cl_abap_unit_assert=>assert_equals(
          act = lv_xsdbool
          exp = abap_false ).
    ENDIF.

    IF xsdbool( 1 = 1 ) = abap_false.
      cl_abap_unit_assert=>fail( ).
    ENDIF.

  ENDMETHOD.

  METHOD test_xsdbool_nested.

    DATA(lv_xsdbool) = check_input( xsdbool( 1 = 1 ) ).
    IF lv_xsdbool = abap_false.
      cl_abap_unit_assert=>assert_equals(
        act = lv_xsdbool
        exp = abap_false ).
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
    cl_abap_unit_assert=>assert_equals(
        act = z2ui5_cl_util=>boolean_check_by_data( lv_bool )
        exp = abap_true ).

    lv_bool = xsdbool( 1 = 2 ).
    cl_abap_unit_assert=>assert_equals(
        act = z2ui5_cl_util=>boolean_check_by_data( lv_bool )
        exp = abap_true ).

    cl_abap_unit_assert=>assert_equals(
        act = z2ui5_cl_util=>boolean_check_by_data( abap_true )
        exp = abap_true ).

    cl_abap_unit_assert=>assert_equals(
        act = z2ui5_cl_util=>boolean_check_by_data( abap_false )
        exp = abap_true ).

  ENDMETHOD.

  METHOD test_sql_get_by_string.

    DATA(lv_test) = ``.
    DATA(ls_sql) = z2ui5_cl_util_api=>sql_get_by_string( lv_test ) ##NEEDED.

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

    cl_abap_unit_assert=>assert_true( z2ui5_cl_util_api=>check_bound_a_not_inital( lr_test ) ).
    CLEAR lv_test.
    cl_abap_unit_assert=>assert_false( z2ui5_cl_util_api=>check_bound_a_not_inital( lr_test ) ).
    CLEAR lr_test.
    cl_abap_unit_assert=>assert_false( z2ui5_cl_util_api=>check_bound_a_not_inital( lr_test ) ).

  ENDMETHOD.

  METHOD test_check_unassign_inital.

    DATA(lv_test) = `test`.
    DATA(lr_test) = REF #( lv_test ).

    cl_abap_unit_assert=>assert_false( z2ui5_cl_util_api=>check_unassign_inital( lr_test ) ).

    CLEAR lv_test.
    cl_abap_unit_assert=>assert_true( z2ui5_cl_util_api=>check_unassign_inital( lr_test ) ).

  ENDMETHOD.

  METHOD rtti_check_ref_data.

    DATA(lv_test) = `test`.
    DATA lr_data TYPE REF TO data.
    GET REFERENCE OF lv_test INTO lr_data.

    cl_abap_unit_assert=>assert_equals(
      act = z2ui5_cl_util_api=>rtti_check_ref_data( lr_data )
      exp = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      act = z2ui5_cl_util_api=>rtti_check_ref_data( lv_test )
      exp = abap_false ).

  ENDMETHOD.

  METHOD conv_copy_ref_data.

    DATA(lv_test) = `test`.
    DATA lr_data TYPE REF TO data.
    GET REFERENCE OF lv_test INTO lr_data.

    DATA(lr_test2) = z2ui5_cl_util_api=>conv_copy_ref_data( lr_data ).

    FIELD-SYMBOLS <result> TYPE data.
    ASSIGN lr_test2->* TO <result>.

    cl_abap_unit_assert=>assert_equals(
       act = <result>
       exp = lv_test ).

  ENDMETHOD.

  METHOD test_boolean_abap_2_json.

    cl_abap_unit_assert=>assert_equals(
       act = z2ui5_cl_util=>boolean_abap_2_json( `{ABCD}` )
       exp = `{ABCD}` ).

  ENDMETHOD.

  METHOD test_time_get_timestampl.

    DATA(lv_time) = z2ui5_cl_util=>time_get_timestampl( ).

    DATA(lv_time2) = z2ui5_cl_util=>time_substract_seconds(
         time    = lv_time
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

    cl_abap_unit_assert=>assert_equals(
        act = z2ui5_cl_util=>c_trim( ` JsadfHHs  ` )
        exp = `JsadfHHs` ).

  ENDMETHOD.

  METHOD test_c_trim_lower.

    cl_abap_unit_assert=>assert_equals(
        act = z2ui5_cl_util=>c_trim_lower( ` JsadfHHs  ` )
        exp = `jsadfhhs` ).

  ENDMETHOD.

  METHOD test_c_trim_upper.

    cl_abap_unit_assert=>assert_equals(
        act = z2ui5_cl_util=>c_trim_upper( ` JsadfHHs  ` )
        exp = `JSADFHHS` ).

  ENDMETHOD.

  METHOD test_func_get_user_tech.

    cl_abap_unit_assert=>assert_equals(
      act = sy-uname
      exp = z2ui5_cl_util=>user_get_tech( ) ).

    cl_abap_unit_assert=>assert_not_initial( z2ui5_cl_util=>user_get_tech( ) ).

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

    cl_abap_unit_assert=>assert_equals(
        act = z2ui5_cl_util=>json_stringify( ls_row )
        exp = `{"selected":false,"title":"test","value":""}` ).

  ENDMETHOD.


  METHOD test_url_param_create_url.

    DATA(lt_param) = z2ui5_cl_util=>url_param_get_tab( `https://url.com/rvice_for_ui?sap-client=100&app_start=z2ui5_cl_app_hello_world` ).
    DATA(lv_url) = z2ui5_cl_util=>url_param_create_url( lt_param ).

    cl_abap_unit_assert=>assert_equals(
        act = lv_url
        exp = `sap-client=100&app_start=z2ui5_cl_app_hello_world` ).

  ENDMETHOD.

  METHOD test_url_param_get.

    DATA(lv_param) = z2ui5_cl_util=>url_param_get(
        val = `app_start`
        url = `https://url.com/rvice_for_ui?sap-client=100&app_start=z2ui5_cl_app_hello_world` ).

    cl_abap_unit_assert=>assert_equals(
        act = lv_param
        exp = `z2ui5_cl_app_hello_world` ).

  ENDMETHOD.

  METHOD test_url_param_get_tab.

    DATA(lt_param) = z2ui5_cl_util=>url_param_get_tab( `https://url.com/rvice_for_ui?sap-client=100&app_start=z2ui5_cl_app_hello_world` ).

    cl_abap_unit_assert=>assert_equals(
          act = lt_param[ n = `sap-client` ]-v
          exp = `100` ).

    cl_abap_unit_assert=>assert_equals(
       act = lt_param[ n = `app_start` ]-v
       exp = `z2ui5_cl_app_hello_world` ).

  ENDMETHOD.

  METHOD test_url_param_set.

    DATA(lv_param) = z2ui5_cl_util=>url_param_set(
         name  = `app_start`
         value = `z2ui5_cl_app_hello_world2`
         url   = `https://url.com/rvice_for_ui?sap-client=100&app_start=z2ui5_cl_app_hello_world` ).

    cl_abap_unit_assert=>assert_equals(
          act = lv_param
          exp = `sap-client=100&app_start=z2ui5_cl_app_hello_world2` ).

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
    cl_abap_unit_assert=>assert_equals(
        act = lv_name
        exp = `XSDBOOLEAN` ).

  ENDMETHOD.

  METHOD test_rtti_get_type_kind.

    DATA(lv_string) = VALUE string( ).

    DATA(lv_type_kind) = z2ui5_cl_util=>rtti_get_type_kind( lv_string ).
    DATA lr_string TYPE REF TO string.
    cl_abap_unit_assert=>assert_equals(
        act = lv_type_kind
        exp = cl_abap_typedescr=>typekind_string ).


    CREATE DATA lr_string.
    lv_type_kind = z2ui5_cl_util=>rtti_get_type_kind( lr_string ).
    cl_abap_unit_assert=>assert_equals(
        act = lv_type_kind
        exp = cl_abap_typedescr=>typekind_dref ).

  ENDMETHOD.

  METHOD test_rtti_check_type_kind.

    DATA(lv_string) = VALUE string( ).
    DATA lr_string TYPE REF TO string.
    cl_abap_unit_assert=>assert_equals(
        act = z2ui5_cl_util=>rtti_check_type_kind_dref( lv_string )
        exp = abap_false ).


    CREATE DATA lr_string.
    cl_abap_unit_assert=>assert_equals(
        act = z2ui5_cl_util=>rtti_check_type_kind_dref( lr_string )
        exp = abap_true ).

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

    IF NOT line_exists( lt_attri[ name = `SS_TAB` type_kind = `v` ] ).
      cl_abap_unit_assert=>fail( ).
    ENDIF.

    IF NOT line_exists( lt_attri[ name = `SV_VAR` type_kind = `g` is_class = abap_true ] ).
      cl_abap_unit_assert=>fail( ).
    ENDIF.

    IF NOT line_exists( lt_attri[ name = `SV_STATUS` type_kind = `g` is_class = abap_true is_constant = `X` ] ).
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
    z2ui5_cl_util=>xml_parse(
      EXPORTING
        xml = lv_xml
      IMPORTING
        any = lo_obj ).

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

    z2ui5_cl_util=>xml_parse(
      EXPORTING
        xml = lv_xml
      IMPORTING
        any = ls_row2 ).

    cl_abap_unit_assert=>assert_equals(
        act = ls_row
        exp = ls_row2 ).

  ENDMETHOD.


  METHOD test_c_trim_horizontal_tab.

    IF z2ui5_cl_util=>c_trim( |{ cl_abap_char_utilities=>horizontal_tab }|
                                && |JsadfHHs|
                                && |{ cl_abap_char_utilities=>horizontal_tab }| ) <> `JsadfHHs`.
      cl_abap_unit_assert=>fail( ).

    ENDIF.

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

    DATA
      BEGIN OF ms_struc2.
    INCLUDE TYPE ty_struc.
    INCLUDE TYPE ty_struc_incl.
    DATA  END OF ms_struc2.

    DATA(lo_datadescr) = cl_abap_typedescr=>describe_by_data( ms_struc2 ).
    DATA(lt_attri) = z2ui5_cl_util=>rtti_get_t_attri_by_include( CAST #( lo_datadescr ) ).

    IF lines( lt_attri ) <> 2.
      cl_abap_unit_assert=>fail( ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.
