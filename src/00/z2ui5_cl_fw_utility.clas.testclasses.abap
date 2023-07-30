CLASS ltcl_test_app DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PUBLIC SECTION.

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

    DATA mv_val TYPE string ##NEEDED.
    DATA ms_tab TYPE ty_row ##NEEDED.
    DATA mt_tab TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY ##NEEDED.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS ltcl_test_app IMPLEMENTATION.
ENDCLASS.

CLASS ltcl_unit_test_sap_api DEFINITION FINAL FOR TESTING
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

    METHODS test_check_is_boolean     FOR TESTING RAISING cx_static_check.
    METHODS test_get_abap_2_json      FOR TESTING RAISING cx_static_check.
    METHODS test_create               FOR TESTING RAISING cx_static_check.
    METHODS test_get_classname_by_ref FOR TESTING RAISING cx_static_check.
    METHODS test_get_json_boolean     FOR TESTING RAISING cx_static_check.
    METHODS test_get_replace          FOR TESTING RAISING cx_static_check.
    METHODS test_get_timestampl       FOR TESTING RAISING cx_static_check.
    METHODS test_get_trim_lower       FOR TESTING RAISING cx_static_check.
    METHODS test_get_trim_upper       FOR TESTING RAISING cx_static_check.
    METHODS test_attri_by_ref         FOR TESTING RAISING cx_static_check.
    METHODS test_get_uuid             FOR TESTING RAISING cx_static_check.
    METHODS test_get_user_tech        FOR TESTING RAISING cx_static_check.
    METHODS test_raise                FOR TESTING RAISING cx_static_check.
    METHODS test_any_2_json           FOR TESTING RAISING cx_static_check.
    METHODS test_any_2_json_02        FOR TESTING RAISING cx_static_check.
    METHODS test_trans_ref_tab_2_tab  FOR TESTING RAISING cx_static_check.
    METHODS test_url_param_create_url FOR TESTING RAISING cx_static_check.
    METHODS test_url_param_get        FOR TESTING RAISING cx_static_check.
    METHODS test_url_param_get_tab    FOR TESTING RAISING cx_static_check.
    METHODS url_param_set             FOR TESTING RAISING cx_static_check.
    METHODS test_raise_error_not      FOR TESTING RAISING cx_static_check.
    METHODS test_raise_error          FOR TESTING RAISING cx_static_check.

ENDCLASS.

CLASS ltcl_unit_test_sap_api IMPLEMENTATION.


  METHOD test_assign.

    DATA(lo_app) = NEW ltcl_test_app( ).

    lo_app->mv_val = `ABC`.
    FIELD-SYMBOLS <any> TYPE any.
    DATA(lv_assign) = `LO_APP->` && 'MV_VAL'.
    ASSIGN (lv_assign) TO <any>.

    cl_abap_unit_assert=>assert_equals(
        act  = <any>
        exp  = `ABC` ).

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

    DATA(lv_search) = replace( val  = `one two three` sub  = `two` with = 'ABC' occ  = 0 ).

    cl_abap_unit_assert=>assert_equals(
     act = replace( val  = `one two three` sub  = `two` with = 'ABC' occ  = 0 )
     exp = `one ABC three` ).

  ENDMETHOD.

  METHOD test_raise_error.

    TRY.
        RAISE EXCEPTION TYPE z2ui5_cl_fw_error.
        cl_abap_unit_assert=>fail( ).

      CATCH z2ui5_cl_fw_error INTO DATA(lx).
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

    IF check_input( xsdbool( 2 = 1 ) ).
      cl_abap_unit_assert=>fail( ).
    ENDIF.

  ENDMETHOD.

  METHOD check_input.

    result = val.

  ENDMETHOD.

ENDCLASS.

CLASS ltcl_unit_test IMPLEMENTATION.

  METHOD test_attri_by_ref.

    "dummy for abaplint check green
    ltcl_test_app=>sv_var = ``.
    ltcl_test_app=>ss_tab = VALUE #( ).
    ltcl_test_app=>st_tab = VALUE #( ).

    DATA(lo_app) = NEW ltcl_test_app( ).

    DATA(lt_attri) = z2ui5_cl_fw_utility=>get_t_attri_by_ref( lo_app ).

    DATA(lt_attri_result) = VALUE z2ui5_cl_fw_utility=>ty_t_attri(
  ( name = `MT_TAB` type_kind = `h` type = `` bind_type = `` data_stringify = `` data_rtti = `` check_ref_data = '' )
  ( name = `MV_VAL` type_kind = `g` type = `` bind_type = `` data_stringify = `` data_rtti = `` check_ref_data = '' )
  ( name = `ST_TAB` type_kind = `h` type = `` bind_type = `` data_stringify = `` data_rtti = `` check_ref_data = '' )
  ( name = `SV_STATUS` type_kind = `g` type = `` bind_type = `` data_stringify = `` data_rtti = `` check_ref_data = '' )
  ( name = `SV_VAR` type_kind = `g` type = `` bind_type = `` data_stringify = `` data_rtti = `` check_ref_data = '' )
  ( name = `MS_TAB-TITLE` type_kind = `g` type = `` bind_type = `` data_stringify = `` data_rtti = `` check_ref_data = '' )
  ( name = `MS_TAB-VALUE` type_kind = `g` type = `` bind_type = `` data_stringify = `` data_rtti = `` check_ref_data = '' )
  ( name = `MS_TAB-DESCR` type_kind = `g` type = `` bind_type = `` data_stringify = `` data_rtti = `` check_ref_data = '' )
  ( name = `MS_TAB-ICON` type_kind = `g` type = `` bind_type = `` data_stringify = `` data_rtti = `` check_ref_data = '' )
  ( name = `MS_TAB-INFO` type_kind = `g` type = `` bind_type = `` data_stringify = `` data_rtti = `` check_ref_data = '' )
  ( name = `MS_TAB-SELECTED` type_kind = `C` type = `` bind_type = `` data_stringify = `` data_rtti = `` check_ref_data = '' )
  ( name = `MS_TAB-CHECKBOX` type_kind = `C` type = `` bind_type = `` data_stringify = `` data_rtti = `` check_ref_data = '' )
  ( name = `SS_TAB-TITLE` type_kind = `g` type = `` bind_type = `` data_stringify = `` data_rtti = `` check_ref_data = '' )
  ( name = `SS_TAB-VALUE` type_kind = `g` type = `` bind_type = `` data_stringify = `` data_rtti = `` check_ref_data = '' )
  ( name = `SS_TAB-DESCR` type_kind = `g` type = `` bind_type = `` data_stringify = `` data_rtti = `` check_ref_data = '' )
  ( name = `SS_TAB-ICON` type_kind = `g` type = `` bind_type = `` data_stringify = `` data_rtti = `` check_ref_data = '' )
  ( name = `SS_TAB-INFO` type_kind = `g` type = `` bind_type = `` data_stringify = `` data_rtti = `` check_ref_data = '' )
  ( name = `SS_TAB-SELECTED` type_kind = `C` type = `` bind_type = `` data_stringify = `` data_rtti = `` check_ref_data = '' )
  ( name = `SS_TAB-CHECKBOX` type_kind = `C` type = `` bind_type = `` data_stringify = `` data_rtti = `` check_ref_data = '' )
  ).

    IF lt_attri_result <> lt_attri.
      cl_abap_unit_assert=>fail( msg  = 'utility - create t_attri failed'
                                 quit = 5 ).
    ENDIF.

  ENDMETHOD.

  METHOD test_check_is_boolean.

    DATA(lv_bool) = xsdbool( 1 = 1 ).
    cl_abap_unit_assert=>assert_equals(
        act                  = z2ui5_cl_fw_utility=>check_is_boolean( lv_bool )
        exp                  = abap_true ).

    lv_bool = xsdbool( 1 = 2 ).
    cl_abap_unit_assert=>assert_equals(
        act                  = z2ui5_cl_fw_utility=>check_is_boolean( lv_bool )
        exp                  = abap_true ).

    cl_abap_unit_assert=>assert_equals(
        act                  = z2ui5_cl_fw_utility=>check_is_boolean( abap_true )
        exp                  = abap_true ).

    cl_abap_unit_assert=>assert_equals(
    act                  = z2ui5_cl_fw_utility=>check_is_boolean( abap_false )
    exp                  = abap_true ).

  ENDMETHOD.

  METHOD test_create.

    DATA(lo_test) = NEW z2ui5_cl_fw_utility( ) ##NEEDED.

  ENDMETHOD.

  METHOD test_get_abap_2_json.

    DATA(lv_bool) = xsdbool( 1 = 1 ).
    cl_abap_unit_assert=>assert_equals( exp = `true` act = z2ui5_cl_fw_utility=>get_abap_2_json( lv_bool ) ).

    lv_bool = xsdbool( 1 = 2 ).
    cl_abap_unit_assert=>assert_equals( exp = `false` act = z2ui5_cl_fw_utility=>get_abap_2_json( lv_bool ) ).

  ENDMETHOD.

  METHOD test_get_classname_by_ref.

    DATA(lo_test) = NEW z2ui5_cl_fw_utility( ).
    DATA(lv_name) = z2ui5_cl_fw_utility=>get_classname_by_ref( lo_test ).
    IF lv_name <> `Z2UI5_CL_FW_UTILITY`.
      cl_abap_unit_assert=>fail( quit = 5 ).
    ENDIF.

    DATA(lo_test2) = NEW ltcl_test_app( ).
    DATA(lv_name2) = z2ui5_cl_fw_utility=>get_classname_by_ref( lo_test2 ).
    IF lv_name2 <> `LTCL_TEST_APP`.
      cl_abap_unit_assert=>fail( quit = 5 ).
    ENDIF.

  ENDMETHOD.

  METHOD test_get_json_boolean.

    IF `false` <> z2ui5_cl_fw_utility=>get_json_boolean( abap_false ).
      cl_abap_unit_assert=>fail( quit = 5 ).
    ENDIF.

    IF `ABCD` <> z2ui5_cl_fw_utility=>get_json_boolean( `ABCD` ).
      cl_abap_unit_assert=>fail( quit = 5 ).
    ENDIF.

  ENDMETHOD.

  METHOD test_get_replace.

    DATA(lv_text) = `this is a replace text`.
    DATA(lv_result) = z2ui5_cl_fw_utility=>get_replace(
        iv_val     = lv_text
        iv_begin   = `is a `
        iv_end     = ` te`
        iv_replace = 'is a test te' ).
    IF lv_result <> `this is a test text`.
      cl_abap_unit_assert=>fail( quit = 5 ).
    ENDIF.

  ENDMETHOD.

  METHOD test_get_timestampl.

    DATA(lv_time) = z2ui5_cl_fw_utility=>get_timestampl( ).
    DATA(lv_time2) = z2ui5_cl_fw_utility=>get_timestampl( ).

    IF lv_time2 < lv_time.
      cl_abap_unit_assert=>fail( quit = 5 ).
    ENDIF.

  ENDMETHOD.

  METHOD test_get_trim_lower.

    IF z2ui5_cl_fw_utility=>get_trim_lower( ` JsadfHHs  ` ) <> `jsadfhhs`.
      cl_abap_unit_assert=>fail( quit = 5 ).
    ENDIF.

  ENDMETHOD.

  METHOD test_get_trim_upper.

    IF z2ui5_cl_fw_utility=>get_trim_upper( ` JsadfHHs  ` ) <> `JSADFHHS`.
      cl_abap_unit_assert=>fail( quit = 5 ).
    ENDIF.

  ENDMETHOD.

  METHOD test_get_uuid.

    DATA(lv_uuid) = z2ui5_cl_fw_utility=>get_uuid( ).

    IF lv_uuid IS INITIAL.
      cl_abap_unit_assert=>fail( quit = 5 ).
    ENDIF.

    IF strlen( lv_uuid ) <> 32.
      cl_abap_unit_assert=>fail( quit = 5 ).
    ENDIF.

  ENDMETHOD.

  METHOD test_get_user_tech.

    IF sy-uname <> z2ui5_cl_fw_utility=>get_user_tech( ).
      cl_abap_unit_assert=>fail( quit = 5 ).
    ENDIF.

  ENDMETHOD.

  METHOD test_raise.

    TRY.
        z2ui5_cl_fw_utility=>raise( ).
        cl_abap_unit_assert=>fail( quit = 5 ).
      CATCH cx_root.
    ENDTRY.

    TRY.
        z2ui5_cl_fw_utility=>raise( when = xsdbool( 1 = 1 ) ).
        cl_abap_unit_assert=>fail( quit = 5 ).
      CATCH cx_root.
    ENDTRY.

    TRY.
        z2ui5_cl_fw_utility=>raise( when = xsdbool( 1 = 3 ) ).
      CATCH cx_root.
        cl_abap_unit_assert=>fail( quit = 5 ).
    ENDTRY.

  ENDMETHOD.

  METHOD test_any_2_json.

    TYPES:
      BEGIN OF ty_row,
        title    TYPE string,
        value    TYPE string,
        selected TYPE abap_bool,
      END OF ty_row.
    TYPES ty_t_tab TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.

    DATA(lt_tab) = VALUE ty_t_tab( ( title = 'Test'  value = 'this is a description' selected = abap_true )
                                   ( title = 'Test2' value = 'this is a new descr'   selected = abap_false ) ).


    DATA(lv_tab_json) = z2ui5_cl_fw_utility=>trans_any_2_json( lt_tab ).

    DATA(lv_result) = `[{"TITLE":"Test","VALUE":"this is a description","SELECTED":true},{"TITLE":"Test2","VALUE":"this is a new descr","SELECTED":false}]`.

    IF lv_result <> lv_tab_json.
      cl_abap_unit_assert=>fail( quit = 5 ).
    ENDIF.

  ENDMETHOD.


  METHOD test_any_2_json_02.

    TYPES:
      BEGIN OF ty_row,
        title    TYPE string,
        value    TYPE string,
        selected TYPE abap_bool,
      END OF ty_row.
    TYPES ty_t_tab TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.

    DATA(lt_tab) = VALUE ty_t_tab( ( title = 'Test'  value = 'this is a description' selected = abap_true )
                                   ( title = 'Test2' value = 'this is a new descr'   selected = abap_false ) ).

    DATA(lt_tab2) = VALUE ty_t_tab( ).
    DATA(lv_tab) = z2ui5_cl_fw_utility=>trans_any_2_json( lt_tab ).

    /ui2/cl_json=>deserialize( EXPORTING json = lv_tab
                               CHANGING  data = lt_tab2 ).

    IF lt_tab <> lt_tab2.
      cl_abap_unit_assert=>fail( quit = 5 ).
    ENDIF.

  ENDMETHOD.

  METHOD test_trans_ref_tab_2_tab.

    TYPES:
      BEGIN OF ty_row,
        title    TYPE string,
        value    TYPE string,
        selected TYPE abap_bool,
      END OF ty_row.
    TYPES ty_t_tab TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.

    DATA(lv_result) = `[{"TITLE":"Test","VALUE":"this is a description","SELECTED":true},{"TITLE":"Test2","VALUE":"this is a new descr","SELECTED":false}]`.

    DATA lo_data TYPE REF TO data.
    /ui2/cl_json=>deserialize( EXPORTING json = lv_result
                               CHANGING  data = lo_data ).

    DATA(lt_tab2) = VALUE ty_t_tab( ).
    z2ui5_cl_fw_utility=>trans_ref_tab_2_tab(
        EXPORTING ir_tab_from = lo_data
        IMPORTING t_result    = lt_tab2 ).


    DATA(lt_tab) = VALUE ty_t_tab( ( title = 'Test'  value = 'this is a description' selected = abap_true )
                                   ( title = 'Test2' value = 'this is a new descr'   selected = abap_false ) ).

    IF lt_tab <> lt_tab2.
      cl_abap_unit_assert=>fail( quit = 5 ).
    ENDIF.

  ENDMETHOD.

  METHOD test_url_param_create_url.

    DATA(lt_param) = z2ui5_cl_fw_utility=>url_param_get_tab( `https://url.com/rvice_for_ui?sap-client=100&app_start=z2ui5_cl_app_hello_world` ).
    DATA(lv_url) = z2ui5_cl_fw_utility=>url_param_create_url( lt_param ).

    IF lv_url <> `sap-client=100&app_start=z2ui5_cl_app_hello_world`.
      cl_abap_unit_assert=>fail( quit = 5 ).
    ENDIF.

  ENDMETHOD.

  METHOD test_url_param_get.

    DATA(lv_param) = z2ui5_cl_fw_utility=>url_param_get(
        val = `app_start`
        url = `https://url.com/rvice_for_ui?sap-client=100&app_start=z2ui5_cl_app_hello_world` ).

    IF lv_param <> `z2ui5_cl_app_hello_world`.
      cl_abap_unit_assert=>fail( quit = 5 ).
    ENDIF.

  ENDMETHOD.

  METHOD test_url_param_get_tab.

    DATA(lt_param) = z2ui5_cl_fw_utility=>url_param_get_tab( `https://url.com/rvice_for_ui?sap-client=100&app_start=z2ui5_cl_app_hello_world` ).
    IF lt_param[ n = `sap-client` ]-v <> `100`.
      cl_abap_unit_assert=>fail( quit = 5 ).
    ENDIF.

    IF lt_param[ n = `app_start` ]-v <> `z2ui5_cl_app_hello_world`.
      cl_abap_unit_assert=>fail( quit = 5 ).
    ENDIF.

  ENDMETHOD.

  METHOD url_param_set.

    DATA(lv_param) = z2ui5_cl_fw_utility=>url_param_set(
         name  = `app_start`
         value = `z2ui5_cl_app_hello_world2`
         url   = `https://url.com/rvice_for_ui?sap-client=100&app_start=z2ui5_cl_app_hello_world` ).

    IF lv_param <> `sap-client=100&app_start=z2ui5_cl_app_hello_world2`.
      cl_abap_unit_assert=>fail( quit = 5 ).
    ENDIF.

  ENDMETHOD.

  METHOD test_raise_error.

    TRY.
        z2ui5_cl_fw_utility=>raise( `error occured` ).
        cl_abap_unit_assert=>fail( ).

      CATCH z2ui5_cl_fw_error INTO DATA(lx).

*        cl_abap_unit_assert=>assert_equals(
*            act                  = lx->get_text( )
*            exp                  = `error occured` ).

    ENDTRY.
  ENDMETHOD.

  METHOD test_raise_error_not.

    TRY.
        z2ui5_cl_fw_utility=>raise( when = xsdbool( 1 = 2 ) ).

      CATCH z2ui5_cl_fw_error INTO DATA(lx).
        cl_abap_unit_assert=>fail( quit = 5 ).
    ENDTRY.
  ENDMETHOD.

ENDCLASS.
